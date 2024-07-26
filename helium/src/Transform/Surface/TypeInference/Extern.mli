open Common

val check :
  fix:fix ->
  env:Env.t ->
  pos:Utils.Position.t ->
    string S.node -> ('td, T.ttype) request -> 'td checked_value
