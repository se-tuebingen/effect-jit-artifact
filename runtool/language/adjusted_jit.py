from runtool.language import Language
from runtool.config import Config

class AdjustedJitBackend(Language):
    def __init__(self, adjusted_backend: Language, adjustment: str):
        self.inner = adjusted_backend
        self.adjustment = adjustment
        self.lang_name = self.inner.lang_name
        self.backend = f"{self.inner.backend}-{adjustment}"
        self.name = f"{self.inner.name}-{adjustment}"
        self.extension = self.inner.extension
        self.main_uppercase = self.inner.main_uppercase

    def compile(self, path: str, name: str, jit_path: str = Config.jit_path):
        adjusted_jit_path = f"{jit_path}-{self.adjustment}"
        cmd = self.inner.compile(path, name.replace(f"-{self.adjustment}", ""), jit_path = jit_path)
        if cmd is None: return None
        assert cmd[0] == jit_path
        return [adjusted_jit_path, *cmd[1:]]

adjustments = [
    "no-addcej",
    "no-labelbydefsite",
    "no-specialization",
    "no-context",
    "2-context",
    "no-opt"
    # "debug", # not built rn.
    # "no-addcej-no-context", # not built rn.
    # "no-labelbydefsite"
]

def with_adjusted_jit_backends(l: Language) -> list[Language]:
    res = [l]
    for adjustment in adjustments:
        res.append(AdjustedJitBackend(l, adjustment))
    return res

def adjustment_index(l: Language) -> int:
    if isinstance(l, AdjustedJitBackend):
        return adjustments.index(l.adjustment)
    else:
        return -1