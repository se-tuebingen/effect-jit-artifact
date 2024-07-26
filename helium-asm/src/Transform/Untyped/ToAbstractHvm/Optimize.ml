open Common


let rec endlet_return program =
  let rec opt p =
    match p with
    | [] -> []
    | T.MakeClosure(n, body) :: instrs -> T.MakeClosure (n, endlet_return body) :: opt instrs
    | T.MakeRecursiveBinding defs :: instrs ->
      let opt_rf (n, body) = (n, endlet_return body) in
      T.MakeRecursiveBinding (List.map opt_rf defs) :: opt instrs
    | T.Handle h :: instrs -> T.Handle
      { body = endlet_return h.body
      ; op_handler = endlet_return h.op_handler
      } :: opt instrs
    | T.Return :: T.BranchZero(left, right) :: instrs ->
      let opt_branch b = endlet_return (b @ [T.Return]) in
      T.BranchZero (opt_branch left, opt_branch right) :: opt instrs
    | T.Return :: T.BranchNonZero(left, right) :: instrs ->
      let opt_branch b = endlet_return (b @ [T.Return]) in
      T.BranchNonZero (opt_branch left, opt_branch right) :: opt instrs
    | T.Return :: T.Switch branches :: instrs ->
      let opt_branch b = endlet_return (b @ [T.Return]) in
      T.Switch (List.map opt_branch branches) :: opt instrs
    | T.Return :: T.Match branches :: instrs ->
      let opt_branch b = endlet_return (b @ [T.Return]) in
      T.Match (List.map opt_branch branches) :: opt instrs
    | T.Switch branches :: instrs -> T.Switch (List.map endlet_return branches) :: opt instrs
    | T.Match branches :: instrs -> T.Match (List.map endlet_return branches) :: opt instrs
    | T.Return :: T.EndLet :: instrs -> opt (T.Return :: instrs)
    | T.Return :: T.Let :: instrs -> opt (T.Return :: instrs)
    | instr :: instrs -> instr :: opt instrs

  in program |> List.rev |> opt |> List.rev



let rec tail_call program =
  match program with
  | [] -> []
  | T.MakeClosure(n, body) :: instrs ->
    T.MakeClosure(n, tail_call body) :: tail_call instrs
  | T.MakeRecursiveBinding defs :: instrs ->
    let opt_rf (n, rf) = (n, tail_call rf) in
    T.MakeRecursiveBinding (List.map opt_rf defs) :: tail_call instrs
  | T.Handle h :: instrs -> T.Handle
    { body = tail_call h.body
    ; op_handler = tail_call h.op_handler
    } :: tail_call instrs
  | T.BranchZero(left, right) :: instrs ->
    T.BranchZero(tail_call left, tail_call right) :: tail_call instrs
  | T.BranchNonZero(left, right) :: instrs ->
    T.BranchNonZero(tail_call left, tail_call right) :: tail_call instrs
  | T.Switch branches :: instrs -> T.Switch (List.map tail_call branches) :: tail_call instrs
  | T.Match branches :: instrs -> T.Match (List.map tail_call branches) :: tail_call instrs
  | T.Call :: T.Return :: instrs -> T.TailCall :: tail_call instrs
  | T.CallGlobal n :: T.Return :: instrs -> T.TailCallGlobal n :: tail_call instrs
  | T.CallLocal n :: T.Return :: instrs -> T.TailCallLocal n :: tail_call instrs
  | T.CallRecursiveBinding(n, k) :: T.Return :: instrs -> T.TailCallRecursiveBinding(n, k) :: tail_call instrs
  | instr :: instrs -> instr :: tail_call instrs



let rec let_accessvar program =
  match program with
  | [] -> []
  | T.MakeClosure(n, body) :: instrs ->
    T.MakeClosure(n, let_accessvar body) :: let_accessvar instrs
  | T.MakeRecursiveBinding defs :: instrs ->
    let opt_rf (n, rf) = (n, let_accessvar rf) in
    T.MakeRecursiveBinding (List.map opt_rf defs) :: let_accessvar instrs
  | T.Handle h :: instrs -> T.Handle
    { body = let_accessvar h.body
    ; op_handler = let_accessvar h.op_handler
    } :: let_accessvar instrs
  | T.BranchZero(left, right) :: instrs ->
    T.BranchZero(let_accessvar left, let_accessvar right) :: let_accessvar instrs
  | T.BranchNonZero(left, right) :: instrs ->
    T.BranchNonZero(let_accessvar left, let_accessvar right) :: let_accessvar instrs
  | T.Switch branches :: instrs -> T.Switch (List.map let_accessvar branches) :: let_accessvar instrs
  | T.Match branches :: instrs -> T.Match (List.map let_accessvar branches) :: let_accessvar instrs
  | T.Let :: T.AccessVar 0 :: instrs -> T.Let :: let_accessvar instrs
  | instr :: instrs -> instr :: let_accessvar instrs



