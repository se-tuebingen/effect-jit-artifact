open Lang.Node
open Common

let check_command fix env cmd rest tp eff =
  match cmd.data with
  | S.ReplExpr e ->
    let e_res = fix.check_expr fix env e Infer (Check eff) in
    let (Infered e_tp) = e_res.ce_type in
    let pretty_env = Env.pretty_env env in
    let tp_pretty  = Pretty.Unif.pretty_ex_type pretty_env 0 e_tp in
    let rest = fix.check_expr fix env rest (Check tp) (Check eff) in
    make ~fix cmd.meta (T.EReplExpr(e_res.ce_expr, tp_pretty, rest.ce_expr))

  | S.ReplDef def ->
    let res =
      fix.check_expr fix env { cmd with data = EDef(def, rest) }
        (Check tp) (Check eff)
    in res.ce_expr

  | S.ReplImport name ->
    let (env, imports, _) = Import.tr_import env cmd.meta name in
    let eff = T.Type.eff_cons (Import.imported_effect imports) eff in
    let rest = fix.check_expr fix env rest (Check tp) (Check eff) in
    make ~fix cmd.meta (T.EReplImport(imports, rest.ce_expr))
