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
 
 
// runtime tag for the effect `:read`
export var _tag_read;
var _tag_read = "read@main";
 
 
// runtime tag for the effect `:stop`
export var _tag_stop;
var _tag_stop = "stop@main";
// type emit
export function _Hnd_emit(_cfc, _fun_emit) /* forall<e,a> (int, hnd/clause1<int,(),emit,e,a>) -> emit<e,a> */  {
  return { _cfc: _cfc, _fun_emit: _fun_emit };
}
// type read
export function _Hnd_read(_cfc, _fun_read) /* forall<e,a> (int, hnd/clause0<chr,read,e,a>) -> read<e,a> */  {
  return { _cfc: _cfc, _fun_read: _fun_read };
}
// type stop
export function _Hnd_stop(_cfc, _ctl_stop) /* forall<e,a> (int, forall<b> hnd/clause0<b,stop,e,a>) -> stop<e,a> */  {
  return { _cfc: _cfc, _ctl_stop: _ctl_stop };
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
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:read` type.
export function read_fs__cfc(read_0) /* forall<e,a> (read : read<e,a>) -> int */  {
  return read_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@fun-read` constructor field of the `:read` type.
export function read_fs__fun_read(read_0) /* forall<e,a> (read : read<e,a>) -> hnd/clause0<chr,read,e,a> */  {
  return read_0._fun_read;
}
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:stop` type.
export function stop_fs__cfc(stop_0) /* forall<e,a> (stop : stop<e,a>) -> int */  {
  return stop_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@ctl-stop` constructor field of the `:stop` type.
export function stop_fs__ctl_stop(stop_0) /* forall<e,a,b> (stop : stop<e,a>) -> hnd/clause0<b,stop,e,a> */  {
  return stop_0._ctl_stop;
}
 
 
// handler for the effect `:emit`
export function _handle_emit(hnd, ret, action) /* forall<a,e,b> (hnd : emit<e,b>, ret : (res : a) -> e b, action : () -> <emit|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_emit, hnd, ret, action);
}
 
 
// handler for the effect `:read`
export function _handle_read(hnd, ret, action) /* forall<a,e,b> (hnd : read<e,b>, ret : (res : a) -> e b, action : () -> <read|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_read, hnd, ret, action);
}
 
 
// handler for the effect `:stop`
export function _handle_stop(hnd, ret, action) /* forall<a,e,b> (hnd : stop<e,b>, ret : (res : a) -> e b, action : () -> <stop|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_stop, hnd, ret, action);
}
 
 
// select `emit` operation out of effect `:emit`
export function _select_emit(hnd) /* forall<e,a> (hnd : emit<e,a>) -> hnd/clause1<int,(),emit,e,a> */  {
  return hnd._fun_emit;
}
 
 
// select `read` operation out of effect `:read`
export function _select_read(hnd) /* forall<e,a> (hnd : read<e,a>) -> hnd/clause0<chr,read,e,a> */  {
  return hnd._fun_read;
}
 
 
// select `stop` operation out of effect `:stop`
export function _select_stop(hnd) /* forall<a,e,b> (hnd : stop<e,b>) -> hnd/clause0<a,stop,e,b> */  {
  return hnd._ctl_stop;
}
 
export function dollar() /* () -> chr */  {
  return 36;
}
 
export function newline() /* () -> chr */  {
  return 10;
}
 
export function is_dollar(c) /* (c : chr) -> bool */  {
  return $std_core_types._int_eq(c,36);
}
 
export function is_newline(c) /* (c : chr) -> bool */  {
  return $std_core_types._int_eq(c,10);
}
 
 
// Call the `ctl stop` operation of the effect `:stop`
export function stop() /* forall<a> () -> stop a */  {
   
  var ev_10087 = $std_core_hnd._evv_at(0);
  var _x0 = ev_10087.hnd._ctl_stop;
  return _x0(ev_10087.marker, ev_10087);
}
 
export function $catch(action) /* forall<e> (action : () -> <stop|e> ()) -> e () */  {
  return _handle_stop(_Hnd_stop(3, function(m /* hnd/marker<727,()> */ , ___wildcard_x730__16 /* hnd/ev<stop> */ ) {
        return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<717,()>) -> 727 () */ ) {
            return $std_core_hnd.protect($std_core_types.Unit, function(___wildcard_x730__55 /* () */ , r /* (717) -> 727 () */ ) {
                return $std_core_types.Unit;
              }, k);
          });
      }), function(_x /* () */ ) {
      return _x;
    }, action);
}
 
 
// Call the `fun emit` operation of the effect `:emit`
export function emit(e) /* (e : int) -> emit () */  {
   
  var ev_10090 = $std_core_hnd._evv_at(0);
  return ev_10090.hnd._fun_emit(ev_10090.marker, ev_10090, e);
}
 
 
// Call the `fun read` operation of the effect `:read`
export function read() /* () -> read chr */  {
   
  var ev_10093 = $std_core_hnd._evv_at(0);
  return (ev_10093.hnd._fun_read)(ev_10093.marker, ev_10093);
}
 
 
// monadic lift
export function _mlift_feed_10072(wild___0) /* forall<h,e> (wild_@0 : ()) -> <local<h>,stop|e> int */  {
  return 10;
}
 
 
// monadic lift
export function _mlift_feed_10073(j, _y_x10023) /* forall<h,e> (j : local-var<h,int>, int) -> <local<h>,stop|e> chr */  {
   
  var x_10095 = ((j).value = _y_x10023);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
      return 10;
    });
  }
  else {
    return 10;
  }
}
 
 
// monadic lift
export function _mlift_feed_10074(i, j, wild__) /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, wild_ : ()) -> <local<h>,stop|e> chr */  {
   
  var x_10098 = ((i).value);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10023 /* int */ ) {
      return _mlift_feed_10073(j, _y_x10023);
    });
  }
  else {
    return _mlift_feed_10073(j, x_10098);
  }
}
 
 
// monadic lift
export function _mlift_feed_10075(i, j, _y_x10021) /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, int) -> <local<h>,stop|e> chr */  {
   
  var x_10100 = ((i).value = ($std_core_types._int_add(_y_x10021,1)));
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild__ /* () */ ) {
      return _mlift_feed_10074(i, j, wild__);
    });
  }
  else {
    return _mlift_feed_10074(i, j, x_10100);
  }
}
 
 
// monadic lift
export function _mlift_feed_10076(wild___1) /* forall<h,e> (wild_@1 : ()) -> <local<h>,stop|e> int */  {
  return 36;
}
 
 
// monadic lift
export function _mlift_feed_10077(j, _y_x10025) /* forall<h,e> (j : local-var<h,int>, int) -> <local<h>,stop|e> chr */  {
   
  var x_10102 = ((j).value = ($std_core_types._int_sub(_y_x10025,1)));
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild___1 /* () */ ) {
      return 36;
    });
  }
  else {
    return 36;
  }
}
 
 
// monadic lift
export function _mlift_feed_10078(i, j, _y_x10020) /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, int) -> <local<h>,stop|e> chr */  {
  if ($std_core_types._int_eq(_y_x10020,0)) {
     
    var x_10105 = ((i).value);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10021 /* int */ ) {
        return _mlift_feed_10075(i, j, _y_x10021);
      });
    }
    else {
      return _mlift_feed_10075(i, j, x_10105);
    }
  }
  else {
     
    var x_0_10107 = ((j).value);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10025 /* int */ ) {
        return _mlift_feed_10077(j, _y_x10025);
      });
    }
    else {
      return _mlift_feed_10077(j, x_0_10107);
    }
  }
}
 
 
// monadic lift
export function _mlift_feed_10079(i, j, n, _y_x10017) /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, n : int, int) -> <local<h>,stop|e> chr */  {
  if ($std_core_types._int_gt(_y_x10017,n)) {
    return $std_core_hnd._open_at0($std_core_hnd._evv_index(_tag_stop), function() {
         
        var ev_10109 = $std_core_hnd._evv_at(0);
        var _x1 = ev_10109.hnd._ctl_stop;
        return _x1(ev_10109.marker, ev_10109);
      });
  }
  else {
     
    var x_10111 = ((j).value);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10020 /* int */ ) {
        return _mlift_feed_10078(i, j, _y_x10020);
      });
    }
    else {
      return _mlift_feed_10078(i, j, x_10111);
    }
  }
}
 
