open Common

(* In fix definitions rewrite type functions (represented as 0 arity functions) to use indirection.
   For example:

  fix r
    fn -> fn xs -> match xs with
      | [] -> 0
      | _ : xs' -> 1 + app (app r.0 []) [xs']
  in ...

  is translated into:

  fix r
    fn-redex -> r.1
    fn -> fn xs -> match xs with
      | [] -> 0
      | _ : xs' -> 1 + app (app r.0 []) [xs']
  in ...

  This allows for safe inlining of recursive functions and
  prevents from unnecessary code expansion if inlined
  function is not applied to arguments. *)
val make_type_functions_indirect : T.expr -> T.expr


(* Rewrite curried multi argument functions to allow optimization:
   For example:

  fix r
    fn a -> fn b -> app (app r.0 [a - 1]) [b - 1]
  in ...

  is rewritten to:

  fix r
    fn-redex a -> fn-redex b -> app r.1 [a - 1, b - 1]
    fn a b -> app (app r.0 [a - 1]) [b - 1]
  in ...

  which is later further optimized by the inline transformation to:

  fix r
    fn-redex a -> fn-redex b -> app r.1 [a - 1, b - 1]
    fn a b -> app r.1 [a - 1, b - 1]
  in ... *)
val arity_rewrite : T.expr -> T.expr

(* Find potential redexes over constructors and ops and mark them syntactically. *)
val find_redexes : T.expr -> T.expr

val eta_let : T.expr -> T.expr

(* Rewrite:
    let x1 =
      let x2 = A in B
    in C

   into:
    let x2 = A in
    let x1 = B in
    in C *)
val hoist_let_let : T.expr -> T.expr

(* Rewrite applications of known functions to let expressions to enable more inlining *)
val app_to_let : T.expr -> T.expr

(* Rewrite projections over variables to allow better inlining *)
val proj_to_field_accessor : T.expr -> T.expr


(* Remove variable aliases created with let expressions *)
val alias : T.expr -> T.expr

(* Inline optimization is able to inline fields of records, functions defined in fix expressions and
   any pure expressions that are used only once. *)
val inline : T.expr -> T.expr

val beta_reduce : T.expr -> T.expr

(* Removed unreferenced let-pures *)
val let_pure_unused : T.expr -> T.expr

val eta_reduce : T.expr -> T.expr

(* Miscellaneous simple rewrites:
  - Rewrites primitive operations with one constant arguments to their specialized versions.
  - Simplifies switch expressions with one branch *)
val simple_rewrites : T.expr -> T.expr

(* Lifts closed definitions to global definitions. *)
val lambda_lifting  : T.expr -> T.program

val optimize : T.program -> T.program