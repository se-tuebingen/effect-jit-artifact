#pragma once
#ifndef kk_std_core_H
#define kk_std_core_H
// Koka generated module: std/core, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_undiv.h"
#include "std_core_unsafe.h"
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
/*---------------------------------------------------------------------------
  Copyright 2020-2024, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

kk_box_t kk_main_console( kk_function_t action, kk_context_t* ctx );



// type declarations

// type std/core/blocking
struct kk_std_core__blocking_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core__blocking;
static inline kk_std_core__blocking kk_std_core__blocking_dup(kk_std_core__blocking _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core__blocking_drop(kk_std_core__blocking _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core__blocking_box(kk_std_core__blocking _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core__blocking kk_std_core__blocking_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/fsys
struct kk_std_core__fsys_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core__fsys;
static inline kk_std_core__fsys kk_std_core__fsys_dup(kk_std_core__fsys _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core__fsys_drop(kk_std_core__fsys _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core__fsys_box(kk_std_core__fsys _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core__fsys kk_std_core__fsys_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/global-scope
struct kk_std_core__global_scope_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core__global_scope;
static inline kk_std_core__global_scope kk_std_core__global_scope_dup(kk_std_core__global_scope _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core__global_scope_drop(kk_std_core__global_scope _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core__global_scope_box(kk_std_core__global_scope _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core__global_scope kk_std_core__global_scope_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/net
struct kk_std_core__net_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core__net;
static inline kk_std_core__net kk_std_core__net_dup(kk_std_core__net _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core__net_drop(kk_std_core__net _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core__net_box(kk_std_core__net _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core__net kk_std_core__net_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/ui
struct kk_std_core__ui_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core__ui;
static inline kk_std_core__ui kk_std_core__ui_dup(kk_std_core__ui _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core__ui_drop(kk_std_core__ui _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core__ui_box(kk_std_core__ui _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core__ui kk_std_core__ui_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/nmd
struct kk_std_core__nmd_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core__nmd;
static inline kk_std_core__nmd kk_std_core__nmd_dup(kk_std_core__nmd _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core__nmd_drop(kk_std_core__nmd _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core__nmd_box(kk_std_core__nmd _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core__nmd kk_std_core__nmd_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/scope
struct kk_std_core__scope_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core__scope;
static inline kk_std_core__scope kk_std_core__scope_dup(kk_std_core__scope _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core__scope_drop(kk_std_core__scope _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core__scope_box(kk_std_core__scope _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core__scope kk_std_core__scope_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/stream
struct kk_std_core__stream_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_std_core__stream;
struct kk_std_core_Next {
  struct kk_std_core__stream_s _base;
  kk_box_t head;
  kk_std_core__stream tail;
};
static inline kk_std_core__stream kk_std_core__base_Next(struct kk_std_core_Next* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_std_core__stream kk_std_core__new_Next(kk_reuse_t _at, int32_t _cpath, kk_box_t head, kk_std_core__stream tail, kk_context_t* _ctx) {
  struct kk_std_core_Next* _con = kk_block_alloc_at_as(struct kk_std_core_Next, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->head = head;
  _con->tail = tail;
  return kk_std_core__base_Next(_con, _ctx);
}
static inline struct kk_std_core_Next* kk_std_core__as_Next(kk_std_core__stream x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_Next*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_std_core__is_Next(kk_std_core__stream x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core__stream kk_std_core__stream_dup(kk_std_core__stream _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_std_core__stream_drop(kk_std_core__stream _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_std_core__stream_box(kk_std_core__stream _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_std_core__stream kk_std_core__stream_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Retrieves the `head` constructor field of the `:stream` type.

static inline kk_box_t kk_std_core_stream_fs_head(kk_std_core__stream stream, kk_context_t* _ctx) { /* forall<a> (stream : stream<a>) -> a */ 
  {
    struct kk_std_core_Next* _con_x67 = kk_std_core__as_Next(stream, _ctx);
    kk_box_t _x = _con_x67->head;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `tail` constructor field of the `:stream` type.

static inline kk_std_core__stream kk_std_core_stream_fs_tail(kk_std_core__stream stream, kk_context_t* _ctx) { /* forall<a> (stream : stream<a>) -> stream<a> */ 
  {
    struct kk_std_core_Next* _con_x68 = kk_std_core__as_Next(stream, _ctx);
    kk_std_core__stream _x = _con_x68->tail;
    return kk_std_core__stream_dup(_x, _ctx);
  }
}

kk_std_core__stream kk_std_core_stream_fs__copy(kk_std_core__stream _this, kk_std_core_types__optional head, kk_std_core_types__optional tail, kk_context_t* _ctx); /* forall<a> (stream<a>, head : ? a, tail : ? (stream<a>)) -> stream<a> */ 

kk_unit_t kk_std_core__default_exn(kk_function_t action, kk_context_t* _ctx); /* forall<e> (action : () -> <exn,console/console|e> ()) -> <console/console|e> () */ 
 
// Generic equality if `cmp` exists

static inline bool kk_std_core_cmp_fs__lp__eq__eq__rp_(kk_box_t x, kk_box_t y, kk_function_t _implicit_fs_cmp, kk_context_t* _ctx) { /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */ 
  kk_std_core_types__order _match_x65 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_cmp, (_implicit_fs_cmp, x, y, _ctx), _ctx); /*order*/;
  if (kk_std_core_types__is_Eq(_match_x65, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Apply a function `f` to a specified argument `x`.

static inline kk_box_t kk_std_core_apply(kk_function_t f, kk_box_t x, kk_context_t* _ctx) { /* forall<a,b,e> (f : (a) -> e b, x : a) -> e b */ 
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, x, _ctx), _ctx);
}
 
// Return a 'constant' function that ignores its argument and always returns the same result


// lift anonymous function
struct kk_std_core_const_fun89__t {
  struct kk_function_s _base;
  kk_box_t kkloc_default;
};
extern kk_box_t kk_std_core_const_fun89(kk_function_t _fself, kk_box_t ___wildcard_x103__6, kk_context_t* _ctx);
static inline kk_function_t kk_std_core_new_const_fun89(kk_box_t kkloc_default, kk_context_t* _ctx) {
  struct kk_std_core_const_fun89__t* _self = kk_function_alloc_as(struct kk_std_core_const_fun89__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_const_fun89, kk_context());
  _self->kkloc_default = kkloc_default;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline kk_function_t kk_std_core_const(kk_box_t kkloc_default, kk_context_t* _ctx) { /* forall<a,b> (default : a) -> ((x : b) -> a) */ 
  return kk_std_core_new_const_fun89(kkloc_default, _ctx);
}

kk_string_t kk_std_core_host(kk_context_t* _ctx); /* () -> ndet string */ 
 
// The `ignore` function ignores its argument.

static inline kk_unit_t kk_std_core_ignore(kk_box_t x, kk_context_t* _ctx) { /* forall<a> (x : a) -> () */ 
  kk_box_drop(x, _ctx);
  kk_Unit; return kk_Unit;
}

kk_box_t kk_std_core_main_console(kk_function_t main, kk_context_t* _ctx); /* forall<a,e> (main : () -> e a) -> e a */ 

kk_function_t kk_std_core_o(kk_function_t f, kk_function_t g, kk_context_t* _ctx); /* forall<a,b,c,e> (f : (a) -> e b, g : (c) -> e a) -> ((x : c) -> e b) */ 
 
// Concise way to ensure two expressions have the same type.

static inline kk_box_t kk_std_core_same_type(kk_box_t x, kk_box_t y, kk_context_t* _ctx) { /* forall<a> (x : a, y : a) -> a */ 
  kk_box_drop(y, _ctx);
  return x;
}

extern kk_ref_t kk_std_core_unique_count;
 
// Generic inequality

static inline bool kk_std_core__lp__excl__eq__rp_(kk_box_t x, kk_box_t y, kk_function_t _implicit_fs__lp__eq__eq__rp_, kk_context_t* _ctx) { /* forall<a> (x : a, y : a, ?(==) : (a, a) -> bool) -> bool */ 
  bool b_10003 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs__lp__eq__eq__rp_, (_implicit_fs__lp__eq__eq__rp_, x, y, _ctx), _ctx); /*bool*/;
  if (b_10003) {
    return false;
  }
  {
    return true;
  }
}
 
// Generic lower than

static inline bool kk_std_core__lp__lt__rp_(kk_box_t x, kk_box_t y, kk_function_t _implicit_fs_cmp, kk_context_t* _ctx) { /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */ 
  kk_std_core_types__order _x_x91 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_cmp, (_implicit_fs_cmp, x, y, _ctx), _ctx); /*order*/
  return kk_std_core_order__lp__eq__eq__rp_(_x_x91, kk_std_core_types__new_Lt(_ctx), _ctx);
}
 
