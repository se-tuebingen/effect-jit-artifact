from rpyeffect.instructions import *
from rpyeffect.program import *
from rpyeffect.types import *
from rpyeffect.representations import encode_str, encode_double, encode_interned, encode_bool
from rpyeffect.codata import VTable, CoData
from rpyeffect.symbol import Symbol
from rpyeffect.util.debug import debug
import rpyeffect.config as cfg
from rpython.rlib.objectmodel import always_inline
from rpyeffect.value import *

def file_chars(filename, buffer_size = 128):
    """
    Generator iterating over the characters in a file
    """
    with open(filename, 'r') as f:
        cs = "START"
        while cs != "":
            cs = f.read()#f.read(buffer_size)
            for c in cs:
                yield c

class Token:
    """Superclass for JSON tokens"""
    pass
class StringToken(Token):
    def __init__(self, value):
        self.value = value
    def __repr__(self):
        return "String(%s)" % self.value
class IntToken(Token):
    def __init__(self, value):
        self.value = value
    def __repr__(self):
        return "Int(%d)" % self.value
class DoubleToken(Token):
    def __init__(self, value):
        self.value = value
    def __repr__(self):
        return "Double(%d)" % self.value
class BoolToken(Token):
    def __init__(self, value):
        self.value = value
    def __repr__(self):
        return "Bool(%d)" % self.value
class OpToken(Token):
    def __init__(self, op):
        self.op = op
    def __repr__(self):
        return "Op(%s)" % self.op
BRACE_OPEN = OpToken('{')
BRACE_CLOSE = OpToken('}')
BRACKET_OPEN = OpToken('[')
BRACKET_CLOSE = OpToken(']')
COLON = OpToken(':')
COMMA = OpToken(',')
EOF = OpToken('')

def nextk(char_gen, k):
    r = ""
    for i in range(k):
        r += char_gen.next()
    return r

def tokens(char_gen):
    """
    Generator iterating over the tokens in a character generator
    """
    S_START, S_INT, S_STR, S_STR_ESC, S_DOUBLE_FRAC, S_DOUBLE_EXP_START, S_DOUBLE_EXP, S_COMMENT, S_SKIP_ID = range(9)
    state = S_START
    token = ""
    for c in char_gen:
        if state == S_INT:
            if c.isdigit():
                token += c
                continue
            elif c=='.':
                token += c
                state = S_DOUBLE_FRAC
                continue
            elif c=='e' or c=='E':
                token += c
                state = S_DOUBLE_EXP_START
                continue
            else:
                yield IntToken(int(token))
                state = S_START
        elif state == S_DOUBLE_FRAC:
            if c.isdigit():
                token += c
                continue
            elif c == 'e'  or c=='E':
                token += c
                state = S_DOUBLE_EXP_START
                continue
            else:
                yield DoubleToken(float(token))
                state = S_START
        elif state == S_DOUBLE_EXP_START:
            if c.isdigit() or c=='+' or c=='-':
                token += c
                state = S_DOUBLE_EXP
                continue
            else:
                raise ParseError("Tokenization error: Float ended in e")
        elif state == S_DOUBLE_EXP:
            if c.isdigit():
                token += c
                continue
            else:
                yield DoubleToken(float(token))
                state = S_START
        elif state == S_SKIP_ID:
            if c >= 'a' and c <= 'z':
                continue
            else:
                state = S_START
        # intentionally fall through here because a new token might start here after a number
        if state == S_START:
            if c == '"':
                token = ""
                state = S_STR
            elif c == '{': yield BRACE_OPEN
            elif c == '}': yield BRACE_CLOSE
            elif c == '[': yield BRACKET_OPEN
            elif c == ']': yield BRACKET_CLOSE
            elif c == ',': yield COMMA
            elif c == ':': yield COLON
            elif c == 't':
                yield BoolToken(True)
                state=S_SKIP_ID
            elif c == 'f':
                yield BoolToken(False)
                state=S_SKIP_ID
            elif c.isdigit() or c == '-':
                token=c
                state=S_INT
            elif c.isspace():
                continue
            elif c == '#':
                state=S_COMMENT
            else:
                raise ParseError("Tokenization error on '%s'" % c)
        elif state == S_STR:
            if c == '"':
                yield StringToken(token)
                state = S_START
            elif c == '\\':
                state = S_STR_ESC
            else:
                token += c
        elif state == S_STR_ESC:
            if c == 'n': token += '\n'
            elif c == 'r': token += '\r'
            elif c == 't': token += '\t'
            elif c == 'v': token += '\v'
            elif c == 'x':
                token += chr(int(nextk(char_gen, 2), 16))
            elif c == '0' or c == '1' or c == '2' or c == '3' or c == '4' or c == '5' or c == '6' or c == '7':
                token += chr(int(c + nextk(char_gen, 2), 8))
            # TODO: More escape sequences?
            else: token +=c
            state = S_STR
        elif state == S_COMMENT:
            if c == '\n':
                state = S_START
        else:
            p_assert(False)
    if state == S_INT:
        yield IntToken(int(token))
    elif state == S_DOUBLE_FRAC or state == S_DOUBLE_EXP:
        yield DoubleToken(float(token))
    elif state == S_STR:
        raise ParseError("String is not terminated")
    yield EOF

