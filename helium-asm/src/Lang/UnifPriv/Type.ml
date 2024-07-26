open TypingStructure

type 'k t = 'k typ

(* ========================================================================= *)
(* Constructors *)

let uvar sub u =
  let r = TypeRef.fresh (UVarBase.kind u) in
  World.set_type r (TV_UVar(sub, u));
  TyType r

let base tp = TyBase tp

let var x = TyNeutral (TVar x)

let eff_pure           = TyEffPure
let eff_inst a         = TyEffInst a
let eff_ivar a         = TyEffInst (IEInstance a)
let eff_cons eff1 eff2 = TyEffCons(eff1, eff2)

let arrow ?name tp extp eff  = TyArrow(name, tp, extp, eff)
let arrow' ?name tp1 tp2 eff = TyArrow(name, tp1, TExists([], tp2), eff)

let handler s t1 e1 t2 e2 = TyHandler(s, t1, e1, t2, e2)

let forall_inst a s tp = TyForallInst(a, s, tp)
let tstruct decls      = TyStruct decls
let type_wit extp      = TyTypeWit extp
let effect_wit eff     = TyEffectWit eff
let effsig_wit s       = TyEffsigWit s
let data_def tp ctors  = TyDataDef(tp, ctors)
let record_def tp flds = TyRecordDef(tp, flds)
let effsig_def s ops   = TyEffsigDef(s, ops)

let tfun x tp    = TyFun(x, tp)
let forall xs tp =
  match xs with
  | [] -> tp
  | _  -> TyForall(xs, tp)

let neutral neu    = TyNeutral neu
let neu_app neu tp = TyNeutral(TApp(neu, tp))

(* ========================================================================= *)
(* Kind of *)

let rec kind_of_neutral : type k. k neutral_type -> k kind =
  function
  | TVar x -> TVar.kind x
  | TApp(neu, _) ->
    begin match kind_of_neutral neu with
    | KArrow(_, k) -> k
    end

let rec kind : type k. k typ -> k kind =
  function
  | TyEffPure      -> KEffect
  | TyEffInst    _ -> KEffect
  | TyEffCons    _ -> KEffect
  | TyBase       _ -> KType
  | TyNeutral neu  -> kind_of_neutral neu
  | TyType  r      -> TypeRef.kind r
  | TyArrow      _ -> KType
  | TyForall     _ -> KType
  | TyForallInst _ -> KType
  | TyHandler    _ -> KType
  | TyFun(x, tp)   -> KArrow(TVar.kind x, kind tp)
  | TyStruct     _ -> KType
  | TyTypeWit    _ -> KType
  | TyEffectWit  _ -> KType
  | TyEffsigWit  _ -> KType
  | TyDataDef    _ -> KType
  | TyRecordDef  _ -> KType
  | TyEffsigDef  _ -> KType

(* ========================================================================= *)
(* Substitution *)

let subst_var sub x =
  match TypeSubst.find_opt x sub.sub_type with
  | None    -> var x
  | Some tp -> tp

let subst_effinst sub a =
  match EffInst.Map.find_opt a sub.sub_inst with
  | None   -> IEInstance a
  | Some a -> a

let subst_extend_var sub x tp =
  { sub with
    sub_type = TypeSubst.add x tp sub.sub_type
  }

let subst_bvar sub x =
  let y = TVar.clone x in
  (y, subst_extend_var sub x (var y))

let subst_binst sub a =
  let b = EffInst.fresh () in
  (b, { sub with
        sub_inst = EffInst.Map.add a (IEInstance b) sub.sub_inst
      })

let rec subst_bvars sub xs =
  match xs with
  | [] -> ([], sub)
  | TVar.Pack x :: xs ->
    let (x,  sub) = subst_bvar  sub x in
    let (xs, sub) = subst_bvars sub xs in
    (TVar.Pack x :: xs, sub)

(* Merge two substitution. This function combined with the next one
  (subst_in_subst) create composition of substitution:
  merge_subst sub1 (subst_in_subst sub1 sub2) *)
let merge_subst sub1 sub2 =
  { sub_type = TypeSubst.merge { merge_f = fun x tp1 tp2 ->
        match tp2 with
        | Some _ -> tp2
        | None -> tp1
      } sub1.sub_type sub2.sub_type
  ; sub_inst = EffInst.Map.merge (fun _ a b ->
        match b with
        | Some _ -> b
        | None   -> a
      ) sub1.sub_inst sub2.sub_inst
  }

