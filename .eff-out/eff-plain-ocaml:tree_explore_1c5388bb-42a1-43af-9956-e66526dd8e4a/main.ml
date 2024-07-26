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
type(_, _) eff_internal_effect += Choose : (unit, bool) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Get : (unit, int) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Set : (int, unit) eff_internal_effect 
;;
type tree = Leaf | Node of (tree * int * tree)

;;
let _operator_48  = 
     fun (_x_49: int) -> fun (_y_50: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                               (( - ) _x_49) >>= (fun 
                                                _b_56 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                           (( * ) 503) >>= (fun 
                                                            _b_58 -> _b_58 
                                                                    _y_50 >>= (fun 
                                                                     _b_57 -> _b_56 
                                                                    _b_57 >>= (fun 
                                                                     _b_55 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( + ) 
                                                                    _b_55) >>= (fun 
                                                                     _b_54 -> _b_54 
                                                                    37 >>= (fun  _b_53 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( mod ) 
                                                                    (abs 
                                                                    _b_53)) >>= (fun  _b_51 -> _b_51 
                                                                    1009))))))) 

;; let operator = _operator_48
;;
type intlist = Nil | Cons of (int * intlist)

;;
let rec _op_59 (* @ *)  _x_66 = 
     Value (fun (_ys_68: intlist) -> begin match _x_66 with 
                                       Nil -> Value _ys_68
                                      |  (Cons (_x_70, _xs_69)) -> _op_59 (* @ *) 
                                                                    _xs_69 >>= (fun 
                                                                     _b_71 -> _b_71 
                                                                    _ys_68 >>= (fun 
                                                                     _b_72 -> Value (Cons (
                                                                    _x_70, _b_72)))) end ) 

;; let _op_59 (* @ *) = _op_59 (* @ *)
;;
let rec _make_73  _x_79 = 
     begin match _x_79 with 
       0 -> Value Leaf
      |  _n_81 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                    (( - ) _n_81) >>= (fun  _b_82 -> _b_82 1 >>= (fun 
                                                        _b_83 -> _make_73 
                                                                   _b_83 >>= (fun 
                                                                    _t_84 -> Value (Node (
                                                                    _t_84, _n_81, _t_84))))) end  

;; let make = _make_73
;;
let _max_85 _tycoer_115
     _tycoer_121
     _tycoer_119
     _tycoer_110
     _tycoer_111
     _tycoer_117 = 
     fun (_a_86: 'ty74) -> fun (_b_87: 'ty75) -> coer_computation (coer_arrow _tycoer_115 coer_refl_ty) 
                                                   (coer_return (coer_arrow _tycoer_121 (coer_return coer_refl_ty)) 
                                                      (( > ) 
                                                         (_tycoer_117 _a_86))) >>= (fun 
                                                    _b_89 -> _b_89 
                                                               (_tycoer_119 
                                                                  _b_87) >>= (fun 
                                                                _b_88 -> if _b_88 then 
                                                                    coer_return _tycoer_111 
                                                                    _a_86 else 
                                                                    coer_return _tycoer_110 
                                                                    _b_87 )) 

;; let max = _max_85
;;
let rec _maxl_90  _x_98 = 
     Value (fun (_x_100: intlist) -> begin match _x_100 with 
                                       Nil -> Value _x_98
                                      |  (Cons (_x_102, _xs_101)) -> _max_85 coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty
                                                                    coer_refl_ty 
                                                                    _x_102 
                                                                    _x_98 >>= (fun 
                                                                     _b_104 -> _maxl_90 
                                                                    _b_104 >>= (fun 
                                                                     _b_105 -> _b_105 
                                                                    _xs_101)) end ) 

