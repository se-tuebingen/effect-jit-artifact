(* Transform/Explicit/ToCore/Main.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Common

let tr_sf_body env body =
  match body with
  | S.UB_Direct b ->
    let body = Expr.tr_expr env b.body in
    let (tp_env, types) = Env.add_tvars env b.types in
    T.UB_Direct
      { types    = types
      ; body_sig = List.map (Type.tr_type tp_env) b.body_sig
      ; body     = body
      }
  | S.UB_CPS b ->
    let body = Expr.tr_expr env b.body in
    let ambient_eff  = Type.tr_type env b.ambient_eff in
    let (env, types) = Env.add_tvars env b.types in
    T.UB_CPS
      { ambient_eff = ambient_eff
      ; types       = types
      ; handle      = Type.tr_type env b.handle
      ; body_sig    = List.map (Type.tr_type env) b.body_sig
      ; body        = body
      }

let tr_program ?(meta=Flow.MetaData.empty) (p : S.source_file) =
  let env = Env.empty meta in
  let (env, import) = Import.tr_imports env p.sf_import in
  { T.sf_import = import
  ; T.sf_body   = tr_sf_body env p.sf_body
  }

let flow_transform p meta =
  match tr_program ~meta p with
  | result -> Flow.return result
  | exception (Errors.Error err) ->
    Flow.error ~node:Errors.flow_node err

let tr_program p = tr_program p

let flow_tag =
  Flow.register_transform
    ~source: Lang.Explicit.flow_node
    ~target: Lang.Core.flow_node
    ~name: "Explicit --> Core"
    ~requires_tags:  [ CommonTags.well_typed ]
    ~provides_tags:  [ CommonTags.well_typed ]
    ~preserves_meta: [ Pack CommonTags.m_position ]
    flow_transform
