package rpyeffectasm.util
import scala.collection.mutable

object DebugInfo extends Output {
  private sealed trait Node
  private class InnerNode(val children: mutable.HashMap[String, Node] = new mutable.HashMap[String, Node]) extends Node
  private case class Leaf(value: Any) extends Node

  var active = false
  private val result: mutable.HashMap[String, Node] = new mutable.HashMap[String, Node]()

  def log(keys: String*)(value: => Any): Unit = {
    import scala.collection.immutable.{AbstractSeq, LinearSeq}
    def go(start: mutable.HashMap[String, Node], keys: Seq[String]): Unit = {
      if(keys.length == 1) {
        start.update(keys.head, Leaf(value))
      } else {
        go(start.getOrElseUpdate(keys.head, new InnerNode) match {
          case node: InnerNode => node.children
          case Leaf(value) => ???
        }, keys.tail)
      }
    }
    if(active) {
      go(result, keys)
    }
  }

  private def isNumber(s: String): Boolean = s.matches("-?[0-9]+")

  private object Printer extends JsonPrinter {
    def apply(m: mutable.Map[String, Node]): Doc = {
      jsonObject(scala.collection.immutable.ListMap.from(
        m.toList.map{
          (k,v) => (escape(k), apply(v))
        }.sortWith{
          case ((k1, _), (k2, _)) if isNumber(k1) && isNumber(k2) =>
            k1.toInt < k2.toInt
          case ((k1, _), (k2, _)) if isNumber(k1) => false
          case ((k1, _), (k2, _)) if isNumber(k2) => true
          case ((k1, _), (k2, _)) => k1 < k2
        }))
    }

    def apply(node: Node): Doc = node match {
      case node: InnerNode => apply(node.children)
      case Leaf(value) => JsonDebugPrinter(value).emitTo(new StringTarget)
    }
  }

  override def emitTo[T](t: Target[T]): T = t.fromString(Printer(result))
}