class ParseError(Exception):
    _immutable_fields_ = ['msg']
    def __init__(self, msg):
        self.msg = msg

@always_inline
def p_assert(cond, msg = ""):
    if not cond:
        raise ParseError(msg)

def load_program(filename, relocate_by, primitives):
    """
    Load a program from a file
    """
    try:
        basename = filename.split('/')[-1]
        return parse_program(tokens(file_chars(filename)), basename + ":", relocate_by, primitives)
    except ParseError as e:
        debug("Loading %s failed with parse error: %s" % (filename, e.msg))
        return None

# Helper functions
def expect(token, tokens):
    tok = tokens.next()
    p_assert(tok == token, "Expected %s, got %s" % (token, tok))
def expect_type(ty, tokens):
    p_assert(isinstance(tokens.next(), ty))

def parse_int(tokens):
    tok = tokens.next()
    p_assert (isinstance(tok, IntToken))
    assert (isinstance(tok, IntToken))
    return tok.value

def parse_bool(tokens):
    tok = tokens.next()
    p_assert (isinstance(tok, BoolToken))
    assert (isinstance(tok, BoolToken))
    return tok.value

def parse_double(tokens):
    tok = tokens.next()
    p_assert(isinstance(tok, DoubleToken))
    assert (isinstance(tok, DoubleToken))
    return tok.value

def parse_string(tokens):
    tok = tokens.next()
    p_assert(isinstance(tok, StringToken))
    assert (isinstance(tok, StringToken))
    return tok.value

def parse_interned(tokens, primitives):
    tok = tokens.next()
    str = ""
    if isinstance(tok, IntToken):
        str = "#%d" % tok.value
    elif isinstance(tok, StringToken):
        str = tok.value
    else:
        p_assert(False, "Expected tag (string or int), got %s" % tok)
    return primitives.intern(str)

def skip_value(tokens):
    """
    Skip the next (possibly malformed) JSON value
    """
    token = tokens.next()
    if isinstance(token, StringToken) or isinstance(token, IntToken) or isinstance(token, DoubleToken):
        return
    elif token == BRACE_OPEN or token == BRACKET_OPEN:
        d = 1
        while d>0:
            token = tokens.next()
            if token == BRACE_OPEN or token == BRACKET_OPEN:
                d+=1
            elif token == BRACE_CLOSE or token == BRACKET_CLOSE:
                d-=1
        return
    else:
        raise ParseError("Expected JSON value")

def json_keys(tokens):
    """
    Generator over JSON keys in tokens.
    Expects objects to be "read out" at yield
    """
    token = tokens.next()
    while token != BRACE_CLOSE:
        if token == COMMA:
            pass
        elif isinstance(token, StringToken):
            expect(COLON, tokens)
            yield token.value
        else:
            raise ParseError("Expected ',' or key string, got '%s'" % token)
        token = tokens.next()

def parse_symbol(tokens, relocate_by):
    pos = 0
    name = NAME_OF_ENTRYPOINT
    for key in json_keys(tokens):
        if key == "name":
            name = parse_string(tokens)
        elif key == "position":
            pos = parse_int(tokens) + relocate_by
        else:
            skip_value(tokens)
    return Symbol(name, pos)

