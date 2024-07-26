open Graph

let check_invariants = ref false
let cmd_line_options = ref
  [ "-check-flow-invariants", Arg.Set check_invariants,
      " Checks flow invariants after each transformation"
  ]
let command  = ref None

let extension_tab = Hashtbl.create 32

let add_cmd_line_option ?cmd_line_flag ?cmd_line_descr cmd =
  match cmd_line_flag with
  | None -> ()
  | Some flag ->
    let opt =
      (flag,
       Arg.Unit (fun () ->
        command :=
          match !command with
          | None        -> Some cmd
          | Some oldCmd -> Some (Command.Seq(oldCmd, cmd))
       ),
       begin match cmd_line_descr with
       | None       -> " (undocumented)"
       | Some descr -> descr
       end)
    in
    cmd_line_options := opt :: !cmd_line_options

let get_cmd_line_options () = List.rev !cmd_line_options

let get_command default_command =
  match !command with
  | None     -> default_command
  | Some cmd -> cmd

let find_extension ext =
  Hashtbl.find_opt extension_tab ext

let register_file_extension ext node =
  Hashtbl.add extension_tab ext node

let register_transform edge =
  match edge with
  | Edge e ->
    e.e_source.edges <- edge :: e.e_source.edges

let register_invariant_checker node checker =
  let old_checkers =
    match Tag.Map.find_opt checker.ic_checks node.invs with
    | None -> []
    | Some checkers -> checkers
  in
  node.invs <- Tag.Map.add
    checker.ic_checks
    (checker :: old_checkers)
    node.invs
