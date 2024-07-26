
type exval =
| EVAny
| EVCtor of string * exval list

type error =
| NonExhaustiveMatch of Utils.UID.t * exval

exception Error of error

let flow_node =
  Flow.Node.create "Error (Unif --> Core)"

(* ========================================================================= *)

let rec pretty_exval ev =
  match ev with
  | EVAny -> Box.word "_"
  | EVCtor(name, []) -> Box.word name
  | EVCtor(name, [ ev1; ev2 ]) when
      (String.length name > 2 && name.[0] = '(') ->
    let name = String.sub name 1 (String.length name - 2) in
    Box.box
    [ Box.prefix (Box.word "(") (pretty_exval ev1)
    ; Box.ws (Box.prefix (Box.oper name)
      (Box.ws (Box.suffix (pretty_exval ev2) (Box.word ")"))))
    ]
  | EVCtor(name, evs) ->
    Box.paren (Box.box
    [ Box.word name
    ; Box.box (List.map (fun ev -> Box.ws (pretty_exval ev)) evs)
    ])

let flow_pretty_printer err meta =
  let open Box in
  Flow.return
  begin match err with
  | NonExhaustiveMatch(uid, ev) ->
    ErrorPrinter.error_pu meta uid
      ( Box.textl "This pattern matching is not exhaustive. E.g., the value"
      @ [ Box.ws (pretty_exval ev) ]
      @ Box.textl "is not matched.")
  end

let pretty_tag : Flow.tag =
  Flow.register_transform
    ~source: flow_node
    ~target: CommonTags.box_node
    ~name:   "Error printer (Unif --> Core)"
    ~provides_tags: [ CommonTags.error_report ]
    flow_pretty_printer
