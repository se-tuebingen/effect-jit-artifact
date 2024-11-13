from rpython.rlib.jit import unroll_safe, promote
from rpython.rlib.unroll import unrolling_iterable
from rpython.rlib import objectmodel
from rpyeffect.util.annotations import assert_big_enough
from rpyeffect.types import *
from rpyeffect.representations import generate_representation_accessors, eNone
from rpyeffect.util.debug import debug_hooks
from rpyeffect.value import IntValue

def with_environment(specialized_for=[]):
    """
    Decorator that adds 
    - two leading constructor parameters (args, env) and 
    - methods set/get_num/ptr
    i.e. an inlined environment to a class.

    specialized_for: List of (n_num, n_ptr) for which numbers of nums/ptrs this should generate
                     specialized variants. -1 means arbitrary. (-1,-1) is always generated.

    Note: To generate set/get_int/double/cont/..., additionally use representations.generate_representation_accessors
    """
    def wrapper(cls):
        def make_class(n_num, n_ptr, superclasses = ()):
            _immutable = []
            if n_num == -1:
                _immutable += ["values_num[*]"]
            else:
                _immutable += ["values_num_%s" % i for i in range(n_num)]
            if n_ptr == -1:
                _immutable += ["values_ptr[*]"]
            else:
                _immutable += ["values_ptr_%s" % i for i in range(n_ptr)]

            unrolling_nums = unrolling_iterable(range(n_num)) if n_num != -1 else None
            unrolling_ptrs = unrolling_iterable(range(n_ptr)) if n_ptr != -1 else None

            @unroll_safe
            @objectmodel.always_inline
            def _init(self, args, env, *init_args):
                getattr(debug_hooks, "new_stored_env__%s" % cls.__name__)(self)
                if n_num == -1:
                    values_num = [IntValue(0)] * len(args.regs[NUMBER])
                    assert_big_enough(len(env.values_num))
                    for i in range(len(args.regs[NUMBER])):
                        val = env.get_num(args.regs[NUMBER][i])
                        getattr(debug_hooks, "set_stored_num__%s" % cls.__name__)(self, i, val)
                        values_num[i] = val
                    self.values_num = values_num
                else:
                    for i in unrolling_nums:
                        val = env.get_num(args.regs[NUMBER][i])
                        getattr(debug_hooks, "set_stored_num__%s" % cls.__name__)(self, i, val)
                        setattr(self, "values_num_%s" % i, val)
                if n_ptr == -1:
                    values_ptr = [eNone] * len(args.regs[OPAQUE_PTR])
                    assert_big_enough(len(env.values_ptr))
                    for i in range(len(args.regs[OPAQUE_PTR])):
                        val = env.get_ptr(args.regs[OPAQUE_PTR][i])
                        getattr(debug_hooks, "set_stored_ptr__%s" % cls.__name__)(self, i, val)
                        values_ptr[i] = val
                    self.values_ptr = values_ptr
                else:
                    for i in unrolling_ptrs:
                        val = env.get_ptr(args.regs[OPAQUE_PTR][i])
                        getattr(debug_hooks, "set_stored_ptr__%s" % cls.__name__)(self, i, val)
                        setattr(self, "values_ptr_%s" % i, val)

                cls.__init__(self, *init_args)
            
            @unroll_safe
            @objectmodel.always_inline
            def _len_num(self):
                if n_num == -1:
                    return len(self.values_num)
                else:
                    return n_num

            @unroll_safe
            @objectmodel.always_inline
            def _len_ptr(self):
                if n_ptr == -1:
                    return len(self.values_ptr)
                else:
                    return n_ptr

            @unroll_safe
            @objectmodel.always_inline
            def _as_argregs(self):
                return [[i for i in range(self.len_num())], [i for i in range(self.len_ptr())]]

            @unroll_safe
            @objectmodel.always_inline
            def _get_num(self, idx):
                getattr(debug_hooks, "get_stored_num__%s" % cls.__name__)(self, idx)
                if n_num == -1:
                    return self.values_num[idx]
                else:
                    for i in unrolling_nums:
                        if idx == i:
                            return getattr(self, "values_num_%s" % i)
                    return IntValue(0)
            
            @unroll_safe
            @objectmodel.always_inline
            def _get_ptr(self, idx):
                getattr(debug_hooks, "get_stored_ptr__%s" % cls.__name__)(self, idx)
                if n_ptr == -1:
                    return self.values_ptr[idx]
                else:
                    for i in unrolling_ptrs:
                        if idx == i:
                            return getattr(self, "values_ptr_%s" % i)
                    return eNone

            methods = {
                "len_num": _len_num,
                "len_ptr": _len_ptr,
                "get_num": _get_num,
                "get_ptr": _get_ptr,
                "as_argregs": _as_argregs,
                "__init__": _init
            }
            newcls = type(cls)("%s__%s_%s" % (cls.__name__, n_num if n_num != -1 else "arb", n_ptr if n_ptr != -1 else "arb"), superclasses, methods)

            setattr(newcls, "_immutable_fields_", _immutable)

            return newcls

        arb_cls = make_class(-1, -1, (cls,))
        specialized_clss = [(n_num, n_ptr, make_class(n_num, n_ptr, (arb_cls,))) for n_num, n_ptr in specialized_for]
        unrolling_sclss = unrolling_iterable(specialized_clss)

        @unroll_safe
        @objectmodel.always_inline
        def _get_cls(args):
            cls = arb_cls
            for n_num, n_ptr, ccls in unrolling_sclss:
                if (n_num == -1 or len(args.regs[NUMBER]) == n_num) and (n_ptr == -1 or len(args.regs[OPAQUE_PTR]) == n_ptr):
                    cls = ccls
            return cls
                    
        @unroll_safe
        @objectmodel.always_inline
        def _make(args, env, *init_args):
            return (_get_cls(args))(args, env, *init_args)

        setattr(cls, "make", staticmethod(_make))
        setattr(cls, "get_concrete_class", staticmethod(_get_cls))
        return cls
    return wrapper

@with_environment()
class StoredEnvironment:
    @unroll_safe
    @objectmodel.always_inline
    def __init__(self): pass

    generate_representation_accessors()

@unroll_safe
@objectmodel.always_inline
def make_StoredEnvironment(args, env, program):
    return StoredEnvironment.make(args, env)