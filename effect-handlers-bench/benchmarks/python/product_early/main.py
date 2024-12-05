import sys
from dataclasses import dataclass

@dataclass
class Cons:
    hd: int
    tl: "Cons | None"

@dataclass
class Done(BaseException):
    value: int

def product(xs):
    if xs is None:
        return 0
    else:
        if xs.hd == 0:
            raise Done(0)
        else:
            return xs.hd * product(xs.tl)

def enumerate(i):
    if i < 0:
        return None
    else:
        return Cons(i, enumerate(i - 1))

def run_product(xs):
    try:
        return product(xs)
    except Done as e:
        return e.value

def run(n):
    xs = enumerate(1000)
    i = n
    a = 0
    while i != 0:
        i = i - 1
        a = a + run_product(xs)
    return a

if __name__ == "__main__":
    n = 5
    if len(sys.argv) > 1:
        n = int(sys.argv[1])
    print (run(n))