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

// type main/abort
struct kk_main__abort_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__abort;
struct kk_main__Hnd_abort {
  struct kk_main__abort_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause1 _ctl_done;
};
static inline kk_main__abort kk_main__base_Hnd_abort(struct kk_main__Hnd_abort* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__abort kk_main__new_Hnd_abort(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause1 _ctl_done, kk_context_t* _ctx) {
  struct kk_main__Hnd_abort* _con = kk_block_alloc_at_as(struct kk_main__Hnd_abort, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_ctl_done = _ctl_done;
  return kk_main__base_Hnd_abort(_con, _ctx);
}
static inline struct kk_main__Hnd_abort* kk_main__as_Hnd_abort(kk_main__abort x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_abort*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_abort(kk_main__abort x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__abort kk_main__abort_dup(kk_main__abort _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__abort_drop(kk_main__abort _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__abort_box(kk_main__abort _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__abort kk_main__abort_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:abort` type.

static inline kk_integer_t kk_main_abort_fs__cfc(kk_main__abort abort, kk_context_t* _ctx) { /* forall<e,a> (abort : abort<e,a>) -> int */ 
  {
    struct kk_main__Hnd_abort* _con_x125 = kk_main__as_Hnd_abort(abort, _ctx);
    kk_integer_t _x = _con_x125->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-done` constructor field of the `:abort` type.

static inline kk_std_core_hnd__clause1 kk_main_abort_fs__ctl_done(kk_main__abort abort, kk_context_t* _ctx) { /* forall<e,a,b> (abort : abort<e,a>) -> hnd/clause1<int,b,abort,e,a> */ 
  {
    struct kk_main__Hnd_abort* _con_x126 = kk_main__as_Hnd_abort(abort, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x126->_ctl_done;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_main__tag_abort;

kk_box_t kk_main__handle_abort(kk_main__abort hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : abort<e,b>, ret : (res : a) -> e b, action : () -> <abort|e> a) -> e b */ 
 
// select `done` operation out of effect `:abort`

static inline kk_std_core_hnd__clause1 kk_main__select_done(kk_main__abort hnd, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : abort<e,b>) -> hnd/clause1<int,a,abort,e,b> */ 
  {
    struct kk_main__Hnd_abort* _con_x130 = kk_main__as_Hnd_abort(hnd, _ctx);
    kk_std_core_hnd__clause1 _ctl_done = _con_x130->_ctl_done;
    return kk_std_core_hnd__clause1_dup(_ctl_done, _ctx);
  }
}
 
// Call the `ctl done` operation of the effect `:abort`

static inline kk_box_t kk_main_done(kk_integer_t i, kk_context_t* _ctx) { /* forall<a> (i : int) -> abort a */ 
  kk_std_core_hnd__ev ev_10034 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/abort>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x131 = kk_std_core_hnd__as_Ev(ev_10034, _ctx);
    kk_box_t _box_x8 = _con_x131->hnd;
    int32_t m = _con_x131->marker;
    kk_main__abort h = kk_main__abort_unbox(_box_x8, KK_BORROWED, _ctx);
    kk_main__abort_dup(h, _ctx);
    {
      struct kk_main__Hnd_abort* _con_x132 = kk_main__as_Hnd_abort(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x132->_cfc;
      kk_std_core_hnd__clause1 _ctl_done = _con_x132->_ctl_done;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_done, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x12 = _ctl_done.clause;
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x12, (_fun_unbox_x12, m, ev_10034, kk_integer_box(i, _ctx), _ctx), _ctx);
      }
    }
  }
}

kk_std_core_types__list kk_main__trmc_enumerate(kk_integer_t i, kk_std_core_types__cctx _acc, kk_context_t* _ctx); /* (i : int, ctx<list<int>>) -> div list<int> */ 

kk_std_core_types__list kk_main_enumerate(kk_integer_t i_0, kk_context_t* _ctx); /* (i : int) -> div list<int> */ 

kk_integer_t kk_main__mlift_product_10032(kk_integer_t y, kk_integer_t _y_x10026, kk_context_t* _ctx); /* (y : int, int) -> abort int */ 

kk_integer_t kk_main_product(kk_std_core_types__list xs, kk_context_t* _ctx); /* (xs : list<int>) -> abort int */ 

kk_integer_t kk_main_run_product(kk_std_core_types__list xs, kk_context_t* _ctx); /* (xs : list<int>) -> int */ 

kk_integer_t kk_main__lift_run_586(kk_std_core_types__list xs, kk_integer_t i, kk_integer_t a, kk_context_t* _ctx); /* (xs : list<int>, i : int, a : int) -> div int */ 

static inline kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  kk_std_core_types__list xs = kk_main_enumerate(kk_integer_from_small(1000), _ctx); /*list<int>*/;
  return kk_main__lift_run_586(xs, n, kk_integer_from_small(0), _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
