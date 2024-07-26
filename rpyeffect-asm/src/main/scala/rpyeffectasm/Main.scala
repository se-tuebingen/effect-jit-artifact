package rpyeffectasm
import rpyeffectasm.asm
import rpyeffectasm.asm.*
import rpyeffectasm.util.ErrorReporter
import rpyeffectasm.util.Phase
import rpyeffectasm.rpyeffect
import rpyeffectasm.util.{FileTarget, StdoutTarget}
import rpyeffectasm.util.{Output, Source, Target}
import rpyeffectasm.util.JsonDebugPrinter
import rpyeffectasm.mcore
import rpyeffectasm.main.Config
import rpyeffectasm.main.Format.*
import rpyeffectasm.main.*
import rpyeffectasm.mcore.{ATerm, OrganizeValueBindings}

import scala.collection.mutable
import scala.io.Source

def mcoreToAsm = (mcore.Desugar
  >> mcore.ANF
  >> new mcore.Dealiasing[mcore.Var] // TODO fix that this is preserved over CC,LL
  >> mcore.ClosureConversion
  >> mcore.ANF
  >> mcore.LambdaLifting
  >> new mcore.Dealiasing[mcore.Var]
  >> new OrganizeValueBindings[mcore.Var]
  >> mcore.ANF
  >> new mcore.Transformer)
def asmToRpyeffect = ((new asm.Elaboration)
  >> new asm.RegisterAllocation
  >> new asm.BlockNumbering
  >> new TailOpt
  >> new asm.Transformer)

val typer = (new mcore.Typer.Check[ATerm]())
def typecheckIntermediate[F,T](p: Phase[F, T]): Phase[F,T] = p.mapPrimitiveSubphases{ [F,T] => (sp: Phase[F,T]) =>
  sp >-> (typer.withName( s"[typecheck result of ${sp.name}]").dontMap.ignoreFatals orElse Phase.drop)
}

def plan(c: Config): Phase[Source, Output] = {
  // first, apply individual configs
  val aMCoreToAsm = c.typecheck match {
    case Typecheck.Never => mcoreToAsm
    case Typecheck.AtStart => Phase.id >-> typer >> mcoreToAsm
    case Typecheck.Intermediate => Phase.id >-> typer.ignoreFatals.withName("[typecheck input]").dontMap >> typecheckIntermediate(mcoreToAsm)
  }

  // then, compose to complete plan
  def basicPlan(src: Format, target: Format): Phase[Source, Output] = (src, target) match {
    // Pretty-printers / conversions
    case (f: AsmFormat, t: AsmFormat) => f.parser >> t.printer
    case (f: MCoreFormat, t: MCoreFormat) if c.typecheck == Typecheck.AtStart =>
      f.parser >-> typer >> t.printer
    case (f: MCoreFormat, t: MCoreFormat) => f.parser >> t.printer
    // Compilation
    case (f: AsmFormat, t: RPyeffectFormat) => f.parser >> asmToRpyeffect >> t.printer
    case (f: MCoreFormat, t: AsmFormat) => f.parser >> aMCoreToAsm >> t.printer
    case (f: MCoreFormat, t: RPyeffectFormat) => f.parser >> aMCoreToAsm >> asmToRpyeffect >> t.printer
    // Running
    case (_, ExecutionResult) => basicPlan(src, RPyeffectExecutable()) >> Runner
    // Error
    case (f, t) => sys error s"Conversion/compilation from ${f} to ${t} is not supported."
  }
  val res = basicPlan(c.inputFormat, c.outputFormat)
  val rres = if c.debug then debug(c, res) else res
  var index = 0
  rres.mapPrimitiveSubphases{ [F,T] => (p: Phase[F,T]) =>
    index += 1
    val i = index
    p.wrap{ run => r => errorReporter ?=> ErrorReporter.withLocation(s"${i}_${p.name}"){ run(r) } }
  }
}

