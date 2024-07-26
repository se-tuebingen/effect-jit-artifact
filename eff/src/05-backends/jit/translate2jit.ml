open Utils
module STe = Language.Term
module STy = Language.Type
module S = Language
module T = SyntaxJit

type state = {
  primitive_effects : (T.term * T.term) list;
  definitions : T.definition list;
  tydefs : (Language.TyName.t, T.typ) Assoc.t;
  main : T.term list;
}

let not_implemented s =
  let r = { T.id = T.Id.fresh "panic_return"; T.typ = T.Top } in
  T.Primitive ("!undefined:" ^ s, [], [ r ], T.Var r)

let not_implemented_def s =
  {
    T.name = { T.id = T.Id.fresh "panic"; T.typ = T.Bottom };
    T.value = not_implemented s;
    T.export_as = [];
  }

let not_implemented_pattern s =
  ( { T.id = T.Id.fresh "panic"; T.typ = T.Bottom },
    fun _b _e -> not_implemented ("pattern " ^ s) )

let translate_const = function
  | S.Const.Integer k -> T.Literal (T.LitInt k)
  | S.Const.String s -> T.Literal (T.LitString s)
  | S.Const.Boolean b -> T.Literal (T.LitBool b)
  | S.Const.Float f -> T.Literal (T.LitDouble f)

let rec tuple_tag _st tpes =
  T.Id.Name
    (Format.asprintf {|{"op": "eff$Tuple", "elements": [%a]}|}
       (Format.pp_print_list
          ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ")
          T.print_typ)
       (List.map (translate_type _st) tpes))

and record_tag _st fields =
  T.Id.Name
    (Format.asprintf {|{"op": "eff$Record", "fields": [%a]}|}
       (Format.pp_print_list
          ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ")
          (fun fmt (name, ty) ->
            Format.fprintf fmt {|{"name": %a, "type": %a}|} T.Id.print
              (T.Id.SrcId name) T.print_typ (translate_type _st ty)))
       (STy.Field.Map.bindings fields))

and sum_tag _st fields =
  T.Id.Name
    (Format.asprintf {|{"op": "eff$Sum", "constructors": [%a]}|}
       (Format.pp_print_list
          ~pp_sep:(fun fmt () -> Format.fprintf fmt ", ")
          (fun fmt (name, ty) ->
            Format.fprintf fmt {|{"name": %a, "arg": %a}|} T.Id.print
              (T.Id.SrcId name) T.print_typ
              (Option.map (translate_type _st) ty
              |> Option.value ~default:(T.Base T.Unit))))
       (STy.Field.Map.bindings fields))

and translate_type _st ty =
  match ty.term with
  | STy.TyParam _ -> T.Top
  | STy.Apply { ty_name; ty_args = _ } ->
      _st.tydefs |> Assoc.lookup ty_name |> Option.value ~default:T.Top
  | STy.Arrow (arg, (ret, dirt)) ->
      T.Function
        ( [ translate_type _st arg ],
          translate_type _st ret,
          if S.Dirt.is_empty dirt then T.Pure else T.Effectful )
  | STy.Tuple tys ->
      let tag = tuple_tag _st tys in
      T.Data
        ( tag,
          [ { T.cns_tag = tag; T.fields = List.map (translate_type _st) tys } ]
        )
  | STy.TyBasic S.Const.StringTy -> T.Base T.String
  | STy.TyBasic S.Const.FloatTy -> T.Base T.Double
  | STy.TyBasic (S.Const.IntegerTy | S.Const.BooleanTy) -> T.Base T.Int
  | STy.Handler (_, _) -> T.Top (* TODO *)

