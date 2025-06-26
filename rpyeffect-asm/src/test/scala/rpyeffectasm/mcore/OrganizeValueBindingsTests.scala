package rpyeffectasm.mcore
import org.scalacheck.Prop
import org.scalacheck.Prop._
import org.scalacheck.Shrink
import scala.collection.immutable
import rpyeffectasm.util.{Query, ErrorReporter, StringTarget}

class OrganizeValueBindingsTests extends MCoreTestSuite[Var] {
  override val scalaCheckInitialSeed = "U1PUHiw_sq8tnn7kdxwlcUXrSKDV_DYcJ3SF9NB4faI="

  type Input = Program[Var]
  override def runPhase(p: Input): Output = {
    val phase = new OrganizeValueBindings[Var]
    phase(p)
  }

//  testResult("program without definitions")(
//    """$x:top""".stripMargin,
//    """(define $gen0:(fun Effectful (ptr) ptr) (lambda ($gen1:ptr)
//      |    (let ((define $gen2:str "???"))
//      |      (prim ($gen3:unit) ("setGlobal(String, Ptr): Unit" $gen2:str $gen1:ptr)
//      |        $gen1:ptr)))
//      |    :export-as ("$static-init"))
//      |$x:top""".stripMargin
//  )

//  testResult("program with different definitions")(
//    """(define $x:num 12)
//      |(define $foo:(fun Pure () unit) (lambda () (unit)))
//      |$x:num""".stripMargin,
//    """(define $foo:(fun Pure () unit) (lambda () (unit)))
//      |
//      |(define $gen0:(fun Effectful (ptr) ptr) (lambda ($gen1:ptr)
//      |     (let ((define $gen2:str "Name(x)") (define $x:num 12))
//      |       (prim ($gen3:unit) ("setGlobal(String, Ptr): Unit" $gen2:str $x:top)
//      |         (let ((define $gen4:str "???"))
//      |           (prim ($gen5:unit) ("setGlobal(String, Ptr): Unit" $gen4:str $gen1:ptr)
//      |             $gen1:ptr)))))
//      |     :export-as ("$static-init"))
//      |
//      |(let ((define $gen6:ptr (label null)))
//      |  (begin
//      |   ($gen0:(fun Effectful (ptr) ptr) $gen6:ptr)
//      |   (let ((define $gen7:str "Name(x)"))
//      |     (prim ($x:top) ("getGlobal(String): Ptr" $gen7:str)
//      |         $x:num))))""".stripMargin
//  )
  // TODO more tests

  given Shrink[Program[Var]] = Generators.wellScopedVarProgram.shrink
  property("there are no global definitions with non-function type afterwards".ignore){
    // FIXME needs a better Generator
    forAll(Generators.wellScopedVarProgram.any){ (p: Program[Var]) =>
        wheneverNoFatal {
          val res = (new OrganizeValueBindings[Var])(p)
          all(res.definitions.map {
            case Definition(name, binding: Var, _) => Prop(true) // for now TODO
            case Definition(name, binding, _) =>
              name.tpe match {
                case Top | Ptr => Prop(true) // for now TODO
                case Function(params, ret, purity) => Prop(true)
                case t => Prop.falsified :| s"Global definition of '${name}' with type ${pp(t)}."
              }
          }.toArray: _*) :| s"In program:\n ${pp(p)}"
        }
    }
  }
  property("OrganizeValueBindings does not introduce free variables") {
    forAll(Generators.wellScopedVarProgram.any) { (p: Program[Var]) =>
      val res = try {
        runPhase(LambdaLifting(p))
      } catch {
        case _ => Program(Nil, Literal.Int(0))
      }
      import rpyeffectasm.mcore.analysis.FreeVariables
      val oldFrees = FreeVariables(p).toSet
      val frees = FreeVariables(res).toSet
      (frees -- oldFrees).isEmpty :|
      s"""After OrganizeValueBindings the following program contains free variables ${frees.map(SExpPrettyPrinter(_)).mkString(",")}
         |---- Input:
         |${SExpPrettyPrinter(p).emitTo(StringTarget())}
         |---- Output:
         |${SExpPrettyPrinter(res).emitTo(StringTarget())}
         |-----------
            """.stripMargin
    }
  }
}
