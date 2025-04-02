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

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:emit` type.

static inline kk_integer_t kk_main_emit_fs__cfc(kk_main__emit emit_0, kk_context_t* _ctx) { /* forall<e,a> (emit : emit<e,a>) -> int */ 
  {
    struct kk_main__Hnd_emit* _con_x149 = kk_main__as_Hnd_emit(emit_0, _ctx);
    kk_integer_t _x = _con_x149->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@fun-emit` constructor field of the `:emit` type.

static inline kk_std_core_hnd__clause1 kk_main_emit_fs__fun_emit(kk_main__emit emit_0, kk_context_t* _ctx) { /* forall<e,a> (emit : emit<e,a>) -> hnd/clause1<int,(),emit,e,a> */ 
  {
    struct kk_main__Hnd_emit* _con_x150 = kk_main__as_Hnd_emit(emit_0, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x150->_fun_emit;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_main__tag_emit;

kk_box_t kk_main__handle_emit(kk_main__emit hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : emit<e,b>, ret : (res : a) -> e b, action : () -> <emit|e> a) -> e b */ 
 
// select `emit` operation out of effect `:emit`

static inline kk_std_core_hnd__clause1 kk_main__select_emit(kk_main__emit hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : emit<e,a>) -> hnd/clause1<int,(),emit,e,a> */ 
  {
    struct kk_main__Hnd_emit* _con_x154 = kk_main__as_Hnd_emit(hnd, _ctx);
    kk_std_core_hnd__clause1 _fun_emit = _con_x154->_fun_emit;
    return kk_std_core_hnd__clause1_dup(_fun_emit, _ctx);
  }
}
 
// Call the `fun emit` operation of the effect `:emit`

static inline kk_unit_t kk_main_emit(kk_integer_t e, kk_context_t* _ctx) { /* (e : int) -> emit () */ 
  kk_std_core_hnd__ev ev_10061 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/emit>*/;
  kk_box_t _x_x155;
  {
    struct kk_std_core_hnd_Ev* _con_x156 = kk_std_core_hnd__as_Ev(ev_10061, _ctx);
    kk_box_t _box_x8 = _con_x156->hnd;
    int32_t m = _con_x156->marker;
    kk_main__emit h = kk_main__emit_unbox(_box_x8, KK_BORROWED, _ctx);
    kk_main__emit_dup(h, _ctx);
    {
      struct kk_main__Hnd_emit* _con_x157 = kk_main__as_Hnd_emit(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x157->_cfc;
      kk_std_core_hnd__clause1 _fun_emit = _con_x157->_fun_emit;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_fun_emit, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x12 = _fun_emit.clause;
        _x_x155 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x12, (_fun_unbox_x12, m, ev_10061, kk_integer_box(e, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x155); return kk_Unit;
}
 
// monadic lift

static inline kk_unit_t kk_main__mlift_counting_10056(kk_ref_t res, kk_integer_t _y_x10020, kk_context_t* _ctx) { /* forall<e,h> (res : local-var<h,int>, int) -> <local<h>|e> () */ 
  kk_integer_t _b_x17_19;
  kk_integer_t _x_x158 = kk_integer_add_small_const(_y_x10020, 1, _ctx); /*int*/
  _b_x17_19 = kk_integer_mod(_x_x158,(kk_integer_from_small(1009)),kk_context()); /*int*/
  kk_unit_t _brw_x145 = kk_Unit;
  kk_ref_set_borrow(res,(kk_integer_box(_b_x17_19, _ctx)),kk_context());
  kk_ref_drop(res, _ctx);
  _brw_x145; return kk_Unit;
}

kk_integer_t kk_main_counting(kk_function_t action, kk_context_t* _ctx); /* forall<a,e> (action : () -> <emit|e> a) -> e int */ 

kk_unit_t kk_main__mlift_lift_generator_1196_10057(kk_integer_t i, kk_integer_t n, kk_unit_t wild__, kk_context_t* _ctx); /* (i : int, n : int, wild_ : ()) -> emit () */ 

kk_unit_t kk_main__lift_generator_1196(kk_integer_t n_0, kk_integer_t i_0, kk_context_t* _ctx); /* (n : int, i : int) -> <emit,div> () */ 

static inline kk_unit_t kk_main_generator(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> <div,emit> () */ 
  kk_main__lift_generator_1196(n, kk_integer_from_small(0), _ctx); return kk_Unit;
}

kk_unit_t kk_main__mlift_sq__summing_10058(kk_integer_t i, kk_ref_t res, kk_integer_t _y_x10031, kk_context_t* _ctx); /* forall<e,h> (i : int, res : local-var<h,int>, int) -> <local<h>|e> () */ 

kk_integer_t kk_main_sq__summing(kk_function_t action, kk_context_t* _ctx); /* forall<a,e> (action : () -> <emit|e> a) -> e int */ 
 
// monadic lift

static inline kk_unit_t kk_main__mlift_summing_10059(kk_integer_t i, kk_ref_t res, kk_integer_t _y_x10038, kk_context_t* _ctx) { /* forall<e,h> (i : int, res : local-var<h,int>, int) -> <local<h>|e> () */ 
  kk_integer_t _b_x95_97;
  kk_integer_t _x_x204 = kk_integer_add(_y_x10038,i,kk_context()); /*int*/
  _b_x95_97 = kk_integer_mod(_x_x204,(kk_integer_from_small(1009)),kk_context()); /*int*/
  kk_unit_t _brw_x137 = kk_Unit;
  kk_ref_set_borrow(res,(kk_integer_box(_b_x95_97, _ctx)),kk_context());
  kk_ref_drop(res, _ctx);
  _brw_x137; return kk_Unit;
}

kk_integer_t kk_main_summing(kk_function_t action, kk_context_t* _ctx); /* forall<a,e> (action : () -> <emit|e> a) -> e int */ 

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx); /* (n : int) -> div int */ 

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
