package rpyeffectasm.common
import rpyeffectasm.util.ErrorReporter
import scala.io.Source
import scala.collection.mutable

object Primitives {

  import rpyeffectasm.common.Purity.Pure

  trait PrimitiveException extends Exception
  case class PrimitiveInfo(name: String, insT: List[Type], outsT: List[Type], purity: Purity = Purity.Pure)
  val primitives: List[PrimitiveInfo] = List(
    PrimitiveInfo("nop(): Unit", Nil, List(Base.Unit)),
    PrimitiveInfo("println(Int): Unit", List(Base.Int), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("println(Boolean): Unit", List(Base.Int), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("println(Unit): Unit", List(Base.Unit), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("println(String): Unit", List(Base.String), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("infixAdd(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixMul(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixDiv(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int), Purity.ErrorFlag),
    PrimitiveInfo("infixSub(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("mod(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int), Purity.ErrorFlag),
    PrimitiveInfo("abs(Int): Int", List(Base.Int), List(Base.Int)),
    PrimitiveInfo("infixEq(Int, Int): Boolean", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixNeq(Int, Int): Boolean", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixLt(Int, Int): Boolean", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixLte(Int, Int): Boolean", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixGt(Int, Int): Boolean", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixGte(Int, Int): Boolean", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("println(Double): Unit", List(Base.Double), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("infixAdd(Double, Double): Double", List(Base.Double, Base.Double), List(Base.Double)),
    PrimitiveInfo("infixMul(Double, Double): Double", List(Base.Double, Base.Double), List(Base.Double)),
    PrimitiveInfo("infixDiv(Double, Double): Double", List(Base.Double, Base.Double), List(Base.Double), Purity.ErrorFlag),
    PrimitiveInfo("infixSub(Double, Double): Double", List(Base.Double, Base.Double), List(Base.Double)),
    PrimitiveInfo("mod(Double, Double): Double", List(Base.Double, Base.Double), List(Base.Double), Purity.ErrorFlag),
    PrimitiveInfo("abs(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("infixEq(Double, Double): Boolean", List(Base.Double, Base.Double), List(Base.Int)),
    PrimitiveInfo("infixNeq(Double, Double): Boolean", List(Base.Double, Base.Double), List(Base.Int)),
    PrimitiveInfo("infixLt(Double, Double): Boolean", List(Base.Double, Base.Double), List(Base.Int)),
    PrimitiveInfo("infixLte(Double, Double): Boolean", List(Base.Double, Base.Double), List(Base.Int)),
    PrimitiveInfo("infixGt(Double, Double): Boolean", List(Base.Double, Base.Double), List(Base.Int)),
    PrimitiveInfo("infixGte(Double, Double): Boolean", List(Base.Double, Base.Double), List(Base.Int)),
    PrimitiveInfo("cos(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("acos(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("sin(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("asin(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("atan(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("tan(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("tanh(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("cosh(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("acosh(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("sinh(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("asinh(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("atanh(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("sqrt(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("log(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("log1p(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("exp(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("exp(Double, Double): Double", List(Base.Double, Base.Double), List(Base.Double)),
    PrimitiveInfo("log10(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("atan2(Double, Double): Double", List(Base.Double, Base.Double), List(Base.Double)),
    PrimitiveInfo("floor(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("ceil(Double): Double", List(Base.Double), List(Base.Double)),
    PrimitiveInfo("toInt(Double): Int", List(Base.Double), List(Base.Int)),
    PrimitiveInfo("toDouble(Int): Double", List(Base.Int), List(Base.Double)),
    PrimitiveInfo("not(Boolean): Boolean", List(Base.Int), List(Base.Int)),
    PrimitiveInfo("infixEq(Boolean, Boolean): Boolean", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixOr(Boolean, Boolean): Boolean", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixAnd(Boolean, Boolean): Boolean", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixConcat(String, String): String", List(Base.String, Base.String), List(Base.String)),
    PrimitiveInfo("infixEq(String, String): Boolean", List(Base.String, Base.String), List(Base.Int)),
    PrimitiveInfo("infixNeq(String, String): Boolean", List(Base.String, Base.String), List(Base.Int)),
    PrimitiveInfo("infixLt(String, String): Boolean", List(Base.String, Base.String), List(Base.Int)),
    PrimitiveInfo("infixLte(String, String): Boolean", List(Base.String, Base.String), List(Base.Int)),
    PrimitiveInfo("infixGt(String, String): Boolean", List(Base.String, Base.String), List(Base.Int)),
    PrimitiveInfo("infixGte(String, String): Boolean", List(Base.String, Base.String), List(Base.Int)),
    PrimitiveInfo("show(Int): String", List(Base.Int), List(Base.String)),
    PrimitiveInfo("show(Double): String", List(Base.Double), List(Base.String)),
    PrimitiveInfo("show(Boolean): String", List(Base.Int), List(Base.String)),
    PrimitiveInfo("read(String): Int", List(Base.String), List(Base.Int), Purity.ErrorFlag),
    PrimitiveInfo("read(String, Int): Int", List(Base.String, Base.Int), List(Base.Int), Purity.ErrorFlag),
    PrimitiveInfo("read(String): Double", List(Base.String), List(Base.Double), Purity.ErrorFlag),
    PrimitiveInfo("read(String): Boolean", List(Base.String), List(Base.Int), Purity.ErrorFlag),
    PrimitiveInfo("random(): Int", List(), List(Base.Int), Purity.Effectful),
    PrimitiveInfo("random(): Double", List(), List(Base.Double), Purity.Effectful),
    PrimitiveInfo("currentTimeNanos(): Int", List(), List(Base.Int), Purity.Effectful),
    PrimitiveInfo("readLn(): String", List(), List(Base.String), Purity.Effectful),
    PrimitiveInfo("readInt(): Int", List(), List(Base.Int), Purity.Effectful),
    PrimitiveInfo("exit(Int): Void", List(Base.Int), List(Bottom), Purity.Effectful),
    PrimitiveInfo("printlnErr(String): Unit", List(Base.String), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("get_argc(): Int", List(), List(Base.Int), Purity.Effectful), // Maybe not effectful for our purposes?
    PrimitiveInfo("get_arg(Int): String", List(Base.Int), List(Base.String), Purity.Effectful), // Maybe not effectful for our purposes?
    PrimitiveInfo("checkErrorFlag(): Boolean", List(), List(Base.Int), Purity.Effectful),
    PrimitiveInfo("clearErrorFlag(): Unit", List(), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("length(String): Int", List(Base.String), List(Base.Int)),
    PrimitiveInfo("substring(String, Int, Int): String", List(Base.String, Base.Int, Base.Int), List(Base.String)),
    PrimitiveInfo("unsafeCharAt(String, Int): String", List(Base.String, Base.Int), List(Base.String), Purity.ErrorFlag),
    PrimitiveInfo("bytes(String): Ptr", List(Base.String), List(Ptr)),
    PrimitiveInfo("bytes(String): Bytes", List(Base.String), List(ExternPtr("Bytes"))),
    PrimitiveInfo("length(Bytes): Int", List(ExternPtr("Bytes")), List(Base.Int)),
    PrimitiveInfo("length(Ptr): Int", List(Ptr), List(Base.Int)),
    PrimitiveInfo("unsafeIndex(Ptr, Int): Int", List(Ptr, Base.Int), List(Base.Int), Purity.ErrorFlag),
    PrimitiveInfo("unsafeIndex(Bytes, Int): Int", List(ExternPtr("Bytes"), Base.Int), List(Base.Int), Purity.ErrorFlag),
    PrimitiveInfo("unsafeGetFileContents(String): String", List(Base.String), List(Base.String), Purity.Effectful),
    PrimitiveInfo("panic(String): Bottom", List(Base.String), List(Bottom), Purity.Effectful),
    PrimitiveInfo("freshlabel", List(), List(Label(Top, None)), Purity.Effectful),
    PrimitiveInfo("equals(Any, Any): Bool", List(Top, Top), List(Base.Bool), Purity.Pure),
    PrimitiveInfo("infixLt(Any, Any): Bool", List(Top, Top), List(Base.Bool), Purity.Pure),
    PrimitiveInfo("infixGt(Any, Any): Bool", List(Top, Top), List(Base.Bool), Purity.Pure),
    PrimitiveInfo("infixLte(Any, Any): Bool", List(Top, Top), List(Base.Bool), Purity.Pure),
    PrimitiveInfo("infixGte(Any, Any): Bool", List(Top, Top), List(Base.Bool), Purity.Pure),
    PrimitiveInfo("show(Any): String", List(Top), List(Base.String), Purity.Pure),
    PrimitiveInfo("ptr_eq", List(Ptr, Ptr), List(Base.Int)),
    PrimitiveInfo("print(String): Unit", List(Base.String), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("non-exhaustive match", List(), List()), // not actually implemented, but used conventionally

    // For the helium prelude
    PrimitiveInfo("getStdin(): InStream", List(), List(ExternPtr("InStream")), Purity.Effectful),
    PrimitiveInfo("openIn(String): InStream", List(Base.String), List(ExternPtr("InStream")), Purity.Effectful),
    PrimitiveInfo("closeIn(InStream): Unit", List(ExternPtr("InStream")), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("read(InStream, Int): String", List(ExternPtr("InStream"), Base.Int), List(Base.String), Purity.Effectful),
    PrimitiveInfo("getStdout(): OutStream", List(), List(ExternPtr("OutStream")), Purity.Effectful),
    PrimitiveInfo("getStderr(): OutStream", List(), List(ExternPtr("OutStream")), Purity.Effectful),
    PrimitiveInfo("openOut(String): OutStream", List(Base.String), List(ExternPtr("OutStream")), Purity.Effectful),
    PrimitiveInfo("closeOut(OutStream): Unit", List(ExternPtr("OutStream")), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("write(OutStream, String): Unit", List(ExternPtr("OutStream"), Base.String), List(Base.Unit), Purity.Effectful),
    // For the helium stdlib
    PrimitiveInfo("assertFalse(String): Void", List(Base.String), List(Bottom), Purity.Effectful),
    PrimitiveInfo("readInt(InStream): Int", List(ExternPtr("InStream")), List(Base.Int), Purity.Effectful),
    PrimitiveInfo("readLine(InStream): String", List(ExternPtr("InStream")), List(Base.String), Purity.Effectful),
    PrimitiveInfo("charAt(Int, String): String", List(Base.Int, Base.String), List(Base.String), Purity.ErrorFlag),
    PrimitiveInfo("compare(String, String): Int", List(Base.String, Base.String), List(Base.Int)),
    PrimitiveInfo("repeat(Int, String): String", List(Base.Int, Base.String), List(Base.String)),
    PrimitiveInfo("charCode(String): Int", List(Base.String), List(Base.Int), Purity.ErrorFlag),
    PrimitiveInfo("chr(Int): String", List(Base.Int), List(Base.String), Purity.ErrorFlag),
    PrimitiveInfo("getArgs(): Array[String]", List(), List(ExternPtr("Array[String]")), Purity.Effectful),
    PrimitiveInfo("length(Array[Ptr]): Int", List(ExternPtr("Array[String]")), List(Base.Int), Purity.Effectful),
    PrimitiveInfo("unsafeIndex(Array[Ptr], Int): Ptr", List(ExternPtr("Array[Ptr]"), Base.Int), List(Ptr), Purity.Effectful),
    PrimitiveInfo("loadLibrary(String): Lib", List(Base.String), List(ExternPtr("Lib")), Purity.Effectful),
    PrimitiveInfo("getGlobal(String): Ptr", List(Base.String), List(Top), Purity.Effectful), // TODO for now
    PrimitiveInfo("getGlobal(String): Num", List(Base.String), List(Num), Purity.Effectful),
    PrimitiveInfo("setGlobal(String, Ptr): Unit", List(Base.String, Top), List(Base.Unit), Purity.Effectful), // TODO for now
    PrimitiveInfo("setGlobal(String, Num): Unit", List(Base.String, Num), List(Base.Unit), Purity.Effectful),

    PrimitiveInfo("mkRef(Ptr): Ref[Ptr]", List(Top), List(ExternPtr("Ref[Ptr]")), Purity.Effectful),
    PrimitiveInfo("mkRef(Num): Ref[Num]", List(Num), List(ExternPtr("Ref[Num]")), Purity.Effectful),
    PrimitiveInfo("getRef(Ref[Ptr]): Ptr", List(ExternPtr("Ref[Ptr]")), List(Top), Purity.Effectful),
    PrimitiveInfo("getRef(Ref[Num]): Num", List(ExternPtr("Ref[Num]")), List(Num), Purity.Effectful),
    PrimitiveInfo("setRef(Ref[Ptr], Ptr): Unit", List(ExternPtr("Ref[Ptr]"), Top), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("setRef(Ref[Num], Num): Unit", List(ExternPtr("Ref[Num]"), Num), List(Base.Unit), Purity.Effectful),
    PrimitiveInfo("divmod(Int, Int): Int, Int", List(Base.Int, Base.Int), List(Base.Int, Base.Int)),

    PrimitiveInfo("promote_ptr", List(Ptr), List(Ptr), Purity.Pure),
    PrimitiveInfo("promote_num", List(Num), List(Num), Purity.Pure),
    PrimitiveInfo("box(Num): Ptr", List(Num), List(Ptr), Purity.Pure),
    PrimitiveInfo("unbox(Ptr): Num", List(Ptr), List(Num), Purity.Pure),

    // TODO The following primitives are not implemented in the JIT yet.
    PrimitiveInfo("neg(Int): Int", List(Base.Int), List(Base.Int)),
    PrimitiveInfo("infixAnd(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixOr(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("xor(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("lsl(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("lsr(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("asr(Int, Int): Int", List(Base.Int, Base.Int), List(Base.Int)),
    PrimitiveInfo("infixNot(Int): Int", List(Base.Int), List(Base.Int)),
  )

  def getReturnType(name: String)(using ErrorReporter): Type = primitives.find(_.name == name).flatMap(_.outsT.headOption).orElse{
    if(name.startsWith("!undefined:")) { Some(Top) }
    else None
  }.getOrElse{
    ErrorReporter.fatal(s"Unknown primitive: ${name}")
  }

  trait PrimitiveContext { // factored out as interface to simplify testing
    val globals: mutable.HashMap[String, Value] = new mutable.HashMap[String, Value]()
    type InStream
    type OutStream
    var errorFlag: Boolean = false
    def cliArgs: List[String]
    def do_println(s: String): Unit = do_write(stdout, s ++ "\n")
    def do_printlnErr(s: String): Unit = do_write(stderr, s ++ "\n")
    def do_println(v: (Unit | Int | Double | Boolean)): Unit = do_println(v.toString)
    def do_random(): Int
    def do_randomDouble(): Double
    def do_currentTimeNanos(): Int
    def do_readLn(): String = do_readLn(stdin)
    def do_readLn(s: InStream): String
    def do_readInt(): Int = {
      try {
        do_readLn().toInt
      } catch {
        case _ =>
          errorFlag = true; 0
      }
    }
    def do_readInt(s: InStream): Int = {
      try {
        do_readLn(s).toInt
      } catch {
        case _ =>
          errorFlag = true; 0
      }
    }
    def do_exit(n: Int): Nothing
    def do_getFileContents(filename: String): String
    def do_panic(msg: String): Nothing
    def stdin: InStream
    def do_openIn(filename: String): InStream
    def stdout: OutStream
    def stderr: OutStream
    def do_openOut(filename: String): OutStream
    def do_closeIn(s: InStream): Unit
    def do_closeOut(s: OutStream): Unit
    def do_read(s: InStream, n: Int): String
    def do_write(s: OutStream, str: String): Unit
  }
  class ExecPrimitiveContext(var cliArgs: List[String]) extends PrimitiveContext {
    type InStream = java.io.InputStream
    type OutStream = java.io.PrintStream
    def do_random(): Int = scala.util.Random.nextInt()
    def do_randomDouble(): Double = scala.util.Random.nextDouble()
    def do_currentTimeNanos(): Int = (System.nanoTime() % Int.MaxValue).toInt
    def do_readLn(s: InStream): String = {
      val res = mutable.StringBuilder()
      var cur = s.read().toChar
      while(cur != '\n') {
        res.addOne(cur)
        cur = s.read().toChar
      }
      res.mkString
    }
    case class Exit(n: Int) extends PrimitiveException
    def do_exit(n: Int): Nothing = throw Exit(n)
    def do_getFileContents(filename: String): String = {
      val src = scala.io.Source.fromFile(filename)
      try {
        src.mkString
      } finally {
        src.close()
      }
    }
    def do_panic(msg: String): Nothing = {
      do_printlnErr(msg); do_exit(1)
    }
    def stdin: InStream = System.in
    override def do_openIn(filename: String): InStream = new java.io.FileInputStream(filename)
    def stdout: OutStream = System.out
    def stderr: OutStream = System.err
    def do_openOut(filename: String): OutStream = new java.io.PrintStream(filename)
    def do_closeIn(s: InStream): Unit = s.close()
    def do_closeOut(s: OutStream): Unit = s.close()
    def do_read(s: InStream, n: Int): String = s.readNBytes(n).map(_.toChar).mkString
    def do_write(s: OutStream, str: String): Unit = s.write(str.toCharArray.map(_.toByte))
  }
  given defaultPrimitiveContext: ExecPrimitiveContext = new ExecPrimitiveContext(Nil)

  def runSafe(name: String, args: List[Value])(using C: PrimitiveContext, E: ErrorReporter): List[Value] = {
    primitives.find { p => p.name == name } match {
      case Some(p) =>
        (args zip (p.insT)).foreach {
          case (v, t) => if (v.tpe != t) {
            ErrorReporter.error(s"Type mismatch at primitive ${name}: ${t} expected, but got ${v}.")
          }
        }
        try {
          run(name, args)
        } catch {
          case e: Any => ErrorReporter.fatal(s"Error while running primitive ${name}: ${e.getMessage}")
        }
      case None => ErrorReporter.fatal(s"Unknown primitive '${name}'")
    }
  }
  def run(name: String, args: List[Value])(using C: PrimitiveContext, E: ErrorReporter): List[Value] = name match {
    // FIXME: Most of those are generated by Copilot, so could be nicer
    case "nop(): Unit" => List(VBase.VUnit)
    case "println(Int): Unit" => C.do_println(args(0).asInstanceOf[VBase.VInt].value); List(VBase.VUnit)
    case "println(Boolean): Unit" => C.do_println(args(0).asInstanceOf[VBase.VInt].value == 1); List(VBase.VUnit)
    case "println(Unit): Unit" => C.do_println(()); List(VBase.VUnit)
    case "println(String): Unit" => C.do_println(args(0).asInstanceOf[VBase.VString].value); List(VBase.VUnit)
    case "infixAdd(Int, Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value + args(1).asInstanceOf[VBase.VInt].value))
    case "infixMul(Int, Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value * args(1).asInstanceOf[VBase.VInt].value))
    case "infixDiv(Int, Int): Int" =>
      val VBase.VInt(a) = args(0)
      val VBase.VInt(b) = args(1)
      List(VBase.VInt(if b == 0 then { C.errorFlag = true; 0 } else a / b))
    case "infixSub(Int, Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value - args(1).asInstanceOf[VBase.VInt].value))
    case "mod(Int, Int): Int" =>
      val VBase.VInt(a) = args(0)
      val VBase.VInt(b) = args(1)
      List(VBase.VInt(if b == 0 then { C.errorFlag = true; 0 } else a % b))
    case "abs(Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value.abs))
    case "infixEq(Int, Int): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value == args(1).asInstanceOf[VBase.VInt].value) 1 else 0))
    case "infixNeq(Int, Int): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value != args(1).asInstanceOf[VBase.VInt].value) 1 else 0))
    case "infixLt(Int, Int): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value < args(1).asInstanceOf[VBase.VInt].value) 1 else 0))
    case "infixLte(Int, Int): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value <= args(1).asInstanceOf[VBase.VInt].value) 1 else 0))
    case "infixGt(Int, Int): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value > args(1).asInstanceOf[VBase.VInt].value) 1 else 0))
    case "infixGte(Int, Int): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value >= args(1).asInstanceOf[VBase.VInt].value) 1 else 0))
    case "println(Double): Unit" => C.do_println(args(0).asInstanceOf[VBase.VDouble].value); List(VBase.VUnit)
    case "infixAdd(Double, Double): Double" => List(VBase.VDouble(args(0).asInstanceOf[VBase.VDouble].value + args(1).asInstanceOf[VBase.VDouble].value))
    case "infixMul(Double, Double): Double" => List(VBase.VDouble(args(0).asInstanceOf[VBase.VDouble].value * args(1).asInstanceOf[VBase.VDouble].value))
    case "infixDiv(Double, Double): Double" =>
      val VBase.VDouble(a) = args(0)
      val VBase.VDouble(b) = args(1)
      List(VBase.VDouble(if b == 0.0 then { C.errorFlag = true; 0.0 } else a / b))
    case "infixSub(Double, Double): Double" => List(VBase.VDouble(args(0).asInstanceOf[VBase.VDouble].value - args(1).asInstanceOf[VBase.VDouble].value))
    case "mod(Double, Double): Double" =>
      val VBase.VDouble(a) = args(0)
      val VBase.VDouble(b) = args(1)
      List(VBase.VDouble(if b == 0.0 then { C.errorFlag = true; 0.0 } else a - Math.floor(a / b) * b)) // TODO correct? (Consistent with RPyeffect?)
    case "abs(Double): Double" => List(VBase.VDouble(args(0).asInstanceOf[VBase.VDouble].value.abs))
    case "infixEq(Double, Double): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VDouble].value == args(1).asInstanceOf[VBase.VDouble].value) 1 else 0))
    case "infixNeq(Double, Double): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VDouble].value != args(1).asInstanceOf[VBase.VDouble].value) 1 else 0))
    case "infixLt(Double, Double): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VDouble].value < args(1).asInstanceOf[VBase.VDouble].value) 1 else 0))
    case "infixLte(Double, Double): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VDouble].value <= args(1).asInstanceOf[VBase.VDouble].value) 1 else 0))
    case "infixGt(Double, Double): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VDouble].value > args(1).asInstanceOf[VBase.VDouble].value) 1 else 0))
    case "infixGte(Double, Double): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VDouble].value >= args(1).asInstanceOf[VBase.VDouble].value) 1 else 0))
    case "cos(Double): Double" => List(VBase.VDouble(math.cos(args(0).asInstanceOf[VBase.VDouble].value)))
    case "acos(Double): Double" => List(VBase.VDouble(math.acos(args(0).asInstanceOf[VBase.VDouble].value)))
    case "sin(Double): Double" => List(VBase.VDouble(math.sin(args(0).asInstanceOf[VBase.VDouble].value)))
    case "asin(Double): Double" => List(VBase.VDouble(math.asin(args(0).asInstanceOf[VBase.VDouble].value)))
    case "atan(Double): Double" => List(VBase.VDouble(math.atan(args(0).asInstanceOf[VBase.VDouble].value)))
    case "tan(Double): Double" => List(VBase.VDouble(math.tan(args(0).asInstanceOf[VBase.VDouble].value)))
    case "cosh(Double): Double" => List(VBase.VDouble(math.cosh(args(0).asInstanceOf[VBase.VDouble].value)))
    case "tanh(Double): Double" => List(VBase.VDouble(math.tanh(args(0).asInstanceOf[VBase.VDouble].value)))
    case "acosh(Double): Double" => ??? // List(VBase.VDouble(math.acosh(args(0).asInstanceOf[VBase.VDouble].value)))
    case "sinh(Double): Double" => List(VBase.VDouble(math.sinh(args(0).asInstanceOf[VBase.VDouble].value)))
    case "asinh(Double): Double" => ??? // List(VBase.VDouble(math.asinh(args(0).asInstanceOf[VBase.VDouble].value)))
    case "atanh(Double): Double" => ??? // List(VBase.VDouble(math.atanh(args(0).asInstanceOf[VBase.VDouble].value)))
    case "sqrt(Double): Double" => List(VBase.VDouble(math.sqrt(args(0).asInstanceOf[VBase.VDouble].value)))
    case "log(Double): Double" => List(VBase.VDouble(math.log(args(0).asInstanceOf[VBase.VDouble].value)))
    case "log1p(Double): Double" => List(VBase.VDouble(math.log1p(args(0).asInstanceOf[VBase.VDouble].value)))
    case "exp(Double): Double" => List(VBase.VDouble(math.exp(args(0).asInstanceOf[VBase.VDouble].value)))
    case "exp(Double, Double): Double" => List(VBase.VDouble(math.pow(args(0).asInstanceOf[VBase.VDouble].value, args(1).asInstanceOf[VBase.VDouble].value)))
    case "log10(Double): Double" => List(VBase.VDouble(math.log10(args(0).asInstanceOf[VBase.VDouble].value)))
    case "atan2(Double, Double): Double" => List(VBase.VDouble(math.atan2(args(0).asInstanceOf[VBase.VDouble].value, args(1).asInstanceOf[VBase.VDouble].value)))
    case "floor(Double): Double" => List(VBase.VDouble(math.floor(args(0).asInstanceOf[VBase.VDouble].value)))
    case "ceil(Double): Double" => List(VBase.VDouble(math.ceil(args(0).asInstanceOf[VBase.VDouble].value)))
    case "toInt(Double): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VDouble].value.toInt))
    case "toDouble(Int): Double" => List(VBase.VDouble(args(0).asInstanceOf[VBase.VInt].value.toDouble))
    case "not(Boolean): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value == 0) 1 else 0))
    case "infixEq(Boolean, Boolean): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value == args(1).asInstanceOf[VBase.VInt].value) 1 else 0))
    case "infixOr(Boolean, Boolean): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value == 1 || args(1).asInstanceOf[VBase.VInt].value == 1) 1 else 0))
    case "infixAnd(Boolean, Boolean): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VInt].value == 1 && args(1).asInstanceOf[VBase.VInt].value == 1) 1 else 0))
    case "infixConcat(String, String): String" => List(VBase.VString(args(0).asInstanceOf[VBase.VString].value + args(1).asInstanceOf[VBase.VString].value))
    case "infixEq(String, String): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VString].value == args(1).asInstanceOf[VBase.VString].value) 1 else 0))
    case "infixNeq(String, String): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VString].value != args(1).asInstanceOf[VBase.VString].value) 1 else 0))
    case "infixGte(String, String): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VString].value >= args(1).asInstanceOf[VBase.VString].value) 1 else 0))
    case "infixGt(String, String): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VString].value > args(1).asInstanceOf[VBase.VString].value) 1 else 0))
    case "infixLte(String, String): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VString].value <= args(1).asInstanceOf[VBase.VString].value) 1 else 0))
    case "infixLt(String, String): Boolean" => List(VBase.VInt(if (args(0).asInstanceOf[VBase.VString].value < args(1).asInstanceOf[VBase.VString].value) 1 else 0))
    case "show(Int): String" => List(VBase.VString(args(0).asInstanceOf[VBase.VInt].value.toString))
    case "show(Double): String" => List(VBase.VString(args(0).asInstanceOf[VBase.VDouble].value.toString))
    case "show(Boolean): String" => List(VBase.VString(if (args(0).asInstanceOf[VBase.VInt].value == 1) "true" else "false"))
    case "read(String): Int" =>
      val VBase.VString(str) = args(0)
      try {
        List(VBase.VInt(str.toInt))
      } catch {
        case _: NumberFormatException => C.errorFlag = true; List(VBase.VInt(0))
      }
    case "read(String): Double" =>
      val VBase.VString(str) = args(0)
      try {
        List(VBase.VDouble(str.toDouble))
      } catch {
        case _: NumberFormatException => C.errorFlag = true; List(VBase.VInt(0))
      }
    case "read(String): Boolean" =>
      val VBase.VString(str) = args(0)
      try {
        List(VBase.VInt(if str.toBoolean then 1 else 0))
      } catch {
        case _: NumberFormatException => C.errorFlag = true; List(VBase.VInt(0))
      }
    case "random(): Int" => List(VBase.VInt(C.do_random()))
    case "random(): Double" => List(VBase.VDouble(C.do_randomDouble()))
    case "currentTimeNanos(): Int" => List(VBase.VInt(C.do_currentTimeNanos()))
    case "readLn(): String" => List(VBase.VString(C.do_readLn()))
    case "readInt(): Int" => List(VBase.VInt(C.do_readInt()))
    case "exit(Int): Void" => C.do_exit(args(0).asInstanceOf[VBase.VInt].value); List()
    case "printlnErr(String): Unit" => C.do_printlnErr(args(0).asInstanceOf[VBase.VString].value); List(VBase.VUnit)
    case "get_argc(): Int" => List(VBase.VInt(C.cliArgs.length))
    case "get_arg(Int): String" => List(VBase.VString(C.cliArgs(args(0).asInstanceOf[VBase.VInt].value)))
    case "checkErrorFlag(): Boolean" => List(VBase.VInt(if (C.errorFlag) 1 else 0))
    case "clearErrorFlag(): Unit" => C.errorFlag = false; List(VBase.VUnit)
    case "length(String): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VString].value.length))
    case "substring(String, Int, Int): String" => List(VBase.VString(args(0).asInstanceOf[VBase.VString].value.substring(args(1).asInstanceOf[VBase.VInt].value, args(2).asInstanceOf[VBase.VInt].value)))
    case "unsafeCharAt(String, Int): String" =>
      val VBase.VString(str) = args(0)
      val VBase.VInt(i) = args(1)
      List(VBase.VString(args(0).asInstanceOf[VBase.VString].value.charAt(args(1).asInstanceOf[VBase.VInt].value).toString))
    case "bytes(String): Ptr" => List(VBase.VArray[Byte](args(0).asInstanceOf[VBase.VString].value.getBytes))
    case "bytes(String): Bytes" => List(VBase.VArray[Byte](args(0).asInstanceOf[VBase.VString].value.getBytes))
    case "length(Ptr): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VArray[?]].value.length))
    case "length(Bytes): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VArray[?]].value.length))
    case "unsafeIndex(Ptr, Int): Int" =>
      args(0) match { case VBase.VArray[Byte](bytes) =>
        val VBase.VInt(n) = args(1)
        if(bytes.length < n) then List (VBase.VInt(bytes(n))) else {
          C.errorFlag = true
          List(VBase.VInt(0))
        }
      }
    case "unsafeIndex(Bytes, Int): Int" =>
      args(0) match { case VBase.VArray[Byte](bytes) =>
      val VBase.VInt(n) = args(1)
      if(bytes.length < n) then List (VBase.VInt(bytes(n))) else {
      C.errorFlag = true
      List(VBase.VInt(0))
      }
      }
    case "unsafeGetFileContents(String): String" =>
      val filename = args(0).asInstanceOf[VBase.VString].value
      List(VBase.VString(C.do_getFileContents(filename)))
    case "panic(String): Bottom" => C.do_panic(args(0).asInstanceOf[VBase.VString].value)
    case "freshlabel" => List(new Concrete.VLabel())
    case "ptr_eq" => List(VBase.VInt(if args(0) == args(1) then 1 else 0))
    case "non-exhaustive match" => ErrorReporter.fatal("Non-exhaustive match")
    case "getStdin(): InStream" => List(VExternPtr[C.InStream](C.stdin, "InStream"))
    case "openIn(String): InStream" => List(VExternPtr[C.InStream](C.do_openIn(args(0).asInstanceOf[VBase.VString].value), "InStream"))
    case "closeIn(InStream): Unit" => C.do_closeIn(args(0).asInstanceOf[VExternPtr[C.InStream]].value); List(VBase.VUnit)
    case "read(InStream, Int): String" => List(VBase.VString(C.do_read(args(0).asInstanceOf[VExternPtr[C.InStream]].value, args(1).asInstanceOf[VBase.VInt].value)))
    case "getStdout(): OutStream" => List(VExternPtr[C.OutStream](C.stdout, "OutStream"))
    case "getStderr(): OutStream" => List(VExternPtr[C.OutStream](C.stderr, "OutStream"))
    case "openOut(String): OutStream" => List(VExternPtr[C.OutStream](C.do_openOut(args(0).asInstanceOf[VBase.VString].value), "OutStream"))
    case "closeOut(OutStream): Unit" => C.do_closeOut(args(0).asInstanceOf[VExternPtr[C.OutStream]].value); List(VBase.VUnit)
    case "write(OutStream, String): Unit" => C.do_write(args(0).asInstanceOf[VExternPtr[C.OutStream]].value, args(1).asInstanceOf[VBase.VString].value); List(VBase.VUnit)
    case "assertFalse(String): Void" => ErrorReporter.fatal("assertFalse: ${args(0).asInstanceOf[VBase.VString].value}")
    case "readInt(InStream): Int" =>
      val s = args(0).asInstanceOf[VExternPtr[C.InStream]].value
      try {
        List(VBase.VInt(C.do_readInt(s)))
      } catch {
        case _: NumberFormatException => C.errorFlag = true; List(VBase.VInt(0))
      }
    case "readLine(InStream): String" =>
      val s = args(0).asInstanceOf[VExternPtr[C.InStream]].value
      try {
        List(VBase.VString(C.do_readLn(s)))
      } catch {
        case _: NoSuchElementException => C.errorFlag = true; List(VBase.VString(""))
      }
    case "charAt(Int, String): String" =>
      val VBase.VInt(i) = args(0)
      val VBase.VString(str) = args(1)
      if(i < 0 || i >= str.length) then {
        C.errorFlag = true
        List(VBase.VString(""))
      } else {
        List(VBase.VString(str.charAt(i).toString))
      }
    case "compare(String, String): Int" =>
      val VBase.VString(a) = args(0)
      val VBase.VString(b) = args(1)
      List(VBase.VInt(a.compareTo(b)))
    case "repeat(Int, String): String" =>
      val VBase.VInt(n) = args(0)
      val VBase.VString(str) = args(1)
      List(VBase.VString(str * n))
    case "charCode(String): Int" =>
      val VBase.VString(str) = args(0)
      if(str.length == 1) then List(VBase.VInt(str.charAt(0).toInt)) else {
        C.errorFlag = true
        List(VBase.VInt(0))
      }
    case "chr(Int): String" =>
      val VBase.VInt(n) = args(0)
      if(n >= 0 && n < 256) then List(VBase.VString(n.toChar.toString)) else {
        C.errorFlag = true
        List(VBase.VString(""))
      }
    case "getArgs(): Array[String]" => List(VExternPtr(C.cliArgs))
    case "neg(Int): Int" => List(VBase.VInt(-args(0).asInstanceOf[VBase.VInt].value))
    case "infixAnd(Int, Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value & args(1).asInstanceOf[VBase.VInt].value))
    case "infixOr(Int, Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value | args(1).asInstanceOf[VBase.VInt].value))
    case "xor(Int, Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value ^ args(1).asInstanceOf[VBase.VInt].value))
    case "lsl(Int, Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value << args(1).asInstanceOf[VBase.VInt].value))
    case "lsr(Int, Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value >>> args(1).asInstanceOf[VBase.VInt].value))
    case "asr(Int, Int): Int" => List(VBase.VInt(args(0).asInstanceOf[VBase.VInt].value >> args(1).asInstanceOf[VBase.VInt].value))
    case "infixNot(Int): Int" => List(VBase.VInt(~args(0).asInstanceOf[VBase.VInt].value))
    case "getGlobal(String): Ptr" => List(C.globals.getOrElse(args(0).asInstanceOf[VBase.VString].value, VBase.VUnit))
    case "getGlobal(String): Num" => List(C.globals.getOrElse(args(0).asInstanceOf[VBase.VString].value, VBase.VInt(0)))
    case "box(Num): Ptr" => List(Concrete.VBox(args(0)))
    case "unbox(Ptr): Num" => List(args(0).asInstanceOf[Concrete.VBox].num)
    case "setGlobal(String, Ptr): Unit" =>
      C.globals.put(args(0).asInstanceOf[VBase.VString].value, args(1))
      List()
    case "setGlobal(String, Num): Unit" =>
      C.globals.put(args(0).asInstanceOf[VBase.VString].value, args(1))
      List()
    case "mkRef(Ptr): Ref[Ptr]" =>
      List(new Concrete.VRef(args(0)))
    //case n if primitives.exists{ p => p.name == name } => ??? // not implemented intentionally
    case _ => ErrorReporter.fatal(s"Unknown primitive '${name}''")
  }
}
