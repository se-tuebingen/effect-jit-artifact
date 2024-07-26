open Lang.Node
open Common

let rec tr_expr env e =
  let make data = { meta = e.meta; data = data } in
  match e.data with
  | S.EValue v ->
    tr_value env v

  | S.ECoerce(crc, e1) ->
    bind_expr env e1 (fun v1 ->
    Coercion.coerce_ex e.meta env crc v1)

  | S.EPack(insts, extp, e1) ->
    bind_expr env e1 (fun v1 ->
    make (T.EValue (fst (Pack.pack_value e.meta env insts extp v1))))

  | S.ELet(xs, x, e1, e2) ->
    bind_expr env e1 (fun v1 ->
    Pack.unpack_value e.meta env xs v1 (fun env v1 ->
    bind_value_as e.meta env v1 x (fun env ->
    tr_expr env e2)))

  | S.EFix(rfs, e2) ->
    let (env, rfs) = tr_rec_functions env rfs in
    make (T.EFix(rfs, tr_expr env e2))

  | S.ETypeDef(tds, e2) ->
    let (env, tds) = TypeDef.tr_typedefs env tds in
    make (T.ETypeDef(tds, tr_expr env e2))

  | S.EApp(v1, v2) ->
    bind_value env v1 (fun v1 ->
    bind_value env v2 (fun v2 ->
    make (T.EApp(v1, v2))))

  | S.EInstApp(v, a) ->
    bind_value env v (fun v ->
    let a = Type.tr_effinst_expr env a in
    make (T.EInstApp(v, a)))

  | S.EMatch(v, cls, tp) ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, tr_value env v,
      PatternMatch.tr_match 
        ~env
        ~uid:e.meta
        ~typ:(Type.tr_ex_type env tp)
        ~bind_value:bind_value
        x
        (cls |> List.map (fun cl ->
          match cl.data with
          | S.Clause(pat, body) -> (pat, (fun env -> tr_expr env body))))))

  | S.EEmptyMatch(v, proof, tp) ->
    let x = T.Var.fresh () in
    let y = T.Var.fresh () in
    make (T.ELetPure(x, tr_value env v,
    make (T.ELetPure(y, tr_value env proof,
    make (T.EMatch(make (T.VVar y), make (T.VVar x), [],
      Type.tr_ex_type env tp))))))

  | S.EHandle hdata ->
    bind_value env hdata.proof (fun proof ->
    let (env_in, a) = Env.add_effinst env hdata.effinst in
    let body    = tr_expr env_in hdata.body in
    let ops     = List.map (Type.tr_op_decl env) hdata.ops in
    let ret_tp  = Type.tr_ex_type env hdata.ret_type in
    let ret_eff = Type.tr_type env hdata.ret_effect in
    let hs = List.mapi (fun i op ->
        tr_op_handler e.meta env i op hdata.op_handlers ret_tp
      ) ops in
    let x      = T.Var.fresh () in
    let ret_cl = tr_return_clause e.meta env x hdata.ret_clauses ret_tp in
    let h_expr = make (T.EHandle(
      { proof       = proof
      ; effinst     = a
      ; body        = body
      ; op_handlers = hs
      ; return_var  = x
      ; return_body = ret_cl
      ; htype       = ret_tp
      ; heffect     = ret_eff
      })) in
    let fin_tp = Type.tr_ex_type env hdata.fin_type in
    tr_fin_clause e.meta env h_expr hdata.fin_clauses fin_tp)

  | S.EHandleWith(a, s, body, hexp) ->
    bind_value env hexp (fun hexp ->
    let s = Type.tr_type env s in
    let (env, a) = Env.add_effinst env a in
    let dummy = T.Var.fresh () in
    make (T.EApp(hexp,
      make (T.VInstFun(a, s,
        make (T.EValue (make (T.VFn(dummy, T.Type.tuple [],
          tr_expr env body)))))))))

  | S.EOp(proof, n, a, targs, args) ->
    bind_value env proof (fun proof ->
    bind_values env args (fun args ->
    make (T.EOp(proof, n, Env.lookup_inst env a,
      List.map (Type.tr_type_arg env) targs,
      args))))

  | S.ERepl(cont, tp, eff, prompt) ->
    let tp  = Type.tr_ex_type env tp in
    let eff = Type.tr_type env eff in
    let cont () =
      let res = cont () in
      let env = Env.update_meta env res.meta in
      match tr_expr env res.data with
      | e -> { res with data = e } 
      | exception (Errors.Error err) ->
        raise (CommonRepl.Error(
          Flow.State.create ~meta:(Env.metadata env)
            Errors.flow_node err,
          res.rollback))
    in
    make (T.ERepl(cont, tp, eff, prompt))
  | S.EReplExpr(e1, tp, e2) ->
    make (T.EReplExpr(tr_expr env e1, tp, tr_expr env e2))

  | S.EReplImport(imports, rest) ->
    let (env, imports) = Import.tr_imports env imports in
    make (T.EReplImport(imports, tr_expr env rest))

