package rpyeffectasm.mcore.analysis
import rpyeffectasm.mcore.*
import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}
import scala.collection.immutable.Set

case class FVSet(ids: Set[Id], vars: Map[Id, Var]) {

  def toSet: Set[Var] = vars.values.toSet

  def toList: List[Var] = vars.values.toList.sortBy(_.toString)

  def union(other: FVSet): FVSet = {
    // TODO There's a better way to do this. There must be.
    val isct = ids intersect other.ids
    var nVars = vars ++ other.vars
    for( x <- isct ){
      nVars.updated(x, Var(x, vars(x).tpe meet other.vars(x).tpe))
    }
    FVSet(ids union other.ids, nVars)
  }

  def removedAll(rem: Iterable[Var]): FVSet = {
    FVSet(ids removedAll (rem.map(_.name)), vars.removedAll(rem.map(_.name)))
  }

  def -(el: Var): FVSet = FVSet(ids - el.name, vars - el.name)
}

object FVSet {
  def empty = FVSet(Set.empty, Map.empty)

  def apply(vars: Var*): FVSet = from(vars)

  def from(vars: Iterable[Var]): FVSet = new FVSet(vars.map(_.name).toSet, vars.map { v => v.name -> v }.toMap)

  extension (it: Iterable[FVSet]) {
    def flattenFV: FVSet = it.fold(FVSet.empty)(_ union _)
  }
}

object FreeVariables {
  import FVSet._

  // TODO distinguish only based on name, not on type
  def apply(cls: Clause[ATerm]): FVSet = cls match {
    case Clause(params, body) => apply(body).removedAll(params)
  }
  def apply(t: Term[ATerm]): FVSet = t match {
    case v @ Var(name, tpe) => FVSet(v)
    case Abs(params, body) => apply(body).removedAll(params)
    case App(fn, args) => apply(fn) union args.map(apply).flattenFV
    case Seq(ts) => ts.map(apply).flattenFV
    case Let(defs, body) => apply(body).removedAll(defs.map(_.name)) union (defs.map{ d => apply(d.binding) }.flattenFV)
    case LetRec(defs, body) => (apply(body) union defs.map{ d => apply(d.binding) }.flattenFV).removedAll(defs.map(_.name))
    case Construct(tpe_tag, tag, args) => args.map(apply).flattenFV
    case Project(scrutinee, tpe_tag, tag, field) => apply(scrutinee)
    case Match(scrutinee, tpe_tag, clauses, default) => apply(scrutinee.unroll) union clauses.map{ case (i,d) => apply(d)}.flattenFV union apply(default)
    case Switch(scrutinee, cases, default) => apply(scrutinee.unroll) union cases.map{ case (_, t) => apply(t) }.flattenFV union apply(default)
    case IfZero(cond, thn, els) => apply(cond.unroll) union apply(thn) union apply(els)
    case New(ifce_tag, methods) => methods.map{ case (_, d) => apply(d) }.flattenFV
    case Invoke(receiver, ifce_tag, method, args) =>
      apply(receiver) union args.map(apply).flattenFV
    case LetRef(ref, region, binding, body) =>
      apply(region.unroll) union apply(binding.unroll) union (apply(body).removedAll(List(ref)))
    case Load(ref) => apply(ref)
    case Store(ref, value) => apply(ref) union apply(value)
    case FreshLabel() => FVSet()
    case Reset(label, region, bnd, body, ret) =>
      apply(label.unroll) union bnd.map{ b => apply(b.unroll) }.getOrElse(FVSet.empty) union (apply(body) - region) union apply(ret)
    case Shift(label, n, k, body, _) => apply(label.unroll) union apply(n.unroll) union (apply(body) - k)
    case Control(label, n, k, body, _) => apply(label.unroll) union apply(n.unroll) union (apply(body) - k)
    case GetDynamic(label, n) => apply(label.unroll) union apply(n.unroll)
    case Primitive(name, args, returns, rest) => args.map{ a => apply(a.unroll) }.flattenFV union (apply(rest).removedAll(returns))
    case _: Literal => FVSet.empty
    case Resume(cont, args) => apply(cont.unroll) union (args.map{ a => apply(a.unroll) }.flattenFV)
    case Resumed(cont, body) => apply(cont.unroll) union apply(body)
    case HandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      handlers.map{ (_, c) => apply(c) }.flattenFV union (ret.map(apply).getOrElse(FVSet.empty)) union apply(body)
    case HandlerSugar.Op(tag, op, args, k, rtpe) =>
      args.map(apply).flattenFV union apply(k)
    case DynamicHandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      apply(tag) union handlers.map{ (_, c) => apply(c) }.fold(FVSet.empty)(_ union _) union (ret.map(apply).getOrElse(FVSet.empty)) union apply(body)
    case DynamicHandlerSugar.Op(tag, op, args, k, rtpe) =>
      apply(tag) union args.map(apply).flattenFV union apply(k)
    case DebugWrap(inner, annotations) => apply(inner)
    case LoadLib(path) => apply(path.unroll)
    case CallLib(lib, symbol, args, returnType) => apply(lib.unroll) union (args.map{ a => apply(a.unroll) }.flattenFV)
    case ThisLib() => FVSet.empty
  }

  def apply(d: Definition[ATerm]): FVSet = d match {
    case Definition(name, binding, _) => apply(binding).removedAll(List(name))
  }

  def apply(p: Program[ATerm]): FVSet = p match {
    case Program(definitions, main) =>
      apply(LetRec(definitions, main))
  }

}
