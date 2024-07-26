package rpyeffectasm.util
import scala.collection.immutable.ListMap
import rpyeffectasm.{mcore, asm}

object JsonDebugPrinter extends JsonPrinter {
  def toDoc(t: Product): Doc = {
    jsonObject(ListMap.from(
      ("_prefix" -> s"\"${t.productPrefix}\"") +:
      ("_scala_class_name" -> s"\"${t.getClass.getName}\"") +:
      (0 until t.productArity).map { i =>
        t.productElementName(i) -> toDoc(t.productElement(i))
      }
    ))
  }
  def toDoc(a: Any): Doc = {
    a match {
      case i: IterableOnce[Any] => jsonList(List.from(i).map(toDoc).toList)
      case i: Tuple => jsonList(i.toList.map(toDoc))
      case a: Array[Any] => jsonList(a.map(toDoc).toList)
      case p: Product => toDoc(p)
      case other =>
        s"\"${escape(other.toString)}\""
    }
  }
  def apply(a: Any): Output = {
    new Output {
      override def emitTo[T](t: Target[T]): T = t.fromString(toDoc(a))
    }
  }

}
