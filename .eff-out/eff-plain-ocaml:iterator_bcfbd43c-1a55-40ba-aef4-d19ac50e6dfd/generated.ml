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

type (_, _) eff_internal_effect += Emit : (int, unit) eff_internal_effect
type (_, _) eff_internal_effect += Get : (unit, int) eff_internal_effect
type (_, _) eff_internal_effect += Set : (int, unit) eff_internal_effect

let rec _range_48 _x_58 =
  Value
    (fun (_u_62 : int) ->
      coer_return
        (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
        (( > ) _x_58)
      >>= fun _b_63 ->
      _b_63 _u_62 >>= fun _b_64 ->
      if _b_64 then Value ()
      else
        Call
          ( Emit,
            _x_58,
            fun (_y_65 : unit) ->
              coer_return
                (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                (( + ) _x_58)
              >>= fun _b_66 ->
              _b_66 1 >>= fun _b_67 ->
              _range_48 _b_67 >>= fun _b_68 -> _b_68 _u_62 ))

let range = _range_48

let _run_69 (_n_70 : int) =
  (handler
     {
       value_clause =
         (fun (_x_78 : int) ->
           coer_return
             (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
             (fun (_ : int) -> _x_78));
       effect_clauses =
         (fun (type a b) (eff : (a, b) eff_internal_effect) :
              (a -> (b -> _) -> _) ->
           match eff with
           | Get ->
               fun (() : unit) _k_72 ->
                 Value
                   (fun (_s_73 : int) ->
                     _k_72 _s_73 >>= fun _b_74 -> _b_74 _s_73)
           | Set ->
               fun (_s_75 : int) _k_76 ->
                 Value (fun (_ : int) -> _k_76 () >>= fun _b_77 -> _b_77 _s_75)
           | eff' -> fun arg k -> Call (eff', arg, k));
     }
     (fun (_x_89 : int -> int computation) -> Value _x_89))
    ((handler
        {
          value_clause = (fun (_id_86 : int) -> Value _id_86);
          effect_clauses =
            (fun (type a b) (eff : (a, b) eff_internal_effect) :
                 (a -> (b -> _) -> _) ->
              match eff with
              | Emit ->
                  fun (_e_81 : int) _k_82 ->
                    Call
                      ( Get,
                        (),
                        fun (_y_103 : int) ->
                          coer_return
                            (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
                            (( + ) _y_103)
                          >>= fun _b_84 ->
                          _b_84 _e_81 >>= fun _b_83 ->
                          Call (Set, _b_83, fun (_y_101 : unit) -> _k_82 ()) )
              | eff' -> fun arg k -> Call (eff', arg, k));
        }
        (fun (_x_94 : int) -> Value _x_94))
       ( _range_48 0 >>= fun _b_88 ->
         _b_88 _n_70 >>= fun _ ->
         Call (Get, (), fun (_y_98 : int) -> Value _y_98) ))
  >>= fun _b_71 -> _b_71 0

let run = _run_69
