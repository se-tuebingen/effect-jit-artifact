open Lang.Core
open Value

let make_tfun xs v =
  let mk_tfun _ f = VTypeFun(fun cont -> cont f) in
  List.fold_right mk_tfun xs v

let rec make_typeval (tp : ttype) =
  match Type.view tp with
  | TForall(_, tp) ->
    let v = make_typeval tp in
    VTypeFun(fun cont -> cont v)
  | TDataDef(_, ctors) ->
    VDataDef(List.map (fun (CtorDecl(name, _, _)) -> name) ctors)
  | TRecordDef(_, flds) ->
    VRecordDef(List.map (fun (FieldDecl(name, _)) -> name) flds)
  | TEffsigDef(_, ops) ->
    VEffsigDef(List.map (fun (OpDecl(name, _, _, _)) -> name) ops)
  | TBase _ | TNeutral _ | TTuple _ | TArrow _ | TExists _ | TForallInst _ 
  | TFuture _ ->
    failwith "Runtime error: invalid type definition."

let eval_typedef env (TypeDef(_, x, tp)) =
  Env.add_var env x (make_typeval tp)

let eval_typedefs env tds =
  List.fold_left eval_typedef env tds

let rec eval env (e : expr) cont =
  match e.data with
  | EValue v -> cont (eval_value env v)
  | ELet(x, e1, e2) | ELetPure(x, e1, e2) ->
    eval env e1 (fun v1 ->
    eval (Env.add_var env x v1) e2 cont)
  | EFix(rfs, e) ->
    let env_ref = ref env in
    let env = List.fold_left (eval_rec_fun env_ref) env rfs in
    env_ref := env;
    eval env e cont
  | EUnpack(_, x, v, e) ->
    eval (Env.add_var env x (eval_value env v)) e cont
  | ETypeDef(tds, e) -> eval (eval_typedefs env tds) e cont
  | ETypeApp(v, _) ->
    begin match eval_value env v with
    | VTypeFun f -> f cont
    | _ -> failwith "Runtime error: not a type function"
    end
  | EInstApp(v, a) ->
    begin match eval_value env v with
    | VInstFun f -> f (Env.lookup_inst env a) cont
    | _ -> failwith "Runtime error: not an instance function"
    end
  | EApp(v1, v2) ->
    begin match eval_value env v1 with
    | VFn f -> f (eval_value env v2) cont
    | _ -> failwith "Runtime error: not a function"
    end
  | EProj(v, n) ->
    begin match eval_value env v with
    | VTuple vs -> cont (List.nth vs n)
    | _ -> failwith "Runtime error: not a tuple"
    end
  | ESelect(_, n, v) ->
    begin match eval_value env v with
    | VRecord(_, vs) -> cont (List.nth vs n)
    | _ -> failwith "Runtime error: not a record"
    end
  | EMatch(_, v, cls, _) ->
    begin match eval_value env v with
    | VCtor(_, n, args) ->
      let (Clause(_, xs, body)) = List.nth cls n in
      eval (Env.add_vars env xs args) body cont
    | _ -> failwith "Runtime error: not a constructor"
    end
  | EHandle h ->
    let a = fresh_efftag () in
    let frame =
      { f_tag     = a
      ; f_handler = List.map (eval_handler env) h.op_handlers
      ; f_return  = fun v ->
          eval (Env.add_var env h.return_var v) h.return_body
      } in
    RPushFrame(cont, frame,
      eval (Env.add_inst env h.effinst a) h.body (fun v -> RValue v))
  | EOp(proof, n, a, _, args) ->
    RDoOp(
      Env.lookup_inst env a,
      eval_value env proof,
      n,
      List.map (eval_value env) args,
      cont,
      [])
  | ERepl(ask, _, _, prompt) ->
    CommonRepl.run
      (fun () -> (ask ()).data)
      (fun e -> eval env e cont)
      prompt
  | EReplExpr(e1, tp, e2) ->
    eval env e1 (fun v1 ->
      CommonRepl.print_value (Value.pretty v1) tp;
      eval env e2 cont)
  | EReplImport(import, rest) ->
    eval_imports env import (fun vs ->
    eval (Env.add_vars_p env vs) rest cont)

