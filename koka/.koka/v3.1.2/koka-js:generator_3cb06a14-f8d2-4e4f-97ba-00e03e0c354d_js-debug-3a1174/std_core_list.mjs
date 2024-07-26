// Koka generated module: std/core/list, koka version: 3.1.2
"use strict";
 
// imports
import * as $std_core_types from './std_core_types.mjs';
import * as $std_core_undiv from './std_core_undiv.mjs';
import * as $std_core_hnd from './std_core_hnd.mjs';
import * as $std_core_exn from './std_core_exn.mjs';
import * as $std_core_char from './std_core_char.mjs';
import * as $std_core_string from './std_core_string.mjs';
import * as $std_core_int from './std_core_int.mjs';
import * as $std_core_vector from './std_core_vector.mjs';
 
// externals
 
// type declarations
 
// declarations
 
 
// lifted local: concat, concat-pre
export function _trmc_lift_concat_4788(ys, zss, _acc) /* forall<a> (ys : list<a>, zss : list<list<a>>, ctx<list<a>>) -> list<a> */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var _trmc_x10076 = undefined;
     
    var _trmc_x10077 = $std_core_types.Cons(ys.head, _trmc_x10076);
    {
      // tail call
      var _x0 = $std_core_types._cctx_extend(_acc,_trmc_x10077,({obj: _trmc_x10077, field_name: "tail"}));
      ys = ys.tail;
      _acc = _x0;
      continue tailcall;
    }
  }
  else {
    if (zss !== null) {
      {
        // tail call
        ys = zss.head;
        zss = zss.tail;
        continue tailcall;
      }
    }
    else {
      return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
    }
  }
}}
 
 
// lifted local: concat, concat-pre
export function _lift_concat_4788(ys_0, zss_0) /* forall<a> (ys : list<a>, zss : list<list<a>>) -> list<a> */  {
  return _trmc_lift_concat_4788(ys_0, zss_0, $std_core_types._cctx_empty());
}
 
 
// Concatenate all lists in a list (e.g. flatten the list). (tail-recursive)
export function concat(xss) /* forall<a> (xss : list<list<a>>) -> list<a> */  {
  return _lift_concat_4788($std_core_types.Nil, xss);
}
 
 
// monadic lift
export function _mlift_trmc_lift_flatmap_4789_10425(_acc, f, zz, ys_1_10002) /* forall<a,b,e> (ctx<list<b>>, f : (a) -> e list<b>, zz : list<a>, ys@1@10002 : list<b>) -> e list<b> */  {
  return _trmc_lift_flatmap_4789(f, ys_1_10002, zz, _acc);
}
 
 
// monadic lift
export function _mlift_trmcm_lift_flatmap_4789_10426(_accm, f_0, zz_0, ys_1_10002_0) /* forall<a,b,e> ((list<b>) -> list<b>, f : (a) -> e list<b>, zz : list<a>, ys@1@10002 : list<b>) -> e list<b> */  {
  return _trmcm_lift_flatmap_4789(f_0, ys_1_10002_0, zz_0, _accm);
}
 
 
// lifted local: flatmap, flatmap-pre
export function _trmc_lift_flatmap_4789(f_1, ys, zs, _acc_0) /* forall<a,b,e> (f : (a) -> e list<b>, ys : list<b>, zs : list<a>, ctx<list<b>>) -> e list<b> */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var _trmc_x10078 = undefined;
     
    var _trmc_x10079 = $std_core_types.Cons(ys.head, _trmc_x10078);
    {
      // tail call
      var _x1 = $std_core_types._cctx_extend(_acc_0,_trmc_x10079,({obj: _trmc_x10079, field_name: "tail"}));
      ys = ys.tail;
      _acc_0 = _x1;
      continue tailcall;
    }
  }
  else {
    if (zs !== null) {
       
      var x_10469 = f_1(zs.head);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(ys_1_10002_1 /* list<690> */ ) {
          return _mlift_trmc_lift_flatmap_4789_10425(_acc_0, f_1, zs.tail, ys_1_10002_1);
        });
      }
      else {
        {
          // tail call
          ys = x_10469;
          zs = zs.tail;
          continue tailcall;
        }
      }
    }
    else {
      return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
    }
  }
}}
 
 
// lifted local: flatmap, flatmap-pre
export function _trmcm_lift_flatmap_4789(f_2, ys_0, zs_0, _accm_0) /* forall<a,b,e> (f : (a) -> e list<b>, ys : list<b>, zs : list<a>, (list<b>) -> list<b>) -> e list<b> */  { tailcall: while(1)
{
  if (ys_0 !== null) {
    {
      // tail call
      var _x4 = function(__at_accm_02 /* (list<690>) -> list<690> */ , _y_03 /* 690 */ ) {
        return function(_trmc_x10081 /* list<690> */ ) {
          return __at_accm_02($std_core_types.Cons(_y_03, _trmc_x10081));
        };
      }(_accm_0, ys_0.head);
      ys_0 = ys_0.tail;
      _accm_0 = _x4;
      continue tailcall;
    }
  }
  else {
    if (zs_0 !== null) {
       
      var x_0_10472 = f_2(zs_0.head);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(ys_1_10002_3 /* list<690> */ ) {
          return _mlift_trmcm_lift_flatmap_4789_10426(_accm_0, f_2, zs_0.tail, ys_1_10002_3);
        });
      }
      else {
        {
          // tail call
          ys_0 = x_0_10472;
          zs_0 = zs_0.tail;
          continue tailcall;
        }
      }
    }
    else {
      return _accm_0($std_core_types.Nil);
    }
  }
}}
 
 
// lifted local: flatmap, flatmap-pre
export function _lift_flatmap_4789(f_3, ys_1, zs_1) /* forall<a,b,e> (f : (a) -> e list<b>, ys : list<b>, zs : list<a>) -> e list<b> */  {
  var _x5 = $std_core_hnd._evv_is_affine();
  if (_x5) {
    return _trmc_lift_flatmap_4789(f_3, ys_1, zs_1, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_lift_flatmap_4789(f_3, ys_1, zs_1, function(_trmc_x10080 /* list<690> */ ) {
        return _trmc_x10080;
      });
  }
}
 
 
// Concatenate the result lists from applying a function to all elements.
export function flatmap(xs, f) /* forall<a,b,e> (xs : list<a>, f : (a) -> e list<b>) -> e list<b> */  {
  return _lift_flatmap_4789(f, $std_core_types.Nil, xs);
}
 
 
// lifted local: reverse-append, reverse-acc
export function _lift_reverse_append_4790(acc, ys) /* forall<a> (acc : list<a>, ys : list<a>) -> list<a> */  { tailcall: while(1)
{
  if (ys !== null) {
    {
      // tail call
      var _x6 = $std_core_types.Cons(ys.head, acc);
      acc = _x6;
      ys = ys.tail;
      continue tailcall;
    }
  }
  else {
    return acc;
  }
}}
 
 
// Efficiently reverse a list `xs` and append it to `tl`:
// `reverse-append(xs,tl) == reserve(xs) ++ tl
export function reverse_append(xs, tl) /* forall<a> (xs : list<a>, tl : list<a>) -> list<a> */  {
  return _lift_reverse_append_4790(tl, xs);
}
 
 
// Return the head of list if the list is not empty.
export function head(xs) /* forall<a> (xs : list<a>) -> maybe<a> */  {
  if (xs !== null) {
    return $std_core_types.Just(xs.head);
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
 
// lifted local: intersperse, before
export function _trmc_lift_intersperse_4791(sep, ys, _acc) /* forall<a> (sep : a, ys : list<a>, ctx<list<a>>) -> list<a> */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var _trmc_x10082 = $std_core_types.Cons(ys.head, undefined);
    {
      // tail call
      var _x7 = $std_core_types._cctx_extend(_acc,($std_core_types.Cons(sep, _trmc_x10082)),({obj: _trmc_x10082, field_name: "tail"}));
      ys = ys.tail;
      _acc = _x7;
      continue tailcall;
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}}
 
 
// lifted local: intersperse, before
export function _lift_intersperse_4791(sep_0, ys_0) /* forall<a> (sep : a, ys : list<a>) -> list<a> */  {
  return _trmc_lift_intersperse_4791(sep_0, ys_0, $std_core_types._cctx_empty());
}
 
 
// Insert a separator `sep`  between all elements of a list `xs` .
export function intersperse(xs, sep) /* forall<a> (xs : list<a>, sep : a) -> list<a> */  {
  if (xs !== null) {
    return $std_core_types.Cons(xs.head, _lift_intersperse_4791(sep, xs.tail));
  }
  else {
    return $std_core_types.Nil;
  }
}
 
 
// Is the list empty?
export function is_empty(xs) /* forall<a> (xs : list<a>) -> bool */  {
  return (xs === null);
}
 
 
// lifted local: length, len
export function _lift_length_4792(ys, acc) /* forall<a> (ys : list<a>, acc : int) -> int */  { tailcall: while(1)
{
  if (ys !== null) {
    {
      // tail call
      var _x8 = $std_core_types._int_add(acc,1);
      ys = ys.tail;
      acc = _x8;
      continue tailcall;
    }
  }
  else {
    return acc;
  }
}}
 
 
// Returns the length of a list.
export function length(xs) /* forall<a> (xs : list<a>) -> int */  {
  return _lift_length_4792(xs, 0);
}
 
 
// Convert a `:maybe` type to a list type.
export function maybe_fs_list(m) /* forall<a> (m : maybe<a>) -> list<a> */  {
  if (m === null) {
    return $std_core_types.Nil;
  }
  else {
    return $std_core_types.Cons(m.value, $std_core_types.Nil);
  }
}
 
 
// monadic lift
export function _mlift_trmc_lift_map_indexed_4793_10427(_acc, f, i_0_10009, yy, _trmc_x10084) /* forall<a,b,e> (ctx<list<b>>, f : (idx : int, value : a) -> e b, i@0@10009 : int, yy : list<a>, b) -> e list<b> */  {
   
  var _trmc_x10085 = undefined;
   
  var _trmc_x10086 = $std_core_types.Cons(_trmc_x10084, _trmc_x10085);
  return _trmc_lift_map_indexed_4793(f, yy, i_0_10009, $std_core_types._cctx_extend(_acc,_trmc_x10086,({obj: _trmc_x10086, field_name: "tail"})));
}
 
 
// monadic lift
export function _mlift_trmcm_lift_map_indexed_4793_10428(_accm, f_0, i_0_10009_0, yy_0, _trmc_x10089) /* forall<a,b,e> ((list<b>) -> list<b>, f : (idx : int, value : a) -> e b, i@0@10009 : int, yy : list<a>, b) -> e list<b> */  {
  return _trmcm_lift_map_indexed_4793(f_0, yy_0, i_0_10009_0, function(_trmc_x10088 /* list<979> */ ) {
      return _accm($std_core_types.Cons(_trmc_x10089, _trmc_x10088));
    });
}
 
 
// lifted local: map-indexed, map-idx
export function _trmc_lift_map_indexed_4793(f_1, ys, i, _acc_0) /* forall<a,b,e> (f : (idx : int, value : a) -> e b, ys : list<a>, i : int, ctx<list<b>>) -> e list<b> */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var i_0_10009_1 = $std_core_types._int_add(i,1);
     
    var x_10475 = f_1(i, ys.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10084_0 /* 979 */ ) {
        return _mlift_trmc_lift_map_indexed_4793_10427(_acc_0, f_1, i_0_10009_1, ys.tail, _trmc_x10084_0);
      });
    }
    else {
       
      var _trmc_x10085_0 = undefined;
       
      var _trmc_x10086_0 = $std_core_types.Cons(x_10475, _trmc_x10085_0);
      {
        // tail call
        var _x9 = $std_core_types._cctx_extend(_acc_0,_trmc_x10086_0,({obj: _trmc_x10086_0, field_name: "tail"}));
        ys = ys.tail;
        i = i_0_10009_1;
        _acc_0 = _x9;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// lifted local: map-indexed, map-idx
export function _trmcm_lift_map_indexed_4793(f_2, ys_0, i_0, _accm_0) /* forall<a,b,e> (f : (idx : int, value : a) -> e b, ys : list<a>, i : int, (list<b>) -> list<b>) -> e list<b> */  { tailcall: while(1)
{
  if (ys_0 !== null) {
     
    var i_0_10009_2 = $std_core_types._int_add(i_0,1);
     
    var x_0_10478 = f_2(i_0, ys_0.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10089_0 /* 979 */ ) {
        return _mlift_trmcm_lift_map_indexed_4793_10428(_accm_0, f_2, i_0_10009_2, ys_0.tail, _trmc_x10089_0);
      });
    }
    else {
      {
        // tail call
        var _x12 = function(__at_accm_010 /* (list<979>) -> list<979> */ , _x_0_1047811 /* 979 */ ) {
          return function(_trmc_x10088_0 /* list<979> */ ) {
            return __at_accm_010($std_core_types.Cons(_x_0_1047811, _trmc_x10088_0));
          };
        }(_accm_0, x_0_10478);
        ys_0 = ys_0.tail;
        i_0 = i_0_10009_2;
        _accm_0 = _x12;
        continue tailcall;
      }
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// lifted local: map-indexed, map-idx
export function _lift_map_indexed_4793(f_3, ys_1, i_1) /* forall<a,b,e> (f : (idx : int, value : a) -> e b, ys : list<a>, i : int) -> e list<b> */  {
  var _x13 = $std_core_hnd._evv_is_affine();
  if (_x13) {
    return _trmc_lift_map_indexed_4793(f_3, ys_1, i_1, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_lift_map_indexed_4793(f_3, ys_1, i_1, function(_trmc_x10087 /* list<979> */ ) {
        return _trmc_x10087;
      });
  }
}
 
 
// Apply a function `f`  to each element of the input list in sequence where takes
// both the index of the current element and the element itself as arguments.
export function map_indexed(xs, f) /* forall<a,b,e> (xs : list<a>, f : (idx : int, value : a) -> e b) -> e list<b> */  {
  return _lift_map_indexed_4793(f, xs, 0);
}
 
 
// monadic lift
export function _mlift_trmc_lift_map_indexed_peek_4794_10429(_acc, f, i_0_10011, yy, _trmc_x10090) /* forall<a,b,e> (ctx<list<b>>, f : (idx : int, value : a, rest : list<a>) -> e b, i@0@10011 : int, yy : list<a>, b) -> e list<b> */  {
   
  var _trmc_x10091 = undefined;
   
  var _trmc_x10092 = $std_core_types.Cons(_trmc_x10090, _trmc_x10091);
  return _trmc_lift_map_indexed_peek_4794(f, yy, i_0_10011, $std_core_types._cctx_extend(_acc,_trmc_x10092,({obj: _trmc_x10092, field_name: "tail"})));
}
 
 
// monadic lift
export function _mlift_trmcm_lift_map_indexed_peek_4794_10430(_accm, f_0, i_0_10011_0, yy_0, _trmc_x10095) /* forall<a,b,e> ((list<b>) -> list<b>, f : (idx : int, value : a, rest : list<a>) -> e b, i@0@10011 : int, yy : list<a>, b) -> e list<b> */  {
  return _trmcm_lift_map_indexed_peek_4794(f_0, yy_0, i_0_10011_0, function(_trmc_x10094 /* list<1041> */ ) {
      return _accm($std_core_types.Cons(_trmc_x10095, _trmc_x10094));
    });
}
 
 
// lifted local: map-indexed-peek, mapidx
export function _trmc_lift_map_indexed_peek_4794(f_1, ys, i, _acc_0) /* forall<a,b,e> (f : (idx : int, value : a, rest : list<a>) -> e b, ys : list<a>, i : int, ctx<list<b>>) -> e list<b> */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var i_0_10011_1 = $std_core_types._int_add(i,1);
     
    var x_10481 = f_1(i, ys.head, ys.tail);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10090_0 /* 1041 */ ) {
        return _mlift_trmc_lift_map_indexed_peek_4794_10429(_acc_0, f_1, i_0_10011_1, ys.tail, _trmc_x10090_0);
      });
    }
    else {
       
      var _trmc_x10091_0 = undefined;
       
      var _trmc_x10092_0 = $std_core_types.Cons(x_10481, _trmc_x10091_0);
      {
        // tail call
        var _x14 = $std_core_types._cctx_extend(_acc_0,_trmc_x10092_0,({obj: _trmc_x10092_0, field_name: "tail"}));
        ys = ys.tail;
        i = i_0_10011_1;
        _acc_0 = _x14;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// lifted local: map-indexed-peek, mapidx
export function _trmcm_lift_map_indexed_peek_4794(f_2, ys_0, i_0, _accm_0) /* forall<a,b,e> (f : (idx : int, value : a, rest : list<a>) -> e b, ys : list<a>, i : int, (list<b>) -> list<b>) -> e list<b> */  { tailcall: while(1)
{
  if (ys_0 !== null) {
     
    var i_0_10011_2 = $std_core_types._int_add(i_0,1);
     
    var x_0_10484 = f_2(i_0, ys_0.head, ys_0.tail);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10095_0 /* 1041 */ ) {
        return _mlift_trmcm_lift_map_indexed_peek_4794_10430(_accm_0, f_2, i_0_10011_2, ys_0.tail, _trmc_x10095_0);
      });
    }
    else {
      {
        // tail call
        var _x17 = function(__at_accm_015 /* (list<1041>) -> list<1041> */ , _x_0_1048416 /* 1041 */ ) {
          return function(_trmc_x10094_0 /* list<1041> */ ) {
            return __at_accm_015($std_core_types.Cons(_x_0_1048416, _trmc_x10094_0));
          };
        }(_accm_0, x_0_10484);
        ys_0 = ys_0.tail;
        i_0 = i_0_10011_2;
        _accm_0 = _x17;
        continue tailcall;
      }
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// lifted local: map-indexed-peek, mapidx
export function _lift_map_indexed_peek_4794(f_3, ys_1, i_1) /* forall<a,b,e> (f : (idx : int, value : a, rest : list<a>) -> e b, ys : list<a>, i : int) -> e list<b> */  {
  var _x18 = $std_core_hnd._evv_is_affine();
  if (_x18) {
    return _trmc_lift_map_indexed_peek_4794(f_3, ys_1, i_1, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_lift_map_indexed_peek_4794(f_3, ys_1, i_1, function(_trmc_x10093 /* list<1041> */ ) {
        return _trmc_x10093;
      });
  }
}
 
 
// Apply a function `f`  to each element of the input list in sequence where takes
// both the index of the current element, the element itself, and the tail list as arguments.
export function map_indexed_peek(xs, f) /* forall<a,b,e> (xs : list<a>, f : (idx : int, value : a, rest : list<a>) -> e b) -> e list<b> */  {
  return _lift_map_indexed_peek_4794(f, xs, 0);
}
 
 
// monadic lift
export function _mlift_trmc_lift_map_peek_4795_10431(_acc, f, yy, _trmc_x10096) /* forall<a,b,e> (ctx<list<b>>, f : (value : a, rest : list<a>) -> e b, yy : list<a>, b) -> e list<b> */  {
   
  var _trmc_x10097 = undefined;
   
  var _trmc_x10098 = $std_core_types.Cons(_trmc_x10096, _trmc_x10097);
  return _trmc_lift_map_peek_4795(f, yy, $std_core_types._cctx_extend(_acc,_trmc_x10098,({obj: _trmc_x10098, field_name: "tail"})));
}
 
 
// monadic lift
export function _mlift_trmcm_lift_map_peek_4795_10432(_accm, f_0, yy_0, _trmc_x10101) /* forall<a,b,e> ((list<b>) -> list<b>, f : (value : a, rest : list<a>) -> e b, yy : list<a>, b) -> e list<b> */  {
  return _trmcm_lift_map_peek_4795(f_0, yy_0, function(_trmc_x10100 /* list<1093> */ ) {
      return _accm($std_core_types.Cons(_trmc_x10101, _trmc_x10100));
    });
}
 
 
// lifted local: map-peek, mappeek
export function _trmc_lift_map_peek_4795(f_1, ys, _acc_0) /* forall<a,b,e> (f : (value : a, rest : list<a>) -> e b, ys : list<a>, ctx<list<b>>) -> e list<b> */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var x_10487 = f_1(ys.head, ys.tail);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10096_0 /* 1093 */ ) {
        return _mlift_trmc_lift_map_peek_4795_10431(_acc_0, f_1, ys.tail, _trmc_x10096_0);
      });
    }
    else {
       
      var _trmc_x10097_0 = undefined;
       
      var _trmc_x10098_0 = $std_core_types.Cons(x_10487, _trmc_x10097_0);
      {
        // tail call
        var _x19 = $std_core_types._cctx_extend(_acc_0,_trmc_x10098_0,({obj: _trmc_x10098_0, field_name: "tail"}));
        ys = ys.tail;
        _acc_0 = _x19;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// lifted local: map-peek, mappeek
export function _trmcm_lift_map_peek_4795(f_2, ys_0, _accm_0) /* forall<a,b,e> (f : (value : a, rest : list<a>) -> e b, ys : list<a>, (list<b>) -> list<b>) -> e list<b> */  { tailcall: while(1)
{
  if (ys_0 !== null) {
     
    var x_0_10490 = f_2(ys_0.head, ys_0.tail);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10101_0 /* 1093 */ ) {
        return _mlift_trmcm_lift_map_peek_4795_10432(_accm_0, f_2, ys_0.tail, _trmc_x10101_0);
      });
    }
    else {
      {
        // tail call
        var _x22 = function(__at_accm_020 /* (list<1093>) -> list<1093> */ , _x_0_1049021 /* 1093 */ ) {
          return function(_trmc_x10100_0 /* list<1093> */ ) {
            return __at_accm_020($std_core_types.Cons(_x_0_1049021, _trmc_x10100_0));
          };
        }(_accm_0, x_0_10490);
        ys_0 = ys_0.tail;
        _accm_0 = _x22;
        continue tailcall;
      }
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// lifted local: map-peek, mappeek
export function _lift_map_peek_4795(f_3, ys_1) /* forall<a,b,e> (f : (value : a, rest : list<a>) -> e b, ys : list<a>) -> e list<b> */  {
  var _x23 = $std_core_hnd._evv_is_affine();
  if (_x23) {
    return _trmc_lift_map_peek_4795(f_3, ys_1, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_lift_map_peek_4795(f_3, ys_1, function(_trmc_x10099 /* list<1093> */ ) {
        return _trmc_x10099;
      });
  }
}
 
 
// Apply a function `f`  to each element of the input list in sequence where `f` takes
// both the current element and the tail list as arguments.
export function map_peek(xs, f) /* forall<a,b,e> (xs : list<a>, f : (value : a, rest : list<a>) -> e b) -> e list<b> */  {
  return _lift_map_peek_4795(f, xs);
}
 
 
// Returns a singleton list.
export function single(x) /* forall<a> (x : a) -> list<a> */  {
  return $std_core_types.Cons(x, $std_core_types.Nil);
}
 
 
// Return the tail of list. Returns the empty list if `xs` is empty.
export function tail(xs) /* forall<a> (xs : list<a>) -> list<a> */  {
  return (xs !== null) ? xs.tail : $std_core_types.Nil;
}
 
 
// monadic lift
export function _mlift_trmc_lift_zipwith_indexed_4796_10433(_acc, f, i_0_10013, xx, yy, _trmc_x10102) /* forall<a,b,c,e> (ctx<list<c>>, f : (int, a, b) -> e c, i@0@10013 : int, xx : list<a>, yy : list<b>, c) -> e list<c> */  {
   
  var _trmc_x10103 = undefined;
   
  var _trmc_x10104 = $std_core_types.Cons(_trmc_x10102, _trmc_x10103);
  return _trmc_lift_zipwith_indexed_4796(f, i_0_10013, xx, yy, $std_core_types._cctx_extend(_acc,_trmc_x10104,({obj: _trmc_x10104, field_name: "tail"})));
}
 
 
// monadic lift
export function _mlift_trmcm_lift_zipwith_indexed_4796_10434(_accm, f_0, i_0_10013_0, xx_0, yy_0, _trmc_x10107) /* forall<a,b,c,e> ((list<c>) -> list<c>, f : (int, a, b) -> e c, i@0@10013 : int, xx : list<a>, yy : list<b>, c) -> e list<c> */  {
  return _trmcm_lift_zipwith_indexed_4796(f_0, i_0_10013_0, xx_0, yy_0, function(_trmc_x10106 /* list<1211> */ ) {
      return _accm($std_core_types.Cons(_trmc_x10107, _trmc_x10106));
    });
}
 
 
// lifted local: zipwith-indexed, zipwith-iter
export function _trmc_lift_zipwith_indexed_4796(f_1, i, xs, ys, _acc_0) /* forall<a,b,c,e> (f : (int, a, b) -> e c, i : int, xs : list<a>, ys : list<b>, ctx<list<c>>) -> e list<c> */  { tailcall: while(1)
{
  if (xs !== null) {
    if (ys !== null) {
       
      var i_0_10013_1 = $std_core_types._int_add(i,1);
       
      var x_0_10493 = f_1(i, xs.head, ys.head);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_trmc_x10102_0 /* 1211 */ ) {
          return _mlift_trmc_lift_zipwith_indexed_4796_10433(_acc_0, f_1, i_0_10013_1, xs.tail, ys.tail, _trmc_x10102_0);
        });
      }
      else {
         
        var _trmc_x10103_0 = undefined;
         
        var _trmc_x10104_0 = $std_core_types.Cons(x_0_10493, _trmc_x10103_0);
        {
          // tail call
          var _x24 = $std_core_types._cctx_extend(_acc_0,_trmc_x10104_0,({obj: _trmc_x10104_0, field_name: "tail"}));
          i = i_0_10013_1;
          xs = xs.tail;
          ys = ys.tail;
          _acc_0 = _x24;
          continue tailcall;
        }
      }
    }
    else {
      return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// lifted local: zipwith-indexed, zipwith-iter
export function _trmcm_lift_zipwith_indexed_4796(f_2, i_0, xs_0, ys_0, _accm_0) /* forall<a,b,c,e> (f : (int, a, b) -> e c, i : int, xs : list<a>, ys : list<b>, (list<c>) -> list<c>) -> e list<c> */  { tailcall: while(1)
{
  if (xs_0 !== null) {
    if (ys_0 !== null) {
       
      var i_0_10013_2 = $std_core_types._int_add(i_0,1);
       
      var x_2_10496 = f_2(i_0, xs_0.head, ys_0.head);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_trmc_x10107_0 /* 1211 */ ) {
          return _mlift_trmcm_lift_zipwith_indexed_4796_10434(_accm_0, f_2, i_0_10013_2, xs_0.tail, ys_0.tail, _trmc_x10107_0);
        });
      }
      else {
        {
          // tail call
          var _x27 = function(__at_accm_025 /* (list<1211>) -> list<1211> */ , _x_2_1049626 /* 1211 */ ) {
            return function(_trmc_x10106_0 /* list<1211> */ ) {
              return __at_accm_025($std_core_types.Cons(_x_2_1049626, _trmc_x10106_0));
            };
          }(_accm_0, x_2_10496);
          i_0 = i_0_10013_2;
          xs_0 = xs_0.tail;
          ys_0 = ys_0.tail;
          _accm_0 = _x27;
          continue tailcall;
        }
      }
    }
    else {
      return _accm_0($std_core_types.Nil);
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// lifted local: zipwith-indexed, zipwith-iter
export function _lift_zipwith_indexed_4796(f_3, i_1, xs_1, ys_1) /* forall<a,b,c,e> (f : (int, a, b) -> e c, i : int, xs : list<a>, ys : list<b>) -> e list<c> */  {
  var _x28 = $std_core_hnd._evv_is_affine();
  if (_x28) {
    return _trmc_lift_zipwith_indexed_4796(f_3, i_1, xs_1, ys_1, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_lift_zipwith_indexed_4796(f_3, i_1, xs_1, ys_1, function(_trmc_x10105 /* list<1211> */ ) {
        return _trmc_x10105;
      });
  }
}
 
 
// Zip two lists together by apply a function `f` to all corresponding elements
// and their index in the list.
// The returned list is only as long as the smallest input list.
export function zipwith_indexed(xs0, ys0, f) /* forall<a,b,c,e> (xs0 : list<a>, ys0 : list<b>, f : (int, a, b) -> e c) -> e list<c> */  {
  return _lift_zipwith_indexed_4796(f, 0, xs0, ys0);
}
 
 
// Return the head of list with a default value in case the list is empty.
export function default_fs_head(xs, $default) /* forall<a> (xs : list<a>, default : a) -> a */  {
  return (xs !== null) ? xs.head : $default;
}
 
 
// Append two lists.
export function _trmc_append(xs, ys, _acc) /* forall<a> (xs : list<a>, ys : list<a>, ctx<list<a>>) -> list<a> */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var _trmc_x10108 = undefined;
     
    var _trmc_x10109 = $std_core_types.Cons(xs.head, _trmc_x10108);
    {
      // tail call
      var _x29 = $std_core_types._cctx_extend(_acc,_trmc_x10109,({obj: _trmc_x10109, field_name: "tail"}));
      xs = xs.tail;
      _acc = _x29;
      continue tailcall;
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc,ys);
  }
}}
 
 
// Append two lists.
export function append(xs_0, ys_0) /* forall<a> (xs : list<a>, ys : list<a>) -> list<a> */  {
  return _trmc_append(xs_0, ys_0, $std_core_types._cctx_empty());
}
 
 
// Append two lists.
export function _lp__plus__plus__rp_(xs, ys) /* forall<a> (xs : list<a>, ys : list<a>) -> list<a> */  {
  return append(xs, ys);
}
 
 
// Element-wise list equality
export function _lp__eq__eq__rp_(xs, ys, _implicit_fs__lp__eq__eq__rp_) /* forall<a> (xs : list<a>, ys : list<a>, ?(==) : (a, a) -> bool) -> bool */  { tailcall: while(1)
{
  if (xs !== null) {
    if (ys === null) {
      return false;
    }
    else {
      var _x30 = _implicit_fs__lp__eq__eq__rp_(xs.head, ys.head);
      if (_x30) {
        {
          // tail call
          xs = xs.tail;
          ys = ys.tail;
          continue tailcall;
        }
      }
      else {
        return false;
      }
    }
  }
  else {
    return (ys === null);
  }
}}
 
 
// Get (zero-based) element `n`  of a list. Return a `:maybe` type.
export function _index(xs, n) /* forall<a> (xs : list<a>, n : int) -> maybe<a> */  { tailcall: while(1)
{
  if (xs !== null) {
    if ($std_core_types._int_gt(n,0)) {
      {
        // tail call
        var _x31 = $std_core_types._int_sub(n,1);
        xs = xs.tail;
        n = _x31;
        continue tailcall;
      }
    }
    else {
      if ($std_core_types._int_eq(n,0)) {
        return $std_core_types.Just(xs.head);
      }
      else {
        return $std_core_types.Nothing;
      }
    }
  }
  else {
    return $std_core_types.Nothing;
  }
}}
 
 
// monadic lift
export function _mlift_all_10435(predicate, xx, _y_x10224) /* forall<a,e> (predicate : (a) -> e bool, xx : list<a>, bool) -> e bool */  {
  if (_y_x10224) {
    return all(xx, predicate);
  }
  else {
    return false;
  }
}
 
 
// Do all elements satisfy a predicate ?
export function all(xs, predicate_0) /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool) -> e bool */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var x_0_10499 = predicate_0(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10224_0 /* bool */ ) {
        return _mlift_all_10435(predicate_0, xs.tail, _y_x10224_0);
      });
    }
    else {
      if (x_0_10499) {
        {
          // tail call
          xs = xs.tail;
          continue tailcall;
        }
      }
      else {
        return false;
      }
    }
  }
  else {
    return true;
  }
}}
 
 
// monadic lift
export function _mlift_any_10436(predicate, xx, _y_x10228) /* forall<a,e> (predicate : (a) -> e bool, xx : list<a>, bool) -> e bool */  {
  if (_y_x10228) {
    return true;
  }
  else {
    return any(xx, predicate);
  }
}
 
 
// Are there any elements in a list that satisfy a predicate ?
export function any(xs, predicate_0) /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool) -> e bool */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var x_0_10502 = predicate_0(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10228_0 /* bool */ ) {
        return _mlift_any_10436(predicate_0, xs.tail, _y_x10228_0);
      });
    }
    else {
      if (x_0_10502) {
        return true;
      }
      else {
        {
          // tail call
          xs = xs.tail;
          continue tailcall;
        }
      }
    }
  }
  else {
    return false;
  }
}}
 
 
// Order on lists
export function cmp(xs, ys, _implicit_fs_cmp) /* forall<a> (xs : list<a>, ys : list<a>, ?cmp : (a, a) -> order) -> order */  { tailcall: while(1)
{
  if (xs !== null) {
    if (ys === null) {
      return $std_core_types.Gt;
    }
    else {
      var _x32 = _implicit_fs_cmp(xs.head, ys.head);
      if (_x32 === 2) {
        {
          // tail call
          xs = xs.tail;
          ys = ys.tail;
          continue tailcall;
        }
      }
      else {
        return _x32;
      }
    }
  }
  else {
    return (ys === null) ? $std_core_types.Eq : $std_core_types.Lt;
  }
}}
 
 
// Concatenate a list of `:maybe` values
export function _trmc_concat_maybe(xs, _acc) /* forall<a> (xs : list<maybe<a>>, ctx<list<a>>) -> list<a> */  { tailcall: while(1)
{
  if (xs !== null) {
    if (xs.head !== null) {
       
      var _trmc_x10110 = undefined;
       
      var _trmc_x10111 = $std_core_types.Cons(xs.head.value, _trmc_x10110);
      {
        // tail call
        var _x33 = $std_core_types._cctx_extend(_acc,_trmc_x10111,({obj: _trmc_x10111, field_name: "tail"}));
        xs = xs.tail;
        _acc = _x33;
        continue tailcall;
      }
    }
    else {
      {
        // tail call
        xs = xs.tail;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}}
 
 
// Concatenate a list of `:maybe` values
export function concat_maybe(xs_0) /* forall<a> (xs : list<maybe<a>>) -> list<a> */  {
  return _trmc_concat_maybe(xs_0, $std_core_types._cctx_empty());
}
 
 
// Drop the first `n` elements of a list (or fewer if the list is shorter than `n`)
export function drop(xs, n) /* forall<a> (xs : list<a>, n : int) -> list<a> */  { tailcall: while(1)
{
  if (xs !== null) {
    if ($std_core_types._int_gt(n,0)){
      {
        // tail call
        var _x34 = $std_core_types._int_sub(n,1);
        xs = xs.tail;
        n = _x34;
        continue tailcall;
      }
    }
  }
  return xs;
}}
 
 
// monadic lift
export function _mlift_drop_while_10437(predicate, xs, xx, _y_x10232) /* forall<a,e> (predicate : (a) -> e bool, xs : list<a>, xx : list<a>, bool) -> e list<a> */  {
  if (_y_x10232) {
    return drop_while(xx, predicate);
  }
  else {
    return xs;
  }
}
 
 
// Drop all initial elements that satisfy `predicate`
export function drop_while(xs_0, predicate_0) /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool) -> e list<a> */  { tailcall: while(1)
{
  if (xs_0 !== null) {
     
    var x_0_10505 = predicate_0(xs_0.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10232_0 /* bool */ ) {
        return _mlift_drop_while_10437(predicate_0, xs_0, xs_0.tail, _y_x10232_0);
      });
    }
    else {
      if (x_0_10505) {
        {
          // tail call
          xs_0 = xs_0.tail;
          continue tailcall;
        }
      }
      else {
        return xs_0;
      }
    }
  }
  else {
    return $std_core_types.Nil;
  }
}}
 
 
// monadic lift
export function _mlift_trmc_filter_10438(_acc, pred, x, xx, _y_x10236) /* forall<a,e> (ctx<list<a>>, pred : (a) -> e bool, x : a, xx : list<a>, bool) -> e list<a> */  {
  if (_y_x10236) {
     
    var _trmc_x10112 = undefined;
     
    var _trmc_x10113 = $std_core_types.Cons(x, _trmc_x10112);
    return _trmc_filter(xx, pred, $std_core_types._cctx_extend(_acc,_trmc_x10113,({obj: _trmc_x10113, field_name: "tail"})));
  }
  else {
    return _trmc_filter(xx, pred, _acc);
  }
}
 
 
// monadic lift
export function _mlift_trmcm_filter_10439(_accm, pred_0, x_0, xx_0, _y_x10241) /* forall<a,e> ((list<a>) -> list<a>, pred : (a) -> e bool, x : a, xx : list<a>, bool) -> e list<a> */  {
  if (_y_x10241) {
    return _trmcm_filter(xx_0, pred_0, function(_trmc_x10115 /* list<1742> */ ) {
        return _accm($std_core_types.Cons(x_0, _trmc_x10115));
      });
  }
  else {
    return _trmcm_filter(xx_0, pred_0, _accm);
  }
}
 
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filter([1,2,3],odd?) == [1,3]`
export function _trmc_filter(xs, pred_1, _acc_0) /* forall<a,e> (xs : list<a>, pred : (a) -> e bool, ctx<list<a>>) -> e list<a> */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var x_2_10508 = pred_1(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10236_0 /* bool */ ) {
        return _mlift_trmc_filter_10438(_acc_0, pred_1, xs.head, xs.tail, _y_x10236_0);
      });
    }
    else {
      if (x_2_10508) {
         
        var _trmc_x10112_0 = undefined;
         
        var _trmc_x10113_0 = $std_core_types.Cons(xs.head, _trmc_x10112_0);
        {
          // tail call
          var _x35 = $std_core_types._cctx_extend(_acc_0,_trmc_x10113_0,({obj: _trmc_x10113_0, field_name: "tail"}));
          xs = xs.tail;
          _acc_0 = _x35;
          continue tailcall;
        }
      }
      else {
        {
          // tail call
          xs = xs.tail;
          continue tailcall;
        }
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filter([1,2,3],odd?) == [1,3]`
export function _trmcm_filter(xs_0, pred_2, _accm_0) /* forall<a,e> (xs : list<a>, pred : (a) -> e bool, (list<a>) -> list<a>) -> e list<a> */  { tailcall: while(1)
{
  if (xs_0 !== null) {
     
    var x_4_10511 = pred_2(xs_0.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10241_0 /* bool */ ) {
        return _mlift_trmcm_filter_10439(_accm_0, pred_2, xs_0.head, xs_0.tail, _y_x10241_0);
      });
    }
    else {
      if (x_4_10511) {
        {
          // tail call
          var _x38 = function(__at_accm_036 /* (list<1742>) -> list<1742> */ , _x_337 /* 1742 */ ) {
            return function(_trmc_x10115_0 /* list<1742> */ ) {
              return __at_accm_036($std_core_types.Cons(_x_337, _trmc_x10115_0));
            };
          }(_accm_0, xs_0.head);
          xs_0 = xs_0.tail;
          _accm_0 = _x38;
          continue tailcall;
        }
      }
      else {
        {
          // tail call
          xs_0 = xs_0.tail;
          continue tailcall;
        }
      }
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filter([1,2,3],odd?) == [1,3]`
export function filter(xs_1, pred_3) /* forall<a,e> (xs : list<a>, pred : (a) -> e bool) -> e list<a> */  {
  var _x39 = $std_core_hnd._evv_is_affine();
  if (_x39) {
    return _trmc_filter(xs_1, pred_3, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_filter(xs_1, pred_3, function(_trmc_x10114 /* list<1742> */ ) {
        return _trmc_x10114;
      });
  }
}
 
 
// monadic lift
export function _mlift_trmc_filter_map_10440(_acc, pred, xx, _y_x10249) /* forall<a,b,e> (ctx<list<b>>, pred : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e list<b> */  {
  if (_y_x10249 === null) {
    return _trmc_filter_map(xx, pred, _acc);
  }
  else {
     
    var _trmc_x10116 = undefined;
     
    var _trmc_x10117 = $std_core_types.Cons(_y_x10249.value, _trmc_x10116);
    return _trmc_filter_map(xx, pred, $std_core_types._cctx_extend(_acc,_trmc_x10117,({obj: _trmc_x10117, field_name: "tail"})));
  }
}
 
 
// monadic lift
export function _mlift_trmcm_filter_map_10441(_accm, pred_0, xx_0, _y_x10254) /* forall<a,b,e> ((list<b>) -> list<b>, pred : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e list<b> */  {
  if (_y_x10254 === null) {
    return _trmcm_filter_map(xx_0, pred_0, _accm);
  }
  else {
    return _trmcm_filter_map(xx_0, pred_0, function(_trmc_x10119 /* list<1810> */ ) {
        return _accm($std_core_types.Cons(_y_x10254.value, _trmc_x10119));
      });
  }
}
 
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filterMap([1,2,3],fn(i) { if i.odd? then Nothing else Just(i*i) }) == [4]`
export function _trmc_filter_map(xs, pred_1, _acc_0) /* forall<a,b,e> (xs : list<a>, pred : (a) -> e maybe<b>, ctx<list<b>>) -> e list<b> */  { tailcall: while(1)
{
  if (xs === null) {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
  else {
     
    var x_0_10514 = pred_1(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10249_0 /* maybe<1810> */ ) {
        return _mlift_trmc_filter_map_10440(_acc_0, pred_1, xs.tail, _y_x10249_0);
      });
    }
    else {
      if (x_0_10514 === null) {
        {
          // tail call
          xs = xs.tail;
          continue tailcall;
        }
      }
      else {
         
        var _trmc_x10116_0 = undefined;
         
        var _trmc_x10117_0 = $std_core_types.Cons(x_0_10514.value, _trmc_x10116_0);
        {
          // tail call
          var _x40 = $std_core_types._cctx_extend(_acc_0,_trmc_x10117_0,({obj: _trmc_x10117_0, field_name: "tail"}));
          xs = xs.tail;
          _acc_0 = _x40;
          continue tailcall;
        }
      }
    }
  }
}}
 
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filterMap([1,2,3],fn(i) { if i.odd? then Nothing else Just(i*i) }) == [4]`
export function _trmcm_filter_map(xs_0, pred_2, _accm_0) /* forall<a,b,e> (xs : list<a>, pred : (a) -> e maybe<b>, (list<b>) -> list<b>) -> e list<b> */  { tailcall: while(1)
{
  if (xs_0 === null) {
    return _accm_0($std_core_types.Nil);
  }
  else {
     
    var x_2_10517 = pred_2(xs_0.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10254_0 /* maybe<1810> */ ) {
        return _mlift_trmcm_filter_map_10441(_accm_0, pred_2, xs_0.tail, _y_x10254_0);
      });
    }
    else {
      if (x_2_10517 === null) {
        {
          // tail call
          xs_0 = xs_0.tail;
          continue tailcall;
        }
      }
      else {
        {
          // tail call
          var _x43 = function(__at_accm_041 /* (list<1810>) -> list<1810> */ , _y_242 /* 1810 */ ) {
            return function(_trmc_x10119_0 /* list<1810> */ ) {
              return __at_accm_041($std_core_types.Cons(_y_242, _trmc_x10119_0));
            };
          }(_accm_0, x_2_10517.value);
          xs_0 = xs_0.tail;
          _accm_0 = _x43;
          continue tailcall;
        }
      }
    }
  }
}}
 
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filterMap([1,2,3],fn(i) { if i.odd? then Nothing else Just(i*i) }) == [4]`
export function filter_map(xs_1, pred_3) /* forall<a,b,e> (xs : list<a>, pred : (a) -> e maybe<b>) -> e list<b> */  {
  var _x44 = $std_core_hnd._evv_is_affine();
  if (_x44) {
    return _trmc_filter_map(xs_1, pred_3, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_filter_map(xs_1, pred_3, function(_trmc_x10118 /* list<1810> */ ) {
        return _trmc_x10118;
      });
  }
}
 
 
// monadic lift
export function _mlift_foreach_while_10442(action, xx, _y_x10262) /* forall<a,b,e> (action : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e maybe<b> */  {
  if (_y_x10262 === null) {
    return foreach_while(xx, action);
  }
  else {
    return _y_x10262;
  }
}
 
 
// Invoke `action` for each element of a list while `action` return `Nothing`
export function foreach_while(xs, action_0) /* forall<a,b,e> (xs : list<a>, action : (a) -> e maybe<b>) -> e maybe<b> */  { tailcall: while(1)
{
  if (xs === null) {
    return $std_core_types.Nothing;
  }
  else {
     
    var x_0_10520 = action_0(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10262_0 /* maybe<1861> */ ) {
        return _mlift_foreach_while_10442(action_0, xs.tail, _y_x10262_0);
      });
    }
    else {
      if (x_0_10520 === null) {
        {
          // tail call
          xs = xs.tail;
          continue tailcall;
        }
      }
      else {
        return x_0_10520;
      }
    }
  }
}}
 
 
// monadic lift
export function _mlift_find_10443(x, _y_x10266) /* forall<a,e> (x : a, bool) -> e maybe<a> */  {
  if (_y_x10266) {
    return $std_core_types.Just(x);
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
 
// Find the first element satisfying some predicate
export function find(xs, pred) /* forall<a,e> (xs : list<a>, pred : (a) -> e bool) -> e maybe<a> */  {
  return foreach_while(xs, function(x /* 1906 */ ) {
       
      var x_0_10523 = pred(x);
       
      function next_10524(_y_x10266) /* (bool) -> 1907 maybe<1906> */  {
        if (_y_x10266) {
          return $std_core_types.Just(x);
        }
        else {
          return $std_core_types.Nothing;
        }
      }
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(next_10524);
      }
      else {
        return next_10524(x_0_10523);
      }
    });
}
 
 
// Find the first element satisfying some predicate and return it.
export function find_maybe(xs, pred) /* forall<a,b,e> (xs : list<a>, pred : (a) -> e maybe<b>) -> e maybe<b> */  {
  return foreach_while(xs, pred);
}
 
 
// monadic lift
export function _mlift_trmc_flatmap_maybe_10444(_acc, f, xx, _y_x10269) /* forall<a,b,e> (ctx<list<b>>, f : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e list<b> */  {
  if (_y_x10269 !== null) {
     
    var _trmc_x10120 = undefined;
     
    var _trmc_x10121 = $std_core_types.Cons(_y_x10269.value, _trmc_x10120);
    return _trmc_flatmap_maybe(xx, f, $std_core_types._cctx_extend(_acc,_trmc_x10121,({obj: _trmc_x10121, field_name: "tail"})));
  }
  else {
    return _trmc_flatmap_maybe(xx, f, _acc);
  }
}
 
 
// monadic lift
export function _mlift_trmcm_flatmap_maybe_10445(_accm, f_0, xx_0, _y_x10274) /* forall<a,b,e> ((list<b>) -> list<b>, f : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e list<b> */  {
  if (_y_x10274 !== null) {
    return _trmcm_flatmap_maybe(xx_0, f_0, function(_trmc_x10123 /* list<2008> */ ) {
        return _accm($std_core_types.Cons(_y_x10274.value, _trmc_x10123));
      });
  }
  else {
    return _trmcm_flatmap_maybe(xx_0, f_0, _accm);
  }
}
 
 
// Concatenate the `Just` result elements from applying a function to all elements.
export function _trmc_flatmap_maybe(xs, f_1, _acc_0) /* forall<a,b,e> (xs : list<a>, f : (a) -> e maybe<b>, ctx<list<b>>) -> e list<b> */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var x_0_10527 = f_1(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10269_0 /* maybe<2008> */ ) {
        return _mlift_trmc_flatmap_maybe_10444(_acc_0, f_1, xs.tail, _y_x10269_0);
      });
    }
    else {
      if (x_0_10527 !== null) {
         
        var _trmc_x10120_0 = undefined;
         
        var _trmc_x10121_0 = $std_core_types.Cons(x_0_10527.value, _trmc_x10120_0);
        {
          // tail call
          var _x45 = $std_core_types._cctx_extend(_acc_0,_trmc_x10121_0,({obj: _trmc_x10121_0, field_name: "tail"}));
          xs = xs.tail;
          _acc_0 = _x45;
          continue tailcall;
        }
      }
      else {
        {
          // tail call
          xs = xs.tail;
          continue tailcall;
        }
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// Concatenate the `Just` result elements from applying a function to all elements.
export function _trmcm_flatmap_maybe(xs_0, f_2, _accm_0) /* forall<a,b,e> (xs : list<a>, f : (a) -> e maybe<b>, (list<b>) -> list<b>) -> e list<b> */  { tailcall: while(1)
{
  if (xs_0 !== null) {
     
    var x_2_10530 = f_2(xs_0.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10274_0 /* maybe<2008> */ ) {
        return _mlift_trmcm_flatmap_maybe_10445(_accm_0, f_2, xs_0.tail, _y_x10274_0);
      });
    }
    else {
      if (x_2_10530 !== null) {
        {
          // tail call
          var _x48 = function(__at_accm_046 /* (list<2008>) -> list<2008> */ , _y_247 /* 2008 */ ) {
            return function(_trmc_x10123_0 /* list<2008> */ ) {
              return __at_accm_046($std_core_types.Cons(_y_247, _trmc_x10123_0));
            };
          }(_accm_0, x_2_10530.value);
          xs_0 = xs_0.tail;
          _accm_0 = _x48;
          continue tailcall;
        }
      }
      else {
        {
          // tail call
          xs_0 = xs_0.tail;
          continue tailcall;
        }
      }
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// Concatenate the `Just` result elements from applying a function to all elements.
export function flatmap_maybe(xs_1, f_3) /* forall<a,b,e> (xs : list<a>, f : (a) -> e maybe<b>) -> e list<b> */  {
  var _x49 = $std_core_hnd._evv_is_affine();
  if (_x49) {
    return _trmc_flatmap_maybe(xs_1, f_3, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_flatmap_maybe(xs_1, f_3, function(_trmc_x10122 /* list<2008> */ ) {
        return _trmc_x10122;
      });
  }
}
 
 
// monadic lift
export function _mlift_foldl_10446(f, xx, _y_x10282) /* forall<a,b,e> (f : (b, a) -> e b, xx : list<a>, b) -> e b */  {
  return foldl(xx, _y_x10282, f);
}
 
 
// Fold a list from the left, i.e. `foldl([1,2],0,(+)) == (0+1)+2`
// Since `foldl` is tail recursive, it is preferred over `foldr` when using an associative function `f`
export function foldl(xs, z, f_0) /* forall<a,b,e> (xs : list<a>, z : b, f : (b, a) -> e b) -> e b */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var x_0_10533 = f_0(z, xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10282_0 /* 2053 */ ) {
        return _mlift_foldl_10446(f_0, xs.tail, _y_x10282_0);
      });
    }
    else {
      {
        // tail call
        xs = xs.tail;
        z = x_0_10533;
        continue tailcall;
      }
    }
  }
  else {
    return z;
  }
}}
 
