open OcamlHeader;;type(_, _) eff_internal_effect += Choose : (unit, bool) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Get : (unit, int) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Set : (int, unit) eff_internal_effect 
;;
type tree = Leaf | Node of (tree * int * tree)

;;
let _operator_42 = 
     fun (_x_43: int) -> fun (_y_44: int) -> ( mod ) 
                                               (abs 
                                                  (( + ) 
                                                     (( - ) _x_43 
                                                        (( * ) 503 _y_44)) 37)) 
                                               1009 

;; let operator = _operator_42
;;
type intlist = Nil | Cons of (int * intlist)

;;
let rec _op_53 (* @ *) _x_60 = 
      fun (_ys_62: intlist) -> begin match _x_60 with 
                                 Nil -> _ys_62
                                |  Cons ((_x_64, _xs_63)) -> Cons (_x_64, 
                                                                   _op_53 (* @ *) 
                                                                    _xs_63 
                                                                    _ys_62) end  

;; let _op_53 (* @ *) = _op_53 (* @ *)
;;
let rec _make_67 _x_73 = 
      begin match _x_73 with 
        0 -> Leaf
       |  _n_75 -> let _t_78 = _make_67 (( - ) _n_75 1) in 
                   Node (_t_78, _n_75, _t_78) end  

;; let make = _make_67
;;
let _max_79 = 
     fun (_a_80: int) -> fun (_b_81: int) -> if ( > ) _a_80 _b_81 then _a_80 else _b_81  

;; let max = _max_79
;;
let rec _maxl_84 _x_92 = 
      fun (_x_94: intlist) -> begin match _x_94 with 
                                Nil -> _x_92
                               |  Cons ((_x_96, _xs_95)) -> _maxl_84 
                                                              (_max_79 _x_96 
                                                                 _x_92) 
                                                              _xs_95 end  

;; let maxl = _maxl_84
;;
let _run_100 = 
     fun (_n_101: int) -> let rec _loop_197 _x_198 = 
                             fun (_i_199: int) -> if ( = ) _i_199 0 then _x_198 else 
                                                  let (_s'_204, _l_203) = 
                                                  let rec _explore_258 (
                                                    _x_162, _k_260) = 
                                                     fun (_x_1: int) -> begin match _x_162 with 
                                                                      Leaf -> _k_260 
                                                                    _x_1 _x_1
                                                                     |  Node ((
                                                                    _l_230, _v_229, _r_228)) -> let _l_165 = 
                                                                    fun 
                                                                    (_y_231: bool) -> fun 
                                                                    (_x_0: int) -> if _y_231 then 
                                                                    _explore_258 
                                                                    (_l_230, (
                                                                    fun 
                                                                    (_b_335: int) -> _k_260 
                                                                    (_operator_42 
                                                                    _v_229 
                                                                    _b_335))) 
                                                                    (_operator_42 
                                                                    _x_0 
                                                                    _v_229) else _explore_258 
                                                                    (_r_228, (
                                                                    fun 
                                                                    (_b_361: int) -> _k_260 
                                                                    (_operator_42 
                                                                    _v_229 
                                                                    _b_361))) 
                                                                    (_operator_42 
                                                                    _x_0 
                                                                    _v_229)  in 
                                                                    let (
                                                                    _s'_126, _l_127) = 
                                                                    _l_165 
                                                                    true _x_1 in 
                                                                    let (
                                                                    _s'_130, _r_131) = 
                                                                    _l_165 
                                                                    false 
                                                                    _s'_126 in 
                                                                    (
                                                                    _s'_130, 
                                                                    _op_53 (* @ *) 
                                                                    _l_127 
                                                                    _r_131) end  
                                                  in 
                                                  _explore_258 
                                                    (_make_67 _n_101, (
                                                     fun (_x_134: int) -> fun 
                                                                    (_u_195: int) -> (_u_195, Cons 
                                                                    (
                                                                    _x_134, Nil)))) 
                                                    _x_198 in 
                                                  _loop_197 
                                                    (_maxl_84 0 _l_203) 
                                                    (( - ) _i_199 1)  
                          in 
                          _loop_197 0 10 

;; let run = _run_100
;;
