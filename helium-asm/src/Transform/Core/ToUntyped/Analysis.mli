open Common

(* Simple syntactic check if expression is a function *)
val is_fn : T.expr -> bool

val is_value : T.expr -> bool

(* Find combined arity of nested lambdas *)
val arity : T.expr -> int

(* Identify redexes over constructors and ops *)
val is_redex  : T.expr -> bool

module VarCount : Map.S
val lookup_var_count : 't VarCount.t -> T.Var.t -> T.field_accessor -> 't option

val count_var_uses : T.expr -> int VarCount.t

(* We can optionally provide environment list of bound variables.
   For example, when we want to check a function body *)
val no_free_vars : ?bindings: T.Var.t list -> T.expr -> bool

(* We can optionally provide environment to allow more accurate analysis *)
val syntactically_pure : ?env: T.expr OptEnv.env -> T.expr  -> bool

val not_passing_arg_further : T.Var.t -> T.expr -> bool