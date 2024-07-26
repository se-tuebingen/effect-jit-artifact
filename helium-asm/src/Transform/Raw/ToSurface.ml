module S = Lang.Raw
module T = Lang.Surface
open Lang.Node

exception Not_supported of Utils.Position.t

let error_node = Flow.Node.create "Syntax not supported error"

let flow_pretty_printer pos _ =
  let open Box in
  Flow.return (ErrorPrinter.error_p pos
    (textfl "This construct is not supported (yet)."))

let pretty_error_tag : Flow.tag =
  Flow.register_transform
    ~source: error_node
    ~target: CommonTags.box_node
    ~name:   "Syntax not supported error printer"
    ~provides_tags: [ CommonTags.error_report ]
    flow_pretty_printer

(* ========================================================================= *)
let tr_name name =
  { name with data =
    match name.data with
    | S.NameThis    -> T.NameThis
    | S.NameUnit    -> T.NameUnit
    | S.NameNil     -> T.NameNil
    | S.NameLVar  x -> T.NameID  x
    | S.NameUVar  x -> T.NameID  x
    | S.NameOper  x -> T.NameBOp x
    | S.NameUOper x -> T.NameUOp x
  }

let tr_ctor_name name =
  { name with data =
    match name.data with
    | S.CNUnit   -> T.CNUnit
    | S.CNNil    -> T.CNNil
    | S.CNName x -> T.CNId x
    | S.CNOper x -> T.CNOp x
  }

let rec tr_ctor_path cp =
  { cp with data =
    match cp.data with
    | S.CPName name     -> T.CPName (tr_ctor_name name)
    | S.CPPath(e, name) -> T.CPPath(tr_expr e, tr_ctor_name name)
  }

and tr_op_path op =
  { op with data =
    match op.data with
    | S.OPName name     -> T.OPName(tr_name name)
    | S.OPPath(e, name) -> T.OPPath(tr_expr e, tr_name name)
  }

and tr_pattern pat =
  let pos = pat.meta in
  let make data = { pat with data = data } in
  { pat with data =
    match pat.data with
    | S.PWildcard       -> T.PWildcard
    | S.PName name      -> T.PVar (tr_name name)
    | S.PAnnot(pat, tp) -> T.PAnnot(tr_pattern pat, tr_expr tp)
    | S.PCtor(cp, ps)   -> T.PCtor(tr_ctor_path cp, List.map tr_pattern ps)
    | S.PRecord _       -> raise (Not_supported pos)
    | S.PList ps        ->
      List.fold_right
        (fun p rest ->
          T.PCtor(make (T.CPName (make (T.CNOp "::"))),
            [ tr_pattern p; make rest ]))
        ps
        (T.PCtor(make (T.CPName (make T.CNNil)), []))
    | S.PBOp(p1, op, p2) ->
      T.PCtor({ op with data = T.CPName {op with data = T.CNOp op.data }},
        [ tr_pattern p1; tr_pattern p2 ])
  }

and tr_inst_pattern_fn_arg ip =
  let pos = ip.meta in
  { ip with data =
    match ip.data with
    | S.IPVar a   -> T.FAEffInst a
    | S.IPTuple _ -> raise (Not_supported pos)
    | S.IPAnnot(ip, s) ->
      T.FAEffInstsAnnot([tr_inst_pattern_name ip], tr_expr s)
  }

and tr_fn_arg arg =
  let make data = { arg with data = data } in
  match arg.data with
  | S.FArgName name -> [ make (T.FAPattern (make (T.PVar (tr_name name)))) ]
  | S.FArgNamesAnnot(xs, tp) ->
    List.map (fun x ->
        let make data = { x with data = data } in
        make (T.FAPattern (make (T.PAnnot(
          make (T.PVar(tr_name x)),
          tr_expr tp))))
      ) xs
  | S.FArgPattern pat -> [ make (T.FAPattern (tr_pattern pat)) ]
  | S.FArgImplicit(xs, tp) ->
    [ make (T.FAImplicit(List.map tr_name xs, tr_expr tp)) ]
  | S.FArgExplicitInst ip -> [ tr_inst_pattern_fn_arg ip ]
  | S.FArgExplicitInstAnnot(ips, s) ->
    [ make (T.FAEffInstsAnnot(List.map tr_inst_pattern_name ips, tr_expr s)) ]
  | S.FArgImplicitInst ip -> [ tr_inst_pattern_fn_arg ip ]

