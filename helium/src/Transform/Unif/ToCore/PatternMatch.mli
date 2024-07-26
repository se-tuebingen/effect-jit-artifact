open Common

val tr_match : 
  env: Env.t ->
  uid: Utils.UID.t ->
  typ: T.ttype ->
  bind_value: (Env.t -> S.value -> (T.value -> T.expr) -> T.expr) ->
  T.var -> (S.pattern * (Env.t -> T.expr)) list ->
    T.expr

val tr_matches :
  uid: Utils.UID.t ->
  typ: T.ttype ->
  bind_value: (Env.t -> S.value -> (T.value -> T.expr) -> T.expr) ->
  case_name: string ->
  T.var list -> (Env.t * S.pattern list * (Env.t -> T.expr)) list ->
    T.expr
