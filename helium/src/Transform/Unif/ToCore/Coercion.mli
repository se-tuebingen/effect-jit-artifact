open Common

val coerce : Utils.UID.t -> Env.t -> S.coercion -> T.value -> T.expr

val coerce_ex : Utils.UID.t -> Env.t -> S.ex_coercion -> T.value -> T.expr
