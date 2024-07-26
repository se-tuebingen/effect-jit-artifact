open Kind
include Kind.Export

type 'k uvar
type 'k tvar = 'k Common.tvar
type effinst = Common.effinst
type effinst_expr
type implicit_effinst
type scope
type subst
type 'k typ
type ttype  = ktype   typ
type effect = keffect typ
type effsig = keffsig typ

module TVar    : Common.TVar_S
module EffInst : Common.EffInst_S

type name_opt = string option

type named_type =
  { nt_name : name_opt
  ; nt_type : ttype
  }

type ex_type =
| TExists of TVar.ex list * ttype

type 'k neutral_type =
| TVar of 'k tvar
| TApp :  ('k1 -> 'k) neutral_type * 'k1 typ -> 'k neutral_type

type op_decl =
| OpDecl of string * TVar.ex list * named_type list * ex_type

and ctor_decl =
| CtorDecl of string * TVar.ex list * named_type list

and field_decl =
| FieldDecl of string * ttype

and decl =
| DeclThis    of ttype
| DeclTypedef of ttype
| DeclVal     of string * ttype
| DeclOp      of TVar.ex list * effsig * op_decl list * int
| DeclCtor    of TVar.ex list * ttype  * ctor_decl list * int
| DeclField   of TVar.ex list * ttype  * field_decl list * int

type effinst_expr_view =
| IEInstance of effinst
| IEImplicit of implicit_effinst

type 'k type_view =
| TEffPure    : keffect type_view
| TEffInst    : effinst_expr -> keffect type_view
| TEffCons    : effect * effect -> keffect type_view
| TUVar       : subst * 'k uvar -> 'k type_view
| TBase       : RichBaseType.t -> ktype type_view
| TNeutral    : 'k neutral_type -> 'k type_view
| TArrow      : name_opt * ttype * ex_type * effect -> ktype type_view
| TForall     : TVar.ex list * ttype -> ktype type_view
| TForallInst : effinst * effsig * ttype -> ktype type_view
| THandler    : effsig * ex_type * effect * ex_type * effect -> ktype type_view
| TFun        : 'k1 tvar * 'k2 typ -> ('k1 -> 'k2) type_view
| TStruct     : decl list -> ktype type_view
| TTypeWit    : ex_type -> ktype type_view
| TEffectWit  : effect -> ktype type_view
| TEffsigWit  : effsig -> ktype type_view
| TDataDef    : ttype * ctor_decl list -> ktype type_view
| TRecordDef  : ttype * field_decl list -> ktype type_view
| TEffsigDef  : effsig * op_decl list -> ktype type_view

type row_view =
| RPure
| RUVar        of subst * keffect uvar
| RConsEffInst of effinst_expr * effect
| RConsNeutral of keffect neutral_type * effect
| RConsUVar    of subst * keffect uvar * effect

type type_env

type type_instance =
| TpInst : 'k tvar * 'k typ -> type_instance

type type_arg =
| TpArg : 'k typ -> type_arg

type coercion =
| CId            of ttype * ttype
| CArrow         of 
    { name_in  : string option
    ; name_out : string option 
    ; arg_crc  : coercion 
    ; res_crc  : ex_coercion
    ; eff_in   : effect
    ; eff_out  : effect
    }
| CGen           of coercion * TVar.ex list * ttype
| CInst          of coercion * type_instance list * ttype
| CForallInst    of effinst * effsig * coercion
| CHandler       of
    { effsig      : effsig
    ; in_crc      : ex_coercion
    ; in_eff_in   : effect
    ; in_eff_out  : effect
    ; out_crc     : ex_coercion
    ; out_eff_in  : effect
    ; out_eff_out : effect
    }
| CStruct        of decl list * decl_coercion list
| CDataDefSeal   of ttype * ctor_decl list
| CRecordDefSeal of ttype * field_decl list
| CEffsigDefSeal of effsig * op_decl list
| CThis          of decl list * coercion
| CApplyInst     of coercion * effinst_expr * coercion

and ex_coercion =
| CExId   of ex_type * ex_type
| CExPack of TVar.ex list * coercion * type_instance list * ttype

and decl_coercion =
| DCThis    of coercion
| DCTypedef of coercion
| DCVal     of string * coercion
| DCOp      of
    TVar.ex list * effsig * op_decl list * type_instance list * int
| DCCtor    of
    TVar.ex list * ttype * ctor_decl list * type_instance list * int
| DCField   of 
    TVar.ex list * ttype * field_decl list * type_instance list * int
