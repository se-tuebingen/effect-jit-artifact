open Lang.Node
open Common

let provided_handlers =
  Utils.ListExt.filter_map (fun p ->
    match p.data with
    | S.PDHandler eff -> Some eff
    | S.PDImport _    -> None)

let ensure_no_export_handler =
  List.iter (fun p ->
    match p.data with
    | S.PDHandler _ -> failwith "Only interface files can export handlers"
    | S.PDImport _  -> ())

(* ========================================================================= *)

let tr_direct_style_program fix env p =
  let (env, imports, imv) = Import.tr_preamble env p.S.sf_preamble in
  let res = Def.check_defs fix env (Import.open_defs env)
    Infer
    (Check (Import.imported_effect imports))
    { cd_cont = fun env _ ->
      Def.check_struct fix
        ~pos: p.S.sf_pos
        ~env: (Import.add_import_vars env imv)
        p.S.sf_defs
    }
  in
  let Infered (T.TExists(ex, tp)) = res.ce_type in
  match T.Type.view tp with
  | TStruct decls ->
    { T.sf_import = imports
    ; T.sf_body   = UB_Direct
      { types    = ex
      ; body_sig = decls
      ; body     = res.ce_expr
      }
    }
  | _ ->
    failwith "This unit does not provide a structure"

(* ========================================================================= *)

let check_direct_style_program fix env ~intf_imports ~types ~decls p =
  let (env, imports, imv) = Import.tr_preamble env p.S.sf_preamble in
  let imports = intf_imports @ imports in
  let res = Def.check_defs fix env (Import.open_defs env)
    (Check (T.TExists(types, T.Type.tstruct decls)))
    (Check (Import.imported_effect imports))
    { cd_cont = fun env _ ->
      Def.check_struct fix
        ~pos: p.S.sf_pos
        ~env: (Import.add_import_vars env imv)
        p.S.sf_defs
    }
  in
  { T.sf_import = imports
  ; T.sf_body   = UB_Direct
    { types    = types
    ; body_sig = decls
    ; body     = res.ce_expr
    }
  }

(* ========================================================================= *)

let check_cps_program fix env ~intf_imports ~types ~handle ~decls p =
  let (env, imports, imv) = Import.tr_preamble env p.S.sf_preamble in
  let imports = intf_imports @ imports in
  let cps_tp  = T.TVar.fresh KType   in
  let cps_eff = T.TVar.fresh KEffect in
  let ambient_eff = Import.imported_effect imports in
  let ambient_tp  = T.TExists([], T.Type.var cps_tp) in
  let ans_eff     = T.Type.eff_cons ambient_eff (T.Type.var cps_eff) in
  let cps_targs   = [ T.TVar.Pack cps_tp; T.TVar.Pack cps_eff ] in
  let env = Env.add_tvar_l env cps_targs in
  let cont_tp =
    T.Type.forall types (T.Type.arrow
      (T.Type.tstruct decls)
      ambient_tp
      (T.Type.eff_cons handle ans_eff)) in
  let (env, cont) = Env.add_var' env cont_tp in
  let res = Def.check_defs fix env (Import.open_defs env)
    (Check ambient_tp)
    (Check ans_eff)
    { cd_cont = fun env _ ->
      Def.check_cps_struct fix
        ~pos:  p.S.sf_pos
        ~env:  (Import.add_import_vars env imv)
        ~cont: cont
        p.S.sf_defs
    } in
  let make data = make ~fix p.S.sf_pos data in
  { T.sf_import = intf_imports @ imports
  ; T.sf_body   = UB_CPS
    { ambient_eff = ambient_eff
    ; types       = types
    ; handle      = handle
    ; body_sig    = decls
    ; body        = make (T.EValue (make (T.VTypeFun(cps_targs,
        make (T.VFn(make (T.PVar cont), res.ce_expr, ambient_tp))))))
    }
  }

(* ========================================================================= *)

