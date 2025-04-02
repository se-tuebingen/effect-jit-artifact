// Koka generated module: std/num/int32, koka version: 3.1.2, platform: 64-bit
#include "std_num_int32.h"
/*---------------------------------------------------------------------------
  Copyright 2020-2023, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

static kk_std_core_types__tuple2 kk_wide_umul32x( int32_t x, int32_t y, kk_context_t* ctx ) {
  uint32_t hi;
  uint32_t lo = kk_wide_umul32((uint32_t)x, (uint32_t)y, &hi);
  return kk_std_core_types__new_Tuple2( kk_int32_box((int32_t)lo,ctx), kk_int32_box((int32_t)hi,ctx), ctx );
}

static kk_std_core_types__tuple2 kk_wide_imul32x( int32_t x, int32_t y, kk_context_t* ctx ) {
  int32_t hi;
  uint32_t lo = kk_wide_imul32(x, y, &hi);
  return kk_std_core_types__new_Tuple2( kk_int32_box((int32_t)lo,ctx), kk_int32_box(hi,ctx), ctx );
}

 
// Full 32x32 bit signed multiply to `(hi,lo)`.
// where `(hi,lo).int == hi.int * 0x1_0000_0000 + lo.uint`

kk_std_core_types__tuple2 kk_std_num_int32_imul(int32_t i, int32_t j, kk_context_t* _ctx) { /* (i : int32, j : int32) -> (int32, int32) */ 
  return kk_wide_imul32x(i,j,kk_context());
}
 
// Full 32x32 bit unsigned multiply to `(hi,lo)`.
// where `(hi,lo).uint == hi.uint * 0x1_0000_0000 + lo.uint`

kk_std_core_types__tuple2 kk_std_num_int32_umul(int32_t i, int32_t j, kk_context_t* _ctx) { /* (i : int32, j : int32) -> (int32, int32) */ 
  return kk_wide_umul32x(i,j,kk_context());
}
 
// The 32-bit integer with value 1.

int32_t kk_std_num_int32_one;
 
// The zero 32-bit integer.

int32_t kk_std_num_int32_zero;
 
// The minimal integer value before underflow happens

int32_t kk_std_num_int32_min_int32;
 
// Euclidean-0 modulus. See `(/):(x : int32, y : int32) -> int32` division for more information.

int32_t kk_std_num_int32__lp__perc__rp_(int32_t x, int32_t y, kk_context_t* _ctx) { /* (x : int32, y : int32) -> int32 */ 
  bool _match_x153 = (y == ((KK_I32(0)))); /*bool*/;
  if (_match_x153) {
    return x;
  }
  {
    bool _match_x154 = (y == ((KK_I32(-1)))); /*bool*/;
    if (_match_x154) {
      bool _match_x157 = (x == kk_std_num_int32_min_int32); /*bool*/;
      if (_match_x157) {
        return (KK_I32(0));
      }
      {
        int32_t r = (x % y); /*int32*/;
        bool _match_x158 = (r >= ((KK_I32(0)))); /*bool*/;
        if (_match_x158) {
          return r;
        }
        {
          bool _match_x159 = (y > ((KK_I32(0)))); /*bool*/;
          if (_match_x159) {
            return (int32_t)((uint32_t)r + (uint32_t)y);
          }
          {
            return (int32_t)((uint32_t)r - (uint32_t)y);
          }
        }
      }
    }
    {
      int32_t r_0 = (x % y); /*int32*/;
      bool _match_x155 = (r_0 >= ((KK_I32(0)))); /*bool*/;
      if (_match_x155) {
        return r_0;
      }
      {
        bool _match_x156 = (y > ((KK_I32(0)))); /*bool*/;
        if (_match_x156) {
          return (int32_t)((uint32_t)r_0 + (uint32_t)y);
        }
        {
          return (int32_t)((uint32_t)r_0 - (uint32_t)y);
        }
      }
    }
  }
}
 
/*
Euclidean-0 division.
Euclidean division is defined as: For any `D`  and `d`  where `d!=0` , we have:
1. `D == d*(D/d) + (D%d)`
2. `D%d`  is always positive where `0 <= D%d < abs(d)`
Moreover, Euclidean-0 is a total function, for the case where `d==0`  we have
that `D%0 == D`  and `D/0 == 0` . So property (1) still holds, but not property (2).
Useful laws that hold for Euclidean-0 division:
* `D/(-d) == -(D/d)`
* `D%(-d) == D%d`
* `D/(2^n) == sar(D,n)         `  (with `0 <= n <= 31`)
* `D%(2^n) == D & ((2^n) - 1)  `  (with `0 <= n <= 31`)
Note that an interesting edge case is `min-int32 / -1` which equals `min-int32` since in modulo 32-bit
arithmetic `min-int32 == -1 * min-int32 == -1 * (min-int32 / -1) + (min-int32 % -1)` satisfying property (1).
Of course `(min-int32 + 1) / -1` is again positive (namely `max-int32`).
See also _Division and modulus for computer scientists, Daan Leijen, 2001_
[pdf](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf) .
*/

int32_t kk_std_num_int32__lp__fs__rp_(int32_t x, int32_t y, kk_context_t* _ctx) { /* (x : int32, y : int32) -> int32 */ 
  bool _match_x146 = (y == ((KK_I32(0)))); /*bool*/;
  if (_match_x146) {
    return (KK_I32(0));
  }
  {
    bool _match_x147 = (y == ((KK_I32(-1)))); /*bool*/;
    if (_match_x147) {
      bool _match_x150 = (x == kk_std_num_int32_min_int32); /*bool*/;
      if (_match_x150) {
        return x;
      }
      {
        int32_t q = (x / y); /*int32*/;
        int32_t r = (x % y); /*int32*/;
        bool _match_x151 = (r >= ((KK_I32(0)))); /*bool*/;
        if (_match_x151) {
          return q;
        }
        {
          bool _match_x152 = (y > ((KK_I32(0)))); /*bool*/;
          if (_match_x152) {
            return (int32_t)((uint32_t)q - (uint32_t)((KK_I32(1))));
          }
          {
            return (int32_t)((uint32_t)q + (uint32_t)((KK_I32(1))));
          }
        }
      }
    }
    {
      int32_t q_0 = (x / y); /*int32*/;
      int32_t r_0 = (x % y); /*int32*/;
      bool _match_x148 = (r_0 >= ((KK_I32(0)))); /*bool*/;
      if (_match_x148) {
        return q_0;
      }
      {
        bool _match_x149 = (y > ((KK_I32(0)))); /*bool*/;
        if (_match_x149) {
          return (int32_t)((uint32_t)q_0 - (uint32_t)((KK_I32(1))));
        }
        {
          return (int32_t)((uint32_t)q_0 + (uint32_t)((KK_I32(1))));
        }
      }
    }
  }
}
 
