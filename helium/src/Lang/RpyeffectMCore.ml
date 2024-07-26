module Id = Common.Var

type id = Id.t

type purity =
  | Pure | Effectful

type typ =
  | Top | Ptr | Num | Bottom
  | Int | Double | String | Boolean
  | Function of typ list * typ * purity
  (* TODO *)

type var = { name : id; tpe : typ }

type clause = { params : var list; body : term }

and term = 
  | Abs of var list * term
  | App of term * term list
  | Seq of term list
  | Let of definition list * term
  | LetRec of definition list * term
  | IfZero of term * term * term
  | Construct of id * int * term list
  | Project of term * id * int
  | Match of term * id * (int * clause) list * clause
  | New of id * (id * clause) list
  | Invoke of term * id * id * term list
  | LetRef of var * term * term * term
  | Load of term
  | Store of term * term
  | FreshLabel
  | Reset of term * var * term * clause
  | Shift of term * term * var * term * typ
  | Control of term * term * var * term * typ
  | Resume of term * term list
  | Primitive of string * term list * var list * term
  | Literal of base
  | Var of var
  | DHandle of var * (int * clause) list * clause * term (* Handler type is hardcoded in pretty-printer, we always have a return clause *)
  | DOp of var * int * term list * clause * typ

and definition =
  | Definition of var * term * string list

and base = BaseInt of int | BaseDouble of float | BaseString of string

type program = Program of definition list * term


let flow_node: program Flow.node = Flow.Node.create
  ~cmd_line_flag: "-rpyeffect-mcore"
  "RPyeffect MCore"