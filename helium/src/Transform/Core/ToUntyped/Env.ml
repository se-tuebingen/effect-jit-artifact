
open Common

type t =
  { var_env  : T.var S.Var.Map.t
  ; inst_env : T.identifier S.EffInst.Map.t
  }

let empty () =
  { var_env  = S.Var.Map.empty
  ; inst_env = S.EffInst.Map.empty
  }

let add_local_var env x x' =
  { env with
    var_env = S.Var.Map.add x (T.Local(x', NoFieldAccess)) env.var_env
  }

let add_inst env i i' =
  { env with
    inst_env = S.EffInst.Map.add i i' env.inst_env
  }

let add_local_recursive_binding env xs x' =
  let field_bindings = List.mapi (fun i x -> (i, x)) xs in
  { env with
    var_env = List.fold_left (fun e (i, x) ->
      S.Var.Map.add x (T.Local(x', RecursiveAccess i)) e) env.var_env field_bindings
  }

let add_local_tuple_binding ?(offset=0) env xs x' =
  let field_bindings = List.mapi (fun i x -> (offset + i, x)) xs in
  { env with
    var_env = List.fold_left (fun e (i, x) ->
      S.Var.Map.add x (T.Local(x', TupleAccess i)) e) env.var_env field_bindings
  }

let add_local_vars env xs xs' =
  List.fold_left2 add_local_var env xs xs'

let lookup_var env x =
  S.Var.Map.find x env.var_env

let lookup_inst env x =
  S.EffInst.Map.find x env.inst_env
