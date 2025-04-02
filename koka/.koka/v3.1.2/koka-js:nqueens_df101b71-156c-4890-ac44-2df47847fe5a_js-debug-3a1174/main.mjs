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
 
 
// runtime tag for the effect `:search`
export var _tag_search;
var _tag_search = "search@main";
// type search
export function _Hnd_search(_cfc, _ctl_fail, _ctl_pick) /* forall<e,a> (int, forall<b> hnd/clause0<b,search,e,a>, hnd/clause1<int,int,search,e,a>) -> search<e,a> */  {
  return { _cfc: _cfc, _ctl_fail: _ctl_fail, _ctl_pick: _ctl_pick };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:search` type.
export function search_fs__cfc(search) /* forall<e,a> (search : search<e,a>) -> int */  {
  return search._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-fail` constructor field of the `:search` type.
export function search_fs__ctl_fail(search) /* forall<e,a,b> (search : search<e,a>) -> hnd/clause0<b,search,e,a> */  {
  return search._ctl_fail;
}
 
 
// Automatically generated. Retrieves the `@ctl-pick` constructor field of the `:search` type.
export function search_fs__ctl_pick(search) /* forall<e,a> (search : search<e,a>) -> hnd/clause1<int,int,search,e,a> */  {
  return search._ctl_pick;
}
 
 
// handler for the effect `:search`
export function _handle_search(hnd, ret, action) /* forall<a,e,b> (hnd : search<e,b>, ret : (res : a) -> e b, action : () -> <search|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_search, hnd, ret, action);
}
 
 
// select `fail` operation out of effect `:search`
export function _select_fail(hnd) /* forall<a,e,b> (hnd : search<e,b>) -> hnd/clause0<a,search,e,b> */  {
  return hnd._ctl_fail;
}
 
 
// select `pick` operation out of effect `:search`
export function _select_pick(hnd) /* forall<e,a> (hnd : search<e,a>) -> hnd/clause1<int,int,search,e,a> */  {
  return hnd._ctl_pick;
}
 
 
// Call the `ctl fail` operation of the effect `:search`
export function fail() /* forall<a> () -> search a */  {
   
  var ev_10041 = $std_core_hnd._evv_at(0);
  var _x0 = ev_10041.hnd._ctl_fail;
  return _x0(ev_10041.marker, ev_10041);
}
 
 
// Call the `ctl pick` operation of the effect `:search`
export function pick(size) /* (size : int) -> search int */  {
   
  var ev_10043 = $std_core_hnd._evv_at(0);
  return ev_10043.hnd._ctl_pick(ev_10043.marker, ev_10043, size);
}
 
export function safe(queen, diag, xs) /* (queen : int, diag : int, xs : solution) -> bool */  { tailcall: while(1)
{
  if (xs === null) {
    return true;
  }
  else {
    if ($std_core_types._int_ne(queen,(xs.head))) {
      var _x1 = $std_core_types._int_ne(queen,($std_core_types._int_add((xs.head),diag)));
      if (_x1) {
        var _x2 = $std_core_types._int_ne(queen,($std_core_types._int_sub((xs.head),diag)));
        if (_x2) {
          {
            // tail call
            var _x3 = $std_core_types._int_add(diag,1);
            diag = _x3;
            xs = xs.tail;
            continue tailcall;
          }
        }
        else {
          return false;
        }
      }
      else {
        return false;
      }
    }
    else {
      return false;
    }
  }
}}
 
 
// monadic lift
export function _mlift_place_10038(rest, next) /* (rest : solution, next : int) -> search list<int> */  {
  var _x4 = $std_core_hnd._open_none3(safe, next, 1, rest);
  if (_x4) {
    return $std_core_types.Cons(next, rest);
  }
  else {
     
    var ev_10046 = $std_core_hnd._evv_at(0);
    var _x5 = ev_10046.hnd._ctl_fail;
    return _x5(ev_10046.marker, ev_10046);
  }
}
 
 
// monadic lift
export function _mlift_place_10039(size, rest_0) /* (size : int, rest : solution) -> <div,search> list<int> */  {
   
  var ev_0_10050 = $std_core_hnd._evv_at(0);
   
  var x_10048 = ev_0_10050.hnd._ctl_pick(ev_0_10050.marker, ev_0_10050, size);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(next_1 /* int */ ) {
      return _mlift_place_10038(rest_0, next_1);
    });
  }
  else {
    return _mlift_place_10038(rest_0, x_10048);
  }
}
 
