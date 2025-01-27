package rpyeffectasm.util
import scala.util.parsing.combinator.{JavaTokenParsers, Parsers, RegexParsers}
import rpyeffectasm.util.ErrorReporter.{error, fatal}

enum Json {
  case Str(s: String)
  case Int(i: scala.Long)
  case Double(d: scala.Double)
  case Bool(b: Boolean)
  case Null
  case List(l: scala.List[Json])
  case Dict(d: Map[String, Json])
  case Raw(s: String)

  def pprint: String = this match {
    case Str(s: String) => JsonPrinter.jsonString(s)
    case Int(i: scala.Long) => i.toString
    case Double(d: scala.Double) => d.toString
    case Bool(b: Boolean) => b.toString
    case Null => "null"
    case List(l: scala.List[Json]) => JsonPrinter.jsonList(l.map(_.pprint))
    case Dict(d: Map[String, Json]) => JsonPrinter.jsonObject(d.view.mapValues(_.pprint).toMap)
    case Raw(s) => s
  }
  def removeField(key: String): Json = this match {
    case Dict(d) => Dict(d.removed(key))
    case _ => sys error "Cannot remove field of non-dictionary json value"
  }
  def +(el: (String, Json)): Json = this match {
    case Json.Dict(d) => Json.Dict(d + el)
    case _ => sys error "Cannot add field to non-dictionary json value"
  }
}

/** Json parser combinators. WIP */
trait JsonParsers {

  import scala.io.Source

  object Parser extends JavaTokenParsers with RegexParsers {
    import rpyeffectasm.util
    override def skipWhitespace: Boolean = true

    // hotfix https://github.com/scala/scala-parser-combinators/issues/371
    override def stringLiteral = ("\""+"""([^"\p{Cntrl}\\]|\\[\\'"bfnrt]|\\u[a-fA-F0-9]{4})*+"""+"\"").r

    def jsonStr: Parser[String] = stringLiteral ^^ { s => unescape(s.substring(1, s.length - 1)) }

    def jsonParser: Parser[Json] = {
      jsonStr ^^ Json.Str.apply
        | floatingPointNumber ^^ { s =>
          try {
            Json.Int(s.toLong)
          } catch {
            case _: NumberFormatException => Json.Double(s.toDouble)
          }
        }
        | "true" ^^ { _ => Json.Bool(true) }
        | "false" ^^ { _ => Json.Bool(false) }
        | "null" ^^ { _ => Json.Null }
        | "[" ~> repsep(jsonParser, opt(",")) <~ "]" ^^ Json.List.apply
        | "{" ~> repsep(jsonStr ~ (":" ~> jsonParser), opt(",")) <~ "}" ^^ { els => Json.Dict(els.map { case (k ~ v) => (k, v) }.toMap) }
    }
  }

  sealed trait Result[+T]
  trait JsonError extends Throwable with Result[Nothing] with Error {
    def message: String
    private var location: List[String] = Nil
    def at(s: String): JsonError = {
      location = s :: location
      this
    }
    def where: String = location.mkString("\n  ")
    def msg = message + "\n  " + where
  }
  case class OK[+T](result: T) extends Result[T]

  object Result {

    import rpyeffectasm.util

    extension[T](self: Result[T]) {
      def flatMap[T2](fn: T => Result[T2]): Result[T2] = self match {
        case OK(result) => fn(result)
        case e: Result[Nothing] @unchecked => e
      }
      def map[T2](fn: T => T2): Result[T2] = self.flatMap{ x => OK(fn(x)) }
    }
  }

  trait JsonParser[+T] extends Parser.Parser[T] {

    def apply(json: Json): Result[T]

    override def apply(in: Parser.Input): Parser.ParseResult[T] = Parser.jsonParser.apply(in) match {
      case Parser.Success(result, next) =>
        apply(result) match {
          case OK(result) => Parser.Success(result, next)
          case e: JsonError => Parser.failure(e.msg)(in)
        }
      case e: Parser.NoSuccess => e
    }
  }

