open Graph

let flow_log boxes =
  Log.log_b "Flow" boxes

let pretty_tag tag =
  Box.ws (Box.paren (Box.word (Tag.name tag)))

let log_flow_state st =
  let state_field name data =
    Box.nl (Box.box
    [ Box.word (name ^ ":")
    ; Box.indent 2 (Box.ws data)
    ])
  in
  flow_log (lazy
  ( Box.textl "Reached state:"
  @[Box.text_indent 2
  ; Box.box
    [ state_field "node" (Box.word st.State.node.name)
    ; state_field "tags"
        (Box.tbox (List.map pretty_tag (Tag.Set.elements st.State.tags)))
    ]
  ]))

let reach_state st =
  log_flow_state st;
  if !DataBase.check_invariants then
    Tag.Set.iter (fun tag ->
      match Node.invariant_checker st.State.node st.State.tags tag with
      | None -> ()
      | Some checker ->
        flow_log (lazy
          [ Box.ws (Box.word "Checking")
          ; Box.ws (Box.paren (Box.word (Tag.name tag)))
          ; Box.ws (Box.word "with:")
          ; Box.ws (Box.word checker.ic_name)
          ]);
        match checker.ic_checker st.State.data st.State.meta with
        | Return ret when ret.result ->
          flow_log (lazy (Box.textfl "%s: Success" checker.ic_name))
        | _ ->
          flow_log (lazy (Box.textfl "%s: Failure" checker.ic_name));
          raise (Error.invariant_violation (State.State st) tag)
    ) st.State.tags

let source fname =
  let ext = Filename.extension fname in
  match DataBase.find_extension ext with
  | None -> raise (Error.unsupported_extension ext)
  | Some node ->
    let st =
      { State.node = node
      ; State.data = fname
      ; State.tags = Tag.Set.singleton node.tag
      ; State.meta = Meta.Map.empty
      }
    in
    reach_state st;
    State.State st

let repl_node =
  Node.create "REPL input"

let repl chan =
  let st =
    { State.node = repl_node
    ; State.data = chan
    ; State.tags = Tag.Set.singleton repl_node.tag
    ; State.meta = Meta.Map.empty
    }
  in
  reach_state st;
  State.State st

