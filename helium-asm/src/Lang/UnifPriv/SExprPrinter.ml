open TypingStructure
open Node
open Syntax

let tr_tvar_binder x =
  SExpr.mk_list
  [ Atom (TVar.unique_name x)
  ; Special "::"
  ; Kind.to_sexpr (TVar.kind x)
  ]

let tr_tvar_binder_e (TVar.Pack x) =
  tr_tvar_binder x

(* ========================================================================= *)

let rec tr_subst sub =
  [ SExpr.mk_list
    (TypeSubst.fold { fold_f = fun x tp xs ->
        SExpr.mk_list [ Atom (TVar.unique_name x); tr_type tp ] :: xs
      } sub.sub_type [])
  ; SExpr.of_list (fun (a, b) ->
      SExpr.mk_list
        [ Atom (EffInst.to_string a); tr_effinst_expr b ])
    (sub.sub_inst |> EffInst.Map.bindings)
  ]

and tr_named_type nt =
  tr_type nt.nt_type

and tr_effinst_expr ie =
  match EffInstExpr.view ie with
  | IEInstance a -> SExpr.Atom (EffInst.to_string a)
  | IEImplicit i -> SExpr.mk_list
    [ Atom (Utils.UID.to_string i.iei_uid)
    ; Special ":"
    ; tr_type i.iei_sig
    ]

and tr_op_decl op =
  match op with
  | OpDecl(name, targs, tps, tp) ->
    SExpr.mk_list
      [ Atom name
      ; SExpr.of_list tr_tvar_binder_e targs
      ; SExpr.of_list tr_named_type tps
      ; tr_ex_type tp
      ]

and tr_ctor_decl ctor =
  match ctor with
  | CtorDecl(name, targs, tp) ->
    SExpr.mk_list
      ( Atom name
      :: SExpr.of_list tr_tvar_binder_e targs
      :: List.map tr_named_type tp)

and tr_field_decl fld =
  match fld with
  | FieldDecl(name, tp) ->
    SExpr.mk_list [ Atom name; tr_type tp ]

and tr_decl decl =
  match decl with
  | DeclThis tp ->
    SExpr.tagged_list "this" [ tr_type tp ]
  | DeclTypedef tp ->
    SExpr.tagged_list "typedef" [ tr_type tp ]
  | DeclVal(name, tp) ->
    SExpr.tagged_list "val" [ Atom name; tr_type tp ]
  | DeclOp(xs, s, ops, n) ->
    SExpr.tagged_list "op"
      [ SExpr.of_list tr_tvar_binder_e xs
      ; tr_type s
      ; SExpr.of_list tr_op_decl ops
      ; SExpr.Int n
      ]
  | DeclCtor(xs, tp, ctors, n) ->
    SExpr.tagged_list "ctor"
      [ SExpr.of_list tr_tvar_binder_e xs
      ; tr_type tp
      ; SExpr.of_list tr_ctor_decl ctors
      ; SExpr.Int n
      ]
  | DeclField(xs, tp, flds, n) ->
    SExpr.tagged_list "field"
      [ SExpr.of_list tr_tvar_binder_e xs
      ; tr_type tp
      ; SExpr.of_list tr_field_decl flds
      ; SExpr.Int n
      ]

and tr_type : type k. k typ -> SExpr.t =
  fun tp ->
  match Type.view tp with
  | TEffPure  ->
    SExpr.tagged_list "row" (tr_row tp)
  | TEffInst _ ->
    SExpr.tagged_list "row" (tr_row tp)
  | TEffCons _ ->
    SExpr.tagged_list "row" (tr_row tp)
  | TUVar(sub, u) ->
    SExpr.tagged_list "uvar" ( Atom (UVar.unique_name u) :: tr_subst sub)
  | TBase b -> SExpr.Special (RichBaseType.name b)
  | TNeutral neu ->
    tr_neutral neu []
  | TArrow(_, tp1, tp2, eff) ->
    SExpr.tagged_list "->"
    [ tr_type tp1
    ; tr_ex_type tp2
    ; SExpr.mk_list (tr_row eff)
    ]
  | TForall(xs, tp) ->
    SExpr.tagged_list "forall"
    [ SExpr.of_list tr_tvar_binder_e xs
    ; tr_type tp
    ]
  | TForallInst(a, s, tp) ->
    SExpr.tagged_list "forall-inst"
    [ Atom (EffInst.to_string a)
    ; tr_type s
    ; tr_type tp
    ]
  | THandler(s, tp1, eff1, tp2, eff2) ->
    SExpr.tagged_list "handler"
    [ tr_type s
    ; tr_ex_type tp1
    ; tr_type eff1
    ; tr_ex_type tp2
    ; tr_type eff2
    ]
  | TFun(x, tp) ->
    SExpr.tagged_list "fn"
      [ tr_tvar_binder x
      ; tr_type tp
      ]
  | TStruct decls ->
    SExpr.tagged_list "struct"
      (List.map tr_decl decls)
  | TTypeWit extp ->
    SExpr.tagged_list "type" [ tr_ex_type extp ]
  | TEffectWit eff ->
    SExpr.tagged_list "effect" (tr_row eff)
  | TEffsigWit s ->
    SExpr.tagged_list "effsig" [ tr_type s ]
  | TDataDef(tp, ctors) ->
    SExpr.tagged_list "data" (tr_type tp :: List.map tr_ctor_decl ctors)
  | TRecordDef(tp, flds) ->
    SExpr.tagged_list "record" (tr_type tp :: List.map tr_field_decl flds)
  | TEffsigDef(s, ops) ->
    SExpr.tagged_list "effect-sig" (tr_type s :: List.map tr_op_decl ops)

