open Common

(* Remove endlets before returns and distribute returns over branches. Example:

  Switch [[Const 5], [Const 5, Let, AccessVar 0, EndLet]]
  Return

  ==endlet_return==>

  Switch [[Const 5, Return], [Const 5, Let, AccessVar 0, Return]] *)
val endlet_return : T.instruction list -> T.instruction list

(* Identify tail calls and rewrite them to use TailCall instruction. *)
val tail_call : T.instruction list -> T.instruction list

(* Rewrite Let, AccessVar 0 into just Let since accumulator is not overwritten. *)
val let_accessvar : T.instruction list -> T.instruction list

(* Try to remove unused Lets *)
val let_unused : T.instruction list -> T.instruction list

(* Remove writes that overwrite the accumulator with same value as stored in it *)
val overwrite_acc_with_the_same : T.instruction list -> T.instruction list

(* Remove unread writes to the accumulator *)
val acc_unread : T.instruction list -> T.instruction list

val optimize : T.program -> T.program