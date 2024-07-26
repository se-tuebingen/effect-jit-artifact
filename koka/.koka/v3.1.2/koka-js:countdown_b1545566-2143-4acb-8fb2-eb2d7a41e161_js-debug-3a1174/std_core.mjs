// Koka generated module: std/core, koka version: 3.1.2
"use strict";
 
// imports
import * as $std_core_types from './std_core_types.mjs';
import * as $std_core_undiv from './std_core_undiv.mjs';
import * as $std_core_unsafe from './std_core_unsafe.mjs';
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
 
// externals
 
// type declarations
// type blocking
// type fsys
// type global-scope
// type net
// type ui
// type nmd
// type scope
// type stream
export function Next(head, tail) /* forall<a> (head : a, tail : stream<a>) -> stream<a> */  {
  return { head: head, tail: tail };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `head` constructor field of the `:stream` type.
export function stream_fs_head(stream) /* forall<a> (stream : stream<a>) -> a */  {
  return stream.head;
}
 
 
// Automatically generated. Retrieves the `tail` constructor field of the `:stream` type.
export function stream_fs_tail(stream) /* forall<a> (stream : stream<a>) -> stream<a> */  {
  return stream.tail;
}
 
export function stream_fs__copy(_this, head, tail) /* forall<a> (stream<a>, head : ? a, tail : ? (stream<a>)) -> stream<a> */  {
  if (head !== undefined) {
    var _x0 = head;
  }
  else {
    var _x0 = _this.head;
  }
  if (tail !== undefined) {
    var _x1 = tail;
  }
  else {
    var _x1 = _this.tail;
  }
  return Next(_x0, _x1);
}
 
 
// The default exception handler
export function _default_exn(action) /* forall<e> (action : () -> <exn,console/console|e> ()) -> <console/console|e> () */  {
  return $std_core_exn._handle_exn($std_core_exn._Hnd_exn(0, function(m /* hnd/marker<<console/console|398>,()> */ , ___wildcard_x696__16 /* hnd/ev<exn> */ , x /* exception */ ) {
        return $std_core_hnd.yield_to_final(m, function(___wildcard_x696__45 /* (hnd/resume-result<387,()>) -> <console/console|398> () */ ) {
             
            $std_core_console.prints("uncaught exception: ");
            return $std_core_console.printsln($std_core_exn.show(x));
          });
      }), function(_x /* () */ ) {
      return _x;
    }, action);
}
 
 
// Generic equality if `cmp` exists
export function cmp_fs__lp__eq__eq__rp_(x, y, _implicit_fs_cmp) /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */  {
  var _x2 = _implicit_fs_cmp(x, y);
  return (_x2 === 2);
}
 
 
// Apply a function `f` to a specified argument `x`.
export function apply(f, x) /* forall<a,b,e> (f : (a) -> e b, x : a) -> e b */  {
  return f(x);
}
 
 
// Return a 'constant' function that ignores its argument and always returns the same result
export function $const($default) /* forall<a,b> (default : a) -> ((x : b) -> a) */  {
  return function(___wildcard_x103__6 /* 470 */ ) {
    return $default;
  };
}
 
 
// Return the host environment: `dotnet`, `browser`, `webworker`, `node`, or `libc`, or `vm`.
export function host() /* () -> ndet string */  {
  return $std_core_console._host;
}
 
 
// The `ignore` function ignores its argument.
export function ignore(x) /* forall<a> (x : a) -> () */  {
  return $std_core_types.Unit;
}
 
 
// Used by the compiler to wrap main console applications
export function main_console(main) /* forall<a,e> (main : () -> e a) -> e a */  {
  return (main)();
}
 
 
// Compose two functions `f` and `g`.
export function o(f, g) /* forall<a,b,c,e> (f : (a) -> e b, g : (c) -> e a) -> ((x : c) -> e b) */  {
  return function(x /* 522 */ ) {
     
    var x_0_10078 = g(x);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(f);
    }
    else {
      return f(x_0_10078);
    }
  };
}
 
 
// Concise way to ensure two expressions have the same type.
export function same_type(x, y) /* forall<a> (x : a, y : a) -> a */  {
  return x;
}
 
