from rpython.rlib.jit import unroll_safe
from rpython.rlib import objectmodel
from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib.longlong2float import longlong2float, float2longlong
import sys
from rpython.tool.sourcetools import func_with_new_name

_representations = {}
def representation(tpe_name, reg_tpe, encode=lambda x: x, decode=lambda x: x):
    """
    Register the representation for type tpe_name in a register of type reg_tpe.

    Returns encode, decode.
    """
    _encode = unroll_safe(objectmodel.always_inline((encode)))
    _decode = unroll_safe(objectmodel.always_inline((decode)))
    _representations[tpe_name] = (reg_tpe, _encode, _decode)
    return _encode, _decode

def erased_representation(tpe_name):
    """
    Shorthand for generating a new_erasing_pair(tpe_name) and calling representation with it.
    """
    _erase, _unerase = new_erasing_pair(tpe_name)
    return representation(tpe_name, "ptr", encode=_erase, decode=_unerase)

def _generate_representation_accessor(target, tpe_name, repr, read_only):
        reg_tpe, _encode, _decode = repr
        @unroll_safe
        @objectmodel.always_inline
        def _get(self, idx):
            return _decode(getattr(self, "get_" + reg_tpe)(idx))

        @unroll_safe
        @objectmodel.always_inline
        def _set(self, idx, val):
            getattr(self, "set_" + reg_tpe)(idx, _encode(val))

        target["get_" + tpe_name] = func_with_new_name(_get, "get_" + tpe_name)
        if not read_only:
            target["set_" + tpe_name] = func_with_new_name(_set, "get_" + tpe_name)

def generate_representation_accessors(read_only = False):
    """
    For each registered represented type T, generate get_T and set_T (unless read_only=True).

    Uses get_R and set_R for the given reg_tpe to get the original value.

    To be called on the toplevel of the class.
    """
    caller = sys._getframe(1)
    target = caller.f_locals
    name = caller.f_globals.get("__name__")

    for tpe_name, repr in _representations.items():
        _generate_representation_accessor(target, tpe_name, repr, read_only)


## Representations of data types
representation("int", "num")
encode_double, decode_double = representation("double", "num", 
    encode=float2longlong, 
    decode=longlong2float)
representation("bool", "num", 
    encode=lambda b: 1 if b else 0, 
    decode=lambda n: n != 0)

encode_str, decode_str = erased_representation("str")
erased_representation("data")
erased_representation("cont")
erased_representation("codata")
erased_representation("ref")
erased_representation("box")
erased_representation("region")
erased_representation("bytearray")
erased_representation("label")
encode_interned, decode_interned = erased_representation("interned")

# representations of "extern" types
erased_representation("instream")
erased_representation("outstream")
erased_representation("lib")
erased_representation("array")

# erased null
erase_none, unerase_none = new_erasing_pair("NoneType")
eNone = erase_none(None)