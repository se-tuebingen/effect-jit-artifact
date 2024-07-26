(* Transform/Unif/ToExplicit/Env.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)

module TVarMap = Lang.Unif.TVar.Map.Make(Lang.Explicit.TVar)
module InstMap = Lang.Unif.EffInst.Map
module VarMap  = Lang.Unif.Var.Map

type t =
  { tvar_map : TVarMap.t
  ; inst_map : Lang.Explicit.effinst InstMap.t
  ; var_map  : Lang.Explicit.var VarMap.t
  }

let empty =
  { tvar_map = TVarMap.empty
  ; inst_map = InstMap.empty
  ; var_map  = VarMap.empty
  }

let add_tvar env x =
  let y = Lang.Explicit.TVar.clone x in
  { env with
    tvar_map = TVarMap.add x y env.tvar_map
  }, y

let add_tvar_ex env (Lang.Unif.TVar.Pack x) =
  let (env, y) = add_tvar env x in
  (env, Lang.Explicit.TVar.Pack y)

let add_tvars env xs =
  List.fold_left_map add_tvar_ex env xs

let add_effinst env a =
  let b = Lang.Explicit.EffInst.clone a in
  { env with
    inst_map = InstMap.add a b env.inst_map
  }, b

let add_var env x =
  let y = Lang.Explicit.Var.fresh () in
  ({ env with var_map = VarMap.add x y env.var_map }, y)

let lookup_tvar env x =
  TVarMap.find x env.tvar_map

let lookup_inst env a =
  InstMap.find a env.inst_map

let lookup_var env x =
  VarMap.find x env.var_map
