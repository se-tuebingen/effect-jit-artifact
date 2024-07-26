open Common

val check_command : fix ->
  Env.t -> S.repl_cmd -> S.expr -> T.ex_type -> T.effect -> T.expr
