open Lang.Unif

module StrMap = Map.Make(String)

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

type t =
  { var_env        : var_value StrMap.t
  ; op_env         : op_value StrMap.t
  ; ctor_env       : ctor_value StrMap.t
  ; field_env      : field_value StrMap.t
  ; effinst_list   : (effinst_expr * effsig) list
  ; effinst_env    : (effinst * effsig) StrMap.t
  ; all_vars       : var list
  ; type_env       : type_env
  ; implicit_scope : ImplicitScope.t option
  ; file_finder    : FileFinder.t
  ; imported       : (TVar.ex list * var) StrMap.t
  }

let empty ff =
  { var_env        = StrMap.empty
  ; op_env         = StrMap.empty
  ; ctor_env       = StrMap.empty
  ; field_env      = StrMap.empty
  ; effinst_list   = []
  ; effinst_env    = StrMap.empty
  ; all_vars       = []
  ; type_env       = TypeEnv.empty
  ; implicit_scope = None
  ; file_finder    = ff
  ; imported       = StrMap.empty
  }

let type_env    env = env.type_env
let scope       env = TypeEnv.scope (type_env env)
let file_finder env = env.file_finder

let pretty_env env =
  let pick_value (name, vv) =
    match vv with
    | VValue(_, tp) -> Some(name, tp)
    | _ -> None
  in
  Pretty.Unif.Env.create env.type_env
    (env.var_env
    |> StrMap.bindings
    |> Utils.ListExt.filter_map pick_value)
    (env.effinst_env
    |> StrMap.bindings
    |> List.map (fun (name, (a, _)) -> (name, a)))

let add_tvar_l env xs =
  { env with type_env = TypeEnv.add_tvar_l (type_env env) xs }

let add_effinst env name s =
  let a = EffInst.fresh () in
  { env with
    effinst_list = (EffInstExpr.instance a, s) :: env.effinst_list
  ; effinst_env  = StrMap.add name (a, s) env.effinst_env
  ; type_env     = TypeEnv.add_effinst (type_env env) a
  }, a

let add_hidden_effinst env s =
  let a = EffInst.fresh () in
  { env with
    effinst_list = (EffInstExpr.instance a, s) :: env.effinst_list
  ; type_env     = TypeEnv.add_effinst (type_env env) a
  }, a

let add_value env x v tp =
  { env with var_env = StrMap.add x (VValue(v, tp)) env.var_env }

let add_var' env tp =
  let y = Var.fresh tp in
  { env with
    all_vars = y :: env.all_vars
  }, y

let add_var env x tp =
  let (env, y) = add_var' env tp in
  (add_value env x (VVar y) tp, y)

let add_op env name v (xs, s, ops, n) =
  { env with
    var_env = StrMap.add name (VOp(v, xs, s, ops, n)) env.var_env
  ; op_env  = StrMap.add name (OpValue(v, xs, s, ops, n)) env.op_env
  }

let add_ctor env name v (xs, tp, ctors, n) =
  { env with
    var_env  = StrMap.add name (VCtor(v, xs, tp, ctors, n)) env.var_env
  ; ctor_env = StrMap.add name (CtorValue(v, xs, tp, ctors, n)) env.ctor_env
  }

let add_field env name v (xs, tp, flds, n) =
  { env with
    field_env = StrMap.add name (FieldValue(v, xs, tp, flds, n)) env.field_env
  }

let lookup_effinst env x =
  StrMap.find_opt x env.effinst_env

let lookup_var env x =
  StrMap.find_opt x env.var_env

let lookup_op env x =
  StrMap.find_opt x env.op_env

let lookup_ctor env x =
  StrMap.find_opt x env.ctor_env

let lookup_field env x =
  StrMap.find_opt x env.field_env

let open_ex_type env (TExists(ex, tp)) =
  let (tenv, xs, tp) = TypeEnv.open_type_ts env.type_env ex tp in
  let env = { env with type_env = tenv } in
  (env, xs, tp)

let instantiate_ex env extp =
  Lang.Unif.ExType.instantiate (type_env env) extp

let instantiate_args env xs =
  Lang.Unif.Type.instantiate_args (type_env env) xs

let open_op_decl env (OpDecl(_, xs, tps, extp)) =
  let (tenv, xs, tps, extp) =
    TypeEnv.open_named_types_ex_type_ts env.type_env xs tps extp in
  let env = { env with type_env = tenv } in
  (env, xs, tps, extp)

let open_ctor_decl env (CtorDecl(_, xs, tps)) =
  let (tenv, xs, tps) = TypeEnv.open_named_types_ts env.type_env xs tps in
  let env = { env with type_env = tenv } in
  (env, xs, tps)

(* ========================================================================= *)
(* Searching for proof of emptiness of given neutral type *)

let rec prove_empty_in_val ~env v tp neu =
  let make data =
    { Lang.Node.meta = Utils.UID.fresh ()
    ; Lang.Node.data = data
    } in
  World.try_alt
    (fun () ->
      let (crc, dtp, ctors) = Lang.Unif.Type.coerce_to_data_def ~env tp in
      match ctors with
      | _ :: _ -> raise (Error CannotUnify)
      | [] -> 
        Lang.Unif.Type.unify ~env dtp (Lang.Unif.Type.neutral neu);
        Some (make (VCoerce(crc, v))))
    [ (fun () ->
      let (crc, decls) = Lang.Unif.Type.coerce_to_struct ~env tp in
      prove_empty_in_struct ~env (make (VCoerce(crc, v))) decls decls neu)
    ; (fun () -> None)
    ]

