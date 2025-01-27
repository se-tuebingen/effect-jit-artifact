package rpyeffectasm.asm
import rpyeffectasm.util.{Phase, ErrorReporter, Emit}
import rpyeffectasm.util.Emit.emit
import scala.annotation.tailrec
import scala.collection.mutable
import rpyeffectasm.common.Value
import rpyeffectasm.common

trait LibLoader {
  def loadLib(path: String): Option[Program[AsmFlags, Id, Id, Id]]
}

object LibLoader {
  object Zero extends LibLoader {
    override def loadLib(path: String): Option[Program[AsmFlags, Id, Id, Id]] = None
  }
}


/** *Inefficient* but correct interpreter for debugging/testing.
 */
object Interpreter extends Phase[Program[AsmFlags, Id, Id, Id], Interpreter.Result] {

  type Prog = Program[AsmFlags, Id, Id, Id]

  case class Result(trace: List[State], terminationCause: TerminationCause, errors: List[rpyeffectasm.util.Error]) {
    def pretty(p: Prog): String = {
      trace.map(_.pretty(p)).mkString("\n") + terminationCause.pretty(p)
    }
    def json(p: Prog): String = {
      import rpyeffectasm.util.JsonPrinter.*
      import scala.collection.immutable.ListMap
      jsonObject(ListMap(
        "trace" -> jsonList(trace.map(_.json(p))),
        "result" -> terminationCause.json(p),
        "errors" -> jsonList(errors.map(_.json))
      ))
    }
  }
  enum TerminationCause extends Throwable {
    case ReturnToEmptyStack(values: List[Value])
    case EndOfBlock
    case UnknownBlock(id: Id)
    case TypeError(comment: String = "")
    case ArityError(expected: LhsOpList[AsmFlags, Id], got: List[Value])
    case UnboundPrompt(label: Id, n: Int)
    case UnboundRegister(name: Var[Id])
    case UnknownSymbol(name: String, lib: String)
    case FailedProjection(expected: Id, got: Id)
    case FatalError
    case Timeout

    val trace = Thread.currentThread().getStackTrace()

    def pretty(p: Prog) = {
      val msg = this match {
        case ReturnToEmptyStack(values) =>
          val tValues = values.map{ v => f"\n${Console.WHITE} - ${v.toString}${Console.RESET}" }.mkString
          s"returned to empty stack with:${tValues}\n"
        case TypeError(m) =>
          f"Type error. ${m}.\n${Console.WHITE}  "
        case o => o.toString
      }
      f"\n\n${Console.RED}TERMINATED${Console.RESET} ${msg}"
    }
    def json(p: Prog) = {
      import rpyeffectasm.util.JsonPrinter.*
      import scala.collection.immutable.ListMap
      jsonObject(ListMap(
        "reason" -> this.productPrefix,
        "trace" -> jsonList(this.trace.map{ f => s"\"${f}\""}.toList)
      ) ++ (this match {
        case ReturnToEmptyStack(values) => (ListMap(
          "reason" -> "\"return to empty stack\"",
          "args" -> jsonList(values.map{ v => v.json(p) })
        ))
        case EndOfBlock => (ListMap("reason" -> "\"end of block\""))
        case UnknownBlock(id) => (ListMap("reason" -> "\"unknown block\"", "name" ->  f"\"${AsmPrettyPrinter(id)}\""))
        case TypeError(m) => (ListMap(
          "reason" -> "\"type error\"",
          "comment" -> s"\"${m}\"",
        ))
        case UnboundRegister(v) => (ListMap("reason" -> "\"unbound register\"",
          "register" -> s"\"${v}\""
        ))
        case UnboundPrompt(label, n) => (ListMap("reason" -> "\"unbound prompt\"",
          "label" -> JsonPrettyPrinter.toDoc(label),
          "n" -> n.toString
        ))
        case o => (ListMap("reason" -> s"\"${o.productPrefix}\""))
      }))
    }
  }

  sealed trait AValue extends Value {
    def json(p: Prog): String = f"\"${this.toString()}\"" // TODO
  }
  extension(self: Value) {
    def json(p: Prog) = self match {
      case v: AValue => v.json(p)
      case v =>  f"\"${this.toString()}\""
    }
  }
  export common.VBase.{VInt, VDouble, VString}
  case class VStack(v: List[Frame | Prompt]) extends AValue { } // TODO
  case class VLabel(i: Id) extends AValue { }
  case class VData(tpe_tag: Id, tag: Id, fields: List[Value]) extends AValue {
  }
  case class VCoData(ifce_tag: Id, vtable: Map[Id, Id], captures: List[Value]) extends AValue {
  }
  object VNull extends AValue {
    val lbl = Name("null_label")
  }

