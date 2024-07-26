#pragma once
#ifndef kk_std_core_char_H
#define kk_std_core_char_H
// Koka generated module: std/core/char, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_int.h"

// type declarations

// value declarations
 
// Compare character code points.

static inline kk_std_core_types__order kk_std_core_char_cmp(kk_char_t x, kk_char_t y, kk_context_t* _ctx) { /* (x : char, y : char) -> order */ 
  bool _match_x34 = (x < y); /*bool*/;
  if (_match_x34) {
    return kk_std_core_types__new_Lt(_ctx);
  }
  {
    bool _match_x35 = (x > y); /*bool*/;
    if (_match_x35) {
      return kk_std_core_types__new_Gt(_ctx);
    }
    {
      return kk_std_core_types__new_Eq(_ctx);
    }
  }
}
 
// Is the character a lower-case ASCII character?

static inline bool kk_std_core_char_is_lower(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> bool */ 
  bool _match_x33 = (c >= ('a')); /*bool*/;
  if (_match_x33) {
    return (c <= ('z'));
  }
  {
    return false;
  }
}
 
// Is the character an upper-case ASCII character?

static inline bool kk_std_core_char_is_upper(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> bool */ 
  bool _match_x32 = (c >= ('A')); /*bool*/;
  if (_match_x32) {
    return (c <= ('Z'));
  }
  {
    return false;
  }
}
 
// Is the character an ASCII digit ?

static inline bool kk_std_core_char_is_digit(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> bool */ 
  bool _match_x31 = (c >= ('0')); /*bool*/;
  if (_match_x31) {
    return (c <= ('9'));
  }
  {
    return false;
  }
}
 
// Is the character an ASCII character, e.g. `c <= '\x7F'`?

static inline bool kk_std_core_char_is_ascii(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> bool */ 
  return (c <= 0x007F);
}
 
// Is the character an ASCII control character, e.g. `c < ' '`?

static inline bool kk_std_core_char_is_control(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> bool */ 
  return (c < (' '));
}

bool kk_std_core_char_is_white(kk_char_t c, kk_context_t* _ctx); /* (c : char) -> bool */ 

kk_std_core_types__order2 kk_std_core_char_order2(kk_char_t x, kk_char_t y, kk_context_t* _ctx); /* (x : char, y : char) -> order2<char> */ 
 
// Add two character code points

static inline kk_char_t kk_std_core_char__lp__plus__rp_(kk_char_t c, kk_char_t d, kk_context_t* _ctx) { /* (c : char, d : char) -> char */ 
  kk_integer_t x_10000 = kk_integer_from_int(c,kk_context()); /*int*/;
  kk_integer_t y_10001 = kk_integer_from_int(d,kk_context()); /*int*/;
  kk_integer_t _x_x36 = kk_integer_add(x_10000,y_10001,kk_context()); /*int*/
  return kk_integer_clamp32(_x_x36,kk_context());
}
 
// Subtract two character code points

static inline kk_char_t kk_std_core_char__lp__dash__rp_(kk_char_t c, kk_char_t d, kk_context_t* _ctx) { /* (c : char, d : char) -> char */ 
  kk_integer_t x_10002 = kk_integer_from_int(c,kk_context()); /*int*/;
  kk_integer_t y_10003 = kk_integer_from_int(d,kk_context()); /*int*/;
  kk_integer_t _x_x37 = kk_integer_sub(x_10002,y_10003,kk_context()); /*int*/
  return kk_integer_clamp32(_x_x37,kk_context());
}

bool kk_std_core_char_is_alpha(kk_char_t c, kk_context_t* _ctx); /* (c : char) -> bool */ 
 
// Is the character ASCII letter or digit?

static inline bool kk_std_core_char_is_alpha_num(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> bool */ 
  bool _match_x20 = kk_std_core_char_is_alpha(c, _ctx); /*bool*/;
  if (_match_x20) {
    return true;
  }
  {
    bool _match_x21 = (c >= ('0')); /*bool*/;
    if (_match_x21) {
      return (c <= ('9'));
    }
    {
      return false;
    }
  }
}

bool kk_std_core_char_is_hex_digit(kk_char_t c, kk_context_t* _ctx); /* (c : char) -> bool */ 

void kk_std_core_char__init(kk_context_t* _ctx);


void kk_std_core_char__done(kk_context_t* _ctx);

#endif // header
