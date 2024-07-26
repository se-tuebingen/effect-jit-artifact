
let tr_program ?(meta=Flow.MetaData.empty) (p : Lang.Unif.source_file) =
  let env = Env.empty meta in
  let (env, import) = Import.tr_imports env p.sf_import in
  { Lang.Core.sf_import = import
  ; Lang.Core.sf_body   =
    begin match p.sf_body with
    | UB_Direct body ->
      let (env, tvars)  = Env.add_tvars env body.types in
      UB_Direct
      { types    = tvars
      ; body_sig = List.map (Type.tr_decl env) body.body_sig
      ; body     = Expr.tr_expr env body.body
      }
    | UB_CPS body ->
      let ambient_eff = Type.tr_type env body.ambient_eff in
      let (env, tvars) = Env.add_tvars env body.types in
      UB_CPS
      { ambient_eff = ambient_eff
      ; types       = tvars
      ; handle      = Type.tr_type env body.handle
      ; body_sig    = List.map (Type.tr_decl env) body.body_sig
      ; body        = Expr.tr_expr env body.body
      }
    end
  }

let flow_transform p meta =
  match tr_program ~meta p with
  | result -> Flow.return result
  | exception (Errors.Error err) ->
    Flow.error ~node:Errors.flow_node err

let tr_program p = tr_program p

let flow_tag =
  Flow.register_transform
    ~source: Lang.Unif.flow_node
    ~target: Lang.Core.flow_node
    ~name: "Unif --> Core"
    ~requires_tags:  [ CommonTags.well_typed ]
    ~provides_tags:  [ CommonTags.well_typed ]
    ~preserves_meta: [ Pack CommonTags.m_position ]
    ~weight: 10.0
    flow_transform
