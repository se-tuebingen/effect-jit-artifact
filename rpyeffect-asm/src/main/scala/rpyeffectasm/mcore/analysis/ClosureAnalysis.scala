package rpyeffectasm.mcore
package analysis
import rpyeffectasm.util.ErrorReporter
import scala.annotation.tailrec

object ClosureAnalysis {
  // TODO It might be useful to cache results here in some cases.
  // TODO Fix global variables

  sealed trait Tpe
  object Tpe {
    case object Value extends Tpe
    case class Function(params: List[Type], captures: List[Var], rtpe: Type) extends Tpe
  }
  enum Env {
    case Empty
    case Bind(bindings: Map[Id, Tpe], outer: Env)

    def lookup(x: Id): Option[Tpe] = this match {
      case Empty => None
      case Bind(bnds, _) if bnds.contains(x) => Some(bnds(x))
      case Bind(_, outer) => outer.lookup(x)
    }
  }

  def apply(t: Term[ATerm])(using env: Env, E: ErrorReporter): Tpe = t match {
    case Var(name, tpe) => env.lookup(name).getOrElse{
      ErrorReporter.fatal(s"Unbound variable ${name}")
    }
    case Abs(params, body) =>
      val capts = FreeVariables(body).removedAll(params).toSet.flatMap{
        capt =>
          env.lookup(capt.name) match {
            case Some(Tpe.Function(_, scapts, _)) => scapts
            case _ => List(capt)
          }
      }.toList.sortBy(_.name.name)
      Tpe.Function(params.map(_.tpe), capts, Type.of(body))
    case App(fn, args) => Tpe.Value
    case Seq(Nil) => Tpe.Value
    case Seq(ts) => Tpe.Value //apply(ts.last)
    case Let(defs, body) => in(t){ apply(body) }
    case LetRec(defs, body) => in(t){ apply(body) }
    case IfZero(cond, thn, els) => Tpe.Value
    case Match(scrutinee, tpe_tag, clauses, default_clause) => Tpe.Value
    case Switch(scrutinee, cases, default) => Tpe.Value
    case LetRef(ref, region, binding, body) => Tpe.Value // in(t){ apply(body) }
    case Reset(label, region, bnd, body, ret) => Tpe.Value // in(t){ apply(body) }
    case Shift(label, n, k, body, retTpe) => Tpe.Value // in(t){ apply(body) }
    case Control(label, n, k, body, retTpe) => Tpe.Value // in(t){ apply(body) }
    case Primitive(name, args, returns, rest) => Tpe.Value // in(t){ apply(rest) }
    case sugar: Sugar => ???
    case DebugWrap(inner, annotations) => apply(inner)
    case LoadLib(path) => Tpe.Value
    case CallLib(lib, symbol, args, returnType) => Tpe.Value
    case _ => Tpe.Value
  }
  def apply(d: Definition[ATerm])(using Env, ErrorReporter): (Id, Tpe) = d match {
    case Definition(name, binding, exportAs) => (name.name, apply(binding))
  }

  def bindingsOf(t: Term[ATerm])(using env: Env, E: ErrorReporter): Map[Id, Tpe] = t match {
    case Abs(params, _) =>
      params.map{ p => p.name -> Tpe.Value }.toMap
    case Let(defs, _) =>
      defs.map(apply).toMap
    case LetRec(defs, _) =>
      // Will never be passed to the outside because:
      // - Only created here => Only in env for the call to compute [[bindings]]
      // - Then removed by [[resolveRecursive]] (which will never return one)
      // TODO potentially ensure this via a type parameter
      case class RecursiveBinding(to: Id) extends Tpe
      given Env = Env.Bind(defs.map{ d => (d.name.name, RecursiveBinding(d.name.name)) }.toMap, env)

      val bindings = defs.map(apply).toMap

      def resolveRecursive(b: Tpe, seen: Set[Id] = Set.empty, ignore: Set[Id] = Set.empty): Tpe = b match {
        case RecursiveBinding(to) if seen.contains(to) =>
          ErrorReporter.fatal(s"Non-productive recursive binding involving ${seen}")
        case RecursiveBinding(to) if bindings.contains(to) => resolveRecursive(bindings(to), seen + to, ignore)
        case Tpe.Function(params, captures, rtpe) =>
          val rcapts = captures.flatMap{
            case x if ignore.contains(x.name) => Nil
            case x if bindings.contains(x.name) => resolveRecursive(bindings(x.name), Set.empty, ignore + (x.name)) match {
              case Tpe.Function(_, subcaptures, _) => subcaptures
              case _ => List(x)
            }
            case x => List(x)
          }.distinctBy(_.name).sortBy(_.name.name)
          Tpe.Function(params, rcapts, rtpe)
        case b => b
      }
      def resolveRecursiveBinding(b: (Id, Tpe)): (Id, Tpe) = b match {
        case (x, t) => (x, resolveRecursive(t, Set(x), Set(x)))
      }
      bindings.map(resolveRecursiveBinding).toMap
    case LetRef(ref, region, binding, _) =>
      Map(ref.name -> Tpe.Value)
    case Reset(label, region, _, _, ret) =>
      Map(region.name -> Tpe.Value)
    case Shift(label, n, k, _, retTpe) =>
      Map(k.name -> Tpe.Value) // TODO ??
    case Control(label, n, k, _, retTpe) =>
      Map(k.name -> Tpe.Value) // TODO ??
    case Primitive(name, args, returns, _) =>
      returns.map{ p => p.name -> Tpe.Value }.toMap
    case sugar: Sugar => ???
    case _ => sys error s"ClosureAnalysis.in called on non-binding form ${t}"
  }

  def in[R](t: Term[ATerm])(using env: Env, E: ErrorReporter)(body: Env ?=> R): R = body(using Env.Bind(bindingsOf(t), env))
  def in[R](c: Clause[ATerm])(using env: Env, E: ErrorReporter)(body: Env ?=> R): R = c match {
    case Clause(params, _) => body(using Env.Bind(params.map{ p => p.name -> Tpe.Value }.toMap, env))
  }
  def in[R](p: Program[ATerm])(using ErrorReporter)(body: Env ?=> R): R = p match {
    case Program(definitions, main) =>
      given Env = Env.Empty
      in(LetRec(definitions, main))(body)
  }

  def captureEscapesHere(t: Tpe)(using env: Env): Boolean = env match {
    case Env.Empty => false
    case Env.Bind(bindings, outer) => t match {
      case Tpe.Function(params, captures, _) =>
        captures.exists{ x => bindings.contains(x.name) }
      case _ => false
    }
  }

}
