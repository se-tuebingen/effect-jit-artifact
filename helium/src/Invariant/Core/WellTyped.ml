(* Invariant/Core/WellTyped.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Lang.Node
open Lang.Core
open Lang.CoreCommon.WellTyped

let log_b = Log.log_b "Invariant.Core.WellTyped"

let rec check_expr env e =
  match e.data with
  | EValue v -> (check_value env v, Type.eff_pure)
  | ELet(x, e1, e2) ->
    let (tp1, eff1) = check_expr env e1 in
    let (tp2, eff2) = check_expr (Env.add_var env x tp1) e2 in
    (tp2, Type.eff_cons eff1 eff2)
  | ELetPure(x, e1, e2) ->
    let tp1 = check_expr_eff env e1 Type.eff_pure in
    check_expr (Env.add_var env x tp1) e2
  | EFix(rfs, e2) ->
    let env = check_rec_functions env rfs in
    check_expr env e2
  | EUnpack(x, z, v, e) ->
    begin match Type.view (check_value env v) with
    | TExists(y, tp1) ->
      begin match Kind.equal (TVar.kind x) (TVar.kind y) with
      | Equal ->
        let scope = Env.scope env in
        let (env, x') = Env.add_tvar env x in
        let tp1 = Type.subst_type y (Type.var x') tp1 in
        let env = Env.add_var env z tp1 in
        let (tp, eff) = check_expr env e in
        begin try
          if Type.check_scope scope eff then
            (Type.supertype_in_scope scope tp, eff)
          else
            raise Type_error
        with
        | Type.Escapes_scope -> raise Type_error
        end
      | NotEqual -> raise Type_error
      end
    | _ -> raise Type_error
    end
  | ETypeDef(tds, e) ->
    let scope = Env.scope env in
    let env = check_typedefs env tds in
    let (tp, eff) = check_expr env e in
    begin try
      if Type.check_scope scope eff then
        (Type.supertype_in_scope scope tp, eff)
      else
        raise Type_error
    with
    | Type.Escapes_scope -> raise Type_error
    end
  | ETypeApp(v, tp) ->
    begin match Type.view (check_value env v) with
    | TForall(x, tbody) ->
      begin match Kind.equal (TVar.kind x) (Type.kind tp) with
      | Equal ->
        (Type.subst_type x (tr_type env tp) tbody, Type.eff_pure)
      | NotEqual -> raise Type_error
      end
    | _ -> raise Type_error
    end
  | EInstApp(v, a) ->
    begin match Type.view (check_value env v) with
    | TForallInst(b, sb, tp) ->
      let (a, sa) = Env.lookup_inst env a in
      if not (Type.equal sa sb) then
        raise Type_error;
      (Type.subst_inst b a tp, Type.eff_pure)
    | _ -> raise Type_error
    end
  | EApp(v1, v2) ->
    begin match Type.view (check_value env v1) with
    | TArrow(tp1, tp2, eff) ->
      check_value_type env v2 tp1;
      (tp2, eff)
    | _ -> raise Type_error
    end
  | EProj(v, idx) ->
    begin match Type.view (check_value env v) with
    | TTuple tps ->
      if idx < List.length tps then
        (List.nth tps idx, Type.eff_pure)
      else
        raise Type_error
    | _ -> raise Type_error
    end
  | ESelect(proof, n, v) ->
    begin match Type.view (check_value env proof) with
    | TRecordDef(tp, flds) when (n < List.length flds) ->
      check_value_type env v tp;
      let (FieldDecl(_, tp)) = List.nth flds n in
      (tp, Type.eff_pure)
    | _ -> raise Type_error
    end
  | EMatch(proof, v, cls, rtp) ->
    begin match Type.view (check_value env proof) with
    | TDataDef(tp, ctors) when (List.length ctors = List.length cls) ->
      check_value_type env v tp;
      let rtp = tr_type env rtp in
      let eff = List.fold_left2 (fun eff cl ctor ->
          Type.eff_cons (check_match_clause env cl ctor rtp) eff
        ) Type.eff_pure cls ctors in
      (rtp, eff)
    | _ -> raise Type_error
    end
  | EHandle hdata ->
    begin match Type.view (check_value env hdata.proof) with
    | TEffsigDef(s, ops) when
        (List.length ops = List.length hdata.op_handlers) ->
      let (env_in, a) = Env.add_effinst env hdata.effinst s in
      let tp  = tr_type env hdata.htype in
      let eff = tr_type env hdata.heffect in
      let tp_in = check_expr_eff env_in hdata.body
        (Type.eff_cons (Type.eff_inst a) eff) in
      check_expr_type_eff (Env.add_var env hdata.return_var tp_in)
        hdata.return_body tp eff;
      List.iter2 (fun h op -> check_op_handler env h op tp eff)
        hdata.op_handlers ops;
      (tp, eff)
    | _ -> raise Type_error
    end
  | EOp(proof, n, a, targs, args) ->
    begin match Type.view (check_value env proof) with
    | TEffsigDef(s1, ops) when (n < List.length ops) ->
      let (a, s2) = Env.lookup_inst env a in
      if not (Type.equal s1 s2) then
        raise Type_error;
      let (OpDecl(_, xs, tps, res_tp)) = List.nth ops n in
      let sub = check_type_args env xs targs in
      let tps = List.map (Type.subst sub) tps in
      let res_tp = Type.subst sub res_tp in
      if List.length tps <> List.length args then
        raise Type_error;
      List.iter2 (check_value_type env) args tps;
      (res_tp, Type.eff_inst a)
    | _ -> raise Type_error
    end
  | ERepl(_, tp, eff, _) ->
    (tr_type env tp, tr_type env eff)
  | EReplExpr(e1, _, e2) ->
    let (tp, eff) = check_expr env e2 in
    let _ : ttype = check_expr_eff env e1 eff in
    (tp, eff)
  | EReplImport _ ->
    failwith "Not implemented"

and check_expr_type env e tp =
  let (tp', eff) = check_expr env e in
  if Type.subtype tp' tp then eff
  else raise Type_error

and check_expr_eff env e eff =
  let (tp, eff') = check_expr env e in
  if Type.subeffect eff' eff then tp
  else raise Type_error

and check_expr_type_eff env e tp eff =
  let (tp', eff') = check_expr env e in
  if not (Type.subtype tp' tp) then begin
    log_b (lazy (Box.textl "type mismatch"));
    log_b (lazy
      [ Box.ws (Box.word "got:")
      ; Box.ws (SExprPrinter.tr_type tp' |> SExpr.pretty) ]);
    log_b (lazy
      [ Box.ws (Box.word "expected:")
      ; Box.ws (SExprPrinter.tr_type tp |> SExpr.pretty) ]);
    raise Type_error
  end
  else if Type.subeffect eff' eff then ()
  else raise Type_error

and check_rec_functions env rfs =
  let prepare_rec_function env rf =
    match rf with
    | RFFun(f, tp, _, _, _, _) | RFInstFun(f, tp, _, _, _, _) ->
      let tp = tr_type env tp in
      (Env.add_var env f tp, (rf, tp))
  in
  let (env, rfs) = Utils.ListExt.fold_map prepare_rec_function env rfs in
  let check_rec_function (rf, tp) =
    let rftp =
      match rf with
      | RFFun(_, _, tvars, arg, arg_tp, body) ->
        let (env, tvars) = Env.add_tvars env tvars in
        let arg_tp = tr_type env arg_tp in
        let env = Env.add_var env arg arg_tp in
        let (body_tp, body_eff) = check_expr env body in
        Type.forall_l tvars (Type.arrow arg_tp body_tp body_eff)
      | RFInstFun(_, _, tvars, a, s, body) ->
        let (env, tvars) = Env.add_tvars env tvars in
        let s = tr_type env s in
        let (env, a) = Env.add_effinst env a s in
        let body_tp = check_expr_eff env body Type.eff_pure in
        Type.forall_l tvars (Type.forall_inst a s body_tp)
    in
    if Type.subtype rftp tp then ()
    else begin
      raise Type_error
    end
  in
  List.iter check_rec_function rfs;
  env

and check_match_clause env (Clause(ys, zs, body)) (CtorDecl(_, xs, tps)) rtp =
  let scope = Env.scope env in
  let (env, sub) = Env.add_tvars2 env ys xs in
  let env = Env.add_vars env zs (List.map (Type.subst sub) tps) in
  let eff = check_expr_type env body rtp in
  if Type.check_scope scope eff then eff
  else raise Type_error

and check_op_handler env h op tp eff =
  let (OpHandler(ys, zs, rx, body)) = h in
  let (OpDecl(_, xs, tps, rtp)) = op in
  let (env, sub) = Env.add_tvars2 env ys xs in
  let env = Env.add_vars env zs (List.map (Type.subst sub) tps) in
  let env = Env.add_var env rx (Type.arrow (Type.subst sub rtp) tp eff) in
  check_expr_type_eff env body tp eff 

and check_value env v =
  match v.data with
  | VLit lit -> Type.base (Lang.RichBaseType.type_of_lit lit)
  | VVar x ->
    Env.check_var env x
  | VFn(x, tp, body) ->
    let tp1 = tr_type env tp in
    let (tp2, eff) = check_expr (Env.add_var env x tp1) body in
    Type.arrow tp1 tp2 eff
  | VTypeFun(x, body) ->
    let (env, x) = Env.add_tvar env x in
    Type.forall x (check_expr_eff env body Type.eff_pure)
  | VInstFun(a, s, body) ->
    let s = tr_type env s in
    let (env, a) = Env.add_effinst env a s in
    Type.forall_inst a s (check_expr_eff env body Type.eff_pure)
  | VPack(ptp, v, x, tp) ->
    let ptp = tr_type env ptp in
    let (env', x) = Env.add_tvar env x in
    let tp = tr_type env' tp in
    check_value_type env v (Type.subst_type x ptp tp);
    Type.exists x tp
  | VTuple vs ->
    Type.tuple (List.map (check_value env) vs)
  | VCtor(proof, n, targs, args) ->
    begin match Type.view (check_value env proof) with
    | TDataDef(tp, ctors) when (n < List.length ctors) ->
      let (CtorDecl(_, xs, tps)) = List.nth ctors n in
      let sub = check_type_args env xs targs in
      let tps = List.map (Type.subst sub) tps in
      if List.length tps <> List.length args then
        raise Type_error;
      List.iter2 (check_value_type env) args tps;
      tp
    | _ -> raise Type_error
    end
  | VRecord(proof, vs) ->
    begin match Type.view (check_value env proof) with
    | TRecordDef(tp, flds) when (List.length vs = List.length flds) ->
      List.iter2 (fun v (FieldDecl(_, tp)) -> check_value_type env v tp)
        vs flds;
      tp
    | _ -> raise Type_error
    end
  | VExtern(name, tp) -> tr_type env tp

and check_value_type env v tp =
  let tp' = check_value env v in
  if Type.subtype tp' tp then ()
  else raise Type_error

(* ========================================================================= *)

let check_program p =
  try check_source_file Env.empty check_expr_type_eff p; true with
  | Type_error -> false

let flow_transform p meta =
  Flow.return (check_program p)

let flow_tag =
  Flow.register_invariant_checker
    ~node:   Lang.Core.flow_node
    ~checks: CommonTags.well_typed
    ~name:   "Core well-typed"
    flow_transform
