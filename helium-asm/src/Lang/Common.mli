
type 'k tvar
type effinst
type var

module type TVar_S = sig
  include Kind.KindedVar_S with type 'k t = 'k tvar
end
module TVar : TVar_S

module type EffInst_S = sig
  type t = effinst

  val compare : t -> t -> int
  val equal   : t -> t -> bool
  val fresh   : unit -> t
  val clone   : t -> t

  val to_string : t -> string
  module Map : Map.S with type key = t
  module Set : Set.S with type elt = t
end
module EffInst : EffInst_S

module type Var_S = sig
  type t = var

  val fresh : unit -> t
  val to_string : t -> string
  module Map : Map.S with type key = t
end
module Var : Var_S

type source_level =
| SL_User
| SL_Lib
| SL_Prelude
