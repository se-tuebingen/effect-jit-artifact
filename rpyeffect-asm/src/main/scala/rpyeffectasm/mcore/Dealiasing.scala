package rpyeffectasm.mcore
import rpyeffectasm.util.{Phase, ErrorReporter}
import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}
import scala.collection.mutable
import rpyeffectasm.util.Emit

/** Phase that remove superfluous [[Let]]-bindings using substitution
 *
 * Preconditions:
 * - There are no (mutually) recursive aliases. (If violated, might not terminate or produce incorrect results.)
 */
class Dealiasing[O <: ATerm] extends Phase[Program[O], Program[O]] {
  // TODO bubble exports in the inverse direction

  import rpyeffectasm.util.fixpoint

  case class Env(aliases: Map[Id, Id]) {
    def --(ids: Iterable[Id]): Env = Env(aliases.removedAll(ids))
    def -(id: Id): Env = Env(aliases.removed(id))
  }
  def binding(defs: List[Definition[O]])(using env: Env, ae: Emit[(Id, String)]): (List[Definition[O]], Env) = {
    val aliases: mutable.ListBuffer[(Id, Id)] = mutable.ListBuffer.empty
    val tDefs: mutable.ListBuffer[Definition[O]] = mutable.ListBuffer.empty
    defs.foreach {
      case Definition(name, alias: Var, exportAs) =>
        aliases.addOne(name.name -> alias.name)
        exportAs.foreach{ s => ae.emit(name.name -> s) }
      case Definition(name, d: DebugWrap[_], exportAs) if d.getTerm.isInstanceOf[Var] =>
        val a = d.getTerm.asInstanceOf[Var]
        aliases.addOne(name.name -> a.name)
        exportAs.foreach{ s => ae.emit(a.name -> s) }
      case d => tDefs.addOne(d)
    }
    (tDefs.toList, Env(env.aliases -- defs.map(_.name.name) ++ aliases.toMap))
  }
  def bindingRec(defs: List[Definition[O]])(using env: Env, E: ErrorReporter, ae: Emit[(Id, String)]): (List[Definition[O]], Env) = {
    val recAliasesB: mutable.ListBuffer[(Id, (Id, List[String]))] = mutable.ListBuffer.empty
    val tDefs: mutable.ListBuffer[Definition[O]] = mutable.ListBuffer.empty
    defs.foreach {
      case Definition(name, alias: Var, exportAs) =>
        recAliasesB.addOne(name.name -> (alias.name, exportAs))
      case Definition(name, d: DebugWrap[_], exportAs) if d.getTerm.isInstanceOf[Var] =>
        recAliasesB.addOne(name.name -> (d.getTerm.asInstanceOf[Var].name, exportAs))
      case d => tDefs.addOne(d)
    }
    val recAliases = recAliasesB.toMap
    val aliases = recAliases.map{
      case (x -> (y, exps)) =>
        var tY = y
        val tExps = mutable.ListBuffer[String](exps*)
        while(recAliases.contains(tY)) {
          recAliases(tY) match {
            case (nY, nExps) =>
              tY = nY
              tExps.addAll(nExps)
          }
          if(tY == y) {
            ErrorReporter.fatal(s"Recursive alias ${SExpPrettyPrinter(y)} - ... -> ${SExpPrettyPrinter(y)}.")
          }
        }
        tExps.foreach{ e => Emit.emit(tY -> e) }
        x -> tY
    }
    val tEnv = Env(env.aliases -- defs.map(_.name.name) ++ aliases)
    (tDefs.toList, tEnv)
  }
  def applyV(v: Var)(using env: Env): Var = v match {
    case Var(name, tpe) if env.aliases contains name => Var(env.aliases(name), tpe)
    case v => v
  }
  def apply(t: O)(using Env, ErrorReporter, Emit[(Id, String)]): Term[O] & O = t match {
    case v: Var => applyV(v).asInstanceOf[Term[O] & O] // FIXME
    case t: Term[_] => apply(t.asInstanceOf[Term[O]]).asInstanceOf[Term[O] & O] // FIXME
  }
  def apply(c: Clause[O])(using env: Env, E: ErrorReporter, ae: Emit[(Id, String)]): Clause[O] = c match {
    case Clause(params, body) => Clause(params, apply(body)(using env -- params.map(_.name)))
  }
  def apply(t: Term[O])(using env: Env, E: ErrorReporter, ae: Emit[(Id, String)]): Term[O] = t match {
    case v @ Var(_, _) => applyV(v)
    case Abs(params, body) => Abs(params, apply(body)(using env -- params.map(_.name)))
    case App(fn, args) => App(apply(fn), args map apply)
    case Seq(ts) => Seq(ts map apply)
    case Let(defs, body) =>
      val (rdefs, inner) = binding(defs map apply)
      val tBody = apply(body)(using inner)
      if rdefs.isEmpty then tBody else Let(rdefs map apply, tBody)
    case IfZero(cond, thn, els) => IfZero(apply(cond), apply(thn), apply(els))
    case LetRec(defs, body) =>
      val (rdefs, inner) = bindingRec(defs)
      {
        given Env = inner
        val tBody = apply(body)
        if rdefs.isEmpty then tBody else LetRec(rdefs map apply, tBody)
      }
    case Construct(tpe_tag, tag, args) => Construct(tpe_tag, tag, args map apply)
    case Project(scrutinee, tpe_tag, tag, field) => Project(apply(scrutinee), tpe_tag, tag, field)
    case Match(scrutinee, tpe_tag, clauses, default) =>
      Match(apply(scrutinee), tpe_tag, clauses map { case (t, c) => (t, apply(c)) }, apply(default))
    case Switch(scrutinee, cases, default) =>
      Switch(apply(scrutinee), cases map { case (v, t) => (v, apply(t)) }, apply(default))
    case New(ifce_tag, methods) => New(ifce_tag, methods map { case (t, c) => (t, apply(c)) })
    case Invoke(receiver, ifce_tag, method, args) => Invoke(apply(receiver), ifce_tag, method, args map apply)
    case LetRef(ref, region, binding, body) => LetRef(ref, apply(region).asInstanceOf[O], apply(binding), apply(body)(using env - ref.name))
    case Load(ref) => Load(apply(ref))
    case Store(ref, value) => Store(apply(ref), apply(value))
    case FreshLabel() => FreshLabel()
    case Reset(label, region, bnd, body, ret) =>
      Reset(apply(label), region, bnd.map(apply(_)), apply(body)(using env - region.name), apply(ret))
    case Shift(label, n, k, body, retTpe) =>
      Shift(apply(label), apply(n), k, apply(body)(using env - k.name), retTpe)
    case Control(label, n, k, body, retTpe) =>
      Control(apply(label), apply(n), k, apply(body)(using env - k.name), retTpe)
    case GetDynamic(label, n) =>
      GetDynamic(apply(label), apply(n))
    case Resume(cont, args) => Resume(apply(cont), args map apply)
    case Resumed(cont, body) => Resumed(apply(cont), apply(body))
    case Primitive(name, args, returns, rest) =>
      Primitive(name, args map apply, returns, apply(rest)(using env -- returns.map(_.name)))
    case literal: Literal => literal
    case HandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      HandlerSugar.Handle(tpe, tag, handlers map { case (t, v) => (t, apply(v)) }, ret map apply, apply(body))
    case HandlerSugar.Op(tag, op, args, k, rtpe) =>
      HandlerSugar.Op(tag, op, args map apply, apply(k), rtpe)
    case DynamicHandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      DynamicHandlerSugar.Handle(tpe, apply(tag), handlers map { case (t, v) => (t, apply(v)) }, ret map apply, apply(body))
    case DynamicHandlerSugar.Op(tag, op, args, k, rtpe) =>
      DynamicHandlerSugar.Op(apply(tag), op, args map apply, apply(k), rtpe)
    case CallLib(lib, symbol, args, returnType) =>
      CallLib(apply(lib), symbol, args map apply, returnType)
    case LoadLib(path) =>
      LoadLib(apply(path))
    case DebugWrap(inner, annotations) =>
      DebugWrap(apply(inner), annotations)
    case ThisLib() => ThisLib()
  }
  def apply(d: Definition[O])(using Env, ErrorReporter, Emit[(Id, String)]): Definition[O] = d match {
    case Definition(name, binding, exportAs) => Definition(name, apply(binding), exportAs)
  }

