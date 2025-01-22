package rpyeffectasm.mcore

import rpyeffectasm.util.ErrorReporter
import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}

sealed trait Id { def name: String }
case class Name(name: String) extends Id
case class Index(i: Int) extends Id { def name = s"#${i}" }
object Generated {
  var lastId: Int = 0
}
class Generated(doc: String) extends Id {
  val id = { Generated.lastId = Generated.lastId + 1; Generated.lastId }
  override def toString: String = s"${name}"
  def name = if doc.length < 30 then s"[${doc}#${id}]" else s"[#${id}]"
  {
    import rpyeffectasm.util.DebugInfo
    DebugInfo.log("mcore", "Generated", this.toString, "origin"){ Thread.currentThread().getStackTrace() }
    DebugInfo.log("mcore", "Generated", this.toString, "doc")(doc)
  }
}

case class Var(name: Id, tpe: Type) extends Term[Nothing]
type LhsOperand = Var

case class Clause[+O <: ATerm](params: List[LhsOperand], body: Term[O])

/** Supertrait for use in type bounds */
sealed trait ATerm {
  def unroll: Term[ATerm] = this match {
    case term: Term[_] => term
  }
}
extension[O <: ATerm](self: O) {
  def unrollAt: Term[O] = self match {
    case term: Term[O] => term
  }
}
sealed trait Term[+Operand <: ATerm] extends ATerm

// Basics
case class Abs[+O <: ATerm](params: List[LhsOperand], body: Term[O]) extends Term[O]
case class App[+O <: Term[ATerm]](fn: O, args: List[O]) extends Term[O]
case class Seq[+O <: ATerm](ts: List[Term[O]]) extends Term[O]

case class Let[+O <: ATerm](defs: List[Definition[O]], body: Term[O]) extends Term[O]
case class LetRec[+O <: ATerm](defs: List[Definition[O]], body: Term[O]) extends Term[O]
case class IfZero[+O <: ATerm](cond: O, thn: Term[O], els: Term[O]) extends Term[O]

// Data
case class Construct[+O <: Term[ATerm]](tpe_tag: Id, tag: Id, args: List[O]) extends Term[O]
case class Project[+O <: Term[ATerm]](scrutinee: O, tpe_tag: Id, tag: Id, field: Int) extends Term[O]
case class Match[+O <: ATerm](scrutinee: O, tpe_tag: Id, clauses: List[(Id, Clause[O])], default_clause: Clause[O]) extends Term[O]
case class Switch[+O <: ATerm](scrutinee: O, cases: List[(Literal, Term[O])], default: Term[O]) extends Term[O]

// Codata
case class New[+O <: ATerm](ifce_tag: Id, methods: List[(Id, Clause[O])]) extends Term[O]
case class Invoke[+O <: Term[ATerm]](receiver: O, ifce_tag: Id, method: Id, args: List[O]) extends Term[O]

// References
case class LetRef[+O <: ATerm](ref: LhsOperand, region: O, binding: O, body: Term[O]) extends Term[O]
case class Load[+O <: Term[ATerm]](ref: O) extends Term[O]
case class Store[+O <: Term[ATerm]](ref: O, value: O) extends Term[O]

// Control operators
case class FreshLabel() extends Term[Nothing]
case class Reset[+O <: ATerm](label: O, region: LhsOperand, bnd: Option[O], body: Term[O], ret: Clause[O]) extends Term[O]
case class Shift[+O <: ATerm](label: O, n: O, k: LhsOperand, body: Term[O], retTpe: Type) extends Term[O]
case class Control[+O <: ATerm](label: O, n: O, k: LhsOperand, body: Term[O], retTpe: Type) extends Term[O]
case class Resume[+O <: Term[ATerm]](cont: O, args: List[O]) extends Term[O]
/** Like [[Resume]], but evaluates [[body]] with the continuation already pushed.
 * I.e., prompts in cont are visible from [[body]] */
case class Resumed[+O <: ATerm](cont: O, body: Term[O]) extends Term[O]
case class GetDynamic[+O <: ATerm](label: O, n: O) extends Term[O]

// Primitives
case class Primitive[+O <: ATerm](name: String, args: List[O], returns: List[LhsOperand], rest: Term[O]) extends Term[O]

