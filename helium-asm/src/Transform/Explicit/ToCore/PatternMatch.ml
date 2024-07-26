(* Transform/Explicit/ToCore/PatternMatch.ml
 *
 * Copyright (c) 2022 Helium Development Team
 *
 * This file is part of Helium, released under MIT license.
 * See LICENSE for details.
 *)
open Lang.Node
open Common

(** Example value, that is not matched *)
module ExVal : sig
  type t

  val hole  : t
  val reify : t -> Errors.exval 

  val refocus_any  : t -> t
  val dup_hole     : t -> t
  val refocus_ctor : t -> string -> 'a list -> t
end = struct
  type ctx =
  | Top
  | Dup  of ctx
  | Ctor of string * Errors.exval list * ctx * Errors.exval list

  type t =
  | Hole of ctx
  | Done of Errors.exval

  let hole = Hole Top

  let rec reify_ctx ctx exval =
    match ctx with
    | Top     -> exval
    | Dup ctx -> reify_ctx ctx exval
    | Ctor(name, a1, ctx, a2) ->
      reify_ctx ctx (Errors.EVCtor(name, List.rev_append a1 (exval :: a2)))

  let reify = function
    | Hole ctx   -> reify_ctx ctx Errors.EVAny
    | Done exval -> exval

  let rec refocus ev = function
    | Top -> Done ev
    | Dup ctx -> Hole ctx
    | Ctor(name, args, ctx, []) ->
      refocus (Errors.EVCtor(name, List.rev_append args [ev])) ctx
    | Ctor(name, args, ctx, _ :: a2) ->
      Hole(Ctor(name, ev :: args, ctx, a2))

  let refocus_any = function
    | Hole ctx -> refocus Errors.EVAny ctx
    | Done _   -> failwith "no hole to fill"

  let dup_hole = function
    | Hole ctx -> Hole (Dup ctx)
    | Done _   -> failwith "no hole to duplicate"

  let refocus_ctor ev name args =
    match ev with
    | Hole ctx ->
      begin match args with
      | []        -> refocus (Errors.EVCtor(name, [])) ctx
      | _ :: args -> Hole
        (Ctor(name, [], ctx, List.map (fun _ -> Errors.EVAny) args))
      end
    | Done _ -> failwith "no hole to fill"
end

(* ========================================================================= *)
(** Internal representation of patterns *)
type pattern =
| PWildcard
| PVar    of S.var * S.ttype
| PCoerce of S.coercion * S.pattern
| PCtor   of
    { proof : S.value
    ; ctors : S.ctor_decl list
    ; index : int
    ; targs : S.TVar.ex list
    ; args  : S.pattern list
    }

let rec tr_pattern p =
  match p.data with
  | S.PVar(x, tp) -> PVar(x, tp)
  | S.PCoerce(crc, p) ->
    begin match crc with
    | S.CId _ -> tr_pattern p
    | _       -> PCoerce(crc, p)
    end
  | S.PCtor c -> PCtor
      { proof = c.proof
      ; ctors = c.ctors
      ; index = c.index
      ; targs = c.targs
      ; args  = c.args
      }

(* ========================================================================= *)
(** Internal representation of clauses *)
type clause =
  { pats  : pattern list
  (** small clauses can be used many times, while large must be save as thunk
    before copying *)
  ; small : bool
  ; env   : Env.t
  ; gen   : Env.t -> T.expr
  }

(* ========================================================================= *)
(** Type of column *)
type column_type =
| CT_Var
| CT_Coerce of Env.t * S.coercion * S.pattern
| CT_Ctor   of Env.t * S.value * S.ctor_decl list

let rec pat_type env pat =
  match pat with
  | PWildcard | PVar _ -> CT_Var
  | PCoerce(crc, p)    -> CT_Coerce(env, crc, p)
  | PCtor c -> CT_Ctor(env, c.proof, c.ctors)

let rec column_type clauses =
  match clauses with
  | [] -> CT_Var
  | { pats = []; _ } :: _ -> assert false (* First column should exist *)
  | { pats = pat :: _; env = env; _ } :: clauses ->
    begin match pat_type env pat with
    | CT_Var -> column_type clauses
    | ctp    -> ctp
    end

(* ========================================================================= *)
(** Collect all variables bound by patterns *)
let rec vars_of_patterns pats =
  match pats with
  | [] -> ([], [])
  | pat :: pats ->
    let (tvs1, xs1) = vars_of_pattern  pat in
    let (tvs2, xs2) = vars_of_patterns pats in
    (tvs1 @ tvs2, xs1 @ xs2)