and bind_expr env e cont =
  let make data = { meta = e.meta; data = data } in
  let e = tr_expr env e in
  match e.data with
  | T.EValue v -> cont v
  | _ ->
    let x = T.Var.fresh () in
    make (T.ELet(x, e, cont (make (T.VVar x))))

and tr_rec_functions env rfs =
  let prepare_rec_function env rf =
    match rf with
    | S.RFFun(f, _, _, _) | S.RFInstFun(f, _, _, _, _)
    | S.RFHandler(f, _, _, _, _, _) ->
      let tp = Type.tr_type env (S.Var.typ f) in
      let f' = T.Var.fresh () in
      let env = Env.add_var env f f' in
      (env, (f', tp, rf))
  in
  let (env, rfs) = Utils.ListExt.fold_map prepare_rec_function env rfs in
  let finalize (f, tp, rf) =
    match rf with
    | S.RFFun(_, targs, arg, body) ->
      let (env, targs) = Env.add_tvars env targs in
      let x = T.Var.fresh () in
      let env = Env.add_var env arg x in
      T.RFFun(f, tp, targs, x, Type.tr_type env (S.Var.typ arg),
        tr_expr env body)

    | S.RFInstFun(_, targs, a, s, body) ->
      let (env, targs) = Env.add_tvars env targs in
      let s = Type.tr_type env s in
      let (env, a) = Env.add_effinst env a in
      T.RFInstFun(f, tp, targs, a, s, tr_expr env body)

    | S.RFHandler(_, targs, s, extp, eff, body) ->
      let (env, targs) = Env.add_tvars env targs in
      let s    = Type.tr_type env s in
      let extp = Type.tr_ex_type env extp in
      let eff  = Type.tr_type env eff in
      let a = T.EffInst.fresh () in
      let comp_tp = T.Type.forall_inst a s
        (T.Type.arrow (T.Type.tuple []) extp
          (T.Type.eff_cons (T.Type.eff_inst a) eff)) in
      let comp = T.Var.fresh () in
      let make data = { body with data = data } in
      T.RFFun(f, tp, targs, comp, comp_tp,
        bind_expr env body (fun v ->
          make (T.EApp(v, make (T.VVar comp)))))
  in
  (env, List.map finalize rfs)

and tr_value env v =
  let make data = { meta = v.meta; data = data } in
  match v.data with
  | S.VLit lit ->
    make (T.EValue (make (T.VLit lit)))

  | S.VVar x ->
    make (T.EValue (make (T.VVar (Env.lookup_var env x))))

  | S.VCoerce(crc, v1) ->
    bind_value env v1 (fun v1 ->
    Coercion.coerce v.meta env crc v1)

  | S.VVarFn(x, body) ->
    let tp = Type.tr_type env (S.Var.typ x) in
    let y  = T.Var.fresh () in
    make (T.EValue (make (T.VFn(y, tp,
      tr_expr (Env.add_var env x y) body))))

  | S.VFn(pat, body, rtp) ->
    let tp = Type.tr_type env (S.Pattern.typ pat) in
    let x  = T.Var.fresh () in
    make (T.EValue (make (T.VFn(x, tp,
      PatternMatch.tr_match 
        ~env
        ~uid:v.meta
        ~typ:(Type.tr_ex_type env rtp)
        ~bind_value:bind_value
        x
        [ (pat, (fun env -> tr_expr env body)) ]))))

  | S.VTypeFun(xs, body) ->
    tr_type_fun v.meta env xs body

  | S.VTypeFunE(xs, body) ->
    tr_type_fun_e v.meta env xs body

  | S.VTypeApp(v1, tps) ->
    bind_value env v1 (fun v1 ->
    tr_type_app v.meta env v1 tps)

  | S.VInstFun(a, s, body) ->
    let s = Type.tr_type env s in
    let (env, a) = Env.add_effinst env a in
    make (T.EValue (make (T.VInstFun(a, s, tr_expr env body))))

  | S.VHandler hdata ->
    bind_value env hdata.proof (fun proof ->
    let ops       = List.map (Type.tr_op_decl env) hdata.ops in
    let s         = Type.tr_type env hdata.effsig in
    let a         = T.EffInst.fresh () in
    let in_type   = Type.tr_ex_type env hdata.in_type in
    let in_effect = Type.tr_type env hdata.in_effect in
    let ret_tp  = Type.tr_ex_type env hdata.ret_type in
    let ret_eff = Type.tr_type env hdata.ret_effect in
    let ctype =
      T.Type.forall_inst a s
        (T.Type.arrow (T.Type.tuple []) in_type
          (T.Type.eff_cons (T.Type.eff_inst a) in_effect)) in
    let body_x = T.Var.fresh () in
    let tmp = T.Var.fresh () in
    let body = make (T.ELetPure(tmp, 
      make (T.EInstApp(make (T.VVar body_x), a)),
      make (T.EApp(make (T.VVar tmp), make (T.VTuple []))))) in
    let hs = List.mapi (fun i op ->
        tr_op_handler v.meta env i op hdata.op_handlers ret_tp
      ) ops in
    let ret_x = T.Var.fresh () in
    let ret_cl = tr_return_clause v.meta env ret_x hdata.ret_clauses ret_tp in
    let h_expr = make (T.EHandle(
      { proof       = proof
      ; effinst     = a
      ; body        = body
      ; op_handlers = hs
      ; return_var  = ret_x
      ; return_body = ret_cl
      ; htype       = ret_tp
      ; heffect     = ret_eff
      })) in
    let fin_tp = Type.tr_ex_type env hdata.out_type in
    make (T.EValue (make (T.VFn(body_x, ctype,
      tr_fin_clause v.meta env h_expr hdata.fin_clauses fin_tp)))))
  
  | S.VCtor(proof, n, targs, args) ->
    bind_value env proof (fun proof ->
    bind_values env args (fun args ->
    make (T.EValue (make (T.VCtor(proof, n,
      List.map (Type.tr_type_arg env) targs,
      args))))))

  | S.VSelect(proof, n, v) ->
    bind_value env proof (fun proof ->
    bind_value env v     (fun v ->
    make (T.ESelect(proof, n, v))))

  | S.VRecord(proof, vs) ->
    bind_value env proof (fun proof ->
    bind_values env vs (fun vs ->
    make (T.EValue (make (T.VRecord(proof, vs))))))

  | S.VStruct defs ->
    tr_struct_defs env defs (fun vs ->
    make (T.EValue (make (T.VTuple vs))))

  | S.VSelThis(decls, v1) ->
    let n = S.Decl.this_index decls in
    bind_value env v1 (fun v1 ->
    make (T.EProj(v1, n)))

  | S.VSelTypedef(decls, v1) ->
    let n = S.Decl.typedef_index decls in
    bind_value env v1 (fun v1 ->
    make (T.EProj(v1, n)))

  | S.VSelVal(decls, v1, name) ->
    let n = S.Decl.val_index decls name in
    bind_value env v1 (fun v1 ->
    make (T.EProj(v1, n)))

  | S.VSelOp(decls, v1, name) ->
    let n = S.Decl.op_index decls name in
    bind_value env v1 (fun v1 ->
    make (T.EProj(v1, n)))

  | S.VSelCtor(decls, v1, name) ->
    let n = S.Decl.ctor_index decls name in
    bind_value env v1 (fun v1 ->
    make (T.EProj(v1, n)))

  | S.VSelField(decls, v1, name) ->
    let n = S.Decl.field_index decls name in
    bind_value env v1 (fun v1 ->
    make (T.EProj(v1, n)))

  | S.VTypeWit _ | S.VEffectWit _ | S.VEffsigWit _ ->
    make (T.EValue (make (T.VTuple [])))

  | S.VExtern(name, tp) ->
    make (T.EValue (make (T.VExtern(name, Type.tr_type env tp))))

and bind_value env v cont =
  let make data = { meta = v.meta; data = data } in
  let e = tr_value env v in
  match e.data with
  | T.EValue v -> cont v
  | _ ->
    let x = T.Var.fresh () in
    make (T.ELet(x, e, cont (make (T.VVar x))))

and bind_values env vs cont =
  match vs with
  | []      -> cont []
  | v :: vs ->
    bind_value  env v  (fun v ->
    bind_values env vs (fun vs ->
    cont (v :: vs)))

and tr_type_fun meta env xs body =
  let make data = { meta = meta; data = data } in
  match xs with
  | [] ->
    tr_value env body
  | S.TVar.Pack x :: xs ->
    let (env, x) = Env.add_tvar env x in
    make (T.EValue (make (T.VTypeFun(x, tr_type_fun meta env xs body))))

and tr_type_fun_e meta env xs body =
  let make data = { meta = meta; data = data } in
  match xs with
  | [] ->
    tr_expr env body
  | S.TVar.Pack x :: xs ->
    let (env, x) = Env.add_tvar env x in
    make (T.EValue (make (T.VTypeFun(x, tr_type_fun_e meta env xs body))))

and tr_type_app meta env v tps =
  let make data = { meta = meta; data = data } in
  match tps with
  | [] -> make (T.EValue v)
  | S.TpArg tp :: tps ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.ETypeApp(v, Type.tr_type env tp)),
      tr_type_app meta env (make (T.VVar x)) tps))

