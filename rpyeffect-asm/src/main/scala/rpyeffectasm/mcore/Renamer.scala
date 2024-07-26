package rpyeffectasm.mcore
import scala.collection.mutable

/** Renames all Generated symbols to Names deterministically as gen0,gen1,... For testing. */
class Renamer[O <: ATerm] {

  import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}

  case class State(var nextIndex: Int, symbols: mutable.Map[Generated, Int]) {
    def apply(g: Generated): Int = {
      symbols.getOrElseUpdate(g, {
        val r = nextIndex
        nextIndex = nextIndex + 1
        r
      })
    }
  }
  def apply(i: Id)(using S: State): Name | Index = i match {
    case g: Generated => Name(s"gen${S(g)}")
    case other: (Name | Index) => other
  }
  def apply(tpe: Type)(using S: State): Type = tpe match {
    case Function(params, ret, purity) =>
      Function(params map apply, apply(ret), purity)
    case Codata(ifce_tag, methods) => Codata(apply(ifce_tag), methods.map{
      case Method(tag, params, ret) => Method(apply(tag), params map apply, apply(ret))
    })
    case Data(type_tag, constructors) => Data(apply(type_tag), constructors.map{
      case Constructor(tag, fields) => Constructor(apply(tag), fields map apply)
    })
    case Ref(to) => Ref(apply(to))
    case other => other
  }
  def apply(lhs: LhsOperand)(using S: State): LhsOperand = lhs match {
    case Var(name, tpe) => Var(apply(name), apply(tpe))
  }
  def apply[OO <: ATerm](x: (Id, Clause[OO]))(using State): (Id, Clause[OO]) = x match {
    case (t, c) => (apply(t), apply(c))
  }
  def apply[OO <: ATerm](c: Clause[OO])(using State): Clause[OO] = c match {
    case Clause(params, body) => Clause(params map apply, apply(body))
  }
  def applyO[OO <: ATerm](t: OO)(using S: State): Term[OO] & OO = apply(t.unroll) match {
    case r: OO => r.asInstanceOf[Term[OO] & OO] // FIXME
    case _ => assert(false, "Renamer preserves type parameters of Term")
  }

  def apply[OO <: ATerm](t: Term[OO])(using S: State): Term[OO] = t match { // TODO complete; straightforward
    case Var(name, tpe) => Var(apply(name), apply(tpe))
    case Abs(params, body) => Abs(params map applyO, apply(body))
    case App(fn, args) => App(applyO(fn), args map applyO)
    case Seq(ts) => Seq(ts map apply)
    case Let(defs, body) => Let(defs map apply, apply(body))
    case LetRec(defs, body) => LetRec(defs map apply, apply(body))
    case IfZero(cond, thn, els) => IfZero(applyO(cond), apply(thn), apply(els))
    case Construct(tpe_tag, tag, args) => Construct(apply(tpe_tag), apply(tag), args map applyO)
    case Project(scrutinee, tpe_tag, tag, field) => Project(applyO(scrutinee), apply(tpe_tag), apply(tag), field)
    case Match(scrutinee, tpe_tag, clauses, default) => Match(applyO(scrutinee), apply(tpe_tag), clauses map apply, apply(default))
    case Switch(scrutinee, cases, default) => Switch(applyO(scrutinee), cases.map{ case (v, t) => (v, apply(t))}, apply(default))
    case New(ifce_tag, methods) => New(apply(ifce_tag), methods map apply)
    case Invoke(receiver, ifce_tag, method, args) => Invoke(applyO(receiver), apply(ifce_tag), apply(method), args map applyO)
    case LetRef(ref, region, binding, body) => LetRef(apply(ref), applyO(region), applyO(binding), apply(body))
    case Load(ref) => Load(applyO(ref))
    case Store(ref, value) => Store(applyO(ref), applyO(value))
    case FreshLabel() => FreshLabel()
    case Reset(label, region, bnd, body, ret) => Reset(applyO(label), apply(region), bnd.map(applyO), apply(body), apply(ret))
    case Shift(label, n, k, body, retTpe) => Shift(applyO(label), applyO(n), apply(k), apply(body), apply(retTpe))
    case Control(label, n, k, body, retTpe) => Control(applyO(label), applyO(n), apply(k), apply(body), apply(retTpe))
    case Primitive(name, args, returns, rest) => Primitive(name, args map applyO, returns map apply, apply(rest))
    case l: Literal => l
    case Resume(cont, args) => Resume(applyO(cont), args map applyO)
    case Resumed(cont, body) => Resumed(applyO(cont), apply(body))
    case HandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      HandlerSugar.Handle(tpe, apply(tag), handlers map { case (t, h) => (apply(t), apply(h)) }, ret.map(apply), apply(body))
    case HandlerSugar.Op(tag, op, args, k, rtpe) =>
      HandlerSugar.Op(apply(tag), apply(op), (args map { a => apply(a.unroll) }), apply(k), apply(rtpe))
    case DynamicHandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      DynamicHandlerSugar.Handle(tpe, apply(tag), handlers map { case (t, h) => (apply(t), apply(h)) }, ret.map(apply), apply(body))
    case DynamicHandlerSugar.Op(tag, op, args, k, rtpe) =>
      DynamicHandlerSugar.Op(apply(tag), apply(op), (args map { a => apply(a.unroll) }), apply(k), apply(rtpe))
    case DebugWrap(inner, annotations) =>
      DebugWrap(apply(inner), annotations)
    case LoadLib(path) => LoadLib(applyO(path))
    case CallLib(lib, symbol, args, returnType) => CallLib(applyO(lib), symbol, args map applyO, apply(returnType))
    case Qualified(lib, qualified_name, tpe) => Qualified(applyO(lib), qualified_name, apply(tpe))
    case AlternativeChoice(choices) => AlternativeChoice(choices map apply)
    case AlternativeFail => AlternativeFail
    case ThisLib() => ThisLib()
    case The(tpe, term) => The(apply(tpe), apply(term))
    case GetDynamic(label, n) => GetDynamic(applyO(label), applyO(n))
  }
  def apply[OO <: ATerm](d: Definition[OO])(using S: State): Definition[OO] = d match {
    case Definition(name, binding, exportAs) => Definition(apply(name), apply(binding), exportAs)
  }
  def apply(p: Program[O]): Program[O] = p match {
    case Program(definitions, main) =>
      given State = State(0, mutable.Map.empty)
      Program(definitions map apply, apply(main))
  }
}