;; let maxl = _maxl_90
;;
let _run_106  = 
     fun (_n_107: int) -> _make_73 _n_107 >>= (fun  _tree_108 -> let rec _explore_109 _x_168 = 
                                                                   begin match _x_168 with 
                                                                     Leaf ->  Call (Get, (()), (fun 
                                                                    (_y_283: int) -> Value _y_283))
                                                                    | 
                                                                    (Node (
                                                                    _l_286, _v_285, _r_284)) ->  Call (Choose, (()), (fun 
                                                                    (_y_287: bool) -> (if _y_287 then Value _l_286 else Value _r_284 ) >>= (fun 
                                                                     _next_288 ->  Call (Get, (()), (fun 
                                                                    (_y_289: int) -> _operator_48 
                                                                    _y_289 
                                                                    _v_285 >>= (fun  _q_291 ->  Call (Set, (_q_291), (fun 
                                                                    (_y_292: unit) -> _explore_109 
                                                                    _next_288 >>= (fun  _b_294 -> _operator_48 
                                                                    _v_285 
                                                                    _b_294))))))))) end  
                                                                 in 
                                                                 let rec _loop_225 _x_226 = 
                                                                   Value (
                                                                   fun 
                                                                    (_i_227: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( = ) 
                                                                    _i_227) >>= (fun  _b_228 -> _b_228 
                                                                    0 >>= (fun  _b_229 -> if _b_229 then Value _x_226 else 
                                                                    (handler {
                                                                    value_clause = (fun 
                                                                    (_x_140: int) -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (fun 
                                                                    (_u_211: int) -> (_u_211, Cons 
                                                                    (
                                                                    _x_140, Nil)))); 
                                                                    effect_clauses = 
                                                                    (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Get -> fun (() : unit) _k_122 -> Value (
                                                                    fun 
                                                                    (_s_123: int) -> _k_122 
                                                                    _s_123 >>= (fun  _b_124 -> _b_124 
                                                                    _s_123))  | Set -> fun (_s_125 : int) _k_126 -> Value (
                                                                    fun 
                                                                    (_: int) -> _k_126 
                                                                    () >>= (fun  _b_127 -> _b_127 
                                                                    _s_125))  | Choose -> fun (() : unit) _k_128 -> Value (
                                                                    fun 
                                                                    (_s_129: int) -> _k_128 
                                                                    true >>= (fun  _b_131 -> _b_131 
                                                                    _s_129 >>= (fun  _b_130 -> let (
                                                                    _s'_132, _l_133) = _b_130 in 
                                                                    _k_128 
                                                                    false >>= (fun 
                                                                     _b_135 -> _b_135 
                                                                    _s'_132 >>= (fun 
                                                                     _b_134 -> let (
                                                                    _s'_136, _r_137) = _b_134 in 
                                                                    _op_59 (* @ *) 
                                                                    _l_133 >>= (fun 
                                                                     _b_139 -> _b_139 
                                                                    _r_137 >>= (fun 
                                                                     _b_138 -> Value (_s'_136, _b_138))))))))   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      ));} (
                                                                    (fun 
                                                                    (_x_169: (int -> (int *
                                                                    intlist) computation)) -> Value _x_169))) 
                                                                    (_explore_109 
                                                                    _tree_108) >>= (fun 
                                                                     _b_230 -> _b_230 
                                                                    _x_226 >>= (fun 
                                                                     _b_231 -> (let (
                                                                    _s'_237, _l_236) = _b_231 in 
                                                                    _maxl_90 
                                                                    0 >>= (fun 
                                                                     _b_238 -> _b_238 
                                                                    _l_236)) >>= (fun 
                                                                     _s_232 -> _loop_225 
                                                                    _s_232 >>= (fun 
                                                                     _b_233 -> coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) 
                                                                    (( - ) 
                                                                    _i_227) >>= (fun 
                                                                     _b_234 -> _b_234 
                                                                    1 >>= (fun  _b_235 -> _b_233 
                                                                    _b_235)))))) ))) 
                                                                 in 
                                                                 _loop_225 0 >>= (fun 
                                                                    _b_239 -> _b_239 
                                                                    10)) 

;; let run = _run_106
;;
