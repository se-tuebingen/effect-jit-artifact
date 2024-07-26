#!/usr/bin/env python -i
# Simple entrypoint for debugger, for interactive use
import rlcompleter, readline
readline.parse_and_bind('tab:complete')
import rpyeffect.config as config
config.debug = True
config.print_debug = True
import rpyeffect.debugger.lib as debugger_lib
from rpyeffect.debugger.graphs import *
from rpyeffect.debugger.lib import strip_erase, pretty, tracefn
from rpyeffect.util.console.pretty import *
import json
import sys
import copy

d = None

def load(file, args, auto_snapshot=True):
    global d
    d = debugger_lib.load(file, args)
    d.auto_snapshot = auto_snapshot

    # Add helpers for debugger functions
    def _wrapped(method):
        global d
        def res(*args):
            return (getattr(d, method))(*args)
        res.__doc__ = getattr(d.__class__, k).__doc__
        return res

    for k in d.__class__.__dict__.keys():
        if not k.startswith("_"):
            globals()[k] = _wrapped(k)

    # Add helpers for debugger functions
    def _wrapped_mod(method):
        global d
        def res(*args):
            global d
            d = (getattr(d, method))(*args)
        res.__doc__ = getattr(d.__class__, k).__doc__
        return res

    for k in ["back", "restore", "runback", "runskip"]:
        if not k.startswith("_"):
            globals()[k] = _wrapped_mod(k)

    _silent = d.silent()
    globals()["silent"] = lambda: _silent.__enter__()
    globals()["noisy"] = lambda: _silent.__exit__(None, None, None)

    d.snapshot() # snapshot at step 0

def debugger():
    return d
        
if len(sys.argv) > 1:
    # Load program
    load(sys.argv[1], sys.argv[2:])

    def _reload():
        load(sys.argv[1], sys.argv[2:])
    globals()["reload"] = _reload

# some pre-defined sanity checks
def _check_returns(d, *_):
    from rpyeffect.instructions import RETURN, DEBUG, LOAD_LIB
    from rpyeffect.types import NUMBER_OF_TYPES
    i = d.cur_ins()
    if isinstance(i, RETURN):
        d.debug_annot["last_return_types"] = [len(i.args.regs[ty]) for ty in range(NUMBER_OF_TYPES)]
    elif isinstance(i, DEBUG) and i.msg == "Returned value":
        got = d.debug_annot["last_return_types"]
        assert(all([len(i.traced.regs[ty]) == got[ty] for ty in range(NUMBER_OF_TYPES)]))
    elif isinstance(i, LOAD_LIB):
        d.debug_annot["last_return_types"] = [1 if ty == OPAQUE_PTR else 0 for ty in range(NUMBER_OF_TYPES)]
debugger().add_debug_hook("step", _check_returns)

# pre-defined additional debug info
def _annotate_creation_step(d, _1, obj, *_2):
    strip_erase(obj).created_in = d.step_count
debugger().add_debug_hook("new_stored_env", _annotate_creation_step, run_on_rerunning=True)
debugger().add_debug_hook("new_codata", _annotate_creation_step, run_on_rerunning=True)