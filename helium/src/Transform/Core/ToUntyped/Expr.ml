open Common

let get_recursive_function_name = function
  | S.RFFun(x, _, _, _, _, _) -> x
  | S.RFInstFun(x, _, _, _, _, _) -> x

let make_tfun targs expr =
  let mk_tfun _ f = T.EFnRedex([], f) in
  List.fold_right mk_tfun targs expr

let rec make_typeval (tp) =
  match S.Type.view tp with
  | S.TForall(_, tp) -> T.EFnRedex([], make_typeval tp)
  | S.TDataDef(_, ctors)  -> T.ELit (LNum 0)
  | S.TRecordDef(_, flds) -> T.ELit (LNum 0)
  | S.TEffsigDef(_, ops)  -> T.ELit (LNum 0)
  | S.TBase _ | S.TNeutral _ | S.TTuple _ | S.TArrow _ | S.TExists _ | S.TForallInst _
  | S.TFuture _ ->
    failwith "Compilation error: invalid type definition."

let rec tr_extern ?(args=[]) tp extern_name =
  match S.Type.view tp with
  | S.TForall(_, tp) -> T.EFnRedex([], tr_extern ~args tp extern_name)
  | S.TArrow(_, t2, _) ->
    let arg = T.Var.fresh () in
    T.EFnRedex([arg], tr_extern ~args: (T.EVar (T.Local(arg, NoFieldAccess)) :: args) t2 extern_name)
  | _ ->
    match extern_name with
    | "helium_addInt" ->  T.EPrim(Lang.PrimCodes.Add,      List.rev args)
    | "helium_subInt" ->  T.EPrim(Lang.PrimCodes.Sub,      List.rev args)
    | "helium_mulInt" ->  T.EPrim(Lang.PrimCodes.Mult,     List.rev args)
    | "helium_divInt" ->  T.EPrim(Lang.PrimCodes.Div,      List.rev args)
    | "helium_modInt" ->  T.EPrim(Lang.PrimCodes.Mod,      List.rev args)
    | "helium_eqInt"  ->  T.EPrim(Lang.PrimCodes.Eq,       List.rev args)
    | "helium_neqInt" ->  T.EPrim(Lang.PrimCodes.Neq,      List.rev args)
    | "helium_ltInt"  ->  T.EPrim(Lang.PrimCodes.Lt,       List.rev args)
    | "helium_gtInt"  ->  T.EPrim(Lang.PrimCodes.Gt,       List.rev args)
    | "helium_leInt"  ->  T.EPrim(Lang.PrimCodes.Le,       List.rev args)
    | "helium_geInt"  ->  T.EPrim(Lang.PrimCodes.Ge,       List.rev args)
    | "helium_andInt" ->  T.EPrim(Lang.PrimCodes.And,      List.rev args)
    | "helium_orInt"  ->  T.EPrim(Lang.PrimCodes.Or,       List.rev args)
    | "helium_xorInt" ->  T.EPrim(Lang.PrimCodes.Xor,      List.rev args)
    | "helium_lslInt" ->  T.EPrim(Lang.PrimCodes.Lsl,      List.rev args)
    | "helium_lsrInt" ->  T.EPrim(Lang.PrimCodes.Lsr,      List.rev args)
    | "helium_asrInt" ->  T.EPrim(Lang.PrimCodes.Asr,      List.rev args)
    | "helium_negInt" ->  T.EPrim(Lang.PrimCodes.Neg,      List.rev args)
    | "helium_notInt" ->  T.EPrim(Lang.PrimCodes.Not,      List.rev args)
    | "helium_exit"   ->  T.EPrim(Lang.PrimCodes.ExitWith, List.rev args)
    | _ -> EExtern(extern_name, List.rev args)


(* Translation from Core to Untyped.
   Even though the Untyped is not defined in the a-normal form, this translation
   preserves a-normal form, which is crucial for the correctness of later optimizations. *)
