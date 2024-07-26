
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

module Impl : Export = struct
  type nonrec ktype   = ktype
  type nonrec keffect = keffect
  type nonrec keffsig = keffsig

  type 'a kind = 'a t =
  | KType   : ktype kind
  | KEffect : keffect kind
  | KEffsig : keffsig kind
  | KArrow  : 'k1 kind * 'k2 kind -> ('k1 -> 'k2) kind

  module Kind = struct
    let rec equal : type k1 k2.
      k1 kind -> k2 kind -> (k1, k2) Utils.EqDec.eq_dec =
      fun k1 k2 ->
      match k1, k2 with
      | KType,   KType   -> Equal
      | KType,   _       -> NotEqual
      | KEffect, KEffect -> Equal
      | KEffect, _       -> NotEqual
      | KEffsig, KEffsig -> Equal
      | KEffsig, _       -> NotEqual
      | KArrow(ka1, kv1), KArrow(ka2, kv2) ->
        begin match equal ka1 ka2 with
        | Equal ->
          begin match equal kv1 kv2 with
          | Equal    -> Equal
          | NotEqual -> NotEqual
          end
        | NotEqual -> NotEqual
        end
      | KArrow _, _ -> NotEqual

    let rec to_sexpr : type k. k kind -> SExpr.t =
      function
      | KType   -> Special "type"
      | KEffect -> Special "effect"
      | KEffsig -> Special "effsig"
      | KArrow(k1, k2) ->
        SExpr.tagged_list "->" [ to_sexpr k1; to_sexpr k2 ]

    module Ex = Utils.Exists.Make(struct type 'k t = 'k kind end)
    include Ex.Datatypes
  end
end

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

module KindedVar : KindedVar_S = struct
  open Impl

  module Core = struct
    type 'k t =
      { uid  : Utils.UID.t
      ; kind : 'k kind
      }

    let uid  x = x.uid

    let gequal x y =
      if Utils.UID.equal x.uid y.uid then
        Impl.Kind.equal x.kind y.kind
      else
        NotEqual
  end
  include Core

  let kind x = x.kind

  let fresh kind =
    { uid  = Utils.UID.fresh ()
    ; kind = kind
    }
  let clone x = fresh x.kind

  let equal x y = Utils.UID.equal x.uid y.uid

  let unique_name x = Utils.UID.to_string x.uid

  module Map = Utils.Map1.Make(Core)
  module Ex  = Utils.Exists.Make(Core)
  include Ex.Datatypes
end
