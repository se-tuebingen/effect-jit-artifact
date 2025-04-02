#pragma once
#ifndef kk_std_core_undiv_H
#define kk_std_core_undiv_H
// Koka generated module: std/core/undiv, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"

// type declarations

// value declarations
 
// _Unsafe_. This function pretends that the given action is terminating.

static inline kk_box_t kk_std_core_undiv_pretend_no_div(kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (action : () -> <div|e> a) -> e a */ 
  return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx);
}

void kk_std_core_undiv__init(kk_context_t* _ctx);


void kk_std_core_undiv__done(kk_context_t* _ctx);

#endif // header