and prove_empty_in_struct ~env v str decls neu =
  match decls with
  | [] -> None
  | decl :: decls ->
    begin match prove_empty_in_decl ~env v str decl neu with
    | None -> prove_empty_in_struct ~env v str decls neu
    | Some proof -> Some proof
    end

and prove_empty_in_decl ~env v str decl neu =
  let make data =
    { Lang.Node.meta = Utils.UID.fresh ()
    ; Lang.Node.data = data
    } in
  match decl with
  | DeclThis tp ->
    prove_empty_in_val ~env (make (VSelThis(str, v))) tp neu
  | DeclTypedef tp ->
    prove_empty_in_val ~env (make (VSelTypedef(str, v))) tp neu
  | DeclVal(name, tp) ->
    prove_empty_in_val ~env (make (VSelVal(str, v, name))) tp neu
  | DeclOp _ | DeclCtor _ | DeclField _ -> None

let rec prove_empty_in_vars ~env xs neu =
  let make data =
    { Lang.Node.meta = Utils.UID.fresh ()
    ; Lang.Node.data = data
    } in
  match xs with
  | [] -> None
  | x :: xs ->
    begin match prove_empty_in_val ~env (make (VVar x)) (Var.typ x) neu with
    | None -> prove_empty_in_vars ~env xs neu
    | Some proof -> Some proof
    end

let prove_empty env neu =
  prove_empty_in_vars ~env:env.type_env env.all_vars neu

(* ========================================================================= *)

let all_effinsts env =
  begin match env.implicit_scope with
  | None -> []
  | Some scope ->
    List.map
      (fun ie -> (EffInstExpr.implicit ie, ImplicitEffInst.effsig ie))
      (ImplicitScope.all_effinsts scope)
  end @ env.effinst_list

let uvars env =
  let uvars = List.fold_left
    (fun s x -> UVar.Set.union (Lang.Unif.Type.uvars (Var.typ x)) s)
    UVar.Set.empty
    env.all_vars in
  List.fold_left (fun uvars (_, s) ->
    UVar.Set.union (Lang.Unif.Type.uvars s) uvars)
    uvars
    (all_effinsts env)

let iinsts env =
  let iinsts = List.fold_left
    (fun s x ->
      ImplicitEffInst.Set.union (Lang.Unif.Type.iinsts (Var.typ x)) s)
    ImplicitEffInst.Set.empty
    env.all_vars in
  List.fold_left (fun iinsts (_, s) ->
    ImplicitEffInst.Set.union (Lang.Unif.Type.iinsts s) iinsts)
    iinsts
    (all_effinsts env)

(* ========================================================================= *)

let generalizable_insts env =
  match env.implicit_scope with
  | None -> failwith "Not in implicit scope"
  | Some scope ->
    begin match ImplicitScope.cur_effinsts scope with
    | [] -> []
    | _  -> ImplicitScope.pick_generalizable scope (iinsts env)
    end

let enter_implicit_scope env =
  { env with implicit_scope =
    Some (ImplicitScope.enter env.implicit_scope env.type_env)
  }

let leave_implicit_scope env =
  match env.implicit_scope with
  | None       -> ()
  | Some scope -> ImplicitScope.leave scope

let create_implicit_instance env pos s =
  match env.implicit_scope with
  | None -> raise (ImplicitScope.Error (NoScopeForEffInst s))
  | Some scope ->
    ImplicitScope.create_implicit_instance scope pos s

(* ========================================================================= *)

let guess_instance env s =
  let rec loop il result =
    match il with
    | []      -> result
    | (a, s1) :: il ->
      let w0 = World.save () in
      if World.try_bool (fun () ->
        Lang.Unif.Type.unify ~env:(type_env env) s s1)
      then begin
        let w1 = World.save () in
        World.rollback w0;
        match result with
        | InstAmbiguous -> assert false
        | InstNo ->
          begin match loop il (InstUnique a) with
          | InstNo -> assert false
          | InstAmbiguous -> InstAmbiguous
          | InstUnique _ ->
            World.rollback w1;
            InstUnique a
          end
        | InstUnique _ -> InstAmbiguous
      end else begin
        World.rollback w0;
        loop il result
      end
  in
  loop (all_effinsts env) InstNo

(* ========================================================================= *)

let import env im =
  match StrMap.find_opt im.im_path env.imported with
  | None ->
    let (env, xs, tp) = open_ex_type env
      (TExists(im.im_types, Lang.Unif.Type.tstruct im.im_sig)) in
    let (env, x) = add_var env im.im_name tp in
    { env with
      imported = StrMap.add im.im_path (xs, x) env.imported
    }, x, None
  | Some(xs, x) ->
    let sub = List.fold_left2 (fun sub (TVar.Pack x) (TVar.Pack y) ->
        match Kind.equal (TVar.kind x) (TVar.kind y) with
        | Equal -> Subst.extend_t sub y (Lang.Unif.Type.var x)
        | NotEqual -> assert false
      ) Subst.empty xs im.im_types in
    (env, x, Some sub)
