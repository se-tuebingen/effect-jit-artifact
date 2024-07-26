open TypingStructure

module UVarMap    = UVar.Map.Make(struct type 'k t = 'k typ end)
module TypeRefMap = TypeRef.Map.Make(struct type 'k t = 'k type_value end)

type t =
  { uvar_map : UVarMap.t
  ; type_map : TypeRefMap.t
  ; inst_map : effinst_expr Utils.UID.Map.t
  }

let world = ref
  { uvar_map = UVarMap.empty
  ; type_map = TypeRefMap.empty
  ; inst_map = Utils.UID.Map.empty
  }

let save () = !world

let rollback w = world := w

let get_uvar u = UVarMap.find_opt u !world.uvar_map
let set_uvar u tp =
  assert (not (UVarMap.mem u !world.uvar_map));
  world := { !world with uvar_map = UVarMap.add u tp !world.uvar_map }

let get_type x = TypeRefMap.find x !world.type_map
let set_type x v =
  world := { !world with type_map = TypeRefMap.add x v !world.type_map }

let get_effinst i = Utils.UID.Map.find_opt i.iei_uid !world.inst_map
let set_effinst i a =
  world :=
    { !world with inst_map = Utils.UID.Map.add i.iei_uid a !world.inst_map }

let try_opt f =
  let w0 = save () in
  try Some (f ()) with
  | Error _ ->
    rollback w0;
    None

let try_bool f =
  match try_opt f with
  | None    -> false
  | Some () -> true

let rec try_alt f0 fs =
  match fs with
  | [] -> f0 ()
  | f1 :: fs ->
    begin match try_opt f0 with
    | Some r -> r
    | None -> try_alt f1 fs
    end

let try_exn f =
  let w0 = save () in
  try f () with
  | ex ->
    rollback w0;
    raise ex
