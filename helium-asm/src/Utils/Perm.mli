
module type DomainType = sig
  type t
  val compare : t -> t -> int
  val equal   : t -> t -> bool
  
  module Map : Map.S with type key = t
  module Set : Set.S with type elt = t
end

module type S = sig
  module Dom : DomainType

  type t

  val is_id : t -> bool
  
  val id      : t
  val rev     : t -> t
  val compose : t -> t -> t
  val swap    : Dom.t -> Dom.t -> t

  val apply : t -> Dom.t -> Dom.t

  val image_of : t -> Dom.Set.t -> Dom.Set.t
  val carrier  : t -> Dom.Set.t
end

module Make(Dom : DomainType) : S with module Dom := Dom