and tr_row : effect -> SExpr.t list=
  fun eff ->
  match Type.view eff with
  | TEffPure   -> []
  | TEffInst a -> [ SExpr.tagged_list "inst" [ tr_effinst_expr a ] ]
  | TEffCons(eff1, eff2) ->
    tr_row eff1 @ tr_row eff2
  | TUVar _ | TNeutral _ -> [ tr_type eff ]

and tr_neutral : type k. k neutral_type -> SExpr.t list -> SExpr.t =
  fun neu rest ->
  match neu with
  | TVar x ->
    SExpr.tagged_list "var" (Atom (TVar.unique_name x) :: rest)
  | TApp(neu, tp) ->
    tr_neutral neu (tr_type tp :: rest)

and tr_ex_type (TExists(ex, tp)) =
  SExpr.tagged_list "exists"
  [ SExpr.of_list tr_tvar_binder_e ex
  ; tr_type tp
  ]

(* ========================================================================= *)

let tr_type_instance (TpInst(x, tp)) =
  SExpr.mk_list [ tr_tvar_binder x; tr_type tp ]

let tr_type_arg (TpArg tp) =
  tr_type tp

(* ========================================================================= *)

let tr_var_binder x =
  SExpr.mk_list
  [ Atom (Var.unique_name x)
  ; Special ":"
  ; tr_type (Var.typ x)
  ]

(* ========================================================================= *)

let rec tr_coercion crc =
  match crc with
  | CId(tp1, tp2) -> SExpr.tagged_list "id" [ tr_type tp1; tr_type tp2 ]
  | CArrow { arg_crc; res_crc; eff_in; eff_out; _ } ->
    SExpr.tagged_list "->"
    [ tr_coercion arg_crc
    ; tr_ex_coercion res_crc
    ; SExpr.mk_list (tr_row eff_in)
    ; SExpr.mk_list (tr_row eff_out)
    ]
  | CGen(crc, xs, tp) ->
    SExpr.tagged_list "gen"
    [ tr_coercion crc
    ; SExpr.of_list tr_tvar_binder_e xs 
    ; tr_type tp
    ]
  | CInst(crc, insts, tp) ->
    SExpr.tagged_list "inst"
    [ tr_coercion crc
    ; SExpr.of_list tr_type_instance insts
    ; tr_type tp
    ]
  | CForallInst(a, s, crc) ->
    SExpr.tagged_list "forall-inst"
    [ Atom (EffInst.to_string a)
    ; tr_type s
    ; tr_coercion crc
    ]
  | CHandler cdata ->
    SExpr.tagged_list "handler"
    [ tr_type cdata.effsig
    ; SExpr.tagged_list "in"
      [ tr_ex_coercion cdata.in_crc
      ; SExpr.mk_list (tr_row cdata.in_eff_in)
      ; SExpr.mk_list (tr_row cdata.in_eff_out)
      ]
    ; SExpr.tagged_list "out"
      [ tr_ex_coercion cdata.out_crc
      ; SExpr.mk_list (tr_row cdata.out_eff_in)
      ; SExpr.mk_list (tr_row cdata.out_eff_out)
      ]
    ]
  | CStruct(decls, crcs) ->
    SExpr.tagged_list "struct"
    [ SExpr.of_list tr_decl decls
    ; SExpr.of_list tr_decl_coercion crcs
    ]
  | CDataDefSeal(tp, ctors) ->
    SExpr.tagged_list "data-seal"
      (tr_type tp :: List.map tr_ctor_decl ctors)
  | CRecordDefSeal(tp, flds) ->
    SExpr.tagged_list "record-seal"
      (tr_type tp :: List.map tr_field_decl flds)
  | CEffsigDefSeal(s, ops) ->
    SExpr.tagged_list "effect-sig-seal"
      (tr_type s :: List.map tr_op_decl ops)
  | CThis(decls, crc) ->
    SExpr.tagged_list "this"
    [ SExpr.of_list tr_decl decls
    ; tr_coercion crc
    ]
  | CApplyInst(c1, ie, c2) ->
    SExpr.tagged_list "apply-inst"
    [ tr_coercion c1
    ; tr_effinst_expr ie
    ; tr_coercion c2
    ]

