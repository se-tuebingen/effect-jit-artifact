open TypingStructure

let rec open_effect_up ~env (eff : effect) =
  match Type.row_view eff with
  | RPure   -> TypeUtils.fresh_uvar env KEffect
  | RUVar _ | RConsUVar _ -> eff
  | RConsEffInst(a, eff) ->
    Type.eff_cons (Type.eff_inst a) (open_effect_up ~env eff)
  | RConsNeutral(neu, eff) ->
    Type.eff_cons (Type.neutral neu) (open_effect_up ~env eff)

let rec open_type_up ~env (tp : ttype) =
  match Type.view tp with
  | TUVar _ | TBase _ | TNeutral _ | TStruct _ | TTypeWit _ | TEffectWit _
  | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ -> 
    tp

  | TArrow(name, tp1, extp, eff) ->
    Type.arrow ?name
      (open_type_down ~env tp1)
      (open_ex_type_up ~env extp)
      (open_effect_up ~env eff)
  | TForall(xs, tp) ->
    let (env, xs, tp) = TypeEnv.open_type_ts env xs tp in
    Type.forall xs (open_type_up ~env tp)
  | TForallInst(a, s, tp) ->
    let (env, a, tp) = TypeEnv.open_type_i env a tp in
    Type.forall_inst a s (open_type_up ~env tp)
  | THandler(s, tp1, eff1, tp2, eff2) ->
    Type.handler s
      (open_ex_type_down ~env tp1) eff1
      (open_ex_type_up   ~env tp2) (open_effect_up ~env eff2)

and open_ex_type_up ~env (TExists(ex, tp)) =
  let (env, ex, tp) = TypeEnv.open_type_ts env ex tp in
  TExists(ex, open_type_up ~env tp)

and open_type_down ~env (tp : ttype) =
  match Type.view tp with
  | TUVar _ | TBase _ | TNeutral _ | TStruct _ | TTypeWit _ | TEffectWit _
  | TEffsigWit _ | TDataDef _ | TRecordDef _ | TEffsigDef _ -> tp

  | TArrow(name, tp1, extp, eff) ->
    Type.arrow ?name (open_type_up ~env tp1) (open_ex_type_down ~env extp) eff
  | TForall(xs, tp) ->
    let (env, xs, tp) = TypeEnv.open_type_ts env xs tp in
    Type.forall xs (open_type_down ~env tp)
  | TForallInst(a, s, tp) ->
    let (env, a, tp) = TypeEnv.open_type_i env a tp in
    Type.forall_inst a s (open_type_down ~env tp)
  | THandler(s, tp1, eff1, tp2, eff2) ->
    Type.handler s
      (open_ex_type_up   ~env tp1) (open_effect_up ~env eff1)
      (open_ex_type_down ~env tp2) eff2

and open_ex_type_down ~env (TExists(ex, tp)) =
  let (env, ex, tp) = TypeEnv.open_type_ts env ex tp in
  TExists(ex, open_type_down ~env tp)
