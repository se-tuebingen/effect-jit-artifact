
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

let word ?(attrs=[]) w = Word(w, attrs)
let const s = Word(s, [Attr.Const])
let oper  s = Word(s, [Attr.Oper])
let kw    s = Word(s, [Attr.Keyword])

let ws b = WhiteSep b
let br b = BreakLine b
let nl b = NewLine b

let text_indent n = TextIndent n

let indent n  b  = Indent(n, b)
let prefix b1 b2 = Prefix(b1, b2)
let suffix b1 b2 = Suffix(b1, b2)

let paren ?(attrs=[]) ?(opn=word ~attrs "(") ?(cls=word ~attrs ")") b =
  prefix opn (suffix b cls)

let brackets ?(attrs=[]) b =
  paren ~opn:(word ~attrs "[") ~cls:(word ~attrs "]") b

let braces ?(attrs=[]) b =
  paren ~opn:(word ~attrs "{") ~cls:(word ~attrs "}") b

let prec_paren ?(attrs=[]) prec expected_prec b =
  if expected_prec > prec then paren ~attrs b
  else b

let box  l = Box l
let tbox l = TBox l

let ws_regexp = Str.regexp "[ \t\n]+"

let textl ?(attrs=[Attr.Text]) str =
  List.map (fun s -> WhiteSep (Word(s, attrs))) (Str.split ws_regexp str)

let textfl ?attrs fmt =
  Printf.ksprintf (textl ?attrs) fmt
