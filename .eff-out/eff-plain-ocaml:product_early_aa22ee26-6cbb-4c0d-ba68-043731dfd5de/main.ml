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
type(_, _) eff_internal_effect += Done : (int, int) eff_internal_effect 
;;
type intlist = Nil | Cons of (int * intlist)

;;
let rec _product_48  _x_58 = 
     begin match _x_58 with 
       Nil -> Value 0
      |  (Cons (_y_63, _ys_62)) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                     (( = ) _y_63) >>= (fun  _b_64 -> _b_64 0 >>= (fun 
                                                                     _b_65 -> if _b_65 then 
                                                                     Call (Done, (0), (fun 
                                                                    (_y_66: int) -> Value _y_66)) else 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( * ) 
                                                                    _y_63) >>= (fun 
                                                                     _b_67 -> _product_48 
                                                                    _ys_62 >>= (fun 
                                                                     _b_68 -> _b_67 
                                                                    _b_68)) )) end  

;; let product = _product_48
;;
let rec _enumerate_69  _x_76 = 
     coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
       (( < ) _x_76) >>= (fun  _b_78 -> _b_78 0 >>= (fun  _b_79 -> if _b_79 then Value Nil else 
                                                                   coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _x_76) >>= (fun 
                                                                     _b_80 -> _b_80 
                                                                    1 >>= (fun  _b_81 -> _enumerate_69 
                                                                    _b_81 >>= (fun  _b_82 -> Value (Cons (
                                                                    _x_76, _b_82))))) )) 

;; let enumerate = _enumerate_69
;;
let _run_product_83  = 
     fun (_xs_84: intlist) -> (handler {value_clause = (fun (_id_87: int) -> Value _id_87); 
                                effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Done -> fun (_r_85 : int) _k_86 -> Value _r_85   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                (fun (_x_89: int) -> Value _x_89))) 
                                (_product_48 _xs_84) 

;; let run_product = _run_product_83
;;
let rec _run_91  _x_107 = 
     _enumerate_69 1000 >>= (fun  _xs_119 -> let rec _loop_120 _x_121 = 
                                               Value (fun (_a_122: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( = ) 
                                                                    _x_121) >>= (fun 
                                                                     _b_123 -> _b_123 
                                                                    0 >>= (fun  _b_124 -> if _b_124 then Value _a_122 else 
                                                                    coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _x_121) >>= (fun 
                                                                     _b_125 -> _b_125 
                                                                    1 >>= (fun  _b_126 -> _loop_120 
                                                                    _b_126 >>= (fun  _b_127 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _a_122) >>= (fun  _b_128 -> _run_product_83 
                                                                    _xs_119 >>= (fun  _b_129 -> _b_128 
                                                                    _b_129 >>= (fun  _b_130 -> _b_127 
                                                                    _b_130)))))) ))) 
                                             in 
                                             _loop_120 _x_107 >>= (fun 
                                                _b_131 -> _b_131 0)) 

;; let run = _run_91
;;
