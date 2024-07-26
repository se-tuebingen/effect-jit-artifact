package rpyeffectasm.asm
import org.scalacheck.Gen

class TagNumberingTests extends AsmTestSuite[AsmFlags, Index, Id, Id, TypingPrecision] {
  type Input = Program[AsmFlags, Id, Id, Id, OperandType[TypingPrecision]]
  type Output = Program[AsmFlags, Index, Id, Id, OperandType[TypingPrecision]]

  override def runPhase(p: Input): Output = {
    val tagNumbering = new TagNumbering[AsmFlags, Id, Id, OperandType[TypingPrecision]]()
    tagNumbering(p)._1
  }

  testIdempotent("TagNumbering")(using Generators.simple.program)

  testResult("empty program")("","")
  testResult("Booleans as data")(
    """$foo() {
      |  $true:ptr <- $Bool.$True();
      |  $false:ptr <- $Bool.$False();
      |  $true2:ptr <- $Bool.$True();
      |  match $true:$Bool
      |      $False() => $elseCase()
      |    | $True() => $thenCase()
      |    | _ => $fail()
      |}
      |""".stripMargin,
    """$foo() {
      |  $true:ptr <- #0.#0();
      |  $false:ptr <- #0.#1();
      |  $true2:ptr <- #0.#0();
      |  match $true:#0
      |      #0() => $thenCase()
      |    | #1() => $elseCase()
      |    | _ => $fail()
      |}
      |""".stripMargin
  )
  testResult("Stream interface cons")(
    """$cons($hd:num,$tl:ptr) {
      |  $s:ptr <- $stream($hd:num,$tl:ptr) {
      |      $head => $head;
      |      $tail => $tail
      |  }
      |}
      |""".stripMargin,
    """$cons($hd:num,$tl:ptr) {
      |  $s:ptr <- #0($hd:num,$tl:ptr) {
      |      #0 => $head;
      |      #1 => $tail
      |  }
      |}
      |""".stripMargin
  )
}
