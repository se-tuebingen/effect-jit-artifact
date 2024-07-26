package rpyeffectasm
package mcore
import rpyeffectasm.util.{Phase, ErrorReporter}
import rpyeffectasm.common.Purity

/**
 * Preconditions:
 * - [[Abs]] only occurs at the top of (not necessarily toplevel) [[Definition]]s
 */
object ClosureConversion extends Phase[Program[Var], Program[ATerm]] {
  import rpyeffectasm.mcore.analysis.ClosureAnalysis
  import ClosureAnalysis.{Tpe, in, captureEscapesHere}

  // TODO superficially, this seems similar to https://dl.acm.org/doi/abs/10.1145/3610612.3610622 - compare and check if we can use some ideas from there
  // TODO Analyse where a function becomes a value, run mkClosure there.

  def typeShorthand(t: Type): String = "v"

  def mkClosureName(params: List[Type], ret: Type): Id = {
    Name(s"closure_${params.map(typeShorthand).mkString}_${typeShorthand(ret)}")
  }
  def mkClosureName(tp: Type): Id = tp match {
    case Function(params, ret, purity) => mkClosureName(params, ret)
    case Codata(ifce_tag, methods) => ifce_tag
    case _ => Generated("Closure of unknown type")
  }

  def mkFn(v: Var)(using ClosureAnalysis.Env, ErrorReporter): Var = (v, ClosureAnalysis(v)) match {
    case (Var(name, tpe@Function(params, ret, purity)), _) =>
      Var(name, transformTpe(tpe, false))
    case (Var(name, _), Tpe.Function(params, _, rtpe)) =>
      Var(name, Function(params.map(transformTpe(_)), transformTpe(rtpe), Purity.Effectful))
    case _ => sys error "Bug in closure conversion: Value in function position"
  }
  def mkClosure(t: Type): Type = t match {
    case Function(params, ret, purity) =>
      Codata(mkClosureName(t), List(Method(Name("apply"),
        params.map(transformTpe(_)), transformTpe(ret))))
    case _ => transformTpe(t, true)
  }
  def mkClosure(fn: Var)(using ClosureAnalysis.Env, ErrorReporter): Term[ATerm] = ClosureAnalysis(fn) match {
    case ClosureAnalysis.Tpe.Value => Var(fn.name, mkClosure(fn.tpe))
    case ClosureAnalysis.Tpe.Function(params, _, _) =>
      val paramNames = params.map{ t => Var(Generated("closure param"), mkClosure(t))}
      New(Generated(s"closure for ${fn}"), List(
        (Name("apply"), Clause(paramNames, App(mkFn(fn), paramNames)))))
  }

  def transformTpe(t: Type, requireValue: Boolean = true): Type = t match {
    case Function(params, ret, purity) if requireValue => mkClosure(t)
    case Function(params, ret, purity) => Function(params.map(transformTpe(_)), transformTpe(ret), purity)
    case Codata(ifce_tag, methods) => Codata(ifce_tag, methods map {
      case Method(tag, params, ret) => Method(tag, params.map(transformTpe(_)), transformTpe(ret))
    })
    case Data(type_tag, constructors) => Data(type_tag, constructors map {
      case Constructor(tag, fields) => Constructor(tag, fields.map(transformTpe(_)))
    })
    case Stack(resume_ret, resume_args) => Stack(transformTpe(resume_ret), resume_args.map(transformTpe(_)))
    case Ref(to) => Ref(transformTpe(to, true))
    case Base.Label(at, binding) => Base.Label(transformTpe(at), binding.map(transformTpe(_)))
    case t => t
  }

  def transformParam(x: Var)(using ClosureAnalysis.Env, ErrorReporter): Var = x match {
    case Var(name, tpe) => Var(name, transformTpe(tpe))
  }

