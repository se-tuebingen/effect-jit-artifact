// Koka generated module: std/num/int32, koka version: 3.1.2
"use strict";
 
// imports
import * as $std_core_types from './std_core_types.mjs';
import * as $std_core_hnd from './std_core_hnd.mjs';
import * as $std_core_exn from './std_core_exn.mjs';
import * as $std_core_bool from './std_core_bool.mjs';
import * as $std_core_order from './std_core_order.mjs';
import * as $std_core_char from './std_core_char.mjs';
import * as $std_core_int from './std_core_int.mjs';
import * as $std_core_vector from './std_core_vector.mjs';
import * as $std_core_string from './std_core_string.mjs';
import * as $std_core_sslice from './std_core_sslice.mjs';
import * as $std_core_list from './std_core_list.mjs';
import * as $std_core_maybe from './std_core_maybe.mjs';
import * as $std_core_either from './std_core_either.mjs';
import * as $std_core_tuple from './std_core_tuple.mjs';
import * as $std_core_show from './std_core_show.mjs';
import * as $std_core_debug from './std_core_debug.mjs';
import * as $std_core_delayed from './std_core_delayed.mjs';
import * as $std_core_console from './std_core_console.mjs';
import * as $std_core from './std_core.mjs';
import * as $std_core_undiv from './std_core_undiv.mjs';
 
// externals
 
// type declarations
 
// declarations
 
 
// Take the bitwise _xor_ of two `:int32`s
export function _lp__hat__rp_(x, y) /* (x : int32, y : int32) -> int32 */  {
  return (x ^ y);
}
 
