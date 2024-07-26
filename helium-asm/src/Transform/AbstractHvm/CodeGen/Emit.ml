open Common

let encode_list elem_encoder xs =
  let l = List.length xs in
  List.map elem_encoder xs |>
  String.concat " "        |>
  (^) (string_of_int l ^ " ")

let encode_int_list = encode_list string_of_int

(* Encode string as a list of char codes *)
let encode_string s =
  String.to_seq s    |>
  List.of_seq        |>
  List.map Char.code |>
  encode_int_list

let add_buffers buf0 sep bfs =
  begin match bfs with
  | [] -> ()
  | bfs_head :: bfs_tail ->
    Buffer.add_buffer buf0 bfs_head;
    List.iter (fun b -> Buffer.add_string buf0 sep; Buffer.add_buffer buf0 b) bfs_tail;
  end

let tr_program (S.Instructions prog) =
  let pc = ref 0 in

  (* Write instruction to buffer (adding new line after it) and increase program counter *)
  let emit ?(comment="") buf s =
    pc := !pc + 1;
    if String.length comment = 0 then
      Buffer.add_string buf ("# " ^ string_of_int (!pc - 1) ^ ": # " ^ s ^ "\n")
    else
      Buffer.add_string buf (s ^ " # " ^ comment  ^ " #\n")
  in
  let rec tr_instructions p buf =
    match p with
    | [] -> buf
    | S.Prim prim_code :: instrs ->
      emit buf (Lang.PrimCodes.to_string prim_code);
      tr_instructions instrs buf
    | S.Push :: instrs ->
      emit buf "Push";
      tr_instructions instrs buf
    | S.Let :: instrs ->
      emit buf "Let";
      tr_instructions instrs buf
    | S.EndLet :: instrs ->
      emit buf "EndLet";
      tr_instructions instrs buf
    | S.CreateGlobal :: instrs ->
      emit buf "CreateGlobal";
      tr_instructions instrs buf
    | S.Call :: instrs ->
      emit buf "Call";
      tr_instructions instrs buf
    | S.TailCall :: instrs ->
      emit buf "TailCall";
      tr_instructions instrs buf
    | S.Return :: instrs ->
      emit buf "Return";
      tr_instructions instrs buf
    | S.EndHandle :: instrs ->
      emit buf "EndHandle";
      tr_instructions instrs buf
    | S.Exit :: instrs ->
      emit buf "Exit";
      tr_instructions instrs buf
    | S.ConstString s :: instrs ->
      emit buf ("ConstString " ^ encode_string s);
      tr_instructions instrs buf
    | S.ConstInt n :: instrs ->
      emit buf ("ConstInt " ^ string_of_int n);
      tr_instructions instrs buf
    | S.AccessVar n :: instrs ->
      emit buf ("AccessVar " ^ string_of_int n);
      tr_instructions instrs buf
    | S.AccessGlobal n :: instrs ->
      emit buf ("AccessGlobal " ^ string_of_int n);
      tr_instructions instrs buf
    | S.AccessRecursiveBinding n :: instrs ->
      emit buf ("AccessRecursiveBinding " ^ string_of_int n);
      tr_instructions instrs buf
    | S.MakeRecord n :: instrs ->
      emit buf ("MakeRecord " ^ string_of_int n);
      tr_instructions instrs buf
    | S.MakeConstructor(k, n) :: instrs ->
      emit buf ("MakeConstructor " ^ string_of_int k ^ " " ^ string_of_int n);
      tr_instructions instrs buf
    | S.GetField n :: instrs ->
      emit buf ("GetField " ^ string_of_int n);
      tr_instructions instrs buf
    | S.Op n :: instrs ->
      emit buf ("Op " ^ string_of_int n);
      tr_instructions instrs buf
    | S.CallGlobal n :: instrs ->
      emit buf ("CallGlobal " ^ string_of_int n);
      tr_instructions instrs buf
    | S.TailCallGlobal n :: instrs ->
      emit buf ("TailCallGlobal " ^ string_of_int n);
      tr_instructions instrs buf
    | S.CallLocal n :: instrs ->
      emit buf ("CallLocal " ^ string_of_int n);
      tr_instructions instrs buf
    | S.TailCallLocal n :: instrs ->
      emit buf ("TailCallLocal " ^ string_of_int n);
      tr_instructions instrs buf
    | S.CallRecursiveBinding(k, n) :: instrs ->
      emit buf ("CallRecursiveBinding " ^ string_of_int k ^ " " ^ string_of_int n);
      tr_instructions instrs buf
    | S.TailCallRecursiveBinding(k, n) :: instrs ->
      emit buf ("TailCallRecursiveBinding " ^ string_of_int k ^ " " ^ string_of_int n);
      tr_instructions instrs buf
    | S.CallExtern(name, n) :: instrs ->
      emit buf ("CallExtern " ^ name ^ " " ^ string_of_int n);
      tr_instructions instrs buf
    | S.Nop :: instrs -> tr_instructions instrs buf

    | [S.BranchZero(left, right)] ->
      pc := !pc + 1;
      let left' = tr_instructions left (Buffer.create 10) in
      let pc' = !pc in
      Buffer.add_string buf ("JumpZero " ^ string_of_int pc' ^ "\n");
      Buffer.add_buffer buf left';
      tr_instructions right buf

    | [S.BranchNonZero(left, right)] ->
      pc := !pc + 1;
      let left' = tr_instructions left (Buffer.create 10) in
      let pc' = !pc in
      Buffer.add_string buf ("JumpNonZero " ^ string_of_int pc' ^ "\n");
      Buffer.add_buffer buf left';
      tr_instructions right buf

    | S.BranchZero(left, right) :: instrs ->
      pc := !pc + 1;
      let left' = tr_instructions (left @ [S.Nop]) (Buffer.create 10) in
      pc := !pc + 1;
      let pc' = !pc in
      let right' = tr_instructions right (Buffer.create 10) in
      let pc'' = !pc in
      Buffer.add_string buf ("JumpZero " ^ string_of_int pc' ^ "\n");
      Buffer.add_buffer buf left';
      Buffer.add_string buf ("Jump " ^ string_of_int pc'' ^ "\n");
      Buffer.add_buffer buf right';
      tr_instructions instrs buf

    | S.BranchNonZero(left, right) :: instrs ->
      pc := !pc + 1;
      let left' = tr_instructions (left @ [S.Nop]) (Buffer.create 10) in
      pc := !pc + 1;
      let pc' = !pc in
      let right' = tr_instructions right (Buffer.create 10) in
      let pc'' = !pc in
      Buffer.add_string buf ("JumpNonZero " ^ string_of_int pc' ^ "\n");
      Buffer.add_buffer buf left';
      Buffer.add_string buf ("Jump " ^ string_of_int pc'' ^ "\n");
      Buffer.add_buffer buf right';
      tr_instructions instrs buf

    | S.MakeClosure(arity, body) :: instrs ->
      pc := !pc + 2;
      let pc' = !pc in
      let body' = tr_instructions body (Buffer.create 10) in
      let pc'' = !pc in
      Buffer.add_string buf ("MakeClosure " ^ string_of_int pc' ^ " " ^ string_of_int arity ^ "\n");
      Buffer.add_string buf ("Jump " ^ string_of_int pc'' ^ "\n");
      Buffer.add_buffer buf body';
      tr_instructions instrs buf

    | S.Handle h :: instrs ->
      pc := !pc + 1;
      let body' = tr_instructions h.body (Buffer.create 40) in
      let pc' = !pc in
      let handle' = tr_instructions h.op_handler body' in
      let pc'' = !pc in
      Buffer.add_string buf ("Handle " ^ string_of_int pc' ^ " " ^ string_of_int pc'' ^ "\n");
      Buffer.add_buffer buf handle';
      tr_instructions instrs buf

    | S.Match branches :: instrs ->
      pc := !pc + 1;
      begin match instrs with
      | [] ->
        let (pcs, branches') = List.split (List.map tr_branch branches) in
        Buffer.add_string buf ("Match " ^ encode_int_list pcs ^ "\n");
        add_buffers buf "" branches';
        buf
      | _ :: _ ->
        let (pcs, branches') = List.split (List.map tr_branch_join branches) in
        (*Not using slot for jump in last branch, thus decrementing pc*)
        pc := !pc - 1;
        let pc' = !pc in
        Buffer.add_string buf ("Match " ^ encode_int_list pcs ^ "\n");
        add_buffers buf ("Jump "^  string_of_int pc' ^ "\n") branches';
        tr_instructions instrs buf
      end

    | S.Switch branches :: instrs ->
      pc := !pc + 1;
      begin match instrs with
      | [] ->
        let (pcs, branches') = List.split (List.map tr_branch branches) in
        Buffer.add_string buf ("Switch " ^ encode_int_list pcs ^ "\n");
        add_buffers buf  "" branches';
        buf
      | _ :: _ ->
        let (pcs, branches') = List.split (List.map tr_branch_join branches) in
        (*Not using slot for jump in last branch, thus decrementing pc*)
        pc := !pc - 1;
        let pc' = !pc in
        Buffer.add_string buf ("Switch " ^ encode_int_list pcs ^ "\n");
        add_buffers buf ("Jump "^  string_of_int pc' ^ "\n") branches';
        tr_instructions instrs buf
      end

    | S.MakeRecursiveBinding (rfs) :: instrs ->
      let tr_rf (arity, body) =
        let pc' = !pc in
        ((pc', arity), tr_instructions body (Buffer.create 20))
      in
      pc := !pc + 2;
      let (meta, rfs') = List.split (List.map tr_rf rfs) in
      let encode_meta m = string_of_int (fst m) ^ " " ^  string_of_int (snd m) in
      let pc' = !pc in
      Buffer.add_string buf ("MakeRecursiveBinding " ^ encode_list encode_meta meta ^ "\n");
      Buffer.add_string buf ("Jump " ^ string_of_int pc' ^ "\n");
      add_buffers buf "" rfs';
      tr_instructions instrs buf

  and tr_branch b =
    let pc' = !pc in
    (pc', tr_instructions b (Buffer.create 10))

  and tr_branch_join b =
    let pc' = !pc in
    let b' = tr_instructions (b @ [S.Nop]) (Buffer.create 10) in
    (* Reserve slot for the jump to join point *)
    pc := !pc + 1;
    (pc', b')
  in
  Buffer.contents (tr_instructions prog (Buffer.create 1000))