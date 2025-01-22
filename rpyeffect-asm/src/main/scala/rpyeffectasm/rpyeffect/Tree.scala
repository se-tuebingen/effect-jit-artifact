package rpyeffectasm
package rpyeffect

type Register = Int
type BlockLabel = Int
type ConstructorTag = Int
type MethodTag = Int

case class Symbol(name: String, position: Int)

case class Program(
  blocks: List[BasicBlock],
  symbols: List[Symbol],
  frameSize: FrameDescriptor
)

case class BasicBlock(
  id: String,
  frameDescriptor: FrameDescriptor,
  instructions: List[Instruction],
  terminator: Terminator)

enum Tag {
  case Index(i: Int)
  case Name(n: String)
}
case class VariableDescriptor(typ: Type, id: Register)
case class FrameDescriptor(locals: Int)
case class RegList(regs: List[Register])
object RegList {
  val empty = RegList(List.empty)
}
case class Clause(tag: Tag, params: RegList, target: BlockLabel)

sealed trait Instruction
case class Const(out: Register, value: Int) extends Instruction
case class ConstBool(out: Register, value: scala.Boolean) extends Instruction
case class ConstDouble(out: Register, value: scala.Double) extends Instruction
case class ConstString(out: Register, value: String) extends Instruction
case class ConstFormat(out: Register, value: String, fmt: String) extends Instruction
case class PrimOp(name: String, out: RegList, in: RegList) extends Instruction
case class Add(out: Register, in1: Register, in2: Register) extends Instruction
case class Push(target: BlockLabel, args: RegList) extends Instruction
case class ShiftDyn(out: Register, n: Register, label: Register) extends Instruction
case class Control(out: Register, n: Register, label: Register) extends Instruction
case class IfZero(arg: Register, thenClause: Clause) extends Instruction
case class Copy(from: Register, to: Register) extends Instruction
case class Drop(reg: Register) extends Instruction
case class Swap(a: Register, b: Register) extends Instruction
case class Allocate(out: Register, init: Register, region: Register) extends Instruction
case class Load(out: Register, ref: Register) extends Instruction
case class Store(ref: Register, value: Register) extends Instruction
case class Debug(msg: String, traced: RegList) extends Instruction
case class GetDynamic(out: Register, n: Register, label: Register) extends Instruction

case class Construct(out: Register, adt_type: Tag, tag: Tag, args: RegList) extends Instruction
case class Proj(out: Register, adt_type: Tag, scrutinee: Register, tag: Tag, field: Int) extends Instruction
case class PushStack(arg: Register) extends Instruction
case class NewStack(out: Register, region: Register, label: Register, target: BlockLabel, args: RegList) extends Instruction
case class NewStackWithBinding(out: Register, region: Register, label: Register, target: BlockLabel, args: RegList, binding: Register) extends Instruction
case class New(out: Register, tags: List[Tag], targets: List[BlockLabel], args: RegList) extends Instruction

sealed trait Terminator
case class Return(args: RegList) extends Terminator
case class Jump(target: BlockLabel) extends Terminator
case class Match(adt_type: Tag, scrutinee: Register, clauses: List[Clause], default: Clause) extends Terminator
case class Switch(arg: Register, values: List[asm.LiteralType], targets: List[BlockLabel], default: BlockLabel) extends Terminator
case class Invoke(receiver: Register, tag: Tag, args: RegList) extends Terminator
case class CallLib(lib: Register, symbol: String) extends Terminator
case class LoadLib(path: Register) extends Terminator

enum Type {
  case Continuation()
  case Integer()
  case Double()
  case String()
  case Label()
  case Datatype(index: Int)
  case Codata(index: Int)
  case Region()
  case Reference(to: Type)
}