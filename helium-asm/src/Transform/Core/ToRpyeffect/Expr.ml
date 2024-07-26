open Common
open Analysis

type tfn =
 | Label of T.label
 | Extern of string * T.tpe list
type result_is = 
 | Returned 
 | InVar of T.var
 | Unit
 | PartialApp of T.var list * tfn * T.var list
type result = {
requires: T.var list;
provides: T.var list;
blocks: T.block list;
instructions: T.instruction list;
result_is: result_is
}
let init = {requires=[];provides=[];blocks=[];instructions=[];result_is=Unit}

let vcmp (T.Var(n1,t1)) (T.Var(n2,t2)) =
    if n1 == n2 then (assert (t1 == t2); 0) else
    match (n1, n2) with
    | (T.I _, T.V _) -> -1
    | (T.I _, T.N _) -> -1
    | (T.N _, T.V _) -> -1
    | (T.N _, T.I _) -> 1
    | (T.V _, T.N _) -> 1
    | (T.V _, T.I _) -> 1
    | (T.N nn1, T.N nn2) -> String.compare nn1 nn2
    | (T.V v1, T.V v2) -> String.compare (T.Id.to_string v1) (T.Id.to_string v2)
    | (T.I i1, T.I i2) -> Int.compare i1 i2
let rec merge_sorted_unique list1 list2 =
    match (list1, list2) with
    | ([], l) -> l
    | (l, []) -> l
    | (x :: xs, y :: ys) ->
      if (vcmp x y) < 0 then
        x :: merge_sorted_unique xs (y :: ys)
      else if (vcmp x y) > 0 then
        y :: merge_sorted_unique (x :: xs) ys
      else
        x :: merge_sorted_unique xs ys
      
