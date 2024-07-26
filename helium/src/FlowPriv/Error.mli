
type t =
| UnsupportedExtension of string
| InvariantViolation   of State.t * Tag.t
| CannotFindPath : 'src Graph.node * Tag.t list * Tag.t list -> t

exception Error of State.t

val node : t Graph.node

val unsupported_extension : string -> exn
val invariant_violation   : State.t -> Tag.t -> exn
val cannot_find_path      : 'a State.state_data -> Tag.t list -> exn
