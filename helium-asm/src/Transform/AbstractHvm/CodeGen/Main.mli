type file_path = string
type message = string

type output_file_error =
| CannotOpenFile  of file_path * message

exception Output_file_error of output_file_error

val error_flow_node : output_file_error Flow.node

val compile_tag : Flow.tag