and bind_value_as meta env v x cont =
  let make data = { meta = meta; data = data } in
  match v.data with
  | T.VVar y -> cont (Env.add_var env x y)
  | _ ->
    let y = T.Var.fresh () in
    make (T.ELetPure(y, make (T.EValue v), cont (Env.add_var env x y)))

and tr_struct_def env def cont =
  match def.data with
  | S.SDThis v | S.SDTypedef v | S.SDVal(_, v) | S.SDOp(v, _) | S.SDCtor(v, _)
  | S.SDField(v, _) ->
    bind_value env v cont

and tr_struct_defs env defs cont =
  match defs with
  | [] -> cont []
  | def :: defs ->
    tr_struct_def  env def  (fun v ->
    tr_struct_defs env defs (fun vs ->
    cont (v :: vs)))

and collect_op_handler meta env n op tvs h rx tp =
  match h.data with
  | S.HOp(m, xs, pats, rpat, body) when n = m ->
    let env = Env.add_tvars' env xs tvs in
    Some (env, pats, (fun env ->
      PatternMatch.tr_match
        ~env
        ~uid: meta
        ~typ: tp
        ~bind_value
        rx [ (rpat, fun env -> tr_expr env body) ]))
  | _ -> None

and collect_op_handlers meta env n op tvs hs rx tp =
  Utils.ListExt.filter_map (fun h ->
      collect_op_handler meta env n op tvs h rx tp
    ) hs

