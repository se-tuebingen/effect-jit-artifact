open OcamlHeader;;type(_, _) eff_internal_effect += Prime : (int, bool) eff_internal_effect 
;;
let rec _primes_42 _x_73 = 
      fun (_n_180: int) -> fun (_a_181: int) -> if ( >= ) _x_73 _n_180 then Value _a_181 else 
                                                 Call (Prime, _x_73, (fun 
                                                  (_y_184: bool) -> if _y_184 then 
                                                                    (handler {
                                                                    value_clause = (fun 
                                                                    (_id_191: int) -> Value _id_191); 
                                                                    effect_clauses = 
                                                                    (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Prime -> fun _e_192 _l_193 -> 
                                                                    if 
                                                                    ( = ) 
                                                                    (( mod ) 
                                                                    _e_192 
                                                                    _x_73) 0 then 
                                                                    _l_193 
                                                                    false else 
                                                                     Call (Prime, _e_192, (fun 
                                                                    (_y_198: bool) -> _l_193 
                                                                    _y_198))    
    | eff' -> (fun arg k -> Call (eff', arg, k))
      )); }) 
                                                                    (_primes_42 
                                                                    (( + ) 
                                                                    _x_73 1) 
                                                                    _n_180 
                                                                    (( + ) 
                                                                    _a_181 
                                                                    _x_73)) else 
                                                                    _primes_42 
                                                                    (( + ) 
                                                                    _x_73 1) 
                                                                    _n_180 
                                                                    _a_181 ))  

;; let primes = _primes_42
;;
let _run_203 = 
     fun (_n_204: int) -> force_unsafe 
                            ((handler {value_clause = (fun (_id_207: int) -> Value _id_207); 
                               effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Prime -> fun _e_205 _l_211 -> Value (
                                                                    coer_arrow coer_refl_ty force_unsafe 
                                                                    _l_211 
                                                                    true)   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      )); }) 
                               (_primes_42 2 _n_204 0)) 

;; let run = _run_203
;;
