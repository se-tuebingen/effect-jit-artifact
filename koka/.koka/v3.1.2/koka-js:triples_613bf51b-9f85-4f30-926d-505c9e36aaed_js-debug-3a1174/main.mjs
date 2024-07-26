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
 
 
// runtime tag for the effect `:fail`
export var _tag_fail;
var _tag_fail = "fail@main";
 
 
// runtime tag for the effect `:flip`
export var _tag_flip;
var _tag_flip = "flip@main";
// type fail
export function _Hnd_fail(_cfc, _ctl_fail) /* forall<e,a> (int, forall<b> hnd/clause0<b,fail,e,a>) -> fail<e,a> */  {
  return { _cfc: _cfc, _ctl_fail: _ctl_fail };
}
// type flip
export function _Hnd_flip(_cfc, _ctl_flip) /* forall<e,a> (int, hnd/clause0<bool,flip,e,a>) -> flip<e,a> */  {
  return { _cfc: _cfc, _ctl_flip: _ctl_flip };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:fail` type.
export function fail_fs__cfc(fail_0) /* forall<e,a> (fail : fail<e,a>) -> int */  {
  return fail_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-fail` constructor field of the `:fail` type.
export function fail_fs__ctl_fail(fail_0) /* forall<e,a,b> (fail : fail<e,a>) -> hnd/clause0<b,fail,e,a> */  {
  return fail_0._ctl_fail;
}
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:flip` type.
export function flip_fs__cfc(flip_0) /* forall<e,a> (flip : flip<e,a>) -> int */  {
  return flip_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-flip` constructor field of the `:flip` type.
export function flip_fs__ctl_flip(flip_0) /* forall<e,a> (flip : flip<e,a>) -> hnd/clause0<bool,flip,e,a> */  {
  return flip_0._ctl_flip;
}
 
 
// handler for the effect `:fail`
export function _handle_fail(hnd, ret, action) /* forall<a,e,b> (hnd : fail<e,b>, ret : (res : a) -> e b, action : () -> <fail|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_fail, hnd, ret, action);
}
 
 
// handler for the effect `:flip`
export function _handle_flip(hnd, ret, action) /* forall<a,e,b> (hnd : flip<e,b>, ret : (res : a) -> e b, action : () -> <flip|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_flip, hnd, ret, action);
}
 
 
// select `fail` operation out of effect `:fail`
export function _select_fail(hnd) /* forall<a,e,b> (hnd : fail<e,b>) -> hnd/clause0<a,fail,e,b> */  {
  return hnd._ctl_fail;
}
 
 
// select `flip` operation out of effect `:flip`
export function _select_flip(hnd) /* forall<e,a> (hnd : flip<e,a>) -> hnd/clause0<bool,flip,e,a> */  {
  return hnd._ctl_flip;
}
 
export function hash(_pat_x25__10) /* ((int, int, int)) -> int */  {
   
  var x_0_10002 = $std_core_types._int_mul(53,(_pat_x25__10.fst));
   
  var y_0_10003 = $std_core_types._int_mul(2809,(_pat_x25__10.snd));
   
  var x_10000 = $std_core_types._int_add(x_0_10002,y_0_10003);
   
  var y_10001 = $std_core_types._int_mul(148877,(_pat_x25__10.thd));
  return $std_core_types._int_mod(($std_core_types._int_add(x_10000,y_10001)),1000000007);
}
 
 
// Call the `ctl fail` operation of the effect `:fail`
export function fail() /* forall<a> () -> fail a */  {
   
  var ev_10057 = $std_core_hnd._evv_at(0);
  var _x0 = ev_10057.hnd._ctl_fail;
  return _x0(ev_10057.marker, ev_10057);
}
 
 
// Call the `ctl flip` operation of the effect `:flip`
export function flip() /* () -> flip bool */  {
   
  var ev_10059 = $std_core_hnd._evv_at(0);
  return (ev_10059.hnd._ctl_flip)(ev_10059.marker, ev_10059);
}
 
 
// monadic lift
export function _mlift_choice_10050(n, _y_x10023) /* (n : int, bool) -> <flip,fail,div> int */  {
  if (_y_x10023) {
    return n;
  }
  else {
    return choice($std_core_types._int_sub(n,1));
  }
}
 
export function choice(n_0) /* (n : int) -> <div,fail,flip> int */  { tailcall: while(1)
{
  if ($std_core_types._int_lt(n_0,1)) {
    return $std_core_hnd._open_at0(0, function() {
         
        var ev_10061 = $std_core_hnd._evv_at(0);
        var _x1 = ev_10061.hnd._ctl_fail;
        return _x1(ev_10061.marker, ev_10061);
      });
  }
  else {
     
    var x_10063 = $std_core_hnd._open_at0(1, function() {
         
        var ev_0_10066 = $std_core_hnd._evv_at(0);
        return (ev_0_10066.hnd._ctl_flip)(ev_0_10066.marker, ev_0_10066);
      });
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10023_0 /* bool */ ) {
        return _mlift_choice_10050(n_0, _y_x10023_0);
      });
    }
    else {
      if (x_10063) {
        return n_0;
      }
      else {
        {
          // tail call
          var _x2 = $std_core_types._int_sub(n_0,1);
          n_0 = _x2;
          continue tailcall;
        }
      }
    }
  }
}}
 
 
// monadic lift
export function _mlift_triple_10051(i, j, s, k) /* (i : int, j : int, s : int, k : int) -> <div,fail,flip> (int, int, int) */  {
   
  var x_1_10043 = $std_core_types._int_add(i,j);
  var _x3 = $std_core_types._int_eq(($std_core_types._int_add(x_1_10043,k)),s);
  if (_x3) {
    return $std_core_types.Tuple3(i, j, k);
  }
  else {
    return $std_core_hnd._open_at0(0, function() {
         
        var ev_10068 = $std_core_hnd._evv_at(0);
        var _x4 = ev_10068.hnd._ctl_fail;
        return _x4(ev_10068.marker, ev_10068);
      });
  }
}
 
 
// monadic lift
export function _mlift_triple_10052(i, s, j) /* (i : int, s : int, j : int) -> <div,fail,flip> (int, int, int) */  {
   
  var x_10070 = choice($std_core_types._int_sub(j,1));
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(k /* int */ ) {
      return _mlift_triple_10051(i, j, s, k);
    });
  }
  else {
    return _mlift_triple_10051(i, j, s, x_10070);
  }
}
 
 
// monadic lift
export function _mlift_triple_10053(s, i) /* (s : int, i : int) -> <div,fail,flip> (int, int, int) */  {
   
  var x_10072 = choice($std_core_types._int_sub(i,1));
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(j /* int */ ) {
      return _mlift_triple_10052(i, s, j);
    });
  }
  else {
    return _mlift_triple_10052(i, s, x_10072);
  }
}
 
