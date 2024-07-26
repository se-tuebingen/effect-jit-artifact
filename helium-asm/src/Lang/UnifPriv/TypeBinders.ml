open TypingStructure

(* ========================================================================= *)
(* Unary binder opening *)

let open_t subst_m scope x m =
  let (x, m) =
    if Scope.has_tvar scope x then
      let y = TVar.clone x in
      (y, subst_m (Subst.rename_tvar x y) m)
    else (x, m) in
  (Scope.add_tvar scope x, x, m)

let open_i subst_m env a m =
  let (a, m) =
    if Scope.has_effinst env a then
      let b = EffInst.fresh () in
      (b, subst_m (Subst.rename_effinst a b) m)
    else (a, m) in
  (Scope.add_effinst env a, a, m)

let rec open_ts subst_m scope xs m =
  match xs with
  | [] -> (scope, [], m)
  | TVar.Pack x :: xs ->
    let (scope, x, (xs, m)) =
      open_t (Subst.subst_binder (Subst.subst_bvars) subst_m)
        scope x (xs, m) in
    let (scope, xs, m) = open_ts subst_m scope xs m in
    (scope, TVar.Pack x :: xs, m)

let open_type_t scope x tp =
  open_t Type.subst scope x tp

let open_type_ts scope xs tp =
  open_ts Type.subst scope xs tp

let open_named_types_ts scope xs tps =
  open_ts (Subst.subst_list Type.subst_named_type) scope xs tps

let open_named_types_ex_type_ts scope xs tps extp =
  let (scope, xs, (tps, extp)) =
    open_ts
      (Subst.subst_pair
        (Subst.subst_list Type.subst_named_type)
        Type.subst_ex_type)
      scope xs (tps, extp) in
  (scope, xs, tps, extp)

let open_type_i scope a tp =
  open_i Type.subst scope a tp

(* ========================================================================= *)
(* Binary binder opening *)

let open_t2 subst_m scope x1 m1 x2 m2 =
  let (x, m1, m2) =
    if TVar.equal x1 x2 && not (Scope.has_tvar scope x1) then
      (x1, m1, m2)
    else
      let x = TVar.clone x1 in
      let m1 = subst_m (Subst.rename_tvar x1 x) m1 in
      let m2 = subst_m (Subst.rename_tvar x2 x) m2 in
      (x, m1, m2) in
  (Scope.add_tvar scope x, x, m1, m2)

let open_i2 subst_m scope a1 m1 a2 m2 =
  let (a, m1, m2) =
    if EffInst.equal a1 a2 && not (Scope.has_effinst scope a1) then
      (a1, m1, m2)
    else
      let a = EffInst.fresh () in
      let m1 = subst_m (Subst.rename_effinst a1 a) m1 in
      let m2 = subst_m (Subst.rename_effinst a2 a) m2 in
      (a, m1, m2) in
  (Scope.add_effinst scope a, a, m1, m2)

let open_unify_te2 subst_m scope (TVar.Pack x1) m1 (TVar.Pack x2) m2 =
  match Kind.equal (TVar.kind x1) (TVar.kind x2) with
  | Equal ->
    let (scope, x, m1, m2) = open_t2 subst_m scope x1 m1 x2 m2 in
    (scope, TVar.Pack x, m1, m2)
  | NotEqual -> raise (Error CannotUnify)

let rec open_unify_ts2 subst_m scope xs1 m1 xs2 m2 =
  match xs1, xs2 with
  | [], [] -> (scope, [], m1, m2)
  | (x1 :: xs1), (x2 :: xs2) ->
    let (scope, x, (xs1, m1), (xs2, m2)) =
      open_unify_te2
        (Subst.subst_binder (Subst.subst_bvars) subst_m)
        scope 
        x1 (xs1, m1)
        x2 (xs2, m2) in
    let (scope, xs, m1, m2) = open_unify_ts2 subst_m scope xs1 m1 xs2 m2 in
    (scope, x :: xs, m1, m2)
  | [], (_ :: _) | (_ :: _), [] -> raise (Error CannotUnify)

let open_type_i2 scope a1 tp1 a2 tp2 =
  open_i2 Type.subst scope a1 tp1 a2 tp2