| DCThisSel of decl list * decl_coercion
| DCOpVal   of TVar.ex list * effsig * op_decl list * int * coercion
| DCCtorVal of TVar.ex list * ttype * ctor_decl list * int * coercion

type var

type typedef =
| TypeDef : 'k tvar * var -> typedef

type pattern = (Utils.UID.t, pattern_data) Node.node
and pattern_data =
| PVar    of var
| PCoerce of coercion * pattern
| PCtor   of
    { typ   : ttype
    ; ctors : ctor_decl list
    ; proof : value
    ; index : int
    ; targs : TVar.ex list
    ; args  : pattern list
    }

and expr = (Utils.UID.t, expr_data) Node.node
and expr_data =
| EValue      of value
| ECoerce     of ex_coercion * expr
| EPack       of type_instance list * ex_type * expr
| ELet        of TVar.ex list * var * expr * expr
| EFix        of rec_function list * expr
| ETypeDef    of typedef list * expr
| EApp        of value * value
| EInstApp    of value * effinst_expr
| EMatch      of value * clause list * ex_type
| EEmptyMatch of value * value * ex_type
| EHandle     of
  { effinst     : effinst
  ; effsig      : effsig
  ; ops         : op_decl list
  ; proof       : value
  ; body        : expr
  ; ret_effect  : effect
  ; ret_type    : ex_type
  ; fin_type    : ex_type
  ; op_handlers : op_handler list
  ; ret_clauses : TVar.ex list * clause list
  ; fin_clauses : TVar.ex list * clause list
  }
| EHandleWith of effinst * effsig * expr * value
| EOp         of value * int * effinst * type_arg list * value list
| ERepl       of (unit -> expr CommonRepl.result) * ex_type * effect * Box.t
| EReplExpr   of expr * Box.t * expr
| EReplImport of (var * import) list * expr

and rec_function =
| RFFun     of var * TVar.ex list * var * expr
| RFInstFun of var * TVar.ex list * effinst * effsig * expr
| RFHandler of var * TVar.ex list * effsig * ex_type * effect * expr

and value = (Utils.UID.t, value_data) Node.node
and value_data =
| VLit       of RichBaseType.lit
| VVar       of var
| VCoerce    of coercion * value
| VVarFn     of var * expr
| VFn        of pattern * expr * ex_type
| VTypeFun   of TVar.ex list * value
| VTypeFunE  of TVar.ex list * expr (* Required only for implicit type args *)
| VTypeApp   of value * type_arg list
| VInstFun   of effinst * effsig * expr
| VHandler   of
  { effsig      : effsig
  ; ops         : op_decl list
  ; proof       : value
  ; in_type     : ex_type
  ; in_effect   : effect
  ; ret_type    : ex_type
  ; ret_effect  : effect
  ; out_type    : ex_type
  ; out_effect  : effect
  ; op_handlers : op_handler list
  ; ret_clauses : TVar.ex list * clause list
  ; fin_clauses : TVar.ex list * clause list
  }
| VCtor       of value * int * type_arg list * value list
| VSelect     of value * int * value
| VRecord     of value * value list
| VStruct     of struct_def list
| VSelThis    of decl list * value
| VSelTypedef of decl list * value
| VSelVal     of decl list * value * string
| VSelOp      of decl list * value * string
| VSelCtor    of decl list * value * string
| VSelField   of decl list * value * string
| VTypeWit    of ex_type
| VEffectWit  of effect
| VEffsigWit  of effsig
| VExtern     of string * ttype

and clause = (Utils.UID.t, clause_data) Node.node
and clause_data =
| Clause of pattern * expr

and op_handler = (Utils.UID.t, op_handler_data) Node.node
and op_handler_data =
| HOp of int * TVar.ex list * pattern list * pattern * expr

and struct_def = (Utils.UID.t, struct_def_data) Node.node
and struct_def_data =
| SDThis    of value
| SDTypedef of value
| SDVal     of string * value
| SDOp      of value * int
| SDCtor    of value * int
| SDField   of value * int

and import =
  { im_name   : string
  ; im_path   : string
  ; im_level  : Common.source_level
  ; im_types  : TVar.ex list
  ; im_handle : effect
  ; im_sig    : decl list
  }

type unit_body =
| UB_Direct of
  { types    : TVar.ex list
  ; body_sig : decl list
  ; body     : expr
  }
| UB_CPS of
  { ambient_eff : effect
  ; types       : TVar.ex list
  ; handle      : effect
  ; body_sig    : decl list
  ; body        : expr
  }

type unit_sig =
| US_Direct of
  { types    : TVar.ex list
  ; body_sig : decl list
  }
