from dataclasses import dataclass
from abc import ABC, abstractmethod
import os
from runtool.util import log
from runtool.language import Language

def get_benchmark_path(lang: Language, benchmark: "Benchmark"):
    return benchmark.suite.get_benchmark_path(lang, benchmark)

class BenchmarkSuite(ABC):
    name: str
    @abstractmethod
    def get_benchmark_path(self, lang: Language, bm: "Benchmark") -> str: ...

@dataclass
class Benchmark:
    name: str
    inputs: list[str]
    expected: list[str]
    suite: BenchmarkSuite
    
    def __hash__(self):
        return hash(self.name)

@dataclass
class BenchmarkFile(BenchmarkSuite):
    path: str
    def get_benchmark_path(self, lang: Language, bm: Benchmark) -> str:
        return self.path

def docompile(lang: Language, benchmark: Benchmark) -> list[str] | None:
    print(f"COMPILING {benchmark.name} for {lang.name}")
    path = get_benchmark_path(lang, benchmark)
    if not os.path.exists(path):
        log(benchmark.name, lang.name, "benchmark", "not found")
        return None
    runcmd = lang.compile(path, f"{lang.name}:{benchmark.name}")
    if runcmd is None:
        print("ERROR.")
        log(benchmark.name, lang.name, "compile", "failed")
        return None
    print(f"DONE.")
    if not os.path.exists("./.runcmds"): os.mkdir("./.runcmds")
    with open(f"./.runcmds/{lang.name}:{benchmark.name}.sh", "w") as f:
        f.write("#!/bin/sh\n")
        addjusted_cmd = [f"'{p}'" for p in runcmd]
        f.write(" ".join(addjusted_cmd) + ' "$@"')
    return runcmd

def getcmd(lang: Language, benchmark: Benchmark) -> list[str] | None:
    if os.path.exists(f"./.runcmds/{lang.name}:{benchmark.name}.sh"):
        with open(f"./.runcmds/{lang.name}:{benchmark.name}.sh") as f:
            assert(f.readline().startswith("#!")) # shebang
            cmd = f.readline().split("' '")
            cmd[0] = cmd[0][1:] # leading '
            assert(cmd[-1].endswith("\' \"$@\""))
            cmd[-1] = cmd[-1][:cmd[-1].index("'")]
            return cmd
    else:
        return docompile(lang, benchmark)