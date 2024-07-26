package rpyeffectasm.asm
import rpyeffectasm.rpyeffect

import scala.collection.mutable
import Type.getRegisterType
import rpyeffectasm.asm.TypingPrecision.ConcretelyTyped
import rpyeffectasm.rpyeffect.FrameDescriptor
import rpyeffectasm.util.{Emit, ErrorReporter, Phase}
import rpyeffectasm.util.Emit.{emit, emitAll}
import rpyeffectasm.util.ErrorReporter.{error, fatal}
import rpyeffectasm.rpyeffect

class Transformer extends Phase[Program[Nothing, Id, Index, Index, OperandType[ConcretelyTyped]], rpyeffect.Program] {

  /** Returns frame descriptor to make sure there are enough registers for loading a library. - Hardcoded for now. */ // TODO Compute this somehow?
  def libraryFrameDescriptor: rpyeffect.FrameDescriptor = rpyeffect.FrameDescriptor(rpyeffect.RegisterType.values.map( _ -> 16 ).toMap)

  def apply(l: RhsOpList[Nothing, Index, OperandType[ConcretelyTyped]] | LhsOpList[Nothing, Index, OperandType[ConcretelyTyped]])(using Emit[rpyeffect.FrameDescriptor]): rpyeffect.RegList = {
    val res = rpyeffect.RegList(l.groupMap {
      case Var(Index(i), tpe) => getRegisterType(tpe)
    }{
      case Var(Index(i), _) => i
    })
    emit(FrameDescriptor(res.regs.view.mapValues{ rs => rs.max+1 }.toMap))
    res
  }

  def applyTag(id: Id): rpyeffect.Tag = id match {
    case Name(name) => rpyeffect.Tag.Name(name)
    case Index(i) => rpyeffect.Tag.Index(i)
    case generated: Generated => rpyeffect.Tag.Name(s"${Generated.runId}#${generated.toString}")
  }