  override def apply(f: Program[O])(using ErrorReporter): Program[O] = fixpoint(f){
    case Program(definitions, main) =>
      val additionalExportNames = new mutable.HashMap[Id, mutable.HashSet[String]]().withDefault{ _ => new mutable.HashSet[String]() }
      given Emit[(Id, String)] with {
        override def emit(a: (Id, String)): Unit = additionalExportNames(a._1) = additionalExportNames(a._1).addOne(a._2)
      }

      val (rdefs, inner) = binding(definitions)(using Env(Map.empty))
      given Env = inner
      val tDefs = rdefs map apply
      val tMain = apply(main)

      Program(tDefs map {
        case Definition(name, binding, exportAs) => Definition(name, binding, exportAs ++ additionalExportNames(name.name).toList)
      }, tMain)
  }

  ////////////////////////////////////////////////////////////////////////////////
  def invariant(f: Program[O]): Unit = ErrorReporter.assertNoError {ErrorReporter.withErrorsToStderr {
    def noUnboundVars(p: Program[O]): Unit = {
      import rpyeffectasm.mcore.analysis.FreeVariables
      val frees = FreeVariables(p).toList
      assert(frees.isEmpty, s"Unbound variables: ${frees.map(SExpPrettyPrinter.apply).mkString(", ")}.")
    }
    noUnboundVars(f)
  }}
  override def precondition(f: Program[O]): Unit = {
    super.precondition(f)
    invariant(f)
  }
  override def postcondition[Result >: Program[O]](t: Result): Unit = ErrorReporter.assertNoError {ErrorReporter.withErrorsToStderr {
    super.postcondition(t)
    // No alias definitions anywhere
    val noAliasDefinitions = new Visitor {
      override def definition: PartialFunction[Definition[ATerm], Unit] = {
        case Definition(name, alias: Var, exportAs) =>
          assert(false, s"Alias definition ${SExpPrettyPrinter(name)} = ${SExpPrettyPrinter(alias)} left after Dealiasing.")
      }
    }
    t match {
      case p: Program[O] =>
        invariant(p)
        noAliasDefinitions(p)
    }
//     // Preserved:
//     ClosureConversion.postcondition(t)
//     LambdaLifting.postcondition(t)
//     // All function vars are defined on the toplevel
//     t match {
//       case p@Program(definitions, main) =>
//         val q = new Query[Unit] {
//           override def term: PartialFunction[Term[ATerm], Unit] = {
//             case App(Var(x, _), args) =>
//               assert(definitions.exists { case Definition(y, _) => x == y.name }, s"Function ${x} is not defined on toplevel")
//               args.map(this.apply)
//           }
//
//           override def combine(xs: Iterable[Unit]): Unit = ()
//         }
//         q(p)
//     }
  }}

}