export function triple(n, s) /* (n : int, s : int) -> <div,fail,flip> (int, int, int) */  {
   
  var x_10074 = choice(n);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(i /* int */ ) {
      return _mlift_triple_10053(s, i);
    });
  }
  else {
     
    var x_0_10077 = choice($std_core_types._int_sub(x_10074,1));
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(j /* int */ ) {
        return _mlift_triple_10052(x_10074, s, j);
      });
    }
    else {
       
      var x_1_10080 = choice($std_core_types._int_sub(x_0_10077,1));
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(k /* int */ ) {
          return _mlift_triple_10051(x_10074, x_0_10077, s, k);
        });
      }
      else {
         
        var x_1_10043 = $std_core_types._int_add(x_10074,x_0_10077);
        var _x5 = $std_core_types._int_eq(($std_core_types._int_add(x_1_10043,x_1_10080)),s);
        if (_x5) {
          return $std_core_types.Tuple3(x_10074, x_0_10077, x_1_10080);
        }
        else {
          return $std_core_hnd._open_at0(0, function() {
               
              var ev_10083 = $std_core_hnd._evv_at(0);
              var _x6 = ev_10083.hnd._ctl_fail;
              return _x6(ev_10083.marker, ev_10083);
            });
        }
      }
    }
  }
}
 
 
// monadic lift
export function _mlift_run_10054(_y_x10033) /* ((int, int, int)) -> <div,fail,flip> int */  {
  return $std_core_hnd._open_none1(function(_pat_x25__10 /* (int, int, int) */ ) {
       
      var x_1_10008 = $std_core_types._int_mul(53,(_pat_x25__10.fst));
       
      var y_1_10009 = $std_core_types._int_mul(2809,(_pat_x25__10.snd));
       
      var x_0_10006 = $std_core_types._int_add(x_1_10008,y_1_10009);
       
      var y_0_10007 = $std_core_types._int_mul(148877,(_pat_x25__10.thd));
      return $std_core_types._int_mod(($std_core_types._int_add(x_0_10006,y_0_10007)),1000000007);
    }, _y_x10033);
}
 
export function run(n, s) /* (n : int, s : int) -> div int */  {
  return _handle_flip(_Hnd_flip(3, function(m /* hnd/marker<div,int> */ , ___wildcard_x730__16 /* hnd/ev<flip> */ ) {
        return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<bool,int>) -> div int */ ) {
            return $std_core_hnd.protect($std_core_types.Unit, function(___wildcard_x730__55 /* () */ , r /* (bool) -> div int */ ) {
                 
                var x_10004 = r(true);
                 
                var y_10005 = r(false);
                return $std_core_types._int_mod(($std_core_types._int_add(x_10004,y_10005)),1000000007);
              }, k);
          });
      }), function(_x /* int */ ) {
      return _x;
    }, function() {
      return _handle_fail(_Hnd_fail(3, function(m_0 /* hnd/marker<<div,flip>,int> */ , ___wildcard_x730__16_0 /* hnd/ev<fail> */ ) {
            return $std_core_hnd.yield_to(m_0, function(k_0 /* (hnd/resume-result<726,int>) -> <div,flip> int */ ) {
                return $std_core_hnd.protect($std_core_types.Unit, function(___wildcard_x730__55_0 /* () */ , r_0 /* (726) -> <div,flip> int */ ) {
                    return 0;
                  }, k_0);
              });
          }), function(_x_0 /* int */ ) {
          return _x_0;
        }, function() {
           
          var x_10087 = triple(n, s);
          if ($std_core_hnd._yielding()) {
            return $std_core_hnd.yield_extend(_mlift_run_10054);
          }
          else {
            return _mlift_run_10054(x_10087);
          }
        });
    });
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10012 = $std_os_env.get_args();
   
  var _x7 = (xs_10012 !== null) ? xs_10012.head : "";
  var m_10010 = $std_core_int.parse_int(_x7);
   
  var _x8 = (m_10010 === null) ? 10 : m_10010.value;
  var _x9 = (m_10010 === null) ? 10 : m_10010.value;
  var r = run(_x8, _x9);
  return $std_core_console.printsln($std_core_int.show(r));
}