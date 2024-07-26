## Pipeline
Eff -> Eff core -> Rpyeffect mcore --> Rpyeffect |- JIT

## Handlers in Eff-core
```ml
let rec expression = (* ... *)
  | Handler of handler_clauses
  | HandlerWithFinally of {
      handler_clauses : handler_clauses;
      finally_clause : abstraction;
    }
let rec computation = (* ... *)
  | Handle of expression * computation
```
Handlers can be passed around and then installed.

### Implementation/Encoding of those Handlers into Rpyeffect mcore
- As lambda that installs the handler and calls its argument.
- The handler (a codata/closure of its impl) is put as a binding into
  a new metastack segment with the corresponding label.
- If a handler handles multiple ops, there will be an additional stack
  segment:
  - fresh label closed over by all handlers to shift to

## Additional notes
TODO