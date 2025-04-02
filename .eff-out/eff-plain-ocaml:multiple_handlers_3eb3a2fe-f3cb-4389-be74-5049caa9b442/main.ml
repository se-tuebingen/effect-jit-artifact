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
type(_, _) eff_internal_effect += Emit : (int, unit) eff_internal_effect 
;;
let _generator_48  = 
     fun (_n_49: int) -> let rec _go_50 _x_58 = 
                           coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                             (( > ) _x_58) >>= (fun  _b_62 -> _b_62 _n_49 >>= (fun 
                                                                 _b_63 -> if _b_63 then Value () else 
                                                                     Call (Emit, (_x_58), (fun 
                                                                    (_y_64: unit) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _x_58) >>= (fun  _b_65 -> _b_65 
                                                                    1 >>= (fun  _b_66 -> _go_50 
                                                                    _b_66)))) )) 
                         in 
                         _go_50 0 

;; let generator = _generator_48
;;
let _summing_67 _tycoer_107
     _tycoer_72
     _tycoer_46 = 
     fun (_fn_68: (unit -> 'ty84 computation)) -> (handler {value_clause = (fun 
                                                            (_x_78: 'ty35) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (fun 
                                                                    (_s_80: int) -> _s_80)); 
                                                    effect_clauses = 
                                                    (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Emit -> fun (_e_70 : int) _k_71 -> Value (
                                                                    fun 
                                                                    (_a_72: int) -> _k_71 
                                                                    () >>= (fun  _b_73 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _a_72) >>= (fun  _b_77 -> _b_77 
                                                                    _e_70 >>= (fun  _b_76 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( mod ) 
                                                                    _b_76) >>= (fun  _b_75 -> _b_75 
                                                                    1009 >>= (fun  _b_74 -> _b_73 
                                                                    _b_74))))))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                                    (fun (_x_82: (int -> int computation)) -> Value _x_82))) 
                                                    (coer_computation _tycoer_72 
                                                       (coer_computation _tycoer_107 
                                                          (_fn_68 ()))) >>= (fun 
                                                     _b_69 -> _b_69 0) 

;; let summing = _summing_67
;;
let _counting_84 _tycoer_178
     _tycoer_143
     _tycoer_117 = 
     fun (_fn_85: (unit -> 'ty138 computation)) -> (handler {value_clause = (fun 
                                                             (_x_95: 'ty89) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (fun 
                                                                    (_s_97: int) -> _s_97)); 
                                                     effect_clauses = 
                                                     (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Emit -> fun (_e_87 : int) _k_88 -> Value (
                                                                    fun 
                                                                    (_a_89: int) -> _k_88 
                                                                    () >>= (fun  _b_90 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _a_89) >>= (fun  _b_94 -> _b_94 
                                                                    1 >>= (fun  _b_93 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( mod ) 
                                                                    _b_93) >>= (fun  _b_92 -> _b_92 
                                                                    1009 >>= (fun  _b_91 -> _b_90 
                                                                    _b_91))))))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                                     (fun (_x_99: (int -> int computation)) -> Value _x_99))) 
                                                     (coer_computation _tycoer_143 
                                                        (coer_computation _tycoer_178 
                                                           (_fn_85 ()))) >>= (fun 
                                                      _b_86 -> _b_86 0) 

;; let counting = _counting_84
;;
let _sq_summing_101 _tycoer_261
     _tycoer_220
     _tycoer_188 = 
     fun (_fn_102: (unit -> 'ty200 computation)) -> (handler {value_clause = (fun 
                                                              (_x_114: 'ty143) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (fun 
                                                                    (_s_116: int) -> _s_116)); 
                                                      effect_clauses = 
                                                      (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Emit -> fun (_e_104 : int) _k_105 -> Value (
                                                                    fun 
                                                                    (_a_106: int) -> _k_105 
                                                                    () >>= (fun  _b_107 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _a_106) >>= (fun  _b_111 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( * ) 
                                                                    _e_104) >>= (fun  _b_113 -> _b_113 
                                                                    _e_104 >>= (fun  _b_112 -> _b_111 
                                                                    _b_112 >>= (fun  _b_110 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( mod ) 
                                                                    _b_110) >>= (fun  _b_109 -> _b_109 
                                                                    1009 >>= (fun  _b_108 -> _b_107 
                                                                    _b_108))))))))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                                      (fun (_x_118: (int -> int computation)) -> Value _x_118))) 
                                                      (coer_computation _tycoer_220 
                                                         (coer_computation _tycoer_261 
                                                            (_fn_102 ()))) >>= (fun 
                                                       _b_103 -> _b_103 0) 

;; let sq_summing = _sq_summing_101
;;
let _run_120  = 
     fun (_n_121: int) -> _sq_summing_101 coer_refl_ty coer_refl_ty
                            coer_refl_ty 
                            (fun ((): unit) -> _generator_48 _n_121) >>= (fun 
                             _sqs_122 -> _summing_67 coer_refl_ty
                                           coer_refl_ty coer_refl_ty 
                                           (fun ((): unit) -> _generator_48 
                                                                _n_121) >>= (fun 
                                            _s_123 -> _counting_84 coer_refl_ty
                                                        coer_refl_ty
                                                        coer_refl_ty 
                                                        (fun ((): unit) -> _generator_48 
                                                                    _n_121) >>= (fun 
                                                         _c_124 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( * ) 
                                                                    _sqs_122) >>= (fun 
                                                                     _b_129 -> _b_129 
                                                                    1009 >>= (fun 
                                                                     _b_128 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _b_128) >>= (fun 
                                                                     _b_127 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( * ) 
                                                                    _s_123) >>= (fun 
                                                                     _b_131 -> _b_131 
                                                                    103 >>= (fun  _b_130 -> _b_127 
                                                                    _b_130 >>= (fun  _b_126 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _b_126) >>= (fun  _b_125 -> _b_125 
                                                                    _c_124)))))))))) 

;; let run = _run_120
;;
