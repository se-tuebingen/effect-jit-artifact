package rpyeffectasm.mcore
import rpyeffectasm.util.{Phase, ErrorReporter}
import collection.mutable
import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}

// TODO fixup expected types for arguments in calls based on callee type

object BindHelper {
  class Binder {
    var current: mutable.ListBuffer[(Definition[Var], Boolean)] = mutable.ListBuffer()
  }
  class Locator {
    var location: List[String] = Nil
  }

  def bind(t: Term[Var])(using B: Binder, ER: ErrorReporter, L: Locator): Var = {
    t match {
      case v: Var => v
      case t =>
        val outer = B.current
        val name = Var(new Generated(s"ANF at ${L.location.mkString(" in ")}:\n" + SExpPrettyPrinter(t)), Type.of(t))
        B.current.addOne((Definition(name, t, Nil), false))
        name
    }
  }
  def bindAs(t: Term[Var], tpe: Type)(using B: Binder, ER: ErrorReporter, L: Locator): Var = {
    t match {
      case v@Var(name, _) => Var(name, tpe)
      case t =>
        val outer = B.current
        val name = Var(new Generated(s"ANF at ${L.location.mkString(" in ")}:\n" + SExpPrettyPrinter(t)), tpe)
        B.current.addOne((Definition(name, t, Nil), false))
        name
    }
  }
  def let(d: Definition[Var])(body: Binder ?=> Term[Var])(using B: Binder, ER: ErrorReporter): Term[Var] = {
    B.current.addOne((d, false))
    body
  }

  def let(d: List[Definition[Var]])(body: Binder ?=> Term[Var])(using B: Binder, ER: ErrorReporter): Term[Var] = {
    B.current.addAll(d.map((_, false)))
    body
  }

  def letrec(d: Definition[Var])(body: Binder ?=> Term[Var])(using B: Binder, ER: ErrorReporter): Term[Var] = {
    B.current.addOne((d, true))
    body
  }

  def letrec(d: List[Definition[Var]])(body: Binder ?=> Term[Var])(using B: Binder, ER: ErrorReporter): Term[Var] = {
    for (bnd <- d) {
      emit(bnd)
    }
    body
  }

  def emit(d: Definition[Var])(using B: Binder): Unit = B.current.addOne((d, true))

  def bindHere(body: Binder ?=> Term[Var]): Term[Var] = {
    val innerBinder = new Binder
    var inner = body(using innerBinder)
    if(innerBinder.current.isEmpty){
      inner
    } else if(innerBinder.current.exists(_._2)) {
      LetRec(innerBinder.current.map(_._1).toList, inner)
    } else {
      innerBinder.current.map(_._1).foldRight(inner){ case (d, b) => Let(List(d), b)}
    }
  }

  def bindToplevel(body: Binder ?=> Unit): List[Definition[Var]] = {
    val binder = new Binder
    val inner = body(using binder)
    binder.current.map(_._1).toList
  }

  def in[R](str: String)(body: Locator ?=> R)(using L: Locator, errorReporter: ErrorReporter): R = {
    L.location = str :: L.location
    val r = body
    L.location = L.location.tail
    r
  }
  def in[R](name: Var)(body: Locator ?=> R)(using L: Locator, errorReporter: ErrorReporter): R = {
    in(SExpPrettyPrinter(name)){ body }
  }

}
/** ANF-ish transformation (binding all intermediate values) */
object ANF extends Phase[Program[ATerm], Program[Var]] {
  import BindHelper.*

