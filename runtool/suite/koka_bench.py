from dataclasses import dataclass
import os
from runtool.language import Language
from runtool.suite import BenchmarkSuite, Benchmark

@dataclass
class KokaBench(BenchmarkSuite):
    name: str = "koka-bench"
    def get_benchmark_path(self, lang: Language, benchmark: "Benchmark") -> str:
        return f"./koka/test/bench/{lang.lang_name}/{benchmark.name}.{lang.extension}"

    @staticmethod
    def all():
        for bm in os.listdir(f"./koka/test/bench/koka/"):
            if bm.endswith(".kk"):
                name = bm[:-3]
            yield Benchmark(name, [], None, KokaBench())
