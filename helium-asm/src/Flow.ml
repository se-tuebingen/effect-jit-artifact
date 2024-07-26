open FlowPriv

type tag         = Tag.t
type 'a node     = 'a Graph.node
type 'a meta_key = 'a Meta.key
type 'a meta     = 'a Meta.t
type metadata    = Meta.Map.t
type state       = State.t

type command = Command.t =
| Skip
| Tags of tag list
| Seq  of command * command

type 'tgt result = 'tgt Graph.result

type ('src, 'tgt) transform =
  'src -> metadata -> 'tgt result

exception Error = Error.Error

type error = Error.t =
| UnsupportedExtension of string
| InvariantViolation   of state * tag
| CannotFindPath : 'src node * tag list * tag list -> error

let error_node = Error.node

let cmd_line_options = DataBase.get_cmd_line_options

let get_command = DataBase.get_command

let source = Pipeline.source
let repl   = Pipeline.repl

let exec = Pipeline.exec

let run_to_node st (node : _ node) =
  let st = Pipeline.exec st (Tags [ node.tag ]) in
  State.unpack st node

module Node = struct
  type 'a t = 'a Graph.node

  let create ?cmd_line_flag ?cmd_line_descr name =
    let node = Graph.Node.create name in
    DataBase.add_cmd_line_option
      ?cmd_line_flag ?cmd_line_descr (Tags [node.Graph.tag]);
    node

  let name = Graph.Node.name
end

module Tag = struct
  include Tag
  let create ?cmd_line_flag ?cmd_line_descr name =
    let tag = create name in
    DataBase.add_cmd_line_option
      ?cmd_line_flag ?cmd_line_descr (Tags [tag]);
    tag
end

module MetaKey  = Meta.Key
module Meta     = Meta
module MetaData = Meta.MetaData
module State    = State
module Command  = Command

let return = Graph.return
let error  = Graph.error

let transform_of_analysis analysis prog meta =
  match analysis prog meta with
  | Graph.Return ret -> Graph.Return { ret with result = prog }
  | Graph.Error  err -> Graph.Error err

let meta_tags = List.map MetaKey.tag_of_ex

let register_file_extension = DataBase.register_file_extension

let register_transform
    ~source ~target ~name
    ?(weight=1.0)
    ?(requires_tags=[])
    ?(provides_tags=[])
    ?(preserves_tags=[])
    ?(requires_meta=[])
    ?(provides_meta=[])
    ?(preserves_meta=[])
    ?cmd_line_flag ?cmd_line_descr
    tr =
  let tag = Tag.create ("t:" ^ name) in
  DataBase.add_cmd_line_option ?cmd_line_flag ?cmd_line_descr (Tags [tag]);
  DataBase.register_transform
    (Graph.Edge
    { Graph.e_tag       = tag
    ; Graph.e_name      = name
    ; Graph.e_weight    = weight
    ; Graph.e_source    = source
    ; Graph.e_target    = target
    ; Graph.e_requires  = Tag.Set.union
        (Tag.Set.of_list requires_tags)
        (Tag.Set.of_list (meta_tags requires_meta))
    ; Graph.e_tag_rules =
      Tag.Rule.set_tags [] ::
      (List.map (fun tag ->
        Tag.Rule.add_tags ~requires:[tag] [tag])
        (preserves_tags @ meta_tags preserves_meta)) @
      [ Tag.Rule.add_tags provides_tags
      ; Tag.Rule.add_tags (meta_tags provides_meta)
      ; Tag.Rule.add_tags [ tag; target.Graph.tag ]
      ]
    ; Graph.e_tr        = tr
    });
  tag

let register_repl ~target ~name ?weight tr =
  register_transform
    ~source: Pipeline.repl_node
    ~target ~name ?weight tr

let register_parser ~extension ~source ~target ~name tr =
  let source_node = Node.create source in
  register_file_extension extension source_node;
  register_transform ~source:source_node ~target ~name tr

let register_analysis
    ~node ~name
    ?(weight=1.0)
    ?(requires_tags=[])
    ?(provides_tags=[])
    ?(requires_meta=[])
    ?(provides_meta=[])
    analysis =
  let tag = Tag.create ("a:" ^ name) in
  DataBase.register_transform
    (Graph.Edge
    { Graph.e_tag       = tag
    ; Graph.e_name      = name
    ; Graph.e_weight    = weight
    ; Graph.e_source    = node
    ; Graph.e_target    = node
    ; Graph.e_requires  = Tag.Set.union
        (Tag.Set.of_list requires_tags)
        (Tag.Set.of_list (meta_tags requires_meta))
    ; Graph.e_tag_rules =
      [ Tag.Rule.add_tags provides_tags
      ; Tag.Rule.add_tags (meta_tags provides_meta)
      ; Tag.Rule.add_tags [ tag ]
      ]
    ; Graph.e_tr        = transform_of_analysis analysis
    });
  tag

let register_invariant_checker
    ~node ~checks ~name
    ?(requires_tags=[])
    ?(requires_meta=[])
    checker =
  let tag = Tag.create ("i:" ^ name) in
  DataBase.register_invariant_checker node
    { Graph.ic_tag      = tag
    ; Graph.ic_checks   = checks
    ; Graph.ic_name     = name
    ; Graph.ic_requires = Tag.Set.union
      (Tag.Set.of_list requires_tags)
      (Tag.Set.of_list (meta_tags requires_meta))
    ; Graph.ic_checker  = checker
    };
  tag
