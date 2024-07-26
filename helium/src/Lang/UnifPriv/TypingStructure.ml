(* ========================================================================= *)
(* Type variables, constants and instances *)

module UVarBase : Kind.KindedVar_S = Kind.KindedVar
module TypeRef  : Kind.KindedVar_S = Kind.KindedVar

module TVar = Common.TVar

type 'k uvar     = 'k UVarBase.t
type 'k tvar     = 'k TVar.t
type 'k type_ref = 'k TypeRef.t

module EffInst = Common.EffInst

type effinst = EffInst.t

type scope =
  { type_scope : unit TVar.Map.t
  ; inst_scope : unit EffInst.Map.t
  }

(* ========================================================================= *)
(* Kinds *)

include Kind.Impl

(* ========================================================================= *)
(* Types *)

type name_opt = string option

type named_type =
  { nt_name : name_opt
  ; nt_type : ttype
  }

and implicit_effinst =
  { iei_uid : Utils.UID.t
  ; iei_sig : effsig
  }

and op_decl =
| OpDecl of string * TVar.ex list * named_type list * ex_type

and ctor_decl =
| CtorDecl of string * TVar.ex list * named_type list

and field_decl =
| FieldDecl of string * ttype

and decl =
| DeclThis    of ttype
| DeclTypedef of ttype
| DeclVal     of string * ttype
| DeclOp      of TVar.ex list * effsig * op_decl list * int
| DeclCtor    of TVar.ex list * ttype  * ctor_decl list * int
| DeclField   of TVar.ex list * ttype  * field_decl list * int

and effinst_expr_view =
| IEInstance of effinst
| IEImplicit of implicit_effinst

and effinst_expr = effinst_expr_view

and 'k typ =
| TyEffPure    : keffect typ
| TyEffInst    : effinst_expr -> keffect typ
| TyEffCons    : effect * effect -> keffect typ
| TyType       : 'k type_ref -> 'k typ
| TyBase       : RichBaseType.t -> ktype typ
| TyNeutral    : 'k neutral_type -> 'k typ
| TyArrow      : name_opt * ttype * ex_type * effect -> ktype typ
| TyForall     : TVar.ex list * ttype -> ktype typ
| TyForallInst : effinst * effsig * ttype -> ktype typ
| TyHandler    : effsig * ex_type * effect * ex_type * effect -> ktype typ
| TyFun        : 'k1 tvar * 'k2 typ -> ('k1 -> 'k2) typ
| TyStruct     : decl list -> ktype typ
| TyTypeWit    : ex_type -> ktype typ
| TyEffectWit  : effect -> ktype typ
| TyEffsigWit  : effsig -> ktype typ
| TyDataDef    : ttype * ctor_decl list -> ktype typ
| TyRecordDef  : ttype * field_decl list -> ktype typ
| TyEffsigDef  : effsig * op_decl list -> ktype typ
and ttype  = ktype typ
and effect = keffect typ
and effsig = keffsig typ

and ex_type =
| TExists of TVar.ex list * ttype

and 'k neutral_type =
| TVar of 'k tvar
| TApp :  ('k1 -> 'k) neutral_type * 'k1 typ -> 'k neutral_type

module TypeSubst = TVar.Map.Make(struct type 'k t = 'k typ end)

type subst =
  { sub_type : TypeSubst.t
  ; sub_inst : effinst_expr EffInst.Map.t
  }

(* Pointed by type_ref in World *)
type 'k type_value =
| TV_UVar of subst * 'k uvar
| TV_Type of 'k typ

type 'k type_view =
| TEffPure    : keffect type_view
| TEffInst    : effinst_expr -> keffect type_view
| TEffCons    : effect * effect -> keffect type_view
| TUVar       : subst * 'k uvar -> 'k type_view
| TBase       : RichBaseType.t -> ktype type_view
| TNeutral    : 'k neutral_type -> 'k type_view
| TArrow      : string option * ttype * ex_type * effect -> ktype type_view
| TForall     : TVar.ex list * ttype -> ktype type_view
| TForallInst : effinst * effsig * ttype -> ktype type_view
| THandler    : effsig * ex_type * effect * ex_type * effect -> ktype type_view
| TFun        : 'k1 tvar * 'k2 typ -> ('k1 -> 'k2) type_view
| TStruct     : decl list -> ktype type_view
| TTypeWit    : ex_type -> ktype type_view
| TEffectWit  : effect -> ktype type_view
| TEffsigWit  : effsig -> ktype type_view
| TDataDef    : ttype * ctor_decl list -> ktype type_view
| TRecordDef  : ttype * field_decl list -> ktype type_view
| TEffsigDef  : effsig * op_decl list -> ktype type_view

type row_view =
| RPure
| RUVar        of subst * keffect uvar
| RConsEffInst of effinst_expr * effect
| RConsNeutral of keffect neutral_type * effect
| RConsUVar    of subst * keffect uvar * effect

(* ========================================================================= *)
(* Exceptions *)

type error_reason =
| CannotUnify
| CannotGuessNeutral

exception Error of error_reason
