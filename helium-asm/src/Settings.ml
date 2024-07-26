
let cur_file_path = ref ""
let current_file_path () = !cur_file_path
let set_current_file_path path = cur_file_path := path

let args_ref = ref []
let set_args args = args_ref := args
let get_args ()   = !args_ref

let source_dirs_ref = ref []
let source_dirs () = List.rev !source_dirs_ref
let add_source_dir dir =
  source_dirs_ref := dir :: !source_dirs_ref

let lib_dirs_ref = ref
  begin match Sys.getenv_opt "HELIUM_LIB" with
  | Some paths -> Str.split (Str.regexp ":") paths
  | None       -> [ "lib" ]
  end
let lib_dirs () = !lib_dirs_ref
let set_lib_dirs dirs = lib_dirs_ref := dirs

let prelude_ref = ref (Some "Prelude")
let auto_open_ref = ref []

let prelude_module () = !prelude_ref
let set_prelude p     = prelude_ref := p

let required_libs_ref = ref []
let required_libs () = !required_libs_ref
let require_lib lib  = required_libs_ref := lib :: !required_libs_ref

let add_auto_open m = auto_open_ref := m :: !auto_open_ref

let auto_open () =
  List.rev !auto_open_ref

let type_printer = ref `Surface
let set_type_printer p  = type_printer := p
let get_type_printer () = !type_printer

let out_filename = ref "a.out"
let get_output_filename () = !out_filename
let set_output_filename filename = out_filename := filename