// Generic greater than

static inline bool kk_std_core__lp__gt__rp_(kk_box_t x, kk_box_t y, kk_function_t _implicit_fs_cmp, kk_context_t* _ctx) { /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */ 
  kk_std_core_types__order _x_x92 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_cmp, (_implicit_fs_cmp, x, y, _ctx), _ctx); /*order*/
  return kk_std_core_order__lp__eq__eq__rp_(_x_x92, kk_std_core_types__new_Gt(_ctx), _ctx);
}
 
// Generic lower than or equal

static inline bool kk_std_core__lp__lt__eq__rp_(kk_box_t x, kk_box_t y, kk_function_t _implicit_fs_cmp, kk_context_t* _ctx) { /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */ 
  kk_std_core_types__order _x_x93 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_cmp, (_implicit_fs_cmp, y, x, _ctx), _ctx); /*order*/
  return kk_std_core_order__lp__eq__eq__rp_(_x_x93, kk_std_core_types__new_Gt(_ctx), _ctx);
}
 
// Generic greater than or equal

static inline bool kk_std_core__lp__gt__eq__rp_(kk_box_t x, kk_box_t y, kk_function_t _implicit_fs_cmp, kk_context_t* _ctx) { /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */ 
  kk_std_core_types__order _x_x94 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_cmp, (_implicit_fs_cmp, y, x, _ctx), _ctx); /*order*/
  return kk_std_core_order__lp__eq__eq__rp_(_x_x94, kk_std_core_types__new_Lt(_ctx), _ctx);
}

