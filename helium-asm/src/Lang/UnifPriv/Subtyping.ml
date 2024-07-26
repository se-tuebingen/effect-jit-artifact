open TypingStructure
open Syntax
open TypeBinders
open Unification

let instantiate env xs =
  let inst = List.map (fun (TVar.Pack x) ->
    Syntax.TpInst(x, TypeUtils.fresh_uvar env (TVar.kind x))) xs in
  let sub = List.fold_left
    (fun sub (Syntax.TpInst(x, tp)) -> Subst.extend_t sub x tp)
    Subst.empty
    inst in
  (sub, inst)

let instantiate_ex env (TExists(xs, tp)) =
  let (sub, inst) = instantiate env xs in
  (inst, Type.subst sub tp)

let instantiate_args env xs =
  let (sub, insts) = instantiate env xs in
  (List.map (fun (TpInst(_, tp)) -> TpArg tp) insts, sub)

(* ========================================================================= *)
(* Subeffecting *)

let match_effinst_sub ~scope sub a =
  World.try_bool (fun () ->
    uvar_match_effinst ~scope sub (UVar.fresh KEffect) a)

let match_neutral_sub ~scope sub neu =
  World.try_bool (fun () ->
    unify_uvar_with_neutral ~scope sub (UVar.fresh KEffect) neu)

let rec restrict_effect_down ~scope sub eff =
  match Type.row_view eff with
  | RPure | RUVar _ -> eff
  | RConsEffInst(a, eff) ->
    if match_effinst_sub ~scope sub a then
      Type.eff_cons (Type.eff_inst a) (restrict_effect_down ~scope sub eff)
    else
      restrict_effect_down ~scope sub eff
  | RConsNeutral(neu, eff) ->
    if match_neutral_sub ~scope sub neu then
      Type.eff_cons (Type.neutral neu) (restrict_effect_down ~scope sub eff)
    else
      restrict_effect_down ~scope sub eff
  | RConsUVar(sub', u', eff) ->
    Type.eff_cons (Type.uvar sub' u') (restrict_effect_down ~scope sub eff)

let rec subeffect ~env eff1 eff2 =
  match Type.row_view eff1 with
  | RPure  -> ()
  | RUVar(sub, u) ->
    let eff2 = restrict_effect_down ~scope:(TypeEnv.scope env) sub eff2 in
    unify ~scope:(TypeEnv.scope env) eff1 eff2
  | RConsEffInst(a, eff1) ->
    find_instance_in_row ~scope:(TypeEnv.scope env) a eff2;
    subeffect ~env eff1 eff2
  | RConsNeutral(neu, eff1) ->
    find_neutral_in_row ~scope:(TypeEnv.scope env) neu eff2;
    subeffect ~env eff1 eff2
  | RConsUVar(sub, u, eff1) ->
    find_uvar_in_row ~scope:(TypeEnv.scope env) sub u eff2;
    subeffect ~env eff1 eff2

(* ========================================================================= *)
(* Infering coercion *)

