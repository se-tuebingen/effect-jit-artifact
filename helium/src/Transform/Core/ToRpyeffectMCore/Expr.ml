open Common
open Lang.Core

let get_recursive_function_name = function
  | S.RFFun(x, _, _, _, _, _) -> x
  | S.RFInstFun(x, _, _, _, _, _) -> x

let rec tr_expr env (e : S.expr) =
  match e.data with
  | S.EValue v -> tr_value env v
  | S.ELet(x,e1,e2) ->
    let x' = { T.name= T.Id.fresh (); T.tpe= T.Top } in (* TODO type *)
    T.Let ([T.Definition(x',tr_expr env e1,[])], tr_expr (Env.add_local_var env x x') e2)
  | S.ELetPure(x,e1,e2) -> (* TODO use purity *)
    let x' = { T.name= T.Id.fresh (); T.tpe= T.Top } in (* TODO type *)
    T.Let ([T.Definition(x',tr_expr env e1,[])], tr_expr (Env.add_local_var env x x') e2)
  | S.ETypeApp(v, _) -> tr_value env v (* TODO T.App (tr_value env v, [])*)
  | S.EInstApp(v, a) -> T.App(tr_value env v, [ T.Var(Env.lookup_inst env a) ])
  | S.EApp(v1, v2) -> T.App(tr_value env v1, [ tr_value env v2 ])
  | S.EProj(v, n) -> T.Project(tr_value env v, T.Id.fresh (), n)
  | S.ESelect(_, n, v) -> T.Project(tr_value env v, T.Id.fresh (), n)
  | S.ETypeDef(tds, e) -> tr_typedefs env tds e (* TODO *)
  | S.EFix(rfs, e) ->
    let rs = List.map (fun _ -> {T.name=T.Id.fresh (); T.tpe=T.Top}) rfs in (* TODO type *)
    let source_vars = List.map get_recursive_function_name rfs in
    let env' = Env.add_local_bindings env source_vars rs in
    T.LetRec(List.map (tr_recursive_function env') (List.combine rs rfs), tr_expr env' e)
  | S.EUnpack(_, x, v, e) ->
    let x' = { T.name= T.Id.fresh (); T.tpe= T.Top } in (* TODO type *)
    T.Let ([T.Definition(x',tr_value env v,[])], tr_expr (Env.add_local_var env x x') e)
  | S.EMatch(_, v, cls, _) -> 
    T.Match(tr_value env v, T.Id.fresh (), 
            List.mapi (fun i (S.Clause(_, xs, e)) -> (i, tr_clause env xs e)) cls,
            {T.params=[]; T.body=T.Primitive("non-exhaustive match", [], [], T.Literal(T.BaseInt(0)))})
  | S.EHandle { effinst; body; op_handlers; 
                return_var; return_body; _ } ->
    let i' = { T.name = T.Id.fresh (); T.tpe = T.Ptr } in (* TODO type *)
    let r' = { T.name = T.Id.fresh (); T.tpe = T.Top } in (* TODO type *)
    T.Let([T.Definition(i', T.FreshLabel, [])],
      T.DHandle(i', List.mapi (tr_op_handler env) op_handlers, 
        {T.params = [r']; T.body = tr_expr (Env.add_local_var env return_var r') return_body}, 
        tr_expr (Env.add_inst env effinst i') body))
  | S.EOp(_, n, a, _, args) -> 
    let rval = { T.name = T.Id.fresh (); T.tpe = T.Top } in (* TODO type *)
    T.DOp(Env.lookup_inst env a, n, List.map (tr_value env) args, {T.params = [rval]; T.body = T.Var rval}, T.Top)
  | S.ERepl _ | S.EReplExpr _ | S.EReplImport _ -> failwith "Compilation of repl code"

and tr_op_handler env n (S.OpHandler(_, xs, xr, body)) =
  let xr' = {T.name = T.Id.fresh (); T.tpe = (T.Function([T.Top],T.Top,Effectful))} in (* TODO type *)
  let xs' = List.map (fun _ -> {T.name = T.Id.fresh (); T.tpe = T.Top}) xs in (* TODO type *)
  (n, { T.params = xr' :: xs'; T.body = tr_expr (Env.add_local_vars env (xr :: xs) (xr' :: xs')) body })

and tr_clause env = fun xs e ->
  let xs' = List.map (fun _ -> {T.name = T.Id.fresh (); T.tpe = T.Top}) xs in (* TODO type *)
    {T.params = xs'; T.body = tr_expr (Env.add_local_vars env xs xs') e}

and tr_recursive_function env = function
  | (x', S.RFFun(_, _, targs, y, _, body)) -> (* TODO type args *)
    let y' = {T.name=T.Id.fresh (); T.tpe=T.Top} in (* TODO type *)
    T.Definition(x', T.Abs([y'], tr_expr (Env.add_local_var env y y') body), [])
  | (x', S.RFInstFun(_, _, targs, a, _, body)) ->
    let a' = {T.name=T.Id.fresh (); T.tpe=T.Top} in (* TODO type *)
    T.Definition(x', T.Abs([a'], tr_expr (Env.add_inst env a a') body), [])

and make_typeval tp =
  let rec go tp =
  match S.Type.view tp with
  | S.TForall(_, tp) -> "(forall ?. " ^ go tp ^ ")" (*T.Abs([], make_typeval tp)*)
  | S.TDataDef(tt, ctors) -> "(some data type)"
  | S.TRecordDef(tt, ctors) -> "(some record type)"
  | S.TEffsigDef(es, ops) -> "(some effect signature)"
  | S.TFun(fr, t) -> "(some function type)"
  | _ -> "(some type)" in
  T.Literal(T.BaseString(go tp))

and tr_typedefs env tds e =
  match tds with
  | [] -> tr_expr env e
  | S.TypeDef(_, x, tp) :: tds' ->
    let x' = {T.name=T.Id.fresh ();T.tpe=T.Ptr} in
    T.Let([T.Definition(x', make_typeval tp, [])],
          tr_typedefs (Env.add_local_var env x x') tds' e)

and tr_value env (v: S.value) =
  match v.data with
  | S.VExtern(name, tpe) -> tr_extern tpe name
  | S.VLit (LNum i)  -> T.Literal (BaseInt i)
  | S.VLit (LString s)  -> T.Literal (BaseString s)
  | S.VLit (LChar c) -> T.Literal (BaseString (String.make 1 c))
  | S.VVar x    -> T.Var(Env.lookup_var env x)
  | S.VTuple vs -> T.Construct(T.Id.fresh (), 0, List.map (tr_value env) vs)
  | S.VCtor(_, n, _, vs) -> T.Construct(T.Id.fresh (), n, List.map (tr_value env) vs)
  | S.VRecord(_, vs) -> T.Construct(T.Id.fresh (), 0, List.map (tr_value env) vs)
  | S.VFn(x, _, body) -> let x' = {T.name=T.Id.fresh(); T.tpe=T.Top } in (* TODO type *)
    T.Abs([x'], tr_expr (Env.add_local_var env x x') body)
  | S.VTypeFun(_, body) -> tr_expr env body (* TODO T.Abs([], tr_expr env body) *)
  | S.VInstFun(x, _, body) -> let x' = {T.name=T.Id.fresh(); T.tpe=T.Top } in
    T.Abs([x'], tr_expr (Env.add_inst env x x') body)
  | S.VPack(_, v, _, _) -> tr_value env v

and tr_extern ?(args=[]) tp extern_name =
  match S.Type.view tp with
  | S.TForall(_, tp) -> T.Abs([], tr_extern ~args tp extern_name)
  | S.TArrow(atp, rtp, _) -> 
    let arg = T.Id.fresh () in (* TODO types *)
    T.Abs([{name = arg; tpe = T.Top}], 
          tr_extern ~args: (arg :: args) rtp extern_name)
  | _ ->
    let emit_prim n atps rtp =
      match rtp with
      | T.Boolean ->
        let res = T.Id.fresh () in
        let argvals = List.map2 (fun a t -> T.Var{T.name=a;T.tpe=t}) (List.rev args) atps in
        (* As in the normal case, but make a Bool out of the Int *)
        let ttrue = T.Construct(T.Id.fresh (), 1, []) in
        let tfalse = T.Construct(T.Id.fresh (), 0, []) in
        T.Primitive(n, argvals, [{T.name=res;T.tpe=rtp}], 
          T.IfZero(T.Var{T.name=res;T.tpe=T.Int}, tfalse, ttrue)) (* TODO type *)
      | _ ->
        let res = T.Id.fresh () in
        let argvals = List.map2 (fun a t -> T.Var{T.name=a;T.tpe=t}) (List.rev args) atps in
        T.Primitive(n, argvals, [{T.name=res;T.tpe=rtp}], T.Var{T.name=res;T.tpe=T.Top}) (* TODO type *)
    in
    match extern_name with
    | "helium_addInt" -> emit_prim "infixAdd(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_subInt" -> emit_prim "infixSub(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_mulInt" -> emit_prim "infixMul(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_divInt" -> emit_prim "infixDiv(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_modInt" -> emit_prim "mod(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_eqInt"  -> emit_prim "infixEq(Int, Int): Boolean" [T.Int; T.Int] T.Boolean
    | "helium_neqInt" -> emit_prim "infixNeq(Int, Int): Boolean" [T.Int; T.Int] T.Boolean
    | "helium_ltInt"  -> emit_prim "infixLt(Int, Int): Boolean" [T.Int; T.Int] T.Boolean
    | "helium_gtInt"  -> emit_prim "infixGt(Int, Int): Boolean" [T.Int; T.Int] T.Boolean
    | "helium_leInt"  -> emit_prim "infixLte(Int, Int): Boolean" [T.Int; T.Int] T.Boolean
    | "helium_geInt"  -> emit_prim "infixGte(Int, Int): Boolean" [T.Int; T.Int] T.Boolean
    | "helium_andInt" -> emit_prim "infixAnd(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_orInt"  -> emit_prim "infixOr(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_xorInt" -> emit_prim "xor(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_lslInt" -> emit_prim "lsl(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_lsrInt" -> emit_prim "lsr(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_asrInt" -> emit_prim "asr(Int, Int): Int" [T.Int; T.Int] T.Int
    | "helium_negInt" -> emit_prim "neg(Int): Int" [T.Int] T.Int
    | "helium_notInt" -> emit_prim "infixNot(Int): Int" [T.Int] T.Int
    | "helium_exit"   -> emit_prim "exit(Int): Void" [T.Int] T.Bottom
    | "helium_printStr" -> emit_prim "println(String): Unit" [T.String] T.Top
    | "helium_string_of_int" -> emit_prim "show(Int): String" [T.Int] T.String
    (* For the Prelude *) (* TODO actually add those or do some translation here *)
    | "helium_stdin" -> emit_prim "getStdin(): InStream" [] T.Ptr
    | "helium_openIn" -> emit_prim "openIn(String): InStream" [T.String] T.Ptr
    | "helium_closeIn" -> emit_prim "closeIn(InStream): Unit" [T.Ptr] T.Top
    | "helium_input" -> emit_prim "read(InStream, Int): String" [T.Ptr; T.Int] T.String
    | "helium_stdout" -> emit_prim "getStdout(): OutStream" [] T.Ptr
    | "helium_stderr" -> emit_prim "getStderr(): OutStream" [] T.Ptr
    | "helium_openOut" -> emit_prim "openOut(String): OutStream" [T.String] T.Ptr
    | "helium_closeOut" -> emit_prim "closeOut(OutStream): Unit" [T.Ptr] T.Top
    | "helium_outputString" -> emit_prim "write(OutStream, String): Unit" [T.Ptr; T.String] T.Top
    (* For the Stdlib *) (* TODO actually add those or do some translation here *)
    | "helium_assertFalse" -> emit_prim "assertFalse(String): Void" [T.String] T.Top
    | "helium_readInt" -> emit_prim "readInt(InStream): Int" [T.Ptr] T.Int
    | "helium_printInt" -> emit_prim "println(Int): Unit" [T.Int] T.Top (* Semantically correct? *)
    | "helium_readLine" -> emit_prim "readLine(InStream): String" [T.Ptr] T.String
    | "helium_appendStr" -> emit_prim "infixConcat(String, String): String" [T.String; T.String] T.String
    | "helium_lengthStr" -> emit_prim "length(String): Int" [T.String] T.Int
    | "helium_substringStr" -> emit_prim "substring(String, Int, Int): String" [T.String; T.Int; T.Int] T.String
    | "helium_stringGet" -> emit_prim "charAt(Int, String): String" [T.Int; T.String] T.String
    | "helium_rawCompareStr" -> emit_prim "compare(String, String): Int" [T.String; T.String] T.Int
    | "helium_stringRepeat" -> emit_prim "repeat(Int, String): String" [T.Int; T.String] T.String
    | "helium_charCode" -> emit_prim "charCode(String): Int" [T.String] T.Int
    | "helium_charChr" -> emit_prim "chr(Int): String" [T.Int] T.String
    | "helium_getArgs" -> (
      let go = {T.name = T.Id.fresh (); T.tpe = T.Function([T.Int], T.Ptr, T.Effectful)} in
      let i = {T.name = T.Id.fresh (); T.tpe = T.Int} in
      let next_i = {T.name = T.Id.fresh (); T.tpe = T.Int} in
      let d = {T.name = T.Id.fresh (); T.tpe = T.Int} in
      let arg = {T.name = T.Id.fresh (); T.tpe = T.String} in
      let argc = {T.name = T.Id.fresh (); T.tpe = T.Int} in
      let list = T.Id.fresh () in
      let tnil = 0 in
      let tcons = 1 in
      T.Primitive("get_argc(): Int", [], [argc],
        T.LetRec([Definition(go, Abs([i], 
          T.Primitive("infixSub(Int, Int): Int", [T.Var(argc); T.Var(i)], [d],
            T.IfZero(T.Var(d),
              T.Construct(list, tnil, []), (* Nil *)
              T.Primitive("get_arg(Int): String", [T.Var(i)], [arg],
                T.Primitive("infixAdd(Int, Int): Int", [T.Var(i); T.Literal(T.BaseInt 1)], [next_i],
                  T.Construct(list, tcons, [T.Var(arg); T.App(T.Var(go), [T.Var(next_i)])])
                )
              )
            )
          )
        ), ["%helium_getArgs%go"])], 
        App(T.Var(go), [Literal(BaseInt 0)])))
      )
    | _ -> failwith ("Unsupported primitive " ^ extern_name)


let tr_program (p : S.expr) (tpe: S.ttype list)
    = let env = Env.empty () in
      T.Program ([], tr_expr env p)