| US_CPS of
  { types       : TVar.ex list
  ; handle      : effect
  ; body_sig    : decl list
  }

type source_file =
  { sf_import : (var * import) list
  ; sf_body   : unit_body
  }

type intf_file =
  { if_import : import list
  ; if_sig    : unit_sig
  }

val flow_node      : source_file Flow.node
val intf_flow_node : intf_file Flow.node

type error_reason =
| CannotUnify
| CannotGuessNeutral

exception Error of error_reason

module UVar : sig
  type 'k t = 'k uvar

  val uid : 'k t -> Utils.UID.t

  val kind : 'k t -> 'k kind

  module Map : Utils.Map1.S with type 'k key = 'k uvar
  module Ex  : Utils.Exists.S with type 'k data = 'k t
  include module type of Ex.Datatypes
  module Set : sig
    type t = unit Map.t

    val empty : t
    val add   : 'k uvar -> t -> t
    val union : t -> t -> t
    val diff  : t -> t -> t

    val unions : t list -> t

    val mem : 'k uvar -> t -> bool

    val to_list : t -> ex list
  end

  val match_arrow       : ?name:string -> subst -> ktype uvar -> unit
  val match_forall_inst : subst -> ktype uvar -> unit
  val match_handler     : subst -> ktype uvar -> unit
end

module ImplicitEffInst : sig
  type t = implicit_effinst

  val fresh : effsig -> implicit_effinst

  val effsig : implicit_effinst -> effsig

  val close : implicit_effinst -> effinst

  module Set : Set.S with type elt = t
end

module EffInstExpr : sig
  type t = effinst_expr

  val instance : effinst -> effinst_expr
  val implicit : implicit_effinst -> effinst_expr

  val view : effinst_expr -> effinst_expr_view
end

module Type : sig
  type 'k t = 'k typ

  val var : 'k tvar -> 'k typ

  val eff_pure : effect
  val eff_ivar : effinst -> effect
  val eff_inst : effinst_expr -> effect
  val eff_cons : effect -> effect -> effect

  val base        : RichBaseType.t -> ttype
  val neutral     : 'k neutral_type -> 'k typ
  val arrow       : ?name:string -> ttype -> ex_type -> effect -> ttype
  val arrow'      : ?name:string -> ttype -> ttype -> effect -> ttype
  val forall_inst : effinst -> effsig -> ttype -> ttype
  val handler     : effsig -> ex_type -> effect -> ex_type -> effect -> ttype
  val tstruct     : decl list -> ttype
  val type_wit    : ex_type -> ttype
  val effect_wit  : effect -> ttype
  val effsig_wit  : effsig -> ttype
  val data_def    : ttype -> ctor_decl list -> ttype
  val record_def  : ttype -> field_decl list -> ttype
  val effsig_def  : effsig -> op_decl list -> ttype

  val tfun : 'k1 tvar -> 'k2 typ -> ('k1 -> 'k2) typ

  val forall : TVar.ex list -> ttype -> ttype

  val app : ('k1 -> 'k2) typ -> 'k1 typ -> 'k2 typ

  val fresh_uvar : type_env -> 'k kind -> 'k typ

  val kind : 'k typ -> 'k kind
  val view : 'k typ -> 'k type_view
  val row_view : effect -> row_view

  val uvars  : 'k typ -> UVar.Set.t
  val iinsts : 'k typ -> ImplicitEffInst.Set.t

  val subst : subst -> 'k typ -> 'k typ
  val subst_type : 'k1 tvar -> 'k1 typ -> 'k2 typ -> 'k2 typ
  val subst_inst : effinst -> effinst_expr -> 'k typ -> 'k typ

  val unify     : env:type_env -> 'k typ -> 'k typ -> unit
  val coerce    : env:type_env -> ttype -> ttype -> coercion
  val subeffect : env:type_env -> effect -> effect -> unit

  val restrict_to_scope : scope -> 'k typ -> unit

  val open_effect_up : env:type_env -> effect -> effect

  val coerce_to_arrow       :
    env:type_env -> ttype -> coercion * ttype * ex_type * effect
  val coerce_to_forall_inst :
    env:type_env -> ttype -> coercion * effinst * effsig * ttype
  val coerce_to_handler     : env:type_env -> ttype ->
    coercion * effsig * ex_type * effect * ex_type * effect
  val coerce_to_type_wit    : env:type_env -> ttype -> coercion * ex_type
  val coerce_to_effect_wit  : env:type_env -> ttype -> coercion * effect
  val coerce_to_effsig_wit  : env:type_env -> ttype -> coercion * effsig

  val coerce_to_data_def    :
    env:type_env -> ttype -> coercion * ttype * ctor_decl list 

  val coerce_to_neutral     :
    env:type_env -> ttype -> coercion * ktype neutral_type

  val coerce_to_neutral_or_struct : env:type_env -> ttype ->
    coercion * (ttype, decl list) Utils.Either.either

  val coerce_to_struct : env:type_env -> ttype -> coercion * decl list

  val close_down_positive   : ttype -> UVar.ex list -> TVar.ex list
  val close_down_positive_l : ttype list -> UVar.ex list -> TVar.ex list

  val op_type   : TVar.ex list -> effsig -> op_decl -> ttype
  val ctor_type : TVar.ex list -> ttype -> ctor_decl -> ttype

  val instantiate_args : type_env -> TVar.ex list -> type_arg list * subst

  val to_sexpr : 'k typ -> SExpr.t
