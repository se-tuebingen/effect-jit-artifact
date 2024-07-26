(* Transform/Unif/ToExplicit/Expr.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Translation of expressions *)

open Common

val tr_expr : Env.t -> S.expr -> T.expr