kk_box_t kk_std_core_range_fs__mlift_fold_10071(kk_integer_t end, kk_function_t f, kk_integer_t start, kk_box_t x, kk_context_t* _ctx); /* forall<a,e> (end : int, f : (int, a) -> e a, start : int, x : a) -> e a */ 

kk_box_t kk_std_core_range_fs_fold(kk_integer_t start_0, kk_integer_t end_0, kk_box_t init, kk_function_t f_0, kk_context_t* _ctx); /* forall<a,e> (start : int, end : int, init : a, f : (int, a) -> e a) -> e a */ 
 
// Fold over the integers between [0,`upto`)  (excluding `upto`).

static inline kk_box_t kk_std_core_fold(kk_integer_t upto, kk_box_t init, kk_function_t f, kk_context_t* _ctx) { /* forall<a,e> (upto : int, init : a, f : (int, a) -> e a) -> e a */ 
  kk_integer_t _x_x100 = kk_integer_add_small_const(upto, -1, _ctx); /*int*/
  return kk_std_core_range_fs_fold(kk_integer_from_small(0), _x_x100, init, f, _ctx);
}

kk_box_t kk_std_core_range_fs__mlift_fold_while_10072(kk_integer_t end, kk_function_t f, kk_box_t init, kk_integer_t start, kk_std_core_types__maybe _y_x10033, kk_context_t* _ctx); /* forall<a,e> (end : int, f : (int, a) -> e maybe<a>, init : a, start : int, maybe<a>) -> e a */ 

kk_box_t kk_std_core_range_fs_fold_while(kk_integer_t start_0, kk_integer_t end_0, kk_box_t init_0, kk_function_t f_0, kk_context_t* _ctx); /* forall<a,e> (start : int, end : int, init : a, f : (int, a) -> e maybe<a>) -> e a */ 
 
// Fold over the integers between [0,`n`) (excluding `n`) or until `f` returns `Nothing`

static inline kk_box_t kk_std_core_fold_while(kk_integer_t n, kk_box_t init, kk_function_t f, kk_context_t* _ctx) { /* forall<a,e> (n : int, init : a, f : (int, a) -> e maybe<a>) -> e a */ 
  kk_integer_t _x_x108 = kk_integer_add_small_const(n, -1, _ctx); /*int*/
  return kk_std_core_range_fs_fold_while(kk_integer_from_small(0), _x_x108, init, f, _ctx);
}

kk_unit_t kk_std_core_range_fs__mlift_lift_for_1256_10073(kk_function_t action, kk_integer_t end, kk_integer_t i, kk_unit_t wild__, kk_context_t* _ctx); /* forall<e> (action : (int) -> e (), end : int, i : int, wild_ : ()) -> e () */ 

kk_unit_t kk_std_core_range_fs__lift_for_1256(kk_function_t action_0, kk_integer_t end_0, kk_integer_t i_0, kk_context_t* _ctx); /* forall<e> (action : (int) -> e (), end : int, i : int) -> e () */ 
 
// Executes `action`  for each integer from `start` to `end` (including `end` ).
// If `start > end`  the function returns without any call to `action` .

static inline kk_unit_t kk_std_core_range_fs_for(kk_integer_t start, kk_integer_t end, kk_function_t action, kk_context_t* _ctx) { /* forall<e> (start : int, end : int, action : (int) -> e ()) -> e () */ 
  kk_integer_t _x_x114 = kk_integer_dup(start, _ctx); /*int*/
  kk_std_core_range_fs__lift_for_1256(action, end, _x_x114, _ctx); return kk_Unit;
}
 
// Executes `action` `n` times for each integer from `0` to `n-1`.
// If `n <= 0`  the function returns without any call to `action` .

