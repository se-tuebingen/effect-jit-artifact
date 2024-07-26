
type rollback = unit -> unit

type 'a result =
  { data     : 'a
  ; meta     : Flow.metadata
  ; rollback : rollback
  }

exception Error of Flow.state * rollback

let print_prompt prompt =
  Box.print_stdout_no_nl (Box.suffix prompt (Box.oper "> "));
  flush stdout

let pretty_error err_state =
  try
    let _ : Flow.state =
      Flow.exec err_state
        (Flow.Tags
          [ CommonTags.box_pretty_error_stdout
          ; CommonTags.error_report
          ])
    in ()
  with
  | Flow.Error _ ->
    Printf.printf "Cannot print error: %s\n"
      (Flow.State.node_name err_state)

let rec run ask cont prompt =
  print_prompt prompt;
  match ask () with
  | ok -> cont ok
  | exception (Error(err_state, rollback)) ->
    pretty_error err_state;
    rollback ();
    run ask cont prompt

let print_value v tp =
  Box.print_stdout
    (Box.box [ v; Box.prefix (Box.ws (Box.oper ":")) (Box.ws tp) ])
