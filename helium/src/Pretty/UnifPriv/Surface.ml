open Lang.Unif
open Common.Prec

let is_pure_arrow (TExists(ex, _)) eff =
  match ex, Type.row_view eff with
  | [], RPure -> true
  | _ -> false

(* ========================================================================= *)

let pretty_arrow pure eff =
  if pure then Box.oper "->"
  else Box.box
    [ Box.oper "->"
    ; Box.indent 2 eff
    ]

let pretty_name name =
  if name = "this" then Box.kw "this"
  else Box.word name

let pretty_path name path =
  Box.box (pretty_name name ::
    List.map
      (fun fld -> Box.indent 1 (Box.prefix (Box.oper ".") fld))
      path)

(* ========================================================================= *)

let pretty_implicit_arrow_arg name kind =
  Box.prefix (Box.oper "'")
    (Box.paren (Box.box
      [ Box.suffix name (Box.ws (Box.oper ":"))
      ; Box.ws (Box.indent 2 (Common.pretty_kind 0 kind))
      ]))

let pretty_instance_arg name s =
  Box.paren (Box.box
    [ Box.suffix name (Box.ws (Box.oper ":"))
    ; Box.ws (Box.indent 2 s)
    ])

(* ========================================================================= *)

let pretty_effinst_expr env a =
  match EffInstExpr.view a with
  | IEInstance a -> Env.pretty_instance env a
  | IEImplicit _ -> failwith "Not implemented: implicit instance"

(* ========================================================================= *)

let rec pretty_arrow_arg env name (info : Env.var_info) tp =
  if info.var_used then
    Box.paren (Box.box
    [ Box.suffix (pretty_name name)
        (Box.ws (Box.oper ":"))
    ; Box.ws (Box.indent 2 (pretty_type env prec_annot_r tp))
    ])
  else
    pretty_type env prec_arrow_l tp

and pretty_type : type k. ?toplevel:_ -> Env.t -> int -> k typ -> Box.t =
  fun ?(toplevel=false) env prec tp ->
  match Type.view tp with
  | TEffPure   -> pretty_row env tp
  | TEffInst _ -> pretty_row env tp
  | TEffCons _ -> pretty_row env tp
  | TUVar(sub, u) ->
    Env.pretty_uvar env u
  | TBase tp ->
    (* TODO: find it in env first *)
    Box.const (Lang.RichBaseType.name tp)
  | TNeutral neu ->
    pretty_neutral env prec neu
  | TArrow(name, tp1, tp2, eff) ->
    let env0 = env in
    let name = Env.pick_fresh_name env name in
    let (env, info) = Env.add_var_with_info env name tp1 in
    let pure = is_pure_arrow tp2 eff in
    let tp2 = pretty_ex_type ~toplevel env prec_arrow_r tp2 in
    let eff = pretty_row env eff in
    Box.prec_paren prec_arrow prec (Box.box
      [ Box.suffix (pretty_arrow_arg env0 name info tp1)
          (Box.ws (pretty_arrow pure eff))
      ; Box.indent 2 (Box.ws tp2)
      ])
  | TForall(xs, tp) ->
    let (env, xs, tp) = Env.open_type_ts env xs tp in
    if toplevel then
      pretty_type ~toplevel env prec tp
    else
      let tp = pretty_type ~toplevel env prec_arrow_r tp in
      pretty_forall env prec xs tp
  | TForallInst(a, s, tp) ->
    let s = pretty_type env prec_annot_r s in
    let (env, a, name, tp) = Env.open_type_i env a tp in
    Box.prec_paren prec_arrow prec (Box.box
      [ Box.suffix (pretty_instance_arg name s)
          (Box.ws (Box.oper "->"))
      ; Box.indent 2 (Box.ws (pretty_type env prec_arrow_r tp))
      ])
  | THandler(s, tp1, eff1, tp2, eff2) ->
    Box.prec_paren prec_arrow prec (Box.box
    [ Box.box
      [ Box.box [ Box.kw "handler"; Box.ws (Box.kw "of") ]
      ; Box.ws (Box.indent 2 (pretty_type env 0 s))
      ; Box.ws (Box.kw "in") ]
    ; Box.box
      [ Box.ws (Box.indent 2 (Box.suffix (Box.box
          [ Box.suffix (pretty_ex_type env 100 tp1) (Box.ws (Box.oper "/"))
          ; Box.ws (Box.indent 2 (pretty_type env 100 eff1))
          ]) (Box.ws (Box.oper "=>"))))
      ; Box.ws (Box.indent 2 (Box.box          
          [ Box.suffix (pretty_ex_type env 100 tp2) (Box.ws (Box.oper "/"))
          ; Box.ws (Box.indent 2 (pretty_type env 100 eff2))
          ]))
      ]
    ])
  | TFun _ ->
    failwith "Not implemented: pretty printing functions"
  | TStruct decls ->
    Box.box 
      (  Box.kw "sig"
      :: List.map (fun b -> Box.ws (Box.indent 2 b)) (pretty_decls env decls)
      @[ Box.ws (Box.kw "end") ])
  | TTypeWit   _ -> Box.kw "type"
  | TEffectWit _ -> Box.kw "effect"
  | TEffsigWit _ -> Box.kw "effsig"
  | TDataDef _   -> Box.kw "type"
  | TRecordDef _ -> Box.kw "type"
  | TEffsigDef _ -> Box.kw "effsig"

