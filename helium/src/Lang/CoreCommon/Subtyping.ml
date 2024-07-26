(* Lang/CoreCommon/Subtyping.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Subtyping and related functions
 *
 * This is internal module that implements part of an interface exposed by
 * CoreTypes.Impl module *)

open TypingStructure

let rec tvars_equal ~sub1 ~sub2 xs1 xs2 =
  match xs1, xs2 with
  | [], [] -> Some(sub1, sub2)
  | TVar.Pack x1 :: xs1, TVar.Pack x2 :: xs2 ->
    begin match Kind.equal (TVar.kind x1) (TVar.kind x2) with
    | Equal ->
      let x = TVar.clone x1 in
      tvars_equal
        ~sub1: (Subst.add_type sub1 x1 (Type.var x))
        ~sub2: (Subst.add_type sub2 x2 (Type.var x))
        xs1 xs2
    | NotEqual -> None
    end
  | [], _ :: _ | _ :: _, [] -> None

let rec subeffect (eff1 : effect) (eff2 : effect) =
  match Type.view eff1 with
  | TEffPure -> true
  | TEffCons(effa, effb) ->
    subeffect effa eff2 && subeffect effb eff2
  | TEffInst _ | TNeutral _ | TFuture _ ->
    begin match Type.view eff2 with
    | TEffPure -> false
    | TEffCons(effa, effb) ->
      subeffect eff1 effa || subeffect eff1 effb
    | TEffInst _ | TNeutral _ | TFuture _ ->
      equal eff1 eff2
    end

and effect_equal (eff1 : effect) (eff2 : effect) =
  subeffect eff1 eff2 && subeffect eff2 eff1

and type_arg_equal (TpArg tp1) (TpArg tp2) =
  match Kind.equal (Type.kind tp1) (Type.kind tp2) with
  | Equal -> equal tp1 tp2
  | NotEqual -> false

and ctor_decl_equal ctor1 ctor2 =
  match ctor1, ctor2 with
  | CtorDecl(name1, xs1, tps1), CtorDecl(name2, xs2, tps2) ->
    begin match tvars_equal ~sub1:Subst.empty ~sub2:Subst.empty xs1 xs2 with
    | None -> false
    | Some(sub1, sub2) ->
      name1 = name2 &&
      List.length tps1 = List.length tps2 &&
      List.for_all2 equal
        (List.map (Type.subst sub1) tps1)
        (List.map (Type.subst sub2) tps2)
    end

and field_decl_equal fld1 fld2 =
  match fld1, fld2 with
  | FieldDecl(name1, tp1), FieldDecl(name2, tp2) ->
    name1 = name2 && equal tp1 tp2

and op_decl_equal op1 op2 =
  match op1, op2 with
  | OpDecl(name1, xs1, tps1, tp1), OpDecl(name2, xs2, tps2, tp2) ->
    begin match tvars_equal ~sub1:Subst.empty ~sub2:Subst.empty xs1 xs2 with
    | None -> false
    | Some(sub1, sub2) ->
      name1 = name2 &&
      List.length tps1 = List.length tps2 &&
      List.for_all2 equal
        (List.map (Type.subst sub1) tps1)
        (List.map (Type.subst sub2) tps2) &&
      equal (Type.subst sub1 tp1) (Type.subst sub2 tp2)
    end

