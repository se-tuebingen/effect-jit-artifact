open TypingStructure
open TypeBinders

(** restrict unification variables and substitution to fit given scope.
  Returns None if domain does not have to be truncated, or Some sub,
  where sub is a identity substitution with restricted domain *)
let rec restrict_subst_to_scope : scope -> subst -> subst option =
  fun scope sub ->
  let exact = ref true in
  let tsub  = TypeSubst.filter 
    { filter_f = fun x tp ->
        if try_restrict_to_scope scope tp then true
        else (exact := false; false)
    } sub.sub_type in
  let isub  = EffInst.Map.filter
    (fun _ ie ->
        if try_restrict_effinst_to_scope scope ie then true
        else (exact := false; false)
    ) sub.sub_inst in
  if !exact then None
  else Some
    { sub_type = TypeSubst.map { map_f = fun x _ -> Type.var x } tsub
    ; sub_inst = EffInst.Map.mapi (fun a _ -> IEInstance a) isub
    }

and restrict_named_type_to_scope scope nt =
  restrict_to_scope scope nt.nt_type

and restrict_effinst_to_scope scope ie =
  match EffInstExpr.view ie with
  | IEInstance a ->
    if not (Scope.has_effinst scope a) then
      raise (Error CannotUnify)
    else ()
  | IEImplicit i ->
    restrict_to_scope scope i.iei_sig

and restrict_op_decl_to_scope scope op =
  match op with
  | OpDecl(_, xs, tps, extp) ->
    let (scope, xs, tps, extp) =
      open_named_types_ex_type_ts scope xs tps extp in
    List.iter (restrict_named_type_to_scope scope) tps;
    restrict_ex_type_to_scope scope extp

and restrict_ctor_decl_to_scope scope ctor =
  match ctor with
  | CtorDecl(_, ex, tps) ->
    let (scope, ex, tps) = open_named_types_ts scope ex tps in
    List.iter (restrict_named_type_to_scope scope) tps

and restrict_field_decl_to_scope scope fld =
  match fld with
  | FieldDecl(_, tp) ->
    restrict_to_scope scope tp

and restrict_decl_to_scope scope decl =
  match decl with
  | DeclThis tp    -> restrict_to_scope scope tp
  | DeclTypedef tp -> restrict_to_scope scope tp
  | DeclVal(_, tp) -> restrict_to_scope scope tp
  | DeclOp(xs, s, ops, n) ->
    let (scope, xs, (s, ops)) = open_ts
      (Subst.subst_pair Type.subst (Subst.subst_list Type.subst_op_decl))
      scope xs (s, ops) in
    restrict_to_scope scope s;
    List.iter (restrict_op_decl_to_scope scope) ops
  | DeclCtor(xs, tp, ctors, n) ->
    let (scope, xs, (tp, ctors)) = open_ts
      (Subst.subst_pair Type.subst (Subst.subst_list Type.subst_ctor_decl))
      scope xs (tp, ctors) in
    restrict_to_scope scope tp;
    List.iter (restrict_ctor_decl_to_scope scope) ctors
  | DeclField(xs, tp, flds, n) ->
    let (scope, xs, (tp, flds)) = open_ts
      (Subst.subst_pair Type.subst (Subst.subst_list Type.subst_field_decl))
      scope xs (tp, flds) in
    restrict_to_scope scope tp;
    List.iter (restrict_field_decl_to_scope scope) flds

