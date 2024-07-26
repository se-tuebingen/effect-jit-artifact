(* Transform/Unif/ToExplicit/Env.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Environment of the translation *)

type t

(** Empty environment *)
val empty : t

(** Add type variable to environment. Returns new environment and fresh type
  * variable *)
val add_tvar : t -> 'k Lang.Unif.tvar -> t * 'k Lang.Explicit.tvar

(** Add type variables to the environment. Returns new envionment and fresh
  * type variables *)
val add_tvars  : t -> Lang.Unif.TVar.ex list -> t * Lang.Explicit.TVar.ex list

(** Add effect instance to the environment. Returns new environment and fresh
  * effect instance *)
val add_effinst : t -> Lang.Unif.effinst -> t * Lang.Explicit.effinst

(** Add variable to the environment. Returns new envrionment and fresh
  * variable *)
val add_var : t -> Lang.Unif.var -> t * Lang.Explicit.var

(** Lookup for type variable *)
val lookup_tvar : t -> 'k Lang.Unif.tvar -> 'k Lang.Explicit.tvar

(** Lookup for effect instance in the environment *)
val lookup_inst : t -> Lang.Unif.effinst -> Lang.Explicit.effinst

(** Lookup for variable *)
val lookup_var  : t -> Lang.Unif.var -> Lang.Core.var
