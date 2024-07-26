
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

let unbound_eff_inst ~pos name =
  Type_error (UnboundEffInst(pos, name))

let unbound_var   name = Type_error (UnboundVar name)
let unbound_op    name = Type_error (UnboundOp name)
let unbound_ctor  name = Type_error (UnboundCtor name)
let unbound_field name = Type_error (UnboundField name)

let no_member ~pos ~env tp name = Type_error (NoMember(pos, env, tp, name))

let no_such_field ~env rdtp name = Type_error (NoSuchField(env, rdtp, name))

let op_redefinition    ~pos name = Type_error (OpRedefinition(pos, name))
let ctor_redefinition  ~pos name = Type_error (CtorRedefinition(pos, name))
let field_redefinition ~pos name = Type_error (FieldRedefinition(pos, name))

let rec_function_redefinition ~pos name =
  Type_error (RecFunctionRedefinition(pos, name))

let field_not_defined ~pos name = Type_error (FieldNotDefined(pos, name))

let type_mismatch ~pos ~env ~syncat tpfrom tpto reason =
  Type_error (TypeMismatch
    { pos    = pos
    ; env    = env
    ; syncat = syncat
    ; tpfrom = tpfrom
    ; tpto   = tpto
    ; reason = reason
    })

let type_mismatch' ~pos ~env ~syncat tpfrom tpto reason =
  Type_error (TypeMismatch
    { pos    = pos
    ; env    = env
    ; syncat = syncat
    ; tpfrom = TExists([], tpfrom)
    ; tpto   = TExists([], tpto)
    ; reason = reason
    })

let effect_mismatch ~pos ~env efrom eto reason =
  Type_error (EffectMismatch
    { pos    = pos
    ; env    = env
    ; efrom  = efrom
    ; eto    = eto
    ; reason = reason
    })

let not_a_function ~pos ~env tp reason =
  Type_error (NotAFunction(pos, env, tp, reason))

let not_forall_inst ~pos ~env tp reason =
  Type_error (NotForallInst(pos, env, tp, reason))

let not_a_handler ~pos ~env tp reason =
  Type_error (NotAHandler(pos, env, tp, reason))

let not_a_type ~pos ~env tp reason =
  Type_error (NotAType(pos, env, tp, reason))

let not_an_effect ~pos ~env tp reason =
  Type_error (NotAnEffect(pos, env, tp, reason))

let not_an_effsig ~pos ~env tp reason =
  Type_error (NotAnEffsig(pos, env, tp, reason))

let not_neutral ~pos ~env tp reason =
  Type_error (NotNeutral(pos, env, tp, reason))

let cannot_select ~pos ~env tp reason =
  Type_error (CannotSelect(pos, env, tp, reason))

let not_a_structure ~pos ~env tp reason =
  Type_error (NotAStructure(pos, env, tp, reason))

let empty_match ~pos ~env tp =
  Type_error (EmptyMatch(pos, env, tp))

let pattern_arity ~pos name n1 n2 =
  Type_error (PatternArity(pos, name, n1, n2))

let cannot_infer_extern_type ~pos =
  Type_error (CannotInferExternType pos)

let cannot_infer_arg_type ~pos =
  Type_error (CannotInferArgType pos)

let effinst_in_data ~pos =
  Type_error (EffinstInData pos)

let existential_field ~pos =
  Type_error (ExistentialField pos)

let cannot_seal_here ~pos =
  Type_error (CannotSealHere pos)

let ambiguous_instance ~pos ~env s =
  Type_error (AmbiguousInstance(pos, env, s))

let implicit_scope_error ~pos ~env err =
  Type_error (ImplicitScopeError(pos, env, err))

let cannot_import pos name = Type_error (CannotImport(pos, name))
let dependency_loop loop   = Type_error (DependencyLoop loop)

let flow_node =
  Flow.Node.create "Type error"

(* ========================================================================= *)

let pretty_name (name : Lang.Surface.name) =
  match name.data with
  | NameThis   -> Box.kw "this"
  | NameUnit   -> Box.const "()"
  | NameNil    -> Box.const "[]"
  | NameID x   -> Box.word x
  | NameBOp op -> Box.paren (Box.oper op)
  | NameUOp op -> Box.paren (Box.box [ Box.word "_"; Box.oper op ])

let pretty_ctor_name (name : Lang.Surface.ctor_name) =
  match name.data with
  | CNUnit  -> Box.const "()"
  | CNNil   -> Box.const "[]"
  | CNId x  -> Box.word x
  | CNOp op -> Box.paren (Box.oper op)

let pretty_type_mismatch_reason reason =
  (* TODO *)
  []

