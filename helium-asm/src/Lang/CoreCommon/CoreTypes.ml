(* Lang/CoreCommon/CoreTypes.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Types used by Core and Explicit languages *)
open Kind

module type S = sig
  module TVar    : Common.TVar_S
  module EffInst : Common.EffInst_S

  (** Type variables *)
  type 'k tvar = 'k Common.tvar

  (** Effect instances *)
  type effinst = Common.effinst

  (** Types, parametrized by its kind *)
  type 'k typ

  (** Aliases for types of base kinds *)
  type ttype  = ktype typ
  type effect = keffect typ
  type effsig = keffsig typ

  (** Substitutions of types and instances *)
  type subst

  (** Scope of the type, i.e., available type variable and effect instances *)
  type scope

  (** Type parameter, used by type application on the level of expresions.
   * It must be an existential GADT, since the kind of the type cannot be
   * staticly known -- we use OCaml type system, to express only kind-system,
   * but not a Helium type-system itself *)
  type type_arg =
  | TpArg : 'k typ -> type_arg

  (** Id of future type (for comparing them) *)
  type 'k type_future_id =
  | TFIdType   : Utils.UID.t -> ktype   type_future_id
  | TFIdEffect : Utils.UID.t -> keffect type_future_id
  | TFIdEffsig : Utils.UID.t -> keffsig type_future_id

  (** Types, that may be not instantiated yet.
   *
   * Such types may appear as a result of translation unification variables
   * in REPL *)
  type 'k type_future =
  | TFType   of 'k typ
  | TFFuture of 'k type_future_id * type_arg list * effinst list

  (** Neutral types, i.e., type variables applied to some arguments *)
  type 'k neutral_type =
  | TVar of 'k tvar
  | TApp : ('k1 -> 'k2) neutral_type * 'k1 typ -> 'k2 neutral_type

  (** Constructors of ADT
   *
   * [CtorDecl(name, tvars, tps)] is a constructor of name [name],
   * it binds existential types [tvars], that are bound in its
   * arguments, of types [tps]. *)
  type ctor_decl =
  | CtorDecl of string * TVar.ex list * ttype list

  (** Field of a record (name + type) *)
  type field_decl =
  | FieldDecl of string * ttype

  (** Operation of algebraic effect.
   *
   * [OpDecl(name, tvars, tps, tp)] is possibly polymorphic operation
   * of name [name], polymorphic in [tvars], which takes arguments of types
   * [tps] and returns [tp]. [tvars] is bound in [tps] and [tp]. *)
  type op_decl =
  | OpDecl of string * TVar.ex list * ttype list * ttype

  (** View of type.
   * As types, it uses GADT to encode kinds *)
  type 'k type_view =
  (** Pure effect *)
  | TEffPure    : keffect type_view
  (** Union of two effects *)
  | TEffCons    : effect * effect -> keffect type_view
  (** Single instance as an effect *)
  | TEffInst    : effinst -> keffect type_view
  (** Base type *)
  | TBase       : RichBaseType.t -> ktype type_view
  (** Neutral type, i.e., type variable applied to some arguments *)
  | TNeutral    : 'k neutral_type -> 'k type_view
  (** Type of tuple *)
  | TTuple      : ttype list -> ktype type_view
  (** Function type *)
  | TArrow      : ttype * ttype * effect -> ktype type_view
  (** Polymorphic type *)
  | TForall     : 'k tvar * ttype -> ktype type_view
  (** Existential type (used by a translation of a module system) *)
  | TExists     : 'k tvar * ttype -> ktype type_view
  (** Instance-polymorphic type *)
  | TForallInst : effinst * effsig * ttype -> ktype type_view
  (** Type of witnesses of algebraic data types.
    *
    * Such witnesses do not contain any computationally usefull content,
    * but existance of such elements (of type [TDataDef(tp, ctors)]) proves
    * that type [tp] is an ADT with constructors described by [ctors].
    * Operations on given ADT, like constructors or pattern-matching must
    * provide such a witness. The only way to produce such a witness is
    * by data-definition language construact which introduses fresh type
    * variable together with witness for it.
    *
    * This approach simplifies many things related to ADT. For instance,
    * the structure of types does not have to be aware of recursive types.
    * Recursive ADT is just ADT which witness has type [TDataDef(tp, ctors)],
    * where [ctors] use [tp]. *)
  | TDataDef    : ttype * ctor_decl list -> ktype type_view
  (** Same as [TDataDef], but for records. *)
  | TRecordDef  : ttype * field_decl list -> ktype type_view
  (** Same as [TDataDef], but for effect signatures.
    *
    * Note that witnesses are first-class citizens and they have types,
    * so the type of a witness has kind [ktype], even if witness describes
    * effect signature *)
  | TEffsigDef  : effsig * op_decl list -> ktype type_view
  (** Functions on level of types *)
  | TFun        : 'k1 tvar * 'k2 typ -> ('k1 -> 'k2) type_view
  (** Type that is not known yet.
    *
    * They may appear in REPL as a result of translation of not instatiated
    * unification variables *)
  | TFuture     :
    { uid    : Utils.UID.t
    ; tholes : type_arg list 
    ; eholes : effinst list 
    ; future : (unit -> 'k type_future)
    ; subst  : subst
    } -> 'k type_view

  (** Operations on types *)
  module Type : sig
    (** Exception raised by scope-checking functions, when something escapes
     * its scope *)
    exception Escapes_scope

    (** Smart constructors *)
    val base        : RichBaseType.t -> ttype
    val var         : 'k tvar -> 'k typ
    val neutral     : 'k neutral_type -> 'k typ
    val tuple       : ttype list -> ttype
    val arrow       : ttype -> ttype -> effect -> ttype
    val forall      : 'k tvar -> ttype -> ttype
    val exists      : 'k tvar -> ttype -> ttype
    val forall_inst : effinst -> effsig -> ttype -> ttype

    val eff_pure : effect
    val eff_cons : effect -> effect -> effect
    val eff_inst : effinst -> effect

    val data_def   : ttype -> ctor_decl list -> ttype
    val record_def : ttype -> field_decl list -> ttype
    val effsig_def : effsig -> op_decl list -> ttype

    val arrow_l      : ttype list -> ttype -> effect -> ttype
    val arrow_l_pure : ttype list -> ttype -> ttype

    val forall_l : TVar.ex list -> ttype -> ttype
    val exists_l : TVar.ex list -> ttype -> ttype

    val tfun : 'k1 tvar -> 'k2 typ -> ('k1 -> 'k2) typ

    val future : (unit -> 'k type_future) -> subst -> 'k typ

    (** Get kind of given type *)
    val kind : 'k typ -> 'k Kind.t
    
    (** Get kind of given neutral_type *)
    val neutral_kind : 'k neutral_type -> 'k Kind.t

    (** View *)
    val view : 'k typ -> 'k type_view
  
    (** Apply substitution *)
    val subst : subst -> 'k typ -> 'k typ

    (** Apply substitution to constructor declaration *)
    val subst_ctor_decl : subst -> ctor_decl -> ctor_decl

    (** APply substitution to operation declaration *)
    val subst_op_decl : subst -> op_decl -> op_decl

    (** Substitute type for single type-variable *)
    val subst_type : 'k1 tvar -> 'k1 typ -> 'k2 typ -> 'k2 typ

    (** [subst_inst a b tp] substitute instance [a] for [b] in type [tp] *)
    val subst_inst : effinst -> effinst -> 'k typ -> 'k typ

    (** Check two types for equality *)
    val equal     : 'k typ -> 'k typ -> bool
    (** Check if one effect is a subeffect of another *)
    val subeffect : effect -> effect -> bool
    (** Check if one type is a subtype of another *)
    val subtype   : ttype  -> ttype  -> bool

    (** Check if a type fits to given scope *)
    val check_scope : scope -> 'k typ -> bool
  
    (** Computes smallest supertype of given type that fits given scope.
     * Raises [Escapes_scope] exception when such a supertype does not exist.
     *
     * Such supertype in created by pruning effects on negative position *)
    val supertype_in_scope : scope -> ttype -> ttype

    (** Types with existential kind *)
    module Ex : Utils.Exists.S with type 'k data = 'k typ
    include module type of Ex.Datatypes
  end

  (** Operations on substitutions *)
  module Subst : sig
    (** Empty (identity) substitution *)
    val empty : subst

    (** Extend substitution by a new mapping of type variable to type *)
    val add_type : subst -> 'k tvar -> 'k typ -> subst
    (** Extend substitution by single effect-instance substitution
     * (only instances can by substituted by instances *)
    val add_inst : subst -> effinst -> effinst -> subst

    (** Extend substitution by a mapping that given variables maps to
     * freshly generated ones. The new list of fresh variables is a part
     * of a result *)
    val add_tvars : subst -> TVar.ex list -> subst * TVar.ex list

    (** Apply substitution to single type variable *)
    val lookup_type : subst -> 'k tvar -> 'k typ

    (** Apply substitution to single effect instance *)
    val lookup_inst : subst -> effinst -> effinst
  
    (** Compose two substitutions
     *
     * The order of arguments is the same as for function composition,
     * i.e., in [compose s2 s1] substitution [s1] is applied first *)
    val compose : subst -> subst -> subst
  end

  (** Operations on scopes *)
  module Scope : sig
    (** Empty scope *)
    val empty : scope

    (** Add type variable to the scope *)
    val add_tvar : scope -> 'k tvar -> scope

    (** Add effect instance to the scope *)
    val add_effinst : scope -> effinst -> scope
  end
end

module Impl : S = struct
  include TypingStructure
  type scope = Scope.t
  module Type = struct
    include Type
    include Subtyping
    include ScopeCheck
  end
  module Subst = struct
    include Subst
    let compose = Type.subst_compose
  end
  module Scope = Scope
end

module type Export = S
  with module TVar = Impl.TVar
  and type 'k typ    = 'k Impl.typ
  and type subst     = Impl.subst
  and type scope     = Impl.scope
  and type type_arg  = Impl.type_arg
  and type ctor_decl = Impl.ctor_decl
  and type op_decl   = Impl.op_decl
