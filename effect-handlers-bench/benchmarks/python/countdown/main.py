import sys
from dataclasses import dataclass

@dataclass
class Get: pass

@dataclass
class Set:
    value: int

def countdown():
    i = yield Get()
    while i != 0:
        yield Set(i - 1)
        i = yield Get()
    return i

def run(n):
    s = n
    try:
        gen = countdown()
        res = next(gen)
        while True:
            if isinstance(res, Get):
                res = gen.send(s)
            else: 
                # assert isinstance(res, Set)
                s = res.value
                res = next(gen)
    except StopIteration as r:
        return r.value

if __name__ == "__main__":
    n = 5
    if len(sys.argv) > 1:
        n = int(sys.argv[1])
    print (run(n))