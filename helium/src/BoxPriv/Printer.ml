
type t =
  {         channel    : out_channel
  ;         use_colors : bool
  ;         max_width  : int
  ;         max_indent : int
  ; mutable new_line   : bool
  ; mutable last_ws    : bool
  ; mutable break_line : bool
  ; mutable pos        : int
  }

type sl_state =
  { mutable sl_new_line   : bool
  ; mutable sl_last_ws    : bool
  ; mutable sl_pos        : int
  ; mutable sl_break_line : bool
  ;         sl_queue      : (string * Attr.t list) Queue.t
  }

exception Too_wide

let is_whitespace ch =
  match ch with
  | '\n' | '\r' | '\t' | ' ' -> true
  | _ -> false

let create channel =
  { channel    = channel
  ; use_colors = ColorScheme.use_colors channel
  ; max_width  = 80
  ; max_indent = 60
  ; new_line   = true
  ; last_ws    = true
  ; break_line = false
  ; pos        = 0
  }

let print_newline p =
  output_char p.channel '\n';
  p.new_line   <- true;
  p.last_ws    <- true;
  p.pos        <- 0;
  p.break_line <- false

let output_string_attrs p attrs str =
  if attrs <> [] && p.use_colors then
    ColorScheme.use_attributes p.channel attrs;
  output_string p.channel str;
  if attrs <> [] && p.use_colors then
    ColorScheme.default_attributes p.channel

let check_width p sl_state =
  if sl_state.sl_pos > p.max_width then raise Too_wide

let rec print_sl_box p sl_state box =
  match box with
  | Core.Word(str, attrs) ->
    let len = String.length str in
    if len > 0 then begin
      sl_state.sl_pos <- sl_state.sl_pos + len;
      check_width p sl_state;
      sl_state.sl_last_ws <- is_whitespace str.[len-1];
      sl_state.sl_new_line <- false;
      Queue.add (str, attrs) sl_state.sl_queue
    end
  | Core.TextIndent _ -> ()
  | Core.WhiteSep box ->
    if sl_state.sl_last_ws then print_sl_box p sl_state box
    else begin
      sl_state.sl_pos <- sl_state.sl_pos + 1;
      check_width p sl_state;
      Queue.add (" ", []) sl_state.sl_queue;
      sl_state.sl_last_ws <- true;
      print_sl_box p sl_state box
    end
  | Core.BreakLine box ->
    print_sl_box p sl_state box;
    sl_state.sl_break_line <- true
  | Core.NewLine box ->
    if sl_state.sl_new_line then
      print_sl_box p sl_state box
    else raise Too_wide
  | Core.Indent(n, box) ->
    if sl_state.sl_new_line then begin
      let n = min n (p.max_indent - sl_state.sl_pos) in
      if n > 0 then begin
        sl_state.sl_pos <- sl_state.sl_pos + n;
        check_width p sl_state;
        Queue.add (String.make n ' ', []) sl_state.sl_queue
      end
    end;
    print_sl_box p sl_state box
  | Core.Prefix(b1, b2) | Core.Suffix(b1, b2) ->
    print_sl_box p sl_state (Core.Box [b1; b2])
  | Core.Box boxes | Core.TBox boxes ->
    List.iter (fun box ->
      if sl_state.sl_break_line then raise Too_wide;
      print_sl_box p sl_state box
    ) boxes

let print_singleline p indent box =
  let sl_state =
    { sl_new_line   = p.new_line
    ; sl_last_ws    = p.last_ws
    ; sl_pos        = (if p.new_line then indent else p.pos)
    ; sl_break_line = false
    ; sl_queue      = Queue.create ()
    } in
  print_sl_box p sl_state box;
  p.last_ws    <- sl_state.sl_last_ws;
  p.pos        <- sl_state.sl_pos;
  p.break_line <- sl_state.sl_break_line;
  if p.new_line && indent > 0 then
    output_string p.channel (String.make indent ' ');
  Queue.iter (fun (str, attrs) ->
    p.new_line <- false;
    output_string_attrs p attrs str;
  ) sl_state.sl_queue

let rec print_box p indent box suffixes =
  match box with
  | Core.Word(str, attrs) ->
    let len = String.length str in
    if p.pos + len > p.max_width && not p.new_line then
      print_newline p;
    if len > 0 then begin
      if p.new_line && indent > 0 then begin
        output_string p.channel (String.make indent ' ');
        p.pos <- indent
      end;
      p.pos <- p.pos + len;
      p.last_ws <- is_whitespace str.[len-1];
      p.new_line <- false;
      output_string_attrs p attrs str
    end;
    print_suffixes p suffixes
  | Core.TextIndent _ -> print_suffixes p suffixes
  | Core.WhiteSep box ->
    if p.last_ws then print_box p indent box suffixes
    else if p.pos >= p.max_width then begin
      print_newline p;
      print_box p indent box suffixes
    end else begin
      p.pos <- p.pos + 1;
      output_char p.channel ' ';
      p.last_ws <- true;
      print_box p indent box suffixes
    end
  | Core.BreakLine box ->
    print_box p indent box [];
    begin match suffixes with
    | [] -> p.break_line <- true
    | (indent, box) :: boxes ->
      print_newline p;
      print_box p indent box suffixes
    end
  | Core.NewLine box ->
    print_box p indent box suffixes
  | Core.Indent(n, box) ->
    print_box p (min (indent + n) p.max_indent) box suffixes
  | Core.Prefix(b1, b2) ->
    print_box p indent b1 [];
    let indent = min p.pos p.max_indent in
    if p.break_line then print_newline p;
    print_box p indent b2 suffixes
  | Core.Suffix(b1, b2) ->
    print_box p indent b1 ((indent, b2) :: suffixes)
  | Core.Box [] -> print_suffixes p suffixes
  | Core.Box(box0 :: boxes) ->
    begin try
      print_singleline p indent (Core.Box(box :: List.map snd suffixes))
    with
    | Too_wide ->
      print_multiline_box p indent box0 boxes suffixes
    end
  | Core.TBox boxes ->
    print_text_box p indent boxes suffixes

and print_multiline_box p indent box boxes suffixes =
  match boxes with
  | [] -> print_box p indent box suffixes
  | box1 :: boxes ->
    print_box p indent box [];
    print_newline p;
    print_multiline_box p indent box1 boxes suffixes

and print_text_box p indent boxes suffixes =
  match boxes with
  | [] -> print_suffixes p suffixes
  | Core.TextIndent n :: boxes ->
    print_text_box p (min (indent + n) p.max_indent) boxes suffixes
  | box :: boxes ->
    if p.break_line then print_newline p;
    begin match print_singleline p indent box with
    | () -> print_text_box p indent boxes suffixes
    | exception Too_wide ->
      if p.new_line then begin
        print_box p indent box [];
        print_newline p;
        print_text_box p indent boxes suffixes
      end else begin
        print_newline p;
        print_text_box p indent (box :: boxes) suffixes
      end
    end

and print_suffixes p suffixes =
  match suffixes with
  | [] -> ()
  | (indent, box) :: suffixes ->
    print_box p indent box suffixes

let print p box =
  print_box p 0 box [];
  if not p.new_line then
    print_newline p

let print_no_nl p box =
  print_box p 0 box []
