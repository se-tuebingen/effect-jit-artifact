(* Invariant/Explicit/WellTyped.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)

open Lang.Node
open Lang.Explicit
open Lang.CoreCommon.WellTyped

let log_b = Log.log_b "Invariant.Explicit.WellTyped"

(* ========================================================================= *)

let type_mismatch msg got exp =
  log_b (lazy (Box.textl msg));
  log_b (lazy
    [ Box.ws (Box.word "got:")
    ; Box.ws (SExprPrinter.tr_type got |> SExpr.pretty) ]);
  log_b (lazy
    [ Box.ws (Box.word "expected:")
    ; Box.ws (SExprPrinter.tr_type exp |> SExpr.pretty) ]);
  raise Type_error

(* ========================================================================= *)

let check_type_insts env insts =
  let check_type_inst (tp_env, sub) (TpInst(x, tp)) =
    let (tp_env, x) = Env.add_tvar tp_env x in
    let tp = tr_type env tp in
    ((tp_env, Subst.add_type sub x tp), TVar.Pack x)
  in
  let ((tp_env, sub), xs) =
    List.fold_left_map check_type_inst (env, Subst.empty) insts in
  (tp_env, xs, sub)

let unpack_type env xs tp =
  let unpack (env, tp) (TVar.Pack x) =
    begin match Type.view tp with
    | TExists(y, tbody) ->
      begin match Kind.equal (TVar.kind x) (TVar.kind y) with
      | Equal ->
        let (env, z) = Env.add_tvar env x in
        (env, Type.subst_type y (Type.var z) tbody)
      | NotEqual -> raise Type_error
      end
    | _ -> raise Type_error
    end
  in
  List.fold_left unpack (env, tp) xs

let instantiate_type env tp tps =
  let instantiate tp (TpArg arg) =
    match Type.view tp with
    | TForall(x, tbody) ->
      begin match Kind.equal (TVar.kind x) (Type.kind arg) with
      | Equal ->
        Type.subst_type x (tr_type env arg) tbody
      | NotEqual -> raise Type_error
      end
    | _ -> raise Type_error
  in
  List.fold_left instantiate tp tps

(* ========================================================================= *)

