open TypingStructure

let subst = Type.subst_decl

type val_decl =
| VDVal  of ttype
| VDOp   of TVar.ex list * effsig * op_decl list * int
| VDCtor of TVar.ex list * ttype * ctor_decl list * int

let op_decl_name (OpDecl(name, _, _, _)) = name
let op_decl_name' ops n =
  op_decl_name (List.nth ops n)

let ctor_decl_name (CtorDecl(name, _, _)) = name
let ctor_decl_name' ctors n =
  ctor_decl_name (List.nth ctors n)

let field_decl_name (FieldDecl(name, _)) = name
let field_decl_name' flds n =
  field_decl_name (List.nth flds n)

let shadowed_by decl1 decl2 =
  match decl1, decl2 with
  | DeclThis _, DeclThis _ -> true
  | DeclThis _, _ -> false

  | DeclTypedef _, DeclTypedef _ -> true
  | DeclTypedef _, _ -> false

  | DeclVal(name1, _), DeclVal(name2, _) -> name1 = name2
  | DeclVal(name, _), DeclOp(_, _, ops, n) -> name = op_decl_name' ops n
  | DeclVal(name, _), DeclCtor(_, _, ctors, n) ->
    name = ctor_decl_name' ctors n
  | DeclVal _, _ -> false

  | DeclOp(_, _, ops1, n1), DeclOp(_, _, ops2, n2) ->
    op_decl_name' ops1 n1 = op_decl_name' ops2 n2
  | DeclOp _, _ -> false

  | DeclCtor(_, _, ctors1, n1), DeclCtor(_, _, ctors2, n2) ->
    ctor_decl_name' ctors1 n1 = ctor_decl_name' ctors2 n2
  | DeclCtor _, _ -> false

  | DeclField(_, _, flds1, n1), DeclField(_, _, flds2, n2) ->
    field_decl_name' flds1 n1 = field_decl_name' flds2 n2
  | DeclField _, _ -> false

let rec select_this decls =
  match decls with
  | [] -> None
  | DeclThis tp :: _ -> Some tp
  | _ :: decls -> select_this decls

let rec select_typedef decls =
  match decls with
  | [] -> None
  | DeclTypedef tp :: _ -> Some tp
  | _ :: decls -> select_typedef decls

let rec select_val decls name =
  match decls with
  | [] -> None
  | decl :: decls ->
    begin match decl with
    | DeclVal(name', tp) when name = name' -> Some (VDVal tp)

    | DeclOp(xs, s, ops, n) when name = op_decl_name' ops n ->
      begin match select_val decls name with
      | None    -> Some (VDOp(xs, s, ops, n))
      | Some vd -> Some vd
      end
    | DeclCtor(xs, tp, ctors, n) when name = ctor_decl_name' ctors n ->
      begin match select_val decls name with
      | None    -> Some (VDCtor(xs, tp, ctors, n))
      | Some vd -> Some vd
      end

    | _ -> select_val decls name
    end

let rec select_op decls name =
  match decls with
  | [] -> None
  | DeclOp(xs, s, ops, n) :: _ when name = op_decl_name' ops n ->
    Some (xs, s, ops, n)
  | _ :: decls -> select_op decls name

let rec select_ctor decls name =
  match decls with
  | [] -> None
  | DeclCtor(xs, tp, ctors, n) :: _ when name = ctor_decl_name' ctors n ->
    Some(xs, tp, ctors, n)
  | _ :: decls -> select_ctor decls name

let rec select_field decls name =
  match decls with
  | [] -> None
  | DeclField(xs, tp, flds, n) :: _ when name = field_decl_name' flds n ->
    Some(xs, tp, flds, n)
  | _ :: decls -> select_field decls name

let this_index decls =
  let rec this_index_aux decls idx =
    match decls with
    | [] -> raise Not_found
    | decl :: decls ->
      begin match decl with
      | DeclThis _ -> idx
      | DeclTypedef _ | DeclVal _ | DeclOp _ | DeclCtor _
      | DeclField _ ->
        this_index_aux decls (idx+1)
      end
  in
  this_index_aux decls 0

let typedef_index decls =
  let rec typedef_index_aux decls idx =
    match decls with
    | [] -> raise Not_found
    | decl :: decls ->
      begin match decl with
      | DeclTypedef _ -> idx
      | DeclThis _ | DeclVal _ | DeclOp _ | DeclCtor _
      | DeclField _ ->
        typedef_index_aux decls (idx+1)
      end
  in
  typedef_index_aux decls 0

let val_index decls name =
  let rec val_index_aux decls idx =
    match decls with
    | [] -> raise Not_found
    | decl :: decls ->
      begin match decl with
      | DeclVal(name', _) when name' = name -> idx
      | DeclThis _ | DeclTypedef _ | DeclVal _ | DeclOp _
      | DeclCtor _ | DeclField _ ->
        val_index_aux decls (idx+1)
      end
  in
  val_index_aux decls 0

let op_index decls name =
  let rec op_index_aux decls idx =
    match decls with
    | [] -> raise Not_found
    | decl :: decls ->
      begin match decl with
      | DeclOp(_, _, ops, n) when
          (op_decl_name' ops n = name) -> idx
      | DeclThis _ | DeclTypedef _ | DeclVal _ | DeclOp _
      | DeclCtor _ | DeclField _ ->
        op_index_aux decls (idx+1)
      end
  in
  op_index_aux decls 0

let ctor_index decls name =
  let rec ctor_index_aux decls idx =
    match decls with
    | [] -> raise Not_found
    | decl :: decls ->
      begin match decl with
      | DeclCtor(_, _, ctors, n) when
          (ctor_decl_name' ctors n = name) -> idx
      | DeclThis _ | DeclTypedef _ | DeclVal _ | DeclOp _
      | DeclCtor _ | DeclField _ ->
        ctor_index_aux decls (idx+1)
      end
  in
  ctor_index_aux decls 0

let field_index decls name =
  let rec field_index_aux decls idx =
    match decls with
    | [] -> raise Not_found
    | decl :: decls ->
      begin match decl with
      | DeclField(_, _, flds, n) when
          (field_decl_name' flds n = name) -> idx
      | DeclThis _ | DeclTypedef _ | DeclVal _ | DeclOp _
      | DeclCtor _ | DeclField _ ->
        field_index_aux decls (idx+1)
      end
  in
  field_index_aux decls 0
