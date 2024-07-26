package rpyeffectasm.mcore
import org.scalacheck.Prop
import org.scalacheck.Prop._
import org.scalacheck.Shrink
import rpyeffectasm.util.StringTarget

class ANFTests extends MCoreTestSuite[Var] {
  type Input = Program[ATerm]

  override def runPhase(p: Program[ATerm]): Output = ANF(p)

  testResult("Simple chain of applications")(
    "($foo:top ($bar:top 12))",
    """(let ((define $gen0:int 12))
      |(let ((define $gen1:top ($bar:top $gen0:int)))
      |  ($foo:top $gen1:top)))
      |""".stripMargin)

  {
    val anfCode =
      """(let ((define $a:int 12))
        |(let ((define $b:top ($foo:top $a:int)))
        |(let ((define $c:top (unit)))
        |  ($b:top $c:top))))
        |""".stripMargin
    testResult("Already in ANF")(anfCode, anfCode)
  }

  given Shrink[Program[ATerm]] = Generators.wellScopedProgram.shrinkAny
  property("Program does not contain Let in rhs of definition"){
    forAll(Generators.wellScopedProgram.any){ (p: Program[ATerm]) =>
      val res = try { runPhase(p) } catch { case _ => Program(Nil, Literal.Int(0)) }
      everywhereIn(res, true){
        case Definition(_, _: (Let[ATerm] | LetRec[ATerm]), _) => falsified
      }
    }
  }
  property("ANF does not introduce free variables"){
    forAll(Generators.wellScopedNosugarProgram.any){ (p: Program[ATerm]) =>
      val res = try { runPhase(p) } catch { case _ => Program(Nil, Literal.Int(0)) }
      import rpyeffectasm.mcore.analysis.FreeVariables
      val frees = FreeVariables(res).toSet
      frees.isEmpty
      :| s"""After ANF the following program contains free variables ${frees.map(SExpPrettyPrinter(_)).mkString(",")}
            |---- Input:
            |${SExpPrettyPrinter(p).emitTo(StringTarget())}
            |---- ANFed:
            |${SExpPrettyPrinter(res).emitTo(StringTarget())}
            |-----------
            """.stripMargin
    }
  }
}
