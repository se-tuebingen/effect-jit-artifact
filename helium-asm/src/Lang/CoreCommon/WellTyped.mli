(* Lang/CoreCommon/WellTyped.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Common parts of internal type-checkers of Core-based languages.
 *
 * The main feature of type-checking in such complex language is treatment
 * of well-formedness of types. During checking well-formedness, type
 * variables and effect-instances are refreshed. Typing environment
 * stores mapping from old to new type variables. Checking of well-formedness
 * is a kind of translation, thus it is very important to use right version
 * of type (before or after the translation). Usual (term) variables do not
 * have to be refreshed. *)

open CoreTypes.Impl
open TypeDef.Impl
open Unit.Impl

(** Exception raised, on internal type error *)
exception Type_error

(** Type checking environments *)
module Env : sig
  type t

  (** Empty environment *)
  val empty : t

  (** Extend environment with type variable. Returns fresh variable, that will
    * be substituted for given one. *)
  val add_tvar : t -> 'k tvar -> t * 'k tvar

  (** Extend environment with multiple type variables at once. *)
  val add_tvars  : t -> TVar.ex list -> t * TVar.ex list
  
  (** [add_tvars2 env xs ys] checks if lists of type variables [xs] and [ys]
    * match with respect to lengths and kinds. If so, it extend environment
    * with type variables [xs] and returns substituion that maps type
    * variables [ys] to freshly generated type variables. If lists [xs] and
    * [ys] do not match, this function raises [Type_error] exception *)
  val add_tvars2 : t -> TVar.ex list -> TVar.ex list -> t * subst

  (** Extend environment with effect instance. Its signature should be provided
   * in the refreshed version *)
  val add_effinst : t -> effinst -> effsig -> t * effinst

  (** Extend environment with variable of given type. The type should be in
   * refreshed form *)
  val add_var  : t -> Common.Var.t -> ttype -> t

  (** Extend environment with multiple variables. If list of variables and
   * list of types have different lenghts, it raises [Type_error] exception. *)
  val add_vars : t -> Common.Var.t list -> ttype list -> t

  (** Get current scope (sets of type variables and effect instances) *)
  val scope : t -> scope

  (** Lookup for effect instance. Returns refreshed version of instance variable
   * as well as its signature (also refreshed) *)
  val lookup_inst : t -> effinst -> effinst * effsig

  (** Checks type of given variable. If variable is not bound, raises
   * [Type_error] *)
  val check_var : t -> Common.Var.t -> ttype
end

(** Refresh and check well-formedness of type *)
val tr_type : Env.t -> 'k typ -> 'k typ

(** Refresh and check well-formedness of constructor declaration *)
val tr_ctor_decl : Env.t -> ctor_decl -> ctor_decl

(** Refresh and check well-formedness of operation declaration *)
val tr_op_decl : Env.t -> op_decl -> op_decl

(** Check if given type arguments match given list of type variables.
 *
 * On success returns substitution that maps given variables to given types.
 * On error raises [Type_error] *)
val check_type_args : Env.t -> TVar.ex list -> type_arg list -> subst

(** Check mutually recursive type definitions *)
val check_typedefs : Env.t -> typedef list -> Env.t

(** Check if given source file is well-typed. Raises [Type_error] on error.
 *
 * As one of parameters it takes function that checks is given expression
 * has given type and effect *)
val check_source_file :
  Env.t ->
  (Env.t -> 'expr -> ttype -> effect -> unit) ->
  'expr source_file_gen ->
    unit
