
let extern_map = Hashtbl.create 32
let register_extern name v =
  Hashtbl.add extern_map name v

let extern_exists name = Hashtbl.mem extern_map name

let get_extern name = Hashtbl.find extern_map name
