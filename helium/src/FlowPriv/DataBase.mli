open Graph

val check_invariants : bool ref

val add_cmd_line_option :
  ?cmd_line_flag:  string ->
  ?cmd_line_descr: string ->
    Command.t -> unit

val get_cmd_line_options : unit -> (string * Arg.spec * string) list

val get_command : Command.t -> Command.t

val find_extension : string -> string node option

val register_file_extension : string -> string node -> unit
val register_transform : 'src edge -> unit
val register_invariant_checker : 'a node -> 'a invariant_checker -> unit
