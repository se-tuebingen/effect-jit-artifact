
module Id = Common.Var (*struct
  include Common.Var
  let fresh _ =  
    let x = Common.Var.fresh () in print_string ("Fresh:" ^ Common.Var.to_string x);
      if Str.string_match (Str.regexp ".*12F") (Common.Var.to_string x) 0 then failwith "12F" else ();
      x
end*)

type tpe =
| Top
| String
| Int
| Unit

type id = V of Common.var | N of string | I of int
type var = Var of id * tpe (* TODO replace those definitions with something else if useful *)
type label = id
type tpe_tag = id
type tag = id

type clause = Clause of var list * var list * label

type literal = LInt of int | LString of string

type instruction =
| ILet       of var list * var list
| ILetConst  of var * literal
| IPrim      of var list * string * var list
| IPush      of label * var list
| IReturn    of var list
| IJump      of label * var list
| IIfZ       of var * label * var list
| IAlloc     of var * var * var
| ILoad      of var * var
| IStore     of var * var
| IShift     of var * var * var
| IPushStack of var
| INewStack  of var * var * var * label * var list
| IConstruct of var * tpe_tag * tag * var list
| IMatch     of tpe_tag * var * (tag * clause) list * clause
| IProj      of var * tpe_tag * var * tag * int
| INew       of var * tpe_tag * (tag * label) list * var list
| IInvoke    of tpe_tag * var * tag * var list

type block = Block of label * var list * instruction list
type program = Program of block list

let flow_node: program Flow.node = Flow.Node.create
  ~cmd_line_flag: "-rpyeffectasm"
  "RPyeffect assembler"

(* TODO register pretty printer *)
let string_of_tpe v = match v with
| Top -> "top"
| String -> "str"
| Int -> "int"
| Unit -> "unit"
let string_of_id v = match v with
| N(n) -> "$" ^ n
| V(v) -> "#" ^ Id.to_string v
let string_of_var v = match v with
| Var(n, t) -> string_of_id n ^ ":" ^ string_of_tpe t
let string_of_var_list l = let rec go l = match l with 
| hd :: [] -> string_of_var hd
| hd :: tl -> (string_of_var hd) ^ ", " ^ go tl
| [] -> "" in "[" ^ go l ^ "]"
