from rpyeffect.instructions import *
from rpyeffect.symbol import Symbol
from rpyeffect.representations import eNone
from rpython.rlib.jit import elidable
from rpyeffect.value import IntValue

NAME_OF_ENTRYPOINT = "$entrypoint"

class Variable(object):
    _immutable_fields_ = ['name', 'var_type']
    def __init__(self, name, var_type):
        self.name = name
        self.var_type = var_type

class Block(object):
    _immutable_fields_ = ['name', 'instructions[*]', 'local_vars_sizes[*]', 'stack_type?']
    def __init__(self, name, instructions, local_vars_sizes, debug_name = ""):
        self.name = name
        self.instructions = instructions
        self.local_vars_sizes = local_vars_sizes
        self.stack_type = None

class LibVersion(object): pass

class Program(object):
    _immutable_fields_ = ['blocks?[*]', 'frame_size[*]', 'symbols', 'lib_version?']
    def __init__(self, blocks, frame_size, symbols):
        self.blocks = blocks
        self.frame_size = frame_size
        self.symbols = symbols
        self.loaded_libs = {}
        self.globals = {}
        self.lib_version = LibVersion()

    def get_instruction(self, pc_block, pc_instruction):
        return self.blocks[pc_block].instructions[pc_instruction]

    def get_block(self, pc_block):
        return self.blocks[pc_block]

    def lookup_env_sizes_at(self, pc_block, pc_instruction = 0):
        return self.frame_size

    def next_pc(self, pc_block, pc_instruction):
        if pc_instruction + 1 >= len(self.blocks[pc_block].instructions):
            return (pc_block+1, 0)
        else:
            return (pc_block, pc_instruction + 1)

    def is_end(self, pc_block, pc_instruction):
        return pc_block >= len(self.blocks) \
            or (pc_block == len(self.blocks)-1 and pc_instruction >= len(self.blocks[len(self.blocks)-1].instructions))

    def get_entry(self):
        e = self.symbols[NAME_OF_ENTRYPOINT]
        return (e.position,0)

    def get_lib(self, name):
        return self._get_lib(name, self.lib_version)

    @elidable
    def _get_lib(self, name, lib_version):
        assert lib_version is self.lib_version
        return self.loaded_libs.get(name)

    def add_lib(self, lib):
        self.lib_version = LibVersion()
        self.loaded_libs[lib.filename] = lib

    def get_global(self, name):
        return self._get_global(name, self.lib_version)

    def get_global_ptr(self, name):
        return self.get_global(name)
    
    @elidable
    def _get_global(self, name, lib_version):
        assert lib_version is self.lib_version
        return self.globals.get(name)

    def add_global(self, name, value):
        self.lib_version = LibVersion()
        self.globals[name] = value

    def add_global_ptr(self, name, ptr):
        self.add_global(name, ptr)
    def add_global_num(self, name, num):
        self.add_global(name, num)

DEFAULT_SYMBOLS = {NAME_OF_ENTRYPOINT: Symbol(NAME_OF_ENTRYPOINT, 0)}
EMPTY_PROGRAM = Program([],[0] * NUMBER_OF_TYPES, DEFAULT_SYMBOLS)
