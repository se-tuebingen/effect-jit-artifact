package rpyeffectasm.mcore.sugar
import rpyeffectasm.mcore.*
import rpyeffectasm.common.Purity
import rpyeffectasm.util.ErrorReporter

// TODO s-exp parser, prettyprinter
trait SomeHandlerSugar {
  type Prompt
  type OpTag

  enum HandlerType {
    case Shallow, Deep
  }

  def opMessageType: Type
  def constructOpMessage(tag: Prompt, op: OpTag, args: List[Term[ATerm]]): Term[ATerm]
  def matchOpMessage(scr: Term[ATerm], tag: Prompt, thn: List[(OpTag, Clause[ATerm])], els: Term[ATerm]): Term[ATerm]

  private val continuationType = Ptr
  private val returnTag = new Generated("return")
  private val opTag = new Generated("op")
  private val messageTypeTag = new Generated("message")
  private val resumeMethod = Name("resume")
  private def continuationTypeTag = new Generated("continuation")
  private def ignore = Var(new Generated("ignore"), Top)

  def lbl(tag: Prompt): Term[ATerm] = Literal.Label
  val fail = Clause(Nil, Primitive("panic(String): Bottom",
                List(Literal.String("FATAL: Handler received malformed message.")), Nil,
                Literal.Unit))

  case class Handle(tpe: HandlerType, tag: Prompt, handlers: List[(OpTag, Clause[ATerm])], ret: Option[Clause[ATerm]], body: Term[ATerm]) extends Sugar {
    def returnType(using ErrorReporter) = Top // ret.map{ c => Type.of(c.body) }.getOrElse{ Type.of(body) }
    override def desugared(using ErrorReporter): Term[ATerm] = {
      import rpyeffectasm.mcore.Clause
      val retTpe = Top //Type.of(body)
      val messageType = Data(messageTypeTag, List(
        Constructor(returnTag, List(retTpe)),
        Constructor(opTag, List(opMessageType, continuationType))))
      val msg = Var(new Generated("message"), messageType)
      val handle = Var(new Generated("handle"), Function(List(messageType), Top /*returnType*/, Purity.Effectful))
      val retVal = Var(new Generated("result"), retTpe)
      val opMsg = Var(new Generated("op_message"), opMessageType)
      val cont = Var(new Generated("cont"), continuationType)
      val kk = Var(new Generated("kk"), Ptr)
      val karg = Var(new Generated("karg"), Top) // TODO compute correct type
      val hret = Var(new Generated("handler_return"), returnType)

      val rkk = New(continuationTypeTag,
        List((resumeMethod, Clause(List(karg),
            Resumed(kk,
              App(handle, List(
                Invoke(cont, continuationTypeTag, resumeMethod, List(
                  karg)))))))))
      val rethrow = Shift(lbl(tag), Literal.Int(0), kk, Construct(messageTypeTag, opTag, List(opMsg, rkk)), Ptr)
      val tHandlers = handlers.map { case (t, Clause(params, body)) =>
        val resumeArg = new Generated("rarg")
        val resumeTpe = params.head.tpe match {
          case Function(params, ret, purity) => ret
          case t => ErrorReporter.fatal(s"Resume parameter must be annotated with Function type, not ${t}.")
        }
        (t, Clause(params.drop(1),
          Let(List(Definition(params.head,
            Abs(List(Var(resumeArg, resumeTpe)),
              // FIXME also handle and reset here!
              App(handle, List(Invoke(cont, continuationTypeTag, resumeMethod, List(Var(resumeArg, Top)))))), Nil)),
            Let(List(Definition(hret, body, Nil)), hret))))
      }
      val handleDef = Definition(handle, Abs(List(msg), Match(msg, messageTypeTag, List(
        (opTag, Clause(List(opMsg, cont), matchOpMessage(opMsg, tag, tHandlers, rethrow))),
        (returnTag, ret.getOrElse{ Clause(List(retVal), retVal) })
      ), fail)), Nil)
      val returnMsg = Construct(messageTypeTag, returnTag, List(retVal))
      val bodyRet = Var(new Generated("body return"), retTpe)
      LetRec(List(handleDef),
        App(handle, List(Reset(lbl(tag), ignore, None, Let(List(Definition(bodyRet, body, Nil)), bodyRet), Clause(List(retVal), returnMsg)))))
    }
  }
  case class Op(tag: Prompt, op: OpTag, args: List[Term[ATerm]], k: Clause[ATerm], rtpe: Type) extends Sugar {
    override def desugared(using ErrorReporter): Term[ATerm] = {
      assert(k.params.length == 1)
      val kk = Var(new Generated("kk"), Stack(rtpe, k.params.map(_.tpe)))
      val tKk = New(continuationTypeTag, List((resumeMethod, Clause(k.params.map{
        case Var(name, tpe) => Var(name, Top)
      }, Resume(kk, k.params)))))
      def tK(a: Term[ATerm]) = Let(List(Definition(k.params.head, Shift(lbl(tag), Literal.Int(0), kk, a, rtpe), Nil)), k.body)
      val opMsg = constructOpMessage(tag, op, args)
      val msg = Construct(messageTypeTag, opTag, List(opMsg, tKk))
      tK(msg)
    }
  }
}
object HandlerSugar extends SomeHandlerSugar {
  override final type Prompt = Id
  override final type OpTag = Id

  val opMessageTypeTag = new Generated("op_message")
  val argsTypeTag = new Generated("args")
  override def opMessageType = Ptr

  override def constructOpMessage(tag: Id, op: Id, args: List[Term[ATerm]]): Term[ATerm] =
    Construct(opMessageTypeTag, tag, List(Construct(argsTypeTag, op, args)))

  override def matchOpMessage(scr: Term[ATerm], tag: Id, thn: List[(Id, Clause[ATerm])], els: Term[ATerm]): Term[ATerm] = {
    val argsV = Var(new Generated("args"), Ptr)
    Match(scr, opMessageTypeTag, List(
      (tag, Clause(List(argsV), Match(argsV, argsTypeTag, thn, fail)))),
      Clause(Nil, els))
  }

}
object DynamicHandlerSugar extends SomeHandlerSugar {
  override final type Prompt = Term[ATerm]
  override final type OpTag = Id

  override def opMessageType: Type = Ptr
  val opMessageTypeTag = new Generated("dyn_op_message")
  val argsTypeTag = new Generated("dyn_args")

  override def constructOpMessage(tag: Term[ATerm], op: Id, args: List[Term[ATerm]]): Term[ATerm] =
    Construct(opMessageTypeTag, Index(0), List(tag, Construct(argsTypeTag, op, args)))

  override def matchOpMessage(scr: Term[ATerm], tag: Term[ATerm], thn: List[(Id, Clause[ATerm])], els: Term[ATerm]): Term[ATerm] = {
    val argsV = Var(new Generated("args"), Ptr)
    val tagV = Var(new Generated("tag"), Ptr)
    val isThisTag = Var(new Generated("is_this_tag"), Base.Int)
    Match(scr, opMessageTypeTag, List(
      (Index(0), Clause(List(tagV, argsV),
        Primitive("ptr_eq", List(tagV, tag), List(isThisTag),
          IfZero(isThisTag, els, Match(argsV, argsTypeTag, thn, fail)))))),
      fail)
  }
}


