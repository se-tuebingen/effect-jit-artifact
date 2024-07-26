package rpyeffectasm
package asm
import rpyeffectasm.common

/** Type level flags for which syntactic constructs are allowed */
sealed trait AsmFlags
object AsmFlags {
  sealed trait ConstantOperands extends AsmFlags
  sealed trait RefOperands extends AsmFlags
}

//region Identifiers
sealed trait Id { def name: String }
case class Name(name: String) extends Id
/** For symbols generated during transformations */
object Generated {
  var lastId = 0
  lazy val runId = java.util.UUID.randomUUID() // TODO To make this deterministic, use e.g. input hash
}
class Generated(doc: String) extends Id {
  val id = { Generated.lastId = Generated.lastId + 1; Generated.lastId }
  override def toString: String = s"${name}".replaceAll("[\"\n]", "_")
  def name = if doc.length < 40 then s"[${doc}#${id}]" else s"[#${id}]"
  {
    import rpyeffectasm.util.DebugInfo
    DebugInfo.log("asm", "Generated", this.toString, "origin"){ Thread.currentThread().getStackTrace() }
    DebugInfo.log("asm", "Generated", this.toString, "doc")(doc)
  }
}
case class Index(i: Int) extends Id {
  def name = s"#${i}"
  def debug: String = ""
}
class IndexWithDebug(i: Int, override val debug: String) extends Index(i)
object IndexWithDebug {
  def unapply(x: IndexWithDebug): Some[(Int, String)] = Some((x.i, x.debug))
}
//endregion

//region Operands
sealed trait RhsOperand[+Flags <: AsmFlags, +V <: Id, +OTpe] { def tpe: OTpe }
case class Const[+Flags <: AsmFlags, +T <: LiteralType](value: T) extends RhsOperand[Flags | AsmFlags.ConstantOperands, Nothing, Base] {
  def tpe = value match {
    case _: Int => Base.Int
    case _: String => Base.String
    case _: Double => Base.Double
  }
}


sealed trait LhsOperand[+Flags <: AsmFlags, +V <: Id, +OTpe] { def tpe: OTpe }
case class Var[+V <: Id, +OTpe](name: V, tpe: OTpe) extends LhsOperand[Nothing, V, OTpe], RhsOperand[Nothing, V, OTpe]
case class Ref[+Flags <: AsmFlags, +V <: Id, P <: asm.TypingPrecision, +OTpe >: OperandType[P]](ref: RhsOperand[Flags, V, OTpe]) extends LhsOperand[Flags | AsmFlags.RefOperands, V, OTpe], RhsOperand[Flags | AsmFlags.RefOperands, V, OTpe] {
  def tpe: OTpe = ref.tpe match {
    case t : RefType[P] @unchecked => t.valueType // FIXME
    case t@Top => t
    case _ => ??? // TODO error out
  }
}
//endregion

type RhsOpList[+Flags <: AsmFlags, +V <: Id, +OTpe] = List[RhsOperand[Flags, V, OTpe]]
type LhsOpList[+Flags <: AsmFlags, +V <: Id, +OTpe] = List[LhsOperand[Flags, V, OTpe]]
type VTable[+Tag <: Id, +Label <: Id] = List[(Tag,Label)]

// TODO document what params and env mean *exactly*
// params: What should be added by the construct with the clause
// env: What will be used at target
//      - including params,
//      - in consistent order between the clauses of a Match,
//      - in same order as at target parameters.
case class Clause[+Flags <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](params: LhsOpList[Flags, V, OTpe], env: RhsOpList[Flags, V, OTpe], target: Label)

