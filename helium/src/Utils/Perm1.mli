
module type DomainType = sig
  type 'a t
  
  val uid : 'a t -> UID.t

  module Map : Map1.S with type 'a key = 'a t
end

module type S = sig
  module Dom : DomainType

  type t

  val is_id : t -> bool

  val id      : t
  val rev     : t -> t
  val compose : t -> t -> t
  val swap    : 'a Dom.t -> 'a Dom.t -> t

  val apply : t -> 'a Dom.t -> 'a Dom.t

  val image_of : t -> 'a Dom.Map.t -> 'a Dom.Map.t
  val carrier  : t -> unit Dom.Map.t
end

module Make(Dom : DomainType) : S with module Dom := Dom