export var unique_count;
var unique_count = { value: 0 };
 
 
// Generic inequality
export function _lp__excl__eq__rp_(x, y, _implicit_fs__lp__eq__eq__rp_) /* forall<a> (x : a, y : a, ?(==) : (a, a) -> bool) -> bool */  {
   
  var b_10003 = _implicit_fs__lp__eq__eq__rp_(x, y);
  return (b_10003) ? false : true;
}
 
 
// Generic lower than
export function _lp__lt__rp_(x, y, _implicit_fs_cmp) /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */  {
  return $std_core_order._lp__eq__eq__rp_(_implicit_fs_cmp(x, y), $std_core_types.Lt);
}
 
 
// Generic greater than
export function _lp__gt__rp_(x, y, _implicit_fs_cmp) /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */  {
  return $std_core_order._lp__eq__eq__rp_(_implicit_fs_cmp(x, y), $std_core_types.Gt);
}
 
 
// Generic lower than or equal
export function _lp__lt__eq__rp_(x, y, _implicit_fs_cmp) /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */  {
  return $std_core_order._lp__eq__eq__rp_(_implicit_fs_cmp(y, x), $std_core_types.Gt);
}
 
 
// Generic greater than or equal
export function _lp__gt__eq__rp_(x, y, _implicit_fs_cmp) /* forall<a> (x : a, y : a, ?cmp : (a, a) -> order) -> bool */  {
  return $std_core_order._lp__eq__eq__rp_(_implicit_fs_cmp(y, x), $std_core_types.Lt);
}
 
 
// monadic lift
export function range_fs__mlift_fold_10071(end, f, start, x) /* forall<a,e> (end : int, f : (int, a) -> e a, start : int, x : a) -> e a */  {
  return range_fs_fold($std_core_types._int_add(start,1), end, x, f);
}
 
 
// Fold over the integers between [`start`,`end`] (including `end`).
export function range_fs_fold(start_0, end_0, init, f_0) /* forall<a,e> (start : int, end : int, init : a, f : (int, a) -> e a) -> e a */  { tailcall: while(1)
{
  if ($std_core_types._int_gt(start_0,end_0)) {
    return init;
  }
  else {
     
    var x_0_10080 = f_0(start_0, init);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(x_1 /* 885 */ ) {
        return range_fs__mlift_fold_10071(end_0, f_0, start_0, x_1);
      });
    }
    else {
      {
        // tail call
        var _x3 = $std_core_types._int_add(start_0,1);
        start_0 = _x3;
        init = x_0_10080;
        continue tailcall;
      }
    }
  }
}}
 
 
// Fold over the integers between [0,`upto`)  (excluding `upto`).
export function fold(upto, init, f) /* forall<a,e> (upto : int, init : a, f : (int, a) -> e a) -> e a */  {
  return range_fs_fold(0, $std_core_types._int_sub(upto,1), init, f);
}
 
 
// monadic lift
export function range_fs__mlift_fold_while_10072(end, f, init, start, _y_x10033) /* forall<a,e> (end : int, f : (int, a) -> e maybe<a>, init : a, start : int, maybe<a>) -> e a */  {
  if (_y_x10033 !== null) {
    return range_fs_fold_while($std_core_types._int_add(start,1), end, _y_x10033.value, f);
  }
  else {
    return init;
  }
}
 
 
// Fold over the integers between [`start`,`end`] (including `end`) or until `f` returns `Nothing`
export function range_fs_fold_while(start_0, end_0, init_0, f_0) /* forall<a,e> (start : int, end : int, init : a, f : (int, a) -> e maybe<a>) -> e a */  { tailcall: while(1)
{
  if ($std_core_types._int_gt(start_0,end_0)) {
    return init_0;
  }
  else {
     
    var x_0_10083 = f_0(start_0, init_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10033_0 /* maybe<982> */ ) {
        return range_fs__mlift_fold_while_10072(end_0, f_0, init_0, start_0, _y_x10033_0);
      });
    }
    else {
      if (x_0_10083 !== null) {
        {
          // tail call
          var _x4 = $std_core_types._int_add(start_0,1);
          start_0 = _x4;
          init_0 = x_0_10083.value;
          continue tailcall;
        }
      }
      else {
        return init_0;
      }
    }
  }
}}
 
 
// Fold over the integers between [0,`n`) (excluding `n`) or until `f` returns `Nothing`
export function fold_while(n, init, f) /* forall<a,e> (n : int, init : a, f : (int, a) -> e maybe<a>) -> e a */  {
  return range_fs_fold_while(0, $std_core_types._int_sub(n,1), init, f);
}
 
 
// monadic lift
export function range_fs__mlift_lift_for_1256_10073(action, end, i, wild__) /* forall<e> (action : (int) -> e (), end : int, i : int, wild_ : ()) -> e () */  {
   
  var i_0_10010 = $std_core_types._int_add(i,1);
  return range_fs__lift_for_1256(action, end, i_0_10010);
}
 
 
// lifted local: range/for, rep
export function range_fs__lift_for_1256(action_0, end_0, i_0) /* forall<e> (action : (int) -> e (), end : int, i : int) -> e () */  { tailcall: while(1)
{
  if ($std_core_types._int_le(i_0,end_0)) {
     
    var x_10086 = action_0(i_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
        return range_fs__mlift_lift_for_1256_10073(action_0, end_0, i_0, wild___0);
      });
    }
    else {
       
      var i_0_10010_0 = $std_core_types._int_add(i_0,1);
      {
        // tail call
        i_0 = i_0_10010_0;
        continue tailcall;
      }
    }
  }
  else {
    return $std_core_types.Unit;
  }
}}
 
 
// Executes `action`  for each integer from `start` to `end` (including `end` ).
// If `start > end`  the function returns without any call to `action` .
export function range_fs_for(start, end, action) /* forall<e> (start : int, end : int, action : (int) -> e ()) -> e () */  {
  return range_fs__lift_for_1256(action, end, start);
}
 
 
// Executes `action` `n` times for each integer from `0` to `n-1`.
// If `n <= 0`  the function returns without any call to `action` .
export function $for(n, action) /* forall<e> (n : int, action : (int) -> e ()) -> e () */  {
   
  var end_10012 = $std_core_types._int_sub(n,1);
  return range_fs__lift_for_1256(action, end_10012, 0);
}
 
 
// monadic lift
export function range_fs__mlift_lift_for_while_1257_10074(action, end, i, _y_x10043) /* forall<a,e> (action : (int) -> e maybe<a>, end : int, i : int, maybe<a>) -> e maybe<a> */  {
  if (_y_x10043 === null) {
     
    var i_0_10014 = $std_core_types._int_add(i,1);
    return range_fs__lift_for_while_1257(action, end, i_0_10014);
  }
  else {
    return $std_core_types.Just(_y_x10043.value);
  }
}
 
 
// lifted local: range/for-while, rep
export function range_fs__lift_for_while_1257(action_0, end_0, i_0) /* forall<a,e> (action : (int) -> e maybe<a>, end : int, i : int) -> e maybe<a> */  { tailcall: while(1)
{
  if ($std_core_types._int_le(i_0,end_0)) {
     
    var x_0_10089 = action_0(i_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10043_0 /* maybe<1121> */ ) {
        return range_fs__mlift_lift_for_while_1257_10074(action_0, end_0, i_0, _y_x10043_0);
      });
    }
    else {
      if (x_0_10089 === null) {
         
        var i_0_10014_0 = $std_core_types._int_add(i_0,1);
        {
          // tail call
          i_0 = i_0_10014_0;
          continue tailcall;
        }
      }
      else {
        return $std_core_types.Just(x_0_10089.value);
      }
    }
  }
  else {
    return $std_core_types.Nothing;
  }
}}
 
 
// Executes `action`  for each integer between `start`  to `end`  (including `end` ).
// If `start > end`  the function returns without any call to `action` .
// If `action` returns `Just`, the iteration is stopped and the result returned
export function range_fs_for_while(start, end, action) /* forall<a,e> (start : int, end : int, action : (int) -> e maybe<a>) -> e maybe<a> */  {
  return range_fs__lift_for_while_1257(action, end, start);
}
 
 
// Executes `action`  for each integer between [0,`n`)  (excluding `n` ).
// If `n <= 0`  the function returns without any call to `action` .
// If `action` returns `Just`, the iteration is stopped and the result returned
export function for_while(n, action) /* forall<a,e> (n : int, action : (int) -> e maybe<a>) -> e maybe<a> */  {
   
  var end_10016 = $std_core_types._int_sub(n,1);
  return range_fs__lift_for_while_1257(action, end_10016, 0);
}
 
 
// The `repeat` fun executes `action`  `n`  times.
export function repeat(n, action) /* forall<e> (n : int, action : () -> e ()) -> e () */  {
   
  var end_10021 = $std_core_types._int_sub(n,1);
  return range_fs__lift_for_1256(function(i_0 /* int */ ) {
      return action();
    }, end_10021, 0);
}
 
 
// Returns a unique integer (modulo 32-bits).
export function unique() /* () -> ndet int */  {
   
  var u = unique_count.value;
   
  ((unique_count).value = ($std_core_types._int_add(u,1)));
  return u;
}
 
 
// monadic lift
export function _mlift_while_10075(action, predicate, wild__) /* forall<e> (action : () -> <div|e> (), predicate : () -> <div|e> bool, wild_ : ()) -> <div|e> () */  {
  return $while(predicate, action);
}
 
 
// monadic lift
export function _mlift_while_10076(action_0, predicate_0, _y_x10051) /* forall<e> (action : () -> <div|e> (), predicate : () -> <div|e> bool, bool) -> <div|e> () */  {
  if (_y_x10051) {
     
    var x_10092 = action_0();
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
        return _mlift_while_10075(action_0, predicate_0, wild___0);
      });
    }
    else {
      return _mlift_while_10075(action_0, predicate_0, x_10092);
    }
  }
  else {
    return $std_core_types.Unit;
  }
}
 
 
// The `while` fun executes `action`  as long as `pred`  is `true`.
export function $while(predicate_1, action_1) /* forall<e> (predicate : () -> <div|e> bool, action : () -> <div|e> ()) -> <div|e> () */  { tailcall: while(1)
{
   
  var x_0_10094 = predicate_1();
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10051_0 /* bool */ ) {
      return _mlift_while_10076(action_1, predicate_1, _y_x10051_0);
    });
  }
  else {
    if (x_0_10094) {
       
      var x_1_10097 = action_1();
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(wild___1 /* () */ ) {
          return _mlift_while_10075(action_1, predicate_1, wild___1);
        });
      }
      else {
        {
          // tail call
          continue tailcall;
        }
      }
    }
    else {
      return $std_core_types.Unit;
    }
  }
}}