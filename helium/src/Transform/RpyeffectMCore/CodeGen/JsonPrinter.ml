type state = State of Buffer.t * bool
type t = state -> state
let start () = State((Buffer.create 1000), true)
let emit s st = match st with
| State(buf,_) -> Buffer.add_string buf s; st

let escape str =
  let escaped_char ch =
    match ch with
    | '"' -> "\\\""
    | '\\' -> "\\\\"
    | '\n' -> "\\n"
    | '\t' -> "\\t"
    | c -> String.make 1 c
  in
  String.concat "" (List.of_seq (Seq.map escaped_char (String.to_seq str)))
let str s = emit ("\"" ^ (escape s) ^ "\"")
let int i = emit (string_of_int i)
let (++) l r st = r (l st)
let (&) l r = l ++ (emit ",") ++ (fun st -> 
  match st with
  | State(_,true) -> emit "\n" st
  | _ -> st) ++ r
let parens o c body = (emit o) ++ body ++ (emit c)
let list = parens "[" "]"
let obj = parens "{" "}"
let (=) k v = (emit ("\"" ^ k ^ "\":")) ++ v
let stop st = match st with
| State(buf,_) ->  Buffer.contents buf
let nop = fun x -> x
let run body = stop (body (start ()))
let seq l =
  match l with
  | [] -> nop
  | hd :: tl -> List.fold_left (&) hd tl
let listof f l = list (seq (List.map f l))
let singleline body st =
  match st with
  | State(buf,old) ->
    match body (State(buf,false)) with
    | State(buf,_) -> State(buf,old)