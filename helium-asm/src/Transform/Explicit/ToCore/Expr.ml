(* Transform/Explicit/ToCore/Expr.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Lang.Node
open Common

let rec tr_expr env e =
  let make data = { meta = e.meta; data = data } in
  match e.data with
  | S.EValue v -> tr_value env v

  | S.ECoerce(crc, e1) ->
    bind_expr env e1 (fun v1 ->
    Coercion.coerce e.meta env crc v1)

  | S.EPack(insts, tp, e1) ->
    bind_expr env e1 (fun v1 ->
    make (T.EValue (fst (Pack.pack_value e.meta env insts tp v1))))

  | S.ELet(xs, x, e1, e2) ->
    bind_expr env e1 (fun v1 ->
    Pack.unpack_value e.meta env xs v1 (fun env v1 ->
    bind_value_as e.meta env v1 x (fun env ->
    tr_expr env e2)))

  | S.EFix(rfs, e2) ->
    let (env, rfs) = tr_rec_functions env rfs in
    make (T.EFix(rfs, tr_expr env e2))

  | S.ETypeDef(tds, e) ->
    let (env, tds) = Type.tr_typedefs env tds in
    let e = tr_expr env e in
    make (T.ETypeDef(tds, e))

  | S.EApp(e1, e2) ->
    bind_expr env e1 (fun v1 ->
    bind_expr env e2 (fun v2 ->
    make (T.EApp(v1, v2))))

  | S.EInstApp(e, a) ->
    bind_expr env e (fun v ->
    make (T.EInstApp(v, Env.lookup_inst env a)))

  | S.EMatch(e1, cls, tp) ->
    let x = T.Var.fresh () in
    make (T.ELet(x, tr_expr env e1,
      PatternMatch.tr_match
        ~env
        ~uid:e.meta
        ~typ:(Type.tr_type env tp)
        ~bind_value:bind_value
        x
        (cls |> List.map (fun cl ->
          match cl.data with
          | S.Clause(pat, body) -> (pat, (fun env -> tr_expr env body))))))

  | S.EEmptyMatch(e1, proof, tp) ->
    bind_expr env e1 (fun v1 ->
    bind_value env proof (fun proof ->
    make (T.EMatch(proof, v1, [], Type.tr_type env tp))))

  | S.EHandle hdata ->
    let ops = List.map (Type.tr_op_decl env) hdata.ops in
    let (body_env, effinst) = Env.add_effinst env hdata.effinst in
    let htype = Type.tr_type env hdata.htype in
    let (ret_env, ret_var) = Env.add_var env hdata.return_var in
    bind_value env hdata.proof (fun proof ->
    make (T.EHandle
      { proof       = proof
      ; effinst     = effinst
      ; body        = tr_expr body_env hdata.body
      ; op_handlers = List.mapi 
          (fun i op -> tr_op_handler e.meta env i op hdata.op_handlers htype)
          ops
      ; return_var  = ret_var
      ; return_body = tr_expr ret_env hdata.return_body
      ; htype       = htype
      ; heffect     = Type.tr_type env hdata.heffect
      }))

  | S.EOp(proof, n, a, targs, args) ->
    bind_value env proof (fun proof ->
    bind_values env args (fun args ->
    make (T.EOp(proof, n, Env.lookup_inst env a,
      List.map (Type.tr_type_arg env) targs,
      args))))

  | S.ERepl(cont, tp, eff, prompt) ->
    let tp  = Type.tr_type env tp in
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

  | S.VVarFn(x, tp, body) ->
    let tp = Type.tr_type env tp in
    let (env, x) = Env.add_var env x in
    make (T.EValue (make (T.VFn(x, tp, tr_expr env body))))

  | S.VFn(pat, body, rtp) ->
    let tp = Type.tr_type env (S.Pattern.typ pat) in
    let x  = T.Var.fresh () in
    make (T.EValue (make (T.VFn(x, tp,
      PatternMatch.tr_match 
        ~env
        ~uid:v.meta
        ~typ:(Type.tr_type env rtp)
        ~bind_value:bind_value
        x
        [ (pat, (fun env -> tr_expr env body)) ]))))

  | S.VTypeFun(xs, body) ->
    tr_type_fun v.meta env xs (fun env -> tr_value env body)

  | S.VTypeFunE(xs, body) ->
    tr_type_fun v.meta env xs (fun env -> tr_expr env body)

  | S.VTypeApp(v1, tps) ->
    bind_value env v1 (fun v1 ->
    tr_type_app v.meta env v1 tps)

  | S.VInstFun(a, s, body) ->
    let s = Type.tr_type env s in
    let (env, a) = Env.add_effinst env a in
    make (T.EValue (make (T.VInstFun(a, s, tr_expr env body))))

  | S.VCtor(proof, n, targs, args) ->
    bind_value env proof (fun proof ->
    bind_values env args (fun args ->
    make (T.EValue (make (T.VCtor(proof, n,
      List.map (Type.tr_type_arg env) targs,
      args))))))

  | S.VSelect(proof, n, v) ->
    bind_value env proof (fun proof ->
    bind_value env v (fun v ->
    make (T.ESelect(proof, n, v))))

  | S.VRecord(proof, vs) ->
    bind_value env proof (fun proof ->
    bind_values env vs (fun vs ->
    make (T.EValue (make (T.VRecord(proof, vs))))))

  | S.VTuple vs ->
    bind_values env vs (fun vs ->
    make (T.EValue (make (T.VTuple vs))))

  | S.VProj(v, n) ->
    bind_value env v (fun v ->
    make (T.EProj(v, n)))

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

and bind_value_as meta env v x cont =
  let make data = { meta = meta; data = data } in
  match v.data with
  | T.VVar y -> cont (Env.add_var' env x y)
  | _ ->
    let (env, y) = Env.add_var env x in
    make (T.ELetPure(y, make (T.EValue v), cont env))

and tr_type_fun meta env xs body =
  let make data = { meta = meta; data = data } in
  match xs with
  | [] -> body env
  | S.TVar.Pack x :: xs ->
    let (env, x) = Env.add_tvar env x in
    make (T.EValue (make (T.VTypeFun(x, tr_type_fun meta env xs body))))

and tr_type_app meta env v tps =
  let make data = { meta = meta; data = data } in
  match tps with
  | [] -> make (T.EValue v)
  | S.TpArg tp :: tps ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.ETypeApp(v, Type.tr_type env tp)),
      tr_type_app meta env (make (T.VVar x)) tps))