def parse_symbols(tokens, relocate_by):
    expect(BRACKET_OPEN, tokens)
    symbols = {}
    token = tokens.next()
    while token != BRACKET_CLOSE:
        if token == COMMA:
            pass
        elif token == BRACE_OPEN:
            symbol = parse_symbol(tokens, relocate_by)
            symbols[symbol.name] = symbol
        else:
            raise ParseError("Expected symbol in symbol table")
        token = tokens.next()
    return symbols

def parse_program(tokens, name_prefix, relocate_by, primitives):
    expect(BRACE_OPEN, tokens)
    blocks = []
    frame_size = [8] * NUMBER_OF_TYPES
    symbols = DEFAULT_SYMBOLS
    for key in json_keys(tokens):
        if key == "blocks":
            blocks = parse_blocks(tokens, name_prefix, relocate_by, primitives)
        elif key == "frameSize":
            frame_size = parse_frame_descriptor(tokens)
        elif key == "symbols":
            symbols = parse_symbols(tokens, relocate_by)
        else:
            skip_value(tokens)
    return Program(blocks, frame_size, symbols)

def parse_blocks(tokens, name_prefix, relocate_by, primitives):
    expect(BRACKET_OPEN, tokens)
    blocks = []
    token = tokens.next()
    while token != BRACKET_CLOSE:
        if token == COMMA:
            pass
        elif token == BRACE_OPEN:
            blocks = blocks + [parse_block(tokens, name_prefix, relocate_by, primitives)]
        else:
            raise ParseError("Expected Block")
        token = tokens.next()
    return blocks

def parse_block(tokens, name_prefix, relocate_by, primitives):
    block_name = name_prefix
    block_instructions = []
    block_local_vars_sizes = [0] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == "label":
            block_name = name_prefix + parse_string(tokens)
        elif key == "instructions":
            block_instructions = parse_instructions(tokens, relocate_by, primitives)
        elif key == "frameDescriptor":
            block_local_vars_sizes = parse_frame_descriptor(tokens)
        else:
            skip_value(tokens)
    return Block(block_name, block_instructions,
                 block_local_vars_sizes)

def parse_frame_descriptor(tokens):
    expect(BRACE_OPEN, tokens)
    local_vars_sizes = [0] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key.startswith("regs_"):
            ty = -1
            for cty in range(NUMBER_OF_TYPES):
                if key[5:] == type_repr(cty):
                    ty = cty
                    break
            if ty >= 0:
                local_vars_sizes[ty] = parse_int(tokens)
                continue
        skip_value(tokens)
    return local_vars_sizes

def parse_instructions(tokens, relocate_by, primitives):
    expect(BRACKET_OPEN, tokens)
    instructions = []
    token = tokens.next()
    while token != BRACKET_CLOSE:
        if token == COMMA:
            pass
        elif token == BRACE_OPEN:
            instruction = parse_instruction(tokens, relocate_by, primitives)
            if instruction is not None:
                instructions = instructions + [instruction]
        else:
            raise ParseError("Expected Instruction")
        token = tokens.next()
    return instructions

