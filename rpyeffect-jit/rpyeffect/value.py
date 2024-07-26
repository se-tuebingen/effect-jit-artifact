from rpyeffect.util.debug import debug_hooks
from rpython.rlib import objectmodel
from rpython.rlib.jit import unroll_safe

ORD_LT = -1
ORD_EQ = 0
ORD_GT = 1

class Value(object):
    _attrs_ = []
    _immutable_fields_ = []

    def equals(self, other):
        return self == other
    def compare(self, other):
        return default_compare(self, other)
    def show(self):
        return "<%s>" % self.__class__.__name__

def default_compare(this, other):
    if this.equals(other):
        return ORD_EQ
    # First order by class name to make heterogenous comparisons okish
    elif this.__class__.__name__ < other.__class__.__name__:
        return ORD_LT
    elif this.__class__.__name__ > other.__class__.__name__:
        return ORD_GT
    else:
        return -2 # TODO
    

class ValueNull(Value): pass

class UnboxableValue(Value):
    _attrs_ = []
    _immutable_fields_ = []
    def make_unboxed_ref(self):
        return UnboxedRef()

class UnboxedRef(Value):
    _attrs_ = []
    _immutable_fields_ = []
    def get_boxed_contents(self):
        return ValueNull()
    def try_set_from(self, value):
        return False

def unbox_in_ref(cls):
    """
    Create the reference class and add an implementation of
    make_unboxed_ref.
    """
    def _init(self, value):
        self.value = value.value
    def _get_boxed_contents(self):
        return cls(self.value)
    def _try_set_from(self, value):
        if isinstance(value, cls):
            self.value = value.value
            return True
        else:
            return False
    ref_cls = type(cls)("Unboxed%sRef" % cls.__name__, (UnboxedRef,), {
        "__init__": _init,
        "get_boxed_contents": _get_boxed_contents,
        "try_set_from": _try_set_from
    })
    def _make_unboxed_ref(self):
        return ref_cls(self)
    setattr(cls, "make_unboxed_ref", _make_unboxed_ref)
    return cls

@unbox_in_ref
class IntValue(UnboxableValue):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

    @objectmodel.always_inline
    @unroll_safe
    def equals(self, other):
        if isinstance(other, IntValue):
            return self.value == other.value
        else:
            return False
    @objectmodel.always_inline
    @unroll_safe
    def compare(self, other):
        if not isinstance(other, IntValue):
            return default_compare(self, other)
        if self.value == other.value:
            return ORD_EQ
        elif self.value < other.value:
            return ORD_LT
        else:
            return ORD_GT

    def show(self):
        return "%d" % self.value

@unbox_in_ref
class DoubleValue(UnboxableValue):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

    @objectmodel.always_inline
    @unroll_safe
    def equals(self, other):
        if isinstance(other, DoubleValue):
            return self.value == other.value
        else:
            return False
    @objectmodel.always_inline
    @unroll_safe
    def compare(self, other):
        if not isinstance(other, DoubleValue):
            return default_compare(self, other)
        if self.value == other.value:
            return ORD_EQ
        elif self.value < other.value:
            return ORD_LT
        else:
            return ORD_GT

    def show(self):
        return "%f" % self.value

@unbox_in_ref
class BoolValue(UnboxableValue):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

    @objectmodel.always_inline
    @unroll_safe
    def equals(self, other):
        if isinstance(other, BoolValue):
            return self.value == other.value
        else:
            return False
    @objectmodel.always_inline
    @unroll_safe
    def compare(self, other):
        if not isinstance(other, BoolValue):
            return default_compare(self, other)
        if self.value == other.value:
            return ORD_EQ
        elif self.value < other.value:
            return ORD_LT
        else:
            return ORD_GT

    def show(self):
        if self.value:
            return "true"
        else:
            return "false"

def escape_string(str):
    return str # TODO

class StringValue(Value):
    _immutable_fields_ = ['value']
    def __init__(self, value):
        self.value = value

    @objectmodel.always_inline
    @unroll_safe
    def equals(self, other):
        if isinstance(other, StringValue):
            return self.value == other.value
        else:
            return False
    @objectmodel.always_inline
    @unroll_safe
    def compare(self, other):
        if not isinstance(other, StringValue):
            return default_compare(self, other)
        if self.value == other.value:
            return ORD_EQ
        elif self.value < other.value:
            return ORD_LT
        else:
            return ORD_GT

    def show(self):
        return "\"%s\"" % escape_string(self.value)

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