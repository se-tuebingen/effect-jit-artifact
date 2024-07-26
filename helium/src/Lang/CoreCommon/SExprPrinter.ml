(* Lang/CoreCommon/SExprPrinter.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Pretty-printing Core types as S-Expressions *)

open Kind.Impl
open CoreTypes.Impl
open TypeDef.Impl

let tr_tvar_binder x =
  SExpr.mk_list
  [ Atom (TVar.unique_name x)
  ; Special "::"
  ; Kind.to_sexpr (TVar.kind x)
  ]

let tr_tvar_binder_e (TVar.Pack x) =
  tr_tvar_binder x

let tr_tvar_binders xs =
  SExpr.of_list tr_tvar_binder_e xs

(* ========================================================================= *)
let rec tr_ctor_decl ctor =
  match ctor with
  | CtorDecl(name, targs, tp) ->
    SExpr.mk_list
      ( Atom name
      :: SExpr.of_list tr_tvar_binder_e targs
      :: List.map tr_type tp)

and tr_field_decl fld =
  match fld with
  | FieldDecl(name, tp) ->
    SExpr.mk_list [ Atom name; tr_type tp ]

and tr_op_decl op =
  match op with
  | OpDecl(name, targs, tps, tp) ->
    SExpr.mk_list
      [ Atom name
      ; SExpr.of_list tr_tvar_binder_e targs
      ; SExpr.of_list tr_type tps
      ; tr_type tp
      ]

and tr_type : type k. k typ -> SExpr.t =
  fun tp ->
  match Type.view tp with
  | TEffPure ->
    SExpr.tagged_list "effect" (tr_effect tp)
  | TEffCons _ ->
    SExpr.tagged_list "effect" (tr_effect tp)
  | TEffInst _ ->
    SExpr.tagged_list "effect" (tr_effect tp)
  | TBase b -> SExpr.Special (RichBaseType.name b)
  | TNeutral neu ->
    tr_neutral_type neu []
  | TTuple tps ->
    SExpr.tagged_list "tuple" (List.map tr_type tps)
  | TArrow(tp1, tp2, eff) ->
    SExpr.tagged_list "->"
      [ tr_type tp1
      ; tr_type tp2
      ; SExpr.mk_list (tr_effect eff)
      ]
  | TForall _ ->
    SExpr.tagged_list "forall" (tr_forall_type tp)
  | TExists _ ->
    SExpr.tagged_list "exists" (tr_exists_type tp)
  | TForallInst(a, s, tp) ->
    SExpr.tagged_list "forall-inst"
      [ Atom (EffInst.to_string a)
      ; tr_type s
      ; tr_type tp
      ]
  | TDataDef(tp, ctors) ->
    SExpr.tagged_list "data" (tr_type tp :: List.map tr_ctor_decl ctors)
  | TRecordDef(tp, flds) ->
    SExpr.tagged_list "record" (tr_type tp :: List.map tr_field_decl flds)
  | TEffsigDef(s, ops) ->
    SExpr.tagged_list "effect-sig" (tr_type s :: List.map tr_op_decl ops)
  | TFun(x, tp) ->
    SExpr.tagged_list "fun" (tr_fun_type tp)
  | TFuture fut ->
    SExpr.tagged_list "future"
    [ Atom (Utils.UID.to_string fut.uid)
    ; SExpr.tagged_list "tholes"
        (List.map (fun (TpArg tp) -> tr_type tp) fut.tholes)
    ; SExpr.tagged_list "eholes"
        (List.map (fun a -> SExpr.Atom (EffInst.to_string a)) fut.eholes)
    ]

and tr_effect : effect -> SExpr.t list =
  fun eff ->
  match Type.view eff with
  | TEffPure -> []
  | TEffCons(eff1, eff2) -> tr_effect eff1 @ tr_effect eff2
  | TEffInst a -> [ SExpr.tagged_list "inst" [ Atom (EffInst.to_string a) ] ]
  | TNeutral _ | TFuture _ -> [ tr_type eff ]

and tr_forall_type : ttype -> _ =
  fun tp ->
  match Type.view tp with
  | TForall(x, tp) ->
    tr_tvar_binder x :: tr_forall_type tp
  | _ -> [ tr_type tp ]

and tr_exists_type : ttype -> _ =
  fun tp ->
  match Type.view tp with
  | TExists(x, tp) ->
    tr_tvar_binder x :: tr_exists_type tp
  | _ -> [ tr_type tp ]

and tr_fun_type : type k. k typ -> _ =
  fun tp ->
  match Type.view tp with
  | TFun(x, tp) ->
    tr_tvar_binder x :: tr_fun_type tp
  | _ -> [ tr_type tp ]

and tr_neutral_type : type k. k neutral_type -> _ -> _ =
  fun neu args ->
  match neu with
  | TVar x -> SExpr.tagged_list "var" (Atom (TVar.unique_name x) :: args)
  | TApp(neu, tp) ->
    tr_neutral_type neu (tr_type tp :: args)

let tr_type_arg (TpArg tp) =
  tr_type tp

(* ========================================================================= *)

let tr_typedef (TypeDef(x, z, tp)) =
  SExpr.mk_list
    [ tr_tvar_binder x
    ; Atom (Common.Var.to_string z)
    ; tr_type tp
    ]