and eval_value env (v : Lang.Core.value) =
  match v.data with
  | VLit lit             -> VConst lit
  | VVar x               -> Env.lookup_var env x
  | VFn(x, _, body)      -> VFn(fun v -> eval (Env.add_var env x v) body)
  | VTypeFun(_, body)    -> VTypeFun (eval env body)
  | VInstFun(x, _, body) -> VInstFun(fun a -> eval (Env.add_inst env x a) body)
  | VPack(_, v, _, _)    -> eval_value env v
  | VTuple vs            -> VTuple (List.map (eval_value env) vs)
  | VCtor(p, n, _, vs)   ->
    VCtor(eval_value env p, n, List.map (eval_value env) vs)
  | VRecord(p, vs)       ->
    VRecord(eval_value env p, List.map (eval_value env)vs)
  | VExtern(name, _)     ->
    (Predef.DB.get_extern name).mk_value Value.v_class

and eval_rec_fun env_ref env rf =
  match rf with
  | RFFun(x, _, targs, y, _, body) ->
    Env.add_var env x (make_tfun targs (VFn(fun v cont ->
      eval (Env.add_var !env_ref y v) body cont)))
  | RFInstFun(x, _, targs, a, _, body) ->
    Env.add_var env x (make_tfun targs (VInstFun(fun b cont ->
      eval (Env.add_inst !env_ref a b) body cont)))

and eval_handler env (OpHandler(_, xs, xr, body)) vs v =
  let env = Env.add_vars env xs vs in
  let env = Env.add_var env xr v in
  eval env body

and eval_imports env imports cont =
  match imports with
  | []            -> cont []
  | im :: imports ->
    eval_import env im (fun v ->
    eval_imports env imports (fun vs ->
    cont ((im.im_var, v) :: vs)))

and eval_unit_body env body cont_fun mcont =
  match body with
  | UB_Direct body -> eval env body.body (fun v -> cont_fun v mcont)
  | UB_CPS    body ->
    let cont_fun = make_tfun body.types (VFn cont_fun) in
    eval env body.body (fun tp_fun ->
    begin match tp_fun with
    | VTypeFun tp_fun -> tp_fun (fun eff_fun ->
      begin match eff_fun with
      | VTypeFun eff_fun -> eff_fun (fun comp ->
        begin match comp with
        | VFn comp -> comp cont_fun mcont
        | _ -> assert false
        end)
      | _ -> assert false
      end)
    | _ -> assert false
    end)

and eval_import env im cont =
  match Env.find_implementation env im.im_path with
  | None ->
    begin match FileFinder.find_core_impl im with
    | None -> failwith
      ("Runtime error: Cannot file implementation of " ^ im.im_path)
    | Some p ->
      eval_imports env p.sf_import (fun vs ->
      eval_unit_body (Env.add_vars_p env vs) p.sf_body
        (fun v fcont ->
          Env.add_implementation env im.im_path v;
          fcont v)
        cont)
    end
  | Some v -> cont v

(* ========================================================================= *)

let rec reify_cont res v cont =
  match res with
  | [] -> cont v
  | (frame, c0) :: res ->
    RPushFrame(cont, frame, reify_cont res v c0)

let rec eval_meta stack ans =
  match ans with
  | RValue v ->
    begin match stack with
    | [] -> v
    | (cont, frame) :: stack ->
      eval_meta stack (frame.f_return v cont)
    end
  | RPushFrame(cont, frame, act) ->
    eval_meta ((cont, frame) :: stack) act
  | RDoOp(a, proof, n, args, cont, rest) ->
    begin match stack with
    | [] -> failwith "Runtime error: Unhandled effect"
    | (c1, frame) :: stack ->
      let rest = (frame, cont) :: rest in
      eval_meta stack begin
        if efftag_equal a frame.f_tag then
          let h = List.nth frame.f_handler n in
          h args (VFn(reify_cont rest)) c1
        else
          RDoOp(a, proof, n, args, c1, rest)
      end
    end
