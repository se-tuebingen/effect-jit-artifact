from rpython.rlib.jit import we_are_jitted, promote
from rpython.rlib import objectmodel

@objectmodel.always_inline
def assert_big_enough(len_lst):
    if we_are_jitted():
        l = promote(len_lst)-1
        assert(l < len_lst)