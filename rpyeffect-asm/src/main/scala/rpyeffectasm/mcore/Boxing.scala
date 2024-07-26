package rpyeffectasm
package mcore
import rpyeffectasm.util.{Phase, ErrorReporter, Emit}
import rpyeffectasm.common.Purity

class Boxing extends Phase[Program[Var], Program[Var]] {
  type O = Var

  trait Coercer {
    def apply(t: Typed[Term[O]]): Typed[Term[O]]
    def apply(v: Var): Term[O] = apply(Typed(v, v.tpe)).get
  }
  object Coercer {
    object Identity extends Coercer {
      override def apply(t: Typed[Term[O]]): Typed[Term[O]] = t
    }
  }

  def Let(defs: List[Definition[O]], body: Term[O]): Term[O] = {
    if defs.isEmpty then body else mcore.Let(defs, body)
  }

  def coercer(from: Type, to: Type)(using ErrorReporter, Emit[Definition[O]]): Coercer = (from, to) match {
    case (f,t) if f == t => Coercer.Identity
    case (NumType(), Ptr | Top | Bottom) => (unboxed: Typed[Term[O]]) =>
      val vunboxed = Var(new Generated("unboxed value"), from)
      val vboxed = Var(new Generated("boxed value"), to)
      Typed(Let(List(Definition(vunboxed, unboxed.get, Nil)),
        Primitive("box(Num): Ptr", List(vunboxed), List(vboxed), vboxed)),
        Ptr)
    case (Ptr | Top | Bottom, NumType()) => (boxed: Typed[Term[O]]) =>
      val vboxed = Var(new Generated("boxed value"), from)
      val vunboxed = Var(new Generated("unboxed value"), to)
      Typed(Let(List(Definition(vboxed, boxed.get, Nil)),
        Primitive("unbox(Ptr): Num", List(vboxed), List(vunboxed), vunboxed)),
        to)
    case (Ref(NumType()), Ref(NumType())) => Coercer.Identity
    case (Ref(PtrType()), Ref(PtrType())) => Coercer.Identity
    case (Ref(to1), Ref(to2)) => ErrorReporter.fatal(s"Cannot cast ${from} to ${to}.")
    case (PtrType(), PtrType()) => Coercer.Identity
    case (NumType(), NumType()) => Coercer.Identity
    case (Function(fparams, fret, _), Function(tparams, tret, tpu)) if fparams.sizeCompare(tparams) == 0 =>
      val pcoercers = (fparams zip tparams).map{ (f,t) => coercer(t, f) }
      val rcoercer = coercer(fret, tret)
      if((rcoercer :: pcoercers).forall(_ == Coercer.Identity)) {
        Coercer.Identity
      } else { (wrapped: Typed[Term[O]]) =>
        wrapped.get match {
          case w@Abs(params, body) =>
            val pcoercers = (params zip tparams).map { (p, e) => coercer(e, apply(p.tpe)) }
            val nparams = (pcoercers zip params zip tparams).map { case ((c, p), e) =>
              if c == Coercer.Identity then apply(p) else Var(new Generated("coerced param"), e)
            }
            val ndefs = (pcoercers zip nparams zip params).collect { case ((c,n: Var), p) if c != Coercer.Identity =>
              Definition(p, c(n), Nil)
            }
            val tbody = if rcoercer == Coercer.Identity then Typed(body,tret) else rcoercer(Typed(body, fret))
            Typed(Abs(nparams, Let(ndefs, tbody.get)),
              Function(nparams.map(_.tpe), tbody.tpe, tpu))
          case v@Var(_,_) =>
            val nparams = tparams.map { t => Var(new Generated("eta-expansion param"), t) }
            val wargs = (pcoercers zip fparams zip nparams).map { case ((c, f), n) =>
              if (c == Coercer.Identity) { n } else { Var(new Generated("coerced param"), f) }
            }
            val ret = Var(new Generated("eta-expansion ret"), fret)
            val wdefs = (pcoercers zip nparams zip wargs).collect { case ((c, n), w) if c != Coercer.Identity =>
              Definition(w, c(n), Nil)
            }
            val rn = Var(new Generated("eta-expanded fn"), apply(to))
            Emit.emit(Definition(rn, Abs(nparams,
              Let(wdefs,
                Let(List(Definition(ret, App(v, wargs), Nil)),
                  rcoercer(ret)))), Nil))
            Typed(rn, to)
          case _ =>
            val nparams = tparams.map { t => Var(new Generated("eta-expansion param"), t) }
            val wargs = (pcoercers zip fparams zip nparams).map { case ((c, f), n) =>
              if (c == Coercer.Identity) { n } else { Var(new Generated("coerced param"), f) }
            }
            val ret = Var(new Generated("eta-expansion ret"), tret)
            val w = Var(new Generated("eta-expanded fn"), from)
            val wdefs = (pcoercers zip nparams zip wargs).collect { case ((c, n), w) if c != Coercer.Identity =>
              Definition(w, c(n), Nil)
            }
            val rn = Var(new Generated("eta-expanded fn"), apply(to))
            Emit.emit(Definition(rn, Abs(nparams,
              Let(wdefs,
                Let(List(Definition(w, wrapped.get, Nil)),
                  Let(List(Definition(ret, App(w, wargs), Nil)),
                    rcoercer(ret))))), Nil))
            Typed(rn, to)
        }

      }
    case (t, Bottom) => Coercer.Identity // OK because dead code
    case _ => ErrorReporter.fatal(s"Cannot coerce ${from} to ${to}.")
  }
  def coercer(from: Type, to: Option[Type])(using ErrorReporter, Emit[Definition[O]]): Coercer = to match {
    case Some(to) => coercer(from, to)
    case None => Coercer.Identity
  }

