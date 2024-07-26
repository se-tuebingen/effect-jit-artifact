from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib import objectmodel
from rpyeffect.stored_environment import with_environment
from rpyeffect.representations import generate_representation_accessors, subtpe_representation
import rpyeffect.config as cfg
from rpyeffect.util.debug import debug_hooks
from rpyeffect.value import Value, ORD_EQ, ORD_GT, ORD_LT, default_compare

@with_environment(specialized_for=[x for x in range(cfg.specialize_datas[0] + cfg.specialize_datas[1])])
class Data(Value):
    _immutable_fields_ = ['tpe']
    def __init__(self, tag):
        self.tag = tag
        debug_hooks.new_data(self)

    @objectmodel.always_inline
    def get_tag(self):
        return self.tag

    generate_representation_accessors()

    def __repr__(self):
        fields = []
        for i in range(self.len_ptr()):
            fields += ["ptr%d: %s" % (i, self.get_ptr(i))]
        return ("%s(%s)" % (self.tag.str, ", ".join(fields)))

    def equals(self, other):
        if not isinstance(other, Data):
            return False
        if self.tag != other.tag:
            return False
        for i in range(self.len_ptr()):
            if not self.get_ptr(i).equals(other.get_ptr(i)):
                return False
        return True
    def compare(self, other):
        if not isinstance(other, Data):
            return default_compare(self, other)
        if self.tag != other.tag:
            return ORD_LT if self.tag.str < other.tag.str else ORD_GT
        for i in range(self.len_ptr()):
            cmp = self.get_ptr(i).compare(other.get_ptr(i))
            if cmp != ORD_EQ:
                return cmp
        return ORD_EQ
    def show(self):
        fields = []
        for i in range(self.len_ptr()):
            fields.append(self.get_ptr(i).show())
        return "%s(%s)" % (self.tag.str, ", ".join(fields))

subtpe_representation("data", "ptr", Data)