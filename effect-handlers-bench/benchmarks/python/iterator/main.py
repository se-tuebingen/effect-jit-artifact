import sys

def rnge(l, u):
    while l <= u:
        yield l
        l = l + 1

def run(n):
    s = 0
    for r in rnge(0, n):
        s = s + r
    return s

if __name__ == "__main__":
    n = 5
    if len(sys.argv) > 1:
        n = int(sys.argv[1])
    print (run(n))