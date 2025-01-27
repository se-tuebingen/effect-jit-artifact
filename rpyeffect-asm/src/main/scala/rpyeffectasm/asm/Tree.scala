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
sealed trait RhsOperand[+Flags <: AsmFlags, +V <: Id]
case class Const[+Flags <: AsmFlags, +T <: LiteralType](value: T) extends RhsOperand[Flags | AsmFlags.ConstantOperands, Nothing]


sealed trait LhsOperand[+Flags <: AsmFlags, +V <: Id]
case class Var[+V <: Id](name: V) extends LhsOperand[Nothing, V], RhsOperand[Nothing, V]
case class Ref[+Flags <: AsmFlags, +V <: Id](ref: RhsOperand[Flags, V]) extends LhsOperand[Flags | AsmFlags.RefOperands, V], RhsOperand[Flags | AsmFlags.RefOperands, V]
//endregion

type RhsOpList[+Flags <: AsmFlags, +V <: Id] = List[RhsOperand[Flags, V]]
type LhsOpList[+Flags <: AsmFlags, +V <: Id] = List[LhsOperand[Flags, V]]
type VTable[+Tag <: Id, +Label <: Id] = List[(Tag,Label)]

// TODO document what params and env mean *exactly*
// params: What should be added by the construct with the clause
// env: What will be used at target
//      - including params,
//      - in consistent order between the clauses of a Match,
//      - in same order as at target parameters.
case class Clause[+Flags <: AsmFlags, +Label <: Id, +V <: Id](params: LhsOpList[Flags, V], env: RhsOpList[Flags, V], target: Label)

//region Instructions
sealed trait Instruction[+Flags <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id] extends common.Tree
sealed trait Terminator extends common.Tree
// simple instructions
case class Let[+Flags <: AsmFlags, +V <: Id, +OTpe](lhss: LhsOpList[Flags, V], rhss: RhsOpList[Flags, V]) extends Instruction[Flags, Nothing, Nothing, V]
case class LetConst[+Flags <: AsmFlags, +V <: Id, T <: LiteralType](out: LhsOperand[Flags, V], value: T) extends Instruction[Flags, Nothing, Nothing, V]

// primitives
case class Primitive[+Flags <: AsmFlags, +V <: Id, +OTpe](out: LhsOpList[Flags, V], name: String, in: RhsOpList[Flags, V]) extends Instruction[Flags, Nothing, Nothing, V]
case class Debug[+Flags <: AsmFlags, +V <: Id, +OTpe](msg: String, trace: RhsOpList[Flags, V]) extends Instruction[Flags, Nothing, Nothing, V]

// Stack
case class Push[+Flags <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](target: Label, args: RhsOpList[Flags, V]) extends Instruction[Flags, Nothing, Label, V]
case class Return[+Flags <: AsmFlags, +V <: Id, +OTpe](args: RhsOpList[Flags, V]) extends Instruction[Flags, Nothing, Nothing, V] with Terminator

// Control flow
case class Jump[+Flags <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](target: Label, env: RhsOpList[Flags, V]) extends Instruction[Flags, Nothing, Label, V] with Terminator
case class IfZero[+Flags <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](arg: RhsOperand[Flags, V], thenClause: Clause[Flags, Label, V]) extends Instruction[Flags, Nothing, Label, V]
case class Switch[+Flags <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](arg: RhsOperand[Flags, V], cases: List[(LiteralType, Label)], default: Label, env: RhsOpList[Flags, V]) extends Instruction[Flags, Nothing, Label, V] with Terminator

// Mutable references
case class Allocate[+Flags <: AsmFlags, +V <: Id, +OTpe](ref: LhsOperand[Flags, V], init: RhsOperand[Flags, V], region: RhsOperand[Flags, V]) extends Instruction[Flags, Nothing, Nothing, V]
case class Load[+Flags <: AsmFlags, +V <: Id, +OTpe](out: LhsOperand[Flags, V], ref: RhsOperand[Flags, V]) extends Instruction[Flags, Nothing, Nothing, V]
case class Store[+Flags <: AsmFlags, +V <: Id, +OTpe](ref: RhsOperand[Flags, V], in: RhsOperand[Flags, V]) extends Instruction[Flags, Nothing, Nothing, V]

