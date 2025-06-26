
## Prerequisites

For the below instructions to work, you need to have [`nix`](https://nixos.org/download/) installed.
Otherwise, you will have to manually ensure that all dependencies are installed.
Also, the benchmarking tool will directly use `nix` to benchmark Ocaml 5.
The `shell.nix` files in the respective subfolders should list all the necessary dependencies,
should you wish to install them manually.

## Compiling

While the compiled binaries are provided with the artefact, they might not work on all systems.
Note that in addition to the following, some of the implementations need to be compiled, too.
To compile everything, use:
```sh
./run setup
```

### Compiling the JIT

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

## Running

- Run `nix-shell` to enter an environment where the necessary systems for benchmarking are installed.
- Run `./run run <implementation> <benchmark>` to run one of the benchmarks once, seeing it's output
  (multiple implementations and benchmarks are possible, see below in Benchmarking).

## Benchmarking

- `./run benchmark-for-paper` will run the combinations of benchmarks and backends we ran for the paper.
  Note that this will take multiple hours (it took >12 hours on the benchmarking machine).
- Using `./run <implementation> <benchmarks>`, individual benchmarks can be run for specific backends.
  Both are `,`-separated, e.g. `./run eff-jit,effekt-jit,koka-vm startup,countdown`.
  - Some sets of benchmarks have short names, in particular:
    - `suite:effect-handlers-bench` refers to the benchmarks from the [community benchmark suite](https://github.com/effect-handlers/effect-handlers-bench)
    - `suite:are-we-fast-yet` refers to the benchmarks adapted from TODO
    - `suite:my_benchmarks` refers to the additional benchmarks created by us.
- Note: Each benchmark is run via an individual invocation of `hyperfine` by benchmark (for all backends).
  Thus, running the same benchmark for `eff-jit` and later for `effekt-jit` will delete the result for `eff-jit`.

### Saving time when benchmarking

- In `./runtool/config.py`, a `timeout` is set after which a benchmark is considered to run unsuccessfully
  (and thus not run multiple times).
- In the same file, you can change the options passed to `hyperfine`, in particular the number of runs.

## Generating JIT logs (for qualitative analysis)
- For the JIT-based implementations, `./run jitlog <implementations> <benchmarks>` will generate
  JIT logs in `./.jitlogs/`.

## Showing results

The benchmarking results from the paper are in the directory where they would be written to by Benchmarking.
Note that, thus, they will be overwritten by benchmarking.
There are multiple ways to access the results

- The raw benchmarking data output by `hyperfine` (in JSON format) can be found in:
  `./.results/.<benchmark>-results.json`
- The data can be rendered to a summary table in the shell using `./run report <implementations> <benchmarks>`,
  which will also show relative numbers for this set of implementations.
  - The same table can be exported to a TSV using `./run export-tables ...` and to TeX code using `./run export-tex-tables ...`
- The tables shown in the paper (and appendix) can be generated
  - using `./run export-all-paper-tables-tsv` as TSV (this additionally generates relative variants) and
  - using `./run export-all-paper-tables` as TeX files
  - both write the results to `./.exported/paper_tables/`.
    Alternatively, all file paths are prefixed with the optional `--target`.
    (i.e. `--target some-other-dir/foo` will write them to `some-other-dir`, and prefix the filenames with `foo`)

## Directory structure
```
.
├── README.md  - this file
├── implementation_descriptions  - TODO Drop?
│
│ # Language implementations
├── rpyeffect-jit  - Implementation of the JIT
│   └── shell.nix  - Definition of dependencies needed for compiling the JIT (sim. for others)
│
├── eff        - modified version of Eff
├── oldeff     - version of Eff at the OOPSLA artefact TODO
├── effekt     - modified version of Effekt
├── effekt-ml  - last version of Effekt supporting the MLton backend
├── koka       - modified version of Koka
├── rpyeffect-asm  - Common middleend compiling to the actual JIT "byte"code
│
│ # Benchmark code
├── effect-handlers-bench           - community benchmarks, adapted to work with above versions
├── effect-handlers-bench-upstream  - community benchmarks, upstream version
├── effekt_are_we_fast_yet          - implementation of the "Are we fast yet?"-benchmarks considered
├── smarr_are_we_fast_yet           - original implementations of the "Are we fast yet?"-benchmarks
├── my_benchmarks                   - Additional benchmarks implemented by us
│
│ # Tooling
├── run      - Python script to run benchmarks and collect results
├── runtool  - Implementation of parts of `run`.
│   ├── language   - This contains the logic of how to run certain implementations
│   └── config.py  - Configuration for certain aspects of how to run benchmarks
├── shell.nix  - Definition of dependencies needed for running the benchmarks
│
│ # Results
├── .eff-out, .oldeff-out, .effekt-out  - compiled versions of the benchmarks in Eff/Effekt
├── koka/.koka/<version>                - compiled versions of the benchmarks in Koka
├── .outputs      - outputs of running the benchmark programs
├── .runcmds      - Commands used to run the benchmarks, as shell scripts
├── .results      - Measurement data of the benchmarks, as json files `.<benchmark>-results.json`
│
│ ## Results from the paper (structured exactly like results)
├── results_x86   - Raw data from the benchmarking results of the paper (on x86)
└── results_m1    - Raw data from the benchmarking results of the paper (on M1, only in appendix)
```