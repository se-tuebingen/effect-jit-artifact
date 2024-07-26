open Lang.Node
open Common

let rec instantiate meta env inst v cont =
  let make data = { meta = meta; data = data } in
  match inst with
  | [] -> cont v
  | S.TpInst(_, tp) :: inst ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.ETypeApp(v, Type.tr_type env tp)),
      instantiate meta env inst (make (T.VVar x)) cont))

let rec generalize meta xs exp =
  let make data = { meta = meta; data = data } in
  match xs with
  | [] -> exp
  | T.TVar.Pack x :: xs ->
    make (T.EValue (make (T.VTypeFun(x, generalize meta xs exp))))

let rec generalize_val meta env xs cont =
  let make data = { meta = meta; data = data } in
  match xs with
  | [] -> cont env []
  | S.TVar.Pack x :: xs ->
    let (env, x) = Env.add_tvar env x in
    make (T.VTypeFun(x, make (T.EValue(
      generalize_val meta env xs (fun env xs ->
        cont env (T.TVar.Pack x :: xs))))))

let rec gen_and_inst_expr meta env xs inst e =
  let make data = { meta = meta; data = data } in
  let (env, xs) = Env.add_tvars env xs in
  generalize meta xs (
  let x = T.Var.fresh () in
  make (T.ELetPure(x, e,
  instantiate meta env inst (make (T.VVar x)) (fun v ->
  make (T.EValue v)))))

let rec bind_apply_tvars meta exp xs cont =
  let make data = { meta = meta; data = data } in
  let x = T.Var.fresh () in
  make (T.ELetPure(x, exp,
  let v = make (T.VVar x) in
  match xs with
  | [] -> cont v
  | T.TVar.Pack x :: xs ->
    bind_apply_tvars meta (make (T.ETypeApp(v, T.Type.var x))) xs cont))

let rec abstract_vals meta tps cont =
  let make data = { meta = meta; data = data } in
  match tps with
  | [] -> cont []
  | tp :: tps ->
    let x = T.Var.fresh () in
    make (T.EValue (make (T.VFn(x, tp,
      abstract_vals meta tps (fun args ->
        cont (make (T.VVar x) :: args))))))

let op_proxy meta env xs s n (S.OpDecl(_, ys, tps, tp)) proof_e =
  let make data = { meta = meta; data = data } in
  generalize_val meta env xs (fun env xs ->
  let a = T.EffInst.fresh () in
  make (T.VInstFun(a, Type.tr_type env s,
  bind_apply_tvars meta proof_e xs (fun proof ->
  let (env, ys) = Env.add_tvars env ys in
  generalize meta ys (
  abstract_vals meta (List.map (Type.tr_named_type env) tps) (fun args ->
  make (T.EOp(proof, n, a,
    List.map (fun (T.TVar.Pack y) -> T.TpArg (T.Type.var y)) ys,
    args))))))))

let ctor_proxy meta env xs n (S.CtorDecl(_, ys, tps)) proof_e =
  let make data = { meta = meta; data = data } in
  let (env, xs) = Env.add_tvars env xs in
  generalize meta xs (
  bind_apply_tvars meta proof_e xs (fun proof ->
  let (env, ys) = Env.add_tvars env ys in
  generalize meta ys (
  abstract_vals meta (List.map (Type.tr_named_type env) tps) (fun args ->
  make (T.EValue(make (T.VCtor(proof, n,
    List.map (fun (T.TVar.Pack y) -> T.TpArg (T.Type.var y)) ys,
    args))))))))

