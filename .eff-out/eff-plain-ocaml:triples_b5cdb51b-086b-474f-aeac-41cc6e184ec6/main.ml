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
type(_, _) eff_internal_effect += Flip : (unit, bool) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Fail : (unit, empty) eff_internal_effect 
;;
let rec _choice_48  _x_62 = 
     coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
       (( < ) _x_62) >>= (fun  _b_80 -> _b_80 1 >>= (fun  _b_81 -> if _b_81 then 
                                                                    Call (Fail, (()), (fun 
                                                                    (_y_82: empty) -> match _y_82 with
                                                                     _ -> assert false)) else 
                                                                    Call (Flip, (()), (fun 
                                                                    (_y_83: bool) -> if _y_83 then Value _x_62 else 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _x_62) >>= (fun 
                                                                     _b_84 -> _b_84 
                                                                    1 >>= (fun  _b_85 -> _choice_48 
                                                                    _b_85)) )) )) 

;; let choice = _choice_48
;;
let _triple_86  = 
     fun (_n_87: int) -> fun (_s_88: int) -> _choice_48 _n_87 >>= (fun 
                                                _i_111 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                            (( - ) _i_111) >>= (fun 
                                                             _b_112 -> _b_112 
                                                                    1 >>= (fun 
                                                                     _b_113 -> _choice_48 
                                                                    _b_113 >>= (fun 
                                                                     _j_114 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _j_114) >>= (fun 
                                                                     _b_115 -> _b_115 
                                                                    1 >>= (fun  _b_116 -> _choice_48 
                                                                    _b_116 >>= (fun  _k_117 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _i_111) >>= (fun  _b_118 -> _b_118 
                                                                    _j_114 >>= (fun  _b_119 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _b_119) >>= (fun  _b_120 -> _b_120 
                                                                    _k_117 >>= (fun  _b_121 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( = ) 
                                                                    _b_121) >>= (fun  _b_122 -> _b_122 
                                                                    _s_88 >>= (fun  _b_123 -> if _b_123 then Value (
                                                                    _i_111, _j_114, _k_117) else 
                                                                     Call (Fail, (()), (fun 
                                                                    (_y_124: empty) -> match _y_124 with
                                                                     _ -> assert false)) ))))))))))))) 

;; let triple = _triple_86
;;
let _hash_126  = 
     fun ((_a_127, _b_128, _c_129): (int * int * int)) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                            (( * ) 53) >>= (fun 
                                                             _b_136 -> _b_136 
                                                                    _a_127 >>= (fun 
                                                                     _b_135 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _b_135) >>= (fun 
                                                                     _b_134 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( * ) 
                                                                    2809) >>= (fun 
                                                                     _b_138 -> _b_138 
                                                                    _b_128 >>= (fun 
                                                                     _b_137 -> _b_134 
                                                                    _b_137 >>= (fun 
                                                                     _b_133 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _b_133) >>= (fun 
                                                                     _b_132 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( * ) 
                                                                    148877) >>= (fun 
                                                                     _b_140 -> _b_140 
                                                                    _c_129 >>= (fun 
                                                                     _b_139 -> _b_132 
                                                                    _b_139 >>= (fun 
                                                                     _b_131 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( mod ) 
                                                                    _b_131) >>= (fun 
                                                                     _b_130 -> _b_130 
                                                                    1000000007))))))))))) 

;; let hash = _hash_126
;;
let _run_141  = 
     fun (_n_142: int) -> fun (_s_143: int) -> (handler {value_clause = (fun 
                                                         (_id_151: int) -> Value _id_151); 
                                                 effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Fail -> fun (() : unit) _k_144 -> Value 0  | Flip -> fun (() : unit) _k_145 -> 
                                                                    _k_145 
                                                                    true >>= (fun 
                                                                     _l_146 -> _k_145 
                                                                    false >>= (fun 
                                                                     _r_147 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _l_146) >>= (fun 
                                                                     _b_150 -> _b_150 
                                                                    _r_147 >>= (fun 
                                                                     _b_149 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( mod ) 
                                                                    _b_149) >>= (fun 
                                                                     _b_148 -> _b_148 
                                                                    1000000007)))))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                                 (fun (_x_155: int) -> Value _x_155))) 
                                                 (_triple_86 _n_142 _s_143 >>= (fun 
                                                     _b_153 -> _hash_126 
                                                                 _b_153)) 

;; let run = _run_141
;;
