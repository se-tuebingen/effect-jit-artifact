open Common

val check_type   : fix -> Env.t -> S.expr -> T.ex_type
val check_effect : fix -> Env.t -> S.expr -> T.effect
val check_effsig : fix -> Env.t -> S.expr -> T.effsig
