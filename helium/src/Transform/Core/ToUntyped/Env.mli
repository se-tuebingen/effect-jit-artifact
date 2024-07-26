
open Common

type t

val empty  : unit -> t

val add_local_var : t -> S.Var.t -> T.Var.t -> t

val add_inst : t -> S.EffInst.t -> T.Var.t -> t

val add_local_recursive_binding : t -> S.Var.t list -> T.Var.t -> t

val add_local_tuple_binding : ?offset:int -> t -> S.Var.t list -> T.Var.t -> t

val add_local_vars : t -> S.Var.t list -> T.Var.t list -> t


val lookup_var : t -> S.Var.t -> T.var

val lookup_inst : t -> S.EffInst.t -> T.identifier
