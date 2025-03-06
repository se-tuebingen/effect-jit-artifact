
## Prerequisites

For the below instructions to work, you need to have `nix` [TODO Link] installed.
Otherwise, you will have to manually ensure that all dependencies are installed.
Also, the benchmarking tool will directly use `nix` to benchmark Ocaml 5.
The `shell.nix` files in the respective subfolders should list all the necessary dependencies.

## Running

- Run `nix-shell` to enter an environment where the necessary systems are installed.
- Run `./run run <implementation> <benchmark>` to run one of the benchmarks once, seeing it's output

## Benchmarking

TODO

## Compiling from source

If you are on a x86 architecture running linux, you can just use the pre-compiled binaries.

### Compiling the JIT compiler

- Go into `./rpyeffect-jit`
- enter a nix-shell (installing the necessary dependencies) by running `nix-shell`
- run `make out/bin/$(uname-m)-$(uname -s)/rpyeffect-jit`
  - to compile other variants, change the target appropriately. run `make all` to compile all available variants.

### Compiling the middle-end

- Run `nix-shell` here (or make sure `sbt` is available)
- Go into `./rpyeffect-asm`
- run `sbt stage`

### Compiling kklib

- Run `nix-shell` here (or make sure `cmake` and `make` are available)
- go to `koka/kklib`
- run `cmake .`
- run `make`

## Notes for MacOS
- On MacOS, the package for mlton does not work, so it will have to be installed manually (e.g. via brew)