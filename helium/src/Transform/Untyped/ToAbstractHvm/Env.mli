open Common

type t

val empty : unit -> t
val shift : int -> t -> t
val add_local_var : t -> S.Var.t -> t
val add_local_vars : t -> S.Var.t list -> t
val lookup_var : t -> S.Var.t -> int