package rpyeffectasm.asm

import org.scalacheck.Arbitrary
import org.scalacheck.Gen
import org.scalacheck.Gen.*
import org.scalacheck.Prop.*
import rpyeffectasm.mcore

object Generators {

  type OTpe = Nothing

  object id {
    val name: Gen[Name] = for {
      name <- Gen.asciiPrintableStr
    } yield Name(name)
    val index: Gen[Index] = Gen.sized { size => for {i <- Gen.choose[Int](0, size)} yield Index(i) }
    private var _old_gen: List[Generated] = Nil
    val new_generated: Gen[Generated] = for {doc <- Gen.asciiPrintableStr} yield {
      new Generated(doc)
    }
    val mcoreGenerated: Gen[mcore.MCoreGenerated] = for { x <- mcore.Generators.id.generated } yield mcore.MCoreGenerated(x)
    val generated: Gen[Generated] =
        if _old_gen.isEmpty then Gen.oneOf(new_generated, mcoreGenerated)
        else Gen.oneOf(new_generated, Gen.oneOf(_old_gen), mcoreGenerated)
    val parseable: Gen[Id] = Gen.oneOf(name, index)
    val any: Gen[Id] = Gen.oneOf(name, index, generated)
    val niceName: Gen[Name] = for {
      name <- Gen.alphaLowerStr
    } yield Name(name)
    val nice: Gen[Id] = Gen.oneOf(niceName, index, generated)
  }

  trait InstructionGenerator[Flags <: AsmFlags, Tag <: Id, Label <: Id, V <: Id] {
    def tag(using Ctx): Gen[Tag]
    def label(using Ctx): Gen[Label]
    def v(using Ctx): Gen[V]

    type Ctx
    given initialCtx: Ctx

    def lvariable(using Ctx): Gen[Var[V]] = for {
      x <- v
    } yield Var(x)
    def rvariable(using Ctx): Gen[Var[V]] = lvariable
    def lhs(using Ctx): Gen[LhsOperand[Flags, V]] = lvariable // TODO Ref, Const
    def rhs(using Ctx): Gen[RhsOperand[Flags, V]] = rvariable // TODO Ref, Const
    def lhss(using Ctx): Gen[LhsOpList[Flags, V]] = Gen.sized { s =>
      for {
        n <- Gen.choose(0, s)
        params <- Gen.listOfN(n, Gen.resize(s/(n+1),lhs))
      } yield params
    }
    def rhss(using Ctx): Gen[RhsOpList[Flags, V]] = Gen.sized { s =>
      for {
        n <- Gen.choose(0, s)
        args <- Gen.listOfN(n, Gen.resize(s/(n+1),rhs))
      } yield args
    }
    def env(using Ctx): Gen[RhsOpList[Flags, V]] = rhss

    def clause(using Ctx): Gen[Clause[Flags, Label, V]] = for {
      target <- label
      params <- lhss
      _env <- env
    } yield Clause(params, _env, target)

    def let(using Ctx): Gen[Let[Flags, V, OTpe]] = Gen.sized{ s =>
      for {
        n <- Gen.choose(0, s)
        _lhss <- lhss
        _rhss <- rhss
      } yield Let(_lhss, _rhss)
    }
    def letConstInt(using Ctx): Gen[LetConst[Flags, V, Int]] = for {
      x <- v
      i <- Arbitrary.arbInt.arbitrary
    } yield LetConst(Var(x), i)
    def letConstDouble(using Ctx): Gen[LetConst[Flags, V, Double]] = for {
      x <- v
      d <- Arbitrary.arbDouble.arbitrary
    } yield LetConst(Var(x), d)
    def letConstString(using Ctx): Gen[LetConst[Flags, V, String]] = for {
      x <- v
      s <- Arbitrary.arbString.arbitrary
    } yield LetConst(Var(x), s)
    def letConst(using Ctx): Gen[LetConst[Flags, V, ?]] = Gen.oneOf(letConstInt, letConstDouble, letConstDouble)

    def primitive(using Ctx): Gen[Primitive[Flags, V, OTpe]] = for {
      p <- Gen.oneOf(rpyeffectasm.common.Primitives.primitives)
      name <- p.name
      ins <- Gen.listOfN(p.insT.length, rhs)
      outs <- Gen.listOfN(p.outsT.length, lhs)
    } yield Primitive(outs, name, ins)

    def push(using Ctx): Gen[Push[Flags, Label, V, OTpe]] = Gen.sized{ s =>
      for {
        target <- label
        n <- Gen.choose(0, s)
        args <- Gen.listOfN(n, rhs)
      } yield Push(target, args)
    }
    def ret(using Ctx): Gen[Return[Flags, V, OTpe]] = for {
      args <- rhss
    } yield Return(args)

    def jump(using Ctx): Gen[Jump[Flags, Label, V, OTpe]] = for {
      t <- label
      e <- env
    } yield Jump(t, e)

    def callib(using Ctx): Gen[CallLib[Flags, V, OTpe]] = for {
      lib <- rhs
      symbol <- Gen.asciiPrintableStr
      e <- env
    } yield CallLib(lib, symbol, e)

    def loadlib(using Ctx): Gen[LoadLib[Flags, V, OTpe]] = for {
      p <- rhs
    } yield LoadLib(p)

