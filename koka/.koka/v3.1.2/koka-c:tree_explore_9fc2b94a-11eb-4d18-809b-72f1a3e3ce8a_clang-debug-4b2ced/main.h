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
#include "std_text_parse.h"

// type declarations

// type main/choose
struct kk_main__choose_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_main__choose;
struct kk_main__Hnd_choose {
  struct kk_main__choose_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause0 _ctl_choose;
};
static inline kk_main__choose kk_main__base_Hnd_choose(struct kk_main__Hnd_choose* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__choose kk_main__new_Hnd_choose(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause0 _ctl_choose, kk_context_t* _ctx) {
  struct kk_main__Hnd_choose* _con = kk_block_alloc_at_as(struct kk_main__Hnd_choose, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_ctl_choose = _ctl_choose;
  return kk_main__base_Hnd_choose(_con, _ctx);
}
static inline struct kk_main__Hnd_choose* kk_main__as_Hnd_choose(kk_main__choose x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main__Hnd_choose*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_main__is_Hnd_choose(kk_main__choose x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_main__choose kk_main__choose_dup(kk_main__choose _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_main__choose_drop(kk_main__choose _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_main__choose_box(kk_main__choose _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_main__choose kk_main__choose_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// type main/tree
struct kk_main__tree_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_main__tree;
struct kk_main_Node {
  struct kk_main__tree_s _base;
  kk_main__tree left;
  kk_integer_t value;
  kk_main__tree right;
};
static inline kk_main__tree kk_main__new_Leaf(kk_context_t* _ctx) {
  return kk_datatype_from_tag((kk_tag_t)(1));
}
static inline kk_main__tree kk_main__base_Node(struct kk_main_Node* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__tree kk_main__new_Node(kk_reuse_t _at, int32_t _cpath, kk_main__tree left, kk_integer_t value, kk_main__tree right, kk_context_t* _ctx) {
  struct kk_main_Node* _con = kk_block_alloc_at_as(struct kk_main_Node, _at, 3 /* scan count */, _cpath, (kk_tag_t)(2), _ctx);
  _con->left = left;
  _con->value = value;
  _con->right = right;
  return kk_main__base_Node(_con, _ctx);
}
static inline struct kk_main_Node* kk_main__as_Node(kk_main__tree x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main_Node*, x, (kk_tag_t)(2), _ctx);
}
static inline bool kk_main__is_Leaf(kk_main__tree x, kk_context_t* _ctx) {
  return (kk_datatype_has_singleton_tag(x, (kk_tag_t)(1)));
}
static inline bool kk_main__is_Node(kk_main__tree x, kk_context_t* _ctx) {
  return (!kk_main__is_Leaf(x, _ctx));
}
static inline kk_main__tree kk_main__tree_dup(kk_main__tree _x, kk_context_t* _ctx) {
  return kk_datatype_dup(_x, _ctx);
}
static inline void kk_main__tree_drop(kk_main__tree _x, kk_context_t* _ctx) {
  kk_datatype_drop(_x, _ctx);
}
static inline kk_box_t kk_main__tree_box(kk_main__tree _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_main__tree kk_main__tree_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:choose` type.

static inline kk_integer_t kk_main_choose_fs__cfc(kk_main__choose choose_0, kk_context_t* _ctx) { /* forall<e,a> (choose : choose<e,a>) -> int */ 
  {
    struct kk_main__Hnd_choose* _con_x207 = kk_main__as_Hnd_choose(choose_0, _ctx);
    kk_integer_t _x = _con_x207->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-choose` constructor field of the `:choose` type.

static inline kk_std_core_hnd__clause0 kk_main_choose_fs__ctl_choose(kk_main__choose choose_0, kk_context_t* _ctx) { /* forall<e,a> (choose : choose<e,a>) -> hnd/clause0<bool,choose,e,a> */ 
  {
    struct kk_main__Hnd_choose* _con_x208 = kk_main__as_Hnd_choose(choose_0, _ctx);
    kk_std_core_hnd__clause0 _x = _con_x208->_ctl_choose;
    return kk_std_core_hnd__clause0_dup(_x, _ctx);
  }
}
 
// Automatically generated. Tests for the `Leaf` constructor of the `:tree` type.

static inline bool kk_main_is_leaf(kk_main__tree tree, kk_context_t* _ctx) { /* (tree : tree) -> bool */ 
  if (kk_main__is_Leaf(tree, _ctx)) {
    return true;
  }
  {
    struct kk_main_Node* _con_x209 = kk_main__as_Node(tree, _ctx);
    return false;
  }
}
 
// Automatically generated. Tests for the `Node` constructor of the `:tree` type.

static inline bool kk_main_is_node(kk_main__tree tree, kk_context_t* _ctx) { /* (tree : tree) -> bool */ 
  if (kk_main__is_Node(tree, _ctx)) {
    struct kk_main_Node* _con_x210 = kk_main__as_Node(tree, _ctx);
    return true;
  }
  {
    return false;
  }
}

extern kk_std_core_hnd__htag kk_main__tag_choose;

kk_box_t kk_main__handle_choose(kk_main__choose hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : choose<e,b>, ret : (res : a) -> e b, action : () -> <choose|e> a) -> e b */ 
 
// select `choose` operation out of effect `:choose`

static inline kk_std_core_hnd__clause0 kk_main__select_choose(kk_main__choose hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : choose<e,a>) -> hnd/clause0<bool,choose,e,a> */ 
  {
    struct kk_main__Hnd_choose* _con_x214 = kk_main__as_Hnd_choose(hnd, _ctx);
    kk_std_core_hnd__clause0 _ctl_choose = _con_x214->_ctl_choose;
    return kk_std_core_hnd__clause0_dup(_ctl_choose, _ctx);
  }
}

static inline kk_integer_t kk_main_operator(kk_integer_t x, kk_integer_t y, kk_context_t* _ctx) { /* (x : int, y : int) -> int */ 
  kk_integer_t y_1_10003 = kk_integer_mul((kk_integer_from_small(503)),y,kk_context()); /*int*/;
  kk_integer_t x_0_10000 = kk_integer_sub(x,y_1_10003,kk_context()); /*int*/;
  kk_integer_t _x_x215;
  kk_integer_t _x_x216 = kk_integer_add_small_const(x_0_10000, 37, _ctx); /*int*/
  _x_x215 = kk_integer_abs(_x_x216,kk_context()); /*int*/
  return kk_integer_mod(_x_x215,(kk_integer_from_small(1009)),kk_context());
}
 
// Call the `ctl choose` operation of the effect `:choose`


// lift anonymous function
struct kk_main_choose_fun219__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x11;
};
extern kk_box_t kk_main_choose_fun219(kk_function_t _fself, int32_t _b_x15, kk_std_core_hnd__ev _b_x16, kk_context_t* _ctx);
static inline kk_function_t kk_main_new_choose_fun219(kk_function_t _fun_unbox_x11, kk_context_t* _ctx) {
  struct kk_main_choose_fun219__t* _self = kk_function_alloc_as(struct kk_main_choose_fun219__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_choose_fun219, kk_context());
  _self->_fun_unbox_x11 = _fun_unbox_x11;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline bool kk_main_choose(kk_context_t* _ctx) { /* () -> choose bool */ 
  kk_std_core_hnd__ev ev_10053 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/choose>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x217 = kk_std_core_hnd__as_Ev(ev_10053, _ctx);
    kk_box_t _box_x8 = _con_x217->hnd;
    int32_t m = _con_x217->marker;
    kk_main__choose h = kk_main__choose_unbox(_box_x8, KK_BORROWED, _ctx);
    kk_main__choose_dup(h, _ctx);
    {
      struct kk_main__Hnd_choose* _con_x218 = kk_main__as_Hnd_choose(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x218->_cfc;
      kk_std_core_hnd__clause0 _ctl_choose = _con_x218->_ctl_choose;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_choose, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x11 = _ctl_choose.clause;
        kk_function_t _bv_x17 = (kk_main_new_choose_fun219(_fun_unbox_x11, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x222 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x17, (_bv_x17, m, ev_10053, _ctx), _ctx); /*3004*/
        return kk_bool_unbox(_x_x222);
      }
    }
  }
}

kk_main__tree kk_main_make(kk_integer_t n, kk_context_t* _ctx); /* (n : int) -> div tree */ 

kk_integer_t kk_main__mlift_lift_run_707_10048(kk_integer_t v, kk_integer_t _y_x10036, kk_context_t* _ctx); /* forall<h> (v : int, int) -> <local<h>,choose,div> int */ 

kk_integer_t kk_main__mlift_lift_run_707_10049(bool _y_x10033, kk_main__tree l, kk_main__tree r, kk_ref_t state, kk_integer_t v_0, kk_unit_t wild__, kk_context_t* _ctx); /* forall<h> (bool, l : tree, r : tree, state : local-var<h,int>, v : int, wild_ : ()) -> <local<h>,choose,div> int */ 

kk_integer_t kk_main__mlift_lift_run_707_10050(bool _y_x10033_0, kk_main__tree l_0, kk_main__tree r_0, kk_ref_t state_0, kk_integer_t v_1, kk_integer_t _y_x10034, kk_context_t* _ctx); /* forall<h> (bool, l : tree, r : tree, state : local-var<h,int>, v : int, int) -> <local<h>,choose,div> int */ 

kk_integer_t kk_main__mlift_lift_run_707_10051(kk_main__tree l_1, kk_main__tree r_1, kk_ref_t state_1, kk_integer_t v_2, bool _y_x10033_1, kk_context_t* _ctx); /* forall<h> (l : tree, r : tree, state : local-var<h,int>, v : int, bool) -> choose int */ 

kk_integer_t kk_main__lift_run_707(kk_ref_t state_2, kk_main__tree t, kk_context_t* _ctx); /* forall<h> (state : local-var<h,int>, t : tree) -> <local<h>,choose,div> int */ 

kk_integer_t kk_main__lift_run_708(kk_function_t explore, kk_ref_t state, kk_main__tree tree, kk_integer_t i, kk_context_t* _ctx); /* forall<h> (explore : (t : tree) -> <choose,div,local<h>> int, state : local-var<h,int>, tree : tree, i : int) -> <div,local<h>> int */ 

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx); /* (n : int) -> div int */ 

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
