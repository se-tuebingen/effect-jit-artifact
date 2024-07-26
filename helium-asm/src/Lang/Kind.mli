(** Common implementation of well-kinded kinds *)

type ktype   = Dummy_KType
type keffect = Dummy_KEffect
type keffsig = Dummy_KEffsig

type _ t =
| KType   : ktype t
| KEffect : keffect t
| KEffsig : keffsig t
| KArrow  : 'k1 t * 'k2 t -> ('k1 -> 'k2) t

module type Export = sig
  type nonrec ktype   = ktype
  type nonrec keffect = keffect
  type nonrec keffsig = keffsig

  type 'a kind = 'a t =
  | KType   : ktype kind
  | KEffect : keffect kind
  | KEffsig : keffsig kind
  | KArrow  : 'k1 kind * 'k2 kind -> ('k1 -> 'k2) kind

  module Kind : sig
    val equal : 'k1 kind -> 'k2 kind -> ('k1, 'k2) Utils.EqDec.eq_dec

    val to_sexpr : 'k kind -> SExpr.t

    module Ex : Utils.Exists.S with type 'k data = 'k kind
    include module type of Ex.Datatypes
  end
end

module Impl : Export

module type KindedVar_S = sig
  type 'k t

  val uid  : 'k t -> Utils.UID.t
  val kind : 'k t -> 'k Impl.kind

  val fresh : 'k Impl.kind -> 'k t
  val clone : 'k t -> 'k t

  val equal  : 'k t -> 'k t -> bool
  val gequal : 'k1 t -> 'k2 t -> ('k1, 'k2) Utils.EqDec.eq_dec

  val unique_name : 'k t -> string

  module Map : Utils.Map1.S with type 'k key = 'k t
  module Ex  : Utils.Exists.S with type 'k data = 'k t
  include module type of Ex.Datatypes
end

module KindedVar : KindedVar_S
