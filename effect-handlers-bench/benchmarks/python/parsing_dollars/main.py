import sys
from dataclasses import dataclass

@dataclass
class Read: pass

@dataclass
class Emit:
    e: int

@dataclass
class Stop(BaseException): pass

def newline():
    return 10
def is_newline(c):
    return c == 10
def dollar():
    return 36
def is_dollar(c):
    return c == 36

def parse(a):
    while True:
        c = yield Read()
        if is_dollar(c):
            a = a + 1
        elif is_newline(c):
            yield Emit(a)
            a = 0
        else:
            raise Stop()

def sum(action):
    s = 0
    for e in action():
        # assert isinstance(e, Emit)
        s = s + e.e
    return s

def catch(action):
    try:
        yield from action()
    except Stop:
        return

def feed(n, action):
    i = 0
    j = 0
    gen = action()
    r = next(gen)
    try:
        while True:
            if isinstance(r, Read):
                if i > n:
                    raise Stop()
                elif j == 0:
                    i = i + 1
                    j = i
                    r = gen.send(newline())
                else:
                    j = j - 1
                    r = gen.send(dollar())
            else:
                r = gen.send((yield r))
    except StopIteration as e:
        return e.value

def run(n):
    return sum(lambda: (yield from catch(lambda: (yield from feed(n, lambda: (yield from parse(0)))))))

if __name__ == "__main__":
    n = 5
    if len(sys.argv) > 1:
        n = int(sys.argv[1])
    print (run(n))