
type 'a state_data =
  { node : 'a Graph.node
  ; data : 'a
  ; tags : Tag.Set.t
  ; meta : Meta.Map.t
  }

type t =
| State : 'a state_data -> t

val create :
  ?tags:Tag.t list -> ?meta:Meta.Map.t -> 'a Graph.node -> 'a -> t

val node_name : t -> string

val set_option : 'a Meta.key -> 'a -> t -> t

val unpack : t -> 'a Graph.node -> 'a
