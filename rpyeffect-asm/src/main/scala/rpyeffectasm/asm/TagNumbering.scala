package rpyeffectasm.asm
import scala.collection.mutable
import scala.collection.immutable.Map
import rpyeffectasm.util.Phase
import rpyeffectasm.util.ErrorReporter

case class ConstructorDescriptor[OTpe](name: Id, index: Index, fields: List[OTpe])
case class DatatypeDescriptor[OTpe](name: Id, index: Index, constructors: List[ConstructorDescriptor[OTpe]])
case class MethodDescriptor[OTpe](name: Id, index: Index, params: List[OTpe])
case class InterfaceDescriptor[OTpe](name: Id, index: Index, methods: List[MethodDescriptor[OTpe]])
case class TagNumberingInfo[OTpe](datatypes: List[DatatypeDescriptor[OTpe]], interfaces: List[InterfaceDescriptor[OTpe]])
/** Replaces all type, constructor and method tags with numbers.
 *  Also collects some basic information about data types and methods. */
class TagNumbering[F <: AsmFlags, Label <: Id, V <: Id, OTpe]
  extends Phase[Program[F, Id, Label, V, OTpe], (Program[F, Index, Label, V, OTpe], TagNumberingInfo[OTpe])] {
  // TODO Make sure this is consistent with separate compilation

  enum Ctx {
    case Tpe
    case Ifce
    case Constructor(tpe: Id)
    case Method(ifce: Id)
  }
  def apply(i: Instruction[F, Id, Label, V, OTpe])(using Numbering): Instruction[F, Index, Label, V, OTpe] = i match {
    case Construct(out, tpe, tag, args) =>
      Construct(out, lookup(Ctx.Tpe, tpe), lookup(Ctx.Constructor(tpe), tag, args.map(_.tpe)), args)
    case Match(tpe, scrutinee, clauses, default) =>
      Match(lookup(Ctx.Tpe, tpe), scrutinee, (clauses map { case (tag, k) =>
        (lookup(Ctx.Constructor(tpe), tag, k.params.map(_.tpe)), k)
      }).sortBy(_._1.i), default)
    case Proj(out, tpe, scrutinee, tag, field) =>
      Proj(out, lookup(Ctx.Tpe, tpe), scrutinee, lookup(Ctx.Constructor(tpe), tag), field)
    case New(out, ifce, targets, args) =>
      New(out, lookup(Ctx.Ifce, ifce), targets map { case (tag, k) =>
        (lookup(Ctx.Method(ifce), tag), k)
      }, args)
    case Invoke(receiver, ifce, tag, args) =>
      Invoke(receiver, lookup(Ctx.Ifce, ifce), lookup(Ctx.Method(ifce), tag, args.map(_.tpe)), args)
    case i: Instruction[F, Nothing, Label, V, OTpe] @unchecked => i
  }
  def apply(b: Block[F, Id, Label, V, OTpe])(using Numbering): Block[F, Index, Label, V, OTpe] = b match {
    case Block(label, params, retTpe, instructions, export_as) => Block(label, params, retTpe, instructions map apply, export_as)
  }
  override def apply(p: Program[F, Id, Label, V, OTpe])(using ErrorReporter): (Program[F, Index, Label, V, OTpe], TagNumberingInfo[OTpe]) = p match {
    case Program(blocks) =>
      given Numbering = new Numbering()
      val res = Program(blocks map apply)
      (res, getInfo())
  }

  def lookup(ctx: Ctx, x: Id)(using N: Numbering) = N.lookup(ctx, x)
  def lookup(ctx: Ctx, x: Id, arity: List[OTpe])(using N: Numbering)= {
    val r = N.lookup(ctx, x)
    N.setArity(ctx, x, arity)
    r
  }
  def getInfo()(using N: Numbering): TagNumberingInfo[OTpe] =
    TagNumberingInfo(N.contents.getOrElse(Ctx.Tpe, Nil).zipWithIndex.map{ (x,i) =>
      DatatypeDescriptor(x, Index(i), N.contents.getOrElse(Ctx.Constructor(x), Nil).zipWithIndex.map{ (c,ci) =>
        ConstructorDescriptor(c, Index(ci), N.arities.getOrElse((Ctx.Constructor(x), c),Nil))
      })
    }, N.contents.getOrElse(Ctx.Ifce, Nil).zipWithIndex.map{ (x,i) =>
      InterfaceDescriptor(x, Index(i), N.contents.getOrElse(Ctx.Method(x), Nil).zipWithIndex.map{ (m,mi) =>
        MethodDescriptor(m, Index(mi), N.arities.getOrElse((Ctx.Method(x), m),Nil))
      })
    })
  class Numbering {
    val contents: mutable.Map[Ctx, List[Id]] = mutable.Map.empty
    val arities: mutable.Map[(Ctx, Id), List[OTpe]] = mutable.Map.empty
    def lookup(ctx: Ctx, x: Id): Index = x match {
      case Index(i) => Index(i)
      case x =>
      contents.getOrElseUpdate(ctx, Nil).indexOf(x) match {
        case -1 =>
          contents.update(ctx, x :: contents(ctx))
          Index(contents(ctx).length - 1)
        case i => Index(contents(ctx).length - i - 1)
      }
    }
    def setArity(ctx: Ctx, x: Id, arity: List[OTpe]): Unit = {
      if(arities.contains((ctx,x))) {
        // should match up
        //assert(arities((ctx,x)).length == arity.length, s"${ctx} tag ${x} is used with different numbers of arguments.")
        for((a1,a2) <- arities((ctx,x)) zip arity) {
          // TODO we need to check for subtyping here.
          //assert(a1 == a2, s"${ctx} tag ${x} is used with differing types: ${a1} vs ${a2}")
        }
      } else {
        arities.update((ctx, x), arity)
      }
    }
  }

}
