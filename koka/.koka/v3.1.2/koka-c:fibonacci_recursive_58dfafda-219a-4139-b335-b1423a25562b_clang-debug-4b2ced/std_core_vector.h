#pragma once
#ifndef kk_std_core_vector_H
#define kk_std_core_vector_H
// Koka generated module: std/core/vector, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_undiv.h"
#include "std_core_hnd.h"
#include "std_core_exn.h"
#include "std_core_int.h"
/*---------------------------------------------------------------------------
  Copyright 2020-2024, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

kk_datatype_t  kk_vector_to_list(kk_vector_t v, kk_datatype_t tail, kk_context_t* ctx);
kk_vector_t    kk_list_to_vector(kk_datatype_t xs, kk_context_t* ctx);

static inline kk_unit_t kk_vector_unsafe_assign( kk_vector_t v, kk_ssize_t i, kk_box_t x, kk_context_t* ctx  ) {
  kk_ssize_t len;
  kk_box_t* p = kk_vector_buf_borrow(v,&len,ctx);
  kk_assert(i < len);
  p[i] = x;
  kk_vector_drop(v,ctx); // TODO: use borrowing
  return kk_Unit;
}

static inline kk_box_t kk_vector_at_int_borrow( kk_vector_t v, kk_integer_t n, kk_context_t* ctx) {
  // TODO: check bounds
  kk_box_t b = kk_vector_at_borrow(v,kk_integer_clamp_ssize_t_borrow(n,ctx),ctx);
  return b;
}


// type declarations

// value declarations

kk_box_t kk_std_core_vector__index(kk_vector_t v, kk_integer_t index, kk_context_t* _ctx); /* forall<a> (v : vector<a>, index : int) -> exn a */ 

kk_std_core_types__maybe kk_std_core_vector_at(kk_vector_t v, kk_integer_t index, kk_context_t* _ctx); /* forall<a> (v : vector<a>, index : int) -> maybe<a> */ 

kk_ssize_t kk_std_core_vector_ssize__t_fs_incr(kk_ssize_t i, kk_context_t* _ctx); /* (i : ssize_t) -> ssize_t */ 
 
// Return the length of a vector.

static inline kk_integer_t kk_std_core_vector_length(kk_vector_t v, kk_context_t* _ctx) { /* forall<a> (v : vector<a>) -> int */ 
  kk_ssize_t _x_x50 = kk_vector_len_borrow(v,kk_context()); /*ssize_t*/
  return kk_integer_from_ssize_t(_x_x50,kk_context());
}

kk_std_core_types__list kk_std_core_vector_vlist(kk_vector_t v, kk_std_core_types__optional tail, kk_context_t* _ctx); /* forall<a> (v : vector<a>, tail : ? (list<a>)) -> list<a> */ 

kk_vector_t kk_std_core_vector_unvlist(kk_std_core_types__list xs, kk_context_t* _ctx); /* forall<a> (xs : list<a>) -> vector<a> */ 

kk_vector_t kk_std_core_vector_vector_alloc(kk_ssize_t n, kk_box_t init, kk_context_t* _ctx); /* forall<a,e> (n : ssize_t, init : a) -> e vector<a> */ 

kk_vector_t kk_std_core_vector_vector_alloc_total(kk_ssize_t n, kk_function_t f, kk_context_t* _ctx); /* forall<a> (n : ssize_t, f : (ssize_t) -> a) -> vector<a> */ 

kk_ssize_t kk_std_core_vector_ssize__t_fs_decr(kk_ssize_t i, kk_context_t* _ctx); /* (i : ssize_t) -> ssize_t */ 

bool kk_std_core_vector_ssize__t_fs_is_zero(kk_ssize_t i, kk_context_t* _ctx); /* (i : ssize_t) -> bool */ 

kk_std_core_types__maybe kk_std_core_vector__mlift_lift_for_whilez_868_10045(kk_function_t action, kk_ssize_t i, kk_ssize_t n, kk_std_core_types__maybe _y_x10023, kk_context_t* _ctx); /* forall<a,e> (action : (ssize_t) -> e maybe<a>, i : ssize_t, n : ssize_t, maybe<a>) -> e maybe<a> */ 

