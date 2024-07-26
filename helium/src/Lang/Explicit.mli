(* Lang/Explicit.mli
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
(** Explicit Intermediate Language
 *
 * Key features of the Explicit language
 * - some high-level features, like deep pattern-maching
 * - remnants of the module system
 * - typed language with explicit coercions (those with computational content)
 * - types shared with Core?
 *)

include Kind.Export
include CoreCommon.CoreTypes.Export
include CoreCommon.TypeDef.Export
include CoreCommon.Unit.Export

module Var : Common.Var_S

type var = Common.var

type type_instance =
| TpInst : 'k tvar * 'k typ -> type_instance

type coercion =
(** Identity coercion. It takes input and output types as parameters. We have
 * two types, because some implicit (computationally irrelevant) subtyping
 * may occur between them *)
| CId        of ttype * ttype
(** Composition of two coercions. The left coercion is applied first *)
| CComp      of coercion * coercion
(** Arrow coercion *)
| CArrow     of
  (** Argument coercion *)
  { arg_crc : coercion
  (** Result coercion *)
  ; res_crc : coercion
  (** Input effect *)
  ; eff_in  : effect
  (** Output effect *)
  ; eff_out : effect
  }
(** Generalize types and then apply given coercion *)
| CTypeGen   of TVar.ex list * coercion
(** Apply value to given types, then apply given coercion. The type stored
 * in the constructor, together with type variables bound in type instances
 * form polymorphic input type *)
| CTypeApp   of type_instance list * ttype * coercion
(** Generalize effect instance and then apply coercion *)
| CInstGen   of effinst * effsig * coercion
(** Apply value to given effect instance, then apply given coercion. The
 * type stored in the constructor is a coercion input type, and should be
 * constructed by TForallInst constructor *)
| CInstApp   of ttype * effinst * coercion
(** Coerce value, then pack given types as existential type. The type stored
 * in the constructor, together with type variables bound in type instances
 * form existential output type *)
| CPack      of coercion * type_instance list * ttype
(** Unpack given value of existential type and apply coercion *)
| CUnpack    of TVar.ex list * coercion
(** Create tuple of applying list of coercions to coerced value. The type
 * stored in the construction is an input type *)
| CTuple     of ttype * coercion list
(** Apply projection on tuple of given types, and then apply given coercion *)
| CProj      of ttype list * int * coercion
(** Reify given TDataDef isomorphism witness into a function that represents
 * n-th constructor of given datatype. The type and the list of constructors
 * are parameters to TDataDef, that describes input type of the coercion *)
| CCtorProxy of ttype * ctor_decl list * int
(** Reify given TEffsigDef isomorphism witness into a function that performs
 * n-th operation of an effect of given signature *)
| COpProxy   of effsig * op_decl list * int

type pattern = (Utils.UID.t, pattern_data) Node.node
and pattern_data =
(** Variable of given type *)
| PVar    of var * ttype
(** Coerce value before matching to given pattern *)
| PCoerce of coercion * pattern
(** Constructor *)
| PCtor   of
  (** Type of the constructor *)
  { typ   : ttype
  (** List of all constructors of given type *)
  ; ctors : ctor_decl list
  (** Type isomorphism witness (of type TDataDef(typ, ctors)) *)
  ; proof : value
  (** Index of the constructor in ADT *)
  ; index : int
  (** Type parameters of the constructor *)
  ; targs : TVar.ex list
  (** Patterns that match arguments of the constructor *)
  ; args  : pattern list
  }

and expr = (Utils.UID.t, expr_data) Node.node
and expr_data = 
(** Value as an expression *)
| EValue      of value
(** Coercing reasult of an expression *)
| ECoerce     of coercion * expr
(** Packing of several types as existential type.
 * EPack([TpInst(a1,tp1);...;TpInst(an,tpn), tp0, e) has type
 * Type.exists_l [a1;...;an] tp0, while e should have type
 * tp0 {tp1/a1,...,tpn/an} *)
| EPack       of type_instance list * ttype * expr
(** Let definitions also unpack existential types *)
| ELet        of TVar.ex list * var * expr * expr
(** Definition of mutually-recurisve functions *)
| EFix        of rec_function list * expr
(** Definition of several mutually recursive data types *)
| ETypeDef    of typedef list * expr
(** Application *)
| EApp        of expr * expr
(** Instance application *)
| EInstApp    of expr * effinst
(** Deep pattern-matching. It stores the type of the whole expression *)
| EMatch      of expr * clause list * ttype
(** Pattern-matching of an empty type. In [EEmptyMatch(e, prf, tp)]
 * [e] is a matched expression, [v] is a isomorphism witness, and [tp]
 * is a type of the whole match expression. *)
| EEmptyMatch of expr * value * ttype
(** Handlers *)
| EHandle     of
  (** Isomorphism witness for handled algebraic effect *)
  { proof       : value
  (** List of all operations of handled effect *)
  ; ops         : op_decl list
  (** Effect instance bound by this handler (visible in the body) *)
  ; effinst     : effinst
  (** Body of the handler, i.e., expression for which the effect is handled *)
  ; body        : expr
  (** Operation handlers. Opposed to Core, each operation may be handled
   * more than once with different patterns on arguments *)
  ; op_handlers : op_handler list
  (** Variable of the return clasue *)
  ; return_var  : var
  (** Body of the return clause *)
  ; return_body : expr
  (** Type of the whole handler expression *)
  ; htype       : ttype
  (** Effect of the whole handler expression *)
  ; heffect     : effect
  }
(** Operation of algebraic effect. The first argument is an isomorphism
  * witness of type TEffectDef. The second argument is an index of an
  * operation *)
| EOp         of value * int * effinst * type_arg list * value list
(** [ERepl(cont, tp, eff, prompt)] is a REPL implementation. It is an
  * expression of type [tp] and effect [eff] that diplays prompt [prompt]
  * and calls the thunk [cont], which reads, parse and typecheck the next
  * portion on input. *)
| ERepl       of (unit -> expr CommonRepl.result) * ttype * effect * Box.t
(** [EReplExpr(e1, tp, e2)] evaluates expression [e1], prints it together
  * with its type [tp] (already pretty-printed), and continue by evaluating
  * [e2] *)
| EReplExpr   of expr * Box.t * expr
(** Dynamic import of units. It can be used only in REPL *)
| EReplImport of import list * expr

(** Values, i.e., obviously pure expressions *)
and value = (Utils.UID.t, value_data) Node.node
and value_data =
(** Literals of base types *)
| VLit      of RichBaseType.lit
(** Variable *)
| VVar      of var
(** Coerce value *)
| VCoerce   of coercion * value
(** Function, that do not pattern-match its argument *)
| VVarFn    of var * ttype * expr
(** Function that pattern-match its argument. It also contains the type
 * of the body *)
| VFn       of pattern * expr * ttype
(** Polymorphic function *)
| VTypeFun  of TVar.ex list * value
(** Polymorphic function with expression as a body. I hope, this construct
 * will be not needed in the future *)
| VTypeFunE of TVar.ex list * expr
(** Type application *)
| VTypeApp  of value * type_arg list
(** Effect-instance polymorphic function *)
| VInstFun  of effinst * effsig * expr
(** Constructor of ADT. The first argument is an isomorphism witness
  * of type TDataDef. The second argument is an index of constructor *)
| VCtor     of value * int * type_arg list * value list
(** Selection of n-th field of a record. The first argument is an isomorphism
  * witness *)
| VSelect   of value * int * value
(** Record. The first argument is an isomorphism witness *)
| VRecord   of value * value list
(** Tuples *)
| VTuple    of value list
(** Projection from a tuple *)
| VProj     of value * int
(** External value of given name and type *)
| VExtern   of string * ttype

(** Recursive function *)
and rec_function =
(** [RFFun(f, tp, xs, x, xtp, body)] is a recursive funcion:
  * [f]    - variable that represents this function
  * [tp]   - type of the function
  * [xs]   - list of type parameters
  * [x]    - first formal parameter
  * [xtp]  - type of [x]
  * [body] - body of the function *)
| RFFun     of var * ttype * TVar.ex list * var * ttype * expr
(** [RFInstFun(f, tp, xs, a, s, body)] is a recursive instance function:
  * [f]    - variable that represents this function
  * [tp]   - type of the function
  * [xs]   - list of type parameters
  * [a]    - instance parameter
  * [s]    - signature of instance [a]
  * [body] - body of the function *)
| RFInstFun of var * ttype * TVar.ex list * effinst * effsig * expr

(** Clause of deep patern-matching *)
and clause = (Utils.UID.t, clause_data) Node.node
and clause_data =
| Clause of pattern * expr

(** Operation handler *)
and op_handler = (Utils.UID.t, op_handler_data) Node.node
and op_handler_data =
(** Usual handler. It takes index of the operation, type binders for polymorphic
 * operations, patterns for arguments, pattern for resumption and the body *)
| HOp of int * TVar.ex list * pattern list * pattern * expr

type unit_body   = expr unit_body_gen
type source_file = expr source_file_gen

(** Operations on coercions *)
module Coercion : sig
  (** Helper function that constructs type type of constructor proxy *)
  val ctor_proxy_type : ttype -> ctor_decl list -> int -> ttype

  (** Helper function that constructs type type of operation proxy *)
  val op_proxy_type : effsig -> op_decl list -> int -> ttype

  (** Get the input type of the coercion *)
  val input_type : coercion -> ttype

  (** Identity coercion on given type *)
  val id : ttype -> coercion

  (** Structural coercion for instance-polymorphic type *)
  val forall_inst : effinst -> effsig -> coercion -> coercion

  (** Ignore coercion: ignores value of given type, and returns empty tuple *)
  val ignore : ttype -> coercion
end

(** Operations on patterns *)
module Pattern : sig
  (** Type of pattern *)
  val typ : pattern -> ttype
end

module SExprPrinter : sig
  val tr_type  : 'k typ -> SExpr.t
end

val flow_node : source_file Flow.node
