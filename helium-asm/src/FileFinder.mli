type t

type 'a result =
| NotFound
| DependencyLoop of string list
| Found          of string * Lang.Common.source_level * 'a 
| FlowError      of Flow.state

val key : t Flow.meta_key

val level      : t -> Lang.Common.source_level
val as_prelude : t -> t

val default : Lang.Common.source_level -> t

val find_corresponding_unif_sig : t -> Lang.Unif.intf_file result

val find_unif_sig : t -> string -> Lang.Unif.intf_file result

val find_core_impl : Lang.Core.import -> Lang.Core.source_file option
