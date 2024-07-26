open Lang.Node
open Common

let rec generalize_kind : type k. _ -> k T.kind -> T.TVar.ex * k T.typ =
  fun ex k ->
  match ex with
  | [] ->
    let y = T.TVar.fresh k in
    (T.TVar.Pack y, T.Type.var y)
  | T.TVar.Pack x :: ex ->
    let (y, tp) = generalize_kind ex (KArrow(T.TVar.kind x, k)) in
    (y, T.Type.app tp (T.Type.var x))

let rec pure_generalize ex1 ex2 tp2 =
  match ex2 with
  | []       -> ([], tp2)
  | T.TVar.Pack x :: ex2 ->
    let (ex2, tp2) = pure_generalize ex1 ex2 tp2 in
    let (y, x') = generalize_kind ex1 (T.TVar.kind x) in
    (y :: ex2, T.Type.subst_type x x' tp2)

let rec pure_generalize_eff_inst a ex tp =
  match ex with
  | [] -> ([], tp)
  | T.TVar.Pack x :: ex ->
    let (ex, tp) = pure_generalize_eff_inst a ex tp in
    let y  = T.TVar.fresh (KArrow(KEffect, T.TVar.kind x)) in
    let x' = T.Type.app (T.Type.var y) (T.Type.eff_ivar a) in
    (T.TVar.Pack x :: ex, T.Type.subst_type x x' tp)

(* ========================================================================= *)
(* Types *)
let rec check_type fix env tp =
  let check_expr env = fix.check_expr fix env in
  let pos = tp.meta in
  match tp.data with
  | S.EType ->
    let x = T.TVar.fresh KType in
    T.TExists([T.TVar.Pack x],
      T.Type.type_wit (T.TExists([], (T.Type.var x))))
  | S.EEffect ->
    let x = T.TVar.fresh KEffect in
    T.TExists([T.TVar.Pack x], T.Type.effect_wit (T.Type.var x))
  | S.EEffsig ->
    let x = T.TVar.fresh KEffsig in
    T.TExists([T.TVar.Pack x], T.Type.effsig_wit (T.Type.var x))
  | S.EArrowPure(args, tp) ->
    check_arrow_pure fix env args tp
  | S.EArrowEff(args, tp, row) ->
    check_arrow_eff fix env args tp row
  | S.EHandlerType(s, tp1, eff1, tp2, eff2) ->
    let s    = fix.check_effsig fix env s in
    let tp1  = fix.check_type   fix env tp1 in
    let eff1 = fix.check_effect fix env eff1 in
    let tp2  = fix.check_type   fix env tp2 in
    let eff2 = fix.check_effect fix env eff2 in
    T.TExists([], T.Type.handler s tp1 eff1 tp2 eff2)
  | S.ESig decls ->
    let (_, ex, decls) = fix.check_decls fix env decls in
    T.TExists(ex, T.Type.tstruct decls)

  | S.ELit _ | S.EVar _ | S.ETypeAnnot _ | S.EDef _ | S.EFn _ | S.EApp _
  | S.EAppInst _ | S.EMatch _ | S.EHandle _ | S.EHandler _ | S.EHandleWith _
  | S.ESelect _ | S.ERecord _ | S.EStruct _ | S.EExtern _ | S.ERepl _ ->
    let res = check_expr env tp Infer (Check T.Type.eff_pure) in
    begin match res.ce_type with
    | Infered (T.TExists([], tp)) ->
      let (_, extp) = TypeView.coerce_to_type_wit ~env ~pos tp in
      extp
    | Infered (T.TExists(_ :: _, _)) ->
      failwith "sealing is not allowed here"
    end

  | S.EEffInst _ | S.ERow _ ->
    failwith "type error: given effect, where type was exptected."

(* ------------------------------------------------------------------------- *)
and check_arrow_pure fix env args tp =
  match args with
  | []          -> check_type fix env tp
  | arg :: args ->
    check_single_arrow_pure fix env arg (fun env ->
      check_arrow_pure fix env args tp)

and check_single_arrow_pure fix env arg tp2_gen =
  let check_type env = fix.check_type fix env in
  match arg.data with
  | S.AAType tp1 ->
    let (env', ex1, tp1) = Env.open_ex_type env (check_type env tp1) in
    let (_,    ex2, tp2) = Env.open_ex_type env' (tp2_gen env') in
    let (ex2, tp2) = pure_generalize ex1 ex2 tp2 in
    T.TExists(ex2,
      T.Type.forall ex1 (T.Type.arrow' tp1 tp2 T.Type.eff_pure))
  | S.AAVars(xs, tp) ->
    check_single_arrow_pure_vars fix env xs (check_type env tp) tp2_gen
  | S.AAEffInsts(xs, s) ->
    check_single_arrow_pure_insts fix env xs (check_effsig fix env s) tp2_gen
  | S.AAImplicit(xs, tp) ->
    check_single_arrow_pure_implicit fix env xs (check_type env tp) tp2_gen

and check_single_arrow_pure_vars fix env xs xstp tp2_gen =
  match xs with
  | [] -> tp2_gen env
  | x :: xs ->
    let name = S.string_of_name x in
    let (env', ex1, tp1) = Env.open_ex_type env xstp in
    let (env', _) = Env.add_var env' name tp1 in
    let (_,    ex2, tp2) = Env.open_ex_type env'
      (check_single_arrow_pure_vars fix env' xs xstp tp2_gen) in
    let (ex2, tp2) = pure_generalize ex1 ex2 tp2 in
    T.TExists(ex2, T.Type.forall ex1
      (T.Type.arrow' ~name tp1 tp2 T.Type.eff_pure))

and check_single_arrow_pure_insts fix env xs xssig tp2_gen =
  match xs with
  | [] -> tp2_gen env
  | x :: xs ->
    let (env', a) = Env.add_effinst env x.data xssig in
    let (_, ex2, tp2) = Env.open_ex_type env'
      (check_single_arrow_pure_insts fix env' xs xssig tp2_gen) in
    let (ex2, tp2) = pure_generalize_eff_inst a ex2 tp2 in
    T.TExists(ex2, T.Type.forall_inst a xssig tp2)

and check_single_arrow_pure_implicit fix env xs xstp tp2_gen =
  match xs with
  | [] -> tp2_gen env
  | x :: xs ->
    let name = S.string_of_name x in
    let (env', ex1, tp1) = Env.open_ex_type env xstp in
    let (env', _) = Env.add_var env' name tp1 in
    let (_, ex2, tp2) = Env.open_ex_type env'
      (check_single_arrow_pure_implicit fix env' xs xstp tp2_gen) in
    let (ex2, tp2) = pure_generalize ex1 ex2 tp2 in
    (* TODO: make sure that tp1 may be implicit *)
    T.TExists(ex2, T.Type.forall ex1 tp2)

(* ------------------------------------------------------------------------- *)
and check_arrow_eff fix env args tp row =
  match args with
  | [] -> failwith "Impure arrow without arguments"
  | [ arg ] ->
    check_single_arrow_eff fix env arg (fun env ->
      (check_type fix env tp, check_row fix env row))
  | arg :: args ->
    check_single_arrow_pure fix env arg (fun env ->
      check_arrow_eff fix env args tp row)

and check_single_arrow_eff fix env arg tp_eff_gen =
  let check_type env = fix.check_type fix env in
  match arg.data with
  | S.AAType tp1 ->
    let (env, ex1, tp1) = Env.open_ex_type env (check_type env tp1) in
    let (extp, eff) = tp_eff_gen env in
    T.TExists([], T.Type.forall ex1 (T.Type.arrow tp1 extp eff))
  | S.AAVars(xs, tp) ->
    check_single_arrow_eff_vars fix env xs (check_type env tp) tp_eff_gen
  | S.AAEffInsts _ ->
    failwith "Impure instance arrow"
  | S.AAImplicit _ ->
    failwith "Impure type arrow"

and check_single_arrow_eff_vars fix env xs xstp tp_eff_gen =
  match xs with
  | [] -> failwith "Impure arrow without arguments"
  | x :: xs ->
    let name = S.string_of_name x in
    let (env, ex1, tp1) = Env.open_ex_type env xstp in
    let (env, _) = Env.add_var env name tp1 in
    let (extp, eff) =
      match xs with
      | []     -> tp_eff_gen env
      | _ :: _ ->
        (check_single_arrow_eff_vars fix env xs xstp tp_eff_gen,
         T.Type.eff_pure)
    in
    T.TExists([], T.Type.forall ex1
      (T.Type.arrow ~name tp1 extp eff))

(* ========================================================================= *)
(* Effects *)
and check_effect fix env eff =
  let check_expr env = fix.check_expr fix env in
  let pos = eff.meta in
  match eff.data with
  | S.ELit _ | S.EVar _ | S.ETypeAnnot _ | S.EDef _ | S.EFn _ | S.EApp _
  | S.EAppInst _ | S.EMatch _ | S.EHandle _ | S.EHandler _ | S.EHandleWith _
  | S.ESelect _ | S.ERecord _ | S.EStruct _ | S.EExtern _ | S.ERepl _ ->
    let res = check_expr env eff Infer (Check T.Type.eff_pure) in
    begin match res.ce_type with
    | Infered (T.TExists([], tp)) ->
      let (_, eff) = TypeView.coerce_to_effect_wit ~env ~pos tp in
      eff
    | Infered (T.TExists(_ :: _, _)) ->
      failwith "sealing is not allowed here"
    end
  | S.EEffInst x ->
    begin match Env.lookup_effinst env x with
    | Some(a, _) -> T.Type.eff_ivar a
    | None -> raise (Error.unbound_eff_inst ~pos x)
    end
  | S.ERow row -> check_row fix env row

  | S.EType | S.EEffect | S.EEffsig | S.EArrowPure _ | S.EArrowEff _
  | S.EHandlerType _ | S.ESig _ ->
    failwith "type error: given type, where effect was exptected."

and check_row fix env effs =
  match effs with
  | []          -> T.Type.eff_pure
  | [ eff ]     -> check_effect fix env eff
  | eff :: effs ->
    T.Type.eff_cons (check_effect fix env eff) (check_row fix env effs)

(* ========================================================================= *)
(* Effect signatures *)
and check_effsig fix env s =
  let check_expr env = fix.check_expr fix env in
  let pos = s.meta in
  match s.data with
  | S.ELit _ | S.EVar _ | S.ETypeAnnot _ | S.EDef _ | S.EFn _ | S.EApp _
  | S.EAppInst _ | S.EMatch _ | S.EHandle _ | S.EHandler _ | S.EHandleWith _ 
  | S.ESelect _ | S.ERecord _ | S.EStruct _ | S.EExtern _ | S.ERepl _ ->
    let res = check_expr env s Infer (Check T.Type.eff_pure) in
    begin match res.ce_type with
    | Infered (T.TExists([], tp)) ->
      let (_, s) = TypeView.coerce_to_effsig_wit ~env ~pos tp in
      s
    | Infered (T.TExists(_ :: _, _)) ->
      failwith "sealing is not allowed here"
    end

  | S.EType | S.EEffect | S.EEffsig | S.EArrowPure _ | S.EArrowEff _
  | S.EHandlerType _ | S.ESig _ ->
    failwith "type error: given type, where effsig was exptected."
  | S.EEffInst _ | S.ERow _ ->
    failwith "type error: given effect, where effsig was exptected."
