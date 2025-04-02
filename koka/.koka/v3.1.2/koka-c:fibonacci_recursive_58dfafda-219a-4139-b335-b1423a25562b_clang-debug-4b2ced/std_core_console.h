#pragma once
#ifndef kk_std_core_console_H
#define kk_std_core_console_H
// Koka generated module: std/core/console, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_unsafe.h"
#include "std_core_hnd.h"
#include "std_core_string.h"
#include "std_core_show.h"

// type declarations

// type std/core/console/console
struct kk_std_core_console__console_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_console__console;
static inline kk_std_core_console__console kk_std_core_console__console_dup(kk_std_core_console__console _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_console__console_drop(kk_std_core_console__console _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_console__console_box(kk_std_core_console__console _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_console__console kk_std_core_console__console_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value declarations

extern kk_ref_t kk_std_core_console_redirect;

kk_unit_t kk_std_core_console_xprints(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> console () */ 

kk_unit_t kk_std_core_console_xprintsln(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> console () */ 

kk_unit_t kk_std_core_console_prints(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> console () */ 
 
// Print a value that has a `show` function

static inline kk_unit_t kk_std_core_console_show_fs_print(kk_box_t x, kk_function_t _implicit_fs_show, kk_context_t* _ctx) { /* forall<a> (x : a, ?show : (a) -> string) -> console () */ 
  kk_string_t _x_x35 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_show, (_implicit_fs_show, x, _ctx), _ctx); /*string*/
  kk_std_core_console_prints(_x_x35, _ctx); return kk_Unit;
}
 
// Print a string to the console.

static inline kk_unit_t kk_std_core_console_string_fs_print(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> console () */ 
  kk_std_core_console_prints(s, _ctx); return kk_Unit;
}

kk_unit_t kk_std_core_console_print_redirect(kk_function_t print, kk_context_t* _ctx); /* (print : (msg : string) -> console ()) -> <st<global>,console,ndet> () */ 

kk_unit_t kk_std_core_console_printsln(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> console () */ 
 
// Print a value that has a `show` function, including a final newline character.

static inline kk_unit_t kk_std_core_console_show_fs_println(kk_box_t x, kk_function_t _implicit_fs_show, kk_context_t* _ctx) { /* forall<a> (x : a, ?show : (a) -> string) -> console () */ 
  kk_string_t _x_x47 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_show, (_implicit_fs_show, x, _ctx), _ctx); /*string*/
  kk_std_core_console_printsln(_x_x47, _ctx); return kk_Unit;
}
 
// Print a string to the console, including a final newline character.

static inline kk_unit_t kk_std_core_console_string_fs_println(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> console () */ 
  kk_std_core_console_printsln(s, _ctx); return kk_Unit;
}

void kk_std_core_console__init(kk_context_t* _ctx);


void kk_std_core_console__done(kk_context_t* _ctx);

#endif // header