  case class State(
      pc_block: Id,
      pc_ins: Int,
      env: Map[Id, Value],
      stack: List[Frame | Prompt],
      symbols: Map[String, Id],
      libs: Map[String, common.Concrete.VLib[Id]] = Map.empty) {
    def pretty(prog: Prog): String = {
      val ins = prog.blocks.find { b => b.label == pc_block }.flatMap { b =>
        if pc_ins < b.instructions.length then Some(b.instructions(pc_ins)) else None
      } match {
        case Some(x) => AsmPrettyPrinter(x)
        case None => "???"
      }
      val oenv = env.map{ case (k, v) => s"${AsmPrettyPrinter(k)}: ${v}"}.mkString("\n       ")
      val ostack = stack.map{
        case Frame(target, env) =>
          val args = env.map{ v => s"\n       ${v}"}.mkString("")
          s"    --- ${AsmPrettyPrinter(target)} ---${args}"
        case Prompt(lbl) => s"    @@@ ${AsmPrettyPrinter(lbl)} @@@"
      }.mkString("\n")
      s"""${Console.WHITE}  Env: ${oenv}
         |  Stack: \n${ostack}${Console.RESET}
         |${Console.CYAN}${AsmPrettyPrinter(pc_block)} + ${pc_ins} :${Console.RESET} ${ins}""".stripMargin
    }
    def json(prog: Prog): String = {
      import rpyeffectasm.util.JsonPrinter.*
      import scala.collection.immutable.ListMap
      jsonObject(ListMap(
        "pc" -> jsonObjectSmall(ListMap("block" -> JsonPrettyPrinter.toDoc(pc_block), "ins" -> pc_ins.toString)),
        "op" -> prog.blocks.find{ b => b.label == pc_block }.flatMap { b =>
          if pc_ins < b.instructions.length then Some(b.instructions(pc_ins)) else None
        }.map { op => JsonPrettyPrinter.toDoc(op) }.getOrElse( "\"not found\"" ),
        "env" -> env.json,
        "stack" -> jsonList(stack.map {
          case Frame(target, env) => jsonObject(ListMap("tpe" -> "\"frame\"", "target" -> JsonPrettyPrinter.toDoc(target), "env" -> jsonListSmall(env.map{v => s"\"${v}\""})))// TODO print values
          case Prompt(lbl) => jsonObjectSmall(ListMap("tpe" -> "\"prompt\"", "label" -> JsonPrettyPrinter.toDoc(lbl)))
        })
      ))
    }
  }


  extension(self: Map[Id, Value]) def json: String = {
    import rpyeffectasm.util.JsonPrinter.*
    import scala.collection.immutable.ListMap
    jsonListSmall(self.toList.map{ case (k, v) => jsonObjectSmall(ListMap("name" -> JsonPrettyPrinter.toDoc(k), "value" -> s"\"${v}\""))})// TODO print values
  }
  case class Frame(target: Id, env: List[Value])
  case class Prompt(label: Id)

  def get(rhs: RhsOperand[AsmFlags, Id], env: Map[Id, Value])(using ErrorReporter): Value = rhs match {
    case Const(value: Int) => VInt(value)
    case Const(value: Double) => VDouble(value)
    case Const(value: String) => VString(value)
    case Var(Index(i)) if i < 0 => VNull
    case Var(name) if env.contains(name) => env(name)
    case v @ Var(name) => throw TerminationCause.UnboundRegister(v)
    case Ref(ref) => get(ref, env) match {
      case v => throw TerminationCause.TypeError()
    }
  }
  def set(lhs: LhsOperand[AsmFlags, Id], value: Value, env: Map[Id, Value])(using ErrorReporter): Map[Id, Value] = lhs match {
    case Var(name) =>
      env.updated(name, value)
  }

