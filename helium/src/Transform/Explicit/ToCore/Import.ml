(* Transform/Explicit/ToCore/Import.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Common

let tr_import env im =
  let (env, types) = Env.add_tvars env im.S.im_types in
  let handl        = Type.tr_type env im.S.im_handle in
  let sign         = List.map (Type.tr_type env) im.S.im_sig in
  let (env, var)   = Env.add_var env im.S.im_var in
  let im =
    { T.im_name   = im.S.im_name
    ; T.im_path   = im.S.im_path
    ; T.im_level  = im.S.im_level
    ; T.im_var    = var
    ; T.im_types  = types
    ; T.im_handle = handl
    ; T.im_sig    = sign
    }
  in (env, im)

let tr_imports env imps =
  List.fold_left_map tr_import env imps
