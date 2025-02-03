import bounce
import sys

n = int(sys.argv[1])

for i in range(n - 1):
    bounce.Bounce().benchmark()
print (bounce.Bounce().benchmark())
