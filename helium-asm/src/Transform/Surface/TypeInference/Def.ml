open Lang.Node
open Common

let rec generalize_insts ~fix ~pos insts v tp =
  match insts with
  | [] -> (v, tp)
  | i :: insts ->
    let (v, tp) = generalize_insts ~fix ~pos insts v tp in
    let s = T.ImplicitEffInst.effsig i in
    let a = T.ImplicitEffInst.close i in
    (make ~fix pos (T.VInstFun(a, s, make ~fix pos (T.EValue v))),
      T.Type.forall_inst a s tp)

let rec ml_generalize_insts ~fix ~env ~pos v tp =
  match Env.generalizable_insts env with
  | [] ->
    begin match Env.leave_implicit_scope env with
    | () -> (v, tp)
    | exception (ImplicitScope.Error err) ->
      raise (Error.implicit_scope_error ~env ~pos err)
    end
  | insts ->
    let (v, tp) = generalize_insts ~fix ~pos insts v tp in
    ml_generalize_insts ~fix ~env ~pos v tp

let ml_generalize_types ~fix ~env ~pos v tp =
  let uvars = T.UVar.Set.to_list
    (T.UVar.Set.diff (T.Type.uvars tp) (Env.uvars env)) in
  let gvars = T.Type.close_down_positive tp uvars in
  (make ~fix pos (T.VTypeFun(gvars, v)), T.Type.forall gvars tp)

let ml_generalize ~fix ~env ~pos v tp =
  let (v, tp) = ml_generalize_insts ~fix ~env ~pos v tp in
  ml_generalize_types ~fix ~env ~pos v tp

(* ========================================================================= *)

let check_ml_let fix ~env ~pos name
    (check_body : Env.t -> infer checked_value) tp_req eff_req cont =
  let env' = Env.enter_implicit_scope env in
  let res = check_body env' in
  let (Infered tp) = res.cv_type in
  let (v, tp) = ml_generalize ~fix ~env:env' ~pos res.cv_value tp in
  let (env, x) = Env.add_var env (S.string_of_name name) tp in
  let x_val = make_val ~fix pos name x tp in
  let res_r = cont.cd_cont env [ x_val ] tp_req eff_req in
  { ce_expr =
    make ~fix pos (T.ELet([], x, make ~fix pos (T.EValue v), res_r.ce_expr))
  ; ce_type = res_r.ce_type
  ; ce_eff  = res_r.ce_eff
  }

let check_include_base fix ~env ~pos e eff_req cont =
  ExprBuilder.bind_expr fix env e Infer eff_req
    (fun env v (Infered tp) eff_resp ->
  let (crc, decls) = TypeView.coerce_to_struct ~env ~pos:e.meta tp in
  ExprBuilder.value_as_var ~fix ~env ~pos
    (make ~fix e.meta (T.VCoerce(crc, v)))
    (T.Type.tstruct decls)
    (fun env x ->
  Request.next_eff_request env eff_req eff_resp (fun eff_req ->
  cont env x eff_req)))

(* ========================================================================= *)

