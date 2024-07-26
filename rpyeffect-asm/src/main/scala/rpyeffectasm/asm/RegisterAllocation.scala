package rpyeffectasm.asm
import rpyeffectasm.asm.TypingPrecision.ConcretelyTyped
import rpyeffectasm.rpyeffect
import rpyeffectasm.util.Phase
import rpyeffectasm.util.ErrorReporter
import rpyeffectasm.util.Emit
import rpyeffectasm.util.DebugInfo
import scala.collection.mutable
import scala.util.control.NonLocalReturns.{returning, throwReturn}

class RegisterAllocation[Tag <: Id, Label <: Id]
  extends Phase[Program[Nothing, Tag, Label, Id, OperandType[ConcretelyTyped]], Program[Nothing, Tag, Label, Index, OperandType[ConcretelyTyped]]]{

  type OTpe = OperandType[ConcretelyTyped]

  case class Register(idx: Int, tpe: rpyeffect.RegisterType) {
    def asIndex(debug: String): Index = IndexWithDebug(idx, debug)
  }

  def possibleRegistersFor(x: Var[Id, OTpe]): LazyList[Register] = x.name match {
    case Index(i) => LazyList(Register(i, Type.getRegisterType(x.tpe)))
    case _ => LazyList.from(0).map(Register(_, Type.getRegisterType(x.tpe)))
  }

  case class State(var registerContents: Map[Register, Var[Id, OTpe]], var block: Id, var ins: Int = 0)
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
    def withAdditionalLiveV[R](liveVars: Seq[Var[Id, OTpe]]): ContextHandler[R] =
      withAdditionalLive(liveVars.map(_.name))

    def reserving[R](reserve: Seq[Register]): ContextHandler[R] = withMask{ a => r => if !reserve.contains(r) then a(r) else false }
    def reservingIf[R](reserve: Register => Boolean): ContextHandler[R] = withMask{ a => r => if !reserve(r) then a(r) else false }
    def overwriting[R](overwrite: Seq[Register]): ContextHandler[R] = withMask{ a => r => a(r) || overwrite.contains(r) }

    //--------------------------------------------------------------------------------
    // Moving and finding registers
    //--------------------------------------------------------------------------------
    def freshFor(x: Var[Id, OTpe]): Option[Register] = {
      possibleRegistersFor(x).find(this.isAvailable)
    }
    def freshFor(xs: Seq[Var[Id, OTpe]]): Option[Iterable[Register]] = returning {
      val r = new mutable.HashSet[Register]()
      reservingIf(r.contains) {
        Some(xs.map{ x =>
          val f = freshFor(x).getOrElse{ throwReturn(None) }
          r.addOne(f)
          f
        })
      }
    }

    def put(r: Register, x: Var[Id, OTpe]): Unit = {
      require(isAvailable(r))
      registerContents = registerContents.updated(r, x)
    }
    def clr(r: Register): Unit = {
      registerContents = registerContents.removed(r)
    }
    def put(r: Register, x: Id): Unit = put(r, Var(x, Type.fromRegisterType(r.tpe)))

    def find(x: Id): Option[Register] = registerContents.collectFirst{ case (r, y) if y.name == x => r }
    def find(x: Var[Id, OTpe]): Option[Register] =
      registerContents.collectFirst{ case (r, y) if y.name == x.name && Type.getRegisterType(x.tpe) == r.tpe => r }
    def asVar(r: Register): Var[Index, OTpe] = {
      val contents = registerContents.get(r)
      val idx = contents match {
        case Some(c) => IndexWithDebug(r.idx, c.name.toString)
        case None => Index(r.idx)
      }
      Var(idx, contents.map(_.tpe).getOrElse{ Type.fromRegisterType(r.tpe) })
    }

    def move(from: Register, to: Register)(using em: Emit[Instruction[Nothing, Tag, Label, Index, OTpe]]): Unit = if(from != to) {
      require(registerContents.contains(from), "moving from unassigned register makes no sense")
      em.emit(Let(List(asVar(to)), List(asVar(from))))
      put(to, registerContents(from))
      clr(from)
    }
    def moveAll(froms: List[Register], tos: List[Register])(using em: Emit[Instruction[Nothing, Tag, Label, Index, OTpe]]): Unit = {
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

  def lookupW(id: Id, tpe: OTpe)(using s: State, em: Emit[Instruction[Nothing, Tag, Label, Index, OTpe]]): Index = { id match {
    case idx @ Index(i) =>
      val reg = Register(i, Type.getRegisterType(tpe))
      s.registerContents.get(reg) match {
        case Some(Var(Index(ii), _)) if i == ii => idx
        case _ if s.isAvailable(reg) =>
          s.put(reg, idx)
          idx
        case Some(v) =>
          // move out of the way
          val replacement = s.freshFor(v).getOrElse{ ??? }
          s.move(reg, replacement)
          // now, we can use the specified register
          s.put(reg, Var(id, tpe))
          idx
      }
    case id =>
      s.find(id).foreach(s.clr) // remove from previous contents (since now overwritten)
      val r = s.freshFor(Var(id, tpe)).get
      s.put(r, Var(id, tpe))
      IndexWithDebug(r.idx, id.toString)
  }} ensuring { r => s.registerContents.get(Register(r.i, Type.getRegisterType(tpe))).map(_.name).contains(id) }

  def lookupR(id: Id, tpe: OTpe)(using s: State, E: ErrorReporter): Index = { id match {
    case idx: Index => idx
    case id =>
      s.find(id).getOrElse {
        ErrorReporter.fatal(s"Register ${id.toString} used before being written to.") // TODO panic - unitialized variable
      }.asIndex(id.name.toString)
  }}// ensuring { r => id.isInstanceOf[Index] || s.registerContents.get(Register(r.i, Type.getRegisterType(tpe))).map(_.name).contains(id) }

  def read(o: RhsOperand[Nothing, Id, OTpe])(using s: State, e: ErrorReporter): RhsOperand[Nothing, Index, OTpe] = o match {
    case Var(name, tpe) => Var(lookupR(name, tpe), tpe)
  }
  def write[OTpe2 <: OTpe](o: LhsOperand[Nothing, Id, OTpe2])(using State, Emit[Instruction[Nothing, Tag, Label, Index, OTpe]]): LhsOperand[Nothing, Index, OTpe2] = o match {
    case Var(name, tpe) => Var(lookupW(name, tpe), tpe)
  }
  def readArgs(l: RhsOpList[Nothing, Id, OTpe])(using State, ErrorReporter): RhsOpList[Nothing, Index, OTpe] = {
    l.zipWithIndex.map { case (rhs, i) => read(rhs) }
  }
  def writeArgs(l: LhsOpList[Nothing, Id, OTpe])(using Emit[Instruction[Nothing, Tag, Label, Index, OTpe]], State): LhsOpList[Nothing, Index, OTpe] = {
    l.zipWithIndex.map { case (lhs, i) => write(lhs) }
  }

  def getArgumentRegisters(args: RhsOpList[Nothing, Id, OTpe] | LhsOpList[Nothing, Id, OTpe]): List[Register] = {
    val counters: mutable.Map[rpyeffect.RegisterType, Int] = mutable.HashMap.empty.withDefault(_ => -1)
    args.map {
      case arg: Var[Id, OTpe] =>
        val rtpe = Type.getRegisterType(arg.tpe)
        counters(rtpe) += 1
        Register(counters(rtpe), rtpe)
    }
  }
  def doPrepareJump(args: RhsOpList[Nothing, Id, OTpe], preserving: List[Id] = Nil)(using s: State, e: ErrorReporter, em: Emit[Instruction[Nothing, Tag, Label, Index, OTpe]]): RhsOpList[Nothing, Index, OTpe] = {
    require(preserving.forall{x => s.find(x).isDefined})
    val argSourceRegs = args.map{ arg => s.find(arg.asInstanceOf[Var[Id, OTpe]]).getOrElse { ErrorReporter.fatal(s"Unbound register as argument to jump: ${arg}") } }
    val argTargetRegs = getArgumentRegisters(args)
    val inTheWay = s.withAdditionalLive(preserving) { s.overwriting(argSourceRegs) { argTargetRegs.filterNot(s.isAvailable) } }
    val inTheWayVars = inTheWay.map(s.registerContents)
    val outOfTheWay = s.overwriting(argSourceRegs) { s.reserving(argTargetRegs) { s.freshFor(inTheWayVars) } }.getOrElse{ ??? }
    s.moveAll(argSourceRegs ++ inTheWay, argTargetRegs ++ outOfTheWay)

    argTargetRegs.map(s.asVar)
  } ensuring { _ =>
    val argt = getArgumentRegisters(args)
    (args zip argt).forall{ case (Var(a, _), t) =>
      s.registerContents.get(t).map(_.name).contains(a)
    } && preserving.forall{ x => s.find(x).isDefined }
  }

  def restrictTo(args: RhsOpList[Nothing, Id, RegisterAllocation.this.OTpe])(using s: State): Unit = {
    val n = s.registerContents.filter{
      case (r, Var(x, _)) => args.exists{ case Var(y, _) => x == y }
    }
    s.registerContents = n
  } ensuring { _ => s.registerContents.forall{ case (_, Var(x, _)) => args.exists{ case Var(y, _) => x == y } } }

  def apply(i: Instruction[Nothing, Tag, Label, Id, OTpe])(using em: Emit[Instruction[Nothing,Tag,Label,Index,OTpe]], s: State, er: ErrorReporter): Unit = {
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
    case Match(tpe, scrutinee@Var(scrId, _), clauses, default) =>
      val bodyFrees = default.env.map{ case Var(x,_) => x }
      doPrepareJump(default.env, scrId :: bodyFrees)
      val tScrutinee = read(scrutinee)
      restrictTo(default.env)
      s.withLive(bodyFrees) {
        val tClauses = clauses.map { case (tag -> cls) => (tag -> apply(cls)) }
        val tDefault = apply(default)
        emit(Match(tpe, tScrutinee, tClauses, tDefault))
      }
    case Switch(arg@Var(argId, _), cases, default, env) =>
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
    case Invoke(receiver@Var(rcvId, _), ifce, tag, args) =>
      // TODO make sure receiver survived jump preparation
      val tArgs = doPrepareJump(args, List(rcvId))
      emit(Invoke(read(receiver), ifce, tag, tArgs))
    case Debug(msg, traced) =>
      emit(Debug(msg, readArgs(traced)))
  }}
  }

  def apply(clause: Clause[Nothing, Label, Id, OTpe])(using em: Emit[Instruction[Nothing, Tag, Label, Index, OTpe]], s: State, E: ErrorReporter): Clause[Nothing, Label, Index, OTpe] = clause match {
    case Clause(pars, frs, target) =>
      s.withAdditionalLiveV(frs.asInstanceOf[Seq[Var[Id, OTpe]]]) {
        val tPars = writeArgs(pars)
        val tFrs = readArgs(frs)
        Clause(tPars, tFrs, target)
      }
  }
  def apply(l: List[(Instruction[Nothing, Tag, Label, Id, OTpe], List[Id])])(using em: Emit[Instruction[Nothing, Tag, Label, Index, OTpe]], s: State, E: ErrorReporter): Unit = {
    l.zipWithIndex.foreach { case ((i, f),idx) => ErrorReporter.withLocation(s"Instruction number ${idx}"){
        s.withLive(f){ apply(i) }
      }
    }
  }
  def apply(block: Block[Nothing, Tag, Label, Id, OTpe])(using ErrorReporter): Block[Nothing, Tag, Label, Index, OTpe] = block match {
    case Block(label, params, ret, instructions, export_as) =>
      val state: State = State(Map.empty, block=label)
      given State = state
      val paramRegs = getArgumentRegisters(params)
      (paramRegs zip params).foreach{ case (r, x: Var[Id, OTpe]) => state.put(r, x) }
      val tParams = paramRegs.map(state.asVar)

      DebugInfo.log("asm", "RegisterAllocation", state.block.toString, "entry", "registerContents")(state.registerContents)
      val instructionsWithLive: List[(Instruction[Nothing, Tag, Label, Id, OTpe], List[Id])] = new LiveVariables().zipInstructionsWith(instructions)
      DebugInfo.log("asm", "RegisterAllocation", state.block.toString, "liveVariables")(instructionsWithLive)

      Block(label, tParams, ret, Emit.collecting_[Instruction[Nothing, Tag, Label, Index, OTpe]]{
        Emit.withOnEmit[Instruction[Nothing, Tag, Label, Index, OTpe], Unit]{ i =>
          DebugInfo.log("asm", "RegisterAllocation", state.block.toString, state.ins.toString, "registerContents")(state.registerContents)
          DebugInfo.log("asm", "RegisterAllocation", state.block.toString, state.ins.toString, "emittedBy"){Thread.currentThread().getStackTrace() }
          state.ins = state.ins + 1
        }{
          apply(instructionsWithLive)
        }
      }, export_as)
  }
  override def apply(program: Program[Nothing, Tag, Label, Id, OTpe])(using ErrorReporter): Program[Nothing, Tag, Label, Index, OTpe] = program match {
    case Program(blocks) => Program(blocks.zipWithIndex map { (b, idx) => ErrorReporter.withLocation(s"During Register Allocation in block ${idx}(\"${b.label}\")"){
      apply(b) }})
  }

}
