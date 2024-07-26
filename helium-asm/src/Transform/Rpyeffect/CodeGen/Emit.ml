open Common

module JsonPrinter : sig
  type t
  val str : string -> t
  val int : int -> t
  val list : t -> t
  val obj : t -> t
  val (=) : string -> t -> t
  val nop : t
  val (&) : t -> t -> t
  val run : t -> string
  val seq: t list -> t
  val listof : ('a -> t) -> 'a list -> t
  val singleline : t -> t
end
= 
struct
  type state = State of Buffer.t * bool
  type t = state -> state
  let start () = State((Buffer.create 1000), true)
  let emit s st = match st with
  | State(buf,_) -> Buffer.add_string buf s; st
  let str s = emit ("\"" ^ s ^ "\"")
  let int i = emit (string_of_int i)
  let (++) l r st = r (l st)
  let (&) l r = l ++ (emit ",") ++ (fun st -> 
    match st with
    | State(_,true) -> emit "\n" st
    | _ -> st) ++ r
  let parens o c body = (emit o) ++ body ++ (emit c)
  let list = parens "[" "]"
  let obj = parens "{" "}"
  let (=) k v = (emit ("\"" ^ k ^ "\":")) ++ v
  let stop st = match st with
  | State(buf,_) ->  Buffer.contents buf
  let nop = fun x -> x
  let run body = stop (body (start ()))
  let seq l =
    match l with
    | [] -> nop
    | hd :: tl -> List.fold_left (&) hd tl
  let listof f l = list (seq (List.map f l))
  let singleline body st =
    match st with
    | State(buf,old) ->
      match body (State(buf,false)) with
      | State(buf,_) -> State(buf,old)
end

open JsonPrinter
let tr_program (S.Program blocks) =
  let rec tr_block b =
    match b with
    | S.Block(l, ps, ins) ->
      obj ("label" = tr_label l
        & "params" = (listof tr_var ps)
        & "instructions" = (listof tr_instruction ins))
  and tr_instruction i =
    let r = match i with
    | S.ILet(lhss,rhss) -> obj ("op" = str "Let"
        & "lhss" = listof tr_var lhss
        & "rhss" = listof tr_var rhss)
    | S.ILetConst(out,v) -> obj ("op" = str "LetConst"
        & "out" = tr_var out
        & "value" = tr_literal v)
    | S.IPrim(outs,name,ins) -> obj ("op" = str "Prim"
        & "name" = str name
        & "outs" = listof tr_var outs
        & "ins" = listof tr_var ins)
    | S.IPush(l,args) -> obj ("op" = str "Push"
        & "target" = tr_label l
        & "args" = listof tr_var args)
    | S.IReturn(args) -> obj ("op" = str "Return"
        & "args" = listof tr_var args)
    | S.IJump(l,args) -> obj ("op" = str "Jump"
        & "target" = tr_label l
        & "args" = listof tr_var args)
    | S.IIfZ(c,l,args) -> obj ("op" = str "IfZero"
        & "cond" = tr_var c
        & "target" = tr_label l
        & "args" = listof tr_var args)
    | S.IAlloc(ref,init,reg) -> obj ("op" = str "Allocate"
        & "ref" = tr_var ref
        & "init" = tr_var init
        & "region" = tr_var reg)
    | S.ILoad(out,ref) -> obj ("op" = str "Load"
        & "out" = tr_var out
        & "ref" = tr_var ref)
    | S.IStore(ref,v) -> obj ("op" = str "Store"
        & "ref" = tr_var ref
        & "arg" = tr_var v)
    | S.IShift(out,n,label) -> obj ("op" = str "Shift"
        & "out" = tr_var out
        & "n" = tr_var n
        & "label" = tr_var label)
    | S.IPushStack(a) -> obj ("op" = str "PushStack"
        & "arg" = tr_var a)
    | S.INewStack(out_stack,out_region, label, target, args) -> obj ("op" = str "NewStack"
        & "stack" = tr_var out_stack
        & "region" = tr_var out_region
        & "label" = tr_var label
        & "target" = tr_label target
        & "args" = listof tr_var args)
    | S.IConstruct(out,tpe,tag,args) -> obj ("op" = str "Construct"
        & "out" = tr_var out
        & "type" = tr_type_tag tpe
        & "tag" = tr_tag tag
        & "args" = listof tr_var args)
    | S.IMatch(tpe,scrutinee,clauses,default_clause) -> obj ("op" = str "Match"
        & "type" = tr_type_tag tpe
        & "scrutinee" = tr_var scrutinee
        & "clauses" = listof (fun (t,c) -> obj ("tag" = tr_tag t & "clause" = tr_clause c)) clauses
        & "default_clause" = tr_clause default_clause)
    | S.IProj(out,tpe,scrutinee,tag,field) -> obj ("op" = str "Proj"
        & "out" = tr_var out
        & "type" = tr_type_tag tpe
        & "scrutinee" = tr_var scrutinee
        & "tag" = tr_tag tag
        & "field" = int field)
    | S.INew(out,tpe,methods,args) -> obj ("op" = str "New"
        & "out" = tr_var out
        & "type" = tr_type_tag tpe
        & "method_targets" = listof tr_method methods
        & "args" = listof tr_var args)
    | S.IInvoke(tpe,receiver,tag,args) -> obj ("op" = str "Invoke"
        & "type" = tr_type_tag tpe
        & "receiver" = tr_var receiver
        & "method" = tr_tag tag
        & "args" = listof tr_var args)
    in singleline r
  and tr_clause c =
    match c with
    | Clause(params,env,target) -> obj ("params" = listof tr_var params
                                      & "env" = listof tr_var env
                                      & "target" = tr_label target)
  and tr_method m =
    match m with
    | (tag, target) -> obj ("method" = tr_tag tag & "target" = tr_label target)
  and tr_var o =
    match o with
    | Var(id,tpe) -> singleline(obj("id" = tr_id id & "type" = tr_type tpe))
  and tr_label l = tr_id l
  and tr_tag t = tr_id t
  and tr_type_tag t = tr_id t
  and tr_id t = match t with
    | V t -> str (S.Id.to_string t)
    | N n -> str n
    | I i -> int i
  and tr_type t = 
    match t with
    | Top -> str "Top"
    | String -> str "String"
    | Int -> str "Int"
    | Unit -> str "Unit"
  and tr_literal v = match v with
    | LString s -> str s
    | LInt n -> int n
  in
  run (obj ("blocks" = (listof tr_block blocks)))