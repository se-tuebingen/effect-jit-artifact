package rpyeffectasm.common
import rpyeffectasm.{mcore, asm}

// Just as a common basis for the specification of [[Primitives]]

enum Purity {
  case Pure, Effectful
}
object Purity {
  val ErrorFlag: Purity = Effectful // for factoring out in the future
}

trait Type extends Tree {
  def asMCore: mcore.Type
}
case class Label(at: Type, bnd: Option[Type]) extends Type {
  override def asMCore: mcore.Type = mcore.Base.Label(at.asMCore, bnd.map(_.asMCore))
}
enum Base extends Type {
  case Unit, Bool, Int, Double, String

  override def asMCore: mcore.Type = this match {
    case Unit => mcore.Base.Unit
    case Bool => mcore.Base.Bool
    case Int => mcore.Base.Int
    case Double => mcore.Base.Double
    case String => mcore.Base.String
  }

}
object TData {
  case class Constructor[Id](tag: Id, fields: List[Type])
}
case class TData[Id](tag: Id, constructors: List[TData.Constructor[Id]]) extends Type {
  override def asMCore: mcore.Type = mcore.Data(tag.asInstanceOf, constructors.map{
    case TData.Constructor(tag, fields) => mcore.Constructor(tag.asInstanceOf, fields.map(_.asMCore))
  })
}
object Bottom extends Type {
  override def asMCore: mcore.Type = mcore.Bottom
}
object Num extends Type {
  override def asMCore: mcore.Type = mcore.Num
}
object Ptr extends Type {
  override def asMCore: mcore.Type = mcore.Ptr
}
object Top extends Type {
  override def asMCore: mcore.Type = mcore.Top
}
case class ExternPtr(name: String) extends Type {
  export Ptr.{asMCore}
}


