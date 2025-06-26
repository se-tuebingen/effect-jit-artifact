# Introduction
<!-- TODO briefly explain the purpose of the artifact and how it supports the paper. We recommend listing all claims in the paper and stating whether or not each is supported. For supported claims, say how the artifact provides support. For unsupported claims, explain why they are omitted. -->
This artifact contains both the described JIT, the frontends for the different languages,
alongside the middleend and the benchmarks. It also contains the other implementations of those languages
used for benchmarking.

It is provided to support our answers to the research questions posed in the paper:
- For **RQ 1** ("How does tracing JIT compilation compare with existing ahead-of-time optimizing implementations of effect handlers?"),
  we claim in the paper:
  > Benchmark results comparing our implementation to AOT optimizing compilers show a competetive performance both over most existing
  > implementations of effect handlers and state-of-the-art language implementations for programs with control effects

  This is supported by the provided benchmark results for different implementations of Eff, Effekt, and Koka,
  as well as the implementations and tooling needed to generate those results.

- For **RQ 2** ("What are classes of effectful programs that tracing JIT compilation can optimize well? What are the limitations of the approach?"),
  we claim in the paper:
  > Effect handlers that use the continuation in a one- shot and tail manner, or as exceptions, are optimized very well by the JIT

  This is supported by the benchmark programs, and the traces from JITting them (in `./.jitlogs/*.log`),
  alongside the implementations and tooling needed ot generate those results.

- For **RQ 3** ("How can we optimize the performance of tracing JIT compilation for effect handlers?"),
  we claim in the paper:
  > Standard optimizations for using the stack context to detect false loops (Section 4.1.4) and specializing certain dynamically sized data structures (Section 4.1.3) have a positive effect.

  and:
  > Additional optimizations for prompt search (Section 4.1.2) and loop start points (Section 4.1.1) have a minor effect and only help with specific benchmarks.

  Those claims are supported by the results of the ablation study, alongside the implementations and tooling needed to generate those results.
  The results of the ablation study are the results for the `-jit` (resp. `-vm` for koka) implementations and their modified variants (`-jit-` resp. `-vm-`).

- For **RQ 4** ("Are there differences in how well tracing JIT compilation performs for different variations of effect handlers?"),
  we claim in the paper:
  > Most differences in the performance are minor in nature.

  This is supported by the benchmarking results for the JIT for Eff, Effekt, and Koka.

  We then list some differences:
  > The adjustment of evidence vectors in Koka can lead to allocations when changing the handler context.
  > [T]he tracking of handlers in evidence vectors in Koka can help to avoid traversing deep stacks in some cases.

  > The prompt search in Eff tends to generate more guards, as it is harder for the JIT to reason about them

  All of these are supported by the traces and benchmarking results for the respective JIT backends
  (in relation to the others).

- For **RQ 5** ("Does JIT-compiling effect handlers impact the performance of programs that do not use effects?"),
  we claim that

  > The implemented JIT is similar in performance to PyPy for our set of baseline benchmarks, but is outperformed by some state-of-the-art JIT compilers (V8, LuaJIT) by a factor of 2–3x. For control-effect-heavy benchmarks, though, we outperform even state-of-the-art language implementations like V8.

  This is supported by the benchmarking results of those other language implementations in comparison with ours,
  on the included subset of the "Are we fast yet?" benchmarks.

# Hardware Dependencies
<!-- TODO describe the hardware required to evaluate the artifact. If the artifact requires specific hardware (e.g., many cores, disk space, GPUs, specific processors), please provide instructions on how to gain access to the hardware. Keep in mind that reviewers must remain anonymous. -->

- Free disk space: 64 GB
- One of the following:
  - Linux running on x86_64
  - macOS running on M1/M2/M3/M4.
- Good internet connection and somewhat recent hardware
  (otherwise, some of the commands will run for longer).

# Getting Started Guide
<!-- TODO give instructions for setup and basic testing. List any software requirements and/or passwords needed to access the artifact. The instructions should take roughly 30 minutes to complete. Reviewers will follow the guide during an initial kick-the-tires phase and report issues as they arise.

The Getting Started Guide should be as simple as possible, and yet it should stress the key elements of your artifact. Anyone who has followed the Getting Started Guide should have no technical difficulties with the rest of your artifact. -->

## Install Nix
If you haven't already, install the Nix package manager as described [here](https://nixos.org/download/)