trait Literal extends Term[Nothing] {
  val tpe: Base
  def value: tpe.ScalaType
}
object Literal {
  case class Bool(value: scala.Boolean) extends Literal { val tpe: Base.Bool.type = Base.Bool }
  case class Int(value: scala.Int) extends Literal { val tpe: Base.Int.type = Base.Int }
  case class Double(value: scala.Double) extends Literal { val tpe: Base.Double.type = Base.Double }
  case class String(value: java.lang.String) extends Literal { val tpe: Base.String.type = Base.String }
  case class StringWithFormat(value: java.lang.String, format: java.lang.String) extends Literal {
    val tpe: Base.String.type = Base.String
  }
  object Unit extends Literal { val tpe: Base.Unit.type = Base.Unit; val value: Unit = () }
  object Label extends Literal { val tpe: Base.Label = Base.Label(Top, None); val value: Null = null }
  case class Injected[T](tpe: Base.Injected[T], var value: T) extends Literal
}

// Dynamic loading
case class ThisLib() extends Term[Nothing]
case class LoadLib[+O <: ATerm](path: O) extends Term[O]
case class CallLib[+O <: ATerm](lib: O, symbol: String, args: List[O], returnType: Type) extends Term[O]

// For debugging purposes
case class DebugWrap[+O <: ATerm](inner: Term[O], annotation: String) extends Term[O] {
  def getTerm: Term[O] = inner match {
    case d: DebugWrap[O] => d.getTerm
    case t => t
  }
}

// Top-level
case class Definition[+O <: ATerm](name: LhsOperand, binding: Term[O], exportAs: List[String])
case class Program[+O <: ATerm](definitions: List[Definition[O]], main: Term[O])


// Sugar -- forms that are macro(-ish)-expanded to the above.
trait Sugar extends Term[ATerm] {
  def desugared(using ErrorReporter): Term[ATerm]
}
case class Qualified(lib: Var, qualified_name: String, tpe: Type) extends Sugar {
  override def desugared(using ErrorReporter): Term[ATerm] = {
    tpe match {
      case Top => ErrorReporter.fatal("Qualified names must have a concrete type (not Top)")
      case Function(params, ret, purity) =>
        val ps = params.map{ t => Var(Generated("param"), t) }
        val nlib = Var(Generated("lib"), Ptr)
        Let(List(Definition(nlib, lib, Nil)),
          Abs(ps, CallLib(nlib, qualified_name, ps, ret))) // TODO ret tpe?
      case Num | Base.Int | Base.Double =>
        val r = Var(Generated("global"), Num)
        Primitive("getGlobal(String): Num", List(Literal.String(qualified_name)), List(r), r)
      case ptrTpe =>
        val r = Var(Generated("global"), Ptr)
        Primitive("getGlobal(String): Ptr", List(Literal.String(qualified_name)), List(r), r)
    }
  }
}

/** See [[AlternativeChoice]] */
object AlternativeFail extends Sugar {
  override def desugared(using ErrorReporter): Term[ATerm] =
    ErrorReporter.fatal("AlternativeFail must be wrapped in AlternativeChoice, and cannot occur in the last choice")
}
/** Alternative.choice / For easily generating if-else-chain-like code similar.
 * In each choice in [[choices]], [[AlternativeFail]] will be substituted by the next choice.
 * So,
 *
 *     (alternative-choice
 *         (if0 c1 r1 (alternative-fail))
 *         (if0 c2 r2 (alternative-fail))
 *         r3
 *     )
 *
 * becomes
 *
 *     (if0 c1 r1 (if0 c2 r2 r3))
 *
 */
case class AlternativeChoice(choices: List[Term[ATerm]]) extends Sugar {
  def expand(term: Term[ATerm], leftover: List[Term[ATerm]])(using ErrorReporter): Term[ATerm] = {
    val impl = new Structural[ATerm, ATerm] {
      override def term: PartialFunction[Term[ATerm], Term[ATerm]] = {
        case AlternativeFail if leftover.isEmpty =>
          ErrorReporter.fatal("AlternativeFail must be wrapped in AlternativeChoice, and cannot occur in the last choice")
        case AlternativeFail => expand(leftover.head, leftover.tail)
        case AlternativeChoice(choices) => AlternativeChoice(choices.init :+ expand(choices.last, leftover))
        case sugar: Sugar => apply(sugar.desugared) // FIXME in [[Structural]]
      }
    }
    impl(term)
  }
  override def desugared(using ErrorReporter): Term[ATerm] = expand(choices.head, choices.tail)
}
/** Type annotations.
 * Desugared to intermediate binding with type annotation
 */
case class The(tpe: Type, term: Term[ATerm]) extends Sugar {
  override def desugared(using ErrorReporter): Term[ATerm] = {
    val ann = Var(new Generated("annotated"), tpe)
    Let(List(Definition(ann, term, Nil)), ann)
  }
}