and tr_ex_coercion crc =
  match crc with
  | CExId(extp1, extp2) ->
    SExpr.tagged_list "id" [ tr_ex_type extp1; tr_ex_type extp2 ]
  | CExPack(ex, crc, insts, tp) ->
    SExpr.tagged_list "expack"
    [ SExpr.of_list tr_tvar_binder_e ex
    ; tr_coercion crc
    ; SExpr.of_list tr_type_instance insts
    ; tr_type tp
    ]

and tr_decl_coercion crc =
  match crc with
  | DCThis crc ->
    SExpr.tagged_list "this" [ tr_coercion crc ]
  | DCTypedef crc ->
    SExpr.tagged_list "typedef" [ tr_coercion crc ]
  | DCVal(name, crc) ->
    SExpr.tagged_list "val" [ Atom name; tr_coercion crc ]
  | DCOp(xs, s, ops, insts, n) ->
    SExpr.tagged_list "op"
      [ SExpr.of_list tr_tvar_binder_e xs
      ; tr_type s
      ; SExpr.of_list tr_op_decl ops
      ; SExpr.of_list tr_type_instance insts
      ; SExpr.Int n
      ]
  | DCCtor(xs, tp, ctors, insts, n) ->
    SExpr.tagged_list "ctor"
      [ SExpr.of_list tr_tvar_binder_e xs
      ; tr_type tp
      ; SExpr.of_list tr_ctor_decl ctors
      ; SExpr.of_list tr_type_instance insts
      ; SExpr.Int n
      ]
  | DCField(xs, tp, flds, insts, n) ->
    SExpr.tagged_list "field"
      [ SExpr.of_list tr_tvar_binder_e xs
      ; tr_type tp
      ; SExpr.of_list tr_field_decl flds
      ; SExpr.of_list tr_type_instance insts
      ; SExpr.Int n
      ]
  | DCThisSel(decls, crc) ->
    SExpr.tagged_list "this-sel"
      [ SExpr.of_list tr_decl decls
      ; tr_decl_coercion crc
      ]
  | DCOpVal(xs, s, ops, n, crc) ->
    SExpr.tagged_list "op-val"
      [ SExpr.of_list tr_tvar_binder_e xs
      ; tr_type s
      ; SExpr.of_list tr_op_decl ops
      ; SExpr.Int n
      ; tr_coercion crc
      ]
  | DCCtorVal(xs, s, ctors, n, crc) ->
    SExpr.tagged_list "ctor-val"
      [ SExpr.of_list tr_tvar_binder_e xs
      ; tr_type s
      ; SExpr.of_list tr_ctor_decl ctors
      ; SExpr.Int n
      ; tr_coercion crc
      ]

(* ========================================================================= *)

let rec tr_pattern p =
  match p.data with
  | PVar x    -> SExpr.tagged_list "var" [ tr_var_binder x ]
  | PCoerce(crc, p) ->
    SExpr.tagged_list "coerce" [ tr_coercion crc; tr_pattern p ]
  | PCtor { typ = _; ctors = _; proof; index; targs; args } ->
    SExpr.tagged_list "ctor"
      (  tr_value proof
      :: Int index
      :: SExpr.of_list tr_tvar_binder_e targs
      :: List.map tr_pattern args)

