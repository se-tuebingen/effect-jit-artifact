open Common
open JsonPrinter

let rec tr_term (t: S.term) = obj(match t with
  | Var v -> "op" = str "Var" & tr_var_inline v
  | Abs(bs, b) -> "op" = str "Abs" & "params" = listof tr_var bs & "body" = tr_term b
  | App(f, a) -> "op" = str "App" & "fn" = tr_term f & "args" = listof tr_term a
  | Seq(els) -> "op" = str "Seq" & "elems" = listof tr_term els
  | Let(bs, b) -> "op" = str "Let" & "definitions" = listof tr_def bs & "body" = tr_term b
  | LetRec(bs, b) -> "op" = str "LetRec" & "definitions" = listof tr_def bs & "body" = tr_term b
  | IfZero(c, t, e) -> "op" = str "IfZero" & "cond" = tr_term c & "then" = tr_term t & "else" = tr_term e
  | Construct(tt,t,args) -> "op" = str "Construct" & "type_tag" = tr_id tt & "tag" = int t & "args" = listof tr_term args
  | Project(s,tt,f) -> "op" = str "Project" & "scrutinee" = tr_term s & "type_tag" = tr_id tt & "tag" = int 0 & "field" = int f
  | Match(s, tt, cs, d) -> "op" = str "Match" & "scrutinee" = tr_term s & "type_tag" = tr_id tt & "clauses" = listof (fun (t,c) -> obj("tag" = int t & tr_clause c)) cs & "default_clause" = obj (tr_clause d)
  | New(i,ms) -> "op" = str "New" & "ifce_tag" = tr_id i & "methods" = listof (fun (t,c) -> obj("tag" = tr_id t & tr_clause c)) ms
  | Invoke(r,tt,t,args) -> "op" = str "Invoke" & "receiver" = tr_term r & "ifce_tag" = tr_id tt & "tag" = tr_id t & "args" = listof tr_term args
  | LetRef(ref,reg,init,body) -> "op" = str "LetRef" & "ref" = tr_var ref & "region" = tr_term reg & "binding" = tr_term init & "body" = tr_term body
  | Load(ref) -> "op" = str "Load" & "ref" = tr_term ref 
  | Store(ref,v) -> "op" = str "Store" & "ref" = tr_term ref & "value" = tr_term v
  | FreshLabel -> "op" = str "FreshLabel"
  | Reset(l,reg,b,r) -> "op" = str "Reset" & "label" = tr_term l & "region" = tr_var reg & "body" = tr_term b & "return" = obj(tr_clause r)
  | Shift(l, n, k, body, t) -> "op" = str "Shift" & "label" = tr_term l & "n" = tr_term n & "k" = tr_var k & "body" = tr_term body & "returnType" = tr_type t
  | Control(l, n, k, body, t) -> "op" = str "Control" & "label" = tr_term l & "n" = tr_term n & "k" = tr_var k & "body" = tr_term body & "returnType" = tr_type t
  | Primitive(name,args,rets,rest) -> "op" = str "Primitive" & "name" = str name & "args" = listof tr_term args & "returns" = listof tr_var rets & "rest" = tr_term rest
  | Resume(k,args) -> "op" = str "Resume" & "k" = tr_term k & "args" = listof tr_term args
  | Literal(BaseInt(i)) -> "op" = str "Literal" & "type" = obj("op" = str "Int") & "value" = int i
  (*| Literal(BaseDouble(d)) -> "op" = str "Literal" & "type" = obj("op" = str "Double") & "value" = double d   (* TODO *) *)
  | Literal(BaseString(s)) -> "op" = str "Literal" & "type" = obj("op" = str "String") & "value" = str s
  | DHandle(tag, handlers, ret, body) -> "op" = str "DHandle" & "tpe" = str "Deep" & "tag" = tr_term (Var tag) & "handlers" = listof (fun (t,c) -> obj("tag" = (int t) & tr_clause c)) handlers & "return" = obj(tr_clause ret) & "body" = tr_term body
  | DOp(tag, op, args, k, rtpe) -> "op" = str "DOp" & "tag" = tr_term (Var tag) & "op_tag" = (int op) & "args" = listof(tr_term) args & "k" = obj(tr_clause k) & "rtpe" = tr_type rtpe
  | _ -> failwith "Not implemented")
and tr_def (d: S.definition) = match d with
  | Definition(n, v, es) -> obj("name" = tr_var n & "value" = tr_term v & "export_as" = listof str es)
and tr_var (v: S.var) = obj(tr_var_inline v)
and tr_var_inline (v: S.var) = match v with
| {name=n; tpe=t} -> "id" = tr_id n & "type" = tr_type t
and tr_id i = str (S.Id.to_string i)
and tr_clause c = match c with
  | {params=ps; body=b} -> "params" = listof(tr_var) ps & "body" = tr_term b
and tr_type t = match t with
  | Top -> obj("op" = str "Top")
  | Ptr -> obj("op" = str "Ptr")
  | Num -> obj("op" = str "Num")
  | Bottom -> obj("op" = str "Bottom")
  | Int -> obj("op" = str "Int")
  | Boolean -> obj("op" = str "Int") (* TODO for now *)
  | Double -> obj("op" = str "Double")
  | String -> obj("op" = str "String")
  | Function(ats,rt,p) -> obj("op" = str "Function" 
      & "params" = listof tr_type ats & "return" = tr_type rt & "purity" = tr_purity p)
  (* TODO *)
and tr_purity p = match p with
  | Pure -> str "Pure"
  | Effectful -> str "Effectful"

let tr_program (p: S.program) = match p with
    | Program(defs,main) -> run (obj 
        ("definitions" = (listof tr_def defs) & "main" = (tr_term main)))
