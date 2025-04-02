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

// type main/state
struct kk_main__state_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__state;
struct kk_main__Hnd_state {
  struct kk_main__state_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause0 _fun_get;
  kk_std_core_hnd__clause1 _fun_set;
};
static inline kk_main__state kk_main__base_Hnd_state(struct kk_main__Hnd_state* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__state kk_main__new_Hnd_state(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause0 _fun_get, kk_std_core_hnd__clause1 _fun_set, kk_context_t* _ctx) {
  struct kk_main__Hnd_state* _con = kk_block_alloc_at_as(struct kk_main__Hnd_state, _at, 3 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_fun_get = _fun_get;
  _con->_fun_set = _fun_set;
  return kk_main__base_Hnd_state(_con, _ctx);
}
static inline struct kk_main__Hnd_state* kk_main__as_Hnd_state(kk_main__state x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_state*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_state(kk_main__state x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__state kk_main__state_dup(kk_main__state _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__state_drop(kk_main__state _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__state_box(kk_main__state _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__state kk_main__state_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// type main/yield
struct kk_main__yield_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__yield;
struct kk_main__Hnd_yield {
  struct kk_main__yield_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause1 _ctl_yield;
};
static inline kk_main__yield kk_main__base_Hnd_yield(struct kk_main__Hnd_yield* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__yield kk_main__new_Hnd_yield(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause1 _ctl_yield, kk_context_t* _ctx) {
  struct kk_main__Hnd_yield* _con = kk_block_alloc_at_as(struct kk_main__Hnd_yield, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_ctl_yield = _ctl_yield;
  return kk_main__base_Hnd_yield(_con, _ctx);
}
static inline struct kk_main__Hnd_yield* kk_main__as_Hnd_yield(kk_main__yield x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_yield*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_yield(kk_main__yield x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__yield kk_main__yield_dup(kk_main__yield _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__yield_drop(kk_main__yield _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__yield_box(kk_main__yield _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__yield kk_main__yield_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:state` type.

static inline kk_integer_t kk_main_state_fs__cfc(kk_main__state state, kk_context_t* _ctx) { /* forall<e,a> (state : state<e,a>) -> int */ 
  {
    struct kk_main__Hnd_state* _con_x207 = kk_main__as_Hnd_state(state, _ctx);
    kk_integer_t _x = _con_x207->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@fun-get` constructor field of the `:state` type.

static inline kk_std_core_hnd__clause0 kk_main_state_fs__fun_get(kk_main__state state, kk_context_t* _ctx) { /* forall<e,a> (state : state<e,a>) -> hnd/clause0<int,state,e,a> */ 
  {
    struct kk_main__Hnd_state* _con_x208 = kk_main__as_Hnd_state(state, _ctx);
    kk_std_core_hnd__clause0 _x = _con_x208->_fun_get;
    return kk_std_core_hnd__clause0_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@fun-set` constructor field of the `:state` type.

static inline kk_std_core_hnd__clause1 kk_main_state_fs__fun_set(kk_main__state state, kk_context_t* _ctx) { /* forall<e,a> (state : state<e,a>) -> hnd/clause1<int,(),state,e,a> */ 
  {
    struct kk_main__Hnd_state* _con_x209 = kk_main__as_Hnd_state(state, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x209->_fun_set;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:yield` type.

static inline kk_integer_t kk_main_yield_fs__cfc(kk_main__yield yield_0, kk_context_t* _ctx) { /* forall<e,a> (yield : yield<e,a>) -> int */ 
  {
    struct kk_main__Hnd_yield* _con_x210 = kk_main__as_Hnd_yield(yield_0, _ctx);
    kk_integer_t _x = _con_x210->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-yield` constructor field of the `:yield` type.

static inline kk_std_core_hnd__clause1 kk_main_yield_fs__ctl_yield(kk_main__yield yield_0, kk_context_t* _ctx) { /* forall<e,a> (yield : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */ 
  {
    struct kk_main__Hnd_yield* _con_x211 = kk_main__as_Hnd_yield(yield_0, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x211->_ctl_yield;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_main__tag_state;

kk_box_t kk_main__handle_state(kk_main__state hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : state<e,b>, ret : (res : a) -> e b, action : () -> <state|e> a) -> e b */ 

extern kk_std_core_hnd__htag kk_main__tag_yield;

kk_box_t kk_main__handle_yield(kk_main__yield hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : yield<e,b>, ret : (res : a) -> e b, action : () -> <yield|e> a) -> e b */ 
 
// select `get` operation out of effect `:state`

static inline kk_std_core_hnd__clause0 kk_main__select_get(kk_main__state hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : state<e,a>) -> hnd/clause0<int,state,e,a> */ 
  {
    struct kk_main__Hnd_state* _con_x218 = kk_main__as_Hnd_state(hnd, _ctx);
    kk_std_core_hnd__clause0 _fun_get = _con_x218->_fun_get;
    return kk_std_core_hnd__clause0_dup(_fun_get, _ctx);
  }
}
 
// select `set` operation out of effect `:state`

static inline kk_std_core_hnd__clause1 kk_main__select_set(kk_main__state hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : state<e,a>) -> hnd/clause1<int,(),state,e,a> */ 
  {
    struct kk_main__Hnd_state* _con_x219 = kk_main__as_Hnd_state(hnd, _ctx);
    kk_std_core_hnd__clause1 _fun_set = _con_x219->_fun_set;
    return kk_std_core_hnd__clause1_dup(_fun_set, _ctx);
  }
}
 
// select `yield` operation out of effect `:yield`

static inline kk_std_core_hnd__clause1 kk_main__select_yield(kk_main__yield hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */ 
  {
    struct kk_main__Hnd_yield* _con_x220 = kk_main__as_Hnd_yield(hnd, _ctx);
    kk_std_core_hnd__clause1 _ctl_yield = _con_x220->_ctl_yield;
    return kk_std_core_hnd__clause1_dup(_ctl_yield, _ctx);
  }
}
 
// Call the `fun get` operation of the effect `:state`


// lift anonymous function
struct kk_main_get_fun223__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x19;
};
extern kk_box_t kk_main_get_fun223(kk_function_t _fself, int32_t _b_x23, kk_std_core_hnd__ev _b_x24, kk_context_t* _ctx);
static inline kk_function_t kk_main_new_get_fun223(kk_function_t _fun_unbox_x19, kk_context_t* _ctx) {
  struct kk_main_get_fun223__t* _self = kk_function_alloc_as(struct kk_main_get_fun223__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_get_fun223, kk_context());
  _self->_fun_unbox_x19 = _fun_unbox_x19;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline kk_integer_t kk_main_get(kk_context_t* _ctx) { /* () -> state int */ 
  kk_std_core_hnd__ev ev_10043 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x221 = kk_std_core_hnd__as_Ev(ev_10043, _ctx);
    kk_box_t _box_x16 = _con_x221->hnd;
    int32_t m = _con_x221->marker;
    kk_main__state h = kk_main__state_unbox(_box_x16, KK_BORROWED, _ctx);
    kk_main__state_dup(h, _ctx);
    {
      struct kk_main__Hnd_state* _con_x222 = kk_main__as_Hnd_state(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x222->_cfc;
      kk_std_core_hnd__clause0 _fun_get = _con_x222->_fun_get;
      kk_std_core_hnd__clause1 _pat_1_0 = _con_x222->_fun_set;
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
        kk_function_t _fun_unbox_x19 = _fun_get.clause;
        kk_function_t _bv_x25 = (kk_main_new_get_fun223(_fun_unbox_x19, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x226 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x25, (_bv_x25, m, ev_10043, _ctx), _ctx); /*3004*/
        return kk_integer_unbox(_x_x226, _ctx);
      }
    }
  }
}
 
// Call the `fun set` operation of the effect `:state`

static inline kk_unit_t kk_main_set(kk_integer_t i, kk_context_t* _ctx) { /* (i : int) -> state () */ 
  kk_std_core_hnd__ev ev_10045 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
  kk_box_t _x_x227;
  {
    struct kk_std_core_hnd_Ev* _con_x228 = kk_std_core_hnd__as_Ev(ev_10045, _ctx);
    kk_box_t _box_x33 = _con_x228->hnd;
    int32_t m = _con_x228->marker;
    kk_main__state h = kk_main__state_unbox(_box_x33, KK_BORROWED, _ctx);
    kk_main__state_dup(h, _ctx);
    {
      struct kk_main__Hnd_state* _con_x229 = kk_main__as_Hnd_state(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x229->_cfc;
      kk_std_core_hnd__clause0 _pat_1_0 = _con_x229->_fun_get;
      kk_std_core_hnd__clause1 _fun_set = _con_x229->_fun_set;
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
        kk_function_t _fun_unbox_x37 = _fun_set.clause;
        _x_x227 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x37, (_fun_unbox_x37, m, ev_10045, kk_integer_box(i, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x227); return kk_Unit;
}

kk_integer_t kk_main__mlift_countdown_10039(kk_unit_t wild__, kk_context_t* _ctx); /* (wild_ : ()) -> state int */ 

kk_integer_t kk_main__mlift_countdown_10040(kk_integer_t i, kk_context_t* _ctx); /* (i : int) -> state int */ 

kk_integer_t kk_main_countdown(kk_context_t* _ctx); /* () -> <div,state> int */ 
 
// Call the `ctl yield` operation of the effect `:yield`

static inline kk_unit_t kk_main_yield(kk_integer_t i, kk_context_t* _ctx) { /* (i : int) -> yield () */ 
  kk_std_core_hnd__ev ev_10064 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/yield>*/;
  kk_box_t _x_x251;
  {
    struct kk_std_core_hnd_Ev* _con_x252 = kk_std_core_hnd__as_Ev(ev_10064, _ctx);
    kk_box_t _box_x83 = _con_x252->hnd;
    int32_t m = _con_x252->marker;
    kk_main__yield h = kk_main__yield_unbox(_box_x83, KK_BORROWED, _ctx);
    kk_main__yield_dup(h, _ctx);
    {
      struct kk_main__Hnd_yield* _con_x253 = kk_main__as_Hnd_yield(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x253->_cfc;
      kk_std_core_hnd__clause1 _ctl_yield = _con_x253->_ctl_yield;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_yield, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x87 = _ctl_yield.clause;
        _x_x251 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x87, (_fun_unbox_x87, m, ev_10064, kk_integer_box(i, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x251); return kk_Unit;
}

kk_box_t kk_main_ignoreyield(kk_function_t body, kk_context_t* _ctx); /* forall<a,e> (body : () -> <yield|e> a) -> e a */ 

kk_integer_t kk_main_handled(kk_integer_t n, kk_integer_t d, kk_context_t* _ctx); /* (n : int, d : int) -> <div,state> int */ 

kk_integer_t kk_main_run(kk_integer_t n, kk_integer_t d, kk_context_t* _ctx); /* (n : int, d : int) -> div int */ 

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
