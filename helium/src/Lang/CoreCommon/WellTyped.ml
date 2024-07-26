(* Lang/CoreCommon/WellTyped.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)

open Kind.Impl
open CoreTypes.Impl
open TypeDef.Impl
open Unit.Impl

exception Type_error

module Env : sig
  type t

  val empty : t

  val add_tvar   : t -> 'k tvar -> t * 'k tvar
  val add_tvars  : t -> TVar.ex list -> t * TVar.ex list
  val add_tvars2 : t -> TVar.ex list -> TVar.ex list -> t * subst

  val add_effinst : t -> effinst -> effsig -> t * effinst

  val add_var  : t -> Common.Var.t -> ttype -> t
  val add_vars : t -> Common.Var.t list -> ttype list -> t

  val scope : t -> scope
  val to_subst : t -> subst

  val tr_tvar     : t -> 'k tvar -> 'k tvar
  val lookup_inst : t -> effinst -> effinst * effsig
  val check_var   : t -> Common.Var.t -> ttype
end = struct
  module TVarMap = TVar.Map.Make(TVar)
  module VarMap  = Common.Var.Map

  type t =
    { type_env : TVarMap.t
    ; inst_env : (effinst * effsig) EffInst.Map.t
    ; var_env  : ttype VarMap.t
    ; scope    : scope
    }

  let empty =
    { type_env = TVarMap.empty
    ; inst_env = EffInst.Map.empty
    ; var_env  = VarMap.empty
    ; scope    = Scope.empty
    }

  let add_tvar env x =
    let y = TVar.clone x in
    { env with
      type_env = TVarMap.add x y env.type_env
    ; scope    = Scope.add_tvar env.scope y
    }, y

  let add_tvar_ex env (TVar.Pack x) =
    let (env, x) = add_tvar env x in
    (env, TVar.Pack x)

  let add_tvars env xs =
    Utils.ListExt.fold_map add_tvar_ex env xs

  let rec add_tvars2_aux env sub xs ys =
    match xs, ys with
    | [], [] -> (env, sub)
    | TVar.Pack x :: xs, TVar.Pack y :: ys ->
      begin match Kind.equal (TVar.kind x) (TVar.kind y) with
      | Equal ->
        let (env, z) = add_tvar env x in
        add_tvars2_aux env (Subst.add_type sub y (Type.var z)) xs ys
      | NotEqual -> raise Type_error
      end
    | [], _ :: _ | _ :: _, [] -> raise Type_error

  let add_tvars2 env xs ys =
    add_tvars2_aux env Subst.empty xs ys

  let add_effinst env a s =
    let b = EffInst.clone a in
    { env with
      inst_env = EffInst.Map.add a (b, s) env.inst_env
    ; scope    = Scope.add_effinst env.scope b
    }, b

  let add_var env x tp =
    { env with
      var_env = VarMap.add x tp env.var_env
    }

  let add_vars env xs tps =
    if List.length xs <> List.length tps then
      raise Type_error
    else List.fold_left2 add_var env xs tps
  
  let scope env = env.scope

  let to_subst env =
    let sub = Subst.empty in
    let sub = TVarMap.fold
      { fold_f = fun x y sub -> Subst.add_type sub x (Type.var y) }
      env.type_env
      sub in
    EffInst.Map.fold
      (fun a (b, _) sub -> Subst.add_inst sub a b)
      env.inst_env
      sub

  let tr_tvar env x =
    match TVarMap.find_opt x env.type_env with
    | None -> raise Type_error
    | Some x -> x

  let lookup_inst env a =
    match EffInst.Map.find_opt a env.inst_env with
    | None -> raise Type_error
    | Some r -> r

  let check_var env x =
    match VarMap.find_opt x env.var_env with
    | None -> raise Type_error
    | Some x -> x
end

(* ========================================================================= *)

let rec tr_ctor_decl env ctor =
  match ctor with
  | CtorDecl(name, xs, tps) ->
    let (env, xs) = Env.add_tvars env xs in
    CtorDecl(name, xs, List.map (tr_type env) tps)

and tr_field_decl env fld =
  match fld with
  | FieldDecl(name, tp) ->
    FieldDecl(name, tr_type env tp)

and tr_op_decl env op =
  match op with
  | OpDecl(name, xs, tps, tp) ->
    let (env, xs) = Env.add_tvars env xs in
    OpDecl(name, xs, List.map (tr_type env) tps, tr_type env tp)

