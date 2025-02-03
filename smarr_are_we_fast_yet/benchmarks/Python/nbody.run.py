import nbody
import sys

n = int(sys.argv[1])
system = nbody.NBodySystem()
for _ in range(n):
    system.advance(0.01)

print ("%f" % system.energy())