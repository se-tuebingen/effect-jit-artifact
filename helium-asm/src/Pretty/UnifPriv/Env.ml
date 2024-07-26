open Lang.Unif

module StrMap = Map.Make(String)

type var_info =
  { mutable var_used : bool
  }

type tvar_info =
  { mutable tvar_implicit_name : Box.t option
  }

type t =
  { type_env : type_env
  ; name_map : (ttype * var_info) StrMap.t
  ; inst_map : effinst StrMap.t
  ; uvar_map : (Utils.UID.t, int) Hashtbl.t
  ; tvar_map : tvar_info TVar.Map.t
  }

let empty () =
  { type_env = TypeEnv.empty
  ; name_map = StrMap.empty
  ; inst_map = StrMap.empty
  ; uvar_map = Hashtbl.create 32
  ; tvar_map = TVar.Map.empty
  }

let create tenv vars insts =
  let name_map =
    List.fold_left
      (fun env (name, tp) -> StrMap.add name (tp, { var_used = false}) env)
      StrMap.empty
      vars
  in
  let inst_map =
    List.fold_left
      (fun env (name, a) -> StrMap.add name a env)
      StrMap.empty
      insts
  in
  { type_env = tenv
  ; name_map = name_map
  ; inst_map = inst_map
  ; uvar_map = Hashtbl.create 32
  ; tvar_map = TVar.Map.empty
  }

let add_var_with_info env name tp =
  let info = { var_used = false } in
  { env with
    name_map = StrMap.add name (tp, info) env.name_map
  }, info

let open_type_ts env xs tp =
  let (tenv, xs, tp) = TypeEnv.open_type_ts env.type_env xs tp in
  let tvar_map = List.fold_left (fun m (TVar.Pack x) ->
      TVar.Map.add x { tvar_implicit_name = None } m
    ) env.tvar_map xs in
  ({ env with type_env = tenv; tvar_map = tvar_map }, xs, tp)

let fresh_instance_name map =
  let rec loop n =
    let name =
      if n < 26 then Printf.sprintf "`%c" (Char.chr (Char.code 'a' + n))
      else Printf.sprintf "`a%d" (n - 26)
    in
    if StrMap.mem name map then loop (n + 1)
    else name
  in loop 0

let open_type_i env a tp =
  let (tenv, a, tp) = TypeEnv.open_type_i env.type_env a tp in
  let name = fresh_instance_name env.inst_map in
  let env =
    { env with type_env = tenv; inst_map = StrMap.add name a env.inst_map } in
  (env, a, Box.word name, tp)

type path = Box.t list

let find_var_shallow env x =
  let rec loop seq =
    match seq () with
    | Seq.Nil -> None
    | Seq.Cons((name, (tp, info)), seq) ->
      if TVarPrinter.type_match_tvar env.type_env x [] [] tp then
        Some(name, info)
      else
        loop seq
  in
  loop (StrMap.to_seq env.name_map)

let find_var_deep env x =
  let rec loop seq =
    match seq () with
    | Seq.Nil -> None
    | Seq.Cons((name, (tp, info)), seq) ->
      begin match TVarPrinter.struct_type_match_tvar env.type_env x tp with
      | None -> loop seq
      | Some path -> Some(name, path, info)
      end
  in
  loop (StrMap.to_seq env.name_map)

let pick_fresh_name env name_opt =
  let rec pick_fresh_name_loop base n =
    let name = base ^ string_of_int n in
    if StrMap.mem name env.name_map then
      pick_fresh_name_loop base (n+1)
    else
      name
  in
  match name_opt with
  | None      -> pick_fresh_name_loop "T" 1
  | Some name ->
    if StrMap.mem name env.name_map then
      pick_fresh_name_loop name 0
    else
      name

let pretty_implicit env uid =
  let pretty n =
    let r = Char.code 'z' - Char.code 'a' + 1 in
    let c = Char.chr (Char.code 'a' + n mod r) in
    let n = n / r in
    Box.word (
      if n = 0 then Printf.sprintf "'%c" c
      else Printf.sprintf "'%c%d" c n)
  in
  match Hashtbl.find_opt env.uvar_map uid with
  | Some n -> pretty n
  | None   ->
    let n = Hashtbl.length env.uvar_map in
    Hashtbl.add env.uvar_map uid n;
    pretty n

let pretty_uvar env u =
  pretty_implicit env (UVar.uid u)

let pretty_implicit_tvar env x =
  match TVar.Map.find_opt x env.tvar_map with
  | None -> pretty_implicit env (TVar.uid x)
  | Some info ->
    begin match info.tvar_implicit_name with
    | Some name -> name
    | None ->
      let name = pretty_implicit env (TVar.uid x) in
      info.tvar_implicit_name <- Some name;
      name
    end

let pretty_instance env a =
  let rec loop insts =
    match insts with
    | [] -> Box.word "<unnamed>"
    | (name, b) :: insts ->
      if EffInst.equal a b then Box.word name
      else loop insts
  in loop (StrMap.bindings env.inst_map)

let tvar_used_implicitly env x =
  match TVar.Map.find_opt x env.tvar_map with
  | None -> None
  | Some info -> info.tvar_implicit_name