and tr_fn_args args =
  match args with
  | [] -> []
  | arg :: args -> tr_fn_arg arg @ tr_fn_args args

and tr_pattern_type_farg p =
  let pos = p.meta in
  { p with data =
    match p.data with
    | S.PName x   -> T.TFA_Var (tr_name x)
    | S.PAnnot(p, tp) ->
      begin match p.data with
      | S.PName x -> T.TFA_Annot([ tr_name x ], tr_expr tp)
      | _ -> raise (Not_supported pos)
      end
    | _ -> raise (Not_supported pos)
  }

and tr_type_farg arg =
  let pos = arg.meta in
  let make data = { arg with data = data } in
  match arg.data with
  | S.FArgName name -> make (T.TFA_Var (tr_name name))
  | S.FArgNamesAnnot(xs, tp) ->
    make (T.TFA_Annot(List.map tr_name xs, tr_expr tp))
  | S.FArgPattern p -> tr_pattern_type_farg p
  | S.FArgImplicit          _ -> raise (Not_supported pos)
  | S.FArgExplicitInst      _ -> raise (Not_supported pos)
  | S.FArgExplicitInstAnnot _ -> raise (Not_supported pos)
  | S.FArgImplicitInst      _ -> raise (Not_supported pos)

and tr_type_fargs args =
  match args with
  | [] -> []
  | arg :: args -> tr_type_farg arg :: tr_type_fargs args

and tr_inst_pattern_arrow_arg ip =
  let pos = ip.meta in
  { ip with data =
    match ip.data with
    | S.IPVar a        -> raise (Not_supported pos)
    | S.IPTuple _      -> raise (Not_supported pos)
    | S.IPAnnot(ip, s) -> T.AAEffInsts([ tr_inst_pattern_name ip ], tr_expr s)
  }

and tr_inst_pattern_name ip =
  let pos = ip.meta in
  { ip with data =
    match ip.data with
    | S.IPVar a -> a
    | S.IPTuple _ -> raise (Not_supported pos)
    | S.IPAnnot _ -> raise (Not_supported pos)
  }

and tr_arrow_arg arg =
  let make data = { meta = arg.meta; data = data } in
  match arg.data with
  | S.AAType tp          -> make (T.AAType (tr_expr tp))
  | S.AANames(xs, tp)    -> make (T.AAVars(List.map tr_name xs, tr_expr tp))
  | S.AAImplicit(xs, tp) ->
    make (T.AAImplicit(List.map tr_name xs, tr_expr tp))
  | S.AAExplicitInst ip  -> tr_inst_pattern_arrow_arg ip
  | S.AAExplicitInstAnnot(ips, s) ->
    make (T.AAEffInsts(List.map tr_inst_pattern_name ips, tr_expr s))
  | S.AAImplicitInst ip  -> tr_inst_pattern_arrow_arg ip

and tr_inst_binder ip =
  let pos = ip.meta in
  { ip with data =
    match ip.data with
    | S.IPVar   x -> T.IBInst x
    | S.IPTuple _ -> raise (Not_supported pos)
    | S.IPAnnot(ip, s) ->
      T.IBAnnot(tr_inst_pattern_name ip, tr_expr s)
  }

and tr_opt_eff_inst_binder pos ip_opt =
  match ip_opt with
  | None    -> { meta = pos; data = T.IBAnon }
  | Some ip -> tr_inst_binder ip

and tr_eff_inst_expr ie =
  let pos = ie.meta in
  { ie with data =
    match ie.data with
    | S.IEVar   x -> T.EIVar x
    | S.IETuple _ -> raise (Not_supported pos)
    | S.IEProj  _ -> raise (Not_supported pos)
  }

and tr_inst_expr_name ie =
  let pos = ie.meta in
  match ie.data with
  | S.IEVar   x -> x
  | S.IETuple _ -> raise (Not_supported pos)
  | S.IEProj  _ -> raise (Not_supported pos)

