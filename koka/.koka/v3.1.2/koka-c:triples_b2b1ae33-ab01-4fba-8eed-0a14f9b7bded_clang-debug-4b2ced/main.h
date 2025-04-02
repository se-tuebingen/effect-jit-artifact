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

// type main/fail
struct kk_main__fail_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__fail;
struct kk_main__Hnd_fail {
  struct kk_main__fail_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause0 _ctl_fail;
};
static inline kk_main__fail kk_main__base_Hnd_fail(struct kk_main__Hnd_fail* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__fail kk_main__new_Hnd_fail(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause0 _ctl_fail, kk_context_t* _ctx) {
  struct kk_main__Hnd_fail* _con = kk_block_alloc_at_as(struct kk_main__Hnd_fail, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_ctl_fail = _ctl_fail;
  return kk_main__base_Hnd_fail(_con, _ctx);
}
static inline struct kk_main__Hnd_fail* kk_main__as_Hnd_fail(kk_main__fail x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_fail*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_fail(kk_main__fail x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__fail kk_main__fail_dup(kk_main__fail _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__fail_drop(kk_main__fail _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__fail_box(kk_main__fail _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__fail kk_main__fail_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// type main/flip
struct kk_main__flip_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__flip;
struct kk_main__Hnd_flip {
  struct kk_main__flip_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause0 _ctl_flip;
};
static inline kk_main__flip kk_main__base_Hnd_flip(struct kk_main__Hnd_flip* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__flip kk_main__new_Hnd_flip(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause0 _ctl_flip, kk_context_t* _ctx) {
  struct kk_main__Hnd_flip* _con = kk_block_alloc_at_as(struct kk_main__Hnd_flip, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_ctl_flip = _ctl_flip;
  return kk_main__base_Hnd_flip(_con, _ctx);
}
static inline struct kk_main__Hnd_flip* kk_main__as_Hnd_flip(kk_main__flip x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_flip*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_flip(kk_main__flip x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__flip kk_main__flip_dup(kk_main__flip _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__flip_drop(kk_main__flip _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__flip_box(kk_main__flip _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__flip kk_main__flip_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:fail` type.

static inline kk_integer_t kk_main_fail_fs__cfc(kk_main__fail fail_0, kk_context_t* _ctx) { /* forall<e,a> (fail : fail<e,a>) -> int */ 
  {
    struct kk_main__Hnd_fail* _con_x246 = kk_main__as_Hnd_fail(fail_0, _ctx);
    kk_integer_t _x = _con_x246->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-fail` constructor field of the `:fail` type.

static inline kk_std_core_hnd__clause0 kk_main_fail_fs__ctl_fail(kk_main__fail fail_0, kk_context_t* _ctx) { /* forall<e,a,b> (fail : fail<e,a>) -> hnd/clause0<b,fail,e,a> */ 
  {
    struct kk_main__Hnd_fail* _con_x247 = kk_main__as_Hnd_fail(fail_0, _ctx);
    kk_std_core_hnd__clause0 _x = _con_x247->_ctl_fail;
    return kk_std_core_hnd__clause0_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:flip` type.

static inline kk_integer_t kk_main_flip_fs__cfc(kk_main__flip flip_0, kk_context_t* _ctx) { /* forall<e,a> (flip : flip<e,a>) -> int */ 
  {
    struct kk_main__Hnd_flip* _con_x248 = kk_main__as_Hnd_flip(flip_0, _ctx);
    kk_integer_t _x = _con_x248->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-flip` constructor field of the `:flip` type.

static inline kk_std_core_hnd__clause0 kk_main_flip_fs__ctl_flip(kk_main__flip flip_0, kk_context_t* _ctx) { /* forall<e,a> (flip : flip<e,a>) -> hnd/clause0<bool,flip,e,a> */ 
  {
    struct kk_main__Hnd_flip* _con_x249 = kk_main__as_Hnd_flip(flip_0, _ctx);
    kk_std_core_hnd__clause0 _x = _con_x249->_ctl_flip;
    return kk_std_core_hnd__clause0_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_main__tag_fail;

kk_box_t kk_main__handle_fail(kk_main__fail hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : fail<e,b>, ret : (res : a) -> e b, action : () -> <fail|e> a) -> e b */ 

extern kk_std_core_hnd__htag kk_main__tag_flip;

kk_box_t kk_main__handle_flip(kk_main__flip hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : flip<e,b>, ret : (res : a) -> e b, action : () -> <flip|e> a) -> e b */ 
 
// select `fail` operation out of effect `:fail`

static inline kk_std_core_hnd__clause0 kk_main__select_fail(kk_main__fail hnd, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : fail<e,b>) -> hnd/clause0<a,fail,e,b> */ 
  {
    struct kk_main__Hnd_fail* _con_x256 = kk_main__as_Hnd_fail(hnd, _ctx);
    kk_std_core_hnd__clause0 _ctl_fail = _con_x256->_ctl_fail;
    return kk_std_core_hnd__clause0_dup(_ctl_fail, _ctx);
  }
}
 
// select `flip` operation out of effect `:flip`

static inline kk_std_core_hnd__clause0 kk_main__select_flip(kk_main__flip hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : flip<e,a>) -> hnd/clause0<bool,flip,e,a> */ 
  {
    struct kk_main__Hnd_flip* _con_x257 = kk_main__as_Hnd_flip(hnd, _ctx);
    kk_std_core_hnd__clause0 _ctl_flip = _con_x257->_ctl_flip;
    return kk_std_core_hnd__clause0_dup(_ctl_flip, _ctx);
  }
}

kk_integer_t kk_main_hash(kk_std_core_types__tuple3 _pat_x25__10, kk_context_t* _ctx); /* ((int, int, int)) -> int */ 
 
// Call the `ctl fail` operation of the effect `:fail`

static inline kk_box_t kk_main_fail(kk_context_t* _ctx) { /* forall<a> () -> fail a */ 
  kk_std_core_hnd__ev ev_10057 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/fail>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x259 = kk_std_core_hnd__as_Ev(ev_10057, _ctx);
    kk_box_t _box_x19 = _con_x259->hnd;
    int32_t m = _con_x259->marker;
    kk_main__fail h = kk_main__fail_unbox(_box_x19, KK_BORROWED, _ctx);
    kk_main__fail_dup(h, _ctx);
    {
      struct kk_main__Hnd_fail* _con_x260 = kk_main__as_Hnd_fail(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x260->_cfc;
      kk_std_core_hnd__clause0 _ctl_fail = _con_x260->_ctl_fail;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_fail, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t f = _ctl_fail.clause;
        kk_function_t _x_x261 = f; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _x_x261, (_x_x261, m, ev_10057, _ctx), _ctx);
      }
    }
  }
}
 
// Call the `ctl flip` operation of the effect `:flip`


// lift anonymous function
struct kk_main_flip_fun264__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x23;
};
extern kk_box_t kk_main_flip_fun264(kk_function_t _fself, int32_t _b_x27, kk_std_core_hnd__ev _b_x28, kk_context_t* _ctx);
static inline kk_function_t kk_main_new_flip_fun264(kk_function_t _fun_unbox_x23, kk_context_t* _ctx) {
  struct kk_main_flip_fun264__t* _self = kk_function_alloc_as(struct kk_main_flip_fun264__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_flip_fun264, kk_context());
  _self->_fun_unbox_x23 = _fun_unbox_x23;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline bool kk_main_flip(kk_context_t* _ctx) { /* () -> flip bool */ 
  kk_std_core_hnd__ev ev_10059 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/flip>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x262 = kk_std_core_hnd__as_Ev(ev_10059, _ctx);
    kk_box_t _box_x20 = _con_x262->hnd;
    int32_t m = _con_x262->marker;
    kk_main__flip h = kk_main__flip_unbox(_box_x20, KK_BORROWED, _ctx);
    kk_main__flip_dup(h, _ctx);
    {
      struct kk_main__Hnd_flip* _con_x263 = kk_main__as_Hnd_flip(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x263->_cfc;
      kk_std_core_hnd__clause0 _ctl_flip = _con_x263->_ctl_flip;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_flip, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x23 = _ctl_flip.clause;
        kk_function_t _bv_x29 = (kk_main_new_flip_fun264(_fun_unbox_x23, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x267 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x29, (_bv_x29, m, ev_10059, _ctx), _ctx); /*3004*/
        return kk_bool_unbox(_x_x267);
      }
    }
  }
}

kk_integer_t kk_main__mlift_choice_10050(kk_integer_t n, bool _y_x10023, kk_context_t* _ctx); /* (n : int, bool) -> <flip,fail,div> int */ 

kk_integer_t kk_main_choice(kk_integer_t n_0, kk_context_t* _ctx); /* (n : int) -> <div,fail,flip> int */ 

kk_std_core_types__tuple3 kk_main__mlift_triple_10051(kk_integer_t i, kk_integer_t j, kk_integer_t s, kk_integer_t k, kk_context_t* _ctx); /* (i : int, j : int, s : int, k : int) -> <div,fail,flip> (int, int, int) */ 

kk_std_core_types__tuple3 kk_main__mlift_triple_10052(kk_integer_t i, kk_integer_t s, kk_integer_t j, kk_context_t* _ctx); /* (i : int, s : int, j : int) -> <div,fail,flip> (int, int, int) */ 

kk_std_core_types__tuple3 kk_main__mlift_triple_10053(kk_integer_t s, kk_integer_t i, kk_context_t* _ctx); /* (s : int, i : int) -> <div,fail,flip> (int, int, int) */ 

kk_std_core_types__tuple3 kk_main_triple(kk_integer_t n, kk_integer_t s, kk_context_t* _ctx); /* (n : int, s : int) -> <div,fail,flip> (int, int, int) */ 

kk_integer_t kk_main__mlift_run_10054(kk_std_core_types__tuple3 _y_x10033, kk_context_t* _ctx); /* ((int, int, int)) -> <div,fail,flip> int */ 

kk_integer_t kk_main_run(kk_integer_t n, kk_integer_t s, kk_context_t* _ctx); /* (n : int, s : int) -> div int */ 

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