  def transform(t: Term[Var], requireValue: Boolean)(using ClosureAnalysis.Env, ErrorReporter): Term[ATerm] = t match {
    case v@Var(name, tpe) if requireValue => mkClosure(v)
    case v@Var(name, t@Function(_,_,_)) if ClosureAnalysis(v) == Tpe.Value => Var(name, mkClosure(t))
    case v@Var(name, tpe) => Var(name, transformTpe(tpe, requireValue))
    case Abs(params, body) => Abs(params.map(transformParam), in(t){
      transform(body, true)
    })
    case App(fn, args) =>
      val tFn = transform(fn, false)
      (tFn match {
        case d: DebugWrap[_] => d.getTerm
        case _ => tFn
      }) match {
        case v@Var(name, tpe) if ClosureAnalysis(v) == Tpe.Value =>
          val tag = mkClosureName(tpe match {
            case f: Function => f
            case c: Codata => c
            case _ => Function(args.map(_.tpe), Top, Purity.Effectful)
          })
          val vt = tpe match {
            case Function(params, ret, purity) =>
              Codata(tag, List(Method(Name("apply"), params, ret)))
            case c@Codata(_, List(Method(Name("apply"), _, _))) => c
            case _ => Ptr
          }
          Invoke(Var(name, vt), tag, Name("apply"), args.map(transform(_, true)))
        case v: Var => App(mkFn(v), args.map(transform(_, true)))
      }
    case Seq(Nil) => Seq(Nil)
    case Seq(ts :+ t) =>
      Seq(ts.flatMap{ s => ClosureAnalysis(s) match {
        case Tpe.Function(_, _, _) => Nil // Will never be called, so just drop it
        case Tpe.Value => List(transform(s, true))
      }} :+ transform(t, true))
    case Seq(_ :: _) => sys error "ERROR: A non-empty list does not seem to split into a last element and a prefix?!?!"
    case Let(defs, body) =>
      val tDefs = defs.map(transform(_))
      in(Let(tDefs, body)){
        Let(tDefs, transform(body, requireValue || captureEscapesHere(ClosureAnalysis(body))))
      }
    case LetRec(defs, body) =>
      val tDefs = in(t){
        defs.map(transform(_))
      }
      in(LetRec(tDefs, body)){
        LetRec(tDefs, transform(body, requireValue || captureEscapesHere(ClosureAnalysis(body))))
      }
    case IfZero(cond, thn, els) =>
      IfZero(transform(cond, true), transform(thn, true), transform(els, true))
    case Construct(tpe_tag, tag, args) => Construct(tpe_tag, tag, args.map(transform(_, true)))
    case Project(scrutinee, tpe_tag, tag, field) => Project(transform(scrutinee, true), tpe_tag, tag, field)
    case Match(scrutinee, tpe_tag, clauses, default_clause) =>
      Match(transform(scrutinee, true), tpe_tag,
        clauses.map{
          case (t, c) => (t, transform(c, true))
        },
        transform(default_clause, true))
    case Switch(scrutinee, cases, default) =>
      Switch(transform(scrutinee, true),
        cases.map {
          case (v, t) => (v, transform(t, true))
        },
        transform(default, true))
    case New(ifce_tag, methods) => New(ifce_tag, methods.map{
      case (t, c) => (t, transform(c, true))
    })
    case Invoke(receiver, ifce_tag, method, args) =>
      Invoke(transform(receiver, true), ifce_tag, method, args.map(transform(_, true)))
    case LetRef(ref, region, binding, body) =>
      LetRef(transformParam(ref), transform(region, true), transform(binding, true),
        in(t){ transform(body, true) })
    case Load(ref) => Load(transform(ref, true))
    case Store(ref, value) => Store(transform(ref, true), transform(value, true))
    case FreshLabel() => FreshLabel()
    case Reset(label, region, bnd, body, ret) =>
      Reset(transform(label, true), region, bnd.map(transform(_, true)),
        in(t){ transform(body, true) }, // TODO ??
        transform(ret, true)) // TODO ??
    case Shift(label, n, k, body, retTpe) =>
      Shift(transform(label, true), transform(n, true), transformParam(k),
        in(t) { transform(body, true) },
        transformTpe(retTpe))
    case Control(label, n, k, body, retTpe) =>
      Control(transform(label, true), transform(n, true), transformParam(k),
        in(t) { transform(body, true) },
        transformTpe(retTpe))
    case Resume(cont, args) =>
      Resume(transform(cont, true), args.map(transform(_, true)))
    case Resumed(cont, body) =>
      Resumed(transform(cont, true), transform(body, true))
    case Primitive(name, args, returns, rest) =>
      Primitive(name, args.map(transform(_, true)), returns, in(t){ transform(rest, true) }) // TODO ??
    case literal: Literal => literal
    case DebugWrap(inner, annotations) => DebugWrap(transform(inner, requireValue), annotations)
    case LoadLib(path) => LoadLib(transform(path, true))
    case CallLib(lib, symbol, args, returnType) => CallLib(transform(lib, true), symbol, args.map(transform(_, true)), returnType)
    case ThisLib() => ThisLib()
    case GetDynamic(label, n) => GetDynamic(transform(label, true), transform(n, true))
    case sugar: Sugar => ???
  }

  def transform(d: Definition[Var], requireValue: Boolean = false)(using ClosureAnalysis.Env, ErrorReporter): Definition[ATerm] = d match {
    case Definition(x@Var(name, tpe), binding, exportAs) =>
      Definition(Var(name, transformTpe(tpe, requireValue)), transform(binding, requireValue), exportAs)
  }
  def transform(c: Clause[Var], requireValueResult: Boolean)(using ClosureAnalysis.Env, ErrorReporter): Clause[ATerm] = c match {
    case Clause(params, body) => Clause(params.map(transformParam), in(c){ transform(body, requireValueResult) })
  }

  override def apply(f: Program[Var])(using ErrorReporter): Program[ATerm] = f match {
    case Program(definitions, main) =>
      in(f) {
        Program(definitions.map(transform(_)),
          transform(main, true))
      }
  }

  ////////////////////////////////////////////////////////////////////////////////
  override def postcondition[Result >: Program[ATerm]](t: Result): Unit = {
    super.postcondition(t)
    // No Function-type symbols except on rhs of definition
    val noFnSymbol = (new Query[Unit] {
      override def term: PartialFunction[Term[ATerm], Unit] = {
        case Var(_, Function(params, ret, purity)) => assert(false, "Function symbol is not closure-converted or alias")
        case App(Var(_,_), args) => args.foreach(this.apply)
      }
      override def definition: PartialFunction[Definition[ATerm], Unit] = {
        case Definition(name, binding: Var, _) => () // ignore alias definitions
        case Definition(name, binding: DebugWrap[_], _) if binding.getTerm.isInstanceOf[Var] => () // also in DebugWrap
      }
      override def combine(xs: Iterable[Unit]): Unit = ()
    })
    // No function parameters (closure-converted)
    val noFnParams = (new Query[Unit] {
      override def param: PartialFunction[LhsOperand, Unit] = {
        case Var(_, Function(params, ret, purity)) => assert(false, "Function parameter is not closure-converted")
      }
      override def combine(xs: Iterable[Unit]): Unit = ()
    })
    t match {
      case p: Program[?] =>
        noFnSymbol(p)
        noFnParams(p)
    }


  }
}
