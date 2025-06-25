from rpython.rlib.jit import unroll_safe
from rpython.rlib import objectmodel
from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib.longlong2float import longlong2float, float2longlong
import sys
from rpython.tool.sourcetools import func_with_new_name
from rpyeffect.value import *

_representations = {}
_update_generated_accessors = lambda tpe_name, repr: ()
def representation(tpe_name, reg_tpe, encode=lambda x: x, decode=lambda x: x):
    """
    Register the representation for type tpe_name in a register of type reg_tpe.

    Returns encode, decode.
    """
    _encode = unroll_safe(objectmodel.always_inline((encode)))
    _decode = unroll_safe(objectmodel.always_inline((decode)))
    repr = (reg_tpe, _encode, _decode)
    _representations[tpe_name] = repr
    _update_generated_accessors(tpe_name, repr)
    return _encode, _decode

def erased_representation(tpe_name):
    """
    Shorthand for generating a new_erasing_pair(tpe_name) and calling representation with it.
    """
    _erase, _unerase = new_erasing_pair(tpe_name)
    return representation(tpe_name, "ptr", encode=_erase, decode=_unerase)

def boxed_representation(tpe_name, reg_tpe, box_cls, box_field="value"):
    """Representation is given by bosing a tpe_name into a box_cls, unboxing by accessing box_field"""
    def box(v):
        return box_cls(v) # TODO convince RPython that this will never throw
    def unbox(v):
        assert isinstance(v, box_cls)
        return getattr(v, box_field)
        
    return representation(tpe_name, reg_tpe, encode=box, decode=unbox)

def subtpe_representation(tpe_name, reg_tpe, cls):
    """Representation is given by tpe_name being the subtype cls of reg_tpe. Inserts assertions at encode/decode"""
    def _annot_cls(v):
        assert isinstance(v, cls)
        return v
    return representation(tpe_name, reg_tpe, encode=_annot_cls, decode=_annot_cls)

def _generate_representation_accessor(target, tpe_name, repr, read_only):
        reg_tpe, _encode, _decode = repr
        @unroll_safe
        @objectmodel.always_inline
        def _get(self, idx):
            return _decode(getattr(self, "get_" + reg_tpe)(idx))

        #@unroll_safe
        #@objectmodel.always_inline     # TODO
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
    global _update_generated_accessors
    caller = sys._getframe(1)
    target = caller.f_locals
    name = caller.f_globals.get("__name__")

    for tpe_name, repr in _representations.items():
        _generate_representation_accessor(target, tpe_name, repr, read_only)
       
    # Note down, that we have to add representations introduced later to this target, too 
    _old_update_generated_accessors = _update_generated_accessors
    def _new_update_generated_accessors(tpe_name, repr):
        _generate_representation_accessor(target, tpe_name, repr, read_only)
        _old_update_generated_accessors(tpe_name, repr)
    _update_generated_accessors = _new_update_generated_accessors
    


## Representations of data types
representation("num", "ptr")
encode_int, decode_int = boxed_representation("int", "num", IntValue)
encode_double, decode_double = boxed_representation("double", "num", DoubleValue)
encode_bool, decode_bool = boxed_representation("bool", "num", BoolValue)

encode_str, decode_str = boxed_representation("str", "ptr", StringValue)
boxed_representation("bytearray", "ptr", BytearrayValue)
from rpyeffect.util.interned import InternedString
encode_interned, decode_interned = subtpe_representation("interned", "ptr", InternedString)

# representations of "extern" types
boxed_representation("instream", "ptr", InstreamValue)
boxed_representation("outstream", "ptr", OutstreamValue)
boxed_representation("array", "ptr", ArrayValue)

# erased null
#erase_none, unerase_none = new_erasing_pair("NoneType")
# DEPRECATED
eNone = ValueNull() # erase_none(None)