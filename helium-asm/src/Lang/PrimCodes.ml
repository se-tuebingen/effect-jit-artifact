type prim_code =
| Add | Sub | Mult
| Div | Mod | Eq
| Neq | Lt  | Le
| Gt  | Ge  | And
| Or  | Xor | Lsl
| Lsr | Asr | Neg
| Not | ExitWith
| AddConst of int
| SubConst of int
| SubFromConst of int
| MultByConst of int
| DivByConst of int
| DivConstBy of int
| ModByConst of int
| ModConstBy of int
| EqConst of int
| NeqConst of int
| LtConst of int
| LeConst of int
| GtConst of int
| GeConst of int
| AndConst of int
| OrConst of int
| XorConst of int
| LslConst of int
| LsrConst of int
| AsrConst of int

let to_string = function
  | Add  -> "Add"
  | Sub  -> "Sub"
  | Mult -> "Mult"
  | Div  -> "Div"
  | Mod  -> "Mod"
  | Eq   -> "Eq"
  | Neq  -> "Neq"
  | Lt   -> "Lt"
  | Le   -> "Le"
  | Gt   -> "Gt"
  | Ge   -> "Ge"
  | And  -> "And"
  | Or   -> "Or"
  | Xor  -> "Xor"
  | Lsl  -> "Lsl"
  | Lsr  -> "Lsr"
  | Asr  -> "Asr"
  | Neg  -> "Neg"
  | Not  -> "Not"
  | ExitWith -> "ExitWith"
  | AddConst n     -> "AddConst " ^ string_of_int n
  | SubConst n     -> "SubConst " ^ string_of_int n
  | SubFromConst n -> "SubFromConst " ^ string_of_int n
  | MultByConst n  -> "MultByConst " ^ string_of_int n
  | DivByConst n   -> "DivByConst " ^ string_of_int n
  | DivConstBy n   -> "DivConstBy " ^ string_of_int n
  | ModByConst n   -> "ModByConst " ^ string_of_int n
  | ModConstBy n   -> "ModConstBy " ^ string_of_int n
  | EqConst n      -> "EqConst " ^ string_of_int n
  | NeqConst n     -> "NeqConst " ^ string_of_int n
  | LtConst n      -> "LtConst " ^ string_of_int n
  | LeConst n      -> "LeConst " ^ string_of_int n
  | GtConst n      -> "GtConst " ^ string_of_int n
  | GeConst n      -> "GeConst " ^ string_of_int n
  | AndConst n     -> "AndConst " ^ string_of_int n
  | OrConst n      -> "OrConst " ^ string_of_int n
  | XorConst n     -> "XorConst " ^ string_of_int n
  | LslConst n     -> "LslConst " ^ string_of_int n
  | LsrConst n     -> "LsrConst " ^ string_of_int n
  | AsrConst n     -> "AsrConst " ^ string_of_int n