  def apply(l: List[Instruction[Nothing, Id, Index, Index, OperandType[ConcretelyTyped]]])(using Emit[rpyeffect.Instruction], Emit[rpyeffect.FrameDescriptor], ErrorReporter): rpyeffect.Terminator = l match {
    case Let(Nil, Nil) :: rest => apply(rest)
    case Let(List(Var(Index(lhs),ltpe)), List(Var(Index(rhs),rtpe))) :: rest if getRegisterType(ltpe) == getRegisterType(rtpe) =>
      if(rhs != lhs) {
        use(getRegisterType(rtpe), rhs); use(getRegisterType(ltpe), lhs)
        emit(rpyeffect.Copy(getRegisterType(rtpe), rhs, lhs))
      }
      apply(rest)
    case Let(lhssOps, rhssOps) :: rest =>
        // # initialize graph structure
        // A graph where
        //   nodes represent registers
        //   edges represent data flow
        //     source: register to move from
        //     sink: register to move to
        //
        // All nodes have in-degree 1 (we cannot assign multiple values to one register)
        //
        // Example graph
        //
        //   ┌►1─┐      ┌────3◄────┐
        //   │   │      │          │
        //   │   │      ▼          │
        //   └─2◄┘      4─────────►5─────►6─────►7
        //
        // In the representation of graphs,
        //   keys (RhsOperand) are sources
        //   values (mutable.HashSet[LhsOperand]) are all targets
        val todo = new mutable.HashMap[RhsOperand[Nothing, Index, OperandType[ConcretelyTyped]],
          mutable.HashSet[LhsOperand[Nothing, Index, OperandType[ConcretelyTyped]]]]()
        /** Normalize types to TopPtr/Num */
        def normalizeLhs(lhsOperand: LhsOperand[Nothing, Index, OperandType[ConcretelyTyped]]) = lhsOperand match {
          case Var(name, tpe) => Var(name, Type.fromRegisterType(getRegisterType(tpe)))
        }
        /** Normalize types to TopPtr/Num */
        def normalizeRhs(rhsOperand: RhsOperand[Nothing, Index, OperandType[ConcretelyTyped]]) = rhsOperand match {
          case Var(name, tpe) => Var(name, Type.fromRegisterType(getRegisterType(tpe)))
        }
        for ((s, t) <- rhssOps zip lhssOps) {
          todo.getOrElseUpdate(normalizeRhs(s), new mutable.HashSet()).addOne(normalizeLhs(t))
        }

        /** Returns true iff it still is a source in [[todo]] (i.e. there we still need the value) */
        def stillNeeded(l: LhsOperand[Nothing, Index, OperandType[ConcretelyTyped]]): Boolean = l match {
          case v@Var(name, tpe) =>
            todo.contains(v)
        }

        /** Dirty flag for the [[todo]] list, for fixpoint computation */
        var changed = true

        /** Removes the given edge from the graph, updating `changed` and possibly removing the node */
        def done(s: RhsOperand[Nothing, Index, OperandType[ConcretelyTyped]], t: LhsOperand[Nothing, Index, OperandType[ConcretelyTyped]]) = {
          todo(s).remove(t)
          changed = true
          if (todo(s).isEmpty) todo.remove(s)
        }

        // # 1. Cut hairs (COPY where target value is no longer needed)
        // Afterwards, all remaining nodes have in- and out-degree 1
        // (i.e. the resulting graph is a union of disjoint cycles)
        while (changed) {
          changed = false
          for (source <- todo.keys; target <- todo(source); if !stillNeeded(target)) {
            //                                                                               generate COPY
            //   ┌►1─┐      ┌────3◄────┐                          ┌►1─┐      ┌────3◄────┐      and remove
            //   │   │      │          │                          │   │      │          │         |
            //   │   │      ▼          │                 ~~~>     │   │      ▼          │         v
            //   └─2◄┘      4─────────►5─────►6─────►7            └─2◄┘      4─────────►5─────►6──/──►7
            //                                ^      ^                                         ^      ^
            //                             source   target                                  source   target

            (source, target) match {
              case (Var(Index(s), tpe), Var(Index(t), tpe2)) if tpe == tpe2 =>
                use(tpe, s); use(tpe, t)
                if(s != t) {
                  use(getRegisterType(tpe), s); use(getRegisterType(tpe), t)
                  emit(rpyeffect.Copy(getRegisterType(tpe), s, t))
                }
                done(source, target)
              case (s, t) =>
                sys error s"Cannot assign ${s} to ${t}."
            }
          }
        }
        // # 2. rotate cycles (with SWAPs)
        // TODO it would probably be more efficient to use one temporary register,
        //      and rotate cyclically using that. For now, we use SWAPs to
        //      shrink the cycles incrementally.
        while (todo.nonEmpty) {
          //
          //  ┌►1─┐      ┌────3◄────┐            ┌►1─┐      ┌────3◄────┐
          //  │   │      │          │            │   │      │    ▲     │
          //  │   │      ▼          │    ~~~>    │   │      ▼    │     │
          //  └─2◄┘      4─────────►5            └─2◄┘      4────┴─/──►5
          //             ^          ^                       ^    ^     ^
          //          source      target                 source  |  target
          //                                                     |
          //                                                generate SWAP
          //                                            and change edge target

          // get some source from the graph
          todo.head match {
            case (source@Var(Index(s), stpe), targets) =>

              assert(targets.size == 1)
              targets.head match {
                case target@Var(Index(t), ttpe) =>
                  assert(stpe == ttpe, "Target and source type must match for assignment.")

                  if (t != s) {
                    use(getRegisterType(stpe), t); use(getRegisterType(stpe), t)
                    emit(rpyeffect.Swap(getRegisterType(stpe), t, s));
                  }
                  todo(source) = todo(target);
                  todo.remove(target);
              }
          }
        }
      // TODO IIUC we do not need to drop here :thinking:
      apply(rest)
    case LetConst(Var(Index(i),_), value: Int) :: rest =>
      useNum(i)
      emit(rpyeffect.Const(i, value))
      apply(rest)
    case LetConst(Var(Index(out),_), value: Double) :: rest =>
      useNum(out)
      emit(rpyeffect.ConstDouble(out, value))
      apply(rest)
    case LetConst(Var(Index(out),_), value: String) :: rest =>
      usePtr(out)
      emit(rpyeffect.ConstString(out, value))
      apply(rest)
    case LetConst(Var(Index(out),_), FormatConst(fmt, value)) :: rest =>
      usePtr(out)
      emit(rpyeffect.ConstFormat(out, value, fmt))
      apply(rest)
    case Primitive(out, name, in) :: rest =>
      emit(rpyeffect.PrimOp(name, apply(out), apply(in)))
      apply(rest)
    case Push(Index(target), args) :: rest =>
      emit(rpyeffect.Push(target, apply(args)))
      apply(rest)
    case Return(args) :: Nil =>
      rpyeffect.Return(apply(args))
    case Jump(Index(target), env) :: Nil =>
      val _ = apply(env) // we can ignore env since register allocation made sure it is 0,...n
      rpyeffect.Jump(target)
    case CallLib(Var(Index(lib),_), symbol, env) :: Nil =>
      val _ = apply(env)
      rpyeffect.CallLib(lib, symbol)
    case LoadLib(Var(Index(path),_)) :: Nil =>
      emit(libraryFrameDescriptor)
      rpyeffect.LoadLib(path)
    case IfZero(Var(Index(arg),_), thenClause @ Clause(params, env, Index(target))) :: rest =>
      useNum(arg)
      assert(params.isEmpty)
      emit(rpyeffect.IfZero(arg, rpyeffect.Clause(rpyeffect.Tag.Index(-1), apply(Nil), target)))
      apply(rest)
    case Allocate(Var(Index(ref),_), Var(Index(init), tpe), Var(Index(region),_)) :: rest =>
      usePtr(ref); usePtr(region); use(tpe, init)
      emit(rpyeffect.Allocate(ref, getRegisterType(tpe), init, region))
      apply(rest)
    case Load(Var(Index(out), tpe), Var(Index(ref),_)) :: rest =>
      use(tpe, out); usePtr(ref)
      emit(rpyeffect.Load(out, getRegisterType(tpe), ref))
      apply(rest)
    case Store(Var(Index(ref),_), Var(Index(in),tpe)) :: rest =>
      usePtr(ref); use(tpe, in)
      emit(rpyeffect.Store(ref, getRegisterType(tpe), in))
      apply(rest)
    case GetDynamic(Var(Index(out),_), Var(Index(n),_), Var(Index(label),tpe)) :: rest =>
      usePtr(out); useNum(n); use(tpe, label)
      emit(rpyeffect.GetDynamic(out, n, label))
      apply(rest)
    case Shift(Var(Index(out),_), Var(Index(n),_), Var(Index(label),tpe)) :: rest =>
      usePtr(out); useNum(n); use(tpe, label)
      emit(rpyeffect.ShiftDyn(out, n, label))
      apply(rest)
    case Control(Var(Index(out),_), Var(Index(n),_), Var(Index(label),tpe)) :: rest =>
      usePtr(out); useNum(n); use(tpe, label)
      emit(rpyeffect.Control(out, n, label))
      apply(rest)
    case PushStack(Var(Index(stack),_)) :: rest =>
      usePtr(stack)
      emit(rpyeffect.PushStack(stack))
      apply(rest)
    case NewStack(Var(Index(oSt),_), Var(Index(oReg),_), Var(Index(label),ltpe), Index(target), args) :: rest =>
      usePtr(oSt); usePtr(oReg); use(ltpe, label)
      emit(rpyeffect.NewStack(oSt, oReg, label, target, apply(args)))
      apply(rest)
    case NewStackWithBinding(Var(Index(oSt),_), Var(Index(oReg),_), Var(Index(label),ltpe), Index(target), args, Var(Index(oBnd), _)) :: rest =>
      usePtr(oSt); usePtr(oReg); usePtr(oBnd); use(ltpe, label)
      emit(rpyeffect.NewStackWithBinding(oSt, oReg, label, target, apply(args), oBnd))
      apply(rest)
    case Construct(Var(Index(out),_), tpe, tag, args) :: rest =>
      usePtr(out)
      emit(rpyeffect.Construct(out, applyTag(tpe), applyTag(tag), apply(args)))
      apply(rest)
    case Match(tpe, Var(Index(scr),_), clauses, default) :: Nil if clauses.isEmpty =>
      rpyeffect.Jump(default.target.i)
    case Match(tpe, Var(Index(scr),_), clauses, default) :: Nil =>
      usePtr(scr)
      val tClauses = clauses.map {
        case (tag, cls) => applyMatchClause(tpe, Some(tag), cls)
      }
      rpyeffect.Match(applyTag(tpe), scr, tClauses, applyMatchClause(tpe, None, default))
    case Switch(Var(Index(arg), _), cases, default, env) :: Nil =>
      useNum(arg)
      val vals = cases.map(_._1)
      val targets = cases.map{ case (_, Index(t)) => t }
      val def_target = default match {
        case Index(t) => t
      }
      rpyeffect.Switch(arg, vals, targets, def_target)
    case Proj(Var(Index(out),rtpe), tpe, Var(Index(scrutinee),_), tag, field) :: rest =>
      emit(rpyeffect.Proj(out, applyTag(tpe), scrutinee, applyTag(tag), field, getRegisterType(rtpe)))
      apply(rest)
    case New(Var(Index(out),otpe), ifce, targets, args) :: rest =>
      use(otpe, out)
      val (tTags, tTargets) = targets.map{ case (mtag, Index(target)) => (applyTag(mtag), target) }.unzip
      emit(rpyeffect.New(out, tTags, tTargets, apply(args)))
      apply(rest)
    case Invoke(Var(recv, tpe), ifce, tag, args) :: Nil =>
      usePtr(recv.i)
      rpyeffect.Invoke(recv.i, applyTag(tag), apply(args))
    case Debug(msg, traced) :: rest =>
      emit(rpyeffect.Debug(msg, apply(traced)))
      apply(rest)
    case (t: Terminator) :: Nil => ???
    case (t: Terminator) :: rest if rest.forall(_.isInstanceOf[Debug[_,_,_]]) =>
      apply((rest.map{
        case Debug(msg, trace) => Debug("AFTER TERMINATOR: " + msg, trace)
      }) :+ t)
    case (t: Terminator) :: rest =>
      error("Dead code: Terminator followed by further instructions.");
      apply(t :: Nil)
    case Nil =>
      fatal("Block not terminated by a terminator")
  }
  def applyMatchClause(tpeTag: Id, tag: Option[Id], clause: Clause[Nothing, Index, Index, OperandType[TypingPrecision.ConcretelyTyped]])(using E: ErrorReporter, EFD: Emit[rpyeffect.FrameDescriptor]) = clause match {
    case Clause(params, env, Index(target)) =>
      rpyeffect.Clause(applyTag(tag.getOrElse(new Generated("Missing Tag"))), apply(params), target)
  }

