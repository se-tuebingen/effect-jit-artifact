(* Lang/CoreCommon/Subst.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Basic operations on type substitutions of types and instances.
 *
 * This is internal module that implements part of an interface exposed by
 * CoreTypes.Impl module *)

open TypingStructure

let empty =
  { sub_type = TVar.Map.empty
  ; sub_inst = EffInst.Map.empty
  }

let singleton_t x tp =
  { sub_type = TVar.Map.singleton x (TKV(x, tp))
  ; sub_inst = EffInst.Map.empty
  }

let singleton_i a b =
  { sub_type = TVar.Map.empty
  ; sub_inst = EffInst.Map.singleton a b
  }

let add_type sub x tp =
  { sub with
    sub_type = TVar.Map.add x (TKV(x, tp)) sub.sub_type
  }

let add_tvars sub xs =
  Utils.ListExt.fold_map (fun sub (TVar.Pack x) ->
      let y = TVar.clone x in
      (add_type sub x (TyNeutral (TVar y)), TVar.Pack y)
    ) sub xs

let add_inst sub a b =
  { sub with
    sub_inst = EffInst.Map.add a b sub.sub_inst
  }

let lookup_type (type k) sub (x : k tvar) : k typ =
  match TVar.Map.find_opt x sub.sub_type with
  | Some (TKV(y, tp)) ->
    begin match TVar.gequal x y with
    | Equal    -> tp
    | NotEqual -> assert false
    end
  | None -> TyNeutral (TVar x)

let lookup_inst sub a =
  match EffInst.Map.find_opt a sub.sub_inst with
  | Some a -> a
  | None   -> a
