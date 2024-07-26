open Lang.Unif

module Prec : sig
  val prec_annot_r : int

  val prec_arrow   : int
  val prec_arrow_l : int
  val prec_arrow_r : int

  val prec_list_member : int

  val prec_app   : int
  val prec_app_l : int
  val prec_app_r : int
end

val pretty_kind : int -> 'k kind -> Box.t
