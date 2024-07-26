
module TVarMap = Lang.Unif.TVar.Map.Make(Lang.Core.TVar)
module InstMap = Lang.Unif.EffInst.Map
module VarMap  = Lang.Unif.Var.Map

type t =
  { metadata : Flow.metadata
  ; tvar_map : TVarMap.t
  ; inst_map : Lang.Core.effinst InstMap.t
  ; var_map  : Lang.Core.var VarMap.t
  }

let empty metadata =
  { metadata = metadata
  ; tvar_map = TVarMap.empty
  ; inst_map = InstMap.empty
  ; var_map  = VarMap.empty
  }

let add_tvar env x =
  let y = Lang.Core.TVar.clone x in
  { env with
    tvar_map = TVarMap.add x y env.tvar_map
  }, y

let add_tvar_ex env (Lang.Unif.TVar.Pack x) =
  let (env, y) = add_tvar env x in
  (env, Lang.Core.TVar.Pack y)

let add_tvars env xs =
  Utils.ListExt.fold_map add_tvar_ex env xs

let rec add_tvars' env xs ys =
  match xs, ys with
  | [], [] -> env
  | (Lang.Unif.TVar.Pack x) :: xs, (Lang.Core.TVar.Pack y) :: ys ->
    begin match
      Lang.Unif.Kind.equal (Lang.Unif.TVar.kind x) (Lang.Core.TVar.kind y)
    with
    | Equal ->
      add_tvars'
        { env with tvar_map = TVarMap.add x y env.tvar_map }
        xs
        ys
    | NotEqual -> failwith "internal kind error"
    end
  | [], _ :: _ | _ :: _, [] -> failwith "internal type error"

let add_effinst env a =
  let b = Lang.Core.EffInst.clone a in
  { env with
    inst_map = InstMap.add a b env.inst_map
  }, b

let add_var env x y =
  { env with var_map = VarMap.add x y env.var_map }

let lookup_tvar env x =
  TVarMap.find x env.tvar_map

let lookup_inst env a =
  InstMap.find a env.inst_map

let lookup_var env x =
  VarMap.find x env.var_map

let metadata env = env.metadata

let update_meta env meta =
  { env with metadata = Flow.MetaData.update env.metadata meta }
