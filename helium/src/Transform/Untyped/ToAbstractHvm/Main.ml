open Common

let flow_transform p _ = Flow.return (Expr.tr_program p |> Optimize.optimize)

let flow_tag =
  Flow.register_transform
    ~source: S.flow_node
    ~target: T.flow_node
    ~name: "Untyped --> Abstract hvm"
    flow_transform
