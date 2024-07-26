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
type(_, _) eff_internal_effect += Fun : (unit, unit) eff_internal_effect 
;;
let rec _outer_48  _x_59 = 
     (handler {value_clause = (fun (_x_68: int) -> Value _x_68); effect_clauses = 
                                                                 (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Fun -> fun (() : unit) _k_69 -> 
                                                                    _k_69 ()   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
       (fun (_x_67: int) -> Value _x_67))) 
       (coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
          (( > ) _x_59) >>= (fun  _b_63 -> _b_63 0 >>= (fun  _b_64 -> if _b_64 then 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _x_59) >>= (fun 
                                                                     _b_65 -> _b_65 
                                                                    1 >>= (fun  _b_66 -> _outer_48 
                                                                    _b_66)) else Value 0 ))) 

;; let outer = _outer_48
;;
let _run_70  = fun (_n_71: int) -> _outer_48 _n_71 

;; let run = _run_70
;;
