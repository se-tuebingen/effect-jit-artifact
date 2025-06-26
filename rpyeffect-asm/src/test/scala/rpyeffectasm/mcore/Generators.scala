package rpyeffectasm.mcore
import org.scalacheck.Gen
import org.scalacheck.Shrink
import rpyeffectasm.mcore.analysis.FreeVariables
import rpyeffectasm.common.Purity

object Generators {

  object id {
    val name: Gen[Name] = for {
      name <- Gen.asciiPrintableStr
    } yield Name(name)
    val index: Gen[Index] = Gen.sized { size => for {i <- Gen.choose[Int](0, size)} yield Index(i) }
    private var _old_gen: List[Generated] = Nil
    val new_generated: Gen[Generated] = for {doc <- Gen.asciiPrintableStr} yield {
      new Generated(doc)
    }
    val generated: Gen[Generated] = if _old_gen.isEmpty then new_generated else Gen.oneOf(new_generated, Gen.oneOf(_old_gen))
    val parseable: Gen[Id] = Gen.oneOf(name, index)
    val any: Gen[Id] = Gen.oneOf(name, index, generated)
    val niceName: Gen[Name] = for {
      name <- Gen.alphaLowerStr
    } yield Name(name)
    val nice: Gen[Id] = Gen.oneOf(niceName, index)
  }



  def shrinkByRemovingOrRecursing[T](l: List[T])(s: T => Stream[T]): Stream[List[T]] = {
    Stream.from(for {i <- l.indices} yield l.patch(i, Nil, 1)) append
      (for {i <- l.indices; r <- s(l(i))} yield l.updated(i, r))
  }

  def shrinkByRecursing[T](l: List[T])(s: T => Stream[T]): Stream[List[T]] = {
    Stream.from(for {i <- l.indices; r <- s(l(i))} yield l.updated(i, r))
  }

  def shrinkByRemovingDepOrRecursing[T](l: List[T], depends: (T,T) => Boolean, canRemove: T => Boolean)(s: T => Stream[T]): Stream[List[T]] = {
    (Stream.from(for { i <- l.indices if canRemove(l(i)) } yield l.patch(i, Nil, 1).filterNot{ e => depends(e, l(i)) })) append // Also remove all dependents
      (for {i <- Stream.from(l.indices); r <- s(l(i))} yield l.updated(i, r))
  }

  def shrinkBindingsSafe[O <: ATerm](l: List[Definition[O]], need: Set[Var])(s: Definition[O] => Stream[Definition[O]]): Stream[List[Definition[O]]] = {
    def depends(d: Definition[O], d2: Definition[O]): Boolean = {
      import rpyeffectasm.mcore.analysis.FreeVariables
      FreeVariables(d).toList.exists{ x => d2.name.name == x.name }
    }
    def canRemove(d: Definition[O]): Boolean = !need.exists{x => x.name == d.name.name }
    shrinkByRemovingDepOrRecursing(l, depends, canRemove)(s)
  }
  def shrinkParams[O <: ATerm](l: List[Var], need: Set[Var])(s: Var => Stream[Var]): Stream[List[Var]] = {
    def canRemove(x: Var): Boolean = !need.exists{y => x.name == y.name }
    shrinkByRemovingDepOrRecursing(l, { (_,_) => false }, canRemove){ x => s(x).map{ case y: Var => y }}
  }

  trait TypeGenerator {

    val base: Gen[Base] = Gen.oneOf(Base.Int, Base.Double, Base.String, Base.Label(Top, None), Base.Unit)

    protected def myId: Gen[Id] = id.parseable

    val function: Gen[Function] = Gen.sized { s => for {
        nParams <- Gen.choose(0, s)
        params <- Gen.listOfN(nParams, Gen.resize(s / (nParams + 1), any))
        ret <- Gen.resize(s / (nParams + 1), any)
        purity <- Gen.oneOf(Purity.Pure, Purity.Effectful)
      } yield Function(params, ret, purity)
    }
    val method: Gen[Method] = Gen.sized { s =>
      for {
        tag <- myId
        nParams <- Gen.choose(0, s)
        params <- Gen.listOfN(nParams, Gen.resize(s / (nParams + 1), any))
        ret <- Gen.resize(s / (nParams + 1), any)
      } yield Method(tag, params, ret)
    }
    val codata: Gen[Codata] = Gen.sized { s =>
      for {
        tag <- myId
        nMethods <- Gen.choose(1, s)
        methods <- Gen.listOfN(nMethods, Gen.resize(s / nMethods, method))
      } yield Codata(tag, methods)
    }
    val constructor: Gen[Constructor] = Gen.sized { s => for {
        tag <- myId
        nFields <- Gen.choose(0, s)
        fields <- Gen.listOfN(nFields, Gen.resize(s / Math.max(1, nFields), any))
      } yield Constructor(tag, fields)
    }
    val data: Gen[Data] = Gen.sized { s => for {
        tag <- myId
        nConstructors <- Gen.choose(0, s)
        constructors <- Gen.listOfN(nConstructors, Gen.resize(s / Math.max(1,nConstructors), constructor))
      } yield Data(tag, constructors)
    }
    val stack: Gen[Stack] = Gen.sized { s => for {
        nArgs <- Gen.choose(0, s)
        res_args <- Gen.listOfN(nArgs, Gen.resize(s / (nArgs + 1), any))
        res_tpe <- Gen.resize(s / (nArgs + 1), any)
      } yield Stack(res_tpe, res_args)
    }
    val ref: Gen[Ref] = Gen.sized{ s => for { rt <- Gen.resize(s-1, any) } yield Ref(rt) }
    val simple: Gen[Type] = Gen.oneOf(base, Gen.oneOf(Top, Ptr, Num, Bottom))
    val region: Gen[Region.type] = Gen.const(Region) // TODO update once we have a region type
    val any: Gen[Type] = Gen.sized { size =>
      if(size <= 0) { simple } else {
        Gen.oneOf(simple, function, codata, data, stack, ref, region)
      }
    }