  def apply(t: Type): Type = t match {
    case Top => Ptr
    // Recursive and identity cases
    case Ptr | Num | Bottom => t
    case Function(params, ret, purity) =>
      Function(params map apply, apply(ret), purity)
    case Codata(ifce_tag, methods) =>
      Codata(ifce_tag, methods map {
        case Method(tag, params, ret) =>
          Method(tag, params map apply, apply(ret))
      })
    case Data(type_tag, constructors) =>
      Data(type_tag, constructors map {
        case Constructor(tag, fields) =>
          Constructor(tag, fields map apply)
      })
    case Stack(resume_ret, resume_args) =>
      Stack(apply(resume_ret), resume_args map apply)
    case Ref(to) => Ref(apply(to))
    case Base.Label(at, bnd) => Base.Label(apply(at), bnd.map(apply))
    case base: Base => base
  }

  case class Typed[T](get: T, tpe: Type)

  def apply(d: Definition[O], env: Map[Id, Type])(using ErrorReporter, Emit[Definition[O]]): Definition[O] = d match {
    case Definition(name, binding, exportAs) =>
      Definition(name, apply(binding, env, Some(name.tpe)).get, exportAs)
  }
  def extend(env: Map[Id, Type], binds: List[LhsOperand]): Map[Id, Type] = {
    env ++ (binds.map { p => p.name -> apply(p.tpe) }.toMap)
  }
  extension(self: Typed[Term[O]]) def bind(doc: String)(body: Var => Typed[Term[O]]): Typed[Term[O]] = self.get match {
    case v: Var => body(v)
    case _ =>
      val v = Var(new Generated(doc), self.tpe)
      val tbody = body(v)
      Typed(Let(List(Definition(v, self.get, Nil)), tbody.get), tbody.tpe)
  }
  extension (self: Option[Typed[Term[O]]]) def bind(doc: String)(body: Option[Var] => Typed[Term[O]]): Typed[Term[O]] = self match {
    case Some(self) => self.bind(doc){ v => body(Some(v)) }
    case None => body(None)
  }
  extension (self: List[Typed[Term[O]]]) def bind(doc: String)(body: List[Var] => Typed[Term[O]]): Typed[Term[O]] = {
    val nvars = self.map { v => v.get match {
      case x: Var => x
      case _ => Var(new Generated(doc), v.tpe)
    }}
    val binds = (self zip nvars).collect {
      case (v,w) if v.get != w => Definition(w, v.get, Nil)
    }
    if binds.isEmpty then body(nvars) else {
      val tbody = body(nvars)
      Typed(Let(binds, tbody.get), tbody.tpe)
    }
  }

