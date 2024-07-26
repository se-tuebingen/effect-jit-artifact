(* Transform/Explicit/ToCore/Type.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(* Translation of types *)
open Common

val tr_type : Env.t -> 'k S.typ -> 'k T.typ

val tr_ctor_decl : Env.t -> S.ctor_decl -> T.ctor_decl
val tr_op_decl   : Env.t -> S.op_decl   -> T.op_decl

val tr_type_arg : Env.t -> S.type_arg -> T.type_arg

val tr_typedefs : Env.t -> S.typedef list -> Env.t * T.typedef list