let translate_type_def _st = function
  | STy.Record fields ->
      let tag = record_tag _st fields in
      T.Data
        ( tag,
          [
            {
              T.cns_tag = tag;
              T.fields =
                List.map
                  (fun (_name, ty) -> translate_type _st ty)
                  (STy.Field.Map.bindings fields);
            };
          ] )
  | STy.Sum cns ->
      let tag = sum_tag _st cns in
      T.Data
        ( tag,
          List.map
            (function
              | name, None -> { T.cns_tag = T.Id.SrcId name; T.fields = [] }
              | name, Some tpe ->
                  {
                    T.cns_tag = T.Id.SrcId name;
                    T.fields = [ translate_type _st tpe ];
                  })
            (STy.Field.Map.bindings cns) )
  | STy.Inline t -> translate_type _st t

let translate_effect_handler_tag eff_def = T.Id.SrcId eff_def.term

let translate_effect_handler_ty _st eff_def =
  let name = translate_effect_handler_tag eff_def in
  T.Codata
    ( name,
      [
        {
          T.method_tag = name;
          T.params = [ translate_type _st (fst eff_def.ty) ];
          T.return = translate_type _st (snd eff_def.ty);
        };
      ] )

let translate_effect_label_name _st eff_def =
  let name = translate_effect_handler_tag eff_def in
  {
    T.id = name;
    T.typ =
      T.Base (T.Label (None, Some (translate_effect_handler_ty _st eff_def)));
  }

let translate_effect_def _st eff_def =
  {
    T.name = translate_effect_label_name _st eff_def;
    T.value = T.FreshLabel;
    T.export_as =
      [ Format.asprintf "%a" (fun x y -> STe.print_effect y x) eff_def ];
  }

let rec translate_computation _st (cmp : STe.computation) =
  match cmp.term with
  | STe.Value v -> translate_expression _st v
  | STe.LetVal (exp, abs) ->
      let var, body = translate_abstraction _st abs in
      T.Let
        ( [
            {
              T.name = var;
              T.value = translate_expression _st exp;
              T.export_as = [];
            };
          ],
          body )
  | STe.LetRec (bnds, body) ->
      T.LetRec
        ( Assoc.to_list bnds
          |> List.map (fun (name, abs) ->
                 let arg, abody = translate_abstraction _st abs in
                 {
                   T.name =
                     {
                       T.id = T.Id.SrcId name;
                       T.typ = translate_type _st (fst abs.ty);
                     };
                   T.value = T.Abs ([ arg ], abody);
                   T.export_as = [];
                 }),
          translate_computation _st body )
  | STe.Apply (f, arg) ->
      T.App (translate_expression _st f, [ translate_expression _st arg ])
  | STe.Handle (hndl, body) ->
      T.App
        ( translate_expression _st hndl,
          [ T.Abs ([], translate_computation _st body) ] )
  | STe.Call (effect, arg, abs) ->
      let hnd =
        {
          T.id = T.Id.fresh "handler";
          T.typ = translate_effect_handler_ty _st effect;
        }
      in
      let tag = translate_effect_handler_tag effect in
      let p, body = translate_abstraction _st abs in
      T.Let
        ( [
            {
              T.name = hnd;
              T.value =
                T.GetDynamic
                  ( T.Var (translate_effect_label_name _st effect),
                    T.Literal (T.LitInt 0) );
              T.export_as = [];
            };
          ],
          T.Let
            ( [
                {
                  T.name = p;
                  T.value =
                    T.Invoke
                      (T.Var hnd, tag, tag, [ translate_expression _st arg ]);
                  T.export_as = [];
                };
              ],
              body ) )
  | STe.Bind (cmp, abs) ->
      let var, body = translate_abstraction _st abs in
      T.Let
        ( [
            {
              T.name = var;
              T.value = translate_computation _st cmp;
              T.export_as = [];
            };
          ],
          body )
  | STe.CastComp (cmp, coerc) ->
      T.DebugWrap
        ( Format.asprintf "coerce to %a"
            (fun x y -> S.Coercion.print_dirty_coercion y x)
            coerc,
          translate_computation _st cmp )
  | STe.Check (annot, code) ->
      T.DebugWrap
        ( Format.asprintf "check %a" (fun x y -> Location.print y x) annot,
          translate_computation _st code )
  | STe.Match (scrutinee, clauses) ->
      let scr =
        {
          T.id = T.Id.fresh "scrutinee";
          T.typ = translate_type _st scrutinee.ty;
        }
      in
      T.Let
        ( [
            {
              T.name = scr;
              T.value = translate_expression _st scrutinee;
              T.export_as = [];
            };
          ],
          List.fold_right
            (translate_match_clause _st (T.Var scr))
            clauses non_exhaustive )

