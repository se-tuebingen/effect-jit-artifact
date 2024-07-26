package rpyeffectasm.util
import scala.io

object Source {

  import scala.io.BufferedSource

  /** Creates a source from a user-provided string.
   * Supports:
   * - Filenames
   * - `-` for stdin
   */
  def fromSpecifier(s: String) = s match {
    case "-" => io.Source.stdin
    case filename => io.Source.fromFile(filename)
  }
}


