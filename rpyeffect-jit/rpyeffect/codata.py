from rpython.rlib.rerased import new_erasing_pair
from rpyeffect.stored_environment import with_environment
from rpyeffect.representations import generate_representation_accessors, subtpe_representation
import rpyeffect.config as cfg
from rpython.rlib.jit import unroll_safe
from rpyeffect.util.debug import debug_hooks
from rpython.rlib.rerased import Erased
from rpyeffect.value import Value

class VTable:
    _immutable_fields_ = ['tags[*]', 'targets[*]', 'codata_cls']
    def __init__(self, tags, targets, cls):
        self.tags = tags
        self.targets = targets
        self.codata_cls = cls

    @unroll_safe
    def get_target(self, tag, primitives):
        for i in range(len(self.tags)):
            if self.tags[i] == tag:
                return self.targets[i]

        primitives.print_stderr("Calling non-existing method %s. Existing methods:" % tag.str)
        for etag in self.tags:
            primitives.print_stderr("  - %s" % etag.str)
        primitives.exit(1)
        assert(False)

    def __repr__(self):
        methods = []
        for i in range(len(self.targets)):
            methods += ["%s -> %d" % (self.tags[i].str, self.targets[i])]
        return ("{ %s }" % (",".join(methods)))

# Codata
@with_environment(specialized_for=[x for x in range(cfg.specialize_codatas[0] + cfg.specialize_codatas[1])])
class CoData(Value):
    _immutable_fields_ = ['vtable']
    def __init__(self, vtable):
        self.vtable = vtable
        debug_hooks.new_codata(self)

    generate_representation_accessors()

    def __repr__(self):
        return self.vtable.__repr__() # TODO captures

subtpe_representation("codata", "ptr", CoData)