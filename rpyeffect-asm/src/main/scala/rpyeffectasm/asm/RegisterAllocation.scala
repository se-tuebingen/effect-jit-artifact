package rpyeffectasm.asm
import rpyeffectasm.rpyeffect
import rpyeffectasm.util.Phase
import rpyeffectasm.util.ErrorReporter
import rpyeffectasm.util.Emit
import rpyeffectasm.util.DebugInfo
import scala.collection.mutable
import scala.util.control.NonLocalReturns.{returning, throwReturn}

class RegisterAllocation[Tag <: Id, Label <: Id]
  extends Phase[Program[Nothing, Tag, Label, Id], Program[Nothing, Tag, Label, Index]]{

  case class Register(idx: Int) {
    def asIndex(debug: String): Index = IndexWithDebug(idx, debug)
  }

  def possibleRegistersFor(x: Var[Id]): LazyList[Register] = x.name match {
    case Index(i) => LazyList(Register(i))
    case _ => LazyList.from(0).map(Register(_))
  }

  case class State(var registerContents: Map[Register, Var[Id]], var block: Id, var ins: Int = 0)
  {
    var isAvailable: Register => Boolean = { r => !this.registerContents.contains(r) }

    //--------------------------------------------------------------------------------
    // Changing context
    //--------------------------------------------------------------------------------
    def withMask[R](mask: (Register => Boolean) => Register => Boolean)(body: => R): R = {
      val oldIsAvailable = this.isAvailable
      try {
        this.isAvailable = { r => mask(oldIsAvailable)(r) }
        body
      } finally {
        this.isAvailable = oldIsAvailable
      }
    }

    type ContextHandler[R] = ( => R) => R
    def withLive[R](liveIds: Seq[Id]): ContextHandler[R] =
      withMask { a => r =>
        a(r) || !this.registerContents.get(r).exists { v => liveIds.contains(v.name) }
      }

    def withAdditionalLive[R](liveIds: Seq[Id]): ContextHandler[R] =
      withMask { a => r =>
        if this.registerContents.get(r).exists { v => liveIds.contains(v.name) } then false else a(r)
      }
    def withAdditionalLiveV[R](liveVars: Seq[Var[Id]]): ContextHandler[R] =
      withAdditionalLive(liveVars.map(_.name))

    def reserving[R](reserve: Seq[Register]): ContextHandler[R] = withMask{ a => r => if !reserve.contains(r) then a(r) else false }
    def reservingIf[R](reserve: Register => Boolean): ContextHandler[R] = withMask{ a => r => if !reserve(r) then a(r) else false }
    def overwriting[R](overwrite: Seq[Register]): ContextHandler[R] = withMask{ a => r => a(r) || overwrite.contains(r) }

    //--------------------------------------------------------------------------------
    // Moving and finding registers
    //--------------------------------------------------------------------------------
    def freshFor(x: Var[Id]): Option[Register] = {
      possibleRegistersFor(x).find(this.isAvailable)
    }
    def freshFor(xs: Seq[Var[Id]]): Option[Iterable[Register]] = returning {
      val r = new mutable.HashSet[Register]()
      reservingIf(r.contains) {
        Some(xs.map{ x =>
          val f = freshFor(x).getOrElse{ throwReturn(None) }
          r.addOne(f)
          f
        })
      }
    }

    def put(r: Register, x: Var[Id]): Unit = {
      require(isAvailable(r))
      registerContents = registerContents.updated(r, x)
    }
    def clr(r: Register): Unit = {
      registerContents = registerContents.removed(r)
    }
    def put(r: Register, x: Id): Unit = put(r, Var(x))

    def find(x: Id): Option[Register] = registerContents.collectFirst{ case (r, y) if y.name == x => r }
    def find(x: Var[Id]): Option[Register] =
      registerContents.collectFirst{ case (r, y) if y.name == x.name => r }
    def asVar(r: Register): Var[Index] = {
      val contents = registerContents.get(r)
      val idx = contents match {
        case Some(c) => IndexWithDebug(r.idx, c.name.toString)
        case None => Index(r.idx)
      }
      Var(idx)
    }

    def move(from: Register, to: Register)(using em: Emit[Instruction[Nothing, Tag, Label, Index]]): Unit = if(from != to) {
      require(registerContents.contains(from), "moving from unassigned register makes no sense")
      em.emit(Let(List(asVar(to)), List(asVar(from))))
      put(to, registerContents(from))
      clr(from)
    }
    def moveAll(froms: List[Register], tos: List[Register])(using em: Emit[Instruction[Nothing, Tag, Label, Index]]): Unit = {
      // TODO: Here, 0 -> 0 & 0 -> 1 does not work properly!! (Removes mapping for 0 -> 0) TODO TODO
      require(froms.forall(registerContents.contains), "moving from unassigned register makes no sense")
      val (_froms, _tos) = (froms zip tos).filterNot{ (x,y) => x == y }.unzip
      val _staying = (froms zip tos).collect { case (x,y) if x == y => x }.toSet
      if(_froms.nonEmpty) {
        em.emit(Let(_tos.map(asVar), _froms.map(asVar)))
        val contents = _froms.map(registerContents)
        _froms.filterNot(_staying.contains).foreach(clr) // first clear, can then be overwritten in next step
        (_tos zip contents).foreach { (to, c) => put(to, c) }
      }
    }
  }

  def lookupW(id: Id)(using s: State, em: Emit[Instruction[Nothing, Tag, Label, Index]]): Index = { id match {
    case idx @ Index(i) =>
      val reg = Register(i)
      s.registerContents.get(reg) match {
        case Some(Var(Index(ii))) if i == ii => idx
        case _ if s.isAvailable(reg) =>
          s.put(reg, idx)
          idx
        case Some(v) =>
          // move out of the way
          val replacement = s.freshFor(v).getOrElse{ ??? }
          s.move(reg, replacement)
          // now, we can use the specified register
          s.put(reg, Var(id))
          idx
      }
    case id =>
      s.find(id).foreach(s.clr) // remove from previous contents (since now overwritten)
      val r = s.freshFor(Var(id)).get
      s.put(r, Var(id))
      IndexWithDebug(r.idx, id.toString)
  }} ensuring { r => s.registerContents.get(Register(r.i)).map(_.name).contains(id) }

  def lookupR(id: Id)(using s: State, E: ErrorReporter): Index = { id match {
    case idx: Index => idx
    case id =>
      s.find(id).getOrElse {
        ErrorReporter.fatal(s"Register ${id.toString} used before being written to.") // TODO panic - unitialized variable
      }.asIndex(id.name.toString)
  }}// ensuring { r => id.isInstanceOf[Index] || s.registerContents.get(Register(r.i, Type.getRegisterType(tpe))).map(_.name).contains(id) }

  def read(o: RhsOperand[Nothing, Id])(using s: State, e: ErrorReporter): RhsOperand[Nothing, Index] = o match {
    case Var(name) => Var(lookupR(name))
  }
  def write(o: LhsOperand[Nothing, Id])(using State, Emit[Instruction[Nothing, Tag, Label, Index]]): LhsOperand[Nothing, Index] = o match {
    case Var(name) => Var(lookupW(name))
  }
  def readArgs(l: RhsOpList[Nothing, Id])(using State, ErrorReporter): RhsOpList[Nothing, Index] = {
    l.zipWithIndex.map { case (rhs, i) => read(rhs) }
  }
  def writeArgs(l: LhsOpList[Nothing, Id])(using Emit[Instruction[Nothing, Tag, Label, Index]], State): LhsOpList[Nothing, Index] = {
    l.zipWithIndex.map { case (lhs, i) => write(lhs) }
  }

  def getArgumentRegisters(args: RhsOpList[Nothing, Id] | LhsOpList[Nothing, Id]): List[Register] = {
    var counter = -1
    args.map {
      case arg: Var[Id] =>
        counter += 1
        Register(counter)
    }
  }
  def doPrepareJump(args: RhsOpList[Nothing, Id], preserving: List[Id] = Nil)(using s: State, e: ErrorReporter, em: Emit[Instruction[Nothing, Tag, Label, Index]]): RhsOpList[Nothing, Index] = {
    require(preserving.forall{x => s.find(x).isDefined})
    val argSourceRegs = args.map{ arg => s.find(arg.asInstanceOf[Var[Id]]).getOrElse { ErrorReporter.fatal(s"Unbound register as argument to jump: ${arg}") } }
    val argTargetRegs = getArgumentRegisters(args)
    val inTheWay = s.withAdditionalLive(preserving) { s.overwriting(argSourceRegs) { argTargetRegs.filterNot(s.isAvailable) } }
    val inTheWayVars = inTheWay.map(s.registerContents)
    val outOfTheWay = s.overwriting(argSourceRegs) { s.reserving(argTargetRegs) { s.freshFor(inTheWayVars) } }.getOrElse{ ??? }
    s.moveAll(argSourceRegs ++ inTheWay, argTargetRegs ++ outOfTheWay)

    argTargetRegs.map(s.asVar)
  } ensuring { _ =>
    val argt = getArgumentRegisters(args)
    (args zip argt).forall{ case (Var(a), t) =>
      s.registerContents.get(t).map(_.name).contains(a)
    } && preserving.forall{ x => s.find(x).isDefined }
  }

  def restrictTo(args: RhsOpList[Nothing, Id])(using s: State): Unit = {
    val n = s.registerContents.filter{
      case (r, Var(x)) => args.exists{ case Var(y) => x == y }
    }
    s.registerContents = n
  } ensuring { _ => s.registerContents.forall{ case (_, Var(x)) => args.exists{ case Var(y) => x == y } } }

  def apply(i: Instruction[Nothing, Tag, Label, Id])(using em: Emit[Instruction[Nothing,Tag,Label,Index]], s: State, er: ErrorReporter): Unit = {
    import Emit.emit
    ErrorReporter.withLocation(s"In instruction ${AsmPrettyPrinter.apply(i)}"){ i match {
    case Let(lhss, rhss) =>
      val tRhss = readArgs(rhss)
      val tLhss = writeArgs(lhss)
      emit(Let(tLhss, tRhss))
    case LetConst(out, value) => emit(LetConst(write(out), value))
    case Primitive(out, name, in) => // TODO use names for in- and out- params?
      val tIn = readArgs(in)
      val tOut = writeArgs(out)
      emit(Primitive(tOut, name, tIn))
    case Push(target, args) => emit(Push(target, readArgs(args)))
    case Return(args) =>
      val tArgs = doPrepareJump(args)
      emit(Return(tArgs))
    case Jump(target, args) =>
      val tArgs = doPrepareJump(args)
      emit(Jump(target, tArgs))
    case CallLib(lib, symbol, env) =>
      val args = doPrepareJump(env :+ lib)
      emit(CallLib(read(lib), symbol, args))
    case LoadLib(path) =>
      em.emit(LoadLib(read(path)))
    case IfZero(arg, Clause(pars, frs, target)) =>
      assert(pars.isEmpty)
      doPrepareJump(frs)
      em.emit(IfZero(read(arg), Clause(Nil, readArgs(frs), target)))
    case Allocate(ref, init, region) =>
      val tInit = read(init)
      val tRegion = read(region)
      val tRef = write(ref)
      emit(Allocate(tRef, tInit, tRegion))
    case Load(out, ref) =>
      val tRef = read(ref)
      val tOut = write(out)
      emit(Load(tOut, tRef))
    case Store(ref, in) =>
      emit(Store(read(ref), read(in)))
    case GetDynamic(out, n, label) =>
      val tN = read(n)
      val tLabel = read(label)
      val tOut = write(out)
      emit(GetDynamic(tOut, tN, tLabel))
    case Shift(out, n, label) =>
      val tN = read(n)
      val tLabel = read(label)
      val tOut = write(out)
      emit(Shift(tOut, tN, tLabel))
    case Control(out, n, label) =>
      val tN = read(n)
      val tLabel = read(label)
      val tOut = write(out)
      emit(Control(tOut, tN, tLabel))
    case PushStack(stack) => emit(PushStack(read(stack)))
    case NewStack(stack, region, label, target, args) =>
      val tArgs = readArgs(args)
      val tLabel = read(label)
      val tStack = write(stack)
      val tRegion = write(region)
      emit(NewStack(tStack, tRegion, tLabel, target, tArgs))
    case NewStackWithBinding(stack, region, label, target, args, bnd) =>
      val tArgs = readArgs(args)
      val tLabel = read(label)
      val tBnd = read(bnd)
      val tStack = write(stack)
      val tRegion = write(region)
      emit(NewStackWithBinding(tStack, tRegion, tLabel, target, tArgs, tBnd))
    case Construct(out, tpe, tag, args) =>
      val tArgs = readArgs(args)
      val tOut = write(out)
      emit(Construct(tOut, tpe, tag, tArgs))
    case Match(tpe, scrutinee@Var(scrId), clauses, default) =>
      val bodyFrees = default.env.map{ case Var(x) => x }
      doPrepareJump(default.env, scrId :: bodyFrees)
      val tScrutinee = read(scrutinee)
      restrictTo(default.env)
      s.withLive(bodyFrees) {
        val tClauses = clauses.map { case (tag -> cls) => (tag -> apply(cls)) }
        val tDefault = apply(default)
        emit(Match(tpe, tScrutinee, tClauses, tDefault))
      }
    case Switch(arg@Var(argId), cases, default, env) =>
      doPrepareJump(env, List(argId))
      emit(Switch(read(arg), cases, default, readArgs(env)))
    case Proj(out, tpe, scrutinee, tag, field) =>
      val tScrutinee = read(scrutinee)
      val tOut = write(out)
      emit(Proj(tOut, tpe, tScrutinee, tag, field))
    case New(out, ifce, targets, args) =>
      val tArgs = readArgs(args)
      val tOut = write(out)
      emit(New(tOut, ifce, targets, tArgs))
    case Invoke(receiver@Var(rcvId), ifce, tag, args) =>
      // TODO make sure receiver survived jump preparation
      val tArgs = doPrepareJump(args, List(rcvId))
      emit(Invoke(read(receiver), ifce, tag, tArgs))
    case Debug(msg, traced) =>
      emit(Debug(msg, readArgs(traced)))
  }}
  }

  def apply(clause: Clause[Nothing, Label, Id])(using em: Emit[Instruction[Nothing, Tag, Label, Index]], s: State, E: ErrorReporter): Clause[Nothing, Label, Index] = clause match {
    case Clause(pars, frs, target) =>
      s.withAdditionalLiveV(frs.asInstanceOf[Seq[Var[Id]]]) {
        val tPars = writeArgs(pars)
        val tFrs = readArgs(frs)
        Clause(tPars, tFrs, target)
      }
  }
  def apply(l: List[(Instruction[Nothing, Tag, Label, Id], List[Id])])(using em: Emit[Instruction[Nothing, Tag, Label, Index]], s: State, E: ErrorReporter): Unit = {
    l.zipWithIndex.foreach { case ((i, f),idx) => ErrorReporter.withLocation(s"Instruction number ${idx}"){
        s.withLive(f){ apply(i) }
      }
    }
  }
  def apply(block: Block[Nothing, Tag, Label, Id])(using ErrorReporter): Block[Nothing, Tag, Label, Index] = block match {
    case Block(label, params, instructions, export_as) =>
      val state: State = State(Map.empty, block=label)
      given State = state
      val paramRegs = getArgumentRegisters(params)
      (paramRegs zip params).foreach{ case (r, x: Var[Id]) => state.put(r, x) }
      val tParams = paramRegs.map(state.asVar)

      DebugInfo.log("asm", "RegisterAllocation", state.block.toString, "entry", "registerContents")(state.registerContents)
      val instructionsWithLive: List[(Instruction[Nothing, Tag, Label, Id], List[Id])] = new LiveVariables().zipInstructionsWith(instructions)
      DebugInfo.log("asm", "RegisterAllocation", state.block.toString, "liveVariables")(instructionsWithLive)

      Block(label, tParams, Emit.collecting_[Instruction[Nothing, Tag, Label, Index]]{
        Emit.withOnEmit[Instruction[Nothing, Tag, Label, Index], Unit]{ i =>
          DebugInfo.log("asm", "RegisterAllocation", state.block.toString, state.ins.toString, "registerContents")(state.registerContents)
          DebugInfo.log("asm", "RegisterAllocation", state.block.toString, state.ins.toString, "emittedBy"){Thread.currentThread().getStackTrace() }
          state.ins = state.ins + 1
        }{
          apply(instructionsWithLive)
        }
      }, export_as)
  }
  override def apply(program: Program[Nothing, Tag, Label, Id])(using ErrorReporter): Program[Nothing, Tag, Label, Index] = program match {
    case Program(blocks) => Program(blocks.zipWithIndex map { (b, idx) => ErrorReporter.withLocation(s"During Register Allocation in block ${idx}(\"${b.label}\")"){
      apply(b) }})
  }

}
