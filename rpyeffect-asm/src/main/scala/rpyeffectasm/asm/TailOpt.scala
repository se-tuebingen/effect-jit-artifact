package rpyeffectasm
package asm
import rpyeffectasm.util.{ErrorReporter, Phase}
import rpyeffectasm.rpyeffect

class TailOpt[F <: AsmFlags, Tag <: Id, Label <: Id, V <: Id]
  extends Phase[Program[F, Tag, Label, V], Program[F, Tag, Label, V]] {

  case class Context(isForward: Map[Label, Spec])

  def isForward(block: Block[F, Tag, Label, V]): Boolean = block match {
    case Block(label, params, instructions, export_as) =>
      if(instructions.forall {
        case Return(args) => true
        case Debug(msg, trace) => true
        case Let(lhss, rhss) if (lhss zip rhss).forall(_==_) => true
        case _ => false
      }) {
        instructions.last match {
          case Return(args) =>
            paramSpec(params) == argSpec(args)
          case _ => false
        }
      } else false
  }

  case class Spec(spec: List[Var[V]])
  def paramSpec(params: LhsOpList[F, V]): Spec =
    Spec(params.map { case (x: Var[V]) => x })
  def argSpec(args: RhsOpList[F, V]): Spec =
    Spec(args.map { case (x: Var[V]) => x })

  def rewrite(block: Block[F, Tag, Label, V])(using C: Context): Block[F, Tag, Label, V] = block match {
    case Block(label, params, instructions, export_as) =>
      Block(label, params, instructions.flatMap {
        case Push(target, args) if C.isForward.contains(target) => None // Pushing a frame that does not do anything
        case i => Some(i)
      }, export_as)
  }

  override def apply(f: Program[F, Tag, Label, V])(using ErrorReporter): Program[F, Tag, Label, V] = f match {
    case Program(blocks) =>
      given Context(blocks.filter(isForward).map { x =>
        (x.label, paramSpec(x.params))
      }.toMap)
      Program(blocks map rewrite)
  }
}
