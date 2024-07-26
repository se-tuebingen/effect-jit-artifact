(* Lang/CoreCommon/ScopeCheck.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Checking scope of types
 *
 * This is internal module that implements part of an interface exposed by
 * CoreTypes.Impl module *)

open TypingStructure

exception Escapes_scope

let rec check_type_arg_scope scope (TpArg tp) =
  check_scope scope tp

and check_ctor_decl_scope scope ctor =
  match ctor with
  | CtorDecl(_, xs, tps) ->
    let scope = Scope.add_tvars scope xs in
    List.for_all (check_scope scope) tps

and check_field_decl_scope scope fld =
  match fld with
  | FieldDecl(_, tp) -> check_scope scope tp

and check_op_decl_scope scope op =
  match op with
  | OpDecl(_, xs, tps, tp) ->
    let scope = Scope.add_tvars scope xs in
    List.for_all (check_scope scope) tps &&
    check_scope scope tp

and check_scope : type k. Scope.t -> k typ -> bool =
  fun scope tp ->
  match Type.view tp with
  | TEffPure -> true
  | TEffCons(eff1, eff2) ->
    check_scope scope eff1 && check_scope scope eff2
  | TEffInst a ->
    Scope.has_effinst scope a
  | TBase _ -> true
  | TNeutral neu ->
    check_neutral_scope scope neu
  | TTuple tps ->
    List.for_all (check_scope scope) tps
  | TArrow(tp1, tp2, eff) ->
    check_scope scope tp1 && check_scope scope tp2 && check_scope scope eff
  | TForall(x, tp) ->
    check_scope (Scope.add_tvar scope x) tp
  | TExists(x, tp) ->
    check_scope (Scope.add_tvar scope x) tp
  | TForallInst(a, s, tp) ->
    check_scope scope s &&
    check_scope (Scope.add_effinst scope a) tp
  | TDataDef(tp, ctors) ->
    check_scope scope tp &&
    List.for_all (check_ctor_decl_scope scope) ctors
  | TRecordDef(tp, flds) ->
    check_scope scope tp &&
    List.for_all (check_field_decl_scope scope) flds
  | TEffsigDef(s, ops) ->
    check_scope scope s &&
    List.for_all (check_op_decl_scope scope) ops
  | TFun(x, tp) ->
    check_scope (Scope.add_tvar scope x) tp
  | TFuture fut ->
    List.for_all (check_type_arg_scope scope) fut.tholes &&
    List.for_all (Scope.has_effinst scope) fut.eholes

and check_neutral_scope : type k. Scope.t -> k neutral_type -> bool =
  fun scope neu ->
  match neu with
  | TVar x -> Scope.has_tvar scope x
  | TApp(neu, tp) ->
    check_neutral_scope scope neu && check_scope scope tp

let check_scope' scope tp =
  if check_scope scope tp then ()
  else raise Escapes_scope

(* ========================================================================= *)
let rec subeffect_in_scope scope (eff : effect) : effect =
  match Type.view eff with
  | TEffPure -> TyEffPure
  | TEffCons(eff1, eff2) ->
    TyEffCons(
      subeffect_in_scope scope eff1,
      subeffect_in_scope scope eff2)
  | TEffInst _ | TNeutral _ | TFuture _ ->
    if check_scope scope eff then eff
    else TyEffPure

let rec supertype_in_scope scope (tp : ttype) : ttype =
  match Type.view tp with
  | TBase _ | TNeutral _ | TDataDef _ | TRecordDef _ | TEffsigDef _
  | TFuture _ ->
    check_scope' scope tp;
    tp
  | TTuple tps ->
    TyTuple (List.map (supertype_in_scope scope) tps)
  | TArrow(tp1, tp2, eff) ->
    check_scope' scope eff;
    TyArrow(subtype_in_scope scope tp1, supertype_in_scope scope tp2, eff)
  | TForall(x, tp) ->
    TyForall(x, supertype_in_scope (Scope.add_tvar scope x) tp)
  | TExists(x, tp) ->
    TyExists(x, supertype_in_scope (Scope.add_tvar scope x) tp)
  | TForallInst(a, s, tp) ->
    check_scope' scope s;
    TyForallInst(a, s, supertype_in_scope (Scope.add_effinst scope a) tp)

and subtype_in_scope scope (tp : ttype) : ttype =
  match Type.view tp with
  | TBase _ | TNeutral _ | TDataDef _ | TRecordDef _ | TEffsigDef _
  | TFuture _ ->
    check_scope' scope tp;
    tp
  | TTuple tps ->
    TyTuple (List.map (subtype_in_scope scope) tps)
  | TArrow(tp1, tp2, eff) ->
    TyArrow(
      supertype_in_scope scope tp1,
      subtype_in_scope   scope tp2,
      subeffect_in_scope scope eff)
  | TForall(x, tp) ->
    TyForall(x, subtype_in_scope (Scope.add_tvar scope x) tp)
  | TExists(x, tp) ->
    TyExists(x, subtype_in_scope (Scope.add_tvar scope x) tp)
  | TForallInst(a, s, tp) ->
    check_scope' scope s;
    TyForallInst(a, s, subtype_in_scope (Scope.add_effinst scope a) tp)
