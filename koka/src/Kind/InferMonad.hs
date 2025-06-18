------------------------------------------------------------------------------
-- Copyright 2012-2021, Microsoft Research, Daan Leijen.
--
-- This is free software; you can redistribute it and/or modify it under the
-- terms of the Apache License, Version 2.0. A copy of the License can be
-- found in the LICENSE file at the root of this distribution.
-----------------------------------------------------------------------------
{--}
-----------------------------------------------------------------------------
module Kind.InferMonad( KInfer
                      , runKindInfer
                      , addError, addWarning
                      , freshKind,freshTypeVar,subst
                      , getKGamma
                      , addSynonym
                      , getSynonyms, getAllNewtypes, getPlatform
                      , extendInfGamma, extendKGamma, extendKSub
                      , findInfKind
                      , getColorScheme
                      , lookupSynInfo, lookupDataInfo
                      , qualifyDef
                      , addRangeInfo
                      , infQualifiedName
                      , checkExternal
                      )  where


import Control.Applicative
import Control.Monad

import Lib.Trace
import Lib.PPrint
import Common.Failure( failure )
import Common.Range
import Common.Syntax( Platform )
import Common.ColorScheme
import Common.Unique
import Common.Name
import Common.QNameMap( Lookup(..) )

import qualified Common.NameMap as M

import Kind.Kind
import Kind.InferKind
import Kind.Assumption
import Kind.Synonym
import Kind.Newtypes
import Kind.ImportMap

import Syntax.Syntax
import Type.Type

import Syntax.RangeMap

import qualified Core.Core as Core

{---------------------------------------------------------------
  Inference monad
---------------------------------------------------------------}

data KInfer a = KInfer (KEnv -> KSt -> KResult a)

data KSt        = KSt{ kunique :: !Int, ksub :: !KSub, mbRangeMap :: Maybe RangeMap, localSyns:: !Synonyms, externals :: M.NameMap Range }
data KEnv       = KEnv{ cscheme :: !ColorScheme, platform :: !Platform, currentModule :: !Name, imports :: ImportMap
                      , kgamma :: !KGamma, infgamma :: !InfKGamma, synonyms :: !Synonyms
                      , newtypesImported :: !Newtypes, newtypesExtended :: !Newtypes
                      }
data KResult a  = KResult{ result:: !a, errors:: ![(Range,Doc)], warnings :: ![(Range,Doc)], st :: !KSt }

