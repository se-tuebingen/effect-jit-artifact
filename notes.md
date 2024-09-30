# Reconstructed from earlier/git
## 2022-10-28
- Env size / number of registers needs to be a constant
## 2022-10-28
- Not actually allocate unused regions, use null
  - Redevelopment: Multiple stack segment kinds might be better
## 2023-01-18
- Removing array bounds checks in favour of pre-checked register indices helps
## 2023-01-25
- Assert array bounds for loops early
## 2023-01-30
- Calling convention: Prepending arguments (as in: newly passed)
  - prevents from having to move again/caller knowing about env sizes beforehand
## 2023-02-09
- Pass program on environment construction => frame_size
## 2023-02-10
- mangle different pointer types bc of restriction on number of virtualizable arrays, and
  too precise register types means too many registers (for hardware register allocation), so bad performance
- passing global const offsets via program parameter instead of immutable field => constant-folded
## 2023-02-20
- Differentiate between live and stored (continuation, codata) environments
  - Improves performance significantly (immutability?)
- Promote jump targets for return and invoke instructions
  - specialize continuation early
## 2023-02-22
- RPython null instead of custom NULL objects => enables more reasoning by RPython
- Store doubles as ints to save on register types (cmp. pointers above)
- Generate code for the different register representations
- Inline environment into Data, CoData, Stack (generate code)
## 2023-02-23
- Use global vtables (generated at parse-time) and point to them from objects
  - => RPython can specialize to them and just guard on the ptr
- Specialized variants of Stack, Data, CoData for common environment sizes (with inlined fields)
## 2023-03-03
- Use the context information that tells us which variant of the specialized Data we will have got.
  - Uniquely determined by how the match clause parameters look like
- For codata, do the same using the vtable.
  - Those are unique by definition site!
- When shifting, assume that there will be enough stack segments (by effect safety)
- Don't store explicit type tags in data values
## 2023-03-15
- Fake loops, detect using topmost stack target
- Add "fake" can_enter_jit points beyond backjumps to make loop starts better
  - We want to see the allocation first, then the usage, so it's removed
## 2023-03-16
- Use None (actual null) as stack bottom => slight performance improvement
## 2023-03-21
- Use target to know which specialized stack (frame) type we will have
  - Uniquely determined by target if we don't do weird stuff
    - weird stuff: call with different number of parameters, relying on the
      captures to shift into place, somehow also changing the rest
## 2023-05-05
- Start writing intermediate compiler, as a compiler from HVM to rpyeffect
## 2023-06-05
- start asm-like format, compiler from there to bytecode
## 2023-06-23
- Start writing a boxing phase for boxing values when used for polymorphism
  - Go type parameter => Top => implicit coercions from/to top with boxing content
## 2023-08-09
- We should not promote constants (strings in externs)
## 2023-08-22
- shift n => shift n label
- Shallow handlers via "open" metastacks / stack segments
  - i.e. don't have a prompt
  - merge lazily on push (concat stack as pair of stacks)
## 2023-08-23
- Control support for the intermediate compiler
## 2023-08-24
- Higher-level IR for the different languages, as join point
- Jona started on eff backend
## 2023-08-25
- lambda lifting for higher-level IR
- Shift/Control has a body in higher-level IR
## 2023-08-29
- Resume gets arguments in higher-level IR
## 2023-08-30
- Write transformer from higher-level to asm-like IR
## 2023-09-20
- Annotate return type of shift/control
## 2023-10-15
- stacks: common superclass instead of one being the superclass of the other
## 2023-10-16
- disable some of the exact_class assertions now impossible
## 2023-12-01
- do not box handle return
## 2024-02-13
- Start writing koka backend
## 2024-02-23
- Dynamic code loading
  - by relocating/renumbering blocks
  - special $0 for path of the script
  - allow calling functions by symbol
## 2024-02-26
- Cache already loaded libs
## 2024-02-27
- Versioning trick to still specialize on code when loading dynamically
- Specialize call by symbol for library and symbol name
- multiple return values instead of error flag
## 2024-02-28
- Implement globals (using strings as id)
## 2024-04-05
- Initial draft of koka backend with somewhat working handlers
  - disable monadic translation, switch out key functions for handlers
## 2024-04-06
- Make LoadLib an instruction so it can divert execution to a static-init for the library
- allow static-init (needed for globals)
- special path literals (resolve at read-time!)
  - prevent path operations from ending up in tight loops
## 2024-04-08
- only execute static-init once per library (by path)
## 2024-04-11
- Monomorphize codata (methods) values for num/ptr, so we don't have to eta-expand them.
## 2024-04-12
- Use Top as argument for resume closure and use the fact that this will now be monomorphized
  => Don't box when resuming with an unboxed int and expecting one, too
## 2024-04-20
- global ref cells
  - just like backtrackable ones, but not registered in region
## 2024-04-25
- interned strings as tags for data types
  - easier to compile for (separate compilation)
  - the JIT can reason well about those
- Also expose interned strings as a object-level construct
## 2024-04-30
- mcore: Allow type annotations
## 2024-05-15
- Expose promote to object code
  - can be used to promote language-specific parts of the encoding
- Use those object-level promotes in koka to promote the current evidence vector evv
  - we want to specialize for the concrete handlers
## 2024-05-16
- Prevent overpromotion by not adhering to object-code promotes if we have seen multiple values already
- Do static optimization to remove some spurious pushes for tail-calls
## 2024-05-24
- We need to restore the evv when resuming
## 2024-05-29
- Evidence vectors in koka are sorted by handler name, fix
## 2024-06-04
- Local mutable state in koka
## 2024-06-07
- Change Effekt backend for new translation of effects
  - Directly use codata, shift-to-label (no handler-sugar)
