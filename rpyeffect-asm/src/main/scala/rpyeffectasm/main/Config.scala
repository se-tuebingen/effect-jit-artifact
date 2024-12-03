package rpyeffectasm.main

import rpyeffectasm.{asm, mcore, rpyeffect}
import rpyeffectasm.util.{StdoutTarget, Target, Phase, Output, ErrorReporter, Emit}
import scala.sys.process.*

import scala.io.Source
import scopt.OParser

object Exit extends Throwable

type MCoreProgram = mcore.Program[mcore.ATerm]
type AsmProgram = asm.Program[asm.AsmFlags, asm.Id, asm.Id, asm.Id]

sealed trait Format {
  type T
  def parser: Phase[Source, T]
  def printer: Phase[T, Output]
}
object Format {
  sealed trait AsmFormat extends Format {
    type T = AsmProgram
  }
  object Asm extends AsmFormat {
    def parser = (new asm.AsmParser).asInstanceOf // FIXME
    def printer = asm.AsmPrettyPrinter
  }
  object AsmJson extends AsmFormat {
    def parser = (new asm.JsonParser).asInstanceOf // FIXME
    def printer = asm.JsonPrettyPrinter
  }
  sealed trait MCoreFormat extends Format {
    type T = MCoreProgram
  }
  object MCoreJson extends MCoreFormat {
    def parser = new mcore.JsonParser
    def printer = mcore.JsonPrettyPrinter
  }
  object MCoreSExp extends MCoreFormat {
    def parser = mcore.SExpParser
    def printer = mcore.SExpPrettyPrinter
  }
  sealed trait RPyeffectFormat extends Format {
    final type T = rpyeffect.Program
    final def parser = sys error "RPyeffect is not supported for input."
  }
  object RPyeffect extends RPyeffectFormat {
    def printer = rpyeffect.PrettyPrinter
  }
  case class RPyeffectExecutable(shebang: String = "/usr/bin/env rpyeffect-jit") extends RPyeffectFormat {
    def printer = new Phase[T, Output] {
      import rpyeffect.{PrettyPrinter, Program}

      override def apply(f: Program)(using ErrorReporter): Output = new Output {
        override def emitTo[T](t: Target[T]): T = {
          import rpyeffectasm.util.{EmitTarget, FileTarget, StringTarget}
          val result = t.collecting{
            Emit.emit(s"#!${shebang}\n");
            PrettyPrinter.apply(f).emit
          }
          // If emitting into file, make it executable
          t match {
            case target: FileTarget =>
              // TODO is there a system-independent API for this? (but then, shebangs aren't either)
              Process(List("chmod", "+x", target.filename.getAbsolutePath)).!!
            case _ => ()
          }
          result
        }
      }
    }
  }
  object ExecutionResult extends Format {
    final type T = Output
    final def parser = sys error "Cannot parse results of running an executable."
    def printer = Runner
  }

  type ProgramType
  extension(self: Format) {
    def fileExtension: String = self match {
      case Asm => ".asm"
      case AsmJson => ".asm.json"
      case MCoreJson => ".mcore.json"
      case MCoreSExp => ".mcore.sexp"
      case RPyeffectExecutable(_) => ""
      case RPyeffect => ".rpyeffect"
      case ExecutionResult => ".out"
    }

    def argumentString: String = self match {
      case Asm => "asm-pretty"
      case AsmJson => "asm"
      case MCoreJson => "mcore-json"
      case MCoreSExp => "mcore-sexp"
      case RPyeffect => "rpyeffect"
      case RPyeffectExecutable("/usr/bin/env rpyeffect-jit") => "exe"
      case RPyeffectExecutable(shebang) => s"exe:${shebang}"
      case ExecutionResult => "do-exec"
    }

    def canBeParsed: Boolean = self match {
      case _: RPyeffectFormat => false
      case _ => true
    }

  }

  def fromFileSpecifier(s: String): Option[Format] = {
    if s == "-" then None else try {
      Some(Format.values.filter { f => s.endsWith(f.fileExtension) }.maxBy { f => f.fileExtension.length })
    } catch {
      case _: UnsupportedOperationException => None
    }
  }

  val values = List(Asm, AsmJson, MCoreJson, MCoreSExp, RPyeffect, RPyeffectExecutable())
}

enum Typecheck {
  case Never, AtStart, Intermediate
}

/**
 * `Opt`: For optional parameters, will be filled with defaults by [[Config.withDefaults]]
 */
