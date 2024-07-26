(* Lang/CoreCommon/SExprPrinter.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Pretty-printing Core types as S-Expressions *)

open CoreTypes.Impl
open TypeDef.Impl

val tr_tvar_binder   : 'k tvar -> SExpr.t
val tr_tvar_binder_e : TVar.ex -> SExpr.t
val tr_tvar_binders  : TVar.ex list -> SExpr.t

val tr_type   : 'k typ -> SExpr.t
val tr_effect : effect -> SExpr.t list

val tr_type_arg : type_arg -> SExpr.t

val tr_typedef : typedef -> SExpr.t