let tr_program_main ff fix p =
  ensure_no_export_handler p.S.sf_preamble;
  let env = Env.empty ff in
  match FileFinder.find_corresponding_unif_sig ff with
  | NotFound -> tr_direct_style_program fix env p
  | Found(_, _, intf) ->
    let (env, intf_imports) = Import.import env intf.T.if_import in
    begin match intf.T.if_sig with
    | US_Direct body_sig ->
      check_direct_style_program fix env
        ~intf_imports: intf_imports
        ~types:        body_sig.types
        ~decls:        body_sig.body_sig
        p
    | US_CPS body_sig ->
      check_cps_program fix env
        ~intf_imports: intf_imports
        ~types:        body_sig.types
        ~handle:       body_sig.handle
        ~decls:        body_sig.body_sig
        p
    end
  | DependencyLoop loop ->
    raise (Error.dependency_loop loop)
  | FlowError state ->
    raise (Flow.Error state)

(* ========================================================================= *)

let tr_direct_style_interface fix env intf =
  let (env, imports, imv) = Import.tr_preamble env intf.S.if_preamble in
  let (env, _, _) = Decl.check_decls fix env (Import.open_decls env) in
  let env = Import.add_import_vars env imv in
  let (_, ex, decls) = Decl.check_decls fix env intf.S.if_decls in
  { T.if_import = List.map snd imports
  ; T.if_sig    = US_Direct
    { types    = ex
    ; body_sig = decls
    }
  }

let tr_cps_interface fix env intf effs =
  let (env, imports, imv) = Import.tr_preamble env intf.S.if_preamble in
  let (env, _, _) = Decl.check_decls fix env (Import.open_decls env) in
  let env = Import.add_import_vars env imv in
  let (env, ex, decls) = Decl.check_decls fix env intf.S.if_decls in
  let h_eff = List.fold_right
    (fun eff -> T.Type.eff_cons (Type.check_effect fix env eff))
    effs
    T.Type.eff_pure in
  { T.if_import = List.map snd imports
  ; T.if_sig    = US_CPS
    { types    = ex
    ; handle   = h_eff
    ; body_sig = decls
    }
  }

let tr_interface_main ff fix intf =
  let env = Env.empty ff in
  match provided_handlers intf.S.if_preamble with
  | []   -> tr_direct_style_interface fix env intf
  | effs -> tr_cps_interface fix env intf effs

(* ========================================================================= *)

let create_fix () =
  { pos_tab        = Utils.UID.Map.empty
  ; check_type     = Type.check_type
  ; check_effect   = Type.check_effect
  ; check_effsig   = Type.check_effsig
  ; check_pattern  = Pattern.check
  ; check_expr     = Expr.check
  ; check_value    = Expr.check_value
  ; check_function = Expr.check_function
  ; check_def      = Def.check
  ; check_decls    = Decl.check_decls
  ; check_repl_cmd = Repl.check_command
  }

let tr_program p =
  tr_program_main (FileFinder.default SL_User) (create_fix ()) p

let tr_interface intf =
  tr_interface_main (FileFinder.default SL_User) (create_fix ()) intf

let get_file_finder meta =
  match Flow.MetaData.get_option meta FileFinder.key with
  | Some ff -> ff
  | None    -> FileFinder.default SL_User

let source_flow_transform p meta =
  let fix = create_fix () in
  let ff  = get_file_finder meta in
  match tr_program_main ff fix p with
  | result ->
    Flow.return
      ~meta:[ Flow.Meta.Pack(CommonTags.m_position, fix.pos_tab) ]
      result
  | exception (Error.Type_error err) ->
    Flow.error
      ~node:Error.flow_node
      err

let intf_flow_transform intf meta =
  let fix = create_fix () in
  let ff  = get_file_finder meta in
  match tr_interface_main ff fix intf with
  | result -> Flow.return result
  | exception (Error.Type_error err) ->
    Flow.error
      ~node:Error.flow_node
      err

let source_flow_tag =
  Flow.register_transform
    ~source: S.flow_node
    ~target: T.flow_node
    ~name: "Surface --> Unif (type inference)"
    ~provides_tags: [ CommonTags.well_typed ]
    ~provides_meta: [ Pack CommonTags.m_position ]
    source_flow_transform

let intf_flow_tag =
  Flow.register_transform
    ~source: S.intf_flow_node
    ~target: T.intf_flow_node
    ~name: "Surface --> Unif (type inference, interface)"
    ~provides_tags: [ CommonTags.well_typed ]
    intf_flow_transform
