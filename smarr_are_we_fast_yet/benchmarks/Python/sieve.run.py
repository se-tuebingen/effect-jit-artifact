import sieve
import sys

n = int(sys.argv[1])

for i in range(n - 1):
    sieve.Sieve().benchmark()
print (sieve.Sieve().benchmark())
