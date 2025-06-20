import sys
import re
from runtool.util import store_logdict


from runtool.language import Language
from runtool.language.effekt import EffektBackend
from runtool.language.eff import EffBackend
from runtool.language.oldeff import OldEffBackend
from runtool.language.koka import KokaBackend
from runtool.language.js import JSBackend
from runtool.language.python import PythonBackend
from runtool.language.lua import LuaBackend
from runtool.language.ocaml5 import Ocaml5Backend

from runtool.language.adjusted_jit import with_adjusted_jit_backends

langs: list[Language] = [
    *with_adjusted_jit_backends(EffektBackend("jit")),
    EffektBackend("llvm"), EffektBackend("js"), EffektBackend("ml"),
    EffBackend("plain-ocaml"),
    OldEffBackend("plain-ocaml"),
    *with_adjusted_jit_backends(EffBackend("jit")),
    KokaBackend("js"), KokaBackend("c"),
    *with_adjusted_jit_backends(KokaBackend("vm")),
    JSBackend("v8"), JSBackend("spider"),
    Ocaml5Backend(),
    PythonBackend("cpython"), PythonBackend("pypy"),
    LuaBackend("lua"), LuaBackend("luajit")
]

def getlang(lang: str) -> Language:
    options = [l for l in langs if lang == l.name]
    if len(options) >= 1:
        return options[0]
    else:
        print(f"Unknown lang: {lang}")
        print([l.name for l in langs])
        store_logdict()
        sys.exit(2)
def getlangs(ls: str) -> set[Language]:
    _langs = ls.split(",")
    res = set()
    for l in _langs:
        if l in ["*", "all", "a"]:
            for lang in langs:
                res.add(lang)
        elif l.startswith("/"):
            for lang in langs:
                if re.match(l[1:], lang.name):
                    res.add(lang)
        elif l[0] == "-":
            res.remove(getlang(l[1:]))
        elif l[0] == "+":
            res.add(getlang(l[1:]))
        else:
            res.add(getlang(l))
    return res

