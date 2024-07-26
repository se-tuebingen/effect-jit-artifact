
type syncat =
| Pattern
| Expression
| Structure
| HandlerContext
| CPS_Unit

type type_error =
| UnboundEffInst of Utils.Position.t * string
| UnboundVar     of Lang.Surface.name
| UnboundOp      of Lang.Surface.name
| UnboundCtor    of Lang.Surface.ctor_name
| UnboundField   of Lang.Surface.name
| NoMember       of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Surface.name
| NoSuchField    of Env.t * Lang.Unif.ttype * Lang.Surface.name
| OpRedefinition          of Utils.Position.t * Lang.Surface.name
| CtorRedefinition        of Utils.Position.t * Lang.Surface.ctor_name
| FieldRedefinition       of Utils.Position.t * Lang.Surface.name
| RecFunctionRedefinition of Utils.Position.t * Lang.Surface.name
| FieldNotDefined         of Utils.Position.t * string
| TypeMismatch of
  { pos    : Utils.Position.t
  ; env    : Env.t
  ; syncat : syncat
  ; tpfrom : Lang.Unif.ex_type
  ; tpto   : Lang.Unif.ex_type
  ; reason : Lang.Unif.error_reason
  }
| EffectMismatch of
  { pos    : Utils.Position.t
  ; env    : Env.t
  ; efrom  : Lang.Unif.effect
  ; eto    : Lang.Unif.effect
  ; reason : Lang.Unif.error_reason
  }
| NotAFunction  of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Unif.error_reason
| NotForallInst of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Unif.error_reason
| NotAHandler   of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Unif.error_reason
| NotAType      of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Unif.error_reason
| NotAnEffect   of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Unif.error_reason
| NotAnEffsig   of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Unif.error_reason
| NotNeutral    of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Unif.error_reason
| CannotSelect  of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Unif.error_reason
| NotAStructure of
  Utils.Position.t * Env.t * Lang.Unif.ttype * Lang.Unif.error_reason
| EmptyMatch    of Utils.Position.t * Env.t * Lang.Unif.ttype
| PatternArity  of Utils.Position.t * Lang.Surface.ctor_name * int * int
| CannotInferExternType of Utils.Position.t
| CannotInferArgType    of Utils.Position.t
| EffinstInData         of Utils.Position.t
| ExistentialField      of Utils.Position.t
| CannotSealHere        of Utils.Position.t
| AmbiguousInstance     of Utils.Position.t * Env.t * Lang.Unif.effsig
| ImplicitScopeError    of Utils.Position.t * Env.t * ImplicitScope.error
| CannotImport          of Utils.Position.t * string
| DependencyLoop        of string list

exception Type_error of type_error

val unbound_eff_inst : pos: Utils.Position.t -> string -> exn
val unbound_var      : Lang.Surface.name -> exn
val unbound_op       : Lang.Surface.name -> exn
val unbound_ctor     : Lang.Surface.ctor_name -> exn
val unbound_field    : Lang.Surface.name -> exn

val no_member :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Surface.name -> exn

val no_such_field : env: Env.t -> Lang.Unif.ttype -> Lang.Surface.name -> exn

val op_redefinition    : pos: Utils.Position.t -> Lang.Surface.name -> exn
val ctor_redefinition  : pos: Utils.Position.t -> Lang.Surface.ctor_name -> exn
val field_redefinition : pos: Utils.Position.t -> Lang.Surface.name -> exn

val rec_function_redefinition :
  pos:Utils.Position.t -> Lang.Surface.name -> exn

val field_not_defined : pos:Utils.Position.t -> string -> exn

val type_mismatch :
  pos:    Utils.Position.t ->
  env:    Env.t  ->
  syncat: syncat ->
    Lang.Unif.ex_type -> Lang.Unif.ex_type -> Lang.Unif.error_reason -> exn

val type_mismatch' :
  pos:    Utils.Position.t ->
  env:    Env.t  ->
  syncat: syncat ->
    Lang.Unif.ttype -> Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val effect_mismatch :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.effect -> Lang.Unif.effect -> Lang.Unif.error_reason -> exn

val not_a_function :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val not_forall_inst :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val not_a_handler :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val not_a_type :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val not_an_effect :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val not_an_effsig :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val not_neutral :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val cannot_select :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val not_a_structure :
  pos: Utils.Position.t ->
  env: Env.t ->
    Lang.Unif.ttype -> Lang.Unif.error_reason -> exn

val empty_match : pos: Utils.Position.t -> env: Env.t -> Lang.Unif.ttype -> exn

val pattern_arity :
  pos: Utils.Position.t -> Lang.Surface.ctor_name -> int -> int -> exn

val cannot_infer_extern_type : pos: Utils.Position.t -> exn
val cannot_infer_arg_type    : pos: Utils.Position.t -> exn
val effinst_in_data          : pos: Utils.Position.t -> exn
val existential_field        : pos: Utils.Position.t -> exn
val cannot_seal_here         : pos: Utils.Position.t -> exn

val ambiguous_instance :
  pos: Utils.Position.t -> env: Env.t -> Lang.Unif.effsig -> exn

val implicit_scope_error :
  pos: Utils.Position.t -> env: Env.t -> ImplicitScope.error -> exn

val cannot_import   : Utils.Position.t -> string -> exn
val dependency_loop : string list -> exn

val flow_node : type_error Flow.node
