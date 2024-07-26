(* Helium Virtual Machine is as stack based machine.
  The program is represented as a list of instructions. The
  machine uses the accumulator for passing results and arguments. It also features
  environment and two stacks: the argument stack and the return stack.
  Finally, the machine configuration consists of meta stack used for algebraic
  effects handling.
 *)

type instruction =
| Prim of PrimCodes.prim_code
| ConstInt of int  (* Place constant integer in the accumulator. *)
| ConstString of string (* Place constant string in the accumulator. *)
| Push (* Push the value of the accumulator on the argument_stack. *)
| AccessVar of int (* addressed with using de bruijn indices. *)
| MakeClosure of int * instruction list
  (* Create closure (which captures current environment) and place in the accumulator. *)
| MakeRecursiveBinding of (int * instruction list) list
  (* Create container of mutually recursive closures and place in the accumulator. *)
| AccessRecursiveBinding of int (* Access container of mutually recursive closures placed in the accumulator. *)
| Let (* Create the new variable with the value of the accumulator. *)
| EndLet (* Remove variable 0 from the environment. *)
| CreateGlobal (* addressed with using de bruijn levels. *)
| AccessGlobal of int (* addressed with using de bruijn levels. *)
| Call (* Call the closure or resumption in the accumulator while taking arguments from the argument stack. *)
| TailCall (* Same as [Call; Return] but more efficient. *)
| CallGlobal of int
  (* Call global closure while taking last argument
     from the accumulator and other arguments from the argument stack. *)
| TailCallGlobal of int
| CallLocal of int
  (* Call closure or resumption from the local variable while taking last argument
     from the accumulator and other arguments from the argument stack. *)
| TailCallLocal of int
| CallRecursiveBinding of int * int
   (* Call closure from recursive binding in the local variable while taking last argument
     from the accumulator and other arguments from the argument stack. *)
| TailCallRecursiveBinding of int * int
| CallExtern of string * int
  (* Call external function while taking last argument
     from the accumulator and other arguments from the argument stack. *)
| Return
| Handle of
    { body        : instruction list (* Represents handled expression and return clause.
      It requires EndHandle instruction to mark the border between handled expression and return clause.
      It requires 'Return' or 'TailCall...' instruction at the end of return clause. *)
    ; op_handler  : instruction list (* It requires 'Return' or 'TailCall...' instruction at the end. *)
    } (* Adds a frame to meta stack, which "registers" the handle *)
| EndHandle (* Removes frame from meta stack, which ends the handle *)
| MakeRecord of int
  (* Takes last argument
     from the accumulator and other arguments from the argument stack. *)
| MakeConstructor of int * int
  (* Takes last argument
     from the accumulator and other arguments from the argument stack. *)
| GetField of int
  (* Gets field from record or constructor. In constructors the tag is stored at index 0. *)
| Match of (instruction list) list
  (* Inspect the constructor in the accumulator and Jump to the branch based on its tag
  (zero argument constructors can be represented as integers). *)
| Switch of (instruction list) list
  (* Jump to the branch based on index in the accumulator. *)
| BranchZero of instruction list * instruction list
  (* Abstract representation of the branching with JumpZero instruction.  *)
| BranchNonZero of instruction list * instruction list
  (* Abstract representation of the branching with JumpNonZero instruction.  *)
| Op of int
| Nop
  (* This is instruction doesn't correspond to any HVM instruction. It is used only in code generation to
     make some subprograms not empty. *)
| Exit (* Marks the end of the program. Necessary for correct execution. *)

type program = Instructions of instruction list

