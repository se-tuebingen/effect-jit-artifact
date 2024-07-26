(* Compilation to JIT *)
open Utils
open SyntaxJit
open Translate2jit
module Term = Language.Term
module Type = Language.Type
module Primitives = Language.Primitives

module Backend : Language.Backend.S = struct
  type state = Translate2jit.state

  let initial_state =
    {
      (* prog = []; *)
      primitive_effects = [];
      definitions = [];
      tydefs = Assoc.empty;
      main = [];
    }

  (* ------------------------------------------------------------------------ *)
  (* Setup *)

  (* ------------------------------------------------------------------------ *)
  (* Processing functions *)

  let process_computation state (_, cmp, _cnstrs) =
    let core = translate_computation state cmp in
    { state with main = core :: state.main }

  let process_type_of state _ = state

  let process_def_effect state eff =
    let new_def = translate_effect_def state eff in
    { state with definitions = new_def :: state.definitions }

  let process_top_let state defs =
    let new_defs = List.concat_map (translate_top_let state) defs in
    { state with definitions = new_defs @ state.definitions }

  let process_top_let_rec state defs =
    let new_defs =
      List.concat_map (translate_top_letrec state) (Assoc.to_list defs)
    in
    { state with definitions = new_defs @ state.definitions }

  let load_primitive_value state x prim =
    {
      state with
      definitions = generate_primitive_value x prim :: state.definitions;
    }

  let load_primitive_effect state eff prim =
    {
      state with
      primitive_effects =
        translate_primitive_effect state eff prim :: state.primitive_effects;
      definitions = translate_effect_def state eff :: state.definitions;
    }

  let process_tydef state tydefs =
    {
      state with
      tydefs =
        Assoc.concat
          (Assoc.kmap
             (function
               | name, { params = _; Type.type_def } ->
                   (name, translate_type_def state type_def))
             tydefs)
          state.tydefs;
    }

  let finalize state =
    let prog =
      {
        definitions = List.rev state.definitions;
        main =
          wrap_with_primitive_effects state state.primitive_effects
            (Seq (List.rev state.main));
      }
    in
    Format.printf "%a" print_program prog
end