def parse_instruction(tokens, relocate_by, primitives):
    p_assert("op" == parse_string(tokens))
    expect(COLON, tokens)
    op_name = parse_string(tokens)
    if op_name == "Const":
        return parse_CONST(tokens, primitives)
    elif op_name == "PrimOp":
        return parse_PRIM_OP(tokens)
    elif op_name == "Add":
        return parse_ADD(tokens)
    elif op_name == "Push":
        return parse_PUSH(tokens, relocate_by)
    elif op_name == "Return":
        return parse_RETURN(tokens)
    elif op_name == "Shift":
        return parse_SHIFT(tokens)
    elif op_name == "ShiftDyn":
        return parse_SHIFT_DYN(tokens)
    elif op_name == "GetDynamic":
        return parse_GET_DYNAMIC(tokens)
    elif op_name == "Control":
        return parse_CONTROL(tokens)
    elif op_name == "Jump":
        return parse_JUMP(tokens, relocate_by)
    elif op_name == "IfZero":
        return parse_IFZERO(tokens, relocate_by)
    elif op_name == "Copy":
        return parse_COPY(tokens)
    elif op_name == "Drop":
        return parse_DROP(tokens)
    elif op_name == "Swap":
        return parse_SWAP(tokens)
    elif op_name == "Construct":
        return parse_CONSTRUCT(tokens, primitives)
    elif op_name == "Match":
        return parse_MATCH(tokens, relocate_by, primitives)
    elif op_name == "Switch":
        return parse_SWITCH(tokens, relocate_by)
    elif op_name == "Proj":
        return parse_PROJ(tokens, primitives)
    elif op_name == "PushStack":
        return parse_PUSH_STACK(tokens)
    elif op_name == "NewStack":
        return parse_NEW_STACK(tokens, relocate_by)
    elif op_name == "NewStackWithBinding":
        return parse_NEW_STACK_WITH_BINDING(tokens, relocate_by)
    elif op_name == "New":
        return parse_NEW(tokens, relocate_by, primitives)
    elif op_name == "Invoke":
        return parse_INVOKE(tokens, primitives)
    elif op_name == "Allocate":
        return parse_ALLOCATE(tokens)
    elif op_name == "Load":
        return parse_LOAD(tokens)
    elif op_name == "Store":
        return parse_STORE(tokens)
    elif op_name == "CallLib":
        return parse_CALL_LIB(tokens)
    elif op_name == "LoadLib":
        return parse_LOAD_LIB(tokens)
    elif op_name == "Debug":
        p = parse_DEBUG(tokens)
        return p if cfg.debug else None
    else:
        raise ParseError("Unsupported operation %s" % op_name)

def parse_int_list(tokens):
    expect(BRACKET_OPEN, tokens)
    res = []
    token = tokens.next()
    while token != BRACKET_CLOSE:
        if isinstance(token, IntToken):
            res = res + [IntValue(token.value)]
        token = tokens.next()
    return res

def parse_lit_list(tokens):
    expect(BRACKET_OPEN, tokens)
    res = []
    token = tokens.next()
    while token != BRACKET_CLOSE:
        if isinstance(token, IntToken):
            res = res + [IntValue(token.value)]
        elif isinstance(token, BoolToken):
            res = res + [BoolValue(token.value)]
        token = tokens.next()
    return res

def parse_idx_list(tokens):
    expect(BRACKET_OPEN, tokens)
    res = []
    token = tokens.next()
    while token != BRACKET_CLOSE:
        if isinstance(token, IntToken):
            res = res + [token.value]
        token = tokens.next()
    return res

def parse_target_list(tokens, relocate_by):
    expect(BRACKET_OPEN, tokens)
    res = []
    token = tokens.next()
    while token != BRACKET_CLOSE:
        if isinstance(token, IntToken):
            res = res + [token.value + relocate_by]
        token = tokens.next()
    return res

def parse_interned_list(tokens, primitives):
    expect(BRACKET_OPEN, tokens)
    res = []
    token = tokens.next()
    while token != BRACKET_CLOSE:
        if isinstance(token, IntToken):
            res = res + [primitives.intern("#%d" % token.value)]
        elif isinstance(token, StringToken):
            res = res + [primitives.intern(token.value)]
        token = tokens.next()
    return res

def parse_register_list(tokens):
    expect(BRACE_OPEN, tokens)
    res = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == "any":
            res[OPAQUE_PTR] = parse_idx_list(tokens)
        elif key == "num" \
        or key == "ptr" \
        or key == 'double'\
        or key == 'string'\
        or key == "cont"\
        or key == 'codata'\
        or key == "adt"\
        or key == "ref"\
        or key == "region":
            print("WARNING: Old-style register list detected: %s" % key)
        else:
            skip_value(tokens)
    return res

def parse_clause(tokens, relocate_by, primitives, i):
    target = 0
    args = [[]] * NUMBER_OF_TYPES
    tag = primitives.intern("#%d" % i)
    for key in json_keys(tokens):
        if key == "target":
            target = parse_int(tokens) + relocate_by
        elif key == "args":
            args = parse_register_list(tokens)
        elif key == "tag":
            tag = parse_interned(tokens, primitives) 
        else:
            skip_value(tokens)
    return tag, target, args

