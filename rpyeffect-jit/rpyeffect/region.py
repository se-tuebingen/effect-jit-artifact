from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib import objectmodel
from rpython.rlib.jit import purefunction, elidable, hint, unroll_safe, promote, promote_string, we_are_jitted, record_exact_class
from rpython.rlib.debug import ll_assert_not_none
from rpyeffect.value import Value, ValueNull, UnboxableValue, UnboxedRef
from rpyeffect.representations import subtpe_representation
from rpyeffect.instructions import ALLOCATE

class Ref(Value):
    _immutable_fields_ = ["allocation_site"]

    def __init__(self, value, alloc_site):
        self.allocation_site = promote(alloc_site)
        record_exact_class(self.allocation_site, ALLOCATE)
        if self.allocation_site.unboxed_tpe is None:
            # first occurence, assume everything is like this
            if isinstance(value, UnboxableValue): # and can be unboxed
                self.value = value.make_unboxed_ref()
                self.allocation_site.unboxed_tpe = self.value.__class__
            else: # is a boxed value already
                self.allocation_site.unboxed_tpe = Value
                self.value = value
        elif self.allocation_site.unboxed_tpe is Value:
            # is always boxed
            self.value = value
        else:
            self.value = value.make_unboxed_ref()
            if self.value.__class__ is not self.allocation_site.unboxed_tpe:
                # unboxed, but type doesn't fit - deoptimize
                self.allocation_site.unboxed_tpe = Value
                self.value = value

    def get_ptr(self):
        alloc_site = promote(self.allocation_site)
        if alloc_site.unboxed_tpe is Value:
            # not unboxed, but we still have to check because it *might* have been deoptimized
            if isinstance(self.value, UnboxedRef):
                # we deoptimized since last accessing this ref, deoptimize it
                self.value = self.value.get_boxed_contents()
            return self.value
        else:
            # unboxed
            bn = ll_assert_not_none(self.value)
            record_exact_class(bn, alloc_site.unboxed_tpe)
            return bn.get_boxed_contents()

    def put_ptr(self, value):
        alloc_site = promote(self.allocation_site)
        if alloc_site.unboxed_tpe is Value: # boxed
            self.value = value
        else: # unboxed, try to set it, otherwise deopt
            bn = ll_assert_not_none(self.value)
            record_exact_class(bn, alloc_site.unboxed_tpe)
            if not bn.try_set_from(value):
                # setting was unsucessful, deopt
                alloc_site.unboxed_tpe = Value
                self.value = value

    def freeze(self): return self.get_ptr()
    def restore(self, box):
        self.put_ptr(box)
erase_ref, unerase_ref = subtpe_representation("ref", "ptr", Ref)

class Region(Value):
    _immutable_fields_ = ['boxes[*]']
    def __init__(self, refs=[], boxes=[]):
        self.refs = refs
        self.boxes = boxes
    def register(self, ref):
        self.refs = self.refs + [ref]
    @objectmodel.always_inline
    @unroll_safe
    def freeze(self):
        boxes = [None] * len(self.refs)
        for i in range(len(self.refs)):
            boxes[i] = self.refs[i].freeze()
        r = Region(self.refs, boxes)
        return r
    @objectmodel.always_inline
    @unroll_safe
    def restore(self):
        for i in range(len(self.boxes)):
            self.refs[i].restore(self.boxes[i])
        return self
erase_region, unerase_region = subtpe_representation("region", "ptr", Region)