let rec tr_expr env (e : S.expr) =
  match e.data with
  | S.EValue v -> tr_value env v
  | S.ELet(x, e1, e2) ->
    let x' = T.Var.fresh () in
    T.ELet(x', tr_expr env e1, tr_expr (Env.add_local_var env x x') e2)
  | S.ELetPure(x, e1, e2) ->
    let x' = T.Var.fresh () in
    T.ELetPure(x', tr_expr env e1, tr_expr (Env.add_local_var env x x') e2)
  | S.ETypeApp(v, _) -> T.EApp (tr_value env v, [])
  | S.EInstApp(v, a) -> T.EApp (tr_value env v, [ T.EVar (T.Local(Env.lookup_inst env a, NoFieldAccess)) ])
  | S.EApp(v1, v2)   -> T.EApp (tr_value env v1, [ tr_value env v2 ])
  | S.EProj(v, n) -> T.EProj (tr_value env v, n)
  | S.ESelect(_, n, v) -> T.EProj (tr_value env v, n)
  | S.ETypeDef(tds, e) -> tr_typedefs env tds e
  | S.EFix(rfs, e) ->
    let r = T.Var.fresh () in
    let source_vars = List.map get_recursive_function_name rfs in
    let env' = Env.add_local_recursive_binding env source_vars r in
    T.EFix(r, List.map (tr_recursive_function env') rfs, tr_expr env' e)
  | S.EUnpack(_, x, v, e)->
    let x' = T.Var.fresh () in
    T.ELet(x', tr_value env v, tr_expr (Env.add_local_var env x x') e)
  | S.EMatch(_, v, cls, _) ->
    if List.for_all (fun (S.Clause(_, xs, _)) -> List.length xs = 0) cls
      then
        T.ESwitch(tr_value env v, List.map (fun (S.Clause(_, _, e)) -> tr_expr env e) cls)
      else
        let x' = T.Var.fresh () in
        T.EMatch(tr_value env v, x', List.map (tr_clause env x') cls)
  | S.ERepl _ | S.EReplExpr _ | S.EReplImport _ -> failwith "Compilation of repl code"
  | S.EHandle h ->
    let i = T.Var.fresh () in
    let op_arg_var' = T.Var.fresh () in
    let resume_var' = T.Var.fresh () in
    let return_var' = T.Var.fresh () in
    T.EHandle
    { effinst = i
    ; body = tr_expr (Env.add_inst env h.effinst i) h.body
    ; op_arg_var = op_arg_var'
    ; resume_var = resume_var'
    ; op_handler =
      if List.length h.op_handlers != 1 then
        T.ESwitch (T.EVar(T.Local(op_arg_var', TupleAccess 0)),
          List.map (tr_handler env op_arg_var' resume_var') h.op_handlers)
      else
        tr_handler env op_arg_var' resume_var' (List.hd h.op_handlers)
    ; return_var = return_var'
    ; return_body =
        tr_expr (Env.add_local_var env h.return_var return_var') h.return_body
    }
  | S.EOp(_, n, a, _, args) ->
    T.EOp(Env.lookup_inst env a, T.EConstr(n, List.map (tr_value env) args))

and tr_value env (v : S.value) =
  match v.data with
  | S.VLit lit             -> T.ELit lit
  | S.VVar x               -> T.EVar(Env.lookup_var env x)
  | S.VTuple vs            -> T.ETuple(List.map (tr_value env) vs)
  | S.VCtor(_, n, _, [])   -> T.ELit (LNum n)
  | S.VCtor(_, n, _, vs)   -> T.EConstr(n, List.map (tr_value env) vs)
  | S.VRecord(_, vs)       -> T.ETuple(List.map (tr_value env) vs)
  | S.VFn(x, _, body)      -> let x' = T.Var.fresh() in
    T.EFn([x'], tr_expr(Env.add_local_var env x x') body)
  | S.VTypeFun(_, body)    -> T.EFnRedex([], tr_expr env body)
  | S.VInstFun(x, _, body) -> let x' = T.Var.fresh() in
    T.EFn([x'], tr_expr(Env.add_inst env x x') body)
  | S.VPack(_, v, _, _)    -> tr_value env v
  | VExtern(name, tp)      -> tr_extern tp name

and tr_typedefs env tds e =
  match tds with
  | [] -> tr_expr env e
  | S.TypeDef(_, x, tp) :: tds' ->
    let x' = T.Var.fresh() in
    T.ELet (x', make_typeval tp, tr_typedefs (Env.add_local_var env x x') tds' e)

and tr_clause env x' (Clause(_, xs, body)) =
  tr_expr (Env.add_local_tuple_binding ~offset: 1 env xs x') body

and tr_handler env  xs' xr' (OpHandler(_, xs, xr, body)) =
  tr_expr (Env.add_local_tuple_binding ~offset: 1 (Env.add_local_var env xr xr') xs xs') body

and tr_recursive_function env = function
  | S.RFFun(_, _, targs, y, _, body) ->
    let y' = T.Var.fresh() in
    make_tfun targs (T.EFn([y'], tr_expr (Env.add_local_var env y y') body))
  | S.RFInstFun(_, _, targs, a, _, body) ->
    let a' = T.Var.fresh() in
    make_tfun targs (T.EFn([a'], tr_expr (Env.add_inst env a a') body))