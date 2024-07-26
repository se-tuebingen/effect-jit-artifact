open OcamlHeader

type chr = int
type (_, _) eff_internal_effect += Read : (unit, int) eff_internal_effect
type (_, _) eff_internal_effect += Emit : (int, unit) eff_internal_effect
type (_, _) eff_internal_effect += Stop : (unit, unit) eff_internal_effect

let _newline_42 = 10
let newline = _newline_42
let _is_newline_43 (_c_44 : int) = _c_44 = 10
let is_newline = _is_newline_43
let _dollar_46 = 36
let dollar = _dollar_46
let _is_dollar_47 (_c_48 : int) = _c_48 = 36
let is_dollar = _is_dollar_47

let _run_50 (_n_51 : int) =
  let rec _parse_263 _x_110 =
    let _l_205 (_y_248 : int) =
      if _is_dollar_47 _y_248 then _parse_263 (_x_110 + 1)
      else if _is_newline_43 _y_248 then
        Call (Emit, _x_110, fun (_y_293 : unit) -> _parse_263 0)
      else
        Call
          ( Stop,
            (),
            fun (_y_294 : unit) ->
              coer_return
                (coer_arrow coer_refl_ty
                   (coer_arrow coer_refl_ty (coer_return coer_refl_ty)))
                (fun (_i_295 : int) (_j_296 : int) -> _y_294) )
    in
    Value
      (fun (_i_206 : int) (_j_207 : int) ->
        if _i_206 > _n_51 then
          Call (Stop, (), fun (_y_210 : unit) -> Value _y_210)
        else if _j_207 = 0 then
          _l_205 _newline_42 >>= fun _b_213 -> _b_213 (_i_206 + 1) (_i_206 + 1)
        else _l_205 _dollar_46 >>= fun _b_219 -> _b_219 _i_206 (_j_207 - 1))
  in
  (let rec _parse_472 _x_110 =
     let _l_205 (_y_248 : int) =
       if _is_dollar_47 _y_248 then _parse_263 (_x_110 + 1)
       else if _is_newline_43 _y_248 then
         Call (Emit, _x_110, fun (_y_293 : unit) -> _parse_263 0)
       else
         Call
           ( Stop,
             (),
             fun (_y_294 : unit) ->
               coer_return
                 (coer_arrow coer_refl_ty
                    (coer_arrow coer_refl_ty (coer_return coer_refl_ty)))
                 (fun (_i_295 : int) (_j_296 : int) -> _y_294) )
     in
     if 0 > _n_51 then fun (_s_595 : int) -> _s_595
     else if 0 = 0 then
       force_unsafe
         ((handler
             {
               value_clause =
                 (fun (_ : unit) -> Value (fun (_s_607 : int) -> _s_607));
               effect_clauses =
                 (fun (type a b) (eff : (a, b) eff_internal_effect) :
                      (a -> (b -> _) -> _) ->
                   match eff with
                   | Emit ->
                       fun _e_608 _l_609 ->
                         Value
                           (fun (_s_610 : int) ->
                             coer_arrow coer_refl_ty force_unsafe _l_609 ()
                               (_s_610 + _e_608))
                   | eff' -> fun arg k -> Call (eff', arg, k));
             })
            ((handler
                {
                  value_clause =
                    (fun (_b_598 : int -> int -> unit computation) ->
                      (handler
                         {
                           value_clause =
                             (fun (_id_604 : unit) -> Value _id_604);
                           effect_clauses =
                             (fun (type a b) (eff : (a, b) eff_internal_effect)
                                  : (a -> (b -> _) -> _) ->
                               match eff with
                               | Stop -> fun () _l_605 -> Value ()
                               | eff' -> fun arg k -> Call (eff', arg, k));
                         })
                        (_b_598 (0 + 1) (0 + 1)));
                  effect_clauses =
                    (fun (type a b) (eff : (a, b) eff_internal_effect) :
                         (a -> (b -> _) -> _) ->
                      match eff with
                      | Stop -> fun () _l_606 -> Value ()
                      | eff' -> fun arg k -> Call (eff', arg, k));
                })
               (_l_205 _newline_42)))
     else
       force_unsafe
         ((handler
             {
               value_clause =
                 (fun (_ : unit) -> Value (fun (_s_621 : int) -> _s_621));
               effect_clauses =
                 (fun (type a b) (eff : (a, b) eff_internal_effect) :
                      (a -> (b -> _) -> _) ->
                   match eff with
                   | Emit ->
                       fun _e_622 _l_623 ->
                         Value
                           (fun (_s_624 : int) ->
                             coer_arrow coer_refl_ty force_unsafe _l_623 ()
                               (_s_624 + _e_622))
                   | eff' -> fun arg k -> Call (eff', arg, k));
             })
            ((handler
                {
                  value_clause =
                    (fun (_b_614 : int -> int -> unit computation) ->
                      (handler
                         {
                           value_clause =
                             (fun (_id_618 : unit) -> Value _id_618);
                           effect_clauses =
                             (fun (type a b) (eff : (a, b) eff_internal_effect)
                                  : (a -> (b -> _) -> _) ->
                               match eff with
                               | Stop -> fun () _l_619 -> Value ()
                               | eff' -> fun arg k -> Call (eff', arg, k));
                         })
                        (_b_614 0 (0 - 1)));
                  effect_clauses =
                    (fun (type a b) (eff : (a, b) eff_internal_effect) :
                         (a -> (b -> _) -> _) ->
                      match eff with
                      | Stop -> fun () _l_620 -> Value ()
                      | eff' -> fun arg k -> Call (eff', arg, k));
                })
               (_l_205 _dollar_46)))
   in
   _parse_472 0)
    0

let run = _run_50
