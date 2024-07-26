(* Transform/Explicit/ToCore/Type.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Common

let tr_type env tp =
  S.Type.subst (Env.to_subst env) tp

let tr_ctor_decl env ctor =
  S.Type.subst_ctor_decl (Env.to_subst env) ctor

let tr_op_decl env op =
  S.Type.subst_op_decl (Env.to_subst env) op

let tr_type_arg env (S.TpArg tp) =
  T.TpArg (tr_type env tp)

(* ========================================================================= *)

let prepare_typedef env (S.TypeDef(x, y, tp)) =
  let (env, x) = Env.add_tvar env x in
  (env, S.TypeDef(x, y, tp))

let tr_typedef env (S.TypeDef(x, y, tp)) =
  let (env, y) = Env.add_var env y in
  (env, T.TypeDef(x, y, tr_type env tp))

let tr_typedefs env tds =
  let (env, tds) = List.fold_left_map prepare_typedef env tds in
  List.fold_left_map tr_typedef env tds