let rec let_unused program =
  let rec unused k p =
    if k < 0
      then false
      else
        match p with
        | [] -> true
        | T.Let :: instrs -> unused (k + 1) instrs
        | T.EndLet :: instrs -> k = 0 || unused (k - 1) instrs
        | T.Op n :: instrs
        | T.CallLocal n :: instrs
        | T.TailCallLocal n :: instrs
        | T.CallRecursiveBinding(n, _) :: instrs
        | T.TailCallRecursiveBinding(n, _) :: instrs
        | T.AccessVar n :: instrs -> k <> n && unused k instrs
        | T.MakeClosure(n, body) :: instrs ->
          unused (n + k) body && unused k instrs
        | T.MakeRecursiveBinding defs :: instrs ->
          let unused_rf (n, rf) = unused (n + 1 + k) rf in
          List.for_all unused_rf defs && unused k instrs
        | T.Handle h :: instrs ->
          unused (k + 1) h.body &&
          unused (k + 2) h.op_handler &&
          unused k instrs
        | T.EndHandle :: instrs -> unused (k - 1) instrs
        | T.BranchZero(left, right) :: instrs
        | T.BranchNonZero(left, right) :: instrs ->
          unused k left && unused k right && unused k instrs
        | T.Switch branches :: instrs -> List.for_all (unused k) branches && unused k instrs
        | T.Match branches :: instrs -> List.for_all (unused (k + 1)) branches && unused k instrs
        | instr :: instrs -> unused k instrs

  in let rec shift k p =
    match p with
    | [] -> []
    | T.Let :: instrs -> T.Let :: shift (k + 1) instrs
    | T.EndLet :: instrs -> if k = 0
      then instrs
      else T.EndLet :: shift (k - 1) instrs
    | T.Op n :: instrs ->
      T.Op (if n > k then n - 1 else n) :: shift k instrs
    | T.CallLocal n :: instrs ->
      T.CallLocal (if n > k then n - 1 else n) :: shift k instrs
    | T.TailCallLocal n :: instrs ->
      T.TailCallLocal (if n > k then n - 1 else n) :: shift k instrs
    | T.CallRecursiveBinding(n, r) :: instrs ->
      T.CallRecursiveBinding((if n > k then n - 1 else n), r) :: shift k instrs
    | T.TailCallRecursiveBinding(n, r) :: instrs ->
      T.TailCallRecursiveBinding((if n > k then n - 1 else n), r) :: shift k instrs
    | T.AccessVar n :: instrs ->
      T.AccessVar (if n > k then n - 1 else n) :: shift k instrs
    | T.MakeClosure(n, body) :: instrs ->
      T.MakeClosure(n, shift (n + k) body) :: shift k instrs
    | T.MakeRecursiveBinding defs :: instrs ->
      let shift_rf (n, rf) = (n, shift (n + 1 + k) rf) in
      T.MakeRecursiveBinding (List.map shift_rf defs) :: shift k instrs
    | T.Handle h :: instrs ->
      T.Handle
      { body = shift (k + 1) h.body
      ; op_handler = shift (k + 2) h.op_handler
      } :: shift k instrs
    | T.EndHandle :: instrs ->  T.EndHandle :: shift (k - 1) instrs
    | T.BranchZero(left, right) :: instrs ->
      T.BranchZero(shift k left, shift k right) :: shift k instrs
    | T.BranchNonZero(left, right) :: instrs ->
      T.BranchNonZero(shift k left, shift k right) :: shift k instrs
    | T.Switch branches :: instrs -> T.Switch (List.map (shift k) branches) :: shift k instrs
    | T.Match branches :: instrs -> T.Match (List.map (shift (k + 1)) branches) :: shift k instrs
    | instr :: instrs -> instr :: shift k instrs

  in let rec opt p =
    match p with
    | [] -> []
    | T.MakeClosure(n, body) :: instrs ->
      T.MakeClosure(n, opt body) :: opt instrs
    | T.MakeRecursiveBinding defs :: instrs ->
      let opt_rf (n, rf) = (n, opt rf) in
      T.MakeRecursiveBinding (List.map opt_rf defs) :: opt instrs
    | T.Handle h :: instrs -> T.Handle
      { body = opt h.body
      ; op_handler = opt h.op_handler
      } :: opt instrs
    | T.BranchZero(left, right) :: instrs ->
      T.BranchZero(opt left, opt right) :: opt instrs
    | T.BranchNonZero(left, right) :: instrs ->
      T.BranchNonZero(opt left, opt right) :: opt instrs
    | T.Switch branches :: instrs -> T.Switch (List.map opt branches) :: opt instrs
    | T.Match branches :: instrs -> T.Match (List.map opt branches) :: opt instrs
    | T.Let :: instrs ->
      if unused 0 instrs
        then opt (shift 0 instrs)
        else T.Let :: opt instrs
    | instr :: instrs -> instr :: opt instrs
  in opt program



