open TypingStructure

type t =
  { scope : scope
  }

let empty =
  { scope = Scope.empty
  }

let has_tvar    env x = Scope.has_tvar    env.scope x
let has_effinst env a = Scope.has_effinst env.scope a

let scope env = env.scope

let add_tvar env x =
  { scope = Scope.add_tvar env.scope x }

let add_tvar_e env (TVar.Pack x) =
  add_tvar env x

let add_tvar_l env xs =
  List.fold_left add_tvar_e env xs

let add_effinst env a =
  { scope = Scope.add_effinst env.scope a }

let open_type_i env a tp =
  let (scope, a, tp) = TypeBinders.open_type_i env.scope a tp in
  ({ scope = scope }, a, tp)

let open_type_i2 env a1 tp1 a2 tp2 =
  let (scope, a, tp1, tp2) =
    TypeBinders.open_type_i2 env.scope a1 tp1 a2 tp2 in
  ({ scope = scope }, a, tp1, tp2)

let open_type_ts env xs tp =
  let (scope, xs, tp) = TypeBinders.open_type_ts env.scope xs tp in
  ({ scope = scope }, xs, tp)

let open_named_types_ts env xs tps =
  let (scope, xs, tps) = TypeBinders.open_named_types_ts env.scope xs tps in
  ({ scope = scope }, xs, tps)

let open_named_types_ex_type_ts env xs tps extp =
  let (scope, xs, tps, extp) =
    TypeBinders.open_named_types_ex_type_ts env.scope xs tps extp in
  ({ scope = scope }, xs, tps, extp)

let open_effsig_def env xs s ops =
  let (scope, xs, (s, ops)) =
    TypeBinders.open_ts
      (Subst.subst_pair Type.subst (Subst.subst_list Type.subst_op_decl))
      env.scope xs (s, ops)
  in
  ({ scope = scope }, xs, s, ops)

let open_data_def env xs tp ctors =
  let (scope, xs, (tp, ctors)) =
    TypeBinders.open_ts
      (Subst.subst_pair Type.subst (Subst.subst_list Type.subst_ctor_decl))
      env.scope xs (tp, ctors)
  in
  ({ scope = scope }, xs, tp, ctors)

let open_record_def env xs tp flds =
  let (scope, xs, (tp, flds)) =
    TypeBinders.open_ts
      (Subst.subst_pair Type.subst (Subst.subst_list Type.subst_field_decl))
      env.scope xs (tp, flds)
  in
  ({ scope = scope }, xs, tp, flds)
