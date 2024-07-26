open Common

type field_def

val field_name : field_def -> S.name
val field_pos  : field_def -> Utils.Position.t

val check_first_def : fix: fix -> env: Env.t -> pos: Utils.Position.t ->
  S.field_def -> ('td, T.ex_type) request -> ('ed, T.effect) request ->
    (Env.t -> T.value -> T.ttype -> T.field_decl list -> field_def ->
      ('ed, T.effect) response -> (check, 'ed) checked_expr) ->
  ('td, 'ed) checked_expr

val check_rest_defs : fix: fix -> env: Env.t -> pos: Utils.Position.t ->
  S.field_def list -> T.ttype -> T.field_decl list ->
  ('ed, T.effect) request ->
    (field_def list -> T.value) -> (check, 'ed) checked_expr

val build_record : pos:Utils.Position.t ->
  T.field_decl list -> field_def list -> T.value list