and tr_path path =
  let pos = path.meta in
  match path.data with
  | S.PathName name -> tr_name name
  | S.PathSel _ -> raise (Not_supported pos)

and tr_expr e =
  let pos = e.meta in
  let make data = { e with data = data } in
  { e with data =
    match e.data with
    | S.EPlaceholder -> raise (Not_supported pos)
    | S.EKindType    -> T.EType
    | S.EKindEffect  -> T.EEffect
    | S.EKindEffsig  -> T.EEffsig
    | S.EArrowPure(args, tp) ->
      T.EArrowPure(List.map tr_arrow_arg args, tr_expr tp)
    | S.EArrowEff(args, tp, eff) ->
      T.EArrowEff(List.map tr_arrow_arg args, tr_expr tp, List.map tr_expr eff)
    | S.EHandlerType(s, tp1, eff1, tp2, eff2) ->
      T.EHandlerType(
        tr_expr s,
        tr_expr tp1,
        make (T.ERow(List.map tr_expr eff1)),
        tr_expr tp2,
        make (T.ERow(List.map tr_expr eff2)))
    | S.EInst ie -> T.EEffInst(tr_inst_expr_name ie)
    | S.EEffect es ->
      T.ERow (List.map tr_expr es)
    | S.ESigProd _ -> raise (Not_supported pos)
    | S.EName name -> T.EVar (tr_name name)
    | S.ETypeVar _ -> raise (Not_supported pos)
    | S.ELit lit   -> T.ELit lit
    | S.EFn(args, body) ->
      T.EFn(tr_fn_args args, tr_expr body)
    | S.EApp(e1, e2)    -> T.EApp(tr_expr e1, tr_expr e2)
    | S.EInstApp(e, ie) -> T.EAppInst(tr_expr e, tr_eff_inst_expr ie)
    | S.EImplicitInstApp(e, ie) ->
      T.EAppInst(tr_expr e, tr_eff_inst_expr ie)
    | S.EDefs(defs, e) ->
      (List.fold_right
        (fun def e ->
          { meta = Utils.Position.join def.meta e.meta
          ; data = T.EDef(tr_def def, e)
          })
        defs
        (tr_expr e)).data
    | S.ETypeAnnot(e, tp) -> T.ETypeAnnot(tr_expr e, tr_expr tp)
    | S.ETypeEffAnnot _   -> raise (Not_supported pos)
    | S.ETypeOf _         -> raise (Not_supported pos)
    | S.ESelect(e, path)  -> T.ESelect(tr_expr e, tr_path path)
    | S.ERecord flds      -> T.ERecord(List.map tr_field_def flds)
    | S.ERecordUpdate _   -> raise (Not_supported pos)
    | S.EList es ->
      List.fold_right
        (fun e es ->
          T.EApp(make (T.EApp(make (T.EVar (make (T.NameBOp "::"))),
            tr_expr e)),
            make es))
        es
        (T.EVar (make T.NameNil))
    | S.EUOp(op, e) ->
      T.EApp({ op with data = T.EVar { op with data = T.NameUOp op.data }},
        tr_expr e)
    | S.EBOp(e1, op, e2) ->
      T.EApp(make (T.EApp(
        { op with data = T.EVar { op with data = T.NameBOp op.data }},
        tr_expr e1)),
        tr_expr e2)
    | S.EUIf(e1, e2) ->
      T.EMatch(tr_expr e1,
      [ make (T.Clause(
          make (T.PCtor(make (T.CPName (make (T.CNId "True"))), [])),
          tr_expr e2))
      ; make (T.Clause(
          make (T.PCtor(make (T.CPName (make (T.CNId "False"))), [])),
          make (T.EVar (make T.NameUnit))))
      ])
    | S.EIf(e1, e2, e3) ->
      T.EMatch(tr_expr e1,
      [ make (T.Clause(
          make (T.PCtor(make (T.CPName (make (T.CNId "True"))), [])),
          tr_expr e2))
      ; make (T.Clause(
          make (T.PCtor(make (T.CPName (make (T.CNId "False"))), [])),
          tr_expr e3))
      ])
    | S.EHandleWith(ip_opt, e, he) ->
      T.EHandleWith(tr_opt_eff_inst_binder pos ip_opt, tr_expr e, tr_expr he)
    | S.EHandle(ip_opt, e, hs) ->
      T.EHandle(tr_opt_eff_inst_binder pos ip_opt, tr_expr e,
        List.map tr_handler hs)
    | S.EHandler(hexpr, []) -> tr_hexpr hexpr
    | S.EHandler(_, _ :: _) -> raise (Not_supported pos)
    | S.EMatch(e, cls) -> T.EMatch(tr_expr e, List.map tr_clause cls)
    | S.EStruct defs   -> T.EStruct(List.map tr_def defs)
    | S.ESig decls     -> T.ESig(List.map tr_decl decls)
    | S.EExtern str    -> T.EExtern str
    | S.ERepl cont     ->
      T.ERepl(fun () ->
        let (cmd, e) = cont () in
        try (tr_repl_cmd cmd, tr_expr e) with
        | Not_supported pos ->
          raise (CommonRepl.Error(Flow.State.create error_node pos, fun () -> ())))
  }

