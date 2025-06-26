package rpyeffectasm.asm
class RegisterAllocationTests extends AsmTestSuite[Nothing, Id, Id, Index]{
  type Input = Program[Nothing, Id, Id, Id]

  override def runPhase(p: Input): Output = {
    val registerAllocation = new RegisterAllocation[Id, Id]()
    registerAllocation(p)
  }

  testResult("empty program")("","")

  testResult("simple loop with one int var")(
    """$loop($x:int) {
      |  jump $loop($x:int)
      |}
      |""".stripMargin,
    """$loop(#0%"Name(x)":int) {
      |  jump $loop(#0%"Name(x)":int)
      |}
      |""".stripMargin)

  testResult("lots of int vars")(
    """$foo($x:int) {
      |   let const $y:int <- 42;
      |   let const $z:int <- 33;
      |   let const $w:int <- 12;
      |   jump $bar($x:int, $w:int, $y: int)
      |}
      |""".stripMargin,
    """$foo(#0%"Name(x)":int) {
      |  let const #1%"Name(y)":int <- 42;
      |  let const #2%"Name(z)":int <- 33;
      |  let const #2%"Name(w)":int <- 12;
      |  let #1%"Name(y)":int <- #2%"Name(w)":int, #2%"Name(w)":int <- #1%"Name(y)":int;
      |  jump $bar(#0%"Name(x)":int, #1%"Name(w)":int, #2%"Name(y)":int)
      |}
      |""".stripMargin
  )

  testResult("num and ptr args")(
    """$foo($a:num,$b:ptr,$c:num,$d:int) {
      |}
      |""".stripMargin,
    """$foo(#0%"Name(a)":num,#1%"Name(b)":ptr,#2%"Name(c)":num,#3%"Name(d)":int) {
      |}
      |""".stripMargin
  )

  testEvaluation("Simple `second` function call")(
    """$entry() {
       |  let const $x:int <- 42;
       |  let const $y:int <- 377;
       |  jump $foo($y:int, $x:int)
       |}
       |$foo($x:int, $y:int) {
       |  return($y:int)
       |}
       |""".stripMargin)
}
