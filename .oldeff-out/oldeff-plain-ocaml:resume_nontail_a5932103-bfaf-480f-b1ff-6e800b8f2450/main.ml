open OcamlHeader;;type(_, _) eff_internal_effect += Operator : (int, unit) eff_internal_effect 
;;
let _repeat_42 = 
     fun (_n_43: int) -> let rec _loop_44 _x_82 = 
                            fun (_s_154: int) -> if ( = ) _x_82 0 then Value _s_154 else 
                                                  Call (Operator, _x_82, (fun 
                                                   (_y_157: unit) -> _loop_44 
                                                                    (( - ) 
                                                                    _x_82 1) 
                                                                    _s_154))  
                         in 
                         let rec _step_96 _x_97 = 
                            fun (_s_98: int) -> if ( = ) _x_97 0 then _s_98 else 
                                                _step_96 (( - ) _x_97 1) 
                                                  (force_unsafe 
                                                     ((handler {value_clause = (fun 
                                                                (_id_139: int) -> Value _id_139); 
                                                        effect_clauses = 
                                                        (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Operator -> fun _x_140 _l_141 -> Value (
                                                                    ( mod ) 
                                                                    (abs 
                                                                    (( + ) 
                                                                    (( - ) 
                                                                    _x_140 
                                                                    (( * ) 
                                                                    503 
                                                                    (coer_arrow coer_refl_ty force_unsafe 
                                                                    _l_141 ()))) 
                                                                    37)) 1009)   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      )); }) 
                                                        (_loop_44 _n_43 _s_98)))  
                         in 
                         _step_96 1000 0 

;; let repeat = _repeat_42
;;
