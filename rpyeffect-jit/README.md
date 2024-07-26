# JIT'ting Effects

Pypy/RPython-based JIT for a simple bytecode language,
intended as a compilation target for [Effekt](https://effekt-lang.org/).

## Dependencies

- [Pypy/RPython](https://rpython.readthedocs.io/en/latest/)

## Build

The build process expects pypy to reside in `./pypy`.

All other dependencies (also for development) can be installed
- using [Nix](https://github.com/NixOS/nix) by running `nix-shell` in the top-level directory.
- using PIP by running `pip install -r requirements.txt`.

Run `make out/bin/rpyeffect-jit` resp. `make out/bin/rpyeffect-interpret` to build the interpreter with or without JIT.
Running `make` without parameters builds both.

## Run
The resulting interpreter can be run with parameters `<bytecode file> <arg 0> ... <arg n>`.
