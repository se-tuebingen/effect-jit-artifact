open Common

let join (type td) (req : (td, _) request) (resp : (td, _) response) =
  match req, resp with
  | Infer, Infered x -> x
  | Check x, Checked -> x

let return_type (type td)
    ~env ~pos ~syncat (tp_req : (td, _) request) tp : (td, _) response * _ =
  match tp_req with
  | Infer     -> (Infered tp, None)
  | Check tp' -> T.World.try_exn
    begin fun () -> try
      match T.Type.coerce ~env:(Env.type_env env) tp tp' with
      | CId _ -> (Checked, None)
      | crc   -> (Checked, Some crc)
    with
    | T.Error err ->
      raise (Error.type_mismatch' ~pos ~env ~syncat tp tp' err)
    end

let return_ex_type (type td)
    ~env ~pos ~syncat (tp_req : (td, _) request) extp : (td, _) response * _ =
  match tp_req with
  | Infer       -> (Infered extp, None)
  | Check extp' ->
    begin try
      match T.ExType.coerce ~env:(Env.type_env env) extp extp' with
      | CExId _ -> (Checked, None)
      | crc     -> (Checked, Some crc)
    with
    | T.Error err ->
      raise (Error.type_mismatch ~pos ~env ~syncat extp extp' err)
    end

let return_type' ~env ~pos tp_req tp =
  return_ex_type ~env ~pos tp_req (T.TExists([], tp))

let guess_type (type td) env (tp_req : (td, _) request) : _ * (td, _) response =
  match tp_req with
  | Infer    -> 
    let tp = T.Type.fresh_uvar (Env.type_env env) T.KType in
    (tp, Infered ([], tp))
  | Check tp -> (tp, Checked)

let guess_ex_type (type td) env (tp_req : (td, _) request) :
    T.ex_type * (td, _) response =
  match tp_req with
  | Infer    ->
    let tp = T.TExists([], T.Type.fresh_uvar (Env.type_env env) T.KType) in
    (tp, Infered tp)
  | Check tp -> (tp, Checked)

let guess_effect (type ed) env (eff_req : (ed, _) request) :
    T.effect * (ed, _) response =
  match eff_req with
  | Infer ->
    let eff = T.Type.fresh_uvar (Env.type_env env) T.KEffect in
    (eff, Infered eff)
  | Check eff -> (eff, Checked)

let return_eff (type ed) ~env ~pos (eff_req : (ed, _) request) eff :
    (ed, _) response =
  match eff_req with
  | Infer      -> Infered eff
  | Check eff' ->
    begin try
      T.Type.subeffect ~env:(Env.type_env env) eff eff';
      Checked
    with
    | T.Error err ->
      raise (Error.effect_mismatch ~pos ~env eff eff' err)
    end

let merge_ex_type (type td) env
    (tp_req  : (td, _) request)
    (tp_resp : (td, _) response) : _ * (td, _) response =
  match tp_req, tp_resp with
  | Infer, Infered extp ->
    let extp = T.ExType.open_up ~env:(Env.type_env env) extp in
    (extp, Infered extp)
  | Check extp, Checked ->
    (extp, Checked)

let merge_effect (type ed) env
    (eff_req : (ed, _) request)
    (eff_resp : (ed, _) response) : _ * (ed, _) response =
  match eff_req, eff_resp with
  | Infer, Infered eff ->
    let eff = T.Type.open_effect_up ~env:(Env.type_env env) eff in
    (eff, Infered eff)
  | Check eff, Checked ->
    (eff, Checked)

let next_eff_request (type ed) env
    (eff_req : (ed, _) request)
    (eff_resp : (ed, _) response) 
    (cont : (check, _) request -> (_, check) checked_expr) :
      (_, ed) checked_expr =
  match eff_req, eff_resp with
  | Infer, Infered eff ->
    let eff = T.Type.open_effect_up ~env:(Env.type_env env) eff in
    { (cont (Check eff)) with ce_eff = Infered eff }
  | Check eff, Checked -> cont (Check eff)
