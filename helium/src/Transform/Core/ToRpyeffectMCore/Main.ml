open Common

let tr_program (p : S.source_file) =
  match p.sf_body with
  | UB_Direct ub -> Flow.return (Expr.tr_program ub.body ub.body_sig)
  | UB_CPS    _  -> assert false

let flow_transform p _ = tr_program p

let flow_tag =
  Flow.register_transform
    ~source: S.flow_node
    ~target: T.flow_node
    ~name: "Core --> Rpyeffect MCore"
    ~requires_tags:  [ CommonTags.well_typed; CommonTags.complete_program; CommonTags.direct_style_unit ]
    flow_transform