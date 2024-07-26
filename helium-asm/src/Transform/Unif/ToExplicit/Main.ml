(* Transform/Unif/ToExplicit/Main.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)

let tr_program ?(meta=Flow.MetaData.empty) (p : Lang.Unif.source_file) =
  let env = Env.empty in
  let (env, import) = Import.tr_imports env p.sf_import in
  { Lang.Explicit.sf_import = import
  ; Lang.Explicit.sf_body   =
    begin match p.sf_body with
    | UB_Direct body ->
      let (env, tvars)  = Env.add_tvars env body.types in
      UB_Direct
      { types    = tvars
      ; body_sig = List.map (Type.tr_decl env) body.body_sig
      ; body     = Expr.tr_expr env body.body
      }
    | UB_CPS body ->
      let ambient_eff  = Type.tr_type env body.ambient_eff in
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

let tr_program p = tr_program p

let flow_tag =
  Flow.register_transform
    ~source: Lang.Unif.flow_node
    ~target: Lang.Explicit.flow_node
    ~name: "Unif --> Explicit"
    ~requires_tags:  [ CommonTags.well_typed ]
    ~provides_tags:  [ CommonTags.well_typed ]
    ~preserves_meta: [ Pack CommonTags.m_position ]
    flow_transform