type ('src, _) rpath =
| RPNil  : ('src, 'src) rpath
| RPSnoc : ('src, 'a) rpath * ('a, 'tgt) edge_data -> ('src, 'tgt) rpath

type 'src path =
| PNil
| PCons : ('src, 'a) edge_data * 'a path -> 'src path

let rec path_rev : type src a.
    (src, a) rpath -> a path -> src path =
    fun p1 p2 ->
  match p1 with
  | RPNil        -> p2
  | RPSnoc(p, e) -> path_rev p (PCons(e, p2))

module GraphPos = struct
  type 'src t =
  | Pos :
    { node   : 'a node
    ; tags   : Tag.Set.t
    ; weight : float
    ; rpath  : ('src, 'a) rpath
    } -> 'src t

  type 'src graph_pos = 'src t
  module Ordered(T : sig type t end) : sig
    type t = T.t graph_pos
    val compare : t -> t -> int
  end = struct
    type t = T.t graph_pos

    let compare (Pos p1) (Pos p2) =
      let c = Tag.compare p1.node.tag p2.node.tag in
      if c = 0 then Tag.Set.compare p1.tags p2.tags
      else c
  end

  module Weighted(T : sig type t end) : sig
    type t = T.t graph_pos
    val compare : t -> t -> int
  end = struct
    module Ordered = Ordered(T)
    type t = Ordered.t

    let compare (Pos p1 as pos1) (Pos p2 as pos2) =
      if p1.weight < p2.weight then -1
      else if p1.weight > p2.weight then 1
      else Ordered.compare pos1 pos2
  end

  let of_state_data st =
    let node = st.State.node in
    Pos
      { node   = node
      ; tags   = st.State.tags
      ; weight = 0.0
      ; rpath  = RPNil
      }
end

let find_path (type src) (pos : src GraphPos.t) tag_set =
  let module PosSet   = Set.Make(GraphPos.Ordered(struct type t = src end)) in
  let module PosQueue = Set.Make(GraphPos.Weighted(struct type t = src end)) in
  let visited = ref PosSet.empty in
  let queue   = ref (PosQueue.singleton pos) in
  let rec loop () =
    match PosQueue.min_elt_opt !queue with
    | None -> None
    | Some(GraphPos.Pos p as pos) ->
      queue := PosQueue.remove pos !queue;
      if PosSet.mem pos !visited then loop ()
      else if Tag.Set.subset tag_set p.tags then
        (Some (path_rev p.rpath PNil))
      else begin
        visited := PosSet.add pos !visited;
        List.iter (fun (Edge edge) ->
          if Tag.Set.subset edge.e_requires p.tags then
            let new_pos = GraphPos.Pos
              { node   = edge.e_target
              ; tags   = Tag.apply_rules edge.e_tag_rules p.tags
              ; weight = p.weight +. edge.e_weight
              ; rpath  = RPSnoc(p.rpath, edge)
              }
            in
            queue := PosQueue.add new_pos !queue
        ) p.node.edges;
        loop ()
      end
  in loop ()

let update_meta old_meta ret_meta new_tags =
  let old_meta =
    Meta.Map.filter_map
      { Meta.Map.filter_map_f = fun key value ->
        if Tag.Set.mem (Meta.Key.tag key) new_tags then
          Some value (* TODO: rename *)
        else
          None
      } old_meta
  in
  List.fold_left (fun meta (Meta.Pack(key, m)) ->
      Meta.Map.add key m meta
    ) old_meta ret_meta

let rec exec state cmd =
  match cmd with
  | Command.Skip -> state
  | Command.Tags tags ->
    let State.State st = state in
    let tag_set = Tag.Set.of_list tags in
    let pos = GraphPos.of_state_data st in
    flow_log (lazy
      ( Box.textl "Finding path to:"
      @ List.map pretty_tag tags));
    begin match find_path pos tag_set with
    | Some path -> exec_path st path tags
    | None ->
      raise (Error.cannot_find_path st tags)
    end
  | Command.Seq(cmd1, cmd2) ->
    exec (exec state cmd1) cmd2

and exec_path : type src.
    src State.state_data -> src path -> Tag.t list -> State.t =
    fun st path target_tags ->
  match path with
  | PNil ->
    flow_log (lazy (Box.textl "End of path reached."));
    State.State st
  | PCons(e, path) ->
    flow_log (lazy (Box.textfl "Running transformation: %s" e.e_name));
    begin match e.e_tr st.State.data st.State.meta with
    | Return ret ->
      flow_log (lazy (Box.textfl "%s: Success" e.e_name));
      let new_tags =
        Tag.apply_rules
          (Edge.select_rules e ret.extra_rules)
          st.State.tags
      in
      let new_st =
        { State.node = e.e_target
        ; State.data = ret.result
        ; State.tags = new_tags
        ; State.meta = update_meta st.State.meta ret.meta new_tags
        }
      in
      reach_state new_st;
      begin match ret.extra_rules with
      | None   -> exec_path new_st path target_tags
      | Some _ ->
        (* Tags might change; find path again *)
        exec (State.State new_st) (Command.Tags target_tags)
      end
    | Error err ->
      flow_log (lazy (Box.textfl "%s: Error" e.e_name));
      let new_tags = Tag.apply_rules err.tag_rules st.State.tags in
      let new_st =
        { State.node = err.node
        ; State.data = err.error
        ; State.tags = new_tags
        ; State.meta = update_meta st.State.meta err.meta new_tags
        }
      in
      reach_state new_st;
      raise (Error.Error (State.State new_st))
    end
