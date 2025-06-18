-----------------------------------------------------------------------------
-- Copyright 2012-2021, Microsoft Research, Daan Leijen.
--
-- This is free software; you can redistribute it and/or modify it under the
-- terms of the Apache License, Version 2.0. A copy of the License can be
-- found in the LICENSE file at the root of this distribution.
-----------------------------------------------------------------------------
{-
    Maps from identifiers to values.
-}
-----------------------------------------------------------------------------
module Common.IdMap
          ( IdMap, module Data.IntMap.Strict
          ) where

import Data.IntMap.Strict

----------------------------------------------------------------
-- Types
----------------------------------------------------------------
-- | A map from identifiers to values
type IdMap a = IntMap a
