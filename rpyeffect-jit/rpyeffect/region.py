from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib import objectmodel
from rpython.rlib.jit import purefunction, elidable, hint, unroll_safe, promote, promote_string, we_are_jitted
from rpyeffect.value import Value
from rpyeffect.representations import subtpe_representation

class Ref(Value):
    def freeze(self): return Box()
    def restore(self, box): pass
class NumRef(Ref):
    def __init__(self, value): self.value = value
    def get_num(self): return self.value
    def put_num(self, value): self.value = value
    def freeze(self): return NumBox(self.value)
    def restore(self, box):
        assert(isinstance(box, NumBox))
        self.value = box.value
class _BoxedNumRefContents(Value):
    def __init__(self, num_value):
        self.value = num_value
class PtrRef(Ref):
    _immutable_fields_ = ["is_num?"]
    def __init__(self, value):
        if isinstance(value, NumBox):
            self.is_num = True
            self.value = _BoxedNumRefContents(value.value)
        else:
            self.is_num = False
            self.value = value
    def get_ptr(self):
        if self.is_num:
            bn = self.value
            assert isinstance(bn, _BoxedNumRefContents)
            return erase_box(NumBox(bn.value))
        else:
            return self.value
    def put_ptr(self, value):
        if self.is_num:
            bn = (self.value)
            assert isinstance(bn, _BoxedNumRefContents)
            if isinstance(value, NumBox):
                bn.value = value.value
            else:
                self.is_num = False
                self.value = value
        else:
            self.value = value
    def freeze(self): return PtrBox(self.get_ptr())
    def restore(self, box):
        assert(isinstance(box, PtrBox))
        self.put_ptr(box.value)
erase_ref, unerase_ref = subtpe_representation("ref", "ptr", Ref)

class Box(Value): pass # TODO
class NumBox(Box):
    _immutable_fields_ = ["value"]
    def __init__(self, value): self.value = value
    def get(self): return self.value
    def __repr__(self): return "NumBox(%d)" % self.value.value
class PtrBox(Box):
    _immutable_fields_ = ["value"]
    def __init__(self, value): self.value = value
    def get(self): return self.value
    def __repr__(self): return "PtrBox(%r)" % self.value
erase_box, unerase_box = subtpe_representation("box", "ptr", Box)


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