export function place(size_0, column) /* (size : int, column : int) -> <div,search> solution */  {
  if ($std_core_types._int_eq(column,0)) {
    return $std_core_types.Nil;
  }
  else {
     
    var x_1_10053 = place(size_0, $std_core_types._int_sub(column,1));
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(rest_1 /* solution */ ) {
        return _mlift_place_10039(size_0, rest_1);
      });
    }
    else {
       
      var ev_1_10059 = $std_core_hnd._evv_at(0);
       
      var x_2_10056 = ev_1_10059.hnd._ctl_pick(ev_1_10059.marker, ev_1_10059, size_0);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(next_4 /* int */ ) {
          return _mlift_place_10038(x_1_10053, next_4);
        });
      }
      else {
        var _x6 = $std_core_hnd._open_none3(safe, x_2_10056, 1, x_1_10053);
        if (_x6) {
          return $std_core_types.Cons(x_2_10056, x_1_10053);
        }
        else {
           
          var ev_2_10062 = $std_core_hnd._evv_at(0);
          var _x7 = ev_2_10062.hnd._ctl_fail;
          return _x7(ev_2_10062.marker, ev_2_10062);
        }
      }
    }
  }
}
 
 
// lifted local: run, loop
export function _lift_run_828(resume_0, size, i, a) /* (resume@0 : (int) -> div int, size : int, i : int, a : int) -> div int */  { tailcall: while(1)
{
  if ($std_core_types._int_eq(i,size)) {
     
    var y_10008 = resume_0(i);
    return $std_core_types._int_add(a,y_10008);
  }
  else {
     
    var i_0_10009 = $std_core_types._int_add(i,1);
     
    var y_1_10014 = resume_0(i);
     
    var a_0_10010 = $std_core_types._int_add(a,y_1_10014);
    {
      // tail call
      i = i_0_10009;
      a = a_0_10010;
      continue tailcall;
    }
  }
}}
 
export function run(n) /* (n : int) -> div int */  {
  return _handle_search(_Hnd_search(3, function(m /* hnd/marker<div,int> */ , ___wildcard_x730__16 /* hnd/ev<search> */ ) {
        return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<648,int>) -> div int */ ) {
            return $std_core_hnd.protect($std_core_types.Unit, function(___wildcard_x730__55 /* () */ , r /* (648) -> div int */ ) {
                return 0;
              }, k);
          });
      }, function(m_0 /* hnd/marker<div,int> */ , ___wildcard_x681__16 /* hnd/ev<search> */ , x /* int */ ) {
        return $std_core_hnd.yield_to(m_0, function(k_0 /* (hnd/resume-result<int,int>) -> div int */ ) {
            return $std_core_hnd.protect(x, function(size /* int */ , resume_0 /* (int) -> div int */ ) {
                return _lift_run_828(resume_0, size, 1, 0);
              }, k_0);
          });
      }), function(__w_l30_c12 /* solution */ ) {
      return 1;
    }, function() {
      return place(n, n);
    });
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10017 = $std_os_env.get_args();
   
  var _x8 = (xs_10017 !== null) ? xs_10017.head : "";
  var m_10015 = $std_core_int.parse_int(_x8);
   
  var r_0 = _handle_search(_Hnd_search(3, function(m /* hnd/marker<div,int> */ , ___wildcard_x730__16 /* hnd/ev<search> */ ) {
        return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<648,int>) -> div int */ ) {
            return $std_core_hnd.protect($std_core_types.Unit, function(___wildcard_x730__55 /* () */ , r /* (648) -> div int */ ) {
                return 0;
              }, k);
          });
      }, function(m_0 /* hnd/marker<div,int> */ , ___wildcard_x681__16 /* hnd/ev<search> */ , x /* int */ ) {
        return $std_core_hnd.yield_to(m_0, function(k_0 /* (hnd/resume-result<int,int>) -> div int */ ) {
            return $std_core_hnd.protect(x, function(size /* int */ , resume_0 /* (int) -> div int */ ) {
                return _lift_run_828(resume_0, size, 1, 0);
              }, k_0);
          });
      }), function(__w_l30_c12 /* solution */ ) {
      return 1;
    }, function() {
      var _x9 = (m_10015 === null) ? 5 : m_10015.value;
      var _x10 = (m_10015 === null) ? 5 : m_10015.value;
      return place(_x9, _x10);
    });
  return $std_core_console.printsln($std_core_int.show(r_0));
}