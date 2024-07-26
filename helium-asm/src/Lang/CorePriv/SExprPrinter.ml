(* Lang/CorePriv/SExprPrinter.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Pretty-printing Core language as S-expression *)

open Node
open CoreCommon.CoreTypes.Impl
open CoreCommon.Unit.Impl
open CoreCommon.SExprPrinter
open Syntax

let rec tr_expr e =
  match e.data with
  | EValue v ->
    SExpr.tagged_list "val" [ tr_value v ]
  | ELet _ | ELetPure _ | EFix _ | EUnpack _ | ETypeDef _ | EReplExpr _
  | EReplImport _ ->
    SExpr.tagged_list "begin" (tr_block e)
  | ETypeApp(v1, tp) ->
    SExpr.tagged_list "type-app" [ tr_value v1; tr_type tp ]
  | EInstApp(v1, a) ->
    SExpr.tagged_list "inst-app" [ tr_value v1; Atom (EffInst.to_string a) ]
  | EApp(v1, v2) ->
    SExpr.tagged_list "app" [ tr_value v1; tr_value v2 ]
  | EProj(v, n) ->
    SExpr.tagged_list "proj"
      [ Int n
      ; tr_value v
      ]
  | ESelect(proof, n, v) ->
    SExpr.tagged_list "select"
      [ tr_value proof
      ; Int n
      ; tr_value v
      ]
  | EMatch(proof, v, cls, tp) ->
    SExpr.tagged_list "match"
      (  tr_value proof
      :: tr_value v
      :: tr_type tp
      :: List.map tr_clause cls)
  | EHandle hdata ->
    SExpr.tagged_list "handler"
    [ SExpr.tagged_list "proof" [ tr_value hdata.proof ]
    ; SExpr.tagged_list "inst" [ Atom (EffInst.to_string hdata.effinst) ]
    ; SExpr.tagged_list "body" [ tr_expr hdata.body ]
    ; SExpr.tagged_list "with" (List.map tr_op_handler hdata.op_handlers)
    ; SExpr.tagged_list "return"
      [ Atom (Var.to_string hdata.return_var)
      ; tr_expr hdata.return_body
      ]
    ; SExpr.tagged_list "h-type"
      ( tr_type hdata.htype :: tr_effect hdata.heffect)
    ]
  | EOp(proof, n, a, targs, args) ->
    SExpr.tagged_list "a"
      [ tr_value proof
      ; Int n
      ; Atom (EffInst.to_string a)
      ; SExpr.of_list tr_type_arg targs
      ; SExpr.of_list tr_value args
      ]
  | ERepl(_, tp, eff, _) ->
    SExpr.tagged_list "repl" (tr_type tp :: tr_effect eff)

and tr_block e =
  match e.data with
  | EValue _ | ETypeApp _ | EInstApp _ | EApp _ | EProj _ | ESelect _ 
  | EMatch _ | EHandle _ | EOp _ | ERepl _ ->
    [ tr_expr e ]
  | ELet(x, e1, e2) ->
    SExpr.tagged_list "let"
      [ Atom (Var.to_string x)
      ; tr_expr e1
      ] :: tr_block e2
  | ELetPure(x, e1, e2) ->
    SExpr.tagged_list "let-pure"
      [ Atom (Var.to_string x)
      ; tr_expr e1
      ] :: tr_block e2
  | EFix(rfs, e) ->
    SExpr.tagged_list "fix" (List.map tr_rec_function rfs) :: tr_block e
  | EUnpack(x, y, v, e) ->
    SExpr.tagged_list "unpack"
      [ Atom (TVar.unique_name x)
      ; Atom (Var.to_string y)
      ; tr_value v
      ] :: tr_block e
  | ETypeDef(tds, e) ->
    SExpr.tagged_list "typedef" (List.map tr_typedef tds) :: tr_block e
  | EReplExpr(e1, _, e2) ->
    SExpr.tagged_list "repl-expr"
      [ tr_expr e1
      ] :: tr_block e2
  | EReplImport(_, e) ->
    SExpr.tagged_list "repl-import" [] :: tr_block e

