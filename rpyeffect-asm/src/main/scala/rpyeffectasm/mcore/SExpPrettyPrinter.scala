package rpyeffectasm.mcore

import rpyeffectasm.util.{Output, Phase, ErrorReporter}
import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}

object SExpPrettyPrinter extends Phase[Program[ATerm], Output] {

  import rpyeffectasm.util.Json

  def escape(s: String): String = s.flatMap(escapeChar)

  def escapeChar(ch: Char): String = ch match {
    case '\b' => "\\b"
    case '\t' => "\\t"
    case '\n' => "\\n"
    case '\f' => "\\f"
    case '\r' => "\\r"
    case '"' => "\\\""
    case '\'' => "\\\'"
    case '\\' => "\\\\"
    case _ => if (ch.isControl) "\\0" + Integer.toOctalString(ch.toInt)
    else String.valueOf(ch)
  }

  case class Context(var indent: Int, var singleline: Boolean, var sepIsNl: Boolean)
  def nl(using C: Context): String = {
    C.sepIsNl = true
    if(C.singleline) {
      " "
    } else {
      val indent = " ".repeat(C.indent)
      s"\n${indent}"
    }
  }
  def sep(using C: Context): String = {
    if C.sepIsNl then {
      val r = nl
      C.sepIsNl = true
      r
    } else " "
  }
  def indented[R](by: Int)(body: => R)(using C: Context): R = {
    val old = C.indent
    C.indent = old + by
    val r = body
    C.indent = old
    r
  }
  def singleline[R](body: => R)(using C: Context): R = {
    val old = C.singleline
    C.singleline = true
    val r = body
    C.singleline = old
    r
  }
  def scope[R](body: => R)(using C: Context): R = {
    val old = C.sepIsNl
    C.sepIsNl = false
    val r = body
    C.sepIsNl = old
    r
  }

  def toDoc(str: String): String = s"\"${rpyeffectasm.util.escape(str)}\""