## 2024-06-28
- Support for dynamic binding via special stacks with *one* dynamic binding
  - lookup based on label
## 2024-07-02
- Start adjusting Eff backend started by Jona
## 2024-07-10
- Start implementing handlers in Eff backend
# 2024-07-11
- Eff benchmarks now run on jit.
- [in the log for countdown](./notes-ref/eff-jit_countdown_2024-07-11.log), we allocate some stack.
  also, it can see through most of it, but checks that stack etc didn't change (by ptr eq).
  Then, it specializes to a simple counter, although the code would have actually generated closures.
- Benchmark results:
  ![relative](./notes-ref/Screenshot%202024-07-11%20at%2016.39.41.png)
  ![absolute](./notes-ref/Screenshot%202024-07-11%20at%2016.40.44.png)
# 2024-07-17
- non-naive implementation with multiple segments for multiple handler clauses, and separate instructions dynamic binding/continuation capture
- Effekt passes handlers in registers, Eff on stack
- Add allocation site to label, promote and compare first
  - might make handler sieve worse at new_with_vtable 8?
# 2024-07-18
- results before this change backupped to [notes-ref](./notes-ref/resback20240718/), jit at cc2df3a
- results after, no promote yet backupped to [notes-ref](./notes-ref/resback20240718_2/), jit at 8fde10d
- results after, with promote backupped to [notes-ref](./notes-ref/resback20240718_3/), jit at ca41098
- TODO: Make benchmarks for unused handlers, benchmark by number, with:
   - best case: different handler
   - worst case: all with label from same program position
   - pushing on the outside? (copy stack?)
   - https://dl.acm.org/doi/pdf/10.1145/2887747.2804319
- TODO Skynet benchmark from Jonas thesis?
- TODO Coroutine standard benchmarks?
  - http://aleksandar-prokopec.com/resources/docs/coroutines-ecoop.pdf
# 2024-07-19
- benchmark multiple_handlers implemented in eff: plain-ocaml times out, current jit is sim. to koka-vm
- unused_handlers (with 10 unused handlers) implemented in koka,eff. Compared to countdown:
  - effekt-ml cant run (eff.poly.rec.)
  - effekt-jit abt same time as countdown, so for other jit backends
  - koka-c,eff-plain-ocaml also like before
  - effekt-llvm a lot slower, koka-js somewhat (10%)
# 2024-07-24
- benchmark to_outermost_handler for koka.
  - eff seems impossible? We can't mask, it's always dynamic
  - koka has problems with incrementing boxed ints (re-unbox, inc, box in trace)
- this + restriction on polymorphic equals (esp. Eff): Maybe drop erased ptrs and switch to Value type?
  - Strings? io streams? (byte)arrays? (the rest should mostly just work)
  - @CF: Vptrs? worth it?
  - if we do, we probably want to also use ints for chars
# 2024-07-25
- to_outermost_handler over number of handlers:
  - ![absolute](./notes-ref/to_outermost_handler_plot0.png)
  - ![absolute](./notes-ref/to_outermost_handler_plot1.png)
  - Weird non-continuity: Trace gets too long, see [log](./notes-ref/to_outermost_handler_effekt_41.log)
    - in koka: see log [log](./notes-ref/to_outermost_handler_koka_41.log)
      - not optimized out statically, at least mask is still in generated code
  - results stored [here](./notes-ref/resback20240725/)
- hnd.kk:668 makes tail resumption non-tail
# 2024-07-31 / Meeting
## Questions to ask CF
- opt from last time (first check label origin): Makes worse in equal case?
  - note: worst part in countdown is boxing
- Trace too long problem (07-25)
- polymorphic equals/RTTI and boxes (see 07-24) - did not get to that, ask later
## Notes from meeting
- microbenchmark with dynamic number of handlers in between - growing_cont
- TODO benchmark to_outermost_handler fully
- TODO trmc that fails statically?
  - future work: jit-trmc
# 2024-07-31
- Maybe create set/matrix of benchmarks for different (explicit!) scenarios:
  - label dynamic/static
  - handlers in between static/dynamic/limited/...
  - handlers tail/nontail/... linear/...
  - ...
  - Potentially: parametrized (generated) benchmark code
# 2024-09-18 / meeting with CF
- for erased ptr type info
  - guard_is_object ? - ask gc
  - "implement a try_cast_erased function" newly committed to pypy
  - TODO UPDATE PYPY!! - DONE
- parser for jit logs: rpython/jit/tool/oparser.py
# 2024-09-20
- Updated Pypy => [results](./notes-ref/resback20240920_1/)
- Started using try_cast_erased to optimize Ref to NumBox
  - Problem: still allocates for the argument to try_cast_erased - @cf: hard to fix?
    ```jit-log
    +1108: p115 = new_with_vtable(descr=<SizeDescr 16>)
    +1216: p117 = call_r(ConstClass(try_cast_erased__NumBox), p115, descr=<Callr 8 r EF=2>)
    +1252: setfield_gc(p115, i114, descr=<FieldS rpyeffect.region.NumBox.inst_value 8 pure>)
    ```
# 2024-09-25
- Started writing tooling for jit trace logs in [runtool](./runtool/util/jitlogparser.py)
# 2024-09-26 / Meeting with jona
- Introduction, Forschungsfrage: How well do tracing jits work for effect handlers?
- Takeaways, insights ?
- Audience? - wants to impl tracing jit for lang with effect handlers
- (Compare with Python/Pypy ?)
- Why not wasm?
  - different level
  - implementation effort?
  - source languages with effect handlers?
  - jitting for wasm?