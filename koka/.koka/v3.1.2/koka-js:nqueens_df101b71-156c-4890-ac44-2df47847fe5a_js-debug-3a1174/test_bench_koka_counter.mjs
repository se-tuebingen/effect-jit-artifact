// Koka generated module: test/bench/koka/counter, koka version: 3.1.2
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
import * as $std_num_int32 from './std_num_int32.mjs';
 
// externals
 
// type declarations
 
 
// runtime tag for the effect `:st`
export var _tag_st;
var _tag_st = "st@counter";
// type st
export function _Hnd_st(_cfc, _fun_get, _fun_set) /* forall<e,a> (int, hnd/clause0<int32,st,e,a>, hnd/clause1<int32,(),st,e,a>) -> st<e,a> */  {
  return { _cfc: _cfc, _fun_get: _fun_get, _fun_set: _fun_set };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:st` type.
export function st_fs__cfc(st) /* forall<e,a> (st : st<e,a>) -> int */  {
  return st._cfc;
}
 
 
// Automatically generated. Retrieves the `@fun-get` constructor field of the `:st` type.
export function st_fs__fun_get(st) /* forall<e,a> (st : st<e,a>) -> hnd/clause0<int32,st,e,a> */  {
  return st._fun_get;
}
 
 
// Automatically generated. Retrieves the `@fun-set` constructor field of the `:st` type.
export function st_fs__fun_set(st) /* forall<e,a> (st : st<e,a>) -> hnd/clause1<int32,(),st,e,a> */  {
  return st._fun_set;
}
 
 
// handler for the effect `:st`
export function _handle_st(hnd, ret, action) /* forall<a,e,b> (hnd : st<e,b>, ret : (res : a) -> e b, action : () -> <st|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_st, hnd, ret, action);
}
 
 
// select `get` operation out of effect `:st`
export function _select_get(hnd) /* forall<e,a> (hnd : st<e,a>) -> hnd/clause0<int32,st,e,a> */  {
  return hnd._fun_get;
}
 
 
// select `set` operation out of effect `:st`
export function _select_set(hnd) /* forall<e,a> (hnd : st<e,a>) -> hnd/clause1<int32,(),st,e,a> */  {
  return hnd._fun_set;
}
 
 
// Call the `fun get` operation of the effect `:st`
export function get() /* () -> st int32 */  {
   
  var ev_10015 = $std_core_hnd._evv_at(0);
  return (ev_10015.hnd._fun_get)(ev_10015.marker, ev_10015);
}
 
 
// Call the `fun set` operation of the effect `:st`
export function set(i) /* (i : int32) -> st () */  {
   
  var ev_10017 = $std_core_hnd._evv_at(0);
  return ev_10017.hnd._fun_set(ev_10017.marker, ev_10017, i);
}
 
export function counter(c) /* (c : int32) -> <div,st> int */  { tailcall: while(1)
{
   
  var ev_10020 = $std_core_hnd._evv_at(0);
   
  var i = (ev_10020.hnd._fun_get)(ev_10020.marker, ev_10020);
  if ((i === ($std_num_int32.zero))) {
    return $std_core_types._int_from_int32(c);
  }
  else {
     
    var i_0_10000 = ((i - 1)|0);
     
    var ev_0_10022 = $std_core_hnd._evv_at(0);
     
    ev_0_10022.hnd._fun_set(ev_0_10022.marker, ev_0_10022, i_0_10000);
    {
      // tail call
      var _x0 = ((c + 1)|0);
      c = _x0;
      continue tailcall;
    }
  }
}}
 
export function state(i, action) /* forall<a,e> (i : int32, action : () -> <st|e> a) -> e a */  {
  return function() {
     
    var loc = { value: i };
     
    var res = _handle_st(_Hnd_st(1, $std_core_hnd.clause_tail0(function() {
          return ((loc).value);
        }), $std_core_hnd.clause_tail1(function(x /* int32 */ ) {
          return ((loc).value = x);
        })), function(_x /* 618 */ ) {
        return _x;
      }, action);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
export function main() /* () -> <console/console,div> () */  {
  return state(100100100, function() {
       
      var _x_x1_10012 = counter($std_num_int32.zero);
      return $std_core_hnd._open_none2(function(x /* int */ , _implicit_fs_show /* (int) -> string */ ) {
          return $std_core_console.printsln(_implicit_fs_show(x));
        }, _x_x1_10012, $std_core_int.show);
    });
}