import rpyeffect.config as cfg
from rpython.rlib.jit import we_are_jitted, we_are_translated, unroll_safe
from rpyeffect.util.generic import generic
from rpython.rlib import objectmodel
import sys

@objectmodel.always_inline
def debug(output):
    if cfg.print_debug and not we_are_jitted():
        if debug_hooks.debugout(output) is None:
            lines = output.split("\n")
            print("\033[36m[DEBUG] " + "\n        ".join(lines) + "\033[0m")

# For hooking into the interpreter, in NON-RPYTHON invocation.
# This is a class to circumvent typing errors.
# NOTE: If compiled in RPython, all of those should be a no-op.
def _generate_debug_hook(target, name):
        @unroll_safe
        @objectmodel.always_inline
        def _hook(self, *args):
            pass
        target[name] = _hook

def _generate_debug_hook_methods():
    caller = sys._getframe(1)
    target = caller.f_locals
    names = target["__hook_names__"]
    
    for name in names:
        _generate_debug_hook(target, name)

class DebugHooks():
    # List of debug hooks (methods on this object to be generated)
    __hook_names__ = [
        "set_num", "set_ptr",
        "get_num", "get_ptr",
        "set_stored_num__Stack", "get_stored_num__Stack",
        "set_stored_ptr__Stack", "get_stored_ptr__Stack",
        "set_stored_num__CoData", "get_stored_num__CoData",
        "set_stored_ptr__CoData", "get_stored_ptr__CoData",
        "set_stored_num__Data", "get_stored_num__Data",
        "set_stored_ptr__Data", "get_stored_ptr__Data",
        "new_data", "new_codata",
        "new_stored_env", "new_stored_env__CoData", "new_stored_env__Stack", "new_stored_env__Data",
        "run_primitive",
        "load_lib",
        "return_through_label",
        "debugout",
        "enter_static_init",
        "mk_value"
        ]
    _generate_debug_hook_methods()
    
debug_hooks = DebugHooks()