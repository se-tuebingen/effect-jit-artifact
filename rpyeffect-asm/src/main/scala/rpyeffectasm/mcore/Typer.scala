package rpyeffectasm
package mcore
import rpyeffectasm.util.ErrorReporter
import rpyeffectasm.util.ErrorReporter.*
import rpyeffectasm.util.Phase
import rpyeffectasm.common.Primitives

object Typer {

  def warn(msg: String)(using ErrorReporter): Unit = {} // TODO

  case class Binding(id: Id, tpe: Type)
  type Env = List[Binding]

  def precheck(d: Definition[ATerm])(using ErrorReporter): Binding = d match {
    case Definition(name, binding, exportAs) => Binding(name.name, name.tpe)
  }

  def lookup(env: Env, name: Id)(using ErrorReporter): Type = {
    env.find { b => b.id == name }.map(_.tpe).getOrElse {
      error(s"Unbound variable ${name}."); Top
    }
  }

  case class PosInfo(at: String)

  extension(l: common.Purity) def flowsInto(r: common.Purity)(using e: ErrorReporter, p: PosInfo): Unit = (l,r) match {
    case (l,r) if l == r => ()
    case (common.Purity.Pure,_) => ()
    case (l,r) => () // error("Purity mismatch")
  }
  extension(l: Type) def flowsInto(r: Type)(using e: ErrorReporter, p: PosInfo): Unit = (l,r) match {
    case (x,y) if x isSubtypeOf y => ()
    case (_,Top) => ()
    case (Top, Num | Base.Int | Base.Double) => warn(s"Unboxing top to ${r}."); () // OK, boxing
    case (Top, _) => warn(s"Implicitly downcasting to ${r}."); () // OK, boxing
    case (Function(params1, ret1, e1), Function(params2, ret2, e2)) if params1.length == params2.length =>
        e1 flowsInto e2
        (params1 zip params2).foreach{ (p1, p2) => p2 flowsInto p1 }
        ret1 flowsInto ret2
    case (Codata(_, ms1), Codata(_, ms2)) =>
      ms2.foreach { case Method(tag2, params2, ret2) =>
        ms1.find(_.tag == tag2).getOrElse {
          error(s"${SExpPrettyPrinter.apply(l)} has no method ${tag2}")
        } match {
          case Method(tag1, params1, ret1) if tag1 == tag2 =>
            (params1 zip params2).foreach { (p1, p2) => p2 flowsInto p1 }
            ret1 flowsInto ret2
          case _ => ()
        }
      }
    case (l,r) => error(
      s"""Type mismatch:
         | ${SExpPrettyPrinter.apply(l)}
         |   flows into
         | ${SExpPrettyPrinter.apply(r)}
         |   at
         | ${p.at}.""".stripMargin)
  }