and equal : type k. k typ -> k typ -> bool =
  fun tp1 tp2 ->
  match Type.view tp1, Type.view tp2 with
  | TEffPure, _   -> effect_equal tp1 tp2
  | TEffCons _, _ -> effect_equal tp1 tp2
  | _, TEffPure   -> effect_equal tp1 tp2
  | _, TEffCons _ -> effect_equal tp1 tp2

  | TEffInst a, TEffInst b -> EffInst.equal a b
  | TEffInst _, _ -> false

  | TBase b1, TBase b2 -> RichBaseType.equal b1 b2
  | TBase _, _ -> false

  | TNeutral neu1, TNeutral neu2 -> neutral_equal neu1 neu2
  | TNeutral neu1, TFun(x, tp) ->
    let y = TVar.clone x in
    equal
      (TyNeutral (TApp(neu1, Type.var y)))
      (Type.subst_type x (Type.var y) tp)
  | TFun(x, tp), TNeutral neu2 ->
    let y = TVar.clone x in
    equal
      (Type.subst_type x (Type.var y) tp)
      (TyNeutral (TApp(neu2, Type.var y)))
  | TFun(x1, tp1), TFun(x2, tp2) ->
    if TVar.equal x1 x2 then equal tp1 tp2
    else
      let x = TVar.clone x1 in
      equal
        (Type.subst_type x1 (Type.var x) tp1)
        (Type.subst_type x2 (Type.var x) tp2)
  | TFun _, TFuture _ -> false
  | TNeutral _, _ -> false

  | TTuple tps1, TTuple tps2 ->
    List.length tps1 = List.length tps2 &&
    List.for_all2 equal tps1 tps2
  | TTuple _, _ -> false

  | TArrow(ta1, tb1, eff1), TArrow(ta2, tb2, eff2) ->
    equal ta2 ta1 && equal tb1 tb2 && effect_equal eff1 eff2
  | TArrow _, _ -> false

  | TForall(x1, tp1), TForall(x2, tp2) ->
    begin match Kind.equal (TVar.kind x1) (TVar.kind x2) with
    | Equal ->
      if TVar.equal x1 x2 then equal tp1 tp2
      else
        let x = TVar.clone x1 in
        equal
          (Type.subst_type x1 (Type.var x) tp1)
          (Type.subst_type x2 (Type.var x) tp2)
    | NotEqual -> false
    end
  | TForall _, _ -> false

  | TExists(x1, tp1), TExists(x2, tp2) ->
    begin match Kind.equal (TVar.kind x1) (TVar.kind x2) with
    | Equal ->
      if TVar.equal x1 x2 then equal tp1 tp2
      else
        let x = TVar.clone x1 in
        equal
          (Type.subst_type x1 (Type.var x) tp1)
          (Type.subst_type x2 (Type.var x) tp2)
    | NotEqual -> false
    end
  | TExists _, _ -> false

  | TForallInst(a1, s1, tp1), TForallInst(a2, s2, tp2) ->
    equal s1 s2 && begin
      if EffInst.equal a1 a2 then equal tp1 tp2
      else
        let a = EffInst.clone a1 in
        equal
          (Type.subst_inst a1 a tp1)
          (Type.subst_inst a2 a tp2)
    end
  | TForallInst _, _ -> false

  | TDataDef(tp1, ctors1), TDataDef(tp2, ctors2) ->
    List.length ctors1 = List.length ctors2 &&
    equal tp1 tp2 &&
    List.for_all2 ctor_decl_equal ctors1 ctors2
  | TDataDef _, _ -> false

  | TRecordDef(tp1, flds1), TRecordDef(tp2, flds2) ->
    List.length flds1 = List.length flds2 &&
    equal tp1 tp2 &&
    List.for_all2 field_decl_equal flds1 flds2
  | TRecordDef _, _ -> false

  | TEffsigDef(s1, ops1), TEffsigDef(s2, ops2) ->
    List.length ops1 = List.length ops2 &&
    equal s1 s2 &&
    List.for_all2 op_decl_equal ops1 ops2
  | TEffsigDef _, _ -> false

  | TFuture fut1, TFuture fut2 ->
    Utils.UID.equal fut1.uid fut2.uid &&
    List.length fut1.tholes = List.length fut2.tholes &&
    List.length fut1.eholes = List.length fut2.eholes &&
    List.for_all2 type_arg_equal fut1.tholes fut2.tholes &&
    List.for_all2 EffInst.equal fut1.eholes fut2.eholes
  | TFuture _, _ -> false

and neutral_equal : type k. k neutral_type -> k neutral_type -> bool =
  fun neu1 neu2 ->
  match neu1, neu2 with
  | TVar x1, TVar x2 -> TVar.equal x1 x2
  | TApp(neu1, tp1), TApp(neu2, tp2) ->
    begin match
      Kind.equal (Type.neutral_kind neu1) (Type.neutral_kind neu2)
    with
    | Equal ->
      neutral_equal neu1 neu2 && equal tp1 tp2
    | NotEqual -> false
    end
  | TVar _, TApp _ -> false
  | TApp _, TVar _ -> false

(* ========================================================================= *)

let rec eff_cons (eff1 : effect) (eff2 : effect) =
  match Type.view eff1 with
  | TEffPure -> eff2
  | TEffCons(effa, effb) ->
    eff_cons effa (eff_cons effb eff2)
  | TEffInst _ | TNeutral _ | TFuture _ ->
    if subeffect eff1 eff2 then eff2
    else TyEffCons(eff1, eff2)

