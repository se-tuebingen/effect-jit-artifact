(* Transform/Unif/ToExplicit/Coercion.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)

open Common

let rec instantiate2 ?(sub1=T.Subst.empty) ?(sub2=T.Subst.empty) tp insts =
  match insts with
  | [] -> (T.Type.subst sub1 tp, T.Type.subst sub2 tp)
  | T.TpInst(x, ti) :: insts ->
    begin match T.Type.view tp with
    | TForall(y, tp) ->
      begin match T.Kind.equal (T.TVar.kind x) (T.TVar.kind y) with
      | Equal ->
        let sub1 = T.Subst.add_type sub1 y (T.Type.var x) in
        let sub2 = T.Subst.add_type sub2 y ti in
        instantiate2 ~sub1 ~sub2 tp insts
      | NotEqual -> failwith "Internal kind error"
      end
    | _ -> failwith "Internal type error"
    end

let coerce_forall_before xs crc tp =
  let self_instance (T.TVar.Pack x) = T.TpInst(x, T.Type.var x) in
  T.CTypeGen(xs, T.CComp(crc,
    T.CTypeApp(List.map self_instance xs, tp, T.CId(tp, tp))))

let rec tr_coercion env crc =
  match crc with
  | S.CId(tp_in, tp_out) ->
    T.CId(Type.tr_type env tp_in, Type.tr_type env tp_out)

  | S.CArrow carr ->
    T.CArrow
      { arg_crc = tr_coercion env carr.arg_crc
      ; res_crc = tr_ex_coercion env carr.res_crc
      ; eff_in  = Type.tr_type env carr.eff_in
      ; eff_out = Type.tr_type env carr.eff_out
      }

  | S.CGen(c, xs, _) ->
    let (env, xs) = Env.add_tvars env xs in
    T.CTypeGen(xs, tr_coercion env c)

  | S.CInst(c, inst, tp) ->
    let c = tr_coercion env c in
    let (env, inst) = Type.tr_type_instances env inst in
    let tp = Type.tr_type env tp in
    T.CTypeApp(inst, tp, c)

  | CForallInst(a, s, c) ->
    let s = Type.tr_type env s in
    let (env, a) = Env.add_effinst env a in
    let c = tr_coercion env c in
    T.Coercion.forall_inst a s c

  | S.CHandler cdata ->
    let a = T.EffInst.fresh () in
    T.CArrow
      { arg_crc =
        T.Coercion.forall_inst a (Type.tr_type env cdata.effsig)
          (T.CArrow
            { arg_crc = T.Coercion.id (T.Type.tuple [])
            ; res_crc = tr_ex_coercion env cdata.in_crc
            ; eff_in  = T.Type.eff_cons (T.Type.eff_inst a)
                          (Type.tr_type env cdata.in_eff_out)
            ; eff_out = T.Type.eff_cons (T.Type.eff_inst a)
                          (Type.tr_type env cdata.in_eff_in)
            })
      ; res_crc = tr_ex_coercion env cdata.out_crc
      ; eff_in  = Type.tr_type env cdata.out_eff_in
      ; eff_out = Type.tr_type env cdata.out_eff_out
      }

  | S.CStruct(decls, dcs) ->
    let tps = List.map (Type.tr_decl env) decls in
    T.CTuple(T.Type.tuple tps, List.map (tr_decl_coercion env decls tps) dcs)

  | S.CDataDefSeal(tp, ctors) ->
    let tp    = Type.tr_type env tp in
    let ctors = List.map (Type.tr_ctor_decl env) ctors in
    T.Coercion.ignore (T.Type.data_def tp ctors)

  | S.CRecordDefSeal(tp, flds) ->
    let tp   = Type.tr_type env tp in
    let flds = List.map (Type.tr_field_decl env) flds in
    T.Coercion.ignore (T.Type.record_def tp flds)

  | S.CEffsigDefSeal(tp, ops) ->
    let tp  = Type.tr_type env tp in
    let ops = List.map (Type.tr_op_decl env) ops in
    T.Coercion.ignore (T.Type.effsig_def tp ops)

  | S.CThis(decls, crc) ->
    let tps = List.map (Type.tr_decl env) decls in
    let n   = S.Decl.this_index decls in
    T.CProj(tps, n, tr_coercion env crc)

  | S.CApplyInst(crc1, a, crc2) ->
    let tp = Type.tr_type env (S.Coercion.output_type crc1) in
    T.CComp(tr_coercion env crc1,
      T.CInstApp(tp, Type.tr_effinst_expr env a, tr_coercion env crc2))

