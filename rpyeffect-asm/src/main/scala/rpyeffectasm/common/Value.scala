package rpyeffectasm.common
import rpyeffectasm.util.ErrorReporter
import scala.collection.mutable

trait Value {
  def tpe(using ErrorReporter): Type = ???
}

enum VBase extends Value {
  case VUnit
  case VInt(value: Int)
  case VDouble(value: Double)
  case VString(value: String)
  case VArray[Of](value: Array[Of])

  override def tpe(using ErrorReporter): Type = this match {
    case VUnit => Base.Unit
    case VInt(_) => Base.Int
    case VDouble(_) => Base.Double
    case VString(_) => Base.String
    case VArray(_) => ???
  }
}
case class VExternPtr[A](value: A, tag: String = "???") extends Value {
  override def tpe(using ErrorReporter) = ExternPtr(tag)
}
case class VData[Id](type_tag: Id, tag: Id, fields: List[Value]) extends Value {
  override def tpe(using ErrorReporter) = ???
}
case class VCodata[Id, Clause](ifce_tag: Id, methods: List[(Id, Clause)]) extends Value {
  override def tpe(using ErrorReporter) = ???
}

object Concrete {
  class VLabel extends Value {
    override def tpe(using ErrorReporter) = Label(Top, None)
  }
  case class VLib[X](path: String, symbols: Map[String, X]) extends Value {
    override def tpe(using ErrorReporter): Type = Ptr
  }
  case class VBox(num: Value) extends Value {
    override def tpe(using ErrorReporter): Type = ExternPtr("Box")
  }
  class VRef(var value: Value) extends Value {
    override def tpe(using ErrorReporter): Type = ExternPtr("Ref[Ptr]")
    val id = { VRef._lastId += 1; VRef._lastId }

    def freeze(): FrozenRef = FrozenRef(this, value)
  }
  object VRef {
    private var _lastId = 0
  }
  case class FrozenRef(ref: VRef, value: Value) {
    def restore(): Unit = {
      ref.value = value
    }
  }
  object VRegion {
    private var _lastId = 0
  }
  class VRegion(val refs: mutable.ListBuffer[VRef] = mutable.ListBuffer.empty) extends Value {
    val id = { VRegion._lastId += 1; VRegion._lastId }
    override def tpe(using ErrorReporter) = Ptr
    var frozen: List[FrozenRef] = Nil
    def freeze(): Unit = {
      frozen = refs.toList.map(_.freeze())
    }
    def restore(): Unit = {
      frozen.foreach(_.restore())
    }
  }
}