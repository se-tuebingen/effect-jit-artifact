(* Transform/Explicit/ToCore/Errors.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Errors that may occur during the translation *)

(** Example value, not matched by pattern-matching *)
type exval =
| EVAny
| EVCtor of string * exval list

(** Errors that may occur during the translation *)
type error =
| NonExhaustiveMatch of Utils.UID.t * exval

exception Error of error

(** Flow node of error representation *)
val flow_node : error Flow.node
