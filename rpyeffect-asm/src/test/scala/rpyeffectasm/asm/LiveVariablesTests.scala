package rpyeffectasm.asm
import rpyeffectasm.util.ErrorReporter
import scala.annotation.tailrec

class LiveVariablesTests extends munit.FunSuite {
  private val parser = new AsmParser()

  type Input = Program[AsmFlags, Id, Id, Id, OperandType[TypingPrecision]]

  def parse(s: String): Program[AsmFlags, Id, Id, Id, OperandType[TypingPrecision]] = {
    parser.parse(parser.program, s) match {
      case parser.Success(result, next) =>
        if (!next.atEnd) {
          fail(s"Parsing failed, trailing garbage: ```\n${next.source.subSequence(next.offset, Math.min(next.offset + 80, next.source.length()))}\n...```")
        }
        result
      case e => fail(s"Parsing failed: ${e}"); ???
    }
  }

  /** At each step, restrict only to the live variables. This only drops dead variables, thus should not change the result! */
  def testMutatingOnInput(name: String)(input: String) = {
    test(name){
      ErrorReporter.catchExitOutside{ ErrorReporter.withErrorsToStderr {
        import rpyeffectasm.asm.Interpreter.*
        val i = parse(input)
        val result = Interpreter(i).terminationCause
        val liveVariables = i.blocks.map { b =>
          b.label ->
          LiveVariables[AsmFlags, Id, Id, Id, TypingPrecision, OperandType[TypingPrecision]].zipInstructionsWith(b.instructions)
        }.toMap

        def mutate(state: State, currentLive: List[Id]): State = {
          val menv = state.env.collect {
            case b@((name, rtpe), value) if currentLive contains name => b
          }
          state.copy(env = menv)
        }

        @tailrec
        def go(state: State): TerminationCause = {
          val o = state.pretty(i).replaceAll("\n", "\n         ")
          val (currentIns, liveAfter) = liveVariables(state.pc_block)(state.pc_ins)
          step(i, state) match {
            case next: State =>
              if state.pc_block == next.pc_block && state.pc_ins + 1 == next.pc_ins // no jump
              then go(mutate(next, liveAfter))
              else go(next)
            case t: TerminationCause => t
          }
        }
        val mutatedResult = go(initialState(i))
        assertEquals(mutatedResult, result)
      }
    }}
  }

  testMutatingOnInput("Simple `second` function call")(
    """$entry():int {
      |  let const $x:int <- 42;
      |  let const $y:int <- 377;
      |  jump $foo($y:int, $x:int)
      |}
      |$foo($x:int, $y:int):int {
      |  return($y:int)
      |}
      |""".stripMargin)

}