// Return the absolute value of an integer.
// Raises an exception if the `:int32` is `min-int32`
// (since the negation of `min-int32` equals itself and is still negative)


// lift anonymous function
struct kk_std_num_int32_abs_fun169__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_num_int32_abs_fun169(kk_function_t _fself, kk_box_t _b_x2, kk_context_t* _ctx);
static kk_function_t kk_std_num_int32_new_abs_fun169(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_num_int32_abs_fun169, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_num_int32_abs_fun169(kk_function_t _fself, kk_box_t _b_x2, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x170;
  bool b_9 = kk_bool_unbox(_b_x2); /*bool*/;
  if (b_9) {
    _x_x170 = false; /*bool*/
  }
  else {
    _x_x170 = true; /*bool*/
  }
  return kk_bool_box(_x_x170);
}

int32_t kk_std_num_int32_abs(int32_t i, kk_context_t* _ctx) { /* (i : int32) -> exn int32 */ 
  bool _x_x1_10070 = 0 > i; /*bool*/;
  bool _match_x144;
  kk_box_t _x_x168 = kk_std_core_hnd__open_none1(kk_std_num_int32_new_abs_fun169(_ctx), kk_bool_box(_x_x1_10070), _ctx); /*1001*/
  _match_x144 = kk_bool_unbox(_x_x168); /*bool*/
  if (_match_x144) {
    return i;
  }
  {
    bool _match_x145 = (i > kk_std_num_int32_min_int32); /*bool*/;
    if (_match_x145) {
      return (int32_t)((uint32_t)((KK_I32(0))) - (uint32_t)i);
    }
    {
      kk_box_t _x_x171;
      kk_string_t _x_x172;
      kk_define_string_literal(, _s_x173, 79, "std/num/int32/abs: cannot make min-int32 into a positive int32 without overflow", _ctx)
      _x_x172 = kk_string_dup(_s_x173, _ctx); /*string*/
      _x_x171 = kk_std_core_exn_throw(_x_x172, kk_std_core_types__new_None(_ctx), _ctx); /*1000*/
      return kk_int32_unbox(_x_x171, KK_OWNED, _ctx);
    }
  }
}
 
// Return the absolute value of an integer.
// Returns 0 if the `:int32` is `min-int32`
// (since the negation of `min-int32` equals itself and is still negative)

int32_t kk_std_num_int32_abs0(int32_t i, kk_context_t* _ctx) { /* (i : int32) -> int32 */ 
  bool b_10000 = 0 > i; /*bool*/;
  if (b_10000) {
    bool _match_x143 = (i > kk_std_num_int32_min_int32); /*bool*/;
    if (_match_x143) {
      return (int32_t)((uint32_t)((KK_I32(0))) - (uint32_t)i);
    }
    {
      return (KK_I32(0));
    }
  }
  {
    return i;
  }
}
 
// The number of bits in an `:int32` (always 32)

int32_t kk_std_num_int32_bits_int32;
 
// Truncated division (as in C). See also `(/):(x : int32, y : int32) -> int32`.

int32_t kk_std_num_int32_cdiv(int32_t i, int32_t j, kk_context_t* _ctx) { /* (i : int32, j : int32) -> exn int32 */ 
  bool _match_x140 = 0 == j; /*bool*/;
  if (_match_x140) {
    kk_box_t _x_x174;
    kk_string_t _x_x175;
    kk_define_string_literal(, _s_x176, 35, "std/num/int32/cdiv: modulus by zero", _ctx)
    _x_x175 = kk_string_dup(_s_x176, _ctx); /*string*/
    _x_x174 = kk_std_core_exn_throw(_x_x175, kk_std_core_types__new_None(_ctx), _ctx); /*1000*/
    return kk_int32_unbox(_x_x174, KK_OWNED, _ctx);
  }
  {
    bool _match_x141 = (j == ((KK_I32(-1)))); /*bool*/;
    if (_match_x141) {
      bool _match_x142 = (i == kk_std_num_int32_min_int32); /*bool*/;
      if (_match_x142) {
        kk_box_t _x_x177;
        kk_string_t _x_x178;
        kk_define_string_literal(, _s_x179, 65, "std/num/int32/cdiv: modulus overflow in cdiv(min-int32, -1.int32)", _ctx)
        _x_x178 = kk_string_dup(_s_x179, _ctx); /*string*/
        _x_x177 = kk_std_core_exn_throw(_x_x178, kk_std_core_types__new_None(_ctx), _ctx); /*1000*/
        return kk_int32_unbox(_x_x177, KK_OWNED, _ctx);
      }
      {
        return (i / j);
      }
    }
    {
      return (i / j);
    }
  }
}
 
// Truncated modulus (as in C). See also `(%):(x : int32, y : int32) -> int32`.

int32_t kk_std_num_int32_cmod(int32_t i, int32_t j, kk_context_t* _ctx) { /* (i : int32, j : int32) -> exn int32 */ 
  bool _match_x137 = 0 == j; /*bool*/;
  if (_match_x137) {
    kk_box_t _x_x180;
    kk_string_t _x_x181;
    kk_define_string_literal(, _s_x182, 35, "std/num/int32/cmod: modulus by zero", _ctx)
    _x_x181 = kk_string_dup(_s_x182, _ctx); /*string*/
    _x_x180 = kk_std_core_exn_throw(_x_x181, kk_std_core_types__new_None(_ctx), _ctx); /*1000*/
    return kk_int32_unbox(_x_x180, KK_OWNED, _ctx);
  }
  {
    bool _match_x138 = (j == ((KK_I32(-1)))); /*bool*/;
    if (_match_x138) {
      bool _match_x139 = (i == kk_std_num_int32_min_int32); /*bool*/;
      if (_match_x139) {
        kk_box_t _x_x183;
        kk_string_t _x_x184;
        kk_define_string_literal(, _s_x185, 65, "std/num/int32/cmod: modulus overflow in cmod(min-int32, -1.int32)", _ctx)
        _x_x184 = kk_string_dup(_s_x185, _ctx); /*string*/
        _x_x183 = kk_std_core_exn_throw(_x_x184, kk_std_core_types__new_None(_ctx), _ctx); /*1000*/
        return kk_int32_unbox(_x_x183, KK_OWNED, _ctx);
      }
      {
        return (i % j);
      }
    }
    {
      return (i % j);
    }
  }
}

kk_std_core_types__tuple2 kk_std_num_int32_divmod(int32_t x, int32_t y, kk_context_t* _ctx) { /* (x : int32, y : int32) -> (int32, int32) */ 
  bool _match_x132 = 0 == y; /*bool*/;
  if (_match_x132) {
    return kk_std_core_types__new_Tuple2(kk_int32_box(kk_std_num_int32_zero, _ctx), kk_int32_box(x, _ctx), _ctx);
  }
  {
    bool _match_x133 = (y == ((KK_I32(-1)))); /*bool*/;
    if (_match_x133) {
      bool _match_x135 = (x == kk_std_num_int32_min_int32); /*bool*/;
      if (_match_x135) {
        int32_t _b_x29_45 = (KK_I32(0)); /*int32*/;
        return kk_std_core_types__new_Tuple2(kk_int32_box(x, _ctx), kk_int32_box(_b_x29_45, _ctx), _ctx);
      }
      {
        int32_t q = (x / y); /*int32*/;
        int32_t r = (x % y); /*int32*/;
        bool b_10002 = 0 > r; /*bool*/;
        if (b_10002) {
          bool _match_x136 = 0 < y; /*bool*/;
          if (_match_x136) {
            int32_t _b_x30_46 = (int32_t)((uint32_t)q - (uint32_t)((KK_I32(1)))); /*int32*/;
            int32_t _b_x31_47 = (int32_t)((uint32_t)r + (uint32_t)y); /*int32*/;
            return kk_std_core_types__new_Tuple2(kk_int32_box(_b_x30_46, _ctx), kk_int32_box(_b_x31_47, _ctx), _ctx);
          }
          {
            int32_t _b_x32_48 = (int32_t)((uint32_t)q + (uint32_t)((KK_I32(1)))); /*int32*/;
            int32_t _b_x33_49 = (int32_t)((uint32_t)r - (uint32_t)y); /*int32*/;
            return kk_std_core_types__new_Tuple2(kk_int32_box(_b_x32_48, _ctx), kk_int32_box(_b_x33_49, _ctx), _ctx);
          }
        }
        {
          return kk_std_core_types__new_Tuple2(kk_int32_box(q, _ctx), kk_int32_box(r, _ctx), _ctx);
        }
      }
    }
    {
      int32_t q_0 = (x / y); /*int32*/;
      int32_t r_0 = (x % y); /*int32*/;
      bool b_0_10005 = 0 > r_0; /*bool*/;
      if (b_0_10005) {
        bool _match_x134 = 0 < y; /*bool*/;
        if (_match_x134) {
          int32_t _b_x36_52 = (int32_t)((uint32_t)q_0 - (uint32_t)((KK_I32(1)))); /*int32*/;
          int32_t _b_x37_53 = (int32_t)((uint32_t)r_0 + (uint32_t)y); /*int32*/;
          return kk_std_core_types__new_Tuple2(kk_int32_box(_b_x36_52, _ctx), kk_int32_box(_b_x37_53, _ctx), _ctx);
        }
        {
          int32_t _b_x38_54 = (int32_t)((uint32_t)q_0 + (uint32_t)((KK_I32(1)))); /*int32*/;
          int32_t _b_x39_55 = (int32_t)((uint32_t)r_0 - (uint32_t)y); /*int32*/;
          return kk_std_core_types__new_Tuple2(kk_int32_box(_b_x38_54, _ctx), kk_int32_box(_b_x39_55, _ctx), _ctx);
        }
      }
      {
        return kk_std_core_types__new_Tuple2(kk_int32_box(q_0, _ctx), kk_int32_box(r_0, _ctx), _ctx);
      }
    }
  }
}
 
// monadic lift

kk_box_t kk_std_num_int32_range_fs__mlift_fold_int32_10071(int32_t end, kk_function_t f, int32_t start, kk_box_t x, kk_context_t* _ctx) { /* forall<a,e> (end : int32, f : (int32, a) -> e a, start : int32, x : a) -> e a */ 
  int32_t _own_x130 = (int32_t)((uint32_t)start + (uint32_t)((KK_I32(1)))); /*int32*/;
  kk_box_t _brw_x131 = kk_std_num_int32_range_fs_fold_int32(_own_x130, end, x, f, _ctx); /*80*/;
  kk_function_drop(f, _ctx);
  return _brw_x131;
}
 
// Fold over the range `[start,end]` (including `end`).


// lift anonymous function
struct kk_std_num_int32_range_fs_fold_int32_fun188__t {
  struct kk_function_s _base;
  kk_function_t f_0;
  int32_t end_0;
  int32_t start_0;
};
static kk_box_t kk_std_num_int32_range_fs_fold_int32_fun188(kk_function_t _fself, kk_box_t x_1, kk_context_t* _ctx);
static kk_function_t kk_std_num_int32_range_fs_new_fold_int32_fun188(kk_function_t f_0, int32_t end_0, int32_t start_0, kk_context_t* _ctx) {
  struct kk_std_num_int32_range_fs_fold_int32_fun188__t* _self = kk_function_alloc_as(struct kk_std_num_int32_range_fs_fold_int32_fun188__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_num_int32_range_fs_fold_int32_fun188, kk_context());
  _self->f_0 = f_0;
  _self->end_0 = end_0;
  _self->start_0 = start_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_num_int32_range_fs_fold_int32_fun188(kk_function_t _fself, kk_box_t x_1, kk_context_t* _ctx) {
  struct kk_std_num_int32_range_fs_fold_int32_fun188__t* _self = kk_function_as(struct kk_std_num_int32_range_fs_fold_int32_fun188__t*, _fself, _ctx);
  kk_function_t f_0 = _self->f_0; /* (int32, 1422) -> 1423 1422 */
  int32_t end_0 = _self->end_0; /* int32 */
  int32_t start_0 = _self->start_0; /* int32 */
  kk_drop_match(_self, {kk_function_dup(f_0, _ctx);kk_skip_dup(end_0, _ctx);kk_skip_dup(start_0, _ctx);}, {}, _ctx)
  return kk_std_num_int32_range_fs__mlift_fold_int32_10071(end_0, f_0, start_0, x_1, _ctx);
}

kk_box_t kk_std_num_int32_range_fs_fold_int32(int32_t start_0, int32_t end_0, kk_box_t init, kk_function_t f_0, kk_context_t* _ctx) { /* forall<a,e> (start : int32, end : int32, init : a, f : (int32, a) -> e a) -> e a */ 
  kk__tailcall: ;
  bool _match_x127 = (start_0 > end_0); /*bool*/;
  if (_match_x127) {
    return init;
  }
  {
    kk_box_t x_0_10075;
    kk_function_t _x_x186 = kk_function_dup(f_0, _ctx); /*(int32, 1422) -> 1423 1422*/
    x_0_10075 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_box_t, kk_context_t*), _x_x186, (_x_x186, start_0, init, _ctx), _ctx); /*1422*/
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_0_10075, _ctx);
      kk_function_t _x_x187;
      kk_function_dup(f_0, _ctx);
      _x_x187 = kk_std_num_int32_range_fs_new_fold_int32_fun188(f_0, end_0, start_0, _ctx); /*(x@1 : 1422) -> 1423 1422*/
      return kk_std_core_hnd_yield_extend(_x_x187, _ctx);
    }
    {
      int32_t _own_x129 = (int32_t)((uint32_t)start_0 + (uint32_t)((KK_I32(1)))); /*int32*/;
      { // tailcall
        start_0 = _own_x129;
        init = x_0_10075;
        goto kk__tailcall;
      }
    }
  }
}
 
