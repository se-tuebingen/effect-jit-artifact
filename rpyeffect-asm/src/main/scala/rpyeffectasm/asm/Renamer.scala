package rpyeffectasm.asm
import scala.collection.mutable

/** Renames all Generated symbols to Names deterministically as gen0,gen1,... For testing. */
class Renamer[Flags <: AsmFlags, Tag <: Id, Label <: Id, V <: Id, P <: TypingPrecision, OTpe >: OperandType[P] <: OperandType[P]] {
  case class State(var nextIndex: Int, symbols: mutable.Map[Generated, Int]) {
    def apply(g: Generated): Int = {
      symbols.getOrElseUpdate(g, {
        val r = nextIndex
        nextIndex = nextIndex + 1
        r
      })
    }
  }
  def apply[T <: Id](i: Generated | T)(using S: State): Name | T = i  match {
    case g: Generated => Name(s"gen${S(g)}")
    case other: T @unchecked => other
  }
  def apply(tpe: OTpe | OperandType[P])(using State): OTpe | OperandType[P] = tpe match {
    case Data(tpe, constructors) => Data(apply(tpe), constructors map { case (id, value) => (apply(id), value map {
      case (id, value) => (apply(id), apply(value))
    })})
    case CoData(tpe, methods) => CoData(apply(tpe), methods map { case (id, value, ret) => (apply(id), value map {
      case (id, value) => (apply(id), apply(value))
    }, apply(ret))})
    case RefType(valueType) => RefType(apply(valueType))
    case other => other
  }
  def apply[Flags <: AsmFlags, V <: Id](l: LhsOperand[Flags, Generated | V, OTpe])(using State): LhsOperand[Flags, Name | V, OTpe] = l match {
    case Var(name, tpe) => Var(apply(name), apply(tpe))
    case Ref(ref) => Ref(apply(ref))
  }
  def apply[Flags <: AsmFlags, V <: Id](r: RhsOperand[Flags, Generated | V, OTpe])(using State): RhsOperand[Flags, Name | V, OTpe] = r match {
    case Const(value) => Const(value)
    case Var(name, tpe) => Var(apply(name), apply(tpe))
    case Ref(ref) => Ref(apply(ref))
  }
  def apply(clause: Clause[Flags, Generated | Label, Generated | V, OTpe])(using State): Clause[Flags, Name | Label, Name | V, OTpe] = clause match {
    case Clause(params, env, target) => Clause(params map apply, env map apply, apply(target))
  }
  def apply(instruction: Instruction[Flags, Generated | Tag, Generated | Label, Generated | V, OTpe])(using State): Instruction[Flags, Name | Tag, Name | Label, Name | V, OTpe] = instruction match {
    case Let(lhss, rhss) => Let(lhss map apply, rhss map apply)
    case LetConst(out, value) => LetConst(apply(out).asInstanceOf, value)
    case Primitive(out, name, in) => Primitive(out map apply, name, in map apply)
    case Push(target, args) => Push(apply(target), args map apply)
    case Return(args) => Return(args map apply)
    case Jump(target, env) => Jump(apply(target), env map apply)
    case IfZero(arg, thenClause) => IfZero(apply(arg), apply(thenClause))
    case Allocate(ref, init, region) => Allocate(apply(ref), apply(init), apply(region))
    case Load(out, ref) => Load(apply(out), apply(ref))
    case Store(ref, in) => Store(apply(ref), apply(in))
    case GetDynamic(out, n, label) => GetDynamic(apply(out), apply(n), apply(label))
    case Shift(out, n, label) => Shift(apply(out), apply(n), apply(label))
    case Control(out, n, label) => Control(apply(out), apply(n), apply(label))
    case PushStack(stack) => PushStack(apply(stack))
    case NewStack(stack, region, label, target, args) => NewStack(apply(stack), apply(region), apply(label), apply(target), args map apply)
    case NewStackWithBinding(stack, region, label, target, args, bnd) =>
      NewStackWithBinding(apply(stack), apply(region), apply(label), apply(target), args map apply, apply(bnd))
    case Construct(out, tpe, tag, args) => Construct(apply(out), apply(tpe), apply(tag), args map apply)
    case Match(tpe, scrutinee, clauses, default) => Match(apply(tpe), apply(scrutinee), clauses map {
      case (id, value) => (apply(id), apply(value))
    }, apply(default))
    case Switch(arg, cases, default, env) =>
      Switch(apply(arg), cases.map{ case (i, t) => (i, apply(t)) }, apply(default), env map apply)
    case Proj(out, tpe, scrutinee, tag, field) => Proj(apply(out), apply(tpe), apply(scrutinee), apply(tag), field)
    case New(out, ifce, targets, args) => New(apply(out), apply(ifce), targets map {
      case (tag, target) => (apply(tag), apply(target))
    }, args map apply)
    case Invoke(receiver, ifce, tag, args) => Invoke(apply(receiver), apply(ifce), apply(tag), args map apply)
    case CallLib(lib, symbol, env) => CallLib(apply(lib), symbol, env map apply)
    case LoadLib(path) => LoadLib(apply(path))
    case Debug(msg, traced) => Debug(msg, traced map apply) 
  }
  def apply(block: Block[Flags, Generated | Tag, Generated | Label, Generated | V, OTpe])(using State): Block[Flags, Name | Tag, Name | Label, Name | V, OTpe] = block match {
    case Block(label, params, ret, instructions, export_as) => Block(apply(label), params map apply, ret, instructions map apply, export_as)
  }
  def apply(program: Program[Flags, Generated | Tag, Generated | Label, Generated | V, OTpe]): Program[Flags, Name | Tag, Name | Label, Name | V, OTpe] = program match {
    case Program(blocks) =>
      given State = State(0, mutable.Map.empty)
      Program(blocks map apply)
  }

}