def parse_tagless_clause(tokens, relocate_by):
    target = 0
    args = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == "target":
            target = parse_int(tokens) + relocate_by
        elif key == "args":
            args = parse_register_list(tokens)
        else:
            skip_value(tokens)
    return target, args

def parse_type(tokens):
    ty_name = parse_string(tokens)
    for t in range(NUMBER_OF_TYPES):
        if type_repr(t) == ty_name:
            return t
    return 0

def parse_CONST(tokens, primitives):
    out = 0
    value = IntValue(0)
    fmt = "int"
    ty = NUMBER
    for key in json_keys(tokens):
        if key == "out":
            out = parse_int(tokens)
        elif key == 'type':
            ty = parse_type(tokens)
        elif key == 'format':
            fmt = parse_string(tokens)
        elif key == "value":
            if fmt == "int":
                value = IntValue(parse_int(tokens))
            elif fmt == "double":
                value = encode_double(parse_double(tokens))
            elif fmt == "string":
                value = encode_str(parse_string(tokens))
            elif fmt == "path":
                value = encode_str(primitives.resolve_path(parse_string(tokens)))
            elif fmt == "interned":
                value = encode_interned(parse_interned(tokens, primitives))
            elif fmt == "bool":
                value = encode_bool(parse_bool(tokens))
        else:
            skip_value(tokens)
    return CONST_PTR(out, value, fmt)

def parse_PRIM_OP(tokens):
    name = ""
    outs = [[]] * NUMBER_OF_TYPES
    ins = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == "name":
            name = parse_string(tokens)
        elif key == "out":
            outs = parse_register_list(tokens)
        elif key == "in":
            ins = parse_register_list(tokens)
        else:
            skip_value(tokens)
    if name == "mkRef(Ptr): Ref[Ptr]" or name == "mkRef(Num): Ref[Num]":
        return ALLOCATE(outs[OPAQUE_PTR][0], OPAQUE_PTR, ins[OPAQUE_PTR][0], -1)
    else:
        return PRIM_OP(name, outs, ins)

def parse_ADD(tokens):
    out, in1, in2 = 0,0,0
    for key in json_keys(tokens):
        if key == "out":
            out = parse_int(tokens)
        elif key == "in1":
            in1 = parse_int(tokens)
        elif key == "in2":
            in2 = parse_int(tokens)
        else:
            skip_value(tokens)
    return ADD(out, in1, in2)

def parse_PUSH(tokens, relocate_by):
    target = 0
    args = [[]]* NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == "target":
            target = parse_int(tokens) + relocate_by
        elif key == "args":
            args = parse_register_list(tokens)
        else:
            skip_value(tokens)
    return PUSH(target, args)

def parse_RETURN(tokens):
    args = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == 'args':
            args = parse_register_list(tokens)
        else:
            skip_value(tokens)
    return RETURN(args)

def parse_SHIFT(tokens):
    out, n = 0, 0
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'n':
            n = parse_int(tokens)
        else:
            skip_value(tokens)
    return SHIFT(out, n)

def parse_SHIFT_DYN(tokens):
    out, n, label = 0, 0, -1
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'n':
            n = parse_int(tokens)
        elif key == 'label':
            label = parse_int(tokens)
        else:
            skip_value(tokens)
    return SHIFT_DYN(out, n, label)

def parse_GET_DYNAMIC(tokens):
    out, n, label = 0, 0, -1
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'n':
            n = parse_int(tokens)
        elif key == 'label':
            label = parse_int(tokens)
        else:
            skip_value(tokens)
    return GET_DYNAMIC(out, n, label)

def parse_CONTROL(tokens):
    out, n, label = 0, 0, -1
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'n':
            n = parse_int(tokens)
        elif key == 'label':
            label = parse_int(tokens)
        else:
            skip_value(tokens)
    return CONTROL(out, n, label)

def parse_JUMP(tokens, relocate_by):
    target = 0
    for key in json_keys(tokens):
        if key == 'target':
            target = parse_int(tokens) + relocate_by
        else:
            skip_value(tokens)
    return JUMP(target)