export function feed(n, action) /* forall<e> (n : int, action : () -> <read,stop|e> ()) -> <stop|e> () */  {
  return function() {
     
    var loc = { value: 0 };
     
    var loc_0 = { value: 0 };
     
    var res_0 = _handle_read(_Hnd_read(1, $std_core_hnd.clause_tail0(function() {
           
          var x_10117 = ((loc).value);
          if ($std_core_hnd._yielding()) {
            return $std_core_hnd.yield_extend(function(_y_x10017 /* int */ ) {
              return _mlift_feed_10079(loc, loc_0, n, _y_x10017);
            });
          }
          else {
            return _mlift_feed_10079(loc, loc_0, n, x_10117);
          }
        })), function(_x /* () */ ) {
        return _x;
      }, action);
     
    var res = $std_core_hnd.prompt_local_var(loc_0, res_0);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
 
// monadic lift
export function _mlift_parse_10080(wild__) /* forall<a> (wild_ : ()) -> <emit,stop,read,div> a */  {
  return parse(0);
}
 
 
// monadic lift
export function _mlift_parse_10081(a, c) /* forall<a> (a : int, c : chr) -> <read,emit,stop,div> a */  {
  if ($std_core_types._int_eq(c,36)) {
    return parse($std_core_types._int_add(a,1));
  }
  else {
    if ($std_core_types._int_eq(c,10)) {
       
      var x_10120 = $std_core_hnd._open_at1(0, function(e /* int */ ) {
           
          var ev_10122 = $std_core_hnd._evv_at(0);
          return ev_10122.hnd._fun_emit(ev_10122.marker, ev_10122, e);
        }, a);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
          return _mlift_parse_10080(wild___0);
        });
      }
      else {
        return _mlift_parse_10080(x_10120);
      }
    }
    else {
      return $std_core_hnd._open_at0(2, function() {
           
          var ev_0_10125 = $std_core_hnd._evv_at(0);
          var _x2 = ev_0_10125.hnd._ctl_stop;
          return _x2(ev_0_10125.marker, ev_0_10125);
        });
    }
  }
}
 