    implicit def shrinkMethod: Shrink[Method] = Shrink {
      case Method(tag, params, ret) =>
        (for { ps <- shrinkByRemovingOrRecursing(params)(shrink.shrink) } yield Method(tag, ps, ret)) append
        (for { r <- shrink.shrink(ret) } yield Method(tag, params, r))
    }
    implicit def shrinkConstructor: Shrink[Constructor] = Shrink {
      case Constructor(tag, fields) =>
        shrinkByRemovingOrRecursing(fields)(shrink.shrink).map(Constructor(tag,_))
    }
    implicit def shrink: Shrink[Type] = Shrink {
      case Bottom => Stream.empty
      case (_: Base) => Stream.from(List(Bottom))
      case Ptr => Stream.from(List(Base.Label(Top, None), Base.String, Base.Unit))
      case Top => Stream.from(List(Num, Ptr))
      case Num => Stream.from(List(Base.Int, Base.Double))
      case Function(params, ret, purity) =>
        Stream.from(List(Top, Bottom, Ptr)) append
        (for { ps <- shrinkByRemovingOrRecursing(params)(shrink.shrink) } yield Function(ps, ret, purity)) append
        (for { r <- shrink.shrink(ret) } yield Function(params, r, purity))
      case Codata(ifce_tag, methods) =>
        Stream.from(List(Top, Bottom, Ptr)) append
        (for { ms <- shrinkByRemovingOrRecursing(methods)(shrinkMethod.shrink) } yield Codata(ifce_tag, ms))
      case Data(type_tag, constructors) =>
        Stream.from(List(Top, Bottom, Ptr)) append
        (for { cs <- shrinkByRemovingOrRecursing(constructors)(shrinkConstructor.shrink) } yield Data(type_tag, cs))
      case Stack(resume_ret, resume_args ) =>
        Stream.from(List(Top, Bottom, Ptr)) append
          (for { args <- shrinkByRemovingOrRecursing(resume_args)(shrink.shrink) } yield Stack(resume_ret, args)) append
          (for { r <- shrink.shrink(resume_ret) } yield Stack(r, resume_args))
      case Ref(t) => t +: Shrink.shrink(t).map(Ref.apply)
    }
  }
  object tpe extends TypeGenerator
  object parseableTpe extends TypeGenerator {
    override def myId: Gen[Id] = id.parseable
  }

  trait TermGenerator[O <: Term[ATerm]] {

    import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}

    type Ctx
    given initialCtx: Ctx
    // To be potentially overwritten
    protected def bind(v: List[Var], ctx: Ctx): Ctx = ctx
    protected def myTpe: Gen[Type] = tpe.any
    protected def myTpeShrink: Shrink[Type] = tpe.shrink
    protected def myId: Gen[Id] = id.any

    // Generators
    def variable(using Ctx): Gen[Var] = for {
      name <- myId
      tpe <- myTpe
    } yield Var(name, tpe)
    def lhsVar(using Ctx): Gen[Var] = variable
    def rhsVar(using Ctx): Gen[Var] = variable

    def freshLabel(using Ctx): Gen[FreshLabel] = Gen.const(FreshLabel())

    def clause(using ctx: Ctx): Gen[Clause[O]] = Gen.sized{ s =>
      for {
        params <- Gen.listOf(lhsVar)
        body <- any(using bind(params, ctx))
      } yield Clause(params, body)
    }

    def abs(using ctx: Ctx): Gen[Abs[O]] = for {
      params <- Gen.listOf(lhsVar)
      body <- any(using bind(params, ctx))
    } yield Abs(params, body)

    def app(using ctx: Ctx): Gen[App[O]] = Gen.sized { s =>
      for {
        nArgs <- Gen.choose(0, s)
        fn <- Gen.resize(s / (nArgs + 1), anyO)
        args <- Gen.listOfN(nArgs, Gen.resize(s / (nArgs + 1), anyO))
      } yield App(fn, args)
    }

    def seq(using ctx: Ctx): Gen[Seq[O]] = Gen.sized { s =>
      for {
        nEls <- Gen.choose(1, s)
        els <- Gen.listOfN(nEls, Gen.resize(s / nEls, any))
      } yield Seq(els)
    }

    def definition(using ctx: Ctx): Gen[Definition[O]] = for {
      name <- lhsVar
      binding <- any
    } yield Definition(name, binding, Nil)

    def let(using ctx: Ctx): Gen[Let[O]] = Gen.sized { s =>
      for {
        nDefs <- Gen.choose(0,s)
        defs <- Gen.listOfN(nDefs, Gen.resize(s / (1 + nDefs), definition))
        body <- Gen.resize(s / (1 + nDefs), any(using bind(defs.map(_.name), ctx)))
      } yield Let(defs, body)
    }
    def letrec(exportSome: Boolean = false)(using ctx: Ctx): Gen[LetRec[O]] = Gen.sized { s =>
      for {
        nDefs <- Gen.choose(0, s)
        names <- Gen.listOfN(nDefs, lhsVar)
        _ctx = bind(names, ctx)
        defs <- Gen.sequence[List[Definition[O]], Definition[O]]( names.map{ n => for {
            body <- Gen.resize(s / (1 + nDefs), any(using _ctx))
            exportAs <- if exportSome then Gen.listOf(Gen.alphaNumStr) else Gen.const(Nil)
          } yield Definition(n, body, exportAs) } )
        body <- Gen.resize(s / (1 + nDefs), any(using _ctx))
      } yield LetRec(defs, body)
    }

