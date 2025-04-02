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
  kk_std_core_hnd__clause0 _ctl_get;
  kk_std_core_hnd__clause1 _ctl_set;
};
static inline kk_main__state kk_main__base_Hnd_state(struct kk_main__Hnd_state* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__state kk_main__new_Hnd_state(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause0 _ctl_get, kk_std_core_hnd__clause1 _ctl_set, kk_context_t* _ctx) {
  struct kk_main__Hnd_state* _con = kk_block_alloc_at_as(struct kk_main__Hnd_state, _at, 3 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_ctl_get = _ctl_get;
  _con->_ctl_set = _ctl_set;
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
    struct kk_main__Hnd_state* _con_x148 = kk_main__as_Hnd_state(state, _ctx);
    kk_integer_t _x = _con_x148->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-get` constructor field of the `:state` type.

static inline kk_std_core_hnd__clause0 kk_main_state_fs__ctl_get(kk_main__state state, kk_context_t* _ctx) { /* forall<e,a> (state : state<e,a>) -> hnd/clause0<int,state,e,a> */ 
  {
    struct kk_main__Hnd_state* _con_x149 = kk_main__as_Hnd_state(state, _ctx);
    kk_std_core_hnd__clause0 _x = _con_x149->_ctl_get;
    return kk_std_core_hnd__clause0_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-set` constructor field of the `:state` type.

static inline kk_std_core_hnd__clause1 kk_main_state_fs__ctl_set(kk_main__state state, kk_context_t* _ctx) { /* forall<e,a> (state : state<e,a>) -> hnd/clause1<int,(),state,e,a> */ 
  {
    struct kk_main__Hnd_state* _con_x150 = kk_main__as_Hnd_state(state, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x150->_ctl_set;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:yield` type.

static inline kk_integer_t kk_main_yield_fs__cfc(kk_main__yield yield_0, kk_context_t* _ctx) { /* forall<e,a> (yield : yield<e,a>) -> int */ 
  {
    struct kk_main__Hnd_yield* _con_x151 = kk_main__as_Hnd_yield(yield_0, _ctx);
    kk_integer_t _x = _con_x151->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-yield` constructor field of the `:yield` type.

static inline kk_std_core_hnd__clause1 kk_main_yield_fs__ctl_yield(kk_main__yield yield_0, kk_context_t* _ctx) { /* forall<e,a> (yield : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */ 
  {
    struct kk_main__Hnd_yield* _con_x152 = kk_main__as_Hnd_yield(yield_0, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x152->_ctl_yield;
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
    struct kk_main__Hnd_state* _con_x159 = kk_main__as_Hnd_state(hnd, _ctx);
    kk_std_core_hnd__clause0 _ctl_get = _con_x159->_ctl_get;
    return kk_std_core_hnd__clause0_dup(_ctl_get, _ctx);
  }
}
 
// select `set` operation out of effect `:state`

static inline kk_std_core_hnd__clause1 kk_main__select_set(kk_main__state hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : state<e,a>) -> hnd/clause1<int,(),state,e,a> */ 
  {
    struct kk_main__Hnd_state* _con_x160 = kk_main__as_Hnd_state(hnd, _ctx);
    kk_std_core_hnd__clause1 _ctl_set = _con_x160->_ctl_set;
    return kk_std_core_hnd__clause1_dup(_ctl_set, _ctx);
  }
}
 
// select `yield` operation out of effect `:yield`

static inline kk_std_core_hnd__clause1 kk_main__select_yield(kk_main__yield hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */ 
  {
    struct kk_main__Hnd_yield* _con_x161 = kk_main__as_Hnd_yield(hnd, _ctx);
    kk_std_core_hnd__clause1 _ctl_yield = _con_x161->_ctl_yield;
    return kk_std_core_hnd__clause1_dup(_ctl_yield, _ctx);
  }
}
 
// Call the `ctl get` operation of the effect `:state`


// lift anonymous function
struct kk_main_get_fun164__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x19;
};
extern kk_box_t kk_main_get_fun164(kk_function_t _fself, int32_t _b_x23, kk_std_core_hnd__ev _b_x24, kk_context_t* _ctx);
static inline kk_function_t kk_main_new_get_fun164(kk_function_t _fun_unbox_x19, kk_context_t* _ctx) {
  struct kk_main_get_fun164__t* _self = kk_function_alloc_as(struct kk_main_get_fun164__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_get_fun164, kk_context());
  _self->_fun_unbox_x19 = _fun_unbox_x19;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline kk_integer_t kk_main_get(kk_context_t* _ctx) { /* () -> state int */ 
  kk_std_core_hnd__ev ev_10047 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x162 = kk_std_core_hnd__as_Ev(ev_10047, _ctx);
    kk_box_t _box_x16 = _con_x162->hnd;
    int32_t m = _con_x162->marker;
    kk_main__state h = kk_main__state_unbox(_box_x16, KK_BORROWED, _ctx);
    kk_main__state_dup(h, _ctx);
    {
      struct kk_main__Hnd_state* _con_x163 = kk_main__as_Hnd_state(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x163->_cfc;
      kk_std_core_hnd__clause0 _ctl_get = _con_x163->_ctl_get;
      kk_std_core_hnd__clause1 _pat_1_0 = _con_x163->_ctl_set;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause1_drop(_pat_1_0, _ctx);
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_get, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x19 = _ctl_get.clause;
        kk_function_t _bv_x25 = (kk_main_new_get_fun164(_fun_unbox_x19, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x167 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x25, (_bv_x25, m, ev_10047, _ctx), _ctx); /*3004*/
        return kk_integer_unbox(_x_x167, _ctx);
      }
    }
  }
}
 
// Call the `ctl set` operation of the effect `:state`

static inline kk_unit_t kk_main_set(kk_integer_t i, kk_context_t* _ctx) { /* (i : int) -> state () */ 
  kk_std_core_hnd__ev ev_10049 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
  kk_box_t _x_x168;
  {
    struct kk_std_core_hnd_Ev* _con_x169 = kk_std_core_hnd__as_Ev(ev_10049, _ctx);
    kk_box_t _box_x33 = _con_x169->hnd;
    int32_t m = _con_x169->marker;
    kk_main__state h = kk_main__state_unbox(_box_x33, KK_BORROWED, _ctx);
    kk_main__state_dup(h, _ctx);
    {
      struct kk_main__Hnd_state* _con_x170 = kk_main__as_Hnd_state(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x170->_cfc;
      kk_std_core_hnd__clause0 _pat_1_0 = _con_x170->_ctl_get;
      kk_std_core_hnd__clause1 _ctl_set = _con_x170->_ctl_set;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause0_drop(_pat_1_0, _ctx);
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_set, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x37 = _ctl_set.clause;
        _x_x168 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x37, (_fun_unbox_x37, m, ev_10049, kk_integer_box(i, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x168); return kk_Unit;
}

kk_integer_t kk_main__mlift_countdown_10042(kk_unit_t wild__, kk_context_t* _ctx); /* (wild_ : ()) -> state int */ 

kk_integer_t kk_main__mlift_countdown_10043(kk_integer_t i, kk_context_t* _ctx); /* (i : int) -> state int */ 

kk_integer_t kk_main_countdown(kk_context_t* _ctx); /* () -> <div,state> int */ 

kk_box_t kk_main_shandler(kk_integer_t n, kk_function_t body, kk_context_t* _ctx); /* forall<a,e> (n : int, body : () -> <state|e> a) -> e a */ 

kk_box_t kk_main__mlift_pad_10044(kk_function_t body, kk_integer_t d, kk_ssize_t _y_x10030, kk_context_t* _ctx); /* forall<a,e> (body : () -> <div|e> a, d : int, hnd/ev-index) -> <state,div|e> a */ 

kk_box_t kk_main_pad(kk_integer_t d_0, kk_function_t body_0, kk_context_t* _ctx); /* forall<a,e> (d : int, body : () -> <div|e> a) -> <div|e> a */ 


// lift anonymous function
struct kk_main_run_fun208__t {
  struct kk_function_s _base;
  kk_integer_t d;
};
extern kk_box_t kk_main_run_fun208(kk_function_t _fself, kk_context_t* _ctx);
static inline kk_function_t kk_main_new_run_fun208(kk_integer_t d, kk_context_t* _ctx) {
  struct kk_main_run_fun208__t* _self = kk_function_alloc_as(struct kk_main_run_fun208__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun208, kk_context());
  _self->d = d;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun209__t {
  struct kk_function_s _base;
};
extern kk_integer_t kk_main_run_fun209(kk_function_t _fself, kk_context_t* _ctx);
static inline kk_function_t kk_main_new_run_fun209(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun209, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun210__t {
  struct kk_function_s _base;
  kk_function_t _b_x102_108;
};
extern kk_box_t kk_main_run_fun210(kk_function_t _fself, kk_context_t* _ctx);
static inline kk_function_t kk_main_new_run_fun210(kk_function_t _b_x102_108, kk_context_t* _ctx) {
  struct kk_main_run_fun210__t* _self = kk_function_alloc_as(struct kk_main_run_fun210__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun210, kk_context());
  _self->_b_x102_108 = _b_x102_108;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline kk_integer_t kk_main_run(kk_integer_t n, kk_integer_t d, kk_context_t* _ctx) { /* (n : int, d : int) -> div int */ 
  kk_box_t _x_x207 = kk_main_shandler(n, kk_main_new_run_fun208(d, _ctx), _ctx); /*774*/
  return kk_integer_unbox(_x_x207, _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 
 
// Call the `ctl yield` operation of the effect `:yield`

static inline kk_unit_t kk_main_yield(kk_integer_t i, kk_context_t* _ctx) { /* (i : int) -> yield () */ 
  kk_std_core_hnd__ev ev_10073 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/yield>*/;
  kk_box_t _x_x226;
  {
    struct kk_std_core_hnd_Ev* _con_x227 = kk_std_core_hnd__as_Ev(ev_10073, _ctx);
    kk_box_t _box_x122 = _con_x227->hnd;
    int32_t m = _con_x227->marker;
    kk_main__yield h = kk_main__yield_unbox(_box_x122, KK_BORROWED, _ctx);
    kk_main__yield_dup(h, _ctx);
    {
      struct kk_main__Hnd_yield* _con_x228 = kk_main__as_Hnd_yield(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x228->_cfc;
      kk_std_core_hnd__clause1 _ctl_yield = _con_x228->_ctl_yield;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_yield, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x126 = _ctl_yield.clause;
        _x_x226 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x126, (_fun_unbox_x126, m, ev_10073, kk_integer_box(i, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x226); return kk_Unit;
}

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
