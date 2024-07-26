open Lang.Node
open Common

type field_def =
  { f_name  : S.name
  ; f_pos   : Utils.Position.t
  ; f_index : int
  ; f_value : T.value
  }

let field_name fd = fd.f_name
let field_pos  fd = fd.f_pos

let check_first_def ~fix ~env ~pos fd tp_req eff_req cont =
  match fd.data with
  | S.FieldName(name, body) ->
    begin match Env.lookup_field env (S.string_of_name name) with
    | None -> raise (Error.unbound_field name)
    | Some (FieldValue(proof_gen, xs, rdtp, flds, n)) ->
      let (proof_args, sub) = Env.instantiate_args env xs in
      let proof = make ~fix fd.meta (T.VTypeApp(proof_gen, proof_args)) in
      let rdtp = T.Type.subst sub rdtp in
      let flds = List.map (T.FieldDecl.subst sub) flds in
      let FieldDecl(_, body_tp) = List.nth flds n in
      ExprBuilder.bind_expr fix env body
        (Check (T.TExists([], body_tp))) eff_req
        (fun env fv Checked eff_resp ->
      let fd =
        { f_name  = name
        ; f_pos   = fd.meta
        ; f_index = n
        ; f_value = fv
        } in
      let ce = cont env proof rdtp flds fd eff_resp in
      let (tp_resp, crc) =
        Request.return_type' ~env ~pos ~syncat:Expression tp_req rdtp in
      { ce_expr = ExprBuilder.coerce_expr_opt ~fix ~pos crc ce.ce_expr
      ; ce_type = tp_resp
      ; ce_eff  = eff_resp
      })
    end

(* ========================================================================= *)
let rec find_decl n name decls =
  match decls with
  | [] -> None
  | (T.FieldDecl(name', tp)) :: _ when S.string_of_name name = name' ->
    Some (n, tp)
  | _ :: decls -> find_decl (n+1) name decls

let check_rest_def ~fix ~env ~pos fd rdtp flds eff_req cont =
  match fd.data with
  | S.FieldName(name, body) ->
    begin match find_decl 0 name flds with
    | Some(n, body_tp) ->
      ExprBuilder.bind_expr fix env body
        (Check (T.TExists([], body_tp))) eff_req
        (fun env fv Checked eff_resp ->
      let fd =
        { f_name  = name
        ; f_pos   = fd.meta
        ; f_index = n
        ; f_value = fv
        } in
      cont env fd eff_resp)
    | None -> raise (Error.no_such_field ~env rdtp name)
    end

let check_rest_defs ~fix ~env ~pos fds rdtp flds eff_req cont =
  let rec check_rest : type ed.
      _ -> (ed, _) request -> _ -> _ -> (_, ed) checked_expr =
      fun env eff_req fds cont ->
    match fds with
    | [] ->
      { ce_expr = make ~fix pos (T.EValue (cont []))
      ; ce_type = Checked
      ; ce_eff  = Request.return_eff ~env ~pos eff_req T.Type.eff_pure
      }
    | fd :: fds ->
      check_rest_def ~fix ~env ~pos fd rdtp flds eff_req
        (fun env fd eff_resp ->
      Request.next_eff_request env eff_req eff_resp (fun eff_req ->
      check_rest env eff_req fds (fun fds -> cont (fd :: fds))))
  in
  check_rest env eff_req fds cont

(* ========================================================================= *)
let build_record ~pos flds fds =
  flds |>
  List.mapi (fun i (T.FieldDecl(name, _)) ->
    match List.find (fun fd -> fd.f_index = i) fds with
    | fd -> fd.f_value
    | exception Not_found ->
      raise (Error.field_not_defined ~pos name))
