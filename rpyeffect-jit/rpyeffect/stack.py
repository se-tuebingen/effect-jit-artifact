from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib.jit import JitDriver, purefunction, elidable, hint, unroll_safe, promote, assert_green, promote_string, we_are_jitted, record_exact_class, record_exact_value, not_rpython
from rpython.rlib import objectmodel
from rpyeffect.stored_environment import with_environment
from rpyeffect.representations import generate_representation_accessors, subtpe_representation
import rpyeffect.config as cfg
from rpyeffect.representations import eNone
from rpyeffect.value import Value

# Stacks
class StackLike(Value): pass

@with_environment(specialized_for=[x for x in range(cfg.specialize_stacks[0] + cfg.specialize_stacks[1])])
class Stack(StackLike):
    _immutable_fields_ = [ 'target', 'tail' ]
    def __init__(self, target, tail):
        self.target = target
        self.tail = tail
    def __repr__(self):
        return ("%d[%s] | %s"
                % (self.target, self.env.__repr__() if 'env' in self.__dict__ else '',
                   "." if self.tail is None else self.tail.__repr__()))

    @not_rpython
    def __deepcopy__(self, memo):
        # For snapshotting in the time-travelling debugger
        import copy
        from rpyeffect.instructions import RegList

        class copy_wrapped:
            def __init__(self, inner):
                self.inner = inner
                self.values_ptr = [copy.deepcopy(inner.get_ptr(i), memo) for i in range(inner.len_ptr())]
            def get_ptr(self, i):
                return self.values_ptr[i]

        res = Stack.make(RegList(self.as_argregs()), copy_wrapped(self), self.target, None)
        cur_new = res
        cur_old = self.tail
        while cur_old is not None:
            if id(cur_old) in memo:
                cur_new.tail = memo[id(cur_old)]
                return res
            cur_new.tail = Stack.make(RegList(cur_old.as_argregs()), copy_wrapped(cur_old), cur_old.target, None)
            cur_new = cur_new.tail
            cur_old = cur_old.tail
        return res

    generate_representation_accessors()


class ConcatStack(StackLike):
    _immutable_fields_ = ['front', 'tail']
    def __init__(self, front, tail):
        self.front = front
        self.tail = tail
    def __repr__(self):
        return ("%s ++ %s" % (self.front.__repr__(), self.tail.__repr__()))

# Metastacks
erase_cont, unerase_cont = new_erasing_pair("MetaStackLike")
class MetaStackLike(Value):
    _attrs_ = ['stack']
    _immutable_fields_ = ['stack']

subtpe_representation("cont", "ptr", MetaStackLike)

class MetaStack(MetaStackLike):
    _immutable_fields_ = [ 'stack', 'region', 'tail' , 'label']
    def __init__(self, stack, region, tail, label):
        self.stack = stack
        self.region = region
        self.tail = tail
        self.label = label
    def __repr__(self):
        return ("%s || %s" # TODO print region
                % (self.stack.__repr__(), ":" if self.tail is None else self.tail.__repr__()))

    def get_binding(self):
        return eNone

class MetaStackWithBinding(MetaStack):
    _immutable_fields_ = ['stack', 'region', 'tail', 'label', 'binding']
    def __init__(self, stack, region, tail, label, binding):
        self.stack = stack
        self.region = region
        self.tail = tail
        self.label = label
        self.binding = binding

    def __repr__(self):
        return ("%s || %s" # TODO print region
                % (self.stack.__repr__(), ":" if self.tail is None else self.tail.__repr__()))

    def get_binding(self):
        return self.binding

@unroll_safe
def makeMetaStack(stack, region, tail, label, binding):
    if binding is eNone:
        return MetaStack(stack, region, tail, label)
    else:
        return MetaStackWithBinding(stack, region, tail, label, binding)
        
class OpenMetaStack(MetaStackLike):
    _immutable_fields_ = ['stack']
    def __init__(self, stack):
        self.stack = stack
    def __repr__(self):
        return ("%s +?" % self.stack.__repr__())


