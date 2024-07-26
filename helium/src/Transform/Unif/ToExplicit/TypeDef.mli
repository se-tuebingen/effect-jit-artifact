(* Transform/Unif/ToExplicit/TypeDef.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Translation of type definitions *)

open Common

val tr_typedefs : Env.t -> S.typedef list -> Env.t * T.typedef list
