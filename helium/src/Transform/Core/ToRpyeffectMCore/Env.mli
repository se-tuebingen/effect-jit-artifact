
open Common

type t

val empty  : unit -> t

val add_local_var : t -> S.Var.t -> T.var -> t

val add_local_bindings : t -> S.Var.t list -> T.var list -> t


val add_inst : t -> S.EffInst.t -> T.var -> t
(*

val add_local_tuple_binding : ?offset:int -> t -> S.Var.t list -> T.var -> t
*)
val add_local_vars : t -> S.Var.t list -> T.var list -> t


val lookup_var : t -> S.Var.t -> T.var

val lookup_inst : t -> S.EffInst.t -> T.var
