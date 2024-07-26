package rpyeffectasm
package mcore
package sugar
import rpyeffectasm.util.ErrorReporter

object RichPrimitives {

  def parsers(using ErrorReporter): PartialFunction[String, String => Term[ATerm]] = {
    case "json" => JsonParser().parseTerm
    case "sexp" => SExpParser.parseTerm
  }

  def isRichPrimitive(name: String)(using ErrorReporter): Boolean = {
    if (name.matches("![a-zA-Z]+:.*")) {
      val (pname, content) = name.splitAt(name.indexOf(':')+1)
      val npname = pname.stripPrefix("!").stripSuffix(":").toLowerCase
      parsers.isDefinedAt(npname) || npname == "undefined" || npname == "generic"
    } else false
  }

  def desugar(using ErrorReporter): PartialFunction[String, (List[ATerm], List[LhsOperand], Term[ATerm]) => Term[ATerm]] = {
    case name if isRichPrimitive(name) =>
      val (pname, content) = name.splitAt(name.indexOf(':')+1)
      val npname = pname.stripPrefix("!").stripSuffix(":").toLowerCase
      // FIXME: This might break with more than 10 arguments...
      npname match {
        case _ if parsers.isDefinedAt(npname) =>
          val b = parsers(npname)(content)
          { case (as, List(res), r) =>
            val ps = as.zipWithIndex.map{ (a, i) =>  Var(Name(s"arg${i}"), Type.of(a.unroll)) }
            val pdefs = (ps zip as).map { (p, a) => Definition(p, a.unroll, Nil) }
            Let(List(Definition(res,
              Let(pdefs, b), Nil)), r)
          }
        case "undefined" => (as,rs,r) =>
          val msg = Var(new Generated("panic msg/undefined"), Base.String)
          Let(List(Definition(msg, Literal.String(s"Undefined: ${content}"), Nil)),
            Primitive("panic(String): Bottom", msg :: as, rs, r))
        case _ => assert(false)
      }
  }

}
