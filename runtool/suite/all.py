import re
import os
import sys
from runtool.suite import Benchmark, BenchmarkFile
from runtool.util import store_logdict

from runtool.suite.handler_bench import HandlerBenchmark
from runtool.suite.my_benchmarks import MyBenchmarks
from runtool.suite.koka_bench import KokaBench
from runtool.suite.are_we_fast_yet import AreWeFastYet

suites = [
    HandlerBenchmark,
    MyBenchmarks,
    KokaBench,
    AreWeFastYet
]

benchmarks = [
    *HandlerBenchmark.all(),
    *AreWeFastYet.all(),
    *MyBenchmarks.all(), #*[bm for bm in MyBenchmarks.all() if bm.name in ["multiple_handlers", "to_outermost_handler", "unused_handlers", "startup", "running_example"]],
    # Benchmark("countdown", ["200000000"], ["0"], HandlerBenchmark()),
    # Benchmark("fibonacci_recursive", ["42"], ["267914296"], HandlerBenchmark()),
    # Benchmark("generator", ["25"], ["67108837"], HandlerBenchmark()),
    # Benchmark("handler_sieve", ["60000"], ["171848738"], HandlerBenchmark()),
    # Benchmark("iterator", ["40000000"], ["800000020000000"], HandlerBenchmark()),
    # Benchmark("nqueens", ["12"], ["14200"], HandlerBenchmark()),
    # Benchmark("parsing_dollars", ["20000"], ["200010000"], HandlerBenchmark()),
    # Benchmark("product_early", ["100000"], ["0"], HandlerBenchmark()),
    # Benchmark("resume_nontail", ["10000"], ["860"], HandlerBenchmark()),
    # Benchmark("tree_explore", ["16"], ["1005"], HandlerBenchmark()),
    # Benchmark("triples", ["300"], ["460212934"], HandlerBenchmark()),
    Benchmark("counter", [], ["100100100"], KokaBench())
]


def getbenchmark(bm: str) -> Benchmark:
    options = [b for b in benchmarks if bm == b.name]
    if len(options) >= 1:
        return options[0]
    elif os.path.exists(bm):
        return Benchmark(bm, [], [], bm)
    elif ":" in bm and os.path.exists(bm.split(":")[1]):
        return Benchmark(bm.split(":")[0], [], [], BenchmarkFile(bm.split(":")[1]))
    else:
        print(f"Unknown benchmark: {bm}")
        store_logdict()
        sys.exit(2)

def getbenchmarks(bms: str) -> set[Benchmark]:
    _bms = bms.split(",")
    res = set()
    for bm in _bms:
        if bm in ["*", "all", "a"]:
            for b in benchmarks:
                res.add(b)
        elif bm.startswith("/"):
            for b in benchmarks:
                if re.match(bm[1:], b.name):
                    res.add(b)
        elif bm.startswith("suite:"):
            for suite in suites:
                if suite.name == bm[len("suite:"):]:
                    for b in suite.all():
                        res.add(b)
        elif bm[0] == "-":
            res.remove(getbenchmark(bm[1:]))
        elif bm[0] == "+":
            res.remove(getbenchmark(bm[1:]))
        else:
            res.add(getbenchmark(bm))
    return res
