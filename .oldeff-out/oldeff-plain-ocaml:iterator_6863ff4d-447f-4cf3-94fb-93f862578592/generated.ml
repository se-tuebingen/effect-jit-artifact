open OcamlHeader

type (_, _) eff_internal_effect += Emit : (int, unit) eff_internal_effect
type (_, _) eff_internal_effect += Get : (unit, int) eff_internal_effect
type (_, _) eff_internal_effect += Set : (int, unit) eff_internal_effect

let rec _range_42 _x_52 (_u_56 : int) =
  if _x_52 > _u_56 then Value ()
  else Call (Emit, _x_52, fun (_y_59 : unit) -> _range_42 (_x_52 + 1) _u_56)

let range = _range_42

let _run_63 (_n_64 : int) =
  force_unsafe
    ((handler
        {
          value_clause = (fun (_x_156 : int) -> Value (fun (_ : int) -> _x_156));
          effect_clauses =
            (fun (type a b) (eff : (a, b) eff_internal_effect) :
                 (a -> (b -> _) -> _) ->
              match eff with
              | Get ->
                  fun () _l_157 ->
                    Value
                      (fun (_s_158 : int) ->
                        coer_arrow coer_refl_ty force_unsafe _l_157 _s_158
                          _s_158)
              | Set ->
                  fun _s_160 _l_161 ->
                    Value
                      (fun (_ : int) ->
                        coer_arrow coer_refl_ty force_unsafe _l_161 () _s_160)
              | eff' -> fun arg k -> Call (eff', arg, k));
        })
       ((handler
           {
             value_clause =
               (fun (_x_148 : unit) ->
                 Call (Get, (), fun (_y_149 : int) -> Value _y_149));
             effect_clauses =
               (fun (type a b) (eff : (a, b) eff_internal_effect) :
                    (a -> (b -> _) -> _) ->
                 match eff with
                 | Emit ->
                     fun _e_150 _l_151 ->
                       Call
                         ( Get,
                           (),
                           fun (_y_152 : int) ->
                             Call
                               ( Set,
                                 _y_152 + _e_150,
                                 fun (_y_155 : unit) -> _l_151 () ) )
                 | eff' -> fun arg k -> Call (eff', arg, k));
           })
          (_range_42 0 _n_64)))
    0

let run = _run_63
