open OcamlHeader;;(* primitive effect *) type(_, _) eff_internal_effect += Print : (string, unit) eff_internal_effect 
;;
(* primitive effect *) type(_, _) eff_internal_effect += Read : (unit, string) eff_internal_effect 
;;
(* primitive effect *) type(_, _) eff_internal_effect += Raise : (string, empty) eff_internal_effect 
;;
(* primitive effect *) type(_, _) eff_internal_effect += RandomInt : (int, int) eff_internal_effect 
;;
(* primitive effect *) type(_, _) eff_internal_effect += RandomFloat : (float, float) eff_internal_effect 
;;
(* primitive effect *) type(_, _) eff_internal_effect += Write : (
                          (string * string), unit) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Operator : (int, unit) eff_internal_effect 
;;
let _repeat_48  = 
     fun (_n_49: int) -> let rec _loop_50 _x_88 = 
                           Value (fun (_s_134: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                         (( = ) _x_88) >>= (fun 
                                                          _b_135 -> _b_135 0 >>= (fun 
                                                                     _b_136 -> if _b_136 then Value _s_134 else 
                                                                     Call (Operator, (_x_88), (fun 
                                                                    (_y_137: unit) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _x_88) >>= (fun  _b_138 -> _b_138 
                                                                    1 >>= (fun  _b_139 -> _loop_50 
                                                                    _b_139 >>= (fun  _b_140 -> _b_140 
                                                                    _s_134))))) ))) 
                         in 
                         let rec _step_102 _x_103 = 
                           Value (fun (_s_104: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                         (( = ) _x_103) >>= (fun 
                                                          _b_105 -> _b_105 0 >>= (fun 
                                                                     _b_106 -> if _b_106 then Value _s_104 else 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _x_103) >>= (fun 
                                                                     _b_107 -> _b_107 
                                                                    1 >>= (fun  _b_108 -> _step_102 
                                                                    _b_108 >>= (fun  _b_109 -> (handler {
                                                                    value_clause = (fun 
                                                                    (_id_144: int) -> Value _id_144); 
                                                                    effect_clauses = 
                                                                    (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Operator -> fun (_x_145 : int) _k_146 -> 
                                                                    _k_146 () >>= (fun 
                                                                     _y_147 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _x_145) >>= (fun 
                                                                     _b_148 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( * ) 
                                                                    503) >>= (fun 
                                                                     _b_149 -> _b_149 
                                                                    _y_147 >>= (fun 
                                                                     _b_150 -> _b_148 
                                                                    _b_150 >>= (fun 
                                                                     _b_151 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _b_151) >>= (fun 
                                                                     _b_152 -> _b_152 
                                                                    37 >>= (fun  _b_153 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( mod ) 
                                                                    (abs 
                                                                    _b_153)) >>= (fun  _b_155 -> _b_155 
                                                                    1009))))))))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                                                    (fun 
                                                                    (_x_143: int) -> Value _x_143))) 
                                                                    (_loop_50 
                                                                    _n_49 >>= (fun 
                                                                     _b_142 -> _b_142 
                                                                    _s_104)) >>= (fun  _b_130 -> _b_109 
                                                                    _b_130)))) ))) 
                         in 
                         _step_102 1000 >>= (fun  _b_112 -> _b_112 0) 

;; let repeat = _repeat_48
;;
