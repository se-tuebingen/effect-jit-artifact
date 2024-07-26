
type t =
| Nil
| Special of string
| Atom    of string
| Cons    of t * t
| Int     of int

val mk_list : t list -> t
val of_list : ('a -> t) -> 'a list -> t
val tagged_list : string -> t list -> t

val pretty : t -> Box.t

val flow_node : t Flow.node
