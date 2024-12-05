import sys

def primes(i, n, a):
    if i >= n:
        return a
    elif (yield i):
        gen = primes(i + 1, n, a + i)
        try:
            res = next(gen)
            while True:
                if res % i == 0:
                    res = gen.send(False)
                else:
                    res = gen.send((yield res))
        except StopIteration as e:
            return e.value
    else:
        return (yield from primes(i + 1, n, a))

def run(n):
    gen = primes(2, n, 0)
    next(gen)
    try:
        while True:
            gen.send(True)
    except StopIteration as e:
        return e.value

if __name__ == "__main__":
    n = 5
    if len(sys.argv) > 1:
        n = int(sys.argv[1])
    print (run(n))