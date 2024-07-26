open Lang.Unif

type error =
| NoScopeForEffInst of effsig
| EscapingEffInst   of Utils.Position.t * effsig * error_reason

exception Error of error

type t =
  {         parent   : t option
  ;         type_env : type_env
  ; mutable effinsts : (implicit_effinst * Utils.Position.t) list
  }

let enter parent type_env =
  { parent   = parent
  ; type_env = type_env
  ; effinsts = []
  }

let leave scope =
  match scope.effinsts with
  | [] -> ()
  | _  ->
    begin match scope.parent with
    | None   -> failwith "Some of implicit instances are not bound"
    | Some p ->
      (* TODO: make sure that parent instances does not interfere with child
      instances, i.e., there are no two instances of the same signature. *)
      p.effinsts <- scope.effinsts @ p.effinsts
    end

let cur_effinsts scope =
  List.map fst scope.effinsts

let rec all_effinsts scope =
  match scope.parent with
  | None   -> cur_effinsts scope
  | Some p -> cur_effinsts scope @ all_effinsts p

let create_implicit_instance scope pos s =
  match Lang.Unif.Type.restrict_to_scope (TypeEnv.scope scope.type_env) s with
  | () ->
    let i = ImplicitEffInst.fresh s in
    scope.effinsts <- (i, pos) :: scope.effinsts;
    i
  | exception (Lang.Unif.Error err) ->
    raise (Error (EscapingEffInst(pos, s, err)))

let pick_generalizable scope env_insts =
  let (gen, rest) =
    List.fold_left (fun (gen, rest) (i, pos) ->
      if ImplicitEffInst.Set.mem i env_insts then
        (gen, (i, pos) :: rest)
      else
        (i :: gen, rest)
    ) ([], []) scope.effinsts in
  scope.effinsts <- List.rev rest;
  gen