let rec coerce ~env (tp1 : ttype) (tp2 : ttype) : Syntax.coercion =
  match Type.view tp1, Type.view tp2 with
  (* generalizaton *)
  | _, TForall(xs, tp2) ->
    let (env, xs, tp2) = TypeEnv.open_type_ts env xs tp2 in
    let c = coerce ~env tp1 tp2 in
    Coercion.cgen c xs tp2

  (* instantiation *)
  | TForall(xs, tp1), _ ->
    let (sub, inst) = instantiate env xs in
    let c = coerce ~env (Type.subst sub tp1) tp2 in
    Coercion.cinst c inst tp1

  (* fall-to-unification cases *)
  | TUVar _, (TUVar _ | TBase _ | TNeutral _ | TEffsigWit _ | TDataDef _
      | TRecordDef _ | TEffsigDef _)
  | TBase _, (TUVar _ | TBase _)
  | TNeutral _, (TUVar _ | TNeutral _)
  | TTypeWit _, (TUVar _ | TTypeWit _)
  | TEffectWit _, (TUVar _ | TEffectWit _)
  | TEffsigWit _, (TUVar _ | TEffsigWit _)
  | TDataDef _, TDataDef _
  | TRecordDef _, TRecordDef _
  | TEffsigDef _, TEffsigDef _ ->
    unify ~scope:(TypeEnv.scope env) tp1 tp2;
    CId(tp1, tp2)

  (* arrows *)
  | TUVar(sub, u), TArrow(name, arg, res, eff)
  | TArrow(name, arg, res, eff), TUVar(sub, u) ->
    (* Restricting arg and res may be too discriminative, since it would fail
       in cases like
       v <:? unit -> unit ->[α v] unit
       Probably we could find a weaker restriction, but it is not clear
       how it would look like. At least we don't have to restrict effect.  *)
    TypeUtils.restrict u arg;
    TypeUtils.restrict_ex_type u res;
    uvar_match_arrow ?name sub u;
    coerce ~env tp1 tp2
  | TArrow(name_in, arg1, res1, eff1), TArrow(name_out, arg2, res2, eff2) ->
    let c1 = coerce ~env arg2 arg1 in (* contravariant in argument *)
    let c2 = coerce_ex ~env res1 res2 in (* and covariant in result *)
    subeffect ~env eff1 eff2;
    Coercion.carrow ?name_in ?name_out c1 c2 eff1 eff2

  (* instance arrows *)
  | TUVar(sub, u), TForallInst(a, s, tp)
  | TForallInst(a, s, tp), TUVar(sub, u) ->
    TypeUtils.restrict u tp;
    uvar_match_forall_inst sub u;
    coerce ~env tp1 tp2
  | TForallInst(a1, s1, tp1), TForallInst(a2, s2, tp2) ->
    unify ~scope:(TypeEnv.scope env) s1 s2;
    let (env, a, tp1, tp2) = TypeEnv.open_type_i2 env a1 tp1 a2 tp2 in
    let c = coerce ~env tp1 tp2 in
    Coercion.cforall_inst a s1 c

  (* handlers *)
  | TUVar(sub, u), THandler(s, extp1, eff1, extp2, eff2)
  | THandler(s, extp1, eff1, extp2, eff2), TUVar(sub, u) ->
    TypeUtils.restrict_ex_type u extp1;
    TypeUtils.restrict_ex_type u extp2;
    uvar_match_handler sub u;
    coerce ~env tp1 tp2
  | THandler(s1, ta1, ea1, tb1, eb1), THandler(s2, ta2, ea2, tb2, eb2) ->
    unify ~scope:(TypeEnv.scope env) s1 s2;
    let c1 = coerce_ex ~env ta2 ta1 in
    subeffect ~env ea2 ea1;
    let c2 = coerce_ex ~env tb1 tb2 in
    subeffect ~env eb1 eb2;
    Coercion.chandler s1 c1 ea1 ea2 c2 eb1 eb2

  (* structures *)
  | TUVar _, TStruct _ ->
    (* structures are large *)
    raise (Error CannotUnify)
  | TStruct decls, (TUVar _ | TBase _ | TNeutral _ | TArrow _ | TForallInst _
      | THandler _ | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _
      | TRecordDef _ | TEffsigDef _) ->
    (* "this" resolution *)
    begin match Decl.select_this decls with
    | None     -> raise (Error CannotUnify)
    | Some tp1 -> Coercion.cthis decls (coerce ~env tp1 tp2)
    end
  | TStruct decls1, TStruct decls2 ->
    let cs = coerce_decls ~env decls1 decls2 in
    Coercion.cstruct decls1 cs

  (* type witness *)
  | TUVar(sub, u), TTypeWit extp ->
    TypeUtils.restrict_ex_type u extp;
    uvar_match_type_wit sub u;
    coerce ~env tp1 tp2
  | TDataDef(tp, ctors), (TUVar _ | TTypeWit _) ->
    unify ~scope:(TypeEnv.scope env) (Type.type_wit (TExists([], tp))) tp2;
    CDataDefSeal(tp, ctors)
  | TRecordDef(tp, flds), (TUVar _ | TTypeWit _) ->
    unify ~scope:(TypeEnv.scope env) (Type.type_wit (TExists([], tp))) tp2;
    CRecordDefSeal(tp, flds)

  (* effect witness *)
  | TUVar(sub, u), TEffectWit eff ->
    uvar_match_effect_wit sub u;
    coerce ~env tp1 tp2

  (* effsig witness *)
  | TEffsigDef(s, ops), (TUVar _ | TEffsigWit _) ->
    unify ~scope:(TypeEnv.scope env) (Type.effsig_wit s) tp2;
    CEffsigDefSeal(s, ops)

  (* not unifiable cases *)
  | TBase _, (TNeutral _ | TArrow _ | TForallInst _ | THandler _ | TStruct _
    | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
    | TEffsigDef _)
  | TNeutral _, (TBase _ | TArrow _ | TForallInst _ | THandler _ | TStruct _
    | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
    | TEffsigDef _)
  | TArrow _, (TBase _ | TNeutral _ | TForallInst _ | THandler _ | TStruct _
    | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
    | TEffsigDef _)
  | TForallInst _, (TBase _ | TNeutral _ | TArrow _ | THandler _ | TStruct _
    | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
    | TEffsigDef _)
  | THandler _, (TBase _ | TNeutral _ | TArrow _ | TForallInst _ | TTypeWit _
    | TStruct _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
    | TEffsigDef _)
  | TTypeWit _, (TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _
    | TStruct _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
    | TEffsigDef _)
  | TEffectWit _, (TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _
    | TStruct _ | TTypeWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
    | TEffsigDef _)
  | TEffsigWit _, (TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _
    | TStruct _ | TTypeWit _ | TEffectWit _ | TDataDef _ | TRecordDef _
    | TEffsigDef _)
  | TDataDef _, (TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _
    | TStruct _ | TEffectWit _ | TEffsigWit _ | TRecordDef _ | TEffsigDef _)
  | TRecordDef _, (TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _
    | TStruct _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TEffsigDef _)
  | TEffsigDef _, (TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _
    | TStruct _ | TTypeWit _ | TEffectWit _ | TDataDef _ | TRecordDef _) ->
    raise (Error CannotUnify)

and coerce_ex ~env (TExists(ex1, tp1)) (TExists(ex2, tp2)) =
  let (env, ex1, tp1) = TypeEnv.open_type_ts env ex1 tp1 in
  let (sub, inst) = instantiate env ex2 in
  let c = coerce ~env tp1 (Type.subst sub tp2) in
  Coercion.cex_pack ex1 c inst tp2

and coerce_decls ~env decls1 decls2 =
  List.map (coerce_decl ~env decls1) decls2

and coerce_decl ~env decls1 decl =
  match decl with
  | DeclThis tp2 ->
    begin match Decl.select_this decls1 with
    | None -> raise (Error CannotUnify)
    | Some tp1 ->
      DCThis(coerce ~env tp1 tp2)
    end
  | DeclTypedef tp2 ->
    begin match Decl.select_typedef decls1 with
    | None     -> coerce_this_decl ~env decls1 decl
    | Some tp1 ->
      DCTypedef (coerce ~env tp1 tp2)
    end
  | DeclVal(name, tp2) ->
    begin match Decl.select_val decls1 name with
    | None -> coerce_this_decl ~env decls1 decl
    | Some(VDVal tp1) ->
      DCVal(name, coerce ~env tp1 tp2)
    | Some(VDOp(xs, s, ops, n)) ->
      DCOpVal(xs, s, ops, n, coerce ~env (TypeUtils.op_type' xs s ops n) tp2)
    | Some(VDCtor(xs, tp, ctors, n)) ->
      DCCtorVal(xs, tp, ctors, n,
        coerce ~env (TypeUtils.ctor_type' xs tp ctors n) tp2)
    end
  | DeclOp(xs2, s2, ops2, n2) ->
    begin match Decl.select_op decls1 (Decl.op_decl_name' ops2 n2) with
    | None -> coerce_this_decl ~env decls1 decl
    | Some(xs1, s1, ops1, n1) ->
      if n1 <> n2 || List.length ops1 <> List.length ops2 then
        raise (Error CannotUnify)
      else begin
        let (env, xs2, s2, ops2) = TypeEnv.open_effsig_def env xs2 s2 ops2 in
        let (sub, insts) = instantiate env xs1 in
        let s1   = Type.subst sub s1 in
        let ops1 = List.map (Type.subst_op_decl sub) ops1 in
        unify ~scope:(TypeEnv.scope env) s1 s2;
        List.iter2 (unify_op_decl ~scope:(TypeEnv.scope env)) ops1 ops2;
        DCOp(xs2, s2, ops2, insts, n2)
      end
    end
  | DeclCtor(xs2, tp2, ctors2, n2) ->
    begin match Decl.select_ctor decls1 (Decl.ctor_decl_name' ctors2 n2) with
    | None -> coerce_this_decl ~env decls1 decl
    | Some(xs1, tp1, ctors1, n1) ->
      if n1 <> n2 || List.length ctors1 <> List.length ctors2 then
        raise (Error CannotUnify)
      else begin
        let (env, xs2, tp2, ctors2) =
          TypeEnv.open_data_def env xs2 tp2 ctors2 in
        let (sub, insts) = instantiate env xs1 in
        let tp1    = Type.subst sub tp1 in
        let ctors1 = List.map (Type.subst_ctor_decl sub) ctors1 in
        unify ~scope:(TypeEnv.scope env) tp1 tp2;
        List.iter2 (unify_ctor_decl ~scope:(TypeEnv.scope env)) ctors1 ctors2;
        DCCtor(xs2, tp2, ctors2, insts, n2)
      end
    end
  | DeclField(xs2, tp2, flds2, n2) ->
    begin match Decl.select_field decls1 (Decl.field_decl_name' flds2 n2) with
    | None -> coerce_this_decl ~env decls1 decl
    | Some(xs1, tp1, flds1, n1) ->
      if n1 <> n2 || List.length flds1 <> List.length flds2 then
        raise (Error CannotUnify)
      else begin
        let (env, xs2, tp2, flds2) =
          TypeEnv.open_record_def env xs2 tp2 flds2 in
        let (sub, insts) = instantiate env xs1 in
        let tp1   = Type.subst sub tp1 in
        let flds1 = List.map (Type.subst_field_decl sub) flds1 in
        unify ~scope:(TypeEnv.scope env) tp1 tp2;
        List.iter2 (unify_field_decl ~scope:(TypeEnv.scope env)) flds1 flds2;
        DCField(xs2, tp2, flds2, insts, n2)
      end
    end

and coerce_this_decl ~env decls decl =
  match Decl.select_this decls with
  | None -> raise (Error CannotUnify)
  | Some tp ->
    begin match Type.view tp with
    | TStruct decls' ->
      DCThisSel(decls', coerce_decl ~env decls' decl)
    | _ -> raise (Error CannotUnify)
    end

(* ========================================================================= *)
(* Coercing to particular type *)

let rec coerce_to_arrow ~env tp =
  match Type.view tp with
  | TArrow(_, tp1, tp2, eff) -> (CId(tp, tp), tp1, tp2, eff)
  | TUVar(sub, u) ->
    uvar_match_arrow sub u;
    coerce_to_arrow ~env tp
  | TForall(xs, tp_body) ->
    let (sub, inst) = instantiate env xs in
    let (c, tp1, tp2, eff) = coerce_to_arrow ~env (Type.subst sub tp_body) in
    (Coercion.cinst c inst tp_body, tp1, tp2, eff)
  | TStruct decls ->
    begin match Decl.select_this decls with
    | None    -> raise (Error CannotUnify)
    | Some tp ->
      let (crc, tp1, tp2, eff) = coerce_to_arrow ~env tp in
      (Coercion.cthis decls crc, tp1, tp2, eff)
    end
  | TBase _ | TNeutral _ | TForallInst _ | THandler _ | TTypeWit _
  | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
let rec coerce_to_forall_inst ~env tp =
  match Type.view tp with
  | TForallInst(a, s, rtp) -> (CId(tp, tp), a, s, rtp)
  | TUVar(sub, u) ->
    uvar_match_forall_inst sub u;
    coerce_to_forall_inst ~env tp
  | TForall(xs, tp1) ->
    let (sub, inst) = instantiate env xs in
    let (c, a, s, rtp) = coerce_to_forall_inst ~env (Type.subst sub tp1) in
    (Coercion.cinst c inst tp1, a, s, rtp)
  | TStruct decls ->
    begin match Decl.select_this decls with
    | None -> raise (Error CannotUnify)
    | Some tp ->
      let (crc, a, s, rtp) = coerce_to_forall_inst ~env tp in
      (Coercion.cthis decls crc, a, s, rtp)
    end

  | TBase _ | TNeutral _ | TArrow _ | THandler _ | TTypeWit _ | TEffectWit _
  | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
let rec coerce_to_handler ~env tp =
  match Type.view tp with
  | THandler(s, tp1, eff1, tp2, eff2) ->
    (CId(tp, tp), s, tp1, eff1, tp2, eff2)
  | TUVar(sub, u) ->
    uvar_match_handler sub u;
    coerce_to_handler ~env tp
  | TForall(xs, tp1) ->
    let (sub, inst) = instantiate env xs in
    let (c, s, extp1, eff1, extp2, eff2) =
      coerce_to_handler ~env (Type.subst sub tp1) in
    (Coercion.cinst c inst tp1, s, extp1, eff1, extp2, eff2)
  | TStruct decls ->
    begin match Decl.select_this decls with
    | None -> raise (Error CannotUnify)
    | Some tp ->
      let (crc, s, tp1, eff1, tp2, eff2) = coerce_to_handler ~env tp in
      (Coercion.cthis decls crc, s, tp1, eff1, tp2, eff2)
    end

  | TBase _ | TNeutral _ | TArrow _ | TForallInst _ | TTypeWit _
  | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
let rec coerce_to_type_wit ~env tp =
  match Type.view tp with
  | TTypeWit extp -> (CId(tp, tp), extp)
  | TDataDef(tp, ctors) ->
    (CDataDefSeal(tp, ctors), TExists([], tp))
  | TRecordDef(tp, flds) ->
    (CRecordDefSeal(tp, flds), TExists([], tp))
  | TUVar(sub, u) ->
    uvar_match_type_wit sub u;
    coerce_to_type_wit ~env tp
  | TForall(xs, tp1) ->
    let (sub, inst) = instantiate env xs in
    let (c, extp) = coerce_to_type_wit ~env (Type.subst sub tp1) in
    (Coercion.cinst c inst tp1, extp)
  | TStruct decls ->
    begin match Decl.select_this decls with
    | None -> raise (Error CannotUnify)
    | Some tp ->
      let (crc, extp) = coerce_to_type_wit ~env tp in
      (Coercion.cthis decls crc, extp)
    end

  | TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _ | TEffectWit _
  | TEffsigWit _ | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
let rec coerce_to_effect_wit ~env tp =
  match Type.view tp with
  | TEffectWit eff -> (CId(tp, tp), eff)
  | TUVar(sub, u) ->
    uvar_match_effect_wit sub u;
    coerce_to_effect_wit ~env tp
  | TForall(xs, tp1) ->
    let (sub, inst) = instantiate env xs in
    let (c, eff) = coerce_to_effect_wit ~env (Type.subst sub tp1) in
    (Coercion.cinst c inst tp1, eff)
  | TStruct decls ->
    begin match Decl.select_this decls with
    | None -> raise (Error CannotUnify)
    | Some tp ->
      let (crc, eff) = coerce_to_effect_wit ~env tp in
      (Coercion.cthis decls crc, eff)
    end

  | TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _ | TTypeWit _
  | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
let rec coerce_to_effsig_wit ~env tp =
  match Type.view tp with
  | TEffsigWit s -> (CId(tp, tp), s)
  | TEffsigDef(s, ops) ->
    (CEffsigDefSeal(s, ops), s)
  | TUVar(sub, u) ->
    uvar_match_effsig_wit sub u;
    coerce_to_effsig_wit ~env tp
  | TForall(xs, tp1) ->
    let (sub, inst) = instantiate env xs in
    let (c, s) = coerce_to_effsig_wit ~env (Type.subst sub tp1) in
    (Coercion.cinst c inst tp1, s)
  | TStruct decls ->
    begin match Decl.select_this decls with
    | None -> raise (Error CannotUnify)
    | Some tp ->
      let (crc, s) = coerce_to_effsig_wit ~env tp in
      (Coercion.cthis decls crc, s)
    end

  | TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _ | TTypeWit _
  | TEffectWit _ | TDataDef _ | TRecordDef _  ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
let rec coerce_to_data_def ~env tp =
  match Type.view tp with
  | TDataDef(dtp, ctors) -> (CId(tp, tp), dtp, ctors)
  | TForall(xs, tp1) ->
    let (sub, inst) = instantiate env xs in
    let (c, dtp, ctors) = coerce_to_data_def ~env (Type.subst sub tp1) in
    (Coercion.cinst c inst tp1, dtp, ctors)
  | TStruct decls ->
    begin match Decl.select_this decls with
    | None -> raise (Error CannotUnify)
    | Some tp ->
      let (crc, dtp, ctors) = coerce_to_data_def ~env tp in
      (Coercion.cthis decls crc, dtp, ctors)
    end

  | TUVar _ ->
    raise (Error CannotGuessNeutral)
  | TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _ | TTypeWit _
  | TEffectWit _ | TEffsigWit _ | TRecordDef _ | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
let rec coerce_to_neutral ~env tp =
  match Type.view tp with
  | TNeutral neu -> (CId(tp, tp), neu)
  | TForall(xs, tp1) ->
    let (sub, inst) = instantiate env xs in
    let (c, neu) = coerce_to_neutral ~env (Type.subst sub tp1) in
    (Coercion.cinst c inst tp1, neu)
  | TStruct decls ->
    begin match Decl.select_this decls with
    | None -> raise (Error CannotUnify)
    | Some tp ->
      let (crc, neu) = coerce_to_neutral ~env tp in
      (Coercion.cthis decls crc, neu)
    end

  | TUVar _ ->
    raise (Error CannotGuessNeutral)
  | TBase _ | TArrow _ | TForallInst _ | THandler _ | TTypeWit _ | TEffectWit _
  | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
let rec coerce_to_neutral_or_struct ~env tp =
  match Type.view tp with
  | TNeutral _ | TUVar _ -> (CId(tp, tp), Utils.Either.Left tp)
  | TStruct decls -> (CId(tp, tp), Utils.Either.Right decls)
  | TForall(xs, tp1) ->
    let (sub, inst) = instantiate env xs in
    let (c, opt) = coerce_to_neutral_or_struct ~env (Type.subst sub tp1) in
    (Coercion.cinst c inst tp1, opt)

  | TBase _ | TArrow _ | TForallInst _ | THandler _ | TTypeWit _ | TEffectWit _
  | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    raise (Error CannotUnify)

(* ------------------------------------------------------------------------- *)
let rec coerce_to_struct ~env tp =
  match Type.view tp with
  | TStruct decls -> (CId(tp, tp), decls)
  | TForall(xs, tp1) ->
    let (sub, inst) = instantiate env xs in
    let (c, opt) = coerce_to_struct ~env (Type.subst sub tp1) in
    (Coercion.cinst c inst tp1, opt)

  | TUVar _ | TBase _ | TNeutral _ | TArrow _ | TForallInst _ | THandler _
  | TTypeWit _ | TEffectWit _ | TEffsigWit _ | TDataDef _ | TRecordDef _
  | TEffsigDef _ ->
    raise (Error CannotUnify)
