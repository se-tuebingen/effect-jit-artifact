package effekt.util

import effekt.context.Context
import effekt.util.messages.EffektMessages
import kiama.util.Source

import scala.collection.mutable

trait Task[In, Out] { self =>

  /**
   * The name of this task
   */
  def taskName: String

  /**
   * The result indicates whether running this task was successful.
   *
   * Error messages are written to the context
   *
   * Can throw FatalPhaseError to abort execution of the task
   */
  def run(input: In)(implicit C: Context): Option[Out]

  /**
   * Apply this task
   */
  def apply(input: In)(implicit C: Context): Option[Out] =
    Task.need(this, input)

  def fingerprint(key: In): Long

  def cached: Task[In, Out] = new Task[In, Out] {
    val taskName = s"${self.taskName}"

    def run(input: In)(implicit C: Context): Option[Out] =
      self.apply(input)

    def fingerprint(key: In): Long = self.fingerprint(key)
  }

  /**
   * sequentially composes two tasks
   */
  def andThen[Out2](other: Task[Out, Out2]): Task[In, Out2] = new Task[In, Out2] {
    val taskName = s"${self.taskName} andThen ${other.taskName}"

    def run(input: In)(implicit C: Context): Option[Out2] =
      self.run(input).flatMap(other.run)

    //    override def apply(input: In)(implicit C: Context): Option[Out2] =
    //      self.apply(input).flatMap(other.apply)

    def fingerprint(key: In): Long = self.fingerprint(key)
  }

  override def toString = taskName
}

abstract class SourceTask[Out](name: String) extends Task[Source, Out] {
  val taskName = name

  // On file sources, we use the timestamp to approximate content changes
  // We currently can't simply use a content hash, since
  // in kiama.FilesSource the content is only read once! and then stored in a `val`.
  // It will not update, if the external file changes.
  def fingerprint(source: Source) = paths.lastModified(source)

}

abstract class HashTask[In, Out](name: String) extends Task[In, Out] {
  val taskName = name
  def fingerprint(in: In) = in.hashCode
}

// TODO maybe tasks should either memoize the result OR error messages? Otherwise we don't have the messages on the next cached run
object Task { build =>

  private def log(msg: => String) = () // println(msg)

  /**
   * A concrete target / request to be build
   */
  case class Target[K, V](task: Task[K, V], key: K) {
    override def toString = s"${task}@${fingerprint}"
    def fingerprint: Long = task.fingerprint(key)
  }

  case class Info(target: Target[_, _], hash: Long) {
    def isValid: Boolean = target.fingerprint == hash
    override def toString =
      if (isValid) target.toString else s"${target}#${Console.RED_B}${Console.WHITE}${hash}${Console.RESET}"
  }

  // The datatype Trace is adapted from the paper "Build systems a la carte" (Mokhov et al. 2018)
  // currently the invariant that Info.target.V =:= V is not enforced
  case class Trace[V](current: Info, depends: List[Info], value: Option[V], msgs: EffektMessages) {
    def trace = current :: depends
    def isValid: Boolean = current.isValid && depends.forall { _.isValid }
    override def toString = {
      s"Trace($current) { ${depends.mkString("; ")} }"
    }
  }

  type Cache = mutable.HashMap[Target[Any, Any], Trace[Any]]
  def emptyCache = mutable.HashMap.empty[Target[Any, Any], Trace[Any]]

  private def coerce[A, B](a: A): B = a.asInstanceOf[B]

  def get[K, V](target: Target[K, V])(using C: Context): Option[Trace[V]] =
    coerce(C.cache.get(coerce(target)))
  def update[K, V](target: Target[K, V], trace: Trace[V])(using C: Context): Unit =
    C.cache.update(coerce(target), coerce(trace))

  /**
   * A trace recording information about computed targets
   */
  private var trace: List[Info] = Nil

  def clearTrace(): List[Info] = {
    val before = trace
    trace = Nil
    before
  }
  def restoreTrace(tr: List[Info]) = {
    trace = tr
  }
  def appendToTrace(t: List[Info]) = {
    val extended = trace ++ t
    trace = extended.distinct
  }

  def compute[K, V](target: Target[K, V])(using C: Context): Option[V] = {
    val before = clearTrace()
    // log(s"computing for ${target}")

    // capture the messages, so they can be replayed later
    val (msgs, res) = C.withMessages {
      target.task.run(target.key)
    }
    C.messaging.append(msgs)

    val tr = Trace(Info(target, target.fingerprint), trace, res, msgs)
    build.update(target, tr)

    // for the potential parent task, we append our trace to the existing one
    restoreTrace(before)
    appendToTrace(tr.trace)
    res
  }

  def reuse[V](tr: Trace[V])(using C: Context): Option[V] = {
    // log(s"reusing ${tr.current.target}")
    // replay the trace
    C.messaging.append(tr.msgs)
    appendToTrace(tr.trace)
    tr.value
  }

  def need[K, V](task: Task[K, V], key: K)(using C: Context): Option[V] = need(Target(task, key))

  def need[K, V](target: Target[K, V])(using C: Context): Option[V] = get(target) match {
    case Some(trace) if !trace.isValid =>
      // log(s"Something changed for ${target}")
      compute(target)
    case Some(trace) =>
      reuse(trace)
    case None =>
      compute(target)
  }

  def dump()(using C: Context) =
    C.cache.foreach { case (k, v) => println(k.toString + " -> " + v) }
}
