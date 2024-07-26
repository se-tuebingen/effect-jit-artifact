
type file_path = string
type message = string

type parse_error =
| CannotOpenFile  of file_path * message
| CannotReadFile  of file_path * message
| UnexpectedChar  of Utils.Position.t * char
| EofInComment    of Utils.Position.t
| EofInChar       of Utils.Position.t
| EofInString     of Utils.Position.t
| InvalidNumber   of Utils.Position.t * string
| InvalidEscape   of Utils.Position.t * string
| InvalidString   of Utils.Position.t * string * string
| UnexpectedToken of Utils.Position.t * string

exception Parse_error of parse_error

let cannot_open_file path msg =
  Parse_error (CannotOpenFile(path, msg))

let cannot_read_file path msg =
  Parse_error (CannotReadFile(path, msg))

let unexpected_char pos c =
  Parse_error (UnexpectedChar(pos, c))

let eof_in_comment pos =
  Parse_error (EofInComment pos)

let eof_in_char pos =
  Parse_error (EofInChar pos)

let eof_in_string pos =
  Parse_error (EofInString pos)

let invalid_number pos tok =
  Parse_error (InvalidNumber(pos, tok))

let invalid_escape pos tok =
  Parse_error (InvalidEscape(pos, tok))

let invalid_string pos tok err =
  Parse_error (InvalidString(pos, tok, err))

let unexpected_token pos tok =
  Parse_error (UnexpectedToken(pos, tok))

let flow_node =
  Flow.Node.create "Parse error"

(* ========================================================================= *)

let flow_pretty_printer err _ =
  let open Box in
  Flow.return
  begin match err with
  | CannotOpenFile(path, msg) ->
    ErrorPrinter.error
      ( textl "Cannot open file"
      @ [ ws (word ~attrs:[Path]  path) ]
      @ textfl "(%s)." msg)
  | CannotReadFile(path, msg) ->
    ErrorPrinter.error
      ( textl "Cannot read file"
      @ [ ws (word ~attrs:[Path] path) ]
      @ textfl "(%s)." msg)
  | UnexpectedChar(pos, c) ->
    ErrorPrinter.error_p pos
      ( textfl "Unexpected character"
      @ [ ws (word (Printf.sprintf "'%s'" (Char.escaped c))) ]
      @ textfl "(0x%02X)." (Char.code c))
  | EofInComment pos ->
    ErrorPrinter.error_p pos
      ( textl "End of file inside block comment (missing `*)').")
  | EofInChar pos ->
    ErrorPrinter.error_p pos
      ( textl "End of file inside character literal (missing `'').")
  | EofInString pos ->
    ErrorPrinter.error_p pos
      ( textl "End of file inside string literal (missing `\"').")
  | InvalidNumber(pos, tok) ->
    ErrorPrinter.error_p pos
      ( textfl "Invalid numerical literal `%s'." tok)
  | InvalidEscape(pos, tok) ->
    ErrorPrinter.error_p pos
      ( textfl "Invalid character escape `%s'." tok)
  | InvalidString(pos, tok, err) ->
    ErrorPrinter.error_p pos
      ( textfl "Invalid string literal `%s': %s" tok err)
  | UnexpectedToken(pos, tok) ->
    ErrorPrinter.error_p pos
      ( textl "Syntax error. Unexpected token"
      @ [ ws (word (Printf.sprintf "`%s'." tok)) ])
  end

let pretty_tag : Flow.tag =
  Flow.register_transform
    ~source: flow_node
    ~target: CommonTags.box_node
    ~name:   "Parse error printer"
    ~provides_tags: [ CommonTags.error_report ]
    flow_pretty_printer
