open TypingStructure

type t = effinst_expr

val instance : effinst -> effinst_expr
val implicit : implicit_effinst -> effinst_expr

val view : effinst_expr -> effinst_expr_view

val equal : effinst_expr -> effinst_expr -> bool
