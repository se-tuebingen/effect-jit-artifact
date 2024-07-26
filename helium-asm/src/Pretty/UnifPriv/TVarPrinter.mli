open Lang.Unif

val type_match_tvar :
  type_env -> 'k tvar -> TVar.ex list -> TVar.ex list -> ttype -> bool

val struct_type_match_tvar : type_env -> 'k tvar -> ttype -> Box.t list option