and tr_expr e =
  match e.data with
  | EValue v -> SExpr.tagged_list "val" [ tr_value v ]
  | ECoerce(crc, e) ->
    SExpr.tagged_list "coerce" [ tr_ex_coercion crc; tr_expr e ]
  | EPack(insts, extp, e) ->
    SExpr.tagged_list "pack"
    [ SExpr.of_list tr_type_instance insts
    ; tr_ex_type extp
    ; tr_expr e
    ]
  | ELet(ex, x, e1, e2) ->
    SExpr.tagged_list "let"
    [ SExpr.of_list tr_tvar_binder_e ex
    ; SExpr.mk_list [ tr_var_binder x; tr_expr e1 ]
    ; tr_expr e2
    ]
  | EFix(rfs, e) ->
    SExpr.tagged_list "fix"
    [ SExpr.of_list tr_rec_function rfs
    ; tr_expr e
    ]
  | ETypeDef(tds, e) ->
    SExpr.tagged_list "typedef"
    [ SExpr.of_list (fun (TypeDef(tx, x)) -> SExpr.mk_list
        [ tr_tvar_binder tx ; tr_var_binder x ]
      ) tds
    ; tr_expr e
    ]
  | EApp(v1, v2) ->
    SExpr.mk_list [ tr_value v1; tr_value v2 ]
  | EInstApp(v, a) ->
    SExpr.mk_list [ tr_value v; tr_effinst_expr a ]
  | EMatch(e, cls, _) ->
    SExpr.tagged_list "match"
      ( tr_value e :: List.map tr_clause cls)
  | EEmptyMatch(e, proof, _) ->
    SExpr.tagged_list "empty-match"
      [ tr_value e; tr_value proof ]
  | EHandle
      { effinst
      ; effsig
      ; proof
      ; body
      ; op_handlers
      ; ret_clauses
      ; fin_clauses
      ; _
      } ->
    SExpr.tagged_list "handle"
      [ Atom (EffInst.to_string effinst)
      ; tr_type  effsig
      ; tr_value proof
      ; tr_expr  body
      ; SExpr.of_list tr_op_handler op_handlers
      ; SExpr.mk_list 
        [ SExpr.of_list tr_tvar_binder_e (fst ret_clauses)
        ; SExpr.of_list tr_clause (snd ret_clauses)
        ]
      ; SExpr.mk_list
        [ SExpr.of_list tr_tvar_binder_e (fst fin_clauses)
        ; SExpr.of_list tr_clause (snd fin_clauses)
        ]
      ]
  | EHandleWith(a, s, e, v) ->
    SExpr.tagged_list "handle-with"
    [ Atom (EffInst.to_string a)
    ; tr_type s
    ; tr_expr e
    ; tr_value v
    ]
  | EOp(proof, n, a, targs, args) ->
    SExpr.tagged_list "op"
      (  tr_value proof
      :: Int n
      :: Atom (EffInst.to_string a)
      :: SExpr.of_list tr_type_arg targs
      :: List.map tr_value args)
  | ERepl(_, extp, eff, prompt) ->
    SExpr.tagged_list "repl"
      (tr_ex_type extp :: tr_row eff)
  | EReplExpr(e1, _, e2) ->
    SExpr.tagged_list "repl-expr" [ tr_expr e1; tr_expr e2 ]
  | EReplImport(_, e) ->
    SExpr.tagged_list "repl-import" [ tr_expr e ]

and tr_rec_function rf =
  match rf with
  | RFFun(x, xs, y, body) ->
    SExpr.tagged_list "fun"
    [ tr_var_binder x
    ; SExpr.of_list tr_tvar_binder_e xs
    ; tr_var_binder y
    ; tr_expr body
    ]
  | RFInstFun(x, xs, a, s, body) ->
    SExpr.tagged_list "inst-fun"
    [ tr_var_binder x
    ; SExpr.of_list tr_tvar_binder_e xs
    ; Atom (EffInst.to_string a)
    ; tr_type s
    ; tr_expr body
    ]
  | RFHandler(x, xs, _, _, _, e) ->
    SExpr.tagged_list "handler"
    [ tr_var_binder x
    ; SExpr.of_list tr_tvar_binder_e xs
    ; tr_expr e
    ]

and tr_clause { data = Clause(p, e); _ } =
  SExpr.mk_list [ tr_pattern p; tr_expr e ]

and tr_op_handler { data = HOp(n, ex, ps, p, e); _ } =
  SExpr.mk_list
   [ Int n
   ; SExpr.of_list tr_tvar_binder_e ex
   ; SExpr.of_list tr_pattern ps
   ; tr_pattern p
   ; tr_expr e
   ]

