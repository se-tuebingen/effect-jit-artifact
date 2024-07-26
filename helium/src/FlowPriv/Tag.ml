
type typ =
| Meta
| Other

module Core = struct
  type t =
    { uid  : Utils.UID.t
    ; name : string
    ; typ  : typ
    }

  let compare t1 t2 = Utils.UID.compare t1.uid t2.uid
end
include Core

let uid tag  = tag.uid
let name tag = tag.name
let typ tag  = tag.typ

let equal t1 t2 = Utils.UID.equal t1.uid t2.uid

let create ?(typ=Other) name =
  { uid  = Utils.UID.fresh ()
  ; name = name
  ; typ  = typ
  }

module Set = Set.Make(Core)
module Map = Map.Make(Core)

type rule_action =
| Set    of Set.t
| Add    of Set.t
| Remove of Set.t

type rule =
  { r_when   : Set.t
  ; r_action : rule_action
  }

module Rule = struct
  let set_tags ?(requires=[]) tags =
    { r_when   = Set.of_list requires
    ; r_action = Set (Set.of_list tags)
    }

  let add_tags ?(requires=[]) tags =
    { r_when   = Set.of_list requires
    ; r_action = Add (Set.of_list tags)
    }
end

let apply_rules rules init_tags =
  let run_action act tags =
    match act with
    | Set tags     -> tags
    | Add new_tags -> Set.union new_tags tags
    | Remove old   -> Set.diff tags old
  in
  let apply_rule tags rule =
    if Set.subset rule.r_when init_tags then
      run_action rule.r_action tags
    else tags
  in
  List.fold_left apply_rule init_tags rules
