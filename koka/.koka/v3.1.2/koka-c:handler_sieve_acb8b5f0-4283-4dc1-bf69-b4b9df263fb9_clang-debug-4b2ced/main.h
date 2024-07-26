#pragma once
#ifndef kk_main_H
#define kk_main_H
// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_hnd.h"
#include "std_core_exn.h"
#include "std_core_bool.h"
#include "std_core_order.h"
#include "std_core_char.h"
#include "std_core_int.h"
#include "std_core_vector.h"
#include "std_core_string.h"
#include "std_core_sslice.h"
#include "std_core_list.h"
#include "std_core_maybe.h"
#include "std_core_either.h"
#include "std_core_tuple.h"
#include "std_core_show.h"
#include "std_core_debug.h"
#include "std_core_delayed.h"
#include "std_core_console.h"
#include "std_core.h"
#include "std_os_env.h"

// type declarations

// type main/prime
struct kk_main__prime_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__prime;
struct kk_main__Hnd_prime {
  struct kk_main__prime_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause1 _fun_prime;
};
static inline kk_main__prime kk_main__base_Hnd_prime(struct kk_main__Hnd_prime* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__prime kk_main__new_Hnd_prime(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause1 _fun_prime, kk_context_t* _ctx) {
  struct kk_main__Hnd_prime* _con = kk_block_alloc_at_as(struct kk_main__Hnd_prime, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_fun_prime = _fun_prime;
  return kk_main__base_Hnd_prime(_con, _ctx);
}
static inline struct kk_main__Hnd_prime* kk_main__as_Hnd_prime(kk_main__prime x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_prime*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_prime(kk_main__prime x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__prime kk_main__prime_dup(kk_main__prime _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__prime_drop(kk_main__prime _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__prime_box(kk_main__prime _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__prime kk_main__prime_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:prime` type.

static inline kk_integer_t kk_main_prime_fs__cfc(kk_main__prime prime_0, kk_context_t* _ctx) { /* forall<e,a> (prime : prime<e,a>) -> int */ 
  {
    struct kk_main__Hnd_prime* _con_x138 = kk_main__as_Hnd_prime(prime_0, _ctx);
    kk_integer_t _x = _con_x138->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@fun-prime` constructor field of the `:prime` type.

static inline kk_std_core_hnd__clause1 kk_main_prime_fs__fun_prime(kk_main__prime prime_0, kk_context_t* _ctx) { /* forall<e,a> (prime : prime<e,a>) -> hnd/clause1<int,bool,prime,e,a> */ 
  {
    struct kk_main__Hnd_prime* _con_x139 = kk_main__as_Hnd_prime(prime_0, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x139->_fun_prime;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_main__tag_prime;

kk_box_t kk_main__handle_prime(kk_main__prime hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : prime<e,b>, ret : (res : a) -> e b, action : () -> <prime|e> a) -> e b */ 
 
// select `prime` operation out of effect `:prime`

static inline kk_std_core_hnd__clause1 kk_main__select_prime(kk_main__prime hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : prime<e,a>) -> hnd/clause1<int,bool,prime,e,a> */ 
  {
    struct kk_main__Hnd_prime* _con_x143 = kk_main__as_Hnd_prime(hnd, _ctx);
    kk_std_core_hnd__clause1 _fun_prime = _con_x143->_fun_prime;
    return kk_std_core_hnd__clause1_dup(_fun_prime, _ctx);
  }
}
 
// Call the `fun prime` operation of the effect `:prime`

static inline bool kk_main_prime(kk_integer_t e, kk_context_t* _ctx) { /* (e : int) -> prime bool */ 
  kk_std_core_hnd__ev ev_10033 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/prime>*/;
  kk_box_t _x_x144;
  {
    struct kk_std_core_hnd_Ev* _con_x145 = kk_std_core_hnd__as_Ev(ev_10033, _ctx);
    kk_box_t _box_x8 = _con_x145->hnd;
    int32_t m = _con_x145->marker;
    kk_main__prime h = kk_main__prime_unbox(_box_x8, KK_BORROWED, _ctx);
    kk_main__prime_dup(h, _ctx);
    {
      struct kk_main__Hnd_prime* _con_x146 = kk_main__as_Hnd_prime(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x146->_cfc;
      kk_std_core_hnd__clause1 _fun_prime = _con_x146->_fun_prime;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_fun_prime, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x12 = _fun_prime.clause;
        _x_x144 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x12, (_fun_unbox_x12, m, ev_10033, kk_integer_box(e, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  return kk_bool_unbox(_x_x144);
}

kk_integer_t kk_main__mlift_primes_10031(kk_integer_t a, kk_integer_t i, kk_integer_t n, bool _y_x10011, kk_context_t* _ctx); /* (a : int, i : int, n : int, bool) -> prime int */ 

kk_integer_t kk_main_primes(kk_integer_t i_0, kk_integer_t n_0, kk_integer_t a_0, kk_context_t* _ctx); /* (i : int, n : int, a : int) -> <div,prime> int */ 

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx); /* (n : int) -> div int */ 

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