    def ifZero(using Ctx): Gen[IfZero[O]] = Gen.sized { s => for {
        i <- Gen.resize(s / 3, anyO)
        t <- Gen.resize(s / 3, any)
        e <- Gen.resize(s / 3, any)
      } yield IfZero(i,t,e)
    }

    def switch(using Ctx): Gen[Switch[O]] = Gen.sized { s =>
      import org.scalacheck.Arbitrary.*
      for {
        n <- Gen.choose(0, s)
        sc <- Gen.resize(s / (2 + n), anyO)
        vs <- Gen.listOfN(n, Gen.resize(s / (2 + n), arbInt.arbitrary))
        ts <- Gen.listOfN(n, Gen.resize(s / (2 + n), any))
        d <- Gen.resize(s / (2 + n), any)
      } yield Switch(sc, (vs.map(Literal.Int(_))) zip ts, d)
    }

    def construct(using Ctx): Gen[Construct[O]] = Gen.sized { s => for {
        tt <- myId
        t <- myId
        nArgs <- Gen.choose(0, s)
        args <- Gen.listOfN(nArgs, Gen.resize(s / Math.max(nArgs, 1), anyO))
      } yield Construct(tt, t, args)
    }

    def project(using Ctx): Gen[Project[O]] = Gen.sized { s =>
      for {
        scr <- anyO
        tt <- myId
        t <- myId
        f <- Gen.choose[Int](0, s - 1)
      } yield Project(scr, tt, t, f)
    }

    def matchT(using Ctx): Gen[Match[O]] = Gen.sized { s =>
      for {
        nClauses <- Gen.choose(0, Math.max(0, s-2))
        scr <- Gen.resize(s / (nClauses + 2), anyO)
        tt <- myId
        clauses <- Gen.listOfN(nClauses, for {
          t <- myId
          cls <- Gen.resize(s / (nClauses + 2), clause)
        } yield (t, cls))
        dcls <- Gen.resize(s / (nClauses + 2), clause)
      } yield Match(scr, tt, clauses, dcls)
    }

    def newT(using Ctx): Gen[New[O]] = Gen.sized { s =>
      for {
        it <- myId
        nMethods <- Gen.choose(1, s)
        methods <- Gen.listOfN(nMethods, for {
          t <- myId
          cls <- Gen.resize(s / Math.max(1, nMethods), clause)
        } yield (t, cls))
      } yield New(it, methods)
    }

    def invoke(using Ctx): Gen[Invoke[O]] = Gen.sized { s =>
      for {
        nArgs <- Gen.choose(0, s)
        rcv <- Gen.resize(s / (nArgs + 1), anyO)
        it <- myId
        m <- myId
        args <- Gen.listOfN(nArgs, Gen.resize(s / (nArgs + 1), anyO))
      } yield Invoke(rcv, it, m, args)
    }

    def letref(using ctx: Ctx): Gen[LetRef[O]] = Gen.sized {s =>
      for {
        ref <- lhsVar
        reg <- Gen.resize(s / 3, anyO)
        bnd <- Gen.resize(s / 3, anyO)
        body <- Gen.resize(s / 3, any(using bind(List(ref), ctx)))
      } yield LetRef(ref, reg, bnd, body)
    }

    def load(using Ctx): Gen[Load[O]] = for { ref <- anyO } yield Load(ref)
    def store(using Ctx): Gen[Store[O]] = Gen.sized { s => for {
        ref <- Gen.resize(s/2, anyO)
        v <- Gen.resize(s/2, anyO)
      } yield Store(ref, v)
    }

    def reset(using ctx: Ctx): Gen[Reset[O]] = Gen.sized { s =>
      for {
        label <- Gen.resize(s/4, anyO)
        reg <- lhsVar
        body <- Gen.resize(s/4, any(using bind(List(reg), ctx)))
        ret <- Gen.resize(s/4, clause)
        bnd <- Gen.option(Gen.resize(s/4, anyO))
      } yield Reset(label, reg, bnd, body, ret)
    }

    def shift(using ctx: Ctx): Gen[Shift[O]] = Gen.sized { s =>
      for {
        label <- Gen.resize(s/4, anyO)
        n <- Gen.resize(s/4, anyO)
        k <- lhsVar
        body <- Gen.resize(s/4, any(using bind(List(k), ctx)))
        retT <- Gen.resize(s/4, myTpe)
      } yield Shift(label, n, k, body, retT)
    }

    def control(using ctx: Ctx): Gen[Control[O]] = Gen.sized { s =>
      for {
        label <- Gen.resize(s / 4, anyO)
        n <- Gen.resize(s / 4, anyO)
        k <- lhsVar
        body <- Gen.resize(s / 4, any(using bind(List(k), ctx)))
        retT <- Gen.resize(s / 4, myTpe)
      } yield Control(label, n, k, body, retT)
    }

    def resume(using Ctx): Gen[Resume[O]] = Gen.sized { s =>
      for {
        nArgs <- Gen.choose(0, s)
        cont <- Gen.resize(s / (nArgs + 1), anyO)
        args <- Gen.listOfN(nArgs, Gen.resize(s / (nArgs + 1), anyO))
      } yield Resume(cont, args)
    }

