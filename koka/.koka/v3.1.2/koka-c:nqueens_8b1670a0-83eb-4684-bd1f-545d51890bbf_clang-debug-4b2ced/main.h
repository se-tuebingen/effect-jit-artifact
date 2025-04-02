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

// type main/search
struct kk_main__search_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__search;
struct kk_main__Hnd_search {
  struct kk_main__search_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause0 _ctl_fail;
  kk_std_core_hnd__clause1 _ctl_pick;
};
static inline kk_main__search kk_main__base_Hnd_search(struct kk_main__Hnd_search* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__search kk_main__new_Hnd_search(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause0 _ctl_fail, kk_std_core_hnd__clause1 _ctl_pick, kk_context_t* _ctx) {
  struct kk_main__Hnd_search* _con = kk_block_alloc_at_as(struct kk_main__Hnd_search, _at, 3 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_ctl_fail = _ctl_fail;
  _con->_ctl_pick = _ctl_pick;
  return kk_main__base_Hnd_search(_con, _ctx);
}
static inline struct kk_main__Hnd_search* kk_main__as_Hnd_search(kk_main__search x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_search*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_search(kk_main__search x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__search kk_main__search_dup(kk_main__search _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__search_drop(kk_main__search _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__search_box(kk_main__search _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__search kk_main__search_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:search` type.

static inline kk_integer_t kk_main_search_fs__cfc(kk_main__search search, kk_context_t* _ctx) { /* forall<e,a> (search : search<e,a>) -> int */ 
  {
    struct kk_main__Hnd_search* _con_x238 = kk_main__as_Hnd_search(search, _ctx);
    kk_integer_t _x = _con_x238->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-fail` constructor field of the `:search` type.

static inline kk_std_core_hnd__clause0 kk_main_search_fs__ctl_fail(kk_main__search search, kk_context_t* _ctx) { /* forall<e,a,b> (search : search<e,a>) -> hnd/clause0<b,search,e,a> */ 
  {
    struct kk_main__Hnd_search* _con_x239 = kk_main__as_Hnd_search(search, _ctx);
    kk_std_core_hnd__clause0 _x = _con_x239->_ctl_fail;
    return kk_std_core_hnd__clause0_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-pick` constructor field of the `:search` type.

static inline kk_std_core_hnd__clause1 kk_main_search_fs__ctl_pick(kk_main__search search, kk_context_t* _ctx) { /* forall<e,a> (search : search<e,a>) -> hnd/clause1<int,int,search,e,a> */ 
  {
    struct kk_main__Hnd_search* _con_x240 = kk_main__as_Hnd_search(search, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x240->_ctl_pick;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_main__tag_search;

kk_box_t kk_main__handle_search(kk_main__search hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : search<e,b>, ret : (res : a) -> e b, action : () -> <search|e> a) -> e b */ 
 
// select `fail` operation out of effect `:search`

static inline kk_std_core_hnd__clause0 kk_main__select_fail(kk_main__search hnd, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : search<e,b>) -> hnd/clause0<a,search,e,b> */ 
  {
    struct kk_main__Hnd_search* _con_x244 = kk_main__as_Hnd_search(hnd, _ctx);
    kk_std_core_hnd__clause0 _ctl_fail = _con_x244->_ctl_fail;
    return kk_std_core_hnd__clause0_dup(_ctl_fail, _ctx);
  }
}
 
// select `pick` operation out of effect `:search`

static inline kk_std_core_hnd__clause1 kk_main__select_pick(kk_main__search hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : search<e,a>) -> hnd/clause1<int,int,search,e,a> */ 
  {
    struct kk_main__Hnd_search* _con_x245 = kk_main__as_Hnd_search(hnd, _ctx);
    kk_std_core_hnd__clause1 _ctl_pick = _con_x245->_ctl_pick;
    return kk_std_core_hnd__clause1_dup(_ctl_pick, _ctx);
  }
}
 
// Call the `ctl fail` operation of the effect `:search`

static inline kk_box_t kk_main_fail(kk_context_t* _ctx) { /* forall<a> () -> search a */ 
  kk_std_core_hnd__ev ev_10041 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/search>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x246 = kk_std_core_hnd__as_Ev(ev_10041, _ctx);
    kk_box_t _box_x8 = _con_x246->hnd;
    int32_t m = _con_x246->marker;
    kk_main__search h = kk_main__search_unbox(_box_x8, KK_BORROWED, _ctx);
    kk_main__search_dup(h, _ctx);
    {
      struct kk_main__Hnd_search* _con_x247 = kk_main__as_Hnd_search(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x247->_cfc;
      kk_std_core_hnd__clause0 _ctl_fail = _con_x247->_ctl_fail;
      kk_std_core_hnd__clause1 _pat_1_0 = _con_x247->_ctl_pick;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause1_drop(_pat_1_0, _ctx);
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_fail, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t f = _ctl_fail.clause;
        kk_function_t _x_x248 = f; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _x_x248, (_x_x248, m, ev_10041, _ctx), _ctx);
      }
    }
  }
}
 
// Call the `ctl pick` operation of the effect `:search`

static inline kk_integer_t kk_main_pick(kk_integer_t size, kk_context_t* _ctx) { /* (size : int) -> search int */ 
  kk_std_core_hnd__ev ev_10043 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/search>*/;
  kk_box_t _x_x249;
  {
    struct kk_std_core_hnd_Ev* _con_x250 = kk_std_core_hnd__as_Ev(ev_10043, _ctx);
    kk_box_t _box_x9 = _con_x250->hnd;
    int32_t m = _con_x250->marker;
    kk_main__search h = kk_main__search_unbox(_box_x9, KK_BORROWED, _ctx);
    kk_main__search_dup(h, _ctx);
    {
      struct kk_main__Hnd_search* _con_x251 = kk_main__as_Hnd_search(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x251->_cfc;
      kk_std_core_hnd__clause0 _pat_1_0 = _con_x251->_ctl_fail;
      kk_std_core_hnd__clause1 _ctl_pick = _con_x251->_ctl_pick;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause0_drop(_pat_1_0, _ctx);
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_pick, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x13 = _ctl_pick.clause;
        _x_x249 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x13, (_fun_unbox_x13, m, ev_10043, kk_integer_box(size, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  return kk_integer_unbox(_x_x249, _ctx);
}

bool kk_main_safe(kk_integer_t queen, kk_integer_t diag, kk_std_core_types__list xs, kk_context_t* _ctx); /* (queen : int, diag : int, xs : solution) -> bool */ 

kk_std_core_types__list kk_main__mlift_place_10038(kk_std_core_types__list rest, kk_integer_t next, kk_context_t* _ctx); /* (rest : solution, next : int) -> search list<int> */ 

kk_std_core_types__list kk_main__mlift_place_10039(kk_integer_t size, kk_std_core_types__list rest_0, kk_context_t* _ctx); /* (size : int, rest : solution) -> <div,search> list<int> */ 

kk_std_core_types__list kk_main_place(kk_integer_t size_0, kk_integer_t column, kk_context_t* _ctx); /* (size : int, column : int) -> <div,search> solution */ 

kk_integer_t kk_main__lift_run_828(kk_function_t resume_0, kk_integer_t size, kk_integer_t i, kk_integer_t a, kk_context_t* _ctx); /* (resume@0 : (int) -> div int, size : int, i : int, a : int) -> div int */ 

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx); /* (n : int) -> div int */ 

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