// monadic lift

kk_box_t kk_std_num_int32_range_fs__mlift_fold_while_int32_10072(int32_t end, kk_function_t f, kk_box_t init, int32_t start, kk_std_core_types__maybe _y_x10044, kk_context_t* _ctx) { /* forall<a,e> (end : int32, f : (int32, a) -> e maybe<a>, init : a, start : int32, maybe<a>) -> e a */ 
  if (kk_std_core_types__is_Just(_y_x10044, _ctx)) {
    kk_box_t x = _y_x10044._cons.Just.value;
    kk_box_drop(init, _ctx);
    int32_t _x_x189 = (int32_t)((uint32_t)start + (uint32_t)((KK_I32(1)))); /*int32*/
    return kk_std_num_int32_range_fs_fold_while_int32(_x_x189, end, x, f, _ctx);
  }
  {
    kk_function_drop(f, _ctx);
    return init;
  }
}
 
// Iterate over the range `[start,end]` (including `end`).


// lift anonymous function
struct kk_std_num_int32_range_fs_fold_while_int32_fun192__t {
  struct kk_function_s _base;
  kk_function_t f_0;
  kk_box_t init_0;
  int32_t end_0;
  int32_t start_0;
};
static kk_box_t kk_std_num_int32_range_fs_fold_while_int32_fun192(kk_function_t _fself, kk_box_t _b_x59, kk_context_t* _ctx);
static kk_function_t kk_std_num_int32_range_fs_new_fold_while_int32_fun192(kk_function_t f_0, kk_box_t init_0, int32_t end_0, int32_t start_0, kk_context_t* _ctx) {
  struct kk_std_num_int32_range_fs_fold_while_int32_fun192__t* _self = kk_function_alloc_as(struct kk_std_num_int32_range_fs_fold_while_int32_fun192__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_num_int32_range_fs_fold_while_int32_fun192, kk_context());
  _self->f_0 = f_0;
  _self->init_0 = init_0;
  _self->end_0 = end_0;
  _self->start_0 = start_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_num_int32_range_fs_fold_while_int32_fun192(kk_function_t _fself, kk_box_t _b_x59, kk_context_t* _ctx) {
  struct kk_std_num_int32_range_fs_fold_while_int32_fun192__t* _self = kk_function_as(struct kk_std_num_int32_range_fs_fold_while_int32_fun192__t*, _fself, _ctx);
  kk_function_t f_0 = _self->f_0; /* (int32, 1519) -> 1520 maybe<1519> */
  kk_box_t init_0 = _self->init_0; /* 1519 */
  int32_t end_0 = _self->end_0; /* int32 */
  int32_t start_0 = _self->start_0; /* int32 */
  kk_drop_match(_self, {kk_function_dup(f_0, _ctx);kk_box_dup(init_0, _ctx);kk_skip_dup(end_0, _ctx);kk_skip_dup(start_0, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _x_x193 = kk_std_core_types__maybe_unbox(_b_x59, KK_OWNED, _ctx); /*maybe<1519>*/
  return kk_std_num_int32_range_fs__mlift_fold_while_int32_10072(end_0, f_0, init_0, start_0, _x_x193, _ctx);
}

kk_box_t kk_std_num_int32_range_fs_fold_while_int32(int32_t start_0, int32_t end_0, kk_box_t init_0, kk_function_t f_0, kk_context_t* _ctx) { /* forall<a,e> (start : int32, end : int32, init : a, f : (int32, a) -> e maybe<a>) -> e a */ 
  kk__tailcall: ;
  bool _match_x124 = (start_0 > end_0); /*bool*/;
  if (_match_x124) {
    kk_function_drop(f_0, _ctx);
    return init_0;
  }
  {
    kk_std_core_types__maybe x_0_10078;
    kk_function_t _x_x191 = kk_function_dup(f_0, _ctx); /*(int32, 1519) -> 1520 maybe<1519>*/
    kk_box_t _x_x190 = kk_box_dup(init_0, _ctx); /*1519*/
    x_0_10078 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, int32_t, kk_box_t, kk_context_t*), _x_x191, (_x_x191, start_0, _x_x190, _ctx), _ctx); /*maybe<1519>*/
    if (kk_yielding(kk_context())) {
      kk_std_core_types__maybe_drop(x_0_10078, _ctx);
      return kk_std_core_hnd_yield_extend(kk_std_num_int32_range_fs_new_fold_while_int32_fun192(f_0, init_0, end_0, start_0, _ctx), _ctx);
    }
    if (kk_std_core_types__is_Just(x_0_10078, _ctx)) {
      kk_box_t x_1 = x_0_10078._cons.Just.value;
      kk_box_drop(init_0, _ctx);
      { // tailcall
        int32_t _x_x194 = (int32_t)((uint32_t)start_0 + (uint32_t)((KK_I32(1)))); /*int32*/
        start_0 = _x_x194;
        init_0 = x_1;
        goto kk__tailcall;
      }
    }
    {
      kk_function_drop(f_0, _ctx);
      return init_0;
    }
  }
}
 
// monadic lift

kk_std_core_types__maybe kk_std_num_int32_range_fs__mlift_lift_for_while32_2275_10073(kk_function_t action, int32_t end, int32_t i, kk_std_core_types__maybe _y_x10049, kk_context_t* _ctx) { /* forall<a,e> (action : (int32) -> e maybe<a>, end : int32, i : int32, maybe<a>) -> e maybe<a> */ 
  if (kk_std_core_types__is_Nothing(_y_x10049, _ctx)) {
    int32_t i_0_10008 = (int32_t)((uint32_t)i + (uint32_t)((KK_I32(1)))); /*int32*/;
    return kk_std_num_int32_range_fs__lift_for_while32_2275(action, end, i_0_10008, _ctx);
  }
  {
    kk_box_t x = _y_x10049._cons.Just.value;
    kk_function_drop(action, _ctx);
    return kk_std_core_types__new_Just(x, _ctx);
  }
}
 
// lifted local: range/for-while32, rep


// lift anonymous function
struct kk_std_num_int32_range_fs__lift_for_while32_2275_fun198__t {
  struct kk_function_s _base;
  kk_function_t action_0;
  int32_t end_0;
  int32_t i_0;
};
static kk_box_t kk_std_num_int32_range_fs__lift_for_while32_2275_fun198(kk_function_t _fself, kk_box_t _b_x63, kk_context_t* _ctx);
static kk_function_t kk_std_num_int32_range_fs__new_lift_for_while32_2275_fun198(kk_function_t action_0, int32_t end_0, int32_t i_0, kk_context_t* _ctx) {
  struct kk_std_num_int32_range_fs__lift_for_while32_2275_fun198__t* _self = kk_function_alloc_as(struct kk_std_num_int32_range_fs__lift_for_while32_2275_fun198__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_num_int32_range_fs__lift_for_while32_2275_fun198, kk_context());
  _self->action_0 = action_0;
  _self->end_0 = end_0;
  _self->i_0 = i_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_num_int32_range_fs__lift_for_while32_2275_fun198(kk_function_t _fself, kk_box_t _b_x63, kk_context_t* _ctx) {
  struct kk_std_num_int32_range_fs__lift_for_while32_2275_fun198__t* _self = kk_function_as(struct kk_std_num_int32_range_fs__lift_for_while32_2275_fun198__t*, _fself, _ctx);
  kk_function_t action_0 = _self->action_0; /* (int32) -> 1595 maybe<1594> */
  int32_t end_0 = _self->end_0; /* int32 */
  int32_t i_0 = _self->i_0; /* int32 */
  kk_drop_match(_self, {kk_function_dup(action_0, _ctx);kk_skip_dup(end_0, _ctx);kk_skip_dup(i_0, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _y_x10049_0_65 = kk_std_core_types__maybe_unbox(_b_x63, KK_OWNED, _ctx); /*maybe<1594>*/;
  kk_std_core_types__maybe _x_x199 = kk_std_num_int32_range_fs__mlift_lift_for_while32_2275_10073(action_0, end_0, i_0, _y_x10049_0_65, _ctx); /*maybe<1594>*/
  return kk_std_core_types__maybe_box(_x_x199, _ctx);
}

kk_std_core_types__maybe kk_std_num_int32_range_fs__lift_for_while32_2275(kk_function_t action_0, int32_t end_0, int32_t i_0, kk_context_t* _ctx) { /* forall<a,e> (action : (int32) -> e maybe<a>, end : int32, i : int32) -> e maybe<a> */ 
  kk__tailcall: ;
  bool _match_x122 = (i_0 <= end_0); /*bool*/;
  if (_match_x122) {
    kk_std_core_types__maybe x_0_10081;
    kk_function_t _x_x196 = kk_function_dup(action_0, _ctx); /*(int32) -> 1595 maybe<1594>*/
    x_0_10081 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, int32_t, kk_context_t*), _x_x196, (_x_x196, i_0, _ctx), _ctx); /*maybe<1594>*/
    if (kk_yielding(kk_context())) {
      kk_std_core_types__maybe_drop(x_0_10081, _ctx);
      kk_box_t _x_x197 = kk_std_core_hnd_yield_extend(kk_std_num_int32_range_fs__new_lift_for_while32_2275_fun198(action_0, end_0, i_0, _ctx), _ctx); /*3596*/
      return kk_std_core_types__maybe_unbox(_x_x197, KK_OWNED, _ctx);
    }
    if (kk_std_core_types__is_Nothing(x_0_10081, _ctx)) {
      int32_t i_0_10008_0 = (int32_t)((uint32_t)i_0 + (uint32_t)((KK_I32(1)))); /*int32*/;
      { // tailcall
        i_0 = i_0_10008_0;
        goto kk__tailcall;
      }
    }
    {
      kk_box_t x_1 = x_0_10081._cons.Just.value;
      kk_function_drop(action_0, _ctx);
      return kk_std_core_types__new_Just(x_1, _ctx);
    }
  }
  {
    kk_function_drop(action_0, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}
 
// monadic lift

kk_unit_t kk_std_num_int32_range_fs__mlift_lift_for32_2276_10074(kk_function_t action, int32_t end, int32_t i, kk_unit_t wild__, kk_context_t* _ctx) { /* forall<e> (action : (int32) -> e (), end : int32, i : int32, wild_ : ()) -> e () */ 
  int32_t i_0_10012 = (int32_t)((uint32_t)i + (uint32_t)((KK_I32(1)))); /*int32*/;
  kk_std_num_int32_range_fs__lift_for32_2276(action, end, i_0_10012, _ctx); return kk_Unit;
}
 
// lifted local: range/for32, rep


// lift anonymous function
struct kk_std_num_int32_range_fs__lift_for32_2276_fun202__t {
  struct kk_function_s _base;
  kk_function_t action_0;
  int32_t end_0;
  int32_t i_0;
};
static kk_box_t kk_std_num_int32_range_fs__lift_for32_2276_fun202(kk_function_t _fself, kk_box_t _b_x67, kk_context_t* _ctx);
static kk_function_t kk_std_num_int32_range_fs__new_lift_for32_2276_fun202(kk_function_t action_0, int32_t end_0, int32_t i_0, kk_context_t* _ctx) {
  struct kk_std_num_int32_range_fs__lift_for32_2276_fun202__t* _self = kk_function_alloc_as(struct kk_std_num_int32_range_fs__lift_for32_2276_fun202__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_num_int32_range_fs__lift_for32_2276_fun202, kk_context());
  _self->action_0 = action_0;
  _self->end_0 = end_0;
  _self->i_0 = i_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_num_int32_range_fs__lift_for32_2276_fun202(kk_function_t _fself, kk_box_t _b_x67, kk_context_t* _ctx) {
  struct kk_std_num_int32_range_fs__lift_for32_2276_fun202__t* _self = kk_function_as(struct kk_std_num_int32_range_fs__lift_for32_2276_fun202__t*, _fself, _ctx);
  kk_function_t action_0 = _self->action_0; /* (int32) -> 1673 () */
  int32_t end_0 = _self->end_0; /* int32 */
  int32_t i_0 = _self->i_0; /* int32 */
  kk_drop_match(_self, {kk_function_dup(action_0, _ctx);kk_skip_dup(end_0, _ctx);kk_skip_dup(i_0, _ctx);}, {}, _ctx)
  kk_unit_t wild___0_69 = kk_Unit;
  kk_unit_unbox(_b_x67);
  kk_unit_t _x_x203 = kk_Unit;
  kk_std_num_int32_range_fs__mlift_lift_for32_2276_10074(action_0, end_0, i_0, wild___0_69, _ctx);
  return kk_unit_box(_x_x203);
}

kk_unit_t kk_std_num_int32_range_fs__lift_for32_2276(kk_function_t action_0, int32_t end_0, int32_t i_0, kk_context_t* _ctx) { /* forall<e> (action : (int32) -> e (), end : int32, i : int32) -> e () */ 
  kk__tailcall: ;
  bool _match_x120 = (i_0 <= end_0); /*bool*/;
  if (_match_x120) {
    kk_unit_t x_10084 = kk_Unit;
    kk_function_t _x_x200 = kk_function_dup(action_0, _ctx); /*(int32) -> 1673 ()*/
    kk_function_call(kk_unit_t, (kk_function_t, int32_t, kk_context_t*), _x_x200, (_x_x200, i_0, _ctx), _ctx);
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x201 = kk_std_core_hnd_yield_extend(kk_std_num_int32_range_fs__new_lift_for32_2276_fun202(action_0, end_0, i_0, _ctx), _ctx); /*3674*/
      kk_unit_unbox(_x_x201); return kk_Unit;
    }
    {
      int32_t i_0_10012_0 = (int32_t)((uint32_t)i_0 + (uint32_t)((KK_I32(1)))); /*int32*/;
      { // tailcall
        i_0 = i_0_10012_0;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_function_drop(action_0, _ctx);
    kk_Unit; return kk_Unit;
  }
}
 
// Create a list with 32-bit integer elements from `lo` to `hi` (including `hi`).

kk_std_core_types__list kk_std_num_int32__trmc_list32(int32_t lo_0, int32_t hi_0, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* (lo : int32, hi : int32, ctx<list<int32>>) -> list<int32> */ 
  kk__tailcall: ;
  bool _match_x119 = (lo_0 <= hi_0); /*bool*/;
  if (_match_x119) {
    kk_std_core_types__list _trmc_x10025 = kk_datatype_null(); /*list<int32>*/;
    kk_std_core_types__list _trmc_x10026 = kk_std_core_types__new_Cons(kk_reuse_null, 0, kk_int32_box(lo_0, _ctx), _trmc_x10025, _ctx); /*list<int32>*/;
    kk_field_addr_t _b_x79_84 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10026, _ctx)->tail, _ctx); /*@field-addr<list<int32>>*/;
    { // tailcall
      int32_t _x_x206 = (int32_t)((uint32_t)lo_0 + (uint32_t)((KK_I32(1)))); /*int32*/
      kk_std_core_types__cctx _x_x207 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10026, _ctx)),_b_x79_84,kk_context()); /*ctx<0>*/
      lo_0 = _x_x206;
      _acc = _x_x207;
      goto kk__tailcall;
    }
  }
  {
    kk_box_t _x_x208 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x208, KK_OWNED, _ctx);
  }
}
 
// Create a list with 32-bit integer elements from `lo` to `hi` (including `hi`).

kk_std_core_types__list kk_std_num_int32_list32(int32_t lo_0_0, int32_t hi_0_0, kk_context_t* _ctx) { /* (lo : int32, hi : int32) -> list<int32> */ 
  kk_std_core_types__cctx _x_x209 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_num_int32__trmc_list32(lo_0_0, hi_0_0, _x_x209, _ctx);
}
 
// The maximal integer value before overflow happens

int32_t kk_std_num_int32_max_int32;
 
// Show an `:int32` in hexadecimal notation
// The `width`  parameter specifies how wide the hex value is where `'0'`  is used to align.
// The `use-capitals` parameter (= `True`) determines if captical letters should be used to display the hexadecimal digits.
// The `pre` (=`"0x"`) is an optional prefix for the number (goes between the sign and the number).

kk_string_t kk_std_num_int32_show_hex(int32_t i, kk_std_core_types__optional width, kk_std_core_types__optional use_capitals, kk_std_core_types__optional pre, kk_context_t* _ctx) { /* (i : int32, width : ? int, use-capitals : ? bool, pre : ? string) -> string */ 
  kk_integer_t _x_x213 = kk_integer_from_int(i,kk_context()); /*int*/
  kk_std_core_types__optional _x_x214;
  kk_box_t _x_x215;
  kk_integer_t _x_x216;
  if (kk_std_core_types__is_Optional(width, _ctx)) {
    kk_box_t _box_x94 = width._cons._Optional.value;
    kk_integer_t _uniq_width_2084 = kk_integer_unbox(_box_x94, _ctx);
    kk_integer_dup(_uniq_width_2084, _ctx);
    kk_std_core_types__optional_drop(width, _ctx);
    _x_x216 = _uniq_width_2084; /*int*/
  }
  else {
    kk_std_core_types__optional_drop(width, _ctx);
    _x_x216 = kk_integer_from_small(1); /*int*/
  }
  _x_x215 = kk_integer_box(_x_x216, _ctx); /*4126*/
  _x_x214 = kk_std_core_types__new_Optional(_x_x215, _ctx); /*? 4126*/
  kk_std_core_types__optional _x_x217;
  kk_box_t _x_x218;
  bool _x_x219;
  if (kk_std_core_types__is_Optional(use_capitals, _ctx)) {
    kk_box_t _box_x96 = use_capitals._cons._Optional.value;
    bool _uniq_use_capitals_2088 = kk_bool_unbox(_box_x96);
    kk_std_core_types__optional_drop(use_capitals, _ctx);
    _x_x219 = _uniq_use_capitals_2088; /*bool*/
  }
  else {
    kk_std_core_types__optional_drop(use_capitals, _ctx);
    _x_x219 = true; /*bool*/
  }
  _x_x218 = kk_bool_box(_x_x219); /*4126*/
  _x_x217 = kk_std_core_types__new_Optional(_x_x218, _ctx); /*? 4126*/
  kk_std_core_types__optional _x_x220;
  kk_box_t _x_x221;
  kk_string_t _x_x222;
  if (kk_std_core_types__is_Optional(pre, _ctx)) {
    kk_box_t _box_x98 = pre._cons._Optional.value;
    kk_string_t _uniq_pre_2092 = kk_string_unbox(_box_x98);
    kk_string_dup(_uniq_pre_2092, _ctx);
    kk_std_core_types__optional_drop(pre, _ctx);
    _x_x222 = _uniq_pre_2092; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(pre, _ctx);
    kk_define_string_literal(, _s_x223, 2, "0x", _ctx)
    _x_x222 = kk_string_dup(_s_x223, _ctx); /*string*/
  }
  _x_x221 = kk_string_box(_x_x222); /*4126*/
  _x_x220 = kk_std_core_types__new_Optional(_x_x221, _ctx); /*? 4126*/
  return kk_std_core_show_show_hex(_x_x213, _x_x214, _x_x217, _x_x220, _ctx);
}
 
// Show an `:int32` in hexadecimal notation interpreted as an unsigned 32-bit value.
// The `width`  parameter specifies how wide the hex value is where `'0'`  is used to align.
// The `use-capitals` parameter (= `True`) determines if captical letters should be used to display the hexadecimal digits.
// The `pre` (=`"0x"`) is an optional prefix for the number.

kk_string_t kk_std_num_int32_show_hex32(int32_t i, kk_std_core_types__optional width, kk_std_core_types__optional use_capitals, kk_std_core_types__optional pre, kk_context_t* _ctx) { /* (i : int32, width : ? int, use-capitals : ? bool, pre : ? string) -> string */ 
  kk_integer_t _x_x224 = kk_std_num_int32_uint(i, _ctx); /*int*/
  kk_std_core_types__optional _x_x225;
  kk_box_t _x_x226;
  kk_integer_t _x_x227;
  if (kk_std_core_types__is_Optional(width, _ctx)) {
    kk_box_t _box_x103 = width._cons._Optional.value;
    kk_integer_t _uniq_width_2131 = kk_integer_unbox(_box_x103, _ctx);
    kk_integer_dup(_uniq_width_2131, _ctx);
    kk_std_core_types__optional_drop(width, _ctx);
    _x_x227 = _uniq_width_2131; /*int*/
  }
  else {
    kk_std_core_types__optional_drop(width, _ctx);
    _x_x227 = kk_integer_from_small(8); /*int*/
  }
  _x_x226 = kk_integer_box(_x_x227, _ctx); /*4171*/
  _x_x225 = kk_std_core_types__new_Optional(_x_x226, _ctx); /*? 4171*/
  kk_std_core_types__optional _x_x228;
  kk_box_t _x_x229;
  bool _x_x230;
  if (kk_std_core_types__is_Optional(use_capitals, _ctx)) {
    kk_box_t _box_x105 = use_capitals._cons._Optional.value;
    bool _uniq_use_capitals_2135 = kk_bool_unbox(_box_x105);
    kk_std_core_types__optional_drop(use_capitals, _ctx);
    _x_x230 = _uniq_use_capitals_2135; /*bool*/
  }
  else {
    kk_std_core_types__optional_drop(use_capitals, _ctx);
    _x_x230 = true; /*bool*/
  }
  _x_x229 = kk_bool_box(_x_x230); /*4171*/
  _x_x228 = kk_std_core_types__new_Optional(_x_x229, _ctx); /*? 4171*/
  kk_std_core_types__optional _x_x231;
  kk_box_t _x_x232;
  kk_string_t _x_x233;
  if (kk_std_core_types__is_Optional(pre, _ctx)) {
    kk_box_t _box_x107 = pre._cons._Optional.value;
    kk_string_t _uniq_pre_2139 = kk_string_unbox(_box_x107);
    kk_string_dup(_uniq_pre_2139, _ctx);
    kk_std_core_types__optional_drop(pre, _ctx);
    _x_x233 = _uniq_pre_2139; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(pre, _ctx);
    kk_define_string_literal(, _s_x234, 2, "0x", _ctx)
    _x_x233 = kk_string_dup(_s_x234, _ctx); /*string*/
  }
  _x_x232 = kk_string_box(_x_x233); /*4171*/
  _x_x231 = kk_std_core_types__new_Optional(_x_x232, _ctx); /*? 4171*/
  return kk_std_core_show_show_hex(_x_x224, _x_x225, _x_x228, _x_x231, _ctx);
}

int32_t kk_std_num_int32_sumacc32(kk_std_core_types__list xs, int32_t acc, kk_context_t* _ctx) { /* (xs : list<int32>, acc : int32) -> int32 */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x235 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x112 = _con_x235->head;
    kk_std_core_types__list xx = _con_x235->tail;
    int32_t x = kk_int32_unbox(_box_x112, KK_BORROWED, _ctx);
    int32_t _own_x117 = (int32_t)((uint32_t)acc + (uint32_t)x); /*int32*/;
    { // tailcall
      xs = xx;
      acc = _own_x117;
      goto kk__tailcall;
    }
  }
  {
    return acc;
  }
}
 
// Convert an `:int` to `:int32` but interpret the `int` as an unsigned 32-bit value.
// `i` is clamped between `0` and `0xFFFFFFFF`.
// `0x7FFF_FFFF.uint32 == 0x7FFF_FFFF.int32 == max-int32`
// `0x8000_0000.uint32 == -0x8000_0000.int32 == min-int32`
// `0xFFFF_FFFF.uint32 == -1.int32`

int32_t kk_std_num_int32_uint32(kk_integer_t i, kk_context_t* _ctx) { /* (i : int) -> int32 */ 
  kk_integer_t _x_x236;
  bool _match_x113;
  kk_integer_t _brw_x114 = kk_integer_from_int(kk_std_num_int32_max_int32,kk_context()); /*int*/;
  bool _brw_x115 = kk_integer_gt_borrow(i,_brw_x114,kk_context()); /*bool*/;
  kk_integer_drop(_brw_x114, _ctx);
  _match_x113 = _brw_x115; /*bool*/
  if (_match_x113) {
    _x_x236 = kk_integer_sub(i,(kk_integer_from_str("4294967296", _ctx)),kk_context()); /*int*/
  }
  else {
    _x_x236 = i; /*int*/
  }
  return kk_integer_clamp32(_x_x236,kk_context());
}

// initialization
void kk_std_num_int32__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_hnd__init(_ctx);
  kk_std_core_exn__init(_ctx);
  kk_std_core_bool__init(_ctx);
  kk_std_core_order__init(_ctx);
  kk_std_core_char__init(_ctx);
  kk_std_core_int__init(_ctx);
  kk_std_core_vector__init(_ctx);
  kk_std_core_string__init(_ctx);
  kk_std_core_sslice__init(_ctx);
  kk_std_core_list__init(_ctx);
  kk_std_core_maybe__init(_ctx);
  kk_std_core_either__init(_ctx);
  kk_std_core_tuple__init(_ctx);
  kk_std_core_show__init(_ctx);
  kk_std_core_debug__init(_ctx);
  kk_std_core_delayed__init(_ctx);
  kk_std_core_console__init(_ctx);
  kk_std_core__init(_ctx);
  kk_std_core_undiv__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
  {
    kk_std_num_int32_one = (KK_I32(1)); /*int32*/
  }
  {
    kk_std_num_int32_zero = (KK_I32(0)); /*int32*/
  }
  {
    kk_std_num_int32_min_int32 = (INT32_MIN); /*int32*/
  }
  {
    kk_std_num_int32_bits_int32 = (KK_I32(32)); /*int32*/
  }
  {
    kk_std_num_int32_max_int32 = (KK_I32(2147483647)); /*int32*/
  }
}

