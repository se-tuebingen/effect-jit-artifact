open OcamlHeader

type (_, _) eff_internal_effect += Get : (unit, int) eff_internal_effect
type (_, _) eff_internal_effect += Set : (int, unit) eff_internal_effect

let rec _countdown_42 _x_52 =
  Call
    ( Get,
      (),
      fun (_y_56 : int) ->
        if _y_56 = 0 then Value _y_56
        else Call (Set, _y_56 - 1, fun (_y_54 : unit) -> _countdown_42 ()) )

let countdown = _countdown_42

let _run_57 (_n_58 : int) =
  let rec _countdown_72 _x_52 (_s_113 : int) =
    if _s_113 = 0 then _s_113 else _countdown_72 () (_s_113 - 1)
  in
  _countdown_72 () _n_58

let run = _run_57
