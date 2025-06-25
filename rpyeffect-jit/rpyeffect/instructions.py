from rpyeffect.types import *
from rpyeffect.data import Data
from rpyeffect.representations import decode_str
from rpyeffect.value import IntValue, Value
try:
    from rpython.rlib.jit import unroll_safe, promote
    from rpython.rlib.signature import signature
    from rpython.rlib import types
except ImportError:
    def unroll_safe(f): return f
    def promote(v): return v

class Instr:
    def __init__(self):
        pass

def num_list_repr(lst):
    res = "["
    first = True
    for e in lst:
        if not first:
            res += ", "
        first = False
        res += ("%s" % e)
        first = False
    return res + "]"

def idx_list_repr(lst):
    res = "["
    first = True
    for e in lst:
        if not first:
            res += ", "
        first = False
        res += ("%d" % e)
        first = False
    return res + "]"

def clause_list_repr(clauses):
    clauses_repr = "["
    first_clause = True
    for clause in clauses:
        if not first_clause:
            clauses_repr += ", "
        clauses_repr += clause.__repr__()
        first_clause = False
    return clauses_repr + "]"

class RegList:
    _immutable_fields_ = ['regs[*]']
    def __init__(self, regs):
        self.regs = regs
    @unroll_safe
    def __repr__(self):
        res = "{"
        first = True
        for ty in range(NUMBER_OF_TYPES):
            if not first:
                res += ", "
            first = False
            res += ("\"%s\": %s" % (type_repr(ty), idx_list_repr(self.regs[ty])))
        return res + "}"
    @unroll_safe
    def shape(self):
        res = [0] * NUMBER_OF_TYPES
        for ty in range(NUMBER_OF_TYPES):
            res[ty] = promote(len(self.regs[ty]))
        return res

class Clause:
    _immutable_fields_ = ['tag', 'target', 'args', 'scrutinee_cls']
    def __init__(self, tag, target, args):
        self.tag = tag
        self.target = target
        self.args = RegList(args)
        self.scrutinee_cls = Data.get_concrete_class(self.args)
    def __repr__(self):
        return ("{\"tag\": %s, \"target\": %d, \"args\": %s}"
                % (self.tag.__repr__() if self.tag is not None else "null", self.target, self.args.__repr__()))
ERROR_CLAUSE = Clause(None, 2**62, ([[]] * NUMBER_OF_TYPES))

class CONST_PTR(Instr):
    _immutable_fields_ = ['out', 'value_ptr', 'format']

    def __init__(self, out, value, fmt):
        self.out = out
        self.value_ptr = value
        self.fmt = fmt

    def __repr__(self):
        val = ""
        if self.fmt == "string":
            val = decode_str(self.value_ptr)
        else:
            val = "%s" % self.value_ptr
        return ("{\"op\": \"Const\", \"type\": \"ptr\", \"out\": %d, \"format\": \"%s\", \"value\": \"%s\"}"
                % (self.out, self.fmt, val))


class PRIM_OP(Instr):
    _immutable_fields_ = ['name', 'outs', 'ins']

    def __init__(self, name, outs, ins):
        self.name = name
        self.outs = RegList(outs)
        self.ins = RegList(ins)

    def __repr__(self):
        return ("{\"op\": \"PrimOp\", \"name\": \"%s\", \"out\": %s, \"in\": %s}"
                % (self.name, self.outs.__repr__(), self.ins.__repr__()))

class ADD(Instr):
    _immutable_fields_ = ['out', 'in1', 'in2']

    def __init__(self, out, in1, in2):
        self.out = out
        self.in1 = in1
        self.in2 = in2

    def __repr__(self):
        return ("{\"op\": \"Add\", \"out\": %d, \"in1\": %d, \"in2\": %d}"
                % (self.out, self.in1, self.in2))

class PUSH(Instr):
    _immutable_fields_ = ['target', 'args']

    def __init__(self, target, args):
        self.target = target
        self.args = RegList(args)

    def __repr__(self):
        return ("{\"op\": \"Push\", \"target\": %d, \"args\": %s}"
                % (self.target, self.args.__repr__()))

class RETURN(Instr):
    _immutable_fields_ = ['args']

    def __init__(self, args):
        self.args = RegList(args)

    def __repr__(self):
        return ("{\"op\": \"Return\", \"args\": %s}"
                % (self.args.__repr__()))

# n is number of lifts
class SHIFT(Instr):
    _immutable_fields_ = ['out', 'n']

    def __init__(self, out, n = 1):
        self.out = out
        self.n = n

    def __repr__(self):
        return ("{\"op\": \"Shift\", \"out\": %d, \"n\": %d}"
                % (self.out, self.n))

class SHIFT_DYN(Instr):
    _immutable_fields_ = ['out', 'n', 'label']

    def __init__(self, out, n, label):
        self.out = out
        self.n = n
        self.label = label

    def __repr__(self):
        return ("{\"op\": \"ShiftDyn\", \"out\": %d, \"n\": %d, \"label\": %d}"
                % (self.out, self.n, self.label))

