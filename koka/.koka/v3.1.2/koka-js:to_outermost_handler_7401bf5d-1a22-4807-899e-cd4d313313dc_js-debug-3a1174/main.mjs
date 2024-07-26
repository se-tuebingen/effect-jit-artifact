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
 
 
// runtime tag for the effect `:yield`
export var _tag_yield;
var _tag_yield = "yield@main";
// type state
export function _Hnd_state(_cfc, _ctl_get, _ctl_set) /* forall<e,a> (int, hnd/clause0<int,state,e,a>, hnd/clause1<int,(),state,e,a>) -> state<e,a> */  {
  return { _cfc: _cfc, _ctl_get: _ctl_get, _ctl_set: _ctl_set };
}
// type yield
export function _Hnd_yield(_cfc, _ctl_yield) /* forall<e,a> (int, hnd/clause1<int,(),yield,e,a>) -> yield<e,a> */  {
  return { _cfc: _cfc, _ctl_yield: _ctl_yield };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:state` type.
export function state_fs__cfc(state) /* forall<e,a> (state : state<e,a>) -> int */  {
  return state._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-get` constructor field of the `:state` type.
export function state_fs__ctl_get(state) /* forall<e,a> (state : state<e,a>) -> hnd/clause0<int,state,e,a> */  {
  return state._ctl_get;
}
 
 
// Automatically generated. Retrieves the `@ctl-set` constructor field of the `:state` type.
export function state_fs__ctl_set(state) /* forall<e,a> (state : state<e,a>) -> hnd/clause1<int,(),state,e,a> */  {
  return state._ctl_set;
}
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:yield` type.
export function yield_fs__cfc(yield_0) /* forall<e,a> (yield : yield<e,a>) -> int */  {
  return yield_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-yield` constructor field of the `:yield` type.
export function yield_fs__ctl_yield(yield_0) /* forall<e,a> (yield : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */  {
  return yield_0._ctl_yield;
}
 
 
// handler for the effect `:state`
export function _handle_state(hnd, ret, action) /* forall<a,e,b> (hnd : state<e,b>, ret : (res : a) -> e b, action : () -> <state|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_state, hnd, ret, action);
}
 
 
// handler for the effect `:yield`
export function _handle_yield(hnd, ret, action) /* forall<a,e,b> (hnd : yield<e,b>, ret : (res : a) -> e b, action : () -> <yield|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_yield, hnd, ret, action);
}
 
 
// select `get` operation out of effect `:state`
export function _select_get(hnd) /* forall<e,a> (hnd : state<e,a>) -> hnd/clause0<int,state,e,a> */  {
  return hnd._ctl_get;
}
 
 
// select `set` operation out of effect `:state`
export function _select_set(hnd) /* forall<e,a> (hnd : state<e,a>) -> hnd/clause1<int,(),state,e,a> */  {
  return hnd._ctl_set;
}
 
 
// select `yield` operation out of effect `:yield`
export function _select_yield(hnd) /* forall<e,a> (hnd : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */  {
  return hnd._ctl_yield;
}
 
 
// Call the `ctl get` operation of the effect `:state`
export function get() /* () -> state int */  {
   
  var ev_10047 = $std_core_hnd._evv_at(0);
  return (ev_10047.hnd._ctl_get)(ev_10047.marker, ev_10047);
}
 
 
// Call the `ctl set` operation of the effect `:state`
export function set(i) /* (i : int) -> state () */  {
   
  var ev_10049 = $std_core_hnd._evv_at(0);
  return ev_10049.hnd._ctl_set(ev_10049.marker, ev_10049, i);
}
 
 
// monadic lift
export function _mlift_countdown_10042(wild__) /* (wild_ : ()) -> state int */  {
  return countdown();
}
 
 
// monadic lift
export function _mlift_countdown_10043(i) /* (i : int) -> state int */  {
  if ($std_core_types._int_eq(i,0)) {
    return i;
  }
  else {
     
    var i_0_10000 = $std_core_types._int_sub(i,1);
     
    var ev_10054 = $std_core_hnd._evv_at(0);
     
    var x_10052 = ev_10054.hnd._ctl_set(ev_10054.marker, ev_10054, i_0_10000);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(_mlift_countdown_10042);
    }
    else {
      return _mlift_countdown_10042(x_10052);
    }
  }
}
 
