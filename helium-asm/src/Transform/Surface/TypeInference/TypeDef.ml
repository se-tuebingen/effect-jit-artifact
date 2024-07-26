open Lang.Node
open Common

(* ========================================================================= *)
(* typedef arguments *)

type typedef_arg =
| Arg of T.TVar.ex list * S.name * T.ttype

let rec check_typedef_args_annot env xs extp =
  match xs with
  | [] -> (env, [])
  | x :: xs ->
    let (env, ex, tp) = Env.open_ex_type env extp in
    let (env, args) = check_typedef_args_annot env xs extp in
    (env, Arg(ex, x, tp) :: args)

let check_typedef_arg fix env arg =
  match arg.data with
  | S.TFA_Var _ ->
    raise (Error.cannot_infer_arg_type ~pos:arg.meta)
  | S.TFA_Annot(xs, tp) ->
    let extp = fix.check_type fix env tp in
    check_typedef_args_annot env xs extp

let rec check_typedef_args fix env args =
  match args with
  | [] -> []
  | arg :: args ->
    let (env, arg1) = check_typedef_arg fix env arg in
    arg1 @ check_typedef_args fix env args

let typedef_tvar (type k0) args (k0 : k0 T.kind) =
  let module Aux = struct
    type result = Result : 'k T.kind * ('k T.typ -> k0 T.typ) -> result

    let rec generalize_kind : type k.
        T.TVar.ex list -> k T.kind -> (k T.typ -> k0 T.typ) -> result =
      fun xs k gen ->
      match xs with
      | [] -> Result(k, gen)
      | T.TVar.Pack x :: xs ->
        let Result(k1, gen) = generalize_kind xs k gen in
        Result(KArrow(T.TVar.kind x, k1),
          fun tp -> gen (T.Type.app tp (T.Type.var x)))

    let rec aux args =
      match args with
      | [] -> Result(k0, fun tp -> tp)
      | Arg(ex, _, _) :: args ->
        let Result(k1, gen) = aux args in
        generalize_kind ex k1 gen
  end
  in
  let Result(k, gen) = Aux.aux args in
  let x = T.TVar.fresh k in
  (T.TVar.Pack x, gen (T.Type.var x))

let add_arg_to_env env (Arg(ex, x, tp)) =
  let env = Env.add_tvar_l env ex in
  let (env, _) = Env.add_var env (S.string_of_name x) tp in
  env

let rec add_args_to_env env args =
  match args with
  | [] -> env
  | arg :: args ->
    add_args_to_env (add_arg_to_env env arg) args

let rec build_type args rtp =
  match args with
  | [] -> rtp
  | Arg(ex, name, tp) :: args ->
    T.Type.forall ex (T.Type.arrow'
      ~name:(S.string_of_name name)
      tp
      (build_type args rtp) 
      T.Type.eff_pure)

let rec type_args_of_args args =
  match args with
  | [] -> []
  | Arg(ex, _, _) :: args -> ex @ type_args_of_args args

(* ========================================================================= *)
(* preparing *)

type typedef_body =
| TDBEffsig of T.effsig * S.op_decl list
| TDBData   of T.ttype  * S.ctor_decl list
| TDBRecord of T.ttype  * S.field_decl list

type pre_td_1 =
  { pre1_pos  : Utils.Position.t
  ; pre1_tvar : T.TVar.ex
  ; pre1_name : S.name
  ; pre1_args : typedef_arg list
  ; pre1_body : typedef_body
  }

let prepare_def fix env td =
  match td.data with
  | S.TDEffsig(x, args, ops) ->
    let args = check_typedef_args fix env args in
    let (Pack tx, s) = typedef_tvar args KEffsig in
    { pre1_pos  = td.meta
    ; pre1_tvar = T.TVar.Pack tx
    ; pre1_name = x
    ; pre1_args = args
    ; pre1_body = TDBEffsig(s, ops)
    }
  | S.TDData(x, args, ctors) ->
    let args = check_typedef_args fix env args in
    let (Pack tx, tp) = typedef_tvar args KType in
    { pre1_pos  = td.meta
    ; pre1_tvar = T.TVar.Pack tx
    ; pre1_name = x
    ; pre1_args = args
    ; pre1_body = TDBData(tp, ctors)
    }
  | S.TDRecord(x, args, flds) ->
    let args = check_typedef_args fix env args in
    let (Pack tx, tp) = typedef_tvar args KType in
    { pre1_pos  = td.meta
    ; pre1_tvar = T.TVar.Pack tx
    ; pre1_name = x
    ; pre1_args = args
    ; pre1_body = TDBRecord(tp, flds)
    }

