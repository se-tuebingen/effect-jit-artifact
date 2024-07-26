open OcamlHeader

(* primitive effect *)

type (_, _) eff_internal_effect += Print : (string, unit) eff_internal_effect

(* primitive effect *)

type (_, _) eff_internal_effect += Read : (unit, string) eff_internal_effect

(* primitive effect *)

type (_, _) eff_internal_effect += Raise : (string, empty) eff_internal_effect

(* primitive effect *)

type (_, _) eff_internal_effect += RandomInt : (int, int) eff_internal_effect

(* primitive effect *)

type (_, _) eff_internal_effect +=
  | RandomFloat : (float, float) eff_internal_effect

(* primitive effect *)

type (_, _) eff_internal_effect +=
  | Write : (string * string, unit) eff_internal_effect

type (_, _) eff_internal_effect += Emit : (int, unit) eff_internal_effect

type (_, _) eff_internal_effect += Pred : (int, bool) eff_internal_effect

let _main_48 =
  let rec _unfaithful_sieve_49 _x_92 =
    Value
      (fun (_endp_133 : int) ->
        coer_return
          (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
          (( >= ) _x_92)
        >>= fun _b_134 ->
        _b_134 _endp_133 >>= fun _b_135 ->
        if _b_135 then Value ()
        else
          Call
            ( Pred,
              _x_92,
              fun (_y_136 : bool) ->
                if _y_136 then
                  Call
                    ( Emit,
                      _x_92,
                      fun (_y_137 : unit) ->
                        (handler
                           {
                             value_clause =
                               (fun (_id_142 : unit) -> Value _id_142);
                             effect_clauses =
                               (fun (type a b)
                                    (eff : (a, b) eff_internal_effect) :
                                    (a -> (b -> _) -> _) ->
                                 match eff with
                                 | Pred ->
                                     fun (_i_143 : int) _k_144 ->
                                       coer_return
                                         (coer_arrow coer_refl_ty
                                            (coer_return coer_refl_ty))
                                         (( mod ) _i_143)
                                       >>= fun _b_145 ->
                                       _b_145 _x_92 >>= fun _b_146 ->
                                       coer_return
                                         (coer_arrow coer_refl_ty
                                            (coer_return coer_refl_ty))
                                         (( = ) _b_146)
                                       >>= fun _b_147 ->
                                       _b_147 0 >>= fun _b_148 ->
                                       if _b_148 then _k_144 false
                                       else
                                         Call
                                           ( Pred,
                                             _i_143,
                                             fun (_y_149 : bool) ->
                                               _k_144 _y_149 )
                                 | eff' -> fun arg k -> Call (eff', arg, k));
                           }
                           (fun (_x_141 : unit) -> Value _x_141))
                          ( coer_return
                              (coer_arrow coer_refl_ty
                                 (coer_return coer_refl_ty))
                              (( + ) _x_92)
                          >>= fun _b_138 ->
                            _b_138 1 >>= fun _b_139 ->
                            _unfaithful_sieve_49 _b_139 >>= fun _b_140 ->
                            _b_140 _endp_133 ) )
                else
                  coer_return
                    (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                    (( + ) _x_92)
                  >>= fun _b_150 ->
                  _b_150 1 >>= fun _b_151 ->
                  _unfaithful_sieve_49 _b_151 >>= fun _b_152 -> _b_152 _endp_133
            ))
  in
  (handler
     {
       value_clause = (fun (_x_76 : unit) -> Value 0);
       effect_clauses =
         (fun (type a b) (eff : (a, b) eff_internal_effect) :
              (a -> (b -> _) -> _) ->
           match eff with
           | Emit ->
               fun (_i_72 : int) _k_73 ->
                 coer_return
                   (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                   (( + ) _i_72)
                 >>= fun _b_74 ->
                 _k_73 () >>= fun _b_75 -> _b_74 _b_75
           | eff' -> fun arg k -> Call (eff', arg, k));
     }
     (fun (_x_93 : int) -> Value _x_93))
    ((handler
        {
          value_clause = (fun (_id_102 : unit) -> Value _id_102);
          effect_clauses =
            (fun (type a b) (eff : (a, b) eff_internal_effect) :
                 (a -> (b -> _) -> _) ->
              match eff with
              | Pred -> fun (_i_103 : int) _k_104 -> _k_104 true
              | eff' -> fun arg k -> Call (eff', arg, k));
        }
        (fun (_x_101 : unit) -> Value _x_101))
       (_unfaithful_sieve_49 2 >>= fun _b_100 -> _b_100 20000))

let main = _main_48
