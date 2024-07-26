open OcamlHeader

(* primitive effect *)
type (_, _) eff_internal_effect += Print : (string, unit) eff_internal_effect

(* primitive effect *)
type (_, _) eff_internal_effect += Read : (unit, string) eff_internal_effect

(* primitive effect *)
type (_, _) eff_internal_effect += Raise : (string, empty) eff_internal_effect

(* primitive effect *)
type (_, _) eff_internal_effect += RandomInt : (int, int) eff_internal_effect

(* primitive effect *)
type (_, _) eff_internal_effect +=
  | RandomFloat : (float, float) eff_internal_effect

(* primitive effect *)
type (_, _) eff_internal_effect +=
  | Write : (string * string, unit) eff_internal_effect

type (_, _) eff_internal_effect += Pick : (int, int) eff_internal_effect
type (_, _) eff_internal_effect += Fail : (unit, empty) eff_internal_effect
type rows = RowsEmpty | RowsCons of (int * rows)

let _run_48 (_n_49 : int) =
  let rec _safe_50 _x_107 (_x_0 : int) =
    coer_return
      (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
      (fun (_xs_167 : rows) ->
        match _xs_167 with
        | RowsEmpty -> Value true
        | RowsCons (_q_169, _qs_168) ->
            coer_return
              (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
              (( <> ) _x_107)
            >>= fun _b_170 ->
            _b_170 _q_169 >>= fun _b_171 ->
            (if _b_171 then
               coer_return
                 (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                 (( <> ) _x_107)
               >>= fun _b_177 ->
               coer_return
                 (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                 (( + ) _q_169)
               >>= fun _b_178 ->
               _b_178 _x_0 >>= fun _b_179 ->
               _b_177 _b_179 >>= fun _b_180 ->
               if _b_180 then
                 coer_return
                   (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                   (( <> ) _x_107)
                 >>= fun _b_181 ->
                 coer_return
                   (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                   (( - ) _q_169)
                 >>= fun _b_182 ->
                 _b_182 _x_0 >>= fun _b_183 -> _b_181 _b_183
               else Value false
             else Value false)
            >>= fun _b_172 ->
            if _b_172 then
              _safe_50 _x_107 >>= fun _b_173 ->
              coer_return
                (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                (( + ) _x_0)
              >>= fun _b_174 ->
              _b_174 1 >>= fun _b_175 ->
              _b_173 _b_175 >>= fun _b_176 -> _b_176 _qs_168
            else Value false)
  in
  let rec _place_70 _x_112 =
    Value
      (fun (_column_153 : int) ->
        coer_return
          (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
          (( = ) _column_153)
        >>= fun _b_154 ->
        _b_154 0 >>= fun _b_155 ->
        if _b_155 then Value RowsEmpty
        else
          _place_70 _x_112 >>= fun _b_156 ->
          coer_return
            (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
            (( - ) _column_153)
          >>= fun _b_157 ->
          _b_157 1 >>= fun _b_158 ->
          _b_156 _b_158 >>= fun _rest_159 ->
          Call
            ( Pick,
              _x_112,
              fun (_y_160 : int) ->
                _safe_50 _y_160 >>= fun _b_161 ->
                _b_161 1 >>= fun _b_162 ->
                _b_162 _rest_159 >>= fun _b_163 ->
                if _b_163 then Value (RowsCons (_y_160, _rest_159))
                else
                  Call
                    ( Fail,
                      (),
                      fun (_y_164 : empty) ->
                        match _y_164 with _ -> assert false ) ))
  in
  (handler
     {
       value_clause = (fun (_x_103 : rows) -> Value 1);
       effect_clauses =
         (fun (type a b) (eff : (a, b) eff_internal_effect) :
              (a -> (b -> _) -> _) ->
           match eff with
           | Fail -> fun (() : unit) _k_86 -> Value 0
           | Pick ->
               fun (_size_87 : int) _k_88 ->
                 let rec _loop_89 _x_113 =
                   Value
                     (fun (_a_117 : int) ->
                       coer_return
                         (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                         (( = ) _x_113)
                       >>= fun _b_118 ->
                       _b_118 _size_87 >>= fun _b_119 ->
                       if _b_119 then
                         coer_return
                           (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                           (( + ) _a_117)
                         >>= fun _b_120 ->
                         _k_88 _x_113 >>= fun _b_121 -> _b_120 _b_121
                       else
                         coer_return
                           (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                           (( + ) _x_113)
                         >>= fun _b_122 ->
                         _b_122 1 >>= fun _b_123 ->
                         _loop_89 _b_123 >>= fun _b_124 ->
                         coer_return
                           (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                           (( + ) _a_117)
                         >>= fun _b_125 ->
                         _k_88 _x_113 >>= fun _b_126 ->
                         _b_125 _b_126 >>= fun _b_127 -> _b_124 _b_127)
                 in
                 _loop_89 1 >>= fun _b_102 -> _b_102 0
           | eff' -> fun arg k -> Call (eff', arg, k));
     }
     (fun (_x_114 : int) -> Value _x_114))
    (_place_70 _n_49 >>= fun _b_106 -> _b_106 _n_49)

let run = _run_48
