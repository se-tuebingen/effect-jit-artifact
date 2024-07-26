(* Lang/CoreCommon/Unit.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Representation of translation units *)

open CoreTypes.Impl

module type S = sig
  (** Description of imported module *)
  type import =
    (** Name of imported module *)
    { im_name   : string
    (** Path to imported file *)
    ; im_path   : string
    (** Level (see Common.source_level) *)
    ; im_level  : Common.source_level
    (** Variable, that contains imported module. Import is a variable binder *)
    ; im_var    : Common.var
    (** Existential types introduced (bound) by this module import *)
    ; im_types  : TVar.ex list
    (** Effects that imported module handles (by e.g. let handle construct) *)
    ; im_handle : effect
    (** Signature of the import. Type of the im_var variable is a tuple of these
      * types *)
    ; im_sig    : ttype list
    }

  (** Body of translation unit *)
  type 'expr unit_body_gen =
  (** Direct-style body -- it cannot handle any effects.
   *
   * Type of [body] should be ∃ α₁ … αₙ, Tuple (τ₁ … τₖ), where
   * - α₁ … αₙ are type variables introduced by this module ([types] field)
   * - τ₁ … τₖ are types of the contents of the module ([body_sig] field) *)
  | UB_Direct of
    { types    : TVar.ex list
    ; body_sig : ttype list
    ; body     : 'expr
    }
  (** Continuation-passing-style body -- it may handle some effects ([handle]
   * field) and assume existence of other handlers ([ambient_eff] field).
   *
   * Type of [body] should be
   *   ∀ βₜ βₑ, (∀ α₁ … αₙ, Tuple (τ₁ … τₖ) →[βₑ · εₐ · εₕ] βₜ) →[βₑ · εₐ] βₜ
   * where
   * - βₜ and βₑ are answer type and effect, and are freshly generated type
   *   variables
   * - α₁ … αₙ are type variables introduced by this module ([types] field)
   * - τ₁ … τₖ are types of the contents of the module ([body_sig] field)
   * - εₐ is an ambient effect ([ambient_eff] field)
   * - εₕ is an effect handled by this module ([handle] field) *)
  | UB_CPS of
    { ambient_eff : effect
    ; types       : TVar.ex list
    ; handle      : effect
    ; body_sig    : ttype list
    ; body        : 'expr
    }

  (** Complete translation unit *)
  type 'expr source_file_gen =
    (** Imported modules *)
    { sf_import : import list
    (** Body of the unit *)
    ; sf_body   : 'expr unit_body_gen
    }
end

module Impl : S = struct
  type import =
    { im_name   : string
    ; im_path   : string
    ; im_level  : Common.source_level
    ; im_var    : Common.var
    ; im_types  : TVar.ex list
    ; im_handle : effect
    ; im_sig    : ttype list
    }

  type 'expr unit_body_gen =
  | UB_Direct of
    { types    : TVar.ex list
    ; body_sig : ttype list
    ; body     : 'expr
    }
  | UB_CPS of
    { ambient_eff : effect
    ; types       : TVar.ex list
    ; handle      : effect
    ; body_sig    : ttype list
    ; body        : 'expr
    }

  type 'expr source_file_gen =
    { sf_import : import list
    ; sf_body   : 'expr unit_body_gen
    }
end

module type Export = S
  with type import = Impl.import
  and  type 'expr unit_body_gen   = 'expr Impl.unit_body_gen
  and  type 'expr source_file_gen = 'expr Impl.source_file_gen
