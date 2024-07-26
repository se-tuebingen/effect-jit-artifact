(* Transform/Unif/ToExplicit/Coercion.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Translation of coercions *)

open Common

val tr_coercion : Env.t -> S.coercion -> T.coercion

val tr_ex_coercion : Env.t -> S.ex_coercion -> T.coercion
