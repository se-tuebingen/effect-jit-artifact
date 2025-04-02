open OcamlHeader

type (_, _) eff_internal_effect += Yield : (int, unit) eff_internal_effect
type tree = Leaf | Node of (tree * int * tree)
type generator = Empty | Thunk of (int * (unit -> generator))

let _run_42 (_n_43 : int) =
  let rec _make_44 _x_75 =
    match _x_75 with
    | 0 -> Leaf
    | _n_121 ->
        let _t_124 = _make_44 (_n_121 - 1) in
        Node (_t_124, _n_121, _t_124)
  in
  let rec _iterate_50 _x_78 =
    match _x_78 with
    | Leaf -> Value ()
    | Node (_l_100, _v_99, _r_98) ->
        _iterate_50 _l_100 >>= fun _ ->
        Call (Yield, _v_99, fun (_y_101 : unit) -> _iterate_50 _r_98)
  in
  let rec _generate_55 _x_80 =
    force_unsafe
      ((handler
          {
            value_clause = (fun (_x_92 : unit) -> Value Empty);
            effect_clauses =
              (fun (type a b) (eff : (a, b) eff_internal_effect) :
                   (a -> (b -> _) -> _) ->
                match eff with
                | Yield ->
                    fun _x_93 _l_94 ->
                      Value
                        (Thunk
                           (_x_93, coer_arrow coer_refl_ty force_unsafe _l_94))
                | eff' -> fun arg k -> Call (eff', arg, k));
          })
         (_x_80 ()))
  in
  let rec _sum_63 _x_81 (_x_83 : generator) =
    match _x_83 with
    | Empty -> _x_81
    | Thunk (_v_85, _f_84) -> _sum_63 (_v_85 + _x_81) (_f_84 ())
  in
  _sum_63 0 (_generate_55 (fun (() : unit) -> _iterate_50 (_make_44 _n_43)))

let run = _run_42