kk_std_core_types__maybe kk_std_core_vector__lift_for_whilez_868(kk_function_t action_0, kk_ssize_t n_0, kk_ssize_t i_0, kk_context_t* _ctx); /* forall<a,e> (action : (ssize_t) -> e maybe<a>, n : ssize_t, i : ssize_t) -> e maybe<a> */ 
 
// Executes `action` at most `n` times for each integer between `0`  upto `n`  (excluding `n` ).
// If `n <= 0`  the function returns without any call to `action` .
// If `action` returns `Just`, the iteration is stopped and the result returned

static inline kk_std_core_types__maybe kk_std_core_vector_for_whilez(kk_ssize_t n, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (n : ssize_t, action : (ssize_t) -> e maybe<a>) -> e maybe<a> */ 
  kk_ssize_t i = (KK_IZ(0)); /*ssize_t*/;
  return kk_std_core_vector__lift_for_whilez_868(action, n, i, _ctx);
}

kk_unit_t kk_std_core_vector__mlift_lift_forz_869_10046(kk_function_t action, kk_ssize_t i, kk_ssize_t n, kk_unit_t wild__, kk_context_t* _ctx); /* forall<e> (action : (ssize_t) -> e (), i : ssize_t, n : ssize_t, wild_ : ()) -> e () */ 

kk_unit_t kk_std_core_vector__lift_forz_869(kk_function_t action_0, kk_ssize_t n_0, kk_ssize_t i_0, kk_context_t* _ctx); /* forall<e> (action : (ssize_t) -> e (), n : ssize_t, i : ssize_t) -> e () */ 
 
// Executes `action` `n` times for each integer between [`0`,`n`)  (excluding `n` ).
// If `n <= 0`  the function returns without any call to `action` .

static inline kk_unit_t kk_std_core_vector_forz(kk_ssize_t n, kk_function_t action, kk_context_t* _ctx) { /* forall<e> (n : ssize_t, action : (ssize_t) -> e ()) -> e () */ 
  kk_ssize_t i = (KK_IZ(0)); /*ssize_t*/;
  kk_std_core_vector__lift_forz_869(action, n, i, _ctx); return kk_Unit;
}

kk_unit_t kk_std_core_vector_foreach_indexedz(kk_vector_t v, kk_function_t f, kk_context_t* _ctx); /* forall<a,e> (v : vector<a>, f : (ssize_t, a) -> e ()) -> e () */ 

kk_unit_t kk_std_core_vector_foreach(kk_vector_t v, kk_function_t f, kk_context_t* _ctx); /* forall<a,e> (v : vector<a>, f : (a) -> e ()) -> e () */ 

kk_unit_t kk_std_core_vector_foreach_indexed(kk_vector_t v, kk_function_t f, kk_context_t* _ctx); /* forall<a,e> (v : vector<a>, f : (int, a) -> e ()) -> e () */ 

kk_std_core_types__maybe kk_std_core_vector_foreach_while(kk_vector_t v, kk_function_t f, kk_context_t* _ctx); /* forall<a,b,e> (v : vector<a>, f : (a) -> e maybe<b>) -> e maybe<b> */ 
 
// Convert a vector to a list.

static inline kk_std_core_types__list kk_std_core_vector_list(kk_vector_t v, kk_context_t* _ctx) { /* forall<a> (v : vector<a>) -> list<a> */ 
  return kk_std_core_vector_vlist(v, kk_std_core_types__new_None(_ctx), _ctx);
}
 
// monadic lift

static inline kk_unit_t kk_std_core_vector__mlift_map_10047(kk_ssize_t i_0, kk_vector_t w, kk_box_t _y_x10040, kk_context_t* _ctx) { /* forall<a,e> (i@0 : ssize_t, w : vector<a>, a) -> e () */ 
  kk_vector_unsafe_assign(w,i_0,_y_x10040,kk_context()); return kk_Unit;
}
 
