
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

module Make(Dom : DomainType) : S with module Dom := Dom = struct
  type t =
    { fwd : Dom.t Dom.Map.t
    ; bck : Dom.t Dom.Map.t
    }

  let is_id p = Dom.Map.is_empty p.fwd

  let id =
    { fwd = Dom.Map.empty
    ; bck = Dom.Map.empty
    }

  let rev p =
    { fwd = p.bck
    ; bck = p.fwd
    }

  let compose_map m1 m2 =
    Dom.Map.merge (fun x c1 c2 ->
      match c2 with
      | None   -> c1
      | Some y ->
        begin match Dom.Map.find_opt y m1 with
        | None   -> Some y
        | Some z ->
          if Dom.equal x z then None
          else Some z
        end) m1 m2

  let compose p1 p2 =
    { fwd = compose_map p1.fwd p2.fwd
    ; bck = compose_map p2.bck p1.bck
    }

  let swap x y =
    if Dom.equal x y then id
    else
      let map = Dom.Map.add x y (Dom.Map.singleton y x) in
      { fwd = map
      ; bck = map
      }

  let apply perm x =
    match Dom.Map.find_opt x perm.fwd with
    | None   -> x
    | Some y -> y

  let image_of perm set =
    Dom.Set.map (apply perm) set

  let carrier perm =
    perm.fwd
    |> Dom.Map.bindings
    |> List.map (fun (x, y) ->
        assert (not (Dom.equal x y));
        x)
    |> Dom.Set.of_list
end
