#pragma once
#ifndef kk_std_core_string_H
#define kk_std_core_string_H
// Koka generated module: std/core/string, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_hnd.h"
#include "std_core_int.h"
#include "std_core_order.h"
#include "std_core_vector.h"
/*---------------------------------------------------------------------------
  Copyright 2020-2024, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

struct kk_std_core_string_Sslice;

kk_datatype_t kk_string_to_list(kk_string_t s, kk_context_t* ctx);
kk_string_t   kk_string_from_list(kk_datatype_t cs, kk_context_t* ctx);

static inline kk_integer_t  kk_string_count_int(kk_string_t s, kk_context_t* ctx) {
  return kk_integer_from_ssize_t( kk_string_count(s,ctx), ctx );
}

static inline kk_integer_t kk_string_cmp_int_borrow(kk_string_t s1, kk_string_t s2, kk_context_t* ctx) {
  return kk_integer_from_small( kk_string_cmp_borrow(s1,s2,ctx) );
}

kk_string_t  kk_string_join(kk_vector_t v, kk_context_t* ctx);
kk_string_t  kk_string_join_with(kk_vector_t v, kk_string_t sep, kk_context_t* ctx);
kk_string_t  kk_string_replace_all(kk_string_t str, kk_string_t pattern, kk_string_t repl, kk_context_t* ctx);

static inline kk_integer_t kk_string_count_pattern(kk_string_t str, kk_string_t pattern, kk_context_t* ctx) {
  kk_integer_t count = kk_integer_from_ssize_t( kk_string_count_pattern_borrow(str,pattern,ctx), ctx );
  kk_string_drop(str,ctx);
  kk_string_drop(pattern,ctx);
  return count;
}


// type declarations

// value declarations

kk_integer_t kk_std_core_string_string_cmp(kk_string_t x, kk_string_t y, kk_context_t* _ctx); /* (x : string, y : string) -> int */ 