and tr_hexpr he =
  match he with
  | S.HEExpr e     -> (tr_expr e).data
  | S.HEClauses hs -> T.EHandler(List.map tr_handler hs)

and tr_handler h =
  let make data = { meta = h.meta; data = data } in
  make begin match h.data with
  | S.HOp(name, ps, None, body) ->
    let res = make (T.PVar (make (T.NameID "resume"))) in
    T.HOp(tr_op_path name, List.map tr_pattern ps, res, tr_expr body)
  | S.HOp(name, ps, Some res, body) ->
    T.HOp(tr_op_path name, List.map tr_pattern ps, tr_pattern res,
      tr_expr body)
  | S.HReturn(pat, body) ->
    T.HReturn(tr_pattern pat, tr_expr body)
  | S.HFinally(pat, body) ->
    T.HFinally(tr_pattern pat, tr_expr body)
  end

and tr_clause cl =
  { cl with data =
    match cl.data with
    | S.Clause(pat, body) -> T.Clause(tr_pattern pat, tr_expr body)
  }

and tr_rec_fun rf =
  match rf.data with
  | S.RecVal(name, body)       -> (tr_name name, [], tr_expr body)
  | S.RecFun(name, args, body) -> (tr_name name, tr_fn_args args, tr_expr body)

and tr_field_def fd =
  { fd with data =
    match fd.data with
    | S.FieldName(name, value) -> T.FieldName(tr_name name, tr_expr value)
    | S.FieldSel _ -> raise (Not_supported fd.meta)
  }

and tr_typedef td =
  { td with data =
    match td.data with
    | S.TDData(name, args, ctors) ->
      T.TDData(tr_name name, tr_type_fargs args, List.map tr_ctor_decl ctors)
    | S.TDRecord(name, args, flds) ->
      T.TDRecord(tr_name name, tr_type_fargs args, List.map tr_field_decl flds)
    | S.TDEffsig(name, args, ops) ->
      T.TDEffsig(tr_name name, tr_type_fargs args, List.map tr_op_decl ops)
  }

and tr_ctor_decl ctor =
  { ctor with data =
    match ctor.data with
    | S.CtorDecl(name, args) ->
      T.CtorDecl(tr_ctor_name name, List.map tr_arrow_arg args)
  }

and tr_field_decl fld =
  { fld with data =
    match fld.data with
    | S.FieldDecl(name, tp) ->
      T.FieldDecl(tr_name name, tr_expr tp)
  }

and tr_op_decl op =
  { op with data =
    match op.data with
    | S.OpDecl(name, args, tp) ->
      T.OpDecl(tr_name name, List.map tr_arrow_arg args, tr_expr tp)
  }

