
type t =
| Skip
| Tags of Tag.t list
| Seq  of t * t

val node :
  ?tags: Tag.t list ->
  'a Graph.node -> t
