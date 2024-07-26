package rpyeffectasm.mcore
import org.scalacheck.Shrink
import org.scalacheck.Arbitrary
import org.scalacheck.Prop
import rpyeffectasm.util
import rpyeffectasm.util.ErrorReporter
import rpyeffectasm.util.StringTarget
import scala.collection.mutable
import org.scalacheck.Prop
import org.scalacheck.Prop._

trait MCoreTestSuite[O <: ATerm] extends munit.FunSuite with munit.ScalaCheckSuite {
  given shrinkTermProgram: Shrink[Program[ATerm]] = Generators.parseableProgram.shrinkAny
  given arbTermProgram: Arbitrary[Program[ATerm]] = Arbitrary(Generators.parseableProgram.any)

  given shrinkVarProgram: Shrink[Program[Var]] = Generators.parseableVarProgram.shrink
  given arbVarProgram: Arbitrary[Program[Var]] = Arbitrary(Generators.parseableVarProgram.any)


  private val parser = SExpParser

  type Input <: Program[ATerm]
  type Output = Program[O]
  def runPhase(p: Input): Output

  def parse(s: String): Program[ATerm] = {
    parser.parse(parser.program, s) match {
      case parser.Success(result, next) =>
        if(!next.atEnd){
          fail(s"Parsing failed, trailing garbage: ```\n${next.source.subSequence(next.offset, next.source.length())}```")
        }
        result
      case e => fail(s"Parsing failed: ${e}"); ???
    }
  }

  given util.ErrorReporter = new util.ErrorReporter {
    var hasErrors: Boolean = false

    override def error(e: util.Error): Unit = fail(s"Error while compiling test input: ${e.msg}")

    override def doThrow: Nothing = fail("Compiling test input failed")
  }

  def assertResult(input: String, output: String) = {
    val i = parse(input).asInstanceOf[Input] // TODO actually check
    val o = parse(output).asInstanceOf[Output] // TODO actually check
    val renamer = new Renamer[O]
    val got = renamer(runPhase(i))
    val expected = renamer(o)
    assertNoDiff(SExpPrettyPrinter(got).mkString, SExpPrettyPrinter(expected).mkString)
    assertEquals(got, expected)
  }

  def testResult(name: String)(input: String, output: String) = test(name){
    assertResult(input, output)
  }

  def pp(p: Program[ATerm]): String = ErrorReporter.catchExitOutside { ErrorReporter.withErrorsToStderr {
    SExpPrettyPrinter(p).emitTo(new StringTarget())
  }}.get
  def pp(d: Definition[ATerm]): String = SExpPrettyPrinter(d)
  def pp(t: Term[ATerm]): String = SExpPrettyPrinter(t)
  def pp(t: Type): String = SExpPrettyPrinter(t)

  def noErrors(body: ErrorReporter ?=> Unit): Prop = {
    ErrorReporter.catchExitOutside { ErrorReporter.withErrorsToStderr{ er ?=>
      body
      Prop(er.hasErrors)
    }}.getOrElse{ Prop.falsified }
  }

  def everywhereIn(p: Definition[ATerm], recurseAlways: Boolean)(pattern: PartialFunction[Term[ATerm] | Definition[ATerm], Prop]): Prop = p match {
    case Definition(name, binding, _) =>
      (if pattern.isDefinedAt(p) then (pattern(p) :| s"At ${SExpPrettyPrinter(p)}") else passed)
        && (if recurseAlways then (everywhereIn(binding, recurseAlways)(pattern) :| s"In ${SExpPrettyPrinter(p)}") else passed )
  }