export function cmp(x, y) /* (x : int32, y : int32) -> order */  {
  if ((x < y)) {
    return $std_core_types.Lt;
  }
  else {
    return ((x > y)) ? $std_core_types.Gt : $std_core_types.Eq;
  }
}
 
 
// Full 32x32 bit signed multiply to `(hi,lo)`.
// where `(hi,lo).int == hi.int * 0x1_0000_0000 + lo.uint`
export function imul(i, j) /* (i : int32, j : int32) -> (int32, int32) */  {
  return $std_core_types._int32_imul(i,j);
}
 
 
// Return the maximum of two integers
export function max(i, j) /* (i : int32, j : int32) -> int32 */  {
  return ((i >= j)) ? i : j;
}
 
 
// Return the minimum of two integers
export function min(i, j) /* (i : int32, j : int32) -> int32 */  {
  return ((i <= j)) ? i : j;
}
 
 
// Compare the argument against zero.
export function sign(i) /* (i : int32) -> order */  {
  if (0 < i) {
    return $std_core_types.Gt;
  }
  else {
    return (0 > i) ? $std_core_types.Lt : $std_core_types.Eq;
  }
}
 
 
// Full 32x32 bit unsigned multiply to `(hi,lo)`.
// where `(hi,lo).uint == hi.uint * 0x1_0000_0000 + lo.uint`
export function umul(i, j) /* (i : int32, j : int32) -> (int32, int32) */  {
  return $std_core_types._int32_umul(i,j);
}
 
 
// The 32-bit integer with value 1.
export var one;
var one = 1;
 
 
// The zero 32-bit integer.
export var zero;
var zero = 0;
 
 
// Convert a boolean to an `:int32`.
export function bool_fs_int32(b) /* (b : bool) -> int32 */  {
  return (b) ? one : zero;
}
 
 
// Create an `:int32` from the give `hi` and `lo` 16-bit numbers.
// Preserves the sign of `hi`.
export function hilo_fs_int32(hi_0, lo_0) /* (hi : int32, lo : int32) -> int32 */  {
  return ((hi_0 << 16) | ((lo_0 & 65535)));
}
 
 
// The minimal integer value before underflow happens
export var min_int32;
var min_int32 = -2147483648;
 
 
// Euclidean-0 modulus. See `(/):(x : int32, y : int32) -> int32` division for more information.
export function _lp__perc__rp_(x, y) /* (x : int32, y : int32) -> int32 */  {
  var _x0 = (y === 0);
  if (_x0) {
    return x;
  }
  else {
    var _x1 = (y === (-1));
    if (_x1) {
      if ((x === min_int32)) {
        return 0;
      }
      else {
         
        var r = ((x % y)|0);
        var _x2 = (r >= 0);
        if (_x2) {
          return r;
        }
        else {
          var _x3 = (y > 0);
          return (_x3) ? ((r + y)|0) : ((r - y)|0);
        }
      }
    }
    else {
       
      var r_0 = ((x % y)|0);
      var _x4 = (r_0 >= 0);
      if (_x4) {
        return r_0;
      }
      else {
        var _x5 = (y > 0);
        return (_x5) ? ((r_0 + y)|0) : ((r_0 - y)|0);
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
export function _lp__fs__rp_(x, y) /* (x : int32, y : int32) -> int32 */  {
  var _x6 = (y === 0);
  if (_x6) {
    return 0;
  }
  else {
    var _x7 = (y === (-1));
    if (_x7) {
      if ((x === min_int32)) {
        return x;
      }
      else {
         
        var q = ((x/y)|0);
         
        var r = ((x % y)|0);
        var _x8 = (r >= 0);
        if (_x8) {
          return q;
        }
        else {
          var _x9 = (y > 0);
          if (_x9) {
            return ((q - 1)|0);
          }
          else {
            return ((q + 1)|0);
          }
        }
      }
    }
    else {
       
      var q_0 = ((x/y)|0);
       
      var r_0 = ((x % y)|0);
      var _x10 = (r_0 >= 0);
      if (_x10) {
        return q_0;
      }
      else {
        var _x11 = (y > 0);
        if (_x11) {
          return ((q_0 - 1)|0);
        }
        else {
          return ((q_0 + 1)|0);
        }
      }
    }
  }
}
 
 
// Negate a 32-bit integer
export function negate(i) /* (i : int32) -> int32 */  {
  return ((0 - i)|0);
}
 
 
// Return the absolute value of an integer.
// Raises an exception if the `:int32` is `min-int32`
// (since the negation of `min-int32` equals itself and is still negative)
export function abs(i) /* (i : int32) -> exn int32 */  {
   
  var _x_x1_10070 = 0 > i;
  var _x12 = $std_core_hnd._open_none1(function(b /* bool */ ) {
      return (b) ? false : true;
    }, _x_x1_10070);
  if (_x12) {
    return i;
  }
  else {
    if ((i > min_int32)) {
      return ((0 - i)|0);
    }
    else {
      return $std_core_exn.$throw("std/num/int32/abs: cannot make min-int32 into a positive int32 without overflow");
    }
  }
}
 
 
// Return the absolute value of an integer.
// Returns 0 if the `:int32` is `min-int32`
// (since the negation of `min-int32` equals itself and is still negative)
export function abs0(i) /* (i : int32) -> int32 */  {
   
  var b_10000 = 0 > i;
  if (b_10000) {
    if ((i > min_int32)) {
      return ((0 - i)|0);
    }
    else {
      return 0;
    }
  }
  else {
    return i;
  }
}
 
 
// The number of bits in an `:int32` (always 32)
export var bits_int32;
var bits_int32 = 32;
 
 
// Convert an `:int32` to a boolean.
export function bool(i) /* (i : int32) -> bool */  {
  return (i !== zero);
}
 
 
// Truncated division (as in C). See also `(/):(x : int32, y : int32) -> int32`.
export function cdiv(i, j) /* (i : int32, j : int32) -> exn int32 */  {
  if (0 === j) {
    return $std_core_exn.$throw("std/num/int32/cdiv: modulus by zero");
  }
  else {
    var _x13 = (j === (-1));
    if (_x13) {
      if ((i === min_int32)) {
        return $std_core_exn.$throw("std/num/int32/cdiv: modulus overflow in cdiv(min-int32, -1.int32)");
      }
      else {
        return ((i/j)|0);
      }
    }
    else {
      return ((i/j)|0);
    }
  }
}
 
 
// Truncated modulus (as in C). See also `(%):(x : int32, y : int32) -> int32`.
export function cmod(i, j) /* (i : int32, j : int32) -> exn int32 */  {
  if (0 === j) {
    return $std_core_exn.$throw("std/num/int32/cmod: modulus by zero");
  }
  else {
    var _x14 = (j === (-1));
    if (_x14) {
      if ((i === min_int32)) {
        return $std_core_exn.$throw("std/num/int32/cmod: modulus overflow in cmod(min-int32, -1.int32)");
      }
      else {
        return ((i % j)|0);
      }
    }
    else {
      return ((i % j)|0);
    }
  }
}
 
 
// Decrement a 32-bit integer.
export function dec(i) /* (i : int32) -> int32 */  {
  return ((i - 1)|0);
}
 
 
// Increment a 32-bit integer.
export function inc(i) /* (i : int32) -> int32 */  {
  return ((i + 1)|0);
}
 
export function divmod(x, y) /* (x : int32, y : int32) -> (int32, int32) */  {
  if (0 === y) {
    return $std_core_types.Tuple2(zero, x);
  }
  else {
    var _x15 = (y === (-1));
    if (_x15) {
      if ((x === min_int32)) {
        return $std_core_types.Tuple2(x, 0);
      }
      else {
         
        var q = ((x/y)|0);
         
        var r = ((x % y)|0);
         
        var b_10002 = 0 > r;
        if (b_10002) {
          if (0 < y) {
            return $std_core_types.Tuple2(((q - 1)|0), ((r + y)|0));
          }
          else {
            return $std_core_types.Tuple2(((q + 1)|0), ((r - y)|0));
          }
        }
        else {
          return $std_core_types.Tuple2(q, r);
        }
      }
    }
    else {
       
      var q_0 = ((x/y)|0);
       
      var r_0 = ((x % y)|0);
       
      var b_0_10005 = 0 > r_0;
      if (b_0_10005) {
        if (0 < y) {
          return $std_core_types.Tuple2(((q_0 - 1)|0), ((r_0 + y)|0));
        }
        else {
          return $std_core_types.Tuple2(((q_0 + 1)|0), ((r_0 - y)|0));
        }
      }
      else {
        return $std_core_types.Tuple2(q_0, r_0);
      }
    }
  }
}
 
 
// monadic lift
export function range_fs__mlift_fold_int32_10071(end, f, start, x) /* forall<a,e> (end : int32, f : (int32, a) -> e a, start : int32, x : a) -> e a */  {
  return range_fs_fold_int32(((start + 1)|0), end, x, f);
}
 
 
// Fold over the range `[start,end]` (including `end`).
export function range_fs_fold_int32(start_0, end_0, init, f_0) /* forall<a,e> (start : int32, end : int32, init : a, f : (int32, a) -> e a) -> e a */  { tailcall: while(1)
{
  if ((start_0 > end_0)) {
    return init;
  }
  else {
     
    var x_0_10075 = f_0(start_0, init);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(x_1 /* 1422 */ ) {
        return range_fs__mlift_fold_int32_10071(end_0, f_0, start_0, x_1);
      });
    }
    else {
      {
        // tail call
        var _x16 = ((start_0 + 1)|0);
        start_0 = _x16;
        init = x_0_10075;
        continue tailcall;
      }
    }
  }
}}
 
 
// Fold over the 32-bit integers `0` to `n-1`.
export function fold_int32(n, init, f) /* forall<a,e> (n : int32, init : a, f : (int32, a) -> e a) -> e a */  {
  return range_fs_fold_int32(zero, ((n - 1)|0), init, f);
}
 
 
// monadic lift
export function range_fs__mlift_fold_while_int32_10072(end, f, init, start, _y_x10044) /* forall<a,e> (end : int32, f : (int32, a) -> e maybe<a>, init : a, start : int32, maybe<a>) -> e a */  {
  if (_y_x10044 !== null) {
    return range_fs_fold_while_int32(((start + 1)|0), end, _y_x10044.value, f);
  }
  else {
    return init;
  }
}
 
 
// Iterate over the range `[start,end]` (including `end`).
export function range_fs_fold_while_int32(start_0, end_0, init_0, f_0) /* forall<a,e> (start : int32, end : int32, init : a, f : (int32, a) -> e maybe<a>) -> e a */  { tailcall: while(1)
{
  if ((start_0 > end_0)) {
    return init_0;
  }
  else {
     
    var x_0_10078 = f_0(start_0, init_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10044_0 /* maybe<1519> */ ) {
        return range_fs__mlift_fold_while_int32_10072(end_0, f_0, init_0, start_0, _y_x10044_0);
      });
    }
    else {
      if (x_0_10078 !== null) {
        {
          // tail call
          var _x17 = ((start_0 + 1)|0);
          start_0 = _x17;
          init_0 = x_0_10078.value;
          continue tailcall;
        }
      }
      else {
        return init_0;
      }
    }
  }
}}
 
 
// Iterate over the 32-bit integers `0` to `n-1`.
export function fold_while_int32(n, init, f) /* forall<a,e> (n : int32, init : a, f : (int32, a) -> e maybe<a>) -> e a */  {
  return range_fs_fold_while_int32(zero, ((n - 1)|0), init, f);
}
 
 
// monadic lift
export function range_fs__mlift_lift_for_while32_2275_10073(action, end, i, _y_x10049) /* forall<a,e> (action : (int32) -> e maybe<a>, end : int32, i : int32, maybe<a>) -> e maybe<a> */  {
  if (_y_x10049 === null) {
     
    var i_0_10008 = ((i + 1)|0);
    return range_fs__lift_for_while32_2275(action, end, i_0_10008);
  }
  else {
    return $std_core_types.Just(_y_x10049.value);
  }
}
 
 
// lifted local: range/for-while32, rep
export function range_fs__lift_for_while32_2275(action_0, end_0, i_0) /* forall<a,e> (action : (int32) -> e maybe<a>, end : int32, i : int32) -> e maybe<a> */  { tailcall: while(1)
{
  if ((i_0 <= end_0)) {
     
    var x_0_10081 = action_0(i_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10049_0 /* maybe<1594> */ ) {
        return range_fs__mlift_lift_for_while32_2275_10073(action_0, end_0, i_0, _y_x10049_0);
      });
    }
    else {
      if (x_0_10081 === null) {
         
        var i_0_10008_0 = ((i_0 + 1)|0);
        {
          // tail call
          i_0 = i_0_10008_0;
          continue tailcall;
        }
      }
      else {
        return $std_core_types.Just(x_0_10081.value);
      }
    }
  }
  else {
    return $std_core_types.Nothing;
  }
}}
 
 
// Executes `action`  for each integer between `start`  upto `end`  (including both `start`  and `end` ).
// If `start > end`  the function returns without any call to `action` .
// If `action` returns `Just`, the iteration is stopped and the result returned
export function range_fs_for_while32(start, end, action) /* forall<a,e> (start : int32, end : int32, action : (int32) -> e maybe<a>) -> e maybe<a> */  {
  return range_fs__lift_for_while32_2275(action, end, start);
}
 
