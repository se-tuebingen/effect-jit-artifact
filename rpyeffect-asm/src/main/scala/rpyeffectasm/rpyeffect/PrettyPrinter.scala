package rpyeffectasm
package rpyeffect

import scala.collection.immutable.ListMap
import rpyeffectasm.util.{JsonPrinter, Phase, Output, Target}
import rpyeffectasm.util.escape

object PrettyPrinter extends JsonPrinter with Phase[rpyeffect.Program, Output] {
  import rpyeffectasm.util.ErrorReporter
  def toDocument(program: Program): Document = pretty(toDoc(program))

  def toDoc(symbol: Symbol): Doc = {
    jsonObjectSmall(ListMap("name" -> jsonString(symbol.name), "position" -> symbol.position.toString))
  }

  def toDoc(program: Program): Doc = {
    jsonObject(ListMap(
      "blocks" -> jsonList(program.blocks.map(toDoc)),
      "symbols" -> jsonList(program.symbols.map(toDoc)),
      "frameSize" -> toDoc(program.frameSize),
    ))
  }
  def toDoc(datatype: List[List[Type]]): Doc =
    jsonList(datatype.map(pars => jsonListSmall(pars map toDoc)))

  def toDoc(tpe: Type): Doc = tpe match {
    case Type.Continuation() => (jsonObjectSmall(ListMap("type" -> "\"cont\"")))
    case Type.Integer() => (jsonObjectSmall(ListMap("type" -> "\"int\"")))
    case Type.Label() => (jsonObjectSmall(ListMap("type" -> "\"label\"")))
    case Type.Double() => (jsonObjectSmall(ListMap("type" -> "\"double\"")))
    case Type.String() => (jsonObjectSmall(ListMap("type" -> "\"string\"")))
    case Type.Codata(index) => (jsonObjectSmall(ListMap("type" -> "\"codata\"", "index" -> index.toString)))
    case Type.Datatype(index) => (jsonObjectSmall(ListMap("type" -> "\"adt\"", "index" -> index.toString)))
    case Type.Reference(to) => (jsonObjectSmall(ListMap("type" -> "\"ref\"", "target" -> toDoc(to))))
    case Type.Region() => (jsonObjectSmall(ListMap("type" -> "\"region\"")))
  }
  
  def toDoc(block: BasicBlock): Doc = block match {
    case BasicBlock(id, frameDescriptor, instructions, terminator) => {
      jsonObject(ListMap(
        "label" -> dquotes(id),
        "frameDescriptor" -> toDoc(frameDescriptor),
        "instructions" -> jsonList(instructions.map(toDoc) ++ List(toDoc(terminator)))
      ))
    }
  }

  def toDoc(frameDescriptor: FrameDescriptor): Doc = {
    jsonObjectSmall(Map(("regs_any") ->
      (frameDescriptor.locals.toString: Doc)
    ))
  }

