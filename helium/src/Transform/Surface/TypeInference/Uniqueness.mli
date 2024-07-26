open Common

val check_op_decl_uniqueness    : S.op_decl list -> unit
val check_ctor_decl_uniqueness  : S.ctor_decl list -> unit
val check_field_decl_uniqueness : S.field_decl list -> unit
val check_field_def_uniqueness  : Record.field_def list -> unit
val check_rec_fun_uniqueness    : (S.name * 'pat * 'expr) list -> unit