// Stacks / metastack
case class Shift[+F <: AsmFlags, +V <: Id, +OTpe](out: LhsOperand[F,V], n: RhsOperand[F,V], label: RhsOperand[F,V]) extends Instruction[F,Nothing, Nothing, V]
case class Control[+F <: AsmFlags, +V <: Id, +OTpe](out: LhsOperand[F,V], n: RhsOperand[F,V], label: RhsOperand[F,V]) extends Instruction[F,Nothing, Nothing, V]
case class PushStack[+F <: AsmFlags, +V <: Id, +OTpe](stack: RhsOperand[F, V]) extends Instruction[F, Nothing, Nothing, V]
case class NewStack[+F <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](stack: LhsOperand[F, V], region: LhsOperand[F, V], label: RhsOperand[F, V], target: Label, args: RhsOpList[F, V]) extends Instruction[F, Nothing, Label, V]
// dynamic binding
case class NewStackWithBinding[+F <: AsmFlags, +Label <: Id, +V <: Id, +OTpe](stack: LhsOperand[F, V], region: LhsOperand[F, V], label: RhsOperand[F, V], target: Label, args: RhsOpList[F, V], binding: RhsOperand[F, V]) extends Instruction[F, Nothing, Label, V]
case class GetDynamic[+F <: AsmFlags, +V <: Id, +OTpe](out: LhsOperand[F, V], n: RhsOperand[F, V], label: RhsOperand[F, V]) extends Instruction[F, Nothing, Nothing, V]

// Data
case class Construct[+F <: AsmFlags, +Tag <: Id, +V <: Id, +OTpe](out: LhsOperand[F,V], tpe: Tag, tag: Tag, args: RhsOpList[F,V]) extends Instruction[F, Tag, Nothing, V]
case class Match[+F <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id, +OTpe](tpe: Tag, scrutinee: RhsOperand[F,V], clauses: List[(Tag, Clause[F, Label, V])], default: Clause[F,Label, V]) extends Instruction[F, Tag, Label, V] with Terminator
case class Proj[+F <: AsmFlags, +Tag <: Id, +V <: Id, +OTpe](out: LhsOperand[F,V], tpe: Tag, scrutinee: RhsOperand[F,V], tag: Tag, field: Int) extends Instruction[F, Tag, Nothing, V]

// Codata
case class New[+F <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id, +OTpe](out: LhsOperand[F,V], ifce: Tag, targets: VTable[Tag, Label], args: RhsOpList[F,V]) extends Instruction[F, Tag, Label, V]
case class Invoke[+F <: AsmFlags, +Tag <: Id, +V <: Id, +OTpe](receiver: RhsOperand[F,V], ifce: Tag, tag: Tag, args: RhsOpList[F,V]) extends Instruction[F, Tag, Nothing, V] with Terminator

// Dynamically loaded code
case class CallLib[+F <: AsmFlags, +V <: Id, +OTpe](lib: RhsOperand[F, V], symbol: String, env: RhsOpList[F, V]) extends Instruction[F, Nothing, Nothing, V] with Terminator
case class LoadLib[+F <: AsmFlags, +V <: Id, +OTpe](path: RhsOperand[F, V]) extends Instruction[F, Nothing, Nothing, V] with Terminator
//endregion

// Blocks, Program
case class Block[+Flags <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id](label: Label, params: LhsOpList[Nothing, V], instructions: List[Instruction[Flags, Tag, Label, V]], export_as: List[String])
case class Program[+Flags <: AsmFlags, +Tag <: Id, +Label <: Id, +V <: Id](blocks: List[Block[Flags, Tag, Label, V]])