export function for_while32(n, action) /* forall<a,e> (n : int32, action : (int32) -> e maybe<a>) -> e maybe<a> */  {
   
  var end_10010 = ((n - 1)|0);
  return range_fs__lift_for_while32_2275(action, end_10010, zero);
}
 
 
// monadic lift
export function range_fs__mlift_lift_for32_2276_10074(action, end, i, wild__) /* forall<e> (action : (int32) -> e (), end : int32, i : int32, wild_ : ()) -> e () */  {
   
  var i_0_10012 = ((i + 1)|0);
  return range_fs__lift_for32_2276(action, end, i_0_10012);
}
 
 
// lifted local: range/for32, rep
export function range_fs__lift_for32_2276(action_0, end_0, i_0) /* forall<e> (action : (int32) -> e (), end : int32, i : int32) -> e () */  { tailcall: while(1)
{
  if ((i_0 <= end_0)) {
     
    var x_10084 = action_0(i_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
        return range_fs__mlift_lift_for32_2276_10074(action_0, end_0, i_0, wild___0);
      });
    }
    else {
       
      var i_0_10012_0 = ((i_0 + 1)|0);
      {
        // tail call
        i_0 = i_0_10012_0;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types.Unit;
  }
}}
 
 
// Executes `action`  for each integer between `start`  upto `end`  (including both `start`  and `end` ).
// If `start > end`  the function returns without any call to `action` .
export function range_fs_for32(start, end, action) /* forall<e> (start : int32, end : int32, action : (int32) -> e ()) -> e () */  {
  return range_fs__lift_for32_2276(action, end, start);
}
 