and tr_type : type k. Env.t -> k typ -> k typ =
  fun env tp ->
  match Type.view tp with
  | TEffPure     -> Type.eff_pure
  | TEffCons(eff1, eff2) ->
    Type.eff_cons (tr_type env eff1) (tr_type env eff2)
  | TEffInst a ->
    Type.eff_inst (fst (Env.lookup_inst env a))
  | TBase    b   -> Type.base b
  | TNeutral neu ->
    Type.neutral (tr_neutral_type env neu)
  | TTuple tps ->
    Type.tuple (List.map (tr_type env) tps)
  | TArrow(tp1, tp2, eff) ->
    Type.arrow (tr_type env tp1) (tr_type env tp2) (tr_type env eff)
  | TForall(x, tp) ->
    let (env, x) = Env.add_tvar env x in
    Type.forall x (tr_type env tp)
  | TExists(x, tp) ->
    let (env, x) = Env.add_tvar env x in
    Type.exists x (tr_type env tp)
  | TForallInst(a, s, tp) ->
    let s = tr_type env s in
    let (env, a) = Env.add_effinst env a s in
    Type.forall_inst a s (tr_type env tp)
  | TDataDef(tp, ctors) ->
    Type.data_def (tr_type env tp) (List.map (tr_ctor_decl env) ctors)
  | TRecordDef(tp, flds) ->
    Type.record_def (tr_type env tp) (List.map (tr_field_decl env) flds)
  | TEffsigDef(s, ops) ->
    Type.effsig_def (tr_type env s) (List.map (tr_op_decl env) ops)
  | TFun(x, tp) ->
    let (env, x) = Env.add_tvar env x in
    Type.tfun x (tr_type env tp)
  | TFuture fut ->
    Type.future fut.future
      (Subst.compose (Env.to_subst env) fut.subst)

and tr_neutral_type : type k. Env.t -> k neutral_type -> k neutral_type =
  fun env neu ->
  match neu with
  | TVar x -> TVar (Env.tr_tvar env x)
  | TApp(neu, tp) ->
    TApp(tr_neutral_type env neu, tr_type env tp)

(* ========================================================================= *)

let check_type_arg env sub (TVar.Pack x) (TpArg tp) =
  match Kind.equal (TVar.kind x) (Type.kind tp) with
  | Equal    -> Subst.add_type sub x (tr_type env tp)
  | NotEqual -> raise Type_error

let check_type_args env xs args =
  if List.length xs <> List.length args then raise Type_error
  else List.fold_left2 (check_type_arg env) Subst.empty xs args

(* ========================================================================= *)

let check_typedefs env tds =
  let module M = struct
    type td = TD : 'k tvar * Common.var * ttype -> td

    let prepare_typedef env (TypeDef(x, z, tp)) =
      let (env, x) = Env.add_tvar env x in
      (env, TD(x, z, tp))

    let rec check_typedef_shape : type k. k neutral_type -> ttype -> unit =
      fun td tp ->
        match Type.neutral_kind td with
        | KType ->
          begin match Type.view tp with
          | TDataDef(td', _) | TRecordDef(td', _) ->
            if Type.equal (Type.neutral td) td' then ()
            else raise Type_error
          | _ -> raise Type_error
          end
        | KEffect -> raise Type_error
        | KEffsig ->
          begin match Type.view tp with
          | TEffsigDef(td', _) ->
            if Type.equal (Type.neutral td) td' then ()
            else raise Type_error
          | _ -> raise Type_error
          end
        | KArrow(k1, _) ->
          begin match Type.view tp with
          | TForall(x, tp) ->
            begin match Kind.equal k1 (TVar.kind x) with
            | Equal ->
              check_typedef_shape (TApp(td, Type.var x)) tp
            | NotEqual -> raise Type_error
            end
          | _ -> raise Type_error
          end

    let check_typedef env (TD(x, z, tp)) =
      let tp = tr_type env tp in
      check_typedef_shape (TVar x) tp;
      Env.add_var env z tp
  end in
  let (env, tds) = List.fold_left_map M.prepare_typedef env tds in
  List.fold_left M.check_typedef env tds

(* ========================================================================= *)

let import (env, eff) im =
  let (env, _) = Env.add_tvars env im.im_types in
  let im_eff = tr_type env im.im_handle in
  let env = Env.add_var env im.im_var
    (Type.tuple (List.map (tr_type env) im.im_sig)) in
  (env, Type.eff_cons im_eff eff)

let check_source_file env check_expr_type_eff p =
  let (env, eff) = List.fold_left import (env, Type.eff_pure) p.sf_import in
  match p.sf_body with
  | UB_Direct body ->
    let (env', xs) = Env.add_tvars env body.types in
    let tp =
      Type.exists_l xs (Type.tuple (List.map (tr_type env') body.body_sig)) in
    check_expr_type_eff env body.body tp eff
  | UB_CPS body ->
    let ambient_eff = tr_type env body.ambient_eff in
    let cps_tp      = TVar.fresh KType   in
    let cps_eff     = TVar.fresh KEffect in
    let (env', xs) = Env.add_tvars env body.types in
    let ans_eff    = Type.eff_cons (Type.var cps_eff) ambient_eff in
    begin if Type.subeffect ambient_eff eff then () else raise Type_error end;
    let tp =
      Type.forall cps_tp (Type.forall cps_eff
        (Type.arrow
          (Type.forall_l xs (Type.arrow
            (Type.tuple (List.map (tr_type env') body.body_sig))
            (Type.var cps_tp)
            (Type.eff_cons ans_eff (tr_type env' body.handle))))
          (Type.var cps_tp)
          ans_eff)) in
    check_expr_type_eff env body.body tp eff
