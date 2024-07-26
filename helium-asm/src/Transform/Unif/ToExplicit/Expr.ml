(* Transform/Unif/ToExplicit/Expr.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)

open Lang.Node
open Common

let value v =
  { meta = v.meta; data = T.EValue v }

let rec tr_pattern env pat =
  let make data = { meta = pat.meta; data = data } in
  match pat.data with
  | S.PVar x ->
    let tp       = Type.tr_type env (S.Var.typ x) in
    let (env, x) = Env.add_var env x in
    (env, make (T.PVar(x, tp)))

  | S.PCoerce(crc, pat) ->
    let crc = Coercion.tr_coercion env crc in
    let (env, pat) = tr_pattern env pat in
    (env, make (T.PCoerce(crc, pat)))

  | S.PCtor p ->
    let typ   = Type.tr_type env p.typ in
    let ctors = List.map (Type.tr_ctor_decl env) p.ctors in
    let proof = tr_value env p.proof in
    let (env, targs) = Env.add_tvars env p.targs in
    let (env, args)  = tr_patterns env p.args in
    (env, make (T.PCtor
      { typ   = typ
      ; ctors = ctors
      ; proof = proof
      ; index = p.index
      ; targs = targs
      ; args  = args
      }))

and tr_patterns env pats =
  List.fold_left_map tr_pattern env pats

and tr_expr env e =
  let make data = { meta = e.meta; data = data } in
  match e.data with
  | S.EValue v -> make (T.EValue (tr_value env v))

  | S.ECoerce(crc, e) ->
    make (T.ECoerce(Coercion.tr_ex_coercion env crc, tr_expr env e))

  | S.EPack(insts, extp, e1) ->
    let e1           = tr_expr env e1 in
    let (env, insts) = Type.tr_type_instances env insts in
    let tp           = Type.tr_ex_type env extp in
    make (T.EPack(insts, tp, e1))

  | S.ELet(tvs, x, e1, e2) ->
    let e1         = tr_expr env e1 in
    let (env, tvs) = Env.add_tvars env tvs in
    let (env, x)   = Env.add_var env x in
    let e2         = tr_expr env e2 in
    make (T.ELet(tvs, x, e1, e2))

  | S.EFix(rfs, e2) ->
    let (env, rfs) = tr_rec_functions env rfs in
    make (T.EFix(rfs, tr_expr env e2))

  | S.ETypeDef(tds, e2) ->
    let (env, tds) = TypeDef.tr_typedefs env tds in
    make (T.ETypeDef(tds, tr_expr env e2))

  | S.EApp(v1, v2) ->
    let v1 = tr_value env v1 in
    let v2 = tr_value env v2 in
    make (T.EApp(value v1, value v2))

  | S.EInstApp(v, a) ->
    let v = tr_value env v in
    let a = Type.tr_effinst_expr env a in
    make (T.EInstApp(value v, a))

  | S.EMatch(v, cls, tp) ->
    make (T.EMatch(
      value (tr_value env v),
      List.map (tr_clause env) cls,
      Type.tr_ex_type env tp))

  | S.EEmptyMatch(v, proof, tp) ->
    make (T.EEmptyMatch(
      value (tr_value env v),
      tr_value env proof,
      Type.tr_ex_type env tp))

  | S.EHandle hdata ->
    let (body_env, effinst) = Env.add_effinst env hdata.effinst in
    let ret_type = Type.tr_ex_type env hdata.ret_type in
    let (ret_var, ret_body) =
      tr_ret_clause e.meta env hdata.ret_clauses ret_type in
    let hexp =
      make (T.EHandle
        { proof       = tr_value env hdata.proof
        ; ops         = List.map (Type.tr_op_decl env) hdata.ops
        ; effinst     = effinst
        ; body        = tr_expr body_env hdata.body
        ; op_handlers = List.map (tr_op_handler env) hdata.op_handlers
        ; return_var  = ret_var
        ; return_body = ret_body
        ; htype       = ret_type
        ; heffect     = Type.tr_type env hdata.ret_effect
        })
    in
    tr_fin_clause e.meta env hdata.fin_clauses hexp
      (Type.tr_ex_type env hdata.fin_type)

  | S.EHandleWith(a, s, body, hexp) ->
    let hexp = tr_value env hexp in
    let s    = Type.tr_type env s in
    let (env, a) = Env.add_effinst env a in
    let body = tr_expr env body in
    let dummy_var = T.Var.fresh () in
    make (T.EApp(make (T.EValue hexp),
      make (T.EValue (make (T.VInstFun(a, s,
        make (T.EValue (make (T.VVarFn(dummy_var, T.Type.tuple [],
          body))))))))))

  | S.EOp(proof, n, a, targs, args) ->
    let proof = tr_value env proof in
    let a     = Env.lookup_inst env a in
    let targs = List.map (Type.tr_type_arg env) targs in
    let args  = List.map (tr_value env) args in
    make (T.EOp(proof, n, a, targs, args))

  | S.ERepl(cont, tp, eff, prompt) ->
    let tp  = Type.tr_ex_type env tp in
    let eff = Type.tr_type env eff in
    let cont () =
      let res = cont () in
      { res with data = tr_expr env res.data }
    in
    make (T.ERepl(cont, tp, eff, prompt))

  | S.EReplExpr(e1, tp, e2) ->
    make (T.EReplExpr(tr_expr env e1, tp, tr_expr env e2))

  | S.EReplImport(imports, rest) ->
    let (env, imports) = Import.tr_imports env imports in
    make (T.EReplImport(imports, tr_expr env rest))