// monadic lift

static inline kk_vector_t kk_std_core_vector__mlift_map_10048(kk_vector_t w, kk_unit_t wild__, kk_context_t* _ctx) { /* forall<a,e> (w : vector<a>, wild_ : ()) -> e vector<a> */ 
  return w;
}

kk_vector_t kk_std_core_vector_map(kk_vector_t v, kk_function_t f, kk_context_t* _ctx); /* forall<a,b,e> (v : vector<a>, f : (a) -> e b) -> e vector<b> */ 
 
// Create a new vector of length `n`  with initial elements `default` .

static inline kk_vector_t kk_std_core_vector_vector(kk_integer_t n, kk_box_t kkloc_default, kk_context_t* _ctx) { /* forall<a> (n : int, default : a) -> vector<a> */ 
  kk_ssize_t _x_x77;
  kk_integer_t _x_x78 = kk_integer_dup(n, _ctx); /*int*/
  _x_x77 = kk_std_core_int_ssize__t(_x_x78, _ctx); /*ssize_t*/
  return kk_std_core_vector_vector_alloc(_x_x77, kkloc_default, _ctx);
}
 
// monadic lift

static inline kk_unit_t kk_std_core_vector__mlift_vector_init_10049(kk_ssize_t i_0, kk_vector_t v, kk_box_t _y_x10042, kk_context_t* _ctx) { /* forall<a,e> (i@0 : ssize_t, v : vector<a>, a) -> e () */ 
  kk_vector_unsafe_assign(v,i_0,_y_x10042,kk_context()); return kk_Unit;
}
 
// monadic lift

static inline kk_vector_t kk_std_core_vector__mlift_vector_init_10050(kk_vector_t v, kk_unit_t wild__, kk_context_t* _ctx) { /* forall<a,e> (v : vector<a>, wild_ : ()) -> e vector<a> */ 
  return v;
}

kk_vector_t kk_std_core_vector_vector_init(kk_integer_t n, kk_function_t f, kk_context_t* _ctx); /* forall<a,e> (n : int, f : (int) -> e a) -> e vector<a> */ 
 
// Create a new vector of length `n`  with initial elements given by _total_ function `f`.
// (can be more efficient than `vector-init`)


// lift anonymous function
struct kk_std_core_vector_vector_init_total_fun90__t {
  struct kk_function_s _base;
  kk_function_t f;
};
extern kk_box_t kk_std_core_vector_vector_init_total_fun90(kk_function_t _fself, kk_ssize_t i, kk_context_t* _ctx);
static inline kk_function_t kk_std_core_vector_new_vector_init_total_fun90(kk_function_t f, kk_context_t* _ctx) {
  struct kk_std_core_vector_vector_init_total_fun90__t* _self = kk_function_alloc_as(struct kk_std_core_vector_vector_init_total_fun90__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_vector_vector_init_total_fun90, kk_context());
  _self->f = f;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline kk_vector_t kk_std_core_vector_vector_init_total(kk_integer_t n, kk_function_t f, kk_context_t* _ctx) { /* forall<a,e> (n : int, f : (int) -> a) -> e vector<a> */ 
  kk_ssize_t _x_x88;
  kk_integer_t _x_x89 = kk_integer_dup(n, _ctx); /*int*/
  _x_x88 = kk_std_core_int_ssize__t(_x_x89, _ctx); /*ssize_t*/
  return kk_std_core_vector_vector_alloc_total(_x_x88, kk_std_core_vector_new_vector_init_total_fun90(f, _ctx), _ctx);
}
 
// Convert a list to a vector.

static inline kk_vector_t kk_std_core_vector_list_fs_vector(kk_std_core_types__list xs, kk_context_t* _ctx) { /* forall<a> (xs : list<a>) -> vector<a> */ 
  return kk_std_core_vector_unvlist(xs, _ctx);
}

void kk_std_core_vector__init(kk_context_t* _ctx);


void kk_std_core_vector__done(kk_context_t* _ctx);

#endif // header
