open Lang.Node
open Common

module StrSet = Set.Make(String)

let check_uniqueness name_of str_of ents =
  let rec loop ns ents =
    match ents with
    | [] -> None
    | ent :: ents ->
      let name = name_of ent in
      let str  = str_of name in
      if StrSet.mem str ns then Some(ent, name)
      else loop (StrSet.add str ns) ents
  in loop StrSet.empty ents

let check_op_decl_uniqueness ops =
  match check_uniqueness
    (fun { data = S.OpDecl(name, _, _); _ } -> name)
    S.string_of_name
    ops
  with
  | None -> ()
  | Some(op, name) ->
    raise (Error.op_redefinition ~pos:op.meta name)

let check_ctor_decl_uniqueness ctors =
  match check_uniqueness
    (fun { data = S.CtorDecl(name, _); _ } -> name)
    S.string_of_ctor_name
    ctors
  with
  | None -> ()
  | Some(ctor, name) ->
    raise (Error.ctor_redefinition ~pos:ctor.meta name)

let check_field_decl_uniqueness flds =
  match check_uniqueness
    (fun { data = S.FieldDecl(name, _); _ } -> name)
    S.string_of_name
    flds
  with
  | None -> ()
  | Some(fld, name) ->
    raise (Error.field_redefinition ~pos:fld.meta name)

let check_field_def_uniqueness flds =
  match check_uniqueness (fun fd -> Record.field_name fd)
    S.string_of_name
    flds
  with
  | None -> ()
  | Some(fld, name) ->
    raise (Error.field_redefinition ~pos:(Record.field_pos fld) name)

let check_rec_fun_uniqueness rfs =
  match check_uniqueness
    (fun (name, _, _) -> name)
    S.string_of_name
    rfs
  with
  | None -> ()
  | Some(_, name) ->
    raise (Error.rec_function_redefinition ~pos:name.meta name)