and tr_value env v =
  let make data = { meta = v.meta; data = data } in
  match v.data with
  | S.VLit l -> make (T.VLit l)

  | S.VVar x -> make (T.VVar (Env.lookup_var env x))

  | S.VCoerce(crc, v1) ->
    let crc = Coercion.tr_coercion env crc in
    let v1  = tr_value env v1 in
    make (T.VCoerce(crc, v1))

  | S.VVarFn(x, body) ->
    let tp       = Type.tr_type env (S.Var.typ x) in
    let (env, x) = Env.add_var env x in
    make (T.VVarFn(x, tp, tr_expr env body))

  | S.VFn(pat, body, rtp) ->
    let rtp        = Type.tr_ex_type env rtp in
    let (env, pat) = tr_pattern env pat in
    let body       = tr_expr env body in
    make (T.VFn(pat, body, rtp))

  | S.VTypeFun(xs, body) ->
    let (env, xs) = Env.add_tvars env xs in
    let body      = tr_value env body in
    make (T.VTypeFun(xs, body))

  | S.VTypeFunE(xs, body) ->
    let (env, xs) = Env.add_tvars env xs in
    let body = tr_expr env body in
    make (T.VTypeFunE(xs, body))

  | S.VTypeApp(v1, tps) ->
    let v1  = tr_value env v1 in
    let tps = List.map (Type.tr_type_arg env) tps in
    make (T.VTypeApp(v1, tps))

  | S.VInstFun(a, s, body) ->
    let s = Type.tr_type env s in
    let (env, a) = Env.add_effinst env a in
    make (T.VInstFun(a, s, tr_expr env body))

  | S.VHandler hdata ->
    let a       = T.EffInst.fresh () in
    let s       = Type.tr_type env hdata.effsig in
    let in_type = Type.tr_ex_type env hdata.in_type in
    let in_eff  = Type.tr_type env hdata.in_effect in
    let comp_x  = T.Var.fresh () in
    let comp_tp =
      T.Type.forall_inst a s
        (T.Type.arrow (T.Type.tuple []) in_type
          (T.Type.eff_cons (T.Type.eff_inst a) in_eff)) in
    let body_exp = make (T.EApp(
      make (T.EInstApp(make (T.EValue (make (T.VVar comp_x))), a)),
      make (T.EValue (make (T.VTuple []))))) in
    let ret_type = Type.tr_ex_type env hdata.ret_type in
    let (ret_var, ret_body) =
      tr_ret_clause v.meta env hdata.ret_clauses ret_type in
    let hexp =
      make (T.EHandle
        { proof       = tr_value env hdata.proof
        ; ops         = List.map (Type.tr_op_decl env) hdata.ops
        ; effinst     = a
        ; body        = body_exp
        ; op_handlers = List.map (tr_op_handler env) hdata.op_handlers
        ; return_var  = ret_var
        ; return_body = ret_body
        ; htype       = ret_type
        ; heffect     = Type.tr_type env hdata.ret_effect
        }) in
    make (T.VVarFn(comp_x, comp_tp,
      tr_fin_clause v.meta env hdata.fin_clauses hexp
        (Type.tr_ex_type env hdata.out_type)))

  | S.VCtor(proof, n, targs, args) ->
    let proof = tr_value env proof in
    let targs = List.map (Type.tr_type_arg env) targs in
    let args  = List.map (tr_value env) args in
    make (T.VCtor(proof, n, targs, args))

  | S.VSelect(proof, n, v) ->
    make (T.VSelect(tr_value env proof, n, tr_value env v))

  | S.VRecord(proof, vs) ->
    make (T.VRecord(tr_value env proof, List.map (tr_value env) vs))

  | S.VStruct defs -> make (T.VTuple(List.map (tr_struct_def env) defs))

  | S.VSelThis(decls, v1) ->
    let v1 = tr_value env v1 in
    let n = S.Decl.this_index decls in
    make (T.VProj(v1, n))

  | S.VSelTypedef(decls, v1) ->
    let v1 = tr_value env v1 in
    let n = S.Decl.typedef_index decls in
    make (T.VProj(v1, n))

  | S.VSelVal(decls, v1, name) ->
    let v1 = tr_value env v1 in
    let n = S.Decl.val_index decls name in
    make (T.VProj(v1, n))

  | S.VSelOp(decls, v1, name) ->
    let v1 = tr_value env v1 in
    let n  = S.Decl.op_index decls name in
    make (T.VProj(v1, n))

  | S.VSelCtor(decls, v1, name) ->
    let v1 = tr_value env v1 in
    let n  = S.Decl.ctor_index decls name in
    make (T.VProj(v1, n))

  | S.VSelField(decls, v1, name) ->
    let v1 = tr_value env v1 in
    let n  = S.Decl.field_index decls name in
    make (T.VProj(v1, n))

  | S.VTypeWit _ | S.VEffectWit _ | S.VEffsigWit _ ->
    (* This values has no computational content, and are translated to an
     * empty tuple *)
    make (T.VTuple [])

  | S.VExtern(name, tp) ->
    make (T.VExtern(name, Type.tr_type env tp))

