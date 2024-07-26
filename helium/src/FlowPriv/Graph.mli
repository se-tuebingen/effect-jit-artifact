
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

module Node : sig
  type 'a t = 'a node

  val create : string -> 'a t

  val name : 'a t -> string

  val invariant_checker :
    'a node -> Tag.Set.t -> Tag.t -> 'a invariant_checker option
end

module Edge : sig
  type ('src, 'tgt) t = ('src, 'tgt) edge_data

  val select_rules : ('src, 'tgt) t -> Tag.rule list option -> Tag.rule list
end

val return :
  ?meta: Meta.ex list ->
  'a -> 'a result
val error  :
  node: 'err node ->
  'err -> 'a result
