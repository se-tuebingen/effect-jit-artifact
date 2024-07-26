package rpyeffectasm.asm

import rpyeffectasm.util.Phase
import rpyeffectasm.util.ErrorReporter

import scala.collection.mutable
class Elaboration[F >: AsmFlags.ConstantOperands <: AsmFlags, Tag <: Id, Label <: Id]
  extends Phase[Program[F,Tag,Label,Id], Program[Nothing, Tag, Label, Id]] {

  override def apply(program: Program[F, Tag, Label, Id])(using ErrorReporter): Program[Nothing, Tag, Label, Id] = program match {
    case Program(blocks) => program.asInstanceOf[Program[Nothing, Tag, Label, Id]]//Program(blocks map apply)
  }
}
