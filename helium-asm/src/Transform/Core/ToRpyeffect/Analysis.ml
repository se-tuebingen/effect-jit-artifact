open Common

module FVSet = Set.Make(struct
  type t = S.var
  let compare (x: t) (y: t) = String.compare (S.Var.to_string x) (S.Var.to_string y)
end) 

(* Computes the set of free variables *)
let rec free_vars_expr (e: S.expr) = match e.data with
  | S.ELet(x,e1,e2) | S.ELetPure(x,e1,e2) ->
    FVSet.union (free_vars_expr e1) (FVSet.remove x (free_vars_expr e2))
  | S.EValue v -> free_vars_value v
  | S.ETypeApp(v, t) -> free_vars_value v
  | S.EInstApp(v, a) -> free_vars_value v (*TODO?*)
  | S.EApp(v1,v2) -> FVSet.union (free_vars_value v1) (free_vars_value v2)
  | S.EProj(v,n) -> free_vars_value v
  | S.ESelect(_,n,v) -> free_vars_value v
  | S.ETypeDef(_, e) -> free_vars_expr e
  | S.EFix(rfs, e) -> List.fold_right (function
      | S.RFFun(x,_,_,_,_,_) -> FVSet.remove x
      | S.RFInstFun(x,_,_,_,_,_) -> FVSet.remove x) rfs 
      (List.fold_right FVSet.union (List.map (function 
      | S.RFFun(x,_,_,y,_,body) -> FVSet.remove y (free_vars_expr body)
      | S.RFInstFun(x,_,_,e,_,body) -> free_vars_expr body) rfs) (free_vars_expr e))
  | S.EUnpack(_, x, v, e) -> FVSet.union (free_vars_value v) (FVSet.remove x (free_vars_expr e))
  | S.EMatch(_, v, cl, _) -> List.fold_right (function
     | S.Clause(_,xs,b) -> FVSet.union 
        (List.fold_right FVSet.remove xs (free_vars_expr b)))
        cl (free_vars_value v)
  | S.EHandle {effinst;body;op_handlers;return_var;return_body;htype;heffect;_} -> 
    FVSet.union (free_vars_expr body) (free_vars_expr return_body) (*TODO?*)
  | S.EOp(_, n, a, _, args) -> 
    List.fold_right (fun arg -> FVSet.union (free_vars_value arg)) args FVSet.empty
  | S.ERepl _ | S.EReplExpr _ | S.EReplImport _ -> failwith "Compilation of repl code"             
and free_vars_value (v: S.value) = match v.data with
  | S.VLit _ -> FVSet.empty
  | S.VVar x -> FVSet.singleton x
  | S.VTuple vs | S.VCtor(_,_,_,vs) | S.VRecord(_,vs) ->
    List.fold_right (fun v a -> FVSet.union (free_vars_value v) a) vs FVSet.empty
  | S.VFn(x,_,body) -> FVSet.remove x (free_vars_expr body)
  | S.VInstFun(_,_,body) | S.VTypeFun(_,body) -> free_vars_expr body
  | S.VPack(_, v, _, _) -> free_vars_value v
  | S.VExtern(_,_) -> FVSet.empty

(* Computes the arity of the function returned by the expression. 
 * (or rather, a lower bound on it, if we count currying).
 *
 * Ideally, we'd use types for the following, but I don't know how to get them at the
 * call site *)
let rec arity_expr (e: S.expr) = match e.data with
  | S.ELet(x,e1,e2) | S.ELetPure(x,e1,e2) -> arity_expr e2
  | S.EFix(rfs, e) -> arity_expr e
  | S.EUnpack(_,x,_,b) -> arity_expr b (*TODO?*)
  | S.ETypeDef(_,e) -> arity_expr e
  | S.ETypeApp(v,_) -> max 0 ((arity_value v) - 1)
  | S.EInstApp(v,i) -> max 0 ((arity_value v) - 1) (*TODO?*)
  | S.EApp(v1,v2) -> max 0 ((arity_value v1) - 1)
  | S.EProj(_,_) -> 0
  | S.ESelect(o,_,v) -> 0 (*TODO?*)
  | S.EMatch(_,_,[],_) -> 0
  | S.EMatch(_,_,((Clause(_,_,e)) :: cs),_) -> arity_expr e (*TODO?*)
  | S.EHandle {effinst;body;op_handlers;return_var;return_body;htype;heffect;_} ->
    arity_expr body
  | S.EOp(x,_,_,_,args) -> 0 (*TODO?*)
  | S.ERepl _ | S.EReplExpr _ | S.EReplImport _ -> failwith "Compilation of repl code"             
and arity_value (v: S.value) = match v.data with
  | S.VLit _ -> 0
  | S.VVar x -> 0 (*TODO?*)
  | S.VFn(_,_,e) | S.VTypeFun(_,e) -> (arity_expr e) + 1
  | S.VInstFun(_,_,e) -> (arity_expr e) + 1 (*TODO?*)
  | S.VPack(_,v,_,_) -> arity_value v (*TODO?*)
  | S.VTuple(_) | S.VCtor(_,_,_,_) | S.VRecord(_,_) -> 0
  | S.VExtern(str,tpe) -> 0 (*TODO*)

let rec eta_pars_args_expr (e: S.expr) = match e.data with
  | S.ELet(x,e1,e2) | S.ELetPure(x,e1,e2) -> eta_pars_args_expr e2
  | S.EFix(rfs, e) -> eta_pars_args_expr e
  | S.EUnpack(_,x,_,b) -> eta_pars_args_expr b (*TODO?*)
  | S.ETypeDef(_,e) -> eta_pars_args_expr e
  | S.ETypeApp(v,_) -> let p,a = eta_pars_args_value v in List.tl p, a
  | S.EInstApp(v,i) -> let p,a = eta_pars_args_value v in List.tl p, a
  | S.EApp(v1,v2) -> (match eta_pars_args_value v1 with
    | p::ps, a::args -> ps, args
    | [], [] -> [], [])
  | S.EProj(_,_) -> [], []
  | S.EValue(_) -> [], []
  | S.ESelect(o,_,v) -> [], [] (*TODO?*)
  | S.EMatch(_,_,[],_) -> [], []
  | S.EMatch(_,_,((Clause(_,_,e)) :: cs),_) -> eta_pars_args_expr e (*TODO?*)
  | S.EHandle {effinst;body;op_handlers;return_var;return_body;htype;heffect;_} ->
    eta_pars_args_expr body
  | S.EOp(x,_,_,_,args) -> [], [] (*TODO?*)
  | S.ERepl _ | S.EReplExpr _ | S.EReplImport _ -> failwith "Compilation of repl code"             
and eta_pars_args_value (v: S.value) = match v.data with
  | S.VLit _ -> [], []
  | S.VVar x -> [], [] (*TODO?*)
  | S.VFn(x,_,e) -> let p,a = eta_pars_args_expr e and x' = T.Var(T.V(x),T.Top) in x'::p, x'::a
  | S.VTypeFun(_,e) -> let p,a = eta_pars_args_expr e and x = T.Var(T.N"type param",T.Unit) in x::p, a
  | S.VInstFun(x,_,e) -> let p,a = eta_pars_args_expr e and x' = T.Var(T.V(T.Id.fresh()),T.Unit) in x'::p, a (*TODO?*)
  | S.VPack(_,v,_,_) -> eta_pars_args_value v (*TODO?*)
  | S.VTuple(_) | S.VCtor(_,_,_,_) | S.VRecord(_,_) -> [], []
  | S.VExtern(str,tpe) -> [], [] (*TODO*)