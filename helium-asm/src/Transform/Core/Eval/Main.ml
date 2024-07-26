open Lang.Node
open Lang.Core

type value = Value.value

let run p =
  let env = Env.empty () in
  EvalExpr.eval_meta []
    (EvalExpr.eval_imports env p.sf_import (fun vs ->
      (EvalExpr.eval_unit_body (Env.add_vars_p env vs) p.sf_body
        (fun v cont -> cont v)
        (fun v -> Value.RValue v))))

let flow_node = Flow.Node.create "Core evaluator value"

let eval_tag =
  Flow.register_transform
    ~cmd_line_flag:  "-eval-core"
    ~cmd_line_descr: " Evaluate a program using Core evaluator"
    ~provides_tags: [ CommonTags.eval ]
    ~source: Lang.Core.flow_node
    ~target: flow_node
    ~name:   "Core eval"
    ~weight: 10.0
    (fun p meta -> Flow.return (run p))
