from runtool.language import Language
import runtool.config as cfg

class AdjustedJitBackend(Language):
    def __init__(self, adjusted_backend: Language, adjustment: str):
        self.inner = adjusted_backend
        self.adjustment = adjustment
        self.lang_name = self.inner.lang_name
        self.backend = f"{self.inner.backend}-{adjustment}"
        self.name = f"{self.inner.name}-{adjustment}"
        self.extension = self.inner.extension
        self.main_uppercase = self.inner.main_uppercase

    def compile(self, path: str, name: str):
        adjusted_jit_path = f"{cfg.jit_path}-{self.adjustment}"
        return self.inner.compile(path, name, jit_path = adjusted_jit_path)

adjustments = [
    "2-context",
    # "debug",
    "no-addcej",
    "no-addcej-no-context",
    "no-context",
    "no-opt",
    "no-specialization"
]

def with_adjusted_jit_backends(l: Language) -> list[Language]:
    res = [l]
    for adjustment in adjustments:
        res.append(AdjustedJitBackend(l, adjustment))
    return res