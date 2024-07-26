open Lang.Node
open Common

type op_handler =
  { oph_pos         : Utils.Position.t
  ; oph_env         : Env.t
  ; oph_index       : int
  ; oph_tvars       : T.TVar.ex list
  ; oph_args        : T.pattern list
  ; oph_res_pattern : S.pattern
  ; oph_out_type    : T.ex_type
  ; oph_body        : S.expr
  }

type handler_list =
  { hl_pos         : Utils.Position.t
  ; hl_op_handlers : op_handler list
  ; hl_ret_clauses : (Utils.Position.t * S.pattern * S.expr) list
  ; hl_fin_clauses : (Utils.Position.t * S.pattern * S.expr) list
  }

type ('td, 'ed) checked_handler =
  { op_handlers : T.op_handler list
  ; ret_clauses : T.TVar.ex list * T.clause list
  ; fin_clauses : T.TVar.ex list * T.clause list
  ; ret_type    : T.ex_type
  ; tp_resp     : ('td, T.ex_type) response
  ; eff_resp    : ('ed, T.effect) response
  }

let check_eff_inst_binder (type d) fix env ib (s_req : (d, _) request) :
    _ * _ * (d, _) response =
  let guess_sig () : _ * (d, _) response =
    match s_req with
    | Check s -> (s, Checked)
    | Infer   ->
      let s = T.Type.fresh_uvar (Env.type_env env) KEffsig in
      (s, Infered s)
  in
  let return_sig s : (d, _) response =
    match s_req with
    | Infer    -> Infered s
    | Check s' ->
      begin try T.Type.unify ~env:(Env.type_env env) s s'; Checked with
      | T.Error _ ->
        failwith "Effect signature mismatch"
      end
  in
  match ib.data with
  | S.IBAnon ->
    let (s, s_resp) = guess_sig () in
    let (env, a) = Env.add_hidden_effinst env s in
    (env, a, s_resp)
  | S.IBInst name ->
    let (s, s_resp) = guess_sig () in
    let (env, a) = Env.add_effinst env name s in
    (env, a, s_resp)
  | S.IBAnnot(a, s) ->
    let s = fix.check_effsig fix env s in
    let (env, a) = Env.add_effinst env a.data s in
    (env, a, return_sig s)

let guess_inner_effect (type ed) env (eff_req : (ed, T.effect) request) =
  match eff_req with
  | Infer -> T.Type.fresh_uvar (Env.type_env env) KEffect
  | Check eff ->
    begin match T.Type.row_view eff with
    | T.RPure -> eff
    | _ ->
      (* Effect of a handler is invariant in the typing rule and can be smaller
      than effect expected by the context. So if handler is not used in pure
      context, we cannot guess its effect before actual typing of the handler.
      *)
      T.Type.fresh_uvar (Env.type_env env) KEffect
    end

(* ========================================================================= *)
(* Preparing *)

let rec check_op_select_loop ~fix ~env ~pos ~v1_pos v1 v1_tp name =
  let (crc, decls) = TypeView.coerce_to_struct ~env ~pos:v1_pos v1_tp in
  let v1 =
    match crc with
    | T.CId _ -> v1
    | _ -> make ~fix pos (T.VCoerce(crc, v1))
  in
  let name_str = S.string_of_name name in
  match T.Decl.select_op decls name_str with
  | Some (xs, s, ops, n) ->
    let proof = make ~fix pos (T.VSelOp(decls, v1, name_str)) in
    Some (Env.OpValue(proof, xs, s, ops, n))
  | None ->
    begin match T.Decl.select_this decls with
    | Some tp ->
      let v1 = make ~fix pos (T.VSelThis(decls, v1)) in
      check_op_select_loop ~fix ~env ~pos ~v1_pos v1 tp name
    | None -> None
    end

let check_op_select ~fix ~env ~pos ~v1_pos v1 v1_tp name =
  match check_op_select_loop ~fix ~env ~pos ~v1_pos v1 v1_tp name with
  | Some ctor -> ctor
  | None ->
    failwith "No such operation"

let check_handler_op ~fix ~pos env op s proof_opt =
  let (Env.OpValue(proof_gen, xs, s0, ops, n)) = op in
  let (proof_args, sub) = Env.instantiate_args env xs in
  let proof =
    begin match proof_opt with
    | None ->
      let ops = List.map (T.OpDecl.subst sub) ops in
      (make ~fix pos (T.VTypeApp(proof_gen, proof_args)), ops)
    | Some proof -> proof
    end in
  let s0 = T.Type.subst sub s0 in
  begin try T.Type.unify ~env:(Env.type_env env) s0 s with
  | T.Error _ ->
    failwith "Effect signature mismatch"
  end;
  let op = T.OpDecl.subst sub (List.nth ops n) in
  (proof, op, n)

let check_op_path ~fix env op s proof_opt =
  let pos = op.meta in
  match op.data with
  | S.OPName name ->
    begin match Env.lookup_op env (S.string_of_name name) with
    | Some op -> check_handler_op ~fix ~pos env op s proof_opt
    | None -> raise (Error.unbound_op name)
    end
  | S.OPPath(mexp, name) ->
    let m_res = fix.check_value fix env mexp Infer in
    let (Infered m_tp) = m_res.cv_type in
    let op = check_op_select
      ~fix ~env ~pos ~v1_pos:mexp.meta m_res.cv_value m_tp name in
    check_handler_op ~fix ~pos env op s proof_opt

let prepare_handler fix env h s proof_opt =
  match h.data with
  | S.HOp(op, args, res_pattern, body) ->
    let (proof, op, n) = check_op_path ~fix env op s proof_opt in
    let (env', xs, tps, out_tp) = Env.open_op_decl env op in
    if List.length args <> List.length tps then
      failwith "Arity mismatch";
    let cps = Pattern.check_patterns fix env' args tps in
    let oph =
      { oph_pos         = h.meta
      ; oph_env         = cps.cps_env
      ; oph_index       = n
      ; oph_tvars       = xs
      ; oph_args        = cps.cps_patterns
      ; oph_res_pattern = res_pattern
      ; oph_out_type    = out_tp
      ; oph_body        = body
      } in
    let update hs = { hs with hl_op_handlers = oph :: hs.hl_op_handlers } in
    (update, Some proof)

  | S.HReturn(pat, body) ->
    let update hs =
      { hs with hl_ret_clauses = (h.meta, pat, body) :: hs.hl_ret_clauses } in
    (update, proof_opt)
  | S.HFinally(pat, body) ->
    let update hs =
      { hs with hl_fin_clauses = (h.meta, pat, body) :: hs.hl_fin_clauses } in
    (update, proof_opt)

let rec prepare_handlers_loop fix ~pos ~env hs s proof_opt =
  match hs with
  | [] ->
    { hl_pos         = pos
    ; hl_op_handlers = []
    ; hl_ret_clauses = []
    ; hl_fin_clauses = []
    }, proof_opt
  | h :: hs ->
    let (update, proof_opt) = prepare_handler fix env h s proof_opt in
    let (hs, proof_opt)     =
      prepare_handlers_loop fix ~pos ~env hs s proof_opt in
    (update hs, proof_opt)

let prepare_handlers fix ~pos ~env hs s =
  let (hs, proof) = prepare_handlers_loop fix ~pos ~env hs s None in
  match proof with
  | None ->
    failwith "Empty handler"
  | Some (proof, ops) -> (hs, proof, ops)

(* ========================================================================= *)
(* Type-checking *)

let build_resumption_type env extp out_tp eff =
  let (_, xs, tp) = Env.open_ex_type env extp in
  T.Type.forall xs (T.Type.arrow tp out_tp eff)

let check_clause fix env tp (pos, pat, body) inner_tp inner_eff =
  let res_p = fix.check_pattern fix env pat (Check tp) in
  let res_e = fix.check_expr fix res_p.cp_env body
    (Check inner_tp) (Check inner_eff) in
  make ~fix pos (T.Clause(res_p.cp_pattern, res_e.ce_expr))

let check_ret_clauses fix env ret_clauses inner_tp inner_eff =
  let inner_eff = T.Type.open_effect_up ~env:(Env.type_env env) inner_eff in
  match ret_clauses with
  | [] ->
    let inner_tp = T.ExType.open_up ~env:(Env.type_env env) inner_tp in
    let (_, ex, tp) = Env.open_ex_type env inner_tp in
    (ex, [], inner_tp, inner_eff)
  | (pos, pat, body) :: ret_clauses ->
    let (env', ex, tp) = Env.open_ex_type env inner_tp in
    let res_p = fix.check_pattern fix env' pat (Check tp) in
    let res_e =
      fix.check_expr fix res_p.cp_env body Infer (Check inner_eff)
      |> ExprBuilder.coerce_to_scope ~fix ~env ~pos:body.meta in
    let (Infered inner_tp) = res_e.ce_type in
    let inner_tp = T.ExType.open_up ~env:(Env.type_env env) inner_tp in
    let cl = make ~fix pos (T.Clause(res_p.cp_pattern, res_e.ce_expr)) in
    let cls = List.map (fun cl ->
        check_clause fix env' tp cl inner_tp inner_eff)
      ret_clauses in
    (ex, cl :: cls, inner_tp, inner_eff)

let check_op_handler fix h inner_tp inner_eff =
  let env = h.oph_env in
  let res_tp = build_resumption_type env h.oph_out_type inner_tp inner_eff in
  let res_p  = fix.check_pattern fix env h.oph_res_pattern (Check res_tp) in
  let body   = fix.check_expr fix res_p.cp_env h.oph_body
    (Check inner_tp) (Check inner_eff) in
  make ~fix h.oph_pos (T.HOp(
    h.oph_index,
    h.oph_tvars,
    h.oph_args,
    res_p.cp_pattern,
    body.ce_expr))

let check_op_handlers fix hs inner_tp inner_eff =
  List.map (fun h ->
    check_op_handler fix h inner_tp inner_eff) hs

let check_fin_clauses fix ~env ~pos
    fin_clauses inner_tp inner_eff tp_req eff_req =
  let (env', ex, tp) = Env.open_ex_type env inner_tp in
  match fin_clauses with
  | [] ->
    let (tp_resp, crc) =
      Request.return_ex_type ~env ~pos ~syncat:Expression tp_req inner_tp in
    let eff_resp = Request.return_eff ~env ~pos eff_req inner_eff in
    begin match crc with
    | None -> (ex, [], tp_resp, eff_resp)
    | Some crc ->
      let x     = T.Var.fresh tp in
      let pat   = make ~fix pos (T.PVar x) in
      let insts = 
        List.map (fun (T.TVar.Pack x) -> T.TpInst(x, T.Type.var x)) ex in
      let body  =
        make ~fix pos (T.ECoerce(crc,
          make ~fix pos (T.EPack(insts, T.TExists([], tp),
            make ~fix pos (T.EValue (make ~fix pos (T.VVar x))))))) in
      let cl = make ~fix pos (T.Clause(pat, body)) in
      (ex, [ cl ], tp_resp, eff_resp)
    end
  | (pos, pat, body) :: fin_clauses ->
    let res_p = fix.check_pattern fix env' pat (Check tp) in
    let res_e =
      fix.check_expr fix res_p.cp_env body tp_req eff_req
      |> ExprBuilder.coerce_to_scope ~fix ~env ~pos:body.meta in
    let (outer_tp,  tp_resp) =
      Request.merge_ex_type env tp_req res_e.ce_type in
    let (outer_eff, eff_resp) =
      Request.merge_effect env eff_req res_e.ce_eff in
    let cl = make ~fix pos (T.Clause(res_p.cp_pattern, res_e.ce_expr)) in
    let cls = List.map (fun cl ->
        check_clause fix env' tp cl outer_tp outer_eff)
      fin_clauses in
    (ex, cl :: cls, tp_resp, eff_resp)

let check_handlers fix env inner_tp inner_eff hs tp_req eff_req =
  let (ret_ex, ret_clauses, inner_tp, inner_eff) =
    check_ret_clauses fix env hs.hl_ret_clauses inner_tp inner_eff in
  let op_handlers =
    check_op_handlers fix hs.hl_op_handlers inner_tp inner_eff in
  let (fin_ex, fin_clauses, tp_resp, eff_resp) =
    check_fin_clauses fix ~pos:hs.hl_pos ~env
      hs.hl_fin_clauses
      inner_tp inner_eff
      tp_req eff_req in
  { op_handlers = op_handlers
  ; ret_clauses = (ret_ex, ret_clauses)
  ; fin_clauses = (fin_ex, fin_clauses)
  ; ret_type    = inner_tp
  ; tp_resp     = tp_resp
  ; eff_resp    = eff_resp
  }