//region Instructions
sealed trait Instruction[+Flags <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id, +OTpe] extends common.Tree
sealed trait Terminator extends common.Tree
// simple instructions
case class Let[+Flags <: AsmFlags, +V <: Id, +OTpe](lhss: LhsOpList[Flags, V, OTpe], rhss: RhsOpList[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Nothing, V, OTpe]
case class LetConst[+Flags <: AsmFlags, +V <: Id, T <: LiteralType](out: LhsOperand[Flags, V, Base], value: T) extends Instruction[Flags, Nothing, Nothing, V, Base]

// primitives
case class Primitive[+Flags <: AsmFlags, +V <: Id, +OTpe](out: LhsOpList[Flags, V, OTpe], name: String, in: RhsOpList[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Nothing, V, OTpe]
case class Debug[+Flags <: AsmFlags, +V <: Id, +OTpe](msg: String, trace: RhsOpList[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Nothing, V, OTpe]

// Stack
case class Push[+Flags <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](target: Label, args: RhsOpList[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Label, V, OTpe]
case class Return[+Flags <: AsmFlags, +V <: Id, +OTpe](args: RhsOpList[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Nothing, V, OTpe] with Terminator

// Control flow
case class Jump[+Flags <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](target: Label, env: RhsOpList[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Label, V, OTpe] with Terminator
case class IfZero[+Flags <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](arg: RhsOperand[Flags, V, OTpe], thenClause: Clause[Flags, Label, V, OTpe]) extends Instruction[Flags, Nothing, Label, V, OTpe]
case class Switch[+Flags <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](arg: RhsOperand[Flags, V, OTpe], cases: List[(Int, Label)], default: Label, env: RhsOpList[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Label, V, OTpe] with Terminator

// Mutable references
case class Allocate[+Flags <: AsmFlags, +V <: Id, +OTpe](ref: LhsOperand[Flags, V, OTpe], init: RhsOperand[Flags, V, OTpe], region: RhsOperand[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Nothing, V, OTpe]
case class Load[+Flags <: AsmFlags, +V <: Id, +OTpe](out: LhsOperand[Flags, V, OTpe], ref: RhsOperand[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Nothing, V, OTpe]
case class Store[+Flags <: AsmFlags, +V <: Id, +OTpe](ref: RhsOperand[Flags, V, OTpe], in: RhsOperand[Flags, V, OTpe]) extends Instruction[Flags, Nothing, Nothing, V, OTpe]

// Stacks / metastack
case class Shift[+F <: AsmFlags, +V <: Id, +OTpe](out: LhsOperand[F,V,OTpe], n: RhsOperand[F,V,OTpe], label: RhsOperand[F,V,OTpe]) extends Instruction[F,Nothing, Nothing, V,OTpe]
case class Control[+F <: AsmFlags, +V <: Id, +OTpe](out: LhsOperand[F,V,OTpe], n: RhsOperand[F,V,OTpe], label: RhsOperand[F,V,OTpe]) extends Instruction[F,Nothing, Nothing, V,OTpe]
case class PushStack[+F <: AsmFlags, +V <: Id, +OTpe](stack: RhsOperand[F, V,OTpe]) extends Instruction[F, Nothing, Nothing, V, OTpe]
case class NewStack[+F <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](stack: LhsOperand[F, V, OTpe], region: LhsOperand[F, V, OTpe], label: RhsOperand[F, V, OTpe], target: Label, args: RhsOpList[F, V, OTpe]) extends Instruction[F, Nothing, Label, V, OTpe]
// dynamic binding
case class NewStackWithBinding[+F <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](stack: LhsOperand[F, V, OTpe], region: LhsOperand[F, V, OTpe], label: RhsOperand[F, V, OTpe], target: Label, args: RhsOpList[F, V, OTpe], binding: RhsOperand[F, V, OTpe]) extends Instruction[F, Nothing, Label, V, OTpe]
case class GetDynamic[+F <: AsmFlags, +V <: Id, +OTpe](out: LhsOperand[F, V, OTpe], n: RhsOperand[F, V, OTpe], label: RhsOperand[F, V, OTpe]) extends Instruction[F, Nothing, Nothing, V, OTpe]

// Data
case class Construct[+F <: AsmFlags, +Tag <: Id, +V <: Id, +OTpe](out: LhsOperand[F,V,OTpe], tpe: Tag, tag: Tag, args: RhsOpList[F,V,OTpe]) extends Instruction[F, Tag, Nothing, V,OTpe]
case class Match[+F <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id, +OTpe](tpe: Tag, scrutinee: RhsOperand[F,V,OTpe], clauses: List[(Tag, Clause[F, Label, V, OTpe])], default: Clause[F,Label, V, OTpe]) extends Instruction[F, Tag, Label, V, OTpe] with Terminator
case class Proj[+F <: AsmFlags, +Tag <: Id, +V <: Id, +OTpe](out: LhsOperand[F,V,OTpe], tpe: Tag, scrutinee: RhsOperand[F,V,OTpe], tag: Tag, field: Int) extends Instruction[F, Tag, Nothing, V, OTpe]

// Codata
case class New[+F <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id, +OTpe](out: LhsOperand[F,V, OTpe], ifce: Tag, targets: VTable[Tag, Label], args: RhsOpList[F,V, OTpe]) extends Instruction[F, Tag, Label, V, OTpe]
case class Invoke[+F <: AsmFlags, +Tag <: Id, +V <: Id, +OTpe](receiver: RhsOperand[F,V, OTpe], ifce: Tag, tag: Tag, args: RhsOpList[F,V, OTpe]) extends Instruction[F, Tag, Nothing, V, OTpe] with Terminator

// Dynamically loaded code
case class CallLib[+F <: AsmFlags, +V <: Id, +OTpe](lib: RhsOperand[F, V, OTpe], symbol: String, env: RhsOpList[F, V, OTpe]) extends Instruction[F, Nothing, Nothing, V, OTpe] with Terminator
case class LoadLib[+F <: AsmFlags, +V <: Id, +OTpe](path: RhsOperand[F, V, OTpe]) extends Instruction[F, Nothing, Nothing, V, OTpe] with Terminator
//endregion

// Blocks, Program
case class Block[+Flags <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id, +OTpe](label: Label, params: LhsOpList[Nothing, V, OTpe], retTpe: OTpe, instructions: List[Instruction[Flags, Tag, Label, V, OTpe]], export_as: List[String])
case class Program[+Flags <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id, +OTpe](blocks: List[Block[Flags, Tag, Label, V, OTpe]])