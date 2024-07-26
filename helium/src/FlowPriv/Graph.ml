
type 'a node =
  {         tag   : Tag.t
  ;         name  : string
  ; mutable edges : 'a edge list
  ; mutable invs  : 'a invariant_checker list Tag.Map.t
  }

and ('src, 'tgt) edge_data =
  { e_tag       : Tag.t
  ; e_name      : string
  ; e_weight    : float
  ; e_source    : 'src node
  ; e_target    : 'tgt node
  ; e_requires  : Tag.Set.t
  ; e_tag_rules : Tag.rule list
  ; e_tr        : 'src -> Meta.Map.t -> 'tgt result
  }

and 'src edge =
| Edge : ('src, 'tgt) edge_data -> 'src edge

and 'tgt result =
| Return of
  { result      : 'tgt
  ; extra_rules : Tag.rule list option
  ; meta        : Meta.ex list
  }
| Error :
  { node      : 'err node
  ; error     : 'err
  ; tag_rules : Tag.rule list
  ; meta      : Meta.ex list
  } -> 'tgt result

and 'a invariant_checker =
  { ic_tag      : Tag.t
  ; ic_checks   : Tag.t
  ; ic_name     : string
  ; ic_requires : Tag.Set.t
  ; ic_checker  : 'a -> Meta.Map.t -> bool result
  }

module Node = struct
  type 'a t = 'a node

  let create name =
    { tag   = Tag.create ("N:" ^ name)
    ; name  = name
    ; edges = []
    ; invs  = Tag.Map.empty
    }

  let name node = node.name

  let invariant_checker node tags tag =
    match Tag.Map.find_opt tag node.invs with
    | None      -> None
    | Some invs ->
      List.find_opt (fun checker ->
          Tag.Set.subset checker.ic_requires tags
        ) invs
end

module Edge = struct
  type ('src, 'tgt) t = ('src, 'tgt) edge_data

  let select_rules e extra_rules =
    match extra_rules with
    | None    -> e.e_tag_rules
    | Some rs ->
      e.e_tag_rules @ rs @ [ Tag.Rule.add_tags [ e.e_tag; e.e_target.tag ]]
end

let return ?(meta=[]) res =
  Return
  { result      = res
  ; extra_rules = None
  ; meta        = meta
  }

let error ~node err =
  Error
  { node      = node
  ; error     = err
  ; tag_rules = [ Tag.Rule.set_tags [ node.tag ] ]
  ; meta      = []
  }
