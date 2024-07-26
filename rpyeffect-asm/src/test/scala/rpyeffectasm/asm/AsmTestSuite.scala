package rpyeffectasm.asm
import rpyeffectasm.util
import org.scalacheck.{Arbitrary, Gen, Prop}
import org.scalacheck.Prop.*

trait AsmTestSuite[Flags <: AsmFlags, Tag <: Id, Label <: Id, V <: Id, P <: TypingPrecision] extends munit.FunSuite with munit.ScalaCheckSuite {
  private val parser = new AsmParser()

  type Input <: Program[AsmFlags, Id, Id, Id, OperandType[TypingPrecision]]
  type Output = Program[Flags, Tag, Label, V, OperandType[P]]
  def runPhase(p: Input): Output

  def parse(s: String): Program[AsmFlags, Id, Id, Id, OperandType[TypingPrecision]] = {
    parser.parse(parser.program, s) match {
      case parser.Success(result, next) =>
        if(!next.atEnd){
          fail(s"Parsing failed, trailing garbage: ```\n${next.source.subSequence(next.offset, Math.min(next.offset+80, next.source.length()))}\n...```")
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
    val renamer = new Renamer[Flags, Tag, Label, V, P, OperandType[P]]()
    val got = renamer(runPhase(i))
    val expected = renamer(o)
    assertNoDiff(AsmPrettyPrinter(got).mkString, AsmPrettyPrinter(expected).mkString)
    assertEquals(got, expected)
  }
  def assertEvaluationUnchanged(input: String): Unit = {
    val i = parse(input).asInstanceOf[Input] // TODO actually check
    val expected = Interpreter(i).terminationCause
    val gotCode = runPhase(i)
    val got = Interpreter(gotCode).terminationCause
    assertEquals(got, expected)
  }

  def testResult(name: String)(input: String, output: String) = test(name){
    assertResult(input, output)
  }
  def testEvaluation(name: String)(input: String) = test(name) {
    assertEvaluationUnchanged(input)
  }

  def testIdempotent(name: String)(using gen: Gen[Input]) = property(s"${name} is idempotent"){
    forAll(gen){ (p: Input) =>
      val r = runPhase(p)
      runPhase(r.asInstanceOf) == r
    }
  }
  def testSemanticsPreserving(name: String, timeout: Int, timeSlack: Int = 2)(using gen: Gen[Input]) = property(s"${name} is semantics-preserving"){
    // FIXME make work
    forAll(gen){ (p: Input) => {
        import rpyeffectasm.asm.Interpreter.TerminationCause
        val prev = try {Interpreter.runWithTimeout(p, Some(timeout))} catch { case _ => Interpreter.Result(null, null, null) }
        prev.terminationCause match {
          case c@(TerminationCause.ReturnToEmptyStack(_) | TerminationCause.EndOfBlock) =>
            val r = try { runPhase(p) } catch { case _ => null }
            (r != null) ==> {
              // println("Actually happens.")
              val after = Interpreter.runWithTimeout(p, Some(timeout * timeSlack))
              after.terminationCause == c
            }
          case _ => undecided
        }
      }
    }
  }
}
