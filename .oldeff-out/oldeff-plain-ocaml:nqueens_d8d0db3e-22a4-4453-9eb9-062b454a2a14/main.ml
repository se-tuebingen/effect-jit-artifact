open OcamlHeader;;type(_, _) eff_internal_effect += Pick : (int, int) eff_internal_effect 
;;
type(_, _) eff_internal_effect += Fail : (unit, empty) eff_internal_effect 
;;
type rows = RowsEmpty | RowsCons of (int * rows)

;;
let _run_42 = 
     fun (_n_43: int) -> let rec _safe_44 _x_101 = 
                            fun (_diag_180: int) -> fun (_xs_181: rows) -> begin match _xs_181 with 
                                                                      RowsEmpty -> true
                                                                     |  RowsCons ((
                                                                    _q_183, _qs_182)) -> ((( <> ) 
                                                                    _x_101 
                                                                    _q_183) && ((( <> ) 
                                                                    _x_101 
                                                                    (( + ) 
                                                                    _q_183 
                                                                    _diag_180)) && (( <> ) 
                                                                    _x_101 
                                                                    (( - ) 
                                                                    _q_183 
                                                                    _diag_180)))) && (_safe_44 
                                                                    _x_101 
                                                                    (( + ) 
                                                                    _diag_180 
                                                                    1) 
                                                                    _qs_182) end  
                         in 
                         let rec _place_64 _x_106 = 
                            fun (_column_148: int) -> if ( = ) _column_148 0 then Value RowsEmpty else 
                                                      _place_64 _x_106 
                                                        (( - ) _column_148 1) >>= (fun 
                                                         _rest_154 ->  Call (Pick, _x_106, (fun 
                                                                    (_y_155: int) -> if 
                                                                    _safe_44 
                                                                    _y_155 1 
                                                                    _rest_154 then Value (RowsCons 
                                                                    (
                                                                    _y_155, _rest_154)) else 
                                                                     Call (Fail, (), (fun 
                                                                    (_y_159: empty) -> Value (match _y_159 with
                                                                     _ -> assert false))) )))  
                         in 
                         force_unsafe 
                           ((handler {value_clause = (fun (_x_161: rows) -> Value 1); 
                              effect_clauses = (fun (type a) (type b) (eff : (a, b) eff_internal_effect) : (a -> (b -> _) -> _) -> 
  (match eff with
    | Fail -> fun () _l_162 -> Value 0  | Pick -> fun _size_163 _l_164 -> Value (
                                                                    let rec _loop_165 _x_166 = 
                                                                     fun 
                                                                    (_a_167: int) -> if 
                                                                    ( = ) 
                                                                    _x_166 
                                                                    _size_163 then ( + ) 
                                                                    _a_167 
                                                                    (coer_arrow coer_refl_ty force_unsafe 
                                                                    _l_164 
                                                                    _x_166) else _loop_165 
                                                                    (( + ) 
                                                                    _x_166 1) 
                                                                    (( + ) 
                                                                    _a_167 
                                                                    (coer_arrow coer_refl_ty force_unsafe 
                                                                    _l_164 
                                                                    _x_166))  
                                                                    in 
                                                                    _loop_165 
                                                                    1 0)   
    | eff' -> (fun arg k -> Call (eff', arg, k))
      )); }) 
                              (_place_64 _n_43 _n_43)) 

;; let run = _run_42
;;
