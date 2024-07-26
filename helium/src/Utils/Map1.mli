
module type UIDType1 = sig
  type 'a t

  val uid : 'a t -> UID.t

  val gequal : 'a t -> 'b t -> ('a, 'b) EqDec.eq_dec
end

module type TypeFamily1 = sig
  type 'a t
end

module type S = sig
  type 'a key
  type 'v t

  val empty     : 'a t
  val singleton : 'a key -> 'v -> 'v t
  val add       : 'a key -> 'v -> 'v t -> 'v t

  val remove : 'a key -> 'v t -> 'v t

  val is_empty : 'v t -> bool
  val mem      : 'a key -> 'v t -> bool
  val find     : 'a key -> 'v t -> 'v
  val find_opt : 'a key -> 'v t -> 'v option

  val cardinal : 'a t -> int

  val inter     : ('v1 -> 'v2 -> 'v) -> 'v1 t -> 'v2 t -> 'v t
  val set_union : unit t -> unit t -> unit t
  val set_inter : unit t -> unit t -> unit t
  val diff      : 'v1 t -> 'v2 t -> 'v1 t

  type ('v, 's) fold_f = { fold_f : 'a. 'a key -> 'v -> 's -> 's }
  val fold : ('v, 's) fold_f -> 'v t -> 's -> 's

  module type S = sig
    type 'a old_t = 'a t
    type 'a v
    type t

    val empty     : t
    val singleton : 'a key -> 'a v -> t
    val add       : 'a key -> 'a v -> t -> t

    val remove : 'a key -> t -> t

    val is_empty : t -> bool
    val mem      : 'a key -> t -> bool
    val find     : 'a key -> t -> 'a v
    val find_opt : 'a key -> t -> 'a v option

    val cardinal : t -> int
    val carrier  : t -> unit old_t

    type map_f = { map_f : 'a. 'a key -> 'a v -> 'a v }
    val map : map_f -> t -> t

    type 'v dmap_f = { dmap_f : 'a. 'a key -> 'v -> 'a v }
    val dmap : 'v dmap_f -> 'v old_t -> t

    type filter_f = { filter_f : 'a. 'a key -> 'a v -> bool }
    val filter : filter_f -> t -> t

    type filter_map_f = { filter_map_f : 'a. 'a key -> 'a v -> 'a v option }
    val filter_map : filter_map_f -> t -> t

    type 's fold_f = { fold_f : 'a. 'a key -> 'a v -> 's -> 's }
    val fold : 's fold_f -> t -> 's -> 's

    type merge_f =
      { merge_f : 'a. 'a key -> 'a v option -> 'a v option -> 'a v option }
    val merge : merge_f -> t -> t -> t
  end with type 'a old_t := 'a t

  module Make(V : TypeFamily1) : S with type 'a v = 'a V.t
end

module Make(Key : UIDType1) : S with type 'a key = 'a Key.t
