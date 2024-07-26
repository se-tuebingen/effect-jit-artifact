(* Lang/CoreCommon/SyntaxOps.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Operations on syntax *)

open CoreCommon.CoreTypes.Impl
open Syntax

(** Apply type and instance substitution in an expression *)
val apply_subst_in_expr : subst -> expr -> expr
