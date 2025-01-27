package rpyeffectasm.mcore
import rpyeffectasm.util
import rpyeffectasm.util.{Phase, Output, Target, JsonPrinter, ErrorReporter}
import scala.collection.immutable.ListMap
import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}

object JsonPrettyPrinter extends JsonPrinter with Phase[Program[ATerm], Output] {

  def toDoc(s: String) = s"\"${util.escape(s)}\""


  def toDoc(id: Id): Doc = id match {
    case Name(name) => toDoc(name)
    case Index(i) => i.toString
    case generated: Generated => s"\"##[${util.escape(generated.name)}]\""
  }
  def toDoc(m: Method): Doc = m match {
    case Method(tag, params, ret) => jsonObjectSmall(ListMap(
      "tag" -> toDoc(tag),
      "params" -> jsonListSmall(params map toDoc),
      "return" -> toDoc(ret)
    ))
  }
  def toDoc(c: Constructor): Doc = c match {
    case Constructor(tag, fields) => jsonObjectSmall(ListMap(
      "tag" -> toDoc(tag),
      "fields" -> jsonListSmall(fields map toDoc)
    ))
  }
  def objName(x: Any) = x.getClass.getSimpleName.replace("$", "")
  def toDoc(t: Type): Doc = jsonObjectSmall(t match {
    case Top | Ptr | Num | Bottom => ListMap("op" -> s"\"${objName(t)}\"")
    case base@Base.Label(at, None) =>
      ListMap("op" -> s"\"${objName(base)}\"",
        "at" -> toDoc(at)
      )
    case base@Base.Label(at, Some(bnd)) =>
      ListMap("op" -> s"\"${objName(base)}\"",
        "at" -> toDoc(at),
        "binding" -> toDoc(bnd)
      )
    case base: Base => ListMap("op" -> s"\"${objName(base)}\"")
    case Function(params, ret, purity) =>
      ListMap("op" -> "\"Function\"",
        "params" -> jsonList(params map toDoc),
        "return" -> toDoc(ret),
        "purity" -> s"\"${purity.toString}\"")
    case Codata(ifce_tag, methods) =>
      ListMap("op" -> "\"Codata\"",
        "interface_tag" -> toDoc(ifce_tag),
        "methods" -> jsonListSmall(methods map toDoc))
    case Data(type_tag, constructors) =>
      ListMap("op" -> "\"Data\"",
        "type_tag" -> toDoc(type_tag),
        "constructors" -> jsonListSmall(constructors map toDoc))
    case Stack(resume_ret, resume_args) =>
      ListMap("op" -> "\"Stack\"",
        "resume_return" -> toDoc(resume_ret),
        "resume_args" -> jsonListSmall(resume_args map toDoc))
    case Ref(to) => ListMap("op" -> "\"Ref\"", "to" -> toDoc(to))
  })
  def toDoc(l: LhsOperand): Doc = l match {
    case Var(name, tpe) => jsonObjectSmall(ListMap("id" -> toDoc(name), "type" -> toDoc(tpe)))
  }
  def toDoc(t: Term[ATerm]): Doc = t match {
    case Var(name, tpe) => jsonObjectSmall(ListMap(
      "op" -> "\"Var\"",
      "id" -> toDoc(name),
      "type" -> toDoc(tpe)))
    case Abs(params, body) => jsonObject(ListMap(
      "op" -> "\"Abs\"",
      "params" -> jsonListSmall(params map toDoc),
      "body" -> toDoc(body)))
    case App(fn, args) => jsonObjectSmall(ListMap(
      "op" -> "\"App\"",
      "fn" -> toDoc(fn),
      "args" -> jsonListSmall(args map toDoc)
    ))
    case Seq(ts) => jsonObject(ListMap(
      "op" -> "\"Seq\"",
      "elems" -> jsonList(ts map toDoc)
    ))
    case Let(defs, body) => jsonObject(ListMap(
      "op" -> "\"Let\"",
      "definitions" -> jsonList(defs map toDoc),
      "body" -> toDoc(body)
    ))
    case LetRec(defs, body) => jsonObject(ListMap(
      "op" -> "\"LetRec\"",
      "definitions" -> jsonList(defs map toDoc),
      "body" -> toDoc(body)
    ))
    case IfZero(cond, thn, els) => jsonObject(ListMap(
      "op" -> "\"IfZero\"",
      "cond" -> toDoc(cond.unroll),
      "then" -> toDoc(thn),
      "else" -> toDoc(els)
    ))
    case Construct(tpe_tag, tag, args) => jsonObjectSmall(ListMap(
      "op" -> "\"Construct\"",
      "type_tag" -> toDoc(tpe_tag),
      "tag" -> toDoc(tag),
      "args" -> jsonListSmall(args map toDoc)
    ))
    case Project(scrutinee, tpe_tag, tag, field) => jsonObjectSmall(ListMap(
      "op" -> "\"Project\"",
      "scrutinee" -> toDoc(scrutinee),
      "type_tag" -> toDoc(tpe_tag),
      "tag" -> toDoc(tag),
      "field" -> s"${field}"
    ))
    case Match(scrutinee, tpe_tag, clauses, Clause(dparams, dbody)) => jsonObject(ListMap(
      "op" -> "\"Match\"",
      "scrutinee" -> toDoc(scrutinee.unroll),
      "type_tag" -> toDoc(tpe_tag),
      "clauses" -> jsonList(clauses map { case (t, Clause(params, body)) =>
          jsonObject(ListMap("tag" -> toDoc(t),
            "params" -> jsonListSmall(params map toDoc),
            "body" -> toDoc(body)))
      }),
      "default_clause" -> jsonObject(ListMap("params" -> jsonListSmall(dparams map toDoc), "body" -> toDoc(dbody)))
    ))
    case Switch(scrutinee, cases, default) => jsonObject(ListMap(
      "op" -> "\"Switch\"",
      "scrutinee" -> toDoc(scrutinee.unroll),
      "cases" -> jsonList(cases map { case (v, t) =>
        jsonObject(ListMap("value" -> s"${v}", "then" -> toDoc(t)))}),
      "default" -> toDoc(default)
    ))
    case New(ifce_tag, methods) => jsonObject(ListMap("op" -> "\"New\"",
      "ifce_tag" -> toDoc(ifce_tag),
      "methods" -> jsonList(methods map { case (t, Clause(params, body)) =>
        jsonObject(ListMap("tag" -> toDoc(t),
          "params" -> jsonListSmall(params map toDoc),
          "body" -> toDoc(body)))
      })
    ))
    case Invoke(receiver, ifce_tag, method, args) => jsonObjectSmall(ListMap(
      "op" -> "\"Invoke\"",
      "receiver" -> toDoc(receiver.unroll),
      "ifce_tag" -> toDoc(ifce_tag),
      "tag" -> toDoc(method),
      "args" -> jsonListSmall(args map toDoc)
    ))
    case LetRef(ref, region, binding, body) => jsonObject(ListMap(
      "op" -> "\"LetRef\"",
      "ref" -> toDoc(ref),
      "region" -> toDoc(region.unroll),
      "binding" -> toDoc(binding.unroll),
      "body" -> toDoc(body)
    ))
    case Load(ref) => jsonObjectSmall(ListMap("op" -> "\"Load\"", "ref" -> toDoc(ref)))
    case Store(ref, value) => jsonObjectSmall(ListMap("op" -> "\"Store\"", "ref" -> toDoc(ref), "value" -> toDoc(value)))
    case FreshLabel() => jsonObjectSmall(ListMap("op" -> "\"FreshLabel\""))
    case Reset(label, region, None, body, Clause(rparams, rbody)) => jsonObject(ListMap("op" -> "\"Reset\"",
      "label" -> toDoc(label.unroll),
      "region" -> toDoc(region),
      "body" -> toDoc(body),
      "return" -> jsonObject(ListMap("params" -> jsonListSmall(rparams map toDoc), "body" -> toDoc(rbody)))))
    case Reset(label, region, Some(bnd), body, Clause(rparams, rbody)) => jsonObject(ListMap("op" -> "\"Reset\"",
      "label" -> toDoc(label.unroll),
      "region" -> toDoc(region),
      "binding" -> toDoc(bnd.unroll),
      "body" -> toDoc(body),
      "return" -> jsonObject(ListMap("params" -> jsonListSmall(rparams map toDoc), "body" -> toDoc(rbody)))))
    case Shift(label, n, k, body, tpe) => jsonObject(ListMap("op" -> "\"Shift\"",
      "label" -> toDoc(label.unroll),
      "n" -> toDoc(n.unroll),
      "k" -> toDoc(k),
      "returnType" -> toDoc(tpe),
      "body" -> toDoc(body)))
    case Control(label, n, k, body, tpe) => jsonObject(ListMap("op" -> "\"Control\"",
      "label" -> toDoc(label.unroll),
      "n" -> toDoc(n.unroll),
      "k" -> toDoc(k),
      "returnType" -> toDoc(tpe),
      "body" -> toDoc(body)))
    case Resume(cont, args) => jsonObjectSmall(ListMap("op" -> "\"Resume\"", "k" -> toDoc(cont), "args" -> jsonListSmall(args map toDoc)))
    case Resumed(cont, body) => jsonObjectSmall(ListMap("op" -> "\"Resumed\"", "k" -> toDoc(cont.unroll), "body" -> toDoc(body)))
    case GetDynamic(label, n) => jsonObjectSmall(ListMap("op" -> "\"GetDynamic\"", "label" -> toDoc(label.unroll), "n" -> toDoc(n.unroll)))
    case Primitive(name, args, returns, rest) => jsonObject(ListMap("op" -> "\"Primitive\"",
      "name" -> toDoc(name),
      "args" -> jsonListSmall(args map { a => toDoc(a.unroll) }),
      "returns" -> jsonListSmall(returns map toDoc),
      "rest" -> toDoc(rest)
    ))
    case literal: Literal => jsonObjectSmall(ListMap("op" -> "\"Literal\"", "type" -> toDoc(literal.tpe)) ++ (literal match {
      case Literal.Int(v) => ListMap("value" -> s"${v}")
      case Literal.Bool(v) => ListMap("value" -> v.toString)
      case Literal.Double(v) => ListMap("value" -> s"${v}")
      case Literal.String(s) => ListMap("value" -> s"\"${rpyeffectasm.util.escape(s)}\"") // TODO escape
      case Literal.StringWithFormat(s, f) => ListMap("value" -> toDoc(s), "format" -> toDoc(f))
      case Literal.Label => ListMap("value" -> "\"null\"") // will be ignored by parser
      case Literal.Unit => ListMap("value" -> "\"unit\"") // will be ignored by parser
      case Literal.Injected(tpe, value) => ListMap("injected" -> "true",
        "value" -> s"\"${rpyeffectasm.util.escape(value.toString)}\""
      )
    }))
    case HandlerSugar.Handle(tpe, tag, handlers, ret, body) => jsonObject(ListMap("op" -> "\"Handle\"",
      "tpe" -> s"\"${tpe.productPrefix}\"",
      "tag" -> toDoc(tag),
      "handlers" -> jsonList(handlers map { case (t, v) => jsonObjectSmall(ListMap(
        "tag" -> toDoc(t), "params" -> jsonListSmall(v.params map toDoc), "body" -> toDoc(v.body)))
      }),
      "body" -> toDoc(body)
    ) ++ ret.map{ r => "ret" -> toDoc(r) }.toList)
    case HandlerSugar.Op(tag, op, args, k, rtpe) => jsonObject(ListMap("op" -> "\"Op\"",
      "tag" -> toDoc(tag),
      "op_tag" -> toDoc(op),
      "args" -> jsonListSmall(args map toDoc),
      "k" -> toDoc(k),
      "rtpe" -> toDoc(rtpe)
    ))
    case DynamicHandlerSugar.Handle(tpe, tag, handlers, ret, body) => jsonObject(ListMap("op" -> "\"DHandle\"",
      "tpe" -> s"\"${tpe.productPrefix}\"",
      "tag" -> toDoc(tag),
      "handlers" -> jsonList(handlers map { case (t, v) => jsonObjectSmall(ListMap(
        "tag" -> toDoc(t), "params" -> jsonListSmall(v.params map toDoc), "body" -> toDoc(v.body)))
      }),
      "body" -> toDoc(body)
    ) ++ ret.map { r => "ret" -> toDoc(r) }.toList)
    case DynamicHandlerSugar.Op(tag, op, args, k, rtpe) => jsonObject(ListMap("op" -> "\"DOp\"",
      "tag" -> toDoc(tag),
      "op_tag" -> toDoc(op),
      "args" -> jsonListSmall(args map toDoc),
      "k" -> toDoc(k),
      "rtpe" -> toDoc(rtpe)
    ))
    case DebugWrap(inner, annotation) => jsonObject(ListMap("op" -> "\"DebugWrap\"",
      "annotation" -> toDoc(annotation),
      "inner" -> toDoc(inner)
    ))
    case LoadLib(path) => jsonObject(ListMap("op" -> "\"LoadLib\"",
      "path" -> toDoc(path.unroll)
    ))
    case CallLib(lib, symbol, args, returnType) => jsonObject(ListMap("op" -> "\"CallLib\"",
      "lib" -> toDoc(lib.unroll),
      "symbol" -> toDoc(symbol),
      "args" -> jsonListSmall(args.map{ a => toDoc(a.unroll) }),
      "return_type" -> toDoc(returnType)
    ))
    case Qualified(l,n,t) => jsonObject(ListMap("op" -> "\"Qualified\"",
      "lib" -> toDoc(l),
      "name" -> toDoc(n),
      "type" -> toDoc(t)
    ))
    case AlternativeFail => jsonObjectSmall(ListMap("op" -> "\"AlternativeFail\""))
    case AlternativeChoice(choices) => jsonObject(ListMap("op" -> "\"AlternativeChoice\"",
      "choices" -> jsonList(choices map toDoc)
    ))
    case The(tp, t) => jsonObjectSmall(ListMap("op" -> "\"The\"", "type" -> toDoc(tp), "term" -> toDoc(t)))
    case ThisLib() => jsonObjectSmall(ListMap("op" -> "\"ThisLib\""))
  }
  def toDoc(c: Clause[ATerm]): Doc = c match {
    case Clause(params, body) =>
      jsonObject(ListMap(
        "params" -> jsonListSmall(params map toDoc),
        "body" -> toDoc(body)))
  }
  def toDoc(d: Definition[ATerm]): Doc = d match {
    case Definition(name, binding, exportAs) => jsonObject(ListMap(
      "name" -> toDoc(name), 
      "value" -> toDoc(binding), 
      "export_as" -> jsonListSmall(exportAs.map(toDoc))))
  }
  def toDoc(p: Program[ATerm]): Doc = p match {
    case Program(definitions, main) =>
      jsonObject(ListMap("definitions" -> jsonList(definitions map toDoc), "main" -> toDoc(main)))
  }
  override def apply(f: Program[ATerm])(using ErrorReporter): Output = new Output {
    override def emitTo[T](t: Target[T]): T = t.fromString(toDoc(f))
  }
}