static inline kk_unit_t kk_std_core_for(kk_integer_t n, kk_function_t action, kk_context_t* _ctx) { /* forall<e> (n : int, action : (int) -> e ()) -> e () */ 
  kk_integer_t end_10012;
  kk_integer_t _x_x115 = kk_integer_dup(n, _ctx); /*int*/
  end_10012 = kk_integer_add_small_const(_x_x115, -1, _ctx); /*int*/
  kk_std_core_range_fs__lift_for_1256(action, end_10012, kk_integer_from_small(0), _ctx); return kk_Unit;
}

kk_std_core_types__maybe kk_std_core_range_fs__mlift_lift_for_while_1257_10074(kk_function_t action, kk_integer_t end, kk_integer_t i, kk_std_core_types__maybe _y_x10043, kk_context_t* _ctx); /* forall<a,e> (action : (int) -> e maybe<a>, end : int, i : int, maybe<a>) -> e maybe<a> */ 

kk_std_core_types__maybe kk_std_core_range_fs__lift_for_while_1257(kk_function_t action_0, kk_integer_t end_0, kk_integer_t i_0, kk_context_t* _ctx); /* forall<a,e> (action : (int) -> e maybe<a>, end : int, i : int) -> e maybe<a> */ 
 
// Executes `action`  for each integer between `start`  to `end`  (including `end` ).
// If `start > end`  the function returns without any call to `action` .
// If `action` returns `Just`, the iteration is stopped and the result returned

static inline kk_std_core_types__maybe kk_std_core_range_fs_for_while(kk_integer_t start, kk_integer_t end, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (start : int, end : int, action : (int) -> e maybe<a>) -> e maybe<a> */ 
  return kk_std_core_range_fs__lift_for_while_1257(action, end, start, _ctx);
}
 
// Executes `action`  for each integer between [0,`n`)  (excluding `n` ).
// If `n <= 0`  the function returns without any call to `action` .
// If `action` returns `Just`, the iteration is stopped and the result returned

static inline kk_std_core_types__maybe kk_std_core_for_while(kk_integer_t n, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (n : int, action : (int) -> e maybe<a>) -> e maybe<a> */ 
  kk_integer_t end_10016 = kk_integer_add_small_const(n, -1, _ctx); /*int*/;
  return kk_std_core_range_fs__lift_for_while_1257(action, end_10016, kk_integer_from_small(0), _ctx);
}
 
// The `repeat` fun executes `action`  `n`  times.


// lift anonymous function
struct kk_std_core_repeat_fun122__t {
  struct kk_function_s _base;
  kk_function_t action;
};
extern kk_unit_t kk_std_core_repeat_fun122(kk_function_t _fself, kk_integer_t i_0, kk_context_t* _ctx);
static inline kk_function_t kk_std_core_new_repeat_fun122(kk_function_t action, kk_context_t* _ctx) {
  struct kk_std_core_repeat_fun122__t* _self = kk_function_alloc_as(struct kk_std_core_repeat_fun122__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_repeat_fun122, kk_context());
  _self->action = action;
  return kk_datatype_from_base(&_self->_base, kk_context());
}


static inline kk_unit_t kk_std_core_repeat(kk_integer_t n, kk_function_t action, kk_context_t* _ctx) { /* forall<e> (n : int, action : () -> e ()) -> e () */ 
  kk_integer_t end_10021;
  kk_integer_t _x_x121 = kk_integer_dup(n, _ctx); /*int*/
  end_10021 = kk_integer_add_small_const(_x_x121, -1, _ctx); /*int*/
  kk_std_core_range_fs__lift_for_1256(kk_std_core_new_repeat_fun122(action, _ctx), end_10021, kk_integer_from_small(0), _ctx); return kk_Unit;
}

kk_integer_t kk_std_core_unique(kk_context_t* _ctx); /* () -> ndet int */ 

kk_unit_t kk_std_core__mlift_while_10075(kk_function_t action, kk_function_t predicate, kk_unit_t wild__, kk_context_t* _ctx); /* forall<e> (action : () -> <div|e> (), predicate : () -> <div|e> bool, wild_ : ()) -> <div|e> () */ 

kk_unit_t kk_std_core__mlift_while_10076(kk_function_t action_0, kk_function_t predicate_0, bool _y_x10051, kk_context_t* _ctx); /* forall<e> (action : () -> <div|e> (), predicate : () -> <div|e> bool, bool) -> <div|e> () */ 

kk_unit_t kk_std_core_while(kk_function_t predicate_1, kk_function_t action_1, kk_context_t* _ctx); /* forall<e> (predicate : () -> <div|e> bool, action : () -> <div|e> ()) -> <div|e> () */ 

void kk_std_core__init(kk_context_t* _ctx);


void kk_std_core__done(kk_context_t* _ctx);

#endif // header
