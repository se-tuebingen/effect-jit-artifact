// Koka generated module: std/core/string, koka version: 3.1.2, platform: 64-bit
#include "std_core_string.h"
/*---------------------------------------------------------------------------
  Copyright 2020-2024, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

kk_std_core_types__list kk_string_to_list(kk_string_t s, kk_context_t* ctx) {
  kk_ssize_t len;
  const uint8_t* p = kk_string_buf_borrow(s,&len,ctx);
  const uint8_t* const end = p + len;
  kk_std_core_types__list nil  = kk_std_core_types__new_Nil(ctx);
  kk_std_core_types__list list = nil;
  struct kk_std_core_types_Cons* tl = NULL;
  kk_ssize_t count;
  while( p < end ) {
    kk_char_t c = kk_utf8_read(p,&count);
    p += count;
    kk_std_core_types__list cons = kk_std_core_types__new_Cons(kk_reuse_null,0,kk_char_box(c,ctx), nil, ctx);
    if (tl!=NULL) {
      tl->tail = cons;
    }
    else {
      list = cons;
    }
    tl = kk_std_core_types__as_Cons(cons,ctx);
  }
  kk_string_drop(s,ctx);
  return list;
}

kk_string_t kk_string_from_list(kk_std_core_types__list cs, kk_context_t* ctx) {
  // TODO: optimize for short strings to write directly into a local buffer?
  // find total UTF8 length
  kk_ssize_t len = 0;
  kk_std_core_types__list xs = cs;
  while (kk_std_core_types__is_Cons(xs,ctx)) {
    struct kk_std_core_types_Cons* cons = kk_std_core_types__as_Cons(xs,ctx);
    len += kk_utf8_len(kk_char_unbox(cons->head,KK_BORROWED,ctx));
    xs = cons->tail;
  }
  // allocate and copy the characters
  uint8_t* p;
  kk_string_t s = kk_unsafe_string_alloc_buf(len,&p,ctx);  // must be initialized
  xs = cs;
  while (kk_std_core_types__is_Cons(xs,ctx)) {
    struct kk_std_core_types_Cons* cons = kk_std_core_types__as_Cons(xs,ctx);
    kk_ssize_t count;
    kk_utf8_write( kk_char_unbox(cons->head,KK_BORROWED,ctx), p, &count );
    p += count;
    xs = cons->tail;
  }
  kk_assert_internal(*p == 0 && (p - kk_string_buf_borrow(s,NULL,ctx)) == len);
  kk_std_core_types__list_drop(cs,ctx);  // todo: drop while visiting?
  return s;
}


kk_integer_t kk_std_core_string_string_cmp(kk_string_t x, kk_string_t y, kk_context_t* _ctx) { /* (x : string, y : string) -> int */ 
  return kk_string_cmp_int_borrow(x,y,kk_context());
}
 
// O(n). Return the number of characters in a string.

kk_integer_t kk_std_core_string_count(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> int */ 
  return kk_string_count_int(s,kk_context());
}
 
// Convert a string to a list of characters

kk_std_core_types__list kk_std_core_string_list(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> list<char> */ 
  return kk_string_to_list(s,kk_context());
}

kk_string_t kk_std_core_string_repeatz(kk_string_t s, kk_ssize_t n, kk_context_t* _ctx) { /* (s : string, n : ssize_t) -> string */ 
  return kk_string_repeat(s,n,kk_context());
}
 
// Convert a character to a string

kk_string_t kk_std_core_string_char_fs_string(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> string */ 
  return kk_string_from_char(c,kk_context());
}
 
// Convert a list of characters to a string

kk_string_t kk_std_core_string_listchar_fs_string(kk_std_core_types__list cs, kk_context_t* _ctx) { /* (cs : list<char>) -> string */ 
  return kk_string_from_list(cs,kk_context());
}
 
// Convert a vector of characters to a string.

kk_string_t kk_std_core_string_vector_fs_string(kk_vector_t _arg_x1, kk_context_t* _ctx) { /* (vector<char>) -> string */ 
  return kk_string_from_chars(_arg_x1,kk_context());
}
 
// Convert a string to lower-case

kk_string_t kk_std_core_string_to_lower(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> string */ 
  return kk_string_to_lower(s,kk_context());
}
 
// Convert a string to upper-case

kk_string_t kk_std_core_string_to_upper(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> string */ 
  return kk_string_to_upper(s,kk_context());
}
 
// Convert a string to a vector of characters.

kk_vector_t kk_std_core_string_vector(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> vector<char> */ 
  return kk_string_to_chars(s,kk_context());
}
 
// Compare two strings.
// Uses the character codes directly for comparison

kk_std_core_types__order kk_std_core_string_cmp(kk_string_t x, kk_string_t y, kk_context_t* _ctx) { /* (x : string, y : string) -> order */ 
  kk_integer_t i_10000 = kk_std_core_string_string_cmp(x, y, _ctx); /*int*/;
  bool _match_x18 = kk_integer_lt_borrow(i_10000,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x18) {
    kk_integer_drop(i_10000, _ctx);
    return kk_std_core_types__new_Lt(_ctx);
  }
  {
    bool _match_x19;
    bool _brw_x20 = kk_integer_gt_borrow(i_10000,(kk_integer_from_small(0)),kk_context()); /*bool*/;
    kk_integer_drop(i_10000, _ctx);
    _match_x19 = _brw_x20; /*bool*/
    if (_match_x19) {
      return kk_std_core_types__new_Gt(_ctx);
    }
    {
      return kk_std_core_types__new_Eq(_ctx);
    }
  }
}
 
// Transform a string to a maybe type, using `Nothing` for an empty string

