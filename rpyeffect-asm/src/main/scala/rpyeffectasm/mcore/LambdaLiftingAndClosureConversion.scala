package rpyeffectasm.mcore
import rpyeffectasm.util.{Phase, ErrorReporter, Emit}
import rpyeffectasm.util.ErrorReporter.*
import rpyeffectasm.util.Emit.{emit, emitAll}

import scala.collection.mutable
import scala.annotation.tailrec

/**
 * Lambda-lifting and closure conversion.
 * Breaks ANF form, so we will need to run ANF afterwards.
 *
 * Postconditions:
 * - All occurences of [[Abs]] are at the top of a toplevel definition
 * - In all occurences of [[App]], [[fn]] is a globally defined variable
 *
 * FIXME Not all types get transformed correctly (cmp. Return type of #317 in helium-compiled SimpleEffect.he)
 * TODO replace this with ClosureConversion >> LambdaLifting
 */
object LambdaLiftingAndClosureConversion extends Phase[Program[Var], Program[ATerm]] {
  override def apply(f: Program[Var])(using ErrorReporter): Program[ATerm] = {
    LambdaLifting(ANF(ClosureConversion(f)))
  }

}