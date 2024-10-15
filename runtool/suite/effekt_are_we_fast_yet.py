from dataclasses import dataclass
import os
from runtool.language import Language
from runtool.suite import BenchmarkSuite, Benchmark

@dataclass
class EffektAreWeFastYet(BenchmarkSuite):
    name: str = "effekt-are-we-fast-yet"
    def get_benchmark_path(self, lang: Language, benchmark: "Benchmark") -> str:
        return f"./effekt_are_we_fast_yet/{benchmark.name}.{lang.extension}"

    @staticmethod
    def all():
        for bm in os.listdir(f"./effekt_are_we_fast_yet"):
            if bm.endswith(".effekt") and bm != "runner.effekt":
                name = bm[:-7]
                yield Benchmark(name, [], None, EffektAreWeFastYet())
