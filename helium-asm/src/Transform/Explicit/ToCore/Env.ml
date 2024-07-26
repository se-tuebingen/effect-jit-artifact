(* Transform/Explicit/ToCore/Env.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Common

type t =
  { metadata : Flow.metadata
  ; tsubst   : S.subst
  ; var_map  : T.var S.Var.Map.t
  }

let empty meta =
  { metadata = meta
  ; tsubst   = S.Subst.empty
  ; var_map  = S.Var.Map.empty
  }

let add_tvar' env x y =
  { env with
    tsubst = S.Subst.add_type env.tsubst x (T.Type.var y)
  }

let add_tvar env x =
  let y = S.TVar.clone x in
  (add_tvar' env x y, y)

let add_tvar_ex env (S.TVar.Pack x) =
  let (env, x) = add_tvar env x in
  (env, T.TVar.Pack x)

let add_tvar_ex' env (S.TVar.Pack x) (T.TVar.Pack y) =
  match S.Kind.equal (S.TVar.kind x) (T.TVar.kind y) with
  | Equal    -> add_tvar' env x y
  | NotEqual -> assert false

let add_tvars env xs =
  List.fold_left_map add_tvar_ex env xs

let add_tvars' env xs ys =
  List.fold_left2 add_tvar_ex' env xs ys

let add_effinst env a =
  let b = S.EffInst.clone a in
  { env with
    tsubst = S.Subst.add_inst env.tsubst a b
  }, b

let add_var' env x y =
  { env with var_map = S.Var.Map.add x y env.var_map }

let add_var env x =
  let y = S.Var.fresh () in
  (add_var' env x y, y)

let to_subst env = env.tsubst

let lookup_tvar env x =
  match T.Type.view (S.Subst.lookup_type env.tsubst x) with
  | TNeutral(TVar x) -> x
  | _ -> assert false

let lookup_inst env a =
  S.Subst.lookup_inst env.tsubst a

let lookup_var env x = S.Var.Map.find x env.var_map

let metadata env = env.metadata

let update_meta env meta =
  { env with metadata = Flow.MetaData.update env.metadata meta }
