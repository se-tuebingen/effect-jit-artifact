open EqDec

module type UIDType1 = sig
  type 'a t

  val uid : 'a t -> UID.t

  val gequal : 'a t -> 'b t -> ('a, 'b) eq_dec
end

module type TypeFamily1 = sig
  type 'a t
end

module type FS = sig
  type 'a old_t
  type 'a key
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
end

module type S = sig
  type 'a key
  type 'v t

  val empty     : 'v t
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

  module type S = FS
    with type 'a old_t := 'a t
    and  type 'a key := 'a key
  module Make(V : TypeFamily1) : S with type 'a v = 'a V.t
end

module Make(Key : UIDType1) : S with type 'a key = 'a Key.t = struct
  type 'a key = 'a Key.t
  type 'v v =
  | UVal : 'a key * 'v -> 'v v
  type 'v t = 'v v UID.Map.t

  let empty = UID.Map.empty

  let singleton x v =
    UID.Map.singleton (Key.uid x) (UVal(x, v))

  let add x v m =
    UID.Map.add (Key.uid x) (UVal(x, v)) m

  let remove x m =
    UID.Map.remove (Key.uid x) m

  let is_empty = UID.Map.is_empty

  let mem x m =
    UID.Map.mem (Key.uid x) m

  let find x m =
    let (UVal(_, v)) = UID.Map.find (Key.uid x) m in v

  let find_opt x m =
    match UID.Map.find_opt (Key.uid x) m with
    | None -> None
    | Some(UVal(_, v)) -> Some v

  let cardinal = UID.Map.cardinal

  let inter f m1 m2 =
    UID.Map.merge (fun _ v1 v2 ->
      match v1, v2 with
      | None, _ -> None
      | _, None -> None
      | Some(UVal(k1, v1)), Some(UVal(k2, v2)) ->
        Some(UVal(k1, f v1 v2))) m1 m2

  let set_union m1 m2 =
    UID.Map.merge (fun _ v1 v2 ->
      match v1, v2 with
      | Some(UVal(k, ())), _ -> Some (UVal(k, ()))
      | _, Some(UVal(k, ())) -> Some (UVal(k, ()))
      | None, None -> None) m1 m2

  let set_inter = inter (fun () () -> ())

  let diff m1 m2 =
    UID.Map.merge (fun _ v1 v2 ->
      match v1, v2 with
      | None,   _      -> None
      | _,      Some _ -> None
      | Some v, None   -> Some v) m1 m2

  type ('v, 's) fold_f = { fold_f : 'a. 'a key -> 'v -> 's -> 's }
  let fold f m s =
    UID.Map.fold (fun _ (UVal(k, v)) s -> f.fold_f k v s) m s

  module type S = FS
    with type 'a old_t := 'a t
    and  type 'a key := 'a key

  module Make(V : TypeFamily1) : S with type 'a v = 'a V.t = struct
    type 'a v = 'a V.t
    type vv =
    | DVal : 'a key * 'a v -> vv

    type t = vv UID.Map.t

    let empty = UID.Map.empty

    let singleton x v =
      UID.Map.singleton (Key.uid x) (DVal(x, v))

    let add x v m =
      UID.Map.add (Key.uid x) (DVal(x, v)) m

    let remove x m =
      UID.Map.remove (Key.uid x) m

    let is_empty = UID.Map.is_empty

    let mem x m =
      UID.Map.mem (Key.uid x) m

    let unpack_val (type a) (key : a key) v : a v =
      let (DVal(key', v)) = v in
      match Key.gequal key key' with
      | Equal -> v
      | NotEqual -> assert false (* UID is not unique *)

    let unpack_val_opt key v =
      match v with
      | None   -> None
      | Some v -> Some (unpack_val key v)

    let find x m =
      unpack_val x (UID.Map.find (Key.uid x) m)

    let find_opt x m =
      unpack_val_opt x (UID.Map.find_opt (Key.uid x) m)
    
    let cardinal = UID.Map.cardinal
    let carrier m =
      UID.Map.map (fun (DVal(k, _)) -> UVal(k, ())) m

    type map_f = { map_f : 'a. 'a key -> 'a v -> 'a v }
    let map f m =
      UID.Map.map (fun (DVal(k, v)) -> DVal(k, f.map_f k v)) m

    type 'v dmap_f = { dmap_f : 'a. 'a key -> 'v -> 'a v }
    let dmap f m =
      UID.Map.map (fun (UVal(k, v)) -> DVal(k, f.dmap_f k v)) m

    type filter_f = { filter_f : 'a. 'a key -> 'a v -> bool }
    let filter f m =
      UID.Map.filter (fun _ (DVal(k, v)) -> f.filter_f k v) m

    type filter_map_f = { filter_map_f : 'a. 'a key -> 'a v -> 'a v option }
    let filter_map f m =
      UID.Map.fold (fun uid (DVal(k, v)) m ->
          match f.filter_map_f k v with
          | None   -> m
          | Some v -> UID.Map.add uid (DVal(k, v)) m
        ) UID.Map.empty m

    type 's fold_f = { fold_f : 'a. 'a key -> 'a v -> 's -> 's }
    let fold f m s =
      UID.Map.fold (fun _ (DVal(k, v)) s -> f.fold_f k v s) m s

    type merge_f =
      { merge_f : 'a. 'a key -> 'a v option -> 'a v option -> 'a v option }

    let merge f m1 m2 =
      let val_opt x v =
        match v with
        | None   -> None
        | Some v -> Some (DVal(x, v))
      in
      UID.Map.merge begin fun _ v1 v2 ->
          match v1, v2 with
          | None,               None -> None
          | Some (DVal(k1, v1)), v2   ->
            val_opt k1 (f.merge_f k1 (Some v1) (unpack_val_opt k1 v2))
          | None, Some (DVal(k2, v2)) ->
            val_opt k2 (f.merge_f k2 None (Some v2))
        end m1 m2
  end
end
