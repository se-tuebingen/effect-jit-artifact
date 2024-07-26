
let error_attr =
  [ Box.Base BA_Bold; Box.Base(BA_FgColor Red) ]

let error msg =
  Box.tbox (Box.word ~attrs:error_attr "error:" :: Box.text_indent 2 :: msg)

let error_p pos msg =
  Box.tbox
    (  Box.word ~attrs:[Box.Path] (Utils.Position.to_string pos ^ ":")
    :: Box.ws (Box.word ~attrs:error_attr "error:")
    :: Box.text_indent 2
    :: msg)

let error_u uid msg =
  Box.tbox
    (  Box.textfl "UID %s: " (Utils.UID.to_string uid)
    @  Box.ws (Box.word ~attrs:error_attr "error:")
    ::  Box.text_indent 2
    :: msg)

let error_pu meta uid msg =
  match Flow.MetaData.find_opt meta CommonTags.m_position uid with
  | Some pos ->
    error_p pos msg
  | None ->
    error_u uid msg

(* ========================================================================= *)
(* Flow error printer *)

let pretty_flow_error (err : Flow.error) _ =
  let open Box in
  let pretty_tag tag = ws (paren (word (Flow.Tag.name tag))) in
  Flow.return begin match err with
  | UnsupportedExtension ext ->
    error (textl "Unsupported file extension:"
        @ [ ws (word ~attrs:[Path] ext); word "." ])
  | InvariantViolation(st, tag) ->
    error
      (  word "Invariant"
      :: pretty_tag tag
      :: textl " is not satisfied in state"
      @[ ws (word (Flow.State.node_name st)); word "." ])
  | CannotFindPath(st, st_tags, tgt_tags) ->
    error ( textl "Cannot find path to"
         @  indent 2 (tbox (List.map pretty_tag tgt_tags))
         :: textl " from"
         @  ws (word (Flow.Node.name st))
         :: textl " with tags"
         @[ indent 2 (tbox (List.map pretty_tag st_tags)); word "." ])
  end

let _ : Flow.tag =
  Flow.register_transform
    ~source: Flow.error_node
    ~target: CommonTags.box_node
    ~name:   "Flow error printer"
    ~provides_tags: [ CommonTags.error_report ]
    pretty_flow_error
