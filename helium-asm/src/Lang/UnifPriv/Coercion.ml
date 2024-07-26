open TypingStructure
open Syntax

let rec match_instances xs insts =
  match xs, insts with
  | [], [] -> true
  | TVar.Pack x :: xs, TpInst(y, tp) :: insts ->
    begin match Kind.equal (TVar.kind x) (TVar.kind y) with
    | Equal ->
      begin match Type.view tp with
      | TNeutral (TVar z) when TVar.equal x z ->
        match_instances xs insts
      | _ -> false
      end
    | NotEqual -> false
    end
  | [], _ :: _ | _ :: _, [] -> false

let rec id_struct_coercion decls dcs =
  match decls, dcs with
  | [], [] -> true
  | decl :: decls, dc :: dcs ->
    begin match decl, dc with
    | DeclThis _, DCThis(CId _) -> id_struct_coercion decls dcs
    | DeclThis _, _ -> false

    | DeclTypedef _, DCTypedef(CId _) -> id_struct_coercion decls dcs
    | DeclTypedef _, _ -> false

    | DeclVal(name1, _), DCVal(name2, CId _) when name1 = name2 ->
      id_struct_coercion decls dcs
    | DeclVal _, _ -> false

    | DeclOp(_, _, ops1, n), DCOp(xs, _, ops2, insts, m) ->
      if n = m
        && Decl.op_decl_name' ops1 n = Decl.op_decl_name' ops2 n
        && match_instances xs insts then
          id_struct_coercion decls dcs
      else false
    | DeclOp _, _ -> false

    | DeclCtor(_, _, ctors1, n), DCCtor(xs, _, ctors2, insts, m) ->
      if n = m
        && Decl.ctor_decl_name' ctors1 n = Decl.ctor_decl_name' ctors2 n
        && match_instances xs insts then
          id_struct_coercion decls dcs
      else false
    | DeclCtor _, _ -> false

    | DeclField(_, _, flds1, n), DCField(xs, _, flds2, insts, m) ->
      if n = m
        && Decl.field_decl_name' flds1 n = Decl.field_decl_name' flds2 n
        && match_instances xs insts then
          id_struct_coercion decls dcs
      else false
    | DeclField _, _ -> false
    end
  | [], _ :: _ | _ :: _, [] -> false

(* ========================================================================= *)
(* Types of coercion *)

let rec input_type crc =
  match crc with
  | CId(tp_in, _) -> tp_in
  | CArrow { name_in = name; arg_crc; res_crc; eff_in; _ } ->
    Type.arrow ?name (output_type arg_crc) (ex_input_type res_crc) eff_in
  | CGen(crc, _, _) -> input_type crc
  | CInst(_, insts, tp) ->
    Type.forall (List.map (fun (TpInst(x, _)) -> TVar.Pack x) insts) tp
  | CForallInst(a, s, crc) ->
    Type.forall_inst a s (input_type crc)
  | CHandler ch ->
    Type.handler ch.effsig
      (ex_output_type ch.in_crc) ch.in_eff_in
      (ex_input_type ch.out_crc) ch.out_eff_in
  | CStruct(decls, _) ->
    Type.tstruct decls
  | CDataDefSeal(tp, ctors) ->
    Type.data_def tp ctors
  | CRecordDefSeal(tp, flds) ->
    Type.record_def tp flds
  | CEffsigDefSeal(s, ops) ->
    Type.effsig_def s ops
  | CThis(decls, _) ->
    Type.tstruct decls
  | CApplyInst(crc, _, _) ->
    input_type crc

