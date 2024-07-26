open Common

(* Optimization Environment *)
type 't env

val empty : 't env
val add_to_env : 't env -> T.Var.t -> 't -> 't env
val lookup_var : 't env -> T.Var.t -> 't option
val get_var : 't env -> T.Var.t -> 't