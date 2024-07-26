package rpyeffectasm
package mcore
import rpyeffectasm.util.{Phase, ErrorReporter}

/**
 * Change codata methods to be specific to the parameter register types,
 * i.e. locally monomorphize [[Top]] to ([[Top]] or [[Num]] in different methods).
 * This prevents us from having to box/unbox codata.
 */
class MonomorphizeCodata[O <: ATerm] extends Phase[Program[O], Program[O]] {

  def typeShorthand(t: Type): String = t.registerType match {
    case rpyeffect.RegisterType.Number => "n"
    case rpyeffect.RegisterType.Ptr => "p"
  }
  def monoMethodName(name: Name | Index, paramTypes: List[Type], retType: Type): Name = {
    val paramPart = paramTypes.map(typeShorthand).mkString
    val retPart = typeShorthand(retType)
    name match {
      case Name(name) => Name(s"%${name}(${paramPart}):${retPart}")
      case Index(i) => Name(s"#${i}(${paramPart}):${retPart}")
    }
  }

  def monoType(t: Type): Iterable[Type] = t match {
    case Top => List(t, Num)
    case Num | Base.Int | Base.Double => List(t, Top)
    case Codata(ifce_tag, methods) => List(Codata(ifce_tag, methods.flatMap(monoMethods)))
    case t => List(t)
  }
  def monoTypes(ts: List[Type]): Iterable[List[Type]] = ts match {
    case hd :: tl => for {
      tHd <- monoType(hd)
      tTl <- monoTypes(tl)
    } yield tHd :: tTl
    case Nil => List(Nil)
  }

  def monoMethods(m: Method): Iterable[Method] = m match {
    case Method(tag: (Index | Name), params, ret) =>
      for {
        params <- monoTypes(params)
        ret <- monoType(ret)
      } yield Method(monoMethodName(tag, params, ret), params, ret)
    case m => List(m)
  }

  class Impl(using ErrorReporter) extends Structural[O,O] {
    override def param: PartialFunction[LhsOperand, LhsOperand] = {
      case Var(name, Codata(ifce_tag, methods)) => Var(name, Codata(ifce_tag, methods.flatMap(monoMethods)))
    }
    override def term: PartialFunction[Term[O], Term[O]] = {
      case Var(name, Codata(ifce_tag, methods)) =>
        Var(name, Codata(ifce_tag, methods.flatMap(monoMethods)))
      case t@New(ifce_tag, methods) =>
        New(ifce_tag, methods.flatMap {
          case (m: (Name | Index), cls) => for {
              paramTypes <- monoTypes(cls.params.map(_.tpe))
              retType <- monoType(Type.of(cls.body))
            } yield (monoMethodName(m, paramTypes, retType),
              cls match {
                case Clause(params, body) =>
                  val tParams = (params zip paramTypes).map {
                    case (Var(name, _), t) => Var(name, t)
                  }
                  val ret = Var(new Generated("returning annotated"), retType)
                  Clause(tParams, Let(List(Definition(ret, Impl.this(body), Nil)), ret))
              })
          case (x, cls) => List((x, cls)) // do not monomorphize methods with Generated tags
        })
      case t@Invoke(receiver, ifce_tag, method, args) =>
        val tMethod = method match {
          case method: Generated => method
          case method: (Name | Index) => monoMethodName(method, args.map(Type.of), Type.of(t))
        }
        Invoke(applyO(receiver), ifce_tag, tMethod, args)
    }
  }

  override def apply(f: Program[O])(using ErrorReporter): Program[O] = (new Impl).apply(f)
}
