## Pipeline
Effekt -> Effekt core -> Rpyeffect mcore --> Rpyeffect |- JIT

## Handlers in Effekt core
```scala
      case Try(body: Block, handlers: List[Implementation])
//...
case class Implementation(interface: BlockType.Interface, operations: List[Operation]) extends Tree
//...
case class Operation(name: Id, tparams: List[Id], cparams: List[Id], vparams: List[Param.ValueParam], bparams: List[Param.BlockParam], resume: Option[Param.BlockParam], body: Stmt)
```
- Handlers are already passed around as codata, get the continuation to call

## Encoding in Rpyeffect mcore
- each try generates a new label and the handler implementations close over it
- handler operations get wrapped to:
  - shift to the relevant prompt and pass a closure that resumes it
    to the handler implementation as the resume parameter