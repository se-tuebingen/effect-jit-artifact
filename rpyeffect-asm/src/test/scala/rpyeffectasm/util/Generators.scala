package rpyeffectasm.util
import org.scalacheck.{Gen, Arbitrary}

object Generators {

  object JsonGen {
    def str: Gen[Json.Str] = for { c <- Arbitrary.arbString.arbitrary } yield Json.Str(c)
    def int: Gen[Json.Int] = for { i <- Arbitrary.arbInt.arbitrary } yield Json.Int(i)
    def double: Gen[Json.Double] = for { d <- Arbitrary.arbDouble.arbitrary } yield Json.Double(d)
    def bool: Gen[Json.Bool] = Gen.oneOf(true, false).map(Json.Bool.apply)
    def nil: Gen[Json.Null.type] = Gen.const(Json.Null)
    def list: Gen[Json.List] = Gen.sized{ s =>
      for {
        n <- Gen.choose(0, s)
        l <- Gen.listOfN(n, Gen.resize(s / (1 + n), JsonGen.any))
      } yield Json.List(l)
    }
    def dict: Gen[Json.Dict] = Gen.sized { s =>
      for {
        n <- Gen.choose(0, s)
        its <- Gen.listOf(
          for {
            k <- Gen.alphaNumStr // Don't be too crazy for now
            v <- Gen.resize(s / (1 + n), any)
          } yield k -> v)
      } yield Json.Dict(its.toMap)
    }
    def any: Gen[Json] = Gen.sized {s =>
      if (s <= 1) {
        Gen.oneOf(str, int, double, bool, nil)
      } else {
        Gen.oneOf(str, int, double, bool, nil, list, dict)
      }
    }
  }

  def exactlyNOf[A](n: Int, g: Gen[A]): Gen[List[A]] = if(n == 0) {
    Gen.const(Nil)
  } else {
    for {
      hd <- g
      tl <- exactlyNOf(n-1, g)
    } yield (hd :: tl)
  }
  def orderedSubsetOf[A](set: List[A]): Gen[List[A]] = for {
    children <- Generators.exactlyNOf(set.length, Arbitrary.arbBool.arbitrary)
  } yield children.zipWithIndex.collect { case (true, i) => set(i) }

  def shuffled[A](l: List[A]): Gen[List[A]] = for { // FIXME
    r <- exactlyNOf(l.length, Arbitrary.arbInt.arbitrary)
  } yield (l zip r).sortBy(_._2).map(_._1)

}
