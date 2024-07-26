open Common

val check_decls : fix ->
  Env.t -> S.decl list -> Env.t * T.TVar.ex list * T.decl list
