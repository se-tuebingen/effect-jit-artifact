open Common

val check : fix ->
  Env.t -> S.def -> ('td, T.ex_type) request -> ('ed, T.effect) request ->
    check_def_cont -> ('td, 'ed) checked_expr

val check_defs : fix ->
  Env.t -> S.def list -> ('td, T.ex_type) request -> ('ed, T.effect) request ->
    check_def_cont -> ('td, 'ed) checked_expr

val check_struct : fix -> pos:Utils.Position.t -> env:Env.t ->
  S.def list -> ('td, T.ex_type) request -> ('ed, T.effect) request ->
    ('td, 'ed) checked_expr

val check_cps_struct : fix ->
  pos:Utils.Position.t -> env:Env.t -> cont:T.var ->
  S.def list -> ('td, T.ex_type) request -> ('ed, T.effect) request ->
    ('td, 'ed) checked_expr
