open Syntax

let typ (pat : pattern) =
  match pat.data with
  | PVar x -> Var.typ x
  | PCoerce(crc, _) -> Coercion.input_type crc
  | PCtor c -> c.typ