and output_type crc =
  match crc with
  | CId(_, tp_out) -> tp_out
  | CArrow { name_out = name; arg_crc; res_crc; eff_out; _ } ->
    Type.arrow ?name (input_type arg_crc) (ex_output_type res_crc) eff_out
  | CGen(_, xs, tp) -> Type.forall xs tp
  | CInst(crc, _, _) -> output_type crc
  | CForallInst(a, s, crc) ->
    Type.forall_inst a s (output_type crc)
  | CHandler ch ->
    Type.handler ch.effsig
      (ex_input_type ch.in_crc)   ch.in_eff_out
      (ex_output_type ch.out_crc) ch.out_eff_out
  | CStruct(_, dcs) ->
    Type.tstruct (List.map decl_output_type dcs)
  | CDataDefSeal(tp, _) ->
    Type.type_wit (TExists([], tp))
  | CRecordDefSeal(tp, _) ->
    Type.type_wit (TExists([], tp))
  | CEffsigDefSeal(s, _) ->
    Type.effsig_wit s
  | CThis(_, crc) ->
    output_type crc
  | CApplyInst(_, _, crc) ->
    output_type crc

and ex_input_type crc =
  match crc with
  | CExId(tp_in, _) -> tp_in
  | CExPack(ex, crc, _, _) -> TExists(ex, input_type crc) 

and ex_output_type crc =
  match crc with
  | CExId(_, tp_out) -> tp_out
  | CExPack(_, _, insts, tp) ->
    TExists(List.map (fun (TpInst(x, _)) -> TVar.Pack x) insts, tp)

and decl_output_type dc =
  match dc with
  | DCThis    crc               -> DeclThis    (output_type crc)
  | DCTypedef crc               -> DeclTypedef (output_type crc)
  | DCVal(name, crc)            -> DeclVal(name, output_type crc)
  | DCOp(xs, s, ops, _, n)      -> DeclOp(xs, s, ops, n)
  | DCCtor(xs, tp, ctors, _, n) -> DeclCtor(xs, tp, ctors, n)
  | DCField(xs, tp, flds, _, n) -> DeclField(xs, tp, flds, n)
  | DCThisSel(_, crc)           -> decl_output_type crc
  | DCOpVal(_, _, ops, n, crc)  ->
    DeclVal(Decl.op_decl_name' ops n, output_type crc)
  | DCCtorVal(_, _, ctors, n, crc) ->
    DeclVal(Decl.ctor_decl_name' ctors n, output_type crc)

(* ========================================================================= *)
(* Smart constructors *)

let carrow ?name_in ?name_out arg_crc res_crc eff_in eff_out =
  match arg_crc, res_crc with
  | CId(tp1_in, tp1_out), CExId(tp2_in, tp2_out) ->
    CId(
      Type.arrow ?name:name_in  tp1_out tp2_in  eff_in,
      Type.arrow ?name:name_out tp1_in  tp2_out eff_out)
  | _ ->
    CArrow { name_in; name_out; arg_crc; res_crc; eff_in; eff_out }

let cgen crc xs tp =
  let c_res = CGen(crc, xs, tp) in
  match crc with
  | CInst(CId _, insts, _) when match_instances xs insts ->
    CId(input_type c_res, output_type c_res)
  | _ -> c_res

let cinst crc insts tp =
  CInst(crc, insts, tp)

let cforall_inst a s crc =
  let c_res = CForallInst(a, s, crc) in
  match crc with
  | CId _ ->
    CId(input_type c_res, output_type c_res)
  | _ -> c_res

let chandler s c1 eff1_in eff1_out c2 eff2_in eff2_out =
  let c_res = CHandler
    { effsig      = s
    ; in_crc      = c1
    ; in_eff_in   = eff1_in
    ; in_eff_out  = eff1_out
    ; out_crc     = c2
    ; out_eff_in  = eff2_in
    ; out_eff_out = eff2_out
    } in
  match c1, c2 with
  | CExId _, CExId _ ->
    CId(input_type c_res, output_type c_res)
  | _ -> c_res

let cstruct decls dcs =
  let c_res = CStruct(decls, dcs) in
  if id_struct_coercion decls dcs then
    CId(input_type c_res, output_type c_res)
  else
    c_res

let cthis decls crc =
  CThis(decls, crc)

let cex_pack xs crc insts tp =
  let c_res = CExPack(xs, crc, insts, tp) in
  match crc with
  | CId _ when match_instances xs insts ->
    CExId(ex_input_type c_res, ex_output_type c_res)
  | _ -> c_res
