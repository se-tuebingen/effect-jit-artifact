from dataclasses import dataclass
import os
from runtool.language import Language
from runtool.suite import BenchmarkSuite, Benchmark

@dataclass
class MyBenchmarks(BenchmarkSuite):
    name: str = "my_benchmarks"
    def get_benchmark_path(self, lang: Language, bm: Benchmark) -> str:
        return f"./my_benchmarks/{bm.name}/main.{lang.extension}"
    
    @staticmethod
    def all():
        for bm in os.listdir("./my_benchmarks"):
            i, o = [], []
            if os.path.exists(f"./my_benchmarks/{bm}/input"):
                with open(f"./my_benchmarks/{bm}/input") as f:
                    i = [l.strip() for l in f.readlines()]
            if os.path.exists(f"./my_benchmarks/{bm}/output"):
                with open(f"./my_benchmarks/{bm}/output") as f:
                    o = f.readlines()
            yield Benchmark(bm, i, o, MyBenchmarks())