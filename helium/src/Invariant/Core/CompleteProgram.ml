open Lang.Core

(* ========================================================================= *)
let check_program p =
  match p.sf_import with
  | []     -> true
  | _ :: _ -> false

let flow_transform p meta =
  Flow.return (check_program p)

let flow_tag =
  Flow.register_invariant_checker
    ~node:   Lang.Core.flow_node
    ~checks: CommonTags.complete_program
    ~name:   "Core complete program"
    flow_transform
