#pragma once
#ifndef kk_std_core_maybe_H
#define kk_std_core_maybe_H
// Koka generated module: std/core/maybe, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_hnd.h"
#include "std_core_exn.h"

// type declarations

// value declarations
 
// Convert a maybe type to a boolean, equivalent to `is-just`.

static inline bool kk_std_core_maybe_bool(kk_std_core_types__maybe mb, kk_context_t* _ctx) { /* forall<a> (mb : maybe<a>) -> bool */ 
  if (kk_std_core_types__is_Just(mb, _ctx)) {
    kk_std_core_types__maybe_drop(mb, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Convert a `:maybe<a>` value to `:a`, using the `nothing` parameter for `Nothing`.

static inline kk_box_t kk_std_core_maybe_default(kk_std_core_types__maybe m, kk_box_t nothing, kk_context_t* _ctx) { /* forall<a> (m : maybe<a>, nothing : a) -> a */ 
  if (kk_std_core_types__is_Nothing(m, _ctx)) {
    return nothing;
  }
  {
    kk_box_t x = m._cons.Just.value;
    kk_box_drop(nothing, _ctx);
    return x;
  }
}
 
// monadic lift

static inline kk_std_core_types__maybe kk_std_core_maybe__mlift_map_10008(kk_box_t _y_x10000, kk_context_t* _ctx) { /* forall<a,e> (a) -> e maybe<a> */ 
  return kk_std_core_types__new_Just(_y_x10000, _ctx);
}

kk_std_core_types__maybe kk_std_core_maybe_map(kk_std_core_types__maybe m, kk_function_t f, kk_context_t* _ctx); /* forall<a,b,e> (m : maybe<a>, f : (a) -> e b) -> e maybe<b> */ 
 
// Match a `:maybe` value and either return a default value on `Nothing` or apply a function to the value on `Just`

static inline kk_box_t kk_std_core_maybe_maybe(kk_std_core_types__maybe m, kk_box_t onNothing, kk_function_t onJust, kk_context_t* _ctx) { /* forall<a,b,e> (m : maybe<a>, onNothing : b, onJust : (a) -> e b) -> e b */ 
  if (kk_std_core_types__is_Nothing(m, _ctx)) {
    kk_function_drop(onJust, _ctx);
    return onNothing;
  }
  {
    kk_box_t x = m._cons.Just.value;
    kk_box_drop(onNothing, _ctx);
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), onJust, (onJust, x, _ctx), _ctx);
  }
}
 
// Get the value of the `Just` constructor or raise an exception

static inline kk_box_t kk_std_core_maybe_unjust(kk_std_core_types__maybe m, kk_context_t* _ctx) { /* forall<a> (m : maybe<a>) -> exn a */ 
  if (kk_std_core_types__is_Just(m, _ctx)) {
    kk_box_t x = m._cons.Just.value;
    return x;
  }
  {
    kk_string_t _x_x32;
    kk_define_string_literal(, _s_x33, 43, "unexpected Nothing in std/core/maybe/unjust", _ctx)
    _x_x32 = kk_string_dup(_s_x33, _ctx); /*string*/
    return kk_std_core_exn_throw(_x_x32, kk_std_core_types__new_None(_ctx), _ctx);
  }
}

static inline kk_std_core_types__maybe kk_std_core_maybe__lp__bar__bar__rp_(kk_std_core_types__maybe m1, kk_std_core_types__maybe m2, kk_context_t* _ctx) { /* forall<a> (m1 : maybe<a>, m2 : maybe<a>) -> maybe<a> */ 
  if (kk_std_core_types__is_Nothing(m1, _ctx)) {
    return m2;
  }
  {
    kk_std_core_types__maybe_drop(m2, _ctx);
    return m1;
  }
}

bool kk_std_core_maybe__lp__eq__eq__rp_(kk_std_core_types__maybe mb1, kk_std_core_types__maybe mb2, kk_function_t _implicit_fs__lp__eq__eq__rp_, kk_context_t* _ctx); /* forall<a> (mb1 : maybe<a>, mb2 : maybe<a>, ?(==) : (a, a) -> bool) -> bool */ 

kk_std_core_types__order kk_std_core_maybe_cmp(kk_std_core_types__maybe mb1, kk_std_core_types__maybe mb2, kk_function_t _implicit_fs_cmp, kk_context_t* _ctx); /* forall<a> (mb1 : maybe<a>, mb2 : maybe<a>, ?cmp : (a, a) -> order) -> order */ 

kk_std_core_types__order2 kk_std_core_maybe_order2(kk_std_core_types__maybe mb1, kk_std_core_types__maybe mb2, kk_function_t _implicit_fs_order2, kk_context_t* _ctx); /* forall<a> (mb1 : maybe<a>, mb2 : maybe<a>, ?order2 : (a, a) -> order2<a>) -> order2<maybe<a>> */ 
 
// monadic lift

static inline kk_string_t kk_std_core_maybe__mlift_show_10009(kk_string_t _y_x10006, kk_context_t* _ctx) { /* forall<e> (string) -> e string */ 
  kk_string_t _x_x47;
  kk_define_string_literal(, _s_x48, 5, "Just(", _ctx)
  _x_x47 = kk_string_dup(_s_x48, _ctx); /*string*/
  kk_string_t _x_x49;
  kk_string_t _x_x50;
  kk_define_string_literal(, _s_x51, 1, ")", _ctx)
  _x_x50 = kk_string_dup(_s_x51, _ctx); /*string*/
  _x_x49 = kk_std_core_types__lp__plus__plus__rp_(_y_x10006, _x_x50, _ctx); /*string*/
  return kk_std_core_types__lp__plus__plus__rp_(_x_x47, _x_x49, _ctx);
}

kk_string_t kk_std_core_maybe_show(kk_std_core_types__maybe mb, kk_function_t _implicit_fs_show, kk_context_t* _ctx); /* forall<a,e> (mb : maybe<a>, ?show : (a) -> e string) -> e string */ 

void kk_std_core_maybe__init(kk_context_t* _ctx);


void kk_std_core_maybe__done(kk_context_t* _ctx);

#endif // header
