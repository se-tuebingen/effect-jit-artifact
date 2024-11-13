from rpython.rlib.rerased import new_erasing_pair
from rpython.rlib import objectmodel
from rpyeffect.stored_environment import with_environment
from rpyeffect.representations import generate_representation_accessors
import rpyeffect.config as cfg
from rpyeffect.util.debug import debug_hooks
from rpyeffect.value import Value

@with_environment(specialized_for=[(x,y) for x in range(cfg.specialize_datas[0]) for y in range(cfg.specialize_datas[1])])
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
        for i in range(self.len_num()):
            fields += ["num%d: %s" % (i, self.get_num(i))]
        for i in range(self.len_ptr()):
            fields += ["ptr%d: %s" % (i, self.get_ptr(i))]
        return ("%s(%s)" % (self.tag.str, ", ".join(fields)))