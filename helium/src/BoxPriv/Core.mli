
type t =
| Word       of string * Attr.t list
| TextIndent of int
| WhiteSep   of t
| BreakLine  of t
| NewLine    of t
| Indent     of int * t
| Prefix     of t * t
| Suffix     of t * t
| Box        of t list
| TBox       of t list

val word  : ?attrs: Attr.t list -> string -> t
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

val paren      : ?attrs: Attr.t list -> ?opn:t -> ?cls:t -> t -> t
val brackets   : ?attrs: Attr.t list -> t -> t
val braces     : ?attrs: Attr.t list -> t -> t
val prec_paren : ?attrs: Attr.t list -> int -> int -> t -> t

val box  : t list -> t
val tbox : t list -> t

val textl  : ?attrs: Attr.t list -> string -> t list
val textfl : ?attrs: Attr.t list -> ('a, unit, string, t list) format4 -> 'a
