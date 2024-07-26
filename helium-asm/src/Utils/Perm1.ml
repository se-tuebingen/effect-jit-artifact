
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

module Make(Dom : DomainType) : S with module Dom := Dom = struct
  module DDMap = Dom.Map.Make(Dom)

  type t =
    { fwd : DDMap.t
    ; bck : DDMap.t
    }

  let is_id p = DDMap.is_empty p.fwd

  let id =
    { fwd = DDMap.empty
    ; bck = DDMap.empty
    }

  let rev p =
    { fwd = p.bck
    ; bck = p.fwd
    }

  let compose_map m1 m2 =
    DDMap.merge { merge_f = fun x c1 c2 ->
      match c2 with
      | None   -> c1
      | Some y ->
        begin match DDMap.find_opt y m1 with
        | None   -> Some y
        | Some z ->
          if UID.equal (Dom.uid x) (Dom.uid z) then None
          else Some z
        end} m1 m2

  let compose p1 p2 =
    { fwd = compose_map p1.fwd p2.fwd
    ; bck = compose_map p2.bck p1.bck
    }

  let swap x y =
    if UID.equal (Dom.uid x) (Dom.uid y) then id
    else
      let map = DDMap.add x y (DDMap.singleton y x) in
      { fwd = map
      ; bck = map
      }

  let apply perm x =
    match DDMap.find_opt x perm.fwd with
    | None   -> x
    | Some y -> y

  let image_of perm m =
    Dom.Map.fold
      { fold_f = fun x v m -> Dom.Map.add (apply perm x) v m
      } m Dom.Map.empty

  let carrier perm =
    DDMap.carrier perm.fwd
end
