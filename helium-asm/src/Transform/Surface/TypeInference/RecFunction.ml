open Common

type rf_source =
  { mono_var  : T.var
  ; mono_type : T.ttype
  ; rf_name   : S.name
  ; rf_args   : S.fn_arg list
  ; rf_body   : S.expr
  }

type rf_sources =
  { init_env  : Env.t
  ; inner_env : Env.t
  ; position  : Utils.Position.t
  ; sources   : rf_source list
  }

(* ========================================================================= *)

let guess_mono_type fix env (name, args, body) =
  (* TODO: we could do some extra work here, to allow polymorphic recursion *)
  let tp = T.Type.fresh_uvar (Env.type_env env) T.KType in
  let (env, x) = Env.add_var env (S.string_of_name name) tp in
  let rf =
    { mono_var  = x
    ; mono_type = tp
    ; rf_name   = name
    ; rf_args   = args
    ; rf_body   = body
    } in
  (env, rf)

let guess_mono_types fix ~env ~pos rfs =
  let init_env = env in
  let (env, srcs) = Utils.ListExt.fold_map (guess_mono_type fix) env rfs in
  { init_env  = init_env
  ; inner_env = env
  ; position  = pos
  ; sources   = srcs
  }

(* ========================================================================= *)

type rec_function =
  { rec_mono_var  : T.var
  ; rec_mono_type : T.ttype
  ; rec_name      : S.name
  ; rec_value     : T.value
  }

type rec_functions =
  { rec_funs   : rec_function list
  ; rec_pos    : Utils.Position.t
  ; poly_vars  : T.TVar.ex list
  }

let check_rec_function fix env check_function rf =
  { rec_mono_var  = rf.mono_var
  ; rec_mono_type = rf.mono_type
  ; rec_name      = rf.rf_name
  ; rec_value     = check_function env rf.rf_args rf.rf_body rf.mono_type
  }

let check_rec_functions fix rfs check_function =
  let funs = List.map
    (check_rec_function fix rfs.inner_env check_function)
    rfs.sources in
  let uvars = List.fold_left
    (fun s rf -> T.UVar.Set.union s (T.Type.uvars rf.mono_type))
    T.UVar.Set.empty
    rfs.sources in
  let uvars = T.UVar.Set.to_list
    (T.UVar.Set.diff uvars (Env.uvars rfs.init_env)) in
  let tps = List.map (fun rf -> rf.mono_type) rfs.sources in
  let gvars = T.Type.close_down_positive_l tps uvars in
  { rec_funs   = funs
  ; rec_pos    = rfs.position
  ; poly_vars  = gvars
  }

(* ========================================================================= *)

type poly_function =
  { pf_mono_var   : T.var
  ; pf_poly_var   : T.var
  ; pf_field      : sig_field
  ; pf_mono_type  : T.ttype
  ; pf_mono_value : T.value
  }

let get_sig_field pf = pf.pf_field

let create_poly_types ~fix rfs env rf =
  let poly_type = T.Type.forall rfs.poly_vars rf.rec_mono_type in
  let (env, x) = Env.add_var env (S.string_of_name rf.rec_name) poly_type in
  let pf =
    { pf_mono_var   = rf.rec_mono_var
    ; pf_poly_var   = x
    ; pf_field      = make_val ~fix rfs.rec_pos rf.rec_name x poly_type
    ; pf_mono_type  = rf.rec_mono_type
    ; pf_mono_value = rf.rec_value
    }
  in (env, pf)

let make_function ~fix ~env rfs poly_functions pf =
  let mk_type_arg (T.TVar.Pack x) = T.TpArg (T.Type.var x) in
  let make data = make ~fix rfs.rec_pos data in
  let create_mono_context rest =
    List.fold_right
      (fun pf rest ->
        make (T.ELet([], pf.pf_mono_var,
          make (T.EValue(make (T.VTypeApp(make (T.VVar pf.pf_poly_var),
            List.map mk_type_arg rfs.poly_vars)))),
          rest)))
      poly_functions
      rest
  in
  let mono_value extra_targs =
    make (T.VTypeApp(pf.pf_mono_value, List.map mk_type_arg extra_targs)) in
  let rec expand env tp extra_targs =
    begin match T.Type.view tp with
    | TArrow(_, tp1, _, _) ->
      let arg = T.Var.fresh tp1 in
      T.RFFun(pf.pf_poly_var, rfs.poly_vars @ extra_targs, arg,
        create_mono_context (
        make (T.EApp(mono_value extra_targs, make (T.VVar arg)))))

    | TForallInst(a, s, _) ->
      let b = T.EffInst.fresh () in
      T.RFInstFun(pf.pf_poly_var, rfs.poly_vars @ extra_targs, b, s,
        create_mono_context (
        make (T.EInstApp(mono_value extra_targs, T.EffInstExpr.instance b))))

    | THandler(s, tp_in, eff_in, _, _) ->
      T.RFHandler(pf.pf_poly_var, rfs.poly_vars @ extra_targs,
        s, tp_in, eff_in,
        create_mono_context (make (T.EValue(mono_value extra_targs))))

    | TForall(xs, tp) ->
      let (env, xs, tp) = Env.open_ex_type env (TExists(xs, tp)) in
      expand env tp (extra_targs @ xs)

    | TUVar _ | TBase _ | TNeutral _ | TStruct _ | TTypeWit _ | TEffectWit _
    | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
      failwith "recursive value must be a function or a handler"
    end
  in
  expand env pf.pf_mono_type []

let define_rec_functions fix env rfs cont =
  let (env, poly_functions) =
    Utils.ListExt.fold_map (create_poly_types ~fix rfs) env rfs.rec_funs in
  let res = cont env (List.map get_sig_field poly_functions) in
  { res with
    ce_expr = make ~fix rfs.rec_pos (T.EFix(
      List.map (make_function ~fix ~env rfs poly_functions) poly_functions,
      res.ce_expr))
  }
