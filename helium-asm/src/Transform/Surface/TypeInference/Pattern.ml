open Lang.Node
open Common

let coerce ~env ~pos tp1 tp2 =
  try T.Type.coerce ~env:(Env.type_env env) tp1 tp2 with
  | T.Error err ->
    raise (Error.type_mismatch ~pos ~env ~syncat:Pattern
      (TExists([], tp1)) (TExists([], tp2)) err)

let coerce_pattern ~fix pos crc pat =
  match crc with
  | T.CId _ -> pat
  | _ -> make ~fix pos (T.PCoerce(crc, pat))

type checked_patterns =
  { cps_env      : Env.t
  ; cps_exvars   : T.TVar.ex list
  ; cps_vals     : sig_field list
  ; cps_patterns : T.pattern list
  }

(* ========================================================================= *)
(* Main function *)
let rec check : type td. fix ->
      Env.t -> S.pattern -> (td, T.ttype) request -> td checked_pattern =
  fun fix env p tp_req ->
  let check_type     env = fix.check_type fix env in
  let check_pattern  env = check fix env in
  let pos = p.meta in
  let make data = make ~fix pos data in
  match p.data with
  | S.PWildcard ->
    let (tp, tp_resp) = Request.guess_type env tp_req in
    let (env, y) = Env.add_var' env tp in
    { cp_env     = env
    ; cp_exvars  = []
    ; cp_vals    = []
    ; cp_pattern = make (T.PVar y)
    ; cp_type    = tp_resp
    }

  | S.PVar name ->
    let (tp, tp_resp) = Request.guess_type env tp_req in
    let (env, y) = Env.add_var env (S.string_of_name name) tp in
    { cp_env     = env
    ; cp_exvars  = []
    ; cp_vals    = [ make_val ~fix pos name y tp ]
    ; cp_pattern = make (T.PVar y)
    ; cp_type    = tp_resp
    }

  | S.PAnnot(p, tp) ->
    let extp = check_type env tp in
    begin match tp_req with
    | Infer ->
      let (env, ex, tp) = Env.open_ex_type env extp in
      let res = check_pattern env p (Check tp) in
      { res with cp_type = Infered (ex, tp) }
    | Check tp0 ->
      let (_, tp) = Env.instantiate_ex env extp in
      let crc = coerce ~env ~pos tp0 tp in
      let res = check_pattern env p (Check tp) in
      { res with
        cp_pattern = coerce_pattern ~fix pos crc res.cp_pattern
      ; cp_type    = Checked
      }
    end

  | S.PCtor({ data = S.CPName name; _ }, args) ->
    (* TODO: Use matched type when known *)
    begin match Env.lookup_ctor env (S.string_of_ctor_name name) with
    | Some ctor ->
      check_ctor_pattern ~fix ~env ~pos name ctor args tp_req
    | None -> raise (Error.unbound_ctor name)
    end

  | S.PCtor({ data = S.CPPath(mexp, name); _ }, args) ->
    let m_res = fix.check_value fix env mexp Infer in
    let (Infered m_tp) = m_res.cv_type in
    let ctor  = check_ctor_select
      ~fix ~env ~pos ~v1_pos:mexp.meta m_res.cv_value m_tp name in
    check_ctor_pattern ~fix ~env ~pos name ctor args tp_req

and infer_and_check : fix ->
    Env.t -> S.pattern -> T.ttype -> check checked_pattern =
  fun fix env p tp ->
  let pos = p.meta in
  let res = check fix env p Infer in
  match res.cp_type with
  | Infered([], tp') ->
    let crc = coerce ~env ~pos tp tp' in
    { res with
      cp_pattern = coerce_pattern ~fix pos crc res.cp_pattern
    ; cp_type    = Checked
    }
  | Infered(_ :: _, _) ->
    failwith "Dependent patterns are not allowed here"

and check_patterns fix env pats (tps : T.named_type list) =
  match pats, tps with
  | [], [] ->
    { cps_env      = env
    ; cps_exvars   = []
    ; cps_vals     = []
    ; cps_patterns = []
    }
  | pat :: pats, nt :: tps ->
    let res1 = check fix env pat (Check nt.nt_type) in
    let res2 = check_patterns fix res1.cp_env pats tps in
    { cps_env      = res2.cps_env
    ; cps_exvars   = res1.cp_exvars @ res2.cps_exvars
    ; cps_vals     = res1.cp_vals @ res2.cps_vals
    ; cps_patterns = res1.cp_pattern :: res2.cps_patterns
    }
  | [], _ :: _ | _ :: _, [] -> assert false

(* ========================================================================= *)
(* Constructors *)

and check_ctor_pattern : type td. fix:_ -> env:_ -> pos:_ ->
    _ -> _ -> _ -> (td, T.ttype) request -> td checked_pattern =
  fun ~fix ~env ~pos name ctor args tp_req ->
  let make data = make ~fix pos data in
  let (Env.CtorValue(proof_gen, xs, tp, ctors, n)) = ctor in
  let (proof_args, sub) = Env.instantiate_args env xs in
  let proof = make (T.VTypeApp(proof_gen, proof_args)) in
  let tp    = T.Type.subst sub tp in
  let ctors = List.map (T.CtorDecl.subst sub) ctors in
  let ((tp_resp : (td, _) response), crc) =
    match tp_req with
    | Infer     -> (Infered([], tp), T.CId(tp, tp))
    | Check tp' -> (Checked, coerce ~env ~pos tp' tp)
  in
  let (env, ys, tps) = Env.open_ctor_decl env (List.nth ctors n) in
  if List.length args <> List.length tps then
    raise (Error.pattern_arity ~pos name
      (List.length args) (List.length tps));
  let resp = check_patterns fix env args tps in
  { cp_env     = resp.cps_env
  ; cp_exvars  = ys @ resp.cps_exvars
  ; cp_vals    = resp.cps_vals
  ; cp_pattern = coerce_pattern ~fix pos crc (make (T.PCtor
      { typ = tp
      ; ctors = ctors
      ; proof = proof
      ; index = n 
      ; targs = ys
      ; args  = resp.cps_patterns
      }))
  ; cp_type = tp_resp
  }

and check_ctor_select ~fix ~env ~pos ~v1_pos v1 v1_tp name =
  match check_ctor_select_loop ~fix ~env ~pos ~v1_pos v1 v1_tp name with
  | Some ctor -> ctor
  | None ->
    failwith "No such constructor"

and check_ctor_select_loop ~fix ~env ~pos ~v1_pos v1 v1_tp name =
  let (crc, decls) = TypeView.coerce_to_struct ~env ~pos:v1_pos v1_tp in
  let v1 =
    match crc with
    | T.CId _ -> v1
    | _ -> make ~fix pos (T.VCoerce(crc, v1))
  in
  let name_str = S.string_of_ctor_name name in
  match T.Decl.select_ctor decls name_str with
  | Some (xs, tp, ctors, n) ->
    let proof = make ~fix pos (T.VSelCtor(decls, v1, name_str)) in
    Some (Env.CtorValue(proof, xs, tp, ctors, n))
  | None ->
    begin match T.Decl.select_this decls with
    | Some tp ->
      let v1 = make ~fix pos (T.VSelThis(decls, v1)) in
      check_ctor_select_loop ~fix ~env ~pos ~v1_pos v1 tp name
    | None -> None
    end
