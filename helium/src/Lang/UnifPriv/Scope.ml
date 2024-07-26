open TypingStructure

let empty =
  { type_scope = TVar.Map.empty
  ; inst_scope = EffInst.Map.empty
  }

let has_tvar scope x =
  TVar.Map.mem x scope.type_scope

let has_effinst scope a =
  EffInst.Map.mem a scope.inst_scope

let add_tvar scope x =
  assert (not (TVar.Map.mem x scope.type_scope));
  { scope with type_scope = TVar.Map.add x () scope.type_scope }

let add_tvar_e scope (TVar.Pack x) =
  add_tvar scope x

let add_tvar_l scope xs =
  List.fold_left add_tvar_e scope xs

let add_effinst scope a =
  { scope with inst_scope = EffInst.Map.add a () scope.inst_scope }

let to_sexpr scope =
  SExpr.tagged_list "scope"
    [ SExpr.mk_list
      (TVar.Map.fold { fold_f = fun x _ xs ->
        SExpr.mk_list
          [ Atom (TVar.unique_name x)
          ; Atom ":"
          ; Kind.to_sexpr (TVar.kind x)
          ] :: xs
        } scope.type_scope [])
    ; SExpr.of_list (fun (a, _) -> Atom (EffInst.to_string a))
      (scope.inst_scope |> EffInst.Map.bindings)
    ]
