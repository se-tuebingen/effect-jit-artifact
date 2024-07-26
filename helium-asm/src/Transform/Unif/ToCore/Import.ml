open Common

let tr_import env x im =
  let (env, xs) = Env.add_tvars env im.S.im_types in
  let handle = Type.tr_type env im.S.im_handle in
  let decls = List.map (Type.tr_decl env) im.S.im_sig in
  let y = T.Var.fresh () in
  let env = Env.add_var env x y in
  let im =
    { T.im_name   = im.S.im_name
    ; T.im_path   = im.S.im_path
    ; T.im_level  = im.S.im_level
    ; T.im_var    = y
    ; T.im_types  = xs
    ; T.im_handle = handle
    ; T.im_sig    = decls
    } in
  (env, im)

let rec tr_imports env imports =
  match imports with
  | [] -> (env, [])
  | (x, im) :: imports ->
    let (env, im) = tr_import env x im in
    let (env, imports) = tr_imports env imports in
    (env, im :: imports)
