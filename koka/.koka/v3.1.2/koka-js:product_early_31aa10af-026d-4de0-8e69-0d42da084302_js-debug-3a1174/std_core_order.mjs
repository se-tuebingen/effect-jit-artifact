// Koka generated module: std/core/order, koka version: 3.1.2
"use strict";
 
// imports
import * as $std_core_types from './std_core_types.mjs';
import * as $std_core_int from './std_core_int.mjs';
 
// externals
 
// type declarations
 
// declarations
 
export function int(x) /* (x : order) -> int */  {
  if (x === 1) {
    return -1;
  }
  else if (x === 2) {
    return 0;
  }
  else {
    return 1;
  }
}
 
 
// Convert an `:order2` to an `:int` (`-1`, `0`, or `1`)
export function order2_fs_int(x) /* forall<a> (x : order2<a>) -> int */  {
  if (x._tag === 1) {
    return -1;
  }
  else if (x._tag === 2) {
    return 0;
  }
  else {
    return 1;
  }
}
 
 
// Given a comparison function, we can order 2 elements.
export function order2(x, y, cmp) /* forall<a> (x : a, y : a, cmp : (a, a) -> order) -> order2<a> */  {
  var _x0 = cmp(x, y);
  if (_x0 === 2) {
    return $std_core_types.Eq2(x);
  }
  else if (_x0 === 1) {
    return $std_core_types.Lt2(x, y);
  }
  else {
    return $std_core_types.Gt2(y, x);
  }
}
 
export function _lp__excl__eq__rp_(x, y) /* (x : order, y : order) -> bool */  {
  if (x === 1) {
    var _x1 = -1;
  }
  else if (x === 2) {
    var _x1 = 0;
  }
  else {
    var _x1 = 1;
  }
  if (y === 1) {
    var _x2 = -1;
  }
  else if (y === 2) {
    var _x2 = 0;
  }
  else {
    var _x2 = 1;
  }
  return $std_core_types._int_ne(_x1,_x2);
}
 
export function _lp__lt__rp_(x, y) /* (x : order, y : order) -> bool */  {
  if (x === 1) {
    var _x3 = -1;
  }
  else if (x === 2) {
    var _x3 = 0;
  }
  else {
    var _x3 = 1;
  }
  if (y === 1) {
    var _x4 = -1;
  }
  else if (y === 2) {
    var _x4 = 0;
  }
  else {
    var _x4 = 1;
  }
  return $std_core_types._int_lt(_x3,_x4);
}
 
export function _lp__lt__eq__rp_(x, y) /* (x : order, y : order) -> bool */  {
  if (x === 1) {
    var _x5 = -1;
  }
  else if (x === 2) {
    var _x5 = 0;
  }
  else {
    var _x5 = 1;
  }
  if (y === 1) {
    var _x6 = -1;
  }
  else if (y === 2) {
    var _x6 = 0;
  }
  else {
    var _x6 = 1;
  }
  return $std_core_types._int_le(_x5,_x6);
}
 
export function _lp__eq__eq__rp_(x, y) /* (x : order, y : order) -> bool */  {
  if (x === 1) {
    var _x7 = -1;
  }
  else if (x === 2) {
    var _x7 = 0;
  }
  else {
    var _x7 = 1;
  }
  if (y === 1) {
    var _x8 = -1;
  }
  else if (y === 2) {
    var _x8 = 0;
  }
  else {
    var _x8 = 1;
  }
  return $std_core_types._int_eq(_x7,_x8);
}
 
export function _lp__gt__rp_(x, y) /* (x : order, y : order) -> bool */  {
  if (x === 1) {
    var _x9 = -1;
  }
  else if (x === 2) {
    var _x9 = 0;
  }
  else {
    var _x9 = 1;
  }
  if (y === 1) {
    var _x10 = -1;
  }
  else if (y === 2) {
    var _x10 = 0;
  }
  else {
    var _x10 = 1;
  }
  return $std_core_types._int_gt(_x9,_x10);
}
 
export function _lp__gt__eq__rp_(x, y) /* (x : order, y : order) -> bool */  {
  if (x === 1) {
    var _x11 = -1;
  }
  else if (x === 2) {
    var _x11 = 0;
  }
  else {
    var _x11 = 1;
  }
  if (y === 1) {
    var _x12 = -1;
  }
  else if (y === 2) {
    var _x12 = 0;
  }
  else {
    var _x12 = 1;
  }
  return $std_core_types._int_ge(_x11,_x12);
}