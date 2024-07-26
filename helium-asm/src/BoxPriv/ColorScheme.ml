open Attr

type color_policy =
| NoColors
| AutoDetect
| ForceColors

type color_scheme =
  { s_constant : base_attribute list
  ; s_operator : base_attribute list
  ; s_keyword  : base_attribute list
  ; s_text     : base_attribute list
  ; s_path     : base_attribute list
  ; s_error    : base_attribute list
  }

let default_scheme =
  { s_constant = [ BA_FgColor Cyan ]
  ; s_operator = [ BA_FgColor Magenta ]
  ; s_keyword  = [ BA_Bold; BA_Underline; BA_FgColor Blue ]
  ; s_text     = []
  ; s_path     = [ BA_Underline ]
  ; s_error    = [ BA_FgColor Black; BA_BgColor Red ]
  }

let color_policy   = ref AutoDetect
let current_scheme = ref default_scheme

let use_colors chan =
  match !color_policy with
  | NoColors    -> false
  | AutoDetect  -> Unix.isatty (Unix.descr_of_out_channel chan)
  | ForceColors -> true

let color_code c =
  match c with
  | Black   -> 0
  | Red     -> 1
  | Green   -> 2
  | Yellow  -> 3
  | Blue    -> 4
  | Magenta -> 5
  | Cyan    -> 6
  | White   -> 7

let output_base_attr_code chan attr =
  match attr with
  | BA_Bold       -> output_string chan ";1"
  | BA_Underline  -> output_string chan ";4"
  | BA_Blink      -> output_string chan ";5"
  | BA_Negative   -> output_string chan ";7"
  | BA_CrossedOut -> output_string chan ";9"
  | BA_FgColor c  -> 
      output_string chan (";" ^ string_of_int (30 + (color_code c)))
  | BA_BgColor c  -> 
      output_string chan (";" ^ string_of_int (40 + (color_code c)))

let output_attr_code chan attr =
  match attr with
  | Const ->
    List.iter (output_base_attr_code chan) (!current_scheme).s_constant
  | Oper ->
    List.iter (output_base_attr_code chan) (!current_scheme).s_operator
  | Keyword ->
    List.iter (output_base_attr_code chan) (!current_scheme).s_keyword
  | Text ->
    List.iter (output_base_attr_code chan) (!current_scheme).s_text
  | Path ->
    List.iter (output_base_attr_code chan) (!current_scheme).s_path
  | Error ->
    List.iter (output_base_attr_code chan) (!current_scheme).s_error
  | Base attr -> output_base_attr_code chan attr

let use_attributes chan attrs =
  output_string chan "\027[";
  List.iter (output_attr_code chan) attrs;
  output_char chan 'm'

let default_attributes chan =
  output_string chan "\027[0m"