  def check(t: Term[ATerm], env: Env)(using ErrorReporter): Type = {
    given PosInfo = PosInfo(SExpPrettyPrinter.apply(t))
    t match {
      case Var(name, tpe) => lookup(env, name) flowsInto tpe; tpe
      case Abs(params, body) =>
        val tParams = params map { case Var(n, t) => Binding(n, t) }
        val Function(_, _, purity) = Type.of(t)
        Function(tParams.map{ p => p.tpe }, check(body, tParams ++ env), purity) // TODO effectfulness
      case App(fn, args) =>
        val tFn = check(fn, env)
        val tArgs = args.map(check(_, env))
        tFn match {
          case Top | Ptr => Top
          case Bottom => Bottom
          case Function(params, ret, purity) =>
            if (params.length != tArgs.length) {
              error(s"Passing ${tArgs.length} arguments to a function with only ${params.length} parameters.")
            }
            (tArgs zip params) foreach { case (a, p) => a flowsInto p }
            ret
          case Codata(ifce_tag, List(Method(tag, params, ret))) =>
            error(s"Calling interface ${ifce_tag} as a normal function.")
            if (params.length != tArgs.length) {
              error(s"Passing ${tArgs.length} arguments to a method with only ${params.length} parameters.")
            }
            ret
          case t => error(s"Cannot call value of type ${t}."); Top
        }
      case Seq(ts) => ts.map(check(_, env)).last
      case Let(defs, body) =>
        val bnds = defs.map(check(_, env))
        check(body, bnds ++ env)
      case LetRec(defs, body) =>
        val bnds = defs map precheck
        defs.foreach { d => check(d, bnds ++ env) }
        check(body, bnds ++ env)
      case IfZero(cond, thn, els) =>
        check(cond.unroll, env) flowsInto Base.Int
        check(thn, env) join check(els, env)
      case Construct(tpe_tag, tag, args) =>
        val tArgs = args.map(check(_, env))
        Data(tpe_tag, List(Constructor(tag, tArgs)))
      case Project(scrutinee, tpe_tag, tag, field) =>
        check(scrutinee, env) match {
          case Top | Ptr => Top
          case Bottom => Bottom
          case Data(type_tag, constructors) =>
            if (type_tag != tpe_tag) {
              error(s"Type tags dont match for projection: ${tpe_tag} expected, got ${type_tag}")
            }
            val fs = constructors.find { c => c.tag == tag }.map(_.fields).getOrElse {
              error(s"${scrutinee} has no constructor ${tag}"); List.fill(field+1)(Top)
            }
            if (fs.length <= field) {
              error(s"Constructor ${tag} has no ${field}th field.")
            }
            fs(field)
          case o => error(s"Cannot project out of ${o}."); Top
        }
      case Match(scrutinee, tpe_tag, clauses, Clause(params, body)) =>
        val expected = Data(tpe_tag, clauses map { case t -> Clause(params, body) => Constructor(t, params.map(_.tpe)) })
        check(scrutinee.unroll, env) flowsInto expected
        if (params.length != 0) {
          error("Default clause cannot have parameters.")
        }
        val tDefault = check(body, env)
        val tClauses = clauses.map {
          case t -> Clause(params, body) =>
            val tParams = params map { p => Binding(p.name, p.tpe) }
            check(body, tParams ++ env)
        }
        tClauses.fold(tDefault)(_ join _)
      case Switch(scrutinee, cases, default) =>
        val expected = Base.Int
        check(scrutinee.unroll, env) flowsInto expected
        val tDefault = check(default, env)
        val tCases = cases.map {
          case v -> t => check(t, env)
        }
        tCases.fold(tDefault)(_ join _)
      case New(ifce_tag, methods) =>
        val tMethods = methods.map { case m -> Clause(params, body) =>
          val tParams = params map { p => Binding(p.name, p.tpe) }
          Method(m, params.map(_.tpe), check(body, tParams ++ env))
        }
        Codata(ifce_tag, tMethods)
      case Invoke(receiver, ifce_tag, method, args) =>
        val tArgs = args.map(check(_, env))
        check(receiver, env) match {
          case Top | Ptr => Top
          case Bottom => Bottom
          case Codata(ifce_tag_g, List(Method(tag, params, ret))) if ifce_tag != ifce_tag_g =>
            error("Interface tags don't match up for invoke.")
            if (params.length != args.length) {
              error(s"Invoked method with ${args.length} arguments, but expected ${params.length}.")
            }
            (tArgs zip params).foreach { case (a, p) => a flowsInto p }
            ret
          case Codata(ifce_tag_g, methods) =>
            if (ifce_tag_g != ifce_tag) {
              error("Interface tags don't match up for invoke")
            }
            val Method(_, params, ret) = methods.find { m => m.tag == method }.getOrElse {
              error(s"${ifce_tag} has no method ${method}.")
            }
            if (params.length != args.length) {
              error(s"Invoked method with ${args.length} arguments, but expected ${params.length}.")
            }
            (tArgs zip params).foreach { case (a, p) => a flowsInto p }
            ret
          case other => error(s"Cannot invoke ${other}."); Top
        }
      case LetRef(ref, region, binding, body) =>
        val tRef = ref.tpe.deref
        check(binding.unroll, env) flowsInto tRef
        check(region.unroll, env) flowsInto Region
        check(body, Binding(ref.name, Ref(tRef)) :: env)
      case Load(ref) =>
        check(ref, env).deref
      case Store(ref, value) =>
        check(value, env) flowsInto (check(ref, env).deref)
        Base.Unit
      case FreshLabel() => Base.Label(Top, None)
      case Reset(label, region, bnd, body, Clause(params, rbody)) =>
        val tBody = check(body, Binding(region.name, Region) :: env)
        val tBnd = bnd.map{ b => check(b.unroll, env) }
        check(label.unroll, env) flowsInto Base.Label(tBody, tBnd)
        if (params.length != 1) {
          error("Multiple-return reset is not supported.")
        }
        tBody flowsInto params.head.tpe
        check(rbody, Binding(params.head.name, tBody) :: env)
      case Shift(label, n, k, body, tpe) =>
        check(n.unroll, env) flowsInto Base.Int
        val resTpe = check(body, Binding(k.name, k.tpe) :: env)
        check(label.unroll, env) flowsInto Base.Label(resTpe, None)
        Stack(tpe, List(resTpe)) flowsInto k.tpe // TODO ???
        tpe
      case Control(label, n, k, body, tpe) =>
        check(n.unroll, env) flowsInto Base.Int
        val resTpe = check(body, Binding(k.name, k.tpe) :: env)
        check(label.unroll, env) flowsInto Base.Label(resTpe, None)
        Stack(tpe, List(resTpe)) flowsInto k.tpe // TODO ???
        tpe
      case GetDynamic(label, n) =>
        check(n.unroll, env) flowsInto Base.Int
        val tlbl = check(label.unroll, env)
        tlbl match {
          case Base.Label(_, Some(r)) => r
          case _ => Top
        }
      case Resume(cont, args) =>
        val tArgs = args.map(check(_, env))
        check(cont, env) match {
          case Top | Ptr => Top
          case Bottom => Bottom
          case Stack(resume_ret, resume_args) =>
            if (resume_args.length != tArgs.length) {
              error(s"Number of arguments to resume does not match: ${resume_args.length} expected, got ${tArgs.length}.")
            }
            (tArgs zip resume_args).foreach { case (a, p) => a flowsInto p }
            resume_ret
          case r => error(s"Cannot resume ${r}."); Top
        }
      case Resumed(cont, body) =>
        val tBody = check(body, env)
        check(cont.unroll, env) match {
          case Top | Ptr => Top
          case Bottom => Bottom
          case Stack(resume_ret, resume_args) =>
            if (resume_args.length != 1) {
              error(s"Number of arguments to resume does not match: ${resume_args.length} expected, got 1.")
            }
            tBody flowsInto (resume_args.head)
            resume_ret
          case r => error(s"Cannot resume ${r}."); Top
        }
      case Primitive(name, args, returns, rest) =>
        val tArgs = args.map { a => check(a.unroll, env) }
        val tRets = returns map { p => Binding(p.name, p.tpe) }


        val rTpes = withLocation(s"In call to primitive '${name}'") {
          Primitives.primitives.find { p => p.name == name } match {
            case Some(p) =>
              (tArgs zip p.insT).foreach { (a, t) => a flowsInto (t.asMCore) }
              (p.outsT zip tRets).foreach { (t, r) => (t.asMCore) flowsInto (r.tpe) }
            case None => ErrorReporter.error(s"Unknown primitive '${name}'"); returns.map(_.tpe)
          }
        }
        // TODO check primitive call
        check(rest, tRets ++ env)
      case literal: Literal => literal.tpe
      case DebugWrap(inner, annotations) => check(inner, env)
      case LoadLib(path) =>
        check(path.unroll, env) flowsInto Base.String
        Ptr
      case CallLib(lib, symbol, args, returnType) =>
        check(lib.unroll, env) flowsInto Ptr
        args.foreach{ a => check(a.unroll, env) }
        returnType
      case ThisLib() =>
        Ptr
      case sugar: Sugar => withLocation(s"In desugaring of ${SExpPrettyPrinter(sugar)}") {
        check(sugar.desugared, env)
      }
    }
  }
  def check(d: Definition[ATerm], env: Env)(using ErrorReporter): Binding = d match {
    case Definition(name, binding, exportAs) =>
      given PosInfo = PosInfo(s"definition of ${SExpPrettyPrinter.apply(name)}")
      val t = check(binding, env)
      t flowsInto name.tpe
      Binding(name.name, t)
  }

  def check(p: Program[ATerm])(using ErrorReporter): Type = p match {
    case Program(definitions, main) =>
      val genv = definitions map precheck
      definitions.foreach{ d => check(d, genv) }
      check(main, genv)
  }

  class Check[O <: ATerm] extends Phase[Program[O], Type] {
    override def apply(f: Program[O])(using E: ErrorReporter): Type = {
      val r = check(f)
      if(E.hasErrors) {
        fatal("Type errors found.")
      }
      r
    }
  }
}