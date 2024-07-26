package rpyeffectasm.mcore
import org.scalacheck.Shrink
import org.scalacheck.Prop
import org.scalacheck.Gen
import org.scalacheck.Prop._
import rpyeffectasm.util.StringTarget

class ClosureConversionTests extends MCoreTestSuite[ATerm] {
  import rpyeffectasm.mcore.analysis.ClosureAnalysis
  import rpyeffectasm.mcore.analysis.ClosureAnalysis.{in, Tpe}

  override type Input = Program[Var]

  override def runPhase(p: Program[Var]): Output = ClosureConversion(p)

  testResult("Simple abs passed to function")(
    """(define $fn:top (lambda ($arg:top) 12))
      |(let ((define $a:top (lambda () 3)))
      |  ($fn:top $a:top))
      |""".stripMargin,
    """(define $fn:top (lambda ($arg:top) 12))
      |(let ((define $a:top (lambda () 3)))
      |  ($fn:(fun Effectful (top) int) (new $gen0 ($apply () ($a:(fun Effectful () int) )))))
      |""".stripMargin)

  property("mkClosure(Var) returns Var with non-function type"){
    forAll(Generators.term.rhsVar){ v =>
      forAll(Gen.oneOf[Tpe](Tpe.Value, for{
        ptpes <- Gen.listOf(Generators.tpe.any)
        cpats <- Gen.listOf(Generators.term.rhsVar)
        rtpe <- Generators.tpe.any
      } yield Tpe.Function(ptpes, cpats, rtpe))){ tp =>
        ClosureConversion.mkClosure(v)(using ClosureAnalysis.Env.Bind(Map(v.name -> tp), ClosureAnalysis.Env.Empty)) match {
          case Var(_, Function(_, _, _)) => falsified
          case _ => passed
        }
      }
    }
  }

  given Shrink[Program[Var]] = Generators.wellScopedVarProgram.shrink
  property("Post: Tpe.Function only occurs in App or binding"){
    forAll(Generators.wellScopedVarProgram.any){ p =>
      wheneverNoFatal {
        val r = ClosureConversion(ANF(p))

        enum Expectation {
          case Fn, Val, Either
        }

        def go(t: Term[ATerm], expected: Expectation = Expectation.Val)(using ClosureAnalysis.Env): Prop = ((t match {
          case v@Var(_, _) if expected == Expectation.Fn => ClosureAnalysis(v).isInstanceOf[Tpe.Function] :| s"${v} is not a function"
          case _ if expected == Expectation.Fn => falsified :| s"${t} used in function position" // TODO ?
          case v@Var(name, Function(_,_,_)) if expected == Expectation.Val => falsified :| s"${v} is a function parameter"
          case v@Var(name, tpe) if expected == Expectation.Val => (ClosureAnalysis(v) == Tpe.Value) :| s"${v} is a function"
          case v@Var(_, _) => passed
          case Abs(params, body) => in(t) {
            all(params.map(go(_, Expectation.Val)): _*) &&
            go(body)
          }
          case App(fn, args) => go(fn, Expectation.Fn) && all(args.map(go(_)): _*)
          case Seq(ts) => all(ts.map(go(_)): _*)
          case Let(defs, body) => all(defs.map { d => go(d.binding, Expectation.Either) }: _*) && in(t) {
            go(body)
          }
          case LetRec(defs, body) => in(t) {
            all(defs.map { d => go(d.binding, Expectation.Either) }: _*) && go(body)
          }
          case IfZero(cond, thn, els) => go(cond.unroll) && go(thn) && go(els)
          case Construct(tpe_tag, tag, args) => all(args.map(go(_)): _*)
          case Project(scrutinee, tpe_tag, tag, field) => go(scrutinee)
          case Match(scrutinee, tpe_tag, clauses, default_clause) =>
            go(scrutinee.unroll) && all(clauses.map { (_, c) => goC(c) }: _*) && goC(default_clause)
          case New(ifce_tag, methods) => all(methods.map { (_, c) => goC(c) }: _*)
          case Invoke(receiver, ifce_tag, method, args) =>
            go(receiver) && all(args.map(go(_)): _*)
          case LetRef(ref, region, binding, body) =>
            go(region.unroll) && go(binding.unroll) && in(t) {
              go(body)
            }
          case Load(ref) => go(ref)
          case Store(ref, value) => go(ref) && go(value)
          case Reset(label, region, bnd, body, ret) =>
            go(label.unroll) && all(bnd.map{ b => go(b.unroll) }.toSeq: _*) && in(t) {
              go(body)
            } && goC(ret)
          case Shift(label, n, k, body, retTpe) =>
            go(label.unroll) && go(n.unroll) && in(t) {
              go(body)
            }
          case Control(label, n, k, body, retTpe) =>
            go(label.unroll) && go(n.unroll) && in(t) {
              go(body)
            }
          case Resume(cont, args) => go(cont) && all(args.map(go(_)): _*)
          case Resumed(cont, body) => go(cont.unroll) && go(body)
          case Primitive(name, args, returns, rest) =>
            all(args.map { a => go(a.unroll) }: _*) && in(t) {
              go(rest)
            }
          case sugar: Sugar => ???
          case _ => passed
        }) :| s"In ${SExpPrettyPrinter(t)}")

        def goC(c: Clause[ATerm])(using ClosureAnalysis.Env): Prop = c match {
          case Clause(params, body) => in(c) {
            all(params.map(go(_, Expectation.Val)): _*) && go(body)
          }
        }

        in(r) {
          all(r.definitions.map { d => go(d.binding, Expectation.Either) }: _*) && go(r.main)
        } :| s"In ${SExpPrettyPrinter(r).emitTo(StringTarget())}" :| s"On input ${SExpPrettyPrinter(p).emitTo(StringTarget())}"
      }
    }
  }
}
