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
import * as $std_text_parse from './std_text_parse.mjs';
 
// externals
 
// type declarations
 
 
// runtime tag for the effect `:choose`
export var _tag_choose;
var _tag_choose = "choose@main";
// type choose
export function _Hnd_choose(_cfc, _ctl_choose) /* forall<e,a> (int, hnd/clause0<bool,choose,e,a>) -> choose<e,a> */  {
  return { _cfc: _cfc, _ctl_choose: _ctl_choose };
}
// type tree
export const Leaf = null; // tree
export function Node(left, value, right) /* (left : tree, value : int, right : tree) -> tree */  {
  return { left: left, value: value, right: right };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:choose` type.
export function choose_fs__cfc(choose_0) /* forall<e,a> (choose : choose<e,a>) -> int */  {
  return choose_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-choose` constructor field of the `:choose` type.
export function choose_fs__ctl_choose(choose_0) /* forall<e,a> (choose : choose<e,a>) -> hnd/clause0<bool,choose,e,a> */  {
  return choose_0._ctl_choose;
}
 
 
// Automatically generated. Tests for the `Leaf` constructor of the `:tree` type.
export function is_leaf(tree) /* (tree : tree) -> bool */  {
  return (tree === null);
}
 
 
// Automatically generated. Tests for the `Node` constructor of the `:tree` type.
export function is_node(tree) /* (tree : tree) -> bool */  {
  return (tree !== null);
}
 
 
// handler for the effect `:choose`
export function _handle_choose(hnd, ret, action) /* forall<a,e,b> (hnd : choose<e,b>, ret : (res : a) -> e b, action : () -> <choose|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_choose, hnd, ret, action);
}
 
 
// select `choose` operation out of effect `:choose`
export function _select_choose(hnd) /* forall<e,a> (hnd : choose<e,a>) -> hnd/clause0<bool,choose,e,a> */  {
  return hnd._ctl_choose;
}
 
export function operator(x, y) /* (x : int, y : int) -> int */  {
   
  var y_1_10003 = $std_core_types._int_mul(503,y);
   
  var x_0_10000 = $std_core_types._int_sub(x,y_1_10003);
  return $std_core_types._int_mod(($std_core_types._int_abs(($std_core_types._int_add(x_0_10000,37)))),1009);
}
 
 
// Call the `ctl choose` operation of the effect `:choose`
export function choose() /* () -> choose bool */  {
   
  var ev_10053 = $std_core_hnd._evv_at(0);
  return (ev_10053.hnd._ctl_choose)(ev_10053.marker, ev_10053);
}
 
export function make(n) /* (n : int) -> div tree */  {
  if ($std_core_types._int_eq(n,0)) {
    return Leaf;
  }
  else {
     
    var t = make($std_core_types._int_sub(n,1));
    return Node(t, n, t);
  }
}
 
 
// monadic lift
export function _mlift_lift_run_707_10048(v, _y_x10036) /* forall<h> (v : int, int) -> <local<h>,choose,div> int */  {
  return $std_core_hnd._open_none2(function(x_2 /* int */ , y_2 /* int */ ) {
       
      var y_4_10013 = $std_core_types._int_mul(503,y_2);
       
      var x_3_10010 = $std_core_types._int_sub(x_2,y_4_10013);
      return $std_core_types._int_mod(($std_core_types._int_abs(($std_core_types._int_add(x_3_10010,37)))),1009);
    }, v, _y_x10036);
}
 
 
// monadic lift
export function _mlift_lift_run_707_10049(_y_x10033, l, r, state, v_0, wild__) /* forall<h> (bool, l : tree, r : tree, state : local-var<h,int>, v : int, wild_ : ()) -> <local<h>,choose,div> int */  {
   
  var _x0 = (_y_x10033) ? l : r;
  var x_10055 = _lift_run_707(state, _x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10036_0 /* int */ ) {
      return _mlift_lift_run_707_10048(v_0, _y_x10036_0);
    });
  }
  else {
    return _mlift_lift_run_707_10048(v_0, x_10055);
  }
}
 
 
// monadic lift
export function _mlift_lift_run_707_10050(_y_x10033_0, l_0, r_0, state_0, v_1, _y_x10034) /* forall<h> (bool, l : tree, r : tree, state : local-var<h,int>, v : int, int) -> <local<h>,choose,div> int */  {
   
  var x_0_10057 = ((state_0).value = ($std_core_hnd._open_none2(function(x_1 /* int */ , y /* int */ ) {
       
      var y_1_10009 = $std_core_types._int_mul(503,y);
       
      var x_0_10006 = $std_core_types._int_sub(x_1,y_1_10009);
      return $std_core_types._int_mod(($std_core_types._int_abs(($std_core_types._int_add(x_0_10006,37)))),1009);
    }, _y_x10034, v_1)));
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
      return _mlift_lift_run_707_10049(_y_x10033_0, l_0, r_0, state_0, v_1, wild___0);
    });
  }
  else {
    return _mlift_lift_run_707_10049(_y_x10033_0, l_0, r_0, state_0, v_1, x_0_10057);
  }
}
 
 
// monadic lift
export function _mlift_lift_run_707_10051(l_1, r_1, state_1, v_2, _y_x10033_1) /* forall<h> (l : tree, r : tree, state : local-var<h,int>, v : int, bool) -> choose int */  {
   
  var x_3_10059 = ((state_1).value);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10034_0 /* int */ ) {
      return _mlift_lift_run_707_10050(_y_x10033_1, l_1, r_1, state_1, v_2, _y_x10034_0);
    });
  }
  else {
    return _mlift_lift_run_707_10050(_y_x10033_1, l_1, r_1, state_1, v_2, x_3_10059);
  }
}
 
 
// lifted local: run, explore
export function _lift_run_707(state_2, t) /* forall<h> (state : local-var<h,int>, t : tree) -> <local<h>,choose,div> int */  {
  if (t === null) {
    return ((state_2).value);
  }
  else {
     
    var ev_10064 = $std_core_hnd._evv_at(0);
     
    var x_4_10061 = (ev_10064.hnd._ctl_choose)(ev_10064.marker, ev_10064);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10033_2 /* bool */ ) {
        return _mlift_lift_run_707_10051(t.left, t.right, state_2, t.value, _y_x10033_2);
      });
    }
    else {
       
      var x_5_10066 = ((state_2).value);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_y_x10034_1 /* int */ ) {
          return _mlift_lift_run_707_10050(x_4_10061, t.left, t.right, state_2, t.value, _y_x10034_1);
        });
      }
      else {
         
        var x_6_10069 = ((state_2).value = ($std_core_hnd._open_none2(function(x_7 /* int */ , y_0 /* int */ ) {
             
            var y_1_10009_0 = $std_core_types._int_mul(503,y_0);
             
            var x_0_10006_0 = $std_core_types._int_sub(x_7,y_1_10009_0);
            return $std_core_types._int_mod(($std_core_types._int_abs(($std_core_types._int_add(x_0_10006_0,37)))),1009);
          }, x_5_10066, t.value)));
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(function(wild___1 /* () */ ) {
            return _mlift_lift_run_707_10049(x_4_10061, t.left, t.right, state_2, t.value, wild___1);
          });
        }
        else {
           
          var _x0 = (x_4_10061) ? t.left : t.right;
          var x_8_10072 = _lift_run_707(state_2, _x0);
          if ($std_core_hnd._yielding()) {
            return $std_core_hnd.yield_extend(function(_y_x10036_1 /* int */ ) {
              return _mlift_lift_run_707_10048(t.value, _y_x10036_1);
            });
          }
          else {
            return $std_core_hnd._open_none2(function(x_2_0 /* int */ , y_2_0 /* int */ ) {
                 
                var y_4_10013_0 = $std_core_types._int_mul(503,y_2_0);
                 
                var x_3_10010_0 = $std_core_types._int_sub(x_2_0,y_4_10013_0);
                return $std_core_types._int_mod(($std_core_types._int_abs(($std_core_types._int_add(x_3_10010_0,37)))),1009);
              }, t.value, x_8_10072);
          }
        }
      }
    }
  }
}
 
 
// lifted local: run, loop
export function _lift_run_708(explore, state, tree, i) /* forall<h> (explore : (t : tree) -> <choose,div,local<h>> int, state : local-var<h,int>, tree : tree, i : int) -> <div,local<h>> int */  { tailcall: while(1)
{
  if ($std_core_types._int_eq(i,0)) {
    return ((state).value);
  }
  else {
     
    var xs_10015 = _handle_choose(_Hnd_choose(3, function(m /* hnd/marker<<div,local<616>>,list<int>> */ , ___wildcard_x730__16 /* hnd/ev<choose> */ ) {
          return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<bool,list<int>>) -> <div,local<616>> list<int> */ ) {
              return $std_core_hnd.protect($std_core_types.Unit, function(___wildcard_x730__55 /* () */ , r /* (bool) -> <div,local<616>> list<int> */ ) {
                   
                  var xs_0_10017 = r(true);
                   
                  var ys_10018 = r(false);
                  return $std_core_list.append(xs_0_10017, ys_10018);
                }, k);
            });
        }), function(x_0 /* int */ ) {
        return $std_core_types.Cons(x_0, $std_core_types.Nil);
      }, function() {
        return explore(tree);
      });
     
    if (xs_10015 === null) {
      var _x1 = undefined;
      var _x0 = (_x1 !== undefined) ? _x1 : 0;
    }
    else {
      var _x0 = $std_core_list.foldl(xs_10015.tail, xs_10015.head, $std_core_int.max);
    }
    ((state).value = _x0);
     
    var i_0_10019 = $std_core_types._int_sub(i,1);
    {
      // tail call
      i = i_0_10019;
      continue tailcall;
    }
  }
}}
 
export function run(n) /* (n : int) -> div int */  {
  return function() {
     
    var tree = make(n);
     
    var loc = { value: 0 };
     
    var res = _lift_run_708(function(t /* tree */ ) {
        return _lift_run_707(loc, t);
      }, loc, tree, 10);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10025 = $std_os_env.get_args();
   
  var _x0 = (xs_10025 !== null) ? xs_10025.head : "";
  var m_10023 = $std_core_int.parse_int(_x0);
   
  var r = function() {
     
    var _x1 = (m_10023 === null) ? 5 : m_10023.value;
    var tree = make(_x1);
     
    var loc = { value: 0 };
     
    var res = _lift_run_708(function(t /* tree */ ) {
        return _lift_run_707(loc, t);
      }, loc, tree, 10);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
  return $std_core_console.printsln($std_core_int.show(r));
}