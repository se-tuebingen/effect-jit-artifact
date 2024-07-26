open TypingStructure

let rec eta_expand : type k. k typ -> k typ =
  fun tp ->
  match Type.kind tp with
  | KType   -> tp
  | KEffect -> tp
  | KEffsig -> tp
  | KArrow(k, _) ->
    let x = TVar.fresh k in
    Type.tfun x (eta_expand (Type.app tp (Type.var x)))

let fresh_uvar env kind =
  Type.uvar (Subst.of_scope (TypeEnv.scope env)) (UVar.fresh kind)
  (* TODO: this η-expansion is a quick-hack that fixes a bug. The Unif type
  representation should work without this hack. We prefer to having
  non-η-expanded unification variables in order to not obscure pretty-printed
  types. However, having non-η-expanded unification variables is not the best
  idea, since Type.view may change radically representation of type. *)
  |> eta_expand

let op_decl_type a (OpDecl(_, xs, tps, res)) =
  let rec build_arrow nt tps =
    match tps with
    | [] -> Type.arrow ?name:nt.nt_name nt.nt_type res (Type.eff_ivar a)
    | nt' :: tps ->
      Type.arrow'
        ?name:nt.nt_name
        nt.nt_type
        (build_arrow nt' tps)
        Type.eff_pure
  in
  match tps with
  | [] -> assert false
  | nt :: tps -> Type.forall xs (build_arrow nt tps)

let op_type xs s op =
  let a = EffInst.fresh () in
  Type.forall xs (Type.forall_inst a s (op_decl_type a op))

let op_type' xs s ops n =
  op_type xs s (List.nth ops n)

let ctor_decl_type (CtorDecl(_, xs, tps)) rtp =
  Type.forall xs (List.fold_right
    (fun nt rtp -> Type.arrow' ?name:nt.nt_name nt.nt_type rtp Type.eff_pure)
    tps rtp)

let ctor_type xs tp ctor =
  Type.forall xs (ctor_decl_type ctor tp)

let ctor_type' xs tp ctors n =
  ctor_type xs tp (List.nth ctors n)

(* ========================================================================= *)
(* Restricting unification variable *)

(** restrict unification variables and substitution to not contain given
  unification variable. Returns None if domain does not have to be truncated,
  or Some sub, where sub is a identity substitution with restricted domain *)
let rec restrict_subst : type k. k uvar -> subst -> subst option =
  fun u sub ->
  let exact = ref true in
  let tsub  = TypeSubst.filter 
    { filter_f = fun x tp ->
        if try_restrict u tp then true
        else (exact := false; false)
    } sub.sub_type in
  if !exact then None
  else Some
    { sub_type = TypeSubst.map { map_f = fun x _ -> Type.var x } tsub
    ; sub_inst = EffInst.Map.mapi (fun a _ -> IEInstance a) sub.sub_inst
    }

and restrict_named_type : type k. k uvar -> named_type -> unit =
  fun u nt ->
  restrict u nt.nt_type

and restrict_op_decl : type k. k uvar -> _ -> unit =
  fun u op ->
  match op with
  | OpDecl(_, _, tps, extp) ->
    List.iter (restrict_named_type u) tps;
    restrict_ex_type u extp

and restrict_ctor_decl : type k. k uvar -> _ -> unit =
  fun u ctor ->
  match ctor with
  | CtorDecl(_, _, tps) -> List.iter (restrict_named_type u) tps

and restrict_field_decl : type k. k uvar -> _ -> unit =
  fun u fld ->
  match fld with
  | FieldDecl(_, tp) -> restrict u tp

and restrict_decl : type k. k uvar -> _ -> unit =
  fun u decl ->
  match decl with
  | DeclThis tp    -> restrict u tp
  | DeclTypedef tp -> restrict u tp
  | DeclVal(_, tp) -> restrict u tp
  | DeclOp(_, s, ops, _) ->
    restrict u s;
    List.iter (restrict_op_decl u) ops
  | DeclCtor(_, tp, ctors, _) ->
    restrict u tp;
    List.iter (restrict_ctor_decl u) ctors
  | DeclField(_, tp, flds, _) ->
    restrict u tp;
    List.iter (restrict_field_decl u) flds

and restrict : type k1 k2. k1 uvar -> k2 typ -> unit =
  fun u tp ->
  match Type.view tp with
  | TEffPure   -> ()
  | TEffInst _ -> ()
  | TEffCons(eff1, eff2) ->
    restrict u eff1;
    restrict u eff2
  | TUVar(sub, u') ->
    begin match UVar.gequal u u' with
    | Equal -> raise (Error CannotUnify)
    | NotEqual ->
      begin match restrict_subst u sub with
      | None -> ()
      | Some sub ->
        begin match World.get_uvar u' with
        | Some _ -> (* Variable has changed *)
          restrict u tp
        | None ->
          World.set_uvar u' (Type.uvar sub (UVar.clone u'))
        end
      end
    end
  | TBase _ -> ()
  | TNeutral neu -> restrict_neutral_type u neu
  | TArrow(_, tp, extp, eff) ->
    restrict u tp;
    restrict_ex_type u extp;
    restrict u eff
  | TForall(_, tp) -> restrict u tp
  | TForallInst(_, s, tp) ->
    restrict u s;
    restrict u tp
  | THandler(s, tp1, eff1, tp2, eff2) ->
    restrict u s;
    restrict_ex_type u tp1;
    restrict u eff1;
    restrict_ex_type u tp2;
    restrict u eff2
  | TFun(_, tp) ->
    restrict u tp
  | TStruct decls  -> List.iter (restrict_decl u) decls
  | TTypeWit extp  -> restrict_ex_type u extp
  | TEffectWit eff -> restrict u eff
  | TEffsigWit s   -> restrict u s
  | TDataDef(tp, ctors) ->
    restrict u tp;
    List.iter (restrict_ctor_decl u) ctors
  | TRecordDef(tp, flds) ->
    restrict u tp;
    List.iter (restrict_field_decl u) flds
  | TEffsigDef(s, ops) ->
    restrict u s;
    List.iter (restrict_op_decl u) ops

and restrict_ex_type : type k. k uvar -> ex_type -> unit =
  fun u (TExists(_, tp)) ->
  restrict u tp

and restrict_neutral_type : type k1 k2. k1 uvar -> k2 neutral_type -> unit =
  fun u neu ->
  match neu with
  | TVar _ -> ()
  | TApp(neu, tp) ->
    restrict_neutral_type u neu;
    restrict u tp

and try_restrict : type k1 k2. k1 uvar -> k2 typ -> bool =
  fun u tp ->
  World.try_bool (fun () -> restrict u tp)

(* ========================================================================= *)
(* Set of unification variables *)

let rec subst_uvars sub =
  TypeSubst.fold
    { fold_f = fun _ tp s -> UVar.Set.union (uvars tp) s }
    sub.sub_type UVar.Set.empty

and named_type_uvars nt =
  uvars nt.nt_type

and op_decl_uvars op =
  match op with
  | OpDecl(_, _, tps, extp) ->
    UVar.Set.unions (ex_type_uvars extp :: List.map named_type_uvars tps)

and ctor_decl_uvars ctor =
  match ctor with
  | CtorDecl(_, _, tps) ->
    UVar.Set.unions (List.map named_type_uvars tps)

and field_decl_uvars fld =
  match fld with
  | FieldDecl(_, tp) -> uvars tp

and decl_uvars decl =
  match decl with
  | DeclThis tp    -> uvars tp
  | DeclTypedef tp -> uvars tp
  | DeclVal(_, tp) -> uvars tp
  | DeclOp(_, s, ops, _) ->
    UVar.Set.unions (uvars s :: List.map op_decl_uvars ops)
  | DeclCtor(_, tp, ctors, _) ->
    UVar.Set.unions (uvars tp :: List.map ctor_decl_uvars ctors)
  | DeclField(_, tp, flds, _) ->
    UVar.Set.unions (uvars tp :: List.map field_decl_uvars flds)

and uvars : type k. k typ -> UVar.Set.t =
  fun tp ->
  match Type.view tp with
  | TEffPure   -> UVar.Set.empty
  | TEffInst _ -> UVar.Set.empty
  | TEffCons(eff1, eff2) -> UVar.Set.union (uvars eff1) (uvars eff2)
  | TUVar(sub, u) ->
    UVar.Set.add u (subst_uvars sub)
  | TBase _ -> UVar.Set.empty
  | TNeutral neu -> neutral_uvars neu
  | TArrow(_, tp, extp, eff) ->
    UVar.Set.unions [ uvars tp; ex_type_uvars extp; uvars eff ]
  | TForall(_, tp) -> uvars tp
  | TForallInst(_, s, tp) -> UVar.Set.union (uvars s) (uvars tp)
  | THandler(s, tp1, eff1, tp2, eff2) ->
    UVar.Set.unions
      [ uvars s
      ; ex_type_uvars tp1
      ; uvars eff1
      ; ex_type_uvars tp2
      ; uvars eff2
      ]
  | TFun(_, tp) -> uvars tp
  | TStruct decls ->
    UVar.Set.unions (List.map decl_uvars decls)
  | TTypeWit extp -> ex_type_uvars extp
  | TEffectWit eff -> uvars eff
  | TEffsigWit s   -> uvars s
  | TDataDef(tp, ctors) ->
    UVar.Set.unions (uvars tp :: List.map ctor_decl_uvars ctors)
  | TRecordDef(tp, flds) ->
    UVar.Set.unions (uvars tp :: List.map field_decl_uvars flds)
  | TEffsigDef(s, ops) ->
    UVar.Set.unions (uvars s :: List.map op_decl_uvars ops)

and neutral_uvars : type k. k neutral_type -> UVar.Set.t =
  fun neu ->
  match neu with
  | TVar _        -> UVar.Set.empty
  | TApp(neu, tp) -> UVar.Set.union (neutral_uvars neu) (uvars tp)

and ex_type_uvars (TExists(_, tp)) = uvars tp

(* ========================================================================= *)
(* Set of implicit instances *)

let rec subst_iinsts sub =
  let s1 = TypeSubst.fold
    { fold_f = fun _ tp s -> ImplicitEffInst.Set.union (iinsts tp) s }
    sub.sub_type ImplicitEffInst.Set.empty in
  EffInst.Map.fold
    (fun _ ei s -> ImplicitEffInst.Set.union (effinst_expr_iinsts ei) s)
    sub.sub_inst
    s1

and named_type_iinsts nt =
  iinsts nt.nt_type

and effinst_expr_iinsts ei =
  match EffInstExpr.view ei with
  | IEInstance _ -> ImplicitEffInst.Set.empty
  | IEImplicit i -> ImplicitEffInst.Set.singleton i

and op_decl_iinsts op =
  match op with
  | OpDecl(_, _, tps, extp) ->
    List.fold_left
      (fun s tp -> ImplicitEffInst.Set.union s (named_type_iinsts tp))
      (ex_type_iinsts extp)
      tps

and ctor_decl_iinsts ctor =
  match ctor with
  | CtorDecl(_, _, tps) ->
    List.fold_left
      (fun s tp -> ImplicitEffInst.Set.union s (named_type_iinsts tp))
      ImplicitEffInst.Set.empty
      tps

and field_decl_iinsts fld =
  match fld with
  | FieldDecl(_, tp) -> iinsts tp

and decl_iinsts decl =
  match decl with
  | DeclThis tp    -> iinsts tp
  | DeclTypedef tp -> iinsts tp
  | DeclVal(_, tp) -> iinsts tp
  | DeclOp(_, s, ops, _) ->
    List.fold_left
      (fun s op -> ImplicitEffInst.Set.union s (op_decl_iinsts op))
      (iinsts s)
      ops
  | DeclCtor(_, tp, ctors, _) ->
    List.fold_left
      (fun s ctor -> ImplicitEffInst.Set.union s (ctor_decl_iinsts ctor))
      (iinsts tp)
      ctors
  | DeclField(_, tp, flds, _) ->
    List.fold_left
      (fun s fld -> ImplicitEffInst.Set.union s (field_decl_iinsts fld))
      (iinsts tp)
      flds

and iinsts : type k. k typ -> ImplicitEffInst.Set.t =
  fun tp ->
  match Type.view tp with
  | TEffPure -> ImplicitEffInst.Set.empty
  | TEffInst ei -> effinst_expr_iinsts ei
  | TEffCons(eff1, eff2) ->
    ImplicitEffInst.Set.union (iinsts eff1) (iinsts eff2)
  | TUVar(sub, u) -> subst_iinsts sub
  | TBase _ -> ImplicitEffInst.Set.empty
  | TNeutral neu -> neutral_iinsts neu
  | TArrow(_, tp, extp, eff) ->
    ImplicitEffInst.Set.union (iinsts tp)
      (ImplicitEffInst.Set.union (ex_type_iinsts extp) (iinsts eff))
  | TForall(_, tp) -> iinsts tp
  | TForallInst(_, s, tp) ->
    ImplicitEffInst.Set.union (iinsts s) (iinsts tp)
  | THandler(s, extp1, eff1, extp2, eff2) ->
    List.fold_left ImplicitEffInst.Set.union
      (iinsts s)
      [ ex_type_iinsts extp1
      ; iinsts eff1
      ; ex_type_iinsts extp2
      ; iinsts eff2
      ]
  | TFun(_, tp)   -> iinsts tp
  | TStruct decls ->
    List.fold_left
      (fun s decl -> ImplicitEffInst.Set.union s (decl_iinsts decl))
      ImplicitEffInst.Set.empty
      decls
  | TTypeWit  extp -> ex_type_iinsts extp
  | TEffectWit eff -> iinsts eff
  | TEffsigWit s   -> iinsts s
  | TDataDef(tp, ctors) ->
    List.fold_left
      (fun s ctor -> ImplicitEffInst.Set.union s (ctor_decl_iinsts ctor))
      (iinsts tp)
      ctors
  | TRecordDef(tp, flds) ->
    List.fold_left
      (fun s fld -> ImplicitEffInst.Set.union s (field_decl_iinsts fld))
      (iinsts tp)
      flds
  | TEffsigDef(s, ops) ->
    List.fold_left
      (fun s op -> ImplicitEffInst.Set.union s (op_decl_iinsts op))
      (iinsts s)
      ops

and neutral_iinsts : type k. k neutral_type -> ImplicitEffInst.Set.t =
  fun neu ->
  match neu with
  | TVar _        -> ImplicitEffInst.Set.empty
  | TApp(neu, tp) ->
    ImplicitEffInst.Set.union (neutral_iinsts neu) (iinsts tp)

and ex_type_iinsts (TExists(_, tp)) = iinsts tp

(* ========================================================================= *)
(* Closing positive effects *)

let fresh_for_subst u sub =
  not (UVar.Set.mem u (subst_uvars sub))

let fresh_for_decl u decl =
  not (UVar.Set.mem u (decl_uvars decl))

let fresh_for_type u tp =
  not (UVar.Set.mem u (uvars tp))

let fresh_for_neutral u neu =
  not (UVar.Set.mem u (neutral_uvars neu))

let fresh_for_ex_type u extp =
  not (UVar.Set.mem u (ex_type_uvars extp))

let rec is_positive_in_effect (u : keffect uvar) (eff : effect) =
  match Type.view eff with
  | TEffPure   -> true
  | TEffInst _ -> true
  | TEffCons(eff1, eff2) ->
    is_positive_in_effect u eff1 && is_positive_in_effect u eff2
  | TUVar(sub, u)  -> fresh_for_subst u sub
  | TNeutral neu   -> fresh_for_neutral u neu

let rec is_positive_in_type (u : keffect uvar) (tp : ttype) =
  match Type.view tp with
  | TUVar(sub, u) -> fresh_for_subst u sub
  | TBase _       -> true
  | TNeutral neu  -> fresh_for_neutral u neu
  | TArrow(_, tp, extp, eff) ->
    is_negative_in_type    u tp   &&
    is_positive_in_ex_type u extp &&
    is_positive_in_effect  u eff
  | TForall(_, tp) -> is_positive_in_type u tp
  | TForallInst(_, s, tp) ->
    fresh_for_type u s && is_positive_in_type u tp
  | THandler(s, tp1, eff1, tp2, eff2) ->
    fresh_for_type         u s    &&
    is_negative_in_ex_type u tp1  &&
    fresh_for_type         u eff1 &&
    is_positive_in_ex_type u tp2  &&
    is_positive_in_effect  u eff2
  | TStruct decls ->
    List.for_all (is_positive_in_decl u) decls
  | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    fresh_for_type u tp

and is_negative_in_type (u : keffect uvar) (tp : ttype) =
  match Type.view tp with
  | TUVar(sub, u) -> fresh_for_subst u sub
  | TBase _       -> true
  | TNeutral neu  -> fresh_for_neutral u neu
  | TArrow(_, tp, extp, eff) ->
    is_positive_in_type    u tp   &&
    is_negative_in_ex_type u extp &&
    fresh_for_type u eff
  | TForall(_, tp) -> is_negative_in_type u tp
  | TForallInst(_, s, tp) ->
    fresh_for_type u s && is_negative_in_type u tp
  | THandler(s, tp1, eff1, tp2, eff2) ->
    fresh_for_type         u s    &&
    is_positive_in_ex_type u tp1  &&
    is_positive_in_effect  u eff1 &&
    is_negative_in_ex_type u tp2  &&
    fresh_for_type         u eff2
  | TStruct decls ->
    List.for_all (is_negative_in_decl u) decls
  | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    fresh_for_type u tp

and is_positive_in_ex_type (u : keffect uvar) (TExists(_, tp)) =
  is_positive_in_type u tp

and is_negative_in_ex_type (u : keffect uvar) (TExists(_, tp)) =
  is_negative_in_type u tp

and is_positive_in_decl u decl =
  match decl with
  | DeclThis tp    -> is_positive_in_type u tp
  | DeclTypedef tp -> is_positive_in_type u tp
  | DeclVal(_, tp) -> is_positive_in_type u tp
  | DeclOp _ | DeclCtor _ | DeclField _ ->
    fresh_for_decl u decl

and is_negative_in_decl u decl =
  match decl with
  | DeclThis tp    -> is_negative_in_type u tp
  | DeclTypedef tp -> is_negative_in_type u tp
  | DeclVal(_, tp) -> is_negative_in_type u tp
  | DeclOp _ | DeclCtor _ | DeclField _ ->
    fresh_for_decl u decl

let close_down_positive_l tps uvars =
  uvars |> Utils.ListExt.filter_map (fun (UVar.Pack u) ->
    match World.get_uvar u with
    | Some _ -> (* variable was already set *)
      None
    | None ->
      begin match UVar.kind u with
      | KEffect when (List.for_all (is_positive_in_type u) tps) ->
        World.set_uvar u Type.eff_pure;
        None
      | k ->
        let x = TVar.fresh k in
        World.set_uvar u (Type.var x);
        Some (TVar.Pack x)
      end)

let close_down_positive tp uvars =
  close_down_positive_l [tp] uvars
