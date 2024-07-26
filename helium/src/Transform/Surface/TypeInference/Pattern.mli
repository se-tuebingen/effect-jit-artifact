open Common

type checked_patterns =
  { cps_env      : Env.t
  ; cps_exvars   : T.TVar.ex list
  ; cps_vals     : sig_field list
  ; cps_patterns : T.pattern list
  }

val check : fix ->
  Env.t -> S.pattern -> ('td, T.ttype) request -> 'td checked_pattern

val check_patterns : fix ->
  Env.t -> S.pattern list -> T.named_type list -> checked_patterns
