(* Lang/CoreCommon/Type.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Basic operations on types.
 *
 * This is internal module that implements part of an interface exposed by
 * CoreTypes.Impl module *)

open TypingStructure

let base b             = TyBase b
let var  x             = TyNeutral (TVar x)
let neutral neu        = TyNeutral neu
let tuple tps          = TyTuple tps
let arrow tp1 tp2 eff  = TyArrow(tp1, tp2, eff)
let forall x tp        = TyForall(x, tp)
let exists x tp        = TyExists(x, tp)
let forall_inst a s tp = TyForallInst(a, s, tp)

let eff_pure   = TyEffPure 
let eff_inst a = TyEffInst a

let data_def   tp ctors = TyDataDef(tp, ctors)
let record_def tp flds  = TyRecordDef(tp, flds)
let effsig_def s ops    = TyEffsigDef(s, ops)

let rec arrow_l tps tp eff =
  match tps with
  | []    -> failwith "arrow_l: arrows must have at least one argument"
  | [tp0] -> arrow tp0 tp eff
  | tp0 :: tps -> arrow tp0 (arrow_l tps tp eff) eff_pure

let arrow_l_pure tps tp =
  List.fold_right (fun ta tv -> arrow ta tv eff_pure) tps tp

let forall_l xs tp =
  List.fold_right (fun (TVar.Pack x) tp -> forall x tp) xs tp
let exists_l xs tp =
  List.fold_right (fun (TVar.Pack x) tp -> exists x tp) xs tp

let tfun x tp = TyFun(x, tp)

let future ask subst = TyFuture(ask, subst)

let rec kind : type k. k typ -> k kind =
  function
  | TyEffPure      -> KEffect
  | TyEffCons _    -> KEffect
  | TyEffInst _    -> KEffect
  | TyBase    _    -> KType
  | TyNeutral neu  -> neutral_kind neu
  | TyTuple  _     -> KType
  | TyArrow  _     -> KType
  | TyForall _     -> KType
  | TyExists _     -> KType
  | TyForallInst _ -> KType
  | TyDataDef    _ -> KType
  | TyRecordDef  _ -> KType
  | TyEffsigDef  _ -> KType
  | TyFun(x, tp) ->
    KArrow(TVar.kind x, kind tp)
  | TyFuture(f, _) -> type_future_kind (f ())

and neutral_kind : type k. k neutral_type -> k kind =
  function
  | TVar x -> TVar.kind x
  | TApp(neu, _) ->
    begin match neutral_kind neu with
    | KArrow(_, k) -> k
    end

and type_future_kind : type k. k type_future -> k kind =
  function
  | TFType tp -> kind tp
  | TFFuture(TFIdType   _, _, _) -> KType
  | TFFuture(TFIdEffect _, _, _) -> KEffect
  | TFFuture(TFIdEffsig _, _, _) -> KEffsig

let type_future_uid (type k) (id : k type_future_id) =
  match id with
  | TFIdType   uid -> uid
  | TFIdEffect uid -> uid
  | TFIdEffsig uid -> uid

let rec view : type k. k typ -> k type_view =
  fun tp ->
  match tp with
  | TyEffPure              -> TEffPure
  | TyEffCons(eff1, eff2)  -> TEffCons(eff1, eff2)
  | TyEffInst a            -> TEffInst a
  | TyBase    b            -> TBase    b
  | TyNeutral neu          -> TNeutral neu
  | TyTuple   tps          -> TTuple tps
  | TyArrow(tp1, tp2, eff) -> TArrow(tp1, tp2, eff)
  | TyForall(x, tp)        -> TForall(x, tp)
  | TyExists(x, tp)        -> TExists(x, tp)
  | TyForallInst(a, s, tp) -> TForallInst(a, s, tp)
  | TyDataDef(tp, ctors)   -> TDataDef(tp, ctors)
  | TyRecordDef(tp, flds)  -> TRecordDef(tp, flds)
  | TyEffsigDef(s, ops)    -> TEffsigDef(s, ops)
  | TyFun(x, tp)           -> TFun(x, tp)
  | TyFuture(func, sub) ->
    begin match func () with
    | TFType tp  -> view (subst sub tp)
    | TFFuture(id, tholes, eholes) ->
      TFuture
        { uid    = type_future_uid id
        ; tholes = List.map (subst_type_arg sub) tholes
        ; eholes = List.map (Subst.lookup_inst sub) eholes
        ; future = func
        ; subst  = sub
        }
    end