export function countdown() /* () -> <div,state> int */  { tailcall: while(1)
{
   
  var ev_0_10060 = $std_core_hnd._evv_at(0);
   
  var x_1_10057 = (ev_0_10060.hnd._ctl_get)(ev_0_10060.marker, ev_0_10060);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_countdown_10043);
  }
  else {
    if ($std_core_types._int_eq(x_1_10057,0)) {
      return x_1_10057;
    }
    else {
       
      var i_0_10000_0 = $std_core_types._int_sub(x_1_10057,1);
       
      var ev_1_10065 = $std_core_hnd._evv_at(0);
       
      var x_2_10062 = ev_1_10065.hnd._ctl_set(ev_1_10065.marker, ev_1_10065, i_0_10000_0);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(_mlift_countdown_10042);
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
 
export function shandler(n, body) /* forall<a,e> (n : int, body : () -> <state|e> a) -> e a */  {
  return function() {
     
    var loc = { value: n };
     
    var res = _handle_state(_Hnd_state(1, $std_core_hnd.clause_tail0(function() {
          return ((loc).value);
        }), $std_core_hnd.clause_tail1(function(i /* int */ ) {
          return ((loc).value = i);
        })), function(_x /* 774 */ ) {
        return _x;
      }, body);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
 
// monadic lift
export function _mlift_pad_10044(body, d, _y_x10030) /* forall<a,e> (body : () -> <div|e> a, d : int, hnd/ev-index) -> <state,div|e> a */  {
  return $std_core_hnd._mask_at(_y_x10030, false, function() {
      return pad($std_core_types._int_sub(d,1), body);
    });
}
 
export function pad(d_0, body_0) /* forall<a,e> (d : int, body : () -> <div|e> a) -> <div|e> a */  {
  if ($std_core_types._int_eq(d_0,0)) {
    return body_0();
  }
  else {
    return shandler(-377, function() {
         
        var x_10071 = $std_core_hnd._evv_index(_tag_state);
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(function(_y_x10030_0 /* hnd/ev-index */ ) {
            return _mlift_pad_10044(body_0, d_0, _y_x10030_0);
          });
        }
        else {
          return _mlift_pad_10044(body_0, d_0, x_10071);
        }
      });
  }
}
 
export function run(n, d) /* (n : int, d : int) -> div int */  {
  return shandler(n, function() {
      return pad(d, countdown);
    });
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10004 = $std_os_env.get_args();
   
  var _x0 = (xs_10004 !== null) ? xs_10004.head : "";
  var m_10002 = $std_core_int.parse_int(_x0);
   
  var xs_1_10010 = $std_os_env.get_args();
   
  var _x2 = (xs_1_10010 !== null) ? xs_1_10010.tail : $std_core_types.Nil;
  var _x1 = (_x2 !== null) ? _x2.head : "";
  var m_0_10006 = $std_core_int.parse_int(_x1);
   
  var _x3 = (m_10002 === null) ? 5 : m_10002.value;
  var r = shandler(_x3, function() {
      var _x4 = (m_0_10006 === null) ? 10 : m_0_10006.value;
      return pad(_x4, countdown);
    });
  return $std_core_console.printsln($std_core_int.show(r));
}
 
 
// Call the `ctl yield` operation of the effect `:yield`
export function $yield(i) /* (i : int) -> yield () */  {
   
  var ev_10073 = $std_core_hnd._evv_at(0);
  return ev_10073.hnd._ctl_yield(ev_10073.marker, ev_10073, i);
}