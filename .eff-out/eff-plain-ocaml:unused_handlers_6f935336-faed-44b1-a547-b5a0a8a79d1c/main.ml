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
type(_, _) eff_internal_effect += Yield : (int, unit) eff_internal_effect 
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
let _ignore_63 _tycoer_62
     _tycoer_57
     _tycoer_54
     _tycoer_53
     _tycoer_48
     _tycoer_52
     _tycoer_49
     _tycoer_58 = 
     fun (_b_64: (unit -> 'ty44 computation)) -> coer_computation _tycoer_58 
                                                   ((handler {value_clause = (fun 
                                                              (_x_66: 'ty33) -> coer_computation _tycoer_52 
                                                                    (coer_return _tycoer_48 
                                                                    (_tycoer_49 
                                                                    _x_66))); 
                                                      effect_clauses = 
                                                      (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Yield -> fun (_ : int) _k_65 -> 
                                                                    _k_65 ()   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                                      (fun (_x_69: 'ty39) -> coer_return _tycoer_54 
                                                                    (_tycoer_53 
                                                                    _x_69)))) 
                                                      (coer_computation _tycoer_57 
                                                         (coer_computation _tycoer_62 
                                                            (_b_64 ())))) 

;; let ignore = _ignore_63
;;
let _handled_72 _tycoer_126 = 
     fun (_n_73: 'ty46) -> fun (_d_74: int) -> let rec _go_75 _x_84 = 
                                                 Value (fun (_d_86: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( = ) 
                                                                    _d_86) >>= (fun 
                                                                     _b_87 -> _b_87 
                                                                    0 >>= (fun  _b_88 -> if _b_88 then 
                                                                    _countdown_48 
                                                                    () else _ignore_63 coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty 
                                                                    (fun 
                                                                    (_: unit) -> _go_75 
                                                                    _x_84 >>= (fun  _b_89 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _d_86) >>= (fun  _b_90 -> _b_90 
                                                                    1 >>= (fun  _b_91 -> _b_89 
                                                                    _b_91)))) ))) 
                                               in 
                                               _go_75 (_tycoer_126 _n_73) >>= (fun 
                                                  _b_83 -> _b_83 _d_74) 

;; let handled = _handled_72
;;
let _run_92  = 
     fun (_n_93: int) -> fun (_d_94: int) -> (handler {value_clause = (fun 
                                                       (_x_102: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (fun 
                                                                    (_: int) -> _x_102)); 
                                               effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Get -> fun (() : unit) _k_96 -> Value (
                                                                    fun 
                                                                    (_s_97: int) -> _k_96 
                                                                    _s_97 >>= (fun  _b_98 -> _b_98 
                                                                    _s_97))  | Set -> fun (_s_99 : int) _k_100 -> Value (
                                                                    fun 
                                                                    (_: int) -> _k_100 
                                                                    () >>= (fun  _b_101 -> _b_101 
                                                                    _s_99))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                               (fun (_x_106: (int -> int computation)) -> Value _x_106))) 
                                               (_handled_72 coer_refl_ty 
                                                  _n_93 _d_94) >>= (fun 
                                                _b_95 -> _b_95 _n_93) 

;; let run = _run_92
;;