trait Query[R] {
  protected def definition: PartialFunction[Definition[ATerm], R] = PartialFunction.empty
  protected def term: PartialFunction[Term[ATerm], R] = PartialFunction.empty
  protected def clause: PartialFunction[Clause[ATerm], R] = PartialFunction.empty
  protected def param: PartialFunction[LhsOperand, R] = PartialFunction.empty
  protected def default: R = combine(Nil)
  protected def combine(x: R, y: R): R = combine(List(x,y))
  protected def combine(xs: Iterable[R]): R = xs.fold(default)(combine)

  def applyParam(p: LhsOperand): R = p match {
    case p if param.isDefinedAt(p) => param(p)
    case Var(name, tpe) => default
  }
  def apply(t: ATerm): R = t match {
    case x: Term[ATerm] if term.isDefinedAt(x) => term(x)
    case Var(name, tpe) => default
    case Abs(params, body) => combine(combine(params.map(applyParam)), apply(body))
    case App(fn, args) => combine(apply(fn), combine(args.map(apply)))
    case Seq(ts) => combine(ts.map(apply))
    case Let(defs, body) => combine(combine(defs.map(apply)), apply(body))
    case LetRec(defs, body) => combine(combine(defs.map(apply)), apply(body))
    case IfZero(cond, thn, els) => combine(List(cond, thn, els).map(apply))
    case Construct(tpe_tag, tag, args) => combine(args.map(apply))
    case Project(scrutinee, tpe_tag, tag, field) => apply(scrutinee)
    case Match(scrutinee, tpe_tag, clauses, default_clause) =>
      combine(List(apply(scrutinee), combine(clauses.map(apply)), apply(default_clause)))
    case Switch(scrutinee, cases, default) =>
      combine(List(apply(scrutinee), combine(cases.map{(_,c) => apply(c)}), apply(default)))
    case New(ifce_tag, methods) => combine(methods.map(apply))
    case Invoke(receiver, ifce_tag, method, args) => combine(apply(receiver),combine(args.map(apply)))
    case LetRef(ref, region, binding, body) => combine(List(ref, region, binding, body).map(apply))
    case Load(ref) => apply(ref)
    case Store(ref, value) => combine(apply(ref), apply(value))
    case FreshLabel() => default
    case Reset(label, region, bnd, body, ret) =>
      combine(bnd.map(apply).toList ++ List(apply(label), apply(region), apply(body), apply(ret)))
    case Shift(label, n, k, body, retTpe) => combine(List(apply(label), apply(n), apply(k), apply(body)))
    case Control(label, n, k, body, retTpe) => combine(List(apply(label), apply(n), apply(k), apply(body)))
    case GetDynamic(label, n) => combine(apply(label), apply(n))
    case Resume(cont, args) => combine(apply(cont), combine(args.map(apply)))
    case Resumed(cont, body) => combine(apply(cont), apply(body))
    case Primitive(name, args, returns, rest) => combine(List(combine(args.map(apply)), combine(returns.map(applyParam)), apply(rest)))
    case literal: Literal => default
    case HandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      combine(List(combine(handlers.map(apply)), combine(ret.map(apply).toList), apply(body)))
    case HandlerSugar.Op(tag, op, args, k, rtpe) =>
      combine(List(combine(args.map(apply)), apply(k)))
    case DynamicHandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      combine(List(apply(tag), combine(handlers.map(apply)), combine(ret.map(apply).toList), apply(body)))
    case DynamicHandlerSugar.Op(tag, op, args, k, rtpe) =>
      combine(List(apply(tag), combine(args.map(apply)), apply(k)))
    case DebugWrap(inner, ann) => apply(inner)
    case LoadLib(path) => apply(path)
    case CallLib(l, _, args, returnType) => combine(apply(l), combine(args map apply))
    case ThisLib() => default
    case sugar: Sugar => ???
  }
  def apply(c: Clause[ATerm]): R = c match {
    case c if clause.isDefinedAt(c) => clause(c)
    case Clause(params, body) => combine(combine(params.map(applyParam)), apply(body))
  }
  def apply(tc: (Id, Clause[ATerm])): R = tc match {
    case (x, c) => apply(c)
  }
  def apply(d: Definition[ATerm]): R = d match {
    case d: Definition[ATerm] if definition.isDefinedAt(d) => definition(d)
    case Definition(name, binding, exportAs) => apply(binding)
  }
  def apply(p: Program[ATerm]): R = p match {
    case Program(definitions, main) => combine(combine(definitions.map(apply)), apply(main))
  }
}
trait Visitor extends Query[Unit] {
  override def combine(xs: Iterable[Unit]): Unit = ()
}
trait Structural[F <: ATerm, T <: ATerm] {
  protected def definition: PartialFunction[Definition[F], Definition[T]] = PartialFunction.empty
  protected def term: PartialFunction[Term[F], Term[T]] = PartialFunction.empty
  protected def clause: PartialFunction[Clause[F], Clause[T]] = PartialFunction.empty
  protected def param: PartialFunction[LhsOperand, LhsOperand] = PartialFunction.empty

