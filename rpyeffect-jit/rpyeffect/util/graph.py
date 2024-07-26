from rpython.rlib.objectmodel import not_rpython

class Graph(object):
    def __init__(self, name, nodes = [], edges = []):
        # type: (Graph, str, list[str], list[tuple[str, str, str | None]]) -> None
        self.name = name
        self.nodes = nodes
        self.edges = edges

    def add_node(self, node):
        # type: (str) -> None
        if node not in self.nodes:
            self.nodes.append(node)

    def add_edge(self, fr, to, label = None):
        # type: (str, str, str | None) -> None
        if (fr,to) not in self.edges:
            self.edges.append((fr,to,label))

    def prune_unreaching(self, goal):
        # type: (list[str]) -> None
        rreachable = {g for g in goal}
        changed = True
        while changed:
            changed = False
            for f, t, _ in self.edges:
                if t in rreachable and f not in rreachable:
                    rreachable.add(f)
                    changed = True
        self.nodes = list(rreachable)
        self.edges = [(f,t,l) for f,t,l in self.edges if f in rreachable and t in rreachable]

    def prune_unreachable(self, source):
        # type: (list[str]) -> None
        reachable = {s for s in source}
        changed = True
        while changed:
            changed = False
            for f, t, _ in self.edges:
                if t not in reachable and f in reachable:
                    reachable.add(t)
                    changed = True
        self.nodes = list(reachable)
        self.edges = [(f,t,l) for f,t,l in self.edges if f in reachable and t in reachable]

    def to_dot(self):
        # type: () -> str
        nodedefs = [("\"%s\";" % (node,)) for node in self.nodes]
        edgedefs = [("\"%s\" -> \"%s\";" % (fr, to)) if lbl is None else ("\"%s\" -> \"%s\" [label=\"%s\"];" % (fr,to,lbl)) for fr, to, lbl in self.edges]
        return "digraph %s {\n%s\n%s\n}" % (self.name, "\n".join(nodedefs), "\n".join(edgedefs))

    def save_dot(self, filename):
        # type: (str) -> None
        with open(filename, "w") as f:
            f.write(self.to_dot())

    @not_rpython
    def show_dot(self, layouter = "dot", viewer = "open", oname = "./cfg.svg"):
        import tempfile, os
        with tempfile.NamedTemporaryFile(suffix = ".dot") as f:
            self.save_dot(f.name)
            os.system("%s -Tsvg %s -o %s" % (layouter, f.name, oname))
            os.system("%s %s" % (viewer, oname))