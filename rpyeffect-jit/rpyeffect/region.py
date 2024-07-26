from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib import objectmodel
from rpython.rlib.jit import purefunction, elidable, hint, unroll_safe, promote, promote_string, we_are_jitted

class Ref:
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
class PtrRef(Ref):
    def __init__(self, value): self.value = value
    def get_ptr(self): return self.value
    def put_ptr(self, value): self.value = value
    def freeze(self): return PtrBox(self.value)
    def restore(self, box):
        assert(isinstance(box, PtrBox))
        self.value = box.value
erase_ref, unerase_ref = new_erasing_pair("Ref")

class Box: pass # TODO
class NumBox(Box):
    _immutable_fields_ = ["value"]
    def __init__(self, value): self.value = value
    def get(self): return self.value
    def __repr__(self): return "NumBox(%d)" % self.value
class PtrBox(Box):
    _immutable_fields_ = ["value"]
    def __init__(self, value): self.value = value
    def get(self): return self.value
    def __repr__(self): return "PtrBox(%r)" % self.value

class Region:
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
erase_region, unerase_region = new_erasing_pair("Region")
