
type 'a node = (Utils.Position.t, 'a) Node.node

type inst_id = string

type name = name_data node
and name_data =
| NameThis
| NameUnit
| NameNil
| NameID  of string
| NameBOp of string
| NameUOp of string

type ctor_name = ctor_name_data node
and ctor_name_data =
| CNUnit
| CNNil
| CNId of string
| CNOp of string

type eff_inst_expr = eff_inst_expr_data node
and eff_inst_expr_data =
| EIVar of string

type eff_inst_binder = eff_inst_binder_data node
and eff_inst_binder_data =
| IBAnon
| IBInst  of inst_id
| IBAnnot of inst_id node * expr

and arrow_arg = arrow_arg_data node
and arrow_arg_data =
| AAType     of expr
| AAVars     of name list * expr
| AAEffInsts of inst_id node list * expr
| AAImplicit of name list * expr

and type_farg = type_farg_data node
and type_farg_data =
| TFA_Var   of name
| TFA_Annot of name list * expr

and op_decl = op_decl_data node
and op_decl_data =
| OpDecl of name * arrow_arg list * expr

and ctor_decl = ctor_decl_data node
and ctor_decl_data =
| CtorDecl of ctor_name * arrow_arg list

and field_decl = field_decl_data node
and field_decl_data =
| FieldDecl of name * expr

and fn_arg = fn_arg_data node
and fn_arg_data =
| FAPattern       of pattern
| FAEffInst       of inst_id
| FAEffInstsAnnot of inst_id node list * expr
| FAImplicit      of name list * expr

and pattern = pattern_data node
and pattern_data =
| PWildcard
| PVar   of name
| PAnnot of pattern * expr
| PCtor  of ctor_path * pattern list

and ctor_path = ctor_path_data node
and ctor_path_data =
| CPName of ctor_name
| CPPath of expr * ctor_name

and op_path = op_path_data node
and op_path_data =
| OPName of name
| OPPath of expr * name

and expr = expr_data node
and expr_data =
| EType
| EEffect
| EEffsig
| ELit         of RichBaseType.lit
| EVar         of name
| EEffInst     of inst_id
| ETypeAnnot   of expr * expr
| EArrowPure   of arrow_arg list * expr
| EArrowEff    of arrow_arg list * expr * expr list
| EHandlerType of expr * expr * expr * expr * expr
| ERow         of expr list
| EDef         of def * expr
| EFn          of fn_arg list * expr
| EApp         of expr * expr
| EAppInst     of expr * eff_inst_expr
| EMatch       of expr * clause list
| EHandle      of eff_inst_binder * expr * handler list
| EHandler     of handler list
| EHandleWith  of eff_inst_binder * expr * expr
| ESelect      of expr * name
| ERecord      of field_def list
| EStruct      of def list
| ESig         of decl list
| EExtern      of string node
| ERepl        of (unit -> repl_cmd * expr)

and clause = clause_data node
and clause_data =
| Clause of pattern * expr

and handler = handler_data node
and handler_data =
| HOp      of op_path * pattern list * pattern * expr
| HReturn  of pattern * expr
| HFinally of pattern * expr

and field_def = field_def_data node
and field_def_data =
| FieldName of name * expr

and typedef = typedef_data node
and typedef_data =
| TDEffsig of name * type_farg list * op_decl list
| TDData   of name * type_farg list * ctor_decl list
| TDRecord of name * type_farg list * field_decl list

and def = def_data node
and def_data =
| DLetPat      of pattern * expr
| DLetVal      of name * expr
| DLetFn       of name * fn_arg list * expr
| DLetRec      of (name * fn_arg list * expr) list
| DTypedef     of typedef
| DTypedefRec  of typedef list
| DHandle      of eff_inst_binder * handler list
| DHandleWith  of eff_inst_binder * expr
| DOpen        of expr
| DWeakOpen    of expr
| DInclude     of expr
| DWeakInclude of expr

and decl = decl_data node
and decl_data =
| DeclValSig      of name * expr
| DeclValDef      of name * expr
| DeclTypedef     of typedef
| DeclTypedefRec  of typedef list
| DeclOpen        of expr
| DeclWeakOpen    of expr
| DeclInclude     of expr
| DeclWeakInclude of expr

and repl_cmd = repl_cmd_data node
and repl_cmd_data =
| ReplExpr   of expr
| ReplDef    of def
| ReplImport of string

type preamble_decl = preamble_decl_data node
and preamble_decl_data =
| PDImport  of string
| PDHandler of expr

type source_file =
  { sf_pos      : Utils.Position.t
  ; sf_preamble : preamble_decl list
  ; sf_defs     : def list
  }

type intf_file =
  { if_pos      : Utils.Position.t
  ; if_preamble : preamble_decl list
  ; if_decls    : decl list
  }

let rec is_value (e : expr) =
  match e.data with
  | EType | EEffect | EEffsig | ELit _ | EVar _ | EEffInst _ | EArrowPure _
  | EArrowEff _ | EHandlerType _ | ERow _ | EFn _ | EHandler _ | ESig _
  | EExtern _ ->
    true
  | ETypeAnnot(e, _) | ESelect(e, _) -> is_value e
  | EDef _ | EApp _ | EAppInst _ | EMatch _ | EHandle _ | EHandleWith _
  | ERecord _ | EStruct _ | ERepl _ -> false

let rec name_of_pattern (p : pattern) =
  match p.data with
  | PVar x       -> Some x
  | PAnnot(p, _) -> name_of_pattern p
  | PWildcard | PCtor _ -> None

let string_of_name (name : name) =
  match name.data with
  | NameThis   -> "this"
  | NameUnit   -> "()"
  | NameNil    -> "[]"
  | NameID  x  -> x
  | NameBOp op -> "(" ^ op ^ ")"
  | NameUOp op -> "(" ^ op ^ "_)"

let string_of_ctor_name (name : ctor_name) =
  match name.data with
  | CNUnit  -> "()"
  | CNNil   -> "[]"
  | CNId x  -> x
  | CNOp op -> "(" ^ op ^ ")"

let flow_node : source_file Flow.node =
  Flow.Node.create "Surface"

let intf_flow_node : intf_file Flow.node =
  Flow.Node.create "Surface (interface)"
