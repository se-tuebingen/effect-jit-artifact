(* Lang/ExplicitPriv/Pattern.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Oprerations on patterns *)

open Node
open Syntax

let typ p =
  match p.data with
  | PVar(_, tp) -> tp
  | PCoerce(crc, _) -> Coercion.input_type crc
  | PCtor p -> p.typ
