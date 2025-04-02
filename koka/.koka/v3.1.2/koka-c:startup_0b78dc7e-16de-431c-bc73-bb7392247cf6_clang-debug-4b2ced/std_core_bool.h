#pragma once
#ifndef kk_std_core_bool_H
#define kk_std_core_bool_H
// Koka generated module: std/core/bool, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"

// type declarations

// value declarations

static inline bool kk_std_core_bool__lp__excl__eq__rp_(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> bool */ 
  if (x) {
    if (y) {
      return false;
    }
    {
      return true;
    }
  }
  {
    return y;
  }
}

static inline bool kk_std_core_bool__lp__lt__rp_(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> bool */ 
  if (x) {
    return false;
  }
  {
    return y;
  }
}

static inline bool kk_std_core_bool__lp__gt__rp_(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> bool */ 
  if (x) {
    if (y) {
      return false;
    }
    {
      return true;
    }
  }
  {
    return false;
  }
}

static inline bool kk_std_core_bool__lp__eq__eq__rp_(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> bool */ 
  if (x) {
    return y;
  }
  if (y) {
    return false;
  }
  {
    return true;
  }
}
 
// Convert a boolean to an `:int`

static inline kk_integer_t kk_std_core_bool_int(bool b, kk_context_t* _ctx) { /* (b : bool) -> int */ 
  if (b) {
    return kk_integer_from_small(1);
  }
  {
    return kk_integer_from_small(0);
  }
}
 
// Convert a `:bool` to a string

static inline kk_string_t kk_std_core_bool_show(bool b, kk_context_t* _ctx) { /* (b : bool) -> string */ 
  if (b) {
    kk_define_string_literal(, _s_x15, 4, "True", _ctx)
    return kk_string_dup(_s_x15, _ctx);
  }
  {
    kk_define_string_literal(, _s_x16, 5, "False", _ctx)
    return kk_string_dup(_s_x16, _ctx);
  }
}

static inline bool kk_std_core_bool__lp__lt__eq__rp_(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> bool */ 
  if (x) {
    if (y) {
      return true;
    }
    {
      return false;
    }
  }
  {
    return true;
  }
}

static inline bool kk_std_core_bool__lp__gt__eq__rp_(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> bool */ 
  if (x) {
    return true;
  }
  if (y) {
    return false;
  }
  {
    return true;
  }
}

kk_std_core_types__order kk_std_core_bool_cmp(bool x, bool y, kk_context_t* _ctx); /* (x : bool, y : bool) -> order */ 

kk_std_core_types__order2 kk_std_core_bool_order2(bool x, bool y, kk_context_t* _ctx); /* (x : bool, y : bool) -> order2<bool> */ 

void kk_std_core_bool__init(kk_context_t* _ctx);


void kk_std_core_bool__done(kk_context_t* _ctx);

#endif // header
