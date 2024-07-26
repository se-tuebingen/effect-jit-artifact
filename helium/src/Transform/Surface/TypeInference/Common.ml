module S = Lang.Surface
module T = Lang.Unif

type check = Dummy_check
type infer = Dummy_infer

type (_, 'a) request =
| Infer : (infer, 'a) request
| Check : 'a -> (check, 'a) request

type (_, 'a) response =
| Infered : 'a -> (infer, 'a) response
| Checked : (check, 'a) response

type ('td, 'ed) checked_expr =
  { ce_expr : T.expr
  ; ce_type : ('td, T.ex_type) response
  ; ce_eff  : ('ed, T.effect) response
  }

type 'td checked_value =
  { cv_value : T.value
  ; cv_type  : ('td, T.ttype) response
  }

type sig_field = T.decl * T.struct_def

type 'td checked_pattern =
  { cp_env     : Env.t
  ; cp_exvars  : T.TVar.ex list
  ; cp_vals    : sig_field list
  ; cp_pattern : T.pattern
  (** In infer mode, we return a type of pattern and type variables
    that has to be bound before pattern, e.g. in type lambda abstraction *)
  ; cp_type    : ('td, T.TVar.ex list * T.ttype) response
  }

type check_def_cont =
  { cd_cont : 'td 'ed. Env.t -> sig_field list ->
    ('td, T.ex_type) request -> ('ed, T.effect) request ->
      ('td, 'ed) checked_expr
  }

type fix =
  { mutable pos_tab : Utils.Position.t Utils.UID.Map.t
  ; check_type      : fix -> Env.t -> S.expr -> T.ex_type
  ; check_effect    : fix -> Env.t -> S.expr -> T.effect
  ; check_effsig    : fix -> Env.t -> S.expr -> T.effsig
  ; check_pattern   : 'td. fix ->
      Env.t -> S.pattern -> ('td, T.ttype) request -> 'td checked_pattern
  ; check_expr      : 'td 'ed. fix ->
      Env.t -> S.expr -> ('td, T.ex_type) request -> ('ed, T.effect) request ->
        ('td, 'ed) checked_expr
  ; check_value     : 'td. fix -> Env.t -> S.expr -> ('td, T.ttype) request ->
      'td checked_value
  ; check_function  : 'td. fix ->
      Env.t -> S.fn_arg list -> S.expr ->
        ('td, T.ttype) request -> 'td checked_value
  ; check_def       : 'td 'ed. fix ->
      Env.t -> S.def -> ('td, T.ex_type) request -> ('ed, T.effect) request ->
        check_def_cont -> ('td, 'ed) checked_expr
  ; check_decls     : fix ->
      Env.t -> S.decl list -> Env.t * T.TVar.ex list * T.decl list
  ; check_repl_cmd  : fix ->
      Env.t -> S.repl_cmd -> S.expr -> T.ex_type -> T.effect -> T.expr
  }

let make ~fix pos data =
  let uid = Utils.UID.fresh () in
  fix.pos_tab <- Utils.UID.Map.add uid pos fix.pos_tab;
  { Lang.Node.meta = uid
  ; Lang.Node.data = data
  }

let make_val ~fix pos name x tp =
  match name.Lang.Node.data with
  | S.NameThis ->
    (T.DeclThis tp, make ~fix pos (T.SDThis(make ~fix pos (T.VVar x))))
  | _ ->
    let name = S.string_of_name name in
    (T.DeclVal(name, tp)
    , make ~fix pos (T.SDVal(name, make ~fix pos (T.VVar x))))

let merge_vals_hide vals1 vals2 =
  let vals1 = vals1 |> List.filter (fun (decl, _) ->
    not (vals2 |> List.exists (fun (decl', _) ->
      T.Decl.shadowed_by decl decl'))) in
  vals1 @ vals2

let rec merge_decls decls1 decls2 =
  match decls1 with
  | [] -> decls2
  | decl :: decls1 ->
    if List.exists (T.Decl.shadowed_by decl) decls2 then
      failwith "Multiple declarations"
    else
      decl :: merge_decls decls1 decls2
