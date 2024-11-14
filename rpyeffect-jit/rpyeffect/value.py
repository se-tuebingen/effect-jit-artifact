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