  def toDoc(x: Id)(using Context): String = x match {
    case Name(name) if escape(name) != name || name.matches(".*(\\s|[):]).*") => s"$$\"${escape(name)}\""
    case Name(name) => "$" + name
    case Index(i) => "#" + i
    case generated: Generated => s"##${generated.name}${generated.toString}"
  }
  def toDoc(tpe: Type)(using Context): String = tpe match {
    case Top => "top"
    case Ptr => "ptr"
    case Num => "num"
    case Bottom => "bot"
    case Function(params, ret, purity) =>
      val tParams = params.map(toDoc).mkString(sep)
      val tPurity = purity.productPrefix
      s"(fun ${tPurity} (${tParams}) ${toDoc(ret)})"
    case Codata(ifce_tag, methods) =>
      val tMethods = methods.map{ case Method(tag, params, ret) =>
        val tParams = params.map(toDoc).mkString(sep)
        s"(${toDoc(tag)} (${tParams}) ${toDoc(ret)})"
      }.mkString(sep)
      s"(codata ${toDoc(ifce_tag)} ${tMethods})"
    case Data(type_tag, constructors) =>
      val tConstructors = constructors.map { case Constructor(tag, fields) =>
        val tFields = fields.map(toDoc).mkString(sep)
        s"(${toDoc(tag)} ${tFields})"
      }.mkString(sep)
      s"(data ${toDoc(type_tag)} ${tConstructors})"
    case Stack(resume_ret, resume_args) =>
      val tArgs = resume_args.map(toDoc).mkString(sep)
      s"(stack ${toDoc(resume_ret)} (${tArgs}))"
    case Ref(to) => s"(ref ${toDoc(to)})"
    case Base.Int => "int"
    case Base.Double => "double"
    case Base.String => "str"
    case Base.Label(at, bnd) => s"(label${sep}${toDoc(at)}${bnd match {
      case Some(bnd) => s"${sep}${toDoc(bnd)}"
      case None => ""
    }})"
    case Base.Unit => "unit"
    case Base.Bool => "bool"
  }
  def toDoc(t: Term[ATerm])(using Context): String = t match {
    case Var(name, tpe) => s"${toDoc(name)}:${singleline{toDoc(tpe)}}"
    case Abs(params, body) =>
      val tParams = scope{ params.map(toDoc).mkString(sep) }
      s"(lambda (${tParams})${nl}${indented(2){toDoc(body)}})"
    case App(fn, args) =>
      scope{
        val tArgs = indented(4){ args.map(toDoc).mkString(sep) }
        s"(${toDoc(fn)}${sep}${tArgs})"
      }
    case Seq(ts) =>
      val body = indented(4){ nl ++ ts.map(toDoc).mkString(nl) }
      s"(begin ${body})"
    case Let(defs, body) =>
      val tDefs = indented(5){ defs.map(toDoc).mkString(nl) }
      val tBody = indented(2){ nl + toDoc(body) }
      s"(let (${tDefs})${tBody})"
    case LetRec(defs, body) =>
      val tDefs = indented(8){ defs.map(toDoc).mkString(nl) }
      val tBody = indented(2){ nl + toDoc(body) }
      s"(letrec (${tDefs})${tBody})"
    case IfZero(cond, thn, els) =>
      val tCond = indented(4){ toDoc(cond.unroll) }
      val tThn = indented(2){ toDoc(thn) }
      val tEls = indented(2){ toDoc(els) }
      s"(if0 ${tCond}${sep}${tThn}${sep}${tEls})"
    case Construct(tpe_tag, tag, args) =>
      val tArgs = indented(4){ scope{ args.map(toDoc).mkString(sep) }}
      s"(make ${toDoc(tpe_tag)} ${toDoc(tag)} (${tArgs}))"
    case Project(scrutinee, tpe_tag, tag, field) =>
      scope{ s"(project ${toDoc(scrutinee)}${indented(4){sep}}${toDoc(tpe_tag)} ${toDoc(tag)} ${field})" }
    case Match(scrutinee, tpe_tag, clauses, Clause(dparams, dbody)) =>
      val tClauses = indented(4){ clauses.map{ case (t, Clause(params, body)) =>
        val tParams = params.map(toDoc).mkString(sep)
        val tBody = indented(2) { s"${nl}${toDoc(body)}"}
        s"(${toDoc(t)} (${tParams}) ${tBody})"
      }.mkString(nl)
      }
      val tDefault = indented(4){
        val tParams = dparams.map(toDoc).mkString(sep)
        val tBody = indented(2) {
          s"${nl}${toDoc(dbody)}"
        }
        s"(_ (${tParams}) ${tBody})"
      }
      s"(match (${toDoc(scrutinee.unroll)}${indented(4){nl}}${toDoc(tpe_tag)})${nl}${tClauses}${nl}${tDefault})"
    case Switch(scrutinee, cases, default) =>
      val tCases = indented(4) { cases.map{ case (v, thn) =>
        val tThn = indented(2) { s"${nl}${toDoc(thn)}" }
        s"(${v} ${tThn})"
      }.mkString(nl) }
      val tDefault = indented(4) {
        val tDef = indented(2){ s"${nl}${toDoc(default)}"}
        s"(_ ${tDef})"
      }
      s"(switch ${toDoc(scrutinee.unroll)}${nl}${tCases}${nl}${tDefault})"
    case New(ifce_tag, methods) =>
      val tMethods = indented(4){ methods.map{ case (t, Clause(params, body)) =>
        val tParams = params.map(toDoc).mkString(sep)
        val tBody = indented(2) { s"${nl}${toDoc(body)}" }
        s"(${toDoc(t)} (${tParams})${tBody})"
      }.mkString(nl) }
      s"(new ${toDoc(ifce_tag)}${indented(4){nl}}${tMethods})"
    case Invoke(receiver, ifce_tag, method, args) =>
      scope { indented(4) {
        val tArgs = args.map(toDoc).mkString(sep)
        s"(invoke ${indented(4){toDoc(receiver)}}${sep}${toDoc(ifce_tag)} ${toDoc(method)}${sep}${tArgs})"
      }}
    case LetRef(ref, region, binding, body) =>
      val tBody = indented(2){s"${nl}${toDoc(body)}"}
      scope { indented(8) {
        s"(letref (${toDoc(ref)} ${toDoc(region.unroll)}${sep}${toDoc(binding.unroll)})${tBody})"
      }}
    case Load(ref) => s"(load ${indented(6){toDoc(ref)}})"
    case Store(ref, value) => scope{ indented(4){ s"(store ${toDoc(ref)}${sep}${toDoc(value)})" }}
    case FreshLabel() => "(fresh-label)"
    case Reset(label, region, bnd, body, Clause(params, ret)) =>
      val tLbl = toDoc(label.unroll)
      val tRegion = s"${sep}${toDoc(region)}"
      val tBnd = bnd.map { b => s"${sep}${toDoc(b.unroll)}" }.getOrElse("")
      val tBody = indented(2) {s"${nl}${toDoc(body)}"}
      val tRParams = params.map(toDoc).mkString(sep)
      val tRet = indented(4) {s"${nl}((${tRParams}) ${toDoc(ret)})"}
      scope{ indented(9){
        s"(reset (${tLbl}${tRegion}${tBnd})${tBody}${tRet})"
      }}
    case Shift(label, n, k, body, tpe) =>
      val tBody = indented(2){s"${nl}${toDoc(body)}"}
      scope { indented(8) {
        s"(shift:${toDoc(tpe)} (${toDoc(label.unroll)}${sep}${toDoc(n.unroll)}) (${toDoc(k)})${tBody})"
      }}
    case GetDynamic(label, n) =>
      s"(get-dynamic ${toDoc(label.unroll)}${sep}${toDoc(n.unroll)})"
    case Control(label, n, k, body, tpe) =>
      val tBody = indented(2) {
        s"${nl}${toDoc(body)}"
      }
      scope { indented(8) {
          s"(control:${toDoc(tpe)} (${toDoc(label.unroll)}${sep}${toDoc(n.unroll)}) (${toDoc(k)})${tBody})"
      }}
    case Primitive(name, args, returns, rest) =>
      val tReturns = returns.map(toDoc).mkString(sep)
      val tArgs = scope{ indented(4){ args.map{ a => toDoc(a.unroll) }.mkString(sep) }}
      val tBody = indented(2){ s"${nl}${toDoc(rest)}" }
      s"(prim (${tReturns}) (\"${name}\" ${tArgs}) ${tBody})"
    case l: Literal => l match {
      case Literal.Int(i) => s"${i}"
      case Literal.Bool(b) => s"${b}"
      case Literal.Double(d) => s"${d}"
      case Literal.String(s) => toDoc(s)
      case Literal.Unit => "(unit)"
      case Literal.Label => "(label null)"
      case Literal.StringWithFormat(v, f) => f ++ toDoc(v)
    }
    case Resume(cont, args) =>
      s"(resume ${toDoc(cont)}${sep}${(args map toDoc).mkString(sep)})"
    case Resumed(cont, body) =>
      s"(resume ${toDoc(cont.unroll)}${sep}${toDoc(body)})"
    case HandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      val tHandlers = scope{ indented(4){ handlers.map{ case (ht, hc) =>
        s"(${toDoc(ht)} (${(hc.params map toDoc).mkString(sep)})${sep}${toDoc(hc.body)})"
      }.mkString(sep)}}
      val tRet = ret.map{ r => scope{ indented(4){
        s"(return (${(r.params map toDoc).mkString(sep)})${sep}${toDoc(r.body)})"
      }} }.getOrElse("")
      val tBody = scope{ indented(2){ toDoc(body) }}
      s"(handle ${tpe.productPrefix} ${toDoc(tag)}${sep}(${tHandlers}${sep}${tRet})${sep}${tBody})"
    case HandlerSugar.Op(tag, op, args, k, rtpe) =>
      val rk = scope{ indented(2) { s"(${(k.params map toDoc).mkString(sep)})${sep}${toDoc(k.body)}" }}
      s"(op ${toDoc(tag)} (${toDoc(op)}${sep}${toDoc(rtpe)}${sep}${(args map toDoc).mkString(sep)}) ${rk})"
    case DynamicHandlerSugar.Handle(tpe, tag, handlers, ret, body) =>
      val tHandlers = scope{ indented(4){ handlers.map{ case (ht, hc) =>
        s"(${toDoc(ht)} (${(hc.params map toDoc).mkString(sep)})${sep}${toDoc(hc.body)})"
      }.mkString(sep)}}
      val tRet = ret.map{ r => scope{ indented(4){
        s"(return (${(r.params map toDoc).mkString(sep)})${sep}${toDoc(r.body)})"
      }} }.getOrElse("")
      val tBody = scope{ indented(2){ toDoc(body) }}
      s"(dhandle ${tpe.productPrefix} ${toDoc(tag)}${sep}(${tHandlers}${sep}${tRet})${sep}${tBody})"
    case DynamicHandlerSugar.Op(tag, op, args, k, rtpe) =>
      val rk = scope{ indented(2) { s"(${(k.params map toDoc).mkString(sep)})${sep}${toDoc(k.body)}" }}
      s"(dop ${toDoc(tag)} (${toDoc(op)}${sep}${toDoc(rtpe)}${sep}${(args map toDoc).mkString(sep)}) ${rk})"
    case DebugWrap(inner, annotation) =>
      s"(debugWrap${sep}\"${rpyeffectasm.util.escape(annotation)}\"${nl}${toDoc(inner)})"
    case CallLib(lib, symbol, args, returnType) =>
      s"(call-lib${sep}${toDoc(lib.unroll)}${sep}${toDoc(symbol)}${sep}${toDoc(returnType)}${sep}${args.map{ a => toDoc(a.unroll)}.mkString(sep)})"
    case Qualified(lib, name, tpe) =>
      s"(qualified ${toDoc(lib)}${sep}${toDoc(name)}${sep}${toDoc(tpe)})"
    case LoadLib(path) => s"(load-lib${sep}${toDoc(path.unroll)})"
    case AlternativeChoice(choices) =>
      s"(alternative-choice ${choices.map(toDoc).mkString(sep)})"
    case AlternativeFail => "(alternative-fail)"
    case The(tp, t) => s"(the${sep}${toDoc(tp)}${sep}${toDoc(t)})"
    case ThisLib() => "(this-lib)"
  }

  def toDoc(definition: Definition[ATerm])(using Context): String = definition match {
    case Definition(name, binding, exportAs) =>
      val tExportAs = s":export-as (${exportAs.map{ x => s"\"${rpyeffectasm.util.escape(x)}\"" }.mkString(" ")})"
      s"(define ${toDoc(name)} ${toDoc(binding)}${if exportAs.isEmpty then "" else s"${sep}${tExportAs}"})"
  }
  def toDoc(p: Program[ATerm])(using Context): String = p match {
    case Program(definitions, main) =>
      val tDefs = definitions.map(toDoc).mkString("\n")
      s"${tDefs}\n\n${toDoc(main)}"
  }

  def apply(d: Definition[ATerm])(using ErrorReporter): String = {
    given Context = Context(0, false, false)
    toDoc(d)
  }

  def apply(t: Term[ATerm])(using ErrorReporter): String = {
    given Context = Context(0, false, false)
    toDoc(t)
  }

  def apply(t: Type)(using ErrorReporter): String = {
    given Context = Context(0, false, false)
    toDoc(t)
  }
  def apply(x: Id)(using ErrorReporter): String = {
    given Context = Context(0, false, false)
    toDoc(x)
  }

  override def apply(f: Program[ATerm])(using ErrorReporter): Output = {
    given Context = Context(0, false, false)
    new Output {
      import rpyeffectasm.util.Target
      override def emitTo[T](t: Target[T]): T = t.fromString(toDoc(f))
    }
  }
}


