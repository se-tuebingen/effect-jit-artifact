#pragma once
#ifndef kk_std_core_unsafe_H
#define kk_std_core_unsafe_H
// Koka generated module: std/core/unsafe, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"

// type declarations

// value declarations
 
// _Unsafe_. This function pretends the given `action` is deterministic

static inline kk_box_t kk_std_core_unsafe_pretend_no_ndet(kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (action : () -> <ndet|e> a) -> e a */ 
  return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx);
}
 
// _Unsafe_. This function calls a function and pretends it did not have any effect at all.
// Use with utmost care as it should not be used to dismiss user-defined effects that need
// a handler and can cause a segfault at runtime in such cases!
//
// You can use `unsafe-total` to dismiss built-in effects without handlers which include:
//
// - behavioral: `:div` (non-termination/divergence), `:ndet` (non-determinism)
// - state: `:alloc`, `:read`, `:write`, `:st`
// - external: `:ui`, `:fsys`, `:net`, `:blocking`
// - combinations: `:io-total` and `:io-noexn`
//
// Do _not_ dismiss `:io` since it has the `:exn` effect that should be handled (and an evidence
// vector should be passed in).
//
// Try to avoid using `unsafe-total` to initialize global values that have a side-effect, but
// use `std/core/delayed/delay` instead:
// ```
// val myglobal = delay( fn() initialize() )
// fun get-global() : e int
//   myglobal.force
// ```

static inline kk_box_t kk_std_core_unsafe_unsafe_total(kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (action : () -> e a) -> a */ 
  return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx);
}

void kk_std_core_unsafe__init(kk_context_t* _ctx);


void kk_std_core_unsafe__done(kk_context_t* _ctx);

#endif // header
