open Lang.Node
open Common

type 'td check_function_arg_cont =
  { cfa_cont : 'ed. Env.t ->
      ('td, T.ex_type) request -> ('ed, T.effect) request ->
        ('td, 'ed) checked_expr
  }

(* ========================================================================= *)
let check_value_as_expr (type td ed) ~fix ~env ~pos
    (tp_req  : (td, T.ex_type) request)
    (eff_req : (ed, T.effect)  request)
    (cont    : ((td, T.ttype) request -> td checked_value)) :
      (td, ed) checked_expr =
  match tp_req with
  | Infer ->
    let res = cont Infer in
    let (Infered tp) = res.cv_type in
    { ce_expr = make ~fix pos (T.EValue res.cv_value)
    ; ce_type = Infered (T.TExists([], tp))
    ; ce_eff  = Request.return_eff ~env ~pos eff_req T.Type.eff_pure
    }
  | Check extp ->
    let (inst, tp) = Env.instantiate_ex env extp in
    let res = cont (Check tp) in
    { ce_expr = make ~fix pos (T.EPack(inst, T.TExists([], tp),
        make ~fix pos (T.EValue res.cv_value)))
    ; ce_type = Checked
    ; ce_eff  = Request.return_eff ~env ~pos eff_req T.Type.eff_pure
    }

let check_var ~fix ~pos vv =
  match vv with
  | Env.VValue(v, tp) -> (make ~fix pos v, tp)

  | Env.VOp(v, xs, s, ops, n) ->
    let op = List.nth ops n in
    let v  = TypeDef.op_proxy ~fix ~pos v xs s op n in
    let tp = T.Type.op_type xs s op in
    (v, tp)

  | Env.VCtor(v, xs, tp, ctors, n) ->
    let ctor = List.nth ctors n in
    let v  = TypeDef.ctor_proxy ~fix ~pos v xs tp ctor n in
    let tp = T.Type.ctor_type xs tp ctor in
    (v, tp)

