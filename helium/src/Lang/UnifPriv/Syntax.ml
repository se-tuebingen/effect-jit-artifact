open TypingStructure

module Var : sig
  type t
  val fresh : ttype -> t
  val typ   : t -> ttype

  val unique_name : t -> string

  module Map : Map.S with type key = t
end = struct
  module Core = struct
    type t =
      { v_uid  : Utils.UID.t
      ; v_type : ttype
      }
    let compare x y = Utils.UID.compare x.v_uid y.v_uid
  end
  include Core
  let fresh tp =
    { v_uid  = Utils.UID.fresh ()
    ; v_type = tp
    }
  let typ x = x.v_type

  let unique_name x = Utils.UID.to_string x.v_uid

  module Map = Map.Make(Core)
end

type var = Var.t

type typedef =
| TypeDef : 'k tvar * var -> typedef

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
