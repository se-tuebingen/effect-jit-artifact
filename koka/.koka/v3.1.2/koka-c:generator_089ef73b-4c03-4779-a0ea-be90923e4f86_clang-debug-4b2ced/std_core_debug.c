// Koka generated module: std/core/debug, koka version: 3.1.2, platform: 64-bit
#include "std_core_debug.h"
/*---------------------------------------------------------------------------
  Copyright 2020-2024, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

kk_unit_t kk_assert_fail( kk_string_t msg, kk_context_t* ctx ) {
  kk_fatal_error(EINVAL, "assertion failed: %s\n", kk_string_cbuf_borrow(msg,NULL,ctx));
  kk_string_drop(msg,ctx);
  return kk_Unit;
}


kk_unit_t kk_std_core_debug_unsafe_assert_fail(kk_string_t msg, kk_context_t* _ctx) { /* (msg : string) -> () */ 
  kk_assert_fail(msg,kk_context()); return kk_Unit;
}
kk_define_string_literal_empty(, kk_std_core_debug_file_fs_kk_file)
kk_define_string_literal_empty(, kk_std_core_debug_file_fs_kk_line)
 
// Explicitly trigger a breakpoint

kk_unit_t kk_std_core_debug_breakpoint(kk_context_t* _ctx) { /* () -> ndet () */ 
  kk_debugger_break(kk_context()); return kk_Unit;
}

kk_ref_t kk_std_core_debug_trace_enabled;

kk_unit_t kk_std_core_debug_xtrace(kk_string_t message, kk_context_t* _ctx) { /* (message : string) -> () */ 
  kk_trace(message,kk_context()); return kk_Unit;
}

kk_unit_t kk_std_core_debug_xtrace_any(kk_string_t message, kk_box_t x, kk_context_t* _ctx) { /* forall<a> (message : string, x : a) -> () */ 
  kk_trace_any(message,x,kk_context()); return kk_Unit;
}
kk_define_string_literal_empty(, kk_std_core_debug_file_fs_kk_module)

kk_unit_t kk_std_core_debug_assert(kk_string_t message, bool condition, kk_string_t _implicit_fs_kk_file_line, kk_context_t* _ctx) { /* (message : string, condition : bool, ?kk-file-line : string) -> () */ 
  if (condition) {
    kk_string_drop(_implicit_fs_kk_file_line, _ctx);
    kk_string_drop(message, _ctx);
    kk_Unit; return kk_Unit;
  }
  {
    kk_string_t _x_x24;
    kk_string_t _x_x25;
    kk_string_t _x_x26;
    kk_define_string_literal(, _s_x27, 2, ": ", _ctx)
    _x_x26 = kk_string_dup(_s_x27, _ctx); /*string*/
    _x_x25 = kk_std_core_types__lp__plus__plus__rp_(_x_x26, message, _ctx); /*string*/
    _x_x24 = kk_std_core_types__lp__plus__plus__rp_(_implicit_fs_kk_file_line, _x_x25, _ctx); /*string*/
    kk_std_core_debug_unsafe_assert_fail(_x_x24, _ctx); return kk_Unit;
  }
}
 
// Disable tracing completely.

kk_unit_t kk_std_core_debug_notrace(kk_context_t* _ctx) { /* () -> (st<global>) () */ 
  kk_ref_set_borrow(kk_std_core_debug_trace_enabled,(kk_bool_box(false)),kk_context()); return kk_Unit;
}
 
// Trace a message used for debug purposes.
// The behaviour is system dependent. On a browser and node it uses
// `console.log`  by default.
// Disabled if `notrace` is called.

kk_unit_t kk_std_core_debug_trace(kk_string_t message, kk_context_t* _ctx) { /* (message : string) -> () */ 
  bool _match_x17;
  kk_box_t _x_x28;
  kk_ref_t _x_x29 = kk_ref_dup(kk_std_core_debug_trace_enabled, _ctx); /*ref<global,bool>*/
  _x_x28 = kk_ref_get(_x_x29,kk_context()); /*1454*/
  _match_x17 = kk_bool_unbox(_x_x28); /*bool*/
  if (_match_x17) {
    kk_std_core_debug_xtrace(message, _ctx); return kk_Unit;
  }
  {
    kk_string_drop(message, _ctx);
    kk_Unit; return kk_Unit;
  }
}

