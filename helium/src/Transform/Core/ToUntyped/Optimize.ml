open Common

let rec make_type_functions_indirect expr =
  let rec rewrite_rfs r next_index = function
  | [] -> []
  | T.EFn([], body) :: defs
  | T.EFnRedex([], body) :: defs ->
    if Analysis.is_fn body
      then T.EFnRedex([], T.EVar(T.Local(r, RecursiveAccess next_index))) ::
        rewrite_rfs r (next_index + 1) (defs @ [body])
      else T.EFnRedex([], body) :: rewrite_rfs r next_index defs
  | e :: defs -> e :: rewrite_rfs r next_index defs

  and opt e =
    match e with
    | T.ELit lit -> T.ELit lit
    | T.EVar x -> T.EVar x
    | T.EFn(args, body) -> T.EFn(args, opt body)
    | T.EFnRedex(args, body) -> T.EFnRedex(args, opt body)
    | T.ETuple es -> T.ETuple (List.map opt es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map opt es)
    | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map opt es)
    | T.ELet(x, e1, e2) -> T.ELet(x, opt e1, opt e2)
    | T.ELetPure(x, e1, e2) -> T.ELetPure(x, opt e1, opt e2)
    | T.EFix(r, rfs, e) ->
      let rfs' = rewrite_rfs r (List.length rfs) rfs in
      T.EFix(r, List.map opt rfs', opt e)
    | T.EApp(f, args) ->  T.EApp(opt f, List.map opt args)
    | T.EProj(v, n) -> T.EProj(opt v, n)
    | T.EMatch(v, x, cls) -> T.EMatch(opt v, x, List.map opt cls)
    | T.ESwitch(v, cls) -> T.ESwitch(opt v, List.map opt cls)
    | T.EHandle h -> T.EHandle
      { h with body = opt h.body
             ; return_body = opt h.return_body
             ; op_handler = opt h.op_handler
      }
    | T.EOp(i, arg) -> T.EOp(i, opt arg)
    | T.EExtern(name, args) -> T.EExtern(name, List.map opt args)
  in opt expr



let rec arity_rewrite expr =
  let rec get_body = function
  | T.EFn(_, e) -> get_body e
  | T.EFnRedex(_, e) -> get_body e
  | body -> body

  in let rec get_args = function
  | T.EFn(args, e) -> args @ get_args e
  | T.EFnRedex(args, e) -> args @ get_args e
  | _ -> []

  in let rec rewrite_fn f_name acc = function
  | T.EFn(args, body)
  | T.EFnRedex(args, body) ->
    let args' = List.map (fun _ -> T.Var.fresh()) args in
    T.EFnRedex(args', rewrite_fn f_name (acc @ args') body)
  | _ -> T.EApp (T.EVar(Local(f_name, NoFieldAccess)),
                 List.map (fun x -> T.EVar(Local(x, NoFieldAccess))) acc)

  in let rewrite_rf r next_index e =
    if Analysis.arity e <= 1
      then (e, [], next_index)
      else
        let rec rewrite acc = function
        | T.EFn(args, body)
        | T.EFnRedex(args, body) ->
          let args' = List.map (fun _ -> T.Var.fresh()) args in
          T.EFnRedex(args', rewrite (acc @ args') body)
        | _ -> T.EApp (T.EVar(Local(r, RecursiveAccess next_index)),
                       List.map (fun x -> T.EVar(Local(x, NoFieldAccess))) acc)
        in (rewrite [] e, [T.EFn(get_args e, get_body e)], next_index + 1)

  in let rec rewrite_rfs r next_index new_fs = function
  | [] -> List.rev new_fs
  | f :: fs -> let (f', f'', next_index') = rewrite_rf r next_index f in
    f' :: rewrite_rfs r next_index' (f'' @ new_fs) fs

  in let rec opt e =
    match e with
    | T.ELit lit -> T.ELit lit
    | T.EVar x -> T.EVar x
    | T.EFn(args, body) -> T.EFn(args, opt body)
    | T.EFnRedex(args, body) -> T.EFnRedex(args, opt body)
    | T.ETuple es -> T.ETuple (List.map opt es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map opt es)
    | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map opt es)
    | T.ELet(x, (T.EFn _ as f), e2)
    | T.ELetPure(x, (T.EFn _ as f), e2)
      when Analysis.no_free_vars f && Analysis.arity f > 1 ->
      let f' = opt f in
      let y = T.Var.fresh() in
      T.ELetPure(y, T.EFn(get_args f, get_body f),
                 T.ELetPure(x, rewrite_fn y [] f', opt e2))
    | T.ELet(x, e1, e2) -> T.ELet(x, opt e1, opt e2)
    | T.ELetPure(x, e1, e2) -> T.ELetPure(x, opt e1, opt e2)
    | T.EFix(r, rfs, e) ->
      let rfs' = rewrite_rfs r (List.length rfs) [] rfs in
      T.EFix(r, List.map opt rfs', opt e)
    | T.EApp(f, args) ->  T.EApp(opt f, List.map opt args)
    | T.EProj(v, n) -> T.EProj(opt v, n)
    | T.EMatch(v, x, cls) -> T.EMatch(opt v, x, List.map opt cls)
    | T.ESwitch(v, cls) -> T.ESwitch(opt v, List.map opt cls)
    | T.EHandle h -> T.EHandle
      { h with body = opt h.body
             ; return_body = opt h.return_body
             ; op_handler = opt h.op_handler
      }
    | T.EOp(i, arg) -> T.EOp(i, opt arg)
    | T.EExtern(name, args) -> T.EExtern(name, List.map opt args)
  in opt expr



let rec find_redexes expr =
  let rec rewrite_fn = function
  | T.EFn(args, body)
  | T.EFnRedex(args, body) -> T.EFnRedex(args, rewrite_fn body)
  | e -> e

  in let rec opt e =
    match e with
    | T.ELit lit -> T.ELit lit
    | T.EVar x -> T.EVar x
    | T.EFn(args, body) ->
      if Analysis.is_redex e
        then rewrite_fn e
        else T.EFn(args, opt body)
    | T.EFnRedex(args, body) -> T.EFnRedex(args, opt body)
    | T.ETuple es -> T.ETuple (List.map opt es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map opt es)
    | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map opt es)
    | T.ELet(x, e1, e2) -> T.ELet(x, opt e1, opt e2)
    | T.ELetPure(x, e1, e2) -> T.ELetPure(x, opt e1, opt e2)
    | T.EFix(r, rfs, e) -> T.EFix(r, List.map opt rfs, opt e)
    | T.EApp(f, args) ->  T.EApp(opt f, List.map opt args)
    | T.EProj(v, n) -> T.EProj(opt v, n)
    | T.EMatch(v, x, cls) -> T.EMatch(opt v, x, List.map opt cls)
    | T.ESwitch(v, cls) -> T.ESwitch(opt v, List.map opt cls)
    | T.EHandle h -> T.EHandle
      { h with body = opt h.body
              ; return_body = opt h.return_body
              ; op_handler = opt h.op_handler
      }
    | T.EOp(i, arg) -> T.EOp(i, opt arg)
    | T.EExtern(name, args) -> T.EExtern(name, List.map opt args)
  in opt expr



let rec eta_let e =
  match e with
  | T.ELit lit -> T.ELit lit
  | T.EVar x -> T.EVar x
  | T.EFn(args, body) -> T.EFn(args, eta_let body)
  | T.EFnRedex(args, body) -> T.EFnRedex(args, eta_let body)
  | T.ETuple es -> T.ETuple (List.map eta_let es)
  | T.EConstr(n, es) -> T.EConstr(n, List.map eta_let es)
  | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map eta_let es)
  | T.ELet(x, e1, (T.EVar (T.Local(y, NoFieldAccess)) as e2)) ->
    if x = y then eta_let e1 else T.ELet (x, eta_let e1, eta_let e2)
  | T.ELetPure(x, e1, (T.EVar (T.Local(y, NoFieldAccess)) as e2)) ->
    if x = y then eta_let e1 else T.ELetPure(x, eta_let e1, eta_let e2)
  | T.ELet(x, e1, e2) -> T.ELet(x, eta_let e1, eta_let e2)
  | T.ELetPure(x, e1, e2) -> T.ELetPure(x, eta_let e1, eta_let e2)
  | T.EFix(r, rfs, e) -> T.EFix(r, List.map eta_let rfs, eta_let e)
  | T.EApp(f, args) ->  T.EApp(eta_let f, List.map eta_let args)
  | T.EProj(v, n) -> T.EProj(eta_let v, n)
  | T.EMatch(v, x, cls) -> T.EMatch(eta_let v, x, List.map eta_let cls)
  | T.ESwitch(v, cls) -> T.ESwitch(eta_let v, List.map eta_let cls)
  | T.EHandle h -> T.EHandle
    { h with body = eta_let h.body
           ; return_body = eta_let h.return_body
           ; op_handler = eta_let h.op_handler
    }
  | T.EOp(i, arg) -> T.EOp(i, eta_let arg)
  | T.EExtern(name, args) -> T.EExtern(name, List.map eta_let args)



let rec hoist_let_let e =
  match e with
  | T.ELit lit -> T.ELit lit
  | T.EVar x -> T.EVar x
  | T.EFn(args, body) -> T.EFn(args, hoist_let_let body)
  | T.EFnRedex(args, body) -> T.EFnRedex(args, hoist_let_let body)
  | T.ETuple es -> T.ETuple (List.map hoist_let_let es)
  | T.EConstr(n, es) -> T.EConstr(n, List.map hoist_let_let es)
  | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map hoist_let_let es)
  | T.ELet(x, T.ELet(y, e1, e2), e3) ->
    T.ELet(y, hoist_let_let e1, hoist_let_let (T.ELet(x, e2, e3)))
  | T.ELetPure(x, T.ELet(y, e1, e2), e3) ->
    T.ELet(y, hoist_let_let e1, hoist_let_let (T.ELetPure(x, e2, e3)))
  | T.ELet(x, T.ELetPure(y, e1, e2), e3) ->
    T.ELetPure(y, hoist_let_let e1, hoist_let_let (T.ELet(x, e2, e3)))
  | T.ELetPure(x, T.ELetPure(y, e1, e2), e3) ->
    T.ELetPure(y, hoist_let_let e1, hoist_let_let (T.ELetPure(x, e2, e3)))
  | T.ELet(x, e1, e2) -> T.ELet(x, hoist_let_let e1, hoist_let_let e2)
  | T.ELetPure(x, e1, e2) -> T.ELetPure(x, hoist_let_let e1, hoist_let_let e2)
  | T.EFix(r, rfs, e) -> T.EFix(r, List.map hoist_let_let rfs, hoist_let_let e)
  | T.EApp(f, args) ->  T.EApp(hoist_let_let f, List.map hoist_let_let args)
  | T.EProj(v, n) -> T.EProj(hoist_let_let v, n)
  | T.EMatch(v, x, cls) -> T.EMatch(hoist_let_let v, x, List.map hoist_let_let cls)
  | T.ESwitch(v, cls) -> T.ESwitch(hoist_let_let v, List.map hoist_let_let cls)
  | T.EHandle h -> T.EHandle
    { h with body = hoist_let_let h.body
            ; return_body = hoist_let_let h.return_body
            ; op_handler = hoist_let_let h.op_handler
    }
  | T.EOp(i, arg) -> T.EOp(i, hoist_let_let arg)
  | T.EExtern(name, args) -> T.EExtern(name, List.map hoist_let_let args)



