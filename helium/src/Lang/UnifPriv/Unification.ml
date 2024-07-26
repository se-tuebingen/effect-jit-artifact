open TypingStructure
open TypeBinders
open TypeUtils

(* ========================================================================= *)
(* Unification with variable *)

let rec set_uvar : type k. subst -> k uvar -> k typ -> unit =
  fun sub u tp ->
  TypeUtils.restrict u tp;
  match World.get_uvar u with
  | None     -> World.set_uvar u tp
  | Some tp' -> (* Variable was set in the mean type, unify again *)
    unify ~scope:(Subst.scope sub) tp' tp

and unify_subst ~scope sub1 sub2 =
  let exact_match = ref true in
  let sub =
    { sub_type =
      TypeSubst.merge { merge_f = fun x tp1 tp2 ->
        match tp1, tp2 with
        | Some tp1, Some tp2 when (try_unify ~scope tp1 tp2) ->
          Some (Type.var x)
        | _ ->
          exact_match := false;
          None
        } sub1.sub_type sub2.sub_type
    ; sub_inst =
      EffInst.Map.merge (fun a a1 a2 ->
        match a1, a2 with
        | Some a1, Some a2 when (EffInstExpr.equal a1 a2) ->
          Some (IEInstance a)
        | _ ->
          exact_match := false;
          None) sub1.sub_inst sub2.sub_inst
    }
  in (sub, !exact_match)

and unify_uvars : type k. scope:_ -> _ -> k uvar -> _ -> k uvar -> unit =
  fun ~scope sub1 u1 sub2 u2 ->
  let (sub, exact_match) = unify_subst ~scope sub1 sub2 in
  if exact_match && UVar.equal u1 u2 then ()
  else begin
    let tp = Type.uvar sub (UVar.clone u1) in
    set_uvar sub1 u1 tp;
    if not (UVar.equal u1 u2) then
      set_uvar sub2 u2 tp
  end

