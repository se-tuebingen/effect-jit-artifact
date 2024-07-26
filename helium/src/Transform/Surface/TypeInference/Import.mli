open Common

type im_var =
  { imv_name : string
  ; imv_var  : T.var
  }

val import : Env.t -> T.import list -> Env.t * (T.var * T.import) list

val tr_import : Env.t -> Utils.Position.t -> string ->
  Env.t * (T.var * T.import) list * im_var

val tr_preamble : Env.t -> S.preamble_decl list ->
  Env.t * (T.var * T.import) list * im_var list

val imported_effect : (T.var * T.import) list -> T.effect

val open_defs  : Env.t -> S.def list
val open_decls : Env.t -> S.decl list

val add_import_vars : Env.t -> im_var list -> Env.t
