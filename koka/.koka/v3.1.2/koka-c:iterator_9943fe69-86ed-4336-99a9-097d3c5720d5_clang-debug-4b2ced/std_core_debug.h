#pragma once
#ifndef kk_std_core_debug_H
#define kk_std_core_debug_H
// Koka generated module: std/core/debug, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_unsafe.h"
#include "std_core_hnd.h"
#include "std_core_string.h"
#include "std_core_console.h"

// type declarations

// value declarations

kk_unit_t kk_std_core_debug_unsafe_assert_fail(kk_string_t msg, kk_context_t* _ctx); /* (msg : string) -> () */ 
 
// Compilation constant that is replaced with the current file name

extern kk_string_t kk_std_core_debug_file_fs_kk_file;
 
// Compilation constant that is replaced with the current line number

extern kk_string_t kk_std_core_debug_file_fs_kk_line;

kk_unit_t kk_std_core_debug_breakpoint(kk_context_t* _ctx); /* () -> ndet () */ 

extern kk_ref_t kk_std_core_debug_trace_enabled;

kk_unit_t kk_std_core_debug_xtrace(kk_string_t message, kk_context_t* _ctx); /* (message : string) -> () */ 

kk_unit_t kk_std_core_debug_xtrace_any(kk_string_t message, kk_box_t x, kk_context_t* _ctx); /* forall<a> (message : string, x : a) -> () */ 
 
// Compilation constant that is replaced with the current file's module name

extern kk_string_t kk_std_core_debug_file_fs_kk_module;

static inline kk_string_t kk_std_core_debug_file_fs_kk_file_line(kk_string_t _implicit_fs_kk_file, kk_string_t _implicit_fs_kk_line, kk_context_t* _ctx) { /* (?kk-file : string, ?kk-line : string) -> string */ 
  kk_string_t _x_x18;
  kk_string_t _x_x19;
  kk_define_string_literal(, _s_x20, 1, "(", _ctx)
  _x_x19 = kk_string_dup(_s_x20, _ctx); /*string*/
  kk_string_t _x_x21;
  kk_string_t _x_x22;
  kk_define_string_literal(, _s_x23, 1, ")", _ctx)
  _x_x22 = kk_string_dup(_s_x23, _ctx); /*string*/
  _x_x21 = kk_std_core_types__lp__plus__plus__rp_(_implicit_fs_kk_line, _x_x22, _ctx); /*string*/
  _x_x18 = kk_std_core_types__lp__plus__plus__rp_(_x_x19, _x_x21, _ctx); /*string*/
  return kk_std_core_types__lp__plus__plus__rp_(_implicit_fs_kk_file, _x_x18, _ctx);
}

kk_unit_t kk_std_core_debug_assert(kk_string_t message, bool condition, kk_string_t _implicit_fs_kk_file_line, kk_context_t* _ctx); /* (message : string, condition : bool, ?kk-file-line : string) -> () */ 

kk_unit_t kk_std_core_debug_notrace(kk_context_t* _ctx); /* () -> (st<global>) () */ 

kk_unit_t kk_std_core_debug_trace(kk_string_t message, kk_context_t* _ctx); /* (message : string) -> () */ 

kk_unit_t kk_std_core_debug_trace_any(kk_string_t message, kk_box_t x, kk_context_t* _ctx); /* forall<a> (message : string, x : a) -> () */ 

kk_unit_t kk_std_core_debug_trace_info(kk_string_t message, kk_string_t _implicit_fs_kk_file_line, kk_context_t* _ctx); /* (message : string, ?kk-file-line : string) -> () */ 

kk_unit_t kk_std_core_debug_trace_show(kk_box_t x, kk_function_t _implicit_fs_show, kk_string_t _implicit_fs_kk_file_line, kk_context_t* _ctx); /* forall<a> (x : a, ?show : (a) -> string, ?kk-file-line : string) -> () */ 

void kk_std_core_debug__init(kk_context_t* _ctx);


void kk_std_core_debug__done(kk_context_t* _ctx);

#endif // header
