open TypingStructure

type t

val save     : unit -> t
val rollback : t -> unit

val get_uvar : 'k uvar -> 'k typ option
val set_uvar : 'k uvar -> 'k typ -> unit

val get_type : 'k type_ref -> 'k type_value
val set_type : 'k type_ref -> 'k type_value -> unit

val get_effinst : implicit_effinst -> effinst_expr option
val set_effinst : implicit_effinst -> effinst_expr -> unit

val try_opt  : (unit -> 'a) -> 'a option
val try_bool : (unit -> unit) -> bool
val try_alt  : (unit -> 'a) -> (unit -> 'a) list -> 'a
val try_exn  : (unit -> 'a) -> 'a
