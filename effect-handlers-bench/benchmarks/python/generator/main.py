import sys
from dataclasses import dataclass

@dataclass
class Leaf: pass

@dataclass
class Node:
    left: "Node"
    value: int
    right: "Node"

def make(n):
    if n == 0:
        return Leaf()
    else:
        sub = make(n - 1)
        return Node(sub, n, sub)

def iterate(t):
    if isinstance(t, Leaf):
        return
    else:
        yield from iterate(t.left)
        yield t.value
        yield from iterate(t.right)

@dataclass
class Empty: pass

@dataclass
class Thunk:
    value: int
    k: callable

def generate(f):
    gen = f()
    def go():
        try:
            res = next(gen)
            return Thunk(res, lambda: go())
        except StopIteration:
            return Empty()
    return go()

def sum(a, g):
    while not isinstance(g, Empty):
        a = g.value + a
        g = g.k()
    return a

def run(n):
    return sum(0, generate(lambda: (yield from iterate(make(n)))))

if __name__ == "__main__":
    n = 5
    if len(sys.argv) > 1:
        n = int(sys.argv[1])
    print (run(n))