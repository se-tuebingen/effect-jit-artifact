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
 
 
// runtime tag for the effect `:operator`
export var _tag_operator;
var _tag_operator = "operator@main";
// type operator
export function _Hnd_operator(_cfc, _ctl_operator) /* forall<e,a> (int, hnd/clause1<int,(),operator,e,a>) -> operator<e,a> */  {
  return { _cfc: _cfc, _ctl_operator: _ctl_operator };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:operator` type.
export function operator_fs__cfc(operator_0) /* forall<e,a> (operator : operator<e,a>) -> int */  {
  return operator_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-operator` constructor field of the `:operator` type.
export function operator_fs__ctl_operator(operator_0) /* forall<e,a> (operator : operator<e,a>) -> hnd/clause1<int,(),operator,e,a> */  {
  return operator_0._ctl_operator;
}
 
 
// handler for the effect `:operator`
export function _handle_operator(hnd, ret, action) /* forall<a,e,b> (hnd : operator<e,b>, ret : (res : a) -> e b, action : () -> <operator|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_operator, hnd, ret, action);
}
 
 
// select `operator` operation out of effect `:operator`
export function _select_operator(hnd) /* forall<e,a> (hnd : operator<e,a>) -> hnd/clause1<int,(),operator,e,a> */  {
  return hnd._ctl_operator;
}
 
 
// Call the `ctl operator` operation of the effect `:operator`
export function operator(x) /* (x : int) -> operator () */  {
   
  var ev_10028 = $std_core_hnd._evv_at(0);
  return ev_10028.hnd._ctl_operator(ev_10028.marker, ev_10028, x);
}
 
 
// monadic lift
export function _mlift_loop_10026(i, s, wild__) /* (i : int, s : int, wild_ : ()) -> operator int */  {
  return loop($std_core_types._int_sub(i,1), s);
}
 
export function loop(i_0, s_0) /* (i : int, s : int) -> <div,operator> int */  { tailcall: while(1)
{
  if ($std_core_types._int_eq(i_0,0)) {
    return s_0;
  }
  else {
     
    var ev_10034 = $std_core_hnd._evv_at(0);
     
    var x_10031 = ev_10034.hnd._ctl_operator(ev_10034.marker, ev_10034, i_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
        return _mlift_loop_10026(i_0, s_0, wild___0);
      });
    }
    else {
      {
        // tail call
        var _x0 = $std_core_types._int_sub(i_0,1);
        i_0 = _x0;
        continue tailcall;
      }
    }
  }
}}
 
export function run(n, s) /* (n : int, s : int) -> div int */  {
  return _handle_operator(_Hnd_operator(3, function(m /* hnd/marker<div,int> */ , ___wildcard_x681__16 /* hnd/ev<operator> */ , x /* int */ ) {
        return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<(),int>) -> div int */ ) {
            return $std_core_hnd.protect(x, function(x_0 /* int */ , resume /* (()) -> div int */ ) {
                 
                var y = resume($std_core_types.Unit);
                 
                var y_1_10004 = $std_core_types._int_mul(503,y);
                 
                var x_0_10001 = $std_core_types._int_sub(x_0,y_1_10004);
                return $std_core_types._int_mod(($std_core_types._int_abs(($std_core_types._int_add(x_0_10001,37)))),1009);
              }, k);
          });
      }), function(_x /* int */ ) {
      return _x;
    }, function() {
      return loop(n, s);
    });
}
 
 
// lifted local: repeat, step
export function _lift_repeat_514(n, l, s) /* (n : int, l : int, s : int) -> div int */  { tailcall: while(1)
{
  if ($std_core_types._int_eq(l,0)) {
    return s;
  }
  else {
     
    var l_0_10005 = $std_core_types._int_sub(l,1);
     
    var s_0_10006 = run(n, s);
    {
      // tail call
      l = l_0_10005;
      s = s_0_10006;
      continue tailcall;
    }
  }
}}
 
export function repeat(n) /* (n : int) -> div int */  {
  return _lift_repeat_514(n, 1000, 0);
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10011 = $std_os_env.get_args();
   
  var _x1 = (xs_10011 !== null) ? xs_10011.head : "";
  var m_10009 = $std_core_int.parse_int(_x1);
   
  var _x2 = (m_10009 === null) ? 5 : m_10009.value;
  var r = _lift_repeat_514(_x2, 1000, 0);
  return $std_core_console.printsln($std_core_int.show(r));
}