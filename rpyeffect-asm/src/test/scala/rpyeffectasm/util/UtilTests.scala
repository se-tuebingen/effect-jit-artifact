package rpyeffectasm.util
import org.scalacheck.Shrink
import org.scalacheck.Arbitrary
import org.scalacheck.Gen
import org.scalacheck.Prop._
import scala.collection.mutable


class UtilTests extends munit.FunSuite with munit.ScalaCheckSuite {

  override val scalaCheckTestParameters = super.scalaCheckTestParameters.withMinSuccessfulTests(10000)
  property("escape andThen unescape is identity"){
    forAll(Arbitrary.arbString.arbitrary) { s => unescape(escape(s)) == s }
  }
  property("escaped Strings only contain safe chars"){
    forAll(Arbitrary.arbString.arbitrary) { s =>
      val e = escape(s)
      all(e.map { c => (c.isLetterOrDigit || (c.toInt >= 32 && c.toInt <= 126)) :| s"'${c}' not allowed"
    }: _*) :| s"in '${e}' = escape('${s}')" }
  }
  property("escaped Strings can be \"-delimited"){
    def splitStr(str: String): List[String] = {
      val res: mutable.ListBuffer[String] = mutable.ListBuffer.empty
      var cur = mutable.StringBuilder()
      var esc = false
      str.foreach{
        case c if esc => cur.addOne(c); esc = false
        case c@'\\' => cur.addOne(c); esc = true
        case '"' => res.addOne(cur.mkString); cur = mutable.StringBuilder()
        case c => cur.addOne(c)
      }
      res.addOne(cur.mkString)
      res.toList
    }
    forAll(Gen.listOf(Arbitrary.arbString.arbitrary)){ strs =>
      val esct = strs.map(escape)
      val sept = esct.mkString("\"")
      val split = splitStr(sept)
      val unesct = split.map(unescape)
      all((unesct zip strs).map(_ == _): _*) :| s"Original list: ${strs}\nEscaped: ${esct}\nSeperated str: '${sept}'\nSplit into: ${split}"
    }
  }

}
