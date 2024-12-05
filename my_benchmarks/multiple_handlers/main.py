import sys

def generator(n):
    i = 0
    while i <= n:
        yield i
        i = i + 1

def summing(body):
    res = 0
    for x in body():
        res = (res + x) % 1009
    return res

def counting(body):
    res = 0
    for x in body():
        res = (res + 1) % 1009
    return res

def sq_summing(body):
    res = 0
    for x in body():
        res = (res + x * x) % 1009
    return res

def run(n):
    sqs = sq_summing(lambda: (yield from generator(n)))
    s = summing(lambda: (yield from generator(n)))
    c = counting(lambda: (yield from generator(n)))
    return sqs * 1009 + s * 103 + c

if __name__ == "__main__":
    n = 5
    if len(sys.argv) > 1:
        n = int(sys.argv[1])
    print (run(n))