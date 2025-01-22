package rpyeffectasm
package asm
import rpyeffectasm.util.Phase

import scala.io.Source
import scala.util.parsing.combinator.*

class AsmParser extends RegexParsers with Phase[Source, Program[AsmFlags, Id, Id, Id]] {
  import rpyeffectasm.util.ErrorReporter

  import scala.util.matching.Regex
  type Flags = AsmFlags
  type Tag = Id
  type Label = Id
  type V = Id

  def string: Parser[String] = """["]([^"\\]|(\\.))*["]""".r ^^ { s => s.stripPrefix("\"").stripSuffix("\"") }
  def id: Parser[Id]
  = "$" ~> """[A-Za-z0-9]+""".r ^^ { n => Name(n): V }
    | "#" ~> """[0-9]+""".r ~ opt("%" ~> string) ^^ {
        case i ~ None => Index(i.toInt): V
        case i ~ Some(d) => IndexWithDebug(i.toInt, util.unescape(d))
      }
  def vid: Parser[V]
  = "$" ~> """[A-Za-z0-9]+""".r ^^ { n => Name(n): V }
    | "#" ~> """[0-9]+""".r ~ opt("%" ~> string) ^^ {
      case i ~ None => Index(i.toInt): V
      case i ~ Some(doc) => IndexWithDebug(i.toInt, doc): V
    }
  def labelid: Parser[Label]
  = "$" ~> """[A-Za-z0-9]+""".r ^^ { n => Name(n): Label }
    | "#" ~> """[0-9]+""".r ~ opt("%" ~> string) ^^ {
      case i ~ None => Index(i.toInt): Label
      case i ~ Some(doc) => IndexWithDebug(i.toInt, doc): Label
    }
  def tagid: Parser[Tag]
  = "$" ~> """[A-Za-z0-9]+""".r ^^ { n => Name(n): Tag }
    | "#" ~> """[0-9]+""".r ~ opt("%" ~> string) ^^ {
        case i ~ None => Index(i.toInt): Tag
        case i ~ Some(doc) => IndexWithDebug(i.toInt, doc): Tag
      }
  def rhsOp: Parser[RhsOperand[Flags, V]]
    = "*" ~> rhsOp ^^ Ref.apply
    | const | variable
  def const: Parser[Const[Flags, LiteralType]]
    = string ^^ Const.apply
    | intConst ^^ Const.apply
    | "true" ^^ { _ => Const(true) } | "false" ^^ { _ => Const(false) }
    | """[0-9]*\.[0-9]*([eE][0-9]+)?""".r ^^ { d => Const.apply(d.toDouble) } // FIXME
    | """[a-zA-Z-][a-zA-Z-]*""".r ~ string ^^ { case fmt ~ p => Const(FormatConst(fmt, p)) }

  def intConst: Parser[Int] = """-?[0-9]+""".r ^^ (_.toInt)
  def variable: Parser[Var[V]]
    = vid ~ opt(":" ~> operandTpe) ^^ {
      case (name ~ Some(tpe)) => asm.Var(name)
      case (name ~ None) => asm.Var(name)
    }

  def lhsOp: Parser[LhsOperand[Flags, V]]
    = "*" ~> rhsOp ^^ Ref.apply
    | variable

  def rhsOpList: Parser[RhsOpList[Flags, V]] = """\(\s*""".r ~> repsep(rhsOp, """\s*,\s*""".r) <~ """\s*\)""".r
  def lhsOpList: Parser[LhsOpList[Flags, V]] = """\(\s*""".r ~> repsep(lhsOp, """\s*,\s*""".r) <~ """\s*\)""".r

  def clause: Parser[Clause[Flags, Label, V]] = (lhsOpList ~ ("""\s*\|\s*""".r ~> rhsOpList) ~ ("""\s*=>\s*""".r ~> labelid)) ^^ {
    case (params ~ env ~ target) => Clause(params, env, target)
  }
  def operandTpe: Parser[Unit] = {
      "int" ^^ { _ => () }
    | "double" ^^ { _ => () }
    | "bool" ^^ { _ => () }
    | "str" ^^ { _ => () }
    | "ptr" ^^ { _ => () }
    | "num" ^^ { _ => () }
    | "Top" ^^ { _ => () }
    | "Bot" ^^ { _ => () }
    | "*" ~> operandTpe ^^ { _ => () }
    | tagid ~ ("(" ~> repsep(tagid ~ ("(" ~> repsep(id ~ (":" ~> operandTpe), ",") <~ ")"), "|") <~ ")") ^^ { case (tpe ~ cnss) =>
        ()
      }
    | tagid ~ ("{" ~> repsep(tagid ~ ("(" ~> repsep(id ~ (":" ~> operandTpe), ",") <~ ")") ~ ("->" ~> operandTpe), ";") <~ "}") ^^ { case (tpe ~ cnss) =>
        ()
      }
  }

