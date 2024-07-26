package rpyeffectasm.mcore
import rpyeffectasm.util.{Phase, ErrorReporter, Emit}
import rpyeffectasm.common.Purity
import scala.collection.mutable

object LambdaLifting extends Phase[Program[Var], Program[Var]] {
  import rpyeffectasm.mcore.analysis.ClosureAnalysis
  import rpyeffectasm.mcore.analysis.ClosureAnalysis.{in, Tpe}
  // TODO also track "actual" function names and replace them accordingly.
  //      Note: this is too late in Dealiasing, since we forgot the scoping until then (by lifting)!!

  def transform(t: Term[Var])(using ClosureAnalysis.Env, ErrorReporter, Emit[Definition[Var]]): Term[Var] = t match {
    case v@Var(name, tpe) => ClosureAnalysis(v) match {
      case Tpe.Function(params, captures, rtpe) => Var(name, Function(params ++ captures.map(_.tpe), rtpe, Purity.Effectful)) // TODO preserve purity
      case _ => v
    }
    case abs@Abs(params, body) =>
      val Tpe.Function(_, capts, rtpe) = ClosureAnalysis(abs)
      val name = Var(Generated("lifted lambda"), Function((params ++ capts).map(_.tpe), Type.of(body), Purity.Effectful)) // TODO preserve purity
      Emit.emit(Definition(name, Abs(params ++ capts, in(abs) { transform(body) }), Nil))
      name
    case App(fn@Var(name, atpe), args) => (atpe, ClosureAnalysis(fn)) match {
      case (Function(aparams, arte, apurity), Tpe.Function(params, captures, rtpe)) =>
        val tp = Function(params ++ captures.map(_.tpe), rtpe meet arte, apurity)
        App(Var(name, tp), args ++ captures)
      case (_, Tpe.Function(params, captures, rtpe)) =>
        val tp = Function(params ++ captures.map(_.tpe), rtpe, Purity.Effectful)
        App(Var(name, tp), args ++ captures)
      case (_, t) => App(fn, args)
    }
    case Seq(ts) => Seq(ts map transform)
    case Let(defs, body) =>
      val tDefs = defs flatMap transform
      val tBody = in(t){ transform(body) }
      if tDefs.isEmpty then tBody else Let(tDefs, tBody)
    case IfZero(cond, thn, els) => IfZero(cond, transform(thn), transform(els))
    case LetRec(defs, body) => in(t){
      val tDefs = defs flatMap transform
      val tBody = transform(body)
      if tDefs.isEmpty then tBody else LetRec(tDefs, tBody)
    }
    case Construct(tpe_tag, tag, args) => Construct(tpe_tag, tag, args)
    case Match(scrutinee, tpe_tag, clauses, default_clause) =>
      Match(scrutinee, tpe_tag, clauses map transform, transform(default_clause))
    case New(ifce_tag, methods) => New(ifce_tag, methods map transform)
    case LetRef(ref, region, binding, body) => LetRef(ref, region, binding, in(t){ transform(body) })
    case Reset(label, region, bnd, body, ret) =>
      Reset(label, region, bnd, in(t){ transform(body) }, transform(ret))
    case Shift(label, n, k, body, retTpe) =>
      Shift(label, n, k, in(t){ transform(body) }, retTpe)
    case Control(label, n, k, body, retTpe) =>
      Control(label, n, k, in(t){ transform(body) }, retTpe)
    case Resumed(cont, body) => Resumed(cont, transform(body))
    case Primitive(name, args, returns, rest) =>
      Primitive(name, args, returns, in(t){ transform(rest) })
    case DebugWrap(inner, annotations) =>
      DebugWrap(transform(inner), annotations)
    case Switch(scrutinee, cases, default) =>
      Switch(scrutinee, cases map {(v, t) => (v, transform(t))}, transform(default))
    case sugar: Sugar => ???
    case t => t
  }
  def transform(c: Clause[Var])(using ClosureAnalysis.Env, ErrorReporter, Emit[Definition[Var]]): Clause[Var] = c match {
    case Clause(params, body) => Clause(params, in(c){ transform(body) })
  }
  def transform(x: (Id, Clause[Var]))(using ClosureAnalysis.Env, ErrorReporter, Emit[Definition[Var]]): (Id, Clause[Var]) = x match {
    case (t, c) => (t, transform(c))
  }
  def transform(d: Definition[Var])(using ClosureAnalysis.Env, ErrorReporter, Emit[Definition[Var]]): Option[Definition[Var]] = d match {
    case Definition(name, abs@Abs(params, body), Nil) =>
      val Tpe.Function(_, capts, rtpe) = ClosureAnalysis(abs)
      val tName = Var(name.name, Function((params ++ capts).map(_.tpe), Type.of(body), Purity.Effectful))
      Emit.emit(Definition(tName, Abs(params ++ capts, in(abs){ transform(body) }), Nil)) // TODO preserve purity
      None
    case Definition(Var(name, _: Function), binding, Nil) =>
      Some(Definition(Var(name, Type.of(binding)), transform(binding), Nil))
    case Definition(name, binding, Nil) =>
      Some(Definition(name, transform(binding), Nil))
  }
  def transformToplevel(d: Definition[Var])(using ClosureAnalysis.Env, ErrorReporter, Emit[Definition[Var]]): Definition[Var] = d match {
    case Definition(name, abs@Abs(params, body), exportAs) =>
      val Tpe.Function(_, capts, rtpe) = ClosureAnalysis(abs)
      // TODO make sure that we are not actually lifting it if there are exports!
      val tName = Var(name.name, Function((params ++ capts).map(_.tpe), Type.of(body), Purity.Effectful))
      Definition(tName, Abs(params ++ capts, in(abs){ transform(body) }), exportAs)
    case Definition(Var(name, _: Function), binding, exportAs) =>
      Definition(Var(name, Type.of(binding)), transform(binding), exportAs)
    case Definition(name, binding, exportAs) => Definition(name, transform(binding), exportAs)
  }
  override def apply(f: Program[Var])(using ErrorReporter): Program[Var] = f match {
    case Program(definitions, main) => in(f){
      val tDefs = mutable.ListBuffer[Definition[Var]]()
      val tMain = Emit.collectingInto(tDefs) {
        definitions.foreach{ d =>
          Emit.emit(transformToplevel(d))
        }
        transform(main)
      }
      Program(tDefs.toList, tMain)
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  override def precondition(f: Program[Var]): Unit = ErrorReporter.assertNoError { ErrorReporter.withErrorsToStderr {
    import rpyeffectasm.mcore.analysis.FreeVariables
    // Well-scoped
    val frees = FreeVariables(f).toList
    assert(frees.isEmpty, s"Input for LambdaLifting has free variables: ${frees.map(SExpPrettyPrinter(_)).mkString(",")}")
  }}
  override def postcondition[Result >: Program[Var]](t: Result): Unit = {
    super.postcondition(t)
    // Preserved from ClosureConversion
    ClosureConversion.postcondition(t)
    // No Abs in non-toplevel lambda
    t match {
      case Program(definitions, main) =>
        val q = new Query[Unit] {
          override def term = {
            case Abs(_, _) => assert(false, "Abs was not lifted to toplevel")
          }
          override def combine(xs: Iterable[Unit]): Unit = ()
        }
        definitions.foreach{
          case Definition(_, Abs(_, b), exportAs) => q(b)
          case Definition(_, b, exportAs) => q(b)
        }
        q(main)
    }
    // All function vars are defined on the toplevel // commented out to test if true after Dealiasing
    t match {
      case p@Program(definitions, main) =>
        val q = new Query[Unit] {
          override def term: PartialFunction[Term[ATerm], Unit] = {
            case App(Var(x, _), args) =>
              assert(definitions.exists { case Definition(y, _, _) => x == y.name }, s"Function ${x} is not defined on toplevel")
              args.map(this.apply)
          }
          override def combine(xs: Iterable[Unit]): Unit = ()
        }
        q(p)
    }
  }
}