## Submodules
Effekt and Koka rely on git submodules for parts of their implementation (kiama resp. mimalloc).
To download them, please use `git submodule update --init` after downloading this repository.

## Compile the individual tools
In the root directory run
```sh
./run setup
```
to install all dependencies and compile all the language implementations, the JIT in all variants, and the middleend.
This will some time (25min on a M1 MacBook), but can be left running in the background.

Note: Although binaries for some of the tools are included, this will still recompile them to ensure compatibility with
the given system.

## Run a minimal program for each implementation, once
*If you haven't, enter an environment where all dependencies are available by running `nix-shell` (without arguments) in the root directory of the artifact.*

Using `./run run all startup`, you can compile and run the `statup` benchmark --- which computes
a constant 0 function --- for each of the language implementations, once (taking about 3min on an M1 MacBook).
If this succeeds without any errors, everything should be setup correctly.
Compilation should result in different output, starting with `COMPILING` and ending with `DONE.` each.
More importantly, the output should end with multiple repetitions of output similar to the following (one per language implementation):

```out
RUNNING ['/Users/gaisseml/dev/effect-jit-artifact/rpyeffect-jit/out/bin/arm64-Darwin/rpyeffect-jit-2-context', '/Users/gaisseml/dev/effect-jit-artifact/.effekt-out/effekt-jit-2-context:startup_e80a2bff-3c68-4aaa-b0b5-38d9c90c59dc/main.rpyeffect', '50000000']
RUNNING timeout 90s /Users/gaisseml/dev/effect-jit-artifact/rpyeffect-jit/out/bin/arm64-Darwin/rpyeffect-jit-2-context /Users/gaisseml/dev/effect-jit-artifact/.effekt-out/effekt-jit-2-context:startup_e80a2bff-3c68-4aaa-b0b5-38d9c90c59dc/main.rpyeffect 50000000
run | 0
DONE
OK
```

There should be no `ERROR` output (instead of the "DONE") for the runs.

# Step by Step Instructions
<!-- TODO explain how to reproduce any experiments or other activities that support the conclusions in your paper. Write this for readers who have a deep interest in your work and are studying it to improve it or compare against it. If your artifact runs for more than a few minutes, point this out, note how long it is expected to run (roughly) and explain how to run it on smaller inputs. Reviewers may choose to run on smaller inputs or larger inputs depending on available resources.

Be sure to explain the expected outputs produced by the Step by Step Instructions. State where to find the outputs and how to interpret them relative to the paper. If there are any expected warnings or error messages, explain those as well. Ideally, artifacts should include sample outputs and logs for comparison. -->

## Running all benchmarks
*If you haven't, enter an environment where all dependencies are available by running `nix-shell` (without arguments) in the root directory of the artifact.*

Note: Running all benchmarks in the same way as for the paper (with warmup runs, a 90s timeout, and 20 runs each)
**takes a lot of time (~14h)**. If you want to do so regardless, you can use the following command:
```sh
./run benchmark-for-paper
```

Otherwise, you can run the benchmarks with a small timeout and number of runs using:
```sh
./run benchmark-for-paper --quick
```
**This still will take about 1h** --- you can reduce this time further as described below.
As far as possible, run this on a quiet machine. The reduced number of runs will already result in relatively
large noise in the results.

### Comparing the outputs
The resulting outputs are shown as tables in the terminal.
Using `./run report $implementations $benchmarks`, individual subsets can be shown.
For the paper, the following are relevant combinations (format copy-pasteable into the above):

- Benchmarks `suite:effect-handlers-bench,counter,multiple_handlers,startup,to_outermost_handler,unused_handlers` (Figure 5),
  on implementations (mostly RQ 1)
  - `eff-jit,eff-plain-ocaml,oldeff-plain-ocaml` for the comparison within Eff
  - `effekt-jit,effekt-llvm,effekt-js,effekt-ml` for the comparison within Effekt
  - `koka-vm,koka-c,koka-js` for the comparison wihtin Koka
  - `eff-jit,effekt-jit,koka-vm` for the comparison between the JIT implementations (cmp. RQ 4)
- `effekt-jit,js-v8,python-cpython,python-pypy,lua-lua,lua-luajit suite:are-we-fast-yet` for the baseline results not using effects (cmp. RQ 5)
- `eff-jit,effekt-jit,ocaml5,js-v8,koka-vm,python-cpython,python-pypy countdown,fibonacci_recursive,generator,handler_sieve,iterator,multiple_handlers,parsing_dollars,product_early,resume_nontail,startup`
  for the baseline comparison with effectful programs (cmp. RQ 5).