kk_integer_t kk_std_core_string_count(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> int */ 
 
// Is a string empty?

static inline bool kk_std_core_string_is_empty(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> bool */ 
  kk_string_t _x_x21 = kk_string_empty(); /*string*/
  return kk_string_is_eq(s,_x_x21,kk_context());
}
 
// Is a string not empty?

static inline bool kk_std_core_string_is_notempty(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> bool */ 
  kk_string_t _x_x23 = kk_string_empty(); /*string*/
  return kk_string_is_neq(s,_x_x23,kk_context());
}

kk_std_core_types__list kk_std_core_string_list(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> list<char> */ 

kk_string_t kk_std_core_string_repeatz(kk_string_t s, kk_ssize_t n, kk_context_t* _ctx); /* (s : string, n : ssize_t) -> string */ 

kk_string_t kk_std_core_string_char_fs_string(kk_char_t c, kk_context_t* _ctx); /* (c : char) -> string */ 

kk_string_t kk_std_core_string_listchar_fs_string(kk_std_core_types__list cs, kk_context_t* _ctx); /* (cs : list<char>) -> string */ 
 
// Convert a `:maybe` string to a string using the empty sting for `Nothing`

static inline kk_string_t kk_std_core_string_maybe_fs_string(kk_std_core_types__maybe ms, kk_context_t* _ctx) { /* (ms : maybe<string>) -> string */ 
  if (kk_std_core_types__is_Nothing(ms, _ctx)) {
    return kk_string_empty();
  }
  {
    kk_box_t _box_x0 = ms._cons.Just.value;
    kk_string_t s = kk_string_unbox(_box_x0);
    kk_string_dup(s, _ctx);
    kk_std_core_types__maybe_drop(ms, _ctx);
    return s;
  }
}

kk_string_t kk_std_core_string_vector_fs_string(kk_vector_t _arg_x1, kk_context_t* _ctx); /* (vector<char>) -> string */ 

kk_string_t kk_std_core_string_to_lower(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> string */ 

kk_string_t kk_std_core_string_to_upper(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> string */ 
 
// Trim whitespace on the left and right side of a string

static inline kk_string_t kk_std_core_string_trim(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> string */ 
  kk_string_t _x_x26 = kk_string_trim_left(s,kk_context()); /*string*/
  return kk_string_trim_right(_x_x26,kk_context());
}

kk_vector_t kk_std_core_string_vector(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> vector<char> */ 

kk_std_core_types__order kk_std_core_string_cmp(kk_string_t x, kk_string_t y, kk_context_t* _ctx); /* (x : string, y : string) -> order */ 

static inline bool kk_std_core_string__lp__lt__rp_(kk_string_t x, kk_string_t y, kk_context_t* _ctx) { /* (x : string, y : string) -> bool */ 
  kk_std_core_types__order _x_x27 = kk_std_core_string_cmp(x, y, _ctx); /*order*/
  return kk_std_core_order__lp__eq__eq__rp_(_x_x27, kk_std_core_types__new_Lt(_ctx), _ctx);
}

static inline bool kk_std_core_string__lp__lt__eq__rp_(kk_string_t x, kk_string_t y, kk_context_t* _ctx) { /* (x : string, y : string) -> bool */ 
  kk_std_core_types__order _x_x28 = kk_std_core_string_cmp(x, y, _ctx); /*order*/
  return kk_std_core_order__lp__lt__rp_(_x_x28, kk_std_core_types__new_Gt(_ctx), _ctx);
}

static inline bool kk_std_core_string__lp__gt__rp_(kk_string_t x, kk_string_t y, kk_context_t* _ctx) { /* (x : string, y : string) -> bool */ 
  kk_std_core_types__order _x_x29 = kk_std_core_string_cmp(x, y, _ctx); /*order*/
  return kk_std_core_order__lp__eq__eq__rp_(_x_x29, kk_std_core_types__new_Gt(_ctx), _ctx);
}

static inline bool kk_std_core_string__lp__gt__eq__rp_(kk_string_t x, kk_string_t y, kk_context_t* _ctx) { /* (x : string, y : string) -> bool */ 
  kk_std_core_types__order _x_x30 = kk_std_core_string_cmp(x, y, _ctx); /*order*/
  return kk_std_core_order__lp__gt__rp_(_x_x30, kk_std_core_types__new_Lt(_ctx), _ctx);
}

kk_std_core_types__maybe kk_std_core_string_maybe(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> maybe<string> */ 

kk_std_core_types__tuple2 kk_std_core_string_order2(kk_string_t x, kk_string_t y, kk_context_t* _ctx); /* (x : string, y : string) -> (string, string) */ 
 
// Repeat a string `n` times

static inline kk_string_t kk_std_core_string_repeat(kk_string_t s, kk_integer_t n, kk_context_t* _ctx) { /* (s : string, n : int) -> string */ 
  kk_ssize_t _x_x35;
  kk_integer_t _x_x36 = kk_integer_dup(n, _ctx); /*int*/
  _x_x35 = kk_std_core_int_ssize__t(_x_x36, _ctx); /*ssize_t*/
  return kk_std_core_string_repeatz(s, _x_x35, _ctx);
}

kk_string_t kk_std_core_string_pad_left(kk_string_t s, kk_integer_t width, kk_std_core_types__optional fill, kk_context_t* _ctx); /* (s : string, width : int, fill : ? char) -> string */ 

kk_string_t kk_std_core_string_pad_right(kk_string_t s, kk_integer_t width, kk_std_core_types__optional fill, kk_context_t* _ctx); /* (s : string, width : int, fill : ? char) -> string */ 
 
// Split a string into parts that were delimited by `sep`. The delimeters are not included in the results.
// For example: `split("1,,2",",") == ["1","","2"]`

static inline kk_std_core_types__list kk_std_core_string_split(kk_string_t s, kk_string_t sep, kk_context_t* _ctx) { /* (s : string, sep : string) -> list<string> */ 
  kk_vector_t v_10012 = kk_string_splitv(s,sep,kk_context()); /*vector<string>*/;
  return kk_std_core_vector_vlist(v_10012, kk_std_core_types__new_None(_ctx), _ctx);
}
 
// Choose a non-empty string

static inline kk_string_t kk_std_core_string__lp__bar__bar__rp_(kk_string_t x, kk_string_t y, kk_context_t* _ctx) { /* (x : string, y : string) -> string */ 
  bool _match_x13;
  kk_string_t _x_x45 = kk_string_dup(x, _ctx); /*string*/
  kk_string_t _x_x46 = kk_string_empty(); /*string*/
  _match_x13 = kk_string_is_eq(_x_x45,_x_x46,kk_context()); /*bool*/
  if (_match_x13) {
    kk_string_drop(x, _ctx);
    return y;
  }
  {
    kk_string_drop(y, _ctx);
    return x;
  }
}
 
// Split a string into at most `n` parts that were delimited by a string `sep`. The delimeters are not included in the results (except for possibly the final part).
// For example: `split("1,2,3",",",2) == ["1","2,3"]`

static inline kk_std_core_types__list kk_std_core_string_splitn_fs_split(kk_string_t s, kk_string_t sep, kk_integer_t n, kk_context_t* _ctx) { /* (s : string, sep : string, n : int) -> list<string> */ 
  kk_vector_t v_10014;
  kk_ssize_t _x_x48;
  kk_integer_t _x_x49 = kk_integer_dup(n, _ctx); /*int*/
  _x_x48 = kk_std_core_int_ssize__t(_x_x49, _ctx); /*ssize_t*/
  v_10014 = kk_string_splitv_atmost(s,sep,_x_x48,kk_context()); /*vector<string>*/
  return kk_std_core_vector_vlist(v_10014, kk_std_core_types__new_None(_ctx), _ctx);
}

void kk_std_core_string__init(kk_context_t* _ctx);


void kk_std_core_string__done(kk_context_t* _ctx);

#endif // header
