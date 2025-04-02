// Koka generated module: std/core/sslice, koka version: 3.1.2
"use strict";
 
// imports
import * as $std_core_types from './std_core_types.mjs';
import * as $std_core_undiv from './std_core_undiv.mjs';
import * as $std_core_unsafe from './std_core_unsafe.mjs';
import * as $std_core_hnd from './std_core_hnd.mjs';
import * as $std_core_int from './std_core_int.mjs';
import * as $std_core_string from './std_core_string.mjs';
 
// externals
/*---------------------------------------------------------------------------
  Copyright 2012-2024, Microsoft Research, Daan Leijen.
  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/
function _slice_to_string(sl) {
  if (sl.start===0 && sl.len===sl.str.length) return sl.str;
  return sl.str.substr(sl.start,sl.len);
}
function _sslice_first( s ) {
  var len;
  if (s.length===0) len = 0;
  else if ($std_core_string._is_high_surrogate(s.charCodeAt(0))) len = 2
  else len = 1;
  return { str: s, start: 0, len: len };
}
function _sslice_last( s ) {
  var len;
  if (s.length===0) len = 0;
  else if ($std_core_string._is_low_surrogate(s.charCodeAt(s.length-1))) len = 2
  else len = 1;
  return { str: s, start: s.length-len, len: len };
}
function _sslice_count(slice) {
  if (slice.len<=0) return 0;
  var count = 0;
  var end = slice.start + slice.len;
  $std_core_string._char_iter(slice.str, slice.start, function(c,i,nexti) {
    count++;
    return (nexti >= end);
  });
  return count;
}
// Extend the length of slice
function _sslice_extend( slice, count ) {
  if (count===0) return slice;
  var idx = slice.start + slice.len;
  if (count > 0) {
    $std_core_string._char_iter(slice.str, idx, function(c,i,nexti) {
      count--;
      idx = nexti;
      return (count <= 0);
    });
  }
  else {
    $std_core_string._char_reviter(slice.str, idx-1, function(c,i,nexti) {
      count++;
      idx = i;
      return (count >= 0 || idx <= slice.start);
    });
  }
  return { str: slice.str, start: slice.start, len: (idx > slice.start ? idx - slice.start : 0) };
}
// advance the start position of a slice
function _sslice_advance( slice, count ) {
  if (count===0) return slice;
  var idx = slice.start;
  var end = slice.start + slice.len;
  var slicecount = _sslice_count(slice); // todo: optimize by caching the character count?
  if (count > 0) {
    var extra = 0;
    $std_core_string._char_iter(slice.str, idx, function(c,i,nexti) {
      extra++;
      idx = nexti;
      return (extra >= count);
    });
    if (extra < slicecount && idx < end) { // optimize
      return _sslice_extend({ str: slice.str, start: idx, len: end-idx }, extra);
    }
  }
  else {
    var extra = 0;
    $std_core_string._char_reviter(slice.str, idx-1, function(c,i,nexti) {
      extra++;
      idx = i;
      return (extra >= -count);
    });
    if (extra < slicecount && idx < slice.start) {  // optimize
      return _sslice_extend({ str: slice.str, start: idx, len: slice.start-idx }, slicecount - extra);
    }
  }
  return _sslice_extend( { str: slice.str, start: idx, len: 0 }, slicecount );
}
// iterate through a slice
function _sslice_next( slice ) {
  if (slice.len <= 0) return null;
  var c = slice.str.charCodeAt(slice.start);
  var n = 1;
  if ($std_core_string._is_high_surrogate(c) && slice.len > 1) {
    var lo = slice.str.charCodeAt(slice.start+1);
    if ($std_core_string._is_low_surrogate(lo)) {
      c = $std_core_string._from_surrogate(c,lo);
      n = 2;
    }
  }
  return $std_core_types.Just( {fst: c, snd: { str: slice.str, start: slice.start+n, len: slice.len-n }} );
}
// return the common prefix of two strings
function _sslice_common_prefix( s, t, upto ) {
  var i;
  var max = Math.min(s.length,t.length);
  for(i = 0; i < max && upto > 0; i++) {
    var c = s.charCodeAt(i);
    if (c !== t.charCodeAt(i)) break;
    if (!$std_core_string._is_low_surrogate(c)) upto--; // count characters
  }
  return { str: s, start: 0, len: i };
}
 
// type declarations
// type sslice
export function Sslice(str, start, len) /* (str : string, start : int, len : int) -> sslice */  {
  return { str: str, start: start, len: len };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `str` constructor field of the `:sslice` type.
export function sslice_fs_str(sslice) /* (sslice : sslice) -> string */  {
  return sslice.str;
}
 
 
// Automatically generated. Retrieves the `start` constructor field of the `:sslice` type.
export function sslice_fs_start(sslice) /* (sslice : sslice) -> int */  {
  return sslice.start;
}
 
 
// Automatically generated. Retrieves the `len` constructor field of the `:sslice` type.
export function sslice_fs_len(sslice) /* (sslice : sslice) -> int */  {
  return sslice.len;
}
 
export function sslice_fs__copy(_this, str, start, len) /* (sslice, str : ? string, start : ? int, len : ? int) -> sslice */  {
  if (str !== undefined) {
    var _x0 = str;
  }
  else {
    var _x0 = _this.str;
  }
  if (start !== undefined) {
    var _x1 = start;
  }
  else {
    var _x1 = _this.start;
  }
  if (len !== undefined) {
    var _x2 = len;
  }
  else {
    var _x2 = _this.len;
  }
  return Sslice(_x0, _x1, _x2);
}
 
 
// Internal export for the regex module
export function _new_sslice(str, start, len) /* (str : string, start : int, len : int) -> sslice */  {
  return Sslice(str, start, len);
}
 
 
// O(n). Copy the `slice` argument into a fresh string.
// Takes O(1) time if the slice covers the entire string.
export function string(slice_0) /* (slice : sslice) -> string */  {
  return _slice_to_string(slice_0);
}
 
 
// If the slice is not empty,
// return the first character, and a new slice that is advanced by 1.
export function next(slice_0) /* (slice : sslice) -> maybe<(char, sslice)> */  {
  return _sslice_next(slice_0);
}
 
 
// O(1). The entire string as a slice
export function slice(s) /* (s : string) -> sslice */  {
  return Sslice(s, 0, s.length);
}
 
 
// O(1). Return the string slice from the end of `slice` argument
// to the end of the string.
export function after(slice_0) /* (slice : sslice) -> sslice */  {
   
  var x_0_10005 = (slice_0.str).length;
   
  var y_0_10006 = $std_core_types._int_add((slice_0.start),(slice_0.len));
  return Sslice(slice_0.str, $std_core_types._int_add((slice_0.start),(slice_0.len)), $std_core_types._int_sub(x_0_10005,y_0_10006));
}
 
 
// O(1). Return the string slice from the start of a string up to the
// start of `slice` argument.
export function before(slice_0) /* (slice : sslice) -> sslice */  {
  return Sslice(slice_0.str, 0, slice_0.start);
}
 
export function first1(s) /* (s : string) -> sslice */  {
  return _sslice_first(s);
}
 
 
// Return the common prefix of two strings (upto `upto` characters (default is minimum length of the two strings))
export function common_prefix(s, t, upto) /* (s : string, t : string, upto : ? int) -> sslice */  {
  var _x3 = (upto !== undefined) ? upto : -1;
  return _sslice_common_prefix(s,t,_x3);
}
 
 
// O(n). Return the number of characters in a string slice
export function count(slice_0) /* (slice : sslice) -> int */  {
  return _sslice_count(slice_0);
}
 
 
// Truncates a slice to length 0
export function truncate(slice_0) /* (slice : sslice) -> sslice */  {
  var _x4 = slice_0.str;
  var _x5 = slice_0.start;
  return Sslice(_x4, _x5, 0);
}
 
 
// An empty slice
export var empty;
var empty = Sslice("", 0, 0);
 
export function xends_with(s, post) /* (s : string, post : string) -> bool */  {
  return ((s).indexOf(post, (s).length - (post).length) !== -1);
}
 
 
// O(n). If it occurs, return the position of substring `sub` in `s`, tupled with
// the position just following the substring `sub`.
export function find(s, sub) /* (s : string, sub : string) -> maybe<sslice> */  {
   
  var i = $std_core_types._int_from_int32((((s).indexOf(sub) + 1)));
  if ($std_core_types._int_iszero(i)) {
    return $std_core_types.Nothing;
  }
  else {
    return $std_core_types.Just(Sslice(s, $std_core_types._int_sub(i,1), sub.length));
  }
}
 
 
// Return the last index of substring `sub` in `s` if it occurs.
export function find_last(s, sub) /* (s : string, sub : string) -> maybe<sslice> */  {
   
  var i = $std_core_types._int_from_int32((((s).lastIndexOf(sub) + 1)));
  if ($std_core_types._int_iszero(i)) {
    return $std_core_types.Nothing;
  }
  else {
    return $std_core_types.Just(Sslice(s, $std_core_types._int_sub(i,1), sub.length));
  }
}
 
 
// An invalid slice
export var invalid;
var invalid = Sslice("", -1, 0);
 
 
// Is a slice empty?
export function is_empty(slice_0) /* (slice : sslice) -> bool */  {
   
  var _x6 = slice_0.len;
  var b_10013 = $std_core_types._int_gt(_x6,0);
  return (b_10013) ? false : true;
}
 
 
// Is a slice not empty?
export function is_notempty(slice_0) /* (slice : sslice) -> bool */  {
  var _x6 = slice_0.len;
  return $std_core_types._int_gt(_x6,0);
}
 
 
// Is a slice invalid?
export function is_valid(slice_0) /* (slice : sslice) -> bool */  {
  var _x7 = slice_0.start;
  return $std_core_types._int_ge(_x7,0);
}
 
export function last1(s) /* (s : string) -> sslice */  {
  return _sslice_last(s);
}
 
 
// Is `pre`  a prefix of `s`? If so, returns a slice
// of `s` following `pre` up to the end of `s`.
export function starts_with(s, pre) /* (s : string, pre : string) -> maybe<sslice> */  {
  if ((s.substr(0,pre.length) === pre)) {
     
    var x_10019 = s.length;
     
    var y_10020 = pre.length;
    return $std_core_types.Just(Sslice(s, pre.length, $std_core_types._int_sub(x_10019,y_10020)));
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
 
// Equality based on contents of the slice
// O(`n`+`m`) where `n` and `m` are the lengths of the two strings
export function _lp__eq__eq__rp_(slice1, slice2) /* (slice1 : sslice, slice2 : sslice) -> bool */  {
  var _x8 = Object.is((slice1.str),(slice2.str));
  if (_x8) {
    if ($std_core_types._int_eq((slice1.start),(slice2.start))) {
      if ($std_core_types._int_eq((slice1.len),(slice2.len))) {
        return true;
      }
      else {
        return ((string(slice1)) === (string(slice2)));
      }
    }
    else {
      return ((string(slice1)) === (string(slice2)));
    }
  }
  else {
    return ((string(slice1)) === (string(slice2)));
  }
}
 
 
// Inequality based on contents of the slice
// O(`n`+`m`) where `n` and `m` are the lengths of the two strings
export function _lp__excl__eq__rp_(slice1, slice2) /* (slice1 : sslice, slice2 : sslice) -> bool */  {
   
  var b_10021 = _lp__eq__eq__rp_(slice1, slice2);
  return (b_10021) ? false : true;
}
 
 
// Equality of slices at the same offset and length on an equal string
// (The strings do not have to be referentially identical though)
export function _lp__eq__eq__eq__rp_(slice1, slice2) /* (slice1 : sslice, slice2 : sslice) -> bool */  {
  if ($std_core_types._int_eq((slice1.start),(slice2.start))) {
    return ($std_core_types._int_eq((slice1.len),(slice2.len))) ? ((slice1.str) === (slice2.str)) : false;
  }
  else {
    return false;
  }
}
 
 
// Inequality of slices at the same offset and length on the same string.
// (The strings do not have to be referentially identical though)
export function _lp__excl__eq__eq__rp_(slice1, slice2) /* (slice1 : sslice, slice2 : sslice) -> bool */  {
   
  var b_10022 = _lp__eq__eq__eq__rp_(slice1, slice2);
  return (b_10022) ? false : true;
}
 
 
// monadic lift
export function _mlift_foreach_while_10115(action, rest, _y_x10092) /* forall<a,e> (action : (c : char) -> e maybe<a>, rest : sslice, maybe<a>) -> e maybe<a> */  {
  if (_y_x10092 === null) {
    return foreach_while(rest, action);
  }
  else {
    return _y_x10092;
  }
}
 
 
// Apply a function for each character in a string slice.
// If `action` returns `Just`, the function returns immediately with that result.
export function foreach_while(slice_0, action_0) /* forall<a,e> (slice : sslice, action : (c : char) -> e maybe<a>) -> e maybe<a> */  { tailcall: while(1)
{
  var _x9 = next(slice_0);
  if (_x9 === null) {
    return $std_core_types.Nothing;
  }
  else {
     
    var x_10124 = action_0(_x9.value.fst);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10092_0 /* maybe<690> */ ) {
        return _mlift_foreach_while_10115(action_0, _x9.value.snd, _y_x10092_0);
      });
    }
    else {
      if (x_10124 === null) {
        {
          // tail call
          slice_0 = _x9.value.snd;
          continue tailcall;
        }
      }
      else {
        return x_10124;
      }
    }
  }
}}
 
 
// Invoke a function for each character in a string.
// If `action` returns `Just`, the function returns immediately with that result.
export function string_fs_foreach_while(s, action) /* forall<a,e> (s : string, action : (c : char) -> e maybe<a>) -> e maybe<a> */  {
  return foreach_while(Sslice(s, 0, s.length), action);
}
 
 
// monadic lift
export function _mlift_foreach_10116(wild__) /* forall<_a,e> (wild_ : ()) -> e maybe<_a> */  {
  return $std_core_types.Nothing;
}
 
 
// monadic lift
export function _mlift_foreach_10117(wild___0) /* forall<_a,e> (wild_@0 : maybe<_a>) -> e () */  {
  return $std_core_types.Unit;
}
 
 
// Apply a function for each character in a string slice.
export function foreach(slice_0, action) /* forall<e> (slice : sslice, action : (c : char) -> e ()) -> e () */  {
   
  var x_10127 = foreach_while(slice_0, function(c /* char */ ) {
       
      var x_0_10130 = action(c);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(wild__ /* () */ ) {
          return $std_core_types.Nothing;
        });
      }
      else {
        return $std_core_types.Nothing;
      }
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild___0_0 /* maybe<_754> */ ) {
      return $std_core_types.Unit;
    });
  }
  else {
    return $std_core_types.Unit;
  }
}
 
 
// monadic lift
export function string_fs__mlift_foreach_10118(wild__) /* forall<_a,e> (wild_ : ()) -> e maybe<_a> */  {
  return $std_core_types.Nothing;
}
 
 
// monadic lift
export function string_fs__mlift_foreach_10119(wild___0) /* forall<_a,e> (wild_@0 : maybe<_a>) -> e () */  {
  return $std_core_types.Unit;
}
 
 
// Invoke a function for each character in a string
export function string_fs_foreach(s, action) /* forall<e> (s : string, action : (c : char) -> e ()) -> e () */  {
   
  var slice_0_10023 = Sslice(s, 0, s.length);
   
  var x_10134 = foreach_while(slice_0_10023, function(c /* char */ ) {
       
      var x_0_10137 = action(c);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(wild__ /* () */ ) {
          return $std_core_types.Nothing;
        });
      }
      else {
        return $std_core_types.Nothing;
      }
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild___0_0 /* maybe<_754> */ ) {
      return $std_core_types.Unit;
    });
  }
  else {
    return $std_core_types.Unit;
  }
}
 
 
// monadic lift
export function pred_fs__mlift_count_10120(cnt, _y_x10103) /* forall<h,e> (cnt : local-var<h,int>, int) -> <local<h>|e> () */  {
  return ((cnt).value = ($std_core_types._int_add(_y_x10103,1)));
}
 
 
// monadic lift
export function pred_fs__mlift_count_10121(_c_x10105) /* forall<_a> (()) -> maybe<_a> */  {
  return $std_core_types.Nothing;
}
 
 
// monadic lift
export function pred_fs__mlift_count_10122(cnt, _y_x10102) /* forall<_a,h,e> (cnt : local-var<h,int>, bool) -> <local<h>|e> maybe<_a> */  {
   
  if (_y_x10102) {
     
    var x_0_10143 = ((cnt).value);
     
    var next_1_10144 = function(_y_x10103 /* int */ ) {
      return ((cnt).value = ($std_core_types._int_add(_y_x10103,1)));
    };
    if ($std_core_hnd._yielding()) {
      var x_10141 = $std_core_hnd.yield_extend(next_1_10144);
    }
    else {
      var x_10141 = next_1_10144(x_0_10143);
    }
  }
  else {
    var x_10141 = $std_core_types.Unit;
  }
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_c_x10105 /* () */ ) {
      return $std_core_types.Nothing;
    });
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
 
