(* Invariant/Explicit/WellTyped.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Internal type-checker for Explicit language *)

val check_program : Lang.Explicit.source_file -> bool

val flow_tag : Flow.tag
