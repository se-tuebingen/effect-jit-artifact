(* Invariant/Core/WellTyped.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Internal type-checker for Core language *)

val check_program : Lang.Core.source_file -> bool

val flow_tag : Flow.tag