class GET_DYNAMIC(Instr):
    _immutable_fields_ = ['out', 'n', 'label']
    
    def __init__(self, out, n, label):
        self.out = out
        self.n = n
        self.label = label

    def __repr__(self):
        return ("{\"op\": \"GetDynamic\", \"out\": %d, \"n\": %d, \"label\": %d}"
                % (self.out, self.n, self.label))

class CONTROL(Instr):
    _immutable_fields_ = ['out', 'n', 'label']

    def __init__(self, out, n, label):
        self.out = out
        self.n = n
        self.label = label

    def __repr__(self):
        return ("{\"op\": \"Control\", \"out\": %d, \"n\": %d, \"label\": %d}"
                % (self.out, self.n, self.label))

class JUMP(Instr):
    _immutable_fields_ = ['target']

    def __init__(self, target):
        self.target = target

    def __repr__(self):
        return ("{\"op\": \"Jump\", \"target\": %d}"
                % self.target)

class IFZERO(Instr):
    _immutable_fields_ = ['cond', 'then']

    def __init__(self, cond, target, args):
        self.cond = cond
        self.then = Clause(None, target, args)

    def __repr__(self):
        return ("{\"op\": \"IfZero\", \"cond\": %d, \"then\": %s}"
                % (self.cond,
                   self.then.__repr__()))

class COPY(Instr):
    _immutable_fields_ = ['ty', 'fr', 'to']
    def __init__(self, ty, fr, to):
        self.ty = ty
        self.fr = fr
        self.to = to
    def __repr__(self):
        return ("{\"op\": \"Copy\", \"type\": \"%s\", \"from\": %d, \"to\", %d}"
                % (type_repr(self.ty), self.fr, self.to))
class DROP(Instr):
    _immutable_fields_ = ['ty', 'reg']
    def __init__(self, ty, reg):
        self.ty = ty
        self.reg = reg
    def __repr__(self):
        return ("{\"op\": \"Drop\", \"type\": \"%s\", \"reg\": %d}"
                % (type_repr(self.ty), self.reg))
class SWAP(Instr):
    _immutable_fields_ = ['ty', 'a', 'b']
    def __init__(self, ty, a, b):
        self.ty = ty
        self.a = a
        self.b = b
    def __repr__(self):
        return ("{\"op\": \"Swap\", \"type\": \"%s\", \"a\": %d, \"b\", %d}"
                % (type_repr(self.ty), self.a, self.b))

class CONSTRUCT(Instr):
    _immutable_fields_ = ['out', 'adt_type', 'tag', 'args']
    def __init__(self, out, adt_type, tag, args):
        self.out = out
        self.adt_type = adt_type
        self.tag = tag
        self.args = RegList(args)

    def __repr__(self):
        return ("{\"op\": \"Construct\", \"out\": %d, \"type\": %s, \"tag\": %s, \"args\": %s}"
                % (self.out, self.adt_type.__repr__(), self.tag.__repr__(),
                   self.args.__repr__()))

class MATCH(Instr):
    _immutable_fields_ = ['adt_type', 'arg', 'clauses[*]', 'default_clause']
    def __init__(self, adt_type, arg, clauses, default_clause):
        self.adt_type = adt_type
        self.arg = arg
        self.clauses = [None] * len(clauses)
        for i in range(len(clauses)):
            self.clauses[i] = clauses[i]
        self.default_clause = default_clause

    def __repr__(self):
        return ("{\"op\": \"Match\", \"type\": %s, \"scrutinee\": %d, \"clauses\": %s, \"default\": %s}"
                % (self.adt_type.__repr__(), self.arg, clause_list_repr(self.clauses), self.default_clause.__repr__()))

class SWITCH(Instr):
    _immutable_fields_ = ['arg', 'values[*]', 'targets[*]', 'default_target']
    def __init__(self, arg, values, targets, default_target):
        self.arg = arg
        assert len(targets) == len(values)
        self.values = [IntValue(0)] * len(values)
        self.targets = [default_target] * len(targets)
        for i in range(len(targets)):
            self.targets[i] = targets[i]
            self.values[i] = values[i]
        self.default_target = default_target

    def __repr__(self):
        return ("{\"op\": \"Switch\", \"scrutinee\": %d, \"values\": %s, \"targets\": %s, \"default\": %d}"
                % (self.arg, num_list_repr(self.values), idx_list_repr(self.targets), self.default_target))

class PROJ(Instr):
    _immutable_fields_ = ['out', 'adt_type', 'scrutinee', 'tag', 'field', 'field_tpe']
    def __init__(self, out, adt_type, scrutinee, tag, field, field_tpe):
        self.out = out
        self.adt_type = adt_type
        self.scrutinee = scrutinee
        self.tag = tag
        self.field = field
        self.field_tpe = field_tpe
    def __repr__(self):
        return ("{\"op\": \"Proj\", \"out\": %d, \"type\": %s, \"scrutinee\": %d, \"tag\": %s, \"field\": %d, \"field_type\": \"%s\"}"
                % (self.out, self.adt_type.__repr__(), self.scrutinee, self.tag.__repr__(), self.field, type_repr(self.field_tpe)))

