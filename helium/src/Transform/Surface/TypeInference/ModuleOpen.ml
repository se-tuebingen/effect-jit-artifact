open Common

let weak_include_def all_decls ~fix ~env ~pos x decl cont =
  let make data = make ~fix pos data in
  match decl with
  | T.DeclThis    _ -> cont env []
  | T.DeclTypedef _ -> cont env []

  | T.DeclVal(name, tp) ->
    let v   = T.VSelVal(all_decls, make (T.VVar x), name) in
    let env = Env.add_value env name v tp in
    cont env [ T.DeclVal(name, tp), make (T.SDVal(name, make v)) ]

  | T.DeclOp(xs, s, ops, n) ->
    let name = T.OpDecl.name' ops n in
    let v    = make (T.VSelOp(all_decls, make (T.VVar x), name)) in
    let env  = Env.add_op env name v (xs, s, ops, n) in
    cont env [ T.DeclOp(xs, s, ops, n), make (T.SDOp(v, n)) ]

  | T.DeclCtor(xs, tp, ctors, n) ->
    let name = T.CtorDecl.name' ctors n in
    let v    = make (T.VSelCtor(all_decls, make (T.VVar x), name)) in
    let env  = Env.add_ctor env name v (xs, tp, ctors, n) in
    cont env [ T.DeclCtor(xs, tp, ctors, n), make (T.SDCtor(v, n)) ]

  | T.DeclField(xs, tp, flds, n) ->
    let name = T.FieldDecl.name' flds n in
    let v    = make (T.VSelField(all_decls, make (T.VVar x), name)) in
    let env  = Env.add_field env name v (xs, tp, flds, n) in
    cont env [ T.DeclField(xs, tp, flds, n), make (T.SDField(v, n)) ]

let full_include_def all_decls ~fix ~env ~pos x decl cont =
  let make data = make ~fix pos data in
  match decl with
  | T.DeclThis    tp ->
    let v   = T.VSelThis(all_decls, make (T.VVar x)) in
    let env = Env.add_value env "this" v tp in
    cont env [ T.DeclThis tp, make (T.SDThis (make v)) ]

  | T.DeclTypedef tp ->
    let v = T.VSelTypedef(all_decls, make (T.VVar x)) in
    cont env [ T.DeclTypedef tp, make (T.SDTypedef (make v)) ]

  | decl -> weak_include_def all_decls ~fix ~env ~pos x decl cont

let rec weak_include_defs all_decls ~fix ~env ~pos x decls cont =
  match decls with
  | [] -> cont env []
  | decl :: decls ->
    weak_include_def  all_decls ~fix ~env ~pos x decl  (fun env vals1 ->
    weak_include_defs all_decls ~fix ~env ~pos x decls (fun env vals2 ->
    cont env (merge_vals_hide vals1 vals2)))

let rec full_include_defs all_decls ~fix ~env ~pos x decls cont =
  match decls with
  | [] -> cont env []
  | decl :: decls ->
    full_include_def  all_decls ~fix ~env ~pos x decl  (fun env vals1 ->
    full_include_defs all_decls ~fix ~env ~pos x decls (fun env vals2 ->
    cont env (merge_vals_hide vals1 vals2)))

let weak_include ~fix ~env ~pos x cont =
  match T.Type.view (T.Var.typ x) with
  | TStruct decls ->
    weak_include_defs decls ~fix ~env ~pos x decls cont
  | _ -> assert false

let full_include ~fix ~env ~pos x cont =
  match T.Type.view (T.Var.typ x) with
  | TStruct decls ->
    full_include_defs decls ~fix ~env ~pos x decls cont
  | _ -> assert false

(* ========================================================================= *)

let weak_include_sig_decl env decl =
  match decl with
  | T.DeclThis _ | T.DeclTypedef _ -> (env, [])

  | T.DeclVal(name, tp) ->
    let (env, _) = Env.add_var env name tp in
    (env, [ decl ])

  | T.DeclOp _ | T.DeclCtor _ | T.DeclField _ ->
    (* Environment is not extended, since constructors are not useful in
       type expressions *)
    (env, [ decl ])

let full_include_sig_decl env decl =
  match decl with
  | T.DeclThis tp ->
    let (env, _) = Env.add_var env "this" tp in
    (env, [ decl ])

  | T.DeclTypedef _ ->
    (env, [ decl ])

  | _ -> weak_include_sig_decl env decl

let rec weak_include_sig_decls env decls =
  match decls with
  | [] -> (env, [])
  | decl :: decls ->
    let (env, decls1) = weak_include_sig_decl  env decl  in
    let (env, decls2) = weak_include_sig_decls env decls in
    (env, merge_decls decls1 decls2)

let rec full_include_sig_decls env decls =
  match decls with
  | [] -> (env, [])
  | decl :: decls ->
    let (env, decls1) = full_include_sig_decl  env decl  in
    let (env, decls2) = full_include_sig_decls env decls in
    (env, merge_decls decls1 decls2)
