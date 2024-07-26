
val current_file_path     : unit -> string
val set_current_file_path : string -> unit

val set_args : string list -> unit
val get_args : unit -> string list

val source_dirs : unit -> string list
val lib_dirs    : unit -> string list

val add_source_dir : string -> unit
val set_lib_dirs   : string list -> unit

val prelude_module   : unit -> string option
val set_prelude      : string option -> unit

val required_libs : unit -> string list
val require_lib   : string -> unit

val add_auto_open    : string -> unit
val auto_open        : unit -> string list

val set_type_printer : [ `Surface | `Semantic | `SExpr ] -> unit
val get_type_printer : unit -> [ `Surface | `Semantic | `SExpr ]

val get_output_filename     : unit -> string
val set_output_filename : string -> unit