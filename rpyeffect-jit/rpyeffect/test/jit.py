from rpython import conftest
from rpyeffect.primitives import Primitives

class o:
    view = False
    viewloops = True
conftest.option = o

from rpython.rlib.nonconst import NonConstant
from rpython.jit.metainterp.test.test_ajit import LLJitMixin

import pytest

from rpyeffect.interpreter import interpret
from rpyeffect.parse import load_program

class TestLLtype(LLJitMixin):
    def test_loop(self):
        def f(x):
            if x == 1:
                p1 = load_program("test/shift_resume")
                interpret(p1, [100000], Primitives())
            elif x == 2:
                p2 = load_program("test/loop")
                interpret(p2, [100], Primitives())
            else:
                p = load_program("test/fib")
                interpret(p, [100], Primitives())
        #f(0)
        self.meta_interp(f, [1], listops=True)
