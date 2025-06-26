package rpyeffectasm.asm
class BlockNumberingTests extends AsmTestSuite[AsmFlags, Id, Index, Id] {
  type Input = Program[AsmFlags, Id, Id, Id]

  def runPhase(p: Input): Output = {
    val phase = new BlockNumbering[AsmFlags, Id, Id]()
    phase(p)
  }

  testIdempotent("BlockNumbering")(using Generators.simple.program)

  testResult("empty program")("","")

  testResult("simple infinite loop")(
      """$loop():ptr {
        |  jump $loop()
        |}
        |""".stripMargin,
      """#0%"Name(loop)"():ptr {
        |  jump #0%"Name(loop)"()
        |}
        |""".stripMargin)

  testResult("multiple blocks")(
      """$foo() {
        |  jump $bar()
        |}
        |$bar() {
        |  if0 $a jump $foo()
        |}
        |""".stripMargin,
      """#0%"Name(foo)"() {
        |  jump #1%"Name(bar)"()
        |}
        |#1%"Name(bar)"() {
        |  if0 $a jump #0%"Name(foo)"()
        |}
        |""".stripMargin)
}