let app_to_let e =
  let rec make_lets xs args body =
    match xs, args with
    | [], [] -> body
    | x :: xs', arg :: args' -> T.ELet(x, arg,  make_lets xs' args' body)
    | _, _ -> failwith "Optimization error: unmatched arities."

  in let rec opt e =
    match e with
    | T.ELit lit -> T.ELit lit
    | T.EVar x -> T.EVar x
    | T.EFn(args, body) -> T.EFn(args, opt body)
    | T.EFnRedex(args, body) -> T.EFnRedex(args, opt body)
    | T.ETuple es -> T.ETuple (List.map opt es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map opt es)
    | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map opt es)
    | T.ELet(x, e1, e2) -> T.ELet (x, opt e1, opt e2)
    | T.ELetPure(x, e1, e2) -> T.ELetPure(x, opt e1, opt e2)
    | T.EFix(r, rfs, e) -> T.EFix(r, List.map opt rfs, opt e)
    | T.EApp(f, args) ->
      begin match f with
      | T.EFn (xs, body) -> make_lets xs args body
      | _ -> T.EApp(opt f, List.map opt args)
      end

    | T.EProj(v, n) -> T.EProj(opt v, n)
    | T.EMatch(v, x, cls) -> T.EMatch(opt v, x, List.map opt cls)
    | T.ESwitch(v, cls) -> T.ESwitch(opt v, List.map opt cls)
    | T.EHandle h -> T.EHandle
      { h with body = opt h.body
              ; return_body = opt h.return_body
              ; op_handler = opt h.op_handler
      }
    | T.EOp(i, arg) -> T.EOp(i, opt arg)
    | T.EExtern(name, args) -> T.EExtern(name, List.map opt args)
  in opt e



