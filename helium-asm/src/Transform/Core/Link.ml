(* Transform/Core/Link.ml
 *
 * This file is part of Helium, developed under MIT license.
 * See LICENSE for details.
 *)

open Lang.Core

(** Representation of already imported unit *)
type import_value =
  { imv_var   : var          (** Name of the imported unit in current unit *)
  ; imv_value : value        (** Value, that represents imported unit      *)
  ; imv_tvars : TVar.ex list (** Imported type name in current unit        *)
  ; imv_types : Type.ex list (** Types to be substituted for imv_tvars     *)
  }

(* ========================================================================= *)
(* Helper functions *)

let make data =
  { Lang.Node.meta = Utils.UID.fresh ()
  ; Lang.Node.data = data
  }

let mk_let e cont =
  let x = Var.fresh () in
  make (ELet(x, e, cont x))

let mk_let_pure e cont =
  let x = Var.fresh () in
  make (ELet(x, e, cont x))

let rec unpack_types v tps cont =
  match tps with
  | [] -> cont v []
  | TVar.Pack a :: tps ->
    let b = TVar.clone a in
    let x = Var.fresh () in
    make (EUnpack(b, x, v,
      unpack_types (make (VVar x)) tps (fun v tps ->
      cont v (Type.Pack (Type.var b) :: tps))))

(** Builds a type abstraction with freshly generated names. It also
 * extends substitution [sub] by a renaming of old type variables [tps]
 * into freshly generated ones *)
let rec abstract_types sub tps cont =
  match tps with
  | [] -> cont sub []
  | TVar.Pack a :: tps ->
    let b = TVar.clone a in
    let tp = Type.var b in
    let sub = Subst.add_type sub a tp in
    make (EValue (make (VTypeFun(b,
      abstract_types sub tps (fun sub tps ->
      cont sub (Type.Pack tp :: tps))))))

(** Translation of single unit. [ambient] is an ambient effect in a place
 * where the unit is imported. In case of CPS units, ambient effect is
 * extended by effects handled by the unit *)
let tr_unit sub u ambient cont =
  match u with
  | UB_Direct ub ->
    mk_let (Syntax.apply_subst_in_expr sub ub.body) (fun body_x ->
    unpack_types (make (VVar body_x)) ub.types (fun v tps ->
    cont v tps ambient)) 
  | UB_CPS ub ->
    let cont_expr =
      abstract_types sub ub.types (fun sub tps ->
      let x = Var.fresh () in
      let v = make (VVar x) in
      let ambient = Type.eff_cons ambient (Type.subst sub ub.handle) in
      let body_sig = Type.tuple (List.map (Type.subst sub) ub.body_sig) in
      make (EValue (make (VFn(x, body_sig, cont v tps ambient)))))
    in
    (* rename types in the body *)
    mk_let (Syntax.apply_subst_in_expr sub ub.body) (fun body ->
    (* apply body to the answer type of the CPS: empty tuple *)
    mk_let_pure (make (ETypeApp(make (VVar body), Type.tuple []))) (fun body ->
    (* apply body to the answer effect of the CPS: ambient *)
    mk_let_pure (make (ETypeApp(make (VVar body), ambient))) (fun body ->
    (* let-bind a continuation *)
    mk_let_pure cont_expr (fun cont_var ->
    (* apply continuation *)
    make (EApp(make (VVar body), make (VVar cont_var)))))))

(** Creates let-bindings of imported units as requested names. It also creates
  * type substitution which will be applied to current unit body *)
let bind_imports ims cont =
  let bind_tvar sub (TVar.Pack a) (Type.Pack tp) =
    match Kind.equal (TVar.kind a) (Type.kind tp) with
    | Equal    -> Subst.add_type sub a tp
    | NotEqual -> assert false
  in
  let rec bind_imports ims sub =
    match ims with
    | [] -> cont sub
    | im :: ims ->
      let sub = List.fold_left2 bind_tvar sub im.imv_tvars im.imv_types in
      make (ELetPure(im.imv_var, make (EValue im.imv_value),
        bind_imports ims sub))
  in
  bind_imports ims Subst.empty

(* ========================================================================= *)

let tr_program prog =
  (* Map of already imported modules *)
  let import_cache = Hashtbl.create 32 in

  let find_implementation path =
    Hashtbl.find_opt import_cache path
  and add_implementation path imp =
    Hashtbl.add import_cache path imp
  in

  let rec tr_imports ims ambient cont =
    match ims with
    | []        -> cont [] ambient
    | im :: ims ->
      tr_import  im  ambient (fun im  ambient ->
      tr_imports ims ambient (fun ims ambient ->
      cont (im :: ims) ambient))

  and tr_import im ambient cont =
    let mk_import_value v tps =
      { imv_var   = im.im_var
      ; imv_value = v
      ; imv_tvars = im.im_types
      ; imv_types = tps
      } in
    match find_implementation im.im_path with
    | None ->
      begin match FileFinder.find_core_impl im with
      | None -> failwith
        ("Cannot find implementation of " ^ im.im_path)
      | Some p ->
        tr_imports p.sf_import ambient (fun ims ambient -> 
        bind_imports ims (fun sub ->
        tr_unit sub p.sf_body ambient (fun v tps ambient ->
        add_implementation im.im_path (v, tps);
        cont (mk_import_value v tps) ambient)))
      end
    | Some(v, tps) ->
      cont (mk_import_value v tps) ambient
  in
  (* Initial ambient effect *)
  let ambient = Type.eff_pure in

  { sf_import = []
  ; sf_body   = UB_Direct
    { types    = []
    ; body_sig = []
    ; body     =
      tr_imports prog.sf_import ambient (fun ims ambient ->
      bind_imports ims (fun sub ->
      tr_unit sub prog.sf_body ambient (fun _ _ _ ->
      make (EValue (make (VTuple []))))))
    }
  }

let flow_transform p meta =
  match tr_program p with
  | result -> Flow.return result

let flow_tag =
  Flow.register_transform
    ~source: Lang.Core.flow_node
    ~target: Lang.Core.flow_node
    ~name: "Core linking"
    ~provides_tags:
      [ CommonTags.complete_program; CommonTags.unique_type_vars; CommonTags.direct_style_unit ]
    ~preserves_tags: [ CommonTags.well_typed ]
    flow_transform
