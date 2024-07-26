
open Common

type t = int S.Var.Map.t

let empty () = S.Var.Map.empty
let shift n env = S.Var.Map.map (fun i -> i + n) env
let add_local_var env x = S.Var.Map.add x 0 (shift 1 env)
let add_local_vars env xs = List.fold_left add_local_var env xs
let lookup_var env x = S.Var.Map.find x env
