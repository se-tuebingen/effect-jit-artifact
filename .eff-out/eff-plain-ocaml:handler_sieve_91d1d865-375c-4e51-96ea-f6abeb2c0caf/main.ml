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
type(_, _) eff_internal_effect += Prime : (int, bool) eff_internal_effect 
;;
let rec _primes_48  _x_79 = 
     coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
       (fun (_n_107: int) -> fun (_a_108: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                    (( >= ) _x_79) >>= (fun 
                                                     _b_109 -> _b_109 _n_107 >>= (fun 
                                                                  _b_110 -> if _b_110 then Value _a_108 else 
                                                                     Call (Prime, (_x_79), (fun 
                                                                    (_y_111: bool) -> if _y_111 then 
                                                                    (handler {
                                                                    value_clause = (fun 
                                                                    (_id_119: int) -> Value _id_119); 
                                                                    effect_clauses = 
                                                                    (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Prime -> fun (_e_120 : int) _k_121 -> 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( mod ) 
                                                                    _e_120) >>= (fun 
                                                                     _b_122 -> _b_122 
                                                                    _x_79 >>= (fun 
                                                                     _b_123 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( = ) 
                                                                    _b_123) >>= (fun 
                                                                     _b_124 -> _b_124 
                                                                    0 >>= (fun  _b_125 -> if _b_125 then 
                                                                    _k_121 
                                                                    false else  Call (Prime, (_e_120), (fun 
                                                                    (_y_126: bool) -> _k_121 
                                                                    _y_126)) ))))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                                                    (fun 
                                                                    (_x_118: int) -> Value _x_118))) 
                                                                    (coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _x_79) >>= (fun 
                                                                     _b_112 -> _b_112 
                                                                    1 >>= (fun  _b_113 -> _primes_48 
                                                                    _b_113 >>= (fun  _b_114 -> _b_114 
                                                                    _n_107 >>= (fun  _b_115 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _a_108) >>= (fun  _b_116 -> _b_116 
                                                                    _x_79 >>= (fun  _b_117 -> _b_115 
                                                                    _b_117))))))) else 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _x_79) >>= (fun 
                                                                     _b_127 -> _b_127 
                                                                    1 >>= (fun  _b_128 -> _primes_48 
                                                                    _b_128 >>= (fun  _b_129 -> _b_129 
                                                                    _n_107 >>= (fun  _b_130 -> _b_130 
                                                                    _a_108)))) )) ))) 

;; let primes = _primes_48
;;
let _run_131  = 
     fun (_n_132: int) -> (handler {value_clause = (fun (_id_135: int) -> Value _id_135); 
                            effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Prime -> fun (_e_133 : int) _k_134 -> 
                                                                    _k_134 
                                                                    true   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                            (fun (_x_139: int) -> Value _x_139))) 
                            (_primes_48 2 >>= (fun  _b_138 -> _b_138 _n_132 >>= (fun 
                                                                 _b_137 -> _b_137 
                                                                    0))) 

;; let run = _run_131
;;
