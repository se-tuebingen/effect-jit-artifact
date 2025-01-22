package rpyeffectasm.mcore
import scala.io.Source
import rpyeffectasm.util.{ErrorReporter, Phase}
import rpyeffectasm.common.Purity

import scala.util.parsing.combinator.{JavaTokenParsers, RegexParsers}

object SExpParser extends Phase[Source, Program[ATerm]] with RegexParsers with JavaTokenParsers {

  import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}

  override def skipWhitespace: Boolean = true
  def maybeComment: Parser[Unit] = rep(""";;[^\n]*\n""".r) ^^ { _ => () }
  def list[T](of: Parser[T]): Parser[List[T]] = ("(" ~ maybeComment) ~> rep(of) <~ (maybeComment ~ ")")
  def tuple[T](of: Parser[T]): Parser[T] = ("(" ~ maybeComment) ~> of <~ (maybeComment ~ ")")
  def id: Parser[Id] = {
    """\$(("([^"\\]|(\\.))*")|([^:)"\s]*))""".r ^^ { n =>
        if n.startsWith("$\"")
        then Name(StringContext.processEscapes(n.substring(2, n.length-1)))
        else Name(n.substring(1))
      }
    | """#[0-9]+""".r ^^ { i => Index(i.substring(1).toInt)}
  }
  def assocKey: Parser[String] =
    """:\|[^|]*\|""".r ^^ { s => s.stripPrefix(":|").stripSuffix("|") }
  def v: Parser[Var] = id ~ (":" ~> tpe) ^^ { case x ~ t => Var(x,t) }
  def lhsOp: Parser[LhsOperand] = v
  def purity: Parser[Purity] = Purity.values.map{ v =>
    v.productPrefix ^^ { _ => v}
  }.reduce(_ | _)
  def methodTpe: Parser[Method] = tuple(id ~ list(tpe) ~ tpe) ^^ { case n ~ ps ~ r => Method(n, ps, r) }
  def constructorTpe: Parser[Constructor] = tuple(id ~ rep(tpe)) ^^ { case n ~ fs => Constructor(n, fs) }
  def tpe: Parser[Type] = {
    "top" ^^ { _ => Top }
    | "ptr" ^^ { _ => Ptr }
    | "num" ^^ { _ => Num }
    | "bot" ^^ { _ => Bottom }
    | "int" ^^ { _ => Base.Int }
    | "unit" ^^ { _ => Base.Unit }
    | "bool" ^^ { _ => Base.Bool }
    | "double" ^^ { _ => Base.Double }
    | "str" ^^ { _ => Base.String }
    | "label" ^^ { _ => Base.Label(Top, None) }
    | tuple("label" ~> opt(tpe ~ opt(tpe))) ^^ {
        case None => Base.Label(Top, None)
        case Some(at ~ bnd) => Base.Label(at, bnd)
      }
    | tuple(
      "fun" ~> purity ~ list(tpe) ~ tpe ^^ { case p ~ ps ~ r => Function(ps, r, p) }
      | "codata" ~> id ~ rep(methodTpe) ^^ { case it ~ ms => Codata(it, ms) }
      | "data" ~> id ~ rep(constructorTpe) ^^ { case tt ~ cs => Data(tt, cs) }
      | "stack" ~> tpe ~ list(tpe) ^^ { case rt ~ at => Stack(rt,at) }
      | "ref" ~> tpe ^^ Ref.apply
    )
  }
  def int: Parser[Int] = wholeNumber ^^ { s => s.toInt }
  def bool: Parser[Boolean] = ("true" ^^ { _ => true }) | ("false" ^^ { _ => false })
  def str: Parser[String] = """\"([^\"\\]|(\\.))*\"""".r ^^ { s => StringContext.processEscapes(s.substring(1, s.length-1)) }
  def dbl: Parser[Double] = floatingPointNumber ^^ { s => s.toDouble }
  def dblOrInt: Parser[Double | Int] = floatingPointNumber ^^ { s =>
    try {
      s.toInt
    } catch {
      case _: NumberFormatException => s.toDouble
    }
  }
  def definition: Parser[Definition[ATerm]] = maybeComment ~> tuple("define" ~> lhsOp ~ term ~ opt(":export-as" ~> list(str))) ^^ {
    case x ~ t ~ e => Definition(x,t,e.getOrElse(Nil)) 
  }
  def clause: Parser[(Id, Clause[ATerm])] = tuple(id ~ list(lhsOp) ~ term) ^^ { case t ~ ps ~ b => (t, Clause(ps, b)) }
  def literal: Parser[Literal] =
      "true" ^^ { _ => Literal.Bool(true) }
    | "false" ^^ { _ => Literal.Bool(false) }
    | dblOrInt ^^ {
        case i: Int => Literal.Int(i)
        case d: Double => Literal.Double(d)
      }
    | str ^^ { s => new Literal.String(s) }
    | """[a-zA-Z-][a-zA-Z-]*\"([^\"]|(\\.))*\"""".r ^^ { case f => Literal.StringWithFormat(f.split('"').tail.mkString("\"").stripSuffix("\""), f.split('"')(0)) }

  def term: Parser[Term[ATerm]] = maybeComment ~> ( v | tuple(
    "lambda" ~> list(lhsOp) ~ term ^^ { case params ~ body => Abs(params, body) }
      | "begin" ~> rep(term) ^^ Seq.apply
      | "letrec" ~> list(definition) ~ term ^^ { case defs ~ body => LetRec(defs, body) }
      | "let" ~> list(definition) ~ term ^^ { case defs ~ body => Let(defs, body) }
      | "if0" ~> term ~ term ~ term ^^ { case c ~ t ~ e => IfZero(c, t, e) }
      | "make" ~> id ~ id ~ list(term) ^^ {case tt ~ t ~ args => Construct(tt, t, args) }
      | "project" ~> term ~ id ~ id ~ int ^^ {case s ~ tt ~ t ~ f => Project(s, tt, t, f) }
      | "match" ~> tuple(term ~ id) ~ rep(tuple((id | "_") ~ list(lhsOp) ~ term)) ^^ {
          case s ~ tt ~ cs =>
            Match(s, tt, cs.collect{
              case (t: Id) ~ ps ~ b => (t, Clause(ps, b))
            }, cs.collectFirst {
              case "_" ~ ps ~ b => Clause(ps, b)
            }.getOrElse { throw IllegalArgumentException("No default clause in match") })
        }
      | "switch" ~> term ~ rep(tuple(literal ~ term) ^^ { case v ~ t => (v, t)}) ~ tuple("_" ~> term) ^^ {
          case s ~ cs ~ d => Switch(s, cs, d)
        }
      | "new" ~> id ~ rep(clause) ^^ { case it ~ cs => New(it, cs) }
      | "invoke" ~> term ~ id ~ id ~ rep(term) ^^ { case r ~ it ~ t ~ args => Invoke(r, it, t, args) }
      | "letref" ~> tuple(lhsOp ~ term ~ term) ~ term ^^ { case (ref ~ reg ~ bnd) ~ bod => LetRef(ref, reg, bnd, bod) }
      | "load" ~> term ^^ Load.apply
      | "store" ~> term ~ term ^^ { case r ~ v => Store(r,v) }
      | "fresh-label" ^^ { _ => FreshLabel() }
      | "reset" ~> tuple(term ~ lhsOp ~ opt(term)) ~ term ~ tuple(list(lhsOp) ~ term) ^^ {
          case (l ~ reg ~ bnd) ~ body ~ (xs ~ ret) => Reset(l, reg, bnd, body, Clause(xs, ret))
        }
      | "get-dynamic" ~> term ~ term ^^ {
          case l ~ n => GetDynamic(l, n)
        }
      | "shift" ~> (":" ~> tpe) ~ tuple(term ~ term) ~ tuple(lhsOp) ~ term ^^ { case tpe ~ (l ~ n) ~ resume ~ body => Shift(l, n, resume, body, tpe) }
      | "control" ~> (":" ~> tpe) ~ tuple(term ~ term) ~ tuple(lhsOp) ~ term ^^ { case tpe ~ (l ~ n) ~ resume ~ body => Control(l, n, resume, body, tpe) }
      | "prim" ~> list(lhsOp) ~ tuple(str ~ rep(term)) ~ term ^^ {case outs ~ (name ~ ins) ~ body => Primitive(name, ins, outs, body)}
      | "resume" ~> term ~ rep(term) ^^ { case k ~ args => Resume(k, args) }
      | "resumed" ~> term ~ term ^^ { case k ~ body => Resumed(k, body) }
      | "unit" ^^ { _ => Literal.Unit }
      | "label" ~ "null" ^^ { case _ ~ _ => Literal.Label }
      | "handle" ~> ("Deep" | "Shallow") ~ id
        ~ tuple(rep(tuple(id ~ list(lhsOp) ~ term))
                ~ opt(tuple("return" ~> list(lhsOp) ~ term))) ~ term ^^ {
          case tpe ~ tag ~ (handlers ~ ret) ~ body =>
            HandlerSugar.Handle(HandlerSugar.HandlerType.valueOf(tpe), tag, handlers.map{
              case t ~ ps ~ b => (t, Clause(ps, b))
            }, ret.map{
              case ps ~ b => Clause(ps, b)
            }, body)
        }
      | "op" ~> id ~ tuple(id ~ tpe ~ rep(term)) ~ list(lhsOp) ~ term ^^ {
          case tag ~ (op ~ rtpe ~ args) ~ kps ~ kb =>
            HandlerSugar.Op(tag, op, args, Clause(kps, kb), rtpe)
        }
      | "dhandle" ~> ("Deep" | "Shallow") ~ term
        ~ tuple(rep(tuple(id ~ list(lhsOp) ~ term))
                ~ opt(tuple("return" ~> list(lhsOp) ~ term))) ~ term ^^ {
          case tpe ~ tag ~ (handlers ~ ret) ~ body =>
            DynamicHandlerSugar.Handle(DynamicHandlerSugar.HandlerType.valueOf(tpe), tag, handlers.map{
              case t ~ ps ~ b => (t, Clause(ps, b))
            }, ret.map{
              case ps ~ b => Clause(ps, b)
            }, body)
        }
      | "dop" ~> term ~ tuple(id ~ tpe ~ rep(term)) ~ list(lhsOp) ~ term ^^ {
          case tag ~ (op ~ rtpe ~ args) ~ kps ~ kb =>
            DynamicHandlerSugar.Op(tag, op, args, Clause(kps, kb), rtpe)
        }
      | "debugWrap" ~> str ~ term ^^ { case j ~ i => DebugWrap(i, j) }
      | "load-lib" ~> term ^^ LoadLib.apply
      | "call-lib" ~> term ~ str ~ tpe ~ rep(term) ^^ {case l ~ s ~ t ~ a => CallLib(l,s,a,t)}
      | "qualified" ~> v ~ str ~ tpe ^^ { case l ~ n ~ t => Qualified(l,n,t) }
      | "alternative-fail" ^^ { _ => AlternativeFail }
      | "alternative-choice" ~> rep(term) ^^ AlternativeChoice.apply
      | "the" ~> tpe ~ term ^^ { case tp ~ t => The(tp, t) }
      | "this-lib" ^^ { case _ => ThisLib() }
      | term ~ rep(term) ^^ { case f ~ a => App(f, a) }
  ) | literal)

  def program: Parser[Program[ATerm]] = (rep(definition) ~ term <~ maybeComment ^^ { case defs ~ main => Program(defs, main) }) <~ """\s*""".r

  def parseTerm(s: String)(using ErrorReporter): Term[ATerm] = {
    parse(term, s) match {
      case Success(result, next) if next.atEnd => result
      case Success(result, next) => error(s"Trailing garbage: '${next.source.subSequence(next.offset, next.source.length())}'"); result
      case e: NoSuccess => fatal(s"\n    ${e.next.pos.longString.replace("\n", "\n    ")}: ${e.msg}")
    }
  }

  override def apply(f: Source)(using ErrorReporter): Program[ATerm] = {
    parse(program, f.mkString) match {
      case Success(result, next) if next.atEnd => result
      case Success(result, next) => error(s"Trailing garbage: '${next.source.subSequence(next.offset, next.source.length())}'"); result
      case e: NoSuccess => fatal(s"\n    ${e.next.pos.longString.replace("\n", "\n    ")}: ${e.msg}")
    }
  }
}