let (>>) r1 r2 = {
    requires = merge_sorted_unique r1.requires (List.filter (fun x -> not (List.mem x r1.provides)) r2.requires);
    provides = merge_sorted_unique r1.provides r2.provides;
    blocks = r1.blocks @ r2.blocks;
    instructions = r1.instructions @ r2.instructions;
    result_is = r2.result_is
}
let sequence (rs : (result * 'a) list) = List.fold_left (fun (e,xs) r -> 
    let e2,x2 = r in e >> e2, x2::xs) (init, []) rs

let instruction_info ins = let r,p = (match ins with
  | T.ILet(lhss,rhss) -> rhss, lhss
  | T.ILetConst(out,v) -> [], [out]
  | T.IPrim(outs,name,ins) -> ins, outs
  | T.IPush(l,args) -> args, []
  | T.IReturn(args) -> args, []
  | T.IJump(l,args) -> args, []
  | T.IIfZ(c,l,args) -> c :: args, []
  | T.IAlloc(ref,init,reg) -> [init;reg], [ref]
  | T.ILoad(out,ref) -> [ref], [out]
  | T.IStore(ref,v) -> [ref;v], []
  | T.IShift(out,n,label) -> [n;label], [out]
  | T.IPushStack(s) -> [s], []
  | T.INewStack(os,oreg, il, t, args) -> il :: args, [os;oreg]
  | T.IConstruct(out,tpe,tag,args) -> args, [out]
  | T.IMatch(tpe,sc,cs,dc) -> sc :: List.flatten (List.map (fun (_,T.Clause(_,e,_)) -> e) ((T.N"",dc)::cs)), []
  | T.IProj(out,tpe,sc,t,f) -> [sc], [out]
  | T.INew(out,tpe,methods,args) -> args, [out]
  | T.IInvoke(tpe,rcv,tag,args) -> rcv :: args, []) in
  List.sort_uniq vcmp r, List.sort_uniq vcmp p
let emit ins = let r,p = instruction_info ins in {
    requires = r; provides = p; blocks = [];
    instructions = [ins]; result_is = Unit
}
let result r = match r with
  | other -> {requires=[]; provides=[]; blocks=[]; instructions=[]; result_is = r}

let nyi m = prerr_string ("Not yet implemented: " ^ m ^ "\n"); emit (T.IPrim([],"hole",[]))

type env =
 | Empty
 | Bind of S.var * T.var * env
 | BindFn of S.var * T.var list * tfn * T.var list * env
 | BindTpe of S.var * env (*TODO maybe we need to store more here.*)
let rec lookup (x: S.var) env = match env with
  | Empty -> failwith ("Unbound variable " ^ (S.Var.to_string x))
  | BindFn (y, params,l,args, tl) -> if x == y then PartialApp(params,l,args) else lookup x tl
  | Bind (y, r, tl) -> if x == y then InVar(r) else lookup x tl
  | BindTpe(y, tl) -> if x == y then Unit else lookup x tl


let subst_var_preserving_type s t v = match (s,t,v) with
    | (T.Var(sn,tpe),T.Var(tn,_),T.Var(vn,_)) -> if sn == vn then T.Var(tn,tpe) else v

let emit_call f args = match f with (* TODO fix handling of parameter types for substitutions *)
  | Extern(name,ret) -> let outs = List.map (fun r -> T.Var(T.V(T.Id.fresh()), r)) ret in 
        emit (T.IPrim(outs, name, args)) >> (match outs with
                | [] -> result Unit
                | [x] -> result (InVar(x))
                | other -> nyi "Multiple return values")
  | Label l -> 
    emit (T.IJump(l,args)) >> result Returned
let rec as_var r = match r.result_is with 
    | InVar(y) -> r, y
    | Unit -> let y = T.Var(T.N"unit",T.Unit) in r >> emit (T.IConstruct(y,T.N"Unit",T.N"unit",[])), y
    | Returned -> failwith "Should not happen"
    | PartialApp(params,f,args) -> (match as_fn params (emit_call f args) with | e,l,cs ->
      let o = T.Var(T.V(T.Id.fresh()),T.Top) in
      r >> e >> emit (T.INew(o,T.N "Fn", [(T.N "apply", l)], cs)), o)
and as_fn params r =
    let l = T.V(T.Id.fresh()) in
    let r', capts = as_fn_with_label l params r in
    r', l, capts
and as_fn_with_label l params r =
    let r = match r.result_is with
     | Returned -> r
     | other -> let r',x = as_var r in r' >> emit (T.IReturn[x]) in
    let capts = (List.filter (fun c -> not (List.exists (fun p -> match (p,c) with | (T.Var(pn,_),T.Var(cn,_)) -> pn == cn) params)) r.requires) in {r with
        blocks = (T.Block(l,params @ capts,r.instructions)) :: r.blocks;
        instructions = [];
        requires = []; provides = []
    }, capts
and as_block r = let r = match r.result_is with
    | Returned -> r 
    | Unit -> r >> emit (T.IReturn[])
    | other -> let r',x = as_var r in r' >> emit (T.IReturn[x]) in 
    let l = T.V(T.Id.fresh()) in {r with 
        blocks = (T.Block(l,r.requires,r.instructions)) :: r.blocks;
        instructions = [];
        requires = []; provides = []
    }, l

let print_env env = (let rec printenv e = match e with 
    | BindFn(x, pars, _, fps, tl) -> (S.Var.to_string x) ^ " = " ^ "\\(" ^ T.string_of_var_list pars ^ ")" ^ "->" ^ T.string_of_var_list fps ^ ", " ^ printenv tl
    | Bind(x, T.Var(T.V(y),_), tl) -> (S.Var.to_string x) ^ " = " ^ (S.Var.to_string y) ^ ", " ^ printenv tl
    | Bind(x, T.Var(T.V(y),_), tl) -> (S.Var.to_string x) ^ " = " ^ (S.Var.to_string y) ^ ", " ^ printenv tl
    | Bind(x, T.Var(T.N(n),_), tl) -> (S.Var.to_string x) ^ " = " ^ n ^ ", " ^ printenv tl
    | Bind(x, _, tl) -> (S.Var.to_string x) ^ " = " ^ "v, " ^ printenv tl
    | BindTpe(x, tl) -> (S.Var.to_string x) ^ " type, " ^ printenv tl
    | Empty -> "}"
    in print_string ("{" ^ printenv env))

(* Make sure x does not escape. If necessary, create a closure or return result *)
let unbind x r = match r.result_is with
    | Returned -> r
    | InVar(y) -> if x == y then r >> (emit (T.IReturn[x])) >> result Returned (* Can we improve this? *) else r
    | PartialApp(params, f, args) -> if List.exists (fun arg -> not (List.mem arg params) && arg == x) args (* is captured *)
        then (let r', y = as_var r in r' >> result (InVar(y)))
        else r
    | other -> r

let rec tr_expr (e': S.expr) (env: env) = match e'.data with
    | S.ELet(x, e1, e2) | S.ELetPure(x, e1, e2) -> (*TODO use purity*)
        let r1 = tr_expr e1 env in
        (match r1.result_is with
        | PartialApp(params,f,args) -> 
            (* if List.for_all (fun arg -> List.mem arg params) args then *) (** We don't need this, do we? **)
            r1 >> tr_expr e2 (BindFn(x,params,f,args,env))
            (*else let e, y = as_var r1 in e >> unbind y (tr_expr e2 (Bind(x,y,env)))*)
        | Returned -> let y = T.Var(T.V x,T.Top) in
            let r2 = tr_expr e2 (Bind(x,y,env)) in
            (match as_block r2 with
             | r2',l -> r2' >> emit (T.IPush(l,List.filter (function T.Var(y',_) -> not (y' = T.V x)) r2.requires)) >> r1)
        | other -> let e, y = as_var r1 in e >> unbind y (tr_expr e2 (Bind(x,y,env))))
    | S.EValue v -> tr_value v env
    | S.ETypeApp(v, t) -> let e1 = tr_value v env in (match e1.result_is with
        | PartialApp([p],l,args) -> 
            let u = T.Var(T.N"type_parameter_value", T.Unit) in (* For easier debugging *)
            emit_call l (List.map (subst_var_preserving_type p u) args)
        | PartialApp(p :: ps,l,args) -> 
            let u = T.Var(T.N"type_parameter_value", T.Unit) in (* For easier debugging *)
            e1 >> result (PartialApp(ps,l,List.map (subst_var_preserving_type p u) args))
        | other -> let u = T.Var(T.N"unit", T.Unit) and r,x = as_var e1 in
            r >> emit (T.IConstruct(u, T.N"Unit", T.N"unit", [])) >> 
                emit (T.IInvoke(T.N"Fn", x, T.N"apply", [u])) >> result Returned)
    | S.EInstApp(v, a) -> nyi "EInstApp"                                                                                          
    | S.EApp(v1, v2) -> let e1 = tr_value v1 env and e2, a = as_var (tr_value v2 env) in (match e1.result_is with (* PROBLEM here with correctly passing a parameter. *)
        | PartialApp([p],l,args) ->
            e1 >> e2 >> emit_call l (List.map (subst_var_preserving_type p a) args)
        | PartialApp(p::ps,l,args) ->
            e1 >> e2 >> result (PartialApp(ps, l, List.map (subst_var_preserving_type p a) args))
        | other -> let e1', f = as_var e1 in
            e1' >> e2 >> emit (T.IInvoke(T.N"Fn", f, T.N"apply", [a])) >> result Returned)
    | S.EProj(v,n) -> let e = tr_value v env in (match e.result_is with
        | Unit -> result Unit
        | other -> let e', x = as_var e and o = T.Var(T.V(T.Id.fresh()),T.Top) in
            e' >> emit (T.IProj(o,T.N"tuple(?)",x,T.N"make",n))) (* TODO find correct type tag *)
    | S.ESelect(_, n, v) -> nyi "ESelect"                                                                                         
    | S.ETypeDef(tds, e) -> tr_expr e (List.fold_right (fun (S.TypeDef(_,x,tp)) env -> (BindTpe(x,env))) tds env)
    | S.EFix(rfs, e) ->
        (* Set of free variables of the recursive bindings (potential captures) *) (* PROBLEM: Seems to not correctly handle additional parameters somehow?? *)
        let fcapts = 
            (* remove duplicates, sort: *)
            List.sort_uniq vcmp
            (* lookup: *)
            (let rec expand x seen = if List.mem x seen then [] else match (lookup x env) with
            | InVar(x) -> [x]
            | PartialApp(ps,l,args) ->
                List.filter (fun arg -> not (List.mem arg ps)) args
            | Unit -> []
            in List.flatten (List.map (fun x -> expand x [])
            (* as a list: *)
            (List.of_seq (FVSet.to_seq
            (* remove recursive bindings: *)
            (List.fold_right (function
            | S.RFFun(x,_,_,_,_,_) | S.RFInstFun(x,_,_,_,_,_) -> FVSet.remove x) rfs
            (* collect free variables: *)
            (List.fold_right (function
            | S.RFFun(x,tp,_,y,_,b) -> (* (minus the argument) *)
                FVSet.union (FVSet.remove y (free_vars_expr b))
            | S.RFInstFun(x,tp,_,_,_,b) ->
                FVSet.union (free_vars_expr b)) rfs FVSet.empty)))))) in
        (* compute environment with recursive bindings ... *)
        (let env' = List.fold_right (function (*TODO use types instead of bodies*)
            | S.RFFun(x,tp,tpars,y,_,b) -> fun e -> 
                let pars, args = eta_pars_args_expr b and y' = T.Var(T.V(T.Id.fresh()),T.Top) in
                let tpars' = List.map (fun _ -> T.Var(T.N"type parameter",T.Unit)) tpars in
                let fps = [y'] @ pars @ fcapts in
                BindFn(x, tpars' @ [y'] @ pars, Label(T.V(x)), fps, e)
            | S.RFInstFun(x,tp,tpars,_,_,b) -> fun e -> 
                let pars, args = eta_pars_args_expr b and y' = T.Var(T.V(T.Id.fresh()),T.Top) in
                let tpars' = List.map (fun _ -> T.Var(T.N"type parameter",T.Unit)) tpars in
                let fps = pars @ fcapts in
                BindFn(x, tpars' @ [y'] @ pars, Label(T.V(x)), fps, e)) rfs env in
        (* Translate bodies in environment *)
        let fsr = List.fold_right (function
            | S.RFFun(x,tp,_,y,_,b) -> fun r' ->
                let pars, args = eta_pars_args_expr b and y'= T.Var(T.V(T.Id.fresh()),T.Top) in
                (* Bind *all* free variables as params, so we can pass them correctly between the functions. *)
                let fps = [y'] @ pars @ fcapts in
                let benv = Bind(y,y',env') in
                let r, capts = as_fn_with_label (T.V(x)) fps (tr_expr_with_args b args benv) in
                r >> r'
            | S.RFInstFun(x,tp,_,_,_,b) -> fun r' ->
                let pars, args = eta_pars_args_expr b in
                (* Bind *all* free variables as params, so we can pass them correctly between the functions. *)
                let fps = pars @ fcapts in
                let benv = env' in
                let r, capts = as_fn_with_label (T.V(x)) fps (tr_expr_with_args b args benv) in
                r >> r'
            ) rfs init in
        (* Now, translate body e *)
        fsr >> tr_expr e env')
    | S.EUnpack(_, x, v, e) -> let e1, x' = as_var (tr_value v env) in
        e1 >> tr_expr e (Bind(x,x',env))
    | S.EMatch(_, v, cls, _) -> let r1, sc = as_var (tr_value v env) in
        let rd, default_lbl = as_block (emit (T.IPrim([],"hole",[]))) 
        and rc, clsls = tr_clauses cls env in
        r1 >> rd >> rc >> 
            emit (T.IMatch(T.V(T.Id.fresh()), sc, clsls, 
                    Clause([],[],default_lbl))) >> result Returned
    | S.EHandle {effinst;body;op_handlers;return_var;return_body;htype;heffect;_} -> nyi "EHandle"                                
    | S.EOp(_, n, a, _, args) -> nyi "EOp"                                                                                        
    | S.ERepl _ | S.EReplExpr _ | S.EReplImport _ -> failwith "Compilation of repl code"             
and tr_expr_with_args (e: S.expr) args (env: env) = match args with
  | [] -> tr_expr e env
  | a::atl ->
     let e1 = tr_expr_with_args e atl env in (match e1.result_is with 
      | PartialApp([p],l,args) ->
          e1 >> emit_call l (List.map (subst_var_preserving_type p a) args)
      | PartialApp(p::ps,l,args) ->
          e1 >> result (PartialApp(ps, l, List.map (subst_var_preserving_type p a) args))
      | other -> let e1', f = as_var e1 in
          e1' >> emit (T.IInvoke(T.N"Fn", f, T.N"apply", [a])) >> result Returned)
and tr_value (v: S.value) (env: env) = match v.data with
    | S.VLit (LNum i) -> let o = T.Var(T.V(T.Id.fresh()),T.Int) in 
        emit (T.ILetConst(o, T.LInt i)) >> result (InVar(o))
    | S.VLit (LString s) -> let o = T.Var(T.V(T.Id.fresh()),T.String) in 
        emit (T.ILetConst(o, T.LString s)) >> result (InVar(o))
    | S.VLit (LChar c) -> nyi "VLit:char"                                                                                              
    | S.VVar var -> result (lookup var env)
    | S.VTuple [] -> result Unit
    | S.VTuple vs -> let e, xs = sequence (List.map (fun v -> as_var (tr_value v env)) vs)         
                     and o = T.Var(T.V(T.Id.fresh()),T.Top) in
        e >> emit (T.IConstruct(o,T.N("tuple(" ^ (string_of_int (List.length xs)) ^ ")"),T.N"make",List.rev xs)) >> result (InVar(o))
    | S.VCtor(_, n, _, vs) -> let e, xs = sequence (List.map (fun v -> as_var (tr_value v env)) vs)         
                              and o = T.Var(T.V(T.Id.fresh()),T.Top) in
        e >> emit (T.IConstruct(o,T.V(T.Id.fresh()),T.I(n),xs)) >> result (InVar(o))
    | S.VRecord(_, vs) -> let e, xs = sequence (List.map (fun v -> as_var (tr_value v env)) vs)         
                          and o = T.Var(T.V(T.Id.fresh()),T.Top) in
        e >> emit (T.IConstruct(o,T.V(T.Id.fresh()),T.N"make",xs)) >> result (InVar(o))
    | S.VFn(x, _, body) -> 
        let x' = T.Var(T.V x,T.Top) in 
        let body' = tr_expr body (Bind(x,x',env)) in
        (match body'.result_is with
          | PartialApp(params,f,args) -> 
            body' >> result (PartialApp(x' :: params, f, args))
          | other -> let e,l,cs = as_fn [x'] body' in 
            e >> result (PartialApp([x'], Label l, x'::cs)))
    | S.VTypeFun(_, body) -> let body' = tr_expr body env and dummy = T.Var(T.V(T.Id.fresh()),T.Top) in
      (match body'.result_is with
        | PartialApp(params,f,args) -> 
            body' >> result (PartialApp(dummy :: params,f,args))
        | other -> let e,l,cs = as_fn [] body' in e >> result (PartialApp([dummy],Label l,cs)))
    | S.VInstFun(x, _, body) -> nyi "VInstFun"                                                                                    
    | S.VPack(_, v, _, _) -> tr_value v env
    | VExtern(name, tp) -> tr_extern(name)
and tr_clauses (cls: S.match_clause list) (env: env) = match cls with
    | (Clause(_,params,body)) :: rest -> 
        let env' = List.fold_right (fun p e -> Bind(p,T.Var(T.V(p),T.Top),e)) params env
        and rr,res = tr_clauses rest env in 
        let rh,lbl = as_block (tr_expr body env') in
        rh >> rr, (T.V(T.Id.fresh()), T.Clause(List.map (fun p -> T.Var(T.V(p),T.Top)) params,[],lbl)) :: res
    | [] -> result Returned, []
and tr_extern name = match name with
  | "helium_printStr" -> 
    let p = T.Var(T.N("what"), T.String) in
    result (PartialApp([p], Extern("println(String): Unit",[]),[p]))
  | "helium_printInt" ->
    let p = T.Var(T.N("what"), T.String) in
    result (PartialApp([p], Extern("println(Int): Unit",[]),[p]))
  | "helium_exit" -> 
    let p = T.Var(T.N("code"), T.Int) in
    result (PartialApp([p], Extern("exit(Int): Void",[]),[p]))
  | "helium_string_of_int" ->
    let p = T.Var(T.N("int"), T.Int) in
    result (PartialApp([p], Extern("show(Int): String",[T.String]),[p]))
  | "helium_appendStr" ->
    let p1 = T.Var(T.N("a"), T.String) and p2 = T.Var(T.N("b"), T.String) in
    result (PartialApp([p1; p2], Extern("infixConcat(String, String): String", [T.String]), [p1; p2]))
  | "helium_readInt" ->
    let u = T.Var(T.N"unit", T.Unit) in
    result (PartialApp([u], Extern("readInt(): Int", [T.Int]), []))
  | "helium_readLine" ->
    let u = T.Var(T.N"unit", T.Unit) in
    result (PartialApp([u], Extern("readLn(): String", [T.String]), []))
  | "helium_assertFalse" -> 
    let s = T.Var(T.N"message", T.String) in
    result (PartialApp([s], Extern("panic(String): Bottom", []), [s]))
  | "helium_ltInt" -> 
    let l = T.Var(T.N"l", T.Int) and r = T.Var(T.N"r", T.Int) in
    result (PartialApp([l;r], Extern("infixLt(Int, Int): Boolean", [T.Int]), [l;r]))
  | "helium_gtInt" -> 
    let l = T.Var(T.N"l", T.Int) and r = T.Var(T.N"r", T.Int) in
    result (PartialApp([l;r], Extern("infixGt(Int, Int): Boolean", [T.Int]), [l;r]))
  | "helium_addInt" -> 
    let l = T.Var(T.N"l", T.Int) and r = T.Var(T.N"r", T.Int) in
    result (PartialApp([l;r], Extern("infixAdd(Int, Int): Int", [T.Int]), [l;r]))
  | "helium_subInt" -> 
    let l = T.Var(T.N"l", T.Int) and r = T.Var(T.N"r", T.Int) in
    result (PartialApp([l;r], Extern("infixSub(Int, Int): Int", [T.Int]), [l;r]))
  | other -> nyi ("VExtern(" ^ name ^ ")")

let run r = (T.Block(T.N "main", [], r.instructions)) :: r.blocks

let tr_program (p : S.expr) (tps: S.ttype list) (* the second param are the types of the exports?? *) 
    = Printexc.record_backtrace true; 
      T.Program (run (let r = tr_expr p Empty in 
                        match r.result_is with
                        | Returned -> r
                        | other -> r >> emit (T.IJump(T.N"done",[])))) (*TODO*)