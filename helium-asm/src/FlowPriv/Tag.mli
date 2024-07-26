
type t

type typ =
| Meta
| Other

val uid  : t -> Utils.UID.t
val name : t -> string
val typ  : t -> typ

val compare : t -> t -> int
val equal   : t -> t -> bool

val create : ?typ:typ -> string -> t

module Set : Set.S with type elt = t
module Map : Map.S with type key = t

type rule_action =
| Set    of Set.t
| Add    of Set.t
| Remove of Set.t

type rule =
  { r_when   : Set.t
  ; r_action : rule_action
  }

module Rule : sig
  val set_tags : ?requires: t list -> t list -> rule
  val add_tags : ?requires: t list -> t list -> rule
end

val apply_rules : rule list -> Set.t -> Set.t
