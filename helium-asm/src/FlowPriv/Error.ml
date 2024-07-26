
type t =
| UnsupportedExtension of string
| InvariantViolation   of State.t * Tag.t
| CannotFindPath : 'src Graph.node * Tag.t list * Tag.t list -> t

exception Error of State.t

let node =
  Graph.Node.create "Flow Error"

let error err =
  Error (State.State
  { State.node = node
  ; State.data = err
  ; State.tags = Tag.Set.singleton node.Graph.tag
  ; State.meta = Meta.Map.empty
  })

let unsupported_extension ext  = error (UnsupportedExtension ext)
let invariant_violation st tag = error (InvariantViolation(st, tag))

let cannot_find_path st tags =
  error (CannotFindPath(st.State.node, Tag.Set.elements st.State.tags, tags))
