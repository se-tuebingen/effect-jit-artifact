package rpyeffectasm.util

trait Phase[-From, +To] { thisPhase =>
  def apply(f: From)(using ErrorReporter): To

  def precondition(f: From): Unit = ()
  def postcondition[Result >: To](t: Result): Unit = ()
  ////////////////////////////////////////////////////////////////////////////////

  def andThen[To2](other: Phase[To, To2]): Phase[From,To2] = new Phase[From,To2] {
    override def name: String = s"(${thisPhase.name} >> ${other.name})"
    override def apply(x: From)(using ErrorReporter) = other.apply(thisPhase.apply(x))
    override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[From,To2] = {
      (thisPhase.mapPrimitiveSubphases(f) >> other.mapPrimitiveSubphases(f))
    }
  }
  /** Alias for andThen */
  final def >>[To2](other: Phase[To, To2]): Phase[From,To2] = this.andThen(other)

  def name = this.getClass.getName

  case class PhaseError(phase: Phase[Nothing, Any], message: String) extends Error {
    override def msg: String = s"${phase.name}: ${message}"

    override def json: String = {
      import rpyeffectasm.util.JsonPrinter.*
      import scala.collection.immutable.ListMap
      jsonObjectSmall(ListMap(
        "phase" -> jsonString(phase.name),
        "message" -> jsonString(message)
      ))
    }
  }
  def error(message: String)(using E: ErrorReporter) = E.error(PhaseError(this, message))
  def fatal(message: String)(using E: ErrorReporter) = { E.error(PhaseError(this, message)); E.doThrow }

  def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[From,To] = f(this)
}
object Phase {
  def id[T]: Phase[T,T] = new Phase[T,T] {
    override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[T,T] = this // ignore
    override def apply(f: T)(using ErrorReporter): T = f
  }
  extension[From, To](self: Phase[From, To]) {
    def **[From2, To2](other: Phase[From2, To2]): Phase[(From,From2), (To, To2)] = new Phase[(From,From2),(To,To2)] {
      override def name: String = s"(${self.name} ** ${other.name})"
      override def apply(f: (From, From2))(using ErrorReporter): (To, To2) = f match {
        case (from, from2) => (self.apply(from), other.apply(from2))
      }
      override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[(From,From2),(To,To2)] = {
        (self.mapPrimitiveSubphases(f) ** other.mapPrimitiveSubphases(f))
      }
    }

    def &&[To2](other: Phase[From, To2]): Phase[From, (To, To2)] = new Phase[From, (To, To2)] {
      override def name: String = s"(${self.name} && ${other.name})"
      override def apply(f: From)(using ErrorReporter): (To, To2) = {
        (self.apply(f), other.apply(f))
      }
      override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[From,(To,To2)] = {
        (self.mapPrimitiveSubphases(f) && other.mapPrimitiveSubphases(f))
      }
    }

    def >->[I](other: Phase[To, I]): Phase[From, To] = new Phase[From, To] {
      override def name: String = s"(${self.name} &&- ${other.name})"
      override def apply(f: From)(using ErrorReporter): To = {
        val r = self.apply(f)
        other.apply(r)
        r
      }
      override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[From,To] = {
        (self.mapPrimitiveSubphases(f) >-> other.mapPrimitiveSubphases(f))
      }
    }

    def ignoreFatals: Phase[From, Unit] = new Phase[From, Unit] {
      override def name = self.name
      override def apply(f: From)(using ErrorReporter): Unit = { ErrorReporter.catchExit{ self(f) }; () }
      override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[From,Unit] = {
        (self.mapPrimitiveSubphases(f)).ignoreFatals
      }
    }
    def dontMap: Phase[From, To] = new Phase[From, To] {
      override def name = self.name
      override def apply(f: From)(using ErrorReporter): To = self(f)
      override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[From, To] = this
    }
    def withName(str: String): Phase[From, To] = new Phase[From, To] {
      override def name = str
      override def apply(f: From)(using ErrorReporter): To = self(f)

      override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[From, To] = {
        self.mapPrimitiveSubphases(f).withName(str)
      }
    }
    def orElse[From2, To2](p2: Phase[From2, To2])(using ft: scala.reflect.TypeTest[Any, From]): Phase[From | From2, To | To2] = new Phase[From | From2, To | To2] {
      override def name = s"(${self.name} orElse ${p2.name})"

      override def apply(f: From | From2)(using ErrorReporter): To | To2 = f match {
        case x: From => self(x)
        case y: From2 => p2(y)
      }

      override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[From | From2, To | To2] = {
        self.mapPrimitiveSubphases(f) orElse p2.mapPrimitiveSubphases(f)
      }
    }
    def wrap(w: (From => ErrorReporter ?=> To) => (From => ErrorReporter ?=> To)): Phase[From, To] = new Phase[From, To] {
      override def apply(f: From)(using ErrorReporter): To = w(self.apply)(f)
      override def name = self.name
      override def mapPrimitiveSubphases(f: [F, T] => Phase[F, T] => Phase[F, T]): Phase[From, To] = self.mapPrimitiveSubphases(f)
    }
  }

  def exec[F](p: Phase[F, Unit]): Phase[F, F] = id >-> p

  def drop[From]: Phase[From, Unit] = new Phase[From, Unit] {
    override def name: String = "drop"
    override def apply(f: From)(using ErrorReporter): Unit = ()
    override def mapPrimitiveSubphases(f: [F,T] => Phase[F,T] => Phase[F,T]): Phase[From, Unit] = this
  }
}