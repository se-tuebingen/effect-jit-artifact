from rpyeffect.parse import load_program
from rpyeffect.types import NUMBER_OF_TYPES
from rpython.rlib.jit import elidable, unroll_safe
from rpyeffect.util.debug import debug, debug_hooks
from rpyeffect.value import Value
from rpyeffect.representations import subtpe_representation

import os

class LoadedLib(Value):
    _immutable_fields_ = ['filename', 'at', 'symbols']
    def __init__(self, filename, at, symbols):
        self.filename = filename
        self.at = at
        self.symbols = symbols

    def __repr__(self):
        return ("<LoadedLib \"%s\" at %d>" % (self.filename, self.at))
subtpe_representation("lib", "ptr", LoadedLib)

@unroll_safe
def load_lib(program, filename, primitives):
    debug_hooks.load_lib(filename)
    # Fast path: Check if already loaded
    l = program.get_lib(filename)
    if l is not None:
        return l, True # Already initialized
    
    # Error case
    if not os.path.exists(filename):
        debug("Cannot load dynlib: No file " + filename)
        return None, False # abuse flag to return that this is a not found
    
    # Find place to relocate library to
    relocate_by = len(program.blocks)
    debug("Relocating %s to %d" % (filename, relocate_by))
    
    # Parse and relocate the program
    lib = load_program(filename, relocate_by, primitives)
    if lib is None:
        debug("Cannot laod dynlib %s: Parse error" % filename)
        return None, True # abuse flag to return that this is a load error
    llib = LoadedLib(filename, relocate_by, lib.symbols)

    # Insert into program
    for tp in range(NUMBER_OF_TYPES):
        if program.frame_size[tp] < lib.frame_size[tp]:
            debug("Cannot load dynlib %s : Not enough registers" % filename)
            return None, True # abuse flag to return that this is a load error
    
    program.blocks = program.blocks + lib.blocks
    program.add_lib(llib)

    return llib, False # Still needs to be initialized (via $static-init)