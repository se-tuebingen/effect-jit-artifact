from rpython.rlib.jit import purefunction, elidable, hint, unroll_safe, promote, promote_string, we_are_jitted
from rpython.rlib import objectmodel
from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib.longlong2float import longlong2float, float2longlong
from rpyeffect.types import *
from rpyeffect.data import *
from rpyeffect.codata import *
from rpyeffect.stack import *
from rpyeffect.region import *
from rpyeffect.representations import generate_representation_accessors, eNone
from rpyeffect.util.generic import generic
from rpyeffect.util.annotations import assert_big_enough
import rpyeffect.config as cfg
from rpyeffect.util.debug import debug_hooks
from rpyeffect.value import IntValue

# Environments
class Environment:
    _virtualizable_ = ['values_ptr[*]']
    @unroll_safe
    def __init__(self, program):
        self = hint(self, access_directly = True, fresh_virtualizable=True)
        self.values_ptr = [eNone] * program.frame_size[OPAQUE_PTR]
    @objectmodel.always_inline
    def get_ptr(self, name):
        name = promote(name)
        debug_hooks.get_ptr(name)
        if name >= 0:
            return self.values_ptr[name]
        else:
            return eNone
    @objectmodel.always_inline
    def set_ptr(self, name, value):
        name = promote(name)
        debug_hooks.set_ptr(name, value)
        if name >= 0:
            self.values_ptr[name] = value

    @objectmodel.always_inline
    def len_ptr(self):
        return len(self.values_ptr)

    generate_representation_accessors()

    @objectmodel.always_inline
    def copy(self, program):
        res = Environment(program)
        for i in range(len(self.values_ptr)):
            res.values_ptr[i] = self.values_ptr[i]
        return res

    @generic(["stored", "stack", "codata"]) # TODO can use objectmodel.specialize.argtype(...) instead?
    @unroll_safe
    @objectmodel.always_inline
    def setfrom(self, stored, parameter_index_start, program):
        assert_big_enough(stored.len_ptr())
        i0 = promote(parameter_index_start[OPAQUE_PTR])
        assert(i0 >= 0)
        for i in range(min(stored.len_ptr(), len(self.values_ptr) - i0)):
            self.values_ptr[i0+i] = stored.get_ptr(i)

    def __repr__(self):
        return ("{\"ptr\": %s}"
                % (self.values_ptr))