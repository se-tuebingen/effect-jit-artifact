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
export function _Hnd_state(_cfc, _fun_get, _fun_set) /* forall<e,a> (int, hnd/clause0<int,state,e,a>, hnd/clause1<int,(),state,e,a>) -> state<e,a> */  {
  return { _cfc: _cfc, _fun_get: _fun_get, _fun_set: _fun_set };
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
 
 
// Automatically generated. Retrieves the `@fun-get` constructor field of the `:state` type.
export function state_fs__fun_get(state) /* forall<e,a> (state : state<e,a>) -> hnd/clause0<int,state,e,a> */  {
  return state._fun_get;
}
 
 
// Automatically generated. Retrieves the `@fun-set` constructor field of the `:state` type.
export function state_fs__fun_set(state) /* forall<e,a> (state : state<e,a>) -> hnd/clause1<int,(),state,e,a> */  {
  return state._fun_set;
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
  return hnd._fun_get;
}
 
 
// select `set` operation out of effect `:state`
export function _select_set(hnd) /* forall<e,a> (hnd : state<e,a>) -> hnd/clause1<int,(),state,e,a> */  {
  return hnd._fun_set;
}
 
 
// select `yield` operation out of effect `:yield`
export function _select_yield(hnd) /* forall<e,a> (hnd : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */  {
  return hnd._ctl_yield;
}
 
 
// Call the `fun get` operation of the effect `:state`
export function get() /* () -> state int */  {
   
  var ev_10043 = $std_core_hnd._evv_at(0);
  return (ev_10043.hnd._fun_get)(ev_10043.marker, ev_10043);
}
 
 
// Call the `fun set` operation of the effect `:state`
export function set(i) /* (i : int) -> state () */  {
   
  var ev_10045 = $std_core_hnd._evv_at(0);
  return ev_10045.hnd._fun_set(ev_10045.marker, ev_10045, i);
}
 
 
// monadic lift
export function _mlift_countdown_10039(wild__) /* (wild_ : ()) -> state int */  {
  return countdown();
}
 
 
// monadic lift
export function _mlift_countdown_10040(i) /* (i : int) -> state int */  {
  if ($std_core_types._int_eq(i,0)) {
    return i;
  }
  else {
     
    var i_0_10000 = $std_core_types._int_sub(i,1);
     
    var ev_10050 = $std_core_hnd._evv_at(0);
     
    var x_10048 = ev_10050.hnd._fun_set(ev_10050.marker, ev_10050, i_0_10000);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(_mlift_countdown_10039);
    }
    else {
      return _mlift_countdown_10039(x_10048);
    }
  }
}
 
export function countdown() /* () -> <div,state> int */  { tailcall: while(1)
{
   
  var ev_0_10056 = $std_core_hnd._evv_at(0);
   
  var x_1_10053 = (ev_0_10056.hnd._fun_get)(ev_0_10056.marker, ev_0_10056);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_countdown_10040);
  }
  else {
    if ($std_core_types._int_eq(x_1_10053,0)) {
      return x_1_10053;
    }
    else {
       
      var i_0_10000_0 = $std_core_types._int_sub(x_1_10053,1);
       
      var ev_1_10061 = $std_core_hnd._evv_at(0);
       
      var x_2_10058 = ev_1_10061.hnd._fun_set(ev_1_10061.marker, ev_1_10061, i_0_10000_0);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(_mlift_countdown_10039);
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
 
 
// Call the `ctl yield` operation of the effect `:yield`
export function $yield(i) /* (i : int) -> yield () */  {
   
  var ev_10064 = $std_core_hnd._evv_at(0);
  return ev_10064.hnd._ctl_yield(ev_10064.marker, ev_10064, i);
}
 
export function ignoreyield(body) /* forall<a,e> (body : () -> <yield|e> a) -> e a */  {
  return _handle_yield(_Hnd_yield(3, function(m /* hnd/marker<651,650> */ , ___wildcard_x681__16 /* hnd/ev<yield> */ , x /* int */ ) {
        return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<(),650>) -> 651 650 */ ) {
            return $std_core_hnd.protect(x, function(i /* int */ , resume /* (()) -> 651 650 */ ) {
                return resume($std_core_types.Unit);
              }, k);
          });
      }), function(_x /* 650 */ ) {
      return _x;
    }, body);
}
 
export function handled(n, d) /* (n : int, d : int) -> <div,state> int */  {
  if ($std_core_types._int_eq(d,0)) {
    return countdown();
  }
  else {
    return _handle_yield(_Hnd_yield(3, function(m /* hnd/marker<<div,state>,int> */ , ___wildcard_x681__16 /* hnd/ev<yield> */ , x /* int */ ) {
          return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<(),int>) -> <div,state> int */ ) {
              return $std_core_hnd.protect(x, function(i /* int */ , resume /* (()) -> <div,state> int */ ) {
                  return resume($std_core_types.Unit);
                }, k);
            });
        }), function(_x /* int */ ) {
        return _x;
      }, function() {
         
        var _x_x2_10038 = $std_core_types._int_sub(d,1);
        return $std_core_hnd._open_at2(0, handled, n, _x_x2_10038);
      });
  }
}
 
export function run(n, d) /* (n : int, d : int) -> div int */  {
  return function() {
     
    var loc = { value: n };
     
    var res = _handle_state(_Hnd_state(1, function(___wildcard_x737__14 /* hnd/marker<<local<955>,div>,int> */ , ___wildcard_x737__17 /* hnd/ev<state> */ ) {
          return ((loc).value);
        }, function(___wildcard_x691__14 /* hnd/marker<<local<955>,div>,int> */ , ___wildcard_x691__17 /* hnd/ev<state> */ , x /* int */ ) {
          return ((loc).value = x);
        }), function(_x /* int */ ) {
        return _x;
      }, function() {
        return handled(n, d);
      });
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10005 = $std_os_env.get_args();
   
  var _x0 = (xs_10005 !== null) ? xs_10005.head : "";
  var m_10003 = $std_core_int.parse_int(_x0);
   
  var xs_1_10011 = $std_os_env.get_args();
   
  var _x2 = (xs_1_10011 !== null) ? xs_1_10011.tail : $std_core_types.Nil;
  var _x1 = (_x2 !== null) ? _x2.head : "";
  var m_0_10007 = $std_core_int.parse_int(_x1);
   
  var _x3 = (m_10003 === null) ? 5 : m_10003.value;
  var _x4 = (m_0_10007 === null) ? 10 : m_0_10007.value;
  var r = run(_x3, _x4);
  return $std_core_console.printsln($std_core_int.show(r));
}