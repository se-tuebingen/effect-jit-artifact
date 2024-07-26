import storage
import sys

n = int(sys.argv[1])

for i in range(n - 1):
    storage.Storage().benchmark()
print (storage.Storage().benchmark())