export function foldl1(xs, f) /* forall<a,e> (xs : list<a>, f : (a, a) -> <exn|e> a) -> <exn|e> a */  {
  if (xs !== null) {
    return foldl(xs.tail, xs.head, f);
  }
  else {
    return $std_core_hnd._open_at2($std_core_hnd._evv_index($std_core_exn._tag_exn), $std_core_exn.$throw, "unexpected Nil in std/core/foldl1");
  }
}
 
 
// Reverse a list.
export function reverse(xs) /* forall<a> (xs : list<a>) -> list<a> */  {
  return _lift_reverse_append_4790($std_core_types.Nil, xs);
}
 
 
// Fold a list from the right, i.e. `foldr([1,2],0,(+)) == 1+(2+0)`
// Note, `foldr` is less efficient than `foldl` as it reverses the list first.
export function foldr(xs, z, f) /* forall<a,b,e> (xs : list<a>, z : b, f : (a, b) -> e b) -> e b */  {
  return foldl(_lift_reverse_append_4790($std_core_types.Nil, xs), z, function(x /* 2162 */ , y /* 2161 */ ) {
      return f(y, x);
    });
}
 
export function foldr1(xs, f) /* forall<a,e> (xs : list<a>, f : (a, a) -> <exn|e> a) -> <exn|e> a */  {
   
  var xs_0_10024 = _lift_reverse_append_4790($std_core_types.Nil, xs);
  if (xs_0_10024 !== null) {
    return foldl(xs_0_10024.tail, xs_0_10024.head, f);
  }
  else {
    return $std_core_hnd._open_at2($std_core_hnd._evv_index($std_core_exn._tag_exn), $std_core_exn.$throw, "unexpected Nil in std/core/foldl1");
  }
}
 
 
// monadic lift
export function _mlift_foreach_10447(action, xx, wild__) /* forall<a,e> (action : (a) -> e (), xx : list<a>, wild_ : ()) -> e () */  {
  return foreach(xx, action);
}
 
 
// Invoke `action` for each element of a list
export function foreach(xs, action_0) /* forall<a,e> (xs : list<a>, action : (a) -> e ()) -> e () */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var x_0_10536 = action_0(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
        return _mlift_foreach_10447(action_0, xs.tail, wild___0);
      });
    }
    else {
      {
        // tail call
        xs = xs.tail;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types.Unit;
  }
}}
 
 
// monadic lift
export function _mlift_foreach_indexed_10448(i, _y_x10299) /* forall<h,e> (i : local-var<h,int>, int) -> <local<h>|e> () */  {
  return ((i).value = ($std_core_types._int_add(_y_x10299,1)));
}
 
 
// monadic lift
export function _mlift_foreach_indexed_10449(i, wild__) /* forall<h,e> (i : local-var<h,int>, wild_ : ()) -> <local<h>|e> () */  {
   
  var x_10539 = ((i).value);
   
  function next_10540(_y_x10299) /* (int) -> <local<2329>|2336> () */  {
    return ((i).value = ($std_core_types._int_add(_y_x10299,1)));
  }
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(next_10540);
  }
  else {
    return next_10540(x_10539);
  }
}
 
 
// monadic lift
export function _mlift_foreach_indexed_10450(action, i, x, j) /* forall<h,a,e> (action : (int, a) -> e (), i : local-var<h,int>, x : a, j : int) -> <local<h>|e> () */  {
   
  var x_0_10543 = action(j, x);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild__ /* () */ ) {
      return _mlift_foreach_indexed_10449(i, wild__);
    });
  }
  else {
    return _mlift_foreach_indexed_10449(i, x_0_10543);
  }
}
 
 
// Invoke `action` for each element of a list, passing also the position of the element.
export function foreach_indexed(xs, action) /* forall<a,e> (xs : list<a>, action : (int, a) -> e ()) -> e () */  {
  return function() {
     
    var loc = { value: 0 };
     
    var res = foreach(xs, function(x /* 2335 */ ) {
         
        var x_0_10548 = ((loc).value);
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(function(j /* int */ ) {
            return _mlift_foreach_indexed_10450(action, loc, x, j);
          });
        }
        else {
          return _mlift_foreach_indexed_10450(action, loc, x, x_0_10548);
        }
      });
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
 
// monadic lift
export function _mlift_index_of_acc_10451(idx, pred, xx, _y_x10304) /* forall<a,e> (idx : int, pred : (a) -> e bool, xx : list<a>, bool) -> e int */  {
  if (_y_x10304) {
    return idx;
  }
  else {
    return index_of_acc(xx, pred, $std_core_types._int_add(idx,1));
  }
}
 
export function index_of_acc(xs, pred_0, idx_0) /* forall<a,e> (xs : list<a>, pred : (a) -> e bool, idx : int) -> e int */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var x_0_10550 = pred_0(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10304_0 /* bool */ ) {
        return _mlift_index_of_acc_10451(idx_0, pred_0, xs.tail, _y_x10304_0);
      });
    }
    else {
      if (x_0_10550) {
        return idx_0;
      }
      else {
        {
          // tail call
          var _x50 = $std_core_types._int_add(idx_0,1);
          xs = xs.tail;
          idx_0 = _x50;
          continue tailcall;
        }
      }
    }
  }
  else {
    return -1;
  }
}}
 
 
// Returns the index of the first element where `pred` holds, or `-1` if no such element exists.
export function index_of(xs, pred) /* forall<a,e> (xs : list<a>, pred : (a) -> e bool) -> e int */  {
  return index_of_acc(xs, pred, 0);
}
 
 
// Return the list without its last element.
// Return an empty list for an empty list.
export function _trmc_init(xs, _acc) /* forall<a> (xs : list<a>, ctx<list<a>>) -> list<a> */  { tailcall: while(1)
{
  if (xs !== null && xs.tail !== null) {
     
    var _trmc_x10124 = undefined;
     
    var _trmc_x10125 = $std_core_types.Cons(xs.head, _trmc_x10124);
    {
      // tail call
      var _x51 = $std_core_types._cctx_extend(_acc,_trmc_x10125,({obj: _trmc_x10125, field_name: "tail"}));
      xs = xs.tail;
      _acc = _x51;
      continue tailcall;
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}}
 
 
// Return the list without its last element.
// Return an empty list for an empty list.
export function init(xs_0) /* forall<a> (xs : list<a>) -> list<a> */  {
  return _trmc_init(xs_0, $std_core_types._cctx_empty());
}
 
 
// lifted local: joinsep, join-acc
export function _lift_joinsep_4797(sep, ys, acc) /* (sep : string, ys : list<string>, acc : string) -> string */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var acc_0_10030 = $std_core_types._lp__plus__plus__rp_(acc, $std_core_types._lp__plus__plus__rp_(sep, ys.head));
    {
      // tail call
      ys = ys.tail;
      acc = acc_0_10030;
      continue tailcall;
    }
  }
  else {
    return acc;
  }
}}
 
 
// Concatenate all strings in a list
export function joinsep(xs, sep) /* (xs : list<string>, sep : string) -> string */  {
  if (xs === null) {
    return "";
  }
  else {
    return _lift_joinsep_4797(sep, xs.tail, xs.head);
  }
}
 
 
// Concatenate all strings in a list
export function join(xs) /* (xs : list<string>) -> string */  {
  if (xs === null) {
    return "";
  }
  else {
    return _lift_joinsep_4797("", xs.tail, xs.head);
  }
}
 
 
// Append `end` to each string in the list `xs` and join them all together.\
// `join-end([],end) === ""`\
// `join-end(["a","b"],"/") === "a/b/"`
export function join_end(xs, end) /* (xs : list<string>, end : string) -> string */  {
  if (xs === null) {
    return "";
  }
  else {
    if (xs === null) {
      var _x52 = "";
    }
    else {
      var _x52 = _lift_joinsep_4797(end, xs.tail, xs.head);
    }
    return $std_core_types._lp__plus__plus__rp_(_x52, end);
  }
}
 
 
// Return the last element of a list (or `Nothing` for the empty list)
export function last(xs) /* forall<a> (xs : list<a>) -> maybe<a> */  { tailcall: while(1)
{
  if (xs !== null && xs.tail === null) {
    return $std_core_types.Just(xs.head);
  }
  else if (xs !== null) {
    {
      // tail call
      xs = xs.tail;
      continue tailcall;
    }
  }
  else {
    return $std_core_types.Nothing;
  }
}}
 
 
// Take the first `n` elements of a list (or fewer if the list is shorter than `n`)
export function _trmc_take(xs, n, _acc) /* forall<a> (xs : list<a>, n : int, ctx<list<a>>) -> list<a> */  { tailcall: while(1)
{
  if (xs !== null) {
    if ($std_core_types._int_gt(n,0)){
       
      var _trmc_x10126 = undefined;
       
      var _trmc_x10127 = $std_core_types.Cons(xs.head, _trmc_x10126);
      {
        // tail call
        var _x53 = $std_core_types._int_sub(n,1);
        var _x54 = $std_core_types._cctx_extend(_acc,_trmc_x10127,({obj: _trmc_x10127, field_name: "tail"}));
        xs = xs.tail;
        n = _x53;
        _acc = _x54;
        continue tailcall;
      }
    }
  }
  return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
}}
 
 
// Take the first `n` elements of a list (or fewer if the list is shorter than `n`)
export function take(xs_0, n_0) /* forall<a> (xs : list<a>, n : int) -> list<a> */  {
  return _trmc_take(xs_0, n_0, $std_core_types._cctx_empty());
}
 
 
// split a list at position `n`
export function split(xs, n) /* forall<a> (xs : list<a>, n : int) -> (list<a>, list<a>) */  {
  return $std_core_types.Tuple2(take(xs, n), drop(xs, n));
}
 
 
// Split a string into a list of lines
export function lines(s) /* (s : string) -> list<string> */  {
   
  var v_10012 = ((s).split(("\n")));
  return $std_core_vector.vlist(v_10012);
}
 
 
// Returns an integer list of increasing elements from `lo`  to `hi`
// (including both `lo`  and `hi` ).
// If `lo > hi`  the function returns the empty list.
export function _trmc_list(lo, hi, _acc) /* (lo : int, hi : int, ctx<list<int>>) -> list<int> */  { tailcall: while(1)
{
  if ($std_core_types._int_le(lo,hi)) {
     
    var _trmc_x10128 = undefined;
     
    var _trmc_x10129 = $std_core_types.Cons(lo, _trmc_x10128);
    {
      // tail call
      var _x55 = $std_core_types._int_add(lo,1);
      var _x56 = $std_core_types._cctx_extend(_acc,_trmc_x10129,({obj: _trmc_x10129, field_name: "tail"}));
      lo = _x55;
      _acc = _x56;
      continue tailcall;
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}}
 
 
// Returns an integer list of increasing elements from `lo`  to `hi`
// (including both `lo`  and `hi` ).
// If `lo > hi`  the function returns the empty list.
export function list(lo_0, hi_0) /* (lo : int, hi : int) -> list<int> */  {
  return _trmc_list(lo_0, hi_0, $std_core_types._cctx_empty());
}
 
 
// monadic lift
export function _mlift_trmc_map_10452(_acc, f, xx, _trmc_x10130) /* forall<a,b,e> (ctx<list<b>>, f : (a) -> e b, xx : list<a>, b) -> e list<b> */  {
   
  var _trmc_x10131 = undefined;
   
  var _trmc_x10132 = $std_core_types.Cons(_trmc_x10130, _trmc_x10131);
  return _trmc_map(xx, f, $std_core_types._cctx_extend(_acc,_trmc_x10132,({obj: _trmc_x10132, field_name: "tail"})));
}
 
 
// monadic lift
export function _mlift_trmcm_map_10453(_accm, f_0, xx_0, _trmc_x10135) /* forall<a,b,e> ((list<b>) -> list<b>, f : (a) -> e b, xx : list<a>, b) -> e list<b> */  {
  return _trmcm_map(xx_0, f_0, function(_trmc_x10134 /* list<3010> */ ) {
      return _accm($std_core_types.Cons(_trmc_x10135, _trmc_x10134));
    });
}
 
 
// Apply a function `f`  to each element of the input list in sequence.
export function _trmc_map(xs, f_1, _acc_0) /* forall<a,b,e> (xs : list<a>, f : (a) -> e b, ctx<list<b>>) -> e list<b> */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var x_0_10553 = f_1(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10130_0 /* 3010 */ ) {
        return _mlift_trmc_map_10452(_acc_0, f_1, xs.tail, _trmc_x10130_0);
      });
    }
    else {
       
      var _trmc_x10131_0 = undefined;
       
      var _trmc_x10132_0 = $std_core_types.Cons(x_0_10553, _trmc_x10131_0);
      {
        // tail call
        var _x57 = $std_core_types._cctx_extend(_acc_0,_trmc_x10132_0,({obj: _trmc_x10132_0, field_name: "tail"}));
        xs = xs.tail;
        _acc_0 = _x57;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// Apply a function `f`  to each element of the input list in sequence.
export function _trmcm_map(xs_0, f_2, _accm_0) /* forall<a,b,e> (xs : list<a>, f : (a) -> e b, (list<b>) -> list<b>) -> e list<b> */  { tailcall: while(1)
{
  if (xs_0 !== null) {
     
    var x_2_10556 = f_2(xs_0.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10135_0 /* 3010 */ ) {
        return _mlift_trmcm_map_10453(_accm_0, f_2, xs_0.tail, _trmc_x10135_0);
      });
    }
    else {
      {
        // tail call
        var _x60 = function(__at_accm_058 /* (list<3010>) -> list<3010> */ , _x_2_1055659 /* 3010 */ ) {
          return function(_trmc_x10134_0 /* list<3010> */ ) {
            return __at_accm_058($std_core_types.Cons(_x_2_1055659, _trmc_x10134_0));
          };
        }(_accm_0, x_2_10556);
        xs_0 = xs_0.tail;
        _accm_0 = _x60;
        continue tailcall;
      }
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// Apply a function `f`  to each element of the input list in sequence.
export function map(xs_1, f_3) /* forall<a,b,e> (xs : list<a>, f : (a) -> e b) -> e list<b> */  {
  var _x61 = $std_core_hnd._evv_is_affine();
  if (_x61) {
    return _trmc_map(xs_1, f_3, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_map(xs_1, f_3, function(_trmc_x10133 /* list<3010> */ ) {
        return _trmc_x10133;
      });
  }
}
 
 
// Create a list of characters from `lo`  to `hi`  (including `hi`).
export function char_fs_list(lo, hi) /* (lo : char, hi : char) -> list<char> */  {
  return map(list(lo, hi), (function(_x62) {
      return (_x62);
    }));
}
 
 
// monadic lift
export function function_fs__mlift_trmc_list_10454(_acc, f, hi, lo, _trmc_x10136) /* forall<a,e> (ctx<list<a>>, f : (int) -> e a, hi : int, lo : int, a) -> e list<a> */  {
   
  var _trmc_x10137 = undefined;
   
  var _trmc_x10138 = $std_core_types.Cons(_trmc_x10136, _trmc_x10137);
  return function_fs__trmc_list($std_core_types._int_add(lo,1), hi, f, $std_core_types._cctx_extend(_acc,_trmc_x10138,({obj: _trmc_x10138, field_name: "tail"})));
}
 
 
// monadic lift
export function function_fs__mlift_trmcm_list_10455(_accm, f_0, hi_0, lo_0, _trmc_x10141) /* forall<a,e> ((list<a>) -> list<a>, f : (int) -> e a, hi : int, lo : int, a) -> e list<a> */  {
  return function_fs__trmcm_list($std_core_types._int_add(lo_0,1), hi_0, f_0, function(_trmc_x10140 /* list<2811> */ ) {
      return _accm($std_core_types.Cons(_trmc_x10141, _trmc_x10140));
    });
}
 
 
// Applies a function `f` to list of increasing elements from `lo`  to `hi`
// (including both `lo`  and `hi` ).
// If `lo > hi`  the function returns the empty list.
export function function_fs__trmc_list(lo_1, hi_1, f_1, _acc_0) /* forall<a,e> (lo : int, hi : int, f : (int) -> e a, ctx<list<a>>) -> e list<a> */  { tailcall: while(1)
{
  if ($std_core_types._int_le(lo_1,hi_1)) {
     
    var x_10559 = f_1(lo_1);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10136_0 /* 2811 */ ) {
        return function_fs__mlift_trmc_list_10454(_acc_0, f_1, hi_1, lo_1, _trmc_x10136_0);
      });
    }
    else {
       
      var _trmc_x10137_0 = undefined;
       
      var _trmc_x10138_0 = $std_core_types.Cons(x_10559, _trmc_x10137_0);
      {
        // tail call
        var _x63 = $std_core_types._int_add(lo_1,1);
        var _x64 = $std_core_types._cctx_extend(_acc_0,_trmc_x10138_0,({obj: _trmc_x10138_0, field_name: "tail"}));
        lo_1 = _x63;
        _acc_0 = _x64;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// Applies a function `f` to list of increasing elements from `lo`  to `hi`
// (including both `lo`  and `hi` ).
// If `lo > hi`  the function returns the empty list.
export function function_fs__trmcm_list(lo_2, hi_2, f_2, _accm_0) /* forall<a,e> (lo : int, hi : int, f : (int) -> e a, (list<a>) -> list<a>) -> e list<a> */  { tailcall: while(1)
{
  if ($std_core_types._int_le(lo_2,hi_2)) {
     
    var x_0_10562 = f_2(lo_2);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10141_0 /* 2811 */ ) {
        return function_fs__mlift_trmcm_list_10455(_accm_0, f_2, hi_2, lo_2, _trmc_x10141_0);
      });
    }
    else {
      {
        // tail call
        var _x67 = $std_core_types._int_add(lo_2,1);
        var _x68 = function(__at_accm_065 /* (list<2811>) -> list<2811> */ , _x_0_1056266 /* 2811 */ ) {
          return function(_trmc_x10140_0 /* list<2811> */ ) {
            return __at_accm_065($std_core_types.Cons(_x_0_1056266, _trmc_x10140_0));
          };
        }(_accm_0, x_0_10562);
        lo_2 = _x67;
        _accm_0 = _x68;
        continue tailcall;
      }
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// Applies a function `f` to list of increasing elements from `lo`  to `hi`
// (including both `lo`  and `hi` ).
// If `lo > hi`  the function returns the empty list.
export function function_fs_list(lo_3, hi_3, f_3) /* forall<a,e> (lo : int, hi : int, f : (int) -> e a) -> e list<a> */  {
  var _x69 = $std_core_hnd._evv_is_affine();
  if (_x69) {
    return function_fs__trmc_list(lo_3, hi_3, f_3, $std_core_types._cctx_empty());
  }
  else {
    return function_fs__trmcm_list(lo_3, hi_3, f_3, function(_trmc_x10139 /* list<2811> */ ) {
        return _trmc_x10139;
      });
  }
}
 
 
// Returns an integer list of increasing elements from `lo`  to `hi` with stride `stride`.
// If `lo > hi`  the function returns the empty list.
export function stride_fs__trmc_list(lo, hi, stride, _acc) /* (lo : int, hi : int, stride : int, ctx<list<int>>) -> list<int> */  { tailcall: while(1)
{
  if ($std_core_types._int_le(lo,hi)) {
     
    var _trmc_x10142 = undefined;
     
    var _trmc_x10143 = $std_core_types.Cons(lo, _trmc_x10142);
    {
      // tail call
      var _x70 = $std_core_types._int_add(lo,stride);
      var _x71 = $std_core_types._cctx_extend(_acc,_trmc_x10143,({obj: _trmc_x10143, field_name: "tail"}));
      lo = _x70;
      _acc = _x71;
      continue tailcall;
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}}
 
 
// Returns an integer list of increasing elements from `lo`  to `hi` with stride `stride`.
// If `lo > hi`  the function returns the empty list.
export function stride_fs_list(lo_0, hi_0, stride_0) /* (lo : int, hi : int, stride : int) -> list<int> */  {
  return stride_fs__trmc_list(lo_0, hi_0, stride_0, $std_core_types._cctx_empty());
}
 
 
// monadic lift
export function stridefunction_fs__mlift_trmc_list_10456(_acc, f, hi, lo, stride, _trmc_x10144) /* forall<a,e> (ctx<list<a>>, f : (int) -> e a, hi : int, lo : int, stride : int, a) -> e list<a> */  {
   
  var _trmc_x10145 = undefined;
   
  var _trmc_x10146 = $std_core_types.Cons(_trmc_x10144, _trmc_x10145);
  return stridefunction_fs__trmc_list($std_core_types._int_add(lo,stride), hi, stride, f, $std_core_types._cctx_extend(_acc,_trmc_x10146,({obj: _trmc_x10146, field_name: "tail"})));
}
 
 
// monadic lift
export function stridefunction_fs__mlift_trmcm_list_10457(_accm, f_0, hi_0, lo_0, stride_0, _trmc_x10149) /* forall<a,e> ((list<a>) -> list<a>, f : (int) -> e a, hi : int, lo : int, stride : int, a) -> e list<a> */  {
  return stridefunction_fs__trmcm_list($std_core_types._int_add(lo_0,stride_0), hi_0, stride_0, f_0, function(_trmc_x10148 /* list<2925> */ ) {
      return _accm($std_core_types.Cons(_trmc_x10149, _trmc_x10148));
    });
}
 
 
// Returns an integer list of increasing elements from `lo`  to `hi` with stride `stride`.
// If `lo > hi`  the function returns the empty list.
export function stridefunction_fs__trmc_list(lo_1, hi_1, stride_1, f_1, _acc_0) /* forall<a,e> (lo : int, hi : int, stride : int, f : (int) -> e a, ctx<list<a>>) -> e list<a> */  { tailcall: while(1)
{
  if ($std_core_types._int_le(lo_1,hi_1)) {
     
    var x_10565 = f_1(lo_1);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10144_0 /* 2925 */ ) {
        return stridefunction_fs__mlift_trmc_list_10456(_acc_0, f_1, hi_1, lo_1, stride_1, _trmc_x10144_0);
      });
    }
    else {
       
      var _trmc_x10145_0 = undefined;
       
      var _trmc_x10146_0 = $std_core_types.Cons(x_10565, _trmc_x10145_0);
      {
        // tail call
        var _x72 = $std_core_types._int_add(lo_1,stride_1);
        var _x73 = $std_core_types._cctx_extend(_acc_0,_trmc_x10146_0,({obj: _trmc_x10146_0, field_name: "tail"}));
        lo_1 = _x72;
        _acc_0 = _x73;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// Returns an integer list of increasing elements from `lo`  to `hi` with stride `stride`.
// If `lo > hi`  the function returns the empty list.
export function stridefunction_fs__trmcm_list(lo_2, hi_2, stride_2, f_2, _accm_0) /* forall<a,e> (lo : int, hi : int, stride : int, f : (int) -> e a, (list<a>) -> list<a>) -> e list<a> */  { tailcall: while(1)
{
  if ($std_core_types._int_le(lo_2,hi_2)) {
     
    var x_0_10568 = f_2(lo_2);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_trmc_x10149_0 /* 2925 */ ) {
        return stridefunction_fs__mlift_trmcm_list_10457(_accm_0, f_2, hi_2, lo_2, stride_2, _trmc_x10149_0);
      });
    }
    else {
      {
        // tail call
        var _x76 = $std_core_types._int_add(lo_2,stride_2);
        var _x77 = function(__at_accm_074 /* (list<2925>) -> list<2925> */ , _x_0_1056875 /* 2925 */ ) {
          return function(_trmc_x10148_0 /* list<2925> */ ) {
            return __at_accm_074($std_core_types.Cons(_x_0_1056875, _trmc_x10148_0));
          };
        }(_accm_0, x_0_10568);
        lo_2 = _x76;
        _accm_0 = _x77;
        continue tailcall;
      }
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// Returns an integer list of increasing elements from `lo`  to `hi` with stride `stride`.
// If `lo > hi`  the function returns the empty list.
export function stridefunction_fs_list(lo_3, hi_3, stride_3, f_3) /* forall<a,e> (lo : int, hi : int, stride : int, f : (int) -> e a) -> e list<a> */  {
  var _x78 = $std_core_hnd._evv_is_affine();
  if (_x78) {
    return stridefunction_fs__trmc_list(lo_3, hi_3, stride_3, f_3, $std_core_types._cctx_empty());
  }
  else {
    return stridefunction_fs__trmcm_list(lo_3, hi_3, stride_3, f_3, function(_trmc_x10147 /* list<2925> */ ) {
        return _trmc_x10147;
      });
  }
}
 
 
// Apply a function `f` to each character in a string
export function string_fs_map(s, f) /* forall<e> (s : string, f : (char) -> e char) -> e string */  {
   
  var x_10571 = map($std_core_string.list(s), f);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend($std_core_string.listchar_fs_string);
  }
  else {
    return $std_core_string.listchar_fs_string(x_10571);
  }
}
 
 
// monadic lift
export function _mlift_lookup_10458(kv, _y_x10337) /* forall<a,b,e> (kv : (a, b), bool) -> e maybe<b> */  {
  if (_y_x10337) {
    var _x79 = kv.snd;
    return $std_core_types.Just(_x79);
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
 
// Lookup the first element satisfying some predicate
export function lookup(xs, pred) /* forall<a,b,e> (xs : list<(a, b)>, pred : (a) -> e bool) -> e maybe<b> */  {
  return foreach_while(xs, function(kv /* (3159, 3160) */ ) {
       
      var _x80 = kv.fst;
      var x_10573 = pred(_x80);
       
      function next_10574(_y_x10337) /* (bool) -> 3161 maybe<3160> */  {
        if (_y_x10337) {
          var _x81 = kv.snd;
          return $std_core_types.Just(_x81);
        }
        else {
          return $std_core_types.Nothing;
        }
      }
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(next_10574);
      }
      else {
        return next_10574(x_10573);
      }
    });
}
 
 
// monadic lift
export function _mlift_trmc_map_while_10459(_acc, action, xx, _y_x10340) /* forall<a,b,e> (ctx<list<b>>, action : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e list<b> */  {
  if (_y_x10340 !== null) {
     
    var _trmc_x10150 = undefined;
     
    var _trmc_x10151 = $std_core_types.Cons(_y_x10340.value, _trmc_x10150);
    return _trmc_map_while(xx, action, $std_core_types._cctx_extend(_acc,_trmc_x10151,({obj: _trmc_x10151, field_name: "tail"})));
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}
 
 
// monadic lift
export function _mlift_trmcm_map_while_10460(_accm, action_0, xx_0, _y_x10344) /* forall<a,b,e> ((list<b>) -> list<b>, action : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e list<b> */  {
  if (_y_x10344 !== null) {
    return _trmcm_map_while(xx_0, action_0, function(_trmc_x10153 /* list<3222> */ ) {
        return _accm($std_core_types.Cons(_y_x10344.value, _trmc_x10153));
      });
  }
  else {
    return _accm($std_core_types.Nil);
  }
}
 
 
// Invoke `action` on each element of a list while `action` returns `Just`
export function _trmc_map_while(xs, action_1, _acc_0) /* forall<a,b,e> (xs : list<a>, action : (a) -> e maybe<b>, ctx<list<b>>) -> e list<b> */  { tailcall: while(1)
{
  if (xs === null) {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
  else {
     
    var x_0_10577 = action_1(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10340_0 /* maybe<3222> */ ) {
        return _mlift_trmc_map_while_10459(_acc_0, action_1, xs.tail, _y_x10340_0);
      });
    }
    else {
      if (x_0_10577 !== null) {
         
        var _trmc_x10150_0 = undefined;
         
        var _trmc_x10151_0 = $std_core_types.Cons(x_0_10577.value, _trmc_x10150_0);
        {
          // tail call
          var _x80 = $std_core_types._cctx_extend(_acc_0,_trmc_x10151_0,({obj: _trmc_x10151_0, field_name: "tail"}));
          xs = xs.tail;
          _acc_0 = _x80;
          continue tailcall;
        }
      }
      else {
        return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
      }
    }
  }
}}
 
 
// Invoke `action` on each element of a list while `action` returns `Just`
export function _trmcm_map_while(xs_0, action_2, _accm_0) /* forall<a,b,e> (xs : list<a>, action : (a) -> e maybe<b>, (list<b>) -> list<b>) -> e list<b> */  { tailcall: while(1)
{
  if (xs_0 === null) {
    return _accm_0($std_core_types.Nil);
  }
  else {
     
    var x_2_10580 = action_2(xs_0.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10344_0 /* maybe<3222> */ ) {
        return _mlift_trmcm_map_while_10460(_accm_0, action_2, xs_0.tail, _y_x10344_0);
      });
    }
    else {
      if (x_2_10580 !== null) {
        {
          // tail call
          var _x83 = function(__at_accm_081 /* (list<3222>) -> list<3222> */ , _y_282 /* 3222 */ ) {
            return function(_trmc_x10153_0 /* list<3222> */ ) {
              return __at_accm_081($std_core_types.Cons(_y_282, _trmc_x10153_0));
            };
          }(_accm_0, x_2_10580.value);
          xs_0 = xs_0.tail;
          _accm_0 = _x83;
          continue tailcall;
        }
      }
      else {
        return _accm_0($std_core_types.Nil);
      }
    }
  }
}}
 
 
// Invoke `action` on each element of a list while `action` returns `Just`
export function map_while(xs_1, action_3) /* forall<a,b,e> (xs : list<a>, action : (a) -> e maybe<b>) -> e list<b> */  {
  var _x84 = $std_core_hnd._evv_is_affine();
  if (_x84) {
    return _trmc_map_while(xs_1, action_3, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_map_while(xs_1, action_3, function(_trmc_x10152 /* list<3222> */ ) {
        return _trmc_x10152;
      });
  }
}
 
 
// Returns the largest element of a list of integers (or `default` (=`0`) for the empty list)
export function maximum(xs, $default) /* (xs : list<int>, default : ? int) -> int */  {
  if (xs === null) {
    return ($default !== undefined) ? $default : 0;
  }
  else {
    return foldl(xs.tail, xs.head, $std_core_int.max);
  }
}
 
 
// Returns the smallest element of a list of integers (or `default` (=`0`) for the empty list)
export function minimum(xs, $default) /* (xs : list<int>, default : ? int) -> int */  {
  if (xs === null) {
    return ($default !== undefined) ? $default : 0;
  }
  else {
    return foldl(xs.tail, xs.head, $std_core_int.min);
  }
}
 
 
// monadic lift
export function _mlift_partition_acc_10461(acc1, acc2, pred, x, xx, _y_x10351) /* forall<a,e> (acc1 : ctx<list<a>>, acc2 : ctx<list<a>>, pred : (a) -> e bool, x : a, xx : list<a>, bool) -> e (list<a>, list<a>) */  {
  if (_y_x10351) {
     
    var _cctx_x3377 = $std_core_types.Cons(x, undefined);
     
    var _cctx_x3378 = {obj: _cctx_x3377, field_name: "tail"};
    return partition_acc(xx, pred, $std_core_types._cctx_compose(acc1,($std_core_types._cctx_create(_cctx_x3377,_cctx_x3378))), acc2);
  }
  else {
     
    var _cctx_x3420 = $std_core_types.Cons(x, undefined);
     
    var _cctx_x3421 = {obj: _cctx_x3420, field_name: "tail"};
    return partition_acc(xx, pred, acc1, $std_core_types._cctx_compose(acc2,($std_core_types._cctx_create(_cctx_x3420,_cctx_x3421))));
  }
}
 
export function partition_acc(xs, pred_0, acc1_0, acc2_0) /* forall<a,e> (xs : list<a>, pred : (a) -> e bool, acc1 : ctx<list<a>>, acc2 : ctx<list<a>>) -> e (list<a>, list<a>) */  { tailcall: while(1)
{
  if (xs === null) {
    return $std_core_types.Tuple2($std_core_types._cctx_apply(acc1_0,($std_core_types.Nil)), $std_core_types._cctx_apply(acc2_0,($std_core_types.Nil)));
  }
  else {
     
    var x_1_10583 = pred_0(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10351_0 /* bool */ ) {
        return _mlift_partition_acc_10461(acc1_0, acc2_0, pred_0, xs.head, xs.tail, _y_x10351_0);
      });
    }
    else {
      if (x_1_10583) {
         
        var _cctx_x3377_0 = $std_core_types.Cons(xs.head, undefined);
         
        var _cctx_x3378_0 = {obj: _cctx_x3377_0, field_name: "tail"};
        {
          // tail call
          var _x85 = $std_core_types._cctx_compose(acc1_0,($std_core_types._cctx_create(_cctx_x3377_0,_cctx_x3378_0)));
          xs = xs.tail;
          acc1_0 = _x85;
          continue tailcall;
        }
      }
      else {
         
        var _cctx_x3420_0 = $std_core_types.Cons(xs.head, undefined);
         
        var _cctx_x3421_0 = {obj: _cctx_x3420_0, field_name: "tail"};
        {
          // tail call
          var _x86 = $std_core_types._cctx_compose(acc2_0,($std_core_types._cctx_create(_cctx_x3420_0,_cctx_x3421_0)));
          xs = xs.tail;
          acc2_0 = _x86;
          continue tailcall;
        }
      }
    }
  }
}}
 
 
// Partition a list in two lists where the first list contains
// those elements that satisfy the given predicate `pred`.
// For example: `partition([1,2,3],odd?) == ([1,3],[2])`
export function partition(xs, pred) /* forall<a,e> (xs : list<a>, pred : (a) -> e bool) -> e (list<a>, list<a>) */  {
  return partition_acc(xs, pred, $std_core_types._cctx_empty(), $std_core_types._cctx_empty());
}
 
 
// monadic lift
export function _mlift_remove_10462(_y_x10357) /* forall<e> (bool) -> e bool */  {
  return (_y_x10357) ? false : true;
}
 
 
// Remove those elements of a list that satisfy the given predicate `pred`.
// For example: `remove([1,2,3],odd?) == [2]`
export function remove(xs, pred) /* forall<a,e> (xs : list<a>, pred : (a) -> e bool) -> e list<a> */  {
  return filter(xs, function(x /* 3506 */ ) {
       
      var x_0_10586 = pred(x);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_y_x10357 /* bool */ ) {
          return (_y_x10357) ? false : true;
        });
      }
      else {
        return (x_0_10586) ? false : true;
      }
    });
}
 
 
// Create a list of `n` repeated elements `x`
export function _trmc_replicate(x, n, _acc) /* forall<a> (x : a, n : int, ctx<list<a>>) -> list<a> */  { tailcall: while(1)
{
  if ($std_core_types._int_gt(n,0)) {
     
    var _trmc_x10154 = undefined;
     
    var _trmc_x10155 = $std_core_types.Cons(x, _trmc_x10154);
    {
      // tail call
      var _x87 = $std_core_types._int_sub(n,1);
      var _x88 = $std_core_types._cctx_extend(_acc,_trmc_x10155,({obj: _trmc_x10155, field_name: "tail"}));
      n = _x87;
      _acc = _x88;
      continue tailcall;
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}}
 
 
// Create a list of `n` repeated elements `x`
export function replicate(x_0, n_0) /* forall<a> (x : a, n : int) -> list<a> */  {
  return _trmc_replicate(x_0, n_0, $std_core_types._cctx_empty());
}
 
 
// Concatenate all strings in a list in reverse order
export function reverse_join(xs) /* (xs : list<string>) -> string */  {
   
  var xs_0_10045 = _lift_reverse_append_4790($std_core_types.Nil, xs);
  if (xs_0_10045 === null) {
    return "";
  }
  else {
    return _lift_joinsep_4797("", xs_0_10045.tail, xs_0_10045.head);
  }
}
 
 
// Concatenate all strings in a list using a specific separator
export function joinsep_fs_join(xs, sep) /* (xs : list<string>, sep : string) -> string */  {
  if (xs === null) {
    return "";
  }
  else {
    return _lift_joinsep_4797(sep, xs.tail, xs.head);
  }
}
 
 
// monadic lift
export function _mlift_show_10463(_y_x10359) /* forall<e> (list<string>) -> e string */  {
  if (_y_x10359 === null) {
    var _x89 = "";
  }
  else {
    var _x89 = _lift_joinsep_4797(",", _y_x10359.tail, _y_x10359.head);
  }
  return $std_core_types._lp__plus__plus__rp_("[", $std_core_types._lp__plus__plus__rp_(_x89, "]"));
}
 
 
// Show a list
export function show(xs, _implicit_fs_show) /* forall<a,e> (xs : list<a>, ?show : (a) -> e string) -> e string */  {
   
  var x_10589 = map(xs, _implicit_fs_show);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10359 /* list<string> */ ) {
      if (_y_x10359 === null) {
        var _x90 = "";
      }
      else {
        var _x90 = _lift_joinsep_4797(",", _y_x10359.tail, _y_x10359.head);
      }
      return $std_core_types._lp__plus__plus__rp_("[", $std_core_types._lp__plus__plus__rp_(_x90, "]"));
    });
  }
  else {
    if (x_10589 === null) {
      var _x91 = "";
    }
    else {
      var _x91 = _lift_joinsep_4797(",", x_10589.tail, x_10589.head);
    }
    return $std_core_types._lp__plus__plus__rp_("[", $std_core_types._lp__plus__plus__rp_(_x91, "]"));
  }
}
 
 
// _deprecated_, use `list/show` instead.
export function show_list(xs, show_elem) /* forall<a,e> (xs : list<a>, show-elem : (a) -> e string) -> e string */  {
  return show(xs, show_elem);
}
 
 
// monadic lift
export function _mlift_lift_span_4798_10464(acc, predicate, y, ys, yy, _y_x10361) /* forall<a,e> (acc : list<a>, predicate : (a) -> e bool, y : a, ys : list<a>, yy : list<a>, bool) -> e (list<a>, list<a>) */  {
  if (_y_x10361) {
    return _lift_span_4798(predicate, yy, $std_core_types.Cons(y, acc));
  }
  else {
    return $std_core_types.Tuple2(_lift_reverse_append_4790($std_core_types.Nil, acc), ys);
  }
}
 
 
// lifted local: span, span-acc
// todo: implement TRMC with multiple results to avoid the reverse
export function _lift_span_4798(predicate_0, ys_0, acc_0) /* forall<a,e> (predicate : (a) -> e bool, ys : list<a>, acc : list<a>) -> e (list<a>, list<a>) */  { tailcall: while(1)
{
  if (ys_0 !== null) {
     
    var x_10593 = predicate_0(ys_0.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10361_0 /* bool */ ) {
        return _mlift_lift_span_4798_10464(acc_0, predicate_0, ys_0.head, ys_0, ys_0.tail, _y_x10361_0);
      });
    }
    else {
      if (x_10593) {
        {
          // tail call
          var _x92 = $std_core_types.Cons(ys_0.head, acc_0);
          ys_0 = ys_0.tail;
          acc_0 = _x92;
          continue tailcall;
        }
      }
      else {
        return $std_core_types.Tuple2(_lift_reverse_append_4790($std_core_types.Nil, acc_0), ys_0);
      }
    }
  }
  else {
    return $std_core_types.Tuple2(_lift_reverse_append_4790($std_core_types.Nil, acc_0), ys_0);
  }
}}
 
export function span(xs, predicate) /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool) -> e (list<a>, list<a>) */  {
  return _lift_span_4798(predicate, xs, $std_core_types.Nil);
}
 
 
// Return the sum of a list of integers
export function sum(xs) /* (xs : list<int>) -> int */  {
  return foldl(xs, 0, $std_core_int._lp__plus__rp_);
}
 
 
// monadic lift
export function _mlift_trmc_take_while_10465(_acc, predicate, x, xx, _y_x10366) /* forall<a,e> (ctx<list<a>>, predicate : (a) -> e bool, x : a, xx : list<a>, bool) -> e list<a> */  {
  if (_y_x10366) {
     
    var _trmc_x10156 = undefined;
     
    var _trmc_x10157 = $std_core_types.Cons(x, _trmc_x10156);
    return _trmc_take_while(xx, predicate, $std_core_types._cctx_extend(_acc,_trmc_x10157,({obj: _trmc_x10157, field_name: "tail"})));
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}
 
 
// monadic lift
export function _mlift_trmcm_take_while_10466(_accm, predicate_0, x_0, xx_0, _y_x10370) /* forall<a,e> ((list<a>) -> list<a>, predicate : (a) -> e bool, x : a, xx : list<a>, bool) -> e list<a> */  {
  if (_y_x10370) {
    return _trmcm_take_while(xx_0, predicate_0, function(_trmc_x10159 /* list<3832> */ ) {
        return _accm($std_core_types.Cons(x_0, _trmc_x10159));
      });
  }
  else {
    return _accm($std_core_types.Nil);
  }
}
 
 
// Keep only those initial elements that satisfy `predicate`
export function _trmc_take_while(xs, predicate_1, _acc_0) /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool, ctx<list<a>>) -> e list<a> */  { tailcall: while(1)
{
  if (xs !== null) {
     
    var x_2_10596 = predicate_1(xs.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10366_0 /* bool */ ) {
        return _mlift_trmc_take_while_10465(_acc_0, predicate_1, xs.head, xs.tail, _y_x10366_0);
      });
    }
    else {
      if (x_2_10596) {
         
        var _trmc_x10156_0 = undefined;
         
        var _trmc_x10157_0 = $std_core_types.Cons(xs.head, _trmc_x10156_0);
        {
          // tail call
          var _x93 = $std_core_types._cctx_extend(_acc_0,_trmc_x10157_0,({obj: _trmc_x10157_0, field_name: "tail"}));
          xs = xs.tail;
          _acc_0 = _x93;
          continue tailcall;
        }
      }
      else {
        return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
      }
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// Keep only those initial elements that satisfy `predicate`
export function _trmcm_take_while(xs_0, predicate_2, _accm_0) /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool, (list<a>) -> list<a>) -> e list<a> */  { tailcall: while(1)
{
  if (xs_0 !== null) {
     
    var x_4_10599 = predicate_2(xs_0.head);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10370_0 /* bool */ ) {
        return _mlift_trmcm_take_while_10466(_accm_0, predicate_2, xs_0.head, xs_0.tail, _y_x10370_0);
      });
    }
    else {
      if (x_4_10599) {
        {
          // tail call
          var _x96 = function(__at_accm_094 /* (list<3832>) -> list<3832> */ , _x_395 /* 3832 */ ) {
            return function(_trmc_x10159_0 /* list<3832> */ ) {
              return __at_accm_094($std_core_types.Cons(_x_395, _trmc_x10159_0));
            };
          }(_accm_0, xs_0.head);
          xs_0 = xs_0.tail;
          _accm_0 = _x96;
          continue tailcall;
        }
      }
      else {
        return _accm_0($std_core_types.Nil);
      }
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// Keep only those initial elements that satisfy `predicate`
export function take_while(xs_1, predicate_3) /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool) -> e list<a> */  {
  var _x97 = $std_core_hnd._evv_is_affine();
  if (_x97) {
    return _trmc_take_while(xs_1, predicate_3, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_take_while(xs_1, predicate_3, function(_trmc_x10158 /* list<3832> */ ) {
        return _trmc_x10158;
      });
  }
}
 
 
// Join a list of strings with newlines
export function unlines(xs) /* (xs : list<string>) -> string */  {
  if (xs === null) {
    return "";
  }
  else {
    return _lift_joinsep_4797("\n", xs.tail, xs.head);
  }
}
 
 
// lifted local: unzip, iter
// todo: implement TRMC for multiple results
export function _lift_unzip_4799(ys, acc1, acc2) /* forall<a,b,c,d> (ys : list<(a, b)>, acc1 : cctx<c,list<a>>, acc2 : cctx<d,list<b>>) -> (c, d) */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var _cctx_x3895 = $std_core_types.Cons(ys.head.fst, undefined);
     
    var _cctx_x3896 = {obj: _cctx_x3895, field_name: "tail"};
     
    var _cctx_x3935 = $std_core_types.Cons(ys.head.snd, undefined);
     
    var _cctx_x3936 = {obj: _cctx_x3935, field_name: "tail"};
    {
      // tail call
      var _x98 = $std_core_types._cctx_compose(acc1,($std_core_types._cctx_create(_cctx_x3895,_cctx_x3896)));
      var _x99 = $std_core_types._cctx_compose(acc2,($std_core_types._cctx_create(_cctx_x3935,_cctx_x3936)));
      ys = ys.tail;
      acc1 = _x98;
      acc2 = _x99;
      continue tailcall;
    }
  }
  else {
    return $std_core_types.Tuple2($std_core_types._cctx_apply(acc1,($std_core_types.Nil)), $std_core_types._cctx_apply(acc2,($std_core_types.Nil)));
  }
}}
 
 
// Unzip a list of pairs into two lists
export function unzip(xs) /* forall<a,b> (xs : list<(a, b)>) -> (list<a>, list<b>) */  {
  return _lift_unzip_4799(xs, $std_core_types._cctx_empty(), $std_core_types._cctx_empty());
}
 
 
// lifted local: unzip3, iter
// todo: implement TRMC for multiple results
export function _lift_unzip3_4800(ys, acc1, acc2, acc3) /* forall<a,b,c,d,a1,b1> (ys : list<(a, b, c)>, acc1 : cctx<d,list<a>>, acc2 : cctx<a1,list<b>>, acc3 : cctx<b1,list<c>>) -> (d, a1, b1) */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var _cctx_x4086 = $std_core_types.Cons(ys.head.fst, undefined);
     
    var _cctx_x4087 = {obj: _cctx_x4086, field_name: "tail"};
     
    var _cctx_x4126 = $std_core_types.Cons(ys.head.snd, undefined);
     
    var _cctx_x4127 = {obj: _cctx_x4126, field_name: "tail"};
     
    var _cctx_x4166 = $std_core_types.Cons(ys.head.thd, undefined);
     
    var _cctx_x4167 = {obj: _cctx_x4166, field_name: "tail"};
    {
      // tail call
      var _x100 = $std_core_types._cctx_compose(acc1,($std_core_types._cctx_create(_cctx_x4086,_cctx_x4087)));
      var _x101 = $std_core_types._cctx_compose(acc2,($std_core_types._cctx_create(_cctx_x4126,_cctx_x4127)));
      var _x102 = $std_core_types._cctx_compose(acc3,($std_core_types._cctx_create(_cctx_x4166,_cctx_x4167)));
      ys = ys.tail;
      acc1 = _x100;
      acc2 = _x101;
      acc3 = _x102;
      continue tailcall;
    }
  }
  else {
    return $std_core_types.Tuple3($std_core_types._cctx_apply(acc1,($std_core_types.Nil)), $std_core_types._cctx_apply(acc2,($std_core_types.Nil)), $std_core_types._cctx_apply(acc3,($std_core_types.Nil)));
  }
}}
 
 
// Unzip a list of triples into three lists
export function unzip3(xs) /* forall<a,b,c> (xs : list<(a, b, c)>) -> (list<a>, list<b>, list<c>) */  {
  return _lift_unzip3_4800(xs, $std_core_types._cctx_empty(), $std_core_types._cctx_empty(), $std_core_types._cctx_empty());
}
 
 
// lifted local: unzip4, iter
// todo: implement TRMC for multiple results
export function _lift_unzip4_4801(ys, acc1, acc2, acc3, acc4) /* forall<a,b,c,d,a1,b1,c1,d1> (ys : list<(a, b, c, d)>, acc1 : cctx<a1,list<a>>, acc2 : cctx<b1,list<b>>, acc3 : cctx<c1,list<c>>, acc4 : cctx<d1,list<d>>) -> (a1, b1, c1, d1) */  { tailcall: while(1)
{
  if (ys !== null) {
     
    var _cctx_x4357 = $std_core_types.Cons(ys.head.fst, undefined);
     
    var _cctx_x4358 = {obj: _cctx_x4357, field_name: "tail"};
     
    var _cctx_x4397 = $std_core_types.Cons(ys.head.snd, undefined);
     
    var _cctx_x4398 = {obj: _cctx_x4397, field_name: "tail"};
     
    var _cctx_x4437 = $std_core_types.Cons(ys.head.thd, undefined);
     
    var _cctx_x4438 = {obj: _cctx_x4437, field_name: "tail"};
     
    var _cctx_x4477 = $std_core_types.Cons(ys.head.field4, undefined);
     
    var _cctx_x4478 = {obj: _cctx_x4477, field_name: "tail"};
    {
      // tail call
      var _x103 = $std_core_types._cctx_compose(acc1,($std_core_types._cctx_create(_cctx_x4357,_cctx_x4358)));
      var _x104 = $std_core_types._cctx_compose(acc2,($std_core_types._cctx_create(_cctx_x4397,_cctx_x4398)));
      var _x105 = $std_core_types._cctx_compose(acc3,($std_core_types._cctx_create(_cctx_x4437,_cctx_x4438)));
      var _x106 = $std_core_types._cctx_compose(acc4,($std_core_types._cctx_create(_cctx_x4477,_cctx_x4478)));
      ys = ys.tail;
      acc1 = _x103;
      acc2 = _x104;
      acc3 = _x105;
      acc4 = _x106;
      continue tailcall;
    }
  }
  else {
    return $std_core_types.Tuple4($std_core_types._cctx_apply(acc1,($std_core_types.Nil)), $std_core_types._cctx_apply(acc2,($std_core_types.Nil)), $std_core_types._cctx_apply(acc3,($std_core_types.Nil)), $std_core_types._cctx_apply(acc4,($std_core_types.Nil)));
  }
}}
 
 
// Unzip a list of quadruples into four lists
export function unzip4(xs) /* forall<a,b,c,d> (xs : list<(a, b, c, d)>) -> (list<a>, list<b>, list<c>, list<d>) */  {
  return _lift_unzip4_4801(xs, $std_core_types._cctx_empty(), $std_core_types._cctx_empty(), $std_core_types._cctx_empty(), $std_core_types._cctx_empty());
}
 
 
// Zip two lists together by pairing the corresponding elements.
// The returned list is only as long as the smallest input list.
export function _trmc_zip(xs, ys, _acc) /* forall<a,b> (xs : list<a>, ys : list<b>, ctx<list<(a, b)>>) -> list<(a, b)> */  { tailcall: while(1)
{
  if (xs !== null) {
    if (ys !== null) {
       
      var _trmc_x10160 = undefined;
       
      var _trmc_x10161 = $std_core_types.Cons($std_core_types.Tuple2(xs.head, ys.head), _trmc_x10160);
      {
        // tail call
        var _x107 = $std_core_types._cctx_extend(_acc,_trmc_x10161,({obj: _trmc_x10161, field_name: "tail"}));
        xs = xs.tail;
        ys = ys.tail;
        _acc = _x107;
        continue tailcall;
      }
    }
    else {
      return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}}
 
 
// Zip two lists together by pairing the corresponding elements.
// The returned list is only as long as the smallest input list.
export function zip(xs_0, ys_0) /* forall<a,b> (xs : list<a>, ys : list<b>) -> list<(a, b)> */  {
  return _trmc_zip(xs_0, ys_0, $std_core_types._cctx_empty());
}
 
 
// monadic lift
export function _mlift_trmc_zipwith_10467(_acc, f, xx, yy, _trmc_x10162) /* forall<a,b,c,e> (ctx<list<c>>, f : (a, b) -> e c, xx : list<a>, yy : list<b>, c) -> e list<c> */  {
   
  var _trmc_x10163 = undefined;
   
  var _trmc_x10164 = $std_core_types.Cons(_trmc_x10162, _trmc_x10163);
  return _trmc_zipwith(xx, yy, f, $std_core_types._cctx_extend(_acc,_trmc_x10164,({obj: _trmc_x10164, field_name: "tail"})));
}
 
 
// monadic lift
export function _mlift_trmcm_zipwith_10468(_accm, f_0, xx_0, yy_0, _trmc_x10167) /* forall<a,b,c,e> ((list<c>) -> list<c>, f : (a, b) -> e c, xx : list<a>, yy : list<b>, c) -> e list<c> */  {
  return _trmcm_zipwith(xx_0, yy_0, f_0, function(_trmc_x10166 /* list<4774> */ ) {
      return _accm($std_core_types.Cons(_trmc_x10167, _trmc_x10166));
    });
}
 
 
// Zip two lists together by apply a function `f` to all corresponding elements.
// The returned list is only as long as the smallest input list.
export function _trmc_zipwith(xs, ys, f_1, _acc_0) /* forall<a,b,c,e> (xs : list<a>, ys : list<b>, f : (a, b) -> e c, ctx<list<c>>) -> e list<c> */  { tailcall: while(1)
{
  if (xs !== null) {
    if (ys !== null) {
       
      var x_0_10602 = f_1(xs.head, ys.head);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_trmc_x10162_0 /* 4774 */ ) {
          return _mlift_trmc_zipwith_10467(_acc_0, f_1, xs.tail, ys.tail, _trmc_x10162_0);
        });
      }
      else {
         
        var _trmc_x10163_0 = undefined;
         
        var _trmc_x10164_0 = $std_core_types.Cons(x_0_10602, _trmc_x10163_0);
        {
          // tail call
          var _x108 = $std_core_types._cctx_extend(_acc_0,_trmc_x10164_0,({obj: _trmc_x10164_0, field_name: "tail"}));
          xs = xs.tail;
          ys = ys.tail;
          _acc_0 = _x108;
          continue tailcall;
        }
      }
    }
    else {
      return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
    }
  }
  else {
    return $std_core_types._cctx_apply(_acc_0,($std_core_types.Nil));
  }
}}
 
 
// Zip two lists together by apply a function `f` to all corresponding elements.
// The returned list is only as long as the smallest input list.
export function _trmcm_zipwith(xs_0, ys_0, f_2, _accm_0) /* forall<a,b,c,e> (xs : list<a>, ys : list<b>, f : (a, b) -> e c, (list<c>) -> list<c>) -> e list<c> */  { tailcall: while(1)
{
  if (xs_0 !== null) {
    if (ys_0 !== null) {
       
      var x_2_10605 = f_2(xs_0.head, ys_0.head);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_trmc_x10167_0 /* 4774 */ ) {
          return _mlift_trmcm_zipwith_10468(_accm_0, f_2, xs_0.tail, ys_0.tail, _trmc_x10167_0);
        });
      }
      else {
        {
          // tail call
          var _x111 = function(__at_accm_0109 /* (list<4774>) -> list<4774> */ , _x_2_10605110 /* 4774 */ ) {
            return function(_trmc_x10166_0 /* list<4774> */ ) {
              return __at_accm_0109($std_core_types.Cons(_x_2_10605110, _trmc_x10166_0));
            };
          }(_accm_0, x_2_10605);
          xs_0 = xs_0.tail;
          ys_0 = ys_0.tail;
          _accm_0 = _x111;
          continue tailcall;
        }
      }
    }
    else {
      return _accm_0($std_core_types.Nil);
    }
  }
  else {
    return _accm_0($std_core_types.Nil);
  }
}}
 
 
// Zip two lists together by apply a function `f` to all corresponding elements.
// The returned list is only as long as the smallest input list.
export function zipwith(xs_1, ys_1, f_3) /* forall<a,b,c,e> (xs : list<a>, ys : list<b>, f : (a, b) -> e c) -> e list<c> */  {
  var _x112 = $std_core_hnd._evv_is_affine();
  if (_x112) {
    return _trmc_zipwith(xs_1, ys_1, f_3, $std_core_types._cctx_empty());
  }
  else {
    return _trmcm_zipwith(xs_1, ys_1, f_3, function(_trmc_x10165 /* list<4774> */ ) {
        return _trmc_x10165;
      });
  }
}