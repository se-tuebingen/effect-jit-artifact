from rpyeffect.util.console import *
import rpyeffect.util.console.colors as colors
from rpyeffect.stack import StackLike, Stack, ConcatStack, MetaStackLike, MetaStack, OpenMetaStack
from rpyeffect.environment import Environment
from rpyeffect.data import Data
from rpyeffect.program import Program
from rpython.rlib.jit import we_are_translated, we_are_jitted, not_rpython

def pretty_num(n):
    return "%d" % n

@not_rpython
def _strip_erase(obj):
    from rpython.rlib.rerased import Erased
    if isinstance(obj, Erased):
        return obj._x
    else:
        return obj
def pretty_ptr(p, program=None, max_width=200):
    if we_are_jitted() or we_are_translated():
        return "%s" % p
    else:
        v = _strip_erase(p)
        if isinstance(v, Stack):
            return pretty_stack(v, program, max_width=max_width)
        elif isinstance(v, MetaStackLike):
            return pretty_metastack(v, program, max_width=max_width)
        elif isinstance(v, Environment):
            return pretty_env(v, program=program, max_width=max_width)
        elif isinstance(v, Data):
            return pretty_data(v, program, max_width=max_width)
        elif hasattr(v, "__repr__"):
            return v.__repr__()
        else:
            return "%s" % p
        

def pretty_env(env, max_width=100, program = None):
    rows = []
    n_ptrs = env.len_ptr()
    for i in range(n_ptrs):
       rows.append(("ptr%d" % i, pretty_ptr(env.get_ptr(i), program, max_width=max_width-6))) 
    widthk, widthv = 4,1
    for row in rows:
        widthk = min(max(widthk, width(row[0])),max_width/2)
        widthv = min(max(widthv, width(row[1])),max_width-widthk-1)
    layouted_rows = []
    for k,v in rows:
        h = max(height(k), height(v))
        layouted_rows.append(beside(wrap_align(k,widthk), wrap_align(v,widthv), sep=u"\u2502"))
    return box("\n".join(layouted_rows))

def pretty_stack(stack, program = None, max_width=100, print_envs=True):
    # type: (StackLike, Program | None, int, bool) -> str
    frames = []
    current = stack
    while current is not None:
        if isinstance(current, Stack):
            tgt = "%s\n%s" % (current.target, colors.purple(program.blocks[current.target].name if program is not None else "?"))
            if print_envs:
                frames.append(beside(tgt, colors.dark_gray(pretty_env(current, program=program, max_width=max_width-2-visual_len(tgt))),
                                        align_v="c", sep=" "))
            else:
                frames.append(tgt.replace("\n"," "))
            current = current.tail
        elif isinstance(current, ConcatStack):
            frames.append(beside("*", pretty_stack(current.front, program,max_width=max_width-2, print_envs=print_envs)))
            current = current.tail
    frames = wrap_align_all(frames, max_width-2)
    frames = [box(f, top=False) for f in frames]
    return "\n".join(frames)

def pretty_metastack(metastack, program=None, max_width=100, print_envs=True):
    if metastack is None:
        return "None"
    stacks = []
    current = metastack
    while current is not None:
        if isinstance(current, MetaStack):
            st = pretty_stack(current.stack, program, max_width=max_width-2, print_envs=print_envs)
            lbl = colors.red("%s" % current.label)
            stacks.append(above(st, "%s (region %s)" % (lbl, current.region)))
            current = current.tail
        elif isinstance(current, OpenMetaStack):
            stacks.append(pretty_stack(current.stack, program, max_width=max_width-2))
            stacks = wrap_align_all(stacks, max_width)
            me = stacks[len(stacks)-1]
            del stacks[len(stacks)-1]
            stacks = [box(f, top=False,hor=u"\u2550",botleft=u"\u2558",botright=u"\u255B") for f in stacks]
            return "\n".join(stacks) + "\n" + box(me, topleft=u"",topright=u"",top="",botleft=u"\u2506",botright=u"\u2506",bot="")
    stacks = wrap_align_all(stacks,max_width)
    stacks = [box(f, top=False,hor=u"\u2550",botleft=u"\u2558",botright=u"\u255B") for f in stacks]
    return "\n".join(stacks)

def pretty_data(data, program=None, max_width=100):
    return box(above(data.tag.str, pretty_env(data, max_width=max_width-len(data.tag.str)-2, program=program), sep=" "))

def simple_data(data, program=None):
    data = _strip_erase(data)
    argstrs = []
    for i in range(data.len_ptr()):
        arg = _strip_erase(data.get_ptr(i))
        if isinstance(arg, Data):
            argstrs.append(simple_data(arg, program))
        else:
            argstrs.append("%s" % arg)
    return "%s(%s)" % (data.tag.str, ", ".join(argstrs))