package rpyeffectasm
import java.io.File

import sbt.io._
import sbt.io.syntax._
import rpyeffectasm.util.ErrorReporter

import scala.language.implicitConversions

@munit.IgnoreSuite // Runner is broken rn.
class GoldenTests extends munit.FunSuite {
  def executeRpyeffect(file: File, args: List[String]): String = {
    import rpyeffectasm.main.Runner
    Runner.runForOutput(file, args)
  }
  val testDir: File = File("./tests")

  val dependencies: Map[File, List[File]] = Map(
    testDir / "handwritten" / "libtest_main.asm" -> List(
      testDir / "handwritten" / "libtest_lib.asm"
    ),
    testDir / "handwritten" / "mcore_libtest_main.mcore.sexp" -> List(
      testDir / "handwritten" / "mcore_libtest_lib.mcore.sexp"
    )
  )

  val ignored: List[File] = List(
    testDir / "effekt" / "failtooption.mcore.json",
  ) ++ dependencies.values.flatten.toList

  def runTestsIn(dir: File): Unit = {
    def normName(f: File) = f.getName.stripSuffix(".json").stripSuffix(".sexp").stripSuffix(".mcore").stripSuffix(".asm")

    dir.listFiles.foreach {
      case f if f.isDirectory && !ignored.contains(f) =>
        runTestsIn(f)
      case f if f.getName.endsWith(".asm") || f.getName.endsWith(".asm.json")
             || f.getName.endsWith(".mcore.json") || f.getName.endsWith(".mcore.sexp") =>
        val path = f.getParentFile
        val baseName = normName(f)

        val checkfile = path / (baseName + ".check")
        val argfile = path / (baseName + ".args")

        if (f.getPath.contains("/.debugout/")) {
          ()
        } else if (ignored.contains(f)) {
          test(f.getName.ignore) {
            ()
          }
        } else {
          if (!checkfile.exists()) {
            test(s"${path}/${baseName}"){ fail(s"Missing checkfile ${checkfile}") }
          } else {

            val args = if (argfile.exists()) {
              IO.readLines(argfile)
            } else Nil

            val deps = dependencies.getOrElse(f, Nil)

            val contents = IO.read(checkfile)
            val outFile = (File("./out") / (baseName + ".exe"))
            val config = rpyeffectasm.main.IncompleteConfig(
              input = f.getPath,
              output = Some(outFile.getPath)
            ).complete
            val depconfigs = deps.map { d => rpyeffectasm.main.IncompleteConfig(
              input = d.getPath,
              output = Some((File("./out") / (normName(d) + ".lib")).getPath)
            ).complete}
            def docompile(c: rpyeffectasm.main.Config) = {
              val plan = rpyeffectasm.plan(c)
              ErrorReporter.catchExitOutside{ ErrorReporter.withErrorsToStderr { (E: ErrorReporter) ?=>
                plan(c.input).emitTo(c.output)
              }}.getOrElse {
                fail(s"Compilation terminated with errors")
              }
            }

            test(s"${path}/${baseName}") {
              depconfigs.foreach(docompile)
              docompile(config)

              val got = executeRpyeffect(outFile, args)
              assertNoDiff(got, contents)
            }
          }
        }

      case _ => ()
    }
  }

  runTestsIn(testDir)
}
