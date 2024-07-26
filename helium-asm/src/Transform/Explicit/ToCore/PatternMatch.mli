(* Transform/Explicit/ToCore/PatternMatch.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Translation of deep pattern-matching *)

open Common

(** Translation deep pattern-matching.
 *
 * [tr_match ~env ~uid ~typ ~bind_value x cls] translates matching of
 * variable [x] againts clauses cls. Each clause is a pair of pattern
 * and function that produce en expression when provided with environment.
 * [bind_value] should be a function [bind_value] from the [Expr] module,
 * that translates Explicit values. Finally, [typ] is the type of the whole
 * expression *)
val tr_match : 
  env: Env.t ->
  uid: Utils.UID.t ->
  typ: T.ttype ->
  bind_value: (Env.t -> S.value -> (T.value -> T.expr) -> T.expr) ->
  T.var -> (S.pattern * (Env.t -> T.expr)) list ->
    T.expr

(** Translation of deep pattern-matching of several patterns at once *)
val tr_matches :
  uid: Utils.UID.t ->
  typ: T.ttype ->
  bind_value: (Env.t -> S.value -> (T.value -> T.expr) -> T.expr) ->
  case_name: string ->
  T.var list -> (Env.t * S.pattern list * (Env.t -> T.expr)) list ->
    T.expr
