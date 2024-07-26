open Lang.Unif

type var_info =
  { mutable var_used : bool
  }

type tvar_info =
  { mutable tvar_implicit_name : Box.t option
  }

type t

val empty : unit -> t

val create :
  type_env -> (string * ttype) list -> (string * effinst) list -> t

val add_var_with_info : t -> string -> ttype -> t * var_info

val open_type_ts : t -> TVar.ex list -> ttype -> t * TVar.ex list * ttype
val open_type_i  : t -> effinst -> ttype -> t * effinst * Box.t * ttype

type path = Box.t list

val find_var_shallow : t -> 'k tvar -> (string * var_info) option
val find_var_deep    : t -> 'k tvar -> (string * path * var_info) option

val pick_fresh_name : t -> string option -> string

val pretty_uvar          : t -> 'k uvar -> Box.t
val pretty_implicit_tvar : t -> 'k tvar -> Box.t

val pretty_instance : t -> effinst -> Box.t

val tvar_used_implicitly : t -> 'k tvar -> Box.t option
