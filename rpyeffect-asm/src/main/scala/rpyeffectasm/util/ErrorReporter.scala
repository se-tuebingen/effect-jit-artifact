package rpyeffectasm.util
import scala.collection.mutable

trait Error {
  def msg: String
  def json: String = {
    import rpyeffectasm.util.JsonPrinter.*
    import scala.collection.immutable.ListMap
    jsonObjectSmall(ListMap("message" -> jsonString(msg)))
  }
}
trait ErrorReporter { // TODO replace with capability-trait
  def hasErrors: Boolean
  def error(e: Error): Unit
  def doThrow: Nothing
}
object ErrorReporter {
  def withErrorsToDebugInfo[R](body: ErrorReporter ?=> R)(using outer: ErrorReporter): R = {
    var idx = 0
    body(using new ErrorReporter {
      override def hasErrors: Boolean = outer.hasErrors

      override def error(e: Error): Unit = {
        idx += 1
        DebugInfo.log("errors", idx.toString, "msg")(e.msg)
        val tr = Thread.currentThread().getStackTrace.drop(4)
        DebugInfo.log("errors", idx.toString, "stackTrace")(tr)
        outer.error(e)
      }

      override def doThrow: Nothing = {
        DebugInfo.log("errors", idx.toString, "fatal")(true)
        outer.doThrow
      }
    })
  }
  def withErrorsToStderr[R](body: ErrorReporter ?=> R)(using outer: ErrorReporter): R = {
      body(using new ErrorReporter {
        override def hasErrors: Boolean = outer.hasErrors

        override def error(e: Error): Unit = {
          System.err.println(s"[${Console.RED} ERROR ${Console.RESET}] ${e.msg}")
          outer.error(e)
        }

        override def doThrow: Nothing = {
          System.err.println(s"${Console.BOLD}${Console.RED}Cannot continue.${Console.RESET}")
          outer.doThrow
        }
      })
  }

  def catchExit[R](body: ErrorReporter ?=> R)(using outer: ErrorReporter): Option[R] = {
    object Exit extends Throwable
    try {
      Some(body(using new ErrorReporter {
        override def hasErrors: Boolean = outer.hasErrors
        override def error(e: Error): Unit = outer.error(e)
        override def doThrow: Nothing = throw Exit
      }))
    } catch {
      case Exit => None
    }
  }

  def catchExitOutside[R](body: ErrorReporter ?=> R): Option[R] = {
    object Exit extends Throwable
    try {
      Some(body(using new ErrorReporter {
        var hasErrors = false

        override def error(e: Error): Unit = { hasErrors = true }

        override def doThrow: Nothing = throw Exit
      }))
    } catch {
      case Exit => None
    }
  }

  def assertNoError[R](body: ErrorReporter ?=> R): Unit = {
    val msg = "Error occured in assertNoError"
    object Exit extends Throwable
    try {
      body(using new ErrorReporter {
        override def hasErrors: Boolean = false
        override def error(e: Error): Unit = doThrow
        override def doThrow: Nothing = throw Exit
      })
    } catch {
      case Exit => assert(false, msg)
    }
  }

  case class ErrorWithLocation(inner: Error, loc: String) extends Error {
    override def msg: String = s"${loc}:\n  ${inner.msg}"

    override def json: String = {
      import rpyeffectasm.util.JsonPrinter.*
      import scala.collection.immutable.ListMap
      jsonObjectSmall(ListMap(
        "location" -> jsonString(loc),
        "error" -> inner.json
      ))
    }
  }
  def withLocation[R](location: String)(body: ErrorReporter ?=> R)(using outer: ErrorReporter): R = {
    body(using new ErrorReporter {
      override def hasErrors: Boolean = outer.hasErrors

      override def error(e: Error): Unit = outer.error(ErrorWithLocation(e, location))

      override def doThrow: Nothing = outer.doThrow
    })
  }

  enum ResultWithCollectedErrors[R] {
    case OK(result: R, errors: List[Error])
    case Fatal(errors: List[Error])
  }
  def collectErrors[R](body: ErrorReporter ?=> R): ResultWithCollectedErrors[R] = {
    val errors: mutable.ListBuffer[Error] = new mutable.ListBuffer[Error]()
    object Exit extends Throwable
    try {
      val r = body(using new ErrorReporter {
        override def hasErrors: Boolean = errors.nonEmpty
        override def error(e: Error): Unit = errors.addOne(e)
        override def doThrow: Nothing = throw Exit
      })
      ResultWithCollectedErrors.OK(r, errors.toList)
    } catch {
      case Exit => ResultWithCollectedErrors.Fatal(errors.toList)
    }
  }

  def exceptionsAsErrors[R](prefix: String)(body: => R)(using ErrorReporter): R = {
    try {
      body
    } catch {
      case e: Throwable => ErrorReporter.fatal(prefix + e.getMessage)
    }
  }

  def error(message: String)(using e: ErrorReporter): Unit = {
    e.error(new Error {
      override def msg: String = message
    })
  }
  def fatal(message: String)(using e: ErrorReporter): Nothing = {
    e.error(new Error {
      override def msg: String = message
    })
    e.doThrow
  }
  def impossible(using ErrorReporter): Nothing = {
    fatal("This should not happen. If you see this message, some basic assumption in rpyeffect-asm is wrong.")
  }

  def ignore[R](body: ErrorReporter ?=> R): R = {
    body(using new ErrorReporter {
      var hasErrors: Boolean = false
      override def error(e: Error): Unit = hasErrors = true
      override def doThrow: Nothing = sys error s"Fatal error was ignored."
    })
  }
}
