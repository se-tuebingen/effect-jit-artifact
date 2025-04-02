open OcamlHeader

type (_, _) eff_internal_effect += Done : (int, int) eff_internal_effect
type intlist = Nil | Cons of (int * intlist)

let rec _product_42 _x_52 =
  match _x_52 with
  | Nil -> Value 0
  | Cons (_y_57, _ys_56) ->
      if _y_57 = 0 then Call (Done, 0, fun (_y_60 : int) -> Value _y_60)
      else _product_42 _ys_56 >>= fun _b_62 -> Value (_y_57 * _b_62)

let product = _product_42

let rec _enumerate_63 _x_70 =
  if _x_70 < 0 then Nil else Cons (_x_70, _enumerate_63 (_x_70 - 1))

let enumerate = _enumerate_63

let _run_product_77 (_xs_78 : intlist) =
  let rec _product_95 (_x_52, _k_97) =
    match _x_52 with
    | Nil -> _k_97 0
    | Cons (_y_57, _ys_56) ->
        if _y_57 = 0 then 0
        else _product_95 (_ys_56, fun (_b_122 : int) -> _k_97 (_y_57 * _b_122))
  in
  _product_95 (_xs_78, fun (_id_81 : int) -> _id_81)

let run_product = _run_product_77

let rec _run_124 _x_140 =
  let rec _loop_153 _x_154 (_a_155 : int) =
    if _x_154 = 0 then _a_155
    else _loop_153 (_x_154 - 1) (_a_155 + _run_product_77 (_enumerate_63 1000))
  in
  _loop_153 _x_140 0

let run = _run_124