let rec proj_to_field_accessor e =
  match e with
  | T.ELit lit -> T.ELit lit
  | T.EVar x -> T.EVar x
  | T.EFn(args, body) -> T.EFn(args, proj_to_field_accessor body)
  | T.EFnRedex(args, body) -> T.EFnRedex(args, proj_to_field_accessor body)
  | T.ETuple es -> T.ETuple (List.map proj_to_field_accessor es)
  | T.EConstr(n, es) -> T.EConstr(n, List.map proj_to_field_accessor es)
  | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map proj_to_field_accessor es)
  | T.ELet(x, e1, e2) -> T.ELet(x, proj_to_field_accessor e1, proj_to_field_accessor e2)
  | T.ELetPure(x, e1, e2) -> T.ELetPure(x, proj_to_field_accessor e1, proj_to_field_accessor e2)
  | T.EFix(r, rfs, e) -> T.EFix(r, List.map proj_to_field_accessor rfs, proj_to_field_accessor e)
  | T.EApp(f, args) ->  T.EApp(proj_to_field_accessor f, List.map proj_to_field_accessor args)
  | T.EProj(T.EVar(T.Local(x, NoFieldAccess)), k) -> T.EVar(T.Local(x, TupleAccess k))
  | T.EProj(v, n) -> T.EProj(proj_to_field_accessor v, n)
  | T.EMatch(v, x, cls) -> T.EMatch(proj_to_field_accessor v, x, List.map proj_to_field_accessor cls)
  | T.ESwitch(v, cls) -> T.ESwitch(proj_to_field_accessor v, List.map proj_to_field_accessor cls)
  | T.EHandle h -> T.EHandle
    { h with body = proj_to_field_accessor h.body
            ; return_body = proj_to_field_accessor h.return_body
            ; op_handler = proj_to_field_accessor h.op_handler
    }
  | T.EOp(i, arg) -> T.EOp(i, proj_to_field_accessor arg)
  | T.EExtern(name, args) -> T.EExtern(name, List.map proj_to_field_accessor args)