and pretty_forall env prec xs tp =
  match xs with
  | [] -> Box.prec_paren prec_arrow_r prec tp
  | TVar.Pack x :: xs ->
    begin match Env.tvar_used_implicitly env x with
    | None      -> pretty_forall env prec xs tp
    | Some name ->
      Box.prec_paren prec_arrow prec (Box.box
        [ Box.suffix
            (pretty_implicit_arrow_arg name (TVar.kind x))
            (Box.ws (Box.oper "->"))
        ; Box.ws (pretty_forall env prec_arrow_r xs tp)
        ])
    end

and pretty_row : Env.t -> effect -> Box.t =
  fun env row ->
  match Type.row_view row with
  | RPure -> Box.brackets (Box.box [])
  | _ -> Box.box (pretty_nonempty_row (Box.oper "[") env row)

and pretty_nonempty_row : Box.t -> Env.t -> effect -> Box.t list =
  fun sep env row ->
  match Type.row_view row with
  | RPure -> [ Box.oper "]" ]
  | RUVar(sub, u) ->
    [ Box.prefix sep (Env.pretty_uvar env u)
    ; Box.oper "]"
    ]
  | RConsEffInst(a, row) ->
    (Box.prefix sep (pretty_effinst_expr env a)) ::
      pretty_nonempty_row (Box.oper ",") env row
  | RConsNeutral(eff, row) ->
    Box.prefix sep (pretty_neutral env prec_list_member eff) ::
      pretty_nonempty_row (Box.oper ",") env row
  | RConsUVar(sub, u, row) ->
    Box.prefix sep (Env.pretty_uvar env u) ::
      pretty_nonempty_row (Box.oper ",") env row

and pretty_neutral : type k. Env.t -> int -> k neutral_type -> Box.t =
  fun env prec neu ->
  match neu with
  | TVar x -> pretty_var env x
  | TApp(neu, tp) ->
    Box.prec_paren prec_app prec (Box.box
      [ pretty_neutral env prec_app_l neu
      ; Box.ws (Box.indent 2 (pretty_type env prec_app_r tp))
      ])

and pretty_var : type k. Env.t -> k tvar -> Box.t =
  fun env x ->
  match Env.find_var_shallow env x with
  | Some(name, info) ->
    info.var_used <- true;
    pretty_name name
  | None ->
    begin match Env.find_var_deep env x with
    | Some(name, path, info) ->
      info.var_used <- true;
      pretty_path name path
    | None -> Env.pretty_implicit_tvar env x
    end

and pretty_ex_type ?(toplevel=false) env prec (TExists(ex, tp)) =
  let (env, _, tp) = Env.open_type_ts env ex tp in
  pretty_type ~toplevel env prec tp

and pretty_decls env decls =
  match decls with
  | [] -> []
  | decl :: decls ->
    let (env, b) = pretty_decl env decl in
    b @ pretty_decls env decls

and pretty_decl env decl =
  match decl with
  | DeclThis tp ->
    let b =
      Box.box
      [ Box.box
        [ Box.kw "val"
        ; Box.suffix (Box.ws (Box.kw "this")) (Box.ws (Box.oper ":")) ]
      ; Box.ws (Box.indent 2 (pretty_type ~toplevel:true env 0 tp))
      ] in
    let (env, _) = Env.add_var_with_info env "this" tp in
    (env, [ b ])
  | DeclVal(name, tp) ->
    let b =
      Box.box
      [ Box.box
        [ Box.kw "val"
        ; Box.suffix (Box.ws (Box.word name)) (Box.ws (Box.oper ":")) ]
      ; Box.ws (Box.indent 2 (pretty_type ~toplevel:true env 0 tp))
      ] in
    let (env, _) = Env.add_var_with_info env name tp in
    (env, [ b ])
  | _ ->
    (* TODO *)
    (env, [])
