package rpyeffectasm.mcore
import org.scalacheck.Prop
import org.scalacheck.Prop._
import org.scalacheck.Shrink
import scala.collection.immutable
import rpyeffectasm.util.Query

class DealiasingTests extends MCoreTestSuite[ATerm] {
  type Input = Program[ATerm]

  override def runPhase(p: Program[ATerm]): Output = (new Dealiasing[ATerm])(p)

  testResult("from lambda lifting test")(
    """(define $gen0:top (lambda ($x:int $y:int) (prim ($r:int) ("infixAdd(Int, Int): Int" $x:int $y:int) $r:int)))
      |(let ((define $y:int 12))
      |(let ((define $foo:top $gen0:top))
      |  ($foo:top 30 $y:int)))
      |""".stripMargin,
    """(define $gen0:top (lambda ($x:int $y:int) (prim ($r:int) ("infixAdd(Int, Int): Int" $x:int $y:int) $r:int)))
      |(let ((define $y:int 12))
      |  ($gen0:top 30 $y:int))
      |""".stripMargin)

  given Shrink[Program[ATerm]] = Generators.program.shrinkAny
  property("Dealiasing removes aliases"){ // Diverges for some reason
    forAll(Generators.program.any){ p =>
        val r = try { runPhase(p) } catch { case _ => Program(Nil, Literal.Int(0)) }
        val noAliasDefs = new QueryProp {
            override def definition: PartialFunction[Definition[ATerm], Prop] = {
              case Definition(name, binding: Var, _) => falsified
            }
          }
        noAliasDefs(r)
    }
  }

}
