// Koka generated module: std/core/vector, koka version: 3.1.2
"use strict";
 
// imports
import * as $std_core_types from './std_core_types.mjs';
import * as $std_core_undiv from './std_core_undiv.mjs';
import * as $std_core_hnd from './std_core_hnd.mjs';
import * as $std_core_exn from './std_core_exn.mjs';
import * as $std_core_int from './std_core_int.mjs';
 
// externals
/*---------------------------------------------------------------------------
  Copyright 2012-2023, Microsoft Research, Daan Leijen.
  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/
// Create a list with from a vector in constant stack space
export function _vlist(elems,tail) {
  var xs = tail || $std_core_types.Nil;
  if (elems!=null && elems.length>0) {
    for(var i = elems.length - 1; i >= 0; i--) {
      var elem = elems[i];
      if (elem !== undefined) xs = $std_core_types.Cons(elem,xs);
    }
  }
  return xs;
}
// Create an array from a list with constant stack space
export function _unvlist(list) {
  var elems = [];
  while(list) {
    elems.push(list.head);
    list = list.tail;
  }
  return elems;
}
// Create a vector with a default value
export function _vector_initz(n, x) {
  if (n<=0) return [];
  var a = new Array(n);
  for(var i = 0; i < n; i++) {
    a[i] = x;
  }
  return a;
}
// Create a vector with a function initializer
export function _vector_initf(n, f) {
  if (n<=0) return [];
  var a = new Array(n);
  for(var i = 0; i < n; i++) {
    a[i] = f(i);
  }
  return a;
}
// Index a vector
export function _vector_at( v, i ) {
  var j = _int_to_number(i);
  var x = v[j];
  if (x === undefined) { $std_core_exn.exn_error_range(); }
  return x;
}
 
// type declarations
 
// declarations
 
 
// Return the element at position `index`  in vector `v`.
// Raise an out of bounds exception if `index < 0`  or `index >= v.length`.
export function _index(v, index) /* forall<a> (v : vector<a>, index : int) -> exn a */  {
   
  var idx = $std_core_int.ssize__t(index);
  var _x0 = (idx < (((v).length)));
  if (_x0) {
    return (v)[idx];
  }
  else {
    return $std_core_exn.$throw("index out of bounds", $std_core_exn.ExnRange);
  }
}
 
 
// Return the element at position `index` in vector `v`, or `Nothing` if out of bounds
export function at(v, index) /* forall<a> (v : vector<a>, index : int) -> maybe<a> */  {
   
  var idx = $std_core_int.ssize__t(index);
  var _x1 = (idx < (((v).length)));
  if (_x1) {
    return $std_core_types.Just((v)[idx]);
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
export function ssize__t_fs_incr(i) /* (i : ssize_t) -> ssize_t */  {
  return (i + 1);
}
 
 
// Return the length of a vector.
export function length(v) /* forall<a> (v : vector<a>) -> int */  {
  return $std_core_types._int_from_int32((((v).length)));
}
 
 
// Convert a vector to a list with an optional tail.
export function vlist(v, tail) /* forall<a> (v : vector<a>, tail : ? (list<a>)) -> list<a> */  {
  var _x2 = (tail !== undefined) ? tail : $std_core_types.Nil;
  return _vlist(v,_x2);
}
 
export function unvlist(xs) /* forall<a> (xs : list<a>) -> vector<a> */  {
  return _unvlist(xs);
}
 
 
// Create a new vector of length `n`  with initial elements `init`` .
export function vector_alloc(n, init) /* forall<a,e> (n : ssize_t, init : a) -> e vector<a> */  {
  return _vector_initz(n,init);
}
 
 
// Create a new vector of length `n`  with initial elements given by a total function `f` .
export function vector_alloc_total(n, f) /* forall<a> (n : ssize_t, f : (ssize_t) -> a) -> vector<a> */  {
  return _vector_initf(n,f);
}
 
export function ssize__t_fs_decr(i) /* (i : ssize_t) -> ssize_t */  {
  return (i - 1);
}
 
export function ssize__t_fs_is_zero(i) /* (i : ssize_t) -> bool */  {
  return (i === 0);
}
 
 
// monadic lift
export function _mlift_lift_for_whilez_868_10045(action, i, n, _y_x10023) /* forall<a,e> (action : (ssize_t) -> e maybe<a>, i : ssize_t, n : ssize_t, maybe<a>) -> e maybe<a> */  {
  if (_y_x10023 === null) {
     
    var i_0_10000 = ssize__t_fs_incr(i);
    return _lift_for_whilez_868(action, n, i_0_10000);
  }
  else {
    return $std_core_types.Just(_y_x10023.value);
  }
}
 
 
// lifted local: for-whilez, rep
export function _lift_for_whilez_868(action_0, n_0, i_0) /* forall<a,e> (action : (ssize_t) -> e maybe<a>, n : ssize_t, i : ssize_t) -> e maybe<a> */  { tailcall: while(1)
{
  if ((i_0 < n_0)) {
     
    var x_0_10051 = action_0(i_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10023_0 /* maybe<484> */ ) {
        return _mlift_lift_for_whilez_868_10045(action_0, i_0, n_0, _y_x10023_0);
      });
    }
    else {
      if (x_0_10051 === null) {
         
        var i_0_10000_0 = ssize__t_fs_incr(i_0);
        {
          // tail call
          i_0 = i_0_10000_0;
          continue tailcall;
        }
      }
      else {
        return $std_core_types.Just(x_0_10051.value);
      }
    }
  }
  else {
    return $std_core_types.Nothing;
  }
}}
 
 
// Executes `action` at most `n` times for each integer between `0`  upto `n`  (excluding `n` ).
// If `n <= 0`  the function returns without any call to `action` .
// If `action` returns `Just`, the iteration is stopped and the result returned
export function for_whilez(n, action) /* forall<a,e> (n : ssize_t, action : (ssize_t) -> e maybe<a>) -> e maybe<a> */  {
   
  var i = 0;
  return _lift_for_whilez_868(action, n, i);
}
 
 
// monadic lift
export function _mlift_lift_forz_869_10046(action, i, n, wild__) /* forall<e> (action : (ssize_t) -> e (), i : ssize_t, n : ssize_t, wild_ : ()) -> e () */  {
   
  var i_0_10001 = ssize__t_fs_incr(i);
  return _lift_forz_869(action, n, i_0_10001);
}
 
 
// lifted local: forz, rep
export function _lift_forz_869(action_0, n_0, i_0) /* forall<e> (action : (ssize_t) -> e (), n : ssize_t, i : ssize_t) -> e () */  { tailcall: while(1)
{
  if ((i_0 < n_0)) {
     
    var x_10054 = action_0(i_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
        return _mlift_lift_forz_869_10046(action_0, i_0, n_0, wild___0);
      });
    }
    else {
       
      var i_0_10001_0 = ssize__t_fs_incr(i_0);
      {
        // tail call
        i_0 = i_0_10001_0;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types.Unit;
  }
}}
 
 
// Executes `action` `n` times for each integer between [`0`,`n`)  (excluding `n` ).
// If `n <= 0`  the function returns without any call to `action` .
export function forz(n, action) /* forall<e> (n : ssize_t, action : (ssize_t) -> e ()) -> e () */  {
   
  var i = 0;
  return _lift_forz_869(action, n, i);
}
 