and tr_rec_function rf =
  match rf with
  | RFFun(x, tp, targs, arg, arg_tp, body) ->
    SExpr.tagged_list "fun"
    [ tr_type tp
    ; Atom (Var.to_string x)
    ; SExpr.of_list tr_tvar_binder_e targs
    ; Atom (Var.to_string arg)
    ; tr_type arg_tp
    ; tr_expr body
    ]
  | RFInstFun(x, tp, targs, a, s, body) ->
    SExpr.tagged_list "inst-fun"
    [ tr_type tp
    ; Atom (Var.to_string x)
    ; SExpr.of_list tr_tvar_binder_e targs
    ; Atom (EffInst.to_string a)
    ; tr_type s
    ; tr_expr body
    ]

and tr_clause (Clause(xs, ys, body)) =
  SExpr.mk_list
    [ SExpr.of_list tr_tvar_binder_e xs
    ; SExpr.of_list (fun x -> Atom (Var.to_string x)) ys
    ; tr_expr body
    ]

and tr_op_handler (OpHandler(xs, ys, z, body)) =
  SExpr.mk_list
    [ SExpr.of_list tr_tvar_binder_e xs
    ; SExpr.of_list (fun x -> Atom (Var.to_string x)) ys
    ; Atom (Var.to_string z)
    ; tr_expr body
    ]

and tr_value v =
  match v.data with
  | VLit lit ->
    SExpr.tagged_list "lit" [ Atom (RichBaseType.to_string lit) ]
  | VVar x -> Atom (Var.to_string x)
  | VFn _ | VTypeFun _ | VInstFun _ ->
    SExpr.tagged_list "fn" (tr_function v)
  | VPack(ptp, v, x, tp) ->
    SExpr.tagged_list "pack"
      [ tr_type ptp
      ; tr_value v
      ; tr_tvar_binder x
      ; tr_type tp
      ]
  | VTuple vs ->
    SExpr.tagged_list "tuple" (List.map tr_value vs)
  | VCtor(proof, n, targs, args) ->
    SExpr.tagged_list "ctor"
      [ tr_value proof
      ; Int n
      ; SExpr.of_list tr_type_arg targs
      ; SExpr.of_list tr_value args
      ]
  | VRecord(proof, vs) ->
    SExpr.tagged_list "record"
      (tr_value proof :: List.map tr_value vs)
  | VExtern(name, tp) ->
    SExpr.tagged_list "extern" [ Atom name; tr_type tp ]

and tr_function v =
  match v.data with
  | VFn(x, tp, body) ->
    SExpr.mk_list
      [ Atom (Var.to_string x)
      ; Special ":"
      ; tr_type tp
      ] :: tr_function' body
  | VTypeFun(x, body) ->
    tr_tvar_binder x :: tr_function' body
  | VInstFun(a, s, body) ->
    SExpr.mk_list
      [ Atom (EffInst.to_string a)
      ; Special "@"
      ; tr_type s
      ] :: tr_function' body
  | VLit _ | VVar _ | VPack _ | VTuple _ | VCtor _ | VRecord _ | VExtern _ ->
    [ SExpr.tagged_list "val" [ tr_value v ]]

and tr_function' e =
  match e.data with
  | EValue v -> tr_function v
  | _ -> [ tr_expr e ]

(* ========================================================================= *)
let tr_source_file sf =
  match sf.sf_body with
  | UB_Direct body ->
    SExpr.tagged_list "unit-direct"
    [ tr_tvar_binders body.types
    ; SExpr.of_list tr_type body.body_sig
    ; tr_expr body.body
    ]
  | UB_CPS body ->
    SExpr.tagged_list "unit-cps"
    [ SExpr.tagged_list "types"
      (List.map tr_tvar_binder_e body.types)
    ; SExpr.tagged_list "handle"
      (tr_effect body.handle)
    ; SExpr.tagged_list "sig"
      (List.map tr_type body.body_sig)
    ; SExpr.tagged_list "body"
      [ tr_expr body.body ]
    ]
