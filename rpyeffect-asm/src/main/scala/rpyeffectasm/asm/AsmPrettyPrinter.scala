package rpyeffectasm.asm

import rpyeffectasm.util.{Output, ErrorReporter, Target, Phase}

object AsmPrettyPrinter extends Phase[Program[AsmFlags, Id, Id, Id], Output] {
  def apply(id: Id): String = id match {
    case Name(name) => s"$$${name}"
    case generated: Generated => s"##[${generated.toString}]"
    case IndexWithDebug(i, debug) => s"#${i}%\"${rpyeffectasm.util.escape(debug)}\""
    case Index(i) => s"#${i}"
  }

  def apply(r: RhsOperand[AsmFlags, Id] | LhsOperand[AsmFlags, Id]): String = r match {
    case Const(value: Int) => value.toString
    case Const(value: Double) => value.toString
    case Const(value: String) => s"\"${value}\""
    case Var(name) => apply(name)
    case Var(name) => s"${apply(name)}"
    case Ref(ref) => s"*${apply(ref)}"
  }

  def apply(value: RhsOpList[AsmFlags, Id] | LhsOpList[AsmFlags, Id]): String = {
    val c = (value map apply).mkString(", ")
    s"(${c})"
  }
  
  def apply(clause: Clause[AsmFlags, Id, Id]): String = clause match {
    case Clause(params, env, target) => s"${apply(params)} | ${apply(env)} => ${apply(target)}"
  }

  def apply(instruction: Instruction[AsmFlags, Id, Id, Id]): String = instruction match {
    case Let(lhss, rhss) => {
      val binds = ((lhss zip rhss) map { case (l,r) => s"${apply(l)} <- ${apply(r)}"}).mkString(", ")
      s"let ${binds}"
    }
    case LetConst(out, value: Int) => s"let const ${apply(out)} <- ${value}"
    case LetConst(out, value: Boolean) => s"let const ${apply(out)} <- ${value}"
    case LetConst(out, value: Double) => s"let const ${apply(out)} <- ${value}"
    case LetConst(out, value: String) => s"let const ${apply(out)} <- \"${value}\""
    case LetConst(out, FormatConst(fmt, value)) => s"let const ${apply(out)} <- ${fmt}\"${value}\""
    case Primitive(out, name, in) => s"${apply(out)} <- prim[${name}]${apply(in)}"
    case Debug(msg, traced) => s"debug \"${rpyeffectasm.util.escape(msg)}\" ${apply(traced)}"
    case Push(target, args) => s"push ${apply(target)}${apply(args)}"
    case Return(args) => s"return${apply(args)}"
    case Jump(target, env) => s"jump ${apply(target)}${apply(env)}"
    case CallLib(lib, symbol, env) => s"calllib ${apply(lib)}[${symbol}]${apply(env)}"
    case LoadLib(path) => s"loadlib ${apply(path)}"
    case IfZero(arg, Clause(Nil, env, target)) => s"if0 ${apply(arg)} jump ${apply(target)}${apply(env)}"
    case Allocate(ref, init, region) => s"${apply(ref)} <- alloc ${apply(init)} in ${apply(region)}"
    case Load(out, ref) => s"${apply(out)} <- !${apply(ref)}"
    case Store(ref, in) => s"!${apply(ref)} <- ${apply(in)}"
    case Shift(out, n, label) => s"${apply(out)} <- shift ${apply(n)}, ${apply(label)}"
    case Control(out, n, label) => s"${apply(out)} <- control ${apply(n)}, ${apply(label)}"
    case PushStack(stack) => s"push stack ${apply(stack)}"
    case NewStack(stack, region, label, target, args) =>
      s"${apply(stack)}(${apply(region)}) <- new stack ${apply(label)} => ${apply(target)}${apply(args)}"
    case Construct(out, tpe, tag, args) => s"${apply(out)} <- ${apply(tpe)}.${apply(tag)}${apply(args)}"
    case Match(tpe, scrutinee, clauses, default) =>
      val body = (clauses map { case (id, Clause(params, env, target)) =>
        s"${apply(id)}${apply(params)} => ${apply(target)}${apply(env)}"
      }).mkString("\n      | ")
      val tDef = s"\n      | _ => ${apply(default.target)}${apply(default.env)}"
      s"match ${apply(scrutinee)}:${apply(tpe)}\n        ${body}${tDef}"
    case Switch(arg, cases, default, env) =>
      val body = (cases map { case (v, t) => s"${v} => ${apply(t)}"}).mkString("\n      | ")
      val tDef = s"\n      | _ => ${apply(default)}"
      s"switch ${apply(arg)}${apply(env)}\n        ${body}${tDef}"
    case Proj(out, tpe, scrutinee, tag, field) =>
      s"${apply(out)} <- ${apply(scrutinee)}:${apply(tpe)}.${apply(tag)}#${field}"
    case New(out, ifce, targets, args) =>
      val body = (targets map {
        case (tag, target) => s"${apply(tag)} => ${apply(target)}"
      }).mkString(";\n|        ")
      s"""${apply(out)} <- ${apply(ifce)}${apply(args)} {
         |        ${body}
         |    }""".stripMargin
    case Invoke(receiver, ifce, tag, args) =>
      s"${apply(receiver)}:${apply(ifce)}.${apply(tag)}${apply(args)}"
    case NewStackWithBinding(stack, region, label, target, args, binding) =>
      s"${apply(stack)}(${apply(region)}) <- new stack ${apply(label)} with ${apply(binding)} => ${apply(target)}${apply(args)}"
    case GetDynamic(out, n, label) =>
      s"${apply(out)} <- get dynamic ${apply(n)}, ${apply(label)}"
    case other => throw new IllegalArgumentException(other.toString)
  }

  def apply(block: Block[AsmFlags, Id, Id, Id]): String = block match {
    case Block(label, params, instructions, export_as) =>
      val body = (instructions map apply).mkString(";\n    ")
        .replace("\n","\n|") // hack to counter-act stripMargin
      val tExportAs = if export_as.isEmpty then "" else {
        s"""@export(${export_as.map{ x => s"\"${rpyeffectasm.util.escape(x)}\""}.mkString(",")})"""
      }
      s"""${tExportAs}${apply(label)}${apply(params)} {
         |    ${body}
         |}
         |""".stripMargin
  }

  def apply(program: Program[AsmFlags, Id, Id, Id])(using ErrorReporter): Output = program match {
    case Program(blocks) => new Output{
      def emitTo[T](t: Target[T]): T = t.fromString((blocks map apply).mkString("\n"))
    }
  }

}