def parse_IFZERO(tokens, relocate_by):
    cond, target = 0, 0
    args = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == 'cond':
            cond = parse_int(tokens)
        elif key == 'then':
            expect(BRACE_OPEN, tokens)
            target, args = parse_tagless_clause(tokens, relocate_by)
        else:
            skip_value(tokens)
    return IFZERO(cond, target, args)

def parse_COPY(tokens):
    ty, fr, to = 0, 0, 0
    for key in json_keys(tokens):
        if key == 'type':
            ty = parse_type(tokens)
        elif key == "from":
            fr = parse_int(tokens)
        elif key == "to":
            to = parse_int(tokens)
        else:
            skip_value(tokens)
    return COPY(ty, fr, to)

def parse_DROP(tokens):
    ty, reg = 0, 0
    for key in json_keys(tokens):
        if key == 'type':
            ty = parse_type(tokens)
        elif key == "reg":
            reg = parse_int(tokens)
        else:
            skip_value(tokens)
    return DROP(ty, reg)

def parse_SWAP(tokens):
    ty, a, b = 0, 0, 0
    for key in json_keys(tokens):
        if key == 'type':
            ty = parse_type(tokens)
        elif key == "a":
            a = parse_int(tokens)
        elif key == "b":
            b = parse_int(tokens)
        else:
            skip_value(tokens)
    return SWAP(ty, a, b)

def parse_CONSTRUCT(tokens, primitives):
    out, adt_type, tag = 0, None, None
    args = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'type':
            adt_type = parse_interned(tokens, primitives)
        elif key == 'tag':
            tag = parse_interned(tokens, primitives)
        elif key == 'args':
            args = parse_register_list(tokens)
        else:
            skip_value(tokens)
    return CONSTRUCT(out, adt_type, tag, args)

def parse_MATCH(tokens, relocate_by, primitives):
    adt_type, arg = None, 0
    clauses = []
    default_clause = ERROR_CLAUSE
    for key in json_keys(tokens):
        if key == "type":
            adt_type = parse_interned(tokens, primitives)
        elif key == "scrutinee":
            arg = parse_int(tokens)
        elif key == "clauses":
            clauses = parse_MATCH_Clauses(tokens, relocate_by, primitives)
        elif key == "default":
            expect(BRACE_OPEN, tokens)
            tag, target, args = parse_clause(tokens, relocate_by, primitives, -1)
            default_clause = Clause(tag, target, args)
        else:
            skip_value(tokens)
    return MATCH(adt_type, arg, clauses, default_clause)

def parse_MATCH_Clauses(tokens, relocate_by, primitives):
    expect(BRACKET_OPEN, tokens)
    clauses = []
    token = tokens.next()
    i = 0
    while token != BRACKET_CLOSE:
        if token == COMMA:
            pass
        elif token == BRACE_OPEN:
            tag, target, args = parse_clause(tokens, relocate_by, primitives, i)
            clauses.append(Clause(tag, target, args))
        
        i+=1
        token = tokens.next()
    return clauses

def parse_SWITCH(tokens, relocate_by):
    arg = 0
    values = []
    targets = []
    default_target = 0
    for key in json_keys(tokens):
        if key == "arg":
            arg = parse_int(tokens)
        elif key == "values":
            values = parse_lit_list(tokens)
        elif key == "targets":
            targets = parse_target_list(tokens, relocate_by)
        elif key == "default":
            default_target = parse_int(tokens) + relocate_by
        else:
            skip_value(tokens)
    return SWITCH(arg, values, targets, default_target)

def parse_PROJ(tokens, primitives):
    out, adt_type, scrutinee, tag, field = 0,None,0,None,0
    field_tpe = 0
    for key in json_keys(tokens):
        if key == "type":
            adt_type = parse_interned(tokens, primitives)
        elif key == "out":
            out = parse_int(tokens)
        elif key == "scrutinee":
            scrutinee = parse_int(tokens)
        elif key == "tag":
            tag = parse_interned(tokens, primitives)
        elif key == "field":
            field = parse_int(tokens)
        elif key == "field_type":
            field_tpe = parse_type(tokens)
        else:
            skip_value(tokens)
    return PROJ(out, adt_type, scrutinee, tag, field, field_tpe)