// monadic lift
export function pred_fs__mlift_count_10123(cnt, wild___0) /* forall<_a,h,e> (cnt : local-var<h,int>, wild_@0 : maybe<_a>) -> <local<h>|e> int */  {
  return ((cnt).value);
}
 
 
// Count the number of times a predicate is true for each character in a string
export function pred_fs_count(s, pred) /* forall<e> (s : string, pred : (char) -> e bool) -> e int */  {
  return function() {
     
    var loc = { value: 0 };
     
    var slice_0_10028 = Sslice(s, 0, s.length);
     
    var x_10150 = foreach_while(slice_0_10028, function(c /* char */ ) {
         
        var x_0_10152 = pred(c);
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(function(_y_x10102 /* bool */ ) {
            return pred_fs__mlift_count_10122(loc, _y_x10102);
          });
        }
        else {
          return pred_fs__mlift_count_10122(loc, x_0_10152);
        }
      });
     
    if ($std_core_hnd._yielding()) {
      var res = $std_core_hnd.yield_extend(function(wild___0 /* maybe<_754> */ ) {
        return ((loc).value);
      });
    }
    else {
      var res = ((loc).value);
    }
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
 
// O(`count`). Advance the start position of a string slice by `count` characters
// up to the end of the string.
// A negative `count` advances the start position backwards upto the first position
// in a string.
// Maintains the character count of the original slice upto the end of the string.
// For example:
//
// * `"abc".first.advance(1).string == "b"`,
// * `"abc".first.advance(3).string == ""`,
// * `"abc".last.advance(-1).string == "b"`.
//
export function advance(slice_0, count_0) /* (slice : sslice, count : int) -> sslice */  {
  return _sslice_advance(slice_0,count_0);
}
 
 
// O(`count`). Extend a string slice by `count` characters up to the end of the string.
// A negative `count` shrinks the slice up to the empty slice.
// For example:
//
// * `"abc".first.extend(1).string == "ab"`
// * `"abc".last.extend(-1).string == ""`
//
export function extend(slice_0, count_0) /* (slice : sslice, count : int) -> sslice */  {
  return _sslice_extend(slice_0,count_0);
}
 
 
// O(`n`). The first `n` (default = `1`) characters in a string.
export function first(s, n) /* (s : string, n : ? int) -> sslice */  {
   
  var slice_0 = first1(s);
  var _x11 = (n !== undefined) ? n : 1;
  var _x10 = $std_core_types._int_eq(_x11,1);
  if (_x10) {
    return slice_0;
  }
  else {
    var _x12 = (n !== undefined) ? n : 1;
    return extend(slice_0, $std_core_types._int_sub(_x12,1));
  }
}
 
 
// Convert the first character of a string to uppercase.
export function capitalize(s) /* (s : string) -> string */  {
   
  var slice_0_1 = first1(s);
   
  var _x15 = undefined;
  var _x14 = (_x15 !== undefined) ? _x15 : 1;
  var _x13 = $std_core_types._int_eq(_x14,1);
  if (_x13) {
    var slice_0_0_10036 = slice_0_1;
  }
  else {
    var _x17 = undefined;
    var _x16 = (_x17 !== undefined) ? _x17 : 1;
    var slice_0_0_10036 = extend(slice_0_1, $std_core_types._int_sub(_x16,1));
  }
   
  var slice_0 = first1(s);
  var _x16 = undefined;
  var _x15 = (_x16 !== undefined) ? _x16 : 1;
  var _x14 = $std_core_types._int_eq(_x15,1);
  if (_x14) {
    var _x13 = slice_0;
  }
  else {
    var _x18 = undefined;
    var _x17 = (_x18 !== undefined) ? _x18 : 1;
    var _x13 = extend(slice_0, $std_core_types._int_sub(_x17,1));
  }
   
  var x_1_10043 = (slice_0_0_10036.str).length;
   
  var y_1_10044 = $std_core_types._int_add((slice_0_0_10036.start),(slice_0_0_10036.len));
  var _x19 = Sslice(slice_0_0_10036.str, $std_core_types._int_add((slice_0_0_10036.start),(slice_0_0_10036.len)), $std_core_types._int_sub(x_1_10043,y_1_10044));
  return $std_core_types._lp__plus__plus__rp_($std_core_string.to_upper(string(_x13)), string(_x19));
}
 
 
// Truncate a string to `count` characters.
export function string_fs_truncate(s, count_0) /* (s : string, count : int) -> string */  {
   
  var slice_0 = first1(s);
  var _x23 = undefined;
  var _x22 = (_x23 !== undefined) ? _x23 : 1;
  var _x21 = $std_core_types._int_eq(_x22,1);
  if (_x21) {
    var _x20 = slice_0;
  }
  else {
    var _x25 = undefined;
    var _x24 = (_x25 !== undefined) ? _x25 : 1;
    var _x20 = extend(slice_0, $std_core_types._int_sub(_x24,1));
  }
  return string(extend(_x20, $std_core_types._int_sub(count_0,1)));
}
 
 
// Gets a slice that drops the first n characters, shrinking the length of the slice by n accordingly.
// If the slice does not have n characters, then the slice is shrunk to an empty slice.
//
// If maintaining the length of the slice is important, use `advance` instead.
export function drop(slice_0, n) /* (slice : sslice, n : int) -> sslice */  {
  if ($std_core_types._int_le(n,0)) {
    return slice_0;
  }
  else {
     
    var slice_0_0_10053 = advance(slice_0, n);
     
    var x_10056 = count(slice_0);
    var _x26 = slice_0_0_10053.str;
    var _x27 = slice_0_0_10053.start;
    return extend(Sslice(_x26, _x27, 0), $std_core_types._int_sub(x_10056,n));
  }
}
 
 
// Does string `s`  end with `post`?
// If so, returns a slice of `s` from the start up to the `post` string at the end.
export function ends_with(s, post) /* (s : string, post : string) -> maybe<sslice> */  {
  var _x28 = xends_with(s, post);
  if (_x28) {
     
    var x_10058 = s.length;
     
    var y_10059 = post.length;
    return $std_core_types.Just(Sslice(s, 0, $std_core_types._int_sub(x_10058,y_10059)));
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
 
// Return the first character of a string as a string (or the empty string)
export function head(s) /* (s : string) -> string */  {
   
  var slice_0 = first1(s);
  var _x32 = undefined;
  var _x31 = (_x32 !== undefined) ? _x32 : 1;
  var _x30 = $std_core_types._int_eq(_x31,1);
  if (_x30) {
    var _x29 = slice_0;
  }
  else {
    var _x34 = undefined;
    var _x33 = (_x34 !== undefined) ? _x34 : 1;
    var _x29 = extend(slice_0, $std_core_types._int_sub(_x33,1));
  }
  return string(_x29);
}
 
 
// Return the first character of a string (or `Nothing` for the empty string).
export function head_char(s) /* (s : string) -> maybe<char> */  {
  return foreach_while(Sslice(s, 0, s.length), $std_core_types.Just);
}
 
 
// O(`n`). The last `n` (default = `1`) characters in a string
export function last(s, n) /* (s : string, n : ? int) -> sslice */  {
   
  var slice_0 = last1(s);
  var _x36 = (n !== undefined) ? n : 1;
  var _x35 = $std_core_types._int_eq(_x36,1);
  if (_x35) {
    return slice_0;
  }
  else {
    var _x37 = (n !== undefined) ? n : 1;
    var _x38 = (n !== undefined) ? n : 1;
    return extend(advance(slice_0, $std_core_types._int_sub(1,_x37)), $std_core_types._int_sub(_x38,1));
  }
}
 
 
// Gets up to (`end`-`start`) characters from the slice beginning from `start`.
// If either start or end is negative, returns the original slice
export function subslice(slice_0, start, end) /* (slice : sslice, start : int, end : int) -> sslice */  {
  if ($std_core_types._int_lt(start,0)) {
    return slice_0;
  }
  else {
    if ($std_core_types._int_lt(end,0)) {
      return slice_0;
    }
    else {
       
      var slice_0_0_10070 = advance(slice_0, start);
      var _x39 = slice_0_0_10070.str;
      var _x40 = slice_0_0_10070.start;
      return extend(Sslice(_x39, _x40, 0), $std_core_types._int_sub(end,start));
    }
  }
}
 
 
// Return the tail of a string (or the empty string)
export function tail(s) /* (s : string) -> string */  {
   
  var slice_0_0 = first1(s);
   
  var _x43 = undefined;
  var _x42 = (_x43 !== undefined) ? _x43 : 1;
  var _x41 = $std_core_types._int_eq(_x42,1);
  if (_x41) {
    var slice_0_10075 = slice_0_0;
  }
  else {
    var _x45 = undefined;
    var _x44 = (_x45 !== undefined) ? _x45 : 1;
    var slice_0_10075 = extend(slice_0_0, $std_core_types._int_sub(_x44,1));
  }
   
  var x_0_10082 = (slice_0_10075.str).length;
   
  var y_0_10083 = $std_core_types._int_add((slice_0_10075.start),(slice_0_10075.len));
  var _x41 = Sslice(slice_0_10075.str, $std_core_types._int_add((slice_0_10075.start),(slice_0_10075.len)), $std_core_types._int_sub(x_0_10082,y_0_10083));
  return string(_x41);
}
 
 
// Gets a slice that only includes up to n characters from the start of the slice.
export function take(slice_0, n) /* (slice : sslice, n : int) -> sslice */  {
  if ($std_core_types._int_le(n,0)) {
    return slice_0;
  }
  else {
    var _x42 = slice_0.str;
    var _x43 = slice_0.start;
    return extend(Sslice(_x42, _x43, 0), n);
  }
}
 
 
// Trim off a substring `sub` while `s` starts with that string.
export function trim_left(s, sub) /* (s : string, sub : string) -> string */  { tailcall: while(1)
{
  if ((sub === (""))) {
    return s;
  }
  else {
    var _x44 = starts_with(s, sub);
    if (_x44 !== null) {
      {
        // tail call
        var _x45 = string(_x44.value);
        s = _x45;
        continue tailcall;
      }
    }
    else {
      return s;
    }
  }
}}
 
 
// Trim off a substring `sub` while `s` ends with that string.
export function trim_right(s, sub) /* (s : string, sub : string) -> string */  { tailcall: while(1)
{
  if ((sub === (""))) {
    return s;
  }
  else {
    var _x46 = ends_with(s, sub);
    if (_x46 !== null) {
      {
        // tail call
        var _x47 = string(_x46.value);
        s = _x47;
        continue tailcall;
      }
    }
    else {
      return s;
    }
  }
}}