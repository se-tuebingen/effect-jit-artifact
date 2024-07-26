open Lang.Node
open Common

type im_var =
  { imv_name : string
  ; imv_var  : T.var
  }

let rec subst_imports sub imports =
  match imports with
  | [] -> []
  | im :: imports ->
    let (xs, sub) = T.Subst.subst_bvars sub im.T.im_types in
    { im with
      T.im_types  = xs
    ; T.im_handle = T.Type.subst sub im.T.im_handle
    ; T.im_sig    = List.map (T.Decl.subst sub) im.T.im_sig
    } :: subst_imports sub imports

let rec import_one env imports =
  match imports with
  | [] -> assert false
  | [ im ] ->
    let (env, x, sub) = Env.import env im in
    let imports =
      match sub with
      | None   -> [ (x, im) ]
      | Some _ -> []
    in
    (env, imports, { imv_name = im.T.im_name; imv_var = x })
  | im :: imports ->
    let (env, x, sub) = Env.import env im in
    begin match sub with
    | None ->
      (* Unit has not been imported yet *)
      let (env, imports, imv) = import_one env imports in
      (env, (x, im) :: imports, imv)
    | Some sub ->
      import_one env (subst_imports sub imports)
    end

let import env imports =
  match imports with
  | [] -> (env, [])
  | _  ->
    let (env, imports, _) = import_one env imports in
    (env, imports)

let tr_import_main env ff pos name =
  match FileFinder.find_unif_sig ff name with
  | Found(path, level, intf) ->
    begin match intf.if_sig with
    | US_Direct isig ->
      let im =
        { T.im_name   = name
        ; T.im_path   = path
        ; T.im_level  = level
        ; T.im_types  = isig.types
        ; T.im_handle = T.Type.eff_pure
        ; T.im_sig    = isig.body_sig
        } in
      import_one env (intf.if_import @ [ im ])
    | US_CPS isig ->
      let im =
        { T.im_name   = name
        ; T.im_path   = path
        ; T.im_level  = level
        ; T.im_types  = isig.types
        ; T.im_handle = isig.handle
        ; T.im_sig    = isig.body_sig
        } in
      import_one env (intf.if_import @ [ im ])
    end
  | NotFound ->
    raise (Error.cannot_import pos name)
  | DependencyLoop loop ->
    raise (Error.dependency_loop loop)
  | FlowError state ->
    raise (Flow.Error state)

let tr_import env pos name =
  tr_import_main env (Env.file_finder env) pos name

let import_prelude env =
  match Settings.prelude_module () with
  | None      -> (env, [], [])
  | Some name ->
    let (env, imports, imv) =
      tr_import_main env
        (FileFinder.as_prelude (Env.file_finder env))
        Utils.Position.nowhere
        name
    in (env, imports, [ imv ])

let tr_preamble_decl env pd =
  match pd.data with
  | S.PDImport name ->
    let (env, imports, imv) = tr_import env pd.meta name in
    (env, imports, [ imv ])
  | S.PDHandler _   -> (env, [], [])

let rec tr_preamble_loop env preamble =
  match preamble with
  | [] -> (env, [], [])
  | pd :: preamble ->
    let (env, import1, imv1) = tr_preamble_decl env pd in
    let (env, import2, imv2) = tr_preamble_loop env preamble in
    (env, import1 @ import2, imv1 @ imv2)

let tr_preamble env preamble =
  match FileFinder.level (Env.file_finder env) with
  | SL_User
  | SL_Lib     ->
    let (env, prelude, imv1) = import_prelude env in
    let (env, imports, imv2) = tr_preamble_loop env preamble in
    (env, prelude @ imports, imv1 @ imv2)
  | SL_Prelude -> tr_preamble_loop env preamble

let imported_effect imports =
  List.fold_right
    (fun (_, im) -> T.Type.eff_cons im.T.im_handle)
    imports
    T.Type.eff_pure

(* ========================================================================= *)

let make_nowhere data =
  { Lang.Node.meta = Utils.Position.nowhere
  ; Lang.Node.data = data
  }

let open_def name =
  make_nowhere (S.DOpen
    (make_nowhere (S.EVar (make_nowhere (S.NameID name)))))

let add_open_prelude_def defs =
  match Settings.prelude_module () with
  | None      -> defs
  | Some name -> open_def name :: defs

let add_auto_open_defs defs =
  List.fold_right
    (fun name defs -> open_def name :: defs)
    (Settings.auto_open ())
    defs

let open_defs env =
  match FileFinder.level (Env.file_finder env) with
  | SL_User    -> add_open_prelude_def (add_auto_open_defs [])
  | SL_Lib     -> add_open_prelude_def []
  | SL_Prelude -> []

(* ========================================================================= *)

let open_decl name =
  make_nowhere (S.DeclOpen
    (make_nowhere (S.EVar (make_nowhere (S.NameID name)))))

let add_open_prelude_decl decls =
  match Settings.prelude_module () with
  | None      -> decls
  | Some name -> open_decl name :: decls

let add_auto_open_decls decls =
  List.fold_right
    (fun name decls -> open_decl name :: decls)
    (Settings.auto_open ())
    decls

let open_decls env =
  match FileFinder.level (Env.file_finder env) with
  | SL_User    -> add_open_prelude_decl (add_auto_open_decls [])
  | SL_Lib     -> add_open_prelude_decl []
  | SL_Prelude -> []

(* ========================================================================= *)

let add_import_vars env imv =
  let add_import_var env imv =
    Env.add_value env imv.imv_name
      (T.VVar imv.imv_var)
      (T.Var.typ imv.imv_var)
  in
  List.fold_left add_import_var env imv
