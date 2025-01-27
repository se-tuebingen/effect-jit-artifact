package rpyeffectasm.asm
import scala.collection.immutable
import rpyeffectasm.util.{Phase, ErrorReporter}

/** Phase that replaces all IDs for blocks (targets) with their index. */
class BlockNumbering[F <: AsmFlags, Tag <: Id, Var <: Id]
  extends Phase[Program[F,Tag,Id,Var], Program[F,Tag,Index,Var]] {
  case class Numbering(byLabel: immutable.Map[Id, Int]) {
    val exitLabel = byLabel.values.max + 1
  }

  def apply(label: Id)(using N: Numbering): Index = IndexWithDebug(N.byLabel.getOrElse(label, N.exitLabel), label.toString)
  def apply(vtable: VTable[Tag, Id])(using Numbering): VTable[Tag, Index] = vtable.map {
    case (tag, id) => (tag, apply(id))
  }
  def apply(c: Clause[F, Id, Var])(using Numbering): Clause[F, Index, Var] = c match {
    case Clause(params, capts, target) => Clause(params, capts, apply(target))
  }
  def apply(i: Instruction[F, Tag, Id, Var])(using Numbering): Instruction[F, Tag, Index, Var] = i match {
    case Jump(target, args) => Jump(apply(target), args)
    case IfZero(arg, thenClause) => IfZero(arg, apply(thenClause))
    case NewStack(stack, region, label, target, args) =>
      NewStack(stack, region, label, apply(target), args)
    case NewStackWithBinding(stack, region, label, target, args, bnd) =>
      NewStackWithBinding(stack, region, label, apply(target), args, bnd)
    case Match(tpe, scrutinee, clauses, default) =>
      Match(tpe, scrutinee, clauses map { case (tag, v) => (tag, apply(v)) }, apply(default))
    case Switch(arg, cases, default, env) =>
      Switch(arg, cases.map{ case (i, t) => (i, apply(t))}, apply(default), env)
    case New(out, ifce, targets, args) => New(out, ifce, apply(targets), args)
    case Push(target, args) => Push(apply(target), args)
    case i: Instruction[F, Tag, Nothing, Var] @unchecked => i
  }
  def apply(b: Block[F, Tag, Id, Var])(using Numbering): Block[F, Tag, Index, Var] = b match {
    case Block(label, params, instructions, export_as) => Block(apply(label), params, instructions map apply, export_as)
  }
  override def apply(p: Program[F, Tag, Id, Var])(using ErrorReporter): Program[F, Tag, Index, Var] = p match {
    case Program(blocks) =>
      import rpyeffectasm.util.DebugInfo
      given numbering: Numbering = Numbering(blocks.map(_.label).zipWithIndex.toMap)
      val r = Program(blocks map apply)
      DebugInfo.log("asm", "BlockNumbering"){ numbering.byLabel }
      r
  }
}
