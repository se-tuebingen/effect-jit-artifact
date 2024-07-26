
let usage_string =
  "Usage: helium [OPTION]... [FILE [CMD_ARG]...]\nAvailable OPTIONs are:"

let args = ref []

let cmd_args_options = Arg.align (
  [ "-verbose",
    Arg.Set Log.enabled,
    " Run in verbose mode"
  ; "-I",
    Arg.String Settings.add_source_dir,
    "<dir> Add <dir> to the list of include directories"
  ; "-no-stdlib",
    Arg.Unit (fun () -> Settings.set_lib_dirs []),
    " Do not use standard library"
  ; "-no-prelude",
    Arg.Unit (fun () -> Settings.set_prelude None),
    " Do not open Prelude module"
  ; "-prelude",
    Arg.String (fun s -> Settings.set_prelude (Some s)),
    "<module> Use <module> instead of Prelude"
  ; "-open",
    Arg.String Settings.add_auto_open,
    "<module> Open <module> before typing"
  ; "-where",
    Arg.Unit (fun () ->
      List.iter print_endline (Settings.lib_dirs ()); exit 0),
    " Print location of standard library and exit"
  ; "-args",
    Arg.Rest (fun arg -> args := arg :: !args),
    "[CMD_ARG]... Pass remaining arguments to interpreted program"
  ; "-type-printer",
    Arg.Symbol(["surface";"semantic";"sexpr"], fun sym ->
      Settings.set_type_printer
        begin match sym with
        | "surface"  -> `Surface
        | "semantic" -> `Semantic
        | "sexpr"    -> `SExpr
        | _          -> assert false
        end),
    " Set type printer used by user interface"
  ; "-output",
    Arg.String (fun s -> Settings.set_output_filename s),
    "<filename> Set <filename> for the compiler output"
  ] @ Flow.cmd_line_options ())

let fname = ref None
let proc_arg arg =
  match !fname with
  | None   ->
    fname := Some arg;
    (* Hack: change current argument to -args and reparse it in order
      to pass remaining arguments to interpreted program *)
    Sys.argv.(!Arg.current) <- "-args";
    Arg.current := !Arg.current - 1
  | Some _ -> assert false

let default_command = Flow.Tags [ CommonTags.eval ]

let _ =
  Predef.StdExtern.register ();
  Invariant.Main.register ();
  Transform.Main.register ();
  try
    Arg.parse cmd_args_options proc_arg usage_string;
    Settings.set_args (List.rev !args);
    let state =
      match !fname with
      | None ->
        Settings.require_lib "REPL";
        Flow.repl stdin
      | Some fname ->
        Settings.set_current_file_path fname;
        Flow.source fname
    in Flow.exec state (Flow.get_command default_command)
  with
  | Flow.Error err_state ->
    begin try
      let _ : Flow.state =
        Flow.exec err_state
        (Flow.Tags [ CommonTags.box_pretty_error; CommonTags.error_report ])
      in exit 1
    with
    | Flow.Error _ ->
      Printf.eprintf "Cannot print error: %s\n"
        (Flow.State.node_name err_state);
      exit 3
    end
