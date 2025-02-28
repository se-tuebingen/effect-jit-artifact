open OcamlHeader

type (_, _) eff_internal_effect += Flip : (unit, bool) eff_internal_effect
type (_, _) eff_internal_effect += Fail : (unit, empty) eff_internal_effect

let rec _choice_42 _x_56 =
  if _x_56 < 1 then
    Call
      ( Fail,
        (),
        fun (_y_76 : empty) -> Value (match _y_76 with _ -> assert false) )
  else
    Call
      ( Flip,
        (),
        fun (_y_77 : bool) ->
          if _y_77 then Value _x_56 else _choice_42 (_x_56 - 1) )

let choice = _choice_42

let _triple_80 (_n_81 : int) (_s_82 : int) =
  _choice_42 _n_81 >>= fun _i_105 ->
  _choice_42 (_i_105 - 1) >>= fun _j_108 ->
  _choice_42 (_j_108 - 1) >>= fun _k_111 ->
  if _i_105 + _j_108 + _k_111 = _s_82 then Value (_i_105, _j_108, _k_111)
  else
    Call
      ( Fail,
        (),
        fun (_y_118 : empty) -> Value (match _y_118 with _ -> assert false) )

let triple = _triple_80

let _hash_120 ((_a_121, _b_122, _c_123) : int * int * int) =
  ((53 * _a_121) + (2809 * _b_122) + (148877 * _c_123)) mod 1000000007

let hash = _hash_120

let _run_135 (_n_136 : int) (_s_137 : int) =
  force_unsafe
    ((handler
        {
          value_clause =
            (fun (_b_169 : int * int * int) -> Value (_hash_120 _b_169));
          effect_clauses =
            (fun (type a b) (eff : (a, b) eff_internal_effect) :
                 (a -> (b -> _) -> _) ->
              match eff with
              | Fail -> fun () _l_171 -> Value 0
              | Flip ->
                  fun () _l_172 ->
                    Value
                      ((coer_arrow coer_refl_ty force_unsafe _l_172 true
                       + coer_arrow coer_refl_ty force_unsafe _l_172 false)
                      mod 1000000007)
              | eff' -> fun arg k -> Call (eff', arg, k));
        })
       (_triple_80 _n_136 _s_137))

let run = _run_135
