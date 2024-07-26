#!/usr/bin/env python2
from rpyeffect.instructions import *
from rpyeffect.parse import load_program
import rpyeffect.program

class Node:
    def __init__(self, id, **attrs):
        self.id = id
        self.attrs = attrs
        self.out_edges = []
        self.in_edges = []

    def print_dot(self):
        attrs = ", ".join(("%s=\"%s\"" % (k,v) for k,v in self.attrs.items()))
        print("%s [%s]" % (self.id, attrs))
class Edge:
    def __init__(self, fr, to, **attrs):
        self.fr = fr
        self.to = to
        self.attrs = attrs

    def print_dot(self):
        attrs = ", ".join(("%s=\"%s\"" % (k,v) for k,v in self.attrs.items()))
        print("%s -> %s [%s]" % (self.fr, self.to, attrs))
class Graph:
    def __init__(self, name):
        self.name = name
        self.nodes = dict()
        self.edges = []

    def add_node(self, node_id, **attrs):
        n = Node(node_id, **attrs)
        self.nodes[node_id] = n
        return n

    def add_edge(self, fr, to, **attrs):
        e= Edge(fr, to, **attrs)
        self.nodes[fr].out_edges.append(e)
        self.nodes[to].in_edges.append(e)
        self.edges.append(e)
        return e

    def print_dot(self, node_pred = lambda x: True, edge_pred = lambda e: True):
        print("digraph \"%s\" {" % self.name)
        for node in self.nodes.values():
            if node_pred(node):
                node.print_dot()
        for edge in self.edges:
            if edge_pred(edge):
                edge.print_dot()
        print("}")

    def get_node(self, id):
        return self.nodes[id]

    def compute_reachable(self, node_id):
        for node in self.nodes.values():
            node.reachable = False
        queue = [node_id]
        while len(queue) > 0:
            c=queue.pop()
            n=self.get_node(c)
            if not n.reachable:
                n.reachable=True
                queue = queue + [e.to for e in n.out_edges]

