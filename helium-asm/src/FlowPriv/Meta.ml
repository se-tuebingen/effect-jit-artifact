
module Key : sig
  type 'a t

  val create : string -> 'a t

  val tag : 'a t -> Tag.t

  type ex =
  | Pack : 'a t -> ex

  val tag_of_ex : ex -> Tag.t

  module Map : Utils.Map1.S with type 'a key = 'a t
end = struct
  module Core = struct
    type 'a t =
      { tag  : Tag.t
      ; name : string
      }

    let uid key = Tag.uid key.tag

    let gequal key1 key2 =
      if Tag.equal key1.tag key2.tag then
        Obj.magic Utils.EqDec.Equal
      else Utils.EqDec.NotEqual
  end
  include Core

  let create name =
    { tag  = Tag.create ~typ:Tag.Meta ("m:" ^ name)
    ; name = name
    }

  let tag k = k.tag

  type ex =
  | Pack : 'a t -> ex

  let tag_of_ex (Pack { tag; _ }) = tag

  module Map = Utils.Map1.Make(Core)
end
type 'a key = 'a Key.t

module Meta = struct
  type 'a t = 'a Utils.UID.Map.t

  let find_opt meta uid =
    Utils.UID.Map.find_opt uid meta
end
include Meta

let find m uid = Utils.UID.Map.find uid m

type ex =
| Pack : 'a key * 'a t -> ex

module Map = Key.Map.Make(Meta)

module MetaData = struct
  type t = Map.t

  let option_uid = Utils.UID.fresh ()

  let empty = Map.empty

  let of_list xs =
    List.fold_left (fun m (Pack(x, y)) -> Map.add x y m) Map.empty xs

  let update m1 m2 =
    Map.merge { merge_f = fun _ v1 v2 ->
        match v2 with
        | Some _ -> v2
        | None   -> v1
      } m1 m2

  let get_meta meta key =
    Map.find key meta

  let set_option meta key v =
    match Map.find_opt key meta with
    | None   -> Map.add key (Utils.UID.Map.singleton option_uid v) meta
    | Some m -> Map.add key (Utils.UID.Map.add option_uid v m) meta

  let find_opt meta key uid =
    match Map.find_opt key meta with
    | None      -> None
    | Some meta -> Meta.find_opt meta uid
  
  let get_option meta key =
    find_opt meta key option_uid
end