and translate_expression _st e =
  match e.term with
  | STe.Var x ->
      T.Var { T.id = T.Id.SrcId x.variable; T.typ = translate_type _st e.ty }
  | STe.Const c -> translate_const c
  | STe.Tuple es ->
      let tag = tuple_tag _st (List.map (fun e -> e.ty) es) in
      T.Construct (tag, tag, List.map (translate_expression _st) es)
  | STe.Record fields ->
      let tag = record_tag _st (STy.Field.Map.map (fun e -> e.ty) fields) in
      T.Construct
        ( tag,
          tag,
          List.map
            (fun (_, e) -> translate_expression _st e)
            (STy.Field.Map.bindings fields) )
  | STe.Variant (name, None) ->
      let tag = sum_tag _st (STy.Field.Map.singleton name None) in
      T.Construct (tag, T.Id.SrcId name, [])
  | STe.Variant (name, Some field) ->
      let tag = sum_tag _st (STy.Field.Map.singleton name (Some field.ty)) in
      T.Construct (tag, T.Id.SrcId name, [ translate_expression _st field ])
  | STe.Lambda abs ->
      let tpat, tcmp = translate_abstraction _st abs in
      T.Abs ([ tpat ], tcmp)
  | STe.CastExp (exp, coerc) ->
      T.DebugWrap
        ( Format.asprintf "coerce to %a"
            (fun x y -> S.Coercion.print_ty_coercion y x)
            coerc,
          translate_expression _st exp )
  | STe.Handler clauses
    when 1 == Assoc.length clauses.term.effect_clauses.effect_part ->
      let ign = { T.id = T.Id.Name "ignore"; T.typ = T.Ptr } in
      let vcp, vcbody = translate_abstraction _st clauses.term.value_clause in
      let body =
        {
          T.id = T.Id.fresh "handled body";
          T.typ = T.Function ([], vcp.typ, T.Effectful);
        }
      in

      let effprt =
        clauses.term.effect_clauses.effect_part |> Assoc.to_list |> List.hd
      in
      let tag = translate_effect_handler_tag (fst effprt) in
      let answertp =
        translate_type _st (clauses.term.value_clause.ty |> snd |> fst)
      in
      let lbl = T.Var (translate_effect_label_name _st (fst effprt)) in
      let kp =
        {
          T.id = T.Id.fresh "kparam";
          T.typ = translate_type _st (snd (fst effprt).ty);
        }
      in
      let k =
        { T.id = T.Id.fresh "k"; T.typ = T.Stack (answertp, [ kp.typ ]) }
      in
      let p, rp, hbody = translate_abstraction2 _st (snd effprt) in
      let handler =
        T.New
          ( tag,
            [
              ( tag,
                {
                  T.params = [ p ];
                  T.body =
                    T.Shift
                      ( lbl,
                        T.Literal (T.LitInt 0),
                        k,
                        T.Let
                          ( [
                              {
                                T.name = rp;
                                T.value =
                                  T.Abs
                                    ([ kp ], T.Resume (T.Var k, [ T.Var kp ]));
                                T.export_as = [];
                              };
                            ],
                            hbody ),
                        kp.typ );
                } );
            ] )
      in

      T.Abs
        ( [ body ],
          T.Reset
            ( lbl,
              ign,
              Some handler,
              T.App (T.Var body, []),
              { T.params = [ vcp ]; T.body = vcbody } ) )
  | STe.Handler clauses ->
      let ign = { T.id = T.Id.Name "ignore"; T.typ = T.Ptr } in
      let vcp, vcbody = translate_abstraction _st clauses.term.value_clause in
      let body =
        {
          T.id = T.Id.fresh "handled body";
          T.typ = T.Function ([], vcp.typ, T.Effectful);
        }
      in
      let answertp =
        translate_type _st (clauses.term.value_clause.ty |> snd |> fst)
      in
      let klbl =
        {
          T.id = T.Id.fresh "label";
          T.typ = T.Base (T.Label (Some answertp, None));
        }
      in
      let idcls_p = { T.id = T.Id.fresh "ret"; T.typ = vcp.typ } in
      let idcls = { T.params = [ idcls_p ]; T.body = T.Var idcls_p } in

      let withbnds =
        List.fold_right
          (fun effprt cbody ->
            let tag = translate_effect_handler_tag (fst effprt) in
            let lbl = T.Var (translate_effect_label_name _st (fst effprt)) in
            let kp =
              {
                T.id = T.Id.fresh "kparam";
                T.typ = translate_type _st (snd (fst effprt).ty);
              }
            in
            let k =
              {
                T.id =
                  T.Id.fresh
                    (Format.asprintf "k_%a"
                       (Fun.flip STe.print_effect)
                       (fst effprt));
                T.typ = T.Stack (answertp, [ kp.typ ]);
              }
            in
            let p, rp, hbody = translate_abstraction2 _st (snd effprt) in
            let handler =
              T.New
                ( tag,
                  [
                    ( tag,
                      {
                        T.params = [ p ];
                        T.body =
                          T.Shift
                            ( T.Var klbl,
                              T.Literal (T.LitInt 0),
                              k,
                              T.Let
                                ( [
                                    {
                                      T.name = rp;
                                      T.value =
                                        T.Abs
                                          ( [ kp ],
                                            T.Resume (T.Var k, [ T.Var kp ]) );
                                      T.export_as = [];
                                    };
                                  ],
                                  hbody ),
                              kp.typ );
                      } );
                  ] )
            in
            T.Reset (lbl, ign, Some handler, cbody, idcls))
          (Assoc.to_list clauses.term.effect_clauses.effect_part)
          (T.App (T.Var body, []))
      in

      T.Abs
        ( [ body ],
          T.Let
            ( [ { T.name = klbl; T.value = T.FreshLabel; T.export_as = [] } ],
              T.Reset
                ( T.Var klbl,
                  ign,
                  None,
                  withbnds,
                  { T.params = [ vcp ]; T.body = vcbody } ) ) )
  | STe.HandlerWithFinally h ->
      Print.warning "Handlers with finally unsupported; ignoring finally clause";
      translate_expression _st
        { term = STe.Handler h.handler_clauses; ty = e.ty }

