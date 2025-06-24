# JIT'ting Effects

Pypy/RPython-based JIT for a simple bytecode language,
intended as a compilation target for languages with effect handlers.

## Dependencies

- [Pypy/RPython](https://rpython.readthedocs.io/en/latest/), included in the source tree
- A version of Pypy or python 2 to compile the JIT (both work, pypy will lead to faster builds)

## Build

The build process expects a pypy checkout to reside in `./pypy`.
This is achieved using [`git subrepo`](https://github.com/ingydotnet/git-subrepo), which
can be used to update `pypy` from the upstream version.

All other dependencies (also for development) can be installed
- using [Nix](https://github.com/NixOS/nix) by running `nix-shell` in the top-level directory.
- using PIP by running `pip install -r requirements.txt`.

Run `make all` to build the interpreter and jit (with variants for the ablation study),
or `make out/bin/$(shell uname -m)-$(shell uname -s)/rpyeffect-jit` resp. `make out/bin/$(shell uname -m)-$(shell uname -s)/rpyeffect-interpret` to build the interpreter with or without JIT.

Note: Aborting the build for the ablation-study variants may change the configuration in `rpyeffect/config.py` inadvertently.

## Run
The resulting JIT can be run as `out/bin/.../rpyeffect-jit <bytecode file> <arg 0> ... <arg n>`.