def debug[F,T](c: Config, p: Phase[F,T]): Phase[F,T] = {
  import rpyeffectasm.util.{DebugInfo, /}
  common.Primitives.defaultPrimitiveContext.cliArgs = c.runArgs
  DebugInfo.active = true
  val to = c.debugTo
  // output plan
  FileTarget(to / "plan").fromString(p.name)
  // output intermediate results
  var index = 1
  p.mapPrimitiveSubphases{ [F,T] => (p: Phase[F,T]) =>
    Phase.exec(new Phase[F, Unit] {
      override def apply(f: F)(using ErrorReporter): Unit = {
        val thename = f"${index}%02d_${p.name}%s"
        if(c.checkContracts){ ErrorReporter.catchExit{ ErrorReporter.exceptionsAsErrors(s"${thename}:\n Precondition failed: "){ p.precondition(f) } } }
      }
    }.dontMap) >> p >-> (new Phase[T, Unit] {
      override def apply(f: T)(using ErrorReporter): Unit = {
        val thename = f"${index}%02d_${p.name}%s"
        index +=1
        System.err.println(s"[${Console.BLUE} DEBUG ${Console.RESET}] Phase ${thename} ran successfully.")

        def go[T](suffix: String, f: T): Unit = {
          // TODO this should be a proper thing
          f match {
            case program: asm.Program[asm.AsmFlags, asm.Id, asm.Id, asm.Id]@unchecked =>
              asm.AsmPrettyPrinter(program).emitTo(FileTarget(to / s"${thename}${suffix}_out.asm"))
              asm.JsonPrettyPrinter(program).emitTo(FileTarget(to / s"${thename}${suffix}_out.asm.json"))
              val renamed = (new Renamer)(program)
              asm.AsmPrettyPrinter(renamed).emitTo(FileTarget(to / s"${thename}${suffix}_out.renamed.asm"))
              asm.JsonPrettyPrinter(renamed).emitTo(FileTarget(to / s"${thename}${suffix}_out.renamed.asm.json"))
              if(c.runIntermediate) {
                val r = asm.Interpreter(program)
                (FileTarget(to / s"${thename}${suffix}_interpreter_log.pretty.txt")).fromString(r.pretty(program))
                (FileTarget(to / s"${thename}${suffix}_interpreter_log.json")).fromString(r.json(program))
              }
            case program: mcore.Program[mcore.ATerm]@unchecked =>
              mcore.SExpPrettyPrinter(program).emitTo(FileTarget(to / s"${thename}${suffix}_out.mcore.sexp"))
              mcore.JsonPrettyPrinter(program).emitTo(FileTarget(to / s"${thename}${suffix}_out.mcore.json"))
              val renamed = (new mcore.Renamer)(program)
              mcore.SExpPrettyPrinter(renamed).emitTo(FileTarget(to / s"${thename}${suffix}_out.renamed.mcore.sexp"))
              mcore.JsonPrettyPrinter(renamed).emitTo(FileTarget(to / s"${thename}${suffix}_out.renamed.mcore.json"))
              if(c.runIntermediate) {
                val libLoader = new mcore.LibLoader[ATerm] {
                  override def loadLib(path: String): Option[mcore.Program[ATerm]] = {
                    ErrorReporter.catchExit {
                      // Translate filename to mcore, correct phase
                      val mpath = java.io.File(path).getName
                      val debugpath = to.getParentFile / mpath / s"${thename}${suffix}_out.mcore.json"
                      mcore.JsonParser()(io.Source.fromFile(debugpath))
                    }
                  }
                }
                val r = mcore.Interpreter(loader = libLoader)(program)
                r.json.emitTo(FileTarget(to / s"${thename}${suffix}_interpreter_log.json"))
                // TODO
              }
            case (fst, snd) =>
              go(suffix + "_fst", fst); go(suffix + "_snd", snd)
            case t => // fallback to generic json serialization
              JsonDebugPrinter(t).emitTo(FileTarget(to / s"${thename}${suffix}_out.json"))
          }
        }

        go("", f)
        if(c.checkContracts){ ErrorReporter.catchExit { ErrorReporter.exceptionsAsErrors(s"${thename}:\n Postcondition failed: "){ p.postcondition(f) } } }
      }
    }.dontMap)
  }
}
@main
def the_main(cliArgs: String*) = {
  import ErrorReporter.*
  catchExitOutside { withErrorsToStderr { withErrorsToDebugInfo {
        val config = Config.parse(cliArgs)
        if (config.debug) {
          scala.io.Source
          System.err.println(s"[${Console.BLUE} DEBUG ${Console.RESET}] Running on input ${config.inputName}.")
        }
        try {
          val thePlan = plan(config)
          thePlan(config.input).emitTo(config.output)
          0
        } finally {
          if (config.debug) {
            import rpyeffectasm.util.{DebugInfo, /}
            DebugInfo.emitTo(FileTarget(config.debugTo / "debuginfo.json"))
          }
        }
  }}}.getOrElse(1)
}