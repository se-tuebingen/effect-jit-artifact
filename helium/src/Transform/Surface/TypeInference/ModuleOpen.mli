open Common

val full_include : fix:fix -> env:Env.t -> pos:Utils.Position.t -> T.var ->
  (Env.t -> sig_field list -> ('td, 'ed) checked_expr) ->
    ('td, 'ed) checked_expr

val weak_include : fix:fix -> env:Env.t -> pos:Utils.Position.t -> T.var ->
  (Env.t -> sig_field list -> ('td, 'ed) checked_expr) ->
    ('td, 'ed) checked_expr

val full_include_sig_decls : Env.t -> T.decl list -> Env.t * T.decl list
val weak_include_sig_decls : Env.t -> T.decl list -> Env.t * T.decl list
