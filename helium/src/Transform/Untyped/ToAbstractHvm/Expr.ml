open Common

let tr_var env v =
  match v with
  | S.Local(n, NoFieldAccess)  -> [ T.AccessVar (Env.lookup_var env n) ]
  | S.Local(n, TupleAccess k)  -> [ T.AccessVar (Env.lookup_var env n); T.GetField k ]
  | S.Local(n, RecursiveAccess k) -> [ T.AccessVar (Env.lookup_var env n); T.AccessRecursiveBinding k ]
  | S.Global n -> [T.AccessGlobal n]

let rec tr_expr env e =
  match e with
  | S.ELit lit ->
    begin match lit with
    | LNum n -> [ T.ConstInt n ]
    | LString s -> [ T.ConstString s ]
    | LChar c -> [ T.ConstInt (Char.code c) ]
    end

  | S.EVar x -> tr_var env x
  | S.EFn(args, body)
  | S.EFnRedex(args, body) -> [ T.MakeClosure(List.length args,
      tr_expr (Env.add_local_vars env (List.rev args)) body @ [T.Return]) ]

  | S.ETuple es ->
    tr_args env es @ [ T.MakeRecord(List.length es) ]

  | S.EConstr(n, es) ->
    tr_args env es @ [ T.MakeConstructor(n, List.length es) ]

  | S.EPrim(prim_code, es) ->
    tr_args env es @ [T.Prim prim_code]

  | S.ELet(x, e1, e2)
  | S.ELetPure(x, e1, e2) -> tr_expr env e1 @ (T.Let :: tr_expr (Env.add_local_var env x) e2) @ [T.EndLet]
  | S.EFix(r, rfs, e) ->
    let tr_rf = function
    | S.EFn(args, body)
    | S.EFnRedex(args, body) -> (List.length args, tr_expr (Env.add_local_vars env (r :: List.rev args)) body @ [T.Return])
    | _ -> failwith "Compilation error: expected function"
    in
    T.MakeRecursiveBinding (List.map tr_rf rfs) :: T.Let :: tr_expr (Env.add_local_var env r) e @ [ T.EndLet ]
  | S.EApp(S.EVar(Local(x, NoFieldAccess)), args) ->
      tr_args env (args) @ [ T.CallLocal (Env.lookup_var env x) ]
  | S.EApp(S.EVar(Local(x, RecursiveAccess k)), args) ->
    tr_args env (args) @ [ T.CallRecursiveBinding(Env.lookup_var env x, k) ]
  | S.EApp(S.EVar(Global n), args) -> tr_args env (args) @ [ T.CallGlobal n ]
  | S.EApp(f, args) -> tr_args env (args @ [f]) @ [ T.Call ]
  | S.EProj(v, n) -> tr_expr env v @ [ T.GetField n ]
  | S.EMatch(v, x, cls) -> tr_expr env v @ [ T.Match(List.map (tr_expr (Env.add_local_var env x)) cls); EndLet ]
  | S.ESwitch(v, cls) ->
    begin match (v, cls) with
    | S.EPrim(Lang.PrimCodes.EqConst 0, [e]), [left; right] ->
      tr_expr env e @ [T.BranchZero (tr_expr env left, tr_expr env right)]
    | S.EPrim(Lang.PrimCodes.NeqConst 0, [e]), [left; right] ->
      tr_expr env e @ [T.BranchNonZero (tr_expr env left, tr_expr env right)]
    | _ -> tr_expr env v @ [ T.Switch(List.map (tr_expr env) cls) ]
    end
  | S.EHandle h -> [ T.Handle
    { body = tr_expr (Env.add_local_var env h.effinst) h.body @ [
      T.EndHandle; T.Let ] @ tr_expr (Env.add_local_var env h.return_var) h.return_body @ [T.Return]
    ; op_handler = tr_expr (Env.add_local_vars env [h.resume_var; h.op_arg_var]) h.op_handler @ [T.Return]
    } ]


  | S.EOp(i, arg) -> tr_expr env arg @ [T.Op (Env.lookup_var env i)]
  | S.EExtern(name, args) ->
    tr_args env args @ [ T.CallExtern(name, List.length args) ]

and tr_args env = function
| [] -> []
| [arg] -> tr_expr env arg
| arg :: args -> tr_expr env arg @ [T.Push] @ tr_args env args

let tr_global expr = tr_expr (Env.empty ()) expr @ [ T.CreateGlobal ]

let tr_program (S.Program(globals, prog)) =
  T.Instructions((List.map tr_global globals |> List.concat) @ tr_expr (Env.empty ()) prog @ [T.Exit])