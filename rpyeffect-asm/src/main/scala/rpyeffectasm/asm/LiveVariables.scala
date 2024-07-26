package rpyeffectasm.asm

// This is a **reverse** analysis, so everything works backwards!
// With `compose`, this is forward again.
class LiveVariables[Flags <: AsmFlags, Tag <: Id, Label <: Id, Var <: Id, P <: TypingPrecision, OTpe >: OperandType[P] <: OperandType[TypingPrecision]] {
  type Res = List[Var]

  def use(v: Var): Res => Res = { frees => if (frees contains v) { frees } else { v :: frees } }
  def use(o: RhsOperand[Flags, Var, OTpe]): Res => Res = o match {
    case Var(name, _) => use(name)
    case Ref(ref) => use(ref)
    case o: RhsOperand[Flags, Nothing, OTpe] @unchecked => identity
  }
  def provide(v: Var): Res => Res = { frees => if (frees contains v) { frees.filterNot(_==v) } else { frees } }
  def provide(o: LhsOperand[Flags, Var, OTpe]): Res => Res = o match {
    case Var(name, _) => provide(name)
    case Ref(ref) => use(ref)
    case o: LhsOperand[Flags, Nothing, OTpe] @unchecked => identity
  }
  def alternatives(l: Iterable[Res => Res]): Res => Res = { frees =>
    l.toSet.flatMap(_(frees).toSet).toList
  }
  def alternatives(l: (Res => Res)*): Res => Res = alternatives(l.toList)
  def read(opList: RhsOpList[Flags, Var, OTpe]): Res => Res = opList.foldRight(identity[Res]) { case (rhs, o) => use(rhs) compose o }
  def write(opList: LhsOpList[Flags, Var, OTpe]): Res => Res = opList.foldRight(identity[Res]) { case (lhs, o) => provide(lhs) compose o }
  def exec(c: Clause[Flags, Tag, Var, OTpe]): Res => Res = c match {
    case Clause(params, capts, target) =>
      write(params) compose read(capts)
  }
  def exec(i: Instruction[Flags, Label, Tag, Var, OTpe]): Res => Res = i match {
    case Let(lhss, rhss) => read(rhss) compose write(lhss)
    case LetConst(out, value) => provide(out)
    case Primitive(out, name, in) => read(in) compose write(out)
    case Push(target, args) => read(args)
    case Return(args) => read(args)
    case Jump(target, args) => read(args)
    case CallLib(lib, symbol, env) => use(lib) compose read(env)
    case LoadLib(path) => use(path)
    case IfZero(arg, thenClause) => alternatives(identity, exec(thenClause)) // TODO ???
    case Allocate(ref, init, region) =>
      use(region) compose use(init) compose provide(ref)
    case Load(out, ref) => use(ref) compose provide(out)
    case Store(ref, in) => use(in) compose use(ref)
    case GetDynamic(out, n, label) => use(n) compose use(label) compose provide(out)
    case Shift(out, n, label) => use(n) compose use(label) compose provide(out)
    case Control(out, n, label) => use(n) compose use(label) compose provide(out)
    case PushStack(stack) => use(stack)
    case NewStack(stack, region, label, target, args) =>
      use(label) compose read(args) compose provide(stack) compose provide(region)
    case NewStackWithBinding(stack, region, label, target, args, bnd) =>
      use(label) compose read(args) compose use(bnd) compose provide(stack) compose provide(region)
    case Construct(out, tpe, tag, args) =>
      read(args) compose provide(out)
    case Match(tpe, scrutinee, clauses, default) =>
      use(scrutinee) compose alternatives(exec(default) :: clauses.map{ case (_,c) => exec(c) }) // TODO ???
    case Proj(out, tpe, scrutinee, tag, field) =>
      use(scrutinee) compose provide(out)
    case New(out, ifce, targets, args) =>
      read(args) compose provide(out)
    case Invoke(receiver, ifce, tag, args) =>
      read(args) compose use(receiver)
    case Switch(arg, cases, default, env) =>
      use(arg) compose read(env)
    case Debug(msg, traced) =>
      read(traced)
  }

  def zipInstructionsWith(l: List[Instruction[Flags, Label, Tag, Var, OTpe]]): List[(Instruction[Flags, Label, Tag, Var, OTpe], List[Var])] = {
    def go(l: List[Instruction[Flags, Label, Tag, Var, OTpe]]) = l.foldRight((List.empty[(Instruction[Flags, Label, Tag, Var, OTpe], Res)], List.empty[Var])) {
      case (hd, (rtl, rhd)) =>
        ((hd, rhd) :: rtl, exec(hd)(rhd))
    }
    go(l)._1
  }
  def apply(l: List[Instruction[Flags, Label, Tag, Var, OTpe]]): List[Var] = {
    l.foldRight(List.empty[Var]) { case (i, l) => exec(i)(l) }
  }
}