and tr_def def =
  let pos = def.meta in
  { def with data =
    match def.data with
    | S.DefLet(pat, body) ->
      let pat  = tr_pattern pat in
      let body = tr_expr body   in
      begin match pat.data with
      | T.PVar name when T.is_value body -> T.DLetVal(name, body)
      | _ -> T.DLetPat(pat, body)
      end
    | S.DefFun(name, args, body) ->
      T.DLetFn(tr_name name, tr_fn_args args, tr_expr body)
    | S.DefLetRec rfs ->
      T.DLetRec (List.map tr_rec_fun rfs)
    | S.DefType(name, [], body) ->
      let body = tr_expr body in
      if T.is_value body then
        T.DLetVal(tr_name name, body)
      else
        T.DLetPat({ name with data = T.PVar (tr_name name) }, body)
    | S.DefType(name, args, body) ->
      T.DLetFn(tr_name name, tr_fn_args args, tr_expr body)
    | S.DefAbsType _ -> raise (Not_supported pos)
    | S.DefTypedef td ->
      T.DTypedef (tr_typedef td)
    | S.DefTypedefRec tds ->
      T.DTypedefRec (List.map tr_typedef tds)
    | S.DefHandle(ip_opt, hs) ->
      T.DHandle(tr_opt_eff_inst_binder pos ip_opt, List.map tr_handler hs)
    | S.DefHandleWith(ip_opt, he) ->
      T.DHandleWith(tr_opt_eff_inst_binder pos ip_opt, tr_expr he)
    | S.DefOpen e ->
      T.DOpen (tr_expr e)
    | S.DefOpenType e ->
      T.DWeakOpen (tr_expr e)
    | S.DefInclude e ->
      T.DInclude (tr_expr e)
    | S.DefIncludeType e ->
      T.DWeakInclude (tr_expr e)
  }

and tr_decl decl =
  let make data = { decl with data = data } in
  make begin match decl.data with
  | S.DeclValSig(name, tp) ->
    T.DeclValSig(tr_name name, tr_expr tp)
  | S.DeclType(name, [], body) ->
    T.DeclValDef(tr_name name, tr_expr body)
  | S.DeclType(name, args, body) ->
    T.DeclValDef(tr_name name, make (T.EFn(tr_fn_args args, tr_expr body)))
  | S.DeclTypedef td ->
    T.DeclTypedef (tr_typedef td)
  | S.DeclTypedefRec tds ->
    T.DeclTypedefRec (List.map tr_typedef tds)
  | S.DeclOpen e ->
    T.DeclOpen (tr_expr e)
  | S.DeclOpenType e ->
    T.DeclWeakOpen (tr_expr e)
  | S.DeclInclude e ->
    T.DeclInclude (tr_expr e)
  | S.DeclIncludeType e ->
    T.DeclWeakInclude (tr_expr e)
  end

and tr_repl_cmd cmd =
  { cmd with data =
    match cmd.data with
    | S.ReplExit     -> print_newline (); exit 0
    | S.ReplExpr e   -> T.ReplExpr (tr_expr e)
    | S.ReplImport m -> T.ReplImport m
    | S.ReplDef def  -> T.ReplDef (tr_def def)
  }

let tr_preamble_decl pd =
  let make data = { pd with data = data } in
  make begin match pd.data with
  | S.PDImport name -> T.PDImport name
  | S.PDHandler eff -> T.PDHandler (make (T.ERow (List.map tr_expr eff)))
  end

let tr_program prog =
  { T.sf_pos      = prog.S.sf_pos
  ; T.sf_preamble = List.map tr_preamble_decl prog.S.sf_preamble
  ; T.sf_defs     = List.map tr_def prog.S.sf_defs
  }

let tr_interface intf =
  { T.if_pos      = intf.S.if_pos
  ; T.if_preamble = List.map tr_preamble_decl intf.S.if_preamble
  ; T.if_decls    = List.map tr_decl intf.S.if_decls
  }

(* ========================================================================= *)

let source_flow_transform p meta =
  match tr_program p with
  | result -> Flow.return result
  | exception (Not_supported pos) ->
    Flow.error ~node:error_node pos

let intf_flow_transform intf meta =
  match tr_interface intf with
  | result -> Flow.return result
  | exception (Not_supported pos) ->
    Flow.error ~node:error_node pos

let source_flow_tag =
  Flow.register_transform
    ~source: S.flow_node
    ~target: T.flow_node
    ~name: "Raw --> Surface (post-parsing)"
    source_flow_transform

let intf_flow_tag =
  Flow.register_transform
    ~source: S.intf_flow_node
    ~target: T.intf_flow_node
    ~name: "Raw --> Surface (post-parsing, interface)"
    intf_flow_transform