(* ========================================================================= *)
(* Telescopes *)

let rec check_telescope_vars env xs extp =
  match xs with
  | [] -> (env, [], [])
  | x :: xs ->
    let name = S.string_of_name x in
    let (env, ex1, tp) = Env.open_ex_type env extp in
    let (env, _) = Env.add_var env name tp in
    let (env, ex2, tps) = check_telescope_vars env xs extp in
    (env, ex1 @ ex2, { T.nt_name = Some name; T.nt_type = tp } :: tps)

let rec check_telescope_implicit env xs extp =
  match xs with
  | [] -> (env, [], [])
  | x :: xs ->
    let name = S.string_of_name x in
    let (env, ex1, tp) = Env.open_ex_type env extp in
    let (env, _) = Env.add_var env name tp in
    let (env, ex2, tps) = check_telescope_implicit env xs extp in
    (* TODO: make sure that tp can be implicit *)
    (env, ex1 @ ex2, tps)

let check_telescope_arg fix env arg =
  match arg.data with
  | S.AAType tp ->
    let (env, ex, tp) = Env.open_ex_type env (fix.check_type fix env tp) in
    (env, ex, [ { T.nt_name = None; T.nt_type = tp } ])
  | S.AAVars(xs, tp) ->
    check_telescope_vars env xs (fix.check_type fix env tp)
  | S.AAEffInsts _ ->
    raise (Error.effinst_in_data ~pos:arg.meta)
  | S.AAImplicit(xs, tp) ->
    check_telescope_implicit env xs (fix.check_type fix env tp)

let rec check_telescope fix env args =
  match args with
  | [] -> (env, [], [])
  | arg :: args ->
    let (env, ex1, tps1) = check_telescope_arg fix env arg  in
    let (env, ex2, tps2) = check_telescope     fix env args in
    (env, ex1 @ ex2, tps1 @ tps2)

(* ========================================================================= *)
(* Checking prepared *)

type pre_td_2 =
  { pre2_pos  : Utils.Position.t
  ; pre2_tvar : T.TVar.ex
  ; pre2_name : S.name
  ; pre2_args : typedef_arg list
  ; pre2_body : T.ttype
  }

let check_op_decl fix env op =
  match op.data with
  | S.OpDecl(name, args, tp) ->
    let (env, ex, tps) = check_telescope fix env args in
    let extp = fix.check_type fix env tp in
    T.OpDecl(S.string_of_name name, ex, tps, extp)

let check_ctor_decl fix env ctor =
  match ctor.data with
  | S.CtorDecl(name, args) ->
    let (_, ex, tps) = check_telescope fix env args in
    T.CtorDecl(S.string_of_ctor_name name, ex, tps)

let check_field_decl fix env fld =
  match fld.data with
  | S.FieldDecl(name, tp) ->
    begin match fix.check_type fix env tp with
    | T.TExists([], tp) ->
      T.FieldDecl(S.string_of_name name, tp)
    | T.TExists(_ :: _, _) ->
      raise (Error.existential_field ~pos:fld.meta)
    end

let check_typedef_body fix env body =
  match body with
  | TDBEffsig(s, ops) ->
    Uniqueness.check_op_decl_uniqueness ops;
    T.Type.effsig_def s (List.map (check_op_decl fix env) ops)
  | TDBData(tp, ctors) ->
    Uniqueness.check_ctor_decl_uniqueness ctors;
    T.Type.data_def tp (List.map (check_ctor_decl fix env) ctors)
  | TDBRecord(tp, flds) ->
    Uniqueness.check_field_decl_uniqueness flds;
    T.Type.record_def tp (List.map (check_field_decl fix env) flds)

let check_prepared_def fix env td =
  let env = add_args_to_env env td.pre1_args in
  { pre2_pos  = td.pre1_pos
  ; pre2_tvar = td.pre1_tvar
  ; pre2_name = td.pre1_name
  ; pre2_args = td.pre1_args
  ; pre2_body = check_typedef_body fix env td.pre1_body
  }

(* ========================================================================= *)
(* Extending environment *)

let add_type_def_to_env env td =
  Env.add_tvar_l env [ td.pre1_tvar ]

let add_type_defs_to_env env tds =
  List.fold_left add_type_def_to_env env tds

