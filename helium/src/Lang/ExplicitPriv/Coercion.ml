(* Lang/ExplicitPriv/Coercion.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Operations on coercions *)

open CoreCommon.CoreTypes.Impl
open Syntax

let ctor_proxy_type tp ctors n =
  let (CtorDecl(_, xs, tps)) = List.nth ctors n in
  Type.forall_l xs (Type.arrow_l_pure tps tp)

let op_proxy_type s ops n =
  let (OpDecl(_, xs, tps, tp)) = List.nth ops n in
  let a = EffInst.fresh () in
  Type.forall_inst a s (Type.forall_l xs
    (Type.arrow_l tps tp (Type.eff_inst a)))

let tvar_of_tp_inst (TpInst(x, _)) = TVar.Pack x

let rec input_type crc =
  match crc with
  | CId(tp, _) -> tp
  | CComp(crc, _) -> input_type crc
  | CArrow cdata ->
    Type.arrow
      (output_type cdata.arg_crc)
      (input_type cdata.res_crc)
      cdata.eff_in
  | CTypeGen(_, crc) -> input_type crc
  | CTypeApp(insts, tp, _) ->
    Type.forall_l (List.map tvar_of_tp_inst insts) tp
  | CInstGen(_, _, crc) -> input_type crc
  | CInstApp(tp, _, _)  -> tp
  | CPack(crc, _, _) -> input_type crc
  | CUnpack(xs, crc) -> Type.exists_l xs (input_type crc)
  | CTuple(tp, _)    -> tp
  | CProj(tps, _, _) -> Type.tuple tps
  | CCtorProxy(tp, ctors, _) -> Type.data_def tp ctors
  | COpProxy(s, ops, _) -> Type.effsig_def s ops

and output_type crc =
  match crc with
  | CId(_, tp) -> tp
  | CComp(_, crc) -> output_type crc
  | CArrow cdata ->
    Type.arrow
      (input_type cdata.arg_crc)
      (output_type cdata.res_crc)
      cdata.eff_out
  | CTypeGen(x, crc) -> Type.forall_l x (output_type crc)
  | CTypeApp(_, _, crc) -> output_type crc
  | CInstGen(a, s, crc) -> Type.forall_inst a s (output_type crc)
  | CInstApp(_, _, crc) -> output_type crc
  | CPack(_, insts, tp) ->
    Type.exists_l (List.map tvar_of_tp_inst insts) tp
  | CUnpack(_, crc) -> output_type crc
  | CTuple(_, cs) -> Type.tuple (List.map output_type cs)
  | CProj(_, _, crc) -> output_type crc
  | CCtorProxy(tp, ctors, n) -> ctor_proxy_type tp ctors n
  | COpProxy(s, ops, n) -> op_proxy_type s ops n

let id tp = CId(tp, tp)

let forall_inst a s crc =
  let tp = input_type crc in
  CInstGen(a, s, CInstApp(Type.forall_inst a s tp, a, crc))

let ignore tp = CTuple(tp, [])