let overwrite_acc_with_the_same program =
  let rec repeated instr = function
    | [] -> false
    | prev :: prevs -> instr = prev || repeated instr prevs

  in let rec opt prev p =
    match p with
    | [] -> []
    | T.MakeClosure(n, body) :: instrs ->
      T.MakeClosure(n, opt [] body) :: opt [] instrs
    | T.MakeRecursiveBinding defs :: instrs ->
      let opt_rf (n, rf) = (n, opt [] rf) in
      T.MakeRecursiveBinding (List.map opt_rf defs) :: opt [] instrs
    | T.Handle h :: instrs -> T.Handle
      { body = opt [] h.body
      ; op_handler = opt [] h.op_handler
      } :: opt [] instrs
    | T.BranchZero(left, right) :: instrs ->
      T.BranchZero(opt prev left, opt (T.ConstInt 0 :: prev) right) :: opt [] instrs
    | T.BranchNonZero(left, right) :: instrs ->
      T.BranchNonZero(opt (T.ConstInt 0 :: prev) left, opt prev right) :: opt [] instrs
    | T.Switch branches :: instrs -> T.Switch (List.mapi (fun i b -> opt (T.ConstInt i:: prev) b) branches) :: opt [] instrs
    | T.Match branches :: instrs -> T.Match (List.map (opt []) branches) :: opt [] instrs
    | ((T.ConstInt _) as instr) :: instrs
    | ((T.ConstString _) as instr) :: instrs
    | ((T.AccessVar _) as instr) :: instrs
    | ((T.AccessGlobal _) as instr) :: instrs ->
      if repeated instr prev
        then opt prev instrs
        else instr :: opt [instr] instrs
    | T.Push :: instrs -> T.Push :: opt prev instrs
    | T.CreateGlobal :: instrs -> T.CreateGlobal :: opt prev instrs
    | instr :: instrs -> instr :: opt [] instrs
    in opt [] program



let rec acc_unread program =
  let independent_acc_overwrite = function
  | T.ConstInt _ -> true
  | T.ConstString _ -> true
  | T.AccessVar _ -> true
  | T.MakeClosure _ -> true
  | T.MakeRecursiveBinding _ -> true
  | T.AccessGlobal _ -> true
  | _ -> false

in let acc_write = function
  | T.MakeRecord _ -> true
  | T.MakeConstructor _ -> true
  | T.AccessRecursiveBinding _ -> true
  | T.GetField _ -> true
  | i -> independent_acc_overwrite i

  in let rec opt p =
    match p with
    | [] -> []
    | instr2 :: instr1 :: instrs when acc_write instr1 && independent_acc_overwrite instr2 ->
      opt (instr2 :: instrs)
    | T.Exit :: instr1 :: instrs when acc_write instr1 ->
      opt (T.Exit :: instrs)
    | T.Exit :: T.Push :: instrs -> opt (T.Exit :: instrs)
    | T.Exit :: T.Let :: instrs -> opt (T.Exit :: instrs)
    | T.Exit :: T.EndLet :: instrs -> opt (T.Exit :: instrs)
    | T.MakeClosure(n, body) :: instrs -> T.MakeClosure (n, acc_unread body) :: opt instrs
    | T.MakeRecursiveBinding defs :: instrs ->
      let opt_rf (n, body) = (n, acc_unread body) in
      T.MakeRecursiveBinding (List.map opt_rf defs) :: opt instrs
    | T.Handle h :: instrs -> T.Handle
      { body = acc_unread h.body
      ; op_handler = acc_unread h.op_handler
      } :: opt instrs
    | T.BranchZero(left, right) :: instrs ->
      T.BranchZero(acc_unread left, acc_unread right) :: opt instrs
    | T.BranchNonZero(left, right) :: instrs ->
      T.BranchNonZero(acc_unread left, acc_unread right) :: opt instrs
    | T.Switch branches :: instrs -> T.Switch (List.map acc_unread branches) :: opt instrs
    | T.Match branches :: instrs -> T.Match (List.map acc_unread branches) :: opt instrs
    | instr :: instrs -> instr :: opt instrs

  in program |> List.rev |> opt |> List.rev

let optimize (T.Instructions program) = T.Instructions (program
  |> let_accessvar |>   let_unused |> endlet_return |> tail_call  |> acc_unread |> overwrite_acc_with_the_same)