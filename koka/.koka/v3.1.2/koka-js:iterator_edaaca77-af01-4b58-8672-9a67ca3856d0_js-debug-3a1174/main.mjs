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
 
 
// runtime tag for the effect `:emit`
export var _tag_emit;
var _tag_emit = "emit@main";
// type emit
export function _Hnd_emit(_cfc, _fun_emit) /* forall<e,a> (int, hnd/clause1<int,(),emit,e,a>) -> emit<e,a> */  {
  return { _cfc: _cfc, _fun_emit: _fun_emit };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:emit` type.
export function emit_fs__cfc(emit_0) /* forall<e,a> (emit : emit<e,a>) -> int */  {
  return emit_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@fun-emit` constructor field of the `:emit` type.
export function emit_fs__fun_emit(emit_0) /* forall<e,a> (emit : emit<e,a>) -> hnd/clause1<int,(),emit,e,a> */  {
  return emit_0._fun_emit;
}
 
 
// handler for the effect `:emit`
export function _handle_emit(hnd, ret, action) /* forall<a,e,b> (hnd : emit<e,b>, ret : (res : a) -> e b, action : () -> <emit|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_emit, hnd, ret, action);
}
 
 
// select `emit` operation out of effect `:emit`
export function _select_emit(hnd) /* forall<e,a> (hnd : emit<e,a>) -> hnd/clause1<int,(),emit,e,a> */  {
  return hnd._fun_emit;
}
 
 
// Call the `fun emit` operation of the effect `:emit`
export function emit(e) /* (e : int) -> emit () */  {
   
  var ev_10022 = $std_core_hnd._evv_at(0);
  return ev_10022.hnd._fun_emit(ev_10022.marker, ev_10022, e);
}
 
 
// monadic lift
export function _mlift_range_10019(l, u, wild__) /* (l : int, u : int, wild_ : ()) -> emit () */  {
  return range($std_core_types._int_add(l,1), u);
}
 
export function range(l_0, u_0) /* (l : int, u : int) -> <div,emit> () */  { tailcall: while(1)
{
  if ($std_core_types._int_gt(l_0,u_0)) {
    return $std_core_types.Unit;
  }
  else {
     
    var ev_10028 = $std_core_hnd._evv_at(0);
     
    var x_10025 = ev_10028.hnd._fun_emit(ev_10028.marker, ev_10028, l_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
        return _mlift_range_10019(l_0, u_0, wild___0);
      });
    }
    else {
      {
        // tail call
        var _x0 = $std_core_types._int_add(l_0,1);
        l_0 = _x0;
        continue tailcall;
      }
    }
  }
}}
 
 
// monadic lift
export function _mlift_run_10020(s, wild___0) /* forall<h> (s : local-var<h,int>, wild_@0 : ()) -> <div,emit> int */  {
  return ((s).value);
}
 
export function run(n) /* (n : int) -> div int */  {
  return function() {
     
    var loc = { value: 0 };
     
    var res = _handle_emit(_Hnd_emit(1, function(___wildcard_x691__14 /* hnd/marker<<local<391>,div>,int> */ , ___wildcard_x691__17 /* hnd/ev<emit> */ , x /* int */ ) {
           
          var x_10002 = ((loc).value);
           
          ((loc).value = ($std_core_types._int_add(x_10002,x)));
          return $std_core_types.Unit;
        }), function(_x /* int */ ) {
        return _x;
      }, function() {
         
        var x_0_10034 = range(0, n);
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
            return ((loc).value);
          });
        }
        else {
          return ((loc).value);
        }
      });
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10006 = $std_os_env.get_args();
   
  var _x1 = (xs_10006 !== null) ? xs_10006.head : "";
  var m_10004 = $std_core_int.parse_int(_x1);
   
  var _x2 = (m_10004 === null) ? 5 : m_10004.value;
  var r = run(_x2);
  return $std_core_console.printsln($std_core_int.show(r));
}