package rpyeffectasm.mcore

import rpyeffectasm.asm
import rpyeffectasm.util.{Phase, ErrorReporter, Emit}
import rpyeffectasm.util.ErrorReporter.impossible
import rpyeffectasm.util.Emit.emit
import rpyeffectasm.asm.{AsmFlags}
import rpyeffectasm.mcore.analysis.FVSet
import scala.collection.mutable

case class MCoreGenerated(val underlying: Generated) extends asm.Generated(s"mcore:${underlying.name}")
class Transformer extends Phase[Program[Var], asm.Program[asm.AsmFlags, asm.Id, asm.Id, asm.Id]] {

  import rpyeffectasm.asm.LiveVariables

  type Block = asm.Block[asm.AsmFlags, asm.Id, asm.Id, asm.Id]
  final type Instruction = asm.Instruction[asm.AsmFlags, asm.Id, asm.Id, asm.Id]
  class State {
    var gensyms: mutable.HashMap[Generated, asm.Generated] = mutable.HashMap.empty
    val blockNames: mutable.HashSet[Id] = mutable.HashSet.empty
    var currentBlock: asm.Id = new asm.Generated("root block")
  }
  def inBlock[R](block: asm.Id)(body: => R)(using S: State): R = {
    val oldB = S.currentBlock
    try {
      S.currentBlock = block
      return body
    } finally {
      S.currentBlock = oldB
    }
  }
  def withoutBlockNames(l: List[Var])(using s: State): List[Var] = l.collect {
    case v if !s.blockNames.contains(v.name) => v
  }

  def transform(x: Id)(using S: State): asm.Id = x match {
    case Name(name) => asm.Name(name)
    case Index(i) => asm.Index(i)
    case generated: Generated => S.gensyms.getOrElseUpdate(generated, new MCoreGenerated(generated))
  }
  def transform(x: LhsOperand)(using State, ErrorReporter): asm.Var[asm.Id] = x match {
    case Var(name, tpe: Function) =>
      ErrorReporter.fatal(s"Function ${name} is transformed to asm as Var. This should not happen (removed by lambda lifting + closure conversion)")
    case Var(name, tpe) => asm.Var(transform(name))
  }

