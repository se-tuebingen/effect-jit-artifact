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
type(_, _) eff_internal_effect += Get : (unit, int) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Set : (int, unit) eff_internal_effect 
;;
let rec _countdown_48  _x_58 = 
      Call (Get, (()), (fun (_y_62: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                              (( = ) _y_62) >>= (fun 
                                               _b_51 -> _b_51 0 >>= (fun 
                                                           _b_50 -> if _b_50 then Value _y_62 else 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _y_62) >>= (fun 
                                                                     _b_53 -> _b_53 
                                                                    1 >>= (fun  _b_52 ->  Call (Set, (_b_52), (fun 
                                                                    (_y_60: unit) -> _countdown_48 
                                                                    ())))) )))) 

;; let countdown = _countdown_48
;;
let _run_63  = 
     fun (_n_64: int) -> (handler {value_clause = (fun (_x_72: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (fun 
                                                                    (_: int) -> _x_72)); 
                           effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Get -> fun (() : unit) _k_66 -> Value (
                                                                    fun 
                                                                    (_s_67: int) -> _k_66 
                                                                    _s_67 >>= (fun  _b_68 -> _b_68 
                                                                    _s_67))  | Set -> fun (_s_69 : int) _k_70 -> Value (
                                                                    fun 
                                                                    (_: int) -> _k_70 
                                                                    () >>= (fun  _b_71 -> _b_71 
                                                                    _s_69))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                           (fun (_x_75: (int -> int computation)) -> Value _x_75))) 
                           (_countdown_48 ()) >>= (fun  _b_65 -> _b_65 _n_64) 

;; let run = _run_63
;;