kk_std_core_types__maybe kk_std_core_string_maybe(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> maybe<string> */ 
  bool _match_x17;
  kk_string_t _x_x31 = kk_string_dup(s, _ctx); /*string*/
  kk_string_t _x_x32 = kk_string_empty(); /*string*/
  _match_x17 = kk_string_is_eq(_x_x31,_x_x32,kk_context()); /*bool*/
  if (_match_x17) {
    kk_string_drop(s, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
  {
    return kk_std_core_types__new_Just(kk_string_box(s), _ctx);
  }
}

kk_std_core_types__tuple2 kk_std_core_string_order2(kk_string_t x, kk_string_t y, kk_context_t* _ctx) { /* (x : string, y : string) -> (string, string) */ 
  bool _match_x16;
  kk_std_core_types__order _x_x34 = kk_std_core_string_cmp(x, y, _ctx); /*order*/
  _match_x16 = kk_std_core_order__lp__lt__rp_(_x_x34, kk_std_core_types__new_Gt(_ctx), _ctx); /*bool*/
  if (_match_x16) {
    return kk_std_core_types__new_Tuple2(kk_string_box(x), kk_string_box(y), _ctx);
  }
  {
    return kk_std_core_types__new_Tuple2(kk_string_box(y), kk_string_box(x), _ctx);
  }
}
 
// Right-align a string to width `width`  using `fill`  (default is a space) to fill from the left.

kk_string_t kk_std_core_string_pad_left(kk_string_t s, kk_integer_t width, kk_std_core_types__optional fill, kk_context_t* _ctx) { /* (s : string, width : int, fill : ? char) -> string */ 
  kk_integer_t n;
  kk_string_t _x_x37 = kk_string_dup(s, _ctx); /*string*/
  n = kk_std_core_string_count(_x_x37, _ctx); /*int*/
  bool _match_x15 = kk_integer_lte_borrow(width,n,kk_context()); /*bool*/;
  if (_match_x15) {
    kk_integer_drop(n, _ctx);
    kk_std_core_types__optional_drop(fill, _ctx);
    return s;
  }
  {
    kk_string_t s_0_10004;
    kk_char_t _x_x38;
    if (kk_std_core_types__is_Optional(fill, _ctx)) {
      kk_box_t _box_x11 = fill._cons._Optional.value;
      kk_char_t _uniq_fill_332 = kk_char_unbox(_box_x11, KK_BORROWED, _ctx);
      kk_std_core_types__optional_drop(fill, _ctx);
      _x_x38 = _uniq_fill_332; /*char*/
    }
    else {
      kk_std_core_types__optional_drop(fill, _ctx);
      _x_x38 = ' '; /*char*/
    }
    s_0_10004 = kk_std_core_string_char_fs_string(_x_x38, _ctx); /*string*/
    kk_integer_t n_0_10005;
    kk_integer_t _x_x39 = kk_integer_dup(width, _ctx); /*int*/
    n_0_10005 = kk_integer_sub(_x_x39,n,kk_context()); /*int*/
    kk_string_t _x_x40 = kk_std_core_string_repeatz(s_0_10004, kk_std_core_int_ssize__t(n_0_10005, _ctx), _ctx); /*string*/
    return kk_std_core_types__lp__plus__plus__rp_(_x_x40, s, _ctx);
  }
}
 
// Left-align a string to width `width`  using `fill`  (default is a space) to fill on the right.

kk_string_t kk_std_core_string_pad_right(kk_string_t s, kk_integer_t width, kk_std_core_types__optional fill, kk_context_t* _ctx) { /* (s : string, width : int, fill : ? char) -> string */ 
  kk_integer_t n;
  kk_string_t _x_x41 = kk_string_dup(s, _ctx); /*string*/
  n = kk_std_core_string_count(_x_x41, _ctx); /*int*/
  bool _match_x14 = kk_integer_lte_borrow(width,n,kk_context()); /*bool*/;
  if (_match_x14) {
    kk_integer_drop(n, _ctx);
    kk_std_core_types__optional_drop(fill, _ctx);
    return s;
  }
  {
    kk_string_t s_0_10008;
    kk_char_t _x_x42;
    if (kk_std_core_types__is_Optional(fill, _ctx)) {
      kk_box_t _box_x12 = fill._cons._Optional.value;
      kk_char_t _uniq_fill_378 = kk_char_unbox(_box_x12, KK_BORROWED, _ctx);
      kk_std_core_types__optional_drop(fill, _ctx);
      _x_x42 = _uniq_fill_378; /*char*/
    }
    else {
      kk_std_core_types__optional_drop(fill, _ctx);
      _x_x42 = ' '; /*char*/
    }
    s_0_10008 = kk_std_core_string_char_fs_string(_x_x42, _ctx); /*string*/
    kk_integer_t n_0_10009;
    kk_integer_t _x_x43 = kk_integer_dup(width, _ctx); /*int*/
    n_0_10009 = kk_integer_sub(_x_x43,n,kk_context()); /*int*/
    kk_string_t _x_x44 = kk_std_core_string_repeatz(s_0_10008, kk_std_core_int_ssize__t(n_0_10009, _ctx), _ctx); /*string*/
    return kk_std_core_types__lp__plus__plus__rp_(s, _x_x44, _ctx);
  }
}

// initialization
void kk_std_core_string__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_hnd__init(_ctx);
  kk_std_core_int__init(_ctx);
  kk_std_core_order__init(_ctx);
  kk_std_core_vector__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_string__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_vector__done(_ctx);
  kk_std_core_order__done(_ctx);
  kk_std_core_int__done(_ctx);
  kk_std_core_hnd__done(_ctx);
  kk_std_core_types__done(_ctx);
}