and restrict_to_scope : type k. scope -> k typ -> unit =
  fun scope tp ->
  match Type.view tp with
  | TEffPure -> ()
  | TEffInst a -> restrict_effinst_to_scope scope a
  | TEffCons(eff1, eff2) ->
    restrict_to_scope scope eff1;
    restrict_to_scope scope eff2
  | TUVar(sub, u) ->
    begin match restrict_subst_to_scope scope sub with
    | None -> ()
    | Some sub ->
      begin match World.get_uvar u with
      | Some _ -> (* Variable has changed *)
        restrict_to_scope scope tp
      | None ->
        World.set_uvar u (Type.uvar sub (UVar.clone u))
      end
    end
  | TBase _ -> ()
  | TNeutral neu ->
    restrict_neutral_to_scope scope neu
  | TArrow(_, tp, extp, eff) ->
    restrict_to_scope scope tp;
    restrict_ex_type_to_scope scope extp;
    restrict_to_scope scope eff
  | TForall(xs, tp) ->
    let (scope, xs, tp) = open_type_ts scope xs tp in
    restrict_to_scope scope tp
  | TForallInst(a, s, tp) ->
    restrict_to_scope scope s;
    let (scope, a, tp) = open_type_i scope a tp in
    restrict_to_scope scope tp
  | THandler(s, tp1, eff1, tp2, eff2) ->
    restrict_to_scope         scope s;
    restrict_ex_type_to_scope scope tp1;
    restrict_to_scope         scope eff1;
    restrict_ex_type_to_scope scope tp2;
    restrict_to_scope         scope eff2
  | TFun(x, tp) ->
    let (scope, x, tp) = open_type_t scope x tp in
    restrict_to_scope scope tp
  | TStruct decls ->
    List.iter (restrict_decl_to_scope scope) decls
  | TTypeWit extp ->
    restrict_ex_type_to_scope scope extp
  | TEffectWit eff ->
    restrict_to_scope scope eff
  | TEffsigWit s ->
    restrict_to_scope scope s
  | TDataDef(tp, ctors) ->
    restrict_to_scope scope tp;
    List.iter (restrict_ctor_decl_to_scope scope) ctors
  | TRecordDef(tp, flds) ->
    restrict_to_scope scope tp;
    List.iter (restrict_field_decl_to_scope scope) flds
  | TEffsigDef(s, ops) ->
    restrict_to_scope scope s;
    List.iter (restrict_op_decl_to_scope scope) ops

and restrict_ex_type_to_scope scope (TExists(ex, tp)) =
  let (scope, ex, tp) = open_type_ts scope ex tp in
  restrict_to_scope scope tp

and restrict_neutral_to_scope : type k. scope -> k neutral_type -> unit =
  fun scope neu ->
  match neu with
  | TVar x ->
    if not (Scope.has_tvar scope x) then
      raise (Error CannotUnify)
    else ()
  | TApp(neu, tp) ->
    restrict_neutral_to_scope scope neu;
    restrict_to_scope scope tp

and try_restrict_to_scope : type k. scope -> k typ -> bool =
  fun scope tp ->
  World.try_bool (fun () -> restrict_to_scope scope tp)

and try_restrict_effinst_to_scope scope ie =
  World.try_bool (fun () -> restrict_effinst_to_scope scope ie)

(* ========================================================================= *)

let rec subeffect_in_scope scope eff =
  let proc_cons eff1 eff2 =
    if try_restrict_to_scope scope eff1 then
      Type.eff_cons eff1 (subeffect_in_scope scope eff2)
    else
      subeffect_in_scope scope eff2
  in
  match Type.row_view eff with
  | RPure -> Type.eff_pure
  | RUVar _ ->
    if try_restrict_to_scope scope eff then eff
    else Type.eff_pure
  | RConsEffInst(a, eff) ->
    proc_cons (Type.eff_inst a) eff
  | RConsNeutral(neu, eff) ->
    proc_cons (Type.neutral neu) eff
  | RConsUVar(sub, u, eff) ->
    proc_cons (Type.uvar sub u) eff