and prepare_rec_function env rf =
  match rf with
  | S.RFFun(f, tp, _, _, _, _) | S.RFInstFun(f, tp, _, _, _, _) ->
    let tp = Type.tr_type env tp in
    let (env, f) = Env.add_var env f in
    (env, (f, tp, rf))

and tr_rec_function env (f, tp, rf) =
  match rf with
  | S.RFFun(_, _, targs, arg, arg_tp, body) ->
    let (env, targs) = Env.add_tvars env targs in
    let arg_tp       = Type.tr_type env arg_tp in
    let (env, arg)   = Env.add_var env arg in
    T.RFFun(f, tp, targs, arg, arg_tp, tr_expr env body)
  | S.RFInstFun(_, _, targs, a, s, body) ->
    let (env, targs) = Env.add_tvars env targs in
    let s            = Type.tr_type env s in
    let (env, a)     = Env.add_effinst env a in
    T.RFInstFun(f, tp, targs, a, s, tr_expr env body)

and tr_rec_functions env rfs =
  let (env, rfs) = Utils.ListExt.fold_map prepare_rec_function env rfs in
  (env, List.map (tr_rec_function env) rfs)

and collect_op_handler env n op tvs h rx tp =
  match h.data with
  | S.HOp(m, xs, pats, rpat, body) when n = m ->
    let env = Env.add_tvars' env xs tvs in
    Some (env, pats, (fun env ->
      PatternMatch.tr_match
        ~env
        ~uid: h.meta
        ~typ: tp
        ~bind_value
        rx [ (rpat, fun env -> tr_expr env body) ]))
  | _ -> None

and collect_op_handlers env n op tvs hs rx tp =
  Utils.ListExt.filter_map (fun h ->
      collect_op_handler env n op tvs h rx tp
    ) hs

and tr_op_handler meta env n op hs tp =
  let (T.OpDecl(name, tvs, tps, rtp)) = op in
  let xs = List.map (fun _ -> T.Var.fresh ()) tps in
  let rx = T.Var.fresh () in
  let pats = collect_op_handlers env n op tvs hs rx tp in
  let body =
    PatternMatch.tr_matches
      ~uid: meta
      ~typ: tp
      ~bind_value
      ~case_name: name
      xs pats in
  T.OpHandler(tvs, xs, rx, body)
