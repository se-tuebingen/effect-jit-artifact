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

// type main/generator
struct kk_main__generator_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_main__generator;
struct kk_main_Thunk {
  struct kk_main__generator_s _base;
  kk_integer_t value;
  kk_function_t next;
};
static inline kk_main__generator kk_main__new_Empty(kk_context_t* _ctx) {
  return kk_datatype_from_tag((kk_tag_t)(1));
}
static inline kk_main__generator kk_main__base_Thunk(struct kk_main_Thunk* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_main__generator kk_main__new_Thunk(kk_reuse_t _at, int32_t _cpath, kk_integer_t value, kk_function_t next, kk_context_t* _ctx) {
  struct kk_main_Thunk* _con = kk_block_alloc_at_as(struct kk_main_Thunk, _at, 2 /* scan count */, _cpath, (kk_tag_t)(2), _ctx);
  _con->value = value;
  _con->next = next;
  return kk_main__base_Thunk(_con, _ctx);
}
static inline struct kk_main_Thunk* kk_main__as_Thunk(kk_main__generator x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_main_Thunk*, x, (kk_tag_t)(2), _ctx);
}
static inline bool kk_main__is_Empty(kk_main__generator x, kk_context_t* _ctx) {
  return (kk_datatype_has_singleton_tag(x, (kk_tag_t)(1)));
}
static inline bool kk_main__is_Thunk(kk_main__generator x, kk_context_t* _ctx) {
  return (!kk_main__is_Empty(x, _ctx));
}
static inline kk_main__generator kk_main__generator_dup(kk_main__generator _x, kk_context_t* _ctx) {
  return kk_datatype_dup(_x, _ctx);
}
static inline void kk_main__generator_drop(kk_main__generator _x, kk_context_t* _ctx) {
  kk_datatype_drop(_x, _ctx);
}
static inline kk_box_t kk_main__generator_box(kk_main__generator _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_main__generator kk_main__generator_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
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
 
// Automatically generated. Tests for the `Empty` constructor of the `:generator` type.

static inline bool kk_main_is_empty(kk_main__generator generator, kk_context_t* _ctx) { /* (generator : generator) -> bool */ 
  if (kk_main__is_Empty(generator, _ctx)) {
    return true;
  }
  {
    struct kk_main_Thunk* _con_x124 = kk_main__as_Thunk(generator, _ctx);
    return false;
  }
}
 
// Automatically generated. Tests for the `Thunk` constructor of the `:generator` type.

static inline bool kk_main_is_thunk(kk_main__generator generator, kk_context_t* _ctx) { /* (generator : generator) -> bool */ 
  if (kk_main__is_Thunk(generator, _ctx)) {
    struct kk_main_Thunk* _con_x125 = kk_main__as_Thunk(generator, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Leaf` constructor of the `:tree` type.

static inline bool kk_main_is_leaf(kk_main__tree tree, kk_context_t* _ctx) { /* (tree : tree) -> bool */ 
  if (kk_main__is_Leaf(tree, _ctx)) {
    return true;
  }
  {
    struct kk_main_Node* _con_x126 = kk_main__as_Node(tree, _ctx);
    return false;
  }
}
 
// Automatically generated. Tests for the `Node` constructor of the `:tree` type.

static inline bool kk_main_is_node(kk_main__tree tree, kk_context_t* _ctx) { /* (tree : tree) -> bool */ 
  if (kk_main__is_Node(tree, _ctx)) {
    struct kk_main_Node* _con_x127 = kk_main__as_Node(tree, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:yield` type.

static inline kk_integer_t kk_main_yield_fs__cfc(kk_main__yield yield_0, kk_context_t* _ctx) { /* forall<e,a> (yield : yield<e,a>) -> int */ 
  {
    struct kk_main__Hnd_yield* _con_x128 = kk_main__as_Hnd_yield(yield_0, _ctx);
    kk_integer_t _x = _con_x128->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@ctl-yield` constructor field of the `:yield` type.

static inline kk_std_core_hnd__clause1 kk_main_yield_fs__ctl_yield(kk_main__yield yield_0, kk_context_t* _ctx) { /* forall<e,a> (yield : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */ 
  {
    struct kk_main__Hnd_yield* _con_x129 = kk_main__as_Hnd_yield(yield_0, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x129->_ctl_yield;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_main__tag_yield;

kk_box_t kk_main__handle_yield(kk_main__yield hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : yield<e,b>, ret : (res : a) -> e b, action : () -> <yield|e> a) -> e b */ 
 
// select `yield` operation out of effect `:yield`

static inline kk_std_core_hnd__clause1 kk_main__select_yield(kk_main__yield hnd, kk_context_t* _ctx) { /* forall<e,a> (hnd : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */ 
  {
    struct kk_main__Hnd_yield* _con_x133 = kk_main__as_Hnd_yield(hnd, _ctx);
    kk_std_core_hnd__clause1 _ctl_yield = _con_x133->_ctl_yield;
    return kk_std_core_hnd__clause1_dup(_ctl_yield, _ctx);
  }
}
 
// Call the `ctl yield` operation of the effect `:yield`

static inline kk_unit_t kk_main_yield(kk_integer_t x, kk_context_t* _ctx) { /* (x : int) -> yield () */ 
  kk_std_core_hnd__ev ev_10024 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/yield>*/;
  kk_box_t _x_x134;
  {
    struct kk_std_core_hnd_Ev* _con_x135 = kk_std_core_hnd__as_Ev(ev_10024, _ctx);
    kk_box_t _box_x8 = _con_x135->hnd;
    int32_t m = _con_x135->marker;
    kk_main__yield h = kk_main__yield_unbox(_box_x8, KK_BORROWED, _ctx);
    kk_main__yield_dup(h, _ctx);
    {
      struct kk_main__Hnd_yield* _con_x136 = kk_main__as_Hnd_yield(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x136->_cfc;
      kk_std_core_hnd__clause1 _ctl_yield = _con_x136->_ctl_yield;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_yield, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x12 = _ctl_yield.clause;
        _x_x134 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x12, (_fun_unbox_x12, m, ev_10024, kk_integer_box(x, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x134); return kk_Unit;
}

kk_main__generator kk_main_generate(kk_function_t f, kk_context_t* _ctx); /* (f : () -> <div,yield> ()) -> div generator */ 

kk_unit_t kk_main__mlift_iterate_10021(kk_main__tree r, kk_unit_t wild___0, kk_context_t* _ctx); /* (r : tree, wild_@0 : ()) -> yield () */ 

kk_unit_t kk_main__mlift_iterate_10022(kk_main__tree r_0, kk_integer_t v, kk_unit_t wild__, kk_context_t* _ctx); /* (r : tree, v : int, wild_ : ()) -> yield () */ 

kk_unit_t kk_main_iterate(kk_main__tree t, kk_context_t* _ctx); /* (t : tree) -> yield () */ 

kk_main__tree kk_main_make(kk_integer_t n, kk_context_t* _ctx); /* (n : int) -> div tree */ 

kk_integer_t kk_main_sum(kk_integer_t a, kk_main__generator g, kk_context_t* _ctx); /* (a : int, g : generator) -> div int */ 

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx); /* (n : int) -> div int */ 

kk_unit_t kk_main_main(kk_context_t* _ctx); /* () -> <console/console,div,ndet> () */ 

void kk_main__init(kk_context_t* _ctx);


void kk_main__done(kk_context_t* _ctx);

#endif // header
