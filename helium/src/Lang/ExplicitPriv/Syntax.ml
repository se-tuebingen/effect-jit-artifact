(* Lang/ExplicitPriv/Syntax.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Syntax of Explicit intermediate language *)
open CoreCommon.CoreTypes.Impl
open CoreCommon.TypeDef.Impl
open CoreCommon.Unit.Impl

module Var = Common.Var

type var = Common.var

type type_instance =
| TpInst : 'k tvar * 'k typ -> type_instance

type coercion =
| CId        of ttype * ttype
| CComp      of coercion * coercion
| CArrow     of
  { arg_crc : coercion
  ; res_crc : coercion
  ; eff_in  : effect
  ; eff_out : effect
  }
| CTypeGen   of TVar.ex list * coercion
| CTypeApp   of type_instance list * ttype * coercion
| CInstGen   of effinst * effsig * coercion
| CInstApp   of ttype * effinst * coercion
| CPack      of coercion * type_instance list * ttype
| CUnpack    of TVar.ex list * coercion
| CTuple     of ttype * coercion list
| CProj      of ttype list * int * coercion
| CCtorProxy of ttype * ctor_decl list * int
| COpProxy   of effsig * op_decl list * int

type pattern = (Utils.UID.t, pattern_data) Node.node
and pattern_data =
| PVar    of var * ttype
| PCoerce of coercion * pattern
| PCtor   of
  { typ   : ttype
  ; ctors : ctor_decl list
  ; proof : value
  ; index : int
  ; targs : TVar.ex list
  ; args  : pattern list
  }

and expr = (Utils.UID.t, expr_data) Node.node
and expr_data = 
| EValue      of value
| ECoerce     of coercion * expr
| EPack       of type_instance list * ttype * expr
| ELet        of TVar.ex list * var * expr * expr
| EFix        of rec_function list * expr
| ETypeDef    of typedef list * expr
| EApp        of expr * expr
| EInstApp    of expr * effinst
| EMatch      of expr * clause list * ttype
| EEmptyMatch of expr * value * ttype
| EHandle     of
  { proof       : value
  ; ops         : op_decl list
  ; effinst     : effinst
  ; body        : expr
  ; op_handlers : op_handler list
  ; return_var  : var
  ; return_body : expr
  ; htype       : ttype
  ; heffect     : effect
  }
| EOp         of value * int * effinst * type_arg list * value list
| ERepl       of (unit -> expr CommonRepl.result) * ttype * effect * Box.t
| EReplExpr   of expr * Box.t * expr
| EReplImport of import list * expr

and value = (Utils.UID.t, value_data) Node.node
and value_data =
| VLit      of RichBaseType.lit
| VVar      of var
| VCoerce   of coercion * value
| VVarFn    of var * ttype * expr
| VFn       of pattern * expr * ttype
| VTypeFun  of TVar.ex list * value
| VTypeFunE of TVar.ex list * expr
| VTypeApp  of value * type_arg list
| VInstFun  of effinst * effsig * expr
| VCtor     of value * int * type_arg list * value list
| VSelect   of value * int * value
| VRecord   of value * value list
| VTuple    of value list
| VProj     of value * int
| VExtern   of string * ttype

and rec_function =
| RFFun     of var * ttype * TVar.ex list * var * ttype * expr
| RFInstFun of var * ttype * TVar.ex list * effinst * effsig * expr

and clause = (Utils.UID.t, clause_data) Node.node
and clause_data =
| Clause of pattern * expr

and op_handler = (Utils.UID.t, op_handler_data) Node.node
and op_handler_data =
| HOp of int * TVar.ex list * pattern list * pattern * expr

type unit_body   = expr unit_body_gen
type source_file = expr source_file_gen
