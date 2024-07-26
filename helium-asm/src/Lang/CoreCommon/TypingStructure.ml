(* Lang/CoreCommon/TypingStructure.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Internal representation of types
 *
 * This is internal module that implements part of an interface exposed by
 * CoreTypes.Impl module *)

(* ========================================================================= *)
(* Type variables and instances *)

module TVar    = Common.TVar
module EffInst = Common.EffInst

type 'k tvar = 'k TVar.t
type effinst = Common.effinst

(* ========================================================================= *)
(* Kinds *)

include Kind.Impl

(* ========================================================================= *)
(* Type future *)

type 'k type_future_id =
| TFIdType   : Utils.UID.t -> ktype   type_future_id
| TFIdEffect : Utils.UID.t -> keffect type_future_id
| TFIdEffsig : Utils.UID.t -> keffsig type_future_id

type 'k type_future =
| TFType   of 'k typ
| TFFuture of 'k type_future_id * type_arg list * effinst list

(* ========================================================================= *)
(* Types *)

and type_arg =
| TpArg : 'k typ -> type_arg

and 'k typ =
| TyEffPure    : keffect typ
| TyEffCons    : effect * effect -> keffect typ
| TyEffInst    : effinst -> keffect typ
| TyBase       : RichBaseType.t -> ktype typ
| TyNeutral    : 'k neutral_type -> 'k typ
| TyTuple      : ttype list -> ktype typ
| TyArrow      : ttype * ttype * effect -> ktype typ
| TyForall     : 'k tvar * ttype -> ktype typ
| TyExists     : 'k tvar * ttype -> ktype typ
| TyForallInst : effinst * effsig * ttype -> ktype typ
| TyDataDef    : ttype * ctor_decl list -> ktype typ
| TyRecordDef  : ttype * field_decl list -> ktype typ
| TyEffsigDef  : effsig * op_decl list -> ktype typ
| TyFun        : 'k1 tvar * 'k2 typ -> ('k1 -> 'k2) typ
| TyFuture     : (unit -> 'k type_future) * subst -> 'k typ

and ctor_decl =
| CtorDecl of string * TVar.ex list * ttype list

and field_decl =
| FieldDecl of string * ttype

and op_decl =
| OpDecl of string * TVar.ex list * ttype list * ttype

and ttype  = ktype typ
and effect = keffect typ
and effsig = keffsig typ

and 'k neutral_type =
| TVar of 'k tvar
| TApp : ('k1 -> 'k2) neutral_type * 'k1 typ -> 'k2 neutral_type

and type_key_val =
| TKV : 'k tvar * 'k typ -> type_key_val

and subst =
  { sub_type : type_key_val TVar.Map.t
  ; sub_inst : effinst EffInst.Map.t
  }

type 'k type_view =
| TEffPure    : keffect type_view
| TEffCons    : effect * effect -> keffect type_view
| TEffInst    : effinst -> keffect type_view
| TBase       : RichBaseType.t -> ktype type_view
| TNeutral    : 'k neutral_type -> 'k type_view
| TTuple      : ttype list -> ktype type_view
| TArrow      : ttype * ttype * effect -> ktype type_view
| TForall     : 'k tvar * ttype -> ktype type_view
| TExists     : 'k tvar * ttype -> ktype type_view
| TForallInst : effinst * effsig * ttype -> ktype type_view
| TDataDef    : ttype * ctor_decl list -> ktype type_view
| TRecordDef  : ttype * field_decl list -> ktype type_view
| TEffsigDef  : effsig * op_decl list -> ktype type_view
| TFun        : 'k1 tvar * 'k2 typ -> ('k1 -> 'k2) type_view
| TFuture     :
  { uid    : Utils.UID.t
  ; tholes : type_arg list 
  ; eholes : effinst list 
  ; future : (unit -> 'k type_future)
  ; subst  : subst
  } -> 'k type_view
