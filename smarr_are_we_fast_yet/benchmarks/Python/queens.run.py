import queens
import sys

n = int(sys.argv[1])

for i in range(n - 1):
    queens.Queens().benchmark()
print (queens.Queens().benchmark())
