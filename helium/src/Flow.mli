
type tag
type 'a node
type 'a meta_key
type 'a meta = 'a Utils.UID.Map.t
type metadata
type state

type command =
| Skip
| Tags of tag list
| Seq  of command * command

type 'tgt result

type ('src, 'tgt) transform =
  'src -> metadata -> 'tgt result

exception Error of state

type error =
| UnsupportedExtension of string
| InvariantViolation   of state * tag
| CannotFindPath : 'src node * tag list * tag list -> error

val error_node : error node

val cmd_line_options : unit -> (string * Arg.spec * string) list

val get_command : command -> command

val source : string -> state
val repl   : in_channel -> state

val exec : state -> command -> state
val run_to_node : state -> 'a node -> 'a

module Tag : sig
  type t = tag

  val create :
    ?cmd_line_flag:string ->
    ?cmd_line_descr:string ->
    string -> t

  val name : t -> string
end

module Node : sig
  type 'a t = 'a node

  val create :
    ?cmd_line_flag:string ->
    ?cmd_line_descr:string ->
    string -> 'a t

  val name : 'a t -> string
end

module MetaKey : sig
  type 'a t = 'a meta_key

  val create : string -> 'a t

  type ex =
  | Pack : 'a meta_key -> ex
end

module Meta : sig
  type 'a t = 'a meta

  val find : 'a t -> Utils.UID.t -> 'a

  type ex =
  | Pack : 'a meta_key * 'a t -> ex
end

module MetaData : sig
  type t = metadata

  val empty   : t
  val of_list : Meta.ex list -> t
  val update  : t -> t -> t

  val get_option : t -> 'a meta_key -> 'a option

  val get_meta : t -> 'a meta_key -> 'a meta

  val find_opt : t -> 'a meta_key -> Utils.UID.t -> 'a option
end

module State : sig
  type t = state

  val create : ?tags:tag list -> ?meta:metadata -> 'a node -> 'a -> t

  val node_name : t -> string

  val set_option : 'a meta_key -> 'a -> t -> t
end

module Command : sig
  type t = command =
  | Skip
  | Tags of tag list
  | Seq  of t * t

  val node :
    ?tags: tag list ->
    'a node -> t
end

val return :
  ?meta: Meta.ex list ->
  'a -> 'a result
val error  :
  node: 'err node ->
  'err -> 'a result

val register_file_extension : string -> string node -> unit

val register_transform :
  source: 'src node ->
  target: 'tgt node ->
  name:   string ->
  ?weight:         float ->
  ?requires_tags:  tag list ->
  ?provides_tags:  tag list ->
  ?preserves_tags: tag list ->
  ?requires_meta:  MetaKey.ex list ->
  ?provides_meta:  MetaKey.ex list ->
  ?preserves_meta: MetaKey.ex list ->
  ?cmd_line_flag:  string ->
  ?cmd_line_descr: string ->
  ('src, 'tgt) transform -> tag

val register_repl :
  target: 'tgt node ->
  name:    string ->
  ?weight: float ->
  (in_channel, 'tgt) transform -> tag

val register_parser :
  extension: string ->
  source:    string ->
  target:    'tgt node ->
  name:      string ->
  (string, 'tgt) transform -> tag

val register_analysis :
  node: 'a node ->
  name: string  ->
  ?weight: float ->
  ?requires_tags: tag list ->
  ?provides_tags: tag list ->
  ?requires_meta: MetaKey.ex list ->
  ?provides_meta: MetaKey.ex list ->
  ('a, unit) transform -> tag

val register_invariant_checker :
  node:   'a node ->
  checks: tag ->
  name:   string ->
  ?requires_tags: tag list ->
  ?requires_meta: MetaKey.ex list ->
  ('a, bool) transform -> tag
