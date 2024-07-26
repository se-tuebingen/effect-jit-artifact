
open Common

type t =
  { var_env  : T.var S.Var.Map.t
  ; inst_env : T.var S.EffInst.Map.t
  }

let empty () =
  { var_env  = S.Var.Map.empty
  ; inst_env = S.EffInst.Map.empty
  }

let add_local_var env x x' =
  { env with
    var_env = S.Var.Map.add x x' env.var_env
  }

let add_inst env i i' =
  { env with
    inst_env = S.EffInst.Map.add i i' env.inst_env
  }

let add_local_bindings env xs xs' =
  { env with
    var_env = List.fold_left (fun e (x, x') -> S.Var.Map.add x x' e) 
      env.var_env (List.combine xs xs')
  }

let add_local_vars env xs xs' =
  List.fold_left2 add_local_var env xs xs'

let lookup_var env x =
  S.Var.Map.find x env.var_env

let lookup_inst env x =
  S.EffInst.Map.find x env.inst_env