and translate_abstraction _st abs =
  let x, w = translate_abstraction_partial _st abs in
  (x, w non_exhaustive)

and translate_abstraction_partial _st abs =
  match abs.term with
  | pat, cmp ->
      let var, wrapper = translate_pattern _st pat in
      (var, wrapper (translate_computation _st cmp))

and translate_abstraction2 _st abs =
  match abs.term with
  | pat1, pat2, cmp ->
      let var1, wrapper1 = translate_pattern _st pat1 in
      let var2, wrapper2 = translate_pattern _st pat2 in
      ( var1,
        var2,
        wrapper1
          (wrapper2 (translate_computation _st cmp) non_exhaustive)
          non_exhaustive )

and translate_match_clause _st scr abs =
  let x, w = translate_abstraction_partial _st abs in
  fun els -> T.Let ([ { T.name = x; T.value = scr; T.export_as = [] } ], w els)

and non_exhaustive = not_implemented "non-exhaustive match"

and translate_pattern _st pat =
  match pat.term with
  | STe.PVar v ->
      ({ T.id = T.Id.SrcId v; T.typ = translate_type _st pat.ty }, fun b _ -> b)
  | STe.PAs (pat, x) ->
      let var, wrapper = translate_pattern _st pat in
      let def =
        {
          T.name = { T.id = T.Id.SrcId x; T.typ = translate_type _st pat.ty };
          T.value = T.Var var;
          T.export_as = [];
        }
      in
      (var, fun thn els -> T.Let ([ def ], wrapper thn els))
  | STe.PTuple pats ->
      let vars, wrappers = List.split (List.map (translate_pattern _st) pats) in
      let tag = tuple_tag _st (List.map (fun p -> p.ty) pats) in
      let scrutinee =
        { T.id = T.Id.fresh "tuple"; T.typ = translate_type _st pat.ty }
      in
      ( scrutinee,
        fun thn els ->
          T.Match
            ( T.Var scrutinee,
              tag,
              [
                ( tag,
                  {
                    T.params = vars;
                    T.body = List.fold_right (fun w b -> w b els) wrappers thn;
                  } );
              ],
              { T.params = []; T.body = els } ) )
  | STe.PNonbinding ->
      ( { T.id = T.Id.fresh "nonbinding"; T.typ = translate_type _st pat.ty },
        fun b _ -> b )
  | STe.PConst (S.Const.Boolean b) ->
      let scrutinee =
        { T.id = T.Id.fresh "cond"; T.typ = translate_type _st pat.ty }
      in
      ( scrutinee,
        fun thn els -> T.Switch (T.Var scrutinee, [ (T.LitBool b, thn) ], els)
      )
  | STe.PConst (S.Const.Integer i) ->
      let scrutinee =
        { T.id = T.Id.fresh "scrutinee"; T.typ = translate_type _st pat.ty }
      in
      ( scrutinee,
        fun thn els -> T.Switch (T.Var scrutinee, [ (T.LitInt i, thn) ], els) )
  | STe.PVariant (name, None) ->
      let tag = sum_tag _st (STy.Field.Map.singleton name None) in
      let scrutinee =
        { T.id = T.Id.fresh "tuple"; T.typ = translate_type _st pat.ty }
      in
      ( scrutinee,
        fun thn els ->
          T.Match
            ( T.Var scrutinee,
              tag,
              [ (T.Id.SrcId name, { T.params = []; T.body = thn }) ],
              { T.params = []; T.body = els } ) )
  | STe.PVariant (name, Some pat) ->
      let arg, sub = translate_pattern _st pat in
      let tag = sum_tag _st (STy.Field.Map.singleton name None) in
      let scrutinee =
        { T.id = T.Id.fresh "tuple"; T.typ = translate_type _st pat.ty }
      in
      ( scrutinee,
        fun thn els ->
          T.Match
            ( T.Var scrutinee,
              tag,
              [
                (T.Id.SrcId name, { T.params = [ arg ]; T.body = sub thn els });
              ],
              { T.params = []; T.body = els } ) )
  | _ ->
      not_implemented_pattern
        (Format.asprintf "%a" (fun fmt x -> STe.print_pattern x fmt) pat)