let rec check_coercion env crc =
  match crc with
  | CId(tp_in, tp_out) ->
    let tp_in  = tr_type env tp_in  in
    let tp_out = tr_type env tp_out in
    if Type.subtype tp_in tp_out then (tp_in, tp_out)
    else raise Type_error
  | CComp(c1, c2) ->
    let (tp_in, tp1)  = check_coercion env c1 in
    let (tp2, tp_out) = check_coercion env c2 in
    if Type.subtype tp1 tp2 then (tp_in, tp_out)
    else raise Type_error
  | CArrow carr ->
    (* Contravariant in argument *)
    let (arg_out, arg_in) = check_coercion env carr.arg_crc in
    let (res_in, res_out) = check_coercion env carr.res_crc in
    let eff_in  = tr_type env carr.eff_in  in
    let eff_out = tr_type env carr.eff_out in
    (Type.arrow arg_in res_in eff_in, Type.arrow arg_out res_out eff_out)
  | CTypeGen(xs, crc) ->
    let scope = Env.scope env in
    let (env, xs) = Env.add_tvars env xs in
    let (tp_in, tp_out) = check_coercion env crc in
    (* I'm not sure if we should use check_scope or subtype_in_scope.
     * I decided to use check_scope function, which puts more restrictions
     * on coercions, but I'm sure, that I can compute coercion input type
     * that is well formed. Other option would be to store input type
     * in the constructor *)
    if Type.check_scope scope tp_in then (tp_in, Type.forall_l xs tp_out)
    else raise Type_error
  | CTypeApp(insts, tp, crc) ->
    let (tp_env, xs, sub) = check_type_insts env insts in
    let tp = tr_type tp_env tp in
    let tp_out = check_coercion_input_type env crc (Type.subst sub tp) in
    (Type.forall_l xs tp, tp_out)
  | CInstGen(a, s, crc) ->
    let scope = Env.scope env in
    let s = tr_type env s in
    let (env, a) = Env.add_effinst env a s in
    let (tp_in, tp_out) = check_coercion env crc in
    if Type.check_scope scope tp_in then (tp_in, Type.forall_inst a s tp_out)
    else raise Type_error
  | CInstApp(tp_in, a, crc) ->
    let tp_in = tr_type env tp_in in
    begin match Type.view tp_in with
    | TForallInst(b, s, tp) ->
      let (a, s') = Env.lookup_inst env a in
      if not (Type.equal s s') then raise Type_error;
      let tp_out =
        check_coercion_input_type env crc (Type.subst_inst b a tp) in
      (tp_in, tp_out)
    | _ -> raise Type_error
    end
  | CPack(crc, insts, tp) ->
    let (tp_in, tp_out) = check_coercion env crc in
    let (tp_env, xs, sub) = check_type_insts env insts in
    let tp = tr_type tp_env tp in
    if Type.subtype tp_out (Type.subst sub tp) then
      (tp_in, Type.exists_l xs tp)
    else raise Type_error
  | CUnpack(xs, crc) ->
    let scope = Env.scope env in
    let (env, xs) = Env.add_tvars env xs in
    let (tp_in, tp_out) = check_coercion env crc in
    (* I'm not sure if we should use check_scope or supertype_in_scope.
     * I decided to use check_scope function, which puts more restrictions
     * on coercions, but I'm sure, that I can compute coercion output type
     * that is well formed. Other option would be to store output type
     * in the constructor *)
    if Type.check_scope scope tp_out then (Type.exists_l xs tp_in, tp_out)
    else raise Type_error
  | CTuple(tp_in, crcs) ->
    let tp_in = tr_type env tp_in in
    let tps =
      List.map (fun crc -> check_coercion_input_type env crc tp_in) crcs in
    (tp_in, Type.tuple tps)
  | CProj(tps, n, crc) ->
    let tps = List.map (tr_type env) tps in
    if n >= List.length tps then raise Type_error;
    let tp_out = check_coercion_input_type env crc (List.nth tps n) in
    (Type.tuple tps, tp_out)
  | CCtorProxy(tp, ctors, n) ->
    let tp    = tr_type env tp in
    let ctors = List.map (tr_ctor_decl env) ctors in
    if n >= List.length ctors then raise Type_error;
    (Type.data_def tp ctors, Coercion.ctor_proxy_type tp ctors n)
  | COpProxy(s, ops, n) ->
    let s   = tr_type env s in
    let ops = List.map (tr_op_decl env) ops in
    if n >= List.length ops then raise Type_error;
    (Type.effsig_def s ops, Coercion.op_proxy_type s ops n)

and check_coercion_input_type env crc tp_in =
  let (tp_in', tp_out) = check_coercion env crc in
  if Type.subtype tp_in tp_in' then tp_out
  else type_mismatch "coercion input type mismatch" tp_in' tp_in

(* ========================================================================= *)

(* TODO: This function does not check if there is no uses of type variables
 * defined in different branch, e.g.
 * PCtor { args = [ PCtor { targs = [ x ] }; PVar(_, tp) ] } where tp uses x
 * I'm not sure if such cases should be uniformly treated as errors. Maybe
 * they are errors, but catched elsewhere *)
let rec check_pattern env pat =
  match pat.data with
  | PVar(x, tp) ->
    let tp = tr_type env tp in
    (Env.add_var env x tp, tp)
  | PCoerce(crc, pat) ->
    let (tp_in, tp_out) = check_coercion env crc in
    let env = check_pattern_type env pat tp_out in
    (env, tp_in)
  | PCtor p ->
    let typ   = tr_type env p.typ in
    let ctors = List.map (tr_ctor_decl env) p.ctors in
    check_value_type env p.proof (Type.data_def typ ctors);
    if p.index >= List.length ctors then raise Type_error;
    let (CtorDecl(_, xs, tps)) = List.nth ctors p.index in
    let (env, sub) = Env.add_tvars2 env p.targs xs in
    let env = 
      check_pattern_types env p.args (List.map (Type.subst sub) tps) in
    (env, typ)

and check_pattern_type env pat tp =
  let (env, tp') = check_pattern env pat in
  if Type.subtype tp tp' then env
  else raise Type_error

and check_pattern_types env pats tps =
  match pats, tps with
  | [], [] -> env
  | pat :: pats, tp :: tps ->
    let env = check_pattern_type env pat tp in
    check_pattern_types env pats tps
  | [], _ :: _ | _ :: _, [] -> raise Type_error

(* ========================================================================= *)

and check_expr env e =
  match e.data with
  | EValue v ->
    (check_value env v, Type.eff_pure)
  | ECoerce(crc, e) ->
    let (tp_in, tp_out) = check_coercion env crc in
    let eff = check_expr_type env e tp_in in
    (tp_out, eff)
  | EPack(insts, tp, e) ->
    let (tp_env, xs, sub) = check_type_insts env insts in
    let tp  = tr_type tp_env tp in
    let eff = check_expr_type env e (Type.subst sub tp) in
    (Type.exists_l xs tp, eff)
  | ELet(xs, x, e1, e2) ->
    let scope = Env.scope env in
    let (tp1, eff1) = check_expr env e1 in
    let (env, tp1)  = unpack_type env xs tp1 in
    let env = Env.add_var env x tp1 in
    let (tp2, eff2) = check_expr env e2 in
    begin try
      if Type.check_scope scope eff2 then
        (Type.supertype_in_scope scope tp2, Type.eff_cons eff1 eff2)
      else
        raise Type_error
    with
    | Type.Escapes_scope -> raise Type_error
    end
  | EFix(rfs, e2) ->
    let env = check_rec_functions env rfs in
    check_expr env e2
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
  | EApp(ef, ea) ->
    let (tp_f, eff1) = check_expr env ef in
    begin match Type.view tp_f with
    | TArrow(tp_a, tp_r, eff) ->
      let eff2 = check_expr_type env ea tp_a in
      (tp_r, Type.eff_cons eff (Type.eff_cons eff1 eff2))
    | _ -> raise Type_error
    end
  | EInstApp(e, a) ->
    let (tp, eff) = check_expr env e in
    begin match Type.view tp with
    | TForallInst(b, sb, tp) ->
      let (a, sa) = Env.lookup_inst env a in
      if not (Type.equal sa sb) then
        raise Type_error;
      (Type.subst_inst b a tp, eff)
    | _ -> raise Type_error
    end
  | EMatch(_, [], _) ->
    log_b (lazy (Box.textl
      "EMatch in Explicit cannot be empty. Use EEmptyMatch istead."));
    raise Type_error
  | EMatch(e, cls, rtp) ->
    let (tp, eff) = check_expr env e in
    let rtp = tr_type env rtp in
    (rtp, Type.eff_cons eff (check_clauses env tp cls rtp))
  | EEmptyMatch(e, prf, tp) ->
    let (etp, eff) = check_expr env e in
    check_value_type env prf (Type.data_def etp []);
    (tr_type env tp, eff)
  | EHandle hdata ->
    let ops' = List.map (tr_op_decl env) hdata.ops in
    begin match Type.view (check_value env hdata.proof) with
    | TEffsigDef(s, ops) when
        Type.equal (Type.effsig_def s ops) (Type.effsig_def s ops') ->
      let (env_in, a) = Env.add_effinst env hdata.effinst s in
      let tp  = tr_type env hdata.htype in
      let eff = tr_type env hdata.heffect in
      let tp_in = check_expr_eff env_in hdata.body
        (Type.eff_cons (Type.eff_inst a) eff) in
      check_expr_type_eff (Env.add_var env hdata.return_var tp_in)
        hdata.return_body tp eff;
      List.iter (fun h -> check_op_handler env h ops tp eff) hdata.op_handlers;
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
    log_b (lazy (Box.textl
      "Internal type-checkers do not work well in REPL mode"));
    (tr_type env tp, tr_type env eff)
  | EReplExpr(e1, _, e2) ->
    log_b (lazy (Box.textl
      "Internal type-checkers do not work well in REPL mode"));
    let (tp, eff) = check_expr env e2 in
    let _ : ttype = check_expr_eff env e1 eff in
    (tp, eff)
  | EReplImport _ ->
    log_b (lazy (Box.textl
      "Internal type-checkers do not work well in REPL mode"));
    failwith "Not implemented"

and check_expr_type env e tp =
  let (tp', eff) = check_expr env e in
  if Type.subtype tp' tp then eff
  else type_mismatch "expresion type mismatch" tp' tp

and check_expr_eff env e eff =
  let (tp, eff') = check_expr env e in
  if Type.subeffect eff' eff then tp
  else raise Type_error

and check_expr_type_eff env e tp eff =
  let (tp', eff') = check_expr env e in
  if not (Type.subtype tp' tp) then
    type_mismatch "expression type mismatch" tp' tp
  else if Type.subeffect eff' eff then ()
  else raise Type_error

and check_value env v =
  match v.data with
  | VLit lit -> Type.base (Lang.RichBaseType.type_of_lit lit)
  | VVar x   -> Env.check_var env x
  | VCoerce(crc, v) ->
    let (tp_in, tp_out) = check_coercion env crc in
    check_value_type env v tp_in;
    tp_out
  | VVarFn(x, tp, e) ->
    let tp1 = tr_type env tp in
    let env = Env.add_var env x tp1 in
    let (tp2, eff) = check_expr env e in
    Type.arrow tp1 tp2 eff
  | VFn(pat, e, rtp) ->
    let scope = Env.scope env in
    let rtp = tr_type env rtp in
    let (env, atp) = check_pattern env pat in
    let eff = check_expr_type env e rtp in
    if Type.check_scope scope eff then Type.arrow atp rtp eff
    else raise Type_error
  | VTypeFun(xs, v) ->
    let (env, xs) = Env.add_tvars env xs in
    let tp = check_value env v in
    Type.forall_l xs tp
  | VTypeFunE(xs, e) ->
    let (env, xs) = Env.add_tvars env xs in
    let tp = check_expr_eff env e Type.eff_pure in
    Type.forall_l xs tp
  | VTypeApp(v, tps) ->
    let tp = check_value env v in
    instantiate_type env tp tps
  | VInstFun(a, s, body) ->
    let s = tr_type env s in
    let (env, a) = Env.add_effinst env a s in
    Type.forall_inst a s (check_expr_eff env body Type.eff_pure)
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
  | VSelect(proof, n, v) ->
    begin match Type.view (check_value env proof) with
    | TRecordDef(tp, flds) when (n < List.length flds) ->
      check_value_type env v tp;
      let (FieldDecl(_, tp)) = List.nth flds n in
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
  | VTuple vs ->
    Type.tuple (List.map (check_value env) vs)
  | VProj(v, n) ->
    begin match Type.view (check_value env v) with
    | TTuple tps when n < List.length tps ->
      List.nth tps n
    | _ -> raise Type_error
    end
  | VExtern(_, tp) ->
    tr_type env tp

and check_value_type env v tp =
  let tp' = check_value env v in
  if Type.subtype tp' tp then ()
  else raise Type_error

(* ========================================================================= *)

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

and check_clause env ptp { data = Clause(pat, body); _ } rtp =
  let scope = Env.scope env in
  let env   = check_pattern_type env pat ptp in
  let eff   = check_expr_type env body rtp in
  if Type.check_scope scope eff then eff
  else raise Type_error

and check_clauses env ptp cls rtp =
  List.fold_left
    (fun eff cl -> Type.eff_cons (check_clause env ptp cl rtp) eff)
    Type.eff_pure
    cls

and check_op_handler env { data = HOp(n, xs, ps, p, body); _ } ops tp eff =
  if n >= List.length ops then raise Type_error;
  let (OpDecl(_, ys, tps, rtp)) = List.nth ops n in
  let (env, sub) = Env.add_tvars2 env xs ys in
  let env = check_pattern_types env ps (List.map (Type.subst sub) tps) in
  let env =
    check_pattern_type env p (Type.arrow (Type.subst sub rtp) tp eff) in
  check_expr_type_eff env body tp eff

(* ========================================================================= *)

let check_program p =
  try check_source_file Env.empty check_expr_type_eff p; true with
  | Type_error -> false

let flow_transform p meta =
  Flow.return (check_program p)

let flow_tag =
  Flow.register_invariant_checker
    ~node:   Lang.Explicit.flow_node
    ~checks: CommonTags.well_typed
    ~name:   "Explicit well-typed"
    flow_transform