  def everywhereIn(p: Term[ATerm], recurseAlways: Boolean = true)(pattern: PartialFunction[Term[ATerm] | Definition[ATerm], Prop]): Prop = {
    def gorec(p: Term[ATerm]): Prop = p match {
      case t: Term[ATerm] if recurseAlways && pattern.isDefinedAt(t) =>
        (pattern(t) :| s"At ${SExpPrettyPrinter(t)}") && (go(t) :| s"In ${SExpPrettyPrinter(p)}")
      case t: Term[ATerm] if !recurseAlways && pattern.isDefinedAt(t) => pattern(t) :| s"At ${SExpPrettyPrinter(t)}"
      case t: Term[ATerm] => go(t) :| s"In ${SExpPrettyPrinter(p)}"
    }
    def go(t: Term[ATerm]): Prop = (t match {
            case Abs(params, body) =>
              gorec(body)
            case App(fn, args) => gorec(fn) && all(args.map { a => gorec(a) }: _*)
            case Seq(ts) => all(ts.map { t => gorec(t) }: _*)
            case Let(defs, body) => all(defs.map { d => everywhereIn(d, recurseAlways)(pattern) }: _*) && gorec(body)
            case LetRec(defs, body) =>
              all(defs.map { d => everywhereIn(d, recurseAlways)(pattern) }: _*) && gorec(body)
            case IfZero(cond, thn, els) =>
              gorec(cond.unroll) && gorec(thn) && gorec(els)
            case Construct(tpe_tag, tag, args) =>
              all(args.map { a => gorec(a) }: _*)
            case Project(scrutinee, tpe_tag, tag, field) =>
              gorec(scrutinee)
            case Match(scrutinee, tpe_tag, clauses, default_clause) =>
              gorec(scrutinee.unroll) &&
                all(clauses.map { case (id, Clause(params, body)) => gorec(body) }: _*) &&
                gorec(default_clause.body)
            case New(ifce_tag, methods) =>
              all(methods.map { case (_, Clause(params, body)) => gorec(body) }: _*)
            case Invoke(receiver, ifce_tag, method, args) =>
              gorec(receiver) && all(args.map { a => gorec(a) }: _*)
            case LetRef(ref, region, binding, body) =>
              gorec(region.unroll) && gorec(binding.unroll) && gorec(body)
            case Load(ref) => gorec(ref)
            case Store(ref, value) => gorec(ref) && gorec(value)
            case Reset(label, region, bnd, body, ret) =>
              gorec(label.unroll) && all(bnd.map{ b => gorec(b.unroll) }.toSeq: _*) && gorec(body) && gorec(ret.body)
            case Shift(label, n, k, body, retTpe) =>
              gorec(label.unroll) && gorec(n.unroll) && gorec(body)
            case Control(label, n, k, body, retTpe) =>
              gorec(label.unroll) && gorec(n.unroll) && gorec(body)
            case Resume(cont, args) => gorec(cont) && all(args.map { a => gorec(a) }: _*)
            case Resumed(cont, body) => gorec(cont.unroll) && gorec(body)
            case Primitive(name, args, returns, rest) =>
              all(args.map { a => gorec(a.unroll) }: _*) && gorec(rest)
            case sugar: Sugar => Prop.passed // FIXME recurse, too
            case _ => Prop.passed
          })
    gorec(p)
  }
  def everywhereIn(p: Program[ATerm], recurseAlways: Boolean)(pattern: PartialFunction[Term[ATerm] | Definition[ATerm], Prop]): Prop = p match {
    case Program(definitions, main) =>
      (all(definitions.map{ d => everywhereIn(d.binding, recurseAlways)(pattern)}: _*) &&
       everywhereIn(main, recurseAlways)(pattern)) :| s"In ${SExpPrettyPrinter(p).emitTo(StringTarget())}"
  }

  def wheneverNoFatal(body: util.ErrorReporter ?=> Prop): Prop = {
    var errors = false
    object Exit extends Throwable
    try {
      body(using new ErrorReporter {
        override def hasErrors: Boolean = errors

        override def error(e: util.Error): Unit = { errors = true }

        override def doThrow: Nothing = throw Exit
      })
    } catch {
      case Exit => Prop.undecided
    }
  }
}
trait QueryProp extends Query[Prop] {
  override def default: Prop = Prop.passed
  override def combine(xs: Iterable[Prop]): Prop = all(xs.toSeq: _*)
  override def combine(x: Prop, y: Prop): Prop = x && y
}