(* This is NOT a composition of substitution. We cannot change the domain
  of sub', since it describes a scope of unification variable *)
let rec subst_in_subst sub sub' =
  { sub_type = TypeSubst.map { map_f = fun _ tp -> subst sub tp } sub'.sub_type
  ; sub_inst = EffInst.Map.map (subst_effinst_expr sub) sub'.sub_inst
  }

and subst_named_type sub nt =
  { nt_name = nt.nt_name
  ; nt_type = subst sub nt.nt_type
  }

and subst_op_decl sub op =
  match op with
  | OpDecl(name, xs, tps, extp) ->
    let (xs, sub) = subst_bvars sub xs in
    OpDecl(name, xs, List.map (subst_named_type sub) tps,
      subst_ex_type sub extp)

and subst_ctor_decl sub ctor =
  match ctor with
  | CtorDecl(name, xs, tps) ->
    let (xs, sub) = subst_bvars sub xs in
    CtorDecl(name, xs, List.map (subst_named_type sub) tps)

and subst_field_decl sub fld =
  match fld with
  | FieldDecl(name, tp) ->
    FieldDecl(name, subst sub tp)

and subst_decl sub decl =
  match decl with
  | DeclThis tp           -> DeclThis(subst sub tp)
  | DeclTypedef tp        -> DeclTypedef(subst sub tp)
  | DeclVal(name, tp)     -> DeclVal(name, subst sub tp)
  | DeclOp(xs, s, ops, n) ->
    let (xs, sub) = subst_bvars sub xs in
    DeclOp(xs, subst sub s, List.map (subst_op_decl sub) ops, n)
  | DeclCtor(xs, tp, ctors, n) ->
    let (xs, sub) = subst_bvars sub xs in
    DeclCtor(xs, subst sub tp, List.map (subst_ctor_decl sub) ctors, n)
  | DeclField(xs, tp, flds, n) ->
    let (xs, sub) = subst_bvars sub xs in
    DeclField(xs, subst sub tp, List.map (subst_field_decl sub) flds, n)

and subst_effinst_expr sub ie =
  match EffInstExpr.view ie with
  | IEInstance a -> subst_effinst sub a
  | IEImplicit i -> IEImplicit i

and subst : type k. subst -> k typ -> k typ =
  fun sub tp ->
  match tp with
  | TyEffPure   -> TyEffPure
  | TyEffInst a -> TyEffInst (subst_effinst_expr sub a)
  | TyEffCons(eff1, eff2) ->
    TyEffCons(subst sub eff1, subst sub eff2)
  | TyType r ->
    begin match World.get_type r with
    | TV_UVar(sub', u) ->
      begin match World.get_uvar u with
      | None ->
        let new_sub = subst_in_subst sub sub' in
        let r = TypeRef.clone r in
        World.set_type r (TV_UVar(new_sub, u));
        TyType r
      | Some tp ->
        let tp = subst sub' tp in
        World.set_type r (TV_Type tp);
        subst sub tp
      end
    | TV_Type tp -> subst sub tp
    end
  | TyBase base   -> TyBase base
  | TyNeutral neu -> subst_neutral sub neu
  | TyArrow(name, tp, extp, eff) ->
    TyArrow(name, subst sub tp, subst_ex_type sub extp, subst sub eff)
  | TyForall(xs, tp) ->
    let (xs, sub) = subst_bvars sub xs in
    TyForall(xs, subst sub tp)
  | TyForallInst(a, s, tp) ->
    let s = subst sub s in
    let (a, sub) = subst_binst sub a in
    TyForallInst(a, s, subst sub tp)
  | TyHandler(s, tp1, eff1, tp2, eff2) ->
    TyHandler(
      subst         sub s,
      subst_ex_type sub tp1,
      subst         sub eff1,
      subst_ex_type sub tp2,
      subst         sub eff2)
  | TyFun(x, tp) ->
    let (x, sub) = subst_bvar sub x in
    TyFun(x, subst sub tp)
  | TyStruct decls ->
    TyStruct (List.map (subst_decl sub) decls)
  | TyTypeWit extp ->
    TyTypeWit (subst_ex_type sub extp)
  | TyEffectWit eff ->
    TyEffectWit (subst sub eff)
  | TyEffsigWit s ->
    TyEffsigWit (subst sub s)
  | TyDataDef(tp, ctors) ->
    TyDataDef(subst sub tp, List.map (subst_ctor_decl sub) ctors)
  | TyRecordDef(tp, flds) ->
    TyRecordDef(subst sub tp, List.map (subst_field_decl sub) flds)
  | TyEffsigDef(s, ops) ->
    TyEffsigDef(subst sub s, List.map (subst_op_decl sub) ops)

and subst_ex_type sub tp =
  match tp with
  | TExists(xs, tp) ->
    let (xs, sub) = subst_bvars sub xs in
    TExists(xs, subst sub tp)

and subst_neutral : type k. subst -> k neutral_type -> k typ =
  fun sub neu ->
  match neu with
  | TVar x         -> subst_var sub x
  | TApp(tp1, tp2) -> app (subst_neutral sub tp1) (subst sub tp2)

and subst_type : type k1 k2. k1 tvar -> k1 typ -> k2 typ -> k2 typ =
  fun x tp1 tp2 ->
  subst
    { sub_type = TypeSubst.singleton x tp1
    ; sub_inst = EffInst.Map.empty
    } tp2

and app : type k1 k2. (k1 -> k2) typ -> k1 typ -> k2 typ =
  fun tp1 tp2 ->
  match tp1 with
  | TyNeutral neu -> TyNeutral(TApp(neu, tp2))
  | TyType r ->
    begin match World.get_type r with
    | TV_UVar(sub, u) ->
      begin match World.get_uvar u with
      | None ->
        let KArrow(k1, k2) = UVarBase.kind u in
        let x  = TVar.fresh k1 in
        let u' = UVarBase.fresh k2 in
        let r' = TypeRef.fresh k2 in
        World.set_type r'
          (TV_UVar(subst_extend_var sub x (var x), u'));
        World.set_uvar u (TyFun(x, TyType r'));
        let r = TypeRef.fresh k2 in
        World.set_type r
          (TV_UVar(subst_extend_var sub x tp2, u'));
        TyType r
      | Some tp ->
        let tp = subst sub tp in
        World.set_type r (TV_Type tp);
        app tp tp2
      end
    | TV_Type tp -> app tp tp2
    end
  | TyFun(x, tp) ->
    subst_type x tp2 tp

let subst_inst a b tp =
  subst
    { sub_type = TypeSubst.empty; sub_inst = EffInst.Map.singleton a b }
    tp

(* ========================================================================= *)
(* View *)

let rec view : type k. k typ -> k type_view =
  fun tp ->
  match tp with
  | TyEffPure   -> TEffPure
  | TyEffInst a -> TEffInst a
  | TyEffCons(eff1, eff2) -> TEffCons(eff1, eff2)
  | TyType r ->
    begin match World.get_type r with
    | TV_UVar(sub, u) ->
      begin match World.get_uvar u with
      | None    -> TUVar(sub, u)
      | Some tp ->
        let tp = subst sub tp in
        World.set_type r (TV_Type tp);
        view tp
      end
    | TV_Type tp -> view tp
    end
  | TyBase base                  -> TBase base
  | TyNeutral neu                -> TNeutral neu
  | TyArrow(name, tp, extp, eff) -> TArrow(name, tp, extp, eff)
  | TyForall(xs, tp)             -> TForall(xs, tp)
  | TyForallInst(a, s, tp)       -> TForallInst(a, s, tp)
  | TyHandler(s, t1, e1, t2, e2) -> THandler(s, t1, e1, t2, e2)
  | TyFun(x, tp)                 -> TFun(x, tp)
  | TyStruct decls               -> TStruct decls
  | TyTypeWit extp               -> TTypeWit extp
  | TyEffectWit eff              -> TEffectWit eff
  | TyEffsigWit s                -> TEffsigWit s
  | TyDataDef(tp, ctors)         -> TDataDef(tp, ctors)
  | TyRecordDef(tp, flds)        -> TRecordDef(tp, flds)
  | TyEffsigDef(s,  ops)         -> TEffsigDef(s, ops)

(* ========================================================================= *)
(* Row view *)

let rec row_view (eff : effect) =
  match view eff with
  | TEffPure   -> RPure
  | TEffInst a -> RConsEffInst(a, TyEffPure)
  | TEffCons(eff1, eff2) ->
    begin match row_view eff1 with
    | RPure -> row_view eff2
    | RUVar(sub, u) ->
      begin match row_view eff2 with
      | RPure                   -> RUVar(sub, u)
      | RConsEffInst(a, eff2)   -> RConsEffInst(a, TyEffCons(eff1, eff2))
      | RConsNeutral(neu, eff2) -> RConsNeutral(neu, TyEffCons(eff1, eff2))
      | RUVar _ | RConsUVar _   -> RConsUVar(sub, u, eff2)
      end
    | RConsEffInst(a, eff1) -> RConsEffInst(a, TyEffCons(eff1, eff2))
    | RConsNeutral(neu, eff1)  ->
      begin match row_view eff2 with
      | RPure  -> RConsNeutral(neu, eff1)
      | RConsEffInst(a, eff2) -> RConsEffInst(a, TyEffCons(eff1, eff2))
      | RUVar _ | RConsNeutral _ | RConsUVar _ ->
        RConsNeutral(neu, TyEffCons(eff1, eff2))
      end
    | RConsUVar(sub, u, eff1) ->
      begin match row_view eff2 with
      | RPure                    -> RConsUVar(sub, u, eff1)
      | RConsEffInst(a, eff2)    -> RConsEffInst(a, TyEffCons(eff1, eff2))
      | RConsNeutral(neu, eff2)  -> RConsNeutral(neu, TyEffCons(eff1, eff2))
      | RUVar _ | RConsUVar _    -> RConsUVar(sub, u, TyEffCons(eff1, eff2))
      end
    end
  | TUVar(sub, x) -> RUVar(sub, x)
  | TNeutral neu -> RConsNeutral(neu, TyEffPure)
