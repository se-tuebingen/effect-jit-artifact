(* Lang/Core.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Core intermediate language.
 *
 * This is the main intermediate language of Helium. Currently it is closely
 * related to the calculus described in Binders by Day, Labels by Night paper.
 *)

include Kind.Export
include CoreCommon.CoreTypes.Export
include CoreCommon.TypeDef.Export
include CoreCommon.Unit.Export

module Var : Common.Var_S

type var = Common.var

type expr = (Utils.UID.t, expr_data) Node.node
and expr_data =
| EValue   of value
| ELet     of var * expr * expr
| ELetPure of var * expr * expr
| EFix     of rec_function list * expr
| EUnpack  :  'k tvar * var * value * expr -> expr_data
| ETypeDef of typedef list * expr
| ETypeApp :  value * 'k typ -> expr_data
| EInstApp of value * effinst
| EApp     of value * value
| EProj    of value * int
| ESelect  of value * int * value
| EMatch   of value * value * match_clause list * ttype
| EHandle  of
    { proof       : value
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

and rec_function =
| RFFun     of var * ttype * TVar.ex list * var * ttype * expr
| RFInstFun of var * ttype * TVar.ex list * effinst * effsig * expr

and match_clause =
| Clause of TVar.ex list * var list * expr

and op_handler =
| OpHandler of TVar.ex list * var list * var * expr

and value = (Utils.UID.t, value_data) Node.node
and value_data =
| VLit     of RichBaseType.lit
| VVar     of var
| VFn      of var * ttype * expr
| VTypeFun : 'k tvar * expr -> value_data
| VInstFun of effinst * effsig * expr
| VPack    : 'k typ * value * 'k tvar * ttype -> value_data
| VTuple   of value list
| VCtor    of value * int * type_arg list * value list
| VRecord  of value * value list
| VExtern  of string * ttype

type unit_body   = expr unit_body_gen
type source_file = expr source_file_gen

(** Operations on syntax *)
module Syntax : sig
  (** Apply type and instance substitution in an expression *)
  val apply_subst_in_expr : subst -> expr -> expr
end

module SExprPrinter : sig
  val tr_type  : 'k typ -> SExpr.t
  val tr_value : value -> SExpr.t
end

val print_expr : expr -> unit

val flow_node : source_file Flow.node