export function for32(n, action) /* forall<e> (n : int32, action : (int32) -> e ()) -> e () */  {
   
  var end_10014 = ((n - 1)|0);
  return range_fs__lift_for32_2276(action, end_10014, zero);
}
 
 
// Return the top 16-bits of an `:int32`.
// Preserves the sign.
export function hi(i) /* (i : int32) -> int32 */  {
  return i >> 16;
}
 
 
// Convenient shorthand to `int32`, e.g. `1234.i32`
export function i32(i) /* (i : int) -> int32 */  {
  return $std_core_types._int_clamp32(i);
}
 
 
// Returns `true` if the integer `i`  is an even number.
export function is_even(i) /* (i : int32) -> bool */  {
  return (((i & 1)) === 0);
}
 
 
// Returns `true` if the integer `i`  is an odd number.
export function is_odd(i) /* (i : int32) -> bool */  {
  return (((i & 1)) === 1);
}
 
 
// Create a list with 32-bit integer elements from `lo` to `hi` (including `hi`).
export function _trmc_list32(lo_0, hi_0, _acc) /* (lo : int32, hi : int32, ctx<list<int32>>) -> list<int32> */  { tailcall: while(1)
{
  if ((lo_0 <= hi_0)) {
     
    var _trmc_x10025 = undefined;
     
    var _trmc_x10026 = $std_core_types.Cons(lo_0, _trmc_x10025);
    {
      // tail call
      var _x18 = ((lo_0 + 1)|0);
      var _x19 = $std_core_types._cctx_extend(_acc,_trmc_x10026,({obj: _trmc_x10026, field_name: "tail"}));
      lo_0 = _x18;
      _acc = _x19;
      continue tailcall;
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}}
 
 
// Create a list with 32-bit integer elements from `lo` to `hi` (including `hi`).
export function list32(lo_0_0, hi_0_0) /* (lo : int32, hi : int32) -> list<int32> */  {
  return _trmc_list32(lo_0_0, hi_0_0, $std_core_types._cctx_empty());
}
 
 
// Return the low 16-bits of an `:int32`.
export function lo(i) /* (i : int32) -> int32 */  {
  return (i & 65535);
}
 
 
// The maximal integer value before overflow happens
export var max_int32;
var max_int32 = 2147483647;
 
 
// Bitwise rotate an `:int32` `n % 32` bits to the left.
export function rotl(i, shift) /* (i : int32, shift : int) -> int32 */  {
  return $std_core_types._int32_rotl(i,($std_core_types._int_clamp32(shift)));
}
 
 
// Bitwise rotate an `:int32` `n % 32` bits to the right.
export function rotr(i, shift) /* (i : int32, shift : int) -> int32 */  {
  return $std_core_types._int32_rotr(i,($std_core_types._int_clamp32(shift)));
}
 
 
// Arithmetic shift an `:int32` to the right by `n % 32` bits. Shifts in the sign bit from the left.
export function sar(i, shift) /* (i : int32, shift : int) -> int32 */  {
  return i >> ($std_core_types._int_clamp32(shift));
}
 
 
// Shift an `:int32` `i` to the left by `n & 31` bits.
export function shl(i, shift) /* (i : int32, shift : int) -> int32 */  {
  return i << ($std_core_types._int_clamp32(shift));
}
 
 
// Convert an `:int32` to an `:int` but interpret the `:int32` as a 32-bit unsigned value.
export function uint(i) /* (i : int32) -> int */  {
  if (0 > i) {
     
    var y_10018 = $std_core_types._int_from_int32(i);
    return $std_core_types._int_add(4294967296,y_10018);
  }
  else {
    return $std_core_types._int_from_int32(i);
  }
}
 
 
// Convert a pair `(lo,hi)` to a signed integer,
// where `(lo,hi).int == hi.int * 0x1_0000_0000 + lo.uint`
export function hilo_fs_int(_pat_x405__19) /* ((int32, int32)) -> int */  {
   
  var x_10019 = $std_core_types._int_mul(($std_core_types._int_from_int32((_pat_x405__19.fst))),4294967296);
   
  var y_10020 = uint(_pat_x405__19.snd);
  return $std_core_types._int_add(x_10019,y_10020);
}
 
 
// Convert a pair `(lo,hi)` to an unsigned integer,
// where `(lo,hi).uint == hi.uint * 0x1_0000_0000 + lo.uint`
export function hilo_fs_uint(_pat_x410__20) /* ((int32, int32)) -> int */  {
   
  var x_10021 = $std_core_types._int_mul((uint(_pat_x410__20.fst)),4294967296);
   
  var y_10022 = uint(_pat_x410__20.snd);
  return $std_core_types._int_add(x_10021,y_10022);
}
 
 
// Convert an `:int32` to a string
export function show(i) /* (i : int32) -> string */  {
  return $std_core_int.show($std_core_types._int_from_int32(i));
}
 
 
// Show an `:int32` in hexadecimal notation
// The `width`  parameter specifies how wide the hex value is where `'0'`  is used to align.\
// The `use-capitals` parameter (= `True`) determines if captical letters should be used to display the hexadecimal digits.\
// The `pre` (=`"0x"`) is an optional prefix for the number (goes between the sign and the number).
export function show_hex(i, width, use_capitals, pre) /* (i : int32, width : ? int, use-capitals : ? bool, pre : ? string) -> string */  {
  var _x20 = (width !== undefined) ? width : 1;
  var _x21 = (use_capitals !== undefined) ? use_capitals : true;
  var _x22 = (pre !== undefined) ? pre : "0x";
  return $std_core_show.show_hex($std_core_types._int_from_int32(i), _x20, _x21, _x22);
}
 
 
// Show an `:int32` in hexadecimal notation interpreted as an unsigned 32-bit value.
// The `width`  parameter specifies how wide the hex value is where `'0'`  is used to align.\
// The `use-capitals` parameter (= `True`) determines if captical letters should be used to display the hexadecimal digits.\
// The `pre` (=`"0x"`) is an optional prefix for the number.
export function show_hex32(i, width, use_capitals, pre) /* (i : int32, width : ? int, use-capitals : ? bool, pre : ? string) -> string */  {
  var _x23 = (width !== undefined) ? width : 8;
  var _x24 = (use_capitals !== undefined) ? use_capitals : true;
  var _x25 = (pre !== undefined) ? pre : "0x";
  return $std_core_show.show_hex(uint(i), _x23, _x24, _x25);
}
 
 
// Logical shift an `:int32` to the right by `n % 32` bits. Shift in zeros from the left.
export function shr(i, shift) /* (i : int32, shift : int) -> int32 */  {
  return i >>> ($std_core_types._int_clamp32(shift));
}
 
export function sumacc32(xs, acc) /* (xs : list<int32>, acc : int32) -> int32 */  { tailcall: while(1)
{
  if (xs !== null) {
    {
      // tail call
      var _x26 = ((acc + (xs.head))|0);
      xs = xs.tail;
      acc = _x26;
      continue tailcall;
    }
  }
  else {
    return acc;
  }
}}
 
export function sum32(xs) /* (xs : list<int32>) -> int32 */  {
  return sumacc32(xs, 0);
}
 
 
// Convert an `:int` to `:int32` but interpret the `int` as an unsigned 32-bit value.
// `i` is clamped between `0` and `0xFFFFFFFF`.\
// `0x7FFF_FFFF.uint32 == 0x7FFF_FFFF.int32 == max-int32`\
// `0x8000_0000.uint32 == -0x8000_0000.int32 == min-int32`\
// `0xFFFF_FFFF.uint32 == -1.int32`\
export function uint32(i) /* (i : int) -> int32 */  {
  var _x28 = $std_core_types._int_gt(i,($std_core_types._int_from_int32(max_int32)));
  var _x27 = (_x28) ? $std_core_types._int_sub(i,4294967296) : i;
  return $std_core_types._int_clamp32(_x27);
}
 
 
// Negate an 32-bit integer
export function _lp__tilde__rp_(i) /* (i : int32) -> int32 */  {
  return ((0 - i)|0);
}