let translate_top_letrec _st = function
  | ( (name : STe.variable),
      ((_params : STy.Params.t), _constraints, (abs : STe.abstraction)) ) ->
      let p, body = translate_abstraction _st abs in
      [
        {
          T.name =
            { T.id = T.Id.SrcId name; T.typ = translate_type _st (fst abs.ty) };
          T.value = T.Abs ([ p ], body);
          T.export_as =
            [ Format.asprintf "%a" (fun x y -> STe.print_variable y x) name ];
        };
      ]

let translate_top_let _st = function
  | ( (pat : STe.pattern),
      (_params : STy.Params.t),
      _constraints,
      (cmp : STe.computation) ) -> (
      match pat.term with
      | STe.PVar name ->
          [
            {
              T.name =
                {
                  T.id = T.Id.SrcId name;
                  T.typ = translate_type _st (fst cmp.ty);
                };
              T.value = translate_computation _st cmp;
              T.export_as =
                [
                  Format.asprintf "%a" (fun x y -> STe.print_variable y x) name;
                ];
            };
          ]
      | _ ->
          [
            not_implemented_def
              (Format.asprintf "let %a = %a"
                 (fun x y -> STe.print_pattern y x)
                 pat
                 (fun x y -> STe.print_computation y x)
                 cmp);
          ])
