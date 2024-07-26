package rpyeffectasm.util
import scala.collection.mutable

/** A place that we can output a String to */
trait Target[T] {
  def fromString(s: String): T
  def collecting(body: Emit[String] ?=> Unit): T
}
/** An output that can be redirected into different kinds of [[Target]]s */
trait Output {
  def emitTo[T](t: Target[T]): T
}

class StringTarget extends Target[String] {
  override def fromString(s: String): String = s

  override def collecting(body: Emit[String] ?=> Unit): String = {
    val sb: mutable.StringBuilder = new mutable.StringBuilder()
    body(using (a: String) => sb.addAll(a));
    sb.toString()
  }
}
class FileTarget(val filename: java.io.File) extends Target[Unit] {
  import java.io.{File, FileWriter}

  override def fromString(s: String): Unit = {
    val fw = new FileWriter(filename)
    try {
      fw.write(s)
    } finally {
      fw.close()
    }
  }

  override def collecting(body: Emit[String] ?=> Unit): Unit = {
    val fw = new FileWriter(filename)
    try {
      body(using (a: String) => fw.write(a))
    } finally {
      fw.close()
    }
  }

}
object FileTarget {
  def apply(filename: String): FileTarget = new FileTarget(java.io.File(filename))
  def apply(file: java.io.File): FileTarget = new FileTarget(file)
}
object StdoutTarget extends Target[Unit] {
  override def fromString(s: String): Unit = {
    println(s)
  }

  override def collecting(body: Emit[String] ?=> Unit): Unit = {
    body(using (a: String) => print(a)); println()
  }
}

class EmitTarget(using E: Emit[String]) extends Target[Unit] {
  override def fromString(s: String): Unit = Emit.emit(s)

  override def collecting(body: ContextFunction1[Emit[String], Unit]): Unit = body(using E)
}

object Target {
  /** Creates a target from a user-provided string.
   * Supports:
   * - Filenames
   * - `-` for stdout
   */
  def fromSpecifier(t: String) = t match {
    case "-" => StdoutTarget
    case filename => FileTarget(filename)
  }
}

object Output {
  extension(self: Output) {
    def emitToFile(filename: String) = self.emitTo(FileTarget(filename))
    def emitToStdout = self.emitTo(StdoutTarget)
    def emit(using Emit[String]): Unit = self.emitTo(new EmitTarget)
    def mkString: String = self.emitTo(new StringTarget)
  }
}