  def instruction: Parser[Instruction[Flags, Tag, Label, V]]
    = ("""let\s*const\s*""".r ~> lhsOp) ~ ("""\s*<-\s*""".r ~> const) ^^ {
        case (asm.Var(x) ~ Const(value: Int)) => LetConst(asm.Var(x), value)
        case (asm.Var(x) ~ Const(value: Boolean)) => LetConst(asm.Var(x), value)
        case (asm.Var(x) ~ Const(value: Double)) => LetConst(asm.Var(x), value)
        case (asm.Var(x) ~ Const(value: String)) => LetConst(asm.Var(x), value)
        case (asm.Var(x) ~ Const(cv: FormatConst)) => LetConst(asm.Var(x), cv) // TODO assumes string for now
        case (asm.Ref(r) ~ _) => ???
      }
    | """let\s*""".r ~> repsep(lhsOp ~ ("<-" ~> rhsOp) ^^ { case l ~ r => (l,r) }, """\s*,\s*""".r) ^^ {
          (l: List[(LhsOperand[Flags, V], RhsOperand[Flags, V])]) =>
            val (lhss, rhss) = l.unzip[LhsOperand[Flags, V], RhsOperand[Flags, V]]
            Let(lhss, rhss)
        }
    | lhsOp ~ ("""\s*<-\s*""".r ~> labelid) ~ ("." ~> labelid) ~ rhsOpList ^^ {
        case (out ~ tpe ~ tag ~ args) => Construct(out, tpe, tag, args)
      }
    | (lhsOpList <~ """\s*<-\s*""".r) ~ ("""prim\s*\[""".r ~> """[^\]]*""".r <~ """\]\s*""".r) ~ rhsOpList ^^ {
        case (out ~ prim ~ in) => Primitive(out, prim, in) // TODO require types?
      }
    | (("""debug\s*["]""".r ~> """[^"]*""".r <~ """["]\s*""".r) ~ rhsOpList ^^ {
        case (msg ~ traced) => Debug(rpyeffectasm.util.unescape(msg), traced)
      })
    | ("""jump\s*""".r ~> labelid) ~ rhsOpList ^^ { case (label ~ args) => Jump(label, args) }
    | ("""calllib\s*""".r ~> rhsOp ~ ("""\[""".r ~> """[^\]]*""".r <~ """\]\s*""".r) ~ rhsOpList ^^ {
        case (lib ~ symbol ~ env) => CallLib(lib, symbol, env)
      })
    | ("""loadlib\s*""".r ~> rhsOp) ^^ LoadLib.apply
    | ("""if0\s*""".r ~> rhsOp) ~ ("""\s*jump\s*""".r ~> labelid) ~ rhsOpList ^^ { case (c~l~a) => IfZero(c, Clause(Nil,a,l))}
    | ("""push\s*""".r ~> labelid) ~ rhsOpList ^^ { case (target ~ args) => Push(target, args) }
    | ("""return\s*""".r ~> rhsOpList) ^^ Return.apply
    | (lhsOp <~ """\s*<-\s*""".r) ~ ("""alloc\s+""".r ~> rhsOp) ~ ("""\s*in\s*""".r ~> rhsOp) ^^ {
        case (out ~ init ~ region) => Allocate(out, init, region)
      }
    | (lhsOp <~ """\s*<-\s*""".r) ~ ("""!\s*""".r ~> rhsOp) ^^ { case (out~ref) => Load(out, ref)}
    | ("""!\s*""".r ~> rhsOp <~ """\s*<-\s*""".r) ~ rhsOp ^^ { case (ref~v) => Store(ref, v)}
    | (lhsOp <~ """\s*<-\s*""".r) ~ ("""shift\s*""".r ~> rhsOp) ~ ("""\s*,\s*""".r ~> rhsOp) ^^ {
      case (out ~ n ~ label) => Shift(out, n, label)
    }
    | (lhsOp <~ """\s*<-\s*""".r) ~ ("""get dynamic\s*""".r ~> rhsOp) ~ ("""\s*,\s*""".r ~> rhsOp) ^^ {
      case (out ~ n ~ label) => GetDynamic(out, n, label)
    }
    | (lhsOp <~ """\s*<-\s*""".r) ~ ("""control\s*""".r ~> rhsOp) ~ ("""\s*,\s*""".r ~> rhsOp) ^^ {
        case (out ~ n ~ label) => Control(out, n, label)
      }
    | """push\s*stack\s*""".r ~> rhsOp ^^ PushStack.apply
    | lhsOp ~ ("""\s*\(\s*""".r ~> lhsOp) ~ ("""\)\s*<-\s*new\s*stack\s*""".r~>rhsOp) ~ opt("with" ~> rhsOp) ~ ("""\s*=>\s*""".r~>labelid) ~ rhsOpList ^^ {
    case (stack ~ region ~ label ~ None ~ target ~ args) => NewStack(stack, region, label, target, args)
    case (stack ~ region ~ label ~ Some(bnd) ~ target ~ args) => NewStackWithBinding(stack, region, label, target, args, bnd)
  }
    | ("""match\s*""".r ~> rhsOp) ~ (":" ~> labelid)
      ~ rep(labelid ~ lhsOpList ~ ("=>" ~> labelid) ~ rhsOpList <~ "|")
      ~ (("_" ~ "=>") ~> labelid ~ rhsOpList) ^^ {
        case (scrutinee ~ tpe ~ clauses ~ (default ~ dfrees)) => Match(tpe, scrutinee, clauses map {
          case (tag ~ params ~ target ~ frees) => (tag, Clause(params, frees, target))
        }, Clause(Nil, dfrees, default))
      }
    | ("""switch\s*""".r ~> rhsOp ~ rhsOpList) ~ rep(intConst ~ ("=>" ~> labelid)) ~ (("_" ~ "=>") ~> labelid) ^^ {
        case ((arg ~ env) ~ cases ~ default) =>
          Switch(arg, cases.map{ case v ~ t => v -> t }, default, env)
      }
    | lhsOp ~ ("""\s*<-\s*""".r ~> rhsOp) ~ ("""\s*:\s*""".r ~> labelid) ~ ("." ~> labelid) ~ ("#" ~> """[0-9]+""".r) ^^ {
        case (out ~ scrutinee ~ tpe ~ tag ~ field) => Proj(out, tpe, scrutinee, tag, field.toInt)
      }
    | lhsOp ~ ("<-" ~> labelid) ~ rhsOpList
      ~ ("{" ~> repsep(labelid ~ ("=>" ~> labelid), ";") <~ "}") ^^ {
        case (out ~ ifce ~ args ~ targets) => New(out, ifce, targets map {
          case (tag ~ target) => (tag, target)
        }, args)
      }
    | rhsOp ~ ("""\s*:\s*""".r ~> labelid) ~ ("." ~> labelid) ~ rhsOpList ^^ {
        case (receiver ~ tpe ~ tag ~ args) => Invoke(receiver, tpe, tag, args)
      }
    | comment ~> instruction

