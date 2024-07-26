package rpyeffectasm.asm
import rpyeffectasm.rpyeffect

import scala.collection.mutable
import rpyeffectasm.rpyeffect.FrameDescriptor
import rpyeffectasm.util.{Emit, ErrorReporter, Phase}
import rpyeffectasm.util.Emit.{emit, emitAll}
import rpyeffectasm.util.ErrorReporter.{error, fatal}
import rpyeffectasm.rpyeffect

class Transformer extends Phase[Program[Nothing, Id, Index, Index], rpyeffect.Program] {

  /** Returns frame descriptor to make sure there are enough registers for loading a library. - Hardcoded for now. */ // TODO Compute this somehow?
  def libraryFrameDescriptor: rpyeffect.FrameDescriptor = rpyeffect.FrameDescriptor(16)

  def apply(l: RhsOpList[Nothing, Index] | LhsOpList[Nothing, Index])(using Emit[rpyeffect.FrameDescriptor]): rpyeffect.RegList = {
    val res = rpyeffect.RegList(l.map {
      case Var(Index(i)) => i
    })
    emit(FrameDescriptor((-1 :: res.regs).max + 1))
    res
  }

  def applyTag(id: Id): rpyeffect.Tag = id match {
    case Name(name) => rpyeffect.Tag.Name(name)
    case Index(i) => rpyeffect.Tag.Index(i)
    case generated: Generated => rpyeffect.Tag.Name(s"${Generated.runId}#${generated.toString}")
  }

