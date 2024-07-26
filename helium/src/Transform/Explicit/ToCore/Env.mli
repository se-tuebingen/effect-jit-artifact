(* Transform/Explicit/ToCore/Env.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Environment of the translation *)
open Common

type t

val empty : Flow.metadata -> t

val add_tvar : t -> 'k S.tvar -> t * 'k T.tvar

val add_tvars : t -> S.TVar.ex list -> t * T.TVar.ex list

(** Same as [add_tvars], but generation of fresh type variables is a
 * responsibility of the user of that function *)
val add_tvars' : t -> S.TVar.ex list -> T.TVar.ex list -> t

val add_effinst : t -> S.effinst -> t * T.effinst

val add_var : t -> S.var -> t * T.var

(** Add variable to the environment. In contrast to [add_var] it does not
 * generate fresh variable, but uses the given one *)
val add_var' : t -> S.var -> T.var -> t

val to_subst : t -> S.subst

val lookup_tvar : t -> 'k S.tvar -> 'k T.tvar
val lookup_inst : t -> S.effinst -> T.effinst
val lookup_var : t -> S.var -> T.var

(** Access to Flow metadata: needed by REPL to properly show input locations
 * in case of error *)
val metadata    : t -> Flow.metadata
val update_meta : t -> Flow.metadata -> t
