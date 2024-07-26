(* Lang/CoreCommon/TypeDef.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** ADT definitions used by Core and Explicit languages *)

open CoreTypes.Impl

module type S = sig
  type typedef =
  | TypeDef : 'k tvar * Common.var * ttype -> typedef
end

module Impl : S = struct
  type typedef =
  | TypeDef : 'k tvar * Common.var * ttype -> typedef
end

module type Export = S
  with type typedef = Impl.typedef
