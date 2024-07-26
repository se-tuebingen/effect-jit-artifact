type 'a node = (Utils.Position.t, 'a) Node.node

type ident = string node

type name = name_data node
and name_data =
| NameThis
| NameUnit
| NameNil
| NameLVar  of string
| NameUVar  of string
| NameOper  of string
| NameUOper of string

type ctor_name = ctor_name_data node
and ctor_name_data =
| CNUnit
| CNNil
| CNName of string
| CNOper of string

type path = path_data node
and path_data =
| PathName of name
| PathSel  of expr * name

and ctor_path = ctor_path_data node
and ctor_path_data =
| CPName of ctor_name
| CPPath of expr * ctor_name

and op_path = op_path_data node
and op_path_data =
| OPName of name
| OPPath of expr * name

and pattern = pattern_data node
and pattern_data =
| PWildcard
| PName   of name
| PAnnot  of pattern * expr
| PCtor   of ctor_path * pattern list
| PRecord of field_pattern list * bool
| PList   of pattern list
| PBOp    of pattern * ident * pattern

and field_pattern = field_pattern_data node
and field_pattern_data =
| FPatName of name * pattern
| FPatSel  of expr * name * pattern

and inst_pattern = inst_pattern_data node
and inst_pattern_data =
| IPVar   of string
| IPTuple of inst_pattern list
| IPAnnot of inst_pattern * expr

and farg = farg_data node
and farg_data =
| FArgName              of name
| FArgNamesAnnot        of name list * expr
| FArgPattern           of pattern
| FArgImplicit          of name list * expr
| FArgExplicitInst      of inst_pattern
| FArgExplicitInstAnnot of inst_pattern list * expr
| FArgImplicitInst      of inst_pattern

and arrow_arg = arrow_arg_data node
and arrow_arg_data =
| AAType              of expr
| AANames             of name list * expr
| AAImplicit          of name list * expr
| AAExplicitInst      of inst_pattern
| AAExplicitInstAnnot of inst_pattern list * expr
| AAImplicitInst      of inst_pattern

and expr = expr_data node
and expr_data =
| EPlaceholder
| EKindType
| EKindEffect
| EKindEffsig
| EArrowPure       of arrow_arg list * expr
| EArrowEff        of arrow_arg list * expr * expr list
| EHandlerType     of expr * expr * expr list * expr * expr list
| EInst            of inst_expr
| EEffect          of expr list
| ESigProd         of expr list
| EName            of name
| ETypeVar         of string
| ELit             of RichBaseType.lit
| EFn              of farg list * expr
| EApp             of expr * expr
| EInstApp         of expr * inst_expr
| EImplicitInstApp of expr * inst_expr
| EDefs            of def list * expr
| ETypeAnnot       of expr * expr
| ETypeEffAnnot    of expr * expr * expr list
| ETypeOf          of expr
| ESelect          of expr * path
| ERecord          of field_def list
| ERecordUpdate    of expr * field_def list
| EList            of expr list
| EUOp             of ident * expr
| EBOp             of expr * ident * expr
| EUIf             of expr * expr
| EIf              of expr * expr * expr
| EHandleWith      of inst_pattern option * expr * expr
| EHandle          of inst_pattern option * expr * handler list
| EHandler         of hexpr * (inst_pattern option * hexpr) list
| EMatch           of expr * clause list
| EStruct          of def list
| ESig             of decl list
| EExtern          of ident
| ERepl            of (unit -> repl_cmd * expr)

and hexpr =
| HEExpr    of expr
| HEClauses of handler list

and handler = handler_data node
and handler_data =
| HOp      of op_path * pattern list * pattern option * expr
| HReturn  of pattern * expr
| HFinally of pattern * expr

and clause = clause_data node
and clause_data =
| Clause of pattern * expr

and field_def = field_def_data node
and field_def_data =
| FieldName of name * expr
| FieldSel  of expr * name * expr

and inst_expr = inst_expr_data node
and inst_expr_data =
| IEVar   of string
| IETuple of inst_expr list
| IEProj  of inst_expr * int

and rec_fun = rec_fun_data node
and rec_fun_data =
| RecVal of name * expr
| RecFun of name * farg list * expr

and typedef = typedef_data node
and typedef_data =
| TDData   of name * farg list * ctor_decl list
| TDRecord of name * farg list * field_decl list
| TDEffsig of name * farg list * op_decl list

and ctor_decl = ctor_decl_data node
and ctor_decl_data =
| CtorDecl of ctor_name * arrow_arg list

and field_decl = field_decl_data node
and field_decl_data =
| FieldDecl of name * expr

and op_decl = op_decl_data node
and op_decl_data =
| OpDecl of name * arrow_arg list * expr

and def = def_data node
and def_data =
| DefLet         of pattern * expr
| DefFun         of name * farg list * expr
| DefLetRec      of rec_fun list
| DefType        of name * farg list * expr
| DefAbsType     of name * expr
| DefTypedef     of typedef
| DefTypedefRec  of typedef list
| DefHandle      of inst_pattern option * handler list
| DefHandleWith  of inst_pattern option * expr
| DefOpen        of expr
| DefOpenType    of expr
| DefInclude     of expr
| DefIncludeType of expr

and decl = decl_data node
and decl_data =
| DeclValSig      of name * expr
| DeclType        of name * farg list * expr
| DeclTypedef     of typedef
| DeclTypedefRec  of typedef list
| DeclOpen        of expr
| DeclOpenType    of expr
| DeclInclude     of expr
| DeclIncludeType of expr

and preamble_decl = preamble_decl_data node
and preamble_decl_data =
| PDImport  of string
| PDHandler of expr list

and repl_cmd = repl_cmd_data node
and repl_cmd_data =
| ReplExit
| ReplExpr   of expr
| ReplDef    of def
| ReplImport of string

type file =
  { sf_pos      : Utils.Position.t
  ; sf_preamble : preamble_decl list
  ; sf_defs     : def list
  }

type intf_file =
  { if_pos      : Utils.Position.t
  ; if_preamble : preamble_decl list
  ; if_decls    : decl list
  }

let flow_node : file Flow.node = Flow.Node.create "Raw"
let intf_flow_node : intf_file Flow.node =
  Flow.Node.create "Raw (interface)"
