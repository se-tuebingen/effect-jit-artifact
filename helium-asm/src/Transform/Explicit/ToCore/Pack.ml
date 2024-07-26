(* Transform/Explicit/ToCore/Pack.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Packing and unpacking of existential types *)
open Common
open Lang.Node

let rec unpack_value meta env xs v cont =
  let make data = { meta = meta; data = data } in
  match xs with
  | [] -> cont env v
  | (S.TVar.Pack x) :: xs ->
    let (env, x) = Env.add_tvar env x in
    let z = T.Var.fresh () in
    make (T.EUnpack(x, z, v,
      unpack_value meta env xs (make (T.VVar z)) cont))

let rec pack_value ?(sub=T.Subst.empty) meta env insts extp v =
  let make data = { meta = meta; data = data } in
  match insts with
  | [] -> (v, Type.tr_type env extp)
  | S.TpInst(x, tp) :: insts ->
    let tp = Type.tr_type env tp in
    let (env', x) = Env.add_tvar env x in
    let (v, tp') =
      pack_value ~sub:(T.Subst.add_type sub x tp) meta env' insts extp v in
    (make (T.VPack(tp, v, x, T.Type.subst sub tp')), T.Type.exists x tp')
