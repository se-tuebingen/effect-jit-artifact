from rpython.rlib.rpath import rabspath, rnormpath
import os
from rpython.rlib.jit import elidable

rnormpath = elidable(rnormpath)

def abspath(filename):
    # type: (str) -> str
    if filename is None:
        return None
    return rnormpath(rabspath(filename)) # TODO remove abspath

def dirname(filename):
    # type: (str) -> str
    if filename is None:
        return None
    return rnormpath(filename + "/..") # FIXME