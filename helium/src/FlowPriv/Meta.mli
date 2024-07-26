
module Key : sig
  type 'a t

  val create : string -> 'a t

  val tag : 'a t -> Tag.t

  type ex =
  | Pack : 'a t -> ex

  val tag_of_ex : ex -> Tag.t

  module Map : Utils.Map1.S with type 'a key = 'a t
end
type 'a key = 'a Key.t

type 'a t = 'a Utils.UID.Map.t

val find : 'a t -> Utils.UID.t -> 'a

type ex =
| Pack : 'a key * 'a t -> ex

module Map : Key.Map.S with type 'a v = 'a t

module MetaData : sig
  type t = Map.t

  val empty   : t
  val of_list : ex list -> t
  val update  : t -> t -> t

  val get_option : t -> 'a key -> 'a option
  val set_option : t -> 'a key -> 'a -> t

  val get_meta : t -> 'a key -> 'a Utils.UID.Map.t

  val find_opt : t -> 'a key -> Utils.UID.t -> 'a option
end
