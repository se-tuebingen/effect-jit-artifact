import sys
from rpython.tool.sourcetools import func_with_new_name

def generic(instances):
    """
    Annotation that copies the function once for each element in instances,
    with name suffixed by "_{instance}", such that they can be typed differently.
    """
    def _wrapper(fn):
        name = fn.__name__
        caller = sys._getframe(1)
        target = caller.f_locals
        caller_name = caller.f_globals.get("__name__")

        for instance in instances:
            target[name + "_" + instance] = func_with_new_name(fn, name + "_" + instance)
    
    return _wrapper