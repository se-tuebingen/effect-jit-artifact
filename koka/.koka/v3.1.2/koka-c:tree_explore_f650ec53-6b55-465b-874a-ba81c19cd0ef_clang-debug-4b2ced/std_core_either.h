#pragma once
#ifndef kk_std_core_either_H
#define kk_std_core_either_H
// Koka generated module: std/core/either, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_hnd.h"

// type declarations

// value declarations
 
// monadic lift

static inline kk_std_core_types__either kk_std_core_either__mlift_map_10005(kk_box_t _y_x10000, kk_context_t* _ctx) { /* forall<a,b,e> (b) -> e either<a,b> */ 
  return kk_std_core_types__new_Right(_y_x10000, _ctx);
}

kk_std_core_types__either kk_std_core_either_map(kk_std_core_types__either e, kk_function_t f, kk_context_t* _ctx); /* forall<a,b,c,e> (e : either<a,b>, f : (b) -> e c) -> e either<a,c> */ 
 
// Convert a `:either` to a `:maybe` type discarding the value of the `Left` constructor
// and using `Just` for the `Right` constructor.

static inline kk_std_core_types__maybe kk_std_core_either_maybe(kk_std_core_types__either e, kk_context_t* _ctx) { /* forall<a,b> (e : either<a,b>) -> maybe<b> */ 
  if (kk_std_core_types__is_Left(e, _ctx)) {
    kk_std_core_types__either_drop(e, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
  {
    kk_box_t x = e._cons.Right.right;
    return kk_std_core_types__new_Just(x, _ctx);
  }
}
 
// monadic lift

static inline kk_string_t kk_std_core_either__mlift_show_10006(kk_string_t _y_x10002, kk_context_t* _ctx) { /* forall<e> (string) -> e string */ 
  kk_string_t _x_x18;
  kk_define_string_literal(, _s_x19, 6, "Right(", _ctx)
  _x_x18 = kk_string_dup(_s_x19, _ctx); /*string*/
  kk_string_t _x_x20;
  kk_string_t _x_x21;
  kk_define_string_literal(, _s_x22, 1, ")", _ctx)
  _x_x21 = kk_string_dup(_s_x22, _ctx); /*string*/
  _x_x20 = kk_std_core_types__lp__plus__plus__rp_(_y_x10002, _x_x21, _ctx); /*string*/
  return kk_std_core_types__lp__plus__plus__rp_(_x_x18, _x_x20, _ctx);
}
 
// monadic lift

static inline kk_string_t kk_std_core_either__mlift_show_10007(kk_string_t _y_x10003, kk_context_t* _ctx) { /* forall<e> (string) -> e string */ 
  kk_string_t _x_x23;
  kk_define_string_literal(, _s_x24, 5, "Left(", _ctx)
  _x_x23 = kk_string_dup(_s_x24, _ctx); /*string*/
  kk_string_t _x_x25;
  kk_string_t _x_x26;
  kk_define_string_literal(, _s_x27, 1, ")", _ctx)
  _x_x26 = kk_string_dup(_s_x27, _ctx); /*string*/
  _x_x25 = kk_std_core_types__lp__plus__plus__rp_(_y_x10003, _x_x26, _ctx); /*string*/
  return kk_std_core_types__lp__plus__plus__rp_(_x_x23, _x_x25, _ctx);
}

kk_string_t kk_std_core_either_show(kk_std_core_types__either e, kk_function_t _implicit_fs_left_fs_show, kk_function_t _implicit_fs_right_fs_show, kk_context_t* _ctx); /* forall<a,b,e> (e : either<a,b>, ?left/show : (a) -> e string, ?right/show : (b) -> e string) -> e string */ 

void kk_std_core_either__init(kk_context_t* _ctx);


void kk_std_core_either__done(kk_context_t* _ctx);

#endif // header