(* ========================================================================= *)
let rec subtype (tp1 : ttype) (tp2 : ttype) =
  match Type.view tp1, Type.view tp2 with
  | TBase _, TBase _ -> equal tp1 tp2
  | TBase _,
    (TNeutral _ | TTuple _ | TArrow _ | TForall _ | TExists _ | TForallInst _
    | TDataDef _ | TRecordDef _ | TEffsigDef _ | TFuture _) -> false

  | TNeutral _, TNeutral _ -> equal tp1 tp2
  | TNeutral _,
    (TBase _ | TTuple _ | TArrow _ | TForall _ | TExists _ | TForallInst _
    | TDataDef _ | TRecordDef _ | TEffsigDef _ | TFuture _) -> false

  | TTuple tps1, TTuple tps2 ->
    List.length tps1 = List.length tps2 &&
    List.for_all2 subtype tps1 tps2
  | TTuple _,
    (TBase _ | TNeutral _ | TArrow _ | TForall _ | TExists _ | TForallInst _
    | TDataDef _ | TRecordDef _ | TEffsigDef _ | TFuture _) -> false

  | TArrow(ta1, tb1, eff1), TArrow(ta2, tb2, eff2) ->
    subtype ta2 ta1 && subtype tb1 tb2 && subeffect eff1 eff2
  | TArrow _,
    (TBase _ | TNeutral _ | TTuple _ | TForall _ | TExists _ | TForallInst _
    | TDataDef _ | TRecordDef _ | TEffsigDef _ | TFuture _) -> false

  | TForall(x1, tp1), TForall(x2, tp2) ->
    begin match Kind.equal (TVar.kind x1) (TVar.kind x2) with
    | Equal ->
      if TVar.equal x1 x2 then subtype tp1 tp2
      else
        let x = TVar.clone x1 in
        subtype
          (Type.subst_type x1 (Type.var x) tp1)
          (Type.subst_type x2 (Type.var x) tp2)
    | NotEqual -> false
    end
  | TForall _,
    (TBase _ | TNeutral _ | TTuple _ | TArrow _ | TExists _ | TForallInst _
    | TDataDef _ | TRecordDef _ | TEffsigDef _ | TFuture _) -> false

  | TExists(x1, tp1), TExists(x2, tp2) ->
    begin match Kind.equal (TVar.kind x1) (TVar.kind x2) with
    | Equal ->
      if TVar.equal x1 x2 then subtype tp1 tp2
      else
        let x = TVar.clone x1 in
        subtype
          (Type.subst_type x1 (Type.var x) tp1)
          (Type.subst_type x2 (Type.var x) tp2)
    | NotEqual -> false
    end
  | TExists _,
    (TBase _ | TNeutral _ | TTuple _ | TArrow _ | TForall _ | TForallInst _
    | TDataDef _ | TRecordDef _ | TEffsigDef _ | TFuture _) -> false

  | TForallInst(a1, s1, tp1), TForallInst(a2, s2, tp2) ->
    equal s1 s2 && begin
      if EffInst.equal a1 a2 then subtype tp1 tp2
      else
        let a = EffInst.clone a1 in
        subtype
          (Type.subst_inst a1 a tp1)
          (Type.subst_inst a2 a tp2)
    end
  | TForallInst _,
    (TBase _ | TNeutral _ | TTuple _ | TArrow _ | TForall _ | TExists _
    | TDataDef _ | TRecordDef _ | TEffsigDef _ | TFuture _) -> false

  | TDataDef _, TDataDef _ -> equal tp1 tp2
  | TDataDef _,
    (TBase _ | TNeutral _ | TTuple _ | TArrow _ | TForall _ | TExists _
    | TForallInst _ | TRecordDef _ | TEffsigDef _ | TFuture _) -> false

  | TRecordDef _, TRecordDef _ -> equal tp1 tp2
  | TRecordDef _,
    (TBase _ | TNeutral _ | TTuple _ | TArrow _ | TForall _ | TExists _
    | TForallInst _ | TDataDef _ | TEffsigDef _ | TFuture _) -> false

  | TEffsigDef _, TEffsigDef _ -> equal tp1 tp2
  | TEffsigDef _,
    (TBase _ | TNeutral _ | TTuple _ | TArrow _ | TForall _ | TExists _
    | TForallInst _ | TDataDef _ | TRecordDef _ | TFuture _) -> false

  | TFuture _, TFuture _ -> equal tp1 tp2
  | TFuture _,
    (TBase _ | TNeutral _ | TTuple _ | TArrow _ | TForall _ | TExists _
    | TForallInst _ | TDataDef _ | TRecordDef _ | TEffsigDef _) -> false
