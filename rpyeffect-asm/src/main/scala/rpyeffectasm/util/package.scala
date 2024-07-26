package rpyeffectasm
import scala.annotation.tailrec
import scala.collection.mutable
import scala.concurrent.duration.FiniteDuration
import scala.concurrent.{TimeoutException, ExecutionContext}

package object util {

  class IterationLimitReached extends Exception
  @tailrec
  @throws[IterationLimitReached]
  def fixpoint[T](start: T, limit: Option[Int] = None)(of: T => T): T = limit match {
    case Some(0) =>
      throw new IterationLimitReached
    case _ =>
      val next = of(start)
      if next == start then next else fixpoint(next, limit.map(_ - 1))(of)
  }

  def escape(s: String): String = s.flatMap(escapeChar)

  def escapeChar(ch: Char): String = ch match {
    case '\b' => "\\b"
    case '\t' => "\\t"
    case '\n' => "\\n"
    case '\f' => "\\f"
    case '\r' => "\\r"
    case '"' => "\\\""
    //case '\'' => "\\\'"
    case '\\' => "\\\\"
    case ch if ch.toInt >= 32 && ch.toInt <= 126 => String.valueOf(ch)
    case ch => "\\u%04x".format(ch.toInt)
  }

  def unescape(s: String): String = Emit.collecting_{
    import Emit.emit
    val it = s.iterator
    while(it.hasNext) {
      val c = it.next()
      c match {
        case '\\' =>
          assert(it.hasNext, "Unterminated escape sequence")
          emit(it.next() match {
          case 'b' => '\b'
          case 't' => '\t'
          case 'n' => '\n'
          case 'f' => '\f'
          case 'r' => '\r'
          case 'u' =>
            Integer.parseInt(List(it.next(),it.next(),it.next(),it.next()).mkString, 16).toChar
          case c => c
        })
        case _ => emit(c)
      }
    }
  }.mkString

  /** Tries to find a cycle in the given data. For debugging; uses reflection and returns a cycle if one exists */
  def findCycle(value: Any): Option[List[Any]] = {
    enum R {
      case NoCycle
      case LimitReached
      case Cycle(elems: List[Any])
    }
    object Exit extends Throwable
    def findCycleWithLength(value: Any, n: Int, seen: List[(String, Any)]): R = {
      value match {
        case x if seen.exists{ case (_, y) => x == y } =>
          val len = seen.indexWhere{ case (_, y) => y == x }
          R.Cycle(("start", x) :: seen.take(len + 1).reverse)
        case _ if n <= 0 => R.LimitReached
        case i: Iterable[_] =>
          var r = R.NoCycle
          try {
            i.zipWithIndex.foreach { (e,idx) =>
              findCycleWithLength(e, n - 1, (s"element ${idx}", i) :: seen) match {
                case R.NoCycle => ()
                case R.LimitReached => r = R.LimitReached
                case R.Cycle(elems) => r = R.Cycle(elems)
              }
            }
            r
          } catch {
            case Exit => r
          }
        case p: Product =>
          var r = R.NoCycle
          try {
            (0 until p.productArity).foreach { i =>
              val e = p.productElement(i)
              findCycleWithLength(e, n - 1, (s"component ${p.productElementName(i)}", p) :: seen) match {
                case R.NoCycle => ()
                case R.LimitReached => r = R.LimitReached
                case R.Cycle(elems) => r = R.Cycle(elems)
              }
            }
            r
          } catch {
            case Exit => r
          }
        case v if v.getClass.getPackageName.startsWith("rpyeffectasm.") =>
          var r = R.NoCycle
          try {
            v.getClass.getDeclaredFields.foreach { f =>
              if(!f.getName.startsWith("MODULE$")) {
                f.setAccessible(true)
                findCycleWithLength(f.get(v), n - 1, (s"declared field ${f.getName}", v) :: seen) match {
                  case R.NoCycle => ()
                  case R.LimitReached => r = R.LimitReached
                  case R.Cycle(elems) => r = R.Cycle(elems)
                }
              }
            }
          } catch {
            case Exit => r
          }
          r
        case _ => R.NoCycle
      }
    }
    @tailrec
    def go(n: Int): Option[List[Any]] = {
      findCycleWithLength(value, n, Nil) match {
        case R.NoCycle =>
          None
        case R.LimitReached => go(n+1)
        case R.Cycle(elems) => Some(elems)
      }
    }
    go(1)
  }

  case class RecursiveDependenciesException[A](vals: List[A]) extends Exception {
    override def getMessage: String = s"Recursive dependencies for topological sort: ${vals.mkString(" -> ")}."
  }
  /** Stable topological sort given keys and dependencies (by key) of values.
   *
   * @throws RecursiveDependenciesException if there are recursive dependencies
   */
  def topologicalSortWithKey[A, K](l: List[A])(deps: A => List[K])(key: A => K): List[A] = {
    val output = mutable.ListBuffer[A]()

    def go(l: Iterable[A], allEls: Iterable[A], trunk: List[A])(using Emit[A]): Unit = {
      if(l.isEmpty) { () } else if(trunk.contains(l.head)) {
        throw RecursiveDependenciesException(trunk)
      } else if(output.contains(l.head)) {
        // already output
        go(l.tail, allEls, trunk)
      } else {
        val missing = deps(l.head).filterNot { d => output.exists { o => key(o) == d } }.toSet
        if (missing.isEmpty) {
          // all dependencies there, output
          output.addOne(l.head)
          go(l.tail, allEls, trunk)
        } else {
          // missing dependencies first
          go(allEls.filter{ d => missing.contains(key(d)) }, allEls, l.head :: trunk)
          output.addOne(l.head)
          go(l.tail, allEls, trunk)
        }
      }
    }

    Emit.collectingInto(output){ go(l, l, Nil) }
    output.toList
  }

  /** NOTE: Will still have the body running, but return to the caller on timeout. */
  @throws[TimeoutException]
  def withTimeout[R](timeout: FiniteDuration)(body: => R): R = {
    // Inspired by https://stackoverflow.com/a/48731191
    import java.util.concurrent.{Executors, ThreadPoolExecutor}
    import scala.concurrent.{Await, Future}
    val executor = Executors.newFixedThreadPool(2)
    given ec: ExecutionContext = ExecutionContext.fromExecutor(executor)
    val future = Future{body}
    // FIXME Actually stop the future somehow
    Await.result(future, timeout)
  }

  extension(self: java.io.File) {
    def /(component: String): java.io.File = if (component == ".") self else new java.io.File(self, component)
  }
}
