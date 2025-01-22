# Library debugger for rpyeffect
from rpyeffect.debugger.patches import *
from rpyeffect.interpreter import interpret_instruction, get_context
from rpyeffect.primitives import Primitives
from rpyeffect.parse import load_program
from rpyeffect.environment import Environment
from rpyeffect.util.path import abspath
from rpyeffect.util import debug
from rpyeffect.stack import MetaStack
import rpyeffect.util.console.colors as colors
import rpyeffect.util.console as console
from rpyeffect.types import NUMBER, OPAQUE_PTR
import rpyeffect.util.console.pretty as pp
from rpython.rlib.objectmodel import not_rpython
from rpyeffect.dynlib import LoadedLib
import rpyeffect.config as config
import copy, math

primitives = Primitives()

# Replace exit with exception (so we can debug panics)
class Exit(Exception):
    def __init__(self, code):
        self.code = code
        super(Exception, self).__init__(self.__repr__())
    def __repr__(self):
        return "Exit(%d)" % self.code
    
def _debug_exit(code):
    raise Exit(code)
primitives.exit = _debug_exit

class _Handle: "Generated as handle for event handlers (to allow removing)"

class _Box:
    def __init__(self, val):
        self.val = val

class Debugger:
    def __init__(self, program, args):
        if program is None:
            return
        self.orig_program = copy.deepcopy(program)
        self.program = program
        self.args = args
        self.primitives = primitives
        self.pc_block, self.pc_instruction = program.get_entry()
        self.env = Environment(program)
        self.stack_label, self.stack_binding, self.stack, self.metastack = None, None, None, None
        primitives.parse_args(args)
        self.context = get_context(self.pc_block, self.pc_instruction, self.stack, self.metastack)
        self.breakpoints = set()
        self.break_conditions = dict()
        self.debughooks = dict()
        self._combined_stack = None
        self._rec = None
        self.step_count = 0
        self.snapshots = dict()
        self._weak_snapshots = set()
        self.auto_snapshot = False
        self.skipped_last_auto_snapshot = False
        self.auto_snapshot_filter_hook = lambda d: True
        self.debug_annot = dict()
        self.debug_asserts = dict()

    def __deepcopy__(self, memo):
        res = Debugger(self.orig_program, self.args)
        res.orig_program = self.orig_program
        res.primitives = self.primitives
        res.snapshots = self.snapshots
        res._weak_snapshots = self._weak_snapshots
        res.auto_snapshot = self.auto_snapshot
        res.skipped_last_auto_snapshot = self.skipped_last_auto_snapshot
        res.auto_snapshot_filter_hook = self.auto_snapshot_filter_hook
        res.args = self.args
        to_deep_copy = [
            'program',
            'pc_block', 'pc_instruction',
            'env', 
            'stack_label', 'stack_binding', 'stack', 'metastack',
            'context',
            'breakpoints', 'break_conditions', 'debughooks',
            '_combined_stack', '_rec', 
            'step_count', "debug_annot"
        ]
        for prop in to_deep_copy:
            setattr(res, prop, copy.deepcopy(getattr(self, prop), memo))
        return res

    def _my_debug_hook(self, name, *args):
        if self._rec == (name, args):
            return
        self._rec = (name, args)
        if name in self.debughooks:
            for hook in self.debughooks[name].values():
                hook(self, name, *args)
        parts = name.split("__")
        if "__" in name and parts[0] in self.debughooks:
            for hook in self.debughooks[parts[0]].values():
                hook(self, name, *args)
        self._rec = None

    def _enter_debug_hook(self, hook):
        old = getattr(debug.debug_hooks, hook)
        debugger = self
        def _hook(*args):
            debugger._my_debug_hook(hook, *args)
        setattr(debug.debug_hooks, hook, _hook)
        return old

    def _exit_debug_hook(self, hook, old):
        setattr(debug.debug_hooks, hook, old)

    def _use_debug_hook(self):
        debugger = self
        class _EnvMgr:
            def __enter__(self):
                self._old = [(h, debugger._enter_debug_hook(h)) for h in debug.DebugHooks.__hook_names__]
            def __exit__(self, exc_type, exc_value, exc_tb):
                for (h, old) in self._old:
                    debugger._exit_debug_hook(h, old)
        return _EnvMgr()

    def auto_snapshot_only_if(self, cond):
        self.auto_snapshot_filter_hook = cond
    
    def add_debug_hook(self, name, hook, one_off=False, when=None, run_on_rerunning=False):
        """
        Call hook with name and args when debug hook name occurs.
        Returns a handle that can be used with del_debug_hook to remove this handler.
        """
        if name not in self.debughooks:
            self.debughooks[name] = dict()
        handle = _Handle()
        handle.run_on_rerunning = run_on_rerunning
        if one_off:
            orig_hook1 = hook
            def one_off_hook(*args):
                self.del_debug_hook(handle)
                return orig_hook1(*args)
            hook = one_off_hook
        if when is not None:
            orig_hook2 = hook
            def cond_hook(*args):
                if when(*args):
                    return orig_hook2(*args)
            hook = cond_hook
        self.debughooks[name][handle] = hook
        return handle

    def del_debug_hook(self, handle):
        for hs in self.debughooks.values():
            if handle in hs:
                del hs[handle]

    def step(self):
        """Step the program (one rpyeffect-code step)"""
        if self.skipped_last_auto_snapshot or (self.auto_snapshot and self.step_count % (Debugger._snapshot_factor * Debugger._snapshot_base) == 0):
            if self.auto_snapshot_filter_hook(self):
                self.skipped_last_auto_snapshot = False
                self._weak_snapshot()
            else:
                self.skipped_last_auto_snapshot = True
        if not self.program.is_end(self.pc_block, self.pc_instruction):
            self._my_debug_hook("step")
            with self._use_debug_hook():
                self.pc_block, self.pc_instruction, self.stack_label, self.stack_binding, self.stack, self.metastack, self.context \
                    = interpret_instruction(
                        program = self.program, pc_block = self.pc_block, pc_instruction = self.pc_instruction, 
                        stack_label=self.stack_label, stack_binding=self.stack_binding, stack=self.stack,env=self.env, metastack=self.metastack, 
                        primitives=self.primitives, context=self.context)
            self.step_count += 1
            self._my_debug_hook("after_step")

    def step_out(self):
        """Run the program until returned to the current topmost return on the stack (potentially never!)"""
        t = self.stack.target
        rem = (t, 0) not in self.breakpoints
        self.set_breakpoint(t)
        self.run()
        if rem:
            self.unset_breakpoint(t)

    def step_block(self):
        """Run the program until reaching a different block"""
        cur = self.pc_block
        hndl = self.set_break_condition(lambda d: d.pc_block != cur)
        self.run()
        self.unset_break_condition(hndl)
        

    def snapshot(self):
        snap = self._snapshot()
        if self.step_count in self._weak_snapshots:
            self._weak_snapshots.remove(self.step_count)
        return snap

    def _snapshot(self):
        if self.step_count in self.snapshots:
            return self.snapshots[self.step_count]
        else:
            snap = copy.deepcopy(self)
            self.snapshots[self.step_count] = snap
            return snap

    ## Machinery for auto-snapshotting (for faster backstepping)
    _snapshot_base = 2
    _snapshot_factor = 100

    def _weak_snapshot(self):
        snap = self._snapshot()
        exp_size = (1+ math.log(self.step_count/Debugger._snapshot_factor+1, Debugger._snapshot_base))
        if len(self._weak_snapshots) > exp_size * 2:
            self._gc_snapshots()
        self._weak_snapshots.add(self.step_count)

    def _retain_weak_snapshot(self, step):
        if step == 0:
            return True
        lvl = min((l for l in range(0,33) if step % (Debugger._snapshot_factor * Debugger._snapshot_base**l) != 0))
        return abs(self.step_count - step) < Debugger._snapshot_factor * Debugger._snapshot_base**(lvl)

    def _gc_snapshots(self):
        rm = []
        for k in self._weak_snapshots:
            if not self._retain_weak_snapshot(k): # should collect?
                rm.append(k)
        for k in rm:
            del self.snapshots[k]
            self._weak_snapshots.remove(k)

    def _find_snapshot(self, for_step):
        # Find last snapshot before
        r = -1
        for k in self.snapshots.keys():
            if k <= for_step and k > r:
                r = k
        if r != -1:
            return self.snapshots[r]
        return Debugger(copy.deepcopy(self.orig_program), self.args)

    def restore(self, snapshot):
        assert isinstance(snapshot, Debugger)
        new = copy.deepcopy(snapshot)
        new.break_conditions = self.break_conditions
        new.breakpoints = self.breakpoints
        new.debughooks = self.debughooks
        return new
    
    def disabled_breakpoints(self):
        this = self
        class _DisabledBreakpoints:
            def __enter__(self):
                self.break_conditions = this.break_conditions
                self.breakpoints = this.breakpoints
                this.break_conditions = dict()
                this.breakpoints = set()
            def __exit__(self, exc_type, exc_value, exc_tb):
                this.break_conditions = self.break_conditions
                this.breakpoints = self.breakpoints
        return _DisabledBreakpoints()
    
    def disabled_hooks(self):
        this = self
        class _DisabledHooks:
            def __enter__(self):
                self.debughooks = this.debughooks
                this.debughooks = dict()
                for k in self.debughooks:
                    for h in self.debughooks[k]:
                        if hasattr(h, "run_on_rerunning") and h.run_on_rerunning:
                            if k not in this.debughooks:
                                this.debughooks[k] = dict()
                            this.debughooks[k][h] = self.debughooks[k][h]
            def __exit__(self, exc_type, exc_value, exc_tb):
                this.debughooks = self.debughooks
        return _DisabledHooks()    

    def local_breakpoints_and_hooks(self):
        this = self
        class _Local:
            def __enter__(self):
                self.break_conditions = this.break_conditions
                self.breakpoints = this.breakpoints
                self.debughooks = this.debughooks
            def __exit__(self, exc_type, exc_value, exc_tb):
                this.break_conditions = self.break_conditions
                this.breakpoints = self.breakpoints
                this.debughooks = self.debughooks
        return _Local()

    def silent(self):
        this = self
        class _Silent:
            def __enter__(self):
                self.hd = this.add_debug_hook("debugout", lambda a,b: True)
                self.oldpd = config.print_debug
                config.print_debug = False
            def __exit__(self, exc_type, exc_value, exc_tb):
                this.del_debug_hook(self.hd)
                config.print_debug = self.oldpd
        return _Silent()

    def back(self, i = 1, startfrom = None):
        """
        Re-run the program to get to i steps before, returns a *new* Debugger instance.
        Will potentially re-run side-effects!
        """
        n = self.step_count - i
        # Setup new debugger
        if startfrom is None:
            startfrom = self._find_snapshot(n)
        if startfrom.step_count == n:
            return startfrom
        new = self.restore(startfrom)
        with new.disabled_breakpoints():
            with new.disabled_hooks():
                with new.silent():
                    # Make sure we stop and remove debug output
                    hbc = new.set_break_condition(lambda s: s.step_count == n)
                    # Run
                    new.run()
        return new

    def runback(self, i = -1):
        if i == -1: i = self.step_count
        last_break = None
        nmax = self.step_count - 1
        while last_break is None and nmax >= self.step_count - i:
            # Start simulating from last snapshot
            startfrom = self._find_snapshot(nmax)
            new = self.restore(startfrom)
            with new.local_breakpoints_and_hooks():
                with new.disabled_hooks():
                    with new.silent():
                        # Run until current step, updating last_break
                        while new.step_count < nmax:
                            # found a breakpoint, snapshot as new last_break
                            if new.is_breakpoint():
                                if last_break is not None:
                                    del new.snapshots[last_break.step_count]
                                last_break = new._snapshot() 
                            new.run(nmax - new.step_count)
                        if new.is_breakpoint():
                            if last_break is not None:
                                del new.snapshots[last_break.step_count]
                            last_break = new._snapshot() 
            # if trying again, start earlier
            nmax = startfrom.step_count-1
        return self.restore(last_break if last_break is not None else self._find_snapshot(0))

    def runskip(self, to_step = -1):
        startfrom = self._find_snapshot(to_step if to_step >= 0 else max(self.snapshots.keys()))
        new = self.restore(startfrom)
        with new.disabled_breakpoints():
            with new.disabled_hooks():
                new.run(to_step - new.step_count)
                if to_step == -1:
                    new.run()
        return new

    def run(self, max_steps = -1):
        """Continue running the program until a breakpoint occurs or the program terminates"""
        lim = self.step_count + max_steps if max_steps > 0 else -1
        while not self.program.is_end(self.pc_block, self.pc_instruction):
            self.step()
            if self.is_breakpoint() or (max_steps > 0 and self.step_count >= lim):
                return
            
    def cur_ins(self):
        return self.cur_block().instructions[self.pc_instruction]
    
    def cur_block(self):
        return self.program.blocks[self.pc_block]

    def list_block(self, i_block = -1, i_ins = -1):
        if i_block == -1:
            i_block = self.pc_block
            if i_ins == -1:
                i_ins = self.pc_instruction
        b = self.program.blocks[i_block]
        s, spos = self.sym_of(i_block)
        print(colors.bold("%d \"%s\":  %s" % (i_block, b.name, (colors.faint("%s %d") % (s.name, spos)))))
        for i in range(len(b.instructions)):
            marker = " "
            if i == i_ins:
                marker = colors.blue(">")
            print("%s %s %s" % (marker, colors.light_gray("%d:" % i), 
                                console.wrap(b.instructions[i].__repr__(), 100, indent=6)[6:]))

    def show_args(self, args, env=None):
        if env is None:
            env = self.env
        res = []
        for i in range(len(args.regs[NUMBER])):
            res.append(console.beside(("NUM %d: " % i), colors.light_gray("%d" % env.get_num(i))))
        for i in range(len(args.regs[OPAQUE_PTR])):
            res.append(console.beside(("PTR %d: " % i), colors.light_gray("%s" % env.get_ptr(i))))
        return "\n".join(res)

    def combined_stack(self):
        if self._combined_stack is None \
            or (self._combined_stack.stack != self.stack 
                or self._combined_stack.tail != self.metastack 
                or self._combined_stack.label != self.stack_label):
            self._combined_stack = MetaStack(self.stack, None, self.metastack, self.stack_label)
        return self._combined_stack

    def is_breakpoint(self):
        return \
            ((self.pc_block, self.pc_instruction) in self.breakpoints) or \
            any((c(self) for c in self.break_conditions.values()))
    
    def set_breakpoint(self, pc_block, pc_ins = 0):
        self.breakpoints.add((pc_block, pc_ins))

    def unset_breakpoint(self, pc_block, pc_ins = 0):
        self.breakpoints.remove((pc_block, pc_ins))

    def set_breakpoint_sym(self, symbol, lib = None):
        if isinstance(lib, str): # Lookup (fuzzy) for strings
            res = None
            for k in self.program.loaded_libs:
                if k == lib:
                    res = k
                    break
                elif lib in k and res is None:
                    res = k
            if res is None:
                print("Could not find loaded lib named '%s'" % lib)
                return
            lib = self.program.loaded_libs[res]
        if isinstance(lib, LoadedLib):
            self.set_breakpoint(lib.symbols[symbol].position)
        else: # search all libs
            alternatives = []
            for k, lib in self.program.loaded_libs.items():
                if symbol in lib.symbols:
                    alternatives.append((lib, lib.symbols[symbol]))
            if len(alternatives) == 0:
                print("Could not find symbol '%s' in any loaded library" % symbol)
            elif len(alternatives) > 1:
                print("Multiple alternatives:")
                for i, (lib, sym) in enumerate(alternatives):
                    print(" %i: at %d in %s" % (i, sym.at, lib.filename))
                c = int(input("Choice: "))
                self.set_breakpoint(alternatives[c][0].position)
                return alternatives[c][0].position
            else:
                self.set_breakpoint(alternatives[0][1].position)
                return alternatives[0][1].position
    
    def set_break_condition(self, condition):
        """
        Adds a predicate that is called at every step. 
        When it returns true, this is considered a breakpoint.
        """
        handle = _Handle()
        def fxd_condition(s):
            try:
                return condition(s)
            except Exception:
                return False
        self.break_conditions[handle] = fxd_condition
        return handle

    def set_watch_break_condition(self, expr):
        this = self
        class WatchExpression:
            def __init__(self, expr):
                self.at = dict()
                self.at[this.step_count] = expr(this)
                self.expr = expr
            def __call__(self, dbgr):
                cur = self.expr(dbgr)
                self.at[dbgr.step_count] = cur
                if (dbgr.step_count - 1) not in self.at:
                    return False
                last = self.at[dbgr.step_count - 1]
                return (cur != last)
        return self.set_break_condition(WatchExpression(expr))

    def add_trace_expr_hook(self, expr, mnemonic = ""):
        this = self
        class TraceExpression:
            def __init__(self, expr):
                self.last = expr(this)
                self.expr = expr
            def __call__(self, dbgr, *_):
                cur = self.expr(dbgr)
                if cur != self.last:
                    print("%s was changed to %s" % (mnemonic, cur))
                self.last = cur
        return self.add_debug_hook("step", TraceExpression(expr))

    def unset_break_condition(self, handle):
        del self.break_conditions[handle]

    def trace_changes(self, fn, doc = ""):
        last = _Box(fn(self)) # Box to work around Python2's lack of `nonlocal`
        def onstep(myname):
            nxt = fn(self)
            if nxt != last.val:
                last.val = nxt
                print("TRACE: Changed %s to %s" % (doc, nxt))
        return self.add_debug_hook("step", onstep)

    def pp_stack(self, print_envs = False):
        print(pp.pretty_metastack(self.combined_stack(), self.program, max_width=250, print_envs=print_envs))

    def pp_env(self):
        print(pp.pretty_env(self.env, max_width=250, program=self.program))

    def lib_of(self, block = None):
        res = None
        if block is None:
            block = self.pc_block
        for _, lib in self.program.loaded_libs.items():
            if lib.at <= block and (res is None or lib.at > res.at):
                res = lib
        return res
    
    def sym_of(self, block = None):
        if block is None: block = self.pc_block
        lib = self.lib_of(block)
        if lib is None:
            syms = self.program.symbols
        else:
            syms = lib.symbols
        res = None
        for name, sym in syms.items():
            if sym.position >= block and (res is None or res.position > sym.position):
                res = sym
        if res.position == block:
            return (res, 0)
        else:
            return (res, block - res.position)

    def get_ptr(self, idx):
        return strip_erase(self.env.get_ptr(idx))
    def get_num(self, idx):
        return self.env.get_num(idx)

    @not_rpython
    def debuginfo(self, lib = None):
        if lib is None: lib = self.lib_of(self.pc_block)
        libfile = lib.filename if lib is not None else self.primitives.real_script_name
        import json, os.path
        difile = os.path.join(os.path.dirname(libfile), ".debugout", os.path.basename(libfile), "debuginfo.json")
        if not os.path.exists(difile):
            return None
        with open(difile) as f:
            return json.load(f)

    @not_rpython
    def asm_syminfo(self, symid, lib = None):
        return self.debuginfo(lib)["asm"]["Generated"][symid]

    @not_rpython
    def mcore_syminfo(self, symid, lib = None):
        return self.debuginfo(lib)["mcore"]["Generated"][symid]

    def check_assertions(self):
        if (self.pc_block, self.pc_instruction) in self.debug_asserts:
            for name, pred in self.debug_asserts[(self.pc_block, self.pc_instruction)]:
                print(colors.faint("    ASSERT %s: %s" % (name, "ok" if pred() else colors.red("FAIL"))))

    def assert_here(self, name, pred):
        if (self.pc_block, self.pc_instruction) not in self.debug_asserts:
            self.debug_asserts[(self.pc_block, self.pc_instruction)] = list()
        self.debug_asserts[(self.pc_block, self.pc_instruction)].append((name, pred))

    # Koka-backend specific:
    # ----------------------
    def _kk_pp_evv(self, evv):
        evv = strip_erase(evv)
        if evv.tag.str == "cons":
            print(pp.simple_data(strip_erase(evv.get_ptr(0)).get_ptr(0)))
            self._kk_pp_evv(evv.get_ptr(1))
        elif evv.tag.str == "nil":
            print("---")
        else:
            print("???")        
    def kk_evv(self):
        if "current-evv" in self.program.globals:
            evv = self.program.globals["current-evv"].get()
            evv = strip_erase(evv)
            evv = evv.value
            self._kk_pp_evv(evv)
        else:
            print("(not yet initialized / not a koka backend)")
            
def load(filename, args=[]):
    primitives.script_name = filename
    primitives.real_script_name = abspath(filename)
    program = load_program(filename, 0, primitives)
    return Debugger(program, args)

def strip_erase(obj):
    from rpython.rlib.rerased import Erased
    if isinstance(obj, Erased):
        return obj._x
    else:
        return obj

def pretty(obj):
    obj = strip_erase(obj)
    return colors.light_gray(pp.pretty_ptr(obj.__repr__()))

def tracefn(fn, name=None):
    if name is None:
        name = fn.__name__
    inner = fn
    def wrapped(*args):
        pargs = ", ".join(("%s" % arg for arg in args))
        print("%s(%s)" % (name, pargs))
        res = fn(*args)
        print("%s(%s) -> %s" % (name, pargs, res))
        return res
    return wrapped