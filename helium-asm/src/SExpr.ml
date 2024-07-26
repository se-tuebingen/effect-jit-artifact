
type t =
| Nil
| Special of string
| Atom    of string
| Cons    of t * t
| Int     of int

let mk_list es =
  List.fold_right (fun t ts -> Cons(t, ts)) es Nil

let of_list tr xs =
  List.fold_right (fun x ts -> Cons(tr x, ts)) xs Nil

let tagged_list tag ts =
  mk_list (Special tag :: ts)

let rec pretty e =
  match e with
  | Nil       -> Box.word "()"
  | Special x -> Box.kw x
  | Atom x    -> Box.word x
  | Cons(e1, e2) -> Box.paren (pretty_list (pretty e1) e2)
  | Int n  -> Box.const (string_of_int n)

and pretty_list liat e =
  match e with
  | Nil -> liat
  | Cons(e1, e2) ->
    pretty_list (Box.box [ liat; Box.indent 1 (Box.ws (pretty e1))]) e2
  | _ ->
    Box.prefix (Box.word ".")
      (Box.ws (pretty e))

let flow_node = Flow.Node.create "SExpr"

let pretty_tag : Flow.tag =
  Flow.register_transform
    ~preserves_tags: [ CommonTags.pretty ]
    ~source: flow_node
    ~target: CommonTags.box_node
    ~name: "SExpr pretty-printer"
    (fun e _ -> Flow.return (pretty e))
