from rpython.jit.metainterp.test.support import LLJitMixin
import pytest

from rpyeffect.interpreter import interpret
from rpyeffect.parse import load_program
from rpyeffect.primitives import Primitives

class TestJIT(LLJitMixin):
    def test_push_return(self):
        def run():
            primitives = Primitives()
            p = load_program("test/push_return", 0, primitives)
            interpret(p, ["10"], primitives)
        self.meta_interp(run, [], listops=True)
        self.check_simple_loop({'guard_not_invalidated': 1, 'guard_false': 1, 'int_add': 1, 'int_is_zero': 1, 'jump': 1})