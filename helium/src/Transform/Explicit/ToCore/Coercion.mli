(* Transform/Explicit/ToCore/Coercion.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Translation of coercions *)

open Common

val coerce : Utils.UID.t -> Env.t -> S.coercion -> T.value -> T.expr