let add_type_def_placeholder_to_env env td =
  let name = S.string_of_name td.pre1_name in
  let tp =
    match td.pre1_body with
    | TDBEffsig(s, _) -> T.Type.effsig_wit s
    | TDBData(tp, _) | TDBRecord(tp, _) ->
      T.Type.type_wit (T.TExists([], tp))
  in
  let tp = build_type td.pre1_args tp in
  let (env, _) = Env.add_var env name tp in
  env

let add_type_def_placeholders_to_env env tds =
  List.fold_left add_type_def_placeholder_to_env env tds

(* ========================================================================= *)
(* Creating target typedefs *)

type td =
  { td_pos   : Utils.Position.t
  ; td_name  : S.name
  ; td_var   : T.var
  ; td_args  : typedef_arg list
  ; td_targs : T.TVar.ex list
  ; td_body  : T.ttype
  }

let finalize_def env td =
  let targs = type_args_of_args td.pre2_args in
  let tp    = T.Type.forall targs td.pre2_body in
  let (env, x) = Env.add_var' env tp in
  let (T.TVar.Pack tx) = td.pre2_tvar in
  let t_td = T.TypeDef(tx, x) in
  let td =
    { td_pos   = td.pre2_pos
    ; td_name  = td.pre2_name
    ; td_var   = x
    ; td_args  = td.pre2_args
    ; td_targs = targs
    ; td_body  = td.pre2_body
    } in
  (env, t_td, td)

let rec finalize_defs env tds =
  match tds with
  | [] -> (env, [], [])
  | td :: tds ->
    let (env, t_td,  td)  = finalize_def  env td in
    let (env, t_tds, tds) = finalize_defs env tds in
    (env, t_td :: t_tds, td :: tds)

(* ========================================================================= *)

let check_def fix env td =
  let td   = prepare_def fix env td in
  let env1 = add_type_def_to_env env td in
  let td   = check_prepared_def fix env td in
  finalize_def env1 td

let check_rec_defs fix env tds =
  let tds  = List.map (prepare_def fix env) tds in
  let env  = add_type_defs_to_env env tds in
  let env1 = add_type_def_placeholders_to_env env tds in
  let tds  = List.map (check_prepared_def fix env1) tds in
  finalize_defs env tds

(* ========================================================================= *)

let build_ctor_decl td tp ctors i _ =
  T.DeclCtor(td.td_targs, tp, ctors, i)

let build_field_decl td tp flds i _ =
  T.DeclField(td.td_targs, tp, flds, i)

let build_op_decl td s ops i _ =
  T.DeclOp(td.td_targs, s, ops, i)

let build_content_decl td =
  match T.Type.view td.td_body with
  | TDataDef(tp, ctors) ->
    List.mapi (build_ctor_decl td tp ctors) ctors
  | TRecordDef(tp, flds) ->
    List.mapi (build_field_decl td tp flds) flds
  | TEffsigDef(s, ops) ->
    List.mapi (build_op_decl td s ops) ops
  | TUVar _ | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _
  | THandler _ | TStruct _ | TTypeWit _ | TEffectWit _ | TEffsigWit _ ->
    assert false

let build_typedef_struct_decl td =
     T.DeclThis    (build_type td.td_args td.td_body)
  :: T.DeclTypedef (T.Var.typ td.td_var)
  :: build_content_decl td

(* ------------------------------------------------------------------------- *)

let type_args xs =
  List.map (fun (T.TVar.Pack x) -> T.TpArg(T.Type.var x)) xs

let build_ctor_def ~fix td i _ =
  make ~fix td.td_pos (T.SDCtor(make ~fix td.td_pos (T.VVar td.td_var), i))

let build_field_def ~fix td i _ =
  make ~fix td.td_pos (T.SDField(make ~fix td.td_pos (T.VVar td.td_var), i))

let build_op_def ~fix td i _ =
  make ~fix td.td_pos (T.SDOp(make ~fix td.td_pos (T.VVar td.td_var), i))

let build_content_def ~fix td =
  match T.Type.view td.td_body with
  | TDataDef(tp, ctors) ->
    List.mapi (build_ctor_def ~fix td) ctors
  | TRecordDef(tp, flds) ->
    List.mapi (build_field_def ~fix td) flds
  | TEffsigDef(s, ops) ->
    List.mapi (build_op_def ~fix td) ops
  | TUVar _ | TBase _ | TNeutral _ | TArrow _ | TForall _ | TForallInst _
  | THandler _ | TStruct _ | TTypeWit _ | TEffectWit _ | TEffsigWit _ ->
    assert false

