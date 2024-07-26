open Lang.Core

(* ========================================================================= *)
let check_program p =
  match p.sf_body with
  | UB_Direct _ -> true
  | UB_CPS _    -> false

let flow_transform p meta =
  Flow.return (check_program p)

let flow_tag =
  Flow.register_invariant_checker
    ~node:   Lang.Core.flow_node
    ~checks: CommonTags.direct_style_unit
    ~name:   "Core direct style program"
    flow_transform
