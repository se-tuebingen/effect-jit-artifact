module Var = Common.Var
module EffInst = Common.EffInst

(* Some instructions, that in the Core language would bind multiple variables,
   in the Untyped language bind only one variable which holds a record
   of values. For example match clause in Core binds multiple values:

   match v with
     C1 (x1, x2) -> x1 + x2

   In the Untyped language this is represented as:

   match v as x with
     C1 -> x->1 + x->2

  This brings us closer to machine semantics for matching.
  To represent this conveniently we add field accessors to all local variables.
  *)
type field_accessor =
| NoFieldAccess
| TupleAccess of int (* Used for in match clauses *)
| RecursiveAccess of int (* Used for accessing functions defined in fix expressions *)

type identifier = Var.t
type effinst = Common.effinst

type var = Local of Var.t * field_accessor | Global of int

type expr =
| ELit     of RichBaseType.lit
| EVar     of var
| EFn      of identifier list * expr
| EFnRedex of identifier list * expr
| ETuple   of expr list
| EConstr  of int * expr list
| EPrim    of PrimCodes.prim_code * expr list
| ELet     of identifier * expr * expr
| ELetPure of identifier * expr * expr
| EFix     of identifier * expr list * expr
| EApp     of expr * expr list
| EProj    of expr * int
| EExtern  of string * expr list
| EMatch   of expr * identifier * expr list
| ESwitch  of expr * expr list
| EHandle  of
    { effinst     : identifier
    ; body        : expr
    ; op_arg_var  : identifier
    ; resume_var  : identifier
    ; op_handler  : expr
    ; return_var  : identifier
    ; return_body : expr
    }
| EOp      of identifier * expr

type program = Program of expr list * expr


let pretty_var v =
  match v with
  | Local(x, NoFieldAccess) ->
    SExpr.tagged_list "local-var"
      [ SExpr.Atom (Var.to_string x) ]
  | Local(x, TupleAccess k) ->
    SExpr.tagged_list "local-var"
      [ SExpr.Atom (Var.to_string x); SExpr.Atom "->"; Int k ]
  | Local(x, RecursiveAccess k) ->
    SExpr.tagged_list "local-var"
      [ SExpr.Atom (Var.to_string x); SExpr.Atom "->"; Int k ]
  | Global n -> SExpr.tagged_list "global-var" [ Int n ]

let rec pretty_expr e =
  match e with
  | ELit lit ->
    SExpr.tagged_list "lit" [ SExpr.Atom (RichBaseType.to_string lit) ]
  | EVar x -> pretty_var x
  | EFn(args, body) ->
    SExpr.tagged_list "fn" (List.map
      (fun arg -> SExpr.Atom (Var.to_string arg)) args @
        [ Atom "->" ; pretty_expr body ])
  | EFnRedex(args, body) ->
    SExpr.tagged_list "fn-redex" (List.map 
      (fun arg -> SExpr.Atom (Var.to_string arg)) args @
        [ Atom "->" ; pretty_expr body ])
  | ETuple vs ->
    SExpr.tagged_list "tuple" (List.map pretty_expr vs)
  | EConstr(n, vs) ->
      SExpr.tagged_list "constr" (Int n :: List.map pretty_expr vs)
  | EPrim(prim_code, es) ->
    SExpr.tagged_list "prim" (SExpr.Atom
      (PrimCodes.to_string prim_code) :: List.map pretty_expr es)
  | ELet(x, e1, e2) ->
    SExpr.tagged_list "let" [ SExpr.Atom (Var.to_string x);
                              pretty_expr e1; pretty_expr e2]
  | ELetPure(x, e1, e2) ->
    SExpr.tagged_list "let-pure" [ SExpr.Atom (Var.to_string x);
                                   pretty_expr e1; pretty_expr e2]
  | EFix(r, rfs, e) ->
    SExpr.tagged_list "fix" ([SExpr.Atom (Var.to_string r); SExpr.Atom "begin"]
      @ List.map pretty_expr rfs @ [SExpr.Atom "end"; pretty_expr e])
  | EApp(f, args) ->
    SExpr.tagged_list "app" (pretty_expr f :: List.map pretty_expr args)
  | EProj(v, n) ->
    SExpr.tagged_list "proj"
      [ Int n
      ; pretty_expr v
      ]
  | EMatch(v, x, cls) ->
    SExpr.tagged_list "match"
      (pretty_expr v :: SExpr.Atom (Var.to_string x) :: List.map pretty_expr cls)
  | ESwitch(v, cls) ->
    SExpr.tagged_list "switch"
      (pretty_expr v :: List.map pretty_expr cls)
  | EHandle hdata ->
    SExpr.tagged_list "handle"
      [ SExpr.Atom (Var.to_string hdata.effinst)
      ; SExpr.tagged_list "body" [ pretty_expr hdata.body ]
      ; SExpr.tagged_list "with"
        [ SExpr.Atom (Var.to_string hdata.op_arg_var);
          SExpr.Atom (Var.to_string hdata.resume_var);
        pretty_expr hdata.op_handler ]
      ; SExpr.tagged_list "return"
        [ SExpr.Atom (Var.to_string hdata.return_var);
          pretty_expr hdata.return_body ]
      ]
  | EOp(i, arg) ->
    SExpr.tagged_list "op"
      [ SExpr.Atom (Var.to_string i)
      ; pretty_expr arg
      ]
  | EExtern(name, args) ->
    SExpr.tagged_list "extern" (Atom name :: List.map pretty_expr args)

let pretty_program (Program(globals, prog)) = SExpr.tagged_list "program"
  [List.map pretty_expr globals |> SExpr.tagged_list "globals"; pretty_expr prog]


let flow_node : program Flow.node = Flow.Node.create
  ~cmd_line_flag: "-untyped"
  "Untyped"

let _ : Flow.tag =
  Flow.register_transform
    ~provides_tags: [ CommonTags.pretty ]
    ~source: flow_node
    ~target: SExpr.flow_node
    ~name:   "Untyped --> SExpr (pretty printer)"
    (fun program _ -> Flow.return (pretty_program program))