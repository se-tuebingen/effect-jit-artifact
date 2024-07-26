open Common

val check : fix ->
  Env.t -> S.expr -> ('td, T.ex_type) request -> ('ed, T.effect) request ->
    ('td, 'ed) checked_expr

val check_value : fix ->
  Env.t -> S.expr -> ('td, T.ttype) request -> 'td checked_value

val check_function : fix ->
  Env.t -> S.fn_arg list -> S.expr -> ('td, T.ttype) request ->
    'td checked_value
