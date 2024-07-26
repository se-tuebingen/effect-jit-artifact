(* Transform/Unif/ToExplicit/Type.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Translation of types and type-related contructs *)

open Common

val tr_effinst_expr : Env.t -> S.effinst_expr -> T.effinst

val tr_ctor_decl  : Env.t -> S.ctor_decl -> T.ctor_decl
val tr_field_decl : Env.t -> S.field_decl -> T.field_decl
val tr_op_decl    : Env.t -> S.op_decl -> T.op_decl

val tr_decl : Env.t -> S.decl -> T.ttype
val tr_type : Env.t -> 'k S.typ -> 'k T.typ

val tr_ex_type : Env.t -> S.ex_type -> T.ttype

val tr_type_arg : Env.t -> S.type_arg -> T.type_arg

val tr_type_instances :
  Env.t -> S.type_instance list -> Env.t * T.type_instance list
