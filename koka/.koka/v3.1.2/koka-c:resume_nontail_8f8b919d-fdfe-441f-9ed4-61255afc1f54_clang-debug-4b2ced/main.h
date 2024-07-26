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

// type main/operator
struct kk_main__operator_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__operator;
struct kk_main__Hnd_operator {
  struct kk_main__operator_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause1 _ctl_operator;
};
static inline kk_main__operator kk_main__base_Hnd_operator(struct kk_main__Hnd_operator* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__operator kk_main__new_Hnd_operator(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause1 _ctl_operator, kk_context_t* _ctx) {
  struct kk_main__Hnd_operator* _con = kk_block_alloc_at_as(struct kk_main__Hnd_operator, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_ctl_operator = _ctl_operator;
  return kk_main__base_Hnd_operator(_con, _ctx);
}
static inline struct kk_main__Hnd_operator* kk_main__as_Hnd_operator(kk_main__operator x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_operator*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_operator(kk_main__operator x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__operator kk_main__operator_dup(kk_main__operator _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__operator_drop(kk_main__operator _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__operator_box(kk_main__operator _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__operator kk_main__operator_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:operator` type.

static inline kk_integer_t kk_main_operator_fs__cfc(kk_main__operator operator_0, kk_context_t* _ctx) { /* forall<e,a> (operator : operator<e,a>) -> int */ 
  {
    struct kk_main__Hnd_operator* _con_x66 = kk_main__as_Hnd_operator(operator_0, _ctx);
    kk_integer_t _x = _con_x66->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-operator` constructor field of the `:operator` type.

static inline kk_std_core_hnd__clause1 kk_main_operator_fs__ctl_operator(kk_main__operator operator_0, kk_context_t* _ctx) { /* forall<e,a> (operator : operator<e,a>) -> hnd/clause1<int,(),operator,e,a> */ 
  {
    struct kk_main__Hnd_operator* _con_x67 = kk_main__as_Hnd_operator(operator_0, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x67->_ctl_operator;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_main__tag_operator;

kk_box_t kk_main__handle_operator(kk_main__operator hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : operator<e,b>, ret : (res : a) -> e b, action : () -> <operator|e> a) -> e b */ 
 
// select `operator` operation out of effect `:operator`

static inline kk_std_core_hnd__clause1 kk_main__select_operator(kk_main__operator hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : operator<e,a>) -> hnd/clause1<int,(),operator,e,a> */ 
  {
    struct kk_main__Hnd_operator* _con_x71 = kk_main__as_Hnd_operator(hnd, _ctx);
    kk_std_core_hnd__clause1 _ctl_operator = _con_x71->_ctl_operator;
    return kk_std_core_hnd__clause1_dup(_ctl_operator, _ctx);
  }
}
 
// Call the `ctl operator` operation of the effect `:operator`

static inline kk_unit_t kk_main_operator(kk_integer_t x, kk_context_t* _ctx) { /* (x : int) -> operator () */ 
  kk_std_core_hnd__ev ev_10028 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/operator>*/;
  kk_box_t _x_x72;
  {
    struct kk_std_core_hnd_Ev* _con_x73 = kk_std_core_hnd__as_Ev(ev_10028, _ctx);
    kk_box_t _box_x8 = _con_x73->hnd;
    int32_t m = _con_x73->marker;
    kk_main__operator h = kk_main__operator_unbox(_box_x8, KK_BORROWED, _ctx);
    kk_main__operator_dup(h, _ctx);
    {
      struct kk_main__Hnd_operator* _con_x74 = kk_main__as_Hnd_operator(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x74->_cfc;
      kk_std_core_hnd__clause1 _ctl_operator = _con_x74->_ctl_operator;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_operator, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x12 = _ctl_operator.clause;
        _x_x72 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x12, (_fun_unbox_x12, m, ev_10028, kk_integer_box(x, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x72); return kk_Unit;
}

kk_integer_t kk_main__mlift_loop_10026(kk_integer_t i, kk_integer_t s, kk_unit_t wild__, kk_context_t* _ctx); /* (i : int, s : int, wild_ : ()) -> operator int */ 

kk_integer_t kk_main_loop(kk_integer_t i_0, kk_integer_t s_0, kk_context_t* _ctx); /* (i : int, s : int) -> <div,operator> int */ 

kk_integer_t kk_main_run(kk_integer_t n, kk_integer_t s, kk_context_t* _ctx); /* (n : int, s : int) -> div int */ 

kk_integer_t kk_main__lift_repeat_514(kk_integer_t n, kk_integer_t l, kk_integer_t s, kk_context_t* _ctx); /* (n : int, l : int, s : int) -> div int */ 

static inline kk_integer_t kk_main_repeat(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  return kk_main__lift_repeat_514(n, kk_integer_from_small(1000), kk_integer_from_small(0), _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
