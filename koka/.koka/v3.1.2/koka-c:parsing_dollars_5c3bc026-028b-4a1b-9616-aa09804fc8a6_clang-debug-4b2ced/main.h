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

// type main/emit
struct kk_main__emit_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__emit;
struct kk_main__Hnd_emit {
  struct kk_main__emit_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause1 _fun_emit;
};
static inline kk_main__emit kk_main__base_Hnd_emit(struct kk_main__Hnd_emit* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__emit kk_main__new_Hnd_emit(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause1 _fun_emit, kk_context_t* _ctx) {
  struct kk_main__Hnd_emit* _con = kk_block_alloc_at_as(struct kk_main__Hnd_emit, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_fun_emit = _fun_emit;
  return kk_main__base_Hnd_emit(_con, _ctx);
}
static inline struct kk_main__Hnd_emit* kk_main__as_Hnd_emit(kk_main__emit x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_emit*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_emit(kk_main__emit x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__emit kk_main__emit_dup(kk_main__emit _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__emit_drop(kk_main__emit _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__emit_box(kk_main__emit _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__emit kk_main__emit_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// type main/read
struct kk_main__read_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__read;
struct kk_main__Hnd_read {
  struct kk_main__read_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause0 _fun_read;
};
static inline kk_main__read kk_main__base_Hnd_read(struct kk_main__Hnd_read* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__read kk_main__new_Hnd_read(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause0 _fun_read, kk_context_t* _ctx) {
  struct kk_main__Hnd_read* _con = kk_block_alloc_at_as(struct kk_main__Hnd_read, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_fun_read = _fun_read;
  return kk_main__base_Hnd_read(_con, _ctx);
}
static inline struct kk_main__Hnd_read* kk_main__as_Hnd_read(kk_main__read x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_read*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_read(kk_main__read x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__read kk_main__read_dup(kk_main__read _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__read_drop(kk_main__read _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__read_box(kk_main__read _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__read kk_main__read_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// type main/stop
struct kk_main__stop_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__stop;
struct kk_main__Hnd_stop {
  struct kk_main__stop_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause0 _ctl_stop;
};
static inline kk_main__stop kk_main__base_Hnd_stop(struct kk_main__Hnd_stop* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__stop kk_main__new_Hnd_stop(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause0 _ctl_stop, kk_context_t* _ctx) {
  struct kk_main__Hnd_stop* _con = kk_block_alloc_at_as(struct kk_main__Hnd_stop, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_ctl_stop = _ctl_stop;
  return kk_main__base_Hnd_stop(_con, _ctx);
}
static inline struct kk_main__Hnd_stop* kk_main__as_Hnd_stop(kk_main__stop x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_stop*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_stop(kk_main__stop x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__stop kk_main__stop_dup(kk_main__stop _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__stop_drop(kk_main__stop _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__stop_box(kk_main__stop _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__stop kk_main__stop_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:emit` type.

static inline kk_integer_t kk_main_emit_fs__cfc(kk_main__emit emit_0, kk_context_t* _ctx) { /* forall<e,a> (emit : emit<e,a>) -> int */ 
  {
    struct kk_main__Hnd_emit* _con_x378 = kk_main__as_Hnd_emit(emit_0, _ctx);
    kk_integer_t _x = _con_x378->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@fun-emit` constructor field of the `:emit` type.

static inline kk_std_core_hnd__clause1 kk_main_emit_fs__fun_emit(kk_main__emit emit_0, kk_context_t* _ctx) { /* forall<e,a> (emit : emit<e,a>) -> hnd/clause1<int,(),emit,e,a> */ 
  {
    struct kk_main__Hnd_emit* _con_x379 = kk_main__as_Hnd_emit(emit_0, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x379->_fun_emit;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:read` type.

static inline kk_integer_t kk_main_read_fs__cfc(kk_main__read read_0, kk_context_t* _ctx) { /* forall<e,a> (read : read<e,a>) -> int */ 
  {
    struct kk_main__Hnd_read* _con_x380 = kk_main__as_Hnd_read(read_0, _ctx);
    kk_integer_t _x = _con_x380->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@fun-read` constructor field of the `:read` type.

static inline kk_std_core_hnd__clause0 kk_main_read_fs__fun_read(kk_main__read read_0, kk_context_t* _ctx) { /* forall<e,a> (read : read<e,a>) -> hnd/clause0<chr,read,e,a> */ 
  {
    struct kk_main__Hnd_read* _con_x381 = kk_main__as_Hnd_read(read_0, _ctx);
    kk_std_core_hnd__clause0 _x = _con_x381->_fun_read;
    return kk_std_core_hnd__clause0_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:stop` type.

static inline kk_integer_t kk_main_stop_fs__cfc(kk_main__stop stop_0, kk_context_t* _ctx) { /* forall<e,a> (stop : stop<e,a>) -> int */ 
  {
    struct kk_main__Hnd_stop* _con_x382 = kk_main__as_Hnd_stop(stop_0, _ctx);
    kk_integer_t _x = _con_x382->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-stop` constructor field of the `:stop` type.

static inline kk_std_core_hnd__clause0 kk_main_stop_fs__ctl_stop(kk_main__stop stop_0, kk_context_t* _ctx) { /* forall<e,a,b> (stop : stop<e,a>) -> hnd/clause0<b,stop,e,a> */ 
  {
    struct kk_main__Hnd_stop* _con_x383 = kk_main__as_Hnd_stop(stop_0, _ctx);
    kk_std_core_hnd__clause0 _x = _con_x383->_ctl_stop;
    return kk_std_core_hnd__clause0_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_main__tag_emit;

kk_box_t kk_main__handle_emit(kk_main__emit hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : emit<e,b>, ret : (res : a) -> e b, action : () -> <emit|e> a) -> e b */ 

extern kk_std_core_hnd__htag kk_main__tag_read;

kk_box_t kk_main__handle_read(kk_main__read hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : read<e,b>, ret : (res : a) -> e b, action : () -> <read|e> a) -> e b */ 

extern kk_std_core_hnd__htag kk_main__tag_stop;

kk_box_t kk_main__handle_stop(kk_main__stop hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : stop<e,b>, ret : (res : a) -> e b, action : () -> <stop|e> a) -> e b */ 
 
// select `emit` operation out of effect `:emit`

static inline kk_std_core_hnd__clause1 kk_main__select_emit(kk_main__emit hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : emit<e,a>) -> hnd/clause1<int,(),emit,e,a> */ 
  {
    struct kk_main__Hnd_emit* _con_x393 = kk_main__as_Hnd_emit(hnd, _ctx);
    kk_std_core_hnd__clause1 _fun_emit = _con_x393->_fun_emit;
    return kk_std_core_hnd__clause1_dup(_fun_emit, _ctx);
  }
}
 
// select `read` operation out of effect `:read`

static inline kk_std_core_hnd__clause0 kk_main__select_read(kk_main__read hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : read<e,a>) -> hnd/clause0<chr,read,e,a> */ 
  {
    struct kk_main__Hnd_read* _con_x394 = kk_main__as_Hnd_read(hnd, _ctx);
    kk_std_core_hnd__clause0 _fun_read = _con_x394->_fun_read;
    return kk_std_core_hnd__clause0_dup(_fun_read, _ctx);
  }
}
 
// select `stop` operation out of effect `:stop`

static inline kk_std_core_hnd__clause0 kk_main__select_stop(kk_main__stop hnd, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : stop<e,b>) -> hnd/clause0<a,stop,e,b> */ 
  {
    struct kk_main__Hnd_stop* _con_x395 = kk_main__as_Hnd_stop(hnd, _ctx);
    kk_std_core_hnd__clause0 _ctl_stop = _con_x395->_ctl_stop;
    return kk_std_core_hnd__clause0_dup(_ctl_stop, _ctx);
  }
}

static inline kk_integer_t kk_main_dollar(kk_context_t* _ctx) { /* () -> chr */ 
  return kk_integer_from_small(36);
}

static inline kk_integer_t kk_main_newline(kk_context_t* _ctx) { /* () -> chr */ 
  return kk_integer_from_small(10);
}

static inline bool kk_main_is_dollar(kk_integer_t c, kk_context_t* _ctx) { /* (c : chr) -> bool */ 
  bool _brw_x367 = kk_integer_eq_borrow(c,(kk_integer_from_small(36)),kk_context()); /*bool*/;
  kk_integer_drop(c, _ctx);
  return _brw_x367;
}

static inline bool kk_main_is_newline(kk_integer_t c, kk_context_t* _ctx) { /* (c : chr) -> bool */ 
  bool _brw_x366 = kk_integer_eq_borrow(c,(kk_integer_from_small(10)),kk_context()); /*bool*/;
  kk_integer_drop(c, _ctx);
  return _brw_x366;
}
 
// Call the `ctl stop` operation of the effect `:stop`

static inline kk_box_t kk_main_stop(kk_context_t* _ctx) { /* forall<a> () -> stop a */ 
  kk_std_core_hnd__ev ev_10087 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/stop>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x396 = kk_std_core_hnd__as_Ev(ev_10087, _ctx);
    kk_box_t _box_x24 = _con_x396->hnd;
    int32_t m = _con_x396->marker;
    kk_main__stop h = kk_main__stop_unbox(_box_x24, KK_BORROWED, _ctx);
    kk_main__stop_dup(h, _ctx);
    {
      struct kk_main__Hnd_stop* _con_x397 = kk_main__as_Hnd_stop(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x397->_cfc;
      kk_std_core_hnd__clause0 _ctl_stop = _con_x397->_ctl_stop;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_stop, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t f = _ctl_stop.clause;
        kk_function_t _x_x398 = f; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _x_x398, (_x_x398, m, ev_10087, _ctx), _ctx);
      }
    }
  }
}

kk_unit_t kk_main_catch(kk_function_t action, kk_context_t* _ctx); /* forall<e> (action : () -> <stop|e> ()) -> e () */ 
 
// Call the `fun emit` operation of the effect `:emit`

static inline kk_unit_t kk_main_emit(kk_integer_t e, kk_context_t* _ctx) { /* (e : int) -> emit () */ 
  kk_std_core_hnd__ev ev_10090 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/emit>*/;
  kk_box_t _x_x417;
  {
    struct kk_std_core_hnd_Ev* _con_x418 = kk_std_core_hnd__as_Ev(ev_10090, _ctx);
    kk_box_t _box_x50 = _con_x418->hnd;
    int32_t m = _con_x418->marker;
    kk_main__emit h = kk_main__emit_unbox(_box_x50, KK_BORROWED, _ctx);
    kk_main__emit_dup(h, _ctx);
    {
      struct kk_main__Hnd_emit* _con_x419 = kk_main__as_Hnd_emit(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x419->_cfc;
      kk_std_core_hnd__clause1 _fun_emit = _con_x419->_fun_emit;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_fun_emit, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x54 = _fun_emit.clause;
        _x_x417 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x54, (_fun_unbox_x54, m, ev_10090, kk_integer_box(e, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x417); return kk_Unit;
}
 
// Call the `fun read` operation of the effect `:read`


// lift anonymous function
struct kk_main_read_fun422__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x61;
};
extern kk_box_t kk_main_read_fun422(kk_function_t _fself, int32_t _b_x65, kk_std_core_hnd__ev _b_x66, kk_context_t* _ctx);
static inline kk_function_t kk_main_new_read_fun422(kk_function_t _fun_unbox_x61, kk_context_t* _ctx) {
  struct kk_main_read_fun422__t* _self = kk_function_alloc_as(struct kk_main_read_fun422__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_read_fun422, kk_context());
  _self->_fun_unbox_x61 = _fun_unbox_x61;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline kk_integer_t kk_main_read(kk_context_t* _ctx) { /* () -> read chr */ 
  kk_std_core_hnd__ev ev_10093 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/read>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x420 = kk_std_core_hnd__as_Ev(ev_10093, _ctx);
    kk_box_t _box_x58 = _con_x420->hnd;
    int32_t m = _con_x420->marker;
    kk_main__read h = kk_main__read_unbox(_box_x58, KK_BORROWED, _ctx);
    kk_main__read_dup(h, _ctx);
    {
      struct kk_main__Hnd_read* _con_x421 = kk_main__as_Hnd_read(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x421->_cfc;
      kk_std_core_hnd__clause0 _fun_read = _con_x421->_fun_read;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_fun_read, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x61 = _fun_read.clause;
        kk_function_t _bv_x67 = (kk_main_new_read_fun422(_fun_unbox_x61, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x425 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x67, (_bv_x67, m, ev_10093, _ctx), _ctx); /*3004*/
        return kk_integer_unbox(_x_x425, _ctx);
      }
    }
  }
}
 
// monadic lift

static inline kk_integer_t kk_main__mlift_feed_10072(kk_unit_t wild___0, kk_context_t* _ctx) { /* forall<h,e> (wild_@0 : ()) -> <local<h>,stop|e> int */ 
  return kk_integer_from_small(10);
}

kk_integer_t kk_main__mlift_feed_10073(kk_ref_t j, kk_integer_t _y_x10023, kk_context_t* _ctx); /* forall<h,e> (j : local-var<h,int>, int) -> <local<h>,stop|e> chr */ 

kk_integer_t kk_main__mlift_feed_10074(kk_ref_t i, kk_ref_t j, kk_unit_t wild__, kk_context_t* _ctx); /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, wild_ : ()) -> <local<h>,stop|e> chr */ 

kk_integer_t kk_main__mlift_feed_10075(kk_ref_t i, kk_ref_t j, kk_integer_t _y_x10021, kk_context_t* _ctx); /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, int) -> <local<h>,stop|e> chr */ 
 
// monadic lift

static inline kk_integer_t kk_main__mlift_feed_10076(kk_unit_t wild___1, kk_context_t* _ctx) { /* forall<h,e> (wild_@1 : ()) -> <local<h>,stop|e> int */ 
  return kk_integer_from_small(36);
}

kk_integer_t kk_main__mlift_feed_10077(kk_ref_t j, kk_integer_t _y_x10025, kk_context_t* _ctx); /* forall<h,e> (j : local-var<h,int>, int) -> <local<h>,stop|e> chr */ 

kk_integer_t kk_main__mlift_feed_10078(kk_ref_t i, kk_ref_t j, kk_integer_t _y_x10020, kk_context_t* _ctx); /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, int) -> <local<h>,stop|e> chr */ 

kk_integer_t kk_main__mlift_feed_10079(kk_ref_t i, kk_ref_t j, kk_integer_t n, kk_integer_t _y_x10017, kk_context_t* _ctx); /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, n : int, int) -> <local<h>,stop|e> chr */ 

kk_unit_t kk_main_feed(kk_integer_t n, kk_function_t action, kk_context_t* _ctx); /* forall<e> (n : int, action : () -> <read,stop|e> ()) -> <stop|e> () */ 

kk_box_t kk_main__mlift_parse_10080(kk_unit_t wild__, kk_context_t* _ctx); /* forall<a> (wild_ : ()) -> <emit,stop,read,div> a */ 

kk_box_t kk_main__mlift_parse_10081(kk_integer_t a, kk_integer_t c, kk_context_t* _ctx); /* forall<a> (a : int, c : chr) -> <read,emit,stop,div> a */ 

kk_box_t kk_main_parse(kk_integer_t a_0, kk_context_t* _ctx); /* forall<a> (a : int) -> <div,emit,read,stop> a */ 
 
// monadic lift

static inline kk_unit_t kk_main__mlift_sum_10082(kk_integer_t e, kk_ref_t s, kk_integer_t _y_x10044, kk_context_t* _ctx) { /* forall<h,e> (e : int, s : local-var<h,int>, int) -> <local<h>|e> () */ 
  kk_integer_t _b_x240_242 = kk_integer_add(_y_x10044,e,kk_context()); /*int*/;
  kk_unit_t _brw_x342 = kk_Unit;
  kk_ref_set_borrow(s,(kk_integer_box(_b_x240_242, _ctx)),kk_context());
  kk_ref_drop(s, _ctx);
  _brw_x342; return kk_Unit;
}
 
// monadic lift

static inline kk_integer_t kk_main__mlift_sum_10083(kk_ref_t s, kk_unit_t wild__, kk_context_t* _ctx) { /* forall<h,e> (s : local-var<h,int>, wild_ : ()) -> <local<h>,emit|e> int */ 
  kk_box_t _x_x509 = kk_ref_get(s,kk_context()); /*3502*/
  return kk_integer_unbox(_x_x509, _ctx);
}

kk_integer_t kk_main_sum(kk_function_t action, kk_context_t* _ctx); /* forall<e> (action : () -> <emit|e> ()) -> e int */ 

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx); /* (n : int) -> div int */ 

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
