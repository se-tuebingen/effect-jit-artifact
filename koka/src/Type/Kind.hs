-----------------------------------------------------------------------------
-- Copyright 2012-2021, Microsoft Research, Daan Leijen.
--
-- This is free software; you can redistribute it and/or modify it under the
-- terms of the Apache License, Version 2.0. A copy of the License can be
-- found in the LICENSE file at the root of this distribution.
-----------------------------------------------------------------------------
module Type.Kind ( HasKind( getKind )
                 , HandledSort(..)
                 , getOperationEffect, getOperationEffectX
                 , isHandledEffect, containsHandledEffect, extractHandledEffect
                 , labelIsLinear
                 , effectIsAffine
                 ) where

import Data.Maybe( isJust )
import Common.NamePrim( nameTpHandled, nameTpHandled1, nameTpNHandled, nameTpNHandled1, nameTpPartial, nameTpScope )
import Common.Failure( failure )
import Kind.Kind
import Type.Type


effectIsAffine :: Effect -> Bool
effectIsAffine eff
  = let (labs,tl) = extractOrderedEffect eff
    in (isEffectEmpty tl && all labelIsAffine labs)


labelIsLinear :: Effect -> Bool
labelIsLinear effect
  = case expandSyn effect of
      TApp (TCon tc) [hx] | (typeConName tc == nameTpHandled1 || typeConName tc == nameTpNHandled1)
        -> True
      TApp (TCon tc) [hx] | typeConName tc /= nameTpHandled && typeConName tc /= nameTpNHandled
        -- allow `alloc<global>` etc.
        -> let k = getKind effect
           in (isKindLabel k || isKindEffect k)
      TCon tc@(TypeCon cname _)  -- builtin effects?
        -> let k = getKind tc
           in (isKindLabel k || isKindEffect k)  -- too liberal? (does not include exn)
      _ -> False

labelIsAffine :: Effect -> Bool
labelIsAffine effect
  = case expandSyn effect of
      TApp (TCon tc) [hx] | (typeConName tc == nameTpHandled1 || typeConName tc == nameTpNHandled1)
        -> True
      TApp (TCon tc) [TCon tcx] | (typeConName tc == nameTpHandled && typeConName tcx == nameTpPartial)
        -- allow exn
        -> True
      TApp (TCon tc) [hx] | typeConName tc /= nameTpHandled && typeConName tc /= nameTpNHandled
        -- allow `alloc<global>` etc.
        -> let k = getKind effect
           in (isKindLabel k || isKindEffect k)
      TCon _   -- builtin effects
        -> True
      _ -> False



-- has effects that are reflected in the evidence vector?
containsHandledEffect :: Effect -> Bool
containsHandledEffect eff
  = {- let (ls,_) = extractEffectExtend eff
    in any (isJust . getHandledEffectX exclude) ls -}
    not $ null $ fst $ extractHandledEffect eff

-- Get the effects that are reflected in the evidence vector
extractHandledEffect :: Type -> ([Type], Tau)
extractHandledEffect eff
  = let (ls,tl) = extractOrderedEffect eff
    in (filter isHandledEffect ls, tl)

-- Is an effect reflected in the evidence vector?
isHandledEffect :: Type -> Bool
isHandledEffect tp -- isJust (getHandledEffect tp)
  = case expandSyn tp of
      TApp (TCon (TypeCon name _)) [t]
        -> (name == nameTpHandled || name == nameTpHandled1)  -- not named effects since these are not in the evidence vector
      _ -> False




data HandledSort = ResumeOnce | ResumeMany
                 deriving (Eq,Show)

-- What effect does an operation have? Used for monadic translation.
-- Note: this includes named effects even though these are not in the evidence vector.
getOperationEffect :: Type -> Maybe (HandledSort,Name)
getOperationEffect tp
  = getOperationEffectX [] tp

getOperationEffectX :: [Name] -> Type -> Maybe (HandledSort,Name)
getOperationEffectX exclude tp
  = case expandSyn tp of
      TApp (TCon (TypeCon name _)) [t]
        | name == nameTpHandled || name == nameTpNHandled   -> getOperationEffectOf ResumeMany exclude t
        | name == nameTpHandled1 || name == nameTpNHandled1 -> getOperationEffectOf ResumeOnce exclude t
        {-
      TApp (TCon (TypeCon hxName _)) _
        | isKindHandled (getKind tp)  && not (hxName `elem` exclude) -> Just (ResumeMany,hxName)
        | isKindHandled1 (getKind tp) && not (hxName `elem` exclude) -> Just (ResumeOnce,hxName)
        -- For named & scoped handlers
        -- TODO: use scope and scope1 to support linear named + scoped effect handlers.
        | hxName == nameTpScope  && not (hxName `elem` exclude) -> Just (ResumeMany,hxName)
      TCon (TypeCon hxName kind)
        | isKindHandled kind  && not (hxName `elem` exclude) -> Just (ResumeMany,hxName)
        | isKindHandled1 kind && not (hxName `elem` exclude) -> Just (ResumeOnce,hxName)
        -}
      _ -> Nothing

getOperationEffectOf hsort exclude tp
  = case expandSyn tp of
      TCon (TypeCon hxName _)           | not (hxName `elem` exclude) -> Just (hsort,hxName)
      TApp (TCon (TypeCon hxName _)) _  | not (hxName `elem` exclude) -> Just (hsort,hxName)
      _ -> Nothing


{--------------------------------------------------------------------------
  Get the kind of a type.
--------------------------------------------------------------------------}
class HasKind a where
  -- | Return the kind of type
  getKind :: a -> Kind


instance HasKind Kind where
  getKind k = k

instance HasKind TypeVar where
  getKind (TypeVar id k _) = k

instance HasKind TypeCon where
  getKind (TypeCon id k) = k


instance HasKind TypeSyn where
  getKind (TypeSyn id k rank _) = k

instance HasKind Type where
  getKind tau
    = case tau of
        TForall _ _ tp -> getKind tp
        TFun _ _ _     -> kindStar
        TVar v         -> getKind v
        TCon c         -> getKind c
        TSyn syn xs tp -> -- getKind tp {- this is wrong for partially applied type synonym arguments, see "kind/alias3" test -}
                          -- if (null xs) then getKind tp else
                          kindApply xs (getKind syn)
        TApp tp args   -> kindApply args (getKind tp)
                          {- case collect [] (getKind tp) of
                            (kres:_) -> kres
                            _  -> failure ("Type.Kind: illegal kind in type application? " ++ show (getKind tp) )
                          -}
    where
      collect :: [Kind] -> Kind -> [Kind]
      collect acc (KApp (KApp arr k1) k2) | arr == kindArrow  = collect (k1:acc) k2
      collect acc k  = k:acc

      kindApply [] k   = k
      kindApply (_:rest) (KApp (KApp arr k1) k2)  = kindApply rest k2
      kindApply args  k  = failure ("Type.Kind.kindApply: illegal kind in application? " ++ show (k) ++ " to " ++ show args
                              ++ "\n  " ++ show tau)
