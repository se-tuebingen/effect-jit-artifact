
type t

type color =
| Black
| Red
| Green
| Yellow
| Blue
| Magenta
| Cyan
| White

type base_attribute =
| BA_Bold
| BA_Underline
| BA_Blink
| BA_Negative
| BA_CrossedOut
| BA_FgColor of color
| BA_BgColor of color

type attr =
| Const
| Oper
| Keyword
| Text
| Path
| Error
| Base of base_attribute

val word  : ?attrs: attr list -> string -> t
val const : string -> t
val oper  : string -> t
val kw    : string -> t

val ws : t -> t
val br : t -> t
val nl : t -> t
val text_indent : int -> t

val indent : int -> t -> t
val prefix : t -> t -> t
val suffix : t -> t -> t

val paren      : ?attrs: attr list -> ?opn:t -> ?cls:t -> t -> t
val brackets   : ?attrs: attr list -> t -> t
val braces     : ?attrs: attr list -> t -> t
val prec_paren : ?attrs: attr list -> int -> int -> t -> t

val box  : t list -> t
val tbox : t list -> t

val textl  : ?attrs: attr list -> string -> t list
val textfl : ?attrs: attr list -> ('a, unit, string, t list) format4 -> 'a

val print_stdout : t -> unit
val print_stderr : t -> unit
val print_stdout_no_nl : t -> unit
val print_stderr_no_nl : t -> unit
