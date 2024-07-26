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
type(_, _) eff_internal_effect += Yield : (int, unit) eff_internal_effect 
;;
type tree = Leaf | Node of (tree * int * tree)

;;
type generator = Empty | Thunk of (int * (unit -> generator computation))

;;
let _run_48  = 
     fun (_n_49: int) -> let rec _make_50 _x_81 = 
                           begin match _x_81 with 
                             0 -> Value Leaf
                            |  _n_111 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                           (( - ) _n_111) >>= (fun  _b_112 -> _b_112 
                                                                    1 >>= (fun  _b_113 -> _make_50 
                                                                    _b_113 >>= (fun  _t_114 -> Value (Node (
                                                                    _t_114, _n_111, _t_114))))) end  
                         in 
                         let rec _iterate_56 _x_84 = 
                           begin match _x_84 with 
                             Leaf -> Value ()
                            |  (Node (_l_108, _v_107, _r_106)) -> _iterate_56 
                                                                    _l_108 >>= (fun 
                                                                     _ ->  Call (Yield, (_v_107), (fun 
                                                                    (_y_109: unit) -> _iterate_56 
                                                                    _r_106))) end  
                         in 
                         let rec _generate_61 _x_86 = 
                           (handler {value_clause = (fun (_x_100: unit) -> Value Empty); 
                             effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Yield -> fun (_x_101 : int) _k_102 -> Value (Thunk 
                                                                    (
                                                                    _x_101, _k_102))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                             (fun (_x_99: generator) -> Value _x_99))) 
                             (_x_86 ()) 
                         in 
                         let rec _sum_69 _x_87 = 
                           Value (fun (_x_89: generator) -> begin match _x_89 with 
                                                              Empty -> Value _x_87
                                                             |  (Thunk (
                                                                    _v_91, _f_90)) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _v_91) >>= (fun  _b_92 -> _b_92 
                                                                    _x_87 >>= (fun  _b_93 -> _sum_69 
                                                                    _b_93 >>= (fun  _b_94 -> _f_90 
                                                                    () >>= (fun  _b_95 -> _b_94 
                                                                    _b_95)))) end ) 
                         in 
                         _sum_69 0 >>= (fun  _b_78 -> _generate_61 
                                                        (fun ((): unit) -> _make_50 
                                                                    _n_49 >>= (fun 
                                                                     _b_80 -> _iterate_56 
                                                                    _b_80)) >>= (fun 
                                                         _b_79 -> _b_78 _b_79)) 

;; let run = _run_48
;;