  def string: JsonParser[String] = new JsonParser[String] { def apply(json: Json) = json match {
    case Json.Str(s) => OK(s)
    case r => new JsonError { def message = s"Expected string, got ${r}" }
  }}
  def exactStr(expected: String): JsonParser[Unit] = new JsonParser[Unit] {
    override def apply(jsonP: Json): Result[Unit] = jsonP match {
      case Json.Str(got) if got == expected => OK(())
      case _ => new JsonError{
        def message = (s"Expected \"${expected}\", got ${jsonP}")
        override def json = {
          import scala.collection.immutable.ListMap
          JsonPrinter.jsonObject(ListMap(
            ("message", message),
            ("expected", JsonPrinter.jsonString(expected)),
            ("got", jsonP.pprint)
          ))
        }
      }
    }
  }
  def fail(_msg: String): JsonParser[Nothing] = new JsonParser[Nothing] { def apply(json: Json) = new JsonError {
    override def message: String = _msg
  }}
  def int: JsonParser[Int] = new JsonParser[Int] { def apply(json: Json) = json match {
    case Json.Int(s) => OK(s.toInt)
    case r => new JsonError { def message = s"Expected int, got ${r}" }
  }}
  def double: JsonParser[Double] = new JsonParser[Double] { def apply(json: Json) = json match {
    case Json.Double(s) => OK(s)
    case Json.Int(i) => OK(i.toDouble)
    case r => new JsonError { def message = s"Expected double, got ${r}" }
  }}
  def bool: JsonParser[Boolean] = new JsonParser[Boolean] { def apply(json: Json) = json match {
    case Json.Bool(s) => OK(s)
    case r => new JsonError { def message = s"Expected bool, got ${r}" }
  }}
  def jsonNull: JsonParser[Unit] = new JsonParser[Unit] { def apply(json: Json) = json match {
    case Json.Bool(s) => OK(())
    case r => new JsonError { def message = s"Expected null, got ${r}" }
  }}
  def list[T](of: JsonParser[T]): JsonParser[List[T]] = new JsonParser[List[T]] { def apply(json: Json) = json match {
    case Json.List(l) =>
      try {
        OK(l.zipWithIndex.map { case (el: Json, i) =>
          of(el) match {
            case OK(result) => result
            case e: JsonError => throw (e.at(s"in list at position ${i}"))
          }
        })
      } catch {
        case (e: JsonError) => e
      }
    case r => new JsonError { def message = s"Expected list, got ${r}" }
  }}
  def obj[T](contents: JsonParser[T]): JsonParser[T] = new JsonParser[T] {
    override def apply(json: Json): Result[T] = json match {
      case Json.Dict(d) => contents(json)
      case o => new JsonError{ def message = "Expected object, got " ++ o.toString }.at("in object")
    }
  }

  extension[L](l: JsonParser[L]) {
    def &[R](r: JsonParser[R]) = new JsonParser[(L,R)] {
      override def apply(json: Json) = {
        (l(json),r(json)) match {
          case (OK(lv), OK(rv)) => OK((lv,rv))
          case (e: JsonError, _) => e
          case (_, e: JsonError) => e
        }
      }
    }
    def &=[R](r: L => JsonParser[R]) = new JsonParser[(L,R)] {
      override def apply(json: Json): Result[(L, R)] = {
        import rpyeffectasm.util
        for( lres <- l(json); rres <- r(lres)(json) ) yield (lres,rres)
      }
    }
    def ||(r: JsonParser[L]): JsonParser[L] = new JsonParser[L] {
      override def apply(in: Json): Result[L] = l(in) match {
        case OK(x) => OK(x)
        case _ => r(in)
      }
    }

    def ^[R](fn : L => R): JsonParser[R] = new JsonParser[R] {
      override def apply(json: Json): Result[R] = l(json).map(fn)
    }
    def ^??[R](fn : L => Option[R]): JsonParser[R] = new JsonParser[R] {
      override def apply(json: Json): Result[R] = l(json).flatMap { x =>
        fn(x) match {
          case Some(value) => OK(value)
          case None => new JsonError {
            override def message: String = "mapping function returned None"
          }
        }
      }
    }
  }
  extension(key: String) {
    def ->[V](v: JsonParser[V]): JsonParser[V] = new JsonParser[V] {
      def apply(json: Json): Result[V] = json match {
        case Json.Dict(entries) if entries.contains(key) =>
          import rpyeffectasm.util
          v(entries(key)) match {
            case OK(result) => OK(result)
            case error: JsonError if entries.contains("op") =>
              error.at(s"in value for '${key}' of ${entries("op")}")
            case error: JsonError =>
              error.at(s"in value for '${key}'")
          }
        case Json.Dict(entries) => new JsonError {
          override def message: String = s"Missing key ${key}"
        }
        case other => new JsonError {
          override def message: String = s"Expected dict, got ${other}"
        }
      }
    }
  }

  def optional[T](p: JsonParser[T]): JsonParser[Option[T]] = new JsonParser[Option[T]] {
    override def apply(json: Json): Result[Option[T]] = p(json) match {
        case error: JsonError => OK(None)
        case OK(result) => OK(Some(result))
      }
  }

  def any: JsonParser[Json] = new JsonParser[Json] {
    override def apply(json: Json): Result[Json] = OK(json)
  }

  def parse[T](j: JsonParser[T], i: Source)(using ErrorReporter): T = {
    Parser.parse(j, i.mkString) match {
      case Parser.Success(result, next) if next.atEnd => result
      case Parser.Success(result, next) =>
        val trailing = next.source.subSequence(next.offset, next.source.length())
        if (trailing.toString.trim.isEmpty) {
          result
        } else {
          error(s"Trailing garbage: '${trailing}'");
          result
        }
      case e: JsonError => fatal(s"FATAL: ${e.msg}")
      case e => fatal(s"FATAL: ${e}")
    }
  }

}
object JsonParsers extends JsonParsers