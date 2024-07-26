open Lang.Unif

val pretty_type    : ?toplevel:bool -> Env.t -> int -> 'k typ -> Box.t
val pretty_ex_type : ?toplevel:bool -> Env.t -> int -> ex_type -> Box.t

val pretty_row : Env.t -> effect -> Box.t
