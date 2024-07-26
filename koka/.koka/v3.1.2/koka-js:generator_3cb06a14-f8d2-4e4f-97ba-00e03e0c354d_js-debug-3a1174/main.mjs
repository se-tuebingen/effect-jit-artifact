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
 
 
// runtime tag for the effect `:yield`
export var _tag_yield;
var _tag_yield = "yield@main";
// type generator
export const Empty = null; // generator
export function Thunk(value, next) /* (value : int, next : () -> div generator) -> generator */  {
  return { value: value, next: next };
}
// type tree
export const Leaf = null; // tree
export function Node(left, value, right) /* (left : tree, value : int, right : tree) -> tree */  {
  return { left: left, value: value, right: right };
}
// type yield
export function _Hnd_yield(_cfc, _ctl_yield) /* forall<e,a> (int, hnd/clause1<int,(),yield,e,a>) -> yield<e,a> */  {
  return { _cfc: _cfc, _ctl_yield: _ctl_yield };
}
 
// declarations
 
 
// Automatically generated. Tests for the `Empty` constructor of the `:generator` type.
export function is_empty(generator) /* (generator : generator) -> bool */  {
  return (generator === null);
}
 
 
// Automatically generated. Tests for the `Thunk` constructor of the `:generator` type.
export function is_thunk(generator) /* (generator : generator) -> bool */  {
  return (generator !== null);
}
 
 
// Automatically generated. Tests for the `Leaf` constructor of the `:tree` type.
export function is_leaf(tree) /* (tree : tree) -> bool */  {
  return (tree === null);
}
 
 
// Automatically generated. Tests for the `Node` constructor of the `:tree` type.
export function is_node(tree) /* (tree : tree) -> bool */  {
  return (tree !== null);
}
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:yield` type.
export function yield_fs__cfc(yield_0) /* forall<e,a> (yield : yield<e,a>) -> int */  {
  return yield_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-yield` constructor field of the `:yield` type.
export function yield_fs__ctl_yield(yield_0) /* forall<e,a> (yield : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */  {
  return yield_0._ctl_yield;
}
 
 
// handler for the effect `:yield`
export function _handle_yield(hnd, ret, action) /* forall<a,e,b> (hnd : yield<e,b>, ret : (res : a) -> e b, action : () -> <yield|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_yield, hnd, ret, action);
}
 
 
// select `yield` operation out of effect `:yield`
export function _select_yield(hnd) /* forall<e,a> (hnd : yield<e,a>) -> hnd/clause1<int,(),yield,e,a> */  {
  return hnd._ctl_yield;
}
 
 
// Call the `ctl yield` operation of the effect `:yield`
export function $yield(x) /* (x : int) -> yield () */  {
   
  var ev_10024 = $std_core_hnd._evv_at(0);
  return ev_10024.hnd._ctl_yield(ev_10024.marker, ev_10024, x);
}
 
export function generate(f) /* (f : () -> <div,yield> ()) -> div generator */  {
  return _handle_yield(_Hnd_yield(3, function(m /* hnd/marker<div,generator> */ , ___wildcard_x681__16 /* hnd/ev<yield> */ , x /* int */ ) {
        return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<(),generator>) -> div generator */ ) {
            return $std_core_hnd.protect(x, function(x_0 /* int */ , resume /* (()) -> div generator */ ) {
                return Thunk(x_0, function() {
                    return resume($std_core_types.Unit);
                  });
              }, k);
          });
      }), function(__w_l33_c12 /* () */ ) {
      return Empty;
    }, f);
}
 
 
// monadic lift
export function _mlift_iterate_10021(r, wild___0) /* (r : tree, wild_@0 : ()) -> yield () */  {
  return iterate(r);
}
 
 
// monadic lift
export function _mlift_iterate_10022(r_0, v, wild__) /* (r : tree, v : int, wild_ : ()) -> yield () */  {
   
  var ev_10030 = $std_core_hnd._evv_at(0);
   
  var x_10028 = ev_10030.hnd._ctl_yield(ev_10030.marker, ev_10030, v);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild___0_0 /* () */ ) {
      return _mlift_iterate_10021(r_0, wild___0_0);
    });
  }
  else {
    return _mlift_iterate_10021(r_0, x_10028);
  }
}
 
export function iterate(t) /* (t : tree) -> yield () */  { tailcall: while(1)
{
  if (t === null) {
    return $std_core_types.Unit;
  }
  else {
     
    var x_1_10033 = iterate(t.left);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___1 /* () */ ) {
        return _mlift_iterate_10022(t.right, t.value, wild___1);
      });
    }
    else {
       
      var ev_0_10039 = $std_core_hnd._evv_at(0);
       
      var x_2_10036 = ev_0_10039.hnd._ctl_yield(ev_0_10039.marker, ev_0_10039, t.value);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(wild___0_1 /* () */ ) {
          return _mlift_iterate_10021(t.right, wild___0_1);
        });
      }
      else {
        {
          // tail call
          t = t.right;
          continue tailcall;
        }
      }
    }
  }
}}
 
export function make(n) /* (n : int) -> div tree */  {
  if ($std_core_types._int_eq(n,0)) {
    return Leaf;
  }
  else {
     
    var t = make($std_core_types._int_sub(n,1));
    return Node(t, n, t);
  }
}
 
export function sum(a, g) /* (a : int, g : generator) -> div int */  { tailcall: while(1)
{
  if (g === null) {
    return a;
  }
  else {
    {
      // tail call
      var _x0 = $std_core_types._int_add((g.value),a);
      var _x1 = g.next();
      a = _x0;
      g = _x1;
      continue tailcall;
    }
  }
}}
 
export function run(n) /* (n : int) -> div int */  {
  return sum(0, _handle_yield(_Hnd_yield(3, function(m /* hnd/marker<div,generator> */ , ___wildcard_x681__16 /* hnd/ev<yield> */ , x /* int */ ) {
          return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<(),generator>) -> div generator */ ) {
              return $std_core_hnd.protect(x, function(x_0 /* int */ , resume /* (()) -> div generator */ ) {
                  return Thunk(x_0, function() {
                      return resume($std_core_types.Unit);
                    });
                }, k);
            });
        }), function(__w_l33_c12 /* () */ ) {
        return Empty;
      }, function() {
        return iterate($std_core_hnd._open_none1(make, n));
      }));
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10008 = $std_os_env.get_args();
   
  var _x2 = (xs_10008 !== null) ? xs_10008.head : "";
  var m_10006 = $std_core_int.parse_int(_x2);
   
  var _x3 = (m_10006 === null) ? 5 : m_10006.value;
  var r = run(_x3);
  return $std_core_console.printsln($std_core_int.show(r));
}