def parse_PUSH_STACK(tokens):
    arg = 0
    for key in json_keys(tokens):
        if key == 'arg':
            arg = parse_int(tokens)
        else:
            skip_value(tokens)
    return PUSH_STACK(arg)

def parse_NEW_STACK(tokens, relocate_by):
    out, target, label = 0, 0, -1
    region = -1
    args = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'target':
            target = parse_int(tokens) + relocate_by
        elif key == 'region':
            region = parse_int(tokens)
        elif key == 'args':
            args = parse_register_list(tokens)
        elif key == 'label':
            label = parse_int(tokens)
        else:
            skip_value(tokens)
    return NEW_STACK(out, target, region, args, label)

def parse_NEW_STACK_WITH_BINDING(tokens, relocate_by):
    out, target, label, binding = 0, 0, -1, -1
    region = -1
    args = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'target':
            target = parse_int(tokens) + relocate_by
        elif key == 'region':
            region = parse_int(tokens)
        elif key == 'args':
            args = parse_register_list(tokens)
        elif key == 'label':
            label = parse_int(tokens)
        elif key == 'binding':
            binding = parse_int(tokens)
        else:
            skip_value(tokens)
    return NEW_STACK_WITH_BINDING(out, target, region, args, label, binding)

def parse_NEW(tokens, relocate_by, primitives):
    out = 0
    tags = None
    targets = None
    args = None
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'targets':
            targets = parse_target_list(tokens, relocate_by)
        elif key == 'tags':
            tags = parse_interned_list(tokens, primitives)
        elif key == 'args':
            args = RegList(parse_register_list(tokens))
        else:
            skip_value(tokens)
    vtable = VTable(tags, targets, CoData.get_concrete_class(args))
    return NEW(out, vtable, args)

def parse_INVOKE(tokens, primitives):
    receiver, tag = 0, None
    args = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == 'receiver':
            receiver = parse_int(tokens)
        elif key == 'tag':
            tag = parse_interned(tokens, primitives)
        elif key == 'args':
            args = parse_register_list(tokens)
        else:
            skip_value(tokens)
    return INVOKE(receiver, tag, args)

def parse_ALLOCATE(tokens):
    out, ty, init, region = 0, 0, 0, 0
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'type':
            ty = parse_type(tokens)
        elif key == 'region':
            region = parse_int(tokens)
        elif key == 'init':
            init = parse_int(tokens)
        else:
            skip_value(tokens)
    return ALLOCATE(out, ty, init, region)

def parse_LOAD(tokens):
    out, ty, ref = 0, 0, 0
    for key in json_keys(tokens):
        if key == 'out':
            out = parse_int(tokens)
        elif key == 'type':
            ty = parse_type(tokens)
        elif key == 'ref':
            ref = parse_int(tokens)
        else:
            skip_value(tokens)
    return LOAD(out, ty, ref)

def parse_STORE(tokens):
    ref, ty, value = 0, 0, 0
    for key in json_keys(tokens):
        if key == 'ref':
            ref = parse_int(tokens)
        elif key == 'type':
            ty = parse_type(tokens)
        elif key == 'value':
            value = parse_int(tokens)
        else:
            skip_value(tokens)
    return STORE(ref, ty, value)

def parse_CALL_LIB(tokens):
    lib = 0
    symbol = NAME_OF_ENTRYPOINT
    for key in json_keys(tokens):
        if key == "lib":
            lib = parse_int(tokens)
        elif key == "symbol":
            symbol = parse_string(tokens)
        else:
            skip_value(tokens)
    return CALL_LIB(lib, symbol)

def parse_LOAD_LIB(tokens):
    path = 0
    for key in json_keys(tokens):
        if key == "path":
            path = parse_int(tokens)
        else:
            skip_value(tokens)
    return LOAD_LIB(path)

def parse_DEBUG(tokens):
    msg = ""
    traced = [[]] * NUMBER_OF_TYPES
    for key in json_keys(tokens):
        if key == "msg":
            msg = parse_string(tokens)
        elif key == "traced":
            traced = parse_register_list(tokens)
        else:
            skip_value(tokens)
    return DEBUG(msg, traced)