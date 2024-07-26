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

let rec _fibonacci_48 _x_61 =
  coer_return (coer_arrow coer_refl_ty (coer_return coer_refl_ty)) (( = ) _x_61)
  >>= fun _b_63 ->
  _b_63 0 >>= fun _b_64 ->
  if _b_64 then Value 0
  else
    coer_return
      (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
      (( = ) _x_61)
    >>= fun _b_65 ->
    _b_65 1 >>= fun _b_66 ->
    if _b_66 then Value 1
    else
      coer_return
        (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
        (( - ) _x_61)
      >>= fun _b_67 ->
      _b_67 1 >>= fun _b_68 ->
      _fibonacci_48 _b_68 >>= fun _b_69 ->
      coer_return
        (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
        (( + ) _b_69)
      >>= fun _b_70 ->
      coer_return
        (coer_arrow coer_refl_ty (coer_return coer_refl_ty))
        (( - ) _x_61)
      >>= fun _b_71 ->
      _b_71 2 >>= fun _b_72 ->
      _fibonacci_48 _b_72 >>= fun _b_73 -> _b_70 _b_73

let fibonacci = _fibonacci_48
