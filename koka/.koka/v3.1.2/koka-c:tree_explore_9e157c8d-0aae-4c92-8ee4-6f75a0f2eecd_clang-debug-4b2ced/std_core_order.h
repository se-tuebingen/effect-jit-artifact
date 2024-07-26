#pragma once
#ifndef kk_std_core_order_H
#define kk_std_core_order_H
// Koka generated module: std/core/order, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_int.h"

// type declarations

// value declarations

static inline kk_integer_t kk_std_core_order_int(kk_std_core_types__order x, kk_context_t* _ctx) { /* (x : order) -> int */ 
  if (kk_std_core_types__is_Lt(x, _ctx)) {
    return kk_integer_from_small(-1);
  }
  if (kk_std_core_types__is_Eq(x, _ctx)) {
    return kk_integer_from_small(0);
  }
  {
    return kk_integer_from_small(1);
  }
}
 
// Convert an `:order2` to an `:int` (`-1`, `0`, or `1`)

static inline kk_integer_t kk_std_core_order_order2_fs_int(kk_std_core_types__order2 x, kk_context_t* _ctx) { /* forall<a> (x : order2<a>) -> int */ 
  if (kk_std_core_types__is_Lt2(x, _ctx)) {
    kk_std_core_types__order2_drop(x, _ctx);
    return kk_integer_from_small(-1);
  }
  if (kk_std_core_types__is_Eq2(x, _ctx)) {
    kk_std_core_types__order2_drop(x, _ctx);
    return kk_integer_from_small(0);
  }
  {
    kk_std_core_types__order2_drop(x, _ctx);
    return kk_integer_from_small(1);
  }
}

kk_std_core_types__order2 kk_std_core_order_order2(kk_box_t x, kk_box_t y, kk_function_t cmp, kk_context_t* _ctx); /* forall<a> (x : a, y : a, cmp : (a, a) -> order) -> order2<a> */ 

bool kk_std_core_order__lp__excl__eq__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx); /* (x : order, y : order) -> bool */ 

bool kk_std_core_order__lp__lt__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx); /* (x : order, y : order) -> bool */ 

bool kk_std_core_order__lp__lt__eq__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx); /* (x : order, y : order) -> bool */ 

bool kk_std_core_order__lp__eq__eq__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx); /* (x : order, y : order) -> bool */ 

bool kk_std_core_order__lp__gt__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx); /* (x : order, y : order) -> bool */ 

bool kk_std_core_order__lp__gt__eq__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx); /* (x : order, y : order) -> bool */ 

void kk_std_core_order__init(kk_context_t* _ctx);


void kk_std_core_order__done(kk_context_t* _ctx);

#endif // header
