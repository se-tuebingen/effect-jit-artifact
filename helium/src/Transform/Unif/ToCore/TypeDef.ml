open Common

type td =
| TD : 'k T.tvar * S.var -> td

let tr_typedef_pass1 env (S.TypeDef(x, z)) =
  let (env, x) = Env.add_tvar env x in
  (env, TD(x, z))

let tr_typedefs_pass1 env tds =
  Utils.ListExt.fold_map tr_typedef_pass1 env tds

let tr_typedef_pass2 env (TD(x, z)) =
  let y = T.Var.fresh () in
  let tp  = Type.tr_type env (S.Var.typ z) in
  let env = Env.add_var env z y in
  (env, T.TypeDef(x, y, tp))

let tr_typedefs_pass2 env tds =
  Utils.ListExt.fold_map tr_typedef_pass2 env tds

let tr_typedefs env tds =
  let (env, tds) = tr_typedefs_pass1 env tds in
  tr_typedefs_pass2 env tds
