open Common

module VarSet = Set.Make(struct type t = T.identifier let compare = compare end)

let is_fn = function
| T.EFn _ -> true
| T.EFnRedex _  -> true
| _ -> false

let rec is_value = function
| T.EFn _ -> true
| T.EFnRedex _  -> true
| T.ELit lit -> true
| T.EVar x -> true
| T.EExtern(name, []) -> true
| T.EConstr(_, args) -> List.for_all is_value args
| T.ETuple(args) -> List.for_all is_value args
| _ -> false

let rec arity = function
| T.EFn(args, e) -> List.length args + arity e
| T.EFnRedex(args, e) -> List.length args + arity e
| _ -> 0

let is_redex expr =
  let rec check_args acc args =
    match (acc, args) with
    | [], [] -> true
    | x :: xs, T.EVar (T.Local(y, NoFieldAccess)) :: ys -> x = y && check_args xs ys
    | _ -> false

  in let rec check_expr acc = function
  | T.EFn(args, body) -> check_expr (acc @ args) body
  | T.EFnRedex(args, body) -> check_expr (acc @ args) body
  | T.EOp(i, T.EConstr(_, args)) -> check_args acc (T.EVar (T.Local(i, NoFieldAccess)) :: args)
  | T.EPrim(_, args) -> check_args acc args
  | T.EConstr(_, args) -> check_args acc args
  | T.ETuple(args) -> check_args acc args
  | T.EProj(arg , _) -> check_args acc [arg]
  | _ -> false

  in check_expr [] expr

module VarCount = Map.Make(String)
let lookup_var_count env x accessor =
  match accessor with
  | T.NoFieldAccess -> VarCount.find_opt (T.Var.to_string x) env
  | T.TupleAccess k
  | T.RecursiveAccess k ->
    VarCount.find_opt ((T.Var.to_string x) ^ "->" ^ string_of_int k) env
let count_var_uses e =
  (* Hack: using string version of variable names to make possible tracking uses record fields *)
  let empty = VarCount.empty in
  let sum = VarCount.union (fun _ c1 c2 -> Some (c1 + c2)) in
  let rec count e =
    match e with
    | T.ELit _ -> empty
    | T.EVar v -> begin match v with
      | T.Local(x, TupleAccess n) ->
        sum (VarCount.singleton ((T.Var.to_string x) ^ "->" ^ string_of_int n) 1)
            (VarCount.singleton (T.Var.to_string x) 1)
      | T.Local(x, accessor) -> VarCount.singleton (T.Var.to_string x) 1
      | _ -> empty
      end
    | T.EFn(args, body) -> count body
    | T.EFnRedex(args, body) -> count body
    | T.ETuple es -> List.fold_left sum empty (List.map count es)
    | T.EConstr(n, es) -> List.fold_left sum empty (List.map count es)
    | T.EPrim(prim_code, es) -> List.fold_left sum empty (List.map count es)
    | T.ELet(x, e1, e2)
    | T.ELetPure(x, e1, e2) -> sum (count e1) (count e2)
    | T.EFix(r, rfs, e) -> List.fold_left sum (count e) (List.map count rfs)
    | T.EApp(f, args) ->  List.fold_left sum (count f) (List.map count args)
    | T.EProj(T.EVar(Local(x, NoFieldAccess)) as v, n) ->  
      sum (VarCount.singleton ((T.Var.to_string x) ^ "->" ^ string_of_int n) 1) (count v)
    | T.EProj(v, n) -> count v
    | T.EMatch(v, _, cls)
    | T.ESwitch(v, cls) -> List.fold_left sum (count v) (List.map count cls)
    | T.EHandle h -> count h.body |> sum (count h.return_body) |> sum (count h.op_handler)
    | T.EOp(i, arg) -> sum (count arg)  (VarCount.singleton ((T.Var.to_string i)) 1)
    | T.EExtern(name, args) -> List.fold_left sum empty (List.map count args)
  in count e