and tr_value v =
  match v.data with
  | VLit lit ->
    SExpr.tagged_list "lit" [ Atom (RichBaseType.to_string lit) ]
  | VVar x -> SExpr.tagged_list "var" [ Atom (Var.unique_name x) ]
  | VCoerce(crc, v) ->
    SExpr.tagged_list "coerce" [ tr_coercion crc; tr_value v ]
  | VVarFn(x, body) ->
    SExpr.tagged_list "fn" [ tr_var_binder x; tr_expr body ]
  | VFn(pat, body, _) ->
    SExpr.tagged_list "fn" [ tr_pattern pat; tr_expr body ]
  | VTypeFun(xs, body) ->
    SExpr.tagged_list "type-fn"
    [ SExpr.of_list tr_tvar_binder_e xs
    ; tr_value body
    ]
  | VTypeFunE(xs, body) ->
    SExpr.tagged_list "type-fn-e"
    [ SExpr.of_list tr_tvar_binder_e xs
    ; tr_expr body
    ]
  | VTypeApp(v, tps) ->
    SExpr.mk_list (tr_value v :: List.map tr_type_arg tps)
  | VInstFun(a, s, body) ->
    SExpr.tagged_list "inst-fn"
      [ Atom (EffInst.to_string a)
      ; tr_type s
      ; tr_expr body
      ]
  | VHandler
      { effsig
      ; proof
      ; op_handlers
      ; ret_clauses
      ; fin_clauses
      ; _
      } ->
    SExpr.tagged_list "handler"
      [ tr_type  effsig
      ; tr_value proof
      ; SExpr.of_list tr_op_handler op_handlers
      ; SExpr.mk_list 
        [ SExpr.of_list tr_tvar_binder_e (fst ret_clauses)
        ; SExpr.of_list tr_clause (snd ret_clauses)
        ]
      ; SExpr.mk_list
        [ SExpr.of_list tr_tvar_binder_e (fst fin_clauses)
        ; SExpr.of_list tr_clause (snd fin_clauses)
        ]
      ]
  | VCtor(proof, n, targs, args) ->
    SExpr.tagged_list "ctor"
      (  tr_value proof
      :: Int n
      :: SExpr.of_list tr_type_arg targs
      :: List.map tr_value args)
  | VSelect(proof, n, v) ->
    SExpr.tagged_list "select"
      [ tr_value proof
      ; Int n
      ; tr_value v
      ]
  | VRecord(proof, vs) ->
    SExpr.tagged_list "record"
      ( tr_value proof :: List.map tr_value vs)
  | VStruct defs ->
    SExpr.tagged_list "struct" (List.map tr_struct_def defs)
  | VSelThis(_, v) ->
    SExpr.tagged_list "sel-this" [ tr_value v ]
  | VSelTypedef(_, v) ->
    SExpr.tagged_list "sel-typedef" [ tr_value v ]
  | VSelVal(_, v, name) ->
    SExpr.tagged_list "sel-val" [ Atom name; tr_value v ]
  | VSelOp(_, v, name) ->
    SExpr.tagged_list "sel-op" [ Atom name; tr_value v ]
  | VSelField(_, v, name) ->
    SExpr.tagged_list "sel-field" [ Atom name; tr_value v ]
  | VSelCtor(_, v, name) ->
    SExpr.tagged_list "sel-ctor" [ Atom name; tr_value v ]
  | VTypeWit extp ->
    SExpr.tagged_list "type" [ tr_ex_type extp ]
  | VEffectWit eff ->
    SExpr.tagged_list "effect" [ tr_type eff ]
  | VEffsigWit s ->
    SExpr.tagged_list "effsig" [ tr_type s ]
  | VExtern(name, tp) ->
    SExpr.tagged_list "extern" [ Atom name; tr_type tp ]

and tr_struct_def def =
  match def.data with
  | SDThis v ->
    SExpr.tagged_list "this" [ tr_value v ]
  | SDTypedef v ->
    SExpr.tagged_list "typedef" [ tr_value v ]
  | SDVal(name, v) ->
    SExpr.tagged_list "val" [ Atom name; tr_value v ]
  | SDOp(v, n) ->
    SExpr.tagged_list "op" [ Int n; tr_value v ]
  | SDCtor(v, n) ->
    SExpr.tagged_list "ctor" [ Int n; tr_value v ]
  | SDField(v, n) ->
    SExpr.tagged_list "field" [ Int n; tr_value v ]

let tr_source_file file =
  match file.sf_body with
  | UB_Direct body ->
    SExpr.tagged_list "unit-direct"
    [ SExpr.of_list tr_tvar_binder_e body.types
    ; SExpr.of_list tr_decl body.body_sig
    ; tr_expr body.body
    ]
  | UB_CPS body ->
    SExpr.tagged_list "unit-cps"
    [ SExpr.tagged_list "types"
      (List.map tr_tvar_binder_e body.types)
    ; SExpr.tagged_list "handle"
      (tr_row body.handle)
    ; SExpr.tagged_list "sig"
      (List.map tr_decl body.body_sig)
    ; SExpr.tagged_list "body"
      [ tr_expr body.body ]
    ]
