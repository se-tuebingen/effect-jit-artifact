package rpyeffectasm.mcore
import rpyeffectasm.util.ErrorReporter
import rpyeffectasm.util.ErrorReporter.{error}
import rpyeffectasm.common.{Purity, Primitives}
import rpyeffectasm.mcore.sugar.{DynamicHandlerSugar, HandlerSugar}
import rpyeffectasm.common
import rpyeffectasm.asm

sealed trait Type extends common.Type {
  override def asMCore: Type = this
}
object Top extends Type
object Ptr extends Type
object Num extends Type
object Bottom extends Type

case class Function(params: List[Type], ret: Type, purity: Purity) extends Type
case class Method(tag: Id, params: List[Type], ret: Type) {
  def purity = Purity.Effectful
}
case class Codata(ifce_tag: Id, methods: List[Method]) extends Type

case class Constructor(tag: Id, fields: List[Type])
case class Data(type_tag: Id, constructors: List[Constructor]) extends Type
case class Stack(resume_ret: Type, resume_args: List[Type]) extends Type

case class Ref(to: Type) extends Type

sealed trait Base extends Type {
  type ScalaType
}
object Base {
  object Bool extends Base { override type ScalaType = scala.Boolean }
  object Int extends Base { override type ScalaType = scala.Int }
  object Double extends Base { override type ScalaType = scala.Double }
  object String extends Base { override type ScalaType = java.lang.String }
  case class Label(at: Type, binding: Option[Type]) extends Base { override type ScalaType = Null }
  object Unit extends Base { override type ScalaType = Unit }
  case class Injected[T]() extends Base { override type ScalaType = T }
}

val Region = Ptr // TODO actual Region type

object Type {

  /** _Infer_ the type of a term. This will not ensure that the term is well-typed,
   * but will return a correct type if it is.
   */
  def of(t: Term[ATerm])(using ErrorReporter): Type = t match {
    case Var(name, tpe) => tpe
    case Abs(params, body) =>
      val isPure = analysis.FreeVariables(t).toList.isEmpty && ((new Query[Boolean] {
        override def term = {
          case Primitive(name, args, returns, rest) => Primitives.primitives.find{ p => p.name == name } match {
            case Some(p) if p.purity == Purity.Pure => apply(rest)
            case _ => false
          }
          case App(Var(name, Function(params, ret, purity)), args) if purity == Purity.Effectful => false
          case Invoke(receiver, ifce_tag, method, args) => false
          case Shift(label, n, k, body, retTpe) => false
          case Control(label, n, k, body, retTpe) => false
          case HandlerSugar.Op(_, _, _, _, _) => false
          case DynamicHandlerSugar.Op(_, _, _, _, _) => false
        }

        override def combine(x: Boolean, y: Boolean): Boolean = x && y
        override def default: Boolean = true
      })(t))
      Function(params.map(_.tpe), of(body), if isPure then Purity.Pure else Purity.Effectful) // TODO better purity analysis
    case App(fn, args) => of(fn) match {
      case Top => Top
      case Ptr => Ptr
      case Function(params, ret, purity) =>
        //if(args.length != params.length) error("Function arities don't match up.") // FIXME
        ret
      case Bottom => Bottom
      case t => error(s"Cannot call a value of type ${t}"); Top
    }
    case Seq(Nil) => Base.Unit
    case Seq(ts) => of(ts.last)
    case Let(defs, body) => of(body)
    case LetRec(defs, body) => of(body)
    case Construct(tpe_tag, tag, args) =>
      Data(tpe_tag, List(Constructor(tag, args.map(of))))
    case Project(scrutinee, tpe_tag, tag, field) => of(scrutinee) match {
      case Top | Ptr => Top
      case stpe@Data(type_tag, constructors) =>
        if(type_tag != tpe_tag && constructors.length > 1)
          error(s"Type tags for data types don't match up: ${type_tag} vs ${tpe_tag}")
        constructors.find { c => c.tag == tag } match {
          case Some(c@Constructor(tag, fields)) => fields.applyOrElse(field, { _ =>
            error(s"Constructor ${c} has no ${field}th field."); Top
          })
          case None => error(s"${stpe} has no constructor with tag ${tag}"); Top
        }
      case Bottom => Bottom
      case t => error(s"Cannot project out of a value of type ${t}"); Top
    }
    case Match(scrutinee, tpe_tag, clauses, default) =>
      (of(default.body) :: clauses.map{ case (id, Clause(params, body)) => of(body) }).reduce(_ join _)
    case Switch(scrutinee, cases, default) =>
      (of(default) :: cases.map{ case (_, c) => of(c) }).reduce(_ join _)
    case IfZero(cond, thn, els) => of(thn) join of(els)
    case New(ifce_tag, methods) =>
      Codata(ifce_tag, methods.map{ case (tag, Clause(params, body)) =>
        Method(tag, params.map(_.tpe), of(body))
      })
    case Invoke(receiver, expected_ifce_tag, method, args) => of(receiver) match {
      case Top | Ptr => Top
      case Codata(ifce_tag, methods) =>
        if(ifce_tag != expected_ifce_tag && methods.length > 1)
          error(s"Interface tags don't match up: ${ifce_tag} vs ${expected_ifce_tag}")
        methods.find { m => m.tag == method } match {
          case Some(Method(tag, params, ret)) =>
            if(params.length != args.length)
              error("Arities of method don't match up.")
            ret
          case None => error(s"${ifce_tag} has no method ${method}"); Top
        }
      case Bottom => Bottom
      case t => error(s"Cannot invoke value of type ${t}"); Top
    }
    case LetRef(ref, region, binding, body) => of(body)
    case Load(ref) => of(ref) match {
      case Top | Ptr => Top
      case Bottom => Bottom
      case Ref(to) => to
      case t => error(s"Cannot dereference value of type ${t}"); Top
    }
    case Store(ref, value) => Base.Unit
    case FreshLabel() => Base.Label(Top, None)
    case Reset(label, region, bnd, body, ret) => of(ret.body)
    case Shift(label, n, k, body, retTpe) => retTpe
    case Control(label, n, k, body, retTpe) => retTpe
    case Primitive(name, args, returns, rest) => of(rest)
    case l: Literal => l.tpe
    case Resume(k, args) => of(k) match {
      case Top | Ptr => Top
      case Bottom => Bottom
      case Stack(resume_ret, resume_args) => resume_ret
      case t => error(s"Cannot resume a value of type ${t}"); Top
    }
    case LoadLib(path) => Ptr
    case CallLib(lib, symbol, args, returnType) => returnType
    case ThisLib() => Ptr
    case Resumed(k, body) => of(k.unroll) match {
      case Top | Ptr => Top
      case Bottom => Bottom
      case Stack(resume_ret, resume_args) => resume_ret
      case t => error(s"Cannot resume a value of type ${t}"); Top
    }
    case DebugWrap(inner, annotations) => Type.of(inner)
    case s: Sugar => Type.of(s.desugared)
  }

