include UnifPriv.TypingStructure
include UnifPriv.Syntax

type type_env = UnifPriv.TypeEnv.t

module ImplicitEffInst = UnifPriv.ImplicitEffInst
module EffInstExpr     = UnifPriv.EffInstExpr
module Decl            = UnifPriv.Decl
module Subst           = UnifPriv.Subst
module Coercion        = UnifPriv.Coercion
module Pattern         = UnifPriv.Pattern
module Scope           = UnifPriv.Scope
module TypeEnv         = UnifPriv.TypeEnv
module World           = UnifPriv.World

module UVar = struct
  include UnifPriv.UVar
  let match_arrow       = UnifPriv.Unification.uvar_match_arrow
  let match_forall_inst = UnifPriv.Unification.uvar_match_forall_inst
  let match_handler     = UnifPriv.Unification.uvar_match_handler
end

module Type = struct
  include UnifPriv.Type
  let unify ~env tp1 tp2 =
    UnifPriv.Unification.unify ~scope:(TypeEnv.scope env) tp1 tp2
  include UnifPriv.Subtyping
  include UnifPriv.TypeUtils
  include UnifPriv.TypeOpen
  include UnifPriv.ScopeRestriction
  let to_sexpr = UnifPriv.SExprPrinter.tr_type
end

module ExType = struct
  let coerce          = UnifPriv.Subtyping.coerce_ex
  let coerce_to_scope = UnifPriv.ScopeRestriction.coerce_ex_type_to_scope
  let instantiate     = UnifPriv.Subtyping.instantiate_ex
  let open_up         = UnifPriv.TypeOpen.open_ex_type_up
  let to_sexpr        = UnifPriv.SExprPrinter.tr_ex_type
end

module OpDecl = struct
  let name' = Decl.op_decl_name'

  let subst = UnifPriv.Type.subst_op_decl
end

module CtorDecl = struct
  let name' = Decl.ctor_decl_name'

  let subst = UnifPriv.Type.subst_ctor_decl
end

module FieldDecl = struct
  let name' = Decl.field_decl_name'

  let subst = UnifPriv.Type.subst_field_decl
end

let flow_node = Flow.Node.create
  ~cmd_line_flag: "-unif"
  "Unif"

let intf_flow_node = Flow.Node.create
  "Unif interface"

let _ : Flow.tag =
  Flow.register_transform
    ~provides_tags: [ CommonTags.pretty ]
    ~source: flow_node
    ~target: SExpr.flow_node
    ~name:   "Unif --> SExpr (pretty printer)"
    (fun file _ -> Flow.return (UnifPriv.SExprPrinter.tr_source_file file))
