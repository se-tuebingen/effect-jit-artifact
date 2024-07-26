open Common

type file_path = string
type message = string

type output_file_error =
| CannotOpenFile  of file_path * message

exception Output_file_error of output_file_error

let error_flow_node =
  Flow.Node.create "Output file error"

let error_flow_pretty_printer err _ =
  let open Box in
  Flow.return
  begin match err with
  | CannotOpenFile(path, msg) ->
    ErrorPrinter.error
      ( textl "Cannot open file"
      @ [ ws (word ~attrs:[Path]  path) ]
      @ textfl "(%s)." msg)
  end

let error_pretty_tag : Flow.tag =
  Flow.register_transform
    ~source: error_flow_node
    ~target: CommonTags.box_node
    ~name:   "Compilation output file error printer"
    ~provides_tags: [ CommonTags.error_report ]
    error_flow_pretty_printer

let compile_tag =
  Flow.register_transform
    ~cmd_line_flag:  "-compile"
    ~cmd_line_descr: " Compile program to Helium Virtual Machine byte code"
    ~source: S.flow_node
    ~target: CommonTags.unit_node
    ~name:   "Hvm codegen"
    (fun p _ ->
      let fname = Settings.get_output_filename () in
      match open_out fname with
      | oc ->
        Printf.fprintf oc "%s" (Emit.tr_program p);
        close_out oc; Flow.return ()
      | exception (Sys_error msg) ->
        raise (Output_file_error (CannotOpenFile(fname, msg))))
