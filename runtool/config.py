import os

class Config: # is a class so it is by reference...
    # System options, autodetection should work and no changes be necessary
    ARCH=os.popen('uname -m').read().rstrip()
    OS=os.popen('uname -s').read().rstrip()
    SYSTEM=f"{ARCH}-{OS}"
    jit_path = os.path.abspath(f"./rpyeffect-jit/out/bin/{SYSTEM}/rpyeffect-jit")

    # Timeout after which to consider a program to fail (and not run multiple times)
    timeout = "90s"

    # Hyperfine config
    hyperfine_opts = [
        "-w", "2", # warmup runs
        "-m", "20", # at least 20 runs (default is 10)
        "--min-benchmarking-time", "6", # minimum benchmarking time in seconds (default is 3)
        "-N", # do not run an intermediate shell
    ]

    def quick():
        """Set the options to the values used when passing --quick"""
        Config.timeout = "6s"
        Config.hyperfine_opts = [
        # no warmup
        "-m", "2",
        "--min-benchmarking-time", "2",
        "-N",
        ]