  enum ResultForm {
    case Returned
    case StoredIn(x: asm.Var[asm.Id])
  }
  def transformMatchClause(doc: String, c: Clause[Var], env: List[asm.Var[asm.Id]], retTpe: Type)(using Emit[Block], ErrorReporter, State): asm.Clause[asm.AsmFlags, asm.Id, asm.Id] = c match {
    case Clause(params, body) =>
      val tParams = params map transform
      val target = asBlock(s"match_${doc}", env ++ tParams, retTpe){
        transformReturning(body)
      }
      asm.Clause(tParams, env ++ tParams, target)
  }
  def transform(literal: Literal): asm.LiteralType = literal match {
    case Literal.Int(value) => value
    case Literal.Bool(value) => value
    case _ => ???
  }
  def transformReturning(t: Term[Var])(using Emit[Block], Emit[Instruction], ErrorReporter, State): Unit = t match {
    case App(fn, args) =>
      emit(asm.Jump(transform(fn.name), args map transform))
    case Invoke(receiver, ifce_tag, method, args) =>
      emit(asm.Invoke(transform(receiver), transform(ifce_tag), transform(method), args map transform))
    case CallLib(lib, symbol, args, returnType) =>
      emit(asm.CallLib(transform(lib), symbol, args map transform))
    case LoadLib(path) =>
      emit(asm.LoadLib(transform(path)))
    case Match(scrutinee, tpe_tag, clauses, default) =>
      val env = withoutBlockNames((default :: clauses.map(_._2)).map{ c => analysis.FreeVariables(c) }.reduce(_ union _).toList)
      val tEnv = env map transform
      val retTpe = Type.of(t)
      val tDefault = transformMatchClause("def", default, tEnv, retTpe)
      val tClauses = clauses map { (t, c) => (transform(t), transformMatchClause(t.name, c, tEnv, retTpe)) }
      emit(asm.Match(transform(tpe_tag), transform(scrutinee), tClauses, tDefault))
    case Switch(scrutinee, cases, default) =>
      val env = withoutBlockNames((default :: cases.map(_._2)).map{ c => analysis.FreeVariables(c) }.reduce(_ union _).toList)
      val tEnv = env map transform
      val retTpe = Type.of(t)
      val tCases = cases.map{ case (v, thn) =>
        val target = new asm.Generated(s"switch case for ${v}")
        transformAsBlock(target, env, retTpe, thn)
        (transform(v), target)
      }
      val tDefault = new asm.Generated("switch default case")
      transformAsBlock(tDefault, env, retTpe, default)
      emit(asm.Switch(transform(scrutinee), tCases, tDefault, tEnv))
    case IfZero(cond, thn, els) =>
      val retTpe = Type.of(t)
      val thnTarget = new asm.Generated("then")
      val env = (analysis.FreeVariables(thn).toSet ++ analysis.FreeVariables(els).toSet ++ analysis.FreeVariables(cond).toSet)
        .toList.distinctBy(_.name).filterNot{ v =>
        v.tpe.isInstanceOf[Function] // would have been lifted by LambdaLifting, thus we do not need to pass it.
      }
      transformAsBlock(thnTarget, env, retTpe, thn)
      emit(asm.IfZero(transform(cond), asm.Clause(Nil, env map transform, thnTarget)))
      transformReturning(els)
    case Resume(cont, args) =>
      emit(asm.PushStack(transform(cont)))
      emit(asm.Return(args map transform))
    case Resumed(cont, body) =>
      emit(asm.PushStack(transform(cont)))
      transformReturning(body)
    case DebugWrap(inner, annotations) =>
      emit(asm.Debug(s"BGN: ${annotations}", Nil))
      transformReturning(inner)
      emit(asm.Debug(s"END: ${annotations}", Nil))
    case t if transformBinder.isDefinedAt(t) => transformBinder(t)(Nil, { t =>
      transformReturning(t)
    })
    case Shift(label, n, k, body, tpe) =>
      emit(asm.Shift(transform(k), transform(n), transform(label)))
      transformReturning(body)
    case Control(label, n, k, body, tpe) =>
      emit(asm.Control(transform(k), transform(n), transform(label)))
      transformReturning(body)
    case Reset(label, region, bnd, body, Clause(List(res), rbody)) =>
      val x = asm.Var(new asm.Generated("return_clause")) // TODO precise type
      val capts = withoutBlockNames((analysis.FreeVariables(rbody) - res).toList)
      val retTpe = label.tpe match {
        case Base.Label(Top, _) => Type.of(t) // TODO
        case Base.Label(at, _) => at
        case _ => Type.of(t)
      }
      val target = asBlock("return_clause", transform(res) :: (capts map transform), retTpe) {
        emit(asm.Debug("Returned to return clause", List(transform(res))))
        transformReturning(rbody)
      }
      bnd match {
        case Some(bnd) =>
          emit(asm.NewStackWithBinding(x, transform(region), transform(label), target, capts map transform, transform(bnd)))
        case None =>
          emit(asm.NewStack(x, transform(region), transform(label), target, capts map transform))
      }
      emit(asm.PushStack(x))
      transformReturning(body)
    case t =>
      transformBinding(t)(Nil) { x => emit(asm.Return(List(x))) }
  }

  def transformBinder(using eb: Emit[Block], e: Emit[Instruction], er: ErrorReporter, s: State): PartialFunction[Term[Var], (List[Var], (Term[Var] => Emit[Instruction] ?=> Unit)) => Unit] = {
    case Let(List(Definition(name, binding, Nil)), body) => (kcapts, k) =>
      transformBinding(binding)(withoutBlockNames((FVSet.from(kcapts) union analysis.FreeVariables(body) - name).toList)){
        x =>
          emit(asm.Let(List(transform(name)), List(x)))
          k(body)
      }
    case Let(defs, body) => (_, k) =>
      val (lhss, rhss) = defs.map{
        case Definition(name: Var, binding: Var, Nil) => (name, binding)
        case Definition(name, binding, Nil) => fatal("ANF transformation should have linearized parallel let with non-variable rhs.")
      }.unzip
      emit(asm.Let(lhss map transform, rhss map transform))
      k(body)
    case LetRec(defs, body) =>
      fatal("LetRec should have been removed after lambda lifting. Recursive values are not supported.")
    case LetRef(ref, region, binding, body) => (_, k) =>
      emit(asm.Allocate(transform(ref), transform(binding), transform(region)))
      k(body)
    case Primitive(name, args, returns, rest) => (_, k) =>
      emit(asm.Primitive(returns map transform, name, args map transform))
      k(rest)
    case DebugWrap(inner, annotations) =>
      emit(asm.Debug(s"BGN/: ${annotations}", Nil))
      transformBinder(inner)
  }