and tr_op_handler meta env n op hs tp =
  let (T.OpDecl(name, tvs, tps, rtp)) = op in
  let xs = List.map (fun _ -> T.Var.fresh ()) tps in
  let rx = T.Var.fresh () in
  let pats = collect_op_handlers meta env n op tvs hs rx tp in
  let body =
    PatternMatch.tr_matches
      ~uid: meta
      ~typ: tp
      ~bind_value
      ~case_name: name
      xs pats in
  T.OpHandler(tvs, xs, rx, body)

and bind_var meta v cont =
  match v.data with
  | T.VVar x -> cont x
  | _ ->
    let make data = { meta; data } in
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.EValue v), cont x))

and tr_return_clause meta env x (ex, cls) tp =
  let make data = { meta = meta; data = data } in
  match cls with
  | []  -> make (T.EValue (make (T.VVar x)))
  | cls ->
    Pack.unpack_value meta env ex (make (T.VVar x)) (fun env v ->
    bind_var meta v (fun x ->
    PatternMatch.tr_match
      ~env
      ~uid: meta
      ~typ: tp
      ~bind_value
      x
      (List.map (fun { data = S.Clause(pat, body); _ } ->
          (pat, fun env -> tr_expr env body)
        ) cls)))

and tr_fin_clause meta env h_expr (ex, cls) tp =
  let make data = { meta = meta; data = data } in
  match cls with
  | [] -> h_expr
  | cls ->
    let x = T.Var.fresh () in
    make (T.ELet(x, h_expr,
    Pack.unpack_value meta env ex (make (T.VVar x)) (fun env v ->
    bind_var meta v (fun x ->
    PatternMatch.tr_match
      ~env
      ~uid: meta
      ~typ: tp
      ~bind_value
      x
      (List.map (fun { data = S.Clause(pat, body); _ } ->
          (pat, fun env -> tr_expr env body)
        ) cls)))))