runKindInfer :: ColorScheme -> Platform -> Maybe RangeMap -> Name -> ImportMap -> KGamma -> Synonyms -> Newtypes -> Int -> KInfer a -> ([(Range,Doc)],[(Range,Doc)],Maybe RangeMap,Int,a)
runKindInfer cscheme platform mbRangeMap moduleName imports kgamma syns datas unique (KInfer ki)
  = let imports' = case importsExtend ({-toShortModuleName-} moduleName) moduleName imports of
                     Just imp -> imp
                     Nothing  -> imports -- ignore
    in -- trace ("Kind.InferMonad.runKindInfer: current module: " ++ show moduleName) $
       case ki (KEnv cscheme platform moduleName imports' kgamma M.empty syns datas newtypesEmpty) (KSt unique ksubEmpty mbRangeMap synonymsEmpty M.empty) of
         KResult x errs warns (KSt unique1 ksub rm _ _) -> (errs,warns,rm,unique1,x)


instance Functor KInfer where
  fmap f (KInfer ki)
    = KInfer (\env -> \st -> let r = ki env st in r{ result = f (result r) })

instance Applicative KInfer where
  pure x  = KInfer (\env -> \st -> KResult x [] [] st)
  (<*>)   = ap

instance Monad KInfer where
  -- return = pure
  (KInfer ki) >>= f
    = KInfer (\env -> \st ->
        case ki env st of
          KResult x errs1 warns1 st1
            -> case f x of
                 KInfer kif
                  -> case kif env st1 of
                       KResult y errs2 warns2 st2 -> KResult y (errs1++errs2) (warns1 ++ warns2) st2)

instance HasUnique KInfer where
  updateUnique f
    = KInfer (\env -> \st -> KResult (kunique st) [] [] (st{ kunique = f (kunique st) }))

getKindEnv :: KInfer KEnv
getKindEnv
  = KInfer (\env -> \st -> KResult env [] [] st)

addError :: Range -> Doc -> KInfer ()
addError range doc
  = do addRangeInfo range (Error doc)
       KInfer (\env -> \st -> KResult () [(range,doc)] [] st)

addWarning :: Range -> Doc -> KInfer ()
addWarning range doc
  = do addRangeInfo range (Warning doc)
       KInfer (\env -> \st -> KResult () [] [(range,doc)] st)

getKSub :: KInfer KSub
getKSub
  = KInfer (\env -> \st -> KResult (ksub st) [] [] st)

extendKSub :: KSub -> KInfer ()
extendKSub sub
  = KInfer (\env -> \st -> KResult () [] [] st{ ksub = sub @@ ksub st })

getLocalSynonyms :: KInfer Synonyms
getLocalSynonyms
  = KInfer (\env -> \st -> KResult (localSyns st) [] [] st)

addSynonym :: SynInfo -> KInfer ()
addSynonym synInfo
  = KInfer (\env -> \st -> KResult () [] [] st{ localSyns = synonymsExtend synInfo (localSyns st) })

addRangeInfo :: Range -> RangeInfo -> KInfer ()
addRangeInfo range info
  = KInfer (\env -> \st -> KResult () [] [] st{ mbRangeMap = case (mbRangeMap st) of
                                                              Just rm -> Just (rangeMapInsert range info rm)
                                                              other   -> other
                                             })

addExternal :: Name -> Range -> KInfer ()
addExternal name range
  = KInfer (\env -> \st -> KResult () [] [] st{ externals = M.insert name range (externals st) })

lookupExternal :: Name -> KInfer (Maybe Range)
lookupExternal name
  = KInfer (\env -> \st -> KResult (M.lookup name (externals st)) [] [] st)

{---------------------------------------------------------------
  Operations
---------------------------------------------------------------}
freshKind :: KInfer InfKind
freshKind
  = do id <- uniqueId "k"
       return (KIVar id)


freshTypeVar :: TypeBinder Kind -> Flavour -> KInfer TypeVar
freshTypeVar (TypeBinder name kind _ _) flavour
  = do id <- uniqueId (show name)
       return (TypeVar id kind flavour)


subst :: HasKindVar k => k -> KInfer k
subst x
  = do sub <- getKSub
       return (sub |=> x)

getKGamma :: KInfer KGamma
getKGamma
  = do env <- getKindEnv
       return (kgamma env)

getSynonyms :: KInfer Synonyms
getSynonyms
  = do env <- getKindEnv
       syns <- getLocalSynonyms
       return (synonymsCompose syns (synonyms env))

getAllNewtypes :: KInfer Newtypes
getAllNewtypes
 = do env <- getKindEnv  -- assume right-biased union
      return (newtypesCompose  (newtypesImported env) (newtypesExtended env))

getColorScheme :: KInfer ColorScheme
getColorScheme
  = do env <- getKindEnv
       return (cscheme env)

getPlatform :: KInfer Platform
getPlatform
 = do env <- getKindEnv
      return (platform env)

-- | Extend the inference kind assumption; checks for 'shadow' definitions
extendInfGamma :: [TypeBinder InfKind] -> KInfer a -> KInfer a
extendInfGamma tbinders ki
  = do env <- getKindEnv
       foldM check (infgamma env) tbinders
       extendInfGammaUnsafe tbinders ki
  where
    check :: InfKGamma -> TypeBinder InfKind -> KInfer InfKGamma
    check infgamma (TypeBinder name infkind nameRange range)
      = case M.lookup name infgamma of
          Nothing -> return (M.insert name infkind infgamma)
          Just _  -> do env <- getKindEnv
                        let cs = cscheme env
                        addError nameRange $ text "Type" <+> ppType cs name <+> text "is already defined"
                        return (M.insert name infkind infgamma) -- replace


extendInfGammaUnsafe :: [TypeBinder InfKind] -> KInfer a -> KInfer a
extendInfGammaUnsafe tbinders (KInfer ki)
  -- ASSUME: assumes left-biased union
  = -- trace ("Kind.extendInfGammaUnsafe: " ++ show bindMap) $
    KInfer (\env -> \st -> ki (env{ infgamma = M.union infGamma (infgamma env) }) st)
  where
    infGamma = M.fromList bindMap
    bindMap  = map (\(TypeBinder name infkind _ _) -> (name,infkind)) tbinders


-- | Extend the kind assumption; checks for duplicate definitions
extendKGamma :: [Range] -> Core.TypeDefGroup -> KInfer a -> KInfer a
extendKGamma ranges (Core.TypeDefGroup (tdefs)) ki
  -- = extendKGammaUnsafe tdefs ki
  -- NOTE: duplication check already happens in extendInfGamma but
  -- there can still be a clash with a definition in another inference group
  = do env     <- getKindEnv
       (_,tdefs')  <- foldM check (kgamma env,[])  (zip ranges tdefs)
       extendKGammaUnsafe (reverse tdefs') ki
  where
    check :: (KGamma,[Core.TypeDef]) -> (Range,Core.TypeDef) -> KInfer (KGamma,[Core.TypeDef])
    check (kgamma,tdefs) (range,tdef)
      = if (Core.typeDefIsExtension tdef) then return (kgamma,tdefs)
         else do let (name,kind,doc) = nameKind tdef
                 -- trace("extend kgamma: " ++ show (name)) $
                 case kgammaLookupQ name kgamma of
                   Nothing -> return (kgammaExtend name kind doc kgamma,tdef:tdefs)
                   Just _  -> do env <- getKindEnv
                                 addError range $ text "Type" <+> ppType (cscheme env) name <+>
                                                  text "is already defined"
                                 return (kgamma,tdefs)
      where
        nameKind (Core.Synonym synInfo) = (synInfoName synInfo, synInfoKind synInfo, synInfoDoc synInfo)
        nameKind (Core.Data dataInfo isExtend)   = (dataInfoName dataInfo, dataInfoKind dataInfo, dataInfoDoc dataInfo)


-- | This extend KGamma does not check for duplicates
extendKGammaUnsafe :: [Core.TypeDef] -> KInfer a -> KInfer a
extendKGammaUnsafe (tdefs) (KInfer ki)
  -- ASSUME: kgamma and synonyms have a right-biased union
  = KInfer (\env -> \st -> ki (env{ kgamma = -- trace ("extend kgamma:\n" ++ show (kgamma env) ++ "\n with\n " ++ show (kGamma)) $
                                             kgammaUnion (kgamma env) kGamma
                                  , synonyms = synonymsCompose (synonyms env) kSyns
                                  , newtypesExtended = newtypesCompose (newtypesExtended env) kNewtypes }) st)
  where
    kGamma = kgammaNewNub (map nameKind tdefs) -- duplicates are removed here
    nameKind (Core.Synonym synInfo) = (synInfoName synInfo, synInfoKind synInfo, synInfoDoc synInfo)
    nameKind (Core.Data dataInfo isExtend)   = (dataInfoName dataInfo, dataInfoKind dataInfo, dataInfoDoc dataInfo)


    kSyns  = synonymsNew (concatMap nameSyn tdefs)
    nameSyn (Core.Synonym synInfo ) = [synInfo]
    nameSyn _                       = []

    kNewtypes  = newtypesNew (concatMap nameNewtype tdefs)
    nameNewtype (Core.Data dataInfo _ )   = [dataInfo]
    nameNewtype _                         = []

checkExternal :: Name -> Range -> KInfer ()
checkExternal name range
  = do mbRes <- lookupExternal name
       case mbRes of
         Just range0 -> do env <- getKindEnv
                           let cs = cscheme env
                           addError range (text "external" <+> prettyName cs name <+> text "is already defined at" <+> text (show (rangeStart range0))
                                           <-> text "hint: use a local qualifier?")
                           return ()
         Nothing     -> addExternal name range



infQualifiedName :: Name -> Range -> KInfer Name
infQualifiedName name range  | not (isQualified name)
  = return name
infQualifiedName name range
  = do env <- getKindEnv
       case importsExpand name (imports env) of
         Right (name',alias)
          -> if (not (nameCaseEqualPrefixOf alias (qualifier name)))
              then do let cs = cscheme env
                      addError range (text "module" <+> ppModule cs name <+> text "should be cased as" <+> color (colorModule cs) (pretty alias)
                                       -- <+> text (showPlain name ++ ", " ++ showPlain alias)
                                    )
                      return name'
              else return name'
         Left []
          -> do let cs = cscheme env
                addError range (text "module" <+> ppModule cs name <+> text "is undefined")
                return name
         Left aliases
          -> do let cs = cscheme env
                addError range (text "module" <+> ppModule cs name <+> ambiguous cs aliases)
                return name

ppModule cs name
  = color (colorModule cs) (text (nameModule name))

findInfKind :: Name -> Range -> KInfer (Name,InfKind,String)
findInfKind name0 range
  = do env <- getKindEnv
       let (name,mbAlias) = case importsExpand name0 (imports env) of
                              Right (name',alias) -> (name',Just alias)
                              _                   -> (name0,Nothing)
           qname          = if isQualified name then name else qualify (currentModule env) name
       -- lookup locally
       -- note: also lookup qualified since it might be recursive definition
       -- todo: check for the locally inferred names for casing too.
       -- trace("find: " ++ show (name,qname) ++ ": " ++ show (M.elems (infgamma env))) $ return ()
       case M.lookup name (infgamma env)  of
         Just infkind -> return (name,infkind,"")
         Nothing ->
           case M.lookup qname (infgamma env) of
             Just infkind -> return (qname,infkind,"")
             Nothing
                 -> case kgammaLookup (currentModule env) name (kgamma env) of
                      Found qname (kind,doc)
                                       -> do let name' = if isQualified name then qname else (unqualify qname)
                                             if (-- trace ("compare: " ++ show (qname,name,name0)) $
                                                 not (nameCaseEqual name' name))
                                              then do let cs = cscheme env
                                                      addError range (text "type" <+> (ppType cs (unqualify name0)) <+> text "should be cased as" <+> ppType cs (unqualify name'))
                                              else return ()
                                             case mbAlias of
                                              Just alias | nameModule name0 /= nameModule alias
                                                -> do let cs = cscheme env
                                                      addError range (text "module" <+> color (colorModule cs) (text (nameModule name0)) <+> text "should be cased as" <+> color (colorModule cs) (pretty alias)
                                                         -- <+> text (show (name,qname,mbAlias,name0))
                                                         -- <+> text ( nameModule name0 ++ ", " ++ showPlain alias)
                                                         )
                                              _ -> return ()
                                             return (qname,KICon kind, doc)
                      NotFound         -> do let cs = cscheme env
                                             -- trace ("cannot find type: " ++ show name ++ ", " ++ show (currentModule env) ++ ", " ++ show (kgamma env)) $
                                             addError range (text "Type" <+> (ppType cs name) <+> text "is not defined" <->
                                                             text " hint: bind the variable using" <+> color (colorType cs) (text "forall<" <.> ppType cs name <.> text ">") <+> text "?")
                                             k <- freshKind
                                             return (name,k,"")
                      Ambiguous names  -> do let cs = cscheme env
                                             addError range (text "Type" <+> ppType cs name <+> ambiguous cs names)
                                             k <- freshKind
                                             return (name,k,"")

ambiguous :: ColorScheme -> [Name] -> Doc
ambiguous cs [name1,name2]
  = text "is ambiguous." <-> text " hint: It can refer to either" <+> ppType cs name1 <.> text ", or" <+> ppType cs name2
ambiguous cs [name1,name2,name3]
  = text "is ambiguous." <-> text " hint: It can refer to either" <+> ppType cs name1 <.> text "," <+> ppType cs name2 <.> text ", or" <+> ppType cs name3
ambiguous cs [name]
  = text "should be cased as:" <+> ppType cs (unqualify name)
ambiguous cs names
  = text "is ambiguous and can refer to multiple imports:" <-> indent 1 (list (map (ppType cs) names))

ppType cs name
  = color (colorType cs) (pretty name)

qualifyDef :: Name -> KInfer Name
qualifyDef name
  = do env <- getKindEnv
       return (qualify (currentModule env) name)

findKind :: Name -> KInfer (Name,Kind,String)
findKind name
  = do env <- getKindEnv
       case kgammaLookup (currentModule env) name (kgamma env) of
        Found qname (kind,doc) -> return (qname,kind,doc)
        _  -> failure ("Kind.Infer.findKind: unknown type constructor: " ++ show name)

lookupSynInfo :: Name -> KInfer (Maybe SynInfo)
lookupSynInfo name
  = do env <- getKindEnv
       localSyns <- getLocalSynonyms
       case synonymsLookup name localSyns of
         Just x -> return (Just x)
         Nothing -> return (synonymsLookup name (synonyms env))

lookupDataInfo :: Name -> KInfer (Maybe DataInfo)
lookupDataInfo name
 = do env <- getKindEnv
      case (newtypesLookupAny name (newtypesExtended env)) of
        Nothing -> return (newtypesLookupAny name (newtypesImported env))
        just    -> return just
