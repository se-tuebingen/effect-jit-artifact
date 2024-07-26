(* Transform/Unif/ToExplicit/TypeDef.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Common

type td =
| TD : 'k T.tvar * S.var -> td

let tr_typedef_pass1 env (S.TypeDef(x, z)) =
  let (env, x) = Env.add_tvar env x in
  (env, TD(x, z))

let tr_typedefs_pass1 env tds =
  List.fold_left_map tr_typedef_pass1 env tds

let tr_typedef_pass2 env (TD(x, z)) =
  let tp  = Type.tr_type env (S.Var.typ z) in
  let (env, z) = Env.add_var env z in
  (env, T.TypeDef(x, z, tp))

let tr_typedefs_pass2 env tds =
  List.fold_left_map tr_typedef_pass2 env tds

let tr_typedefs env tds =
  let (env, tds) = tr_typedefs_pass1 env tds in
  tr_typedefs_pass2 env tds
