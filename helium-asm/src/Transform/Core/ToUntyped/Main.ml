open Common

let tr_program (p : S.source_file) =
  let env = Env.empty () in
  match p.sf_body with
  | UB_Direct ub -> Flow.return (T.Program([], Expr.tr_expr env ub.body) |> Optimize.optimize)
  | UB_CPS    _ -> assert false

let flow_transform p _ = tr_program p

let flow_tag =
  Flow.register_transform
    ~source: S.flow_node
    ~target: T.flow_node
    ~name: "Core --> Untyped"
    ~requires_tags:  [ CommonTags.well_typed; CommonTags.complete_program; CommonTags.direct_style_unit ]
    flow_transform
