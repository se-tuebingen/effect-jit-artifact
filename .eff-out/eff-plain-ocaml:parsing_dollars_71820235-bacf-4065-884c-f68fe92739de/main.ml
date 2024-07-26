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
type chr = int

;;
type(_, _) eff_internal_effect += Reade : (unit, int) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Emit : (int, unit) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Stop : (unit, unit) eff_internal_effect 
;;
let _newline_48  = 10 

;; let newline = _newline_48
;;
let _is_newline_49  = 
     fun (_c_50: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                           (( = ) _c_50) >>= (fun  _b_51 -> _b_51 10) 

;; let is_newline = _is_newline_49
;;
let _dollar_52  = 36 

;; let dollar = _dollar_52
;;
let _is_dollar_53  = 
     fun (_c_54: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                           (( = ) _c_54) >>= (fun  _b_55 -> _b_55 36) 

;; let is_dollar = _is_dollar_53
;;
let _run_56  = 
     fun (_n_57: int) -> let rec _parse_58 _x_116 = 
                            Call (Reade, (()), (fun (_y_260: int) -> _is_dollar_53 
                                                                    _y_260 >>= (fun 
                                                                     _b_269 -> if _b_269 then 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _x_116) >>= (fun 
                                                                     _b_270 -> _b_270 
                                                                    1 >>= (fun  _b_271 -> _parse_58 
                                                                    _b_271)) else 
                                                                    _is_newline_49 
                                                                    _y_260 >>= (fun 
                                                                     _b_272 -> if _b_272 then 
                                                                     Call (Emit, (_x_116), (fun 
                                                                    (_y_273: unit) -> _parse_58 
                                                                    0)) else  Call (Stop, (()), (fun 
                                                                    (_y_274: unit) -> Value _y_274)) ) ))) 
                         in 
                         (handler {value_clause = (fun (_x_245: unit) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (fun 
                                                                    (_s_246: int) -> _s_246)); 
                           effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Emit -> fun (_e_247 : int) _k_248 -> Value (
                                                                    fun 
                                                                    (_s_249: int) -> _k_248 
                                                                    () >>= (fun  _b_250 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _s_249) >>= (fun  _b_251 -> _b_251 
                                                                    _e_247 >>= (fun  _b_252 -> _b_250 
                                                                    _b_252))))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                           (fun (_x_244: (int -> int computation)) -> Value _x_244))) 
                           ((handler {value_clause = (fun (_id_240: unit) -> Value _id_240); 
                              effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Stop -> fun (() : unit) _k_241 -> Value ()   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                              (fun (_x_239: unit) -> Value _x_239))) 
                              ((handler {value_clause = (fun (_x_218: unit) -> coer_return (coer_arrow coer_refl_ty (coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)))) 
                                                                    (fun 
                                                                    (_i_219: int) -> fun 
                                                                    (_j_220: int) -> _x_218)); 
                                 effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Reade -> fun (() : unit) _k_221 -> 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (fun 
                                                                    (_i_222: int) -> fun 
                                                                    (_j_223: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( > ) 
                                                                    _i_222) >>= (fun  _b_224 -> _b_224 
                                                                    _n_57 >>= (fun  _b_225 -> if _b_225 then 
                                                                     Call (Stop, (()), (fun 
                                                                    (_y_226: unit) -> Value _y_226)) else 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( = ) 
                                                                    _j_223) >>= (fun 
                                                                     _b_227 -> _b_227 
                                                                    0 >>= (fun  _b_228 -> if _b_228 then 
                                                                    _k_221 
                                                                    _newline_48 >>= (fun 
                                                                     _b_229 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _i_222) >>= (fun 
                                                                     _b_230 -> _b_230 
                                                                    1 >>= (fun  _b_231 -> _b_229 
                                                                    _b_231 >>= (fun  _b_232 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _i_222) >>= (fun  _b_233 -> _b_233 
                                                                    1 >>= (fun  _b_234 -> _b_232 
                                                                    _b_234)))))) else _k_221 
                                                                    _dollar_52 >>= (fun  _b_235 -> _b_235 
                                                                    _i_222 >>= (fun  _b_236 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _j_223) >>= (fun  _b_237 -> _b_237 
                                                                    1 >>= (fun  _b_238 -> _b_236 
                                                                    _b_238)))) )) )))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                 (fun (_x_217: (int -> (int -> unit computation) computation)) -> Value _x_217))) 
                                 (_parse_58 0) >>= (fun  _b_215 -> _b_215 0 >>= (fun 
                                                                     _b_216 -> _b_216 
                                                                    0)))) >>= (fun 
                            _b_243 -> _b_243 0) 

;; let run = _run_56
;;
