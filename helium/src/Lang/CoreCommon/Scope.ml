(* Lang/CoreCommon/Scope.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)

open TypingStructure

type t =
  { types : unit TVar.Map.t
  ; insts : EffInst.Set.t
  }

let empty =
  { types = TVar.Map.empty
  ; insts = EffInst.Set.empty
  }

let add_tvar scope x =
  { scope with
    types = TVar.Map.add x () scope.types
  }

let add_tvars scope xs =
  List.fold_left (fun scope (TVar.Pack x) -> add_tvar scope x) scope xs

let add_effinst scope a =
  { scope with
    insts = EffInst.Set.add a scope.insts
  }

let has_tvar scope x =
  TVar.Map.mem x scope.types

let has_effinst scope a =
  EffInst.Set.mem a scope.insts
