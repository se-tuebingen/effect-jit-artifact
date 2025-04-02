#pragma once
#ifndef kk_std_core_delayed_H
#define kk_std_core_delayed_H
// Koka generated module: std/core/delayed, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_hnd.h"
#include "std_core_unsafe.h"

// type declarations

// value type std/core/delayed/delayed
struct kk_std_core_delayed_XDelay {
  kk_ref_t dref;
};
typedef struct kk_std_core_delayed_XDelay kk_std_core_delayed__delayed;
static inline kk_std_core_delayed__delayed kk_std_core_delayed__new_XDelay(kk_ref_t dref, kk_context_t* _ctx) {
  kk_std_core_delayed__delayed _con = { dref };
  return _con;
}
static inline bool kk_std_core_delayed__is_XDelay(kk_std_core_delayed__delayed x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core_delayed__delayed kk_std_core_delayed__delayed_dup(kk_std_core_delayed__delayed _x, kk_context_t* _ctx) {
  kk_ref_dup(_x.dref, _ctx);
  return _x;
}
static inline void kk_std_core_delayed__delayed_drop(kk_std_core_delayed__delayed _x, kk_context_t* _ctx) {
  kk_ref_drop(_x.dref, _ctx);
}
static inline kk_box_t kk_std_core_delayed__delayed_box(kk_std_core_delayed__delayed _x, kk_context_t* _ctx) {
  return kk_ref_box(_x.dref, _ctx);
}
static inline kk_std_core_delayed__delayed kk_std_core_delayed__delayed_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_std_core_delayed__new_XDelay(kk_ref_unbox(_x, _ctx), _ctx);
}

// value declarations
 
// Automatically generated. Retrieves the `dref` constructor field of the `:delayed` type.

static inline kk_ref_t kk_std_core_delayed_delayed_fs_dref(kk_std_core_delayed__delayed delayed, kk_context_t* _ctx) { /* forall<e,a> (delayed : delayed<e,a>) -> ref<global,either<() -> e a,a>> */ 
  {
    kk_ref_t _x = delayed.dref;
    return kk_ref_dup(_x, _ctx);
  }
}

kk_std_core_delayed__delayed kk_std_core_delayed_delayed_fs__copy(kk_std_core_delayed__delayed _this, kk_std_core_types__optional dref, kk_context_t* _ctx); /* forall<e,a> (delayed<e,a>, dref : ? (ref<global,either<() -> e a,a>>)) -> delayed<e,a> */ 
 
// Create a new `:delayed` value.

static inline kk_std_core_delayed__delayed kk_std_core_delayed_delay(kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (action : () -> e a) -> delayed<e,a> */ 
  kk_ref_t r;
  kk_box_t _x_x35;
  kk_std_core_types__either _x_x36 = kk_std_core_types__new_Left(kk_function_box(action, _ctx), _ctx); /*either<1194,1195>*/
  _x_x35 = kk_std_core_types__either_box(_x_x36, _ctx); /*186*/
  r = kk_ref_alloc(_x_x35,kk_context()); /*ref<global,either<() -> 162 161,161>>*/
  return kk_std_core_delayed__new_XDelay(r, _ctx);
}
 
// monadic lift

static inline kk_box_t kk_std_core_delayed__mlift_force_10010(kk_ref_t r, kk_box_t x_0, kk_context_t* _ctx) { /* forall<a,e> (r : ref<global,either<() -> e a,a>>, x@0 : a) -> <st<global>,div|e> a */ 
  kk_unit_t __ = kk_Unit;
  kk_unit_t _brw_x33 = kk_Unit;
  kk_box_t _x_x37;
  kk_std_core_types__either _x_x38;
  kk_box_t _x_x39 = kk_box_dup(x_0, _ctx); /*270*/
  _x_x38 = kk_std_core_types__new_Right(_x_x39, _ctx); /*either<1312,1313>*/
  _x_x37 = kk_std_core_types__either_box(_x_x38, _ctx); /*1456*/
  kk_ref_set_borrow(r,_x_x37,kk_context());
  kk_ref_drop(r, _ctx);
  _brw_x33;
  return x_0;
}

kk_box_t kk_std_core_delayed_force(kk_std_core_delayed__delayed delayed, kk_context_t* _ctx); /* forall<a,e> (delayed : delayed<e,a>) -> e a */ 

kk_function_t kk_std_core_delayed_once(kk_function_t calc, kk_context_t* _ctx); /* forall<a> (calc : () -> a) -> (() -> a) */ 

void kk_std_core_delayed__init(kk_context_t* _ctx);


void kk_std_core_delayed__done(kk_context_t* _ctx);

#endif // header
