package rpyeffectasm.mcore
import rpyeffectasm.util.{Phase, ErrorReporter}

object Desugar extends Phase[Program[ATerm], Program[ATerm]] {
  // TODO make difference clear in type

  def apply(c: Clause[ATerm])(using ErrorReporter): Clause[ATerm] = c match {
    case Clause(params, body) => Clause(params, apply(body))
  }
  def apply(tc: (Id, Clause[ATerm]))(using ErrorReporter): (Id, Clause[ATerm]) = tc match {
    case (id, c) => (id, apply(c))
  }

  def apply(t: Term[ATerm])(using ErrorReporter): Term[ATerm] = t match {
    // recurse
    case Abs(params, body) => Abs(params, apply(body))
    case App(Literal.String(name), args) =>
      val res = Var(new Generated(s"primitive result of ${name}"), rpyeffectasm.common.Primitives.getReturnType(name).asMCore)
      apply(Primitive(name, args, List(res), res))
    case App(fn, args) => App(apply(fn), args map apply)
    case Seq(ts) => Seq(ts map apply)
    case Let(defs, body) => Let(defs map apply, apply(body))
    case LetRec(defs, body) => LetRec(defs map apply, apply(body))
    case IfZero(cond, thn, els) => IfZero(apply(cond.unroll), apply(thn), apply(els))
    case Construct(tpe_tag, tag, args) => Construct(tpe_tag, tag, args map apply)
    case Project(scrutinee, tpe_tag, tag, field) => Project(apply(scrutinee), tpe_tag, tag, field)
    case Match(scrutinee, tpe_tag, clauses, default_clause) =>
      Match(apply(scrutinee.unroll), tpe_tag, clauses map apply, apply(default_clause))
    case Switch(scrutinee, cases, default) =>
      Switch(apply(scrutinee.unroll), cases.map{ (v, t) => (v, apply(t))}, apply(default))
    case New(ifce_tag, methods) => New(ifce_tag, methods map apply)
    case Invoke(receiver, ifce_tag, method, args) => Invoke(apply(receiver), ifce_tag, method, args map apply)
    case LetRef(ref, region, binding, body) => LetRef(ref, apply(region.unroll), apply(binding.unroll), apply(body))
    case Load(ref) => Load(apply(ref))
    case Store(ref, value) => Store(apply(ref), apply(value))
    case Reset(label, region, bnd, body, ret) =>
      Reset(apply(label.unroll), region, bnd.map{ b => apply(b.unroll) }, apply(body), apply(ret))
    case Shift(label, n, k, body, retTpe) => Shift(apply(label.unroll), apply(n.unroll), k, apply(body), retTpe)
    case Control(label, n, k, body, retTpe) => Control(apply(label.unroll), apply(n.unroll), k, apply(body), retTpe)
    case GetDynamic(label, n) => GetDynamic(apply(label.unroll), apply(n.unroll))
    case Resume(cont, args) => Resume(apply(cont), args map apply)
    case Resumed(cont, body) => Resumed(apply(cont.unroll), apply(body))
    case Primitive(name, args, returns, rest) if sugar.RichPrimitives.desugar.isDefinedAt(name) =>
      apply(sugar.RichPrimitives.desugar(name)(args, returns, rest))
    case Primitive(name, args, returns, rest) => Primitive(name, args map {a => apply(a.unroll) }, returns, apply(rest))
    case DebugWrap(inner, annotations) => DebugWrap(apply(inner), annotations)
    case LoadLib(path) => LoadLib(apply(path.unroll))
    case CallLib(lib, symbol, args, returnType) => CallLib(apply(lib.unroll), symbol, args map { a => apply(a.unroll) }, returnType)
    case ThisLib() => ThisLib()
    case t: Sugar => apply(t.desugared)
    case t: (Var | FreshLabel | Literal) => t
  }

  def apply(d: Definition[ATerm])(using ErrorReporter): Definition[ATerm] = d match {
    case Definition(name, binding, exportAs) => Definition(name, apply(binding), exportAs)
  }

  override def apply(f: Program[ATerm])(using ErrorReporter): Program[ATerm] = f match {
    case Program(definitions, main) => Program(definitions map apply, apply(main))
  }

}
