// Koka generated module: main, koka version: 3.1.2
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
import * as $std_os_env from './std_os_env.mjs';
 
// externals
 
// type declarations
 
 
// runtime tag for the effect `:state`
export var _tag_state;
var _tag_state = "state@main";
// type state
export function _Hnd_state(_cfc, _fun_get, _fun_set) /* forall<e,a> (int, hnd/clause0<int,state,e,a>, hnd/clause1<int,(),state,e,a>) -> state<e,a> */  {
  return { _cfc: _cfc, _fun_get: _fun_get, _fun_set: _fun_set };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:state` type.
export function state_fs__cfc(state) /* forall<e,a> (state : state<e,a>) -> int */  {
  return state._cfc;
}
 
 
// Automatically generated. Retrieves the `@fun-get` constructor field of the `:state` type.
export function state_fs__fun_get(state) /* forall<e,a> (state : state<e,a>) -> hnd/clause0<int,state,e,a> */  {
  return state._fun_get;
}
 
 
// Automatically generated. Retrieves the `@fun-set` constructor field of the `:state` type.
export function state_fs__fun_set(state) /* forall<e,a> (state : state<e,a>) -> hnd/clause1<int,(),state,e,a> */  {
  return state._fun_set;
}
 
 
// handler for the effect `:state`
export function _handle_state(hnd, ret, action) /* forall<a,e,b> (hnd : state<e,b>, ret : (res : a) -> e b, action : () -> <state|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_state, hnd, ret, action);
}
 
 
// select `get` operation out of effect `:state`
export function _select_get(hnd) /* forall<e,a> (hnd : state<e,a>) -> hnd/clause0<int,state,e,a> */  {
  return hnd._fun_get;
}
 
 
// select `set` operation out of effect `:state`
export function _select_set(hnd) /* forall<e,a> (hnd : state<e,a>) -> hnd/clause1<int,(),state,e,a> */  {
  return hnd._fun_set;
}
 
 
// Call the `fun get` operation of the effect `:state`
export function get() /* () -> state int */  {
   
  var ev_10021 = $std_core_hnd._evv_at(0);
  return (ev_10021.hnd._fun_get)(ev_10021.marker, ev_10021);
}
 
 
// Call the `fun set` operation of the effect `:state`
export function set(i) /* (i : int) -> state () */  {
   
  var ev_10023 = $std_core_hnd._evv_at(0);
  return ev_10023.hnd._fun_set(ev_10023.marker, ev_10023, i);
}
 
 
// monadic lift
export function _mlift_countdown_10018(wild__) /* (wild_ : ()) -> state int */  {
  return countdown();
}
 
 
// monadic lift
export function _mlift_countdown_10019(i) /* (i : int) -> state int */  {
  if ($std_core_types._int_eq(i,0)) {
    return i;
  }
  else {
     
    var i_0_10000 = $std_core_types._int_sub(i,1);
     
    var ev_10028 = $std_core_hnd._evv_at(0);
     
    var x_10026 = ev_10028.hnd._fun_set(ev_10028.marker, ev_10028, i_0_10000);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(_mlift_countdown_10018);
    }
    else {
      return _mlift_countdown_10018(x_10026);
    }
  }
}
 
export function countdown() /* () -> <div,state> int */  { tailcall: while(1)
{
   
  var ev_0_10034 = $std_core_hnd._evv_at(0);
   
  var x_1_10031 = (ev_0_10034.hnd._fun_get)(ev_0_10034.marker, ev_0_10034);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_countdown_10019);
  }
  else {
    if ($std_core_types._int_eq(x_1_10031,0)) {
      return x_1_10031;
    }
    else {
       
      var i_0_10000_0 = $std_core_types._int_sub(x_1_10031,1);
       
      var ev_1_10039 = $std_core_hnd._evv_at(0);
       
      var x_2_10036 = ev_1_10039.hnd._fun_set(ev_1_10039.marker, ev_1_10039, i_0_10000_0);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(_mlift_countdown_10018);
      }
      else {
        {
          // tail call
          continue tailcall;
        }
      }
    }
  }
}}
 
export function run(n) /* (n : int) -> div int */  {
  return function() {
     
    var loc = { value: n };
     
    var res = _handle_state(_Hnd_state(1, function(___wildcard_x737__14 /* hnd/marker<<local<603>,div>,int> */ , ___wildcard_x737__17 /* hnd/ev<state> */ ) {
          return ((loc).value);
        }, function(___wildcard_x691__14 /* hnd/marker<<local<603>,div>,int> */ , ___wildcard_x691__17 /* hnd/ev<state> */ , x /* int */ ) {
          return ((loc).value = x);
        }), function(_x /* int */ ) {
        return _x;
      }, countdown);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10004 = $std_os_env.get_args();
   
  var _x0 = (xs_10004 !== null) ? xs_10004.head : "";
  var m_10002 = $std_core_int.parse_int(_x0);
   
  var _x1 = (m_10002 === null) ? 5 : m_10002.value;
  var r = run(_x1);
  return $std_core_console.printsln($std_core_int.show(r));
}