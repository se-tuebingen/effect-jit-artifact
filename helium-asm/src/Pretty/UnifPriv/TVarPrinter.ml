open Lang.Unif

let rec neutral_is_tvar : type k1 k2.
    k1 tvar -> k2 neutral_type -> TVar.ex list -> bool =
  fun x neu args ->
  match neu with
  | TVar y ->
    begin match TVar.gequal x y with
    | Equal    -> true
    | NotEqual -> false
    end
  | TApp(neu, tp) ->
    begin match args with
    | [] -> false
    | TVar.Pack y :: args ->
      neutral_is_tvar x neu args && type_is_tvar y tp []
    end

and type_is_tvar : type k1 k2. k1 tvar -> k2 typ -> TVar.ex list -> bool =
  fun x tp args ->
  match Type.view tp with
  | TNeutral neu -> neutral_is_tvar x neu args
  | _ -> false

let rec type_match_tvar : type k.
    type_env -> k tvar -> TVar.ex list -> TVar.ex list -> ttype -> bool =
  fun env x req_args app_args tp ->
  let var_case tp =
    match req_args with
    | []     -> type_is_tvar x tp app_args
    | _ :: _ -> false
  in
  match Type.view tp with
  | TArrow(_, tp1, TExists(xs, tp2), eff) ->
    begin match xs, Type.row_view eff, req_args with
    | [], RPure, TVar.Pack y :: req_args when type_match_tvar env y [] [] tp1 ->
      type_match_tvar env x req_args (TVar.Pack y :: app_args) tp2
    | _ -> false
    end
  | TForall(xs, tp) ->
    let (env, xs, tp) = TypeEnv.open_type_ts env xs tp in
    type_match_tvar env x (req_args @ xs) app_args tp
  | TTypeWit(TExists([], tp)) -> var_case tp
  | TEffectWit eff            -> var_case eff
  | TEffsigWit s              -> var_case s
  | TDataDef(tp, _)           -> var_case tp
  | TRecordDef(tp, _)         -> var_case tp
  | TEffsigDef(s, _)          -> var_case s

  | TUVar _ | TBase _ | TNeutral _ | TForallInst _ | THandler _ | TStruct _
  | TTypeWit(TExists(_ :: _, _)) -> false

let rec struct_type_match_tvar : type k. type_env -> k tvar -> ttype -> _ =
  fun env x tp ->
  match Type.view tp with
  | TStruct decls -> struct_match_tvar env x decls

  | TUVar _ | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _
  | THandler _ | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _
  | TRecordDef _ | TEffsigDef _ ->
    None

and struct_match_tvar : type k. type_env -> k tvar -> decl list -> _ =
  fun env x decls ->
  match decls with
  | [] -> None
  | decl :: decls ->
    begin match decl_match_tvar env x decl with
    | Some path -> Some path
    | None -> struct_match_tvar env x decls
    end

and decl_match_tvar : type k. type_env -> k tvar -> decl -> _ =
  fun env x decl ->
  match decl with
  | DeclThis tp ->
    if type_match_tvar env x [] [] tp then
      Some []
    else
      begin match struct_type_match_tvar env x tp with
      | Some []   -> Some []
      | Some path -> Some (Box.word "this" :: path)
      | None      -> None
      end
  | DeclVal(name, tp) ->
    if type_match_tvar env x [] [] tp then
      Some [ Box.word name ]
    else
      begin match struct_type_match_tvar env x tp with
      | Some path -> Some (Box.word name :: path)
      | None      -> None
      end
  | DeclTypedef _ | DeclOp _ | DeclCtor _ | DeclField _ -> None
