from dataclasses import dataclass
import re
import os
from runtool.language import Language
from runtool.suite import BenchmarkSuite, Benchmark

@dataclass
class HandlerBenchmark(BenchmarkSuite):
    name: str = "effect-handlers-bench"
    def get_benchmark_path(self, lang: Language, benchmark: "Benchmark") -> str:
        if lang.name.startswith("old"):
            return f"./effect-handlers-bench-upstream/benchmarks/{lang.lang_name[3:]}/{benchmark.name}/{'M' if lang.main_uppercase else 'm'}ain.{lang.extension}"
        else:
            return f"./effect-handlers-bench/benchmarks/{lang.lang_name}/{benchmark.name}/{'M' if lang.main_uppercase else 'm'}ain.{lang.extension}"

    @staticmethod
    def all():
        for bm in os.listdir("./effect-handlers-bench/descriptions"):
            if bm != "template":
                with open(f"./effect-handlers-bench/descriptions/{bm}/README.md") as f:
                    last = f.readline()
                    while last != "### Large\n":
                        last = f.readline()
                    while not re.match(r"^Input:\s*.*", last):
                        last = f.readline()
                    i = last.split(":")[1].strip()
                    while not re.match(r"^Output:\s*.*", last):
                        last = f.readline()
                    o = last.split(":")[1].strip()
                    yield Benchmark(bm, [i], [o], HandlerBenchmark())