export function parse(a_0) /* forall<a> (a : int) -> <div,emit,read,stop> a */  { tailcall: while(1)
{
   
  var x_1_10127 = $std_core_hnd._open_at0(1, function() {
       
      var ev_1_10130 = $std_core_hnd._evv_at(0);
      return (ev_1_10130.hnd._fun_read)(ev_1_10130.marker, ev_1_10130);
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(c_0 /* chr */ ) {
      return _mlift_parse_10081(a_0, c_0);
    });
  }
  else {
    if ($std_core_types._int_eq(x_1_10127,36)) {
      {
        // tail call
        var _x3 = $std_core_types._int_add(a_0,1);
        a_0 = _x3;
        continue tailcall;
      }
    }
    else {
      if ($std_core_types._int_eq(x_1_10127,10)) {
         
        var x_2_10132 = $std_core_hnd._open_at1(0, function(e_0 /* int */ ) {
             
            var ev_2_10135 = $std_core_hnd._evv_at(0);
            return ev_2_10135.hnd._fun_emit(ev_2_10135.marker, ev_2_10135, e_0);
          }, a_0);
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(function(wild___1 /* () */ ) {
            return _mlift_parse_10080(wild___1);
          });
        }
        else {
          {
            // tail call
            var _x4 = 0;
            a_0 = _x4;
            continue tailcall;
          }
        }
      }
      else {
        return $std_core_hnd._open_at0(2, function() {
             
            var ev_3_10138 = $std_core_hnd._evv_at(0);
            var _x5 = ev_3_10138.hnd._ctl_stop;
            return _x5(ev_3_10138.marker, ev_3_10138);
          });
      }
    }
  }
}}
 
 
// monadic lift
export function _mlift_sum_10082(e, s, _y_x10044) /* forall<h,e> (e : int, s : local-var<h,int>, int) -> <local<h>|e> () */  {
  return ((s).value = ($std_core_types._int_add(_y_x10044,e)));
}
 
 
// monadic lift
export function _mlift_sum_10083(s, wild__) /* forall<h,e> (s : local-var<h,int>, wild_ : ()) -> <local<h>,emit|e> int */  {
  return ((s).value);
}
 
export function sum(action) /* forall<e> (action : () -> <emit|e> ()) -> e int */  {
  return function() {
     
    var loc = { value: 0 };
     
    var res = _handle_emit(_Hnd_emit(1, $std_core_hnd.clause_tail1(function(e /* int */ ) {
           
          var x_10142 = ((loc).value);
           
          function next_10143(_y_x10044) /* (int) -> <local<1508>|1512> () */  {
            return ((loc).value = ($std_core_types._int_add(_y_x10044,e)));
          }
          if ($std_core_hnd._yielding()) {
            return $std_core_hnd.yield_extend(next_10143);
          }
          else {
            return next_10143(x_10142);
          }
        })), function(_x /* int */ ) {
        return _x;
      }, function() {
         
        var x_0_10147 = action();
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(function(wild__ /* () */ ) {
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
 
export function run(n) /* (n : int) -> div int */  {
  return sum(function() {
    return _handle_stop(_Hnd_stop(3, function(m /* hnd/marker<<div,emit>,()> */ , ___wildcard_x730__16 /* hnd/ev<stop> */ ) {
          return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<717,()>) -> <div,emit> () */ ) {
              return $std_core_hnd.protect($std_core_types.Unit, function(___wildcard_x730__55 /* () */ , r /* (717) -> <div,emit> () */ ) {
                  return $std_core_types.Unit;
                }, k);
            });
        }), function(_x /* () */ ) {
        return _x;
      }, function() {
        return feed(n, function() {
            return parse(0);
          });
      });
  });
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10005 = $std_os_env.get_args();
   
  var _x6 = (xs_10005 !== null) ? xs_10005.head : "";
  var m_10003 = $std_core_int.parse_int(_x6);
   
  var r_0 = sum(function() {
    return _handle_stop(_Hnd_stop(3, function(m /* hnd/marker<<div,emit>,()> */ , ___wildcard_x730__16 /* hnd/ev<stop> */ ) {
          return $std_core_hnd.yield_to(m, function(k /* (hnd/resume-result<717,()>) -> <div,emit> () */ ) {
              return $std_core_hnd.protect($std_core_types.Unit, function(___wildcard_x730__55 /* () */ , r /* (717) -> <div,emit> () */ ) {
                  return $std_core_types.Unit;
                }, k);
            });
        }), function(_x /* () */ ) {
        return _x;
      }, function() {
        var _x7 = (m_10003 === null) ? 10 : m_10003.value;
        return feed(_x7, function() {
            return parse(0);
          });
      });
  });
  return $std_core_console.printsln($std_core_int.show(r_0));
}