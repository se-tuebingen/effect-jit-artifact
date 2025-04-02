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
 
 
// runtime tag for the effect `:prime`
export var _tag_prime;
var _tag_prime = "prime@main";
// type prime
export function _Hnd_prime(_cfc, _fun_prime) /* forall<e,a> (int, hnd/clause1<int,bool,prime,e,a>) -> prime<e,a> */  {
  return { _cfc: _cfc, _fun_prime: _fun_prime };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:prime` type.
export function prime_fs__cfc(prime_0) /* forall<e,a> (prime : prime<e,a>) -> int */  {
  return prime_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@fun-prime` constructor field of the `:prime` type.
export function prime_fs__fun_prime(prime_0) /* forall<e,a> (prime : prime<e,a>) -> hnd/clause1<int,bool,prime,e,a> */  {
  return prime_0._fun_prime;
}
 
 
// handler for the effect `:prime`
export function _handle_prime(hnd, ret, action) /* forall<a,e,b> (hnd : prime<e,b>, ret : (res : a) -> e b, action : () -> <prime|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_prime, hnd, ret, action);
}
 
 
// select `prime` operation out of effect `:prime`
export function _select_prime(hnd) /* forall<e,a> (hnd : prime<e,a>) -> hnd/clause1<int,bool,prime,e,a> */  {
  return hnd._fun_prime;
}
 
 
// Call the `fun prime` operation of the effect `:prime`
export function prime(e) /* (e : int) -> prime bool */  {
   
  var ev_10033 = $std_core_hnd._evv_at(0);
  return ev_10033.hnd._fun_prime(ev_10033.marker, ev_10033, e);
}
 
 
// monadic lift
export function _mlift_primes_10031(a, i, n, _y_x10011) /* (a : int, i : int, n : int, bool) -> prime int */  {
  if (_y_x10011) {
    return _handle_prime(_Hnd_prime(1, $std_core_hnd.clause_tail1(function(e_0 /* int */ ) {
          var _x0 = $std_core_types._int_eq(($std_core_types._int_mod(e_0,i)),0);
          if (_x0) {
            return false;
          }
          else {
             
            var ev_10036 = $std_core_hnd._evv_at(0);
            return ev_10036.hnd._fun_prime(ev_10036.marker, ev_10036, e_0);
          }
        })), function(_x /* int */ ) {
        return _x;
      }, function() {
         
        var _x_x1_10028 = $std_core_types._int_add(i,1);
         
        var _x_x3_10030 = $std_core_types._int_add(a,i);
        return $std_core_hnd._open_at3(0, primes, _x_x1_10028, n, _x_x3_10030);
      });
  }
  else {
    return primes($std_core_types._int_add(i,1), n, a);
  }
}
 
export function primes(i_0, n_0, a_0) /* (i : int, n : int, a : int) -> <div,prime> int */  { tailcall: while(1)
{
  if ($std_core_types._int_ge(i_0,n_0)) {
    return a_0;
  }
  else {
     
    var ev_0_10042 = $std_core_hnd._evv_at(0);
     
    var x_0_10039 = ev_0_10042.hnd._fun_prime(ev_0_10042.marker, ev_0_10042, i_0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10011_0 /* bool */ ) {
        return _mlift_primes_10031(a_0, i_0, n_0, _y_x10011_0);
      });
    }
    else {
      if (x_0_10039) {
        return _handle_prime(_Hnd_prime(1, $std_core_hnd.clause_tail1(function(e_0_0 /* int */ ) {
              var _x1 = $std_core_types._int_eq(($std_core_types._int_mod(e_0_0,i_0)),0);
              if (_x1) {
                return false;
              }
              else {
                 
                var ev_1_10045 = $std_core_hnd._evv_at(0);
                return ev_1_10045.hnd._fun_prime(ev_1_10045.marker, ev_1_10045, e_0_0);
              }
            })), function(_x_0 /* int */ ) {
            return _x_0;
          }, function() {
             
            var _x_x1_10028_0 = $std_core_types._int_add(i_0,1);
             
            var _x_x3_10030_0 = $std_core_types._int_add(a_0,i_0);
            return $std_core_hnd._open_at3(0, primes, _x_x1_10028_0, n_0, _x_x3_10030_0);
          });
      }
      else {
        {
          // tail call
          var _x2 = $std_core_types._int_add(i_0,1);
          i_0 = _x2;
          continue tailcall;
        }
      }
    }
  }
}}
 
export function run(n) /* (n : int) -> div int */  {
  return _handle_prime(_Hnd_prime(1, function(___wildcard_x691__14 /* hnd/marker<div,int> */ , ___wildcard_x691__17 /* hnd/ev<prime> */ , x /* int */ ) {
        return true;
      }), function(_x /* int */ ) {
      return _x;
    }, function() {
      return primes(2, n, 0);
    });
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10004 = $std_os_env.get_args();
   
  var _x3 = (xs_10004 !== null) ? xs_10004.head : "";
  var m_10002 = $std_core_int.parse_int(_x3);
   
  var r = _handle_prime(_Hnd_prime(1, function(___wildcard_x691__14 /* hnd/marker<div,int> */ , ___wildcard_x691__17 /* hnd/ev<prime> */ , x /* int */ ) {
        return true;
      }), function(_x /* int */ ) {
      return _x;
    }, function() {
      var _x4 = (m_10002 === null) ? 10 : m_10002.value;
      return primes(2, _x4, 0);
    });
  return $std_core_console.printsln($std_core_int.show(r));
}