let pretty_implicit_scope_error pretty_env (err : ImplicitScope.error) =
  let open Box in
  match err with
  | NoScopeForEffInst s ->
    ( textl "There is no implicit scope which can bind instance of signature"
    @ [ ws (suffix (Pretty.Unif.pretty_type pretty_env 0 s) (word ".")) ])
  | EscapingEffInst(pos, s, err) ->
    ( textl "Implicit instance of signature"
    @ [ ws (Pretty.Unif.pretty_type pretty_env 0 s) ]
    @ textl "introduced at"
    @ [ ws (word ~attrs:[ Path ] (Utils.Position.to_string pos)) ]
    @ textl "escapes its own scope."
    @ pretty_type_mismatch_reason err)

let flow_pretty_printer err _ =
  let open Box in
  Flow.return
  begin match err with
  | UnboundEffInst(pos, name) ->
    ErrorPrinter.error_p pos
      ( textl "Unbound effect instance"
      @ [ ws (suffix (word name) (word ".")) ])
  | UnboundVar name ->
    ErrorPrinter.error_p name.meta
      ( textl "Unbound variable"
      @ [ ws ((suffix (pretty_name name)) (word ".")) ])
  | UnboundOp name ->
    ErrorPrinter.error_p name.meta
      ( textl "Unbound operation"
      @ [ ws ((suffix (pretty_name name)) (word ".")) ])
  | UnboundCtor name ->
    ErrorPrinter.error_p name.meta
      ( textl "Unbound constructor"
      @ [ ws ((suffix (pretty_ctor_name name)) (word ".")) ])
  | UnboundField name ->
    ErrorPrinter.error_p name.meta
      ( textl "Unbound field"
      @ [ ws ((suffix (pretty_name name)) (word ".")) ])

  | NoMember(pos, env, tp, name) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This structure has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 tp)
            (word ".")) ]
      @ textl "It has no member of name "
      @ [ ws (suffix (pretty_name name) (word ".")) ])

  | NoSuchField(env, rdtp, name) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p name.meta
      ( textl "Record"
      @ [ ws (Pretty.Unif.pretty_type pretty_env 0 rdtp) ]
      @ textl "has no field named"
      @ [ ws (suffix (pretty_name name) (word ".")) ])

  | OpRedefinition(pos, name) ->
    ErrorPrinter.error_p pos
      ( textl "Operation"
      @ [ ws (pretty_name name) ]
      @ textl " is defined more than once.")
  | CtorRedefinition(pos, name) ->
    ErrorPrinter.error_p pos
      ( textl "Constructor"
      @ [ ws (pretty_ctor_name name) ]
      @ textl " is defined more than once.")
  | FieldRedefinition(pos, name) ->
    ErrorPrinter.error_p pos
      ( textl "Field"
      @ [ ws (pretty_name name) ]
      @ textl " is defined more than once.")
  | RecFunctionRedefinition(pos, name) ->
    ErrorPrinter.error_p pos
      ( textl "Recursive value"
      @ [ ws (pretty_name name) ]
      @ textl " is defined more than once.")
  | FieldNotDefined(pos, name) ->
    ErrorPrinter.error_p pos
      ( textl "Field"
      @ [ ws (word name) ]
      @ textl " is not defined in this record.")

  | TypeMismatch({ syncat = Pattern; _ } as err) ->
    let pretty_env = Env.pretty_env err.env in
    ErrorPrinter.error_p err.pos
      ( textl "This pattern matches values of type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpto)
            (word ",")) ]
      @ textl "but a pattern was expected of type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpfrom)
            (Box.word ".")) ]
      @ pretty_type_mismatch_reason err.reason)

  | TypeMismatch({ syncat = Expression; _ } as err) ->
    let pretty_env = Env.pretty_env err.env in
    ErrorPrinter.error_p err.pos
      ( textl "This expression has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpfrom)
            (word ",")) ]
      @ textl "but an expression was expected of type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpto)
            (Box.word ".")) ]
      @ pretty_type_mismatch_reason err.reason)

  | TypeMismatch({ syncat = Structure; _ } as err) ->
    let pretty_env = Env.pretty_env err.env in
    ErrorPrinter.error_p err.pos
      ( textl "This structure has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpfrom)
            (word ",")) ]
      @ textl "but a structure was expected of type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpto)
            (Box.word ".")) ]
      @ pretty_type_mismatch_reason err.reason)

  | TypeMismatch({ syncat = HandlerContext; _ } as err) ->
    let pretty_env = Env.pretty_env err.env in
    ErrorPrinter.error_p err.pos
      ( textl "This handler provides a value of type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpfrom)
            (word ",")) ]
      @ textl "but is used in context of type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpto)
            (Box.word ".")) ]
      @ pretty_type_mismatch_reason err.reason)

  | TypeMismatch({ syncat = CPS_Unit; _ } as err) ->
    let pretty_env = Env.pretty_env err.env in
    ErrorPrinter.error_p err.pos
      ( textl "This CPS unit has type an answer type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpfrom)
            (word ",")) ]
      @ textl "but the type"
      @ [ ws (Pretty.Unif.pretty_ex_type pretty_env 0 err.tpto) ]
      @ (textl "was expected.")
      @ pretty_type_mismatch_reason err.reason)

  | EffectMismatch err ->
    let pretty_env = Env.pretty_env err.env in
    ErrorPrinter.error_p err.pos
      ( textl "This expression has effect"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 err.efrom)
            (word ",")) ]
      @ textl "but an expression was expected of effect"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 err.eto)
            (Box.word ".")) ]
      @ pretty_type_mismatch_reason err.reason)

  | NotAFunction(pos, env, tp, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This expression has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 tp)
            (word ".")) ]
      @ textl "This is not a function and cannot be applied."
      @ pretty_type_mismatch_reason err)

  | NotForallInst(pos, env, tp, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This expression has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 tp)
            (word ".")) ]
      @ textl "This is not an instance function"
      @ textl " and cannot be applied to effect instance."
      @ pretty_type_mismatch_reason err)

  | NotAHandler(pos, env, tp, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This expression has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 tp)
            (word ".")) ]
      @ textl "This is not a handler."
      @ pretty_type_mismatch_reason err)

  | NotAType(pos, env, tp, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This expression has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 tp)
            (word ",")) ]
      @ textl "but a type was expected here."
      @ pretty_type_mismatch_reason err)

  | NotAnEffect(pos, env, tp, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This expression has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 tp)
            (word ",")) ]
      @ textl "but an effect was expected here."
      @ pretty_type_mismatch_reason err)

  | NotAnEffsig(pos, env, tp, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This expression has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 tp)
            (word ",")) ]
      @ textl "but an effect signature was expected here."
      @ pretty_type_mismatch_reason err)

  | NotNeutral(pos, env, tp, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This expression has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 tp)
            (word ",")) ]
      @ textl "but a known neutral type was expected here."
      @ pretty_type_mismatch_reason err)

  | CannotSelect(pos, env, tp, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This expression has type"
      @ [ ws (Pretty.Unif.pretty_type pretty_env 0 tp) ]
      @ textl " and has no fields to select."
      @ pretty_type_mismatch_reason err)

  | NotAStructure(pos, env, tp, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "This expression has type"
      @ [ ws (suffix
            (Pretty.Unif.pretty_type pretty_env 0 tp)
            (word ",")) ]
      @ textl "but a structure was expected here."
      @ pretty_type_mismatch_reason err)

  | EmptyMatch(pos, env, tp) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "Empty pattern matching on type"
      @ [ ws (Pretty.Unif.pretty_type pretty_env 0 tp) ]
      @ textl "which is not known to be empty.")

  | PatternArity(pos, name, n1, n2) ->
    ErrorPrinter.error_p pos
      ( textl "Constructor"
      @ [ ws (pretty_ctor_name name) ]
      @ textfl "expects %d argument(s), but here is applied to %d." n2 n1)

  | CannotInferExternType pos ->
    ErrorPrinter.error_p pos
      (textl "Cannot infer type of this external value.")
  | CannotInferArgType pos ->
    ErrorPrinter.error_p pos
      (textl "Cannot infer type of this argument.")
  | EffinstInData pos ->
    ErrorPrinter.error_p pos
      (textl "Effect instances cannot be stored in datatypes.")

  | ExistentialField pos ->
    ErrorPrinter.error_p pos
      (textl "Types cannot be members of a record.")
  | CannotSealHere pos ->
    ErrorPrinter.error_p pos
      (textl "Existential sealing is not allowed here.")

  | AmbiguousInstance(pos, env, s) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos
      ( textl "Ambiguous instance of signature"
      @ [ ws (suffix (Pretty.Unif.pretty_type pretty_env 0 s) (word ".")) ]
      @ textl " Try apply it explicitly.")

  | ImplicitScopeError(pos, env, err) ->
    let pretty_env = Env.pretty_env env in
    ErrorPrinter.error_p pos (pretty_implicit_scope_error pretty_env err)

  | CannotImport(pos, name) ->
    ErrorPrinter.error_p pos
      ( textl "Cannot import module"
      @ [ ws (suffix (word name) (word ".")) ])

  | DependencyLoop loop ->
    ErrorPrinter.error
      ( textl "Dependency loop:"
      @ [ Box.box
        (List.rev_map (fun name -> ws (Box.word ~attrs:[ Path ] name)) loop)
      ])
  end

let pretty_tag : Flow.tag =
  Flow.register_transform
    ~source: flow_node
    ~target: CommonTags.box_node
    ~name:   "Type error printer"
    ~provides_tags: [ CommonTags.error_report ]
    flow_pretty_printer
