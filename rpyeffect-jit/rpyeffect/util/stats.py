import sys
from rpython.rlib.unroll import unrolling_iterable
from rpython.tool.sourcetools import func_with_new_name
from rpython.rlib import objectmodel
from rpython.rlib.jit import we_are_jitted, we_are_translated, unroll_safe

class Stat(object):
    def __init__(self, name, fields, methods, outputs):
        self.name = name
        self.fields = fields
        self.methods = methods
        self.outputs = outputs

    @unroll_safe
    @objectmodel.always_inline
    def _generate_methods(self, target):
        pass
    
class Counter(Stat):
    def __init__(self, name):
        super(Counter, self).__init__(name, ["%s_count" % name], ["inc_%s" % name], [name])
    
    @unroll_safe
    @objectmodel.always_inline
    def generate_methods(self, target):
        st = self
        fname = "%s_count" % st.name
        
        @unroll_safe
        @objectmodel.always_inline
        def _inc(self):
            setattr(self, fname, getattr(self, fname) + 1)
        
        fnname = "inc_%s" % self.name
        target[fnname] = func_with_new_name(_inc, fnname)

        @unroll_safe
        @objectmodel.always_inline
        def _out(self):
            return (getattr(self, fname))
        target[self.name] = func_with_new_name(_out, self.name)

class EventStat(Stat):
    def __init__(self, name, additional_fields = [], additional_methods = [], additional_outputs = []):
        super(EventStat, self).__init__(name, 
            ["%s_count" % name, "%s_sum" % name, "%s_max" % name] + additional_fields,
            ["emit_%s" % name] + additional_methods, 
            ["avg_%s" % name, "max_%s" % name, "n_%s" % name] + additional_outputs)
    
    @unroll_safe
    @objectmodel.always_inline
    def generate_methods(self, target):
        st = self
        n_name = "%s_count" % st.name
        max_name = "%s_sum" % st.name
        sum_name = "%s_max" % st.name
        
        @unroll_safe
        @objectmodel.always_inline
        def _emit(self, v):
            setattr(self, n_name, getattr(self, n_name) + 1)
            setattr(self, sum_name, getattr(self, sum_name) + v)
            if getattr(self, max_name) < v:
                setattr(self, max_name, v)
        
        fnname = "emit_%s" % self.name
        target[fnname] = func_with_new_name(_emit, fnname)

        @unroll_safe
        @objectmodel.always_inline
        def _n_out(self):
            return getattr(self, n_name)
        target["n_%s" % self.name] = func_with_new_name(_n_out, "n_%s" % self.name)
        
        @unroll_safe
        @objectmodel.always_inline
        def _avg_out(self):
            if getattr(self, n_name) == 0: return 0
            return float(getattr(self, sum_name)) / getattr(self, n_name)
        target["avg_%s" % self.name] = func_with_new_name(_avg_out, "avg_%s" % self.name)
        
        @unroll_safe
        @objectmodel.always_inline
        def _max_out(self):
            return getattr(self, max_name)
        target["max_%s" % self.name] = func_with_new_name(_max_out, "max_%s" % self.name)

class ContinuousStat(Stat):
    def __init__(self, name, t_field):
        super(ContinuousStat, self).__init__(name, 
            ["%s_t" % name, "%s_sum" % name, "%s_max" % name, "%s_cur" % name],
            ["inc_%s" % name, "set_%s" % name], 
            ["avg_%s" % name, "max_%s" % name])
        self.t_field = t_field
    
    @unroll_safe
    @objectmodel.always_inline
    def generate_methods(self, target):
        st = self
        t_name = "%s_t" % st.name
        t_field = self.t_field
        max_name = "%s_sum" % st.name
        sum_name = "%s_max" % st.name
        cur_name = "%s_cur" % st.name
        
        @unroll_safe
        @objectmodel.always_inline
        def _inc(self, d):
            v = getattr(self, cur_name) + d
            t = getattr(self, t_field)
            dt = t - getattr(self, t_name)
            setattr(self, t_name, t)
            setattr(self, sum_name, getattr(self, sum_name) + getattr(self, cur_name) * dt)
            setattr(self, cur_name, v)
            if getattr(self, max_name) < v:
                setattr(self, max_name, v)
        
        fnname = "inc_%s" % self.name
        target[fnname] = func_with_new_name(_inc, fnname)

        @unroll_safe
        @objectmodel.always_inline
        def _set(self, v):
            t = getattr(self, t_field)
            dt = t - getattr(self, t_name)
            setattr(self, t_name, t)
            setattr(self, sum_name, getattr(self, sum_name) + getattr(self, cur_name) * dt)
            setattr(self, cur_name, v)
            if getattr(self, max_name) < v:
                setattr(self, max_name, v)
        
        sfnname = "set_%s" % self.name
        target[sfnname] = func_with_new_name(_set, sfnname)

        @unroll_safe
        @objectmodel.always_inline
        def _avg_out(self):
            if getattr(self, t_name) == 0: return 0.0
            return float(getattr(self, sum_name)) / getattr(self, t_name)
        target["avg_%s" % self.name] = func_with_new_name(_avg_out, "avg_%s" % self.name)
        
        @unroll_safe
        @objectmodel.always_inline
        def _max_out(self):
            return (getattr(self, max_name))
        target["max_%s" % self.name] = func_with_new_name(_max_out, "max_%s" % self.name)

## Metaprogramming to generate fields and increment/... methods 
 
def _generate_stats_class(stats):
    caller = sys._getframe(1)
    target = caller.f_locals
    name = caller.f_globals.get("__name__")

    # __init__(self):
    fields = unrolling_iterable([field for stat in stats for field in stat.fields])
    @unroll_safe
    @objectmodel.always_inline
    def _init(self):
        for field in fields:
            setattr(self, field, 0)
    target["__init__"] = func_with_new_name(_init, "__init__")
    
    # methods for specific stats
    for stat in stats:
        stat.generate_methods(target)

    # generate output
    outs = unrolling_iterable([o for stat in stats for o in stat.outputs])
    @unroll_safe
    @objectmodel.always_inline
    def _out(self):
        for o in outs:
            print("%s: %f" % (o, getattr(self, o)()))
    target["output"] = func_with_new_name(_out, "output")
            
        
def _generate_dummy_stats_class(stats):
    caller = sys._getframe(1)
    target = caller.f_locals
    name = caller.f_globals.get("__name__")
    
    @unroll_safe
    @objectmodel.always_inline
    def _nop(self, *args):
        pass
    target["__init__"] = func_with_new_name(_nop, "__init__")
    target["output"] = func_with_new_name(_nop, "output")
    
    for method in unrolling_iterable([method for stat in stats for method in stat.methods]):
        target[method] = func_with_new_name(_nop, method)

    @unroll_safe
    @objectmodel.always_inline
    def _const0(self, *args):
        return 0.0
    for method in unrolling_iterable([method for stat in stats for method in stat.outputs]):
        target[method] = func_with_new_name(_const0, method)

## Definition of actual stats
STATS = [
    Counter("executed_instructions"),
    Counter("metastack_push_iterations"),
    ContinuousStat("stack_segments_installed", "executed_instructions_count"),
    Counter("split_metastack_n_iterations"),
    EventStat("stack_segments_captured"),
    Counter("split_metastack_n_open_iterations"),
    EventStat("open_stack_segments_captured"),
]

class NoStats:
    _generate_dummy_stats_class(STATS)

class Stats(NoStats):
    _generate_stats_class(STATS)