  extension(self: Typed[Term[O]]) def as(expected: Option[Type])(using ErrorReporter, Emit[Definition[O]]): Typed[Term[O]] = {
    val coerced = coercer(self.tpe, expected)(self)
    coerced
  }

  def apply(p: LhsOperand): LhsOperand = p match {
    case Var(name, tpe) => Var(name, apply(tpe))
  }

  def apply(t: Term[O], env: Map[Id, Type], expected: Option[Type])(using ErrorReporter, Emit[Definition[O]]): Typed[Term[O]] = { (t match {
    case Var(name, annotatedTpe) =>
      val tpe = env.getOrElse(name, apply(annotatedTpe))
      expected match {
        case Some(etpe) => coercer(tpe, etpe) match {
          case Coercer.Identity => Typed(Var(name, etpe meet tpe), etpe meet tpe)
          case c => Typed(c(Var(name, tpe)), etpe)
        }
        case None => coercer(tpe, annotatedTpe) match {
          case Coercer.Identity => Typed(Var(name, annotatedTpe meet tpe), annotatedTpe meet tpe)
          case c =>
            Typed(c(Var(name, tpe)), annotatedTpe)
        }
      }
    case Abs(params, body) =>
      val tparams = params.map(apply)
      expected match {
        case Some(Function(eparams, eret, epu)) =>
          val pcoercers = (params zip eparams).map { (p, e) => coercer(e, apply(p.tpe)) }
          val nparams = (pcoercers zip params zip eparams).map { case ((c, p), e) =>
            if c == Coercer.Identity then apply(p) else Var(new Generated("coerced param"), e)
          }
          val ndefs = (pcoercers zip nparams zip params).collect { case ((c,n: Var), p) if c != Coercer.Identity =>
            Definition(p, c(n), Nil)
          }
          val tbody = apply(body, extend(env, nparams), Some(eret))
          Typed(Abs(nparams, Let(ndefs, tbody.get)),
            Function(nparams.map(_.tpe), tbody.tpe, epu))
        case _ =>
          val tBody = apply(body, extend(env, params), None)
          Typed(Abs(params, tBody.get), Function(params.map(_.tpe), tBody.tpe, Purity.Effectful))
      }
    case App(fn, args) =>
      val (tfn, targs) = expected match {
        case _ =>
          val tfn = apply(fn, env, None)
          tfn.tpe match {
            case Function(params, ret, purity) =>
              val targs = (args zip params).map { (a, p) => apply(a, env, Some(p)) }
              (tfn, targs)
            case _ =>
              val targs = args.map { a => apply(a, env, None) }
              (tfn, targs)
          }
      }
      targs.bind("coerced arg"){ nargs =>
        tfn.bind("coerced fn") { nfn =>
          val rtpe =  tfn.tpe match {
            case Function(params, ret, purity) => ret
            case _ => Bottom
          }
          Typed(App(nfn, nargs), rtpe)
        }
      }
    case Seq(Nil) => Typed(Seq(Nil), Base.Unit)
    case Seq(ts) =>
      val tinit = ts.init.map(apply(_, env, Some(Base.Unit))).map(_.get)
      val tret = apply(ts.last, env, expected)
      Typed(Seq(tinit :+ tret.get), tret.tpe)
    case Let(defs, body) =>
      val tdefs = defs.map(apply(_, env))
      val tbody = apply(body, extend(env, tdefs.map(_.name)), expected)
      Typed(Let(tdefs, tbody.get), tbody.tpe)
    case LetRec(defs, body) =>
      val inner = extend(env, defs.map(_.name))
      val tdefs = defs.map(apply(_, inner))
      val tbody = apply(body, inner, expected)
      Typed(LetRec(tdefs, tbody.get), tbody.tpe)
    case IfZero(cond, thn, els) =>
      val tcond = apply(cond, env, Some(Base.Int))
      val tthn = apply(thn, env, expected)
      val tels = apply(els, env, expected.orElse{ Some(tthn.tpe) })
      tcond.bind("coerced cond"){ ncond =>
        Typed(IfZero(ncond, tthn.get, tels.get), tels.tpe)
      }
    case Construct(tpe_tag, tag, args) =>
      val targs = expected match {
        case Some(Data(ttag, constructors)) if ttag == tpe_tag && constructors.exists{ c => c.tag == tag } =>
          val cns = constructors.find{ c => c.tag == tag }.get
          assert(cns.fields.sizeCompare(args) == 0)
          (args zip cns.fields).map { (a,f) => apply(a, env, Some(f)) }
        case _ =>
          args.map { a => apply(a, env, None) }
      }
      targs.bind("coerced field"){ nargs =>
        Typed(Construct(tpe_tag, tag, nargs),
          Data(tpe_tag, List(Constructor(tag, nargs.map(_.tpe)))))
      }
    case Project(scrutinee, tpe_tag, tag, field) =>
      val tscrutinee = apply(scrutinee, env, None)
      tscrutinee.bind("coerced scrutinee") { nscrutinee =>
        tscrutinee.tpe match {
          case Data(type_tag, constructors) if type_tag == tpe_tag && constructors.exists { c => c.tag == tag } =>
            val cns = constructors.find { c => c.tag == tag }.get
            assert(cns.fields.sizeIs > field)
            coercer(cns.fields(field), expected)(Typed(Project(nscrutinee, tpe_tag, tag, field), cns.fields(field)))
          case _ =>
            Typed(Project(nscrutinee, tpe_tag, tag, field), Bottom)
        }
      }
    case Match(scrutinee, tpe_tag, clauses, default_clause) =>
      val tscrutinee = apply(scrutinee, env, None)
      val tdefault = default_clause match {
        case Clause(params, body) =>
          val tparams = params.map(apply)
          val tbody = apply(body, extend(env, tparams), expected)
          Typed(Clause(tparams, tbody.get), tbody.tpe)
      }
      tscrutinee.tpe match {
        case Data(type_tag, constructors) if tpe_tag == type_tag =>
          val tclauses = clauses.map {
            case (tag, Clause(params, body)) =>
              constructors.find{ c => c.tag == tag } match {
                case Some(Constructor(tag, fields)) =>
                  val pcoercers = (params zip fields).map{ (p, f) => coercer(f, apply(p.tpe)) }
                  val nparams = (pcoercers zip params zip fields).map { case ((c, p), e) =>
                    if c == Coercer.Identity then apply(p) else Var(new Generated("original field"), e)
                  }
                  val ndefs = (pcoercers zip nparams zip params).collect { case ((c,n), p) if c != Coercer.Identity =>
                    Definition(p, c(n), Nil)
                  }
                  val tbody = apply(body, extend(env, params.map(apply)), expected.orElse(Some(tdefault.tpe)))
                  Typed((tag, Clause(nparams, Let(ndefs, tbody.get))), tbody.tpe)
                case _ =>
                  val tparams = params.map(apply)
                  val tbody = apply(body, extend(env, tparams), expected.orElse(Some(tdefault.tpe)))
                  Typed((tag, Clause(tparams, tbody.get)), tbody.tpe)
              }
          }
          tscrutinee.bind("coerced scrutinee"){ nscrutinee =>
            Typed(Match(nscrutinee, tpe_tag, tclauses.map(_.get), tdefault.get), tclauses.lastOption.map(_.tpe).getOrElse(tdefault.tpe))
          }
        case _ =>
          val tclauses = clauses.map {
            case (tag, Clause(params, body)) =>
              val tparams = params.map(apply)
              val tbody = apply(body, extend(env, tparams), expected.orElse(Some(tdefault.tpe)))
              Typed((tag, Clause(tparams, tbody.get)), tbody.tpe)
          }
          tscrutinee.bind("coerced scrutinee"){ nscrutinee =>
            Typed(Match(nscrutinee, tpe_tag, tclauses.map(_.get), tdefault.get), tclauses.lastOption.map(_.tpe).getOrElse(tdefault.tpe))
          }
      }

    case Switch(scrutinee, cases, default) =>
      apply(scrutinee, env, Some(Base.Int)).bind("coerced scrutinee"){ nscrutinee =>
        val tdefault = apply(default, env, expected)
        val tcases = cases.map { (i, body) => (i, apply(body, env, expected.orElse(Some(tdefault.tpe))).get) }
        Typed(Switch(nscrutinee, tcases, tdefault.get), tdefault.tpe)
      }
    case New(ifce_tag, methods) =>
      val emethods = expected match {
        case Some(Codata(itag, emethods)) if itag == ifce_tag => emethods
        case _ => Nil
      }
      val tmethods = methods.map { case (tag, Clause(params, body)) =>
        emethods.find { m => m.tag == tag } match {
          case Some(Method(tag, eparams, eret)) =>
            val pcoercers = (params zip eparams).map { (p, e) => coercer(e, apply(p.tpe)) }
            val nparams = (pcoercers zip params zip eparams).map { case ((c, p), e) =>
              if c == Coercer.Identity then apply(p) else Var(new Generated("coerced param"), e)
            }
            val ndefs = (pcoercers zip nparams zip params).collect { case ((c, n: Var), p) if c != Coercer.Identity =>
              Definition(p, c(n), Nil)
            }
            val tbody = apply(body, extend(env, nparams), Some(eret))
            (tag, Clause(nparams, Let(ndefs, tbody.get)), tbody.tpe)
          case _ =>
            val tparams = params.map(apply)
            val tbody = apply(body, extend(env, tparams), None)
            (tag, Clause(tparams, tbody.get), tbody.tpe)
        }
      }
      Typed(New(ifce_tag, tmethods.map {
        case (tag, cls, _) => (tag, cls)
      }), Codata(ifce_tag, tmethods.map {
        case (tag, Clause(ps, _), ret) => Method(tag, ps.map(_.tpe), ret)
      }))
    case Invoke(receiver, ifce_tag, method, args) =>
      val trecv = apply(receiver, env, None)
      val targs = {
          trecv.tpe match {
            case Codata(ifce_tag, methods) if methods.exists{ m => m.tag == method } =>
              val m = methods.find{ m => m.tag == method }.get
              assert(m.params.sizeCompare(args) == 0)
              (args zip m.params).map{ (a, p) => apply(a, env, Some(p)) }
            case _ =>
              args.map{ a => apply(a, env, None) }
          }
      }
      val rtpe = trecv.tpe match {
        case Codata(itag, methods) if itag == ifce_tag && methods.exists{ m => m.tag == method } =>
          methods.find{ m => m.tag == method }.get match {
            case Method(tag, params, ret) =>
              ret
          }
        case _ => Bottom
      }
      trecv.bind("coerced recv") { nrecv =>
        targs.bind("coerced arg") { nargs =>
          Typed(Invoke(nrecv, ifce_tag, method, nargs), rtpe)
        }
      }
    case LetRef(ref, region, binding, body) =>
      val tregion = apply(region, env, Some(Region))
      val tbinding = apply(binding, env, ref.tpe match {
        case Ref(to) => Some(to)
        case _ => None
      })
      val tref = Var(ref.name, Ref(tbinding.tpe))
      val inner = extend(env, List(tref))
      val tbody = apply(body, inner, expected)
      tregion.bind("coerced region"){ nregion =>
        tbinding.bind("coerced initial value"){ nbinding =>
          Typed(LetRef(tref, nregion, nbinding, tbody.get), tbody.tpe)
        }
      }
    case Load(ref) =>
      val tref = apply(ref, env, None)
      tref.bind("coerced ref"){ nref =>
        Typed(Load(nref), tref.tpe match {
          case Ref(to) => to
          case _ => Ptr
        })
      }
    case Store(ref, value) =>
      val tref = apply(ref, env, None)
      val tval = apply(value, env, tref.tpe match {
        case Ref(to) => Some(to)
        case _ => None
      })
      tref.bind("coerced ref"){ nref =>
        tval.bind("coerced value"){ nval =>
          Typed(Store(nref, nval), Base.Unit)
        }
      }
    case FreshLabel() => Typed(FreshLabel(), Ptr)
    case Reset(label, region, bnd, body, ret) =>
      expected match {
        case Some(eret) =>
          val tbnd = bnd.map{ b => apply(b, env, Some(Ptr)) }
          val tlabel = apply(label, env, Some(Base.Label(eret, tbnd.map(_.tpe))))
          val tbody = apply(body, extend(env, List(region, Var(label.name, tlabel.tpe))), Some(apply(ret.params.head.tpe)))
          val tret = apply(ret.body, extend(env, ret.params), Some(eret))
          tlabel.bind("coerced label"){ nlabel =>
            tbnd.bind("coerced binding") { nbnd =>
              Typed(Reset(nlabel, region, nbnd, tbody.get, Clause(ret.params.map(apply), tret.get)), eret)
            }
          }
        case None =>
          val tbnd = bnd.map{ b => apply(b, env, Some(Ptr)) }
          val tret = apply(ret.body, extend(env, ret.params), None)
          val eret = tret.tpe
          val tlabel = apply(label, env, Some(Base.Label(eret, tbnd.map(_.tpe))))
          val tbody = apply(body, extend(env, List(region, Var(label.name, tlabel.tpe))), Some(apply(ret.params.head.tpe)))
          tlabel.bind("coerced label"){ nlabel =>
            tbnd.bind("coerced binding"){ nbnd =>
              Typed(Reset(nlabel, region, nbnd, tbody.get, Clause(ret.params.map(apply), tret.get)), eret)
            }
          }
      }
    case Shift(label, n, k, body, retTpe) =>
      val tn = apply(n, env, Some(Base.Int))
      val tlabel = apply(label, env, None)
      val (nk, tbody) = k.tpe match {
        case Stack(resume_ret, resume_args) =>
          val tk = apply(k)
          val tbody = apply(body, extend(env, List(tk)), Some(resume_ret))
          (tk, tbody)
        case _ =>
          tlabel.tpe match {
            case Base.Label(at,_) =>
              val tk = Var(k.name, Stack(at, List(expected.getOrElse(apply(retTpe)))))
              val tbody = apply(body, extend(env, List(tk)), Some(at))
              (tk, tbody)
            case _ =>
              (apply(k), apply(body, extend(env, List(apply(k))), None))
          }
      }
      tlabel.bind("coerced label"){ nlabel =>
        tn.bind("coerced offset"){ nn =>
          Typed(Shift(nlabel, nn, nk, tbody.get, apply(retTpe)), apply(retTpe))
        }
      }
    case Control(label, n, k, body, retTpe) =>
      val tn = apply(n, env, Some(Base.Int))
      val tlabel = apply(label, env, None)
      val (nk, tbody) = k.tpe match {
        case Stack(resume_ret, resume_args) =>
          val tk = apply(k)
          val tbody = apply(body, extend(env, List(tk)), Some(resume_ret))
          (tk, tbody)
        case _ =>
          tlabel.tpe match {
            case Base.Label(at, _) =>
              val tk = Var(k.name, Stack(at, List(expected.getOrElse(apply(retTpe)))))
              val tbody = apply(body, extend(env, List(tk)), Some(at))
              (tk, tbody)
            case _ =>
              (apply(k), apply(body, extend(env, List(apply(k))), None))
          }
      }
      tlabel.bind("coerced label"){ nlabel =>
        tn.bind("coerced offset"){ nn =>
          Typed(Shift(nlabel, nn, nk, tbody.get, apply(retTpe)), apply(retTpe))
        }
      }
    case GetDynamic(label, n) =>
      val tn = apply(n, env, Some(Base.Int))
      val tlabel = apply(label, env, None)
      tlabel.tpe match {
        case Base.Label(_, Some(t)) =>
          tlabel.bind("coerced label"){ nlabel =>
            tn.bind("coerced n"){ nn =>
              Typed(GetDynamic(nlabel, nn), t)
            }
          }
        case _ =>
          tlabel.bind("coerced label"){ nlabel =>
            tn.bind("coerced n"){ nn =>
              Typed(GetDynamic(nlabel, nn), Ptr)
            }
          }
      }
    case Resume(cont, args) =>
      val tcont = apply(cont, env, None)
      tcont.tpe match {
        case Stack(eret, eargs) =>
          val targs = (args zip eargs).map { (a, e) => apply(a, env, Some(e)) }
          targs.bind("coerced resume arg") { nargs =>
            tcont.bind("coerced continuation") { ncont =>
              Typed(Resume(ncont, nargs), eret)
            }
          }
        case _ =>
          val targs = args.map{ a => apply(a, env, None) }
          targs.bind("resume arg"){ nargs =>
            tcont.bind("coerced continuation"){ ncont =>
              Typed(Resume(ncont, nargs), expected.getOrElse(Ptr))
            }
          }
      }
    case Resumed(cont, body) =>
      val tcont = apply(cont, env, None)
      tcont.tpe match {
        case Stack(eret, List(earg)) =>
          val targ = apply(body, env, Some(earg))
          tcont.bind("coerced continuation"){ ncont =>
            Typed(Resumed(ncont, targ.get), eret)
          }
        case _ =>
          val targ = apply(body, env, None)
          tcont.bind("coerced continuation"){ ncont =>
            Typed(Resumed(ncont, targ.get), Ptr)
          }
      }
    case Primitive(name, args, returns, rest) =>
      val targs = args.map{ a => apply(a, env, None)}
      val trest = apply(rest, extend(env, returns.map(apply)), expected)
      targs.bind("coerced primitive arg"){ nargs =>
        Typed(Primitive(name, nargs, returns.map(apply), trest.get), trest.tpe)
      }
    case literal: Literal =>
      coercer(literal.tpe, expected)(Typed(literal, literal.tpe))
    case ThisLib() =>
      Typed(ThisLib(), Ptr)
    case LoadLib(path) =>
      val tpath = apply(path, env, Some(Base.String))
      tpath.bind("coerced path"){ npath =>
        Typed(LoadLib(npath), Ptr)
      }
    case CallLib(lib, symbol, args, returnType) =>
      val tlib = apply(lib, env, Some(Ptr))
      val targs = args.map{ a => apply(a, env, None) }
      tlib.bind("coerced lib"){ nlib =>
        targs.bind("coerced arg"){ nargs =>
          Typed(CallLib(nlib, symbol, nargs, returnType), apply(returnType))
        }
      }
    case DebugWrap(inner, annotation) =>
      val tinner = apply(inner, env, expected)
      Typed(DebugWrap(tinner.get, annotation), tinner.tpe)
    case sugar: Sugar => ???
  }).as(expected) }

  override def apply(f: Program[O])(using ErrorReporter): Program[O] = f match {
    case Program(definitions, main) =>
      val env: Map[Id, Type] = definitions.map { d => d.name.name -> (d.name.tpe meet Type.of(d.binding)) }.toMap
      val (tdefinitions, tmain) = Emit.collecting[Definition[O], Term[O]] {
        definitions.foreach { d =>
          Emit.emit(apply(d, env))
        }
        apply(main, env, None).get
      }
      Program(tdefinitions, tmain)
  }

}
