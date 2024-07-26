import permute
import sys

n = int(sys.argv[1])

for i in range(n - 1):
    permute.Permute().benchmark()
print (permute.Permute().benchmark())