kk_unit_t kk_std_core_debug_trace_any(kk_string_t message, kk_box_t x, kk_context_t* _ctx) { /* forall<a> (message : string, x : a) -> () */ 
  bool _match_x16;
  kk_box_t _x_x30;
  kk_ref_t _x_x31 = kk_ref_dup(kk_std_core_debug_trace_enabled, _ctx); /*ref<global,bool>*/
  _x_x30 = kk_ref_get(_x_x31,kk_context()); /*1498*/
  _match_x16 = kk_bool_unbox(_x_x30); /*bool*/
  if (_match_x16) {
    kk_std_core_debug_xtrace_any(message, x, _ctx); return kk_Unit;
  }
  {
    kk_box_drop(x, _ctx);
    kk_string_drop(message, _ctx);
    kk_Unit; return kk_Unit;
  }
}

kk_unit_t kk_std_core_debug_trace_info(kk_string_t message, kk_string_t _implicit_fs_kk_file_line, kk_context_t* _ctx) { /* (message : string, ?kk-file-line : string) -> () */ 
  kk_string_t message_0_10004;
  kk_string_t _x_x32;
  kk_string_t _x_x33;
  kk_define_string_literal(, _s_x34, 2, ": ", _ctx)
  _x_x33 = kk_string_dup(_s_x34, _ctx); /*string*/
  _x_x32 = kk_std_core_types__lp__plus__plus__rp_(_x_x33, message, _ctx); /*string*/
  message_0_10004 = kk_std_core_types__lp__plus__plus__rp_(_implicit_fs_kk_file_line, _x_x32, _ctx); /*string*/
  bool _match_x15;
  kk_box_t _x_x35;
  kk_ref_t _x_x36 = kk_ref_dup(kk_std_core_debug_trace_enabled, _ctx); /*ref<global,bool>*/
  _x_x35 = kk_ref_get(_x_x36,kk_context()); /*1454*/
  _match_x15 = kk_bool_unbox(_x_x35); /*bool*/
  if (_match_x15) {
    kk_std_core_debug_xtrace(message_0_10004, _ctx); return kk_Unit;
  }
  {
    kk_string_drop(message_0_10004, _ctx);
    kk_Unit; return kk_Unit;
  }
}

kk_unit_t kk_std_core_debug_trace_show(kk_box_t x, kk_function_t _implicit_fs_show, kk_string_t _implicit_fs_kk_file_line, kk_context_t* _ctx) { /* forall<a> (x : a, ?show : (a) -> string, ?kk-file-line : string) -> () */ 
  kk_string_t message_10006 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_show, (_implicit_fs_show, x, _ctx), _ctx); /*string*/;
  kk_string_t message_0_10004;
  kk_string_t _x_x37;
  kk_string_t _x_x38;
  kk_define_string_literal(, _s_x39, 2, ": ", _ctx)
  _x_x38 = kk_string_dup(_s_x39, _ctx); /*string*/
  _x_x37 = kk_std_core_types__lp__plus__plus__rp_(_x_x38, message_10006, _ctx); /*string*/
  message_0_10004 = kk_std_core_types__lp__plus__plus__rp_(_implicit_fs_kk_file_line, _x_x37, _ctx); /*string*/
  bool _match_x14;
  kk_box_t _x_x40;
  kk_ref_t _x_x41 = kk_ref_dup(kk_std_core_debug_trace_enabled, _ctx); /*ref<global,bool>*/
  _x_x40 = kk_ref_get(_x_x41,kk_context()); /*1454*/
  _match_x14 = kk_bool_unbox(_x_x40); /*bool*/
  if (_match_x14) {
    kk_std_core_debug_xtrace(message_0_10004, _ctx); return kk_Unit;
  }
  {
    kk_string_drop(message_0_10004, _ctx);
    kk_Unit; return kk_Unit;
  }
}

// initialization
void kk_std_core_debug__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_unsafe__init(_ctx);
  kk_std_core_hnd__init(_ctx);
  kk_std_core_string__init(_ctx);
  kk_std_core_console__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
  {
    kk_std_core_debug_trace_enabled = kk_ref_alloc((kk_bool_box(true)),kk_context()); /*ref<global,bool>*/
  }
}

// termination
void kk_std_core_debug__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_ref_drop(kk_std_core_debug_trace_enabled, _ctx);
  kk_std_core_console__done(_ctx);
  kk_std_core_string__done(_ctx);
  kk_std_core_hnd__done(_ctx);
  kk_std_core_unsafe__done(_ctx);
  kk_std_core_types__done(_ctx);
}
