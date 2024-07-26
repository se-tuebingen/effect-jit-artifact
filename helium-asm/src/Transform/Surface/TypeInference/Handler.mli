open Common

type handler_list

type ('td, 'ed) checked_handler =
  { op_handlers : T.op_handler list
  ; ret_clauses : T.TVar.ex list * T.clause list
  ; fin_clauses : T.TVar.ex list * T.clause list
  ; ret_type    : T.ex_type
  ; tp_resp     : ('td, T.ex_type) response
  ; eff_resp    : ('ed, T.effect) response
  }

val check_eff_inst_binder :
  fix -> Env.t -> S.eff_inst_binder -> ('d, T.effsig) request ->
    Env.t * T.effinst * ('d, T.effsig) response

val guess_inner_effect : Env.t -> ('ed, T.effect) request -> T.effect

val prepare_handlers : fix -> pos:Utils.Position.t -> env:Env.t ->
  S.handler list -> T.effsig -> handler_list * T.value * T.op_decl list

val check_handlers : fix ->
  Env.t -> T.ex_type -> T.effect -> handler_list ->
    ('td, T.ex_type) request -> ('ed, T.effect) request ->
      ('td, 'ed) checked_handler