let rec pretty_instruction i =
  match i with
  | Prim prim_code -> SExpr.Atom (PrimCodes.to_string prim_code)
  | ConstInt n -> SExpr.tagged_list "ConstInt" [Int n]
  | ConstString s -> SExpr.tagged_list "ConstString" [SExpr.Atom s]
  | Push -> SExpr.Atom "Push"
  | AccessVar n ->  SExpr.tagged_list "AccessVar" [Int n]
  | MakeClosure(arity, body) ->
    SExpr.tagged_list "MakeClosure" (Int arity :: List.map pretty_instruction body)
  | MakeRecursiveBinding rfs -> SExpr.tagged_list "MakeRecursiveBinding"
      [SExpr.mk_list (List.map
        (fun (n, b) -> SExpr.mk_list
          (SExpr.Atom "fn /" :: Int n :: (List.map pretty_instruction b)))
      rfs)]
  | AccessRecursiveBinding n -> SExpr.tagged_list "AccessRecursiveBinding" [Int n]
  | Let -> SExpr.Atom "Let"
  | EndLet -> SExpr.Atom "EndLet"
  | CreateGlobal -> SExpr.Atom "CreateGlobal"
  | AccessGlobal n -> SExpr.tagged_list "AccessGlobal" [Int n]
  | Call -> SExpr.Atom "Call"
  | TailCall -> SExpr.Atom "TailCall"
  | CallGlobal n -> SExpr.tagged_list "CallGlobal" [Int n]
  | TailCallGlobal n -> SExpr.tagged_list "TailCallGlobal" [Int n]
  | CallLocal n -> SExpr.tagged_list "CallLocal" [Int n]
  | TailCallLocal n -> SExpr.tagged_list "TailCallLocal" [Int n]
  | CallRecursiveBinding(n, k) ->
    SExpr.tagged_list "CallRecursiveBinding" [Int n; SExpr.Atom "->"; Int k]
  | TailCallRecursiveBinding(n, k) ->
    SExpr.tagged_list "TailCallRecursiveBinding" [Int n; SExpr.Atom "->"; Int k]
  | CallExtern(name, arity) -> SExpr.tagged_list "CallExtern" [SExpr.Atom name; Int arity]
  | Return -> SExpr.Atom "Return"
  | Handle h ->
    SExpr.tagged_list "Handle"
      (List.map pretty_instruction h.body @ [SExpr.Atom "with"]
        @ List.map pretty_instruction h.op_handler)
  | EndHandle -> SExpr.Atom "EndHandle"
  | MakeRecord n -> SExpr.tagged_list "MakeRecord" [Int n]
  | MakeConstructor(k, n) -> SExpr.tagged_list "MakeConstructor" [Int k; Int n]
  | GetField n -> SExpr.tagged_list "GetField" [Int n]
  | Match branches -> SExpr.tagged_list "Match"
    [SExpr.tagged_list "->"
      (List.map (fun b -> SExpr.mk_list (List.map pretty_instruction b)) branches)]
  | Switch branches -> SExpr.tagged_list "Switch"
    [SExpr.tagged_list "->"
      (List.map (fun b -> SExpr.mk_list (List.map pretty_instruction b)) branches)]
  | Op n -> SExpr.tagged_list "Op" [Int n]
  | BranchZero(left, right) ->
    SExpr.tagged_list "BranchZero"
      [SExpr.mk_list (List.map pretty_instruction left);
       SExpr.mk_list (List.map pretty_instruction right)]
  | BranchNonZero(left, right) ->
    SExpr.tagged_list "BranchNonZero"
      [SExpr.mk_list (List.map pretty_instruction left);
       SExpr.mk_list (List.map pretty_instruction right)]
  | Exit -> SExpr.Atom "Exit"
  | Nop -> SExpr.Atom "Nop"

let pretty_program (Instructions defs) = List.map pretty_instruction defs |> SExpr.mk_list

let flow_node : program Flow.node = Flow.Node.create
  ~cmd_line_flag: "-abstract-hvm"
  "abstract hvm"

let _ : Flow.tag =
  Flow.register_transform
    ~provides_tags: [ CommonTags.pretty ]
    ~source: flow_node
    ~target: SExpr.flow_node
    ~name:   "Abstract hvm --> SExpr (pretty printer)"
    (fun program _ -> Flow.return (pretty_program program))