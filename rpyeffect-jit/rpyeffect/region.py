from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib import objectmodel
from rpython.rlib.jit import purefunction, elidable, hint, unroll_safe, promote, promote_string, we_are_jitted, record_exact_class
from rpyeffect.value import Value, ValueNull, UnboxableValue, UnboxedRef
from rpyeffect.representations import subtpe_representation

class Ref(Value):
    _immutable_fields_ = ["unboxed_tpe?"]
    def __init__(self, value):
        if isinstance(value, UnboxableValue):
            self.value = value.make_unboxed_ref()
            self.unboxed_tpe = self.value.__class__
        else:
            self.unboxed_tpe = None
            self.value = value
    def get_ptr(self):
        if self.unboxed_tpe is not None:
            bn = self.value
            assert isinstance(bn, self.unboxed_tpe)
            return bn.get_boxed_contents()
        else:
            return self.value
    def put_ptr(self, value):
        if self.unboxed_tpe is not None:
            bn = self.value
            assert isinstance(bn, self.unboxed_tpe)
            if bn.try_set_from(value):
                pass
            else:
                self.unboxed_tpe = None
                self.value = value
        else:
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