    def ifZero(using Ctx): Gen[IfZero[Flags, Label, V, OTpe]] = for {
      s <- rhs
      th <- clause
    } yield IfZero(s, th)
    def switch(using Ctx): Gen[Switch[Flags, Label, V, OTpe]] = Gen.sized { s =>
      for {
        arg <- rhs
        n <- Gen.choose(0, s)
        cases <- Gen.listOfN(n, for {
          v <- Arbitrary.arbInt.arbitrary
          th <- label
        } yield (v, th))
        _env <- env
        default <- label
      } yield Switch(arg, cases, default, _env)
    }
    def allocate(using Ctx): Gen[Allocate[Flags, V, OTpe]] = for {
      ref <- lhs
      init <- rhs
      reg <- rhs
    } yield Allocate(ref, init, reg)
    def load(using Ctx): Gen[Load[Flags, V, OTpe]] = for {
      out <- lhs
      ref <- rhs
    } yield Load(out, ref)
    def store(using Ctx): Gen[Store[Flags, V, OTpe]] = for {
      ref <- rhs
      in <- rhs
    } yield Store(ref, in)

    def getDynamic(using Ctx): Gen[GetDynamic[Flags, V, OTpe]] = for {
      out <- lhs
      n <- rhs
      l <- rhs
    } yield GetDynamic(out, n, l)

    def shift(using Ctx): Gen[Shift[Flags, V, OTpe]] = for {
      out <- lhs
      n <- rhs
      l <- rhs
    } yield Shift(out, n, l)
    def control(using Ctx): Gen[Control[Flags, V, OTpe]] = for {
      out <- lhs
      n <- rhs
      l <- rhs
    } yield Control(out, n, l)
    def pushStack(using Ctx): Gen[PushStack[Flags, V, OTpe]] = for {
      s <- rhs
    } yield PushStack(s)
    def newStack(using Ctx): Gen[NewStack[Flags, Label, V, OTpe]] = for {
      out <- lhs
      reg <- lhs
      l <- rhs
      t <- label
      args <- rhss
    } yield NewStack(out, reg, l, t, args)
    def newStackWithBinding(using Ctx): Gen[NewStackWithBinding[Flags, Label, V, OTpe]] = for {
      out <- lhs
      reg <- lhs
      l <- rhs
      t <- label
      args <- rhss
      bnd <- rhs
    } yield NewStackWithBinding(out, reg, l, t, args, bnd)
    def construct(using Ctx): Gen[Construct[Flags, Tag, V, OTpe]] = for {
      out <- lhs
      tt <- tag
      t <- tag
      args <- rhss
    } yield Construct(out, tt, t, args)
    def matchI(using Ctx): Gen[Match[Flags, Tag, Label, V, OTpe]] = Gen.sized { s =>
      for {
        tt <- tag
        sc <- rhs
        n <- Gen.choose(0, s)
        clss <- Gen.listOfN(n, for {
          x <- tag
          c <- clause
        } yield (x, c))
        default <- clause
      } yield Match(tt, sc, clss, default)
    }
    def project(using Ctx): Gen[Proj[Flags, Tag, V, OTpe]] = Gen.sized { s =>
      for {
        out <- lhs
        tt <- tag
        sc <- rhs
        t <- tag
        f <- Gen.choose(0, s)
      } yield Proj(out, tt, sc, t, f)
    }

    def newI(using Ctx): Gen[New[Flags, Tag, Label, V, OTpe]] = Gen.sized { s =>
      for {
        out <- lhs
        it <- tag
        n <- Gen.choose(0, s)
        ts <- Gen.listOfN(n, for {
          t <- tag
          l <- label
        } yield (t, l))
        args <- rhss
      } yield New(out, it, ts, args)
    }
    def invoke(using Ctx): Gen[Invoke[Flags, Tag, V, OTpe]] = for {
      rcv <- rhs
      it <- tag
      ot <- tag
      args <- rhss
    } yield Invoke(rcv, it, ot, args)

    def anyInstruction(using Ctx): Gen[Instruction[Flags, Tag, Label, V]] = Gen.oneOf[Instruction[Flags, Tag, Label, V]](
      anyTerminator,
      anyNonTerminator,
    )
    def anyTerminator(using Ctx): Gen[Instruction[Flags, Tag, Label, V] & Terminator] = Gen.oneOf(
      jump, switch, matchI, callib, loadlib,
    )
    def anyNonTerminator(using Ctx): Gen[Instruction[Flags, Tag, Label, V]] = Gen.oneOf(
      let, letConst,
      primitive,
      push, ret,
      ifZero,
      allocate, load, store,
      shift, control, getDynamic,
      pushStack, newStack, newStackWithBinding,
      construct, project,
      newI, invoke,
    )

    def block(using Ctx): Gen[Block[Flags, Tag, Label, V]] = Gen.sized { s =>
      for {
        lbl <- label
        params <- Gen.listOf(lvariable)
        l <- Gen.choose(0, s)
        ins <- Gen.listOfN(l, Gen.resize(s / (l+1), anyNonTerminator))
        lins <- Gen.resize(s / (l+1), anyTerminator)
      } yield Block(lbl, params, ins :+ lins, Nil) // TODO exports
    }
    def program: Gen[Program[Flags, Tag, Label, V]] = Gen.sized { s =>
      for {
        n <- Gen.choose(1, s+1)
        blocks <- listOfN(n, Gen.resize(s / n, block))
      } yield Program(blocks)
    }
  }

  object simple extends InstructionGenerator[Nothing, Id, Id, Id] {
    import rpyeffectasm.asm.Generators.simple
    override def tag(using Ctx): Gen[Id] = id.any
    override def label(using Ctx): Gen[Id] = id.any
    override def v(using Ctx): Gen[Id] = id.any

    override type Ctx = Unit
    override def initialCtx: Ctx = ()
  }

}
