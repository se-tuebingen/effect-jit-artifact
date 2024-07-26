(* Transform/Explicit/ToCore/Coercion.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)

open Lang.Node
open Common

let is_trivial v =
  match v.data with
  | T.VLit _ | T.VVar _ ->
    true
  | T.VFn _ | T.VTypeFun _ | T.VInstFun _ | T.VPack _ | T.VTuple _ | T.VCtor _
  | T.VRecord _ | T.VExtern _ ->
    false

let bind_trivial meta v cont =
  if is_trivial v then cont v
  else
    let make data = { meta = meta; data = data } in
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.EValue v), cont (make (T.VVar x))))

let bind_expr meta e cont =
  match e.data with
  | T.EValue v -> cont v
  | _ ->
    let make data = { meta = meta; data = data } in
    let x = T.Var.fresh () in
    make (T.ELetPure(x, e, cont (make (T.VVar x))))

let rec bind_exprs meta es cont =
  match es with
  | [] -> cont []
  | e :: es ->
    bind_expr meta e (fun v ->
    bind_exprs meta es (fun vs ->
    cont (v :: vs)))

let rec generalize meta xs exp =
  let make data = { meta = meta; data = data } in
  match xs with
  | [] -> exp
  | T.TVar.Pack x :: xs ->
    make (T.EValue (make (T.VTypeFun(x, generalize meta xs exp))))

let rec instantiate meta env inst v cont =
  let make data = { meta = meta; data = data } in
  match inst with
  | [] -> cont v
  | S.TpInst(_, tp) :: inst ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.ETypeApp(v, Type.tr_type env tp)),
      instantiate meta env inst (make (T.VVar x)) cont))

let rec make_fun meta tps cont =
  let make data = { meta = meta; data = data } in
  match tps with
  | [] -> cont []
  | tp :: tps ->
    let x = T.Var.fresh () in
    make (T.EValue (make (T.VFn(x, tp,
      make_fun meta tps (fun xs -> cont (x :: xs))))))

let make_targs xs =
  let make_targ (T.TVar.Pack x) = T.TpArg (T.Type.var x) in
  List.map make_targ xs

let make_args meta xs =
  List.map (fun x -> { meta; data = T.VVar x }) xs

let rec coerce meta env crc v =
  let make data = { meta = meta; data = data } in
  match crc with
  | S.CId _ -> make (T.EValue v)

  | S.CComp(crc1, crc2) ->
    bind_expr meta (coerce meta env crc1 v) (fun v ->
      coerce meta env crc2 v)

  | S.CArrow { arg_crc; res_crc; _ } ->
    let x  = T.Var.fresh () in
    let tp = Type.tr_type env (S.Coercion.input_type arg_crc) in
    make (T.EValue (make (T.VFn(x, tp,
      let y = T.Var.fresh () in
      make (T.ELetPure(y, coerce meta env arg_crc (make (T.VVar x)),
        let z = T.Var.fresh () in
        make (T.ELet(z, make (T.EApp(v, (make (T.VVar y)))),
          coerce meta env res_crc (make (T.VVar z))))))))))

  | S.CTypeGen(xs, crc) ->
    let (env, xs) = Env.add_tvars env xs in
    generalize meta xs (coerce meta env crc v)

  | S.CTypeApp(inst, _, crc) ->
    instantiate meta env inst v (fun v ->
    coerce meta env crc v)

  | S.CInstGen(a, s, crc) ->
    let s = Type.tr_type env s in
    let (env, a) = Env.add_effinst env a in
    make (T.EValue (make (T.VInstFun(a, s, coerce meta env crc v))))

  | S.CInstApp(_, a, crc) ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.EInstApp(v, Env.lookup_inst env a)),
      coerce meta env crc (make (T.VVar x))))

  | S.CPack(crc, inst, tp) ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, coerce meta env crc v,
      let (v, _) = Pack.pack_value meta env inst tp (make (T.VVar x)) in
      make (T.EValue v)))

  | S.CUnpack(xs, crc) ->
    Pack.unpack_value meta env xs v (fun env v ->
    coerce meta env crc v)

  | CTuple(_, crcs) ->
    bind_trivial meta v (fun v ->
    bind_exprs meta 
      (List.map (fun crc -> coerce meta env crc v) crcs)
      (fun vs -> make (T.EValue (make (T.VTuple vs)))))

  | CProj(_, n, crc) ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.EProj(v, n)),
      coerce meta env crc (make (T.VVar x))))

  | CCtorProxy(tp, ctors, n) ->
    let (CtorDecl(_, tvars, tps)) = Type.tr_ctor_decl env (List.nth ctors n) in
    generalize meta tvars (make_fun meta tps (fun xs ->
      make (T.EValue
        (make (T.VCtor(v, n, make_targs tvars, make_args meta xs))))))

  | COpProxy(s, ops, n) ->
    let s = Type.tr_type env s in
    let (OpDecl(_, tvars, tps, tp)) = Type.tr_op_decl env (List.nth ops n) in
    let a = T.EffInst.fresh () in
    make (T.EValue (make (T.VInstFun(a, Type.tr_type env s,
      generalize meta tvars
        (make_fun meta tps (fun xs ->
          make (T.EOp(v, n, a, make_targs tvars, make_args meta xs))))))))
