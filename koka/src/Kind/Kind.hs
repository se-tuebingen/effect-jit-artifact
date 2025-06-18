------------------------------------------------------------------------------
-- Copyright 2012-2021, Microsoft Research, Daan Leijen.
--
-- This is free software; you can redistribute it and/or modify it under the
-- terms of the Apache License, Version 2.0. A copy of the License can be
-- found in the LICENSE file at the root of this distribution.
-----------------------------------------------------------------------------
{-
    Definition of kinds and helper functions.
-}
-----------------------------------------------------------------------------
module Kind.Kind( -- * Kinds
                    Kind(..)
                  , KindCon
                 -- * Standard kinds
                  , kindStar, kindPred, kindEffect, kindArrow, kindScope, kindHeap
                  , kindHandled, kindHandled1, kindLocal
                  , kindFun, kindLabel, extractKindFun, kindFunN
                  , builtinKinds
                  , kindCon, kindConOver
                  , isKindFun
                  , isKindStar
                  , isKindEffect, isKindHandled, isKindHandled1, isKindScope, isKindHeap
                  , isKindLabel, isKindAnyLabel
                  , hasKindStarResult, hasKindLabelResult
                  , kindAddArg
                  ) where

import Common.Name
import Common.NamePrim

{--------------------------------------------------------------------------
  Kinds
--------------------------------------------------------------------------}
-- | Kinds
data Kind
  = KCon     !KindCon        -- ^ Kind constants: "*","->","!","H","P"
  | KApp     !Kind !Kind      -- ^ Application (only allowed for functions as yet)
  deriving (Eq,Ord, Show)

-- | Kind constant
type KindCon  = Name

-- | Kind and Type variables come in three flavours: 'Unifiable'
-- variables can be unified, 'Skolem's are non-unifiable (fresh)
-- variables, and 'Bound' variables are bound by a quantifier.
data Flavour  = Bound
              | Skolem
              | Meta    -- used for pretty printing
              deriving(Eq, Show)

hasKindStarResult :: Kind -> Bool
hasKindStarResult kind
  = isKindStar (snd (extractKindFun kind))

hasKindLabelResult :: Kind -> Bool
hasKindLabelResult kind
  = isKindAnyLabel (snd (extractKindFun kind))


{--------------------------------------------------------------------------
  Standard kinds
--------------------------------------------------------------------------}
-- | Kind @V@ (or "*")
kindStar :: Kind
kindStar
  = KCon nameKindStar

-- | Kind @X@, atomic effects
kindLabel :: Kind
kindLabel
  = KCon nameKindLabel

-- | Kind arrow @->@
kindArrow :: Kind
kindArrow
  = KCon nameKindFun

kindAddArg :: Kind -> Kind -> Kind
kindAddArg kfun karg
  = case kfun of
      KApp (KApp k0 k1) k2  | k0 == kindArrow && not (isKindEffect k1 && isKindStar k2)
        -> KApp (KApp k0 k1) (kindAddArg k1 karg)
      _ -> kindFun karg kfun

kindPred :: Kind
kindPred
  = KCon nameKindPred

-- Effect row E
kindEffect :: Kind
kindEffect
  = KCon nameKindEffect

kindScope :: Kind
kindScope
  = KCon nameKindScope

kindHeap :: Kind
kindHeap
  = KCon nameKindHeap

kindLocal :: Kind
kindLocal
  = kindFun kindHeap kindLabel

-- user defined effects: (E,V) -> V
kindHandled :: Kind
kindHandled
  = kindFun kindEffect (kindFun kindStar kindStar) -- KCon nameKindHandled

-- (used defined) linear effects: (E,V) -> V
kindHandled1 :: Kind
kindHandled1
  = kindHandled -- KCon nameKindHandled1

-- Effect extension (X,E) -> E
kindExtend :: Kind
kindExtend
  = kindFun kindLabel (kindFun kindEffect kindEffect)

-- | Kind constructor N from n kind star to kind star
kindCon :: Int -> Kind
kindCon n
  = kindConOver (replicate n kindStar)

kindConOver kinds
  = foldr kindFun kindStar kinds


kindFunN :: [Kind] -> Kind -> Kind
kindFunN kinds kind
  = foldr kindFun kind kinds

-- | Create a (kind) function from a kind to another kind.
kindFun :: Kind -> Kind -> Kind
kindFun k1 k2
  = KApp (KApp kindArrow k1) k2

isKindFun :: Kind -> Bool
isKindFun k
  = case k of
      KApp (KApp k0 k1) k2  -> k0 == kindArrow
      _ -> False


extractKindFun :: Kind -> ([Kind],Kind)
extractKindFun k
  = case k of
      KApp (KApp k0 k1) k2 | k0 == kindArrow
        -> let (args,res) = extractKindFun k2
           in (k1:args,res)
      _ -> ([],k)

isKindStar, isKindLabel, isKindEffect, isKindHandled, isKindScope, isKindHeap :: Kind -> Bool
isKindStar k
  = k == kindStar

isKindEffect k
  = k == kindEffect

isKindLabel k
  = k == kindLabel

isKindScope k
  = k == kindScope

isKindHeap k
  = k == kindHeap

isKindHandled1 k
  = isKindHandled k -- k == kindHandled1

isKindHandled k
  = -- k == kindHandled
    case extractKindFun k of
      ([k1,k2],k3) -> isKindEffect k1 && isKindStar k2 && isKindStar k3
      _            -> False




isKindAnyLabel :: Kind -> Bool
isKindAnyLabel k
  = isKindHandled k || isKindHandled1 k || isKindLabel k

-- | Standard kind constants with their kind.
builtinKinds :: [(Name,Kind)]
builtinKinds
  = [(nameKindStar, kindStar)
    ,(nameKindFun, kindArrow)
    ,(nameKindPred, kindPred)
    ,(nameKindEffect, kindEffect)
    ,(nameKindLabel, kindLabel)
    ,(nameKindHeap, kindHeap)
    ,(nameKindScope, kindScope)
    -- ,(nameKindHandled, kindHandled)
    -- ,(nameKindHandled1, kindHandled1)
    ]
