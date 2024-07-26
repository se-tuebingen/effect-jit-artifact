
type 'a state_data =
  { node : 'a Graph.node
  ; data : 'a
  ; tags : Tag.Set.t
  ; meta : Meta.Map.t
  }

type t =
| State : 'a state_data -> t

let create ?(tags=[]) ?(meta=Meta.Map.empty) node data =
  State
    { node = node
    ; data = data
    ; tags = Tag.Set.of_list tags
    ; meta = meta
    }

let node_name (State st) =
  Graph.Node.name st.node

let set_option key v (State st) =
  State { st with meta = Meta.MetaData.set_option st.meta key v }

let unpack (State st) (node : _ Graph.node) =
  if st.node.tag == node.tag then
    Obj.magic st.data
  else
    failwith "Unpacking of wrong Flow state"