(* TODO *)

let primitive_value_decl = function
  | S.Primitives.CompareEq ->
      [
        ("equals(Any, Any): Bool", [ T.Top; T.Top ], [ T.Base T.Bool ], T.Pure);
      ]
  | S.Primitives.CompareGe ->
      [
        ("infixGte(Any, Any): Bool", [ T.Top; T.Top ], [ T.Base T.Bool ], T.Pure);
      ]
  | S.Primitives.CompareGt ->
      [
        ("infixGt(Any, Any): Bool", [ T.Top; T.Top ], [ T.Base T.Bool ], T.Pure);
      ]
  | S.Primitives.CompareLe ->
      [
        ("infixLte(Any, Any): Bool", [ T.Top; T.Top ], [ T.Base T.Bool ], T.Pure);
      ]
  | S.Primitives.CompareLt ->
      [
        ("infixLt(Any, Any): Bool", [ T.Top; T.Top ], [ T.Base T.Bool ], T.Pure);
      ]
  | S.Primitives.CompareNe ->
      [
        ( "!sexp:(\"not(Boolean): Boolean\" (\"equals(Any, Any): Bool\" \
           $arg0:top $arg1:top))",
          [ T.Top; T.Top ],
          [ T.Base T.Bool ],
          T.Pure );
      ]
  | S.Primitives.FloatAcos ->
      [
        ( "acos(Double): Double",
          [ T.Base T.Double ],
          [ T.Base T.Double ],
          T.Pure );
      ]
  | S.Primitives.FloatAdd ->
      [
        ( "infixAdd(Double, Double): Double",
          [ T.Base T.Double; T.Base T.Double ],
          [ T.Base T.Double ],
          T.Pure );
      ]
  | S.Primitives.FloatAsin ->
      [
        ( "asin(Double): Double",
          [ T.Base T.Double ],
          [ T.Base T.Double ],
          T.Pure );
      ]
  | S.Primitives.FloatAtan ->
      [
        ( "atan(Double): Double",
          [ T.Base T.Double ],
          [ T.Base T.Double ],
          T.Pure );
      ]
  | S.Primitives.FloatCos ->
      [
        ("cos(Double): Double", [ T.Base T.Double ], [ T.Base T.Double ], T.Pure);
      ]
  | S.Primitives.FloatDiv ->
      [
        ( "infixDiv(Double, Double): Double",
          [ T.Base T.Double; T.Base T.Double ],
          [ T.Base T.Double ],
          T.Pure );
      ]
  | S.Primitives.FloatExp ->
      [
        ("exp(Double): Double", [ T.Base T.Double ], [ T.Base T.Double ], T.Pure);
      ]
  | S.Primitives.FloatLog ->
      [
        ("log(Double): Double", [ T.Base T.Double ], [ T.Base T.Double ], T.Pure);
      ]
  | S.Primitives.FloatLog1p ->
      [
        ( "log1p(Double): Double",
          [ T.Base T.Double ],
          [ T.Base T.Double ],
          T.Pure );
      ]
  | S.Primitives.FloatMul ->
      [
        ( "infixMul(Double, Double): Double",
          [ T.Base T.Double; T.Base T.Double ],
          [ T.Base T.Double ],
          T.Pure );
      ]
  | S.Primitives.FloatOfInt ->
      [
        ("toDouble(Int): Double", [ T.Base T.Int ], [ T.Base T.Double ], T.Pure);
      ]
  | S.Primitives.FloatSin ->
      [
        ("sin(Double): Double", [ T.Base T.Double ], [ T.Base T.Double ], T.Pure);
      ]
  | S.Primitives.FloatSqrt ->
      [
        ( "sqrt(Double): Double",
          [ T.Base T.Double ],
          [ T.Base T.Double ],
          T.Pure );
      ]
  | S.Primitives.FloatSub ->
      [
        ( "infixSub(Double, Double): Double",
          [ T.Base T.Double; T.Base T.Double ],
          [ T.Base T.Double ],
          T.Pure );
      ]
  | S.Primitives.FloatTan ->
      [
        ("tan(Double): Double", [ T.Base T.Double ], [ T.Base T.Double ], T.Pure);
      ]
  | S.Primitives.IntegerAdd ->
      [
        ( "infixAdd(Int, Int): Int",
          [ T.Base T.Int; T.Base T.Int ],
          [ T.Base T.Int ],
          T.Pure );
      ]
  | S.Primitives.IntegerDiv ->
      [
        ( "infixDiv(Int, Int): Int",
          [ T.Base T.Int; T.Base T.Int ],
          [ T.Base T.Int ],
          T.Pure );
      ]
  | S.Primitives.IntegerMod ->
      [
        ( "mod(Int, Int): Int",
          [ T.Base T.Int; T.Base T.Int ],
          [ T.Base T.Int ],
          T.Pure );
      ]
  | S.Primitives.IntegerMul ->
      [
        ( "infixMul(Int, Int): Int",
          [ T.Base T.Int; T.Base T.Int ],
          [ T.Base T.Int ],
          T.Pure );
      ]
  | S.Primitives.IntegerNeg ->
      [ ("neg(Int): Int", [ T.Base T.Int ], [ T.Base T.Int ], T.Pure) ]
  | S.Primitives.IntegerAbs ->
      [ ("abs(Int): Int", [ T.Base T.Int ], [ T.Base T.Int ], T.Pure) ]
  | S.Primitives.IntegerSub ->
      [
        ( "infixSub(Int, Int): Int",
          [ T.Base T.Int; T.Base T.Int ],
          [ T.Base T.Int ],
          T.Pure );
      ]
  | S.Primitives.IntOfFloat ->
      [ ("toInt(Double): Int", [ T.Base T.Double ], [ T.Base T.Int ], T.Pure) ]
  | S.Primitives.StringConcat ->
      [
        ( "infixConcat(String, String): String",
          [ T.Base T.String; T.Base T.String ],
          [ T.Base T.String ],
          T.Pure );
      ]
  | S.Primitives.StringLength ->
      [ ("length(String): Int", [ T.Base T.String ], [ T.Base T.Int ], T.Pure) ]
  | S.Primitives.StringOfFloat ->
      [
        ( "show(Double): String",
          [ T.Base T.Double ],
          [ T.Base T.String ],
          T.Pure );
      ]
  | S.Primitives.StringOfInt ->
      [ ("show(Int): String", [ T.Base T.Int ], [ T.Base T.String ], T.Pure) ]
  | S.Primitives.StringSub ->
      [
        ( "substring(String, Int, Int): String",
          [ T.Base T.String; T.Base T.Int; T.Base T.Int ],
          [ T.Base T.String ],
          T.Pure );
      ]
  | S.Primitives.ToString ->
      [
        ("show(Int): String", [ T.Base T.Int ], [ T.Base T.String ], T.Pure);
        ( "show(Double): String",
          [ T.Base T.Double ],
          [ T.Base T.String ],
          T.Pure );
      ]
  | _ -> []