  def apply(clause: Clause[ATerm])(using ErrorReporter, Binder, Locator): Clause[Var] = clause match {
    case Clause(params, body) => Clause(params, bindHere{apply(body)})
  }
  def apply(t: Term[ATerm])(using ErrorReporter, Binder, Locator): Term[Var] = t match {
    case v@Var(name, tpe) => v
    case Abs(params, body) => bind(Abs(params, bindHere{ apply(body) }))
    case App(fn, args) =>
      val tpes = Type.of(fn) match {
        case Function(params, ret, purity) => params
        case _ => args.map(Type.of)
      }
      App(bind(apply(fn)), (args zip tpes).map{ (arg, tpe) => bindAs(apply(arg), tpe) })
    case Let(Nil, body) => apply(body)
    case Let(defs, body) =>
      let(defs.map{
        case Definition(name, Abs(params, body), _) => Definition(name, in(name){ Abs(params, bindHere { apply(body)}) }, Nil)
        case Definition(name, binding, _) => Definition(name, in(name){ apply(binding) }, Nil)
      }){ apply(body) }
    case LetRec(Nil, body) => apply(body)
    case LetRec(defs, body) => defs.foreach {
        case Definition(name, Abs(params, body), _) => emit(Definition(name, in(name){ Abs(params, bindHere { apply(body)}) }, Nil))
        case Definition(name, binding, _) => emit(Definition(name, in(name){ apply(binding) }, Nil))
      }
      apply(body)
    case IfZero(cond, thn, els) => bindHere{ IfZero(bindAs(apply(cond.unroll), Base.Int), bindHere{ apply(thn) }, bindHere{ apply(els) }) }
    case Seq(ts) =>
      Seq(ts.map{ t => bindHere{ apply(t) }})
    case Construct(tpe_tag, tag, args) => Construct(tpe_tag, tag, args.map{ arg => bind(apply(arg)) })
    case Project(scrutinee, tpe_tag, tag, field) => Project(bind(apply(scrutinee)), tpe_tag, tag, field)
    case Match(scrutinee, tpe_tag, clauses, default_clause) =>
      Match(bind(apply(scrutinee.unroll)), tpe_tag, clauses.map {
        case (id, clause) => (id, apply(clause))
      }, apply(default_clause))
    case Switch(scrutinee, cases, default) =>
      Switch(bind(apply(scrutinee.unroll)), cases.map {
        case (v, t) => (v, bindHere{ apply(t) })
      }, bindHere{ apply(default) })
    case New(ifce_tag, methods) =>
      New(ifce_tag, methods.map {
        case (id, clause) => (id, apply(clause))
      })
    case Invoke(receiver, ifce_tag, method, args) =>
      Invoke(bind(apply(receiver)), ifce_tag, method, args.map{ arg => bind(apply(arg)) })
    case LetRef(ref, region, binding, body) => bindHere {
      LetRef(ref, bind(apply(region.unroll)), bind(apply(binding.unroll)), bindHere{ apply(body) })
    }
    case Load(ref) => Load(bind(apply(ref)))
    case Store(ref, value) => Store(bind(apply(ref)), bind(apply(value)))
    case FreshLabel() => FreshLabel()
    case Reset(label, region, bnd, body, ret) =>
      Reset(bind(apply(label.unroll)), region, bnd.map{ b => bind(apply(b.unroll)) }, bindHere{apply(body)}, apply(ret))
    case Shift(label, n, k, body, retTpe) => Shift(bind(apply(label.unroll)), bind(apply(n.unroll)), k, bindHere {
      apply(body)
    }, retTpe)
    case Control(label, n, k, body, retTpe) => Control(bind(apply(label.unroll)), bind(apply(n.unroll)), k, bindHere {
      apply(body)
    }, retTpe)
    case GetDynamic(label, n) => GetDynamic(bind(apply(label.unroll)), bind(apply(n.unroll)))
    case Primitive(name, args, returns, rest) =>
      import rpyeffectasm.common.{Primitives, Purity}
      Primitives.primitives.find{ p => p.name == name } match {
        case Some(p) =>
          val tArgs = (args zip p.insT).map{ case (t, tp) => bindAs(apply(t.unroll), tp.asMCore) }
          Primitive(name, tArgs, returns, bindHere{ apply(rest) })
        case None =>
          ErrorReporter.error(s"Unknown primitive '${name}'")
          Primitive(name, args.map{ a => bind(apply(a.unroll))}, returns, bindHere{apply(rest)})
      }
    case l: Literal => l
    case Resume(k, args) => bindHere{ Resume(bind(apply(k)), args map { a => bind(apply(a)) }) }
    case Resumed(k, body) => bindHere{
      Resumed(bind(apply(k.unroll)), bindHere{ apply(body) })
    }
    case DebugWrap(inner, annotations) =>
      DebugWrap(bindHere{ apply(inner) }, annotations)
    case LoadLib(path) => LoadLib(bindAs(apply(path.unroll), Base.String))
    case CallLib(lib, symbol, args, returnType) =>
      CallLib(bind(apply(lib.unroll)), symbol, args map { a => bind(apply(a.unroll)) }, returnType)
    case ThisLib() => ThisLib()
  }
  override def apply(f: Program[ATerm])(using ErrorReporter): Program[Var] = f match {
    case Program(definitions, main) =>
      given Locator = new Locator()
      Program(
        bindToplevel {
          definitions.foreach {
            case Definition(name, Abs(params, body), exportAs) => emit(Definition(name, in(name){ Abs(params, bindHere {
              apply(body)
            })}, exportAs))
            case Definition(name, binding, exportAs) => emit(Definition(name, in(name){ apply(binding) }, exportAs))
          }
        },
        bindHere{in("main"){apply(main)}})
  }

  /** Helper to fix-up terms that becom un-ANFed in later transformations. */
  def fixTerm(t: Term[ATerm])(using ErrorReporter, Locator): Term[Var] = {
    given Binder = new Binder
    bindHere{ apply(t) }
  }

  ////////////////////////////////////////////////////////////////////////////////
  override def postcondition[Result >: Program[Var]](t: Result): Unit = {
    super.postcondition(t)
    t match { case p: Program[Var] =>
      // No Let(Rec) in rhs of definition:
      (new Query[Unit] {
        override def definition: PartialFunction[Definition[ATerm], Unit] = {
          case Definition (name, binding: (Let[?] | LetRec[?] ), _) => assert (false, "Let/LetRec in rhs of definition.")
        }
        override def combine (xs: Iterable[Unit] ): Unit = ()
      }).apply(p)
    }
  }

}
