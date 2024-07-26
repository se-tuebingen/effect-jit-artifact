from dataclasses import dataclass
import os
from runtool.language import Language
from runtool.suite import BenchmarkSuite, Benchmark

def translate_lang_names_for_smarr_are_we_fast_yet(lang_name):
    match lang_name:
        case "python": return "Python"
        case "lua": return "Lua"
        case "js": return "JavaScript"
        case _: return lang_name


@dataclass
class AreWeFastYet(BenchmarkSuite):
    inputs_and_outputs = {
        "bounce": (10000, 1331),
        "queens": (10000, True),
        "list_tail": (10000, 10),
        "mandelbrot": (500, 191),
        "nbody": (250000, "%f" % -0.1690859889909308),
        "permute": (10000, 8660),
        "sieve": (10000, 669),
        "storage": (2000, 5461),
        "towers": (10000, 8191),
    }
    name: str = "are-we-fast-yet"

    def get_benchmark_path(self, lang: Language, benchmark: "Benchmark") -> str:
        if lang.lang_name == "effekt":
            return f"./effekt_are_we_fast_yet/{benchmark.name}.{lang.extension}"
        else:
            lname = translate_lang_names_for_smarr_are_we_fast_yet(lang.lang_name)
            bname = benchmark.name
            if bname == "list_tail":
                bname = "list" # Renamed to prevent clash with Effekt stdlib
            file = f"./smarr_are_we_fast_yet/benchmarks/{lname}/{bname}.run.{lang.extension}"
            return file

    @staticmethod
    def all():
        for name, io in AreWeFastYet.inputs_and_outputs.items():
            i, o = io
            yield Benchmark(name, [f"{i}"], [f"{o}"], AreWeFastYet())
