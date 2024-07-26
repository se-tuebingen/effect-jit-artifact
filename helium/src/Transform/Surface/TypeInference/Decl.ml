open Lang.Node
open Common

let check_decl fix env decl =
  let check_type env = fix.check_type fix env in
  let pos = decl.meta in
  match decl.data with
  | S.DeclValSig(name, tp) ->
    let (env, xs, tp) = Env.open_ex_type env (check_type env tp) in
    let (env, _) = Env.add_var env (S.string_of_name name) tp in
    begin match name.data with
    | S.NameThis -> (env, xs, [ T.DeclThis tp ])
    | _          -> (env, xs, [ T.DeclVal(S.string_of_name name, tp) ])
    end

  | S.DeclValDef(name, v) ->
    (* TODO: we could make sure that v is a type-like or module-like *)
    let res_v = fix.check_expr fix env v Infer (Check T.Type.eff_pure) in
    begin match res_v.ce_type with
    | Infered(TExists([], tp)) ->
      let (env, _) = Env.add_var env (S.string_of_name name) tp in
      begin match name.data with
      | S.NameThis -> (env, [], [ T.DeclThis tp ])
      | _          -> (env, [], [ T.DeclVal(S.string_of_name name, tp) ])
      end
    | Infered(TExists(_ :: _, tp)) ->
      raise (Error.cannot_seal_here ~pos)
    end

  | S.DeclTypedef td ->
    let (env, t_td, td) = TypeDef.check_def fix env td in
    let (env, decls) = TypeDef.build_typedecl env td in
    (env, TypeDef.tvars [ t_td ], decls)

  | S.DeclTypedefRec tds ->
    let (env, t_tds, tds) = TypeDef.check_rec_defs fix env tds in
    let (env, decls) = TypeDef.build_typedecls env tds in
    (env, TypeDef.tvars t_tds, decls)

  | S.DeclOpen expr ->
    let res_e = fix.check_expr fix env expr Infer (Check T.Type.eff_pure) in
    begin match res_e.ce_type with
    | Infered(TExists([], tp)) ->
      let (_, decls) = TypeView.coerce_to_struct ~env ~pos:expr.meta tp in
      let (env, _) = ModuleOpen.full_include_sig_decls env decls in
      (env, [], [])
    | Infered(TExists(_ :: _, tp)) ->
      raise (Error.cannot_seal_here ~pos)
    end

  | S.DeclWeakOpen expr ->
    let res_e = fix.check_expr fix env expr Infer (Check T.Type.eff_pure) in
    begin match res_e.ce_type with
    | Infered(TExists([], tp)) ->
      let (_, decls) = TypeView.coerce_to_struct ~env ~pos:expr.meta tp in
      let (env, _) = ModuleOpen.weak_include_sig_decls env decls in
      (env, [], [])
    | Infered(TExists(_ :: _, tp)) ->
      raise (Error.cannot_seal_here ~pos)
    end

  | S.DeclInclude expr ->
    let (T.TExists(tps, tp)) = check_type env expr in
    begin match T.Type.view tp with
    | TStruct decls ->
      let (env, decls) = ModuleOpen.full_include_sig_decls env decls in
      (env, tps, decls)
    | _ -> failwith "Not a module signature"
    end

  | S.DeclWeakInclude expr ->
    let (T.TExists(tps, tp)) = check_type env expr in
    begin match T.Type.view tp with
    | TStruct decls ->
      let (env, decls) = ModuleOpen.weak_include_sig_decls env decls in
      (env, tps, decls)
    | _ -> failwith "Not a module signature"
    end

let rec check_decls fix env decls =
  match decls with
  | [] -> (env, [], [])
  | decl :: decls ->
    let (env, ex1, decls1) = check_decl fix env decl in
    let (env, ex2, decls2) = check_decls fix env decls in
    (env, ex1 @ ex2, merge_decls decls1 decls2)