let check_effinst env inst s =
  match inst.data with
  | S.EIVar x ->
    begin match Env.lookup_effinst env x with
    | Some(a, s') ->
      begin try T.Type.unify ~env:(Env.type_env env) s s'; a with
      | T.Error _ ->
        failwith "Effect signature mismatch"
      end

    | None ->
      raise (Error.unbound_eff_inst ~pos:inst.meta x)
    end

(* ========================================================================= *)
(* Expressions *)

let rec check : type td ed. fix ->
    Env.t -> S.expr -> (td, T.ex_type) request -> (ed, T.effect) request ->
      (td, ed) checked_expr =
  fun fix env e tp_req eff_req ->
  let check_type  env = fix.check_type fix env in
  let check_def   env = fix.check_def  fix env in
  let check_expr  env = check          fix env in
  let check_value env = check_value    fix env in
  let pos = e.meta in
  let make data = make ~fix pos data in
  match e.data with
  | S.EType | S.EEffect | S.EEffsig | S.EArrowPure _ | S.EArrowEff _
  | S.EHandlerType _ | S.ERow _ | S.ELit _ | S.EVar _ | S.EEffInst _ | S.EFn _
  | S.EHandler _ | S.ESig _ | S.EExtern _ ->
    check_value_as_expr ~fix ~env ~pos tp_req eff_req (fun tp_req ->
    check_value env e tp_req)

  | S.ETypeAnnot(e, tp) ->
    let extp = check_type env tp in
    let res  = check_expr env e (Check extp) eff_req in
    let (tp_resp, crc) =
      Request.return_ex_type ~env ~pos ~syncat:Expression tp_req extp in
    { ce_expr = ExprBuilder.coerce_expr_opt ~fix ~pos crc res.ce_expr
    ; ce_type = tp_resp
    ; ce_eff  = res.ce_eff
    }

  | S.EDef(def, e) ->
    check_def env def tp_req eff_req { cd_cont = fun env flds tp_req eff_req ->
    check_expr env e tp_req eff_req }

  | S.EApp(e1, e2) ->
    ExprBuilder.bind_expr fix env e1 Infer eff_req
      (fun env v1 (Infered tp1) eff_resp ->
    let (crc, arg_tp, res_tp, f_eff) =
      TypeView.coerce_to_arrow ~env ~pos:e1.meta tp1 in
    let v1 = make (T.VCoerce(crc, v1)) in
    Request.next_eff_request env eff_req eff_resp (fun eff_req ->
    let e2_tp_req = Check (T.TExists([], arg_tp)) in
    ExprBuilder.bind_expr fix env e2 e2_tp_req eff_req
      (fun env v2 Checked Checked ->
    let (tp_resp, crc) =
      Request.return_ex_type ~env ~pos ~syncat:Expression tp_req res_tp in
    { ce_expr = ExprBuilder.coerce_expr_opt ~fix ~pos crc
        (make (T.EApp(v1, v2)))
    ; ce_type = tp_resp
    ; ce_eff  = Request.return_eff ~env ~pos eff_req f_eff
    })))

  | S.EAppInst(e1, inst) ->
    ExprBuilder.bind_expr fix env e1 Infer eff_req
      (fun env v1 (Infered tp1) eff_resp ->
    let (crc, a0, s, res_tp) =
      TypeView.coerce_to_forall_inst ~env ~pos:e1.meta tp1 in
    let v1 = make (T.VCoerce(crc, v1)) in
    let a = T.EffInstExpr.instance (check_effinst env inst s) in
    let res_tp = T.Type.subst_inst a0 a res_tp in
    let (tp_resp, crc) =
      Request.return_type' ~env ~pos ~syncat:Expression tp_req res_tp in
    { ce_expr = ExprBuilder.coerce_expr_opt ~fix ~pos crc
        (make (T.EInstApp(v1, a)))
    ; ce_type = tp_resp
    ; ce_eff  = eff_resp
    })

  | S.EMatch(e0, []) ->
    ExprBuilder.bind_expr fix env e0 Infer eff_req
      (fun env v0 (Infered tp0) eff_resp ->
    let (crc, neu) = TypeView.coerce_to_neutral ~env ~pos:e0.meta tp0 in
    let v0 = make (T.VCoerce(crc, v0)) in
    match Env.prove_empty env neu with
    | None ->
      raise (Error.empty_match ~env ~pos tp0)
    | Some proof ->
      let (extp, tp_resp) = Request.guess_ex_type env tp_req in
      { ce_expr = make (T.EEmptyMatch(v0, proof, extp))
      ; ce_type = tp_resp
      ; ce_eff  = eff_resp
      })

  | S.EMatch(e0, ((_ :: _) as cls)) ->
    ExprBuilder.bind_expr fix env e0 Infer eff_req
      (fun env v0 (Infered tp0) eff_resp ->
    Request.next_eff_request env eff_req eff_resp (fun eff_req ->
    let (extp, tp_resp) = Request.guess_ex_type env tp_req in
    let cls = check_clauses fix env cls tp0 (Check extp) eff_req in
    { ce_expr = make (T.EMatch(v0, cls, extp))
    ; ce_type = tp_resp
    ; ce_eff  = Checked
    }))

  | S.EHandle(ib, e, hs) ->
    let (env', a, Infered s) =
      Handler.check_eff_inst_binder fix env ib Infer in
    let (hs, proof, ops) = Handler.prepare_handlers fix ~pos ~env hs s in
    let inner_eff = Handler.guess_inner_effect env eff_req in
    let res_e = check_expr env' e Infer
      (Check (T.Type.eff_cons (T.Type.eff_ivar a) inner_eff)) in
    let (Infered inner_tp) = res_e.ce_type in
    let h_res =
      Handler.check_handlers fix env inner_tp inner_eff hs tp_req eff_req in
    { ce_expr = make (T.EHandle
        { effinst     = a
        ; effsig      = s
        ; ops         = ops
        ; proof       = proof
        ; body        = res_e.ce_expr
        ; ret_effect  = inner_eff (* TODO: is it correct? *)
        ; ret_type    = h_res.ret_type
        ; fin_type    = Request.join tp_req h_res.tp_resp
        ; op_handlers = h_res.op_handlers
        ; ret_clauses = h_res.ret_clauses
        ; fin_clauses = h_res.fin_clauses
        })
    ; ce_type = h_res.tp_resp
    ; ce_eff  = h_res.eff_resp
    }

  | S.EHandleWith(ib, body, he) ->
    ExprBuilder.bind_expr fix env he Infer eff_req
      (fun env hv (Infered h_tp) eff_resp ->
    let (crc, s, in_tp, in_eff, out_tp, out_eff) =
      TypeView.coerce_to_handler ~env ~pos:he.meta h_tp in
    let hv = make (T.VCoerce(crc, hv)) in
    Request.next_eff_request env eff_req eff_resp (fun eff_req ->
    let (env', a, Checked) =
      Handler.check_eff_inst_binder fix env ib (Check s) in
    let body_res = check_expr env' body
      (Check in_tp)
      (Check (T.Type.eff_cons (T.Type.eff_ivar a) in_eff)) in
    let (tp_resp, crc) =
      Request.return_ex_type ~env ~pos ~syncat:Expression tp_req out_tp in
    { ce_expr = ExprBuilder.coerce_expr_opt ~fix ~pos crc
        (make (T.EHandleWith(a, s, body_res.ce_expr, hv)))
    ; ce_type = tp_resp
    ; ce_eff  = Request.return_eff ~env ~pos eff_req out_eff
    }))

  | S.ESelect(e1, name) ->
    ExprBuilder.bind_expr fix env e1 Infer eff_req
      (fun env v1 (Infered tp1) eff_resp ->
    let res_e =
      check_value_as_expr ~fix ~env ~pos tp_req Infer (fun tp_req ->
      let (v1, tp) = check_select ~fix ~env ~pos ~v1_pos:e1.meta v1 tp1 name in
      let (tp_resp, crc) =
        Request.return_type ~env ~pos ~syncat:Expression tp_req tp in
      { cv_value = ExprBuilder.coerce_value_opt ~fix ~pos crc v1
      ; cv_type = tp_resp
      }) in
    { ce_expr = res_e.ce_expr
    ; ce_type = res_e.ce_type
    ; ce_eff  = eff_resp
    })

  | S.ERecord [] -> assert false
  | S.ERecord(fd1 :: fds) ->
    Record.check_first_def ~fix ~env ~pos fd1 tp_req eff_req
      (fun env proof rdtp flds fd1 eff_resp ->
    Request.next_eff_request env eff_req eff_resp (fun eff_req ->
    Record.check_rest_defs ~fix ~env ~pos fds rdtp flds eff_req (fun fds ->
    Uniqueness.check_field_def_uniqueness (fd1 :: fds);
    make (T.VRecord(proof, Record.build_record ~pos flds (fd1 :: fds))))))

  | S.EStruct defs ->
    Def.check_struct fix ~pos ~env defs tp_req eff_req

  | S.ERepl cont ->
    let (tp,  tp_resp)  = Request.guess_ex_type env tp_req in
    let (eff, eff_resp) = Request.guess_effect env eff_req in
    let cont () =
      let (cmd, rest) = cont () in
      let w0 = T.World.save () in
      let rollback () = T.World.rollback w0 in
      match fix.check_repl_cmd fix env cmd rest tp eff with
      | rest -> 
        { CommonRepl.data     = rest
        ; CommonRepl.meta     =
          Flow.MetaData.of_list [ Pack(CommonTags.m_position, fix.pos_tab) ]
        ; CommonRepl.rollback = rollback
        }
      | exception (Error.Type_error err) ->
        raise (CommonRepl.Error(Flow.State.create Error.flow_node err, rollback))
    in
    let pretty_env = Env.pretty_env env in
    let prompt     = Pretty.Unif.pretty_row pretty_env eff in
    { ce_expr = make (T.ERepl(cont, tp, eff, prompt))
    ; ce_type = tp_resp
    ; ce_eff  = eff_resp
    }

(* ========================================================================= *)
(* Values *)

and check_value : type td. fix ->
    Env.t -> S.expr -> (td, T.ttype) request -> td checked_value =
  fun fix env e tp_req ->
  let check_type   env = fix.check_type fix env in
  let check_effect env = fix.check_effect fix env in
  let check_value  env = check_value    fix env in
  let pos = e.meta in
  let make data = make ~fix pos data in
  match e.data with
  | S.EType | S.EEffect | S.EEffsig | S.EArrowPure _ | S.EArrowEff _
  | S.EHandlerType _ | S.ESig _ ->
    let extp = check_type env e in
    let (tp_resp, crc) =
      Request.return_type ~env ~pos ~syncat:Expression tp_req
        (T.Type.type_wit extp) in
    { cv_value = ExprBuilder.coerce_value_opt ~fix ~pos crc
        (make (T.VTypeWit extp))
    ; cv_type = tp_resp
    }

  | S.EEffInst _ | S.ERow _ ->
    let eff = check_effect env e in
    let (tp_resp, crc) =
      Request.return_type ~env ~pos ~syncat:Expression tp_req
        (T.Type.effect_wit eff) in
    { cv_value = ExprBuilder.coerce_value_opt ~fix ~pos crc
        (make (T.VEffectWit eff))
    ; cv_type = tp_resp
    }

  | S.ELit lit ->
    let tp = T.Type.base (Lang.RichBaseType.type_of_lit lit) in
    let (tp_resp, crc) =
      Request.return_type ~env ~pos ~syncat:Expression tp_req tp in
    { cv_value = ExprBuilder.coerce_value_opt ~fix ~pos crc
        (make (T.VLit lit))
    ; cv_type = tp_resp
    }

  | S.EVar name ->
    let (v, tp) =
      match Env.lookup_var env (S.string_of_name name) with
      | Some vv -> check_var ~fix ~pos vv
      | None -> raise (Error.unbound_var name)
    in
    let (tp_resp, crc) =
      Request.return_type ~env ~pos ~syncat:Expression tp_req tp in
    { cv_value = ExprBuilder.coerce_value_opt ~fix ~pos crc v
    ; cv_type = tp_resp
    }

  | S.ETypeAnnot(e, tp) ->
    begin match check_type env tp with
    | T.TExists([], tp) ->
      let res  = check_value env e (Check tp) in
      let (tp_resp, crc) =
        Request.return_type ~env ~pos ~syncat:Expression tp_req tp in
      { cv_value = ExprBuilder.coerce_value_opt ~fix ~pos crc res.cv_value
      ; cv_type = tp_resp
      }
    | T.TExists(_ :: _, _) ->
      failwith "Existentials are not allowed here"
    end

  | S.EFn(args, body) ->
    check_function fix env args body tp_req

  | S.EHandler hs ->
    check_handler_context ~fix ~env ~pos tp_req
      (fun s inner_tp inner_eff out_tp out_eff ->
    let (hs, proof, ops) = Handler.prepare_handlers fix ~pos ~env hs s in
    let h_res =
      Handler.check_handlers fix env inner_tp inner_eff hs out_tp out_eff in
    let out_tp  = Request.join out_tp  h_res.tp_resp  in
    let out_eff = Request.join out_eff h_res.eff_resp in
    (make (T.VHandler
      { effsig      = s
      ; ops         = ops
      ; proof       = proof
      ; in_type     = inner_tp
      ; in_effect   = inner_eff
      ; ret_type    = h_res.ret_type
      ; ret_effect  = inner_eff (* TODO: is it correct? *)
      ; out_type    = out_tp
      ; out_effect  = out_eff
      ; op_handlers = h_res.op_handlers
      ; ret_clauses = h_res.ret_clauses
      ; fin_clauses = h_res.fin_clauses
      }), h_res.tp_resp, h_res.eff_resp))
  
  | S.ESelect(e1, name) ->
    let v1_resp = check_value env e1 Infer in
    let v1      = v1_resp.cv_value in
    let (Infered v1_tp) = v1_resp.cv_type in
    let (v1, tp) = check_select ~fix ~env ~pos ~v1_pos:e1.meta v1 v1_tp name in
    let (tp_resp, crc) =
      Request.return_type ~env ~pos ~syncat:Expression tp_req tp in
    { cv_value = ExprBuilder.coerce_value_opt ~fix ~pos crc v1
    ; cv_type  = tp_resp
    }

  | S.EExtern name -> Extern.check ~fix ~env ~pos name tp_req

  | S.EDef _ | S.EApp _ | S.EAppInst _ | S.EMatch _ | S.EHandle _
  | S.EHandleWith _ | S.ERecord _ | S.EStruct _ | S.ERepl _ ->
    failwith ("Not a value (" ^ Utils.Position.to_string pos ^ ")")

(* ========================================================================= *)
(* functions *)

and check_function : type td. fix ->
    Env.t -> S.fn_arg list -> S.expr -> (td, _) request -> td checked_value =
  fun fix env args body tp_req ->
  match args with
  | [] -> assert false
  | arg :: args ->
    check_function_arg fix env arg tp_req
      { cfa_cont = fun env tp_req eff_req ->
        check_function_expr fix env args body tp_req eff_req }

and check_function_expr : type td ed. fix ->
    Env.t -> S.fn_arg list -> S.expr ->
    (td, T.ex_type) request -> (ed, T.effect) request ->
      (td, ed) checked_expr =
  fun fix env args body tp_req eff_req ->
  let check_expr env = check fix env in
  let pos = body.meta in (* TODO: what is correct position here? *)
  match args with
  | [] -> check_expr env body tp_req eff_req
  | _ ->
    check_value_as_expr ~fix ~env ~pos tp_req eff_req (fun tp_req ->
    check_function fix env args body tp_req)

and check_function_arg : type td. fix ->
    Env.t -> S.fn_arg -> (td, T.ttype) request ->
      td check_function_arg_cont -> td checked_value =
  fun fix env arg tp_req cont ->
  let check_pattern env = fix.check_pattern fix env in
  let check_type    env = fix.check_type    fix env in
  let check_effsig  env = fix.check_effsig  fix env in
  let pos = arg.meta in
  let make data = make ~fix pos data in
  match arg.data with
  | S.FAPattern p ->
    begin match tp_req with
    | Infer ->
      let name =
        match S.name_of_pattern p with
        | None -> None
        | Some name -> Some (S.string_of_name name)
      in
      let res_p = check_pattern env p Infer in
      let (Infered (gvars, tp1)) = res_p.cp_type in
      let res_b = cont.cfa_cont res_p.cp_env Infer Infer in
      (* We create environment, that extends env only by gvars only for scope
      checking. Other variables, i.e. from res_p exvars should not escape the
      scope *)
      let env' = Env.add_tvar_l env gvars in
      let res_b = ExprBuilder.coerce_to_scope ~fix ~pos ~env:env' res_b in
      let (Infered tp2) = res_b.ce_type in
      let (Infered eff) = res_b.ce_eff in
      { cv_value = make (T.VTypeFun(gvars,
            (make (T.VFn(res_p.cp_pattern, res_b.ce_expr, tp2)))))
      ; cv_type  = Infered (T.Type.forall gvars
          (T.Type.arrow ?name tp1 tp2 eff))
      }
    | Check tp ->
      { cv_value =
          generalize_to_arrow ~fix ~pos ~env tp (fun env tp1 extp eff ->
          let res_p = check_pattern env p (Check tp1) in
          let res_b = cont.cfa_cont res_p.cp_env (Check extp) (Check eff) in
          (* We do not need to restrict scope, since we are in checking mode *)
          make (T.VFn(res_p.cp_pattern, res_b.ce_expr, extp)))
      ; cv_type = Checked
      }
    end

  | S.FAEffInst name ->
    let s = T.Type.fresh_uvar (Env.type_env env) T.KEffsig in
    check_instance_arg fix ~pos ~env name s tp_req cont
  
  | S.FAEffInstsAnnot(names, s) ->
    let s = check_effsig env s in
    check_instance_args fix env names s tp_req cont

  | S.FAImplicit(names, tp) ->
    let tp = check_type env tp in
    check_implicit_args fix env names tp tp_req cont

and check_instance_arg : type td. fix -> pos:_ -> env:_ ->
    string -> T.effsig -> (td, T.ttype) request ->
      td check_function_arg_cont -> td checked_value =
  fun fix ~pos ~env name s tp_req cont ->
  match tp_req with
  | Infer ->
    let (env, a) = Env.add_effinst env name s in
    let res_b = cont.cfa_cont env Infer (Check T.Type.eff_pure) in
    begin match res_b.ce_type with
    | Infered (TExists([], tp2)) ->
      { cv_value = make ~fix pos (T.VInstFun(a, s, res_b.ce_expr))
      ; cv_type  = Infered (T.Type.forall_inst a s tp2)
      }
    | Infered (TExists(_ :: _, _)) ->
      failwith "Existentials are not allowed here"
    end
  | Check tp ->
    { cv_value =
        generalize_to_forall_inst ~fix ~pos ~env tp (fun env a0 s' tp ->
        begin try T.Type.unify ~env:(Env.type_env env) s s' with
        | T.Error _ -> failwith "Effect signature mismatch"
        end;
        let (env, a) = Env.add_effinst env name s in
        let tp = T.Type.subst_inst a0 (T.EffInstExpr.instance a) tp in
        let res_b = cont.cfa_cont env
          (Check (TExists([], tp))) (Check T.Type.eff_pure) in
        make ~fix pos (T.VInstFun(a, s, res_b.ce_expr)))
    ; cv_type = Checked
    }

and check_instance_args : type td. fix ->
    Env.t -> S.inst_id S.node list -> T.effsig -> (td, T.ttype) request ->
      td check_function_arg_cont -> td checked_value =
  fun fix env names s tp_req cont ->
  match names with
  | []       -> assert false
  | [ name ] ->
    check_instance_arg fix ~pos:name.meta ~env name.data s tp_req cont
  | name :: names ->
    let pos = name.meta in
    check_instance_arg fix ~pos ~env name.data s tp_req
      { cfa_cont = fun env tp_req eff_req ->
        check_value_as_expr ~fix ~env ~pos tp_req eff_req (fun tp_req ->
          check_instance_args fix env names s tp_req cont) }

and check_implicit_arg : type td. fix -> pos:_ -> env:_ ->
    S.name -> T.ex_type -> (td, T.ttype) request ->
      td check_function_arg_cont -> td checked_value =
  fun fix ~pos ~env name extp tp_req cont ->
  let make data = make ~fix pos data in
  let rec gen_witness tp =
    match T.Type.view tp with
    | TTypeWit   extp -> make (T.VTypeWit extp)
    | TEffectWit eff  -> make (T.VEffectWit eff)
    | TEffsigWit s    -> make (T.VEffsigWit s)
    | TArrow(_, tp1, TExists([], tp2), _) ->
      let x = T.Var.fresh tp1 in
      make (T.VFn(make (T.PVar x), 
        make (T.EValue (gen_witness tp2)),
        TExists([], tp2)))
    | TForall(xs, tp) ->
      make (T.VTypeFun(xs, gen_witness tp))

    | TUVar _ | TBase _ | TNeutral _ | TArrow(_, _, TExists(_ :: _, _), _) 
    | TForallInst _ | THandler _ | TStruct _ | TDataDef _ | TRecordDef _
    | TEffsigDef _ ->
      failwith "Cannot infer value of this type"
  in
  match tp_req with
  | Infer ->
    let (env, xs, tp) = Env.open_ex_type env extp in
    let v = gen_witness tp in
    let (env, x) = Env.add_var env (S.string_of_name name) tp in
    let res = cont.cfa_cont env Infer (Check T.Type.eff_pure) in
    begin match res.ce_type with
    | Infered (TExists([], tp2)) ->
      { cv_value = make (T.VTypeFunE(xs,
          make (T.ELet([], x, make (T.EValue v), res.ce_expr))))
      ; cv_type  = Infered (T.Type.forall xs tp2)
      }
    | Infered (TExists(_ :: _, _)) ->
      failwith "Sealing is not allowed here"
    end
  | Check _ ->
    failwith "Not implemented"

and check_implicit_args : type td. fix ->
    Env.t -> S.name list -> T.ex_type -> (td, T.ttype) request ->
      td check_function_arg_cont -> td checked_value =
  fun fix env names tp tp_req cont ->
  match names with
  | []       -> assert false
  | [ name ] ->
    check_implicit_arg fix ~pos:name.meta ~env name tp tp_req cont
  | name :: names ->
    let pos = name.meta in
    check_implicit_arg fix ~pos ~env name tp tp_req
      { cfa_cont = fun env tp_req eff_req ->
        check_value_as_expr ~fix ~env ~pos tp_req eff_req (fun tp_req ->
          check_implicit_args fix env names tp tp_req cont) }

and generalize_to_arrow ~fix ~pos ~env tp cont =
  match T.Type.view tp with
  | TArrow(_, tp1, extp, eff) -> cont env tp1 extp eff
  | TUVar(sub, u) ->
    T.UVar.match_arrow sub u;
    generalize_to_arrow ~fix ~pos ~env tp cont
  | TForall(xs, tp) ->
    let (env, xs, tp) = Env.open_ex_type env (T.TExists(xs, tp)) in
    make ~fix pos (T.VTypeFun(xs,
      (generalize_to_arrow ~fix ~pos ~env tp cont)))
  | TBase _ | TNeutral _ | TForallInst _ | THandler _ | TStruct _ | TTypeWit _
  | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    failwith "Not an arrow context"

and generalize_to_forall_inst ~fix ~pos ~env tp cont =
  match T.Type.view tp with
  | TForallInst(a, s, tp) -> cont env a s tp
  | TUVar(sub, u) ->
    T.UVar.match_forall_inst sub u;
    generalize_to_forall_inst ~fix ~pos ~env tp cont
  | TForall(xs, tp) ->
    let (env, xs, tp) = Env.open_ex_type env (T.TExists(xs, tp)) in
    make ~fix pos (T.VTypeFun(xs,
      (generalize_to_forall_inst ~fix ~pos ~env tp cont)))
  | TBase _ | TNeutral _ | TArrow _ | THandler _ | TStruct _ | TTypeWit _
  | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    failwith "Not an instance arrow context"

(* ========================================================================= *)
(* First class handler *)

and check_handler_context : type td. fix: _ -> env: _ -> pos: _ ->
    (td, T.ttype) request ->
    (T.effsig -> T.ex_type -> T.effect -> (td, _) request -> (td, _) request ->
      (T.value * (td, _) response * (td, _) response)) ->
    td checked_value =
  fun ~fix ~env ~pos tp_req cont ->
  match tp_req with
  | Infer ->
    let s      = T.Type.fresh_uvar (Env.type_env env) KEffsig in
    let in_tp  = T.TExists([], T.Type.fresh_uvar (Env.type_env env) KType) in
    let in_eff = T.Type.fresh_uvar (Env.type_env env) KEffect in
    let (v, Infered out_tp, Infered out_eff) =
      cont s in_tp in_eff Infer Infer in
    { cv_value = v
    ; cv_type  = Infered (T.Type.handler s in_tp in_eff out_tp out_eff)
    }
  | Check tp ->
    begin match T.Type.view tp with
    | THandler(s, in_tp, in_eff, out_tp, out_eff) ->
      let (v, Checked, Checked) =
        cont s in_tp in_eff (Check out_tp) (Check out_eff) in
      { cv_value = v
      ; cv_type  = Checked
      }

    | TUVar(sub, u) ->
      T.UVar.match_handler sub u;
      check_handler_context ~fix ~env ~pos tp_req cont

    | TForall(xs, tp) ->
      let (env, xs, tp) = Env.open_ex_type env (T.TExists(xs, tp)) in
      let res_v = check_handler_context ~fix ~env ~pos (Check tp) cont in
      { cv_value = make ~fix pos (T.VTypeFun(xs, res_v.cv_value))
      ; cv_type  = Checked
      }

    | TBase _ | TNeutral _ | TArrow _ | TForallInst _ | TStruct _ | TTypeWit _
    | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
      failwith "Not a handler context"
    end

(* ========================================================================= *)
(* Select *)

and check_select ~fix ~env ~pos ~v1_pos v1 v1_tp name =
  let tpv = TypeView.coerce_to_neutral_or_struct ~env ~pos:v1_pos v1_tp in
  match check_select_loop ~fix ~env ~pos ~v1_pos v1 tpv name with
  | Some(v, tp) -> (v, tp)
  | None -> raise (Error.no_member ~pos:v1_pos ~env v1_tp name)

and check_select_loop ~fix ~env ~pos ~v1_pos v1 v1_tp name =
  let (crc, opt) = v1_tp in
  let v1 =
    match crc with
    | T.CId _ -> v1
    | _ -> make ~fix pos (T.VCoerce(crc, v1))
  in
  match opt with
  (* Record *)
  | Left struct_tp ->
    begin match Env.lookup_field env (S.string_of_name name) with
    | Some(FieldValue(proof_gen, xs, tp, flds, n)) ->
      let (proof_args, sub) = Env.instantiate_args env xs in
      let proof = make ~fix pos (T.VTypeApp(proof_gen, proof_args)) in
      let tp = T.Type.subst sub tp in
      begin try T.Type.unify ~env:(Env.type_env env) struct_tp tp with
      | T.Error _ -> failwith "Type mismatch"
      end;
      let (T.FieldDecl(_, tp_out)) = List.nth flds n in
      let tp_out = T.Type.subst sub tp_out in
      Some (make ~fix pos (T.VSelect(proof, n, v1)), tp_out)

    | None -> raise (Error.unbound_field name)
    end

  (* Structure *)
  | Right decls ->
    begin match name.data with
    | S.NameThis ->
      begin match T.Decl.select_this decls with
      | Some tp ->
        Some (make ~fix pos (T.VSelThis(decls, v1)), tp)
      | None -> None
      end

    | _ ->
      let name_str = S.string_of_name name in
      begin match T.Decl.select_val decls name_str with
      | Some (VDVal tp) ->
        Some (make ~fix pos (T.VSelVal(decls, v1, name_str)), tp)
      | Some (VDOp(xs, s, ops, n)) ->
        let op = List.nth ops n in
        let v1 = make ~fix pos (T.VSelOp(decls, v1, name_str)) in
        let v  = TypeDef.op_proxy ~fix ~pos v1 xs s op n in
        let tp = T.Type.op_type xs s op in
        Some (v, tp)
      | Some (VDCtor(xs, tp, ctors, n)) ->
        let ctor = List.nth ctors n in
        let v1 = make ~fix pos (T.VSelCtor(decls, v1, name_str)) in
        let v  = TypeDef.ctor_proxy ~fix ~pos v1 xs tp ctor n in
        let tp = T.Type.ctor_type xs tp ctor in
        Some (v, tp)
      | None ->
        begin match T.Decl.select_this decls with
        | Some tp ->
          let v1 = make ~fix pos (T.VSelThis(decls, v1)) in
          begin match 
            TypeView.coerce_to_neutral_or_struct ~env ~pos:v1_pos tp
          with
          | v1_tp ->
            check_select_loop ~fix ~env ~pos ~v1_pos v1 v1_tp name
          | exception (Error.Type_error _) -> None
          end
        | None -> None
        end
      end
    end

(* ========================================================================= *)
(* Clauses *)

and check_clause : fix ->
    Env.t -> S.clause -> T.ttype ->
      (check, _) request -> (check, _) request -> T.clause =
  fun fix env cl tp0 tp_req eff_req ->
  let check_pattern env = fix.check_pattern fix env in
  let check_expr    env = fix.check_expr fix env in
  let pos = cl.meta in
  match cl.data with
  | S.Clause(pat, body) ->
    let p_resp = check_pattern env pat (Check tp0) in
    let b_resp =
      check_expr p_resp.cp_env body tp_req eff_req
      |> ExprBuilder.coerce_to_scope ~fix ~env ~pos in
    make ~fix pos (T.Clause(p_resp.cp_pattern, b_resp.ce_expr))

and check_clauses : fix ->
    Env.t -> S.clause list -> T.ttype ->
      (check, _) request -> (check, _) request -> T.clause list =
  fun fix env cls tp0 tp_req eff_req ->
  List.map (fun cl -> check_clause fix env cl tp0 tp_req eff_req) cls
