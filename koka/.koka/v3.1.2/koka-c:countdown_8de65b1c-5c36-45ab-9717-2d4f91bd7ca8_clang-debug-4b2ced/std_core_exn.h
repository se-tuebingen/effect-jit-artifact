#pragma once
#ifndef kk_std_core_exn_H
#define kk_std_core_exn_H
// Koka generated module: std/core/exn, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_hnd.h"
/*---------------------------------------------------------------------------
  Copyright 2020-2024, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

kk_box_t kk_std_core_error_pattern(kk_string_t location, kk_string_t definition, kk_context_t* _ctx);

struct kk_std_core_exn_error_s;
struct kk_std_core_exn_error_s kk_error_ok( kk_box_t result, kk_context_t* ctx );
struct kk_std_core_exn_error_s kk_error_from_errno( int err, kk_context_t* ctx );

// type declarations

// type std/core/exn/exception-info
struct kk_std_core_exn__exception_info_s {
  kk_block_t _block;
  kk_string_t _tag;
};
typedef kk_datatype_ptr_t kk_std_core_exn__exception_info;
struct kk_std_core_exn_ExnError {
  struct kk_std_core_exn__exception_info_s _base;
};
struct kk_std_core_exn_ExnAssert {
  struct kk_std_core_exn__exception_info_s _base;
};
struct kk_std_core_exn_ExnTodo {
  struct kk_std_core_exn__exception_info_s _base;
};
struct kk_std_core_exn_ExnRange {
  struct kk_std_core_exn__exception_info_s _base;
};
struct kk_std_core_exn_ExnPattern {
  struct kk_std_core_exn__exception_info_s _base;
  kk_string_t location;
  kk_string_t definition;
};
struct kk_std_core_exn_ExnSystem {
  struct kk_std_core_exn__exception_info_s _base;
  kk_integer_t kkloc_errno;
};
struct kk_std_core_exn_ExnInternal {
  struct kk_std_core_exn__exception_info_s _base;
  kk_string_t name;
};
static inline kk_std_core_exn__exception_info kk_std_core_exn__base_ExnError(struct kk_std_core_exn_ExnError* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
extern kk_string_t kk_std_core_exn__tag_ExnError;
static inline kk_std_core_exn__exception_info kk_std_core_exn__new_ExnError(kk_context_t* _ctx) {
  struct kk_std_core_exn_ExnError* _con = kk_block_alloc_at_as(struct kk_std_core_exn_ExnError, kk_reuse_null, 1 /* scan count */, 0, KK_TAG_OPEN, _ctx);
  _con->_base._tag = kk_string_dup(kk_std_core_exn__tag_ExnError, _ctx);
  return kk_std_core_exn__base_ExnError(_con, _ctx);
}
static inline struct kk_std_core_exn_ExnError* kk_std_core_exn__as_ExnError(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_exn_ExnError*, x, KK_TAG_OPEN, _ctx);
}
static inline kk_std_core_exn__exception_info kk_std_core_exn__base_ExnAssert(struct kk_std_core_exn_ExnAssert* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
extern kk_string_t kk_std_core_exn__tag_ExnAssert;
static inline kk_std_core_exn__exception_info kk_std_core_exn__new_ExnAssert(kk_context_t* _ctx) {
  struct kk_std_core_exn_ExnAssert* _con = kk_block_alloc_at_as(struct kk_std_core_exn_ExnAssert, kk_reuse_null, 1 /* scan count */, 0, KK_TAG_OPEN, _ctx);
  _con->_base._tag = kk_string_dup(kk_std_core_exn__tag_ExnAssert, _ctx);
  return kk_std_core_exn__base_ExnAssert(_con, _ctx);
}
static inline struct kk_std_core_exn_ExnAssert* kk_std_core_exn__as_ExnAssert(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_exn_ExnAssert*, x, KK_TAG_OPEN, _ctx);
}
static inline kk_std_core_exn__exception_info kk_std_core_exn__base_ExnTodo(struct kk_std_core_exn_ExnTodo* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
extern kk_string_t kk_std_core_exn__tag_ExnTodo;
static inline kk_std_core_exn__exception_info kk_std_core_exn__new_ExnTodo(kk_context_t* _ctx) {
  struct kk_std_core_exn_ExnTodo* _con = kk_block_alloc_at_as(struct kk_std_core_exn_ExnTodo, kk_reuse_null, 1 /* scan count */, 0, KK_TAG_OPEN, _ctx);
  _con->_base._tag = kk_string_dup(kk_std_core_exn__tag_ExnTodo, _ctx);
  return kk_std_core_exn__base_ExnTodo(_con, _ctx);
}
static inline struct kk_std_core_exn_ExnTodo* kk_std_core_exn__as_ExnTodo(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_exn_ExnTodo*, x, KK_TAG_OPEN, _ctx);
}
static inline kk_std_core_exn__exception_info kk_std_core_exn__base_ExnRange(struct kk_std_core_exn_ExnRange* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
extern kk_string_t kk_std_core_exn__tag_ExnRange;
static inline kk_std_core_exn__exception_info kk_std_core_exn__new_ExnRange(kk_context_t* _ctx) {
  struct kk_std_core_exn_ExnRange* _con = kk_block_alloc_at_as(struct kk_std_core_exn_ExnRange, kk_reuse_null, 1 /* scan count */, 0, KK_TAG_OPEN, _ctx);
  _con->_base._tag = kk_string_dup(kk_std_core_exn__tag_ExnRange, _ctx);
  return kk_std_core_exn__base_ExnRange(_con, _ctx);
}
static inline struct kk_std_core_exn_ExnRange* kk_std_core_exn__as_ExnRange(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_exn_ExnRange*, x, KK_TAG_OPEN, _ctx);
}
static inline kk_std_core_exn__exception_info kk_std_core_exn__base_ExnSystem(struct kk_std_core_exn_ExnSystem* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
extern kk_string_t kk_std_core_exn__tag_ExnSystem;
static inline kk_std_core_exn__exception_info kk_std_core_exn__new_ExnSystem(kk_reuse_t _at, int32_t _cpath, kk_integer_t kkloc_errno, kk_context_t* _ctx) {
  struct kk_std_core_exn_ExnSystem* _con = kk_block_alloc_at_as(struct kk_std_core_exn_ExnSystem, _at, 2 /* scan count */, _cpath, KK_TAG_OPEN, _ctx);
  _con->_base._tag = kk_string_dup(kk_std_core_exn__tag_ExnSystem, _ctx);
  _con->kkloc_errno = kkloc_errno;
  return kk_std_core_exn__base_ExnSystem(_con, _ctx);
}
static inline struct kk_std_core_exn_ExnSystem* kk_std_core_exn__as_ExnSystem(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_exn_ExnSystem*, x, KK_TAG_OPEN, _ctx);
}
static inline kk_std_core_exn__exception_info kk_std_core_exn__base_ExnInternal(struct kk_std_core_exn_ExnInternal* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
extern kk_string_t kk_std_core_exn__tag_ExnInternal;
static inline kk_std_core_exn__exception_info kk_std_core_exn__new_ExnInternal(kk_reuse_t _at, int32_t _cpath, kk_string_t name, kk_context_t* _ctx) {
  struct kk_std_core_exn_ExnInternal* _con = kk_block_alloc_at_as(struct kk_std_core_exn_ExnInternal, _at, 2 /* scan count */, _cpath, KK_TAG_OPEN, _ctx);
  _con->_base._tag = kk_string_dup(kk_std_core_exn__tag_ExnInternal, _ctx);
  _con->name = name;
  return kk_std_core_exn__base_ExnInternal(_con, _ctx);
}
static inline struct kk_std_core_exn_ExnInternal* kk_std_core_exn__as_ExnInternal(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_exn_ExnInternal*, x, KK_TAG_OPEN, _ctx);
}
static inline kk_std_core_exn__exception_info kk_std_core_exn__base_ExnPattern(struct kk_std_core_exn_ExnPattern* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
extern kk_string_t kk_std_core_exn__tag_ExnPattern;
static inline kk_std_core_exn__exception_info kk_std_core_exn__new_ExnPattern(kk_reuse_t _at, int32_t _cpath, kk_string_t location, kk_string_t definition, kk_context_t* _ctx) {
  struct kk_std_core_exn_ExnPattern* _con = kk_block_alloc_at_as(struct kk_std_core_exn_ExnPattern, _at, 3 /* scan count */, _cpath, KK_TAG_OPEN, _ctx);
  _con->_base._tag = kk_string_dup(kk_std_core_exn__tag_ExnPattern, _ctx);
  _con->location = location;
  _con->definition = definition;
  return kk_std_core_exn__base_ExnPattern(_con, _ctx);
}
static inline struct kk_std_core_exn_ExnPattern* kk_std_core_exn__as_ExnPattern(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_exn_ExnPattern*, x, KK_TAG_OPEN, _ctx);
}
static inline bool kk_std_core_exn__is_ExnError(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return (kk_string_ptr_eq_borrow((kk_datatype_as(struct kk_std_core_exn__exception_info_s*, x, _ctx))->_tag, kk_std_core_exn__tag_ExnError));
}
static inline bool kk_std_core_exn__is_ExnAssert(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return (kk_string_ptr_eq_borrow((kk_datatype_as(struct kk_std_core_exn__exception_info_s*, x, _ctx))->_tag, kk_std_core_exn__tag_ExnAssert));
}
static inline bool kk_std_core_exn__is_ExnTodo(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return (kk_string_ptr_eq_borrow((kk_datatype_as(struct kk_std_core_exn__exception_info_s*, x, _ctx))->_tag, kk_std_core_exn__tag_ExnTodo));
}
static inline bool kk_std_core_exn__is_ExnRange(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return (kk_string_ptr_eq_borrow((kk_datatype_as(struct kk_std_core_exn__exception_info_s*, x, _ctx))->_tag, kk_std_core_exn__tag_ExnRange));
}
static inline bool kk_std_core_exn__is_ExnSystem(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return (kk_string_ptr_eq_borrow((kk_datatype_as(struct kk_std_core_exn__exception_info_s*, x, _ctx))->_tag, kk_std_core_exn__tag_ExnSystem));
}
static inline bool kk_std_core_exn__is_ExnInternal(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return (kk_string_ptr_eq_borrow((kk_datatype_as(struct kk_std_core_exn__exception_info_s*, x, _ctx))->_tag, kk_std_core_exn__tag_ExnInternal));
}
static inline bool kk_std_core_exn__is_ExnPattern(kk_std_core_exn__exception_info x, kk_context_t* _ctx) {
  return (kk_string_ptr_eq_borrow((kk_datatype_as(struct kk_std_core_exn__exception_info_s*, x, _ctx))->_tag, kk_std_core_exn__tag_ExnPattern));
}
static inline kk_std_core_exn__exception_info kk_std_core_exn__exception_info_dup(kk_std_core_exn__exception_info _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_std_core_exn__exception_info_drop(kk_std_core_exn__exception_info _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_std_core_exn__exception_info_box(kk_std_core_exn__exception_info _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_std_core_exn__exception_info kk_std_core_exn__exception_info_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value type std/core/exn/exception
struct kk_std_core_exn_Exception {
  kk_string_t message;
  kk_std_core_exn__exception_info info;
};
typedef struct kk_std_core_exn_Exception kk_std_core_exn__exception;
static inline kk_std_core_exn__exception kk_std_core_exn__new_Exception(kk_string_t message, kk_std_core_exn__exception_info info, kk_context_t* _ctx) {
  kk_std_core_exn__exception _con;
  _con.message = message;
  _con.info = info;
  return _con;
}
static inline bool kk_std_core_exn__is_Exception(kk_std_core_exn__exception x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core_exn__exception kk_std_core_exn__exception_dup(kk_std_core_exn__exception _x, kk_context_t* _ctx) {
  kk_string_dup(_x.message, _ctx);
  kk_std_core_exn__exception_info_dup(_x.info, _ctx);
  return _x;
}
static inline void kk_std_core_exn__exception_drop(kk_std_core_exn__exception _x, kk_context_t* _ctx) {
  kk_string_drop(_x.message, _ctx);
  kk_std_core_exn__exception_info_drop(_x.info, _ctx);
}
static inline kk_box_t kk_std_core_exn__exception_box(kk_std_core_exn__exception _x, kk_context_t* _ctx) {
  kk_box_t _box;
  kk_valuetype_box(kk_std_core_exn__exception, _box, _x, 2 /* scan count */, _ctx);
  return _box;
}
static inline kk_std_core_exn__exception kk_std_core_exn__exception_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  kk_std_core_exn__exception _unbox;
  kk_valuetype_unbox(kk_std_core_exn__exception, _unbox, _x, _borrow, _ctx);
  return _unbox;
}

// value type std/core/exn/error
struct kk_std_core_exn_Error {
  kk_std_core_exn__exception exception;
};
struct kk_std_core_exn_Ok {
  kk_box_t result;
};
struct kk_std_core_exn_error_s {
  kk_value_tag_t _tag;
  union {
    struct kk_std_core_exn_Error Error;
    struct kk_std_core_exn_Ok Ok;
    kk_box_t _fields[2];
  } _cons;
};
typedef struct kk_std_core_exn_error_s kk_std_core_exn__error;
static inline kk_std_core_exn__error kk_std_core_exn__new_Error(kk_std_core_exn__exception exception, kk_context_t* _ctx) {
  kk_std_core_exn__error _con;
  _con._tag = kk_value_tag(1);
  _con._cons.Error.exception = exception;
  return _con;
}
static inline kk_std_core_exn__error kk_std_core_exn__new_Ok(kk_box_t result, kk_context_t* _ctx) {
  kk_std_core_exn__error _con;
  _con._tag = kk_value_tag(2);
  _con._cons.Ok.result = result;
  _con._cons._fields[1] = kk_box_null();
  return _con;
}
static inline bool kk_std_core_exn__is_Error(kk_std_core_exn__error x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(1)));
}
static inline bool kk_std_core_exn__is_Ok(kk_std_core_exn__error x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(2)));
}
static inline kk_std_core_exn__error kk_std_core_exn__error_dup(kk_std_core_exn__error _x, kk_context_t* _ctx) {
  if (kk_std_core_exn__is_Error(_x, _ctx)) { kk_std_core_exn__exception_dup(_x._cons.Error.exception, _ctx); }
  else { kk_box_dup(_x._cons.Ok.result, _ctx); }
  return _x;
}
static inline void kk_std_core_exn__error_drop(kk_std_core_exn__error _x, kk_context_t* _ctx) {
  if (kk_std_core_exn__is_Error(_x, _ctx)) { kk_std_core_exn__exception_drop(_x._cons.Error.exception, _ctx); }
  else { kk_box_drop(_x._cons.Ok.result, _ctx); }
}
static inline kk_box_t kk_std_core_exn__error_box(kk_std_core_exn__error _x, kk_context_t* _ctx) {
  kk_box_t _box;
  kk_valuetype_box(kk_std_core_exn__error, _box, _x, 3 /* scan count */, _ctx);
  return _box;
}
static inline kk_std_core_exn__error kk_std_core_exn__error_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  kk_std_core_exn__error _unbox;
  kk_valuetype_unbox(kk_std_core_exn__error, _unbox, _x, _borrow, _ctx);
  return _unbox;
}

