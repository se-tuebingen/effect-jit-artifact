
type efftag = Utils.UID.t

let fresh_efftag () = Utils.UID.fresh ()
let efftag_equal = Utils.UID.equal

type value =
| VConst     of Lang.RichBaseType.lit
| VFn        of (value -> cont -> ans)
| VInstFun   of (efftag -> cont -> ans)
| VTypeFun   of (cont -> ans)
| VTuple     of value list
| VCtor      of value * int * value list
| VRecord    of value * value list
| VDataDef   of string list
| VRecordDef of string list
| VEffsigDef of string list
| VSeal      of Utils.Seal.seal

and cont = value -> ans

and ans =
| RValue     of value
| RPushFrame of cont * frame * ans
| RDoOp      of efftag * value * int * value list * cont * (frame * cont) list

and frame =
  { f_tag     : efftag
  ; f_handler : handler list
  ; f_return  : value -> cont -> ans
  }

and handler = value list -> value -> cont -> ans

let v_class : value Predef.Value.value_class =
  let unit_def = VDataDef [ "()" ] in
  let bool_def = VDataDef [ "False"; "True" ] in
  let list_def = VDataDef [ "[]"; "(::)" ] in
  { v_unit    = VCtor(unit_def, 0, [])
  ; list_nil  = VCtor(list_def, 0, [])
  ; list_cons = (fun x xs -> VCtor(list_def, 1, [ x; xs ]))
  ; of_int    = (fun n -> VConst (LNum n))
  ; of_bool   = (fun b -> VCtor(bool_def, (if b then 1 else 0), []))
  ; of_string = (fun s -> VConst (LString s))
  ; of_char   = (fun c -> VConst (LChar c))
  ; of_func   = (fun f -> VFn(fun v cont -> cont (f v)))
  ; of_seal   = (fun s -> VSeal s)
  ; to_int    =
    begin function
    | VConst(LNum n) -> n
    | _ -> failwith "Core: not an integer"
    end
  ; to_bool   =
    begin function
    | VCtor(_, 0, []) -> false
    | VCtor(_, 1, []) -> true
    | _ -> failwith "Core: not a boolean"
    end
  ; to_string =
    begin function
    | VConst(LString s) -> s
    | _ -> failwith "Core: not a string"
    end
  ; to_char   =
    begin function
    | VConst(LChar c) -> c
    | _ -> failwith "Core: not a char"
    end
  ; to_seal   =
    begin function
    | VSeal s -> s
    | _ -> failwith "Core: not a seal"
    end
  }

let rec pretty_value prec v =
  match v with
  | VConst lit -> Box.const (Lang.RichBaseType.to_string lit)
  | VFn      _ -> Box.word "<func>"
  | VInstFun _ -> Box.word "<func>"
  | VTypeFun _ -> Box.word "<func>"
  | VTuple   _ -> Box.word "<abstr>"
  | VCtor(proof, n, vs) ->
    begin match proof with
    | VDataDef names ->
      let name = List.nth names n in
      begin match vs with
      | [] -> Box.word name
      | _  ->
        Box.prec_paren 0 prec
          (Box.box (Box.word name ::
            List.map (fun v -> Box.indent 2 (Box.ws (pretty_value 1 v))) vs))
      end
    | _ -> Box.word ~attrs:[Error] "<broken-data>"
    end
  | VRecord(proof, vs) ->
    begin match proof with
    | VRecordDef [] -> Box.word "{}"
    | VRecordDef(name :: names) ->
      let pretty_field sep name v =
        Box.ws (Box.prefix (Box.word sep)
          (Box.box
          [ Box.box [ Box.word name; Box.ws (Box.oper "=") ]
          ; Box.indent 2 (Box.ws (pretty_value 0 v))
          ]))
      in
      Box.box
      (  pretty_field "{ " name (List.hd vs)
      :: List.map2 (pretty_field "; ") names (List.tl vs)
      @ [ Box.ws (Box.word "}") ])
    | _ -> Box.word ~attrs:[Error] "<broken-data>"
    end
  | VDataDef   _ -> Box.word "<type>"
  | VRecordDef _ -> Box.word "<type>"
  | VEffsigDef _ -> Box.word "<effsig>"
  | VSeal      _ -> Box.word "<abstr>"

let pretty v = pretty_value 0 v
