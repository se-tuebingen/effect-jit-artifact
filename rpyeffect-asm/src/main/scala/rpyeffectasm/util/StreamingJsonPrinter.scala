package rpyeffectasm.util
import rpyeffectasm.util
import Emit.*
import scala.collection.mutable

trait StreamingJsonPrinter extends util.StreamingPrinter
object StreamingJsonPrinter {
  import StreamingPrinter.*
  trait KVPair extends StreamingJsonPrinter
  extension(self: String) {
    def toJson: StreamingJsonPrinter = { (e: Emit[String]) ?=> emit(s"\"${util.escape(self)}\"") }
    def -->(body: => StreamingJsonPrinter): KVPair = { (e: Emit[String]) ?=>
      self.toJson.run
      emit(":\n")
      body.run
    }
  }
  extension(self: Int) {
    def json: StreamingJsonPrinter = { (e: Emit[String]) ?=> emit(self.toString) }
  }
  extension(self: Boolean) {
    def json: StreamingJsonPrinter = { (e: Emit[String]) ?=> if(self){ emit("true") } else { emit("false") } }
  }
  def obj(entries: => KVPair*): StreamingJsonPrinter = { (e: Emit[String]) ?=>
    emit("{")
    sepBy(entries, ",\n").run
    emit("}")
  }
  def obj(body: Emit[KVPair] ?=> Unit): StreamingJsonPrinter = { (e: Emit[String]) ?=>
    emit("{")
    sepBy(",\n")(body).run
    emit("}")
  }
  def objL(entries: => Iterable[KVPair]): StreamingJsonPrinter = { (e: Emit[String]) ?=>
    emit("{"); sepBy(entries, ",\n").run; emit("}")
  }
  def objOf[A](fn: A => KVPair)(els: Iterable[A]): StreamingJsonPrinter = obj{ (e: Emit[KVPair]) ?=>
    els.foreach{ el => emit(fn(el)) }
  }
  def list(entries: => StreamingJsonPrinter*): StreamingJsonPrinter = { (e: Emit[String]) ?=>
    emit("["); sepBy(entries, ",\n").run; emit("]")
  }
  def list(body: Emit[StreamingPrinter] ?=> Unit): StreamingJsonPrinter = { (e: Emit[String]) ?=>
    emit("["); sepBy(",\n")(body).run; emit("]")
  }
  def listL(entries: Iterable[StreamingJsonPrinter]): StreamingJsonPrinter = { (e: Emit[String]) ?=>
    emit("["); sepBy(entries, ",\n"); emit("]")
  }
  def listOf[A](fn: A => StreamingJsonPrinter)(els: Iterable[A]): StreamingJsonPrinter = list{ (em: Emit[StreamingJsonPrinter]) ?=>
      els.foreach{ el => emit(fn(el)) }
    }
  def raw(jsonString: String): StreamingJsonPrinter = { (em: Emit[String]) ?=> emit(jsonString) }

  extension(self: StreamingJsonPrinter) {
    def wrapState(before: => Unit)(after: => Unit): StreamingJsonPrinter = { (em: Emit[String]) ?=>
      before
      self.run
      after
    }
  }

  trait SharingContext
  given NoSharingContext: SharingContext = new SharingContext {}
  case class DoSharingContext(shared: mutable.HashMap[Int, Int], var nextId: Int) extends SharingContext
  def allowSharing[R](body: SharingContext ?=> R): R = {
    body(using DoSharingContext(new mutable.HashMap(), 0))
  }
  def explicitlySharing[A](o: A)(body: A => Iterable[KVPair])(using sc: SharingContext): StreamingJsonPrinter = sc match {
    case sc: DoSharingContext =>
      if(sc.shared.contains(System.identityHashCode(o))) {
        obj("__sharingId" --> sc.shared(System.identityHashCode(o)).json, "__shared" --> true.json)
      } else {
        val id = sc.nextId
        sc.nextId += 1
        sc.shared.put(System.identityHashCode(o), id)
        objL("__sharingId" --> id.json :: "__shared" --> false.json :: body(o).toList)
      }
    case _ => objL(body(o))
  }

}