// type std/core/exn/exn
struct kk_std_core_exn__exn_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_std_core_exn__exn;
struct kk_std_core_exn__Hnd_exn {
  struct kk_std_core_exn__exn_s _base;
  kk_integer_t _cfc;
  kk_std_core_hnd__clause1 _brk_throw_exn;
};
static inline kk_std_core_exn__exn kk_std_core_exn__base_Hnd_exn(struct kk_std_core_exn__Hnd_exn* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_std_core_exn__exn kk_std_core_exn__new_Hnd_exn(kk_reuse_t _at, int32_t _cpath, kk_integer_t _cfc, kk_std_core_hnd__clause1 _brk_throw_exn, kk_context_t* _ctx) {
  struct kk_std_core_exn__Hnd_exn* _con = kk_block_alloc_at_as(struct kk_std_core_exn__Hnd_exn, _at, 2 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->_cfc = _cfc;
  _con->_brk_throw_exn = _brk_throw_exn;
  return kk_std_core_exn__base_Hnd_exn(_con, _ctx);
}
static inline struct kk_std_core_exn__Hnd_exn* kk_std_core_exn__as_Hnd_exn(kk_std_core_exn__exn x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_exn__Hnd_exn*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_std_core_exn__is_Hnd_exn(kk_std_core_exn__exn x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core_exn__exn kk_std_core_exn__exn_dup(kk_std_core_exn__exn _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_std_core_exn__exn_drop(kk_std_core_exn__exn _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_std_core_exn__exn_box(kk_std_core_exn__exn _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_std_core_exn__exn kk_std_core_exn__exn_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value declarations
 
// Automatically generated. Tests for the `ExnError` constructor of the `:exception-info` type.

static inline bool kk_std_core_exn_is_exnError(kk_std_core_exn__exception_info kkloc_exception_info, kk_context_t* _ctx) { /* (exception-info : exception-info) -> bool */ 
  if (kk_std_core_exn__is_ExnError(kkloc_exception_info, _ctx)) {
    struct kk_std_core_exn_ExnError* _con_x93 = kk_std_core_exn__as_ExnError(kkloc_exception_info, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `ExnAssert` constructor of the `:exception-info` type.

static inline bool kk_std_core_exn_is_exnAssert(kk_std_core_exn__exception_info kkloc_exception_info, kk_context_t* _ctx) { /* (exception-info : exception-info) -> bool */ 
  if (kk_std_core_exn__is_ExnAssert(kkloc_exception_info, _ctx)) {
    struct kk_std_core_exn_ExnAssert* _con_x94 = kk_std_core_exn__as_ExnAssert(kkloc_exception_info, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `ExnTodo` constructor of the `:exception-info` type.

static inline bool kk_std_core_exn_is_exnTodo(kk_std_core_exn__exception_info kkloc_exception_info, kk_context_t* _ctx) { /* (exception-info : exception-info) -> bool */ 
  if (kk_std_core_exn__is_ExnTodo(kkloc_exception_info, _ctx)) {
    struct kk_std_core_exn_ExnTodo* _con_x95 = kk_std_core_exn__as_ExnTodo(kkloc_exception_info, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `ExnRange` constructor of the `:exception-info` type.

static inline bool kk_std_core_exn_is_exnRange(kk_std_core_exn__exception_info kkloc_exception_info, kk_context_t* _ctx) { /* (exception-info : exception-info) -> bool */ 
  if (kk_std_core_exn__is_ExnRange(kkloc_exception_info, _ctx)) {
    struct kk_std_core_exn_ExnRange* _con_x96 = kk_std_core_exn__as_ExnRange(kkloc_exception_info, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `ExnPattern` constructor of the `:exception-info` type.

static inline bool kk_std_core_exn_is_exnPattern(kk_std_core_exn__exception_info kkloc_exception_info, kk_context_t* _ctx) { /* (exception-info : exception-info) -> bool */ 
  if (kk_std_core_exn__is_ExnPattern(kkloc_exception_info, _ctx)) {
    struct kk_std_core_exn_ExnPattern* _con_x97 = kk_std_core_exn__as_ExnPattern(kkloc_exception_info, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `ExnSystem` constructor of the `:exception-info` type.

static inline bool kk_std_core_exn_is_exnSystem(kk_std_core_exn__exception_info kkloc_exception_info, kk_context_t* _ctx) { /* (exception-info : exception-info) -> bool */ 
  if (kk_std_core_exn__is_ExnSystem(kkloc_exception_info, _ctx)) {
    struct kk_std_core_exn_ExnSystem* _con_x98 = kk_std_core_exn__as_ExnSystem(kkloc_exception_info, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `ExnInternal` constructor of the `:exception-info` type.

static inline bool kk_std_core_exn_is_exnInternal(kk_std_core_exn__exception_info kkloc_exception_info, kk_context_t* _ctx) { /* (exception-info : exception-info) -> bool */ 
  if (kk_std_core_exn__is_ExnInternal(kkloc_exception_info, _ctx)) {
    struct kk_std_core_exn_ExnInternal* _con_x99 = kk_std_core_exn__as_ExnInternal(kkloc_exception_info, _ctx);
    return true;
  }
  {
    return false;
  }
}

extern kk_string_t kk_std_core_exn__tag_ExnError;

extern kk_string_t kk_std_core_exn__tag_ExnAssert;

extern kk_string_t kk_std_core_exn__tag_ExnTodo;

extern kk_string_t kk_std_core_exn__tag_ExnRange;

extern kk_string_t kk_std_core_exn__tag_ExnPattern;

extern kk_string_t kk_std_core_exn__tag_ExnSystem;

extern kk_string_t kk_std_core_exn__tag_ExnInternal;
 
// Automatically generated. Retrieves the `message` constructor field of the `:exception` type.

static inline kk_string_t kk_std_core_exn_exception_fs_message(kk_std_core_exn__exception exception, kk_context_t* _ctx) { /* (exception : exception) -> string */ 
  {
    kk_string_t _x = exception.message;
    return kk_string_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `info` constructor field of the `:exception` type.

static inline kk_std_core_exn__exception_info kk_std_core_exn_exception_fs_info(kk_std_core_exn__exception exception, kk_context_t* _ctx) { /* (exception : exception) -> exception-info */ 
  {
    kk_std_core_exn__exception_info _x = exception.info;
    return kk_std_core_exn__exception_info_dup(_x, _ctx);
  }
}

kk_std_core_exn__exception kk_std_core_exn_exception_fs__copy(kk_std_core_exn__exception _this, kk_std_core_types__optional message, kk_std_core_types__optional info, kk_context_t* _ctx); /* (exception, message : ? string, info : ? exception-info) -> exception */ 
 
// Automatically generated. Tests for the `Error` constructor of the `:error` type.

static inline bool kk_std_core_exn_is_error(kk_std_core_exn__error error, kk_context_t* _ctx) { /* forall<a> (error : error<a>) -> bool */ 
  if (kk_std_core_exn__is_Error(error, _ctx)) {
    kk_std_core_exn__exception _pat_0 = error._cons.Error.exception;
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Ok` constructor of the `:error` type.

static inline bool kk_std_core_exn_is_ok(kk_std_core_exn__error error, kk_context_t* _ctx) { /* forall<a> (error : error<a>) -> bool */ 
  if (kk_std_core_exn__is_Ok(error, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:exn` type.

static inline kk_integer_t kk_std_core_exn_exn_fs__cfc(kk_std_core_exn__exn exn_0, kk_context_t* _ctx) { /* forall<e,a> (exn : exn<e,a>) -> int */ 
  {
    struct kk_std_core_exn__Hnd_exn* _con_x102 = kk_std_core_exn__as_Hnd_exn(exn_0, _ctx);
    kk_integer_t _x = _con_x102->_cfc;
    return kk_integer_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `@brk-throw-exn` constructor field of the `:exn` type.

static inline kk_std_core_hnd__clause1 kk_std_core_exn_exn_fs__brk_throw_exn(kk_std_core_exn__exn exn_0, kk_context_t* _ctx) { /* forall<e,a,b> (exn : exn<e,a>) -> hnd/clause1<exception,b,exn,e,a> */ 
  {
    struct kk_std_core_exn__Hnd_exn* _con_x103 = kk_std_core_exn__as_Hnd_exn(exn_0, _ctx);
    kk_std_core_hnd__clause1 _x = _con_x103->_brk_throw_exn;
    return kk_std_core_hnd__clause1_dup(_x, _ctx);
  }
}

extern kk_std_core_hnd__htag kk_std_core_exn__tag_exn;

kk_box_t kk_std_core_exn__handle_exn(kk_std_core_exn__exn hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx); /* forall<a,e,b> (hnd : exn<e,b>, ret : (res : a) -> e b, action : () -> <exn|e> a) -> e b */ 
 
// select `throw-exn` operation out of effect `:exn`

static inline kk_std_core_hnd__clause1 kk_std_core_exn__select_throw_exn(kk_std_core_exn__exn hnd, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : exn<e,b>) -> hnd/clause1<exception,a,exn,e,b> */ 
  {
    struct kk_std_core_exn__Hnd_exn* _con_x107 = kk_std_core_exn__as_Hnd_exn(hnd, _ctx);
    kk_std_core_hnd__clause1 _brk_throw_exn = _con_x107->_brk_throw_exn;
    return kk_std_core_hnd__clause1_dup(_brk_throw_exn, _ctx);
  }
}
 
// Use default value `def` in case of an error.

static inline kk_box_t kk_std_core_exn_default(kk_std_core_exn__error t, kk_box_t def, kk_context_t* _ctx) { /* forall<a> (t : error<a>, def : a) -> a */ 
  if (kk_std_core_exn__is_Error(t, _ctx)) {
    kk_std_core_exn__exception _pat_0 = t._cons.Error.exception;
    kk_std_core_exn__error_drop(t, _ctx);
    return def;
  }
  {
    kk_box_t x = t._cons.Ok.result;
    kk_box_drop(def, _ctx);
    return x;
  }
}

kk_std_core_types__either kk_std_core_exn_either(kk_std_core_exn__error t, kk_context_t* _ctx); /* forall<a> (t : error<a>) -> either<exception,a> */ 
 
// Transform an `:error` type to a `:maybe` value.

static inline kk_std_core_types__maybe kk_std_core_exn_maybe(kk_std_core_exn__error t, kk_context_t* _ctx) { /* forall<a> (t : error<a>) -> maybe<a> */ 
  if (kk_std_core_exn__is_Error(t, _ctx)) {
    kk_std_core_exn__exception _pat_0 = t._cons.Error.exception;
    kk_std_core_exn__error_drop(t, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
  {
    kk_box_t x = t._cons.Ok.result;
    return kk_std_core_types__new_Just(x, _ctx);
  }
}
 
// Set a `hndler` that is always called when the `action` finishes (either normally or with an exception).

static inline kk_box_t kk_std_core_exn_on_exit(kk_function_t hndler, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (hndler : () -> e (), action : () -> e a) -> e a */ 
  kk_box_t _x_x108 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx); /*518*/
  return kk_std_core_hnd_finally_prompt(hndler, _x_x108, _ctx);
}
 
// Show the exception message

static inline kk_string_t kk_std_core_exn_show(kk_std_core_exn__exception exn_0, kk_context_t* _ctx) { /* (exn : exception) -> string */ 
  {
    kk_string_t _x = exn_0.message;
    kk_string_dup(_x, _ctx);
    kk_std_core_exn__exception_drop(exn_0, _ctx);
    return _x;
  }
}
 
// Throw an exception
// Call the `final ctl throw-exn` operation of the effect `:exn`

static inline kk_box_t kk_std_core_exn_throw_exn(kk_std_core_exn__exception exn_0, kk_context_t* _ctx) { /* forall<a> (exn : exception) -> exn a */ 
  kk_std_core_hnd__ev ev_10032 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<exn>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x109 = kk_std_core_hnd__as_Ev(ev_10032, _ctx);
    kk_box_t _box_x12 = _con_x109->hnd;
    int32_t m = _con_x109->marker;
    kk_std_core_exn__exn h = kk_std_core_exn__exn_unbox(_box_x12, KK_BORROWED, _ctx);
    kk_std_core_exn__exn_dup(h, _ctx);
    {
      struct kk_std_core_exn__Hnd_exn* _con_x110 = kk_std_core_exn__as_Hnd_exn(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x110->_cfc;
      kk_std_core_hnd__clause1 _brk_throw_exn = _con_x110->_brk_throw_exn;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_brk_throw_exn, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x16 = _brk_throw_exn.clause;
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x16, (_fun_unbox_x16, m, ev_10032, kk_std_core_exn__exception_box(exn_0, _ctx), _ctx), _ctx);
      }
    }
  }
}

kk_box_t kk_std_core_exn_exn_fs_try(kk_function_t action, kk_function_t hndl, kk_context_t* _ctx); /* forall<a,e> (action : () -> <exn|e> a, hndl : (exception) -> e a) -> e a */ 
 
// monadic lift

static inline kk_std_core_exn__error kk_std_core_exn__mlift_try_10028(kk_box_t _y_x10019, kk_context_t* _ctx) { /* forall<a,e> (a) -> <exn|e> error<a> */ 
  return kk_std_core_exn__new_Ok(_y_x10019, _ctx);
}

kk_std_core_exn__error kk_std_core_exn_try(kk_function_t action, kk_context_t* _ctx); /* forall<a,e> (action : () -> <exn|e> a) -> e error<a> */ 

kk_box_t kk_std_core_exn_catch(kk_function_t action, kk_function_t hndl, kk_context_t* _ctx); /* forall<a,e> (action : () -> <exn|e> a, hndl : (exception) -> e a) -> e a */ 

kk_box_t kk_std_core_exn_throw(kk_string_t message, kk_std_core_types__optional info, kk_context_t* _ctx); /* forall<a> (message : string, info : ? exception-info) -> exn a */ 

kk_box_t kk_std_core_exn_error_pattern(kk_string_t location, kk_string_t definition, kk_context_t* _ctx); /* forall<a> (location : string, definition : string) -> exn a */ 

kk_box_t kk_std_core_exn_untry(kk_std_core_exn__error err, kk_context_t* _ctx); /* forall<a> (err : error<a>) -> exn a */ 
 
// Transform an `:error` type back to an `exn` effect.

static inline kk_box_t kk_std_core_exn_exn(kk_std_core_exn__error err, kk_context_t* _ctx) { /* forall<a> (err : error<a>) -> exn a */ 
  return kk_std_core_exn_untry(err, _ctx);
}

kk_box_t kk_std_core_exn_exn_error_range(kk_context_t* _ctx); /* forall<a> () -> exn a */ 

void kk_std_core_exn__init(kk_context_t* _ctx);


void kk_std_core_exn__done(kk_context_t* _ctx);

#endif // header
