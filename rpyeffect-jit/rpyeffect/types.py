NUMBER_OF_TYPES = 1
OPAQUE_PTR, = range(NUMBER_OF_TYPES)
NUMBER = OPAQUE_PTR

def type_repr(ty):
    if ty == OPAQUE_PTR: return "any"
    else: return "!ERR!"