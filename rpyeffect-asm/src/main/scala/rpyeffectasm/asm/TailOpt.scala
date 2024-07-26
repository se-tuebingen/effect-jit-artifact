package rpyeffectasm
package asm
import rpyeffectasm.util.{ErrorReporter, Phase}
import rpyeffectasm.rpyeffect

class TailOpt[F <: AsmFlags, Tag <: Id, Label <: Id, V <: Id, OTpe <: OperandType[TypingPrecision.ConcretelyTyped]]
  extends Phase[Program[F, Tag, Label, V, OTpe], Program[F, Tag, Label, V, OTpe]] {

  case class Context(isForward: Map[Label, Spec])

  def isForward(block: Block[F, Tag, Label, V, OTpe]): Boolean = block match {
    case Block(label, params, _, instructions, export_as) =>
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

  case class Spec(spec: Map[rpyeffect.RegisterType, List[Var[V, OTpe]]])
  def paramSpec(params: LhsOpList[F, V, OTpe]): Spec =
    Spec(params.groupMap { x => Type.getRegisterType(x.tpe) } { case y: Var[_,_] => y }.toMap)
  def argSpec(args: RhsOpList[F, V, OTpe]): Spec =
    Spec(args.groupMap { x => Type.getRegisterType(x.tpe) } { case y: Var[_,_] => y }.toMap)

  def rewrite(block: Block[F, Tag, Label, V, OTpe])(using C: Context): Block[F, Tag, Label, V, OTpe] = block match {
    case Block(label, params, retTpe, instructions, export_as) =>
      Block(label, params, retTpe, instructions.flatMap {
        case Push(target, args) if C.isForward.contains(target) => None // Pushing a frame that does not do anything
        case i => Some(i)
      }, export_as)
  }

  override def apply(f: Program[F, Tag, Label, V, OTpe])(using ErrorReporter): Program[F, Tag, Label, V, OTpe] = f match {
    case Program(blocks) =>
      given Context(blocks.filter(isForward).map { x =>
        (x.label, paramSpec(x.params))
      }.toMap)
      Program(blocks map rewrite)
  }
}
