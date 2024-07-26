package rpyeffectasm
package mcore

import rpyeffectasm.util.{Phase, ErrorReporter, Emit}
import scala.collection.mutable
import rpyeffectasm.mcore.analysis.FreeVariables
import rpyeffectasm.util.topologicalSortWithKey
import rpyeffectasm.common.Purity
import java.util.UUID

class OrganizeValueBindings[O >: Var <: ATerm] extends Phase[Program[O], Program[ATerm]] {
  // FIXME preserve ANF

  case class SplitDefinitions(values: List[Definition[O]], functions: List[Definition[O]])

  private def toRTpe(t: Type): String = "Ptr" // FIXME to prevent boxing globals

  lazy val selfLibName = s"ThisLib_${UUID.randomUUID()}"

  case class OrganizedDefinitions(values: List[Definition[O]], functions: List[Definition[O]]) {
    // assert: Values are topologically sorted

    def wrap(t: Term[O]): Term[O] = values.foldRight(t){
      case (d, t) => Let(List(d), t)
    }

    object asGlobals extends Structural[O, O] {
      def staticInit: (Var,Definition[O]) = {
        val self = Var(Generated("lib self"), Ptr)
        val name = Var(Generated("static initializers"), Function(List(Ptr),Ptr, Purity.Effectful))
        val selfGname = Var(Generated("lib self name"), Base.String)
        val ret = Let(List(Definition(selfGname, Literal.String(selfLibName), Nil)),
          Primitive("setGlobal(String, Ptr): Unit", List(selfGname, self),
            List(Var(Generated("unit"), Base.Unit)),
          self))
        (name, Definition(name, Abs(List(self),
          values.foldRight[Term[O]](ret){ case (Definition(name, binding, exportAs), rest) =>
            val tpe = toRTpe(name.tpe)
            val gname = Var(Generated("global name"), Base.String)
            val rname = Var(Generated("unit"), Base.Unit)
            val tBinding = (new Structural[O,O] {
              override def term: PartialFunction[Term[O], Term[O]] = {
                case ThisLib() => self
              }
            }).apply(binding)
            Let(List(
              Definition(gname, Literal.String(name.name.toString), Nil),
              Definition(name, tBinding, Nil)), // Does not need to be transformed, as HERE, globals are already in scope
                Primitive(s"setGlobal(String, ${tpe}): Unit", List(gname, Var(name.name, Top)), List(rname),
                  exportAs.foldRight(rest){ (as, tl) =>
                    val ename = Var(Generated("external name"), Base.String)
                    Let(List(Definition(ename, Literal.String(as), Nil)),
                      Primitive(s"setGlobal(String, ${tpe}): Unit", List(ename, Var(name.name, Top)), List(rname),
                        tl))
                  }))
          }),
          List("$static-init")))
      }

      override def term: PartialFunction[Term[O], Term[O]] = {
        case v@Var(name, _tpe) if values.exists{ d => d.name.name == name } =>
          val d = values.find{ d => d.name.name == name }.get
          val tpe = toRTpe(_tpe)
          val gname = Var(Generated("global name"), Base.String)
          Let(List(Definition(gname, Literal.String(name.toString), Nil)),
            Primitive(s"getGlobal(String): ${tpe}", List(gname), List(Var(name, Top)), v))
        case ThisLib() =>
          val v = Var(Generated("ThisLib"), Ptr)
          val gname = Var(Generated("global name"), Base.String)
          Let(List(Definition(gname, Literal.String(selfLibName), Nil)),
            Primitive("getGlobal(String): Ptr", List(gname), List(v), v))
      }
    }
  }

  def split(defs: List[Definition[O]])(using ErrorReporter): SplitDefinitions = {
    val values = mutable.ListBuffer[Definition[O]]()
    val functions = mutable.ListBuffer[Definition[O]]()
    defs.foreach {
      case d@Definition(Var(_, Function(_, _, _)), Abs(_, _), exportAs) => functions.addOne(d)
      case Definition(Var(n, _), b@Abs(_, _), exportAs) => functions.addOne(Definition(Var(n, Type.of(b)), b, exportAs))
      case d@Definition(_, _, _) => values.addOne(d)
    }
    SplitDefinitions(values.toList, functions.toList)
  }

  def organize(defs: List[Definition[O]])(using ErrorReporter): OrganizedDefinitions = try {
    val SplitDefinitions(vals, fns) = split(defs)
    val sVals = topologicalSortWithKey(vals){
      case Definition(name, binding, exportAs) => FreeVariables(binding).toList.map(_.name)
    }{
      case Definition(name, binding, exportAs) => name.name
    }
    OrganizedDefinitions(sVals, fns)
  } catch {
    case rpyeffectasm.util.RecursiveDependenciesException(vals: List[Definition[O]]) =>
      ErrorReporter.fatal("There are recursive dependencies between LetRec-bound variables: " +
        vals.map{ d => SExpPrettyPrinter(d.name) }.mkString(", "))
  }

  class Impl(using ErrorReporter) extends Structural[O, O] {
    override def term: PartialFunction[Term[O], Term[O]] = {
      case LetRec(defs, body) =>
        val odefs = organize(defs map this.apply)
        if(odefs.functions.nonEmpty) { ErrorReporter.fatal("Functions left in local binding") }
        odefs.wrap(this.apply(body))
    }
  }

  override def apply(f: Program[O])(using ErrorReporter): Program[O] = f match {
    case Program(definitions, main) =>
      val impl = new Impl
      val tDefs = organize(definitions map impl.apply)
      val (siName, siDef) = tDefs.asGlobals.staticInit
      val tFuns = tDefs.functions.map(tDefs.asGlobals.apply)
      val self = Var(new Generated("self placeholder"), Ptr)
      val tMain = if (tDefs.values.nonEmpty) {
        Let(List(Definition(self, Literal.Label, Nil)), // TODO unit is just a placeholder here
          Seq(List(App(siName, List(self)), tDefs.asGlobals(impl(main)))))
      } else { tDefs.asGlobals(impl(main)) }
      Program(tFuns :+ siDef, tMain)
  }

  ////////////////////////////////////////////////////////////////////////////////
  override def precondition(f: Program[O]): Unit = {
    super.precondition(f)
    (new Visitor {
      override def definition: PartialFunction[Definition[ATerm], Unit] = {
        case Definition(name, Abs(_, body), exportAs) => this.apply(body)
      }

      override def term: PartialFunction[Term[ATerm], Unit] = {
        case Abs(_, _) => assert(false, "Function that is not bound to a variable.")
      }
    }).apply(f)
  }

  override def postcondition[Result >: Program[O]](t: Result): Unit = {
    val q = new Visitor {
      override def term: PartialFunction[Term[ATerm], Unit] = {
        case LetRec(defs, body) => assert(false, "LetRec exists after organizing value bindings")
      }

      override def apply(p: Program[O]): Unit = p match {
        case Program(definitions, main) =>
          definitions.foreach{
            case Definition(name, Abs(_, body), exportAs) => this.apply(body)
            case Definition(name, binding, exportAs) => assert(false, "Toplevel value binding")
          }
          this.apply(main)
      }
    }
    t match {
      case p: Program[O] => q(p)
    }
  }

}