  def apply(l: List[Instruction[Nothing, Id, Index, Index]])(using Emit[rpyeffect.Instruction], Emit[rpyeffect.FrameDescriptor], ErrorReporter): rpyeffect.Terminator = l match {
    case Let(Nil, Nil) :: rest => apply(rest)
    case Let(List(Var(Index(lhs))), List(Var(Index(rhs)))) :: rest =>
      if(rhs != lhs) {
        use(rhs); use(lhs)
        emit(rpyeffect.Copy(rhs, lhs))
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
        val todo = new mutable.HashMap[RhsOperand[Nothing, Index],
          mutable.HashSet[LhsOperand[Nothing, Index]]]()
        /** Normalize types to TopPtr/Num */
        def normalizeLhs(lhsOperand: LhsOperand[Nothing, Index]) = lhsOperand match {
          case Var(name) => Var(name)
        }
        /** Normalize types to TopPtr/Num */
        def normalizeRhs(rhsOperand: RhsOperand[Nothing, Index]) = rhsOperand match {
          case Var(name) => Var(name)
        }
        for ((s, t) <- rhssOps zip lhssOps) {
          todo.getOrElseUpdate(normalizeRhs(s), new mutable.HashSet()).addOne(normalizeLhs(t))
        }

        /** Returns true iff it still is a source in [[todo]] (i.e. there we still need the value) */
        def stillNeeded(l: LhsOperand[Nothing, Index]): Boolean = l match {
          case v@Var(name) =>
            todo.contains(v)
        }

        /** Dirty flag for the [[todo]] list, for fixpoint computation */
        var changed = true

        /** Removes the given edge from the graph, updating `changed` and possibly removing the node */
        def done(s: RhsOperand[Nothing, Index], t: LhsOperand[Nothing, Index]) = {
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
              case (Var(Index(s)), Var(Index(t))) =>
                use(s); use(t)
                if(s != t) {
                  use(s); use(t)
                  emit(rpyeffect.Copy(s, t))
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
            case (source@Var(Index(s)), targets) =>

              assert(targets.size == 1)
              targets.head match {
                case target@Var(Index(t)) =>
                  if (t != s) {
                    use(t); use(t)
                    emit(rpyeffect.Swap(t, s));
                  }
                  todo(source) = todo(target);
                  todo.remove(target);
              }
          }
        }
      // TODO IIUC we do not need to drop here :thinking:
      apply(rest)
    case LetConst(Var(Index(i)), value: Int) :: rest =>
      use(i)
      emit(rpyeffect.Const(i, value))
      apply(rest)
    case LetConst(Var(Index(i)), value: Boolean) :: rest =>
      use(i)
      emit(rpyeffect.ConstBool(i, value))
      apply(rest)
    case LetConst(Var(Index(out)), value: Double) :: rest =>
      use(out)
      emit(rpyeffect.ConstDouble(out, value))
      apply(rest)
    case LetConst(Var(Index(out)), value: String) :: rest =>
      use(out)
      emit(rpyeffect.ConstString(out, value))
      apply(rest)
    case LetConst(Var(Index(out)), FormatConst(fmt, value)) :: rest =>
      use(out)
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
    case CallLib(Var(Index(lib)), symbol, env) :: Nil =>
      val _ = apply(env)
      rpyeffect.CallLib(lib, symbol)
    case LoadLib(Var(Index(path))) :: Nil =>
      emit(libraryFrameDescriptor)
      rpyeffect.LoadLib(path)
    case IfZero(Var(Index(arg)), thenClause @ Clause(params, env, Index(target))) :: rest =>
      use(arg)
      assert(params.isEmpty)
      emit(rpyeffect.IfZero(arg, rpyeffect.Clause(rpyeffect.Tag.Index(-1), apply(Nil), target)))
      apply(rest)
    case Allocate(Var(Index(ref)), Var(Index(init)), Var(Index(region))) :: rest =>
      use(ref); use(region); use(init)
      emit(rpyeffect.Allocate(ref, init, region))
      apply(rest)
    case Load(Var(Index(out)), Var(Index(ref))) :: rest =>
      use(out); use(ref)
      emit(rpyeffect.Load(out, ref))
      apply(rest)
    case Store(Var(Index(ref)), Var(Index(in))) :: rest =>
      use(ref); use(in)
      emit(rpyeffect.Store(ref, in))
      apply(rest)
    case GetDynamic(Var(Index(out)), Var(Index(n)), Var(Index(label))) :: rest =>
      use(out); use(n); use(label)
      emit(rpyeffect.GetDynamic(out, n, label))
      apply(rest)
    case Shift(Var(Index(out)), Var(Index(n)), Var(Index(label))) :: rest =>
      use(out); use(n); use(label)
      emit(rpyeffect.ShiftDyn(out, n, label))
      apply(rest)
    case Control(Var(Index(out)), Var(Index(n)), Var(Index(label))) :: rest =>
      use(out); use(n); use(label)
      emit(rpyeffect.Control(out, n, label))
      apply(rest)
    case PushStack(Var(Index(stack))) :: rest =>
      use(stack)
      emit(rpyeffect.PushStack(stack))
      apply(rest)
    case NewStack(Var(Index(oSt)), Var(Index(oReg)), Var(Index(label)), Index(target), args) :: rest =>
      use(oSt); use(oReg); use(label)
      emit(rpyeffect.NewStack(oSt, oReg, label, target, apply(args)))
      apply(rest)
    case NewStackWithBinding(Var(Index(oSt)), Var(Index(oReg)), Var(Index(label)), Index(target), args, Var(Index(oBnd))) :: rest =>
      use(oSt); use(oReg); use(oBnd); use(label)
      emit(rpyeffect.NewStackWithBinding(oSt, oReg, label, target, apply(args), oBnd))
      apply(rest)
    case Construct(Var(Index(out)), tpe, tag, args) :: rest =>
      use(out)
      emit(rpyeffect.Construct(out, applyTag(tpe), applyTag(tag), apply(args)))
      apply(rest)
    case Match(tpe, Var(Index(scr)), clauses, default) :: Nil if clauses.isEmpty =>
      rpyeffect.Jump(default.target.i)
    case Match(tpe, Var(Index(scr)), clauses, default) :: Nil =>
      use(scr)
      val tClauses = clauses.map {
        case (tag, cls) => applyMatchClause(tpe, Some(tag), cls)
      }
      rpyeffect.Match(applyTag(tpe), scr, tClauses, applyMatchClause(tpe, None, default))
    case Switch(Var(Index(arg)), cases, default, env) :: Nil =>
      use(arg)
      val vals = cases.map(_._1)
      val targets = cases.map{ case (_, Index(t)) => t }
      val def_target = default match {
        case Index(t) => t
      }
      rpyeffect.Switch(arg, vals, targets, def_target)
    case Proj(Var(Index(out)), tpe, Var(Index(scrutinee)), tag, field) :: rest =>
      emit(rpyeffect.Proj(out, applyTag(tpe), scrutinee, applyTag(tag), field))
      apply(rest)
    case New(Var(Index(out)), ifce, targets, args) :: rest =>
      use(out)
      val (tTags, tTargets) = targets.map{ case (mtag, Index(target)) => (applyTag(mtag), target) }.unzip
      emit(rpyeffect.New(out, tTags, tTargets, apply(args)))
      apply(rest)
    case Invoke(Var(recv), ifce, tag, args) :: Nil =>
      use(recv.i)
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
  def applyMatchClause(tpeTag: Id, tag: Option[Id], clause: Clause[Nothing, Index, Index])(using E: ErrorReporter, EFD: Emit[rpyeffect.FrameDescriptor]) = clause match {
    case Clause(params, env, Index(target)) =>
      rpyeffect.Clause(applyTag(tag.getOrElse(new Generated("Missing Tag"))), apply(params), target)
  }

  //region Folding frame descriptors to get the maximum
  def foldFrameDescriptors[R](body: Emit[FrameDescriptor] ?=> R): (FrameDescriptor, R) = {
    Emit.folding(FrameDescriptor(0)) {
      case (FrameDescriptor(m), FrameDescriptor(n)) =>
        FrameDescriptor(Math.max(m, n))
    }(body)
  }
  def use(idx: Int)(using Emit[FrameDescriptor]) = {
    emit(FrameDescriptor(idx+1))
  }
  def apply(b: Block[Nothing, Id, Index, Index])(using Emit[FrameDescriptor], Emit[rpyeffect.Symbol], ErrorReporter): rpyeffect.BasicBlock = b match {
    case Block(label, params, instructions, export_as) =>
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

  override def apply(p: Program[Nothing, Id, Index, Index])(using ErrorReporter): rpyeffect.Program = p match {
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
