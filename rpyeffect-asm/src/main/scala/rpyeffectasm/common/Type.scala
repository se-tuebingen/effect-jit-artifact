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
  def asAsm: asm.OperandType[asm.TypingPrecision]
}
case class Label(at: Type, bnd: Option[Type]) extends Type {
  import rpyeffectasm.asm.{OperandType, TypingPrecision}
  override def asMCore: mcore.Type = mcore.Base.Label(at.asMCore, bnd.map(_.asMCore))
  override def asAsm: OperandType[TypingPrecision] = asm.LabelT(at.asAsm, bnd.map(_.asAsm))
}
enum Base extends Type {
  case Unit, Int, Double, String

  override def asMCore: mcore.Type = this match {
    case Unit => mcore.Base.Unit
    case Int => mcore.Base.Int
    case Double => mcore.Base.Double
    case String => mcore.Base.String
  }

  override def asAsm: asm.OperandType[asm.TypingPrecision] = this match {
    case Unit => asm.Top // TODO ?
    case Int => asm.Base.Int
    case Double => asm.Base.Double
    case String => asm.Base.String
  }
}
object TData {
  case class Constructor[Id](tag: Id, fields: List[Type])
}
case class TData[Id](tag: Id, constructors: List[TData.Constructor[Id]]) extends Type {
  override def asMCore: mcore.Type = mcore.Data(tag.asInstanceOf, constructors.map{
    case TData.Constructor(tag, fields) => mcore.Constructor(tag.asInstanceOf, fields.map(_.asMCore))
  })

  override def asAsm: asm.OperandType[asm.TypingPrecision] = asm.Data(tag.asInstanceOf, constructors.map{
    case TData.Constructor(tag, fields) => (tag.asInstanceOf, fields.zipWithIndex.map{ (t, i) =>
      (asm.Index(i), t.asAsm.asInstanceOf)})
  })
}
object Bottom extends Type {
  override def asMCore: mcore.Type = mcore.Bottom
  override def asAsm: asm.OperandType[asm.TypingPrecision] = asm.Bot
}
object Num extends Type {
  override def asMCore: mcore.Type = mcore.Num
  override def asAsm: asm.OperandType[asm.TypingPrecision] = asm.TopNum
}
object Ptr extends Type {
  override def asMCore: mcore.Type = mcore.Ptr
  override def asAsm: asm.OperandType[asm.TypingPrecision] = asm.TopPtr
}
object Top extends Type {
  override def asMCore: mcore.Type = mcore.Top
  override def asAsm: asm.OperandType[asm.TypingPrecision] = asm.Top
}
case class ExternPtr(name: String) extends Type {
  export Ptr.{asAsm, asMCore}
}


