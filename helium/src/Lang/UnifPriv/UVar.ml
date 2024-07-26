open TypingStructure
include UVarBase

module Set = struct
  type t = unit Map.t

  let empty = Map.empty

  let add x s = Map.add x () s

  let union = Map.set_union
  let diff  = Map.diff

  let unions ss = List.fold_left union empty ss

  let mem x s = Map.mem x s

  let to_list s = Map.fold { fold_f = fun x () xs -> Pack x :: xs } s []
end
