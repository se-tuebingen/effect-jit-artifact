from rpyeffect.util.graph import Graph
from rpyeffect.instructions import CONST_NUMBER, CONST_PTR
from rpython.rlib.rerased import Erased
from rpyeffect.types import NUMBER, OPAQUE_PTR

class CfgBuilder(Graph):
    def __init__(self, debugger, pos = lambda dbg: dbg.pc_block):
        super(CfgBuilder, self).__init__("CFG", [], [])
        self._debugger = debugger
        self._pos = pos
        self._cur = pos(debugger)
        self.add_node(self._cur)
        # Register
        self._handle = debugger.add_debug_hook("step", self.on_step)

    def on_step(self, _1, _2):
        next = self._pos(self._debugger)
        if next is not None:
            old = self._cur
            self._cur = self._pos(self._debugger)
            if old != self._cur:
                self.add_node(self._cur)
                self.add_edge(old, self._cur)

    def build(self):
        self._debugger.del_debug_hook(self._handle)
        return self

class DfBuilder(Graph):
    def __init__(self, debugger):
        super(DfBuilder, self).__init__("DFG", [], [])
        self._debugger = debugger
        self._handles = [
            debugger.add_debug_hook("set_ptr", self.on_set_ptr),
            debugger.add_debug_hook("set_num", self.on_set_num),
            debugger.add_debug_hook("get_ptr", self.on_get_ptr),
            debugger.add_debug_hook("get_num", self.on_get_num),
            debugger.add_debug_hook("set_stored_ptr", self.on_set_stored_ptr),
            debugger.add_debug_hook("set_stored_num", self.on_set_stored_num),
            debugger.add_debug_hook("get_stored_ptr", self.on_get_stored_ptr),
            debugger.add_debug_hook("get_stored_num", self.on_get_stored_num),
            debugger.add_debug_hook("new_stored_env", self.on_new_stored_env),
            debugger.add_debug_hook("run_primitive", self.on_run_primitive),
            debugger.add_debug_hook("step", self.on_step),
        ]
        self._available = []
        self._i = 0
        pc = (debugger.pc_block, debugger.pc_instruction, self._i)
        self._last_set = dict()
        self._unknown = 0
        self._alloc = dict()
        self._known = dict()
        for i in range(len(debugger.env.values_num)):
            self._last_set[("num",i)] = pc
        for i in range(len(debugger.env.values_ptr)):
            self._last_set[("ptr",i)] = pc

    def pc(self):
        return (self._debugger.pc_block, self._debugger.pc_instruction, self._i)

    def on_step(self, _1, _2):
        self._i += 1
        self._available = []
        self._known = dict()
        ins = self._debugger.cur_ins()
        if isinstance(ins, CONST_PTR):
            self._available.append((ins.value, "const %s" % ins.value))
        elif isinstance(ins, CONST_NUMBER):
            self._available.append((ins.value, "const %d" % ins.value))
    def on_set_ptr(self, _1, _2, name, value):
        b,i,j = self.pc()
        self._last_set[("ptr", name)] = (b,i,j)
        self.flow_to(value, (b,i,j, "ptr", name), set=("ptr", name))
    def on_set_num(self, _1, _2, name, value):
        b,i,j = self.pc()
        self._last_set[("num", name)] = (b,i,j)
        self.flow_to(value, (b,i,j, "num", name), set=("num", name))
    def on_get_ptr(self, _1, _2, name):
        if name == -1:
            self._available.append((self._debugger.env.values_ptr[name], "null" ))
        else:
            b, i, j = self._last_set[("ptr", name)]
            self._available.append((self._debugger.env.values_ptr[name], (b, i, j, "ptr", name) ))
    def on_get_num(self, _1, _2, name):
        b, i, j = self._last_set[("num", name)]
        self._available.append((self._debugger.env.values_num[name], (b, i, j, "num", name) ))
    def on_set_stored_ptr(self, _1, _2, obj, name, value):
        self.flow_to(value, (id(obj), "ptr", name))
        self.add_edge((id(obj), "ptr", name), self._alloc[id(obj)], "ptr %d" % name)
    def on_set_stored_num(self, _1, _2, obj, name, value):
        self.flow_to(value, (id(obj), "num", name))
        self.add_edge((id(obj), "num", name), self._alloc[id(obj)], "num %d" % name)
    def on_get_stored_ptr(self, _1, _2, obj, name):
        self._available.append((obj.get_ptr(name), (id(obj), "ptr", name) ))
    def on_get_stored_num(self, _1, _2, obj, name):
        self._available.append((obj.get_num(name), (id(obj), "num", name) ))
    def on_new_stored_env(self, _1, _2, obj):
        self._alloc[id(obj)] = ("new @ (%d:%d, %d)" % self.pc())
        self._available.append((obj, self._alloc[id(obj)]))
    def on_run_primitive(self, _1, _2, prim, ins, outs):
        b,i,j = self.pc()
        n = "%d(%d:%d): %s" % (j,b,i,prim)
        for out in outs.regs[NUMBER]:
            self._known[("num", out)] = n        
        for out in outs.regs[OPAQUE_PTR]:
            self._known[("ptr", out)] = n

    def flow_to(self, value, pos, set = None):
        self.add_node(pos)
        if set is not None and set in self._known:
            self.add_edge(self._known[set], pos, (self._debugger.pc_block, self._debugger.pc_instruction))
            return
        found = False
        for v, p in self._available:
            if value == v or (isinstance(value, Erased) and value._x == v):
                self.add_edge(p, pos, (self._debugger.pc_block, self._debugger.pc_instruction))
                found = True
        if not found:
            self._unknown += 1
            self.add_edge(("?%d" % (self._unknown)), pos, (self._debugger.pc_block, self._debugger.pc_instruction))
        