  def applyParam(p: LhsOperand): LhsOperand = p match {
    case p if param.isDefinedAt(p) => param(p)
    case p => p
  }
  def applyO(t: F): Term[ATerm] & T = apply(t.unroll.asInstanceOf[Term[F]]) match {
    case t: T => t
    case _ => assert(false, "Structural transformation does not preserve ANFiness")
  }
  def apply(d: Definition[F]): Definition[T] = d match {
    case d if definition.isDefinedAt(d) => definition(d)
    case Definition(name, binding, exportAs) => Definition(applyParam(name), apply(binding), exportAs)
  }
  def apply(c: Clause[F]): Clause[T] = c match {
    case c if clause.isDefinedAt(c) => clause(c)
    case Clause(params, body) => Clause(params map applyParam, apply(body))
  }
  def apply(tc: (Id, Clause[F])): (Id, Clause[T]) = tc match {
    case (t, c) => (t, apply(c))
  }
  def apply(t: Term[F]): Term[T] = t match {
    case t if term.isDefinedAt(t) => term(t)
    case Abs(params, body) => Abs(params map applyParam, apply(body))
    case App(fn, args) => App(applyO(fn), args map applyO)
    case Seq(ts) => Seq(ts map apply)
    case Let(defs, body) => Let(defs map apply, apply(body))
    case LetRec(defs, body) => LetRec(defs map apply, apply(body))
    case IfZero(cond, thn, els) => IfZero(applyO(cond), apply(thn), apply(els))
    case Construct(tpe_tag, tag, args) => Construct(tpe_tag, tag, args map applyO)
    case Project(scrutinee, tpe_tag, tag, field) => Project(applyO(scrutinee), tpe_tag, tag, field)
    case Match(scrutinee, tpe_tag, clauses, default_clause) =>
      Match(applyO(scrutinee), tpe_tag, clauses map apply, apply(default_clause))
    case Switch(scrutinee, cases, default) =>
      Switch(applyO(scrutinee), cases.map {
        (v, t) => (v, apply(t))
      }, apply(default))
    case New(ifce_tag, methods) => New(ifce_tag, methods map apply)
    case Invoke(receiver, ifce_tag, method, args) =>
      Invoke(applyO(receiver), ifce_tag, method, args map applyO)
    case LetRef(ref, region, binding, body) =>
      LetRef(applyParam(ref), applyO(region), applyO(binding), apply(body))
    case Load(ref) => Load(applyO(ref))
    case Store(ref, value) => Store(applyO(ref), applyO(value))
    case FreshLabel() => FreshLabel()
    case Reset(label, region, bnd, body, ret) =>
      Reset(applyO(label), applyParam(region), bnd.map(applyO), apply(body), apply(ret))
    case Shift(label, n, k, body, retTpe) =>
      Shift(applyO(label), applyO(n), applyParam(k), apply(body), retTpe)
    case Control(label, n, k, body, retTpe) =>
      Control(applyO(label), applyO(n), applyParam(k), apply(body), retTpe)
    case Resume(cont, args) =>
      Resume(applyO(cont), args map applyO)
    case Resumed(cont, body) =>
      Resumed(applyO(cont), apply(body))
    case Primitive(name, args, returns, rest) =>
      Primitive(name, args map applyO, returns map applyParam, apply(rest))
    case DebugWrap(inner, annotations) => DebugWrap(apply(inner), annotations)
    case LoadLib(path) => LoadLib(applyO(path))
    case CallLib(lib, symbol, args, returnType) => CallLib(applyO(lib), symbol, args map applyO, returnType)
    case ThisLib() => ThisLib()
    case AlternativeFail => AlternativeFail.asInstanceOf[Term[T]]
    case AlternativeChoice(choices) => AlternativeChoice(choices map apply).asInstanceOf[Term[T]]
    case The(tpe, term) => The(tpe, apply(term)).asInstanceOf[Term[T]]
    case Qualified(lib, qn, tpe) => Qualified(applyO(lib).asInstanceOf[Var], qn, tpe).asInstanceOf[Term[T]]
    case GetDynamic(lbl, n) => GetDynamic(applyO(lbl), applyO(n))
    case sugar: Sugar => print(sugar.getClass); ???
    case o: Term[Nothing] @unchecked => o
  }
  def apply(p: Program[F]): Program[T] = p match {
    case Program(definitions, main) => Program(definitions.map(apply), apply(main))
  }
}
