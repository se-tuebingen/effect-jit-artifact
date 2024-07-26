(* Lang/CoreCommon/Scope.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Scope of the type, i.e., sets of available type variables and effect
  * instances.
 *
 * This is internal module that implements part of an interface exposed by
 * CoreTypes.Impl module *)

open TypingStructure

type t

val empty : t

val add_tvar  : t -> 'k tvar -> t
val add_tvars : t -> TVar.ex list -> t

val add_effinst : t -> effinst -> t

val has_tvar    : t -> 'k tvar -> bool
val has_effinst : t -> effinst -> bool
