package rpyeffectasm.asm
class TransformerTests extends munit.FunSuite {

  //region Helper functions
  import rpyeffectasm.asm.TypingPrecision.ConcretelyTyped
  import rpyeffectasm.util

  private val asmParser = new AsmParser()
  def parseInput(s: String): Program[Nothing, Index, Index, Index] = {
    asmParser.parse(asmParser.program, s) match {
      case asmParser.Success(result, next) =>
        if(!next.atEnd){
          fail(s"Parsing failed, trailing garbage: ```\n${next.source.subSequence(next.offset, Math.min(next.offset+80, next.source.length()))}\n...```")
        }
        result.asInstanceOf[Program[Nothing, Index, Index, Index]] // TODO actually check
      case e => fail(s"Parsing failed: ${e}")
    }
  }
  def parseOutput(s: String): rpyeffectasm.util.Json = {
    import rpyeffectasm.util.*
    JsonParsers.parse(JsonParsers.any, io.Source.fromString(s))
  }

  given errs: util.ErrorReporter = new util.ErrorReporter {
    var hasErrors: Boolean = false
    override def error(e: util.Error): Unit = fail(s"Error while compiling test input: ${e.msg}")
    override def doThrow: Nothing = fail("Compiling test input failed")
  }

  def assertResult(input: String, result: String) = {
    import rpyeffectasm.rpyeffect.PrettyPrinter
    import rpyeffectasm.util.ErrorReporter
    val i = parseInput(input)
    val transformer = new Transformer()
    val got = transformer(i)
    val gotN = parseOutput(PrettyPrinter.format(got))
    val expected = parseOutput(result)
    assertNoDiff(gotN.pprint, expected.pprint)
    assertEquals(gotN,expected)
  }

  def testResult(name: String)(input: String, output: String) = test(name){
    assertResult(input, output)
  }
  //endregion

  testResult("Minimal program")(
    """#0(#0:int) {
      |  jump #1()
      |}
      |""".stripMargin,
    """{"blocks":[
      |    {"label":"0()",
      |     "frameDescriptor":{"regs_num":1,"regs_ptr":0},
      |     "instructions":[
      |       {"op":"Jump","target":1}
      |     ]}
      | ],
      | "symbols": [],
      | "frameSize":{"regs_num":1,"regs_ptr":0}}
      |""".stripMargin
  )
  // TODO
}