  extension(self: Type) {
    // TODO most `zip`s should be `zipAll(_, Bottom, Bottom)`s (or similar)
    def join(other: Type): Type = (self,other) match {
      case (x,y) if x == y => x
      case (x,y) if x isSubtypeOf y => y
      case (x,y) if y isSubtypeOf x => x
      case (Function(ps1, ret1, p1), Function(ps2, ret2, p2)) =>
        val p = (p1,p2) match {
          case (Purity.Pure, Purity.Pure) => Purity.Pure
          case (Purity.Effectful, Purity.Effectful) => Purity.Effectful
          case _ => Purity.Effectful // TODO Do we have to? Or can we error out here (i.e. return Top/SomeFunction) and treat them as completely separate types?
        }
        Function((ps1 zip ps2) map { case (p1,p2) => p1 meet p2 }, ret1 join ret2, p)
      case (Codata(it1, ms1), Codata(it2, ms2)) =>
        if(it1 == it2) {
          val tags = ms1.map(_.tag) intersect ms2.map(_.tag)
          Codata(it1, tags.map{ t =>
            val m1 = ms1.find{ m => m.tag == t }.get
            val m2 = ms2.find{ m => m.tag == t }.get
            Method(t, (m1.params zip m2.params).map(_ meet _), m1.ret join m2.ret)
          })
        } else Ptr
      case (Data(t1, cs1), Data(t2, cs2)) =>
        if(t1 == t2) {
          val cnsTags = cs1.map(_.tag) intersect cs2.map(_.tag)
          Data(t1, cnsTags.map { t =>
            val c1 = cs1.find{ c => c.tag == t }.get
            val c2 = cs2.find{ c => c.tag == t }.get
            Constructor(t, (c1.fields zip c2.fields).map(_ join _))
          })
        } else Ptr
      case (Ref(to1), Ref(to2)) => Ref(to1 join to2)
      case (Stack(r1, args1), Stack(r2, args2)) => Stack(r1 join r2, (args1 zip args2).map(_ meet _))
      case _ => Top
    }
    def meet(other: Type): Type = (self,other) match {
      case (x, y) if x == y => x
      case (x, y) if x isSubtypeOf y => x
      case (x, y) if y isSubtypeOf x => y
      case (Function(ps1, ret1, p1), Function(ps2, ret2, p2)) =>
        val p = (p1, p2) match {
          case (Purity.Pure, Purity.Pure) => Purity.Pure
          case (Purity.Effectful, Purity.Effectful) => Purity.Effectful
          case _ => Purity.Pure // TODO Do we have to? Or can we error out here (i.e. return Top/SomeFunction) and treat them as completely separate types?
        }
        Function((ps1 zip ps2) map { case (p1, p2) => p1 join p2 }, ret1 meet ret2, p)
      case (Codata(it1, ms1), Codata(it2, ms2)) =>
        if (it1 == it2) {
          val tags = ms1.map(_.tag) intersect ms2.map(_.tag)
          Codata(it1, tags.map { t =>
            val m1 = ms1.find { m => m.tag == t }.get
            val m2 = ms2.find { m => m.tag == t }.get
            Method(t, (m1.params zip m2.params).map(_ join _), m1.ret meet m2.ret)
          })
        } else Bottom
      case (Data(t1, cs1), Data(t2, cs2)) =>
        if (t1 == t2) {
          val cnsTags = cs1.map(_.tag) intersect cs2.map(_.tag)
          Data(t1, cnsTags.map { t =>
            val c1 = cs1.find { c => c.tag == t }.get
            val c2 = cs2.find { c => c.tag == t }.get
            Constructor(t, (c1.fields zip c2.fields).map(_ meet _))
          })
        } else Bottom
      case (Stack(r1, args1), Stack(r2, args2)) => Stack(r1 meet r2, (args1 zip args2).map(_ join _))
      case (Ref(to1), Ref(to2)) => Ref(to1 meet to2)
      case _ => Bottom
    }
    def isSubtypeOf(other: Type): Boolean = (self, other) match {
      case (x,y) if x == y => true
      case (_,Top) => true
      case (Bottom, _) => true
      case (Ptr | Function(_,_,_) | Codata(_,_) | Data(_,_) | Ref(_) | Base.String | Base.Unit | Base.Label(_, _) | Stack(_,_), Ptr) => true
      case (Num | Base.Int | Base.Double, Num) => true
      case (Function(ps1,r1,pu1), Function(ps2,r2,pu2)) =>
        /*pu1 == pu2 &&*/ (r1 isSubtypeOf r2) && ps2.length == ps1.length && (ps2 zip ps1).forall{ case (p2, p1) => p2 isSubtypeOf p1 }
      case (Codata(t1, ms1), Codata(t2, ms2)) =>
        t1 == t2 && ms2.forall { case Method(t2, ps2, r2) =>
          ms1.find{ m1 => m1.tag == t2 }.map { case Method(t1, ps1, r1) =>
            ps1.length == ps2.length
            && ((ps1 zip ps2).forall {case (p1,p2) => p2 isSubtypeOf p1})
            && (r1 isSubtypeOf r2)
          }.getOrElse(false)
        }
      case (Data(t1, cs1), Data(t2, cs2)) =>
        t1 == t2 && cs1.forall { case Constructor(ct1, fs1) =>
          cs2.find{ c => c.tag == ct1 }.map { case Constructor(ct2, fs2) =>
            fs1.length == fs2.length && ((fs1 zip fs2) forall { case (f1, f2) => f1 isSubtypeOf f2 })
          }.getOrElse(false)
        }
      case (Ref(o1), Ref(o2)) => (o1 isSubtypeOf o2) && (o2 isSubtypeOf o1)
      case (Stack(r1, as1), Stack(r2, as2)) =>
        (r1 isSubtypeOf r2) && (as1.length == as2.length) && ((as1 zip as2) forall { case (a1, a2) => a2 isSubtypeOf a1 })
      case (_,_) => false
    }

    def deref(using ErrorReporter): Type = self match {
      case Top | Ptr => Top
      case Bottom => Bottom
      case Ref(to) => to
      case other => ErrorReporter.fatal(s"Dereferencing ${other}.")
    }
    
  }
}

object PtrType {
  def unapply(x: Type): Boolean = x match {
    case Ptr | Top | Data(_, _) | Codata(_, _) | Base.String | Base.Label(_, _) | Base.Unit | Stack(_, _) | Bottom | Ref(_) => true
    case _ => false
  }
}

object NumType {
  def unapply(x: Type): Boolean = x match {
    case Num | Base.Int | Base.Double => true
    case _ => false
  }
}