  def transformBinding(t: Term[Var])(kcapts: List[Var])(k: asm.Var[asm.Id] => Emit[Instruction] ?=> Unit)
                      (using emitblock: Emit[Block], e: Emit[Instruction], errorreporter: ErrorReporter, state: State): Unit = t match {
    case v @ Var(name, tpe) => k(transform(v))
    case Abs(params, body) => fatal("Local `Abs` should have been removed by lambda lifting or closure conversion.")
    case Seq(Nil) => transformBinding(Literal.Unit)(kcapts)(k)
    case Seq(List(t)) => transformBinding(t)(kcapts)(k)
    case Seq(t :: ts) => transformBinding(t)
      (withoutBlockNames((FVSet.from(kcapts) union ts.map(analysis.FreeVariables.apply).flattenFV).toList))
      { _ => transformBinding(Seq(ts))(kcapts)(k) }
    case Construct(tpe_tag, tag, args) =>
      val x = asm.Var(new asm.Generated("constructed"))
      emit(asm.Construct(x, transform(tpe_tag), transform(tag), args map transform))
      k(x)
    case Project(scrutinee, tpe_tag, tag, field) =>
      val x = asm.Var(new asm.Generated("proj_result"))
      emit(asm.Proj(x, transform(tpe_tag), transform(scrutinee), transform(tag), field))
      k(x)
    case New(ifce_tag, methods) =>
      val x = asm.Var(new asm.Generated(" new"))
      val captures = withoutBlockNames(methods.map{ case (t, c) => analysis.FreeVariables(c) }.flattenFV.toList).map(transform)
      val targets = methods.map{ case (t, Clause(params, body)) =>
        transform(t) -> asBlock(s"method_${t.name}", (params map transform) ++ captures, Type.of(body)){
          transformReturning(body)
        }
      }
      emit(asm.New(x, transform(ifce_tag), targets, captures))
      k(x)
    case Load(ref) =>
      val x = asm.Var(new asm.Generated("loaded"))
      emit(asm.Load(x, transform(ref)))
      k(x)
    case Store(ref, value) =>
      emit(asm.Store(transform(ref), transform(value)))
      transformBinding(Literal.Unit)(kcapts)(k)
    case FreshLabel() =>
      val x = asm.Var(new asm.Generated("fresh"))
      emit(asm.Primitive(List(x), "freshlabel", List())) // sic!
      k(x)
    case Primitive(name, args, returns, rest) =>
      emit(asm.Primitive(returns map transform, name, args map transform))
      transformBinding(rest)(kcapts)(k)
    case literal: Literal =>
      val x = asm.Var(new asm.Generated(s"literal ${literal.value}"))
      literal match {
      case Literal.Int(v) =>
        emit(asm.LetConst(x, v))
        k(x)
      case Literal.Bool(v) =>
        emit(asm.LetConst(x, v))
        k(x)
      case Literal.Double(v) =>
        emit(asm.LetConst(x, v))
        k(x)
      case Literal.String(s) =>
        emit(asm.LetConst(x, s))
        k(x)
      case Literal.StringWithFormat(v,f) =>
        emit(asm.LetConst(x, asm.FormatConst(f, v)))
        k(x)
      case Literal.Label =>
        k(asm.Var(asm.Index(-1)))
      case Literal.Unit =>
        val x = asm.Var(asm.Name("unit"))
        emit(asm.Construct(x, asm.Name("Unit"), asm.Name("unit"), Nil))
        k(x)
      }
    case GetDynamic(label, n) =>
      val x = asm.Var(new asm.Generated("dynamically bound value"))
      emit(asm.GetDynamic(x, transform(n), transform(label)))
      k(x)
    case DebugWrap(inner, annotations) =>
      emit(asm.Debug(s"BGN: ${annotations}", Nil))
      transformBinding(inner)(kcapts)(k)
      emit(asm.Debug(s"END: ${annotations}", Nil))

    case t if transformBinder.isDefinedAt(t) => transformBinder(t)(kcapts, { t =>
      transformBinding(t)(kcapts)(k)
    })
    case t =>
      val retTpe = Type.of(t)
      val x = asm.Var(new asm.Generated(s"returned@${state.currentBlock}[${SExpPrettyPrinter(t)}]"))
      val params = x :: (kcapts map transform)
      val klbl = asBlock("k", params, retTpe){
        emit(asm.Debug("Returned value", List(x)))
        k(x)
      }
      emit(asm.Push(klbl, params.tail))
      transformReturning(t)
  }
  def asBlock[R](params: List[asm.Var[asm.Id]], retTpe: Type)(k: Emit[Instruction] ?=> Unit)(using eb: Emit[Block], S: State, E: ErrorReporter): asm.Id = {
    asBlock("block", params, retTpe)(k)
  }
  def asBlock[R](doc: String, params: List[asm.Var[asm.Id]], retTpe: Type)(k: Emit[Instruction] ?=> Unit)(using eb: Emit[Block], S: State, E: ErrorReporter): asm.Id = {
    val name = new asm.Generated(s"${doc}@${S.currentBlock}")
    val instructions = inBlock(name) { Emit.collecting_[Instruction]{k} }
    emit(asm.Block(name, params, instructions, Nil)) // TODO exports
    name
  }

