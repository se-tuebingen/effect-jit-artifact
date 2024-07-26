(* Transform/Explicit/ToCore/Main.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Transformation from Explicit to Core intermediate language *)

val tr_program : Lang.Explicit.source_file -> Lang.Core.source_file

val flow_tag : Flow.tag
