// Koka generated module: std/core/delayed, koka version: 3.1.2
"use strict";
 
// imports
import * as $std_core_types from './std_core_types.mjs';
import * as $std_core_hnd from './std_core_hnd.mjs';
import * as $std_core_unsafe from './std_core_unsafe.mjs';
 
// externals
 
// type declarations
// type delayed
export function XDelay(dref) /* forall<e,a> (dref : ref<global,either<() -> e a,a>>) -> delayed<e,a> */  {
  return dref;
}
 
// declarations
 
 
// Automatically generated. Retrieves the `dref` constructor field of the `:delayed` type.
export function delayed_fs_dref(delayed) /* forall<e,a> (delayed : delayed<e,a>) -> ref<global,either<() -> e a,a>> */  {
  return delayed;
}
 
export function delayed_fs__copy(_this, dref) /* forall<e,a> (delayed<e,a>, dref : ? (ref<global,either<() -> e a,a>>)) -> delayed<e,a> */  {
  if (dref !== undefined) {
    var _x0 = dref;
  }
  else {
    var _x0 = _this;
  }
  return _x0;
}
 
 
// Create a new `:delayed` value.
export function delay(action) /* forall<a,e> (action : () -> e a) -> delayed<e,a> */  {
   
  var r = { value: ($std_core_types.Left(action)) };
  return r;
}
 
 
// monadic lift
export function _mlift_force_10010(r, x_0) /* forall<a,e> (r : ref<global,either<() -> e a,a>>, x@0 : a) -> <st<global>,div|e> a */  {
   
  ((r).value = ($std_core_types.Right(x_0)));
  return x_0;
}
 
 
// Force a delayed value; the value is computed only on the first
// call to `force` and cached afterwards.
export function force(delayed) /* forall<a,e> (delayed : delayed<e,a>) -> e a */  {
  var _x2 = delayed;
  var _x1 = _x2.value;
  if (_x1._tag === 2) {
    return _x1.right;
  }
  else {
     
    var x_0_10011 = _x1.left();
     
    var next_10012 = function(x_0_0 /* 270 */ ) {
       
      var _x3 = delayed;
      ((_x3).value = ($std_core_types.Right(x_0_0)));
      return x_0_0;
    };
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(next_10012);
    }
    else {
      return next_10012(x_0_10011);
    }
  }
}
 
 
// Given a total function to calculate a value `:a`, return
// a total function that only calculates the value once and then
// returns the cached result.
export function once(calc) /* forall<a> (calc : () -> a) -> (() -> a) */  {
   
  var r = { value: ($std_core_types.Nothing) };
  return function() {
    var _x3 = r.value;
    if (_x3 !== null) {
      return _x3.value;
    }
    else {
       
      var x_0 = calc();
       
      ((r).value = ($std_core_types.Just(x_0)));
      return x_0;
    }
  };
}