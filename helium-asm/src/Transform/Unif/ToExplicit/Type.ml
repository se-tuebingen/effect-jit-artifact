(* Transform/Unif/ToExplicit/Type.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Common

let tr_effinst_expr env ie =
  match S.EffInstExpr.view ie with
  | IEInstance a -> Env.lookup_inst env a
  | IEImplicit _ ->
    failwith "Internal type error: unbound implicit instance"

let rec tr_named_type env nt =
  tr_type env nt.S.nt_type

and tr_ctor_decl env ctor =
  match ctor with
  | S.CtorDecl(name, xs, tps) ->
    let (env, xs) = Env.add_tvars env xs in
    T.CtorDecl(name, xs, List.map (tr_named_type env) tps)

and tr_field_decl env fld =
  match fld with
  | S.FieldDecl(name, tp) ->
    T.FieldDecl(name, tr_type env tp)

and tr_op_decl env op =
  match op with
  | S.OpDecl(name, xs, tps, extp) ->
    let (env, xs) = Env.add_tvars env xs in
    T.OpDecl(name, xs, List.map (tr_named_type env) tps, tr_ex_type env extp)

and tr_decl env decl : T.ttype =
  match decl with
  | S.DeclThis tp | S.DeclTypedef tp | S.DeclVal(_, tp) ->
    tr_type env tp
  | S.DeclOp(xs, s, ops, n) ->
    let (env, xs) = Env.add_tvars env xs in
    T.Type.forall_l xs (T.Type.effsig_def
      (tr_type env s)
      (List.map (tr_op_decl env) ops))
  | S.DeclCtor(xs, tp, ctors, n) ->
    let (env, xs) = Env.add_tvars env xs in
    T.Type.forall_l xs (T.Type.data_def
      (tr_type env tp)
      (List.map (tr_ctor_decl env) ctors))
  | S.DeclField(xs, tp, flds, n) ->
    let (env, xs) = Env.add_tvars env xs in
    T.Type.forall_l xs (T.Type.record_def
      (tr_type env tp)
      (List.map (tr_field_decl env) flds))

and tr_type : type k. Env.t -> k S.typ -> k T.typ =
  fun env tp ->
  match S.Type.view tp with
  | S.TEffPure -> T.Type.eff_pure
  | S.TEffInst a -> T.Type.eff_inst (tr_effinst_expr env a)
  | S.TEffCons(eff1, eff2) ->
    T.Type.eff_cons (tr_type env eff1) (tr_type env eff2)
  | S.TUVar(_, u) ->
    let uid = S.UVar.uid u in
    begin match S.UVar.kind u with
    | KType   -> tr_future env uid (T.TFIdType   uid) tp
    | KEffect -> tr_future env uid (T.TFIdEffect uid) tp
    | KEffsig -> tr_future env uid (T.TFIdEffsig uid) tp
    | KArrow(k1, _) ->
      let x = S.TVar.fresh k1 in
      tr_type env (S.Type.tfun x (S.Type.app tp (S.Type.var x)))
    end
  | S.TBase base -> T.Type.base base
  | S.TNeutral neu ->
    T.Type.neutral (tr_neutral_type env neu)
  | S.TArrow(_, tp1, extp, eff) ->
    T.Type.arrow (tr_type env tp1) (tr_ex_type env extp) (tr_type env eff)
  | S.TForall(xs, tp) ->
    let (env, xs) = Env.add_tvars env xs in
    T.Type.forall_l xs (tr_type env tp)
  | S.TForallInst(a, s, tp) ->
    let s = tr_type env s in
    let (env, a) = Env.add_effinst env a in
    T.Type.forall_inst a s (tr_type env tp)
  | S.THandler(s, tp1, eff1, tp2, eff2) ->
    let a = T.EffInst.fresh () in
    T.Type.arrow
      (T.Type.forall_inst a (tr_type env s)
        (T.Type.arrow (T.Type.tuple [])
          (tr_ex_type env tp1)
          (T.Type.eff_cons (T.Type.eff_inst a) (tr_type env eff1))))
      (tr_ex_type env tp2)
      (tr_type    env eff2)
  | S.TFun(x, tp) ->
    let (env, x) = Env.add_tvar env x in
    T.Type.tfun x (tr_type env tp)
  | S.TStruct decls ->
    T.Type.tuple (List.map (tr_decl env) decls)
  | S.TTypeWit extp  -> T.Type.tuple []
  | S.TEffectWit eff -> T.Type.tuple []
  | S.TEffsigWit s   -> T.Type.tuple []
  | S.TDataDef(tp, ctors) ->
    T.Type.data_def (tr_type env tp) (List.map (tr_ctor_decl env) ctors)
  | S.TRecordDef(tp, flds) ->
    T.Type.record_def (tr_type env tp) (List.map (tr_field_decl env) flds)
  | S.TEffsigDef(s, ops) ->
    T.Type.effsig_def (tr_type env s) (List.map (tr_op_decl env) ops)

and tr_neutral_type : type k. Env.t -> k S.neutral_type -> k T.neutral_type =
  fun env neu ->
  match neu with
  | S.TVar x ->
    T.TVar (Env.lookup_tvar env x)
  | S.TApp(neu, tp) ->
    T.TApp(tr_neutral_type env neu, tr_type env tp)

and tr_ex_type env (S.TExists(xs, tp)) =
  let (env, xs) = Env.add_tvars env xs in
  T.Type.exists_l xs (tr_type env tp)

and tr_future : type k.
    Env.t -> Utils.UID.t -> k T.type_future_id -> k S.typ -> k T.typ =
  fun env uid id tp ->
  T.Type.future
  (fun () ->
    match S.Type.view tp with
    | S.TUVar(sub, u) when Utils.UID.equal uid (S.UVar.uid u) ->
      T.TFFuture(id, tr_sub_types env sub, tr_sub_insts env sub)
    | _ -> T.TFType (tr_type env tp))
  T.Subst.empty

and tr_sub_types env sub =
  S.Subst.fold_types
    { fold_f = fun tps x tp -> T.TpArg (tr_type env tp) :: tps }
    []
    sub

and tr_sub_insts env sub =
  S.Subst.fold_insts
    (fun is _ a -> tr_effinst_expr env a :: is)
    []
    sub

let tr_type_arg env (S.TpArg tp) =
  T.TpArg(tr_type env tp)

let tr_type_instances env insts =
  let tr_type_instance env1 (S.TpInst(a, tp)) =
    let (env1, b) = Env.add_tvar env1 a in
    let tp = tr_type env tp in
    (env1, T.TpInst(b, tp))
  in
  List.fold_left_map tr_type_instance env insts