let rec build_typedef_fn ~fix args td =
  match args with
  | [] ->
    make ~fix td.td_pos (T.VTypeApp(
      make ~fix td.td_pos (T.VVar td.td_var),
      type_args td.td_targs))
  | Arg(ex, x, tp) :: args ->
    make ~fix td.td_pos (T.VTypeFun(ex,
      make ~fix td.td_pos (T.VVarFn(T.Var.fresh tp,
        make ~fix td.td_pos (T.EValue (build_typedef_fn ~fix args td))))))

let build_typedef_struct_def ~fix td =
     make ~fix td.td_pos (T.SDThis    (build_typedef_fn ~fix td.td_args td))
  :: make ~fix td.td_pos (T.SDTypedef (make ~fix td.td_pos (T.VVar td.td_var)))
  :: build_content_def ~fix td

(* ------------------------------------------------------------------------- *)

let build_typedef ~fix env td cont =
  let name = td.td_name in
  let str_decl = build_typedef_struct_decl td in
  let str_def  =
    make ~fix td.td_pos (T.VStruct (build_typedef_struct_def ~fix td)) in
  let (env, x) =
    Env.add_var env (S.string_of_name name) (T.Type.tstruct str_decl) in
  let v0 = [ make_val ~fix td.td_pos name x (T.Type.tstruct str_decl) ] in
  ExprBuilder.build_let ~fix ~env ~pos:td.td_pos [] x
    (make ~fix td.td_pos (T.EValue str_def)) (
  ModuleOpen.weak_include ~fix ~env ~pos:td.td_pos x (fun env vals ->
  cont env (merge_vals_hide v0 vals)))

let rec build_typedefs ~fix env tds cont =
  match tds with
  | [] -> cont env []
  | td :: tds ->
    build_typedef  ~fix env td  (fun env vals1 ->
    build_typedefs ~fix env tds (fun env vals2 ->
    cont env (merge_vals_hide vals1 vals2)))

(* ========================================================================= *)

let build_typedecl env td =
  let name = td.td_name in
  let str_decl = build_typedef_struct_decl td in
  let (env, _) =
    Env.add_var env (S.string_of_name name) (T.Type.tstruct str_decl) in
  let decl0 =
    match name.data with
    | S.NameThis -> T.DeclThis (T.Type.tstruct str_decl)
    | _ -> T.DeclVal(S.string_of_name name, T.Type.tstruct str_decl)
  in
  let (env, decls) = ModuleOpen.weak_include_sig_decls env str_decl in
  (env, merge_decls [ decl0 ] decls)

let rec build_typedecls env tds =
  match tds with
  | [] -> (env, [])
  | td :: tds ->
    let (env, decls1) = build_typedecl  env td in
    let (env, decls2) = build_typedecls env tds in
    (env, merge_decls decls1 decls2)

let tvars tds =
  List.map (fun (T.TypeDef(x, _)) -> T.TVar.Pack x) tds

(* ========================================================================= *)

let rec make_fun ~fix pos args cont =
  match args with
  | []     -> assert false
  | [ nt ] ->
    let x = T.Var.fresh nt.T.nt_type in
    make ~fix pos (T.VVarFn(x, cont [ make ~fix pos (T.VVar x) ]))
  | nt :: tps ->
    make_fun ~fix pos [ nt ] (fun args1 ->
    make ~fix pos (T.EValue(make_fun ~fix pos tps (fun args2 ->
    cont (args1 @ args2)))))

let make_fun_value ~fix pos args cont =
  match args with
  | [] -> cont []
  | _  -> make_fun ~fix pos args (fun args ->
    make ~fix pos (T.EValue(cont args)))

let op_proxy ~fix ~pos v xs s (T.OpDecl(_, ys, args, res)) n =
  let a = T.EffInst.fresh () in
  let proof = make ~fix pos (T.VTypeApp(v, type_args xs)) in
  make ~fix pos (T.VTypeFun(xs, make ~fix pos (T.VInstFun(a, s,
    make ~fix pos (T.EValue(make ~fix pos (T.VTypeFun(ys,
      make_fun ~fix pos args (fun args ->
        make ~fix pos (T.EOp(proof, n, a, type_args ys, args)))))))))))

let ctor_proxy ~fix ~pos v xs tp (T.CtorDecl(_, ys, args)) n =
  let proof = make ~fix pos (T.VTypeApp(v, type_args xs)) in
  make ~fix pos (T.VTypeFun(xs, make ~fix pos (T.VTypeFun(ys,
    make_fun_value ~fix pos args (fun args ->
      make ~fix pos (T.VCtor(proof, n, type_args ys, args)))))))