  def step(prog: Prog, prev_state: State)(using ErrorReporter): State | TerminationCause = try {
    prev_state match {
      case State(pc_block, pc_ins, env, stack, _, _) =>
        val block = prog.blocks.find{ b => b.label == pc_block }.getOrElse{
          throw TerminationCause.UnknownBlock(pc_block)
        }
        if(block.instructions.length <= pc_ins) {
          throw TerminationCause.EndOfBlock
        }
        val ins = block.instructions(pc_ins)
        val state = prev_state.copy(pc_ins = pc_ins + 1)

        ins match {
          case Let(lhss, rhss) =>
            var newEnv = env
            (lhss zip rhss).foreach{ case (lhs, rhs) =>
              val v = get(rhs, env)
              lhs match {
                case x@Var(name) =>
                  newEnv = set(x, v, newEnv)
                case Ref(ref) => get(ref, env) match {
                  case v => throw TerminationCause.TypeError( "lhs of let")
                }
              }
            }
            return state.copy(env = newEnv)
          case LetConst(out, value) =>
            out match {
              case x@Var(name) =>
                return state.copy(env = set(x, value match {
                  case i: Int => VInt(i)
                  case d: Double => VDouble(d)
                  case s: String => VString(s)
                  case f: FormatConst if f.fmt == "path" => VString(f.value.replace("$0", "."))
                }, env))
            }
          case Primitive(out, name, in) =>
            val tIn = in.map(get(_, env))
            val res = runPrimitive(name, tIn)
            return state.copy(env = env ++ ((out zip res).map{ case (Var(o),v) => o -> v }.toMap))
          case Push(target, args) =>
            return state.copy(stack = Frame(target, args.map(get(_, env))) :: stack)
          case Return(args) =>
            stack.dropWhile(_.isInstanceOf[Prompt]) match {
              case Frame(target, senv) :: tail =>
                val tBlock = prog.blocks.find { b => b.label == target }.getOrElse {
                  throw TerminationCause.UnknownBlock(target)
                }
                val pars = tBlock.params.take(args.length)
                val spars = tBlock.params.drop(args.length)
                val newEnv = ((pars zip (args.map(get(_,env)))) ++ (spars zip senv)).map {
                  case (x@Var(k),v) =>
                    k -> v
                }.toMap
                return state.copy(pc_block = target, pc_ins = 0, env = newEnv, stack = tail)
              case (_: Prompt) :: tail => ???
              case Nil =>
                throw TerminationCause.ReturnToEmptyStack(args.map { a => get(a, env) })
            }
          case Jump(target, args) =>
            val tBlock = prog.blocks.find { b => b.label == target }.getOrElse {
              throw TerminationCause.UnknownBlock(target)
            }
            if(tBlock.params.length != args.length) {
              throw TerminationCause.ArityError(tBlock.params, args.map { a => get(a, env) })
            }
            val newEnv = (tBlock.params zip args).map{
              case (Var(p), a) => p -> get(a, env)
            }.toMap
            return state.copy(pc_block = target, pc_ins = 0, env = newEnv)
          case IfZero(arg, thenClause) =>
            get(arg, env) match {
              case VInt(x) => if(x == 0) {
                assert(thenClause.params.isEmpty)
                return state.copy(pc_block = thenClause.target, pc_ins = 0)
              }
              case v => throw TerminationCause.TypeError( "in if0")
            }
            return state
          case Allocate(ref, init, region) => ???
          case Load(out, ref) => ???
          case Store(ref, in) => ???
          case Shift(outx@Var(out), nV, label) =>
            val lbl = get(label, env) match {
              case VLabel(i) => i
              case VNull => VNull.lbl
              case l => throw TerminationCause.TypeError( "in shift")
            }
            val n = get(nV, env) match {
              case VInt(i) => i
              case v => throw TerminationCause.TypeError( "as evidence in shift")
            }
            def go(m: Int, stack: List[Frame | Prompt], cont: List[Frame | Prompt]): (List[Frame | Prompt], List[Frame | Prompt]) = {
              stack match {
                case (p @ Prompt(clbl)) :: tail if clbl == lbl && m == 0 => (tail, p :: cont)
                case (p @ Prompt(clbl)) :: tail if clbl == lbl => go(m-1, tail, p :: cont)
                case o :: tail => go(m, tail, o :: cont)
                case Nil => throw TerminationCause.UnboundPrompt(lbl, n)
              }
            }
            val (newStack, cont) = go(n, stack, Nil)
            return state.copy(stack = newStack, env = set(outx, VStack(cont), env))
          case Control(outx@Var(out), nV, label) =>
            val lbl = get(label, env) match {
              case VLabel(i) => i
              case VNull => VNull.lbl
              case l => throw TerminationCause.TypeError( "in control")
            }
            val n = get(nV, env) match {
              case VInt(i) => i
              case v => throw TerminationCause.TypeError( "as evidence in control")
            }

            def go(m: Int, stack: List[Frame | Prompt], cont: List[Frame | Prompt]): (List[Frame | Prompt], List[Frame | Prompt]) = {
              stack match {
                case (p@Prompt(clbl)) :: tail if clbl == lbl && m == 0 => (tail, cont)
                case (p@Prompt(clbl)) :: tail if clbl == lbl => go(m - 1, tail, p :: cont)
                case o :: tail => go(m, tail, o :: cont)
                case Nil => throw TerminationCause.UnboundPrompt(lbl, n)
              }
            }

            val (newStack, cont) = go(n, stack, Nil)
            return state.copy(stack = newStack, env = set(outx, VStack(cont), env))
          case PushStack(contV) =>
            def go(cont: List[Frame | Prompt], stack: List[Frame | Prompt]): List[Frame | Prompt] = cont match {
              case hd :: tl => go(tl, hd :: stack)
              case Nil => stack
            }
            val cont = get(contV, env) match {
              case VStack(v) => v
              case v => throw TerminationCause.TypeError()
            }
            return state.copy(stack = go(cont, stack))
          case NewStack(x@Var(name), region, label, target, args) =>
            val lbl = get(label, env) match {
              case VLabel(i) => i
              case VNull => VNull.lbl
              case v => throw TerminationCause.TypeError()
            }
            val senv = args.map { case a => get(a, env) }
            return state.copy(env = set(x, VStack(List(Prompt(lbl), Frame(target, senv))), env))
          case Construct(outx@Var(out), tpe, tag, args) =>
            return state.copy(env = set(outx, VData(tpe, tag, args.map(get(_,env))), env))
          case Match(tpe, scrutinee, clauses, default) =>
            get(scrutinee, env) match {
              case VData(tpe_tag, tag, fields) =>
                if(tpe_tag != tag) {
                  error("Type tags don't match up in match.")
                }
                val cls = clauses.find { case (t, _) => t == tag }.map(_._2)
                cls match {
                  case Some(Clause(params, cenv, target)) =>
                    if(params.length != fields.length) {
                      error(s"Match clause does not have the correct number of parameters. Should have ${fields.length} but has ${params.length}.")
                    }
                    val tBlock = prog.blocks.find { b => b.label == target }.getOrElse {
                      throw TerminationCause.UnknownBlock(target)
                    }
                    val cpars = cenv.filterNot{ case Var(p) => params.exists{ case Var(p2) => p == p2 }}
                    val newEnv = (cpars.map{ case p@Var(name) => name -> get(p, env)}.toMap) ++ ((params zip fields).map{
                      case (x@Var(p),v) =>
                        p -> v
                    }.toMap)
                    return state.copy(
                      pc_block = target, pc_ins = 0,
                      env = newEnv
                    )
                  case None => default match { case Clause(params, cenv, target) =>
                    assert(params.isEmpty)
                    val newEnv = cenv.map { case p@Var(v) => v -> get(p, env) }.toMap
                    return state.copy(pc_block = target, pc_ins = 0, env = newEnv)
                  }
                }
              case v => throw TerminationCause.TypeError( "in match")
            }
          case Proj(outx@Var(out), tpe, scrutinee, etag, field) =>
            get(scrutinee, env) match {
              case VData(tpe_tag, tag, fields) =>
                if(tpe_tag != tpe) {
                  error("Type tags don't match up in projection.")
                }
                if(tag != etag) {
                  throw TerminationCause.FailedProjection(etag, tag)
                }
                return state.copy(env = set(outx, fields(field), env))
              case v =>
                throw TerminationCause.TypeError()
            }
          case Switch(arg, cases, default, cenv) =>
            get(arg, env) match {
              case VInt(got) =>
                val newEnv = cenv.map { case p@Var(v) =>
                  val newVal = get(p, env)
                  v -> newVal }.toMap
                cases.find{ case (exp, _) => exp == got} match {
                  case Some((_, thn)) =>
                    return state.copy(pc_block = thn, pc_ins = 0, env = newEnv)
                  case None => ???
                    return state.copy(pc_block = default, pc_ins = 0, env = newEnv)
                }
              case v =>
                throw TerminationCause.TypeError("in switch")
            }
          case New(outx@Var(out), ifce, targets, args) =>
            val r = VCoData(ifce, targets.toMap, args.map(get(_,env)))
            return state.copy(env = set(outx, r, env))
          case Invoke(receiver, ifce, tag, args) =>
            get(receiver, env) match {
              case v @ VCoData(ifce_tag, vtable, captures) =>
                if(ifce != ifce_tag) {
                  error(s"Interface tags don't match up for call. Got ${ifce_tag}, expected ${ifce}.")
                }
                val target = vtable.getOrElse(tag, { fatal(s"${v} of interface ${ifce_tag} does not have a method ${tag}") })
                val tBlock = prog.blocks.find { b => b.label == target }.getOrElse {
                  throw TerminationCause.UnknownBlock(target)
                }
                val pars = tBlock.params.take(args.length)
                val cpars = tBlock.params.drop(args.length)
                val newEnv = ((pars zip (args.map(get(_,env)))) ++ (cpars zip captures)).map {
                  case (x@Var(k), v) =>
                    k -> v
                }.toMap
                return state.copy(
                  pc_block = target, pc_ins = 0,
                  env = newEnv)
              case v =>
                throw TerminationCause.TypeError()
            }
          case CallLib(lib, symbol, args) =>
            get(lib, env) match {
              case common.Concrete.VLib(libname, symbols) =>
                symbols.get(symbol) match {
                  case Some(target: Id) =>
                    val tBlock = prog.blocks.find { b => b.label == target }.getOrElse {
                      throw TerminationCause.UnknownBlock(target)
                    }
                    if(tBlock.params.length != args.length) {
                      throw TerminationCause.ArityError(tBlock.params, args.map { a => get(a, env) })
                    }
                    val newEnv = (tBlock.params zip args).map{
                      case (Var(p), a) => p -> get(a, env)
                    }.toMap
                    return state.copy(pc_block = target, pc_ins = 0, env = newEnv)
                  case None => throw TerminationCause.UnknownSymbol(symbol, libname)
                }
              case _ => throw TerminationCause.TypeError( "Expected a library")
            }
          case LoadLib(path) =>
            // Find lib with modified name
            // Load lib
            // Insert in program
            // Create lib value
            ???
          case Debug(msg, trace) => state
        }
    }
  } catch {
    case t: TerminationCause => t
  }