  //region Folding frame descriptors to get the maximum
  def foldFrameDescriptors[R](body: Emit[FrameDescriptor] ?=> R): (FrameDescriptor, R) = {
    Emit.folding(FrameDescriptor(Map.empty)) {
      case (FrameDescriptor(m), FrameDescriptor(n)) =>
        FrameDescriptor((rpyeffect.RegisterType.values map { ty =>
          ty -> Math.max(m.getOrElse(ty, 0), n.getOrElse(ty, 0))
        }).toMap)
    }(body)
  }
  def use(rtpe: rpyeffect.RegisterType, idx: Int)(using Emit[FrameDescriptor]) = {
    emit(FrameDescriptor(Map(rtpe -> (idx+1))))
  }
  def use(tpe: OperandType[ConcretelyTyped], idx: Int)(using Emit[FrameDescriptor]): Unit = {
    use(getRegisterType(tpe), idx)
  }
  def useNum(idx: Int)(using Emit[FrameDescriptor]) = use(rpyeffect.RegisterType.Number, idx)
  def usePtr(idx: Int)(using Emit[FrameDescriptor]) = use(rpyeffect.RegisterType.Ptr, idx)
  def apply(b: Block[Nothing, Id, Index, Index, OperandType[ConcretelyTyped]])(using Emit[FrameDescriptor], Emit[rpyeffect.Symbol], ErrorReporter): rpyeffect.BasicBlock = b match {
    case Block(label, params, _, instructions, export_as) =>
      foldFrameDescriptors {
        val _ = apply(params) // for adjusting the frame descriptor
        Emit.collecting[rpyeffect.Instruction, rpyeffect.Terminator] {
          apply(instructions)
        }
      } match {
        case (fd, (pIns, terminator)) =>
          emit (fd)
          export_as.foreach{ name => emit(rpyeffect.Symbol(name, label.i)) }
          rpyeffect.BasicBlock(s"${label.i}(${label.debug})", fd, pIns, terminator)
      }
  }
  //endregion

  override def apply(p: Program[Nothing, Id, Index, Index, OperandType[ConcretelyTyped]])(using ErrorReporter): rpyeffect.Program = p match {
    case Program(blocks) =>
      import scala.collection.mutable.ListBuffer
      val exports: mutable.ListBuffer[rpyeffect.Symbol] = new ListBuffer[rpyeffect.Symbol]()
      val (fd, tBlocks) =
        Emit.collectingInto(exports) {
          foldFrameDescriptors {
            blocks map apply
          }
        }
      rpyeffect.Program(tBlocks, exports.toList, fd)
  }

}
