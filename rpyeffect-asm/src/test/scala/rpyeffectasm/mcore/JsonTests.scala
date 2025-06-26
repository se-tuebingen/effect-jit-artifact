package rpyeffectasm.mcore
import org.scalacheck.Prop.*
import org.scalacheck.Prop
import org.scalacheck.Shrink
import scala.io.Source
import rpyeffectasm.util.StringTarget
import rpyeffectasm.util.ErrorReporter

class JsonTests extends munit.ScalaCheckSuite {

  def pp(p: Program[ATerm]): String = ErrorReporter.catchExitOutside { ErrorReporter.withErrorsToStderr {
    SExpPrettyPrinter(p).emitTo(new StringTarget())
  }}.get

  property("prettyPrint andThen parse  is  identity".ignore){
    given Shrink[Program[ATerm]] = Generators.parseableProgram.shrinkAny
    forAll(Generators.parseableProgram.any){ original =>
      ErrorReporter.catchExitOutside { ErrorReporter.withErrorsToStderr {
        val prettyPrinted = JsonPrettyPrinter(original).emitTo(new StringTarget())
        (prettyPrinted, (new JsonParser)(Source.fromString(prettyPrinted)))
      }} match {
        case Some((pret, pars)) => (original == pars) :| s"Did not match\n# original:\n${pp(original)}\n\n# printed: \n${pret}\n\n# parsed: \n${pp(pars)}"
        case None => fail(s"There were Errors.\n# original:\n${pp(original)}")
      }
    }
  }

}