  // TODO maybe model those somewhere else (alongside other properties like type etc)
  def runPrimitive(name: String, args: List[Value])(using ErrorReporter): List[Value] = {
    import rpyeffectasm.common.Primitives
    Primitives.primitives.find{ p => p.name == name } match {
      case Some(p) =>
        Primitives.runSafe(name, args)
      case None => ErrorReporter.fatal(s"Unknown primitive '${name}'")
    }
  }

  def initialState(f: Prog) = State(f.blocks.find(_.export_as.contains("$entrypoint")).getOrElse(f.blocks.head).label, 0, Map.empty, Nil,
    f.blocks.flatMap{ b => b.export_as.map((_, b.label)) }.toMap)

  override def apply(f: Prog)(using ErrorReporter): Result = {
    runWithTimeout(f, None)
  }

  def runWithTimeout(f: Prog, maxSteps: Option[Int])(using ErrorReporter): Result = {
    val trace: mutable.ListBuffer[State] = new mutable.ListBuffer[State]()
    ErrorReporter.collectErrors {
      Emit.collectingInto(trace) {
          @tailrec
          def go(state: State, time: Int): TerminationCause = {
            if (maxSteps.exists(time >= _)){ return TerminationCause.Timeout }
            val o = state.pretty(f).replaceAll("\n", "\n         ")
            emit(state)
            ErrorReporter.withLocation(s"step ${trace.length-1}"){
              step(f, state)
            } match {
              case next: State => go(next, time+1)
              case t: TerminationCause => t
            }
          }

          go(initialState(f), 0)
      }
    } match {
      case ErrorReporter.ResultWithCollectedErrors.OK(tc, errors) =>
        Result(trace.toList, tc, errors)
      case ErrorReporter.ResultWithCollectedErrors.Fatal(errors) =>
        Result(trace.toList, TerminationCause.FatalError, errors)
    }
  }

}
