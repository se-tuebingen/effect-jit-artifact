open Common

type rf_sources
type rec_functions

val guess_mono_types : fix ->
  env: Env.t ->
  pos: Utils.Position.t ->
    (S.name * S.fn_arg list * S.expr) list -> rf_sources

val check_rec_functions : fix -> rf_sources ->
  (Env.t -> S.fn_arg list -> S.expr -> T.ttype -> T.value) ->
  rec_functions

val define_rec_functions : fix -> Env.t -> rec_functions ->
  (Env.t -> sig_field list -> ('td, 'ed) checked_expr) ->
    ('td, 'ed) checked_expr
