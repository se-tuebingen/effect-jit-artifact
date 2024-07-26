open Lang.Unif

type error =
| NoScopeForEffInst of effsig
| EscapingEffInst   of Utils.Position.t * effsig * error_reason

exception Error of error

type t

val enter : t option -> type_env -> t
val leave : t -> unit

val cur_effinsts : t -> implicit_effinst list
val all_effinsts : t -> implicit_effinst list

val create_implicit_instance :
  t -> Utils.Position.t -> effsig -> implicit_effinst

val pick_generalizable : t -> ImplicitEffInst.Set.t -> implicit_effinst list