class PUSH_STACK(Instr):
    _immutable_fields_ = ['arg']
    def __init__(self, arg):
        self.arg = arg
    def __repr__(self):
        return ("{\"op\": \"PushStack\", \"arg\": %d}" % self.arg)

class NEW_STACK_WITH_BINDING(Instr):
    _immutable_fields_ = ['out', 'target', 'region', 'args', 'label', 'binding']
    def __init__(self, out, target, region, args, label, binding):
        self.out = out
        self.target = target
        self.region = region
        self.args = RegList(args)
        self.label = label
        self.binding = binding

    def __repr__(self):
        return ("{\"op\": \"NewStackWithBinding\", \"out\": %d, \"target\": %d, \"region\": %d, \"args\": %s, \"label\": %d, \"binding\": %d}"
                % (self.out, self.target, self.region, self.args.__repr__(), self.label, self.binding))

class NEW_STACK(Instr):
    _immutable_fields_ = ['out', 'target', 'region', 'args', 'label']
    def __init__(self, out, target, region, args, label):
        self.out = out
        self.target = target
        self.region = region
        self.args = RegList(args)
        self.label = label

    def __repr__(self):
        return ("{\"op\": \"NewStack\", \"out\": %d, \"target\": %d, \"region\": %d, \"args\": %s, \"label\": %d}"
                % (self.out, self.target, self.region, self.args.__repr__(), self.label))
        
class NEW(Instr):
    _immutable_fields_ = ['out', 'vtable', 'args']
    def __init__(self, out, vtable, args):
        self.out = out
        self.vtable = vtable
        self.args = args

    def __repr__(self):
        return ("{\"op\": \"New\", \"out\": %d, \"targets\": %s, \"args\": %s}"
                % (self.out, idx_list_repr(self.vtable.targets), self.args.__repr__()))

class INVOKE(Instr):
    _immutable_fields_ = ['receiver', 'tag', 'args']
    def __init__(self, receiver, tag, args):
        self.receiver = receiver
        self.tag = tag
        self.args = RegList(args)

    def __repr__(self):
        return ("{\"op\": \"Invoke\", \"receiver\": %d, \"tag\": %s, \"args\" : %s}"
                % (self.receiver, self.tag.__repr__(), self.args.__repr__()))

class ALLOCATE(Instr):
    _immutable_fields_ = [ 'out', 'ty', 'init', 'region', 'unboxed_tpe?' ]
    def __init__(self, out, ty, init, region):
        self.out = out
        self.ty = ty
        self.init = init
        self.region = region
        self.unboxed_tpe = None

    def __repr__(self):
        return ("{\"op\": \"Allocate\", \"out\": %d, \"type\": \"%s\", \"init\": %d, \"region\": %d}"
                % (self.out, type_repr(self.ty), self.init, self.region))

class LOAD(Instr):
    _immutable_fields_ = [ 'out', 'ty', 'ref' ]
    def __init__(self, out, ty, ref):
        self.out = out
        self.ty = ty
        self.ref = ref
    def __repr__(self):
        return ("{\"op\": \"Load\", \"out\": %d, \"type\": \"%s\", \"ref\": %d}"
                % (self.out, type_repr(self.ty), self.ref))

class STORE(Instr):
    _immutable_fields_ = [ 'ref', 'ty', 'value_reg' ]
    def __init__(self, ref, ty, value):
        self.ref = ref
        self.ty = ty
        self.value_reg = value
    def __repr__(self):
        return ("{\"op\": \"Store\", \"ref\": %d, \"type\": \"%s\", \"value\": %d}"
                % (self.ref, type_repr(self.ty), self.value_reg))

class CALL_LIB(Instr):
    _immutable_fields_ = ['lib', 'symbol', 'cache_lib?', 'cache_target?']
    def __init__(self, lib, symbol):
        self.lib = lib
        self.symbol = symbol
        self.cache_lib = None # To validate that lib did not change
        self.cache_target = -1 # Will be cached after first call

    def __repr__(self):
        return ("{\"op\": \"CallLib\", \"lib\": \"%s\", \"symbol\": \"%s\"}" 
                % (self.lib, self.symbol))

class LOAD_LIB(Instr):
    _immutable_fields_ = ['path']
    def __init__(self, path):
        self.path = path

    def __repr__(self):
        return ("{\"op\": \"LoadLib\", \"path\": %d}"
                % (self.path))

class DEBUG(Instr):
    _immutable_fields_ = ['msg', 'traced']
    def __init__(self, msg, traced):
        self.msg = msg
        self.traced = RegList(traced)

    def __repr__(self):
        return ("{\"op\": \"Debug\", \"msg\": \"%s\"}" % (self.msg))