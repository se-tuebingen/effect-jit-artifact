open Lang.Unif

type env

module Env : sig
  type t = env

  val empty : unit -> t

  val create :
    Lang.Unif.type_env -> (string * ttype) list -> (string * effinst) list -> t
end

val pretty_type    : ?toplevel:bool -> env -> int -> 'k typ -> Box.t
val pretty_ex_type : ?toplevel:bool -> env -> int -> ex_type -> Box.t

val pretty_row : env -> effect -> Box.t
