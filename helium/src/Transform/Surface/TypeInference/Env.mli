open Lang.Unif

type t

type var_value =
| VValue of value_data * ttype
| VOp    of value * TVar.ex list * effsig * op_decl list * int
| VCtor  of value * TVar.ex list * ttype * ctor_decl list * int

type op_value =
| OpValue of value * TVar.ex list * effsig * op_decl list * int

type ctor_value =
| CtorValue of value * TVar.ex list * ttype * ctor_decl list * int

type field_value =
| FieldValue of value * TVar.ex list * ttype * field_decl list * int

type instance_guess =
| InstNo
| InstAmbiguous
| InstUnique of effinst_expr

val empty : FileFinder.t -> t

val type_env    : t -> type_env
val scope       : t -> scope
val pretty_env  : t -> Pretty.Unif.env
val file_finder : t -> FileFinder.t

(** Extend environment with given type variables. Given variables must be
unique and may not occur in environment *)
val add_tvar_l : t -> TVar.ex list -> t

val add_effinst        : t -> string -> effsig -> t * effinst
val add_hidden_effinst : t -> effsig -> t * effinst

val add_value : t -> string -> value_data -> ttype -> t
val add_var   : t -> string -> ttype -> t * var
val add_var'  : t -> ttype -> t * var

val add_op : t -> string -> value ->
  TVar.ex list * effsig * op_decl list * int -> t

val add_ctor : t -> string -> value ->
  TVar.ex list * ttype * ctor_decl list * int -> t

val add_field : t -> string -> value ->
  TVar.ex list * ttype * field_decl list * int -> t

val lookup_effinst : t -> string -> (effinst * effsig) option
val lookup_var     : t -> string -> var_value option
val lookup_op      : t -> string -> op_value option 
val lookup_ctor    : t -> string -> ctor_value option
val lookup_field   : t -> string -> field_value option

val open_ex_type   : t -> ex_type -> t * TVar.ex list * ttype
val instantiate_ex : t -> ex_type -> type_instance list * ttype

val instantiate_args : t -> TVar.ex list -> type_arg list * subst

val open_op_decl : t -> op_decl -> t * TVar.ex list * named_type list * ex_type
val open_ctor_decl : t -> ctor_decl -> t * TVar.ex list * named_type list

val prove_empty : t -> ktype neutral_type -> value option

val uvars : t -> UVar.Set.t

val generalizable_insts : t -> implicit_effinst list

val enter_implicit_scope : t -> t

(** may raise ImplicitScope.Error *)
val leave_implicit_scope : t -> unit

(** may raise ImplicitScope.Error *)
val create_implicit_instance :
  t -> Utils.Position.t -> effsig -> implicit_effinst

val guess_instance : t -> effsig -> instance_guess

(** Import given unit. Returns variable representing given unit and optionally
  substitution representing correct type names if the unit was already
  imported *)
val import : t -> import -> t * var * subst option
