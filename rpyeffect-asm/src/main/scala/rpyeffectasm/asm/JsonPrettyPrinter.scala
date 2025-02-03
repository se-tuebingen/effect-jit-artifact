package rpyeffectasm.asm

import rpyeffectasm.util.{Phase, Output, Target, JsonPrinter, ErrorReporter, escape}
import rpyeffectasm.mcore
import scala.collection.immutable.ListMap

object JsonPrettyPrinter extends JsonPrinter with Phase[Program[AsmFlags, Id, Id, Id], Output]{

  def toDoc(id: Id): Doc = id match {
    case Name(name) => s"\"${escape(name)}\""
    // case IndexWithDebug(i, d) => ??? // TODO how to represent this?
    case Index(i) => i.toString
    case generated: Generated => s"\"${escape(generated.toString)}\""
  }

  def toDoc(p: LhsOperand[AsmFlags, Id]): Doc = p match {
    case Var(name) => jsonObjectSmall(ListMap("id" -> toDoc(name)))
    case Ref(ref) => ???
  }

  def toDoc(p: RhsOperand[AsmFlags, Id]): Doc = p match {
    case Var(name) => jsonObjectSmall(ListMap("id" -> toDoc(name)))
    case Const(value) => ???
    case Ref(ref) => ???
  }

  def toDoc(literalType: LiteralType): Doc = literalType match {
    case i: Int => i.toString
    case d: Double => d.toString
    case s: String => s"\"${escape(s)}\""
    case b: Boolean => s"${b}"
    case FormatConst(fmt, value) => jsonObjectSmall(ListMap("format" -> toDoc(fmt), "value" -> toDoc(value)))
  }

  def toDoc(value: Clause[AsmFlags, Id, Id]): Doc = value match {
    case Clause(params, env, target) => jsonObjectSmall(ListMap(
      "params" -> jsonListSmall(params.map(toDoc)),
      "env" -> jsonListSmall(env.map(toDoc)),
      "target" -> toDoc(target)
    ))
  }

