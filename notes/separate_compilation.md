# Notes on new feature: Separate compilation / dynamic loading
- New (red) program var in rpython: current program
- New instructions:
  - `load <filename:str>` returning a `Lib` (whatever that is)
  - `call <lib:Lib> <function:str> <args:...>`
    - mapping function -> index can be cached on first call
  - Both could be primitives
  - Potentially: Lazy load
- This would be the *most dynamic* way.

## Implementation
- We need to know in which program we currently are
- Variant 0: Annotating every pc/target 
  - is maybe costly, needs lots of source changes
- Variant 1:
  - Always have "current" program
  - `call` installs *special* program-switch frame
    - needs to be treated somewhat special by shift:
      - bubble last before split point to current stack
      - add one to every continuation (or to every continuation passed between programs)
- Variant 2:
  - shadowstacks for program
- Variant 3:
  - Force stack segments to be mono-program, install a new segment on switch
    - store program there
    - Needs to check program *on each return*
    - Needs to check program *on push* (so it is on the correct stack)
- Variant 4:
  - Relocate on load: I.e., when `load`ing a library, increment *all* targets by some `offset`.
    Then use those.
    - Does not need fancy stack management (everything "just works")
    - Maybe longer load times (but those should be dominated by parsing, which could track the offset, too)
    - What to do with diamonds? -- We need to keep track of loaded files!
  - If we do this and cache on first call, library calls become (almost) actual jumps afterwards.
  - Have to make `blocks` only quasi-immutable (but initial measurements suggest this is not a problem)


## Alternatives
- Static dependencies: Specify dependencies on toplevel
  - Only slightly simpler, but bigger change to program structure


## Additional considerations
- For static values in libraries, we need some soltion
  - Introduce special "globals"
  - Allow library init code


---------------------------

main:
0
1   call lib 12 -- jump 17
2
3
4
5 0
6 1
...


lib:
0
1
2
3
4