package rpyeffectasm.mcore

import scala.annotation.targetName
import rpyeffectasm.util.{Phase, ErrorReporter}

/** Capture-avoiding substitution.
 *
 * Substitutes **everywhere** (i.e., also tags etc) but makes sure that no binding will
 * capture any of those (and does not substitute it in bound context).
 *
 * As long as the same [[Id]] isn't used for a tag and a variable name, this should do
 * what you want.
 */
case class Substitution(sigma: Map[Id, Id]) {
  val potentialCaptures: Set[Id] = sigma.values.toSet

  def bind(bound: Iterable[Id]): Substitution = {
    var result = sigma
    bound.foreach { x =>
      if(sigma contains x) {
        result = result - x
      }
      if(potentialCaptures contains x) {
        result = result + (x -> new Generated(x.name + "_r"))
      }
    }
    Substitution(result)
  }
  def bind(bound: Id*): Substitution = bind(bound)
  def bind(lhsOp: LhsOperand): Substitution = bind(lhsOp.name)
  @targetName("bindLhsOp")
  def bind(bound: LhsOperand*): Substitution = bind(bound.map(_.name))
  def apply(x: Id): Id = x match {
    case x if (sigma contains x) => sigma(x)
    case x => x
  }

  def apply(m: Method): Method = m match {
    case Method(tag, params, ret) => Method(apply(tag), params map apply, apply(ret))
  }
  def apply(c: Constructor): Constructor = c match {
    case Constructor(tag, fields) => Constructor(apply(tag), fields map apply)
  }
  def apply(t: Type): Type = t match {
    case t @ (Top | Ptr | Num | Bottom | _: Base) => t
    case Function(params, ret, purity) => Function(params map apply, apply(ret), purity)
    case Codata(ifce_tag, methods) => Codata(apply(ifce_tag), methods map apply)
    case Data(type_tag, constructors) => Data(apply(type_tag), constructors map apply)
    case Stack(resume_ret, resume_args) => Stack(apply(resume_ret), resume_args map apply)
    case Ref(to) => Ref(apply(to))
  }
  def apply(l: LhsOperand): LhsOperand = l match {
    case Var(name, tpe) => Var(apply(name), apply(tpe))
  }
  def apply[O <: ATerm](t: O): Term[O] & O = t match {
    case Var(name, tpe) => Var(apply(name), apply(tpe)).asInstanceOf[Term[O] & O] // FIXME
    case t: Term[_] => apply(t)
  }
  def apply[O <: ATerm](t: Term[O]): Term[O] = t match {
    case Var(name, tpe) => Var(apply(name), apply(tpe))
    case Abs(params, body) =>
      val inner = bind(params.map(_.name))
      Abs(params map inner.apply, inner.apply(body))
    case App(fn, args) => App(apply(fn), args map apply)
    case Seq(ts) => Seq(ts map apply)
    case Let(defs, body) =>
      val inner = bind(defs.map(_.name.name))
      Let(defs.map {
        case Definition(name, binding, exportAs) => Definition(inner.apply(name), this.apply(binding), exportAs)
      }, inner.apply(body))
    case LetRec(defs, body) =>
      val inner = bind(defs.map(_.name.name))
      LetRec(defs map inner.apply, inner.apply(body))
    case IfZero(cond, thn, els) =>
      IfZero(apply(cond), apply(thn), apply(els))
    case Construct(tpe_tag, tag, args) => Construct(apply(tpe_tag), apply(tag), args map apply)
    case Project(scrutinee, tpe_tag, tag, field) => Project(apply(scrutinee), apply(tpe_tag), apply(tag), field)
    case Match(scrutinee, tpe_tag, clauses, Clause(dparams, dbody)) =>
      Match(apply(scrutinee), apply(tpe_tag), clauses map {
      case (tag, Clause(params, body)) =>
        val inner = bind(params.map(_.name))
        (apply(tag), Clause(params map inner.apply, inner(body)))
    }, {
        val inner = bind(dparams.map(_.name))
        Clause(dparams map inner.apply, inner(dbody))
      })
    case Switch(scrutinee, cases, default) =>
      Switch(apply(scrutinee), cases map {
        case (v, t) => (v, apply(t))
      }, apply(default))
    case New(ifce_tag, methods) => New(apply(ifce_tag), methods map {
      case (tag, Clause(params, body)) =>
        val inner = bind(params.map(_.name))
        (apply(tag), Clause(params map inner.apply, inner.apply(body)))
    })
    case Invoke(receiver, ifce_tag, method, args) =>
      Invoke(apply(receiver), apply(ifce_tag), apply(method), args map apply)
    case LetRef(ref, region, binding, body) =>
      val inner = bind(ref)
      LetRef(inner(ref), this(region), this(binding), inner(body))
    case Load(ref) => Load(apply(ref))
    case Store(ref, value) => Store(apply(ref), apply(value))
    case FreshLabel() => FreshLabel()
    case Reset(label, region, bnd, body, Clause(params, ret_body)) =>
      val bodyS = bind(region)
      val retS = bind(params.map(_.name))
      Reset(apply(label), bodyS(region), bnd.map(apply), bodyS(body), Clause(params map retS.apply, retS(ret_body)))
    case Shift(label, n, k, body, retTpe) =>
      val inner = bind(k)
      Shift(this (label), this (n), inner(k), inner(body), retTpe)
    case Control(label, n, k, body, retTpe) =>
      val inner = bind(k)
      Control(this (label), this (n), inner(k), inner(body), retTpe)
    case Resume(cont, args) => Resume(apply(cont), args map apply)
    case Resumed(cont, body) => Resumed(apply(cont), apply(body))
    case Primitive(name, args, returns, rest) =>
      val inner = bind(returns.map(_.name))
      Primitive(name, args map this.apply, returns map inner.apply, inner(rest))
    case literal: Literal => literal
    case DebugWrap(inner, annotations) => DebugWrap(apply(inner), annotations)
    case LoadLib(path) => LoadLib(apply(path))
    case CallLib(lib, symbol, args, returnType) => CallLib(apply(lib), symbol, args map apply, apply(returnType))
    case ThisLib() => ThisLib()
  }
  def apply[O <: ATerm](t: Definition[O]): Definition[O] = t match {
    case Definition(name, binding, exportAs) => Definition(apply(name), apply(binding), exportAs)
  }
  def apply(f: Program[ATerm]): Program[ATerm] = f match {
    case Program(definitions, main) =>
      val mainS = bind(definitions.map(_.name.name))
      Program(definitions map mainS.apply, mainS(main))
  }
}

object Substitution {
  def empty: Substitution = Substitution(Map.empty)
  def apply(substs: (Id,Id)*): Substitution = Substitution(substs.toMap)
  extension(self: Substitution) {
    def compose(other: Substitution): Substitution = other andThen self
    def andThen(other: Substitution): Substitution = {
      Substitution(other.sigma ++ self.sigma.view.mapValues(other.apply))
    }
  }
}