include Error

let with_in_channel fname func =
  match open_in fname with
  | chan ->
    begin match func chan with
    | result -> close_in_noerr chan; result
    | exception Sys_error msg ->
      close_in_noerr chan;
      raise (Error.cannot_read_file fname msg)
    | exception ex ->
      close_in_noerr chan;
      raise ex
    end
  | exception (Sys_error msg) ->
    raise (Error.cannot_open_file fname msg)

let run_parser start lexbuf =
  try start Lexer.token lexbuf with
  | Parsing.Parse_error ->
    raise (Error.unexpected_token
      (Utils.Position.of_pp
        lexbuf.Lexing.lex_start_p
        lexbuf.Lexing.lex_curr_p)
      (Lexing.lexeme lexbuf))

let parse fname start =
  with_in_channel fname (fun chan ->
    let lexbuf = Lexing.from_channel chan in
    lexbuf.Lexing.lex_curr_p <-
      { lexbuf.Lexing.lex_curr_p with
        Lexing.pos_fname = fname
      };
    run_parser start lexbuf
  )

let parse_file fname =
  parse fname YaccParser.file

let parse_intf_file fname =
  parse fname YaccParser.intf_file

let parse_repl_cmd chan =
  let lexbuf = Lexing.from_channel chan in
  lexbuf.Lexing.lex_curr_p <-
    { lexbuf.Lexing.lex_curr_p with
      Lexing.pos_fname = "repl"
    };
  run_parser YaccParser.repl_cmd lexbuf

(* ========================================================================= *)
(* REPL *)

let rec repl chan =
  match parse_repl_cmd chan with
  | cmd -> (cmd, repl_expr chan)
  | exception (Error.Parse_error err) ->
    raise (CommonRepl.Error(Flow.State.create Error.flow_node err, fun () -> ()))

and repl_expr chan =
  { Lang.Node.meta = Utils.Position.nowhere
  ; Lang.Node.data = Lang.Raw.ERepl (fun () -> repl chan)
  }

let init_repl chan _ =
  let open Lang.Raw in
  let make data = { Lang.Node.meta = Utils.Position.nowhere; data = data } in
  Flow.return
    { sf_pos      = Utils.Position.nowhere
    ; sf_preamble = []
    ; sf_defs     = [ make (DefLet(make PWildcard, repl_expr chan)) ]
    }

(* ========================================================================= *)

let source_flow_transform fname _ =
  match parse_file fname with
  | file -> Flow.return file
  | exception (Error.Parse_error err) ->
    Flow.error
      ~node:Error.flow_node
      err

let intf_flow_transform fname _ =
  match parse_intf_file fname with
  | file -> Flow.return file
  | exception (Error.Parse_error err) ->
    Flow.error
      ~node:Error.flow_node
      err

let source_flow_tag =
  Flow.register_parser
    ~extension: ".he"
    ~source:    "Helium source file"
    ~target:    Lang.Raw.flow_node
    ~name:      "Helium parser"
    source_flow_transform

let intf_flow_tag =
  Flow.register_parser
    ~extension: ".she"
    ~source:    "Helium interface file"
    ~target:    Lang.Raw.intf_flow_node
    ~name:      "Helium parser"
    intf_flow_transform

let repl_flow_tag =
  Flow.register_repl
    ~target: Lang.Raw.flow_node
    ~name: "Helium REPL"
    init_repl
