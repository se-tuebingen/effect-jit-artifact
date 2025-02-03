import towers
import sys

n = int(sys.argv[1])

for i in range(n - 1):
    towers.Towers().benchmark()
print (towers.Towers().benchmark())
