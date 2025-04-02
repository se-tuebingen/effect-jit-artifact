#pragma once
#ifndef kk_test_bench_koka_counter_H
#define kk_test_bench_koka_counter_H
// Koka generated module: test/bench/koka/counter, koka version: 3.1.2, platform: 64-bit
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
#include "std_num_int32.h"

// type declarations

// type test/bench/koka/counter/st
struct kk_test_bench_koka_counter__st_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_test_bench_koka_counter__st;
struct kk_test_bench_koka_counter__Hnd_st {
  struct kk_test_bench_koka_counter__st_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause0 _fun_get;
  kk_std_core_hnd__clause1 _fun_set;
};
static inline kk_test_bench_koka_counter__st kk_test_bench_koka_counter__base_Hnd_st(struct kk_test_bench_koka_counter__Hnd_st* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_test_bench_koka_counter__st kk_test_bench_koka_counter__new_Hnd_st(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause0 _fun_get, kk_std_core_hnd__clause1 _fun_set, kk_context_t* _ctx) {
  struct kk_test_bench_koka_counter__Hnd_st* _con = kk_block_alloc_at_as(struct kk_test_bench_koka_counter__Hnd_st, _at, 3 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_fun_get = _fun_get;
  _con->_fun_set = _fun_set;
  return kk_test_bench_koka_counter__base_Hnd_st(_con, _ctx);
}
static inline struct kk_test_bench_koka_counter__Hnd_st* kk_test_bench_koka_counter__as_Hnd_st(kk_test_bench_koka_counter__st x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_test_bench_koka_counter__Hnd_st*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_test_bench_koka_counter__is_Hnd_st(kk_test_bench_koka_counter__st x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_test_bench_koka_counter__st kk_test_bench_koka_counter__st_dup(kk_test_bench_koka_counter__st _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_test_bench_koka_counter__st_drop(kk_test_bench_koka_counter__st _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_test_bench_koka_counter__st_box(kk_test_bench_koka_counter__st _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_test_bench_koka_counter__st kk_test_bench_koka_counter__st_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:st` type.

static inline kk_integer_t kk_test_bench_koka_counter_st_fs__cfc(kk_test_bench_koka_counter__st st, kk_context_t* _ctx) { /* forall<e,a> (st : st<e,a>) -> int */ 
  {
    struct kk_test_bench_koka_counter__Hnd_st* _con_x98 = kk_test_bench_koka_counter__as_Hnd_st(st, _ctx);
    kk_integer_t _x = _con_x98->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@fun-get` constructor field of the `:st` type.

static inline kk_std_core_hnd__clause0 kk_test_bench_koka_counter_st_fs__fun_get(kk_test_bench_koka_counter__st st, kk_context_t* _ctx) { /* forall<e,a> (st : st<e,a>) -> hnd/clause0<int32,st,e,a> */ 
  {
    struct kk_test_bench_koka_counter__Hnd_st* _con_x99 = kk_test_bench_koka_counter__as_Hnd_st(st, _ctx);
    kk_std_core_hnd__clause0 _x = _con_x99->_fun_get;
    return kk_std_core_hnd__clause0_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@fun-set` constructor field of the `:st` type.

static inline kk_std_core_hnd__clause1 kk_test_bench_koka_counter_st_fs__fun_set(kk_test_bench_koka_counter__st st, kk_context_t* _ctx) { /* forall<e,a> (st : st<e,a>) -> hnd/clause1<int32,(),st,e,a> */ 
  {
    struct kk_test_bench_koka_counter__Hnd_st* _con_x100 = kk_test_bench_koka_counter__as_Hnd_st(st, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x100->_fun_set;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_test_bench_koka_counter__tag_st;

kk_box_t kk_test_bench_koka_counter__handle_st(kk_test_bench_koka_counter__st hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : st<e,b>, ret : (res : a) -> e b, action : () -> <st|e> a) -> e b */ 
 
// select `get` operation out of effect `:st`

static inline kk_std_core_hnd__clause0 kk_test_bench_koka_counter__select_get(kk_test_bench_koka_counter__st hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : st<e,a>) -> hnd/clause0<int32,st,e,a> */ 
  {
    struct kk_test_bench_koka_counter__Hnd_st* _con_x104 = kk_test_bench_koka_counter__as_Hnd_st(hnd, _ctx);
    kk_std_core_hnd__clause0 _fun_get = _con_x104->_fun_get;
    return kk_std_core_hnd__clause0_dup(_fun_get, _ctx);
  }
}
 
// select `set` operation out of effect `:st`

static inline kk_std_core_hnd__clause1 kk_test_bench_koka_counter__select_set(kk_test_bench_koka_counter__st hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : st<e,a>) -> hnd/clause1<int32,(),st,e,a> */ 
  {
    struct kk_test_bench_koka_counter__Hnd_st* _con_x105 = kk_test_bench_koka_counter__as_Hnd_st(hnd, _ctx);
    kk_std_core_hnd__clause1 _fun_set = _con_x105->_fun_set;
    return kk_std_core_hnd__clause1_dup(_fun_set, _ctx);
  }
}
 
// Call the `fun get` operation of the effect `:st`


// lift anonymous function
struct kk_test_bench_koka_counter_get_fun108__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x11;
};
extern kk_box_t kk_test_bench_koka_counter_get_fun108(kk_function_t _fself, int32_t _b_x15, kk_std_core_hnd__ev _b_x16, kk_context_t* _ctx);
static inline kk_function_t kk_test_bench_koka_counter_new_get_fun108(kk_function_t _fun_unbox_x11, kk_context_t* _ctx) {
  struct kk_test_bench_koka_counter_get_fun108__t* _self = kk_function_alloc_as(struct kk_test_bench_koka_counter_get_fun108__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_test_bench_koka_counter_get_fun108, kk_context());
  _self->_fun_unbox_x11 = _fun_unbox_x11;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline int32_t kk_test_bench_koka_counter_get(kk_context_t* _ctx) { /* () -> st int32 */ 
  kk_std_core_hnd__ev ev_10015 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<test/bench/koka/counter/st>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x106 = kk_std_core_hnd__as_Ev(ev_10015, _ctx);
    kk_box_t _box_x8 = _con_x106->hnd;
    int32_t m = _con_x106->marker;
    kk_test_bench_koka_counter__st h = kk_test_bench_koka_counter__st_unbox(_box_x8, KK_BORROWED, _ctx);
    kk_test_bench_koka_counter__st_dup(h, _ctx);
    {
      struct kk_test_bench_koka_counter__Hnd_st* _con_x107 = kk_test_bench_koka_counter__as_Hnd_st(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x107->_cfc;
      kk_std_core_hnd__clause0 _fun_get = _con_x107->_fun_get;
      kk_std_core_hnd__clause1 _pat_1_0 = _con_x107->_fun_set;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause1_drop(_pat_1_0, _ctx);
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_fun_get, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x11 = _fun_get.clause;
        kk_function_t _bv_x17 = (kk_test_bench_koka_counter_new_get_fun108(_fun_unbox_x11, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x111 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x17, (_bv_x17, m, ev_10015, _ctx), _ctx); /*3004*/
        return kk_int32_unbox(_x_x111, KK_OWNED, _ctx);
      }
    }
  }
}
 
// Call the `fun set` operation of the effect `:st`

static inline kk_unit_t kk_test_bench_koka_counter_set(int32_t i, kk_context_t* _ctx) { /* (i : int32) -> st () */ 
  kk_std_core_hnd__ev ev_10017 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<test/bench/koka/counter/st>*/;
  kk_box_t _x_x112;
  {
    struct kk_std_core_hnd_Ev* _con_x113 = kk_std_core_hnd__as_Ev(ev_10017, _ctx);
    kk_box_t _box_x25 = _con_x113->hnd;
    int32_t m = _con_x113->marker;
    kk_test_bench_koka_counter__st h = kk_test_bench_koka_counter__st_unbox(_box_x25, KK_BORROWED, _ctx);
    kk_test_bench_koka_counter__st_dup(h, _ctx);
    {
      struct kk_test_bench_koka_counter__Hnd_st* _con_x114 = kk_test_bench_koka_counter__as_Hnd_st(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x114->_cfc;
      kk_std_core_hnd__clause0 _pat_1_0 = _con_x114->_fun_get;
      kk_std_core_hnd__clause1 _fun_set = _con_x114->_fun_set;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause0_drop(_pat_1_0, _ctx);
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_fun_set, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x29 = _fun_set.clause;
        _x_x112 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x29, (_fun_unbox_x29, m, ev_10017, kk_int32_box(i, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x112); return kk_Unit;
}

kk_integer_t kk_test_bench_koka_counter_counter(int32_t c, kk_context_t* _ctx); /* (c : int32) -> <div,st> int */ 

kk_box_t kk_test_bench_koka_counter_state(int32_t i, kk_function_t action, kk_context_t* _ctx); /* forall<a,e> (i : int32, action : () -> <st|e> a) -> e a */ 

kk_unit_t kk_test_bench_koka_counter_main(kk_context_t* _ctx); /* () -> <console/console,div> () */ 

void kk_test_bench_koka_counter__init(kk_context_t* _ctx);


void kk_test_bench_koka_counter__done(kk_context_t* _ctx);

#endif // header