For comparison, the results from the paper can be shown using `./run report --root results_x86 $implementations $benchmarks`
(resp. using `results_m1` for the results generated on M1).
Each table is printed twice, once with relative numbers (slowdown compared to the fastest shown) and once absolute (in seconds).

The individual outputs will of course differ depending on specific hardware, and measurement noise will have distorted them
slightly (especially when using `--quick` above). Thus, you should mostly check that the relative results are in a similar
direction and order of magnitude.

### Saving time: Decrease the number of runs
In `./runtool/config.py`, you can change the parameters passed to `hyperfine`,
in particular, you want to change the following lines to use fewer runs (without `--quick`):
```python
hyperfine_opts = [
    "-w", "2", # warmup runs
    "-m", "20", # at least 20 runs (default is 10)
    "--min-benchmarking-time", "6", # minimum benchmarking time in seconds (default is 3)
```
The respective options for `--quick` are defined inside the function definition `quick`.

### Saving time: Decrease the timeout
In `./runtool/config.py`, you can change the timeout after which benchmarks are stopped.
Benchmarks that run longer than this on the test run will not be run using `hyperfine`
during benchmarking.
```python
# Timeout after which to consider a program to fail (and not run multiple times)
timeout = "90s"
```
The respective options for `--quick` are defined inside the function definition `quick`.

### Saving time: Only run some benchmarks
Of course, it is also possible to save time by running just a subset of the benchmarks.
Most subcommands (in particular `run`, `benchmark`, `report`) take
the set of implementations and benchmarks as command-line parameters, e.g.
`./run run eff-jit,koka-vm triples,startup`
will run the `triples` and `startup` benchmarks on `eff-jit` and `koka-vm` (the Koka JIT backend).

Note that the results files are per-benchmark, over all languages, so all other results for the given
benchmark will be overwritten.

## Generating trace logs
*If you haven't, enter an environment where all dependencies are available by running `nix-shell` (without arguments) in the root directory of the artifact.*

To generate the trace log for one (or multiple) benchmarks, run
```sh
./run jitlog $implementations $benchmarks
```

The trace logs generated to `.jitlogs` end with a summary. Here, the numbers of loops and bridges should not differ by a large number from the ones for the paper results
(in `./results_x86/.jitlogs` resp. `./results_m1/.jitlogs`).
Also, the loop should be similar, which however is non-trivial to check.

# Reusability Guide
<!-- TODO explain which parts of your artifact constitute the core pieces which should be evaluated for reusability. Explain how to adapt the artifact to new inputs or new use cases. Provide instructions for how to find/generate/read documentation about the core artifact. Articulate any limitations to the artifact’s reusability. -->

## The JIT implementation
The main part of the artifact is the RPython-based JIT implementation, to be found in `./rpyeffect-jit`.
To compile the JIT itself, a version of Python 2 and the (contained) PyPy-checkout,
or a version of the `rpython` tool from there, are enough. The dependencies are there to simplify the
usage of debug tooling etc.
The (small) test suite can be run using `make test` in the `rpyeffect-jit` directory.

## The Middleend
To simplify writing the language backends, a common middleend was created to transform the intermediate representation
generated by the language frontends to the JIT "byte"code.
It can be found in `./rpyeffect-asm` and is a mostly standard micro-pass compiler written in Scala.

## The language backends
The three language implementations can be found in `./effekt`, `./koka` resp. `./eff`.
All that was changed from the upstream version in each case was adding an additional backend,
called `jit` (or `vm` in the koka case).
They all generate the input format for `rpyeffect-asm`, which has a JSON and an s-exp syntax.
`rpyeffectasm` (the binary) can also convert between the two if needed by using, e.g.:
```sh
rpyeffect-asm/target/universal/stage/bin/rpyeffectasm -f mcore-json -t mcore-sexp $inputfile $outputfile
```

## The benchmarking infrastructure
To add a new implementation/language to benchmark against, add a new subclass of `Language` (defined in `./runtool/language/__init__.py`)
as was done for the others and add an instance to the list in `./runtool/language/all.py`.
The `compile` function is supposed to do any necessary compilation work and return a shell command (as a list) used to run the resulting program.
You might also need to change some of the benchmark suites in `./runtool/suite/` to return the correct benchmark files for the new implementation/language.