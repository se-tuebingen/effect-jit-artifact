package rpyeffectasm.asm
import rpyeffectasm.util.{ErrorReporter, JsonParsers, Phase}
import rpyeffectasm.util.ErrorReporter.{error, fatal}

import scala.io.Source

class JsonParser extends JsonParsers with Phase[Source, Program[AsmFlags, Id, Id, Id]] {
  type JP[T] = JsonParser[T]
  type Flags = AsmFlags
  type Tag = Id
  type Label = Id
  type V = Id

  def tpe: JP[Unit] = {
    exactStr("Top") ^ { _ => () }
    || exactStr("Unit") ^ { _ => () }
    || exactStr("String") ^ { _ => () }
    || exactStr("Int") ^ { _ => () }
    || exactStr("Double") ^ { _ => () }
    || exactStr("Ptr") ^ { _ => () }
    || exactStr("Num") ^ { _ => () }
    || exactStr("Label") ^ { _ => () }
    || obj("kind" -> string &= {
      case "data" => ("name" -> v & "constructors" ->
        list(obj("tag" -> v & "fields" -> list(obj("id" -> v & "type" -> tpe)))))
        ^ { _ => () }
      case "codata" => ("name" -> v & "methods" ->
        list(obj("tag" -> v & "args" -> list(obj("id" -> v & "type" -> tpe)) & "ret" -> tpe))) ^ {
        case (t, ms) => ()
      }
      case "ref" => ("to" -> tpe) ^ { _ => () }
      case "Label" => ("at" -> tpe & optional("binding" -> tpe)) ^ { _ => () }
      case _ => ??? // TODO error
    }) ^ (_._2)
  }

  def v: JP[V] = {
    string ^ { n => Name(n) } || int ^ { i => Index(i) }
  }
  def rhsOperand: JP[RhsOperand[Flags, V]] = (
    obj("id" -> v) ^ Var.apply
  )
  def lhsOperand: JP[LhsOperand[Flags, V]] = (
    obj("id" -> v) ^ Var.apply
    )
  def literal: JP[LiteralType] = (
    string ^ (_.asInstanceOf[LiteralType]) || int || double || (obj("format" -> string & "value" -> string) ^ FormatConst.apply)
  )
  def label: JP[Label] = v
  def tag: JP[Label] = v

  def clause: JP[Clause[Flags,Label,V]] = ("params" -> list(lhsOperand) & "env" -> list(rhsOperand) & "target" -> label) ^ {
    case ((ps,e),t) => Clause(ps,e,t)
  }

