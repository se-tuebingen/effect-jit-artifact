## Pipeline
Koka -> Koka core -> Rpyeffect mcore --> Rpyeffect |- JIT

## Handlers in Koka
- usually translates into monadic encoding. We DISABLE this part of the translation for our backend
- mostly implemented in stdlib
- passes evidence vector with the prompts and handlers

## Encoding of those handlers into Rpyeffect mcore
- evidence vectors are singly-linked cons lists
- stdlib functions are replaced to directly use our
  delimited control features