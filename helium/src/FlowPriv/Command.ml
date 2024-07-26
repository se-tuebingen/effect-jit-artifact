
type t =
| Skip
| Tags of Tag.t list
| Seq  of t * t

let node ?(tags=[]) node =
  Tags(node.Graph.tag :: tags)