let primitive_effect_decl = function
  | S.Primitives.Print ->
      Some
        ( "print(String): Unit",
          [ T.Base T.String ],
          [ T.Base T.Unit ],
          T.Effectful )
  | S.Primitives.RandomFloat ->
      Some ("random(): Double", [], [ T.Base T.Double ], T.Effectful)
  | S.Primitives.RandomInt ->
      Some ("random(): Int", [], [ T.Base T.Int ], T.Effectful)
  | S.Primitives.Read ->
      Some ("readLn(): String", [], [ T.Base T.String ], T.Effectful)
  | S.Primitives.Raise ->
      Some
        ("panic(String): Bottom", [ T.Base T.String ], [ T.Bottom ], T.Effectful)
  | _ -> None

let rec mkAbs (ps, body) =
  match ps with
  | [ _ ] -> T.Abs (ps, body)
  | p :: ps -> T.Abs ([ p ], mkAbs (ps, body))
  | [] -> body (* TODO ?? *)

let rec mkFunTy (argtpes, rtpe, purity) =
  match argtpes with
  | [ p ] -> T.Function ([ p ], rtpe, purity)
  | p :: ps -> T.Function ([ p ], mkFunTy (ps, rtpe, purity), T.Pure)
  | [] -> T.Function ([], rtpe, purity)