let rec coerce_to_scope scope (tp : ttype) : Syntax.coercion * ttype =
  match Type.view tp with
  | TUVar _ | TBase _ | TNeutral _ | TStruct _ | TTypeWit _ | TEffectWit _
  | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    restrict_to_scope scope tp;
    (CId(tp, tp), tp)
  | TArrow(name, tp, extp, eff) ->
    let (c1, tp')   = coerce_from_scope scope tp in
    let (c2, extp') = coerce_ex_type_to_scope scope extp in
    restrict_to_scope scope eff;
    (Coercion.carrow ?name_in:name ?name_out:name c1 c2 eff eff,
      Type.arrow ?name tp' extp' eff)
  | TForall(xs, tp) ->
    let (scope, xs, tp) = open_type_ts scope xs tp in
    let inst =
      List.map (fun (TVar.Pack x) -> Syntax.TpInst(x, Type.var x)) xs in
    let (c, tp') = coerce_to_scope scope tp in
    (Coercion.cgen (Coercion.cinst c inst tp) xs tp', Type.forall xs tp')
  | TForallInst(a, s, tp) ->
    restrict_to_scope scope s;
    let (scope, a, tp) = open_type_i scope a tp in
    let (c, tp') = coerce_to_scope scope tp in
    (Coercion.cforall_inst a s c, Type.forall_inst a s tp')
  | THandler(s, tp1, eff1, tp2, eff2) ->
    restrict_to_scope scope s;
    let (c1, tp1') = coerce_ex_type_from_scope scope tp1 in
    let eff1' = subeffect_in_scope scope eff1 in
    let (c2, tp2') = coerce_ex_type_to_scope scope tp2 in
    restrict_to_scope scope eff2;
    (Coercion.chandler s c1 eff1 eff1' c2 eff2 eff2,
      Type.handler s tp1' eff1' tp2' eff2)

and coerce_from_scope scope (tp : ttype) : Syntax.coercion * ttype =
  match Type.view tp with
  | TUVar _ | TBase _ | TNeutral _ | TStruct _ | TTypeWit _ | TEffectWit _
  | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ ->
    restrict_to_scope scope tp;
    (CId(tp, tp), tp)
  | TArrow(name, tp, extp, eff) ->
    let (c1, tp')   = coerce_to_scope scope tp in
    let (c2, extp') = coerce_ex_type_from_scope scope extp in
    let eff' = subeffect_in_scope scope eff in
    (Coercion.carrow ?name_in:name ?name_out:name c1 c2 eff' eff,
      Type.arrow ?name tp' extp' eff')
  | TForall(xs, tp) ->
    let (scope, xs, tp) = open_type_ts scope xs tp in
    let inst =
      List.map (fun (TVar.Pack x) -> Syntax.TpInst(x, Type.var x)) xs in
    let (c, tp') = coerce_from_scope scope tp in
    (Coercion.cgen (Coercion.cinst c inst tp') xs tp, Type.forall xs tp)
  | TForallInst(a, s, tp) ->
    restrict_to_scope scope s;
    let (scope, a, tp) = open_type_i scope a tp in
    let (c, tp') = coerce_from_scope scope tp in
    (Coercion.cforall_inst a s c, Type.forall_inst a s tp')
  | THandler(s, tp1, eff1, tp2, eff2) ->
    restrict_to_scope scope s;
    let (c1, tp1') = coerce_ex_type_to_scope scope tp1 in
    restrict_to_scope scope eff1;
    let (c2, tp2') = coerce_ex_type_from_scope scope tp2 in
    let eff2' = subeffect_in_scope scope eff2 in
    (Coercion.chandler s c1 eff1 eff1 c2 eff2' eff2,
      Type.handler s tp1' eff1 tp2' eff2')

and coerce_ex_type_to_scope scope (TExists(ex, tp)) :
    Syntax.ex_coercion * ex_type =
  let (scope, ex, tp) = open_type_ts scope ex tp in
  let (c, tp') = coerce_to_scope scope tp in
  let inst =
    List.map (fun (TVar.Pack x) -> Syntax.TpInst(x, Type.var x)) ex in
  (Coercion.cex_pack ex c inst tp', TExists(ex, tp'))

and coerce_ex_type_from_scope scope (TExists(ex, tp)) :
    Syntax.ex_coercion * ex_type =
  let (scope, ex, tp) = open_type_ts scope ex tp in
  let (c, tp') = coerce_from_scope scope tp in
  let inst =
    List.map (fun (TVar.Pack x) -> Syntax.TpInst(x, Type.var x)) ex in
  (Coercion.cex_pack ex c inst tp, TExists(ex, tp'))
