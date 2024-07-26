package rpyeffectasm
package mcore
package analysis

import rpyeffectasm.mcore.MCoreTestSuite
import rpyeffectasm.util
import rpyeffectasm.mcore.analysis.ClosureAnalysis.{Env, Tpe}

class ClosureAnalysisTests extends munit.FunSuite {
  val parser = SExpParser
  def parse(s: String): Term[ATerm] = {
    parser.parse(parser.term, s) match {
      case parser.Success(result, next) =>
        if (!next.atEnd) {
          fail(s"Parsing failed, trailing garbage: ```\n${next.source.subSequence(next.offset, next.source.length())}```")
        }
        result
      case e => fail(s"Parsing failed: ${e}"); ???
    }
  }
  def v(s: String): Var = parse(s).asInstanceOf[Var]
  def i(s: String): Id = parser.parse(parser.id, s) match {
    case parser.Success(result, next) =>
      if (!next.atEnd) {
        fail(s"Parsing failed, trailing garbage: ```\n${next.source.subSequence(next.offset, next.source.length())}```")
      }
      result
    case e => fail(s"Parsing failed: ${e}"); ???
  }

  given util.ErrorReporter = new util.ErrorReporter {
    var hasErrors: Boolean = false

    override def error(e: util.Error): Unit = fail(s"Error while compiling test input: ${e.msg}")

    override def doThrow: Nothing = fail("Compiling test input failed")
  }

  def testCapturesOf(name: String)(env: ClosureAnalysis.Env, code: String, captures: List[String]): Unit = {
    test(name){
      given ClosureAnalysis.Env = env
      ClosureAnalysis(parse(code)) match {
        case ClosureAnalysis.Tpe.Value => assert(false, "Should not be a value")
        case ClosureAnalysis.Tpe.Function(_, capts, _) =>
          assertEquals(capts, captures.map(v))
      }
    }
  }

  testCapturesOf("Simple Lambda with one capture")(
    Env.Empty,
    """(lambda () $x:int)""",
    List("$x:int")
  )

  testCapturesOf("Not capturing functions")(
    Env.Empty,
    """(let ((define $x:top (lambda () 12))) (lambda () $x:top))""",
    List()
  )

  testCapturesOf("Propagating function captures")(
    Env.Empty,
    """(let ((define $x:top (lambda () $y:int))) (lambda () $x:top))""",
    List("$y:int")
  )
}
