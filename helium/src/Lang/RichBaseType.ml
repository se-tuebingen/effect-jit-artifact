
type lit =
| LNum    of int
| LString of string
| LChar   of char

let to_string = function
  | LNum    n   -> string_of_int n
  | LString str -> "\"" ^ String.escaped str ^ "\""
  | LChar   ch  -> "'" ^ Char.escaped ch ^ "'"

type t =
| TInt
| TString
| TChar

let equal b1 b2 =
  match b1, b2 with
  | TInt, TInt       -> true
  | TInt, _          -> false

  | TString, TString -> true
  | TString, _       -> false

  | TChar, TChar -> true
  | TChar, _     -> false

let type_of_lit = function
  | LNum    _ -> TInt
  | LString _ -> TString
  | LChar   _ -> TChar

let name = function
  | TInt    -> "Int"
  | TString -> "String"
  | TChar   -> "Char"