end

module ExType : sig
  val coerce : env:type_env -> ex_type -> ex_type -> ex_coercion
  val coerce_to_scope : scope -> ex_type -> ex_coercion * ex_type

  val instantiate : type_env -> ex_type -> type_instance list * ttype

  val open_up : env:type_env -> ex_type -> ex_type

  val to_sexpr : ex_type -> SExpr.t
end

module Decl : sig
  type val_decl =
  | VDVal  of ttype
  | VDOp   of TVar.ex list * effsig * op_decl list * int
  | VDCtor of TVar.ex list * ttype * ctor_decl list * int

  val subst : subst -> decl -> decl

  val shadowed_by : decl -> decl -> bool

  val select_this : decl list -> ttype option
  val select_val  : decl list -> string -> val_decl option
  val select_ctor : decl list -> string ->
    (TVar.ex list * ttype * ctor_decl list * int) option
  val select_op   : decl list -> string ->
    (TVar.ex list * effsig * op_decl list * int) option

  val this_index     : decl list -> int
  val typedef_index  : decl list -> int
  val val_index      : decl list -> string -> int
  val op_index       : decl list -> string -> int
  val ctor_index     : decl list -> string -> int
  val field_index    : decl list -> string -> int
end

module OpDecl : sig
  val name' : op_decl list -> int -> string

  val subst : subst -> op_decl -> op_decl
end

module CtorDecl : sig
  val name' : ctor_decl list -> int -> string

  val subst : subst -> ctor_decl -> ctor_decl
end

module FieldDecl : sig
  val name' : field_decl list -> int -> string

  val subst : subst -> field_decl -> field_decl
end

module Subst : sig
  val empty : subst

  val extend_t : subst -> 'k tvar -> 'k typ -> subst

  val subst_bvars : subst -> TVar.ex list -> TVar.ex list * subst

  type 's fold_f = { fold_f : 'k. 's -> 'k tvar -> 'k typ -> 's }

  val fold_types : 's fold_f -> 's -> subst -> 's
  val fold_insts : ('s -> effinst -> effinst_expr -> 's) -> 's -> subst -> 's
end

module Coercion : sig
  val input_type  : coercion -> ttype
  val output_type : coercion -> ttype
end

module Var : sig
  type t = var

  val fresh : ttype -> var

  val typ   : var -> ttype

  module Map : Map.S with type key = var
end

module Pattern : sig
  val typ : pattern -> ttype
end

module Scope : sig
  val to_sexpr : scope -> SExpr.t
end

module TypeEnv : sig
  type t = type_env

  val empty : t

  (** Extend environment with given type variables. Given variables must be
  unique and may not occur in environment *)
  val add_tvar_l : t -> TVar.ex list -> t

  (** Extend environment with given effect instance. Given instance may not
  occur in environment *)
  val add_effinst : t -> effinst -> t

  val scope : type_env -> scope

  val open_type_ts :
    type_env -> TVar.ex list -> ttype ->
      type_env * TVar.ex list * ttype

  val open_named_types_ts :
    type_env -> TVar.ex list -> named_type list ->
      type_env * TVar.ex list * named_type list

  val open_named_types_ex_type_ts :
    type_env -> TVar.ex list -> named_type list -> ex_type ->
      type_env * TVar.ex list * named_type list * ex_type

  val open_type_i :
    type_env -> effinst -> ttype ->
      type_env * effinst * ttype
end

module World : sig
  type t

  val save     : unit -> t
  val rollback : t -> unit

  val try_opt  : (unit -> 'a) -> 'a option
  val try_bool : (unit -> unit) -> bool
  val try_alt  : (unit -> 'a) -> (unit -> 'a) list -> 'a
  val try_exn  : (unit -> 'a) -> 'a
end
