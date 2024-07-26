package rpyeffectasm.main
import java.io.File
import scala.sys.process.*
import rpyeffectasm.util.{Phase, ErrorReporter, Output, FileTarget, Emit}

object Runner extends Phase[Output, Output] {

  private val jitPath = "../rpyeffect-jit/out/bin/arm64-Darwin/rpyeffect-jit" // FIXME hardcoded for now

  def runForOutput(file: File, args: List[String] = Nil): String = {
    Process(List(jitPath, file.getPath) ++ args).!!
  }

  def runForLazyOutput(file: File, args: List[String] = Nil): LazyList[String] = {
    Process(List(jitPath, file.getPath) ++ args).lazyLines
  }

  def run(file: File, args: List[String] = Nil): Unit = {
    Process(List(jitPath, file.getPath) ++ args).!<
  }

  override def apply(f: Output)(using ErrorReporter): Output = new Output {
    import rpyeffectasm.util.Target
    override def emitTo[T](t: Target[T]): T = {
      t.collecting{
        val tmp = java.nio.file.Files.createTempFile("", ".rpyeffect")
        f.emitTo(FileTarget(tmp.toAbsolutePath.toString))
        runForLazyOutput(tmp.toFile).foreach{ l => Emit.emit(l ++ "\n") }
      }
    }
  }

}
