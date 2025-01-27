package rpyeffectasm.mcore
import scala.io.Source
import rpyeffectasm.util.{ErrorReporter, JsonParsers, Phase}
import rpyeffectasm.common.Purity
import rpyeffectasm.mcore.sugar.{HandlerSugar, DynamicHandlerSugar}

class JsonParser extends JsonParsers with Phase[Source, Program[ATerm]] {
  def id: JsonParser[Id] = {
    string ^ { n => Name(n) } || int ^ { i => Index(i) }
  }
  def const[T](t: T): JsonParser[T] = any ^ { _ => t }
  def purity: JsonParser[Purity] = (string &= {
    case "Pure" => const(Purity.Pure)
    case "Impure" | "Effectful" => const(Purity.Effectful)
    case o => fail(s"Unknown purity ${o}")
  }) ^ { case (_, p) => p }
  def methodTpe: JsonParser[Method] = obj(
    "tag" -> id & "params" -> list(tpe) & "return" -> tpe
  ) ^ { case ((t,ps),r) => Method(t,ps,r) }
  def constructorTpe: JsonParser[Constructor] = obj(
    "tag" -> id & "fields" -> list(tpe)
  ) ^ Constructor.apply
  def tpe: JsonParser[Type] = obj("op" -> string &= {
    case "Top" => const(Top)
    case "Ptr" => const(Ptr)
    case "Num" => const(Num)
    case "Bottom" => const(Bottom)
    case "Int" => const(Base.Int)
    case "Bool" => const(Base.Bool)
    case "Double" => const(Base.Double)
    case "String" => const(Base.String)
    case "Label" => optional("at" -> tpe) & optional("binding" -> tpe) ^ { (at, bnd) => Base.Label(at.getOrElse(Top), bnd) }
    case "Unit" => const(Base.Unit)
    case "Function" => ("params" -> list(tpe) & "return" -> tpe & "purity" -> purity) ^ {
      case ((ps,r),p) => Function(ps, r, p)
    }
    case "Codata" => ("interface_tag" -> id & "methods" -> list(methodTpe)) ^ Codata.apply
    case "Data" => ("type_tag" -> id & "constructors" -> list(constructorTpe)) ^ Data.apply
    case "Stack" => ("resume_return" -> tpe & "resume_args" -> list(tpe)) ^ Stack.apply
    case "Ref" => ("to" -> tpe) ^ Ref.apply
    case o => fail(s"Unknown type op ${o}")
  }) ^ { case (_, t) => t }
  def v: JsonParser[Var] = obj("id" -> id & "type" -> tpe) ^ Var.apply
  def lhsOperand = v
  def clause: JsonParser[Clause[ATerm]] = obj("params" -> list(lhsOperand) & "body" -> term) ^ { case (ps, b) => Clause(ps, b) }
  def literal: JsonParser[Literal] = ("type" -> tpe &= {
    case Base.Int => "value" -> int ^ { i => Literal.Int(i) }
    case Base.Bool => "value" -> bool ^ { b => Literal.Bool(b) }
    case Base.Double => "value" -> double ^ { d => Literal.Double(d) }
    case Base.String => "value" -> string & optional("format" -> string) ^ {
      case (s, None) => Literal.String(s)
      case (s, Some(fmt)) => Literal.StringWithFormat(s, fmt)
    }
    case Base.Label(_,_) => const(Literal.Label)
    case Base.Unit => const(Literal.Unit)
    case o =>
      fail(s"Literals of non-base type ${o} are not supported.")
  }) ^ { case (_, r) => r }
  def term: JsonParser[Term[ATerm]] = obj("op" -> string &= {
    case "Var" => v // spliced in
    case "Abs" => ("params" -> list(lhsOperand) & "body" -> term) ^ Abs.apply
    case "App" => ("fn" -> term & "args" -> list(term)) ^ App.apply
    case "Seq" => ("elems" -> list(term)) ^ Seq.apply
    case "Let" => ("definitions" -> list(definition) & "body" -> term) ^ Let.apply
    case "LetRec" => ("definitions" -> list(definition) & "body" -> term) ^ LetRec.apply
    case "IfZero" => ("cond" -> term & "then" -> term & "else" -> term) ^ { case ((c,t),e) => IfZero(c,t,e) }
    case "Construct" => ("type_tag" -> id & "tag" -> id & "args" -> list(term)) ^ { case ((tt,t),args) => Construct(tt,t,args) }
    case "Project" => ("scrutinee" -> term & "type_tag" -> id & "tag" -> id & "field" -> int) ^ { case (((s,tt),t),f) => Project(s,tt,t,f) }
    case "Match" => ("scrutinee" -> term & "type_tag" -> id & "clauses" -> list(obj("tag" -> id & clause /* spliced in */)) & "default_clause" -> obj(clause)) ^ { case (((s,tt),cs),d) => Match(s, tt, cs, d) }
    case "Switch" => ("scrutinee" -> term & "cases" -> list(obj("value" -> ((int ^ Literal.Int) || obj(literal)) & "then" -> term)) & "default" -> term) ^ { case ((s,c),d) => Switch(s, c, d) }
    case "New" => ("ifce_tag" -> id & "methods" -> list(obj("tag" -> id & clause /* spliced in */))) ^ New.apply
    case "Invoke" => ("receiver" -> term & "ifce_tag" -> id & "tag" -> id & "args" -> list(term)) ^ { case (((r,tt),t),args) => Invoke(r,tt,t,args) }
    case "LetRef" => ("ref" -> lhsOperand & "region" -> term & "binding" -> term & "body" -> term) ^ { case (((ref,reg),init),body) => LetRef(ref,reg,init,body) }
    case "Load" => ("ref" -> term) ^ Load.apply
    case "Store" => ("ref" -> term & "value" -> term) ^ Store.apply
    case "FreshLabel" => const(FreshLabel())
    case "Reset" => ("label" -> term & "region" -> lhsOperand & optional("binding" -> term) & "body" -> term & "return" -> clause) ^ { case ((((l,reg),bnd),b),r) => Reset(l,reg,bnd,b,r) }
    case "Shift" => ("label" -> term & "n" -> term & "k" -> lhsOperand & "body" -> term & "returnType" -> tpe) ^ { case ((((l,n),k),body),t) => Shift(l, n, k, body, t) }
    case "GetDynamic" => ("label" -> term & "n" -> term) ^ GetDynamic.apply
    case "Control" => ("label" -> term & "n" -> term & "k" -> lhsOperand & "body" -> term & "returnType" -> tpe) ^ { case ((((l,n),k),body),t) => Control(l, n, k, body, t) }
    case "Primitive" => ("name" -> string & "args" -> list(term) & "returns" -> list(lhsOperand) & "rest" -> term) ^ { case (((name,args),rets),rest) => Primitive(name,args,rets,rest) }
    case "Resume" => ("k" -> term & "args" -> list(term)) ^ Resume.apply
    case "Resumed" => ("k" -> term & "body" -> term) ^ Resumed.apply
    case "Literal" => literal
    case "Handle" => ("tpe" -> (string ^ HandlerSugar.HandlerType.valueOf) & "tag" -> id
      & "handlers" -> list(obj("tag" -> id & "params" -> list(lhsOperand) & "body" -> term))
      & "body" -> term & optional("ret" -> clause)) ^ {
      case ((((tpe, tag), handlers), body), ret) => HandlerSugar.Handle(tpe, tag, handlers.map{
        case ((t, ps), b) => (t, Clause(ps, b))
      }, ret, body)
    }
    case "Op" => ("tag" -> id & "op_tag" -> id & "args" -> list(term) & "k" -> clause & "rtpe" -> tpe) ^ {
      case ((((tag, op), args), k), rtpe) => HandlerSugar.Op(tag, op, args, k, rtpe)
    }
    case "DHandle" => ("tpe" -> (string ^ DynamicHandlerSugar.HandlerType.valueOf) & "tag" -> term
      & "handlers" -> list(obj("tag" -> id & "params" -> list(lhsOperand) & "body" -> term))
      & "body" -> term & optional("ret" -> clause)) ^ {
      case ((((tpe, tag), handlers), body), ret) => DynamicHandlerSugar.Handle(tpe, tag, handlers.map {
        case ((t, ps), b) => (t, Clause(ps, b))
      }, ret, body)
    }
    case "DOp" => ("tag" -> term & "op_tag" -> id & "args" -> list(term) & "k" -> clause & "rtpe" -> tpe) ^ {
      case ((((tag, op), args), k), rtpe) => DynamicHandlerSugar.Op(tag, op, args, k, rtpe)
    }
    case "DebugWrap" => ("inner" -> term & "annotation" -> string) ^ {
      case (inner, annot) => DebugWrap(inner, annot)
    }
    case "LoadLib" => ("path" -> term) ^ LoadLib.apply
    case "CallLib" => ("lib" -> term & "symbol" -> string & "args" -> list(term) & "return_type" -> tpe) ^ {
      case (((l,s),a),t) => CallLib(l,s,a,t)
    }
    case "Qualified" => ("lib" -> v & "name" -> string & "type" -> tpe) ^ {
      case ((l,n),t) => Qualified(l,n,t)
    }
    case "AlternativeFail" => const(AlternativeFail)
    case "AlternativeChoice" => ("choices" -> list(term)) ^ AlternativeChoice.apply
    case "The" => ("type" -> tpe & "term" -> term) ^ The.apply
    case "ThisLib" => const(ThisLib())
    case op => fail(s"Unknown op '${op}'")
  }) ^ { case (_, t) => t }

