open Common

(* Optimization Environment *)
type 't env = 't T.Var.Map.t
let empty = T.Var.Map.empty
let add_to_env env x elem = T.Var.Map.add x elem env
let lookup_var env x = T.Var.Map.find_opt x env
let get_var env x = T.Var.Map.find x env