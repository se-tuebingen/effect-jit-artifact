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

type (_, _) eff_internal_effect += Pred : (int, bool) eff_internal_effect

let _main_48 = 0

let main = _main_48
