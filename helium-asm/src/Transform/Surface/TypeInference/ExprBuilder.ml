open Common

let coerce_ex_type_to_scope ~env ~pos extp =
  try T.ExType.coerce_to_scope (Env.scope env) extp with
  | T.Error _ ->
    failwith "Something escapes scope"

let restrict_effect_to_scope ~env ~pos eff =
  try T.Type.restrict_to_scope (Env.scope env) eff with
  | T.Error _ ->
    failwith "Something escapes scope"

let restrict_type_resp_to_scope (type td) ~fix
    ~env ~pos expr (tp_resp : (td, _) response) : _ * (td, _) response =
  match tp_resp with
  | Infered extp ->
    let (crc, extp) = coerce_ex_type_to_scope ~env ~pos extp in
    begin match crc with
    | CExId _ -> (expr, Infered extp)
    | _  -> (make ~fix pos (T.ECoerce(crc, expr)), Infered extp)
    end
  | Checked -> (expr, Checked)

let restrict_effect_resp_to_scope (type ed)
    ~env ~pos (eff_resp : (ed, _) response) : (ed, _) response =
  match eff_resp with
  | Infered eff -> 
    restrict_effect_to_scope ~env ~pos eff;
    Infered eff
  | Checked -> Checked

let coerce_to_scope (type td ed) ~fix ~env ~pos res =
  let (e, tp_resp) =
    restrict_type_resp_to_scope ~fix ~env ~pos res.ce_expr res.ce_type in
  { ce_expr = e
  ; ce_type = tp_resp
  ; ce_eff  = restrict_effect_resp_to_scope ~env ~pos res.ce_eff
  }

let extend_pack (type td ed) ~fix ~pos ex (res : (td, ed) checked_expr) :
    (td, ed) checked_expr =
  match res.ce_type with
  | Infered _ when ex = [] -> res
  | Infered (T.TExists(ex', tp) as extp0) ->
    let inst =
      List.map (fun (T.TVar.Pack x) -> (T.TpInst(x, T.Type.var x))) ex in
    let extp = T.TExists(ex @ ex', tp) in
    { ce_expr = make ~fix pos (T.EPack(inst, extp0, res.ce_expr))
    ; ce_type = Infered extp
    ; ce_eff  = res.ce_eff
    }
  | Checked -> res

let build_let (type td ed) ~fix ~env ~pos ex x e1
    (res : (td, ed) checked_expr) =
  let res = extend_pack ~fix ~pos ex res in
  { ce_expr = make ~fix pos (T.ELet(ex, x, e1, res.ce_expr))
  ; ce_type = res.ce_type
  ; ce_eff  = restrict_effect_resp_to_scope ~env ~pos res.ce_eff
  }

let build_let_pat ~fix ~env ~pos ex pat v tp_req res =
  let res = coerce_to_scope ~fix ~env ~pos res in
  let tp  = Request.join tp_req res.ce_type in
  { ce_expr = make ~fix pos
      (T.EMatch(v, [ make ~fix pos (T.Clause(pat, res.ce_expr)) ], tp))
  ; ce_type = res.ce_type
  ; ce_eff  = res.ce_eff
  }

let build_typedef ~fix ~env ~pos tds res =
  let ex = List.map (fun (T.TypeDef(x, _)) -> T.TVar.Pack x) tds in
  let res = extend_pack ~fix ~pos ex res in
  { ce_expr = make ~fix pos (T.ETypeDef(tds, res.ce_expr))
  ; ce_type = res.ce_type
  ; ce_eff  = restrict_effect_resp_to_scope ~env ~pos res.ce_eff
  }

let bind_expr (type td) fix env e
    (tp_req  : (td, _) request)
    (eff_req : (_,  _) request)
    (cont    : _ -> _ -> (td, _) response -> _ -> (_, _) checked_expr) =
  let pos = e.Lang.Node.meta in
  let res = fix.check_expr fix env e tp_req eff_req in
  match tp_req, res.ce_type with
  | Infer, Infered extp ->
    let (env, ex, tp) = Env.open_ex_type env extp in
    let (env, x) = Env.add_var' env tp in
    build_let ~fix ~env ~pos ex x res.ce_expr
      (cont env (make ~fix pos (T.VVar x)) (Infered tp) res.ce_eff)
  | Check extp, Checked ->
    let (env, ex, tp) = Env.open_ex_type env extp in
    let (env, x) = Env.add_var' env tp in
    build_let ~fix ~env ~pos ex x res.ce_expr
      (cont env (make ~fix pos (T.VVar x)) Checked res.ce_eff)

let coerce_value_opt ~fix ~pos crc v =
  match crc with
  | None -> v
  | Some crc -> make ~fix pos (T.VCoerce(crc, v))

let coerce_expr_opt ~fix ~pos crc e =
  match crc with
  | None -> e
  | Some crc -> make ~fix pos (T.ECoerce(crc, e))

let value_as_var ~fix ~env ~pos v tp cont =
  let (env, x) = Env.add_var' env tp in
  let res = cont env x in
  { res with
    ce_expr =
      make ~fix pos (T.ELet([], x,
        make ~fix pos (T.EValue v),
        res.ce_expr))
  }
