open Lang.Unif

module Prec = struct
  let prec_annot   = 30
  let prec_annot_r = prec_annot + 1

  let prec_arrow   = 40
  let prec_arrow_l = prec_arrow + 1
  let prec_arrow_r = prec_arrow

  let prec_list_member = 41

  let prec_app   = 200
  let prec_app_l = prec_app
  let prec_app_r = prec_app + 1
end

let rec pretty_kind : type k. int -> k kind -> Box.t =
  fun prec k ->
  match k with
  | KType   -> Box.kw "type"
  | KEffect -> Box.kw "effect"
  | KEffsig -> Box.kw "effsig"
  | KArrow(k1, k2) ->
    Box.prec_paren 0 prec (Box.box
      [ Box.suffix (pretty_kind 1 k1) (Box.ws (Box.oper "->"))
      ; Box.ws (Box.indent 2 (pretty_kind 0 k2))
      ])