  def definition: JsonParser[Definition[ATerm]] = obj("name" -> lhsOperand & "value" -> term & optional("export_as" -> list(string))) ^ {
    case ((n,v),e) => Definition(n,v,e.getOrElse(Nil))
  }

  def include: JsonParser[List[Definition[ATerm]]] = (obj("format" -> string &= {
    case "sexp" => "value" -> string ^ {
      sexp => ErrorReporter.catchExitOutside{ ErrorReporter.withErrorsToStderr { SExpParser(Source.fromString(sexp)) } }
    }
    case "json" => "value" -> string ^ {
      json => ErrorReporter.catchExitOutside{ ErrorReporter.withErrorsToStderr { parseProgram(json) } }
    }
    case _ => const(None)
  }) ^?? {
    case (_, Some(Program(defs, _))) => Some(defs)
    case _ => None
  })
  def program: JsonParser[Program[ATerm]] = obj(optional("includes" -> list(include)) & "definitions" -> list(definition) & "main" -> term) ^ {
    case ((sdefs, defs), main) =>
      Program(sdefs.getOrElse(Nil).flatten ++ defs, main)
  }

  def parseTerm(s: String)(using ErrorReporter): Term[ATerm] = parse(term, Source.fromString(s))
  def parseProgram(s: String)(using ErrorReporter): Program[ATerm] = parse(program, Source.fromString(s))
  override def apply(f: Source)(using ErrorReporter): Program[ATerm] = parse(program, f)
}

