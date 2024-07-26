open Lang.Core
open Value

type t

val empty : unit -> t

val add_var  : t -> var -> value -> t
val add_inst : t -> effinst -> efftag -> t

val add_vars_p : t -> (var * value) list -> t
val add_vars   : t -> var list -> value list -> t

val lookup_var  : t -> var -> value
val lookup_inst : t -> effinst -> efftag

val find_implementation : t -> string -> value option
val add_implementation  : t -> string -> value -> unit