let alias expr =
  let rec opt env e =
    match e with
    | T.ELit lit -> T.ELit lit
    | T.EVar v -> begin match v with
      | T.Local(x, accessor) -> begin match OptEnv.lookup_var env x with
        | None -> T.EVar v
        | Some x' -> T.EVar (T.Local(x', accessor))
        end
      | _ -> T.EVar v
      end
    | T.EFn(args, body) ->
      T.EFn(args, opt env body)
    | T.EFnRedex(args, body) ->
      T.EFnRedex(args, opt env body)
    | T.ETuple es -> T.ETuple (List.map (opt env) es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map (opt env) es)
    | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map (opt env) es)
    | T.ELet(x, T.EVar (T.Local(x', NoFieldAccess)), e2)
    | T.ELetPure(x, T.EVar (T.Local(x', NoFieldAccess)), e2) ->
      begin match OptEnv.lookup_var env x' with
      | None -> opt (OptEnv.add_to_env env x x') e2
      | Some x'' -> opt (OptEnv.add_to_env env x x'') e2
      end
    | T.ELet(x, e1, e2) ->  T.ELet(x, opt env e1, opt env e2)
    | T.ELetPure(x, e1, e2) -> T.ELetPure(x, opt env e1, opt env e2)
    | T.EFix(r, rfs, e) -> T.EFix(r, List.map (opt env) rfs, opt env e)
    | T.EApp(f, args) ->  T.EApp(opt env f, List.map (opt env) args)
    | T.EProj(v, n) -> T.EProj(opt env v, n)
    | T.EMatch(v, x, cls) -> T.EMatch(opt env v, x, List.map (opt env) cls)
    | T.ESwitch(v, cls) -> T.ESwitch(opt env v, List.map (opt env) cls)
    | T.EHandle h -> T.EHandle
      { h with body = opt env h.body
             ; return_body = opt env h.return_body
             ; op_handler = opt env h.op_handler
      }
    | T.EOp(i, arg) -> begin match OptEnv.lookup_var env i with
      | None -> T.EOp(i, opt env arg)
      | Some i' -> T.EOp(i', opt env arg)
      end
    | T.EExtern(name, args) -> T.EExtern(name, List.map (opt env) args)
  in opt OptEnv.empty expr



let inline expr =
  let var_use_counts = Analysis.count_var_uses expr in
  let simple = function
  | T.ELit lit -> true
  | T.EVar x -> true
  | _ -> false
  in
  let rec opt env e =
    match e with
    | T.ELit lit -> T.ELit lit
    | T.EVar var -> begin match var with
      | T.Local(x, NoFieldAccess) -> begin match OptEnv.lookup_var env x with
        | Some e ->
          if Analysis.lookup_var_count var_use_counts x NoFieldAccess = Some 1 || simple e
            then e
            else T.EVar var
        | _ -> T.EVar var
        end
      | T.Local(x, TupleAccess k) -> begin match OptEnv.lookup_var env x with
        | Some (T.ETuple args) -> let v = List.nth args k in
          if simple v || (Analysis.lookup_var_count var_use_counts x (TupleAccess k)
             = Some 1 && Analysis.is_value v) then v else T.EVar var
        | _ -> T.EVar var
        end
      | _ -> T.EVar var
      end
    | T.EFn(args, body) ->
      T.EFn(args, opt env body)
    | T.EFnRedex(args, body) ->
      T.EFnRedex(args, opt env body)
    | T.ETuple es -> T.ETuple (List.map (opt env) es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map (opt env) es)
    | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map (opt env) es)
    | T.ELet(x, T.ELit v, e2)
    | T.ELetPure(x, T.ELit v, e2) ->
      opt (OptEnv.add_to_env env x (T.ELit v)) e2
    | T.ELet(x, e1, e2) -> let e1' = opt env e1 in
      let e1_pure = Analysis.syntactically_pure ~env: env e1' in
      let e2' = if e1_pure
        then opt (OptEnv.add_to_env env x e1') e2
        else opt env e2
      in begin match e2' with
      | T.EMatch(T.EVar (T.Local(x', NoFieldAccess)), x'', cls)
        when x = x' && Analysis.lookup_var_count var_use_counts x NoFieldAccess = Some 1 -> T.EMatch(e1', x'', cls)
      | T.ESwitch(T.EVar (T.Local(x', NoFieldAccess)), cls)
        when x = x' && Analysis.lookup_var_count var_use_counts x NoFieldAccess = Some 1 -> T.ESwitch(e1', cls)
      | T.EOp(i, T.EVar (T.Local(x', NoFieldAccess)))
        when x = x' -> T.EOp(i, e1')
      | T.EProj(T.EVar (T.Local(x', NoFieldAccess)), i)
        when x = x' -> T.EProj(e1', i)
      | _ ->
        if e1_pure
        then T.ELetPure(x, e1', e2')
        else T.ELet(x, e1', e2')
      end
    | T.ELetPure(x, e1, e2) -> let e1' = opt env e1 in
      T.ELetPure(x, e1', (opt (OptEnv.add_to_env env x e1') e2))
    | T.EFix(r, rfs, e) ->
      let env' = OptEnv.add_to_env env r (T.ETuple rfs) in
      T.EFix(r, List.map (opt env') rfs, opt env' e)
    | T.EApp((T.EVar T.Local(x, NoFieldAccess)) as var, args) ->
      begin match OptEnv.lookup_var env x with
      | Some (EFnRedex _ as redex) -> T.EApp(redex, List.map (opt env) args)
      | Some (EFn(xs, body)) -> begin match try_specialize xs body args env with
        | Some specialized -> specialized
        | None -> T.EApp(opt env var, List.map (opt env) args)
        end
      | _ -> T.EApp(opt env var, List.map (opt env) args)
      end
    | T.EApp((T.EVar T.Local(x, TupleAccess k)) as var, args)
    | T.EApp((T.EVar T.Local(x, RecursiveAccess k)) as var, args) ->
      begin match OptEnv.lookup_var env x with
      | Some (ETuple rfs) -> begin match List.nth rfs k with
        | EFnRedex _ as redex -> T.EApp(redex, List.map (opt env) args)
        | _ -> T.EApp(opt env var, List.map (opt env) args)
        end
      | _ -> T.EApp(opt env var, List.map (opt env) args)
      end
    | T.EApp(EFn(xs, body) as f, args) ->
      begin match try_specialize xs body args env with
      | Some specialized -> specialized
      | None -> T.EApp(opt env f, List.map (opt env) args)
      end
    | T.EApp(f, args) ->  T.EApp(opt env f, List.map (opt env) args)
    (* | T.EProj(T.EVar T.Local(x, NoFieldAccess), k) as proj-> *)

    | T.EProj(v, n) -> T.EProj(opt env v, n)
    | T.EMatch(v, x, cls) -> T.EMatch(opt env v, x, List.map (opt env) cls)
    | T.ESwitch(v, cls) -> T.ESwitch(opt env v, List.map (opt env) cls)
    | T.EHandle h -> T.EHandle
      {  h with body = opt env h.body
              ; return_body = opt env h.return_body
              ; op_handler = opt env h.op_handler
      }
    | T.EOp(i, arg) -> T.EOp(i, opt env arg)
    | T.EExtern(name, args) -> T.EExtern(name, List.map (opt env) args)

  (* Try specializing higher order functions that receive multi-argument redex as a first argument. For example:
      in expression 'foldl (+) 0 xs', 'foldl' and '(+)' will be inlined and first argument ((+)) will be marked as redex. *)
  and try_specialize xs body args env =
    let is_multi_arg_redex = function
    | T.EVar (Local(x, NoFieldAccess)) ->
      begin match OptEnv.lookup_var env x with
      | Some (T.EFnRedex _ as redex) -> Analysis.arity redex >= 2
      | _ -> false
      end
    | T.EVar (Local(x, RecursiveAccess k)) ->
      begin match OptEnv.lookup_var env x with
      | Some (ETuple rfs) -> begin match List.nth rfs k with
        | EFnRedex _ as redex -> Analysis.arity redex >= 2
        | _ -> false
        end
      | _ -> false
      end
    | EFnRedex _ as redex -> Analysis.arity redex >= 2
    | _ -> false

    in match (xs, args) with
    | x :: xs, arg :: args when
      is_multi_arg_redex arg &&
      Analysis.not_passing_arg_further x body ->
        begin match arg with
        | T.EVar (Local(y, NoFieldAccess)) ->
          Some (T.EApp(T.EFnRedex([x], T.EApp(T.EFn(xs, body), args)), [OptEnv.get_var env y]))
        | T.EVar (Local(y, RecursiveAccess k)) ->
          begin match OptEnv.get_var env y with
          | T.ETuple rfs ->
            Some (T.EApp(T.EFnRedex([x], T.EApp(T.EFn(xs, body), args)), [List.nth rfs k]))
          | _ -> None
          end
        | e -> Some (T.EApp(T.EFnRedex([x], T.EApp(T.EFn(xs, body), args)), [e]))
        end
    | _, _ -> None

  in opt OptEnv.empty expr



let beta_reduce expr =
  let rec opt env e =
    match e with
    | T.ELit lit -> T.ELit lit
    | (T.EVar x) as var -> begin match x with
      | T.Local(n, NoFieldAccess) -> begin match OptEnv.lookup_var env n with
        | Some e -> e
        | None -> var
        end
      | _ -> var
      end
    | T.EFn(args, body) -> T.EFn(args, opt env body)
    | T.EFnRedex(args, body) -> T.EFnRedex(args, opt env body)
    | T.ETuple es -> T.ETuple (List.map (opt env) es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map (opt env) es)
    | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map (opt env) es)
    | T.ELet(x, e1, e2) -> T.ELet(x, opt env e1, opt env e2)
    | T.ELetPure(x, e1, e2) -> T.ELetPure(x, opt env e1, opt env e2)
    | T.EFix(r, rfs, e) -> T.EFix(r, List.map (opt env) rfs, opt env e)
    | T.EProj(v, n) -> T.EProj(opt env v, n)
    | T.EMatch(v, x, cls) -> T.EMatch(opt env v, x, List.map (opt env) cls)
    | T.ESwitch(v, cls) -> T.ESwitch(opt env v, List.map (opt env) cls)
    | T.EHandle h -> T.EHandle
      { h with body = opt env h.body
             ; return_body = opt env h.return_body
             ; op_handler = opt env h.op_handler
      }
    | T.EOp(i, arg) ->  begin match OptEnv.lookup_var env i with
        | Some (T.EVar (T.Local(i', NoFieldAccess))) -> T.EOp(i', opt env arg)
        | Some _ -> failwith "Optimization: expected instance"
        | None -> T.EOp(i, opt env arg)
        end
    | T.EExtern(name, args) -> T.EExtern(name, List.map (opt env) args)
    | T.EApp(f, args) ->
      match opt env f with
      | T.EFnRedex (xs, body) ->
        let env' = List.fold_left2 OptEnv.add_to_env env xs (List.map (opt env) args)
        in opt env' body
      | f' -> T.EApp(f', List.map (opt env) args)
  in opt OptEnv.empty expr



let rec let_pure_unused expr =
  let var_use_counts = Analysis.count_var_uses expr in
  let rec opt e =
    match e with
    | T.ELit lit -> T.ELit lit
    | T.EVar x -> T.EVar x
    | T.EFn(args, body) -> T.EFn(args, opt body)
    | T.EFnRedex(args, body) -> T.EFnRedex(args, opt body)
    | T.ETuple es -> T.ETuple (List.map opt es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map opt es)
    | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map opt es)
    | T.ELet(x, e1, e2) ->
      let e1' = opt e1 in
      if Analysis.lookup_var_count var_use_counts x NoFieldAccess = None && Analysis.syntactically_pure e1'
        then opt e2
        else T.ELet(x, e1', opt e2)
    | T.ELetPure(x, e1, e2) ->
      if Analysis.lookup_var_count var_use_counts x NoFieldAccess = None
        then opt e2
        else T.ELetPure(x, opt e1, opt e2)
    | T.EFix(r, rfs, e) -> T.EFix(r, List.map opt rfs, opt e)
    | T.EApp(f, args) ->  T.EApp(opt f, List.map opt args)
    | T.EProj(v, n) -> T.EProj(opt v, n)
    | T.EMatch(v, x, cls) -> T.EMatch(opt v, x, List.map opt cls)
    | T.ESwitch(v, cls) -> T.ESwitch(opt v, List.map opt cls)
    | T.EHandle h -> T.EHandle
      { h with body = opt h.body
              ; return_body = opt h.return_body
              ; op_handler = opt h.op_handler
      }
    | T.EOp(i, arg) -> T.EOp(i, opt arg)
    | T.EExtern(name, args) -> T.EExtern(name, List.map opt args)
in opt expr



let rec eta_reduce e =
  match e with
  | T.ELit lit -> T.ELit lit
  | T.EVar x -> T.EVar x
  | T.EFn([x], (T.EApp (e, [T.EVar (T.Local(x', NoFieldAccess))]) as body)) ->
    if x = x'
      then e
      else T.EFn([x], body)
  | T.EFn(args, body) -> T.EFn(args, eta_reduce body)
  | T.EFnRedex(args, body) -> T.EFnRedex(args, eta_reduce body)
  | T.ETuple es -> T.ETuple (List.map eta_reduce es)
  | T.EConstr(n, es) -> T.EConstr(n, List.map eta_reduce es)
  | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map eta_reduce es)
  | T.ELet(x, e1, e2) -> T.ELet(x, eta_reduce e1, eta_reduce e2)
  | T.ELetPure(x, e1, e2) -> T.ELetPure(x, eta_reduce e1, eta_reduce e2)
  | T.EFix(r, rfs, e) -> T.EFix(r, List.map eta_reduce rfs, eta_reduce e)
  | T.EApp(f, args) ->  T.EApp(eta_reduce f, List.map eta_reduce args)
  | T.EProj(v, n) -> T.EProj(eta_reduce v, n)
  | T.EMatch(v, x, cls) -> T.EMatch(eta_reduce v, x, List.map eta_reduce cls)
  | T.ESwitch(v, cls) -> T.ESwitch(eta_reduce v, List.map eta_reduce cls)
  | T.EHandle h -> T.EHandle
    { h with body = eta_reduce h.body
            ; return_body = eta_reduce h.return_body
            ; op_handler = eta_reduce h.op_handler
    }
  | T.EOp(i, arg) -> T.EOp(i, eta_reduce arg)
  | T.EExtern(name, args) -> T.EExtern(name, List.map eta_reduce args)



let simple_rewrites expr =
  let int_from_lit = function
  | Lang.RichBaseType.LNum n -> n
  | _ -> failwith "Optimize: Expected int"
  in
  let rec opt e =
    match e with
    | T.ELit lit -> T.ELit lit
    | T.EVar x -> T.EVar x
    | T.EFn(args, body) -> T.EFn(args, opt body)
    | T.EFnRedex(args, body) -> T.EFnRedex(args, opt body)
    | T.ETuple [] -> T.ELit (Lang.RichBaseType.LNum 0)
    | T.ETuple es -> T.ETuple (List.map opt es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map opt es)
    | T.EPrim(prim_code, es) -> begin match (prim_code, es) with
      | (Lang.PrimCodes.Add,  [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.AddConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Add,  [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.AddConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Sub,  [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.SubConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Sub,  [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.SubFromConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Mult, [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.MultByConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Mult, [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.MultByConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Div,  [e; T.ELit lit]) -> let n = int_from_lit lit in
        if n = 2
          then T.EPrim(Lang.PrimCodes.AsrConst 1, [opt e])
          else T.EPrim(Lang.PrimCodes.DivByConst n, [opt e])
      | (Lang.PrimCodes.Div,  [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.DivConstBy(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Mod,  [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.ModByConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Mod,  [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.ModConstBy(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Eq,   [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.EqConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Eq,   [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.EqConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Neq,  [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.NeqConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Neq,  [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.NeqConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Lt,   [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.LtConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Lt,   [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.GtConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Le,   [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.LeConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Le,   [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.GeConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Gt,   [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.GtConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Gt,   [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.LtConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Ge,   [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.GeConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Ge,   [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.LeConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.And,  [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.AndConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.And,  [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.AndConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Or,   [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.OrConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Or,   [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.OrConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Xor,  [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.XorConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Xor,  [T.ELit lit; e]) -> T.EPrim(Lang.PrimCodes.XorConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Lsl,  [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.LslConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Lsr,  [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.LsrConst(int_from_lit lit), [opt e])
      | (Lang.PrimCodes.Asr,  [e; T.ELit lit]) -> T.EPrim(Lang.PrimCodes.AsrConst(int_from_lit lit), [opt e])
      | _ -> T.EPrim(prim_code, List.map opt es)
      end
    | T.ELet(x, e1, e2) -> T.ELet(x, opt e1, opt e2)
    | T.ELetPure(x, e1, e2) -> T.ELetPure(x, opt e1, opt e2)
    | T.EFix(r, rfs, e) -> T.EFix(r, List.map opt rfs, opt e)
    | T.EApp(f, args) ->  T.EApp(opt f, List.map opt args)
    | T.EProj(v, n) -> T.EProj(opt v, n)
    | T.EMatch(v, x, [cl]) -> T.ELet(x, opt v, opt cl)
    | T.EMatch(v, x, cls) -> T.EMatch(opt v, x, List.map opt cls)
    | T.ESwitch(v, [cl]) ->
      if Analysis.syntactically_pure v
        then opt cl
        else T.ESwitch(opt v, [opt cl])
    | T.ESwitch(v, cls) -> T.ESwitch(opt v, List.map opt cls)
    | T.EHandle h -> T.EHandle
      { h with body = opt h.body
             ; return_body = opt h.return_body
             ; op_handler = opt h.op_handler
      }
    | T.EOp(i, arg) -> T.EOp(i, opt arg)
    | T.EExtern(name, args) -> T.EExtern(name, List.map opt args)
  in opt expr



let lambda_lifting expr =
  let next_global = ref 0 in
  let globals = ref [] in
  let rec opt env e =
    match e with
    | T.ELit lit -> T.ELit lit
    | T.EVar v -> begin match v with
      | T.Local(x, NoFieldAccess) -> begin match OptEnv.lookup_var env x with
        | None -> T.EVar v
        | Some n -> T.EVar (T.Global(n))
        end
      | T.Local(x, RecursiveAccess k) -> begin match OptEnv.lookup_var env x with
        | None -> T.EVar v
        | Some n -> T.EVar (T.Global(n + k))
        end
      | _ -> T.EVar v
      end
    | T.EFn(args, body) ->
      T.EFn(args, opt env body)
    | T.EFnRedex(args, body) ->
      T.EFnRedex(args, opt env body)
    | T.ETuple es -> T.ETuple (List.map (opt env) es)
    | T.EConstr(n, es) -> T.EConstr(n, List.map (opt env) es)
    | T.EPrim(prim_code, es) -> T.EPrim(prim_code, List.map (opt env) es)
    | T.ELet(x, e1, e2)
    | T.ELetPure(x, e1, e2) ->
      let e1' = opt env e1 in
      if Analysis.is_fn e1' && Analysis.no_free_vars e1'
        then
          let n = !next_global in
          next_global := !next_global + 1;
          globals := e1' :: !globals;
          opt (OptEnv.add_to_env env x n) e2
        else T.ELet(x, e1', opt env e2)
    | T.EFix(r, rfs, e) ->
      let rfs' = List.map (opt env) rfs in
      if List.for_all (Analysis.no_free_vars ~bindings: [r]) rfs'
        then
          let n = !next_global in
          next_global := !next_global + List.length rfs';
          let globals_copy = !globals in
          globals := [];
          let rfs'' = List.map (opt (OptEnv.add_to_env env r n)) rfs' in
          globals := !globals @ List.rev rfs'' @ globals_copy;
          opt (OptEnv.add_to_env env r n) e
        else T.EFix(r, rfs', opt env e)
    | T.EApp(f, args) ->  T.EApp(opt env f, List.map (opt env) args)
    | T.EProj(v, n) -> T.EProj(opt env v, n)
    | T.EMatch(v, x, cls) -> T.EMatch(opt env v, x, List.map (opt env) cls)
    | T.ESwitch(v, cls) -> T.ESwitch(opt env v, List.map (opt env) cls)
    | T.EHandle h -> T.EHandle
      { h with body = opt env h.body
             ; return_body = opt env h.return_body
             ; op_handler = opt env h.op_handler
      }
    | T.EOp(i, arg) -> T.EOp(i, opt env arg)
    | T.EExtern(name, args) -> T.EExtern(name, List.map (opt env) args)
  in T.Program(List.rev !globals, opt OptEnv.empty expr)

let optimize (T.Program(_, prog)) =
  let optimization_pass e =
    e |> app_to_let |> eta_let |> proj_to_field_accessor |> alias |> hoist_let_let |> inline
      |> beta_reduce |> let_pure_unused |> eta_reduce in

  let prog' = ref prog in
  let prog'' = ref (!prog' |> eta_reduce |> make_type_functions_indirect |> optimization_pass) in

  let optimization_pass_loop () =
    while !prog' <> !prog'' do
      prog' := !prog'';
      prog'' := optimization_pass !prog';
    done
  in

  optimization_pass_loop ();

  prog'' := !prog' |> arity_rewrite |> find_redexes |> optimization_pass;

  optimization_pass_loop ();

  prog'' := !prog' |> simple_rewrites |> find_redexes |> optimization_pass;

  optimization_pass_loop ();

  !prog'' |> lambda_lifting