  def instruction: JP[Instruction[Flags,Tag,Label,V]] = (
    obj("op" -> string &= {
      case "Let" => ("lhss" -> list(lhsOperand) & "rhss" -> list(rhsOperand)) ^ Let.apply
      case "LetConst" => ("out" -> lhsOperand & "value" -> literal) ^ {case (o,v) => LetConst(o.asInstanceOf[LhsOperand[Flags,V]],v) }
      case "Prim" => ("outs" -> list(lhsOperand) & "name" -> string & "ins" -> list(rhsOperand)) ^ {case ((o,n),i) => Primitive(o,n,i)}
      case "Push" => ("target" -> label & "args" -> list(rhsOperand)) ^ Push.apply
      case "Return" => ("args" -> list(rhsOperand)) ^ Return.apply
      case "Jump" => ("target" -> label & "args" -> list(rhsOperand)) ^ Jump.apply
      case "IfZero" => ("cond" -> rhsOperand & "target" -> label & "args" -> list(rhsOperand)) ^ {case ((c,t),a) => IfZero(c,Clause(Nil,a,t))}
      case "Allocate" => ("ref" -> lhsOperand & "init" -> rhsOperand & "region" -> rhsOperand) ^ {case ((rf,i),rg) => Allocate(rf,i,rg)}
      case "Load" => ("out" -> lhsOperand & "ref" -> rhsOperand) ^ Load.apply
      case "Store" => ("ref" -> rhsOperand & "arg" -> rhsOperand) ^ Store.apply
      case "GetDynamic" => ("out" -> lhsOperand & "n" -> rhsOperand & "label" -> rhsOperand) ^ {case ((o,n),l) => GetDynamic(o,n,l)}
      case "Shift" => ("out" -> lhsOperand & "n" -> rhsOperand & "label" -> rhsOperand) ^ {case ((o,n),l) => Shift(o,n,l)}
      case "Control" => ("out" -> lhsOperand & "n" -> rhsOperand & "label" -> rhsOperand) ^ {case ((o,n),l) => Control(o,n,l)}
      case "PushStack" => ("arg" -> rhsOperand) ^ PushStack.apply
      case "NewStack" => (("stack" -> lhsOperand & "region" -> lhsOperand) & ("label" -> rhsOperand & "target" -> label) & "args" -> list(rhsOperand)) ^ {
        case (((s,r),(l,t)),a) => NewStack(s,r,l,t,a)
      }
      case "NewStackWithBinding" => (("stack" -> lhsOperand & "region" -> lhsOperand) & ("label" -> rhsOperand & "target" -> label) & "args" -> list(rhsOperand) & "binding" -> rhsOperand) ^ {
        case ((((s,r),(l,t)),a),b) => NewStackWithBinding(s,r,l,t,a,b)
      }
      case "Construct" => (("out" -> lhsOperand & "type" -> tag) & ("tag" -> tag & "args" -> list(rhsOperand))) ^ {
          case ((o,tp),(ta,a)) => Construct(o,tp,ta,a)
        }
      case "Match" => (("type" -> tag & "scrutinee" -> rhsOperand) & ("clauses" -> list(obj("tag" -> tag & "clause" -> clause)) & "default_clause" -> clause)) ^ {
          case ((tp,s),(cs,d)) => Match(tp,s,cs,d)
        }
      case "Proj" => ("out" -> lhsOperand & ("type" -> tag & "scrutinee" -> rhsOperand) & ("tag" -> tag & "field" -> int)) ^ {
          case ((o,(tp,s)),(ta,f)) => Proj(o,tp,s,ta,f)
        }
      case "New" => ("out" -> lhsOperand & "type" -> tag & "method_targets" -> list("method" -> tag & "target" -> label) & "args" -> list(rhsOperand)) ^ {
        case (((o,tp),ts),as) => New(o,tp,ts,as)
        }
      case "Invoke" => ("type" -> tag & "receiver" -> rhsOperand & "method" -> tag & "args" -> list(rhsOperand)) ^ {
          case (((tp,r),m),as) => Invoke(r,tp,m,as)
        }
      case "Switch" => ("arg" -> rhsOperand &
        "cases" -> list(obj("value" -> literal & "target" -> label)) &
        "default" -> label &
        "env" -> list(rhsOperand)) ^ {
        case (((a,cs),d),e) => Switch(a,cs,d,e)
        }
      case "CallLib" => ("lib" -> rhsOperand & "symbol" -> string & "env" -> list(rhsOperand)) ^ {
        case ((l,s),e) => CallLib(l,s,e)
        }
      case "LoadLib" => ("path" -> rhsOperand) ^ LoadLib.apply
      case "Debug" => ("msg" -> string & "traced" -> list(rhsOperand)) ^ Debug.apply
      case other => fail(s"Unknown instruction ${other}")
    }) ^ (_._2)
  )
  def block = obj("label" -> label & "params" -> list(lhsOperand) & "instructions" -> list(instruction) & "export_as" -> list(string)) ^ {
    case (((l,ps),is), export_as) => Block(l,ps.asInstanceOf[LhsOpList[Nothing,Id]], is, export_as)
  }
  def program = obj("blocks" -> list(block)) ^ Program.apply

  override def apply(f: Source)(using E: ErrorReporter): Program[Flags, V, V, V] = parse(program, f)
}
