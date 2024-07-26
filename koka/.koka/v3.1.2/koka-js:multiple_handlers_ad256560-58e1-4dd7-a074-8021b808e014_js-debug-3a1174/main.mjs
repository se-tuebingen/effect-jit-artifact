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
   
  var ev_10061 = $std_core_hnd._evv_at(0);
  return ev_10061.hnd._fun_emit(ev_10061.marker, ev_10061, e);
}
 
 
// monadic lift
export function _mlift_counting_10056(res, _y_x10020) /* forall<e,h> (res : local-var<h,int>, int) -> <local<h>|e> () */  {
  return ((res).value = ($std_core_types._int_mod(($std_core_types._int_add(_y_x10020,1)),1009)));
}
 
export function counting(action) /* forall<a,e> (action : () -> <emit|e> a) -> e int */  {
  return function() {
     
    var loc = { value: 0 };
     
    var res = _handle_emit(_Hnd_emit(1, $std_core_hnd.clause_tail1(function(i /* int */ ) {
           
          var x_10066 = ((loc).value);
           
          function next_10067(_y_x10020) /* (int) -> <local<472>|223> () */  {
            return ((loc).value = ($std_core_types._int_mod(($std_core_types._int_add(_y_x10020,1)),1009)));
          }
          if ($std_core_hnd._yielding()) {
            return $std_core_hnd.yield_extend(next_10067);
          }
          else {
            return next_10067(x_10066);
          }
        })), function(__w_l28_c12 /* 270 */ ) {
        return ((loc).value);
      }, action);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
 
// monadic lift
export function _mlift_lift_generator_1196_10057(i, n, wild__) /* (i : int, n : int, wild_ : ()) -> emit () */  {
   
  var i_0_10002 = $std_core_types._int_add(i,1);
  return _lift_generator_1196(n, i_0_10002);
}
 
 
// lifted local: generator, go
export function _lift_generator_1196(n_0, i_0) /* (n : int, i : int) -> <emit,div> () */  { tailcall: while(1)
{
  if ($std_core_types._int_gt(i_0,n_0)) {
    return $std_core_types.Unit;
  }
  else {
     
    var ev_10074 = $std_core_hnd._evv_at(0);
     
    var x_10071 = ev_10074.hnd._fun_emit(ev_10074.marker, ev_10074, i_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
        return _mlift_lift_generator_1196_10057(i_0, n_0, wild___0);
      });
    }
    else {
       
      var i_0_10002_0 = $std_core_types._int_add(i_0,1);
      {
        // tail call
        i_0 = i_0_10002_0;
        continue tailcall;
      }
    }
  }
}}
 
export function generator(n) /* (n : int) -> <div,emit> () */  {
  return _lift_generator_1196(n, 0);
}
 
 
// monadic lift
export function _mlift_sq__summing_10058(i, res, _y_x10031) /* forall<e,h> (i : int, res : local-var<h,int>, int) -> <local<h>|e> () */  {
   
  var y_10053 = $std_core_types._int_mul(i,i);
  return ((res).value = ($std_core_types._int_mod(($std_core_types._int_add(_y_x10031,y_10053)),1009)));
}
 
export function sq__summing(action) /* forall<a,e> (action : () -> <emit|e> a) -> e int */  {
  return function() {
     
    var loc = { value: 0 };
     
    var res = _handle_emit(_Hnd_emit(1, $std_core_hnd.clause_tail1(function(i /* int */ ) {
           
          var x_10079 = ((loc).value);
           
          function next_10080(_y_x10031) /* (int) -> <local<779>|522> () */  {
             
            var y_10053 = $std_core_types._int_mul(i,i);
            return ((loc).value = ($std_core_types._int_mod(($std_core_types._int_add(_y_x10031,y_10053)),1009)));
          }
          if ($std_core_hnd._yielding()) {
            return $std_core_hnd.yield_extend(next_10080);
          }
          else {
            return next_10080(x_10079);
          }
        })), function(__w_l37_c12 /* 569 */ ) {
        return ((loc).value);
      }, action);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
 
// monadic lift
export function _mlift_summing_10059(i, res, _y_x10038) /* forall<e,h> (i : int, res : local-var<h,int>, int) -> <local<h>|e> () */  {
  return ((res).value = ($std_core_types._int_mod(($std_core_types._int_add(_y_x10038,i)),1009)));
}
 
export function summing(action) /* forall<a,e> (action : () -> <emit|e> a) -> e int */  {
  return function() {
     
    var loc = { value: 0 };
     
    var res = _handle_emit(_Hnd_emit(1, $std_core_hnd.clause_tail1(function(i /* int */ ) {
           
          var x_10087 = ((loc).value);
           
          function next_10088(_y_x10038) /* (int) -> <local<1037>|788> () */  {
            return ((loc).value = ($std_core_types._int_mod(($std_core_types._int_add(_y_x10038,i)),1009)));
          }
          if ($std_core_hnd._yielding()) {
            return $std_core_hnd.yield_extend(next_10088);
          }
          else {
            return next_10088(x_10087);
          }
        })), function(__w_l19_c12 /* 835 */ ) {
        return ((loc).value);
      }, action);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
export function run(n) /* (n : int) -> div int */  {
   
  var sqs = sq__summing(function() {
    return _lift_generator_1196(n, 0);
  });
   
  var s = summing(function() {
    return _lift_generator_1196(n, 0);
  });
   
  var c = counting(function() {
    return _lift_generator_1196(n, 0);
  });
   
  var x_0_10010 = $std_core_types._int_mul(sqs,1009);
   
  var y_0_10011 = $std_core_types._int_mul(s,103);
   
  var x_10008 = $std_core_types._int_add(x_0_10010,y_0_10011);
  return $std_core_types._int_add(x_10008,c);
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10014 = $std_os_env.get_args();
   
  var _x0 = (xs_10014 !== null) ? xs_10014.head : "";
  var m_10012 = $std_core_int.parse_int(_x0);
   
  var _x1 = (m_10012 === null) ? 5 : m_10012.value;
  var r = run(_x1);
  return $std_core_console.printsln($std_core_int.show(r));
}