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
 
 
// runtime tag for the effect `:abort`
export var _tag_abort;
var _tag_abort = "abort@main";
// type abort
export function _Hnd_abort(_cfc, _ctl_done) /* forall<e,a> (int, forall<b> hnd/clause1<int,b,abort,e,a>) -> abort<e,a> */  {
  return { _cfc: _cfc, _ctl_done: _ctl_done };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:abort` type.
export function abort_fs__cfc(abort) /* forall<e,a> (abort : abort<e,a>) -> int */  {
  return abort._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-done` constructor field of the `:abort` type.
export function abort_fs__ctl_done(abort) /* forall<e,a,b> (abort : abort<e,a>) -> hnd/clause1<int,b,abort,e,a> */  {
  return abort._ctl_done;
}
 
 
// handler for the effect `:abort`
export function _handle_abort(hnd, ret, action) /* forall<a,e,b> (hnd : abort<e,b>, ret : (res : a) -> e b, action : () -> <abort|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_abort, hnd, ret, action);
}
 
 
// select `done` operation out of effect `:abort`
export function _select_done(hnd) /* forall<a,e,b> (hnd : abort<e,b>) -> hnd/clause1<int,a,abort,e,b> */  {
  return hnd._ctl_done;
}
 
 
// Call the `ctl done` operation of the effect `:abort`
export function done(i) /* forall<a> (i : int) -> abort a */  {
   
  var ev_10034 = $std_core_hnd._evv_at(0);
  var _x0 = ev_10034.hnd._ctl_done;
  return _x0(ev_10034.marker, ev_10034, i);
}
 
export function _trmc_enumerate(i, _acc) /* (i : int, ctx<list<int>>) -> div list<int> */  { tailcall: while(1)
{
  if ($std_core_types._int_lt(i,0)) {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
  else {
     
    var _trmc_x10021 = undefined;
     
    var _trmc_x10022 = $std_core_types.Cons(i, _trmc_x10021);
    {
      // tail call
      var _x1 = $std_core_types._int_sub(i,1);
      var _x2 = $std_core_types._cctx_extend(_acc,_trmc_x10022,({obj: _trmc_x10022, field_name: "tail"}));
      i = _x1;
      _acc = _x2;
      continue tailcall;
    }
  }
}}
 
export function enumerate(i_0) /* (i : int) -> div list<int> */  {
  return _trmc_enumerate(i_0, $std_core_types._cctx_empty());
}
 
 
// monadic lift
export function _mlift_product_10032(y, _y_x10026) /* (y : int, int) -> abort int */  {
  return $std_core_types._int_mul(y,_y_x10026);
}
 
export function product(xs) /* (xs : list<int>) -> abort int */  {
  if (xs === null) {
    return 0;
  }
  else {
    if ($std_core_types._int_eq((xs.head),0)) {
       
      var ev_10037 = $std_core_hnd._evv_at(0);
      var _x3 = ev_10037.hnd._ctl_done;
      return _x3(ev_10037.marker, ev_10037, 0);
    }
    else {
       
      var x_0_10040 = product(xs.tail);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_y_x10026_0 /* int */ ) {
          return _mlift_product_10032(xs.head, _y_x10026_0);
        });
      }
      else {
        return $std_core_types._int_mul((xs.head),x_0_10040);
      }
    }
  }
}
 
export function run_product(xs) /* (xs : list<int>) -> int */  {
  return _handle_abort(_Hnd_abort(3, function(m /* hnd/marker<total,int> */ , ___wildcard_x681__16 /* hnd/ev<abort> */ , x /* int */ ) {
        return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<422,int>) -> int */ ) {
            return $std_core_hnd.protect(x, function(r /* int */ , resume /* (422) -> int */ ) {
                return r;
              }, k);
          });
      }), function(_x /* int */ ) {
      return _x;
    }, function() {
      return product(xs);
    });
}
 
 
// lifted local: run, loop
export function _lift_run_586(xs, i, a) /* (xs : list<int>, i : int, a : int) -> div int */  { tailcall: while(1)
{
  if ($std_core_types._int_eq(i,0)) {
    return a;
  }
  else {
     
    var i_0_10003 = $std_core_types._int_sub(i,1);
     
    var y_0_10008 = _handle_abort(_Hnd_abort(3, function(m /* hnd/marker<total,int> */ , ___wildcard_x681__16 /* hnd/ev<abort> */ , x /* int */ ) {
          return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<422,int>) -> int */ ) {
              return $std_core_hnd.protect(x, function(r /* int */ , resume /* (422) -> int */ ) {
                  return r;
                }, k);
            });
        }), function(_x /* int */ ) {
        return _x;
      }, function() {
        return product(xs);
      });
     
    var a_0_10004 = $std_core_types._int_add(a,y_0_10008);
    {
      // tail call
      i = i_0_10003;
      a = a_0_10004;
      continue tailcall;
    }
  }
}}
 
export function run(n) /* (n : int) -> div int */  {
   
  var xs = enumerate(1000);
  return _lift_run_586(xs, n, 0);
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10014 = $std_os_env.get_args();
   
  var _x4 = (xs_10014 !== null) ? xs_10014.head : "";
  var m_10012 = $std_core_int.parse_int(_x4);
   
  var xs_0 = enumerate(1000);
   
  var _x5 = (m_10012 === null) ? 5 : m_10012.value;
  var r = _lift_run_586(xs_0, _x5, 0);
  return $std_core_console.printsln($std_core_int.show(r));
}