and vars_of_pattern pat =
  match pat with
  | PWildcard -> ([], [])
  | PVar(x, tp) -> ([], [ (x, tp) ])
  | PCoerce(_, p) -> vars_of_pattern (tr_pattern p)
  | PCtor { targs; args; _ } ->
    let (tvs, xs) = vars_of_patterns (List.map tr_pattern args) in
    (targs @ tvs, xs)

(* ========================================================================= *)
(* Variable patterns *)
let open_var_column x clauses =
  clauses |> List.map (fun cl ->
    match cl.pats with
    | [] -> assert false (* First column should exist *)
    | pat :: pats ->
      begin match pat with
      | PWildcard -> { cl with pats = pats }
      | PVar(y, _) ->
        { cl with
          pats = pats
        ; env  = Env.add_var' cl.env y x
        }
      | PCoerce _ | PCtor _ -> assert false
        (* function should be called on variable columns *)
      end
  )

let rec match_with_vars pats vars env =
  match pats, vars with
  | [],          []        -> ([], env)
  | pat :: pats, x :: vars ->
    let (pat, env) =
      match pat with
      | PVar(y, _) -> (PWildcard, Env.add_var' env y x)
      | _          -> (pat, env)
    in
    let (pats, env) = match_with_vars pats vars env in
    (pat :: pats, env)
  | _ -> assert false

(* ========================================================================= *)
(* Coercion patterns *)
let add_dummy_snd_pat cl =
  match cl.pats with
  | [] -> assert false (* First column should exist *)
  | pat :: pats ->
    { cl with
      pats = pat :: PWildcard :: pats
    }

let rec open_coerce_column clauses =
  match clauses with
  | [] -> assert false (* no coercion pattern found *)
  | cl :: clauses ->
    begin match cl.pats with
    | [] -> assert false (* First column should exist *)
    | pat :: pats ->
      begin match pat with
      | PCoerce(_, p) ->
        { cl with
          pats = PWildcard :: tr_pattern p :: pats
        } :: List.map add_dummy_snd_pat clauses
      | _ ->
        add_dummy_snd_pat cl :: open_coerce_column clauses
      end
    end

(* ========================================================================= *)
module Make(Ctx : sig
  val meta       : Utils.UID.t
  val bind_value : Env.t -> S.value -> (T.value -> T.expr) -> T.expr
  val make : 'a -> (Utils.UID.t, 'a) Lang.Node.node
  val typ  : T.ttype
end) = struct
  open Ctx

  let rec make_clause_tfun env tvs gen =
    match tvs with
    | [] -> gen env
    | S.TVar.Pack x :: tvs ->
      let (env, x) = Env.add_tvar env x in
      make (T.EValue (make (T.VTypeFun(x,
        make_clause_tfun env tvs gen))))

  let rec make_clause_fun env xs gen =
    match xs with
    | [] ->
      let x = T.Var.fresh () in
      make (T.EValue (make (T.VFn(x, T.Type.tuple [], gen env))))
    | (x, tp) :: xs ->
      let tp = Type.tr_type env tp in
      let y  = T.Var.fresh () in
      let env = Env.add_var' env x y in
      make (T.EValue (make (T.VFn(y, tp,
        make_clause_fun env xs gen))))

  let make_clause_thunk_apply thunk =
    make (T.EApp(thunk, make (T.VTuple [])))

  let rec make_clause_fun_apply env f xs cont =
    match xs with
    | [] -> cont f
    | (x, _) :: xs ->
      let g = T.Var.fresh () in
      make (T.ELetPure(g, make (T.EApp(f, make (T.VVar (Env.lookup_var env x)))),
      make_clause_fun_apply env (make (T.VVar g)) xs cont))

  let rec make_clause_tfun_apply env f tvs cont =
    match tvs with
    | [] -> cont f
    | S.TVar.Pack x :: tvs ->
      let g = T.Var.fresh () in
      make (T.ELetPure(g, make (T.ETypeApp(f, (T.Type.var (Env.lookup_tvar env x)))),
      make_clause_tfun_apply env (make (T.VVar g)) tvs cont))

  let save_clause_body cl vars cont =
    let (pats, env) = match_with_vars cl.pats vars cl.env in
    let (tvs, xs)   = vars_of_patterns pats in
    let f = T.Var.fresh () in
    make (T.ELetPure(f,
      make_clause_tfun env tvs (fun env ->
        make_clause_fun env xs cl.gen),
      cont
        { pats  = pats
        ; small = true
        ; env   = env
        ; gen   = (fun env ->
          make_clause_tfun_apply env (make (T.VVar f)) tvs (fun f ->
          make_clause_fun_apply env f xs (fun f ->
          make_clause_thunk_apply f)))
        }))

  let save_var_clause vars cl cont =
    if cl.small then cont cl
    else match cl.pats with
    | (PWildcard | PVar _ | PCoerce _) :: pats ->
      save_clause_body cl vars cont
    | [] | PCtor _ :: _ -> cont cl

  let rec tr_match_loop exval vars clauses =
    match vars with
    | [] ->
      begin match clauses with
      | [] ->
        let exval = ExVal.reify exval in
        raise (Errors.Error (NonExhaustiveMatch(meta, exval)))
      | cl :: _ -> cl.gen cl.env
      end
    | x :: vars ->
      begin match column_type clauses with
      | CT_Var ->
        let exval   = ExVal.refocus_any exval in
        let clauses = open_var_column x clauses in
        tr_match_loop exval vars clauses
      | CT_Coerce(env, c, p) ->
        let exval = ExVal.dup_hole exval in
        let y = T.Var.fresh () in
        make (T.ELetPure(y,
          Coercion.coerce meta env c (make (T.VVar x)),
          tr_match_loop exval (x :: y :: vars) (open_coerce_column clauses)))
      | CT_Ctor(env, proof, ctors) ->
        Utils.ListExt.map_cps (save_var_clause (x :: vars)) clauses
        (fun clauses ->
        Utils.ListExt.mapi_cps (tr_ctor_clause env exval x vars clauses) ctors
        (fun clauses ->
        bind_value env proof (fun proof ->
        make (T.EMatch(proof, make (T.VVar x), clauses, typ)))))
      end

  and tr_ctor_clause env exval x vars clauses n ctor cont =
    let (T.CtorDecl(name, xs, tps)) = Type.tr_ctor_decl env ctor in
    let exval = ExVal.refocus_ctor exval name tps in
    let nvars = List.map (fun _ -> T.Var.fresh ()) tps in
    Utils.ListExt.map_filter_redo_cps (fun cl cont ->
    begin match cl.pats with
    | [] -> assert false (* First column should exist *)
    | pat :: pats ->
      begin match pat with
      | PWildcard ->
        let pats' = List.map (fun tp -> PWildcard) tps in
        cont (Done { cl with pats = pats' @ pats })
      | PVar(y, _) ->
        let pats' = List.map (fun tp -> PWildcard) tps in
        cont (Done { cl with pats = pats' @ pats; env = Env.add_var' env y x })
      | PCtor { index; targs; args; _ } when n = index ->
        let cl_env = Env.add_tvars' cl.env targs xs in
        cont (Done
          { cl with
            pats = List.map tr_pattern args @ pats
          ; env  = cl_env
          })
      | PCtor _ -> cont Utils.ListExt.Drop
      | PCoerce _ ->
        (* Coercion patterns should be processed before *)
        assert false
      end
    end) clauses (fun clauses ->
    cont (T.Clause (xs, nvars, tr_match_loop exval (nvars @ vars) clauses)))
end

let tr_match ~env ~uid ~typ ~bind_value x clauses =
  let module M = Make(struct
    let meta       = uid
    let bind_value = bind_value
    let make data  = { meta = uid; data = data }
    let typ        = typ
  end) in
  M.tr_match_loop
    ExVal.hole
    [ x ]
    (List.map (fun (pat, gen) ->
      { pats  = [ tr_pattern pat ]
      ; small = false
      ; env   = env
      ; gen   = gen
      }) clauses)

let tr_matches ~uid ~typ ~bind_value ~case_name xs clauses =
  let module M = Make(struct
    let meta       = uid
    let bind_value = bind_value
    let make data  = { meta = uid; data = data }
    let typ        = typ
  end) in
  M.tr_match_loop
    (ExVal.refocus_ctor ExVal.hole case_name xs)
    xs
    (List.map (fun (env, pats, gen) ->
      { pats  = List.map tr_pattern pats
      ; small = false
      ; env   = env
      ; gen   = gen
      }) clauses)