let rec coerce meta env crc v =
  let make data = { meta = meta; data = data } in
  match crc with
  | S.CId _ -> make (T.EValue v)
  | S.CArrow { arg_crc; res_crc; _ } ->
    let x  = T.Var.fresh () in
    let tp = Type.tr_type env (S.Coercion.input_type arg_crc) in
    make (T.EValue (make (T.VFn(x, tp,
      let y = T.Var.fresh () in
      make (T.ELetPure(y, coerce meta env arg_crc (make (T.VVar x)),
        let z = T.Var.fresh () in
        make (T.ELet(z, make (T.EApp(v, (make (T.VVar y)))),
          coerce_ex meta env res_crc (make (T.VVar z))))))))))
  | S.CGen(c, xs, _) ->
    let (env, xs) = Env.add_tvars env xs in
    generalize meta xs (coerce meta env c v)
  | S.CInst(c, inst, _) ->
    instantiate meta env inst v (fun v ->
    coerce meta env c v)
  | S.CForallInst(a, s, c) ->
    let s = Type.tr_type env s in
    let (env, a) = Env.add_effinst env a in
    make (T.EValue(make (T.VInstFun(a, s,
      let x = T.Var.fresh () in
      make (T.ELet(x, make (T.EInstApp(v, a)),
        coerce meta env c (make (T.VVar x))))))))
  | S.CHandler cdata ->
    let a = S.EffInst.fresh () in
    let crc = S.CArrow
      { name_in  = None
      ; name_out = None
      ; arg_crc  = S.CForallInst(a, cdata.effsig, S.CArrow
        { name_in  = None
        ; name_out = None
        ; arg_crc  = S.CId(S.Type.tstruct [], S.Type.tstruct [])
        ; res_crc  = cdata.in_crc
        ; eff_in   = S.Type.eff_cons (S.Type.eff_ivar a) cdata.in_eff_out
        ; eff_out  = S.Type.eff_cons (S.Type.eff_ivar a) cdata.in_eff_in
        })
      ; res_crc  = cdata.out_crc
      ; eff_in   = cdata.out_eff_in
      ; eff_out  = cdata.out_eff_out
      }
    in
    coerce meta env crc v
  | S.CStruct(decls, dcs) ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.EValue v),
    coerce_decls meta env decls dcs (make (T.VVar x)) (fun vs ->
    make (T.EValue (make (T.VTuple vs))))))
  | S.CDataDefSeal _ | S.CRecordDefSeal _ | S.CEffsigDefSeal _ ->
    make (T.EValue (make (T.VTuple [])))
  | S.CThis(decls, crc) ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x,
      make (T.EProj(v, S.Decl.this_index decls)),
      coerce meta env crc (make (T.VVar x))))
  | S.CApplyInst(crc1, a, crc2) ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, coerce meta env crc1 v,
    let y = T.Var.fresh () in
    make (T.ELetPure(y,
      make (T.EInstApp(make (T.VVar x), Type.tr_effinst_expr env a)),
    coerce meta env crc2 (make (T.VVar y))))))

and coerce_ex meta env crc v =
  let make data = { meta = meta; data = data } in
  match crc with
  | S.CExId _ -> make (T.EValue v)
  | S.CExPack(xs, crc, insts, tp) ->
    Pack.unpack_value meta env xs v (fun env v ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, coerce meta env crc v,
    let v = make (T.VVar x) in
    let (v, _) = Pack.pack_value meta env insts (S.TExists([], tp)) v in
    make (T.EValue v))))

and coerce_decl meta env decls dc v =
  let make data = { meta = meta; data = data } in
  match dc with
  | S.DCThis crc ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.EProj(v, S.Decl.this_index decls)),
    coerce meta env crc (make (T.VVar x))))
  | S.DCTypedef crc ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.EProj(v, S.Decl.typedef_index decls)),
    coerce meta env crc (make (T.VVar x))))
  | S.DCVal(name, crc) ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.EProj(v, S.Decl.val_index decls name)),
    coerce meta env crc (make (T.VVar x))))
  | S.DCOp(xs, _, ops, inst, n) ->
    let name = S.OpDecl.name' ops n in
    gen_and_inst_expr meta env xs inst
      (make (T.EProj(v, S.Decl.op_index decls name)))
  | S.DCCtor(xs, _, ctors, inst, n) ->
    let name = S.CtorDecl.name' ctors n in
    gen_and_inst_expr meta env xs inst
      (make (T.EProj(v, S.Decl.ctor_index decls name)))
  | S.DCField(xs, _, flds, inst, n) ->
    let name = S.FieldDecl.name' flds n in
    gen_and_inst_expr meta env xs inst
      (make (T.EProj(v, S.Decl.field_index decls name)))
  | S.DCThisSel(decls', dc) ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, make (T.EProj(v, S.Decl.this_index decls)),
    coerce_decl meta env decls' dc (make (T.VVar x))))
  | S.DCOpVal(xs, s, ops, n, crc) ->
    let name = S.OpDecl.name' ops n in
    let v1 =
      op_proxy meta env xs s n (List.nth ops n)
        (make (T.EProj(v, S.Decl.op_index decls name))) in
    coerce meta env crc v1
  | S.DCCtorVal(xs, tp, ctors, n, crc) ->
    let name = S.CtorDecl.name' ctors n in
    let x = T.Var.fresh () in
    make (T.ELetPure(x,
      ctor_proxy meta env xs n (List.nth ctors n)
        (make (T.EProj(v, S.Decl.ctor_index decls name))),
    coerce meta env crc (make (T.VVar x))))

and coerce_decls meta env decls dcs v cont =
  let make data = { meta = meta; data = data } in
  match dcs with
  | [] -> cont []
  | dc :: dcs ->
    let x = T.Var.fresh () in
    make (T.ELetPure(x, coerce_decl meta env decls dc v,
    coerce_decls meta env decls dcs v (fun vs ->
    cont (make (T.VVar x) :: vs))))
