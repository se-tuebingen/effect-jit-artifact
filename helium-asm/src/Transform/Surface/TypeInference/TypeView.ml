open Common

let rec coerce_loop ~env ~pos coerce tp =
  let w0 = T.World.save () in
  try coerce ~env:(Env.type_env env) tp with
  | (T.Error T.CannotGuessNeutral) as err0 ->
    raise err0
  | (T.Error err) as err0 ->
    let w1 = T.World.save () in
    T.World.rollback w0;
    begin match T.Type.coerce_to_forall_inst ~env:(Env.type_env env) tp with
    | (crc1, a, s, tp') ->
      begin match Env.guess_instance env s with
      | Env.InstNo ->
        begin match Env.create_implicit_instance env pos s with
        | i ->
          let b = T.EffInstExpr.implicit i in
          let (crc2, result) =
            coerce_loop ~env ~pos coerce (T.Type.subst_inst a b tp') in
          (T.CApplyInst(crc1, b, crc2), result)
        | exception (ImplicitScope.Error err) ->
          raise (Error.implicit_scope_error ~env ~pos err)
        end
      | Env.InstAmbiguous ->
        raise (Error.ambiguous_instance ~env ~pos s)
      | Env.InstUnique b ->
        let (crc2, result) =
          coerce_loop ~env ~pos coerce (T.Type.subst_inst a b tp') in
        (T.CApplyInst(crc1, b, crc2), result)
      end
    | exception (T.Error _) ->
      T.World.rollback w1;
      raise err0
    end

let coerce_to_arrow ~env ~pos tp =
  match
    coerce_loop ~env ~pos
      (fun ~env tp ->
        let (crc, tp1, tp2, eff) = T.Type.coerce_to_arrow ~env tp in
        (crc, (tp1, tp2, eff)))
      tp
  with
  | (crc, (tp1, tp2, eff)) -> (crc, tp1, tp2, eff)
  | exception (T.Error err) ->
    raise (Error.not_a_function ~env ~pos tp err)

let coerce_to_forall_inst ~env ~pos tp =
  try T.Type.coerce_to_forall_inst ~env:(Env.type_env env) tp with
  | T.Error err ->
    raise (Error.not_forall_inst ~env ~pos tp err)

let coerce_to_handler ~env ~pos tp =
  match
    coerce_loop ~env ~pos
      (fun ~env tp ->
        let (crc, s, in_tp, in_eff, out_tp, out_eff) =
          T.Type.coerce_to_handler ~env tp in
        (crc, (s, in_tp, in_eff, out_tp, out_eff)))
      tp
  with
  | (crc, (s, in_tp, in_eff, out_tp, out_eff)) ->
    (crc, s, in_tp, in_eff, out_tp, out_eff)
  | exception (T.Error err) ->
    raise (Error.not_a_handler ~env ~pos tp err)

let coerce_to_type_wit ~env ~pos tp =
  try coerce_loop ~env ~pos T.Type.coerce_to_type_wit tp with
  | T.Error err ->
    raise (Error.not_a_type ~env ~pos tp err)

let coerce_to_effect_wit ~env ~pos tp =
  try coerce_loop ~env ~pos T.Type.coerce_to_effect_wit tp with
  | T.Error err ->
    raise (Error.not_an_effect ~env ~pos tp err)

let coerce_to_effsig_wit ~env ~pos tp =
  try coerce_loop ~env ~pos T.Type.coerce_to_effsig_wit tp with
  | T.Error err ->
    raise (Error.not_an_effsig ~env ~pos tp err)

let coerce_to_neutral ~env ~pos tp =
  try coerce_loop ~env ~pos T.Type.coerce_to_neutral tp with
  | T.Error err ->
    raise (Error.not_neutral ~env ~pos tp err)

let coerce_to_neutral_or_struct ~env ~pos tp =
  try coerce_loop ~env ~pos T.Type.coerce_to_neutral_or_struct tp with
  | T.Error err ->
    raise (Error.cannot_select ~env ~pos tp err)

let coerce_to_struct ~env ~pos tp =
  try coerce_loop ~env ~pos T.Type.coerce_to_struct tp with
  | T.Error err ->
    raise (Error.not_a_structure ~env ~pos tp err)