  def toDoc(instruction: Instruction): Doc = instruction match {
    case Const(out, value) => jsonObjectSmall(ListMap("op" -> "\"Const\"",
      "format" -> "\"int\"", "out" -> toDoc(out), "value" -> value.toString))
    case ConstBool(out, value) => jsonObjectSmall(ListMap("op" -> "\"Const\"",
      "format" -> "\"bool\"", "out" -> toDoc(out), "value" -> value.toString))
    case ConstDouble(out, value) => jsonObjectSmall(ListMap("op" -> "\"Const\"",
      "format" -> "\"double\"", "out" -> toDoc(out), "value" -> value.toString))
    case ConstString(out, value) => jsonObjectSmall(ListMap("op" -> "\"Const\"",
      "format" -> "\"string\"", "out" -> toDoc(out), "value" -> "\"%s\"".format(escape(value))))
    case ConstFormat(out, value, fmt) => jsonObjectSmall(ListMap("op" -> "\"Const\"",
      "format" -> s"\"${fmt}\"", "out" -> toDoc(out), "value" -> "\"%s\"".format(escape(value))))
    case PrimOp(name, out, in) => jsonObjectSmall(ListMap("op" -> "\"PrimOp\"",
      "name" -> dquotes(escape(name)),
      "out" -> toDoc(out),
      "in" -> toDoc(in)))
    case Add(out, in1, in2) => jsonObjectSmall(ListMap("op" -> "\"Add\"",
      "out" -> toDoc(out), "in1" -> toDoc(in1), "in2" -> toDoc(in2)))
    case Push(target, args) => jsonObjectSmall(ListMap("op" -> "\"Push\"",
      "target" -> toDoc(target), "args" -> toDoc(args)))
    case ShiftDyn(out, n, label) => jsonObjectSmall(ListMap("op" -> "\"ShiftDyn\"",
      "out" -> toDoc(out), "n" -> toDoc(n), "label" -> toDoc(label)))
    case Control(out, n, label) => jsonObjectSmall(ListMap("op" -> "\"Control\"",
      "out" -> toDoc(out), "n" -> toDoc(n), "label" -> toDoc(label)))
    case IfZero(arg, thenClause) => jsonObjectSmall(ListMap("op" -> "\"IfZero\"",
      "cond" -> toDoc(arg),
      "then" -> toDoc(thenClause)))
    case Copy(from, to) => jsonObjectSmall(ListMap("op" -> "\"Copy\"",
      "from" -> toDoc(from), "to" -> toDoc(to)
    ))
    case Drop(reg) => jsonObjectSmall(ListMap("op" -> "\"Drop\"",
      "reg" -> toDoc(reg)
    ))
    case Swap(a, b) => jsonObjectSmall(ListMap("op" -> "\"Swap\"",
      "a" -> toDoc(a), "b" -> toDoc(b)
    ))
    case Construct(out, adt_type, tag, args) => jsonObjectSmall(ListMap("op" -> "\"Construct\"",
      "out" -> toDoc(out),
      "type" -> toDoc(adt_type),
      "tag" -> toDoc(tag),
      "args" -> toDoc(args)
    ))
    case NewStack(out, region, label, target, args) => jsonObjectSmall(ListMap("op" -> "\"NewStack\"",
      "out" -> toDoc(out),
      "region" -> toDoc(region),
      "label" -> toDoc(label),
      "target" -> toDoc(target),
      "args" -> toDoc(args)
    ))
    case NewStackWithBinding(out, region, label, target, args, binding) => jsonObjectSmall(ListMap("op" -> "\"NewStackWithBinding\"",
      "out" -> toDoc(out),
      "region" -> toDoc(region),
      "label" -> toDoc(label),
      "target" -> toDoc(target),
      "args" -> toDoc(args),
      "binding" -> toDoc(binding)
    ))
    case PushStack(arg) => jsonObjectSmall(ListMap("op" -> "\"PushStack\"",
      "arg" -> toDoc(arg)
    ))
    case New(out, tags, targets, args) => jsonObjectSmall(ListMap("op" -> "\"New\"",
      "out" -> toDoc(out),
      "targets" -> jsonListSmall(targets.map(toDoc)),
      "args" -> toDoc(args),
      "tags" -> jsonListSmall(tags map toDoc)
    ))
    case Allocate(out, init, region) => jsonObjectSmall(ListMap("op" -> "\"Allocate\"",
      "out" -> toDoc(out),
      "init" -> toDoc(init),
      "region" -> toDoc(region)
    ))
    case Load(out, ref) => jsonObjectSmall(ListMap("op" -> "\"Load\"",
      "out" -> toDoc(out),
      "ref" -> toDoc(ref)
    ))
    case Store(ref, value) => jsonObjectSmall(ListMap("op" -> "\"Store\"",
      "ref" -> toDoc(ref),
      "value" -> toDoc(value)
    ))
    case Proj(out, adt_type, scrutinee, tag, field) => jsonObjectSmall(ListMap("op" -> "\"Proj\"",
      "out" -> toDoc(out),
      "type" -> toDoc(adt_type),
      "scrutinee" -> toDoc(scrutinee),
      "tag" -> toDoc(tag),
      "field" -> toDoc(field)
    ))
    case GetDynamic(out, n, label) => jsonObjectSmall(ListMap("op" -> "\"GetDynamic\"",
      "out" -> toDoc(out), "n" -> toDoc(n), "label" -> toDoc(label)))
    case Debug(msg, traced) => jsonObjectSmall(ListMap("op" -> "\"Debug\"", "msg" -> s"\"${escape(msg)}\"", "traced" -> toDoc(traced)))
  }

  def toDoc(tag: Tag): Doc = tag match {
    case Tag.Index(i) => toDoc(i)
    case Tag.Name(n) => s"\"${escape(n)}\""
  }

  def toDoc(terminator: Terminator): Doc = terminator match {
    case Return(args) => jsonObjectSmall(ListMap("op" -> "\"Return\"", "args" -> toDoc(args)))
    case Jump(target) => jsonObjectSmall(ListMap("op" -> "\"Jump\"", "target" -> toDoc(target)))
    case Match(adt_type, scrutinee, clauses, default) => jsonObjectSmall(ListMap("op" -> "\"Match\"",
      "type" -> toDoc(adt_type),
      "scrutinee" -> toDoc(scrutinee),
      "clauses" -> jsonListSmall(clauses.map(toDoc)),
      "default" -> toDoc(default)))
    case Invoke(receiver, tag, args) => jsonObjectSmall(ListMap("op" -> "\"Invoke\"",
      "receiver" -> toDoc(receiver),
      "tag" -> toDoc(tag),
      "args" -> toDoc(args)
    ))
    case Switch(arg, values, targets, default) => jsonObjectSmall(ListMap("op" -> "\"Switch\"",
      "arg" -> toDoc(arg),
      "values" -> jsonListSmall(values.map(toDoc)),
      "targets" -> jsonListSmall(targets.map(toDoc)),
      "default" -> toDoc(default)
    ))
    case CallLib(lib, symbol) => jsonObjectSmall(ListMap("op" -> "\"CallLib\"",
      "lib" -> toDoc(lib),
      "symbol" -> jsonString(symbol)
    ))
    case LoadLib(path) => jsonObjectSmall(ListMap("op" -> "\"LoadLib\"",
      "path" -> toDoc(path)
    ))
  }

  def toDoc(clause: Clause): Doc = clause match
    case Clause(tag, args, target) => {
      jsonObjectSmall(ListMap("tag" -> toDoc(tag), "target" -> toDoc(target), "args" -> toDoc(args)))
    }

  def toDoc(args: RegList): Doc = args match
    case RegList(args) => {
      jsonObjectSmall(Map("any" ->
        jsonListSmall(args.map(toDoc))
      ))
    }

  def toDoc(i: asm.LiteralType): Doc = i match {
    case i: Int => i.toString
    case b: Boolean => b.toString
    case _ => ???
  }

  def format(prog: Program): Document = {
    pretty(toDoc(prog))
  }

  override def apply(f: Program)(using ErrorReporter): Output = new Output {
    override def emitTo[T](t: Target[T]): T = t.fromString(format(f))
  }
}
