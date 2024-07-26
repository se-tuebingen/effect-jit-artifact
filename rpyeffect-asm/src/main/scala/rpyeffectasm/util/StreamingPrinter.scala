package rpyeffectasm.util
import rpyeffectasm.util.Emit.*

trait StreamingPrinter extends Output  {
  def run(using Emit[String]): Unit

  override def emitTo[T](t: Target[T]): T = {
    t.collecting {
      run
    }
  }
}
object StreamingPrinter {
  def sepBy(iterable: Iterable[StreamingPrinter], sep: String): StreamingPrinter = { (em: Emit[String]) ?=>
    iterable.headOption.foreach { e0 =>
      e0.run
      iterable.tail.foreach { e =>
        emit(sep)
        e.run
      }
    }
  }
  def sepBy(sep: String)(body: Emit[StreamingPrinter] ?=> Unit): StreamingPrinter = { (em: Emit[String]) ?=>
    var isFirst = true
    body(using (a: StreamingPrinter) => {
      if(isFirst) { isFirst = false } else { emit(sep) }
      a.run
    })
  }
}