    def primitive(using ctx: Ctx): Gen[Primitive[O]] = Gen.sized { s =>
      for {
        pi <- Gen.oneOf(rpyeffectasm.common.Primitives.primitives)
        args <- Gen.sequence[List[O], O](pi.insT.map{ _ => anyO })
        returns <- Gen.sequence[List[Var], Var](pi.outsT.map{ _ => lhsVar })
        rest <- any(using bind(returns, ctx))
      } yield Primitive(pi.name, args, returns, rest)
    }

    def handle(using ctx: Ctx): Gen[HandlerSugar.Handle] = Gen.sized { s =>
      for {
        tpe <- Gen.oneOf(HandlerSugar.HandlerType.values)
        tag <- myId
        nHandlers <- Gen.choose(0, s)
        nRet <- Gen.choose(0, 1)
        handlers <- Gen.listOfN(nHandlers, for {
          t <- myId
          c <- Gen.resize(s / (nHandlers + nRet + 1), clause)
        } yield (t, c))
        ret <- if nRet > 0 then Gen.resize(s / (nHandlers + nRet + 1), clause).map(Some) else Gen.const(None)
        body <- Gen.resize(s / (nHandlers + nRet + 1), any)
      } yield HandlerSugar.Handle(tpe, tag, handlers, ret, body)
    }

    def op(using ctx: Ctx): Gen[HandlerSugar.Op] = Gen.sized { s =>
      for {
        tag <- myId
        op <- myId
        nArgs <- Gen.choose(0, s)
        args <- Gen.listOfN(nArgs, Gen.resize(s / (nArgs + 2), any))
        k <- Gen.resize(s / (nArgs + 2), clause)
        rtpe <- Gen.resize(s / (nArgs + 2), myTpe)
      } yield HandlerSugar.Op(tag, op, args, k, rtpe)
    }

    def dhandle(using ctx: Ctx): Gen[DynamicHandlerSugar.Handle] = Gen.sized { s =>
      for {
        tpe <- Gen.oneOf(DynamicHandlerSugar.HandlerType.values)
        nHandlers <- Gen.choose(0, s)
        nRet <- Gen.choose(0, 1)
        tag <- Gen.resize(s / (nHandlers + nRet + 2), any)
        handlers <- Gen.listOfN(nHandlers, for {
          t <- myId
          c <- Gen.resize(s / (nHandlers + nRet + 2), clause)
        } yield (t, c))
        ret <- if nRet > 0 then Gen.resize(s / (nHandlers + nRet + 1), clause).map(Some) else Gen.const(None)
        body <- Gen.resize(s / (nHandlers + nRet + 1), any)
      } yield DynamicHandlerSugar.Handle(tpe, tag, handlers, ret, body)
    }

    def dop(using ctx: Ctx): Gen[DynamicHandlerSugar.Op] = Gen.sized { s =>
      for {
        op <- myId
        nArgs <- Gen.choose(0, s)
        tag <- Gen.resize(s / (nArgs + 3), any)
        args <- Gen.listOfN(nArgs, Gen.resize(s / (nArgs + 3), any))
        k <- Gen.resize(s / (nArgs + 3), clause)
        rtpe <- Gen.resize(s / (nArgs + 3), myTpe)
      } yield DynamicHandlerSugar.Op(tag, op, args, k, rtpe)
    }

    def literal(using ctx: Ctx): Gen[Literal] = {
      import org.scalacheck.Arbitrary.*
      for {
        tp <- tpe.base
        v <- (tp match {
          case Base.Int => arbInt.arbitrary
          case Base.Double => arbDouble.arbitrary
          case Base.String => arbString.arbitrary
          case Base.Label(_,_) => Gen.const(null)
          case Base.Unit => Gen.const(())
        }).asInstanceOf[Gen[tp.ScalaType]]
        fmt <- Gen.alphaStr
      } yield (tp match {
        case Base.Int => Literal.Int(v.asInstanceOf[Int])
        case Base.Double => Literal.Double(v.asInstanceOf[Double])
        case Base.String => Literal.String(v.asInstanceOf[String])
         if fmt == "" then Literal.String(v.asInstanceOf[String])
         else Literal.StringWithFormat(v.asInstanceOf[String], fmt)
        case Base.Label(_,_) => Literal.Label
        case Base.Unit => Literal.Unit
      })
    }
    def debugWrap(using ctx: Ctx): Gen[DebugWrap[O]] = {
      for {
        ann <- Gen.asciiPrintableStr
        t <- any
      } yield DebugWrap(t, ann)
    }

    def loadLib(using ctx: Ctx): Gen[LoadLib[O]] = {
      for {
        path <- anyO
      } yield LoadLib(path)
    }
    def callLib(using ctx: Ctx): Gen[CallLib[O]] = Gen.sized { s =>
      for {
        na <- Gen.choose(0, s)
        lib <- Gen.resize(s / (1 + na), anyO)
        symb <- Gen.asciiPrintableStr
        args <- Gen.listOfN(na, Gen.resize(s / (1 + na), anyO))
        returnType <- myTpe
      } yield CallLib(lib, symb, args, returnType)
    }
    def qualified(using ctx: Ctx): Gen[Qualified] = for {
      l <- rhsVar
      n <- Gen.asciiPrintableStr
      t <- tpe.any
    } yield Qualified(l,n,t)

    def alternativeFail: Gen[AlternativeFail.type] = Gen.const(AlternativeFail)
    def alternativeChoice: Gen[AlternativeChoice] = Gen.sized { s =>
      for {
        n <- Gen.choose(1, s)
        init <- Gen.listOfN(n-1, Gen.resize(s / n, any))
        lst <- Gen.resize(s / n, any)
      } yield AlternativeChoice(init :+ lst)
    }