let no_free_vars ?(bindings=[]) expr =
  let rec check bound e =
    match e with
    | T.ELit _ -> true
    | T.EVar v -> begin match v with
      | T.Local(x, _) -> VarSet.mem x bound
      | T.Global _ -> true
      end
    | T.EFn(args, body)
    | T.EFnRedex(args, body) -> check (VarSet.add_seq (List.to_seq args) bound) body
    | T.ETuple es -> List.for_all (check bound) es
    | T.EConstr(n, es) -> List.for_all (check bound) es
    | T.EPrim(prim_code, es) -> List.for_all (check bound) es
    | T.ELet(x, e1, e2)
    | T.ELetPure(x, e1, e2) -> check bound e1 && check (VarSet.add x bound) e2
    | T.EFix(r, rfs, e) -> List.for_all (check (VarSet.add r bound)) rfs && check (VarSet.add r bound) e
    | T.EApp(f, args) ->  check bound f && List.for_all (check bound) args
    | T.EProj(v, n) -> check bound v
    | T.EMatch(v, x, cls) -> check bound v && List.for_all (check (VarSet.add x bound)) cls
    | T.ESwitch(v, cls) -> check bound v && List.for_all (check bound) cls
    | T.EHandle h ->
        check (VarSet.add h.effinst bound) h.body &&
        check (VarSet.add h.return_var bound) h.return_body &&
        check (VarSet.add h.op_arg_var (VarSet.add h.resume_var bound)) h.op_handler
    | T.EOp(i, arg) -> VarSet.mem i bound && check bound arg
    | T.EExtern(name, args) -> List.for_all (check bound) args
  in check (VarSet.of_list bindings) expr

