from runtool.language import Language
from runtool.language.effekt import EffektBackend
from runtool.language.eff import EffBackend
from runtool.language.helium import HeliumBackend
from runtool.language.koka import KokaBackend

langs: list[Language] = [
    EffektBackend("jit"), EffektBackend("llvm"), EffektBackend("js"), EffektBackend("ml"),
    EffBackend("plain-ocaml"), EffBackend("jit"),
    HeliumBackend("rpyeffect"),
    KokaBackend("js"), KokaBackend("vm"), KokaBackend("c"),
]