# TODO static information about later usage
@unroll_safe # TODO look_inside_iff(lambda self,n: isconstant(n) or isvirtual(self)) ?
def split_metastack_n(metastack, n, label):
    record_exact_value(metastack is None, False)
    assert(isinstance(metastack, MetaStack))  # TODO Get rid of this. record_exact_class does not seem to work ?!?!??!?!
    region = metastack.region.freeze() if metastack.region is not None else None
    if n==0 and eq_label(metastack.label, label):
        return (makeMetaStack(metastack.stack, region, None, metastack.label, metastack.get_binding()), metastack.tail)
    else:
        (h,t) = split_metastack_n(metastack.tail, n-(1 if eq_label(metastack.label, label) else 0), label)
        return (makeMetaStack(metastack.stack, region, h, metastack.label, metastack.get_binding()), t)

@unroll_safe # TODO look_inside_iff(lambda self,n: isconstant(n) or isvirtual(self)) ?
def split_metastack_n_open(metastack, n, label):
    record_exact_value(metastack is None, False)
    region = metastack.region.freeze() if metastack.region is not None else None
    if n==0 and eq_label(metastack.label, label):
        return (OpenMetaStack(metastack.stack), metastack.tail)
    else:
        (h,t) = split_metastack_n(metastack.tail, n-(1 if eq_label(metastack.label, label) else 0), label)
        return (makeMetaStack(metastack.stack, region, h, metastack.label, metastack.get_binding()), t)

def concat_stack(f, t):
    if f is None: t
    elif t is None: f
    else: ConcatStack(f,t)

@unroll_safe
def metastack_push(self, metastack):
    if metastack is None:
        return self
    elif isinstance(metastack, OpenMetaStack):
        if isinstance(self, MetaStack):
            return makeMetaStack(concat_stack(metastack.stack, self.stack), self.region, self.tail, self.label, self.get_binding())
        elif isinstance(self, OpenMetaStack):
            return OpenMetaStack(concat_stack(metastack.stack, self.stack))
        else:
            return metastack
    else:
        assert isinstance(metastack, MetaStack)
        region = metastack.region.restore() if metastack.region is not None else None
        return makeMetaStack(metastack.stack, region, metastack_push(self, metastack.tail), metastack.label, metastack.get_binding())

@unroll_safe
def get_dynamic(metastack, n, label):
    if metastack is None or not isinstance(metastack, MetaStack):
        return eNone
    elif n==0 and eq_label(metastack.label, label):
        return metastack.get_binding()
    else:
        return get_dynamic(metastack.tail, n - (1 if metastack.label == label else 0), label)

class Label(Value):
    _immutable_fields_ = [ "origin" ]
    def __init__(self, origin):
        if cfg.allocation_site_based_eq_label:
            self.origin = origin
subtpe_representation("label", "ptr", Label)

def eq_label(x, y):
    if not cfg.allocation_site_based_eq_label:
        return x == y
    if x is None and y is None:
        return True
    elif x is None or y is None:
        return False
    elif promote(x.origin) != promote(y.origin):
        return False
    else:
        return x == y
def fresh_label(bl, ins):
    if cfg.allocation_site_based_eq_label:
        return Label(bl * 1024 + ins)
    else:
        return Label(0)

def metastack_depth(metastack):
    cur = metastack
    res = 0
    while True:
        if cur is None:
            return res
        elif isinstance(cur, MetaStack):
            res += 1
            cur = cur.tail
        elif isinstance(cur, OpenMetaStack):
            return res + 0.5

def metastack_size(metastack):
    cur = metastack
    res = 0
    while True:
        if cur is None:
            return res
        elif isinstance(cur, MetaStack):
            res += stack_depth(cur.stack)
            cur = cur.tail
        elif isinstance(cur, OpenMetaStack):
            res += stack_depth(cur.stack)
            return res + 0.5

def stack_depth(stack):
    cur = stack
    res = 0
    while True:
        if cur is None:
            return res
        elif isinstance(cur, Stack):
            res += 1
            cur = cur.tail
        elif isinstance(cur, ConcatStack):
            res += stack_depth(cur.front)
            cur = cur.tail