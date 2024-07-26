package rpyeffectasm.asm

import rpyeffectasm.util.Phase
import rpyeffectasm.util.ErrorReporter

import scala.collection.mutable
class Elaboration[F >: AsmFlags.ConstantOperands <: AsmFlags, Tag <: Id, Label <: Id, OTpe >: Base]
  extends Phase[Program[F,Tag,Label,Id,OTpe], Program[Nothing, Tag, Label, Id, OTpe]] {

  override def apply(program: Program[F, Tag, Label, Id, OTpe])(using ErrorReporter): Program[Nothing, Tag, Label, Id, OTpe] = program match {
    case Program(blocks) => program.asInstanceOf[Program[Nothing, Tag, Label, Id, OTpe]]//Program(blocks map apply)
  }
}