and subst_type_arg sub (TpArg tp) = TpArg (subst sub tp)

and subst_ctor_decl sub ctor =
  match ctor with
  | CtorDecl(name, xs, tps) ->
    let (sub, xs) = Subst.add_tvars sub xs in
    CtorDecl(name, xs, List.map (subst sub) tps)

and subst_field_decl sub fld =
  match fld with
  | FieldDecl(name, tp) ->
    FieldDecl(name, subst sub tp)

and subst_op_decl sub op =
  match op with
  | OpDecl(name, xs, tps, tp) ->
    let (sub, xs) = Subst.add_tvars sub xs in
    OpDecl(name, xs, List.map (subst sub) tps, subst sub tp)

and subst : type k. subst -> k typ -> k typ =
  fun sub tp ->
  match view tp with
  | TEffPure -> TyEffPure
  | TEffCons(eff1, eff2) ->
    TyEffCons(subst sub eff1, subst sub eff2)
  | TEffInst a -> TyEffInst (Subst.lookup_inst sub a)
  | TBase base -> TyBase base
  | TNeutral neu -> subst_neutral sub neu
  | TTuple tps   -> TyTuple (List.map (subst sub) tps)
  | TArrow(tp1, tp2, eff) ->
    TyArrow(subst sub tp1, subst sub tp2, subst sub eff)
  | TForall(x, tp) ->
    let y = TVar.clone x in
    TyForall(y, subst (Subst.add_type sub x (var y)) tp)
  | TExists(x, tp) ->
    let y = TVar.clone x in
    TyExists(y, subst (Subst.add_type sub x (var y)) tp)
  | TForallInst(a, s, tp) ->
    let b = EffInst.clone a in
    TyForallInst(b, subst sub s, subst (Subst.add_inst sub a b) tp)
  | TDataDef(tp, ctors) ->
    TyDataDef(subst sub tp, List.map (subst_ctor_decl sub) ctors)
  | TRecordDef(tp, flds) ->
    TyRecordDef(subst sub tp, List.map (subst_field_decl sub) flds)
  | TEffsigDef(s, ops) ->
    TyEffsigDef(subst sub s, List.map (subst_op_decl sub) ops)
  | TFun(x, tp) ->
    let y = TVar.clone x in
    TyFun(y, subst (Subst.add_type sub x (var y)) tp)
  | TFuture fut ->
    future fut.future (subst_compose sub fut.subst)

and subst_neutral : type k. subst -> k neutral_type -> k typ =
  fun sub neu ->
  match neu with
  | TVar x -> Subst.lookup_type sub x
  | TApp(neu, tp) ->
    let tp = subst sub tp in
    begin match subst_neutral sub neu with
    | TyNeutral neu -> TyNeutral (TApp(neu, tp))
    | TyFun(x, body) -> subst (Subst.singleton_t x tp) body
    | TyFuture _ -> assert false
    end

and subst_compose sub2 sub1 =
  let sub = sub2 in
  let sub =
    TVar.Map.fold
      { fold_f = fun _ (TKV(x, tp)) sub ->
        Subst.add_type sub x (subst sub2 tp) }
      sub1.sub_type
      sub in
  let sub =
    EffInst.Map.fold
      (fun a b sub -> Subst.add_inst sub a (Subst.lookup_inst sub2 b))
      sub1.sub_inst
      sub in
  sub

let subst_type x stp tp =
  subst (Subst.singleton_t x stp) tp

let subst_inst a b tp =
  subst (Subst.singleton_i a b) tp

module Ex  = Utils.Exists.Make(struct type 'k t = 'k typ end)
include Ex.Datatypes