(* ========================================================================= *)

and prepare_rec_function env rf =
  match rf with
  | S.RFFun(f, _, _, _) | S.RFInstFun(f, _, _, _, _)
  | S.RFHandler(f, _, _, _, _, _) ->
    let tp = Type.tr_type env (S.Var.typ f) in
    let (env, f) = Env.add_var env f in
    (env, (f, tp, rf))

and tr_rec_function env (f, tp, rf) =
  match rf with
  | S.RFFun(_, targs, arg, body) ->
    let (env, targs) = Env.add_tvars env targs in
    let arg_tp       = Type.tr_type env (S.Var.typ arg) in
    let (env, arg)   = Env.add_var env arg in
    T.RFFun(f, tp, targs, arg, arg_tp, tr_expr env body)

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
      make (T.EApp(tr_expr env body,
        make (T.EValue (make (T.VVar comp))))))

and tr_rec_functions env rfs =
  let (env, rfs) = Utils.ListExt.fold_map prepare_rec_function env rfs in
  (env, List.map (tr_rec_function env) rfs)

(* ========================================================================= *)

and tr_clause env cl =
  let make data = { meta = cl.meta; data = data } in
  match cl.data with
  | S.Clause(pat, body) ->
    let (env, pat) = tr_pattern env pat in
    make (T.Clause(pat, tr_expr env body))

and tr_op_handler env hop =
  let make data = { meta = hop.meta; data = data } in
  match hop.data with
  | S.HOp(n, xs, ps, p, body) ->
    let (env, xs) = Env.add_tvars env xs in
    let (env, ps) = tr_patterns env ps in
    let (env, p)  = tr_pattern env p in
    make (T.HOp(n, xs, ps, p, tr_expr env body))

and tr_ret_clause meta env (xs, cls) tp =
  let make data = { meta = meta; data = data } in
  let ret_var = T.Var.fresh () in
  let ret_body =
    match cls with
    | [] ->
      (* Empty clauses list means default clause *)
      value (make (T.VVar ret_var))
    | _ ->
      let (env, xs) = Env.add_tvars env xs in
      let x = T.Var.fresh () in
      make (T.ELet(xs, x,
        value (make (T.VVar ret_var)),
        make (T.EMatch(
          value (make (T.VVar x)),
          List.map (tr_clause env) cls, 
          tp))))
  in
  (ret_var, ret_body)

and tr_fin_clause meta env (xs, cls) hexp tp =
  let make data = { meta = meta; data = data } in
  match cls with
  | [] ->
    (* Empty clauses list means default clause *)
    hexp
  | _ ->
    let (env, fin_tvars) = Env.add_tvars env xs in
    let fin_var = T.Var.fresh () in
    make (T.ELet(fin_tvars, fin_var, hexp,
      make (T.EMatch(
        value (make (T.VVar fin_var)),
        List.map (tr_clause env) cls,
        tp))))

and tr_struct_def env def =
  match def.data with
  | S.SDThis v | S.SDTypedef v | S.SDVal(_, v) | S.SDOp(v, _) | S.SDCtor(v, _)
  | S.SDField(v, _) -> tr_value env v