and uvar_match_type : type k. scope:_ -> _ -> k uvar -> k typ -> unit =
  fun ~scope sub u tp ->
  match
    TypeSubst.fold { fold_f =
      fun (type k1) (x : k1 tvar) (tp' : k1 typ) (res : k tvar option) ->
      match res with
      | Some _ -> res
      | None ->
        begin match Kind.equal (TVar.kind x) (UVar.kind u) with
        | Equal when (try_unify ~scope tp tp') -> Some x
        | _ -> None
        end
      } sub.sub_type None
  with
  | None -> raise (Error CannotUnify)
  | Some x ->
    set_uvar sub u (Type.var x)

and uvar_match_effinst ~scope sub u a =
  match EffInstExpr.view a with
  | IEInstance _ ->
    begin match
      EffInst.Map.fold (fun a0 b res ->
        match res with
        | None when (EffInstExpr.equal a b) -> Some a0
        | _ -> res
      ) sub.sub_inst None
    with
    | None    -> uvar_match_type ~scope sub u (Type.eff_inst a)
    | Some a0 ->
      set_uvar sub u (Type.eff_ivar a0)
    end
  | IEImplicit _ ->
    set_uvar sub u (Type.eff_inst a)

and unify_uvar_with_neutral : type k.
  scope:_ -> _ -> k uvar -> k neutral_type -> unit =
  fun ~scope sub u neu ->
  World.try_alt (fun () -> unify_uvar_with_app ~scope sub u neu)
    [ fun () -> uvar_match_type ~scope sub u (TyNeutral neu) ]

and unify_uvar_with_app : type k.
    scope:_ -> _ -> k uvar -> k neutral_type -> unit =
  fun ~scope sub u neu ->
  match neu with
  | TVar _ -> raise (Error CannotUnify)
  | TApp(neu, tp) ->
    TypeUtils.restrict_neutral_type u neu;
    TypeUtils.restrict u tp;
    let u1 = UVar.fresh (Type.kind_of_neutral neu) in
    let u2 = UVar.fresh (Type.kind tp) in
    unify_uvar_with_neutral ~scope sub u1 neu;
    unify ~scope (Type.uvar sub u2) tp;
    let sub = Subst.domain sub in
    set_uvar sub u (Type.app (Type.uvar sub u1) (Type.uvar sub u2))

(* ========================================================================= *)
(* Row unification *)

and find_instance_in_row ~scope a eff =
  match Type.row_view eff with
  | RPure         -> raise (Error CannotUnify)
  | RUVar(sub, u) ->
    let sub' = Subst.domain sub in
    let u1 = UVar.fresh KEffect in
    let eff1 = Type.uvar sub' u1 in
    let eff2 = Type.uvar sub' (UVar.fresh KEffect) in
    set_uvar sub u (Type.eff_cons eff1 eff2);
    uvar_match_effinst ~scope sub u1 a
  | RConsEffInst(b, eff) ->
    if not (EffInstExpr.equal a b) then
      find_instance_in_row ~scope a eff
  | RConsNeutral(_, eff) | RConsUVar(_, _, eff) ->
    find_instance_in_row ~scope a eff

and find_neutral_in_row ~scope neu eff =
  match Type.row_view eff with
  | RPure -> raise (Error CannotUnify)
  | RUVar(sub, u) ->
    let sub' = Subst.domain sub in
    let u1 = UVar.fresh KEffect in
    let eff1 = (Type.uvar sub' u1) in
    let eff2 = Type.uvar sub' (UVar.fresh KEffect) in
    set_uvar sub u (Type.eff_cons eff1 eff2);
    unify_uvar_with_neutral ~scope sub u1 neu
  | RConsNeutral(neu', eff) ->
    World.try_alt (fun () -> unify_neutrals ~scope neu neu')
      [ fun () -> find_neutral_in_row ~scope neu eff ]
  | RConsEffInst(_, eff) | RConsUVar(_, _, eff) ->
    find_neutral_in_row ~scope neu eff

and find_uvar_in_row ~scope sub u eff =
  match Type.row_view eff with
  | RPure  ->
    set_uvar sub u Type.eff_pure
  | RUVar(sub', u') ->
    unify_uvars ~scope sub u sub' u'
  | RConsUVar(sub', u', eff) ->
    if UVar.equal u u' then
      unify_uvars ~scope sub u sub' u'
    else
      find_uvar_in_row ~scope sub u eff
  | RConsEffInst(_, eff) | RConsNeutral(_, eff) ->
    find_uvar_in_row ~scope sub u eff

and unify_rows ~scope tot1 tot2 eff1 eff2 =
  match Type.row_view eff1, Type.row_view eff2 with
  (* Pure base case *)
  | RPure, RPure -> ()

  (* Unification variable base cases *)
  | RPure, RUVar(sub, u) | RUVar(sub, u), RPure ->
    set_uvar sub u Type.eff_pure
  | RUVar(sub1, u1), RUVar(sub2, u2) ->
    unify_uvars ~scope sub1 u1 sub2 u2

  (* Effect instance *)
  | RConsEffInst(a, eff1), _ ->
    find_instance_in_row ~scope a tot2;
    unify_rows ~scope tot1 tot2 eff1 eff2
  | _, RConsEffInst(a, eff2) ->
    find_instance_in_row ~scope a tot1;
    unify_rows ~scope tot1 tot2 eff1 eff2

  (* Neutral effect *)
  | RConsNeutral(neu, eff1),
    (RPure | RUVar _ | RConsNeutral _ | RConsUVar _) ->
    find_neutral_in_row ~scope neu tot2;
    unify_rows ~scope tot1 tot2 eff1 eff2
  | (RPure | RUVar _ | RConsUVar _), RConsNeutral(neu, eff2) ->
    find_neutral_in_row ~scope neu tot1;
    unify_rows ~scope tot1 tot2 eff1 eff2

  (* Non-tail unification variable *)
  | RConsUVar(sub, u, eff1), (RPure | RUVar _ | RConsUVar _) ->
    find_uvar_in_row ~scope sub u tot2;
    unify_rows ~scope tot1 tot2 eff1 eff2
  | (RPure | RUVar _), RConsUVar(sub, u, eff2) ->
    find_uvar_in_row ~scope sub u tot1;
    unify_rows ~scope tot1 tot2 eff1 eff2

and unify_effects ~scope eff1 eff2 =
  unify_rows ~scope eff1 eff2 eff1 eff2

(* ========================================================================= *)
(* Main algorithm *)

and unify_named_type ~scope nt1 nt2 =
  unify ~scope nt1.nt_type nt2.nt_type

and unify_op_decl ~scope op1 op2 =
  match op1, op2 with
  | OpDecl(name1, targs1, args1, res1), OpDecl(name2, targs2, args2, res2) ->
    if name1 <> name2 then
      raise (Error CannotUnify);
    let (scope, targs, (args1, res1), (args2, res2)) =
      open_unify_ts2
        (Subst.subst_pair
          (Subst.subst_list Type.subst_named_type)
          Type.subst_ex_type)
        scope
        targs1 (args1, res1)
        targs2 (args2, res2) in
    List.iter2 (unify_named_type ~scope) args1 args2;
    unify_ex_types ~scope res1 res2

and unify_ctor_decl ~scope ctor1 ctor2 =
  match ctor1, ctor2 with
  | CtorDecl(name1, targs1, args1), CtorDecl(name2, targs2, args2) ->
    if name1 <> name2 then
      raise (Error CannotUnify)
    else
      let (scope, targs, args1, args2) =
        open_unify_ts2 (Subst.subst_list Type.subst_named_type)
          scope
          targs1 args1
          targs2 args2 in
      List.iter2 (unify_named_type ~scope) args1 args2

and unify_field_decl ~scope fld1 fld2 =
  match fld1, fld2 with
  | FieldDecl(name1, tp1), FieldDecl(name2, tp2) ->
    if name1 <> name2 then
      raise (Error CannotUnify)
    else
      unify ~scope tp1 tp2

and unify_decl ~scope decl1 decl2 =
  match decl1, decl2 with
  | DeclThis tp1, DeclThis tp2 -> unify ~scope tp1 tp2
  | DeclThis _, _ -> raise (Error CannotUnify)

  | DeclTypedef tp1, DeclTypedef tp2 -> unify ~scope tp1 tp2
  | DeclTypedef _, _ -> raise (Error CannotUnify)

  | DeclVal(name1, tp1), DeclVal(name2, tp2) ->
    if name1 <> name2 then
      raise (Error CannotUnify)
    else
      unify ~scope tp1 tp2
  | DeclVal _, _ -> raise (Error CannotUnify)

  | DeclOp(xs1, s1, ops1, n1), DeclOp(xs2, s2, ops2, n2) ->
    if n1 <> n2 || List.length ops1 <> List.length ops2 then
      raise (Error CannotUnify)
    else begin
      let (scope, xs, (s1, ops1), (s2, ops2)) =
        open_unify_ts2
          (Subst.subst_pair Type.subst (Subst.subst_list Type.subst_op_decl))
          scope
          xs1 (s1, ops1)
          xs2 (s2, ops2) in
      unify ~scope s1 s2;
      List.iter2 (unify_op_decl ~scope) ops1 ops2
    end
  | DeclOp _, _ -> raise (Error CannotUnify)

  | DeclCtor(xs1, tp1, ctors1, n1), DeclCtor(xs2, tp2, ctors2, n2) ->
    if n1 <> n2 || List.length ctors1 <> List.length ctors2 then
      raise (Error CannotUnify)
    else begin
      let (scope, xs, (tp1, ctors1), (tp2, ctors2)) =
        open_unify_ts2
          (Subst.subst_pair Type.subst
            (Subst.subst_list Type.subst_ctor_decl))
          scope
          xs1 (tp1, ctors1)
          xs2 (tp2, ctors2) in
      unify ~scope tp1 tp2;
      List.iter2 (unify_ctor_decl ~scope) ctors1 ctors2
    end
  | DeclCtor _, _ -> raise (Error CannotUnify)

  | DeclField(xs1, tp1, flds1, n1), DeclField(xs2, tp2, flds2, n2) ->
    if n1 <> n2 || List.length flds1 <> List.length flds2 then
      raise (Error CannotUnify)
    else begin
      let (scope, xs, (tp1, flds1), (tp2, flds2)) =
        open_unify_ts2
          (Subst.subst_pair Type.subst 
            (Subst.subst_list Type.subst_field_decl))
          scope
          xs1 (tp1, flds1)
          xs2 (tp2, flds2) in
      unify ~scope tp1 tp2;
      List.iter2 (unify_field_decl ~scope) flds1 flds2
    end
  | DeclField _, _ -> raise (Error CannotUnify)

and try_unify : type k. scope:_ -> k typ -> k typ -> bool =
  fun ~scope tp1 tp2 ->
  World.try_bool (fun () -> unify ~scope tp1 tp2)

and unify : type k. scope:_ -> k typ -> k typ -> unit =
  fun ~scope tp1 tp2 ->
  match Type.kind tp1 with
  | KEffect ->
    World.try_alt (fun () -> unify_no_rows ~scope tp1 tp2)
      [ fun () -> unify_effects ~scope tp1 tp2 ]
  | _ -> unify_no_rows ~scope tp1 tp2

and unify_no_rows : type k. scope:_ -> k typ -> k typ -> unit =
  fun ~scope tp1 tp2 ->
  match Type.view tp1, Type.view tp2 with
  (* variable *)
  | TUVar(sub1, u1), TUVar(sub2, u2) ->
    unify_uvars ~scope sub1 u1 sub2 u2

  (* neutral types *)
  | TUVar(sub, u), TNeutral neu
  | TNeutral neu, TUVar(sub, u) ->
    unify_uvar_with_neutral ~scope sub u neu
  | TNeutral neu1, TNeutral neu2 ->
    unify_neutrals ~scope neu1 neu2

  (* pure effect *)
  | TEffPure, _ -> unify_with_eff_pure ~scope tp2
  | _, TEffPure -> unify_with_eff_pure ~scope tp1

  (* effect instance *)
  | TEffInst a, _ -> unify_with_eff_inst ~scope a tp2
  | _, TEffInst a -> unify_with_eff_inst ~scope a tp1

  (* cons effect *)
  | TEffCons(eff1, eff2), _ -> unify_with_eff_cons ~scope eff1 eff2 tp2
  | _, TEffCons(eff1, eff2) -> unify_with_eff_cons ~scope eff1 eff2 tp1

  (* base types *)
  | TBase b, _ -> unify_with_base_type ~scope b tp2
  | _, TBase b -> unify_with_base_type ~scope b tp1

  (* arrow *)
  | TArrow(n, tp, extp, eff), _ -> unify_with_arrow ~scope n tp extp eff tp2
  | _, TArrow(n, tp, extp, eff) -> unify_with_arrow ~scope n tp extp eff tp1

  (* universal *)
  | TForall(xs, tp), _ -> unify_with_forall ~scope xs tp tp2
  | _, TForall(xs, tp) -> unify_with_forall ~scope xs tp tp1

  (* instance arrow *)
  | TForallInst(a, s, tp), _ -> unify_with_forall_inst ~scope a s tp tp2
  | _, TForallInst(a, s, tp) -> unify_with_forall_inst ~scope a s tp tp1

  (* handlers *)
  | THandler(s, extp1, eff1, extp2, eff2), _ ->
    unify_with_handler ~scope s extp1 eff1 extp2 eff2 tp2
  | _, THandler(s, extp1, eff1, extp2, eff2) ->
    unify_with_handler ~scope s extp1 eff1 extp2 eff2 tp1

  (* type function *)
  | TFun(x, tp), _ -> unify_with_fun ~scope x tp tp2
  | _, TFun(x, tp) -> unify_with_fun ~scope x tp tp1

  (* structures *)
  | TStruct decls, _ -> unify_with_struct ~scope decls tp2
  | _, TStruct decls -> unify_with_struct ~scope decls tp1

  (* type witness *)
  | TTypeWit extp, _ -> unify_with_type_wit ~scope extp tp2
  | _, TTypeWit extp -> unify_with_type_wit ~scope extp tp1

  (* effect witness *)
  | TEffectWit eff, _ -> unify_with_effect_wit ~scope eff tp2
  | _, TEffectWit eff -> unify_with_effect_wit ~scope eff tp1

  (* effsig witness *)
  | TEffsigWit s, _ -> unify_with_effsig_wit ~scope s tp2
  | _, TEffsigWit s -> unify_with_effsig_wit ~scope s tp1

  (* data definition *)
  | TDataDef(tp, ctors), _ -> unify_with_data_def ~scope tp ctors tp2
  | _, TDataDef(tp, ctors) -> unify_with_data_def ~scope tp ctors tp1

  (* record definition *)
  | TRecordDef(tp, flds), _ -> unify_with_record_def ~scope tp flds tp2
  | _, TRecordDef(tp, flds) -> unify_with_record_def ~scope tp flds tp1

  (* effsig definition *)
  | TEffsigDef(s, ops), _ -> unify_with_effsig_def ~scope s ops tp2
  | _, TEffsigDef(s, ops) -> unify_with_effsig_def ~scope s ops tp1

and unify_neutrals : type k.
    scope:_ -> k neutral_type -> k neutral_type -> unit =
  fun ~scope neu1 neu2 ->
  match neu1, neu2 with
  | TVar x1, TVar x2 ->
    if TVar.equal x1 x2 then ()
    else raise (Error CannotUnify)
  | TApp(neu1, tp1), TApp(neu2, tp2) ->
    begin match Kind.equal (Type.kind tp1) (Type.kind tp2) with
    | Equal ->
      unify_neutrals ~scope neu1 neu2;
      unify ~scope tp1 tp2
    | NotEqual -> raise (Error CannotUnify)
    end

  | TVar _, TApp _ -> raise (Error CannotUnify)
  | TApp _, TVar _ -> raise (Error CannotUnify)

and unify_ex_types : type k. scope:_ -> ex_type -> ex_type -> unit =
  fun ~scope (TExists(ex1, tp1)) (TExists(ex2, tp2)) ->
  let (scope, ex, tp1, tp2) =
    open_unify_ts2 Type.subst scope ex1 tp1 ex2 tp2 in
  unify ~scope tp1 tp2

and unify_with_eff_pure : scope:_ -> effect -> unit =
  fun ~scope r_tp ->
  match Type.view r_tp with
  | TEffPure   -> ()
  | TEffCons(eff1, eff2) ->
    unify_with_eff_pure ~scope eff1;
    unify_with_eff_pure ~scope eff2
  | TEffInst _ | TNeutral _ -> raise (Error CannotUnify)
  | TUVar(sub, u) ->
    set_uvar sub u Type.eff_pure

and unify_with_eff_inst : scope:_ -> _ -> effect -> unit =
  fun ~scope a r_tp ->
  match Type.view r_tp with
  | TEffInst b ->
    if EffInstExpr.equal a b then ()
    else raise (Error CannotUnify)
  | TEffPure | TEffCons _ | TNeutral _ -> raise (Error CannotUnify)
  | TUVar(sub, u) -> uvar_match_effinst ~scope sub u a

and unify_with_eff_cons : scope:_ -> _ -> _ -> effect -> unit =
  fun ~scope effl1 effr1 r_tp ->
  match Type.view r_tp with
  | TEffCons(effl2, effr2) ->
    (* Try opportunistic match. If it fails, unify function will do the job *)
    unify ~scope effl1 effl2;
    unify ~scope effr1 effr2
  | TEffPure ->
    unify_with_eff_pure ~scope effl1;
    unify_with_eff_pure ~scope effr1
  | TEffInst _ | TNeutral _ -> raise (Error CannotUnify)
  | TUVar(sub, u) ->
    TypeUtils.restrict u effl1;
    TypeUtils.restrict u effr1;
    let sub = Subst.domain sub in
    let effl2 = Type.uvar sub (UVar.fresh KEffect) in
    let effr2 = Type.uvar sub (UVar.fresh KEffect) in
    set_uvar sub u (Type.eff_cons effl2 effr2);
    unify_with_eff_cons ~scope effl1 effr1 r_tp

(* ------------------------------------------------------------------------- *)
and unify_with_base_type : scope:_ -> _ -> ttype -> unit =
  fun ~scope b1 r_tp ->
  match Type.view r_tp with
  | TBase b2 ->
    if RichBaseType.equal b1 b2 then ()
    else raise (Error CannotUnify)
  | TUVar(sub, u) ->
    set_uvar sub u (Type.base b1)
  | TNeutral _ | TArrow _ | TForall _ | TForallInst _ | THandler _ | TStruct _
  | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
and unify_with_arrow : scope:_ -> _ -> _ -> _ -> _ -> ttype -> unit =
  fun ~scope name tp1 extp1 eff1 r_tp ->
  match Type.view r_tp with
  | TArrow(_, tp2, extp2, eff2) ->
    unify ~scope tp1 tp2;
    unify_ex_types ~scope extp1 extp2;
    unify ~scope eff1 eff2
  | TUVar(sub, u) ->
    (* We instantiate u with small arrow type *)
    TypeUtils.restrict u tp1;
    TypeUtils.restrict_ex_type u extp1;
    TypeUtils.restrict u eff1;
    uvar_match_arrow ?name sub u;
    unify_with_arrow ~scope name tp1 extp1 eff1 r_tp
  | TBase _ | TNeutral _ | TForall _ | TForallInst _ | THandler _ | TStruct _
  | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

and uvar_match_arrow ?name sub u =
  let sub  = Subst.domain sub in
  let tp   = Type.uvar sub (UVar.fresh KType) in
  let extp = TExists([], Type.uvar sub (UVar.fresh KType)) in
  let eff  = Type.uvar sub (UVar.fresh KEffect) in
  set_uvar sub u (Type.arrow ?name tp extp eff)

(* ------------------------------------------------------------------------- *)
and unify_with_forall : scope:_ -> _ -> _ -> ttype -> unit =
  fun ~scope xs1 tp1 r_tp ->
  match Type.view r_tp with
  | TForall(xs2, tp2) ->
    let (scope, xs, tp1, tp2) =
      open_unify_ts2 Type.subst scope xs1 tp1 xs2 tp2 in
    unify ~scope tp1 tp2
  | TUVar _ -> (* type is too large *)
    raise (Error CannotUnify)
  | TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _ | TStruct _
  | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
and unify_with_forall_inst : scope:_ -> _ -> _ -> _ -> ttype -> unit =
  fun ~scope a1 s1 tp1 r_tp ->
  match Type.view r_tp with
  | TForallInst(a2, s2, tp2) ->
    unify ~scope s1 s2;
    let (scope, a, tp1, tp2) = open_i2 Type.subst scope a1 tp1 a2 tp2 in
    unify ~scope tp1 tp2
  | TUVar(sub, u) ->
    TypeUtils.restrict u s1;
    TypeUtils.restrict u tp1;
    uvar_match_forall_inst sub u;
    unify_with_forall_inst ~scope a1 s1 tp1 r_tp
  | TBase _ | TNeutral _ | TArrow _ | TForall _ | THandler _ | TStruct _
  | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

and uvar_match_forall_inst sub u =
  let sub = Subst.domain sub in
  let a   = EffInst.fresh () in
  let s   = Type.uvar sub (UVar.fresh KEffsig) in
  let tp  = Type.uvar (Subst.add_effinst sub a) (UVar.fresh KType) in
  set_uvar sub u (Type.forall_inst a s tp)

(* ------------------------------------------------------------------------- *)

and unify_with_handler : scope:_ ->
    effsig -> _ -> effect -> _ -> effect -> ttype -> unit =
  fun ~scope s extp1 eff1 extp2 eff2 r_tp ->
  match Type.view r_tp with
  | THandler(s', extp1', eff1', extp2', eff2') ->
    unify ~scope s s';
    unify_ex_types ~scope extp1' extp1;
    unify ~scope eff1' eff1;
    unify_ex_types ~scope extp2 extp2';
    unify ~scope eff2 eff2'
  | TUVar(sub, u) ->
    TypeUtils.restrict u s;
    TypeUtils.restrict_ex_type u extp1;
    TypeUtils.restrict u eff1;
    TypeUtils.restrict_ex_type u extp2;
    TypeUtils.restrict u eff2;
    uvar_match_handler sub u;
    unify_with_handler ~scope s extp1 eff1 extp2 eff2 r_tp
  | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _ | TStruct _
  | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

and uvar_match_handler sub u =
  let sub = Subst.domain sub in
  let s = Type.uvar sub (UVar.fresh KEffsig) in
  let extp1 = TExists([], Type.uvar sub (UVar.fresh KType)) in
  let eff1  = Type.uvar sub (UVar.fresh KEffect) in
  let extp2 = TExists([], Type.uvar sub (UVar.fresh KType)) in
  let eff2  = Type.uvar sub (UVar.fresh KEffect) in
  set_uvar sub u (Type.handler s extp1 eff1 extp2 eff2)

(* ------------------------------------------------------------------------- *)
and unify_with_fun : type k1 k2.
    scope:_ -> k1 tvar -> k2 typ -> (k1 -> k2) typ -> unit =
  fun ~scope x1 tp1 r_tp ->
  match Type.view r_tp with
  | TFun(x2, tp2) ->
    let (scope, x, tp1, tp2) = open_t2 Type.subst scope x1 tp1 x2 tp2 in
    unify ~scope tp1 tp2
  | TUVar(sub, u) ->
    TypeUtils.restrict u tp1;
    let sub = Subst.domain sub in
    let x2  = TVar.clone x1 in
    let tp2 = Type.uvar (Subst.add_tvar sub x2) (UVar.fresh (Type.kind tp1)) in
    set_uvar sub u (Type.tfun x2 tp2);
    unify_with_fun ~scope x1 tp1 r_tp
  | TNeutral neu ->
    (* eta-exapand, and continue *)
    let x2 = TVar.clone x1 in
    unify_with_fun ~scope x1 tp1
      (Type.tfun x2 (Type.neu_app neu (Type.var x2)))

and unify_with_struct : scope:_ -> _ -> ttype -> unit =
  fun ~scope decls1 r_tp ->
  match Type.view r_tp with
  | TStruct decls2 ->
    if List.length decls1 <> List.length decls2 then
      raise (Error CannotUnify)
    else
      List.iter2 (unify_decl ~scope) decls1 decls2
  | TUVar(sub, u) ->
    (* TODO: structures are considered large. Maybe, we could allow stuctures
    with small elements only. *)
    raise (Error CannotUnify)
  | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _ | THandler _
  | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
and unify_with_type_wit : scope:_ -> _ -> ttype -> unit =
  fun ~scope extp1 r_tp ->
  match Type.view r_tp with
  | TTypeWit extp2 -> unify_ex_types ~scope extp1 extp2
  | TUVar(sub, u) ->
    TypeUtils.restrict_ex_type u extp1;
    uvar_match_type_wit sub u;
    unify_with_type_wit ~scope extp1 r_tp
  | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _ | THandler _
  | TStruct _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

and uvar_match_type_wit sub u =
  let sub = Subst.domain sub in
  let tp  = Type.uvar sub (UVar.fresh KType) in
  set_uvar sub u (Type.type_wit (TExists([], tp)))

(* ------------------------------------------------------------------------- *)
and unify_with_effect_wit : scope:_ -> _ -> ttype -> unit =
  fun ~scope eff1 r_tp ->
  match Type.view r_tp with
  | TEffectWit eff2 -> unify ~scope eff1 eff2
  | TUVar(sub, u) ->
    TypeUtils.restrict u eff1;
    uvar_match_effect_wit sub u;
    unify_with_effect_wit ~scope eff1 r_tp
  | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _ | THandler _
  | TStruct _ | TTypeWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

and uvar_match_effect_wit sub u =
  let sub = Subst.domain sub in
  let eff = Type.uvar sub (UVar.fresh KEffect) in
  set_uvar sub u (Type.effect_wit eff)

(* ------------------------------------------------------------------------- *)
and unify_with_effsig_wit : scope:_ -> _ -> ttype -> unit =
  fun ~scope s1 r_tp ->
  match Type.view r_tp with
  | TEffsigWit s2 -> unify ~scope s1 s2
  | TUVar(sub, u) ->
    TypeUtils.restrict u s1;
    uvar_match_effsig_wit sub u;
    unify_with_effsig_wit ~scope s1 r_tp
  | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _ | THandler _
  | TStruct _ | TTypeWit _ | TEffectWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

and uvar_match_effsig_wit sub u =
  let sub = Subst.domain sub in
  let s = Type.uvar sub (UVar.fresh KEffsig) in
  set_uvar sub u (Type.effsig_wit s)

and unify_with_data_def : scope:_ -> _ -> _ -> ttype -> unit =
  fun ~scope tp1 ctors1 r_tp ->
  match Type.view r_tp with
  | TDataDef(tp2, ctors2) ->
    if List.length ctors1 <> List.length ctors2 then
      raise (Error CannotUnify);
    unify ~scope tp1 tp2;
    List.iter2 (unify_ctor_decl ~scope) ctors1 ctors2
  | TUVar _ -> (* Type definitions are considered large *)
    raise (Error CannotUnify)
  | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _ | THandler _
  | TStruct _ | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

and unify_with_record_def : scope:_ -> _ -> _ -> ttype -> unit =
  fun ~scope tp1 flds1 r_tp ->
  match Type.view r_tp with
  | TRecordDef(tp2, flds2) ->
    if List.length flds1 <> List.length flds2 then
      raise (Error CannotUnify);
    unify ~scope tp1 tp2;
    List.iter2 (unify_field_decl ~scope) flds1 flds2
  | TUVar _ -> (* Type definitions are considered large *)
    raise (Error CannotUnify)
  | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _ | THandler _
  | TStruct _ | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)

and unify_with_effsig_def : scope:_ -> _ -> _ -> ttype -> unit =
  fun ~scope s1 ops1 r_tp ->
  match Type.view r_tp with
  | TEffsigDef(s2, ops2) ->
    if List.length ops1 <> List.length ops2 then
      raise (Error CannotUnify);
    unify ~scope s1 s2;
    List.iter2 (unify_op_decl ~scope) ops1 ops2
  | TUVar _ -> (* Type definitions are considered large *)
    raise (Error CannotUnify)
  | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _ | THandler _
  | TStruct _ | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _
  | TRecordDef _ ->
    raise (Error CannotUnify)
