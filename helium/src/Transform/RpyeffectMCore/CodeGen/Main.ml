open Common

type file_path = string
type message = string
type output_file_error =
| CannotOpenFile  of file_path * message
exception Output_file_error of output_file_error
let error_flow_node =
Flow.Node.create "Output file error"  

let compile_tag =
  Flow.register_transform
    ~cmd_line_flag:   "-rpycompile"
    ~cmd_line_descr:  " Compile program to rpyeffect mcore code"
    ~source:          S.flow_node
    ~target:          CommonTags.unit_node
    ~name:            "Rpyeffect MCore codegen"
    (fun p _ ->
      let fname = Settings.get_output_filename () in
      match open_out fname with
      | oc ->
        Printf.fprintf oc "%s" (Emit.tr_program p);
        close_out oc; Flow.return ()
      | exception (Sys_error msg) ->
        raise (Output_file_error (CannotOpenFile(fname, msg))))