  def toDoc(instruction: Instruction[AsmFlags, Id, Id, Id]): Doc = jsonObjectSmall(instruction match {
    case Let(lhss, rhss) => ListMap("op" -> "\"Let\"", "lhss" -> jsonListSmall(lhss.map(toDoc)), "rhss" -> jsonListSmall(rhss.map(toDoc)))
    case LetConst(out, value) => ListMap("op" -> "\"LetConst\"", "out" -> toDoc(out), "value" -> toDoc(value))
    case Primitive(out, name, in) => ListMap("op" -> "\"Prim\"", "outs" -> jsonListSmall(out.map(toDoc)), "name" -> s"\"${name}\"", "ins" -> jsonListSmall(in.map(toDoc)))
    case Push(target, args) => ListMap("op" -> "\"Push\"", "target" -> toDoc(target), "args" -> jsonListSmall(args.map(toDoc)))
    case Return(args) => ListMap("op" -> "\"Return\"", "args" -> jsonListSmall(args.map(toDoc)))
    case Jump(target, env) => ListMap("op" -> "\"Jump\"", "target" -> toDoc(target), "args" -> jsonListSmall(env.map(toDoc)))
    case IfZero(arg, Clause(params, env, target)) =>
      assert(params.isEmpty, "Clause in IfZero cannot have parameters.")
      ListMap("op" -> "\"IfZero\"", "cond" -> toDoc(arg), "target" -> toDoc(target), "args" -> jsonListSmall(env.map(toDoc)))
    case Allocate(ref, init, region) => ListMap("op" -> "\"Allocate\"", "ref" -> toDoc(ref), "init" -> toDoc(init), "region" -> toDoc(region))
    case Load(out, ref) => ListMap("op" -> "\"Load\"", "out" -> toDoc(out), "ref" -> toDoc(ref))
    case Store(ref, in) => ListMap("op" -> "\"Store\"", "ref" -> toDoc(ref), "arg" -> toDoc(in))
    case GetDynamic(out, n, label) => ListMap("op" -> "\"GetDynamic\"", "out" -> toDoc(out), "n" -> toDoc(n), "label" -> toDoc(label))
    case Shift(out, n, label) => ListMap("op" -> "\"Shift\"", "out" -> toDoc(out), "n" -> toDoc(n), "label" -> toDoc(label))
    case Control(out, n, label) => ListMap("op" -> "\"Control\"", "n" -> toDoc(n), "label" -> toDoc(label))
    case PushStack(stack) => ListMap("op" -> "\"PushStack\"", "arg" -> toDoc(stack))
    case NewStack(stack, region, label, target, args) => ListMap("op" -> "\"NewStack\"",
      "stack" -> toDoc(stack), "region" -> toDoc(region), "label" -> toDoc(label), "target" -> toDoc(target),
      "args" -> jsonListSmall(args.map(toDoc))
    )
    case NewStackWithBinding(stack, region, label, target, args, bnd) => ListMap("op" -> "\"NewStack\"",
      "stack" -> toDoc(stack), "region" -> toDoc(region), "label" -> toDoc(label), "target" -> toDoc(target),
      "args" -> jsonListSmall(args.map(toDoc)), "binding" -> toDoc(bnd)
    )
    case Construct(out, tpe, tag, args) => ListMap("op" -> "\"Construct\"",
      "out" -> toDoc(out), "type" -> toDoc(tpe), "tag" -> toDoc(tag),
      "args" -> jsonListSmall(args.map(toDoc))
    )
    case Match(tpe, scrutinee, clauses, default) => ListMap("op" -> "\"Match\"",
      "type" -> toDoc(tpe), "scrutinee" -> toDoc(scrutinee),
      "clauses" -> jsonList(clauses.map{
        case (id, clause) => jsonObjectSmall(ListMap("tag" -> toDoc(id), "clause" -> toDoc(clause)))
      }),
      "default_clause" -> toDoc(default)
    )
    case Proj(out, tpe, scrutinee, tag, field) => ListMap("op" -> "\"Proj\"",
      "out" -> toDoc(out), "type" -> toDoc(tpe), "scrutinee" -> toDoc(scrutinee),
      "tag" -> toDoc(tag), "field" -> field.toString
    )
    case New(out, ifce, targets, args) => ListMap("op" -> "\"New\"",
      "out" -> toDoc(out), "type" -> toDoc(ifce), "method_targets" -> jsonListSmall(targets.map {
        case (tag, target) => jsonObjectSmall(ListMap("method" -> toDoc(tag), "target" -> toDoc(target)))
      }),
      "args" -> jsonListSmall(args.map(toDoc))
    )
    case Invoke(receiver, ifce, tag, args) => ListMap("op" -> "\"Invoke\"",
      "type" -> toDoc(ifce), "receiver" -> toDoc(receiver), "method" -> toDoc(tag),
      "args" -> jsonListSmall(args.map(toDoc))
    )
    case Switch(arg, cases, default, env) => ListMap("op" -> "\"Switch\"",
      "arg" -> toDoc(arg), "cases" -> jsonList(cases.map{
        case (i, t) => jsonObjectSmall(ListMap("value" -> toDoc(i), "target" -> toDoc(t)))
      }),
      "default" -> toDoc(default),
      "env" -> jsonListSmall(env.map(toDoc)))
    case CallLib(lib, symbol, env) => ListMap("op" -> "\"CallLib\"",
      "lib" -> toDoc(lib),
      "symbol" -> jsonString(symbol),
      "env" -> jsonListSmall(env.map(toDoc))
    )
    case LoadLib(path) => ListMap("op" -> "\"LoadLib\"",
      "path" -> toDoc(path)
    )
    case Debug(msg, traced) => ListMap("op" -> "\"Debug\"", "msg" -> toDoc(msg), "traced" -> jsonListSmall(traced map toDoc))
  })

  def toDoc(lit: mcore.Literal): Doc = lit match {
    case mcore.Literal.Int(v) => toDoc(v)
    case mcore.Literal.Bool(v) => v.toString
    case _ => ???
  }

  def toDoc(b: Block[AsmFlags, Id, Id, Id]): Doc =
    jsonObject(ListMap(
      "label" -> toDoc(b.label),
      "params" -> jsonList(b.params.map(toDoc)),
      "instructions" -> jsonList(b.instructions.map(toDoc)),
      "export_as" -> jsonListSmall(b.export_as.map(toDoc))
    ))

  def toDoc(p: Program[AsmFlags, Id, Id, Id]): Doc =
    jsonObject(ListMap("blocks" -> jsonList(p.blocks.map(toDoc))))

  override def apply(p: Program[AsmFlags, Id, Id, Id])(using ErrorReporter): Output = new Output {
    override def emitTo[T](t: Target[T]): T = t.fromString(pretty(toDoc(p)))
  }
}