let syntactically_pure ?(env = OptEnv.empty) e =
  (* Check if function does not pass its arguments to other functions and does not create aliases of its arguments. *)
  let safe_arg_use expr =
    let rec allowed args e =
      match e with
      | T.ELit lit -> true
      | T.EVar x -> true
      | T.EFn(xs, body)
      | T.EFnRedex(xs, body) -> not_allowed (VarSet.add_seq (List.to_seq xs) args) body
      | T.ETuple es -> List.for_all (allowed args) es
      | T.EConstr(n, es) -> List.for_all (allowed args) es
      | T.ELet(x, e1, e2)
      | T.ELetPure(x, e1, e2) ->
        not_allowed args e1 && allowed args e2
      | T.EPrim(prim_code, es) -> List.for_all (allowed args) es
      | T.EFix(r, rfs, e) -> List.for_all (allowed args) rfs && allowed args e
      | T.EApp(f, es) -> not_allowed args f && List.for_all (allowed args) es
      | T.EProj(v, n) ->  allowed args v
      | T.EMatch(v, _, cls) -> not_allowed args v && List.for_all (allowed args) cls
      | T.ESwitch(v, cls) -> allowed args v && List.for_all (allowed args) cls
      | T.EHandle h -> false
      | T.EOp(i, arg) -> false
      | T.EExtern(name, args) -> false

    and not_allowed args e =
      match e with
      | T.ELit lit -> true
      | T.EVar (Local(x, _)) -> not (VarSet.mem x args)
      | T.EVar (Global _) -> true
      | T.EFn(xs, body)
      | T.EFnRedex(xs, body) -> not_allowed (VarSet.add_seq (List.to_seq xs) args) body
      | T.ETuple es -> List.for_all (allowed args) es
      | T.EConstr(n, es) -> List.for_all (allowed args) es
      | T.ELet(x, e1, e2)
      | T.ELetPure(x, e1, e2) ->
        not_allowed args e1 && not_allowed args e2
      | T.EPrim(prim_code, es) -> List.for_all (allowed args) es
      | T.EFix(r, rfs, e) -> List.for_all (not_allowed args) rfs && not_allowed args e
      | T.EApp(f, es) -> not_allowed args f && List.for_all (allowed args) es
      | T.EProj(v, n) -> allowed args v
      | T.EMatch(v, _, cls) -> not_allowed args v && List.for_all (not_allowed args) cls
      | T.ESwitch(v, cls) -> allowed args v && List.for_all (not_allowed args) cls
      | T.EHandle h -> false
      | T.EOp(i, arg) -> false
      | T.EExtern(name, args) -> false

    in match expr with
    | T.EFn(args, body)
    | T.EFnRedex(args, body) -> allowed (VarSet.of_list args) body
    | _ -> not_allowed VarSet.empty expr

  (* Check if there is no op expression in e *)
  in let rec no_effect_use e =
    match e with
    | T.ELit lit -> true
    | T.EVar x -> true
    | T.EFn(args, body)
    | T.EFnRedex(args, body) -> no_effect_use body
    | T.ETuple es -> List.for_all no_effect_use es
    | T.EConstr(n, es) -> List.for_all no_effect_use es
    | T.ELet(x, e1, e2)
    | T.ELetPure(x, e1, e2) ->
      no_effect_use e1 && no_effect_use e2
    | T.EPrim(prim_code, es) -> List.for_all no_effect_use es && prim_code != Lang.PrimCodes.ExitWith
    | T.EFix(r, rfs, e) -> no_effect_use e
    | T.EApp(f, args) -> no_effect_use f && List.for_all no_effect_use args
    | T.EProj(v, n) -> no_effect_use v
    | T.EMatch(v, _, cls)
    | T.ESwitch(v, cls) -> no_effect_use v && List.for_all no_effect_use cls
    | T.EHandle h -> false
    | T.EOp(i, arg) -> false
    | T.EExtern(name, args) -> false

  in let rec pure_func = function
  | T.EFn(_, body)
  | T.EFnRedex(_, body) -> pure_expr body
  | T.EVar(Local(x, NoFieldAccess)) ->
    begin match OptEnv.lookup_var env x with
    | Some (T.EFn(_, body))
    | Some (T.EFnRedex(_, body)) -> pure_expr body
    | _ -> false
    end
  | T.EVar(Local(x, RecursiveAccess k)) ->
    begin match OptEnv.lookup_var env x with
    | Some (T.ETuple rfs) -> List.for_all safe_arg_use rfs && List.for_all no_effect_use rfs &&
      List.for_all (no_free_vars ~bindings: [x]) rfs
    | _ -> false
    end
  | _ -> false

  and pure_expr e =
    match e with
    | T.ELit lit -> true
    | T.EVar x -> true
    | T.EFn(args, body) -> true
    | T.EFnRedex(args, body) -> true
    | T.ETuple es -> List.for_all pure_expr es
    | T.EConstr(n, es) -> List.for_all pure_expr es
    | T.ELet(x, e1, e2)
    | T.ELetPure(x, e1, e2) -> pure_expr e1 && pure_expr e2
    | T.EPrim(prim_code, es) -> List.for_all pure_expr es && prim_code != Lang.PrimCodes.ExitWith
    | T.EFix(r, rfs, e) -> pure_expr e
    | T.EApp(f, args) ->
      pure_func f && List.for_all pure_expr args
    | T.EProj(v, n) -> pure_expr v
    | T.EMatch(v, _, cls)
    | T.ESwitch(v, cls) -> pure_expr v && List.for_all pure_expr cls
    | T.EHandle h -> false
    | T.EOp(i, arg) -> false
    | T.EExtern(name, args) -> List.for_all pure_expr args && List.mem name
      ["helium_stdin"; "helium_stdout"; "helium_stderr"]
  in pure_expr e

let not_passing_arg_further arg expr =
  let rec check_args = function
  | [] -> true
  | T.EVar (Local(x, _)) :: args -> arg != x && check_args args
  | _ :: args -> check_args args

  in let rec check e =
    match e with
    | T.ELit lit -> true
    | T.EVar x -> true
    | T.EFn(args, body)
    | T.EFnRedex(args, body) -> check body
    | T.ETuple es -> List.for_all check es
    | T.EConstr(n, es) -> List.for_all check es
    | T.EPrim(prim_code, es) -> List.for_all check es
    | T.ELet(_, e1, e2)
    | T.ELetPure(_, e1, e2) ->
      begin match e1 with
      | T.EVar(Local(x, _)) -> x != arg
      | _ -> check e1 && check e2
      end
    | T.EFix(r, rfs, e) -> List.for_all check rfs && check e
    | T.EApp(f, args) -> check f && check_args args
    | T.EProj(v, _) -> check v
    | T.EMatch(v, _, cls) -> check v && List.for_all check cls
    | T.ESwitch(v, cls) -> check v && List.for_all check cls
    | T.EHandle h -> check h.body && check h.return_body && check h.op_handler
    | T.EOp(_, arg) -> check arg
    | T.EExtern(_, args) -> List.for_all check args

  in check expr