// termination
void kk_std_num_int32__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_skip_drop(kk_std_num_int32_max_int32, _ctx);
  kk_skip_drop(kk_std_num_int32_bits_int32, _ctx);
  kk_skip_drop(kk_std_num_int32_min_int32, _ctx);
  kk_skip_drop(kk_std_num_int32_zero, _ctx);
  kk_skip_drop(kk_std_num_int32_one, _ctx);
  kk_std_core_undiv__done(_ctx);
  kk_std_core__done(_ctx);
  kk_std_core_console__done(_ctx);
  kk_std_core_delayed__done(_ctx);
  kk_std_core_debug__done(_ctx);
  kk_std_core_show__done(_ctx);
  kk_std_core_tuple__done(_ctx);
  kk_std_core_either__done(_ctx);
  kk_std_core_maybe__done(_ctx);
  kk_std_core_list__done(_ctx);
  kk_std_core_sslice__done(_ctx);
  kk_std_core_string__done(_ctx);
  kk_std_core_vector__done(_ctx);
  kk_std_core_int__done(_ctx);
  kk_std_core_char__done(_ctx);
  kk_std_core_order__done(_ctx);
  kk_std_core_bool__done(_ctx);
  kk_std_core_exn__done(_ctx);
  kk_std_core_hnd__done(_ctx);
  kk_std_core_types__done(_ctx);
}