    // TODO

  def comment: Parser[Unit] = rep1("""/\*((?!\*/).)*\*/""".r) ^^ { _ => () }

  def block: Parser[Block[Flags, Tag, Label, V]] =
    (("""@export\s*\(\s*""".r ~> repsep(string, "\\s*,\\s*".r) <~ "\\s*\\)\\s*".r ) ~ labelid ~ lhsOpList  ~ opt(":" ~> operandTpe) ~ ("""\s*\{\s*""".r ~> repsep(instruction, """\s*;\s*""".r) <~ (opt(comment) ~ """\s*\}""".r)) ^^ {
      case (export_as ~ label ~ params ~ ret ~ instructions) =>
        Block(label, params.asInstanceOf, instructions, export_as) // TODO replace `asInstanceOf` with actual check
    }) | (labelid ~ lhsOpList ~ opt(":" ~> operandTpe) ~ ("""\s*\{\s*""".r ~> repsep(instruction, """\s*;\s*""".r) <~ (opt(comment) ~ """\s*\}""".r)) ^^ {
      case (label ~ params ~ ret ~ instructions) =>
        Block(label, params.asInstanceOf, instructions, Nil) // TODO replace `asInstanceOf` with actual check
    }) | comment ~> block

  def program: Parser[Program[Flags, Tag, Label, V]] = ("""\s*""".r ~> repsep(block, """\s*""".r) <~ """\s*""".r) ^^ Program.apply
                                                           | comment ~> program

  override def apply(f: Source)(using ErrorReporter): Program[Flags, Label, Label, Label] = {
    parse(program, f.mkString) match {
      case Success(result, next) if next.atEnd => result
      case Success(result, next) => error(s"Trailing garbage: '${next.source.subSequence(next.offset, next.source.length())}'"); result
      case e: NoSuccess => fatal(e.msg)
    }
  }
}