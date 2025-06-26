package rpyeffectasm.mcore
import org.scalacheck.Shrink
import org.scalacheck.Prop
import org.scalacheck.Prop._
import rpyeffectasm.util.StringTarget

class LambdaLiftingAndClosureConversionTests extends MCoreTestSuite[ATerm] {
  type Input = Program[Var]

  override def runPhase(p: Program[Var]): Output = LambdaLiftingAndClosureConversion(p)

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
  testResult("wrap hof parameter")(
    """(define $fn:(fun Effectful (top) top) (lambda ($a:top) $a:top))
      |(let ((define $arg:top (lambda () 12)))
      |   ($fn:top $arg:top))
      |""".stripMargin,
    """(define $fn:(fun Effectful (top) top) (lambda ($a:top) $a:top))
      |(define $arg:(fun Effectful () int) (lambda () 12))
      |(let ((define $gen0:top
      |              (new $gen1 ($apply () ($arg:(fun Effectful () int))))))
      |  ($fn:(fun Effectful (top) top) $gen0:top ))
      |""".stripMargin
  )
  // TODO more tests, especially: closure conversion

  given Shrink[Program[Var]] = Generators.wellScopedVarProgram.shrink
  property("Post: Abs only occurs in toplevel definitions"){
    forAll(Generators.wellScopedVarProgram.any){ p =>
      wheneverNoFatal{
        LambdaLiftingAndClosureConversion(p) match {
          case Program(defs, main) =>
            all(defs.map{
              case Definition(_, Abs(_, b), _) =>
                everywhereIn(b){
                  case Abs(_, _) => falsified
                }
              case Definition(_, b, _) =>
                everywhereIn(b){
                  case Abs(_, _) => falsified
                }
            }: _*) && everywhereIn(main){
              case Abs(_, _) => falsified
            }
        }
      }
    }
  }

  property("Post: Function types only in toplevel definitions or App"){
    forAll(Generators.wellScopedVarProgram.any){ p =>
      wheneverNoFatal{
        var pattern: PartialFunction[Term[ATerm] | Definition[ATerm], Prop] = null
        pattern = {
          case Var(name, Function(params, ret, purity)) => falsified :| "Function in value position"
          case App(fn, args) => all(args.map { a => everywhereIn(a, false)(pattern) }: _*)
        }
        val r = LambdaLiftingAndClosureConversion(ANF(p))
        (r match {
          case Program(defs, main) =>
            all(defs.map{
              case Definition(_, Var(name, _), _) => passed // Alias definitions are not removed.
              case d => everywhereIn(d.binding, false)(pattern)
            }: _*) && everywhereIn(main, false)(pattern)
        }) :| s"Program: ${SExpPrettyPrinter(p).emitTo(StringTarget())}\nResult: ${SExpPrettyPrinter(r).emitTo(StringTarget())}"
      }
    }
  }

}
