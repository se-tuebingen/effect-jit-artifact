package rpyeffectasm.mcore
import org.scalacheck.Shrink
import org.scalacheck.Prop
import org.scalacheck.Prop._

class LambdaLiftingTests extends MCoreTestSuite[Var] {
  override val scalaCheckInitialSeed = "UhWteUMK8nEo1lWxE4G-6_Bndu8jbWmI1XyzX8cAi3P="
  type Input = Program[Var]

  override def runPhase(p: Program[Var]): Output = LambdaLifting(p)

  testResult("Simple lambda lifted to toplevel")(
    """(define $thirty:int 30)
      |(let ((define $y:int 12))
      |(let ((define $foo:top (lambda ($x:int) (prim ($r:int) ("infixAdd(Int, Int): Int" $x:int $y:int) $r:int))))
      |  ($foo:top $thirty:int)))
      |""".stripMargin,
    """(define $thirty:int 30)
      |(define $foo:(fun Effectful (int int) int) (lambda ($x:int $y:int) (prim ($r:int) ("infixAdd(Int, Int): Int" $x:int $y:int) $r:int)))
      |(let ((define $y:int 12))
      |($foo:(fun Effectful (int int) int) $thirty:int $y:int))
      |""".stripMargin)

  testResult("simple recursive function")(
    """(letrec ((define $diverge:top (lambda () ($diverge:top))))
      |  ($diverge:top))
      |""".stripMargin,
    """(define $diverge:(fun Effectful () top) (lambda () ($diverge:(fun Effectful () top))))
      |
      |($diverge:(fun Effectful () top))
      |""".stripMargin
  )
  testResult("lift function calling other function to be lifted")(
    """(let ((define $x:int 2))
      |  (let ((define $f:(fun Effectful (int) int) (lambda ($y:int) $x:int)))
      |    (let ((define $g:(fun Effectful () int) (lambda ()
      |          (let ((define $fortytwo:int 42))
      |            ($f:(fun Effectful (int) int) $fortytwo:int)))))
      |       ($g:(fun Effectful () int)))))
      |""".stripMargin,
    """(define $f:(fun Effectful (int int) int) (lambda ($y:int $x:int) $x:int))
      |(define $g:(fun Effectful (int) int) (lambda ($x:int)
      |  (let ((define $fortytwo:int 42))
      |    ($f:(fun Effectful (int int) int) $fortytwo:int $x:int))))
      |
      |(let ((define $x:int 2))
      |  ($g:(fun Effectful (int) int) $x:int))
      |""".stripMargin
  )

  given Shrink[Program[ATerm]] = Generators.wellScopedProgram.shrinkAny
  property("Post: Abs only on toplevel"){
    forAll(Generators.wellScopedVarProgram.any){ p =>
      wheneverNoFatal{
        val r = LambdaLifting(p)
        val pattern: PartialFunction[Term[ATerm] | Definition[ATerm], Prop] = {
          case Abs(_, _) => falsified
        }
        r match {
          case Program(definitions, main) =>
            everywhereIn(main)(pattern) && all(definitions.map{
              case Definition(name, Abs(params, body), _) => everywhereIn(body)(pattern)
              case Definition(name, binding, _) => everywhereIn(binding)(pattern)
            }: _*)
        }
      }
    }
  }
  property("Post: Types of function variables (in proper position) are consistent".ignore){ // FIXME
    forAll(Generators.wellScopedVarProgram.any){ p =>
      wheneverNoFatal{
        val r = LambdaLifting(p)
        case class Res(typesConsistent: Prop, barendregdt: Prop, bnds: Map[Id, Type], defined: Set[Id])
        val q = new Query[Res] {
          override protected def term: PartialFunction[Term[ATerm], Res] = {
            case App(Var(name, tpe), args) => combine(Res(true, true, Map(name -> tpe), Set.empty), combine(args.map(apply)))
          }

          override protected def definition: PartialFunction[Definition[ATerm], Res] = {
            case Definition(Var(name, tpe: Function), binding, _) =>
              combine(Res(true, true, Map(name -> tpe), Set(name)), apply(binding))
            case Definition(Var(name, tpe), binding, _) =>
              combine(Res(true, true, Map.empty, Set(name)), apply(binding))
          }

          override def default: Res = Res(true, true, Map.empty, Set.empty)
          override def combine(x: Res, y: Res): Res = Res(
              x.typesConsistent && y.typesConsistent &&
                all((x.bnds.keySet intersect y.bnds.keySet).map{
                  case v => (x.bnds(v) == y.bnds(v)) :| s"${SExpPrettyPrinter(v)} found with multiple types:\n - ${SExpPrettyPrinter(x.bnds(v))}\n - ${SExpPrettyPrinter(y.bnds(v))}"
                }.toSeq: _*),
              x.barendregdt && y.barendregdt &&
                (x.defined intersect y.defined).isEmpty :| s"Multiple definitions of: ${(x.defined intersect y.defined).map(SExpPrettyPrinter.apply).mkString(", ")}",
              x.bnds ++ y.bnds, x.defined ++ y.defined)
        }
        val res = q(r)
        res.barendregdt ==> res.typesConsistent :| s"---- Original program:\n${SExpPrettyPrinter(p).mkString}\n---- Transformed program:\n${SExpPrettyPrinter(r).mkString}\n--------"
      }
    }
  }
}
