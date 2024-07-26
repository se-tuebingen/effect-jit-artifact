open Common

type td

val check_def : fix -> Env.t -> S.typedef -> Env.t * T.typedef * td

val check_rec_defs : fix -> Env.t -> S.typedef list ->
  Env.t * T.typedef list * td list

val build_typedef : fix:fix -> Env.t -> td ->
  (Env.t -> sig_field list -> ('td, 'ed) checked_expr) ->
    ('td, 'ed) checked_expr

val build_typedefs : fix:fix -> Env.t -> td list ->
  (Env.t -> sig_field list -> ('td, 'ed) checked_expr) ->
    ('td, 'ed) checked_expr

val build_typedecl  : Env.t -> td -> Env.t * T.decl list
val build_typedecls : Env.t -> td list -> Env.t * T.decl list

val tvars : T.typedef list -> T.TVar.ex list

val op_proxy : fix:fix -> pos:Utils.Position.t ->
  T.value -> T.TVar.ex list -> T.effsig -> T.op_decl -> int -> T.value

val ctor_proxy : fix:fix -> pos:Utils.Position.t ->
  T.value -> T.TVar.ex list -> T.ttype -> T.ctor_decl -> int -> T.value