and tr_ex_coercion env crc =
  match crc with
  | S.CExId(tp_in, tp_out) ->
    T.CId(Type.tr_ex_type env tp_in, Type.tr_ex_type env tp_out)
  | S.CExPack(xs, crc, insts, tp) ->
    let (env, xs) = Env.add_tvars env xs in
    let crc = tr_coercion env crc in
    let (env, insts) = Type.tr_type_instances env insts in
    let tp = Type.tr_type env tp in
    T.CUnpack(xs, T.CPack(crc, insts, tp))

and tr_decl_coercion env decls tps dc =
  match dc with
  | S.DCThis crc ->
    let n = S.Decl.this_index decls in
    T.CProj(tps, n, tr_coercion env crc)

  | S.DCTypedef crc ->
    let n = S.Decl.typedef_index decls in
    T.CProj(tps, n, tr_coercion env crc)

  | S.DCVal(name, crc) ->
    let n = S.Decl.val_index decls name in
    T.CProj(tps, n, tr_coercion env crc)

  | S.DCOp(xs, _, ops, inst, n) ->
    let name = S.OpDecl.name' ops n in
    let n    = S.Decl.op_index decls name in
    let (env, xs) = Env.add_tvars env xs in
    let (env, inst) = Type.tr_type_instances env inst in
    let (tp_pre, tp_post) = instantiate2 (List.nth tps n) inst in
    T.CTypeGen(xs, T.CProj(tps, n, T.CTypeApp(inst, tp_pre,
      T.CId(tp_post, tp_post))))

  | S.DCCtor(xs, _, ctors, inst, n) ->
    let name = S.CtorDecl.name' ctors n in
    let n    = S.Decl.ctor_index decls name in
    let (env, xs) = Env.add_tvars env xs in
    let (env, inst) = Type.tr_type_instances env inst in
    let (tp_pre, tp_post) = instantiate2 (List.nth tps n) inst in
    T.CTypeGen(xs, T.CProj(tps, n, T.CTypeApp(inst, tp_pre,
      T.CId(tp_post, tp_post))))

  | S.DCField(xs, _, flds, inst, n) ->
    let name = S.FieldDecl.name' flds n in
    let n    = S.Decl.field_index decls name in
    let (env, xs) = Env.add_tvars env xs in
    let (env, inst) = Type.tr_type_instances env inst in
    let (tp_pre, tp_post) = instantiate2 (List.nth tps n) inst in
    T.CTypeGen(xs, T.CProj(tps, n, T.CTypeApp(inst, tp_pre,
      T.CId(tp_post, tp_post))))

  | S.DCThisSel(decls', dc) ->
    let tps' = List.map (Type.tr_decl env) decls' in
    T.CProj(tps, S.Decl.this_index decls,
      tr_decl_coercion env decls' tps' dc)

  | S.DCOpVal(xs, s, ops, n, crc) ->
    let name = S.OpDecl.name' ops n in
    let (env1, xs) = Env.add_tvars env xs in
    let s   = Type.tr_type env1 s in
    let ops = List.map (Type.tr_op_decl env1) ops in
    T.CProj(tps, S.Decl.op_index decls name,
      T.CComp(
        coerce_forall_before xs (T.COpProxy(s, ops, n))
          (T.Coercion.op_proxy_type s ops n),
        tr_coercion env crc))

  | S.DCCtorVal(xs, tp, ctors, n, crc) ->
    let name = S.CtorDecl.name' ctors n in
    let (env1, xs) = Env.add_tvars env xs in
    let tp    = Type.tr_type env1 tp in
    let ctors = List.map (Type.tr_ctor_decl env1) ctors in
    T.CProj(tps, S.Decl.ctor_index decls name,
      T.CComp(
        coerce_forall_before xs (T.CCtorProxy(tp, ctors, n))
          (T.Coercion.ctor_proxy_type tp ctors n),
        tr_coercion env crc))
