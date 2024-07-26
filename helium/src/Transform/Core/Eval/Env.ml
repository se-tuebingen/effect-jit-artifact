open Lang.Core
open Value

module StrMap = Map.Make(String)

type t =
  { var_env  : Value.value Var.Map.t
  ; inst_env : efftag EffInst.Map.t
  ; impl_env : (Value.value StrMap.t) ref (* TODO!!! this is not correct!
      sometimes implementation can become not available. *)
  }

let empty () =
  { var_env  = Var.Map.empty
  ; inst_env = EffInst.Map.empty
  ; impl_env = ref StrMap.empty 
  }

let add_var env x v =
  { env with
    var_env = Var.Map.add x v env.var_env
  }

let add_inst env x a =
  { env with
    inst_env = EffInst.Map.add x a env.inst_env
  }

let add_vars_p env vs =
  List.fold_left (fun env (x, v) -> add_var env x v) env vs

let add_vars env xs vs =
  List.fold_left2 add_var env xs vs

let lookup_var env x =
  Var.Map.find x env.var_env

let lookup_inst env a =
  EffInst.Map.find a env.inst_env

let find_implementation env path =
  StrMap.find_opt path !(env.impl_env)

let add_implementation env path v =
  env.impl_env := StrMap.add path v !(env.impl_env)
