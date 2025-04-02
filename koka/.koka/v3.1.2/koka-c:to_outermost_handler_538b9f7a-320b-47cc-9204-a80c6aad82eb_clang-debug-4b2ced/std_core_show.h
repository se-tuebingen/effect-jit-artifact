#pragma once
#ifndef kk_std_core_show_H
#define kk_std_core_show_H
// Koka generated module: std/core/show, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_hnd.h"
#include "std_core_int.h"
#include "std_core_char.h"
#include "std_core_string.h"
#include "std_core_sslice.h"
#include "std_core_list.h"

// type declarations

// value declarations

kk_string_t kk_std_core_show_gshow(kk_box_t _arg_x1, kk_context_t* _ctx); /* forall<a> (a) -> string */ 

kk_string_t kk_std_core_show_int_show_hex(kk_integer_t i, bool use_capitals, kk_context_t* _ctx); /* (i : int, use-capitals : bool) -> string */ 

kk_string_t kk_std_core_show_show_hex(kk_integer_t i, kk_std_core_types__optional width, kk_std_core_types__optional use_capitals, kk_std_core_types__optional pre, kk_context_t* _ctx); /* (i : int, width : ? int, use-capitals : ? bool, pre : ? string) -> string */ 

kk_string_t kk_std_core_show_show_char(kk_char_t c, kk_context_t* _ctx); /* (c : char) -> string */ 
 
// Show a `:char` as a character literal

static inline kk_string_t kk_std_core_show_char_fs_show(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> string */ 
  kk_string_t _x_x120;
  kk_define_string_literal(, _s_x121, 1, "\'", _ctx)
  _x_x120 = kk_string_dup(_s_x121, _ctx); /*string*/
  kk_string_t _x_x122;
  kk_string_t _x_x123 = kk_std_core_show_show_char(c, _ctx); /*string*/
  kk_string_t _x_x124;
  kk_define_string_literal(, _s_x125, 1, "\'", _ctx)
  _x_x124 = kk_string_dup(_s_x125, _ctx); /*string*/
  _x_x122 = kk_std_core_types__lp__plus__plus__rp_(_x_x123, _x_x124, _ctx); /*string*/
  return kk_std_core_types__lp__plus__plus__rp_(_x_x120, _x_x122, _ctx);
}

kk_string_t kk_std_core_show_string_fs_show(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> string */ 
 
// Show an `:sslice` as a string literal

static inline kk_string_t kk_std_core_show_sslice_fs_show(kk_std_core_sslice__sslice s, kk_context_t* _ctx) { /* (s : sslice/sslice) -> string */ 
  kk_string_t _x_x139 = kk_std_core_sslice_string(s, _ctx); /*string*/
  return kk_std_core_show_string_fs_show(_x_x139, _ctx);
}

void kk_std_core_show__init(kk_context_t* _ctx);


void kk_std_core_show__done(kk_context_t* _ctx);

#endif // header
