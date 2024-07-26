package rpyeffectasm
package asm
import rpyeffectasm.common

sealed trait Type extends common.Type {
  override def asMCore: mcore.Type = ???
  override def asAsm: asm.OperandType[TypingPrecision] = this.asInstanceOf[asm.OperandType[TypingPrecision]]
}

/** Type-level enum for untyped / typed / concretely typed (no Top) */
sealed trait TypingPrecision
object TypingPrecision {
  sealed trait Typed extends TypingPrecision
  sealed trait Untyped extends Typed // Top everywhere
  sealed trait ConcretelyTyped extends Typed // no Top anywhere
}

type TypingEnvironment[+P <: TypingPrecision] = List[(Id, OperandType[P])]

sealed trait OperandType[+P <: TypingPrecision] extends Type
case class FormatConst(fmt: String, value: String)
type LiteralType = Int | Double | String | FormatConst
sealed trait Base extends OperandType[TypingPrecision.ConcretelyTyped] { type ScalaType }
object Base {
  object Int extends Base { type ScalaType = Int }
  object Double extends Base { type ScalaType = Double }
  object String extends Base { type ScalaType = String }
}
case class Data[+P <: TypingPrecision](tpe: Id, constructors: List[(Id, TypingEnvironment[P])]) extends OperandType[P]
case class CoData[+P <: TypingPrecision](tpe: Id, methods: List[(Id, TypingEnvironment[P], OperandType[P])]) extends OperandType[P]
case class RefType[+P <: TypingPrecision](valueType: OperandType[P]) extends OperandType[P]

case class StackT[+P <: TypingPrecision](args: TypingEnvironment[P], ret: OperandType[P]) extends OperandType[P]

object TopPtr extends OperandType[TypingPrecision.ConcretelyTyped]
object TopNum extends OperandType[TypingPrecision.ConcretelyTyped]
object Top extends OperandType[TypingPrecision.Untyped]
object Bot extends OperandType[TypingPrecision.ConcretelyTyped] // TODO correct?

case class LabelT[+P <: TypingPrecision](at: OperandType[P], bnd: Option[OperandType[P]]) extends OperandType[P]


type NumericType = Base.Int.type | Base.Double.type | TopNum.type
type PtrType = TopPtr.type | Data[TypingPrecision] | CoData[TypingPrecision] | RefType[TypingPrecision] | Base.String.type

object Type {

  import rpyeffectasm.asm.TypingPrecision.ConcretelyTyped
  import rpyeffectasm.rpyeffect.RegisterType
  import rpyeffectasm.rpyeffect.RegisterType.Ptr
  
  def getRegisterType(operandType: OperandType[ConcretelyTyped]): rpyeffect.RegisterType = operandType match {
    case Base.Int | Base.Double | TopNum => rpyeffect.RegisterType.Number
    case Base.String | LabelT(_,_)
         | Data(_, _) | CoData(_, _)
         | RefType(_) | StackT(_, _)
         | TopPtr => rpyeffect.RegisterType.Ptr
    case Bot => rpyeffect.RegisterType.Ptr // FIXME
  }
  def fromRegisterType(rtpe: rpyeffect.RegisterType): OperandType[ConcretelyTyped] = rtpe match {
    // This is a hack for [[Boxing]]
    case RegisterType.Number => TopNum
    case Ptr => TopPtr
  }
}