let check fix env def tp_req eff_req cont =
  let check_pattern env  = fix.check_pattern fix env in
  let check_value env    = fix.check_value fix env in
  let check_function env = fix.check_function fix env in
  let pos = def.meta in
  match def.data with
  | S.DLetPat(p, e) ->
    ExprBuilder.bind_expr fix env e Infer eff_req
      (fun env v1 (Infered tp) eff_resp ->
    let res_p = check_pattern env p (Check tp) in
    Request.next_eff_request res_p.cp_env eff_req eff_resp (fun eff_req ->
    ExprBuilder.build_let_pat ~fix ~env ~pos
      res_p.cp_exvars res_p.cp_pattern v1 tp_req (
    cont.cd_cont res_p.cp_env res_p.cp_vals tp_req eff_req)))

  | S.DLetVal(name, e) ->
    let check_body env = check_value env e Infer in
    check_ml_let fix ~env ~pos name check_body tp_req eff_req cont

  | S.DLetFn(name, args, body) ->
    let check_body env = check_function env args body Infer in
    check_ml_let fix ~env ~pos name check_body tp_req eff_req cont

  | S.DLetRec rfs ->
    Uniqueness.check_rec_fun_uniqueness rfs;
    let rfs = RecFunction.guess_mono_types fix ~env ~pos rfs in
    let rfs = RecFunction.check_rec_functions fix rfs
      (fun env args body tp ->
        begin match args with
        | [] -> check_value env body (Check tp)
        | _  -> check_function env args body (Check tp)
        end.cv_value) in
    RecFunction.define_rec_functions fix env rfs (fun env vals ->
    cont.cd_cont env vals tp_req eff_req)

  | S.DTypedef td ->
    let (env, t_td, td) = TypeDef.check_def fix env td in
    ExprBuilder.build_typedef ~fix ~env ~pos [ t_td ] (
    TypeDef.build_typedef ~fix env td (fun env vals ->
    cont.cd_cont env vals tp_req eff_req))

  | S.DTypedefRec tds ->
    let (env, t_tds, tds) = TypeDef.check_rec_defs fix env tds in
    ExprBuilder.build_typedef ~fix ~env ~pos t_tds (
    TypeDef.build_typedefs ~fix env tds (fun env vals ->
    cont.cd_cont env vals tp_req eff_req))

  | S.DHandle(ib, hs) ->
    let (env', a, Infered s) =
      Handler.check_eff_inst_binder fix env ib Infer in
    let (hs, proof, ops) = Handler.prepare_handlers fix ~pos ~env hs s in
    let inner_eff = Handler.guess_inner_effect env eff_req in
    let res_e = cont.cd_cont env' [] Infer
      (Check (T.Type.eff_cons (T.Type.eff_ivar a) inner_eff)) in
    let (Infered inner_tp) = res_e.ce_type in
    let h_res =
      Handler.check_handlers fix env inner_tp inner_eff hs tp_req eff_req in
    { ce_expr = make ~fix pos (T.EHandle
        { effinst     = a
        ; effsig      = s
        ; ops         = ops
        ; proof       = proof
        ; body        = res_e.ce_expr
        ; ret_effect  = inner_eff
        ; ret_type    = h_res.ret_type
        ; fin_type    = Request.join tp_req h_res.tp_resp
        ; op_handlers = h_res.op_handlers
        ; ret_clauses = h_res.ret_clauses
        ; fin_clauses = h_res.fin_clauses
        })
    ; ce_type = h_res.tp_resp
    ; ce_eff  = h_res.eff_resp
    }

  | S.DHandleWith(ib, he) ->
    ExprBuilder.bind_expr fix env he Infer eff_req
      (fun env hv (Infered h_tp) eff_resp ->
    let (crc, s, in_tp, in_eff, out_tp, out_eff) =
      TypeView.coerce_to_handler ~env ~pos:he.meta h_tp in
    let hv = make ~fix he.meta (T.VCoerce(crc, hv)) in
    Request.next_eff_request env eff_req eff_resp (fun eff_req ->
    let (env', a, Checked) =
      Handler.check_eff_inst_binder fix env ib (Check s) in
    let body_res = cont.cd_cont env' [] (Check in_tp)
      (Check (T.Type.eff_cons (T.Type.eff_ivar a) in_eff)) in
    let (tp_resp, crc) =
      Request.return_ex_type ~env ~pos ~syncat:HandlerContext tp_req out_tp in
    { ce_expr = ExprBuilder.coerce_expr_opt ~fix ~pos crc
        (make ~fix pos (T.EHandleWith(a, s, body_res.ce_expr, hv)))
    ; ce_type = tp_resp
    ; ce_eff  = Request.return_eff ~env ~pos eff_req out_eff
    }))

  | S.DOpen e ->
    check_include_base fix ~env ~pos e eff_req (fun env x eff_req ->
    ModuleOpen.full_include ~fix ~env ~pos x (fun env _ ->
    cont.cd_cont env [] tp_req eff_req))

  | S.DWeakOpen e ->
    check_include_base fix ~env ~pos e eff_req (fun env x eff_req ->
    ModuleOpen.weak_include ~fix ~env ~pos x (fun env _ ->
    cont.cd_cont env [] tp_req eff_req))

  | S.DInclude e ->
    check_include_base fix ~env ~pos e eff_req (fun env x eff_req ->
    ModuleOpen.full_include ~fix ~env ~pos x (fun env vals ->
    cont.cd_cont env vals tp_req eff_req))

  | S.DWeakInclude e ->
    check_include_base fix ~env ~pos e eff_req (fun env x eff_req ->
    ModuleOpen.weak_include ~fix ~env ~pos x (fun env vals ->
    cont.cd_cont env vals tp_req eff_req))

let rec check_defs : type td ed. fix ->
    Env.t -> S.def list -> (td, _) request -> (ed, T.effect) request ->
      check_def_cont -> (td, ed) checked_expr =
  fun fix env defs tp_req eff_req cont ->
  match defs with
  | [] -> cont.cd_cont env [] tp_req eff_req
  | def :: defs ->
    check      fix env def  tp_req eff_req
      { cd_cont = fun env vals1 tp_req eff_req ->
    check_defs fix env defs tp_req eff_req
      { cd_cont = fun env vals2 tp_req eff_req ->
    cont.cd_cont env (merge_vals_hide vals1 vals2) tp_req eff_req }}

let check_struct fix ~pos ~env defs tp_req eff_req =
  check_defs fix env defs tp_req eff_req
    { cd_cont = fun env vals tp_req eff_req ->
  let tp = T.Type.tstruct (List.map fst vals) in
  let flds = List.map snd vals in
  let (tp_resp, crc) =
    Request.return_type' ~env ~pos ~syncat:Structure tp_req tp in
  { ce_expr = ExprBuilder.coerce_expr_opt ~fix ~pos crc
      (make ~fix pos (T.EValue(make ~fix pos (T.VStruct flds))))
  ; ce_type = tp_resp
  ; ce_eff  = Request.return_eff ~env ~pos eff_req T.Type.eff_pure
  }}

(* ========================================================================= *)

let check_cps_struct fix ~pos ~env ~cont defs tp_req eff_req =
  let make data = make ~fix pos data in
  check_defs fix env defs tp_req eff_req
    { cd_cont = fun env vals tp_req eff_req ->
  let cont_tp = T.Var.typ cont in
  let (cont_crc, arg_tp, res_tp, f_eff) =
    TypeView.coerce_to_arrow ~env ~pos cont_tp in
  let cont = make (T.VCoerce(cont_crc, make (T.VVar cont))) in
  let (Checked, str_crc) =
    Request.return_type ~env ~pos ~syncat:Structure (Check arg_tp)
      (T.Type.tstruct (List.map fst vals)) in
  let flds = List.map snd vals in
  let str = ExprBuilder.coerce_value_opt ~fix ~pos str_crc
    (make (T.VStruct flds)) in
  let (tp_resp, crc) =
    Request.return_ex_type ~env ~pos ~syncat:CPS_Unit tp_req res_tp in
  { ce_expr = ExprBuilder.coerce_expr_opt ~fix ~pos crc
      (make (T.EApp(cont, str)))
  ; ce_type = tp_resp
  ; ce_eff  = Request.return_eff ~env ~pos eff_req f_eff
  }}
