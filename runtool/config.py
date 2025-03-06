import os

ARCH=os.popen('uname -m').read().rstrip()
OS=os.popen('uname -s').read().rstrip()
SYSTEM=f"{ARCH}-{OS}"
jit_path = os.path.abspath(f"./rpyeffect-jit/out/bin/{SYSTEM}/rpyeffect-jit")

timeout = "90s"