  def transformAsBlock(name: asm.Id, params: List[LhsOperand], retTpe: Type, body: Term[Var], exportAs: List[String] = Nil)(using Emit[Block], ErrorReporter, State): Unit = {
    inBlock(name) {
      val instructions = Emit.collecting_[Instruction] {
        emit(asm.Debug("parameters", params.map(transform)))
        transformReturning(body)
      }
      params.foreach{
        case p if p.tpe.isInstanceOf[Function] =>
          assert(false, s"Passing a function as a parameter ${p} to ${name}. This should have been converted to a closure by LambdaLifting.")
        case _ => ()
      }
      emit(asm.Block(name, params map { p => transform(p) }, instructions, exportAs))
    }
  }
  def transform(d: Definition[Var])(using Emit[Block], ErrorReporter, State): Unit = d match {
    case Definition(name, Abs(params, body), exportAs) =>
      ErrorReporter.withLocation(s"In definition of ${SExpPrettyPrinter(name)}") {
        val retTpe = name.tpe match {
          case Function(params, ret, purity) => ret
          case _ => Type.of(body)
        }
        transformAsBlock(transform(name.name), params, retTpe, body, exportAs)
      }
    case _ => fatal("Must run MakeConstantsLocal before Transformer")
  }
  override def apply(f: Program[Var])(using ErrorReporter): asm.Program[AsmFlags, asm.Id, asm.Id, asm.Id] = f match {
    case Program(definitions, main) =>
      given S: State = new State
      definitions.foreach{ case Definition(name, binding, exportAs) => S.blockNames.addOne(name.name) }
      val entrypoint = asm.Generated("main entrypoint")
      val blocks = Emit.collecting_[Block] {
        definitions.foreach(transform)
        ErrorReporter.withLocation("In main") {
          transformAsBlock(entrypoint, Nil, Base.Unit, main, List("$entrypoint"))
        }
      }
      asm.Program(blocks)
  }

  ////////////////////////////////////////////////////////////////////////////////
  override def precondition(f: Program[Var]): Unit = {
    super.precondition(f)

    val noExports = new Visitor {
      override def definition: PartialFunction[Definition[ATerm], Unit] = {
        case Definition(_, _, _ :: _) => assert(false, "Only toplevel definitions may be exported.")
      }
    }
    f.definitions.foreach{
      case Definition(_, body, _) => noExports(body)
    }
    noExports(f.main)
  }

}