export function foreach_indexedz(v, f) /* forall<a,e> (v : vector<a>, f : (ssize_t, a) -> e ()) -> e () */  {
   
  var n_10002 = ((v).length);
   
  var i = 0;
  return _lift_forz_869(function(i_0 /* ssize_t */ ) {
      return f(i_0, (v)[i_0]);
    }, n_10002, i);
}
 
 
// Invoke a function `f` for each element in a vector `v`
export function foreach(v, f) /* forall<a,e> (v : vector<a>, f : (a) -> e ()) -> e () */  {
   
  var n_10002 = ((v).length);
   
  var i = 0;
  return _lift_forz_869(function(i_0 /* ssize_t */ ) {
       
      var x_10015 = (v)[i_0];
      return f(x_10015);
    }, n_10002, i);
}
 
 
// Invoke a function `f` for each element in a vector `v`
export function foreach_indexed(v, f) /* forall<a,e> (v : vector<a>, f : (int, a) -> e ()) -> e () */  {
   
  var n_10002 = ((v).length);
   
  var i = 0;
  return _lift_forz_869(function(i_0 /* ssize_t */ ) {
       
      var x_10017 = (v)[i_0];
      return f($std_core_types._int_from_int32(i_0), x_10017);
    }, n_10002, i);
}
 
 
// Invoke a function `f` for each element in a vector `v`.
// If `f` returns `Just`, the iteration is stopped early and the result is returned.
export function foreach_while(v, f) /* forall<a,b,e> (v : vector<a>, f : (a) -> e maybe<b>) -> e maybe<b> */  {
   
  var n_10004 = ((v).length);
   
  var i = 0;
  return _lift_for_whilez_868(function(i_0 /* ssize_t */ ) {
      return f((v)[i_0]);
    }, n_10004, i);
}
 
 
// Convert a vector to a list.
export function list(v) /* forall<a> (v : vector<a>) -> list<a> */  {
  return vlist(v);
}
 
 
// monadic lift
export function _mlift_map_10047(i_0, w, _y_x10040) /* forall<a,e> (i@0 : ssize_t, w : vector<a>, a) -> e () */  {
  return (w)[i_0] = _y_x10040;
}
 
 
// monadic lift
export function _mlift_map_10048(w, wild__) /* forall<a,e> (w : vector<a>, wild_ : ()) -> e vector<a> */  {
  return w;
}
 
 
// Apply a total function `f` to each element in a vector `v`
export function map(v, f) /* forall<a,b,e> (v : vector<a>, f : (a) -> e b) -> e vector<b> */  {
   
  var w = Array(($std_core_int.ssize__t($std_core_types._int_from_int32((((v).length))))));
   
  var n_10002 = ((v).length);
   
  var i = 0;
   
  var x_10057 = _lift_forz_869(function(i_0 /* ssize_t */ ) {
       
      var x_10019 = (v)[i_0];
       
      var x_0_10060 = f(x_10019);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_y_x10040 /* 735 */ ) {
          return (w)[i_0] = _y_x10040;
        });
      }
      else {
        return (w)[i_0] = x_0_10060;
      }
    }, n_10002, i);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild__ /* () */ ) {
      return w;
    });
  }
  else {
    return w;
  }
}
 
 
// Create a new vector of length `n`  with initial elements `default` .
export function vector(n, $default) /* forall<a> (n : int, default : a) -> vector<a> */  {
  return vector_alloc($std_core_int.ssize__t(n), $default);
}
 
 
// monadic lift
export function _mlift_vector_init_10049(i_0, v, _y_x10042) /* forall<a,e> (i@0 : ssize_t, v : vector<a>, a) -> e () */  {
  return (v)[i_0] = _y_x10042;
}
 
 
// monadic lift
export function _mlift_vector_init_10050(v, wild__) /* forall<a,e> (v : vector<a>, wild_ : ()) -> e vector<a> */  {
  return v;
}
 
 
// Create a new vector of length `n`  with initial elements given by function `f` which can have a control effect.
export function vector_init(n, f) /* forall<a,e> (n : int, f : (int) -> e a) -> e vector<a> */  {
   
  var len = $std_core_int.ssize__t(n);
   
  var v = Array(len);
   
  var i = 0;
   
  var x_10067 = _lift_forz_869(function(i_0 /* ssize_t */ ) {
       
      var x_0_10070 = f($std_core_types._int_from_int32(i_0));
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_y_x10042 /* 809 */ ) {
          return (v)[i_0] = _y_x10042;
        });
      }
      else {
        return (v)[i_0] = x_0_10070;
      }
    }, len, i);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild__ /* () */ ) {
      return v;
    });
  }
  else {
    return v;
  }
}
 
 
// Create a new vector of length `n`  with initial elements given by _total_ function `f`.
// (can be more efficient than `vector-init`)
export function vector_init_total(n, f) /* forall<a,e> (n : int, f : (int) -> a) -> e vector<a> */  {
  return vector_alloc_total($std_core_int.ssize__t(n), function(i /* ssize_t */ ) {
      return f($std_core_types._int_from_int32(i));
    });
}
 
 
// Convert a list to a vector.
export function list_fs_vector(xs) /* forall<a> (xs : list<a>) -> vector<a> */  {
  return unvlist(xs);
}