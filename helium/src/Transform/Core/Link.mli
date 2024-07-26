(* Transform/Core/Link.mli
 *
 * This file is part of Helium, developed under MIT license.
 * See LICENSE for details.
 *)

(** Transformation, that recursively links all imported modules of a Core unit
 * into a single unit. *)

(** Main function of the transformation *)
val tr_program : Lang.Core.source_file -> Lang.Core.source_file

(** Flow tag *)
val flow_tag : Flow.tag
