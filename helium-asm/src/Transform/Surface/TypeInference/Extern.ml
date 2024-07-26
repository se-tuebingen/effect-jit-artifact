open Lang.Node
open Common

let base_type (type td) ~fix ~env ~pos tp (tp_req : (td, _) request) :
    td checked_value =
  let tp = T.TExists([], T.Type.base tp) in
  let tp_wit = T.Type.type_wit tp in
  let (tp_resp, crc) =
    Request.return_type ~env ~pos ~syncat:Expression tp_req tp_wit in
  { cv_value = ExprBuilder.coerce_value_opt ~fix ~pos crc
      (make ~fix pos (T.VTypeWit tp))
  ; cv_type = tp_resp
  }

let check (type td) ~fix ~env ~pos name (tp_req : (td, _) request) :
    td checked_value =
  match name.data with
  | "helium_Int"    -> base_type ~fix ~env ~pos TInt    tp_req
  | "helium_String" -> base_type ~fix ~env ~pos TString tp_req
  | "helium_Char"   -> base_type ~fix ~env ~pos TChar   tp_req
  
  | _ ->
    begin match tp_req with
    | Check tp ->
      { cv_value = make ~fix pos (T.VExtern(name.data, tp))
      ; cv_type  = Checked
      }
    | Infer ->
      raise (Error.cannot_infer_extern_type ~pos)
    end