def generate_graph(program, with_instructions = False):
    def id(index):
        if index < len(program.blocks):
            return "block%s" % index
        else:
            return "exit"

    def init_node(node):
        node.stack_shapes = [[]]
        node.codata_targets = {r: [] for r in range(program.frame_size[CODATA])}
        node.return_targets = []
        node.invoke_targets = []
        node.dirty = True
        node.reachable = False

    gr = Graph(args.bytecode)
    for block_index, block in enumerate(program.blocks):
        if with_instructions:
            content = "\n\n" + "\n".join("%d: %s" % (idx, ins.__repr__().replace("\"", "'")) for idx, ins in enumerate(block.instructions))
        else:
            content = ""
        init_node(gr.add_node(id(block_index), 
          label="%d: %s%s" %(block_index, block.name, content),
          shape = "box"))
    init_node(gr.add_node("entry", label="ENTRY", color="red"))
    n = gr.get_node(id(0))
    n.stack_shapes = [[("exit",{})]]
    n.reachable = True
    gr.add_edge("entry", id(0))
    init_node(gr.add_node("exit", label="EXIT", color="red"))

    for block_index, block in enumerate(program.blocks):
        for instruction in block.instructions:
            if isinstance(instruction, JUMP):
                e = gr.add_edge(id(block_index), id(instruction.target))
                e.conditional = False
            if isinstance(instruction, IFZERO):
                e = gr.add_edge(id(block_index), id(instruction.then.target))
                e.conditional = True
            if isinstance(instruction, PUSH) or isinstance(instruction, NEW_STACK):
                e = gr.add_edge(id(block_index), id(instruction.target), color="blue")
                e.pushed = True
            if isinstance(instruction, NEW):
                for target in instruction.targets:
                    e = gr.add_edge(id(block_index), id(target), color="green")
                    e.operation = True
            if isinstance(instruction, MATCH):
                for clause in instruction.clauses:
                    e = gr.add_edge(id(block_index), id(clause.target))
                    e.conditional = True
                e = gr.add_edge(id(block_index), id(instruction.default_clause.target))
                e.conditional = True
                e.default = True
            if isinstance(instruction, RETURN):
                gr.get_node(id(block_index)).attrs["color"] = "blue"
            if isinstance(instruction, PRIM_OP):
                gr.add_node("prim%x" % abs(hash(instruction.name)), label=instruction.name, color="yellow")
                gr.add_edge(id(block_index), "prim%x" % abs(hash(instruction.name)), color="yellow")

    for i in range(len(program.blocks)*2): # TODO how large does this bound have to be?
        changes = False
        for block_index, block in enumerate(program.blocks):
            n = gr.get_node(id(block_index))
            if not n.reachable: continue
            if not n.dirty: continue
            changes = True
            n.dirty = False
            stack_shapes = n.stack_shapes
            codata_targets = n.codata_targets

            def mk_target(target):
                target_node = gr.get_node(id(target))
                target_node.dirty = True
                target_node.reachable = True
                for stack_shape in stack_shapes:
                    if stack_shape not in target_node.stack_shapes:
                        target_node.stack_shapes.append(stack_shape)
                for k in codata_targets.keys():
                    for codata_target in codata_targets[k]:
                        if codata_target not in target_node.codata_targets[k]:
                            target_node.codata_targets[k].append(codata_target)

            for ins in block.instructions:
                if isinstance(ins, PUSH):
                    stack_shapes = [ [(ins.target, {r: codata_targets[a] for r,a in enumerate(ins.args.regs[CODATA])})] + stack_shape for stack_shape in stack_shapes]
                if isinstance(ins, NEW):
                    if ins.out in codata_targets:
                        codata_targets[ins.out].append(ins.targets)
                    else:
                        codata_targets[ins.out] = [ins.targets]
                if isinstance(ins, RETURN):
                    for stack_shape in stack_shapes:
                        if len(stack_shape) == 0: continue
                        target, cargs = stack_shape[0]
                        stack_shapes = [stack_shape[1:] for stack_shape in stack_shapes]
                        s = max(cargs.keys()) if len(cargs) > 0 else 0
                        codata_targets = { r+s: codata_targets[r] for r in codata_targets.keys() if r+s < program.frame_size[CODATA] }
                        for r, carg in cargs.items():
                            codata_targets[r] = carg
                        mk_target(target)
                        if target not in n.return_targets:
                            n.return_targets.append(target)
                if isinstance(ins, COPY) and ins.ty == CODATA:
                    codata_targets[ins.to] = codata_targets[ins.fr]
                if isinstance(ins, SWAP) and ins.ty == CODATA:
                    tmp = codata_targets[ins.a]
                    codata_targets[ins.a] = codata_targets[ins.b]
                    codata_targets[ins.b] = tmp
                if isinstance(ins, DROP) and ins.ty == CODATA:
                    codata_targets[ins.reg] = []
                if isinstance(ins, INVOKE):
                    for targets in codata_targets[ins.receiver]:
                        target = targets[ins.tag]
                        mk_target(target)
                        if target not in n.invoke_targets:
                            n.invoke_targets.append(target)
                if isinstance(ins, SHIFT):
                    stack_shapes = [stack_shape[ins.n:] for stack_shape in stack_shapes]
                if isinstance(ins, SHIFT_DYN):
                    pass #TODO
                if isinstance(ins, JUMP):
                    mk_target(ins.target)
                if isinstance(ins, IFZERO):
                    mk_target(ins.then.target)
                if isinstance(ins, MATCH):
                    for clause in ins.clauses:
                        mk_target(clause.target)
                    mk_target(ins.default_clause.target)
        if not changes: break
    for block_index, block in enumerate(program.blocks):
        n = gr.get_node(id(block_index))
        for target in n.return_targets:
            gr.add_edge(n.id, id(target), color="magenta")
        for target in n.invoke_targets:
            gr.add_edge(n.id, id(target), color="magenta")

    return gr

if __name__ == "__main__":
    from argparse import ArgumentParser
    argparser = ArgumentParser("blockgraph.py", description="Generates a graph of blocks in dot format from the given rpyeffect bytecode")
    argparser.add_argument("bytecode", help="The rpyeffect bytecode file")
    argparser.add_argument("--with-instructions", default = False, action='store_true')
    argparser.add_argument("--reachable", default=False, action='store_true')
    args = argparser.parse_args()

    program = load_program(args.bytecode)
    gr = generate_graph(program, with_instructions=args.with_instructions)
    if args.reachable:
        gr.compute_reachable("entry")
        for node in gr.nodes.values():
            if hasattr(node, "codata_targets"):
                node.attrs["label"] += ("\n %s") % node.codata_targets
        gr.print_dot(lambda n: n.reachable, lambda e: gr.get_node(e.fr).reachable and gr.get_node(e.to).reachable) 
    else:
        gr.print_dot()

