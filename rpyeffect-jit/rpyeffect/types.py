NUMBER_OF_TYPES = 2
NUMBER, OPAQUE_PTR = range(NUMBER_OF_TYPES)

def type_repr(ty):
    if ty == NUMBER: return "num"
    elif ty == OPAQUE_PTR: return "ptr"
    else: return "!ERR!"