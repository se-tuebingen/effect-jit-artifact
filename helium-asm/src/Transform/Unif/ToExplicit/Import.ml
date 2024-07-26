(* Transform/Unif/ToExplicit/Import.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Common

let tr_import env (x, im) =
  let (env, xs) = Env.add_tvars env im.S.im_types in
  let handle = Type.tr_type env im.S.im_handle in
  let decls = List.map (Type.tr_decl env) im.S.im_sig in
  let (env, x) = Env.add_var env x in
  let im =
    { T.im_name   = im.S.im_name
    ; T.im_path   = im.S.im_path
    ; T.im_level  = im.S.im_level
    ; T.im_var    = x
    ; T.im_types  = xs
    ; T.im_handle = handle
    ; T.im_sig    = decls
    } in
  (env, im)

let tr_imports env imports =
  List.fold_left_map tr_import env imports