let generate_primitive_value name prim =
  match primitive_value_decl prim with
  | (tname, argtpes, [ rtpe ], purity) :: rest ->
      let args =
        List.mapi
          (fun i t ->
            { T.id = T.Id.fresh (Format.sprintf "arg%d" i); T.typ = t })
          argtpes
      in
      let r = { T.id = T.Id.fresh "ret"; T.typ = rtpe } in
      if not (0 == List.length rest) then
        Print.warning "Defaulting to first implementation %s of %s" tname
          (S.Primitives.primitive_value_name prim);
      {
        T.name =
          { T.id = T.Id.SrcId name; T.typ = mkFunTy (argtpes, rtpe, purity) };
        T.value =
          mkAbs
            ( args,
              T.Primitive
                (tname, List.map (fun a -> T.Var a) args, [ r ], T.Var r) );
        T.export_as =
          [ Format.asprintf "%a" (fun x y -> STe.print_variable y x) name ];
      }
  | _ ->
      Print.warning "Unsupported primitive '%s'"
        (S.Primitives.primitive_value_name prim);
      {
        T.name =
          {
            T.id = T.Id.SrcId name;
            T.typ = T.Function ([], T.Bottom, T.Effectful);
          };
        T.value =
          T.Abs
            ( [],
              not_implemented
                ("primitive " ^ S.Primitives.primitive_value_name prim) );
        T.export_as =
          [ Format.asprintf "%a" (fun x y -> STe.print_variable y x) name ];
      }

let translate_primitive_effect _st eff prim =
  match primitive_effect_decl prim with
  | Some (tprim, args, rets, _) ->
      let tag = translate_effect_handler_tag eff in
      let ps =
        List.mapi
          (fun i tp ->
            { T.id = T.Id.fresh (Format.sprintf "param%d" i); T.typ = tp })
          args
      in
      let rs =
        List.mapi
          (fun i tp ->
            { T.id = T.Id.fresh (Format.sprintf "ret%d" i); T.typ = tp })
          rets
      in
      ( T.Var (translate_effect_label_name _st eff),
        T.New
          ( tag,
            [
              ( tag,
                {
                  T.params = ps;
                  T.body =
                    T.Primitive
                      ( tprim,
                        List.map (fun x -> T.Var x) ps,
                        rs,
                        T.Var (List.hd rs) );
                } );
            ] ) )
  | _ ->
      Print.warning "Unsupported primitive effect %s"
        (S.Primitives.primitive_effect_name prim);
      let tag = translate_effect_handler_tag eff in
      (T.Var (translate_effect_label_name _st eff), T.New (tag, []))

let wrap_with_primitive_effects _st es body =
  let ign = { T.id = T.Id.Name "ignored"; T.typ = T.Ptr } in
  List.fold_right
    (fun (label, cap) b ->
      let r = { T.id = T.Id.fresh "return"; T.typ = T.Top } in
      T.Reset (label, ign, Some cap, b, { T.params = [ r ]; T.body = T.Var r }))
    es body
