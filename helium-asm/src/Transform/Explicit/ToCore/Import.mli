(* Transform/Explicit/ToCore/Import.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Translation of import metadata *)
open Common

val tr_imports : Env.t -> S.import list -> Env.t * T.import list
