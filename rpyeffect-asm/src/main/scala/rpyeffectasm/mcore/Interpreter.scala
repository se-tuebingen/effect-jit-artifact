package rpyeffectasm.mcore
import rpyeffectasm.util
import scala.collection.mutable
import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}
import rpyeffectasm.util.ErrorReporter
import rpyeffectasm.common.{Purity, Value, Primitives}
import rpyeffectasm.common

trait LibLoader[+O <: ATerm] {
  def loadLib(path: String): Option[Program[O]]
}
object LibLoader {
  object Zero extends LibLoader[ATerm] {
    override def loadLib(path: String): Option[Program[ATerm]] = None
  }

}

case class Interpreter(filename: String = "__main__", loader: LibLoader[ATerm] = LibLoader.Zero) {

  case class SpecializeLib(lib: Literal) extends Structural[ATerm, ATerm] {
    override def term: PartialFunction[Term[ATerm], Term[ATerm]] = {
      case ThisLib() => lib
    }
  }

  sealed trait StepResult
  case class State(env: Env, focused: Term[ATerm], stack: Stack,
                   symbols: Map[String, (Value.VDynLib[ATerm], Var)], libs: Map[String, VDynLib[ATerm]]) extends StepResult {

    def push(f: Frame): State = f match {
      case FNop => this
      case f => this.copy(stack = f :: this.stack)
    }
    def pop(): State = this.copy(stack = this.stack.tail)

    def json(using util.StreamingJsonPrinter.SharingContext) = {
      import rpyeffectasm.util.StreamingJsonPrinter.*
      obj("env" --> env.json,
        "focused" --> raw(JsonPrettyPrinter.toDoc(focused)),
        "stack" --> listOf[Frame](_.json)(stack))
    }
  }
  sealed trait Env
  object Env {
    private var json_trunk: List[Env] = Nil
    case object Toplevel extends Env
    case class Bind(bindings: Map[Var, Value], outer: Env)(using ErrorReporter) extends Env {
      bindings.foreach{
        case x -> v if !v.tpe.asMCore.isSubtypeOf(x.tpe) =>
          ErrorReporter.error(
            s"Type of variable\n  ${x}\nand value don't match in binding: \n" +
              s"  ${v}\nis not a\n  ${x.tpe}."
          )
        case _ => ()
      }

      override def toString: String = s"Bind(${bindings.keySet.toString()}, ${outer.toString})"
    }
    class BindRec(val binds: Set[Var], var bindings: Map[Var, Value], val outer: Env) extends Env
    object BindRec {
      def unapply(br: BindRec): (Set[Var], Map[Var, Value], Env) = (br.binds, br.bindings, br.outer)
    }

    extension(self: Env) {
      def lookup(v: Var)(using ErrorReporter): Option[Value] = self match {
        case Toplevel => None
        case Bind(bnds, _) if bnds.contains(v) => Some(bnds(v))
        case Bind(bnds, outer) =>
          bnds.collectFirst{ // try to find an appropriate binding to automatically convert
            case (Var(x, t), r) if x == v.name && t.isSubtypeOf(Num) && v.tpe == Top =>
              common.Concrete.VBox(r)
            case (Var(x, t), r) if x == v.name && v.tpe.isSubtypeOf(Num) && t == Top =>
              r match {
                case common.Concrete.VBox(r) => r
                case v: Value.VInt =>
                  ErrorReporter.error("Unboxing value that was not yet boxed. This is expected before Boxing.")
                  v
                case _ => throw Error.UnboxNonDataToNum(r)
              }
            case (Var(x, t), r) if x == v.name
              && ((v.tpe.isSubtypeOf(Ptr) || v.tpe == Top)
                  && (t.isSubtypeOf(Ptr) || t == Top)) =>
              r
          }.orElse {
            outer.lookup(v)
          }
        case BindRec(_, bnds, _) if bnds.contains(v) => Some(bnds(v))
        case BindRec(bnds, _, _) if bnds.contains(v) => throw Error.UninitializedRec(v)
        case BindRec(eBnds, bnds, outer) =>
          eBnds.collectFirst { // try to find an appropriate binding to automatically convert
            case c@Var(x, t) if x == v.name && t.isSubtypeOf(Num) && v.tpe == Top =>
              val r = self.lookup(c).get
              VData(Name(s"Boxed${t.toString}"), Index(0), List(r))
            case c@Var(x, t) if x == v.name && v.tpe.isSubtypeOf(Num) && t == Top =>
              val r = self.lookup(c).get
              r match {
                case Value.VData(tpe_tag, tag, fields) => fields.head
                case v: Value.VInt =>
                  ErrorReporter.error("Unboxing value that was not yet boxed. This is expected before Boxing.")
                  v
                case _ => throw Error.UnboxNonDataToNum(r)
              }
            case c@Var(x, t) if x == v.name
              && ((v.tpe.isSubtypeOf(Ptr) || v.tpe == Top)
              && (t.isSubtypeOf(Ptr) || t == Top)) =>
              self.lookup(c).get
          }.orElse {
            outer.lookup(v)
          }
      }
      def json(using util.StreamingJsonPrinter.SharingContext): util.StreamingJsonPrinter = {
        import util.StreamingJsonPrinter._
        import util.StreamingJsonPrinter
        explicitlySharing(self) {
          case Toplevel => List("tpe" --> StreamingJsonPrinter.toJson("Toplevel"))
          case Bind(bnds, outer) => List("tpe" --> StreamingJsonPrinter.toJson("Bind"), "bindings" --> listOf[(Var, Value)] {
            case (v -> value) => obj("var" --> raw(JsonPrettyPrinter.toDoc(v)), "value" --> value.vjson)
          }(bnds), "outer" --> outer.json)
          case BindRec(binds, bnds, outer) if Env.json_trunk.contains(self) =>
              List("tpe" --> StreamingJsonPrinter.toJson("BindRec"), "binds" --> listOf[Var] { x => raw(JsonPrettyPrinter.toDoc(x)) }(binds),
                "recursive" --> StreamingJsonPrinter.json(true))
          case BindRec(binds, bnds, outer) =>
              val r = List("tpe" --> StreamingJsonPrinter.toJson("BindRec"),
                "binds" --> listOf[Var] { x => raw(JsonPrettyPrinter.toDoc((x))) }(binds),
                "bindings" --> listOf[(Var, Value)] {
                  case (v -> value) =>
                    obj("var" --> raw(JsonPrettyPrinter.toDoc(v)),
                      "value" --> value.vjson.wrapState {
                        json_trunk = self :: json_trunk
                      } {
                        json_trunk = json_trunk.tail
                      })
                    obj("var" --> raw(JsonPrettyPrinter.toDoc(v)),
                      "value" --> value.vjson.wrapState {
                        json_trunk = self :: json_trunk
                      } {
                        json_trunk = json_trunk.tail
                      })
                }(bnds),
                "outer" --> outer.json)
              r
          }
      }
    }
  }
  type Stack = List[Frame]
  enum Frame {
    case FApp1(args: List[Term[ATerm]], env: Env)
    case FApp2(fn: Value, env: Env)
    case FSeq(ts: List[Term[ATerm]], env: Env)
    case FLet(names: List[Var], env: Env, body: Term[ATerm])
    case FLetRec(names: List[Var], evaluated: List[Value], unevaluated: List[Term[ATerm]], env: Env.BindRec, body: Term[ATerm])
    case FIfZero(thn: Term[ATerm], els: Term[ATerm], env: Env)
    case FConstruct(tpe_tag: Id, tag: Id)
    case FProj(tpe_tag: Id, tag: Id, field: Int)
    case FMatch(tpe_tag: Id, clauses: List[(Id, Clause[ATerm])], default_clause: Clause[ATerm], env: Env)
    case FSwitch(cases: List[(Literal, Term[ATerm])], default: Term[ATerm], env: Env)
    case FInvoke1(ifce_tag: Id, method: Id, args: List[Term[ATerm]], env: Env)
    case FInvoke2(ifce_tag: Id, method: Id, rcv: Value)
    case FMany(evaluated: List[Value], unevaluated: List[Term[ATerm]], env: Env)
    case FClause(c: Clause[ATerm], env: Env)
    case FReset(region: LhsOperand, body: Term[ATerm], ret: Clause[ATerm], env: Env)
    case FShift1(n: ATerm, k: LhsOperand, body: Term[ATerm], retType: Type, env: Env)
    case FShift2(label: Value, k: LhsOperand, body: Term[ATerm], retType: Type, env: Env)
    case FControl1(n: ATerm, k: LhsOperand, body: Term[ATerm], retType: Type, env: Env)
    case FControl2(label: Value, k: LhsOperand, body: Term[ATerm], retType: Type, env: Env)
    case FResume1(args: List[Term[ATerm]], env: Env)
    case FResume2(cont: Value)
    case FResumed(body: Term[ATerm], env: Env)
    case FPrimitive(name: String)
    case Prompt(label: Value, region: common.Concrete.VRegion)
    case Handler(tpe: HandlerSugar.HandlerType, tag: Id, handlers: List[(Id, Clause[ATerm])], env: Env)
    case DHandler(tpe: DynamicHandlerSugar.HandlerType, tag: Value, handlers: List[(Id, Clause[ATerm])], env: Env)
    case FOp(tag: Id, op: Id, k: Clause[ATerm])
    case FDHandle(tpe: DynamicHandlerSugar.HandlerType, handlers: List[(Id, Clause[ATerm])], body: Term[ATerm], ret: Option[Clause[ATerm]], env: Env)
    case FDOp(op: Id, k: Clause[ATerm])
    case FLetRef1(ref: LhsOperand, init: Term[ATerm], body: Term[ATerm], env: Env)
    case FLetRef2(ref: LhsOperand, region: common.Concrete.VRegion, body: Term[ATerm], env: Env)
    case FLoadLib
    case FCallLib1(symbol: String, args: List[Term[ATerm]], retType: Type)
    case FCallLib2(lib: Value.VDynLib[ATerm], symbol: String, retType: Type)
    case FQualified(name: String, tpe: Type)
    case FNop

    def json(using util.StreamingJsonPrinter.SharingContext) = {
      import rpyeffectasm.util.StreamingJsonPrinter.*
      extension(self: Term[ATerm]) def tjson = raw(JsonPrettyPrinter.toDoc(self))
      extension(self: Id) def ijson = raw(JsonPrettyPrinter.toDoc(self))

      objL(List("type" --> this.productPrefix.toJson) ++ (this match {
      case Frame.FApp1(args, env) => (List("args" --> listOf[Term[ATerm]](_.tjson)(args), "env" --> env.json))
      case Frame.FApp2(fn, env) => (List("fn" --> fn.vjson, "env" --> env.json))
      case Frame.FSeq(ts, env) => (List("ts" --> listOf[Term[ATerm]](_.tjson)(ts), "env" --> env.json))
      case Frame.FLet(names, env, body) => (List(
        "names" --> listOf[Var]{ x => raw(JsonPrettyPrinter.toDoc(x)) }(names),
        "env" --> env.json,
        "body" --> raw(JsonPrettyPrinter.toDoc(body))
      ))
      case Frame.FLetRec(names, eval, uneval, env, body) => (List(
        "names" --> listOf[Var] { x => raw(JsonPrettyPrinter.toDoc(x)) }(names),
        "evaluated" --> listOf[Value](_.vjson)(eval),
        "unevaluated" --> listOf[Term[ATerm]] (_.tjson) (uneval),
        "env" --> env.json,
        "body" --> raw (JsonPrettyPrinter.toDoc (body) )
      ))
      case Frame.FIfZero(thn, els, env) => (List(
        "then" --> thn.tjson,
        "else" --> els.tjson,
        "env" --> env.json
      ))
      case Frame.FConstruct(tpe_tag, tag) => List(
        "type_tag" --> tpe_tag.ijson,
        "tag" --> tag.ijson
      )
      case Frame.FProj(tpe_tag, tag, field) => List(
        "type_tag" --> tpe_tag.ijson,
        "tag" --> tag.ijson,
        "field" --> field.json
      )
      case Frame.FMatch(tpe_tag, clauses, default_clause, env) => List(
        "type_tag" --> tpe_tag.ijson,
        "clauses" --> listOf[(Id, Clause[ATerm])]{
          case (t, Clause(params, body)) => obj(
            "tag" --> t.ijson,
            "params" --> listOf[Var](_.tjson)(params),
            "body" --> body.tjson
          )
        }(clauses),
        "default_clause" --> obj(
          "params" --> listOf[Var](_.tjson)(default_clause.params),
          "body" --> default_clause.body.tjson
        ),
        "env" --> env.json
      )
      case Frame.FSwitch(cases, default, env) => List(
        "cases" --> listOf[(Literal, Term[ATerm])]{
          case (v, t) => obj("value" --> raw(v.toString), "then" --> t.tjson)
        }(cases),
        "default" --> default.tjson,
        "env" --> env.json
      )
      case Frame.FInvoke1(ifce_tag, method, args, env) => List(
        "ifce_tag" --> ifce_tag.ijson,
        "method" --> method.ijson,
        "args" --> listOf[Term[ATerm]](_.tjson)(args),
        "env" --> env.json
      )
      case Frame.FInvoke2(ifce_tag, method, rcv) => List(
        "ifce_tag" --> ifce_tag.ijson,
        "method" --> method.ijson,
        "receiver" --> rcv.vjson
      )
      case Frame.FMany(evaluated, unevaluated, env) => List(
        "evaluated" --> listOf[Value](_.vjson)(evaluated),
        "unevaluated" --> listOf[Term[ATerm]](_.tjson)(unevaluated),
        "env" --> env.json
      )
      case Frame.FClause(c, env) => List("clause" --> raw(JsonPrettyPrinter.toDoc(c)), "env" --> env.json)
      case Frame.FReset(region, body, ret, env) => List(
        "region" --> region.tjson,
        "body" --> body.tjson,
        "ret" --> raw(JsonPrettyPrinter.toDoc(ret)),
        "env" --> env.json
      )
      case Frame.FShift1(n, k, body, retType, env) => List(
        "n" --> n.unroll.tjson,
        "k" --> k.tjson,
        "body" --> body.tjson,
        "retType" --> raw(JsonPrettyPrinter.toDoc(retType)),
        "env" --> env.json
      )
      case Frame.FShift2(label, k, body, retType, env) => List(
        "label" --> label.vjson,
        "k" --> k.tjson,
        "body" --> body.tjson,
        "retType" --> raw(JsonPrettyPrinter.toDoc(retType)),
        "env" --> env.json
      )
      case Frame.FControl1(n, k, body, retType, env) => List(
        "n" --> n.unroll.tjson,
        "k" --> k.tjson,
        "body" --> body.tjson,
        "retType" --> raw(JsonPrettyPrinter.toDoc(retType)),
        "env" --> env.json
      )
      case Frame.FControl2(label, k, body, retType, env) => List(
        "label" --> label.vjson,
        "k" --> k.tjson,
        "body" --> body.tjson,
        "retType" --> raw(JsonPrettyPrinter.toDoc(retType)),
        "env" --> env.json
      )
      case Frame.FResume1(args, env) => List(
        "args" --> listOf[Term[ATerm]](_.tjson)(args),
        "env" --> env.json
      )
      case Frame.FResume2(cont) => List("cont" --> cont.vjson)
      case Frame.FPrimitive(name) => List("name" --> name.toJson)
      case Frame.Prompt(label, _) => List("label" --> label.vjson) // TODO region
      case Frame.Handler(tpe, tag, handlers, env) => List(
        "handlerType" --> tpe.productPrefix.toJson,
        "tag" --> tag.ijson,
        "handlers" --> listOf[(Id, Clause[ATerm])]{
          case (id, Clause(params, body)) => obj("tag" --> id.ijson, "params" --> listOf[Var](_.tjson)(params), "body" --> body.tjson)
        }(handlers),
        "env" --> env.json
      )
      case Frame.DHandler(tpe, tag, handlers, env) => List(
        "handlerType" --> tpe.productPrefix.toJson,
        "tag" --> tag.vjson,
        "handlers" --> listOf[(Id, Clause[ATerm])] {
          case (id, Clause(params, body)) => obj("tag" --> id.ijson, "params" --> listOf[Var](_.tjson)(params), "body" --> body.tjson)
        }(handlers),
        "env" --> env.json
      )
      case Frame.FOp(tag, op, k) => List("tag" --> tag.ijson, "op" --> op.ijson,
        "k" --> obj("params" --> listOf[Var](_.tjson)(k.params), "body" --> k.body.tjson))
      case Frame.FDHandle(tpe, handlers, body, ret, env) => List(
        "handlerType" --> tpe.productPrefix.toJson,
        "handlers" --> listOf[(Id, Clause[ATerm])] {
          case (id, Clause(params, body)) => obj("tag" --> id.ijson, "params" --> listOf[Var](_.tjson)(params), "body" --> body.tjson)
        }(handlers),
        "body" --> body.tjson,
      ) ++ ret.map{ case Clause(params, body) =>
        "ret" --> obj("params" --> listOf[Var](_.tjson)(params), "body" --> body.tjson)
      }.toList ++ List("env" --> env.json)
      case Frame.FDOp(op, k) => List(
        "op" --> op.ijson, "k" --> obj("params" --> listOf[Var](_.tjson)(k.params), "body" --> k.body.tjson)
      )
      case Frame.FLoadLib => List()
      case Frame.FCallLib1(symbol, args, rtpe) => List(
        "symbol" --> symbol.toJson, "args" --> listOf[Term[ATerm]](_.tjson)(args), // TODO rtpe
      )
      case Frame.FCallLib2(lib, symbol, rtpe) => List(
        "symbol" --> symbol.toJson, "lib" --> lib.vjson, // TODO rtpe
      )
      case Frame.FQualified(name, tpe) => List(
        "symbol" --> name.toJson
      )
      case Frame.FNop => List()
      case _ => List("value" --> this.toString.toJson)
      }))
    }
  }
  object Frame {
    def fMany(evaluated: List[Value], unevaluated: List[Term[ATerm]], env: Env): Frame = {
      if(unevaluated.isEmpty) {
        if(evaluated.isEmpty) {
          FNop
        } else {
          FMany(evaluated, Nil, Env.Toplevel)
        }
      } else {
        FMany(evaluated, unevaluated, env)
      }
    }
  }
  export Frame.*
  object Value {

    import rpyeffectasm.util.ErrorReporter
    export common.VBase.{VUnit, VInt, VString, VDouble}
    export common.VExternPtr

    case class VLambda(lenv: Env, params: List[Var], body: Term[ATerm]) extends Value {
      override def tpe(using ErrorReporter): Type = Function(params.map(_.tpe), Type.of(body), Purity.Effectful)
    }
    case class VData(tpe_tag: Id, tag: Id, fields: List[Value]) extends Value {
      override def tpe(using ErrorReporter): Type = Data(tpe_tag, List(Constructor(tag, fields.map(_.tpe.asMCore))))
    }
    case class VCoData(lenv: Env, ifce_tag: Id, methods: List[(Id, Clause[ATerm])]) extends Value {
      override def tpe(using ErrorReporter) = Codata(ifce_tag, methods.map {
          case (t, c) => Method(t, c.params.map(_.tpe), Type.of(c.body))
        })
    }
    case class VMany(vals: List[Value]) extends Value {
      override def tpe(using ErrorReporter) =
        ErrorReporter.fatal("Trying to get type of implementation-internal VMany")
    }
    case class VLabel(name: Id) extends Value {
      override def tpe(using ErrorReporter): Type = Base.Label(Top, None)
    }
    case class VCont(frames: List[Frame]) extends Value { override def tpe(using ErrorReporter): Type = Ptr }
    case class VResumption(frames: List[Frame]) extends Value { // like VCont, but callable as lambda; only used by handler sugar
      override def tpe(using ErrorReporter): Type = Function(List(Ptr), Ptr, Purity.Effectful)
    }
    case class VDynLib[+O <: ATerm](filename: String, code: Program[O], lenv: Env) extends Value {
      override def tpe(using ErrorReporter): common.Type = Ptr

      override def toString: String = s"DynLib(\"${filename}\")>"
    }

    extension(self: Value) {

      def many: List[Value] = self match {
        case VMany(vals) => vals
        case v => List(v)
      }

      def vjson(using util.StreamingJsonPrinter.SharingContext): rpyeffectasm.util.StreamingJsonPrinter = {
        import rpyeffectasm.util.StreamingJsonPrinter.*
        explicitlySharing(self) {
          case VInt(x: Int) => List("type" --> "Int".toJson, "value" --> x.json)
          case VString(s) => List("type" --> "String".toJson, "value" --> raw(JsonPrettyPrinter.toDoc(s)))
          case VLambda(lenv, params, body) =>
            List(
              "type" --> "Function".toJson,
              "lenv" --> lenv.json,
              "params" --> listOf[Var] { x => raw(JsonPrettyPrinter.toDoc(x)) }(params),
              "body" --> raw(JsonPrettyPrinter.toDoc(body))
            )
          case VData(tt, t, fs) => List(
            "type" --> "Data".toJson,
            "type_tag" --> raw(JsonPrettyPrinter.toDoc(tt)),
            "tag" --> raw(JsonPrettyPrinter.toDoc(t)),
            "fields" --> listOf[Value](_.vjson)(fs)
          )
          case VCoData(env, it, ms) => List(
            "type" --> "Codata".toJson,
            "ifce_tag" --> raw(JsonPrettyPrinter.toDoc(it)),
            "methods" --> listOf[(Id, Clause[ATerm])] {
              case (name, Clause(params, body)) => obj("name" --> raw(JsonPrettyPrinter.toDoc(name)),
                "params" --> listOf[Var] { x => raw(JsonPrettyPrinter.toDoc(x)) }(params),
                "body" --> raw(JsonPrettyPrinter.toDoc(body))
              )
            }(ms),
            "env" --> env.json
          )
          case VMany(els) => List(
            "type" --> "(many)".toJson,
            "elements" --> listOf[Value](_.vjson)(els)
          )
          case VUnit => List("type" --> "Unit".toJson)
          case VLabel(name) => List("type" --> "Label".toJson, "name" --> raw(JsonPrettyPrinter.toDoc(name)))
          case VCont(frames) => List("type" --> "Cont".toJson,
            "frames" --> listOf[Frame](_.json)(frames)
          )
          case VResumption(frames) => List("type" --> "Resumption".toJson,
            "frames" --> listOf[Frame](_.json)(frames)
          )
          case VExternPtr(value, tag) => List("type" --> "ExternPtr".toJson, "name" --> tag.toJson)
          case VDynLib(name, code, env) => List("type" --> "Lib".toJson,
            "name" --> name.toJson
          )
          case v: common.Concrete.VRef => List("type" --> "Ref".toJson, "id" --> v.id.json)
          case v: common.Concrete.VBox => List("type" --> "Box".toJson, "value" --> v.num.vjson)
          case v: common.Concrete.VRegion => List("type" --> "Region".toJson, "id" --> v.id.json)
        }
      }
    }
  }
  export Value.*
  sealed trait Result extends StepResult { def json(using util.StreamingJsonPrinter.SharingContext): rpyeffectasm.util.StreamingJsonPrinter }
  case class Returned(v: Value) extends Result {
    def json(using util.StreamingJsonPrinter.SharingContext): rpyeffectasm.util.StreamingJsonPrinter = {
      import rpyeffectasm.util.StreamingJsonPrinter.*
      obj("reason" --> "Returned".toJson, "value" --> v.vjson)
    }
  }
  enum Error extends Throwable with Result {
    case PrimitiveException(e: Primitives.PrimitiveException)
    case UnboundVar(v: Var, e: Env)
    case ApplyNonFunction(fn: Value)
    case IfZeroNonInt(v: Value)
    case ProjNonData(v: Value)
    case SwitchNonInt(v: Value)
    case ProjWrongTag(v: Value, expected: Id)
    case InvokeNonCoData(v: Value)
    case UnknownMethod(method: Id, v: Value)
    case UnboundPrompt(prompt: Value, stack: Stack)
    case UninitializedRec(v: Var)
    case UnboxNonDataToNum(v: Value)
    case UnknownPrimitive(name: String)
    case PrimitiveAtWrongTypes(name: String, expected: List[Type], got: List[Value])
    case Fatal
    def json(using util.StreamingJsonPrinter.SharingContext): rpyeffectasm.util.StreamingJsonPrinter = {
      import rpyeffectasm.util.StreamingJsonPrinter.*
      objL(List("reason" --> this.productPrefix.toJson) ++ (this match {
        case UnboundVar(x, env) => List("name" --> raw(JsonPrettyPrinter.toDoc(x)), "env" --> env.json)
        case UnboundPrompt(p, stack) => List("prompt" --> p.vjson, "stack" --> listOf[Frame](_.json)(stack))
        case UnknownPrimitive(name) => List("name" --> raw(JsonPrettyPrinter.toDoc(name)))
        case PrimitiveException(e) => List("msg" --> e.toString.toJson)
        case PrimitiveAtWrongTypes(name, expected, got) =>
          List(
            "name" --> name.toJson,
            "expectedTypes" --> listOf[Type]{ x => raw(JsonPrettyPrinter.toDoc(x)) }(expected),
            "got" --> listOf[Value](_.vjson)(got)
          )
        case UnboxNonDataToNum(v) => List(
          "value" --> v.vjson
        )
        case ProjWrongTag(v, t) => List(
          "expected" --> raw(JsonPrettyPrinter.toDoc(t)),
          "got" --> v.vjson
        )
        case ProjNonData(v) => List(
          "value" --> v.vjson
        )
        case ApplyNonFunction(fn) => List(
          "value" --> fn.vjson
        )
        case IfZeroNonInt(v) => List(
          "value" --> v.vjson
        )
        case InvokeNonCoData(v) => List(
          "value" --> v.vjson
        )
        case UninitializedRec(x) => List("var" --> raw(JsonPrettyPrinter.toDoc(x)))
        case _ => List("value" --> this.toString.toJson) // TODO
      }))
    }
  }

  def returns(state: State, v: Value)(using ErrorReporter): StepResult = {
    if (state.stack.isEmpty) {
      Returned(v)
    } else state.stack.head match {
      case FApp1(Nil, env) => v match {
        case lam@VLambda(lenv, Nil, body) =>
          state.copy(env = lenv, focused = body, stack = state.stack.tail)
        case fn =>
          throw Error.ApplyNonFunction(fn)
      }
      case FApp1(args, env) => state.pop().copy(focused = args.head).push(FApp2(v, env)).push(fMany(Nil, args.tail, env))
      case FApp2(lam@VLambda(lenv, params, body), env) =>
        state.copy(env = Env.Bind((params zip (v.many)).toMap, lenv), focused = body, stack = state.stack.tail)
      case FApp2(re@VResumption(cont), env) =>
        returns(state.copy(env = env, stack = cont.reverse ++ state.stack.tail), v.many.head)
      case FApp2(cd@VCoData(lenv, it, ms), env) if ms.exists{ case (m,_) => m == Name("apply") } =>
        returns(state.pop().push(FInvoke2(it, Name("apply"), cd)), v)
      case FApp2(fn, _) => Error.ApplyNonFunction(fn)
      case FMany(ev, next :: unev, env) => state.pop().push(fMany(ev :+ v, unev, env)).copy(focused = next, env = env)
      case FMany(ev, Nil, _) => returns(state.pop(), VMany(ev :+ v))
      case FSeq(Nil, _) => assert(false)
      case FSeq(List(t), env) => state.pop().copy(focused = t, env = env)
      case FSeq(t :: ts, env) => state.pop().push(FSeq(ts, env)).copy(focused = t, env = env)
      case FLet(names, env, body) =>
        state.pop().copy(focused = body, env = Env.Bind((names zip (v.many)).toMap, env))
      case FLetRec(names, eval, next :: uneval, env, body) =>
        env.bindings = (names zip ((v :: eval).reverse)).toMap
        env.bindings.foreach {
          case x -> v if !v.tpe.asMCore.isSubtypeOf(x.tpe) =>
            ErrorReporter.error(
              s"Type of variable\n  ${x}\nand value don't match in recursive binding:\n" +
                s"  ${v}\nis not a\n  ${x.tpe}."
            )
          case _ => ()
        }
        state.pop().push(FLetRec(names, v :: eval, uneval, env, body)).copy(focused = next, env = env)
      case FLetRec(names, eval, Nil, env, body) =>
        env.bindings = (names zip ((v :: eval).reverse)).toMap
        env.bindings.foreach{
          case x -> v if !v.tpe.asMCore.isSubtypeOf(x.tpe) =>
            ErrorReporter.error(
              s"Type of variable\n  ${x}\nand value don't match in recursive binding:\n" +
                s"  ${v}\nis not a\n  ${x.tpe}."
            )
          case _ => ()
        }
        state.pop().copy(focused = body, env = env)
      case FIfZero(thn, els, env) => v match {
        case VInt(0) => state.pop().copy(focused = thn, env = env)
        case VInt(_) => state.pop().copy(focused = els, env = env)
        case _ => Error.IfZeroNonInt(v)
      }
      case FProj(tt, t, f) => v match {
        case VData(ctt, ct, fs) if t == ct =>
          if(tt != ctt) { /* TODO warn */ }
          returns(state.pop(), fs(f))
        case _ => Error.ProjWrongTag(v, t)
      }
      case FMatch(tt, cs, dc, env) => v match {
        case VData(ctt, ct, fs) =>
          if(tt != ctt) { /* TODO warn */ }
          val c = cs.collectFirst{
            case (t, c) if t == ct => c
          }.getOrElse(dc)
          state.pop().copy(focused = c.body, env = Env.Bind((c.params zip fs).toMap, env))
        case _ => Error.ProjNonData(v)
      }
      case FSwitch(cases, default, env) => v match {
        case VInt(got) => cases.find{ case (Literal.Int(exp), _) => exp == got } match {
          case Some((_, t)) =>
            state.pop().copy(focused = t, env = env)
          case None =>
            state.pop().copy(focused = default, env = env)
        }
        case _ => Error.SwitchNonInt(v)
      }
      case FConstruct(tt, t) => returns(state.pop(), VData(tt, t, v.many))
      case FInvoke1(ifce_tag, method, Nil, env) =>
        returns(state.pop().push(FInvoke2(ifce_tag, method, v)), VMany(Nil))
      case FInvoke1(ifce_tag, method, args, env) =>
        state.pop().push(FInvoke2(ifce_tag, method, v)).push(fMany(Nil, args.tail, env)).copy(focused = args.head, env = env)
      case FInvoke2(ifce_tag, method, rcv) => rcv match {
        case VCoData(lenv, cit, methods) =>
          methods.collectFirst{
            case (t, m) if t == method =>
              state.pop().copy(focused = m.body, env = Env.Bind((m.params zip v.many).toMap, lenv))
          }.getOrElse{
            Error.UnknownMethod(method, rcv)
          }
        case _ => Error.InvokeNonCoData(v)
      }
      case FClause(Clause(params, body), env) =>
        v match {
          case v: VMany => state.pop().copy(focused = body, env = Env.Bind((params zip v.many).toMap, env))
          case v => state.pop().copy(focused = body, env = Env.Bind((params zip List(v)).toMap, env))
        }
      case FReset(region, body, ret, env) =>
        val vreg = new common.Concrete.VRegion()
        state.copy(focused = body)
          .pop()
          .push(Prompt(v, vreg))
          .push(FClause(ret, Env.Bind(Map(region -> vreg), env)))
      case Prompt(_,_) | Handler(_,_,_,_) | DHandler(_,_,_,_) | FNop => returns(state.pop(), v)
      case FShift1(n, k, body, retType, env) =>
        state.copy(focused = n.unroll, env = env).pop().push(FShift2(v, k, body, retType, env))
      case FShift2(label, k, body, retType, env) =>
        def go(cont: List[Frame], stack: List[Frame], lbl: Value, n: Int): (List[Frame], List[Frame]) = stack match {
          case (p @ Prompt(clbl, reg)) :: tail if clbl == lbl && n == 0 => reg.freeze(); (p :: cont, tail)
          case (p @ Prompt(clbl, reg)) :: tail if clbl == lbl => reg.freeze(); go(p :: cont, tail, lbl, n-1)
          case (p @ Prompt(_, reg)) :: tail => reg.freeze(); go(p :: cont, tail, lbl, n)
          case o :: tail => go(o :: cont, tail, lbl, n)
          case Nil => throw Error.UnboundPrompt(lbl, state.stack.tail)
        }
        val (cont, stack) = go(Nil, state.stack.tail, label, v match {
          case VInt(n) => n
          case _ => ???
        })
        state.copy(env =  Env.Bind(Map(k -> VCont(cont)), env), focused = body, stack = stack)
      case FControl1(n, k, body, retType, env) =>
        state.copy(focused = n.unroll, env = env).pop().push(FControl2(v, k, body, retType, env))
      case FControl2(label, k, body, retType, env) =>
        def go(cont: List[Frame], stack: List[Frame], lbl: Value, n: Int): (List[Frame], List[Frame]) = stack match {
          case (p@Prompt(clbl, reg)) :: tail if clbl == lbl && n == 0 => reg.freeze(); (cont, tail)
          case (p@Prompt(clbl, reg)) :: tail if clbl == lbl => reg.freeze(); go(p :: cont, tail, lbl, n - 1)
          case (o@Prompt(_, reg)) :: tail => reg.freeze(); go(o :: cont, stack, lbl, n)
          case o :: tail => go(o :: cont, stack, lbl, n)
          case Nil => throw Error.UnboundPrompt(lbl, state.stack.tail)
        }

        val (cont, stack) = go(Nil, state.stack.tail, label, v match {
          case VInt(n) => n
          case _ => ???
        })
        state.copy(env = Env.Bind(Map(k -> VCont(cont)), env), focused = body, stack = stack)
      case FResume1(args, env) =>
        state.pop().copy(focused = args.head, env = env)
          .push(FResume2(v))
          .push(fMany(Nil, args.tail, env))
      case FResume2(cont) => cont match {
        case VCont(frames) =>
          val stack = frames.reverse ++ state.stack.tail
          assert(v.many.length == 1)
          returns(state.copy(stack = stack), v.many.head)
        case _ => ???
      }
      case FResumed(body, env) => v match {
        case VCont(frames) =>
          val stack = frames.reverse ++ state.stack.tail
          state.copy(env = env, focused = body, stack = stack)
        case _ => ???
      }

      case FLetRef1(ref, init, body, env) =>
        v match {
          case reg: common.Concrete.VRegion =>
            state.copy(focused = init).pop().push(FLetRef2(ref, reg, body, env))
          case _ => ???
        }
      case FLetRef2(ref, reg, body, env) =>
        val r = new common.Concrete.VRef(v)
        reg.refs.addOne(r)
        state.pop().copy(focused = body, env = Env.Bind(Map(ref -> r), env))

      case FOp(tag, op, k) =>
        def go(cont: List[Frame], stack: List[Frame], tag: Id): (List[Frame], List[Frame], (Clause[ATerm], Env)) = stack match {
          case (h@Handler(HandlerSugar.HandlerType.Deep, ctag, handlers, env)) :: tail if ctag == tag =>
            (h :: cont, tail, handlers.collectFirst {
              case (opTag, cls) if opTag == op => (cls, env)
            }.get)
          case (h@Handler(HandlerSugar.HandlerType.Shallow, ctag, handlers, env)) :: tail if ctag == tag =>
            (cont, tail, handlers.collectFirst {
              case (opTag, cls) if opTag == op => (cls, env)
            }.get)
          case o :: tail => go(o :: cont, tail, tag)
          case Nil => ???
        }

        val (cont, stack, (handler, henv)) = go(Nil, state.stack.tail, tag)
        state.copy(env = Env.Bind((handler.params zip (VResumption(cont) :: v.many)).toMap, henv), focused = handler.body, stack = FClause(k, state.env) :: stack)
      case FDHandle(tpe, handlers, body, ret, env) =>
        val s = state.copy(focused = body)
          .pop()
          .push(DHandler(tpe, v, handlers, env))
        if ret.isEmpty then s else s.push(FClause(ret.get, env))
      case FDOp(op, k) =>
        val tag :: args = v.many : @unchecked

        def go(cont: List[Frame], stack: List[Frame], tag: Value): (List[Frame], List[Frame], (Clause[ATerm], Env)) = stack match {
          case (h@DHandler(DynamicHandlerSugar.HandlerType.Deep, ctag, handlers, env)) :: tail if ctag == tag =>
            (h :: cont, tail, handlers.collectFirst {
              case (opTag, cls) if opTag == op => (cls, env)
            }.get)
          case (h@DHandler(DynamicHandlerSugar.HandlerType.Shallow, ctag, handlers, env)) :: tail if ctag == tag =>
            (cont, tail, handlers.collectFirst {
              case (opTag, cls) if opTag == op => (cls, env)
            }.get)
          case o :: tail => go(o :: cont, tail, tag)
          case Nil => ???
        }

        val (cont, stack, (handler, henv)) = go(Nil, state.stack.tail, tag)
        state.copy(env = Env.Bind((handler.params zip (VResumption(cont) :: args)).toMap, henv), focused = handler.body, stack = FClause(k, state.env) :: stack)
      case FLoadLib =>
        v match {
          case v: Value.VString =>
            if (state.libs.contains(v.value)) { return returns(state.pop(), state.libs(v.value)) } else {
              loader.loadLib(v.value) match {
                case Some(origp) =>
                  val libStmt = Literal.Injected(Base.Injected[Value](), null)
                  val p = SpecializeLib(libStmt)(origp)
                  val libEnv: Env.BindRec = Env.BindRec(p.definitions.map(_.name).toSet, Map.empty, Env.Toplevel)
                  val lib = VDynLib(v.value, p, libEnv)
                  libStmt.value = lib
                  val next = p.definitions.find(_.exportAs.contains("$static-init")) match {
                    case Some(si) =>
                      state.pop().copy(env = libEnv, focused = p.definitions.head.binding)
                        .push(FLetRec(p.definitions.map(_.name), Nil, p.definitions.tail.map(_.binding), libEnv,
                          App(si.name, List(Literal.Injected(Base.Injected[VDynLib[ATerm]](), lib)))))
                    case None => state.pop()
                      state.pop().copy(env = libEnv, focused = p.definitions.head.binding)
                        .push(FLetRec(p.definitions.map(_.name), Nil, p.definitions.tail.map(_.binding), libEnv,
                          Literal.Injected(Base.Injected[VDynLib[ATerm]](), lib)))
                  }
                  return next
                case None => returns(state.pop(), VUnit)
              }
            }
          case _ => ???
        }
      case FCallLib1(symbol, args, retType) =>
        v match {
          case v: VDynLib[ATerm] =>
            state.pop().push(FCallLib2(v, symbol, retType)).push(fMany(Nil, args.tail, state.env)).copy(focused = args.head)
          case _ =>
            ???
        }
      case FCallLib2(lib, symbol, retType) =>
        val args = v.many
        lib.code.definitions.find(_.exportAs.contains(symbol)) match {
          case Some(d) =>
            state.pop().copy(env = lib.lenv, focused = App(d.name, args.map(Literal.Injected(Base.Injected[Value](), _))))
          case None => ???
        }
      case FQualified(symbol, tpe) =>
        v match {
          case lib: VDynLib[ATerm] =>
            lib.code.definitions.find(_.exportAs.contains(symbol)) match {
              case Some(d) =>
                state.pop().copy(env = lib.lenv, focused = d.name)
              case None => ???
            }
        }
      case FPrimitive(name) => returns(state.pop(), VMany((name, v.many) match {
        case ("infixSub(Int, Int): Int", List(VInt(i), VInt(j))) => List(VInt(i - j))
        case ("infixAdd(Int, Int): Int", List(VInt(i), VInt(j))) => List(VInt(i + j))
        case ("infixMul(Int, Int): Int", List(VInt(i), VInt(j))) => List(VInt(i * j))
        case ("infixDiv(Int, Int): Int", List(VInt(i), VInt(j))) => List(VInt(i / j))
        case ("infixGte(Int, Int): Boolean", List(VInt(i), VInt(j))) => List(VInt(if i >= j then 1 else 0))
        case ("println(Int): Unit", List(VInt(i))) => println(i); List(VUnit)
        case ("println(String): Unit", List(VString(s))) => println(s); List(VUnit)
        case ("ptr_eq", List(x, y)) => List(VInt(if x == y then 1 else 0))
        case _ =>
          Primitives.primitives.collectFirst {
            case Primitives.PrimitiveInfo(`name`, insT, outsT, _) if insT.length == v.many.length =>
              import rpyeffectasm.common.Primitives
              val concreteTypes = v.many.map(_.tpe)
              if (!(concreteTypes zip insT).forall {
                case (common.ExternPtr("Box"),e) if e.asMCore.isSubtypeOf(Num) => true
                case (g, e) => g.asMCore.isSubtypeOf(e.asMCore)
              }) {
                  throw Error.PrimitiveAtWrongTypes(name, insT.map(_.asMCore), v.many)
              }
              Primitives.run(name, (v.many zip insT).map {
                case (common.Concrete.VBox(v), e) if e.asMCore.isSubtypeOf(Num) => v
                case (v, e) => v
              })
          } match {
            case Some(v) => v
            case None =>
              throw Error.UnknownPrimitive(name)
          }
      }))
    }
  }
  def step(state: State)(using ErrorReporter): StepResult = state.focused match {
    case v@Var(name, tpe) => state.env.lookup(v).map(returns(state,_)).getOrElse{ Error.UnboundVar(v, state.env) }
    case Abs(params, body) => returns(state, VLambda(state.env, params, body))
    case App(fn, args) => state.copy(focused = fn).push(FApp1(args, state.env))
    case Seq(Nil) => returns(state, VUnit)
    case Seq(List(t)) => state.copy(focused = t)
    case Seq(ts) => state.copy(focused = ts.head).push(FSeq(ts.tail, state.env))
    case Let(Nil, body) => state.copy(focused = body)
    case Let(defs, body) => state.copy(focused = defs.head.binding)
      .push(FLet(defs.map(_.name), state.env, body))
      .push(fMany(Nil, defs.tail.map(_.binding), state.env))
    case LetRec(Nil, body) => state.copy(focused = body)
    case LetRec(defs, body) =>
      val innerEnv: Env.BindRec = Env.BindRec(defs.map(_.name).toSet, Map.empty, state.env)
      state.copy(focused = defs.head.binding, env = innerEnv)
        .push(FLetRec(defs.map(_.name), Nil, defs.tail.map(_.binding), innerEnv, body))
    case IfZero(cond, thn, els) => state.copy(focused = cond.unroll).push(FIfZero(thn, els, state.env))
    case Construct(tpe_tag, tag, Nil) => returns(state.push(FConstruct(tpe_tag, tag)), VMany(Nil))
    case Construct(tpe_tag, tag, args) => state.copy(focused = args.head)
      .push(FConstruct(tpe_tag, tag))
      .push(fMany(Nil, args.tail, state.env))
    case Project(scrutinee, tpe_tag, tag, field) => state.copy(focused = scrutinee).push(FProj(tpe_tag, tag, field))
    case Match(scrutinee, tpe_tag, clauses, default_clause) =>
      state.copy(focused = scrutinee.unroll).push(FMatch(tpe_tag, clauses, default_clause, state.env))
    case Switch(scrutinee, cases, default) =>
      state.copy(focused = scrutinee.unroll).push(FSwitch(cases, default, state.env))
    case New(ifce_tag, methods) => returns(state, VCoData(state.env, ifce_tag, methods))
    case Invoke(receiver, ifce_tag, method, args) => state.copy(focused = receiver).push(FInvoke1(ifce_tag, method, args, state.env))
    case LetRef(ref, region, binding, body) =>
      state.copy(focused = region.unroll).push(FLetRef1(ref, binding.unroll, body, state.env))
    case Load(ref) => ???
    case Store(ref, value) => ???
    case FreshLabel() => returns(state, VLabel(new Generated("fresh-label")))
    case Reset(label, region, bnd, body, ret) =>
      // TODO bnd
      state.copy(focused = label.unroll).push(FReset(region, body, ret, state.env))
    case Shift(label, n, k, body, retTpe) =>
      state.copy(focused = label.unroll).push(FShift1(n, k, body, retTpe, state.env))
    case Control(label, n, k, body, retTpe) =>
      state.copy(focused = label.unroll).push(FControl1(n, k, body, retTpe, state.env))
    case Resume(cont, args) =>
      state.copy(focused = cont)
        .push(FResume1(args, state.env))
    case Resumed(cont, body) =>
      state.copy(focused = cont.unroll)
        .push(FResumed(body, state.env))
    case Primitive(name, Nil, rets, rest) =>
      returns(
        state
          .push(FClause(Clause(rets, rest), state.env))
          .push(FPrimitive(name)),
        VMany(Nil))
    case Primitive(name, args, returns, rest) =>
      state.copy(focused = args.head.unroll)
        .push(FClause(Clause(returns, rest), state.env))
        .push(FPrimitive(name))
        .push(fMany(Nil, args.tail.map(_.unroll), state.env))
    case LoadLib(path) =>
      state.copy(focused = path.unroll).push(FLoadLib)
    case CallLib(lib, symbol, args, returnType) =>
      state.copy(focused = lib.unroll).push(FCallLib1(symbol, args.map(_.unroll), returnType))
    case ThisLib() => ???
    case Qualified(lib, name, tpe) =>
      state.copy(focused = lib.unroll).push(FQualified(name, tpe))
    case literal: Literal => literal match {
      case Literal.Int(n: Int) => returns(state, VInt(n))
      case Literal.Label => returns(state, VLabel(Index(0)))
      case Literal.String(str: String) => returns(state, VString(str))
      case Literal.StringWithFormat(str, "path") =>
        returns(state, VString(str.replace("$0", ".")))
      case Literal.Unit => returns(state, VUnit)
      case Literal.Injected(_, value) => returns(state, value.asInstanceOf[Value])
      case _ => ???
    }
    case DebugWrap(inner, annotations) =>
      state.copy(focused = inner)
    case sugar: Sugar => sugar match {
      case HandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
        val s = state.copy(focused = body)
          .push(Handler(tpe, tag, handlers, state.env))
        if ret.isEmpty then s else s.push(FClause(ret.get, state.env))
      case HandlerSugar.Op(tag, op, args, k, rtpe) =>
        state.copy(focused = args.head).push(FOp(tag, op, k)).push(fMany(Nil, args.tail, state.env))
      case DynamicHandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
        state.copy(focused = tag).push(FDHandle(tpe, handlers, body, ret, state.env))
      case DynamicHandlerSugar.Op(tag, op, args, k, rtpe) =>
        state.copy(focused = tag)
          .push(FDOp(op, k))
          .push(fMany(Nil, args, state.env))
    }
  }

  case class InterpreterResult(trace: List[State], end: Result, errors: List[rpyeffectasm.util.Error]) {
    def json = {
      import rpyeffectasm.util.StreamingJsonPrinter.*
      allowSharing {
        obj(
          "result" --> end.json,
          "errors" --> listOf[util.Error] { x => raw(x.json) }(errors),
          "trace" --> listOf[State](_.json)(trace)
        )
      }
    }
  }
  def apply(p: Program[ATerm]): InterpreterResult = {
    import rpyeffectasm.util.ErrorReporter.ResultWithCollectedErrors
    val innerEnv: Env.BindRec = Env.BindRec(p.definitions.map(_.name).toSet, Map.empty, Env.Toplevel)
    val dynlib = Value.VDynLib(filename, p, innerEnv)
    val symbols = p.definitions.flatMap { d =>
      d.exportAs.map { s =>
        (s, (dynlib, d.name))
      }
    }.toMap
    var cur: StepResult = if (p.definitions.isEmpty) {
      State(Env.Toplevel, p.main, Nil, symbols, Map.empty)
    } else {
      State(Env.Toplevel, p.definitions.head.binding, Nil, symbols, Map.empty)
        .push(FLetRec(p.definitions.map(_.name), Nil, p.definitions.tail.map(_.binding), innerEnv, p.main))
    }
    val trace: mutable.ListBuffer[State] = mutable.ListBuffer()
    ErrorReporter.collectErrors {
      while (!cur.isInstanceOf[Result]) {
        trace.addOne(cur.asInstanceOf[State])
        cur = (try {
          ErrorReporter.withLocation(s"step ${trace.length-1}") {
            print(".")
            step(cur.asInstanceOf[State])
          }
        } catch {
          case e: Error => e
          case e: common.Primitives.PrimitiveException =>
            Error.PrimitiveException(e)
        })
      }
    } match {
      case ResultWithCollectedErrors.OK((), errors) =>
        println(if errors.isEmpty then "V" else "v")
        InterpreterResult(trace.toList, cur.asInstanceOf[Result], errors)
      case ResultWithCollectedErrors.Fatal(errors) =>
        println("x")
        cur match {
          case st: State =>
            InterpreterResult(trace.toList :+ st, Error.Fatal, errors)
          case result: Result =>
            InterpreterResult(trace.toList, result, errors)
        }
    }
  }

}