    def simple(using Ctx): Gen[Term[O]] = {
      Gen.oneOf(freshLabel, literal, rhsVar)
    }
    def sugar(using Ctx): Gen[Sugar] = {
      Gen.oneOf(handle, op, dhandle, dop, qualified)
    }

    def nonSugar(using Ctx): Gen[Term[O]] = Gen.oneOf(simple,
      abs, app, seq,
      let, letrec(),
      construct, project, matchT,
      newT, invoke,
      loadLib, callLib,
      letref, load, store,
      reset, shift, control, resume,
      primitive, literal, ifZero, switch, debugWrap)

    def any(using Ctx): Gen[Term[O]] = Gen.sized{ s =>
      if (s <= 0) {
        simple
      } else {
        nonSugar
      }
    }
    protected def anyO(using Ctx): Gen[O]

    implicit def shrinkDef: Shrink[Definition[O]] = Shrink {
      case Definition(name, binding, exportAs) =>
        shrinkVar.shrink(name).map{ n => Definition(n, binding, exportAs) } append
        shrink.shrink(binding).map(Definition(name, _, exportAs))
    }
    implicit def shrinkClause: Shrink[Clause[O]] = Shrink {
      case Clause(params, body) =>
        shrinkByRemovingOrRecursing(params)(shrinkVar.shrink).map{ x => Clause(x, body) } append
        shrink.shrink(body).map(Clause(params, _))
    }
    implicit def shrinkVar: Shrink[Var] = Shrink {
      case Var(name, tpe) => for { t <- myTpeShrink.shrink(tpe) } yield Var(name, t)
    }
    implicit def shrinkO: Shrink[O]
    implicit def shrink: Shrink[Term[O]] = Shrink {
      case v@Var(name, tpe) => Stream.from(List(FreshLabel(), Literal.Int(0))) append shrinkVar.shrink(v)
      case Abs(params, body) => body +:
        (for { ps <- shrinkByRemovingOrRecursing(params)(shrinkVar.shrink) } yield Abs(ps, body)) append
        (for { b <- shrink.shrink(body) } yield Abs(params, b))
      case App(fn, args) => fn.asInstanceOf[Term[O]] +: Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        (for { as <- shrinkByRemovingOrRecursing(args)(shrinkO.shrink)} yield App(fn, as)) append
        (for { f <- shrinkO.shrink(fn)} yield App(f, args))
      case Seq(ts) => Stream.from(ts) append shrinkByRemovingOrRecursing(ts)(shrink.shrink).map(Seq(_))
      case Let(defs, body) => body +: Stream.from(defs.map(_.binding)) append
        shrinkByRemovingOrRecursing(defs)(shrinkDef.shrink).map(Let(_, body)) append
          shrink.shrink(body).map(Let(defs, _))
      case LetRec(defs, body) => body +: Stream.from(defs.map(_.binding)) append
        shrinkByRemovingOrRecursing(defs)(shrinkDef.shrink).map(LetRec(_, body)) append
          shrink.shrink(body).map(LetRec(defs, _))
      case IfZero(cond, thn, els) => Stream.from(List(cond.unroll.asInstanceOf[Term[O]],thn,els)) append
        shrinkO.shrink(cond).map(IfZero(_, thn, els)) append
        shrink.shrink(thn).map(IfZero(cond, _, els)) append
        shrink.shrink(els).map(IfZero(cond, thn, _))
      case Construct(tpe_tag, tag, args) => Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        shrinkByRemovingOrRecursing(args)(shrinkO.shrink).map(Construct(tpe_tag, tag, _))
      case Project(scrutinee, tpe_tag, tag, field) => scrutinee.asInstanceOf[Term[O]] +:
        shrinkO.shrink(scrutinee).map(Project(_, tpe_tag, tag, field))
      case Match(scrutinee, tpe_tag, clauses, default_clause) => scrutinee.unroll.asInstanceOf[Term[O]] +:
        Stream.from((default_clause +: clauses.map(_._2)).map(_.body)).asInstanceOf[Stream[Term[O]]] append
        shrinkO.shrink(scrutinee).map(Match(_, tpe_tag, clauses, default_clause)) append
        shrinkByRemovingOrRecursing(clauses){ case (t,c) => shrinkClause.shrink(c).map((t,_)) }.map(Match(scrutinee, tpe_tag, _, default_clause)) append
        shrinkClause.shrink(default_clause).map(Match(scrutinee, tpe_tag, clauses, _))
      case Switch(scrutinee, cases, default) => scrutinee.unroll.asInstanceOf[Term[O]] +:
        Stream.from((default +: cases.map(_._2))) append(
        shrinkByRemovingOrRecursing(cases){ case (v, c) => shrink.shrink(c).map((v, _)) }.map(Switch(scrutinee, _, default)) append
        shrink.shrink(default).map(Switch(scrutinee, cases, _))
      )
      case New(ifce_tag, methods) => Stream.from(methods.map{m => m._2.body}) append
        shrinkByRemovingOrRecursing(methods){ case (t,c) => shrinkClause.shrink(c).map((t,_)) }.map(New(ifce_tag, _))
      case Invoke(receiver, ifce_tag, method, args) => receiver.asInstanceOf[Term[O]] +: Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        shrinkO.shrink(receiver).map(Invoke(_, ifce_tag, method, args)) append
        shrinkByRemovingOrRecursing(args)(shrinkO.shrink).map(Invoke(receiver, ifce_tag, method, _))
      case LetRef(ref, region, binding, body) =>
        Stream.from(List(region.unroll, binding.unroll, body)).asInstanceOf[Stream[Term[O]]] append
        shrinkO.shrink(region).map(LetRef(ref, _, binding, body)) append
        shrinkO.shrink(binding).map(LetRef(ref, region, _, body)) append
        shrink.shrink(body).map(LetRef(ref, region, binding, _))
      case Load(ref) => Stream.from(List(ref.asInstanceOf[Term[O]])) append shrinkO.shrink(ref).map(Load(_))
      case Store(ref, value) => ref.asInstanceOf[Term[O]] +: value.asInstanceOf[Term[O]] +:
        shrinkO.shrink(ref).map(Store(_, value)) append shrinkO.shrink(value).map(Store(ref, _))
      case FreshLabel() => Stream.empty
      case Reset(label, region, bnd, body, ret) => label.asInstanceOf[Term[O]] +: body +: ret.body +:
        shrinkO.shrink(label).map(Reset(_, region, bnd, body, ret)) append
        Stream.from(bnd).flatMap{ bnd =>
          Reset(label, region, None, body, ret)
          +: shrinkO.shrink(bnd).map{ b => Reset(label, region, Some(b), body, ret) } } append
        shrink.shrink(body).map(Reset(label, region, bnd, _, ret)) append
        shrinkClause.shrink(ret).map(Reset(label, region, bnd, body, _))
      case Shift(label, n, k, body, retTpe) => label.asInstanceOf[Term[O]] +: n.asInstanceOf[Term[O]] +: body +:
        shrinkO.shrink(label).map(Shift(_, n, k, body, retTpe)) append
        shrinkO.shrink(n).map(Shift(label, _, k, body, retTpe)) append
        shrink.shrink(body).map(Shift(label, n, k, _, retTpe)) append
        myTpeShrink.shrink(retTpe).map(Shift(label, n, k, body, _))
      case Control(label, n, k, body, retTpe) => label.asInstanceOf[Term[O]] +: n.asInstanceOf[Term[O]] +: body +:
        shrinkO.shrink(label).map(Control(_, n, k, body, retTpe)) append
        shrinkO.shrink(n).map(Control(label, _, k, body, retTpe)) append
        shrink.shrink(body).map(Control(label, n, k, _, retTpe)) append
        myTpeShrink.shrink(retTpe).map(Control(label, n, k, body, _))
      case Resume(cont, args) => cont.asInstanceOf[Term[O]] +: Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        shrinkO.shrink(cont).map(Resume(_, args)) append
        shrinkByRemovingOrRecursing(args)(shrinkO.shrink).map(Resume(cont, _))
      case Primitive(name, args, returns, rest) => rest +: Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        shrink.shrink(rest).map(Primitive(name, args, returns, _)) append
        (for { i <- args.indices; a <- shrinkO.shrink(args(i)) } yield Primitive(name, args.updated(i, a), returns, rest))
      case Literal.Int(0) => Stream.empty
      case Literal.Int(v: Int) => Shrink.shrinkIntegral[Int].shrink(v).map(Literal.Int(_))
      case Literal.Double(v: Double) => Stream.from(List(Literal.Int(0)))
      case Literal.String(v: String) => Shrink.shrinkString.shrink(v).map(Literal.String(_))
      case Literal.Label | Literal.Unit => Stream.from(List(Literal.Int(0)))
      case sugar: Sugar => import rpyeffectasm.util.Query
        Stream.from(Query[List[Term[O]]](Nil, { ls => ls.flatten.toList }){
          case t: Term[O] => List(t)
        }(sugar).filterNot(_ == sugar))
      case _ => Stream.empty
    }
  }

  trait BasicTermGenerator[O <: Term[ATerm]] extends TermGenerator[O] {
    case class Ctx()
    given initialCtx: Ctx = Ctx()
  }
  trait WellScopedTermGenerator[O <: Term[ATerm]] extends TermGenerator[O] {
    import rpyeffectasm.mcore.Generators.term.{any, Ctx}

    enum Ctx {
      case Bind(bindings: List[Var], outer: Ctx)
      case Empty
    }

    given initialCtx: Ctx = Ctx.Empty

    override def bind(v: List[Var], ctx: Ctx): Ctx = Ctx.Bind(v, ctx)

    override def rhsVar(using ctx: Ctx): Gen[Var] = {
      def options(ctx: Ctx): List[Var] = ctx match {
        case Ctx.Bind(bindings, outer) => bindings ++ options(outer)
        case Ctx.Empty => Nil
      }
      options(ctx) match {
        case Nil => Gen.fail
        case opts => Gen.oneOf(opts)
      }
    }

    override def simple(using C: Ctx): Gen[Term[O]] = C match {
      case Ctx.Empty => Gen.oneOf(literal, freshLabel)
      case _ => super.simple
    }

    override def any(using C: Ctx): Gen[Term[O]] = C match {
      case Ctx.Empty => Gen.oneOf(simple,
        abs, seq,
        let, letrec(),
        newT,
        letref,
        literal)
      case _ => super.any
    }

    override def shrink: Shrink[Term[O]] = Shrink {
      case v@Var(name, tpe) => Stream.from(List(FreshLabel(), Literal.Int(0))) append shrinkVar.shrink(v)
      case Abs(params, body) => body +:
        (for {ps <- shrinkParams(params, FreeVariables(body).toSet)(shrinkVar.shrink)} yield Abs(ps, body)) append
        (for {b <- shrink.shrink(body)} yield Abs(params, b))
      case App(fn, args) => fn.asInstanceOf[Term[O]] +: Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        (for {as <- shrinkByRecursing(args)(shrinkO.shrink)} yield App(fn, as)) append
        (for {f <- shrinkO.shrink(fn)} yield App(f, args))
      case Seq(ts) => Stream.from(ts) append shrinkByRemovingOrRecursing(ts)(shrink.shrink).map(Seq(_))
      case Let(defs, body) => body +: Stream.from(defs.map(_.binding)) append
        shrinkByRemovingDepOrRecursing(defs,
          { (_, _) => false }, {
            d => FreeVariables(body).toSet.exists { c => d.name.name == c.name }
          })(shrinkDef.shrink).map(Let(_, body)) append
        shrink.shrink(body).map(Let(defs, _))
      case LetRec(defs, body) => body +: Stream.from(defs.map(_.binding)) append
        shrinkBindingsSafe(defs, FreeVariables(body).toSet)(shrinkDef.shrink).map(LetRec(_, body)) append
        shrink.shrink(body).map(LetRec(defs, _))
      case IfZero(cond, thn, els) => Stream.from(List(cond.unroll.asInstanceOf[Term[O]], thn, els)) append
        shrinkO.shrink(cond).map(IfZero(_, thn, els)) append
        shrink.shrink(thn).map(IfZero(cond, _, els)) append
        shrink.shrink(els).map(IfZero(cond, thn, _))
      case Construct(tpe_tag, tag, args) => Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        shrinkByRemovingOrRecursing(args)(shrinkO.shrink).map(Construct(tpe_tag, tag, _))
      case Project(scrutinee, tpe_tag, tag, field) => scrutinee.asInstanceOf[Term[O]] +:
        shrinkO.shrink(scrutinee).map(Project(_, tpe_tag, tag, field))
      case Match(scrutinee, tpe_tag, clauses, default_clause) => scrutinee.unroll.asInstanceOf[Term[O]] +:
        Stream.from((default_clause +: clauses.map(_._2)).map(_.body)).asInstanceOf[Stream[Term[O]]] append
        shrinkO.shrink(scrutinee).map(Match(_, tpe_tag, clauses, default_clause)) append
        shrinkByRemovingOrRecursing(clauses) { case (t, c) => shrinkClause.shrink(c).map((t, _)) }.map(Match(scrutinee, tpe_tag, _, default_clause)) append
        shrinkClause.shrink(default_clause).map(Match(scrutinee, tpe_tag, clauses, _))
      case Switch(scrutinee, cases, default) => scrutinee.unroll.asInstanceOf[Term[O]] +:
        Stream.from((default +: cases.map(_._2))) append (
        shrinkByRemovingOrRecursing(cases) { case (v, c) => shrink.shrink(c).map((v, _)) }.map(Switch(scrutinee, _, default)) append
          shrink.shrink(default).map(Switch(scrutinee, cases, _))
        )
      case New(ifce_tag, methods) => Stream.from(methods.map { m => m._2.body }) append
        shrinkByRemovingOrRecursing(methods) { case (t, c) => shrinkClause.shrink(c).map((t, _)) }.map(New(ifce_tag, _))
      case Invoke(receiver, ifce_tag, method, args) => receiver.asInstanceOf[Term[O]] +: Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        shrinkO.shrink(receiver).map(Invoke(_, ifce_tag, method, args)) append
        shrinkByRemovingOrRecursing(args)(shrinkO.shrink).map(Invoke(receiver, ifce_tag, method, _))
      case LetRef(ref, region, binding, body) =>
        Stream.from(List(region.unroll, binding.unroll, body)).asInstanceOf[Stream[Term[O]]] append
          shrinkO.shrink(region).map(LetRef(ref, _, binding, body)) append
          shrinkO.shrink(binding).map(LetRef(ref, region, _, body)) append
          shrink.shrink(body).map(LetRef(ref, region, binding, _))
      case Load(ref) => Stream.from(List(ref.asInstanceOf[Term[O]])) append shrinkO.shrink(ref).map(Load(_))
      case Store(ref, value) => ref.asInstanceOf[Term[O]] +: value.asInstanceOf[Term[O]] +:
        shrinkO.shrink(ref).map(Store(_, value)) append shrinkO.shrink(value).map(Store(ref, _))
      case FreshLabel() => Stream.empty
      case Reset(label, region, bnd, body, ret) => label.asInstanceOf[Term[O]] +: body +: ret.body +:
        shrinkO.shrink(label).map(Reset(_, region, bnd, body, ret)) append
        Stream.from(bnd).flatMap{ bnd => Reset(label, region, None, body, ret) +:
          shrinkO.shrink(bnd).map{ b => Reset(label, region, Some(bnd), body, ret) } } append
        shrink.shrink(body).map(Reset(label, region, bnd, _, ret)) append
        shrinkClause.shrink(ret).map(Reset(label, region, bnd, body, _))
      case Shift(label, n, k, body, retTpe) => label.asInstanceOf[Term[O]] +: n.asInstanceOf[Term[O]] +: body +:
        shrinkO.shrink(label).map(Shift(_, n, k, body, retTpe)) append
        shrinkO.shrink(n).map(Shift(label, _, k, body, retTpe)) append
        shrink.shrink(body).map(Shift(label, n, k, _, retTpe)) append
        myTpeShrink.shrink(retTpe).map(Shift(label, n, k, body, _))
      case Control(label, n, k, body, retTpe) => label.asInstanceOf[Term[O]] +: n.asInstanceOf[Term[O]] +: body +:
        shrinkO.shrink(label).map(Control(_, n, k, body, retTpe)) append
        shrinkO.shrink(n).map(Control(label, _, k, body, retTpe)) append
        shrink.shrink(body).map(Control(label, n, k, _, retTpe)) append
        myTpeShrink.shrink(retTpe).map(Control(label, n, k, body, _))
      case Resume(cont, args) => cont.asInstanceOf[Term[O]] +: Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        shrinkO.shrink(cont).map(Resume(_, args)) append
        shrinkByRemovingOrRecursing(args)(shrinkO.shrink).map(Resume(cont, _))
      case Primitive(name, args, returns, rest) => rest +: Stream.from(args).asInstanceOf[Stream[Term[O]]] append
        shrink.shrink(rest).map(Primitive(name, args, returns, _)) append
        (for {i <- args.indices; a <- shrinkO.shrink(args(i))} yield Primitive(name, args.updated(i, a), returns, rest))
      case Literal.Int(0) => Stream.empty
      case Literal.Int(v: Int) => Shrink.shrinkIntegral[Int].shrink(v).map(Literal.Int(_))
      case Literal.Double(_: Double) => Stream.from(List(Literal.Int(0)))
      case Literal.String(v: String) => Shrink.shrinkString.shrink(v).map(Literal.String(_))
      case Literal.Label | Literal.Unit => Stream.from(List(Literal.Int(0)))
      case DebugWrap(inner, annotations) => inner +: Shrink.shrink(inner).map(DebugWrap(_, annotations))
      case sugar: Sugar => import rpyeffectasm.util.Query
        Stream.from(Query[List[Term[O]]](Nil, { ls => ls.flatten.toList }) {
          case t: Term[O] => List(t)
        }(sugar).filterNot(_ == sugar))
      case _ => Stream.empty
    }

  }
  trait ParseableTermGenerator[O <: Term[ATerm]] extends TermGenerator[O] {
    override def myTpe: Gen[Type] = parseableTpe.any
    override def myId: Gen[Id] = id.parseable
  }
  trait VarTermGenerator extends TermGenerator[Var] {
    override def anyO(using Ctx): Gen[Var] = rhsVar

    override implicit def shrinkO: Shrink[Var] = Shrink { v => for { t <- myTpeShrink.shrink(v.tpe) } yield Var(v.name, t) }
  }
  trait TermTermGenerator extends TermGenerator[Term[ATerm]] {
    override def any(using Ctx): Gen[Term[Term[ATerm]]] = Gen.sized { s =>
      if(s <= 0) { simple } else { Gen.oneOf(sugar.asInstanceOf, nonSugar) }
    }
    override def anyO(using Ctx): Gen[Term[ATerm]] = any

    override implicit def shrinkO: Shrink[Term[ATerm]] = Shrink { t => shrink.shrink(t.asInstanceOf) }
  }

  object term extends BasicTermGenerator[Term[ATerm]] with TermTermGenerator
  object wellScopedTerm extends WellScopedTermGenerator[Term[ATerm]] with TermTermGenerator
  object wellScopedNosugarTerm extends WellScopedTermGenerator[Term[ATerm]] with TermGenerator[Term[ATerm]] {
    override def anyO(using Ctx): Gen[Term[ATerm]] = any
    override implicit def shrinkO: Shrink[Term[ATerm]] = Shrink { t => shrink.shrink(t.asInstanceOf) }
  }
  object wellScopedVarTerm extends WellScopedTermGenerator[Var] with VarTermGenerator {
    override def myId: Gen[Id] = id.nice
  }

  object parseableTerm extends ParseableTermGenerator[Term[ATerm]] with BasicTermGenerator[Term[ATerm]] with TermTermGenerator
  object parseableVarTerm extends ParseableTermGenerator[Var] with BasicTermGenerator[Var] with VarTermGenerator

  trait ProgramGenerator[O <: Term[ATerm]](val theTerm: TermGenerator[O]) {

    def any: Gen[Program[O]] = {
      for {
        main <- theTerm.letrec(true)(using theTerm.initialCtx)
      } yield {
        Program(main.defs, main.body)
      }
    }

    implicit def shrink: Shrink[Program[O]] = Shrink {
      case Program(definitions, main) =>
        Stream.from(definitions.map{ d => Program(Nil, d.binding)}) append
        shrinkByRemovingOrRecursing(definitions)(theTerm.shrinkDef.shrink).map(Program(_, main)) append
        theTerm.shrink.shrink(main).map(Program(definitions, _))
    }
    implicit def shrinkAny: Shrink[Program[ATerm]] = Shrink { p => shrink.shrink(p.asInstanceOf) }
  }
  object program extends ProgramGenerator[Term[ATerm]](term)
  object wellScopedProgram extends ProgramGenerator[Term[ATerm]](wellScopedTerm)
  object wellScopedNosugarProgram extends ProgramGenerator[Term[ATerm]](wellScopedNosugarTerm)
  object wellScopedVarProgram extends ProgramGenerator[Var](wellScopedVarTerm) {
    implicit override def shrink: Shrink[Program[Var]] = Shrink {
      case p@Program(definitions, main) =>
        import rpyeffectasm.mcore.analysis.FreeVariables

        Stream.from(definitions.map { d => Program(Nil, d.binding) })
          shrinkBindingsSafe(definitions, FreeVariables(main).toSet)(theTerm.shrinkDef.shrink).map(Program(_, main)) append
          theTerm.shrink.shrink(main).map(Program(definitions, _))
    }
    implicit override def shrinkAny: Shrink[Program[ATerm]] = Shrink { p => shrink.shrink(p.asInstanceOf) }
  }
  object parseableProgram extends ProgramGenerator[Term[ATerm]](parseableTerm)
  object parseableVarProgram extends ProgramGenerator[Var](parseableVarTerm)
}
