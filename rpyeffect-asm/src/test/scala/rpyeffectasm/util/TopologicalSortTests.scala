package rpyeffectasm.util
import org.scalacheck.Prop.*
import org.scalacheck.{Prop, Gen, Arbitrary}
import scala.collection.mutable

class TopologicalSortTests extends munit.FunSuite with munit.ScalaCheckSuite {


  case class PO(deps: List[List[Int]], els: List[Int])
  def genPartialDeps(k: Int): Gen[List[List[Int]]] = {
    if(k == 0) {
      Gen.const(List())
    } else if(k == 1) {
      Gen.const(List(Nil))
    } else {
      for {
        init <- genPartialDeps(k - 1)
        last <- Generators.orderedSubsetOf((0 until (k-1)).toList)
      } yield (init :+ last)
    }
  }
  def genPartialDeps(): Gen[List[List[Int]]] = Gen.sized { s =>
    for {
      k <- Gen.choose(0, s)
      po <- genPartialDeps(k)
    } yield po
  }
  def genPO(): Gen[PO] = for {
    deps <- genPartialDeps()
    els <- Generators.shuffled(deps.indices.toList)
  } yield PO(deps, els)

  property("Post: Elements are in topological order (on PO)"){
    forAll(genPO()){ po =>
      try {
        val ts = topologicalSortWithKey(po.els)(po.deps.apply) { x => x }

        var seen: Set[Int] = Set()
        all(ts.map { i =>
          val p = all(po.deps(i).map{ d => seen.contains(d) :| s"${i} emitted before it's dependency ${d}" }: _*)
          seen = seen + i
          p
        }: _*) :| s"Input order: ${po.els}\nOutput order: ${ts}\nDependencies:\n${po.deps.zipWithIndex.map{(c,p) => s"  ${p} => ${c}"}.mkString("\n")}"
      } catch {
        case RecursiveDependenciesException(_) => Prop.undecided
      }
    }
  }

}
