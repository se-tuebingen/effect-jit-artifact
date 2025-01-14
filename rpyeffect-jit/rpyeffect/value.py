from rpyeffect.util.debug import debug_hooks
from rpython.rlib import objectmodel
from rpython.rlib.jit import unroll_safe

class Value(object):
    _attrs_ = []
    _immutable_fields_ = []

class IntValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

class DoubleValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

class BoolValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

class StringValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

class BytearrayValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

class InstreamValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

class InstreamValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

class OutstreamValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

class ArrayValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

class ValueNull(Value): pass

@objectmodel.always_inline
@unroll_safe
def equal(a, b):
    if isinstance(a, IntValue) and isinstance(b, IntValue):
        return a.value == b.value
    elif isinstance(a, DoubleValue) and isinstance(b, DoubleValue):
        return a.value == b.value
    elif isinstance(a, BoolValue) and isinstance(b, BoolValue):
        return a.value == b.value
    elif isinstance(a, StringValue) and isinstance(b, StringValue):
        return a.value == b.value
    else:
        return a == b