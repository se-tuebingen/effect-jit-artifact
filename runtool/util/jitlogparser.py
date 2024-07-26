import re
import sys
from dataclasses import dataclass
from typing import Callable

def file_lines(file):
    with open(file) as f:
        for line in f:
            yield line

def split_logfile(lines):
    r_start = re.compile(r"\[([0-9a-fA-F]+)\] \{([\w-]+)" + "$")
    r_stop  = re.compile(r"\[([0-9a-fA-F]+)\] ([\w-]+)\}" + "$")
    cur = []
    cur_tpe = None
    nested = 0
    for line in lines:
        m = r_start.match(line)
        if m and nested == 0:
            nested = 1
            cur_tpe = m.group(2)
            continue
        if m: nested += 1
        me = r_stop.match(line)
        if me and nested == 1:
            nested = 0
            yield (cur_tpe, cur)
            cur = []
            continue
        if me: nested -= 1
        cur.append(line)

@dataclass
class Op:
    raw: str

@dataclass
class Op_(Op):
    pass

@dataclass
class Op_guard(Op):
    descr: str

@dataclass
class Op_debug_merge_point(Op):
    pos: str

@dataclass
class Op_label(Op):
    descr: str

@dataclass
class Op_guardfail(Op):
    descr: str

@dataclass
class Op_jump(Op):
    descr: str

@dataclass
class Loop:
    name: str
    labels: dict[str, int]
    ops: list[Op]

@dataclass
class Bridge(Loop):
    pass    

@dataclass
class Loops:
    loops: list[Loop]
    labels: dict[str, (int, int)]
 
r_label = re.compile(r"([+][0-9]+:)? *label\([pi0-9, ]*descr=(.*)\)" + "$")
def parse_op(line):
    r_op_debug_merge_point = re.compile(r"debug_merge_point\(0, 0, '(.*)'\)" + "$")
    m = r_op_debug_merge_point.match(line)
    if m:
        return Op_debug_merge_point(line, m.group(1))

    m = r_label.match(line)
    if m:
        return Op_label(line, m.group(2))

    r_op_jump = re.compile(r"([+][0-9]+:)? *jump\([pi0-9, ]*descr=(.*)\)" + "$")
    m = r_op_jump.match(line)
    if m:
        return Op_jump(line, m.group(2))
    
    r_op_guard = re.compile(r"([+][0-9]+:)? *guard_([a-zA-Z0-9_]*)\(.*?, descr=(.*)\).*" + "$")
    m = r_op_guard.match(line)
    if m:
        return Op_guard(line, m.group(3))

    return Op_(line)

def parse_loop(lines):
    r_loopstart = re.compile(r"[#] *([a-zA-Z0-9 -]*?) *\((.*)\)[^)]*" + "$")
    r_loopend = re.compile(r"([+][0-9]+:)? *[-][-]end of the loop[-][-]" + "$")

    m_loopstart = r_loopstart.match(lines[0])
    assert(m_loopstart)
    name = m_loopstart.group(1)

    labels = dict()
    content = []
    
    for line in lines[2:]:
        m_label = r_label.match(line)
        if m_label:
            labels[m_label.group(2)] = len(content)
        
        if r_loopend.match(line):
            break

        content.append(parse_op(line))
    
    return Loop(name, labels, content)

def parse_bridge(lines):
    r_bridgestart = re.compile(r"[#] *bridge out of Guard ([x0-9a-fA-F]*) with.*")
    
    m_bridgestart = r_bridgestart.match(lines[0])
    if m_bridgestart:
        gt = m_bridgestart.group(1)
    else:
        gt = "???"

    labels = dict()
    start = Op_guardfail(lines[0], f"<Guard{gt}>")
    content = [start]
    
    for line in lines[2:]:
        m_label = r_label.match(line)
        if m_label:
            labels[m_label.group(2)] = len(content)
        
        content.append(parse_op(line))
    
    return Bridge(f"bridge out of <Guard{gt}>", labels, content)

def parse_loops(lines):
    loops = []
    labels = dict()
    for kind, content in split_logfile(lines):
        if kind == "jit-log-opt-loop":
            l = parse_loop(content)
            for k, v in l.labels.items():
                labels[k] = (len(loops), v)
            loops.append(l)
        if kind == "jit-log-opt-bridge":
            l = parse_bridge(content)
            for k, v in l.labels.items():
                labels[k] = (len(loops), v)
            loops.append(l)
    return Loops(loops, labels)

def print_loop_as_dot(loop: Loop, op_labeler: Callable[[Op], str | None], edge_ops: str):
    last = None
    for op in loop.ops:
        cur = op_labeler(op)
        if cur is not None:
            if last is not None and cur != last:
                print(f"   \"{last}\" -> \"{cur}\" [{edge_ops}]")
            last = cur

def print_loops_as_dot(loops: Loops, op_labeler: Callable[[Op], str | None]):
    print("digraph {")
    colors = ["aqua", "brown", "crimson", "gold", "indigo", "fuchsia", "lawngreen", "plum", "red", "teal", "tomato",
              "magenta", "khaki", "rosybrown", "navy", "olive", "hotpink", "salmon", "mediumaquamarine"]
    i = 0
    for loop in loops.loops:
        print_loop_as_dot(loop, op_labeler, f"color=\"{colors[i]}\"")
        i += 1
    print("}")

def block_id_labeler(op):
    if isinstance(op, Op_debug_merge_point):
        return re.match(r"([0-9]*)[<]", op.pos).group(1)

def block_label_labeler(op):
    if isinstance(op, Op_debug_merge_point):
        return re.match(r"[0-9]*[<]([^>]*)[>]", op.pos).group(1)

def jmp_label_labeler(op):
    if isinstance(op, Op_jump):
        return op.descr
    if isinstance(op, Op_label):
        return op.descr
    if isinstance(op, Op_guard):
        return op.descr
    if isinstance(op, Op_guardfail):
        return op.descr

def smart_jmp_labeler(loops: Loops):
    def res(op):
        if isinstance(op, Op_jump):
            return op.descr
        if isinstance(op, Op_label):
            return op.descr
        if isinstance(op, Op_guard) and any(isinstance(loop.ops[0], Op_guardfail) and loop.ops[0].descr == op.descr for loop in loops.loops):
            return op.descr
        if isinstance(op, Op_guardfail):
            return op.descr
        ...
    return res

if __name__ == "__main__":
    loops = parse_loops(file_lines(sys.argv[1]))
    print_loops_as_dot(loops, lambda op: smart_jmp_labeler(loops)(op) or block_label_labeler(op))