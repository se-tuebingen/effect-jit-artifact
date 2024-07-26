(* Lang/CoreCommon/SyntaxOps.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)

open Node
open CoreCommon.CoreTypes.Impl
open CoreCommon.TypeDef.Impl
open Syntax

let refresh_typedef sub td =
  match td with
  | TypeDef(a, x, tp) ->
    let b = TVar.clone a in
    let sub = Subst.add_type sub a (Type.var b) in
    (sub, TypeDef(b, x, tp))

let refresh_typedefs sub tds =
  List.fold_left_map refresh_typedef sub tds

let apply_subst_in_typedef sub td =
  match td with
  | TypeDef(a, x, tp) ->
    TypeDef(a, x, Type.subst sub tp)

let apply_subst_in_type_arg sub (TpArg tp) =
  TpArg (Type.subst sub tp)

let rec apply_subst_in_expr sub e =
  { e with data =
    match e.data with
    | EValue v -> EValue (apply_subst_in_value sub v)
    | ELet(x, e1, e2) ->
      ELet(x,
        apply_subst_in_expr sub e1,
        apply_subst_in_expr sub e2)
    | ELetPure(x, e1, e2) ->
      ELetPure(x,
        apply_subst_in_expr sub e1,
        apply_subst_in_expr sub e2)
    | EFix(rfs, e) ->
      EFix(
        List.map (apply_subst_in_rec_function sub) rfs,
        apply_subst_in_expr sub e)
    | EUnpack(a, x, v, e) ->
      let b = TVar.clone a in
      let v = apply_subst_in_value sub v in
      let sub = Subst.add_type sub a (Type.var b) in
      EUnpack(b, x, v, apply_subst_in_expr sub e)
    | ETypeDef(tds, e) ->
      let (sub, tds) = refresh_typedefs sub tds in
      ETypeDef(
        List.map (apply_subst_in_typedef sub) tds,
        apply_subst_in_expr sub e)
    | ETypeApp(v, tp) ->
      ETypeApp(apply_subst_in_value sub v, Type.subst sub tp)
    | EInstApp(v, ei) ->
      EInstApp(apply_subst_in_value sub v, Subst.lookup_inst sub ei)
    | EApp(v1, v2) ->
      EApp(apply_subst_in_value sub v1, apply_subst_in_value sub v2)
    | EProj(v, n) ->
      EProj(apply_subst_in_value sub v, n)
    | ESelect(pf, n, v) ->
      ESelect(apply_subst_in_value sub pf, n, apply_subst_in_value sub v)
    | EMatch(pf, v, cls, tp) ->
      EMatch(
        apply_subst_in_value sub pf,
        apply_subst_in_value sub v,
        List.map (apply_subst_in_match_clause sub) cls,
        Type.subst sub tp)
    | EHandle h ->
      let a = EffInst.clone h.effinst in
      let sub' = Subst.add_inst sub h.effinst a in
      EHandle
        { proof       = apply_subst_in_value sub h.proof
        ; effinst     = a
        ; body        = apply_subst_in_expr sub' h.body
        ; op_handlers = List.map (apply_subst_in_op_handler sub) h.op_handlers
        ; return_var  = h.return_var
        ; return_body = apply_subst_in_expr sub h.return_body
        ; htype       = Type.subst sub h.htype
        ; heffect     = Type.subst sub h.heffect
        }
    | EOp(v, n, ei, tps, vs) ->
      EOp(apply_subst_in_value sub v, n,
        Subst.lookup_inst sub ei,
        List.map (apply_subst_in_type_arg sub) tps,
        List.map (apply_subst_in_value sub) vs)
    | ERepl _ | EReplExpr _ | EReplImport _ ->
      failwith (
        "Substitution in REPL session is not implemented.\n" ^
        "It might be possible to implement it, but I don't see any scenario " ^
        "where it might be useful.")
  }

and apply_subst_in_rec_function sub rf =
  match rf with
  | RFFun(f, ftp, tvs, x, xtp, body) ->
    let (sub', tvs) = Subst.add_tvars sub tvs in
    RFFun(f, Type.subst sub ftp, tvs, x, Type.subst sub' xtp,
      apply_subst_in_expr sub' body)
  | RFInstFun(f, ftp, tvs, a, asig, body) ->
    let (sub', tvs) = Subst.add_tvars sub tvs in
    let bsig = Type.subst sub' asig in
    let b = EffInst.clone a in
    let sub' = Subst.add_inst sub' a b in
    RFInstFun(f, Type.subst sub ftp, tvs, b, bsig,
      apply_subst_in_expr sub' body)

and apply_subst_in_match_clause sub (Clause(tps, xs, e)) =
  let (sub, tps) = Subst.add_tvars sub tps in
  Clause(tps, xs, apply_subst_in_expr sub e)

and apply_subst_in_op_handler sub (OpHandler(tps, xs, r, e)) =
  let (sub, tps) = Subst.add_tvars sub tps in
  OpHandler(tps, xs, r, apply_subst_in_expr sub e)

and apply_subst_in_value sub v =
  { v with data =
    match v.data with
    | VLit _ | VVar _ -> v.data
    | VFn(x, tp, body) ->
      VFn(x, Type.subst sub tp, apply_subst_in_expr sub body)
    | VTypeFun(a, body) ->
      let b = TVar.clone a in
      let sub = Subst.add_type sub a (Type.var b) in
      VTypeFun(b, apply_subst_in_expr sub body)
    | VInstFun(a, s, e) ->
      let b = EffInst.clone a in
      let s = Type.subst sub s in
      VInstFun(b, s, apply_subst_in_expr (Subst.add_inst sub a b) e)
    | VPack(tp, v, a, etp) ->
      let b = TVar.clone a in
      let sub' = Subst.add_type sub a (Type.var b) in
      VPack(
        Type.subst sub tp,
        apply_subst_in_value sub v,
        b,
        Type.subst sub' etp)
    | VTuple vs ->
      VTuple (List.map (apply_subst_in_value sub) vs)
    | VCtor(v, n, targs, args) ->
      VCtor(apply_subst_in_value sub v, n,
        List.map (apply_subst_in_type_arg sub) targs,
        List.map (apply_subst_in_value sub) args)
    | VRecord(pf, vs) ->
      VRecord(apply_subst_in_value sub pf,
        List.map (apply_subst_in_value sub) vs)
    | VExtern(name, tp) ->
      VExtern(name, Type.subst sub tp)
  }