case class IncompleteConfig
(
  input: String = "-",
  inputIsLiteral: Boolean = false,
  inputFormat: Option[Format] = None,
  output: Option[String] = None,
  outputFormat: Option[Format] = None,
  debug: Boolean = false,
  typecheck: Typecheck = Typecheck.Never,
  runIntermediate: Boolean = false,
  checkContracts: Boolean = false,
  runArgs: List[String] = Nil
) {
  def complete: Config = {
    val tOutputFormat: Format = outputFormat.orElse{ output.flatMap(Format.fromFileSpecifier) }.getOrElse{ Format.RPyeffectExecutable() }
    val tInputFormat: Format = if inputIsLiteral then inputFormat.getOrElse { Format.MCoreSExp }
                               else inputFormat.orElse { Format.fromFileSpecifier(input) }.getOrElse { Format.MCoreSExp }
    Config(
      input = if inputIsLiteral then Source.fromString(input) else rpyeffectasm.util.Source.fromSpecifier(input),
      inputName = input,
      inputFormat = tInputFormat,
      output = rpyeffectasm.util.Target.fromSpecifier(output.getOrElse{ input match {
        case "-" => "-"
        case _ if tOutputFormat == Format.ExecutionResult => "-"
        case f if tOutputFormat.fileExtension == "" && !f.endsWith(tInputFormat.fileExtension) =>
          // special cased so we always have output != input with default settings
          assert(tOutputFormat.isInstanceOf[Format.RPyeffectExecutable])
          f ++ ".exe"
        case f => f.stripSuffix(tInputFormat.fileExtension) ++ tOutputFormat.fileExtension
      }}),
      outputFormat = tOutputFormat,
      debug = debug,
      typecheck = typecheck,
      runIntermediate = runIntermediate,
      checkContracts = checkContracts,
      runArgs = runArgs
    )
  }
}
case class Config
(
  input: Source,
  inputName: String,
  inputFormat: Format,
  output: Target[Unit],
  outputFormat: Format,
  debug: Boolean = false,
  typecheck: Typecheck = Typecheck.Never,
  runIntermediate: Boolean = false,
  checkContracts: Boolean = false,
  runArgs: List[String] = Nil,
) {

  lazy val debugTo: java.io.File = {
    import rpyeffectasm.util./
    val targetfile = output match {
      case target: rpyeffectasm.util.FileTarget =>
        target.filename
      case _ =>
        java.io.File(".", "_interactive_")
    }
    val res = targetfile.getParentFile / ".debugout" / s"${targetfile.getName}"
    assert(res.isDirectory || res.mkdirs())
    res
  }
}
object Config {
  given sourceRead: scopt.Read[Source] = scopt.Read.stringRead.map(rpyeffectasm.util.Source.fromSpecifier)
  given targetRead: scopt.Read[Target[Unit]] = scopt.Read.stringRead.map(rpyeffectasm.util.Target.fromSpecifier)
  given formatRead: scopt.Read[Format] = scopt.Read.stringRead.map{
    case "asm-pretty" => Format.Asm
    case "asm" => Format.AsmJson
    case "mcore-json" => Format.MCoreJson
    case "mcore-sexp" => Format.MCoreSExp
    case "jit" => Format.RPyeffect
    case "exe" => Format.RPyeffectExecutable()
    case "do-exec" => Format.ExecutionResult
    case f if f.startsWith("exe:") => Format.RPyeffectExecutable(f.substring("exe:".length))
    case format => sys error s"Unknown format ${format}"
  }
  def parser = {
    val builder = OParser.builder[IncompleteConfig]
    import builder._
    OParser.sequence(
      programName("rpyeffectasm"),
      note("Program to convert mcore or rpyeffect-asm code to rpyeffect bytecode that can be executed by the rpyeffect-jit. " +
        "Also supports converting between supported input formats on the same level or mcore -> asm."),
      note("\nInput options:"),
      arg[String]("input")
        .required()
        .text("The file to read the input from, or - for stdin")
        .action((f,c) => c.copy(input = f)),
      opt[Format]('f', "from")
        .optional()
        .text(s"The format of the input (one of: ${Format.values.filter(_.canBeParsed).map(_.argumentString).mkString(", ")})")
        .action((f,c) => c.copy(inputFormat = Some(f))),
      opt[Unit]('e', "expr")
        .optional()
        .action((_, c) => c.copy(inputIsLiteral = true))
        .text("Interpret the input as a source program directly, not as a file name"),
      note("\nOutput options:"),
      arg[String]("output")
        .optional()
        .text("The file to write the output to, or - for stdout")
        .action((t,c) => c.copy(output = Some(t))),
      opt[Format]('t', "to")
        .optional()
        .text(s"The format of the output (one of: ${Format.values.map(_.argumentString).mkString(", ")})." +
          "You can also use `exe:$SHEBANG` to set the shebang of the generated file explicitly.")
        .action((t,c) => c.copy(outputFormat = Some(t))),
      note("\nHelp and debugging:"),
      opt[Unit]("debug")
        .optional()
        .action((_, c) => c.copy(debug = true))
        .text("Write all intermediate results into .debugout/filename"),
      opt[Unit]("typecheck")
        .optional()
        .action((_, c) => c.copy(typecheck = Typecheck.AtStart))
        .text("Typecheck input"),
      opt[Unit]("typecheck-intermediate")
        .optional()
        .action((_, c) => c.copy(typecheck = Typecheck.Intermediate))
        .text("Typecheck all intermediate mcore results (including input)"),
      opt[Unit]("run-intermediate")
        .optional()
        .action((_, c) => c.copy(runIntermediate = true))
        .text("Run the slow debug interpreter on all intermediate asm results. Requires --debug"),
      opt[Unit]("check")
        .optional()
        .action((_, _) => sys exit(0))
        .text("Exit with exit code 0."),
      opt[Unit]("check-contracts")
        .optional()
        .action((_, c) => c.copy(checkContracts = true))
        .text("Check pre- and postconditions of phases when running them"),
      help("help").text("prints this help text")
    )
  }

  def parse(args: Seq[String])(using ErrorReporter): Config =
    OParser.parse(parser, args.takeWhile(_ != "--"), IncompleteConfig(runArgs = args.dropWhile(_ != "--").drop(1).toList)) match {
      case Some(value) => value.complete
      case None => ErrorReporter.fatal("Could not parse cli parameters")
    }
}