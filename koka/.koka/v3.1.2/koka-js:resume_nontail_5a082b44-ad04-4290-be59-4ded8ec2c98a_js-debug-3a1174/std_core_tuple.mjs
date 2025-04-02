// Koka generated module: std/core/tuple, koka version: 3.1.2
"use strict";
 
// imports
import * as $std_core_types from './std_core_types.mjs';
import * as $std_core_hnd from './std_core_hnd.mjs';
 
// externals
 
// type declarations
 
// declarations
 
 
// Convert a unit value `()` to a string
export function unit_fs_show(u) /* (u : ()) -> string */  {
  return "()";
}
 
 
// monadic lift
export function tuple2_fs__mlift_map_10029(_y_x10000, _y_x10001) /* forall<a,e> (a, a) -> e (a, a) */  {
  return $std_core_types.Tuple2(_y_x10000, _y_x10001);
}
 
 
// monadic lift
export function tuple2_fs__mlift_map_10030(f, t, _y_x10000) /* forall<a,b,e> (f : (a) -> e b, t : (a, a), b) -> e (b, b) */  {
   
  var _x0 = t.snd;
  var x_10043 = f(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10001 /* 242 */ ) {
      return $std_core_types.Tuple2(_y_x10000, _y_x10001);
    });
  }
  else {
    return $std_core_types.Tuple2(_y_x10000, x_10043);
  }
}
 
 
// Map a function over a tuple of elements of the same type.
export function tuple2_fs_map(t, f) /* forall<a,b,e> (t : (a, a), f : (a) -> e b) -> e (b, b) */  {
   
  var _x0 = t.fst;
  var x_10047 = f(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10000 /* 242 */ ) {
      return tuple2_fs__mlift_map_10030(f, t, _y_x10000);
    });
  }
  else {
     
    var _x0 = t.snd;
    var x_0_10050 = f(_x0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10001 /* 242 */ ) {
        return $std_core_types.Tuple2(x_10047, _y_x10001);
      });
    }
    else {
      return $std_core_types.Tuple2(x_10047, x_0_10050);
    }
  }
}
 
 
// monadic lift
export function tuple3_fs__mlift_map_10031(_y_x10002, _y_x10003, _y_x10004) /* forall<a,e> (a, a, a) -> e (a, a, a) */  {
  return $std_core_types.Tuple3(_y_x10002, _y_x10003, _y_x10004);
}
 
 
// monadic lift
export function tuple3_fs__mlift_map_10032(_y_x10002, f, t, _y_x10003) /* forall<a,b,e> (b, f : (a) -> e b, t : (a, a, a), b) -> e (b, b, b) */  {
   
  var _x0 = t.thd;
  var x_10055 = f(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10004 /* 389 */ ) {
      return $std_core_types.Tuple3(_y_x10002, _y_x10003, _y_x10004);
    });
  }
  else {
    return $std_core_types.Tuple3(_y_x10002, _y_x10003, x_10055);
  }
}
 
 
// monadic lift
export function tuple3_fs__mlift_map_10033(f, t, _y_x10002) /* forall<a,b,e> (f : (a) -> e b, t : (a, a, a), b) -> e (b, b, b) */  {
   
  var _x0 = t.snd;
  var x_10060 = f(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10003 /* 389 */ ) {
      return tuple3_fs__mlift_map_10032(_y_x10002, f, t, _y_x10003);
    });
  }
  else {
    return tuple3_fs__mlift_map_10032(_y_x10002, f, t, x_10060);
  }
}
 
 
// Map a function over a triple of elements of the same type.
export function tuple3_fs_map(t, f) /* forall<a,b,e> (t : (a, a, a), f : (a) -> e b) -> e (b, b, b) */  {
   
  var _x0 = t.fst;
  var x_10062 = f(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10002 /* 389 */ ) {
      return tuple3_fs__mlift_map_10033(f, t, _y_x10002);
    });
  }
  else {
     
    var _x0 = t.snd;
    var x_0_10065 = f(_x0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10003 /* 389 */ ) {
        return tuple3_fs__mlift_map_10032(x_10062, f, t, _y_x10003);
      });
    }
    else {
       
      var _x0 = t.thd;
      var x_1_10068 = f(_x0);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_y_x10004 /* 389 */ ) {
          return $std_core_types.Tuple3(x_10062, x_0_10065, _y_x10004);
        });
      }
      else {
        return $std_core_types.Tuple3(x_10062, x_0_10065, x_1_10068);
      }
    }
  }
}
 
 
// monadic lift
export function tuple4_fs__mlift_map_10034(_y_x10005, _y_x10006, _y_x10007, _y_x10008) /* forall<a,e> (a, a, a, a) -> e (a, a, a, a) */  {
  return $std_core_types.Tuple4(_y_x10005, _y_x10006, _y_x10007, _y_x10008);
}
 
 
// monadic lift
export function tuple4_fs__mlift_map_10035(_y_x10005, _y_x10006, f, t, _y_x10007) /* forall<a,b,e> (b, b, f : (a) -> e b, t : (a, a, a, a), b) -> e (b, b, b, b) */  {
   
  var _x0 = t.field4;
  var x_10074 = f(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10008 /* 576 */ ) {
      return $std_core_types.Tuple4(_y_x10005, _y_x10006, _y_x10007, _y_x10008);
    });
  }
  else {
    return $std_core_types.Tuple4(_y_x10005, _y_x10006, _y_x10007, x_10074);
  }
}
 
 
// monadic lift
export function tuple4_fs__mlift_map_10036(_y_x10005, f, t, _y_x10006) /* forall<a,b,e> (b, f : (a) -> e b, t : (a, a, a, a), b) -> e (b, b, b, b) */  {
   
  var _x0 = t.thd;
  var x_10080 = f(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10007 /* 576 */ ) {
      return tuple4_fs__mlift_map_10035(_y_x10005, _y_x10006, f, t, _y_x10007);
    });
  }
  else {
    return tuple4_fs__mlift_map_10035(_y_x10005, _y_x10006, f, t, x_10080);
  }
}
 
 
// monadic lift
export function tuple4_fs__mlift_map_10037(f, t, _y_x10005) /* forall<a,b,e> (f : (a) -> e b, t : (a, a, a, a), b) -> e (b, b, b, b) */  {
   
  var _x0 = t.snd;
  var x_10082 = f(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10006 /* 576 */ ) {
      return tuple4_fs__mlift_map_10036(_y_x10005, f, t, _y_x10006);
    });
  }
  else {
    return tuple4_fs__mlift_map_10036(_y_x10005, f, t, x_10082);
  }
}
 
 
// Map a function over a quadruple of elements of the same type.
export function tuple4_fs_map(t, f) /* forall<a,b,e> (t : (a, a, a, a), f : (a) -> e b) -> e (b, b, b, b) */  {
   
  var _x0 = t.fst;
  var x_10084 = f(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10005 /* 576 */ ) {
      return tuple4_fs__mlift_map_10037(f, t, _y_x10005);
    });
  }
  else {
     
    var _x0 = t.snd;
    var x_0_10087 = f(_x0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10006 /* 576 */ ) {
        return tuple4_fs__mlift_map_10036(x_10084, f, t, _y_x10006);
      });
    }
    else {
       
      var _x0 = t.thd;
      var x_1_10090 = f(_x0);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_y_x10007 /* 576 */ ) {
          return tuple4_fs__mlift_map_10035(x_10084, x_0_10087, f, t, _y_x10007);
        });
      }
      else {
         
        var _x0 = t.field4;
        var x_2_10093 = f(_x0);
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(function(_y_x10008 /* 576 */ ) {
            return $std_core_types.Tuple4(x_10084, x_0_10087, x_1_10090, _y_x10008);
          });
        }
        else {
          return $std_core_types.Tuple4(x_10084, x_0_10087, x_1_10090, x_2_10093);
        }
      }
    }
  }
}
 
 
// monadic lift
export function tuple2_fs__mlift_show_10038(_y_x10009, _y_x10010) /* forall<e> (string, string) -> e string */  {
  return $std_core_types._lp__plus__plus__rp_("(", $std_core_types._lp__plus__plus__rp_(_y_x10009, $std_core_types._lp__plus__plus__rp_(",", $std_core_types._lp__plus__plus__rp_(_y_x10010, ")"))));
}
 
 
// monadic lift
export function tuple2_fs__mlift_show_10039(x, _implicit_fs_snd_fs_show, _y_x10009) /* forall<a,b,e> (x : (a, b), ?snd/show : (b) -> e string, string) -> e string */  {
   
  var _x0 = x.snd;
  var x_0_10100 = _implicit_fs_snd_fs_show(_x0);
   
  function next_10101(_y_x10010) /* (string) -> 748 string */  {
    return $std_core_types._lp__plus__plus__rp_("(", $std_core_types._lp__plus__plus__rp_(_y_x10009, $std_core_types._lp__plus__plus__rp_(",", $std_core_types._lp__plus__plus__rp_(_y_x10010, ")"))));
  }
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(next_10101);
  }
  else {
    return next_10101(x_0_10100);
  }
}
 
 
// Show a tuple
export function tuple2_fs_show(x, _implicit_fs_fst_fs_show, _implicit_fs_snd_fs_show) /* forall<a,b,e> (x : (a, b), ?fst/show : (a) -> e string, ?snd/show : (b) -> e string) -> e string */  {
   
  var _x0 = x.fst;
  var x_0_10104 = _implicit_fs_fst_fs_show(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10009 /* string */ ) {
      return tuple2_fs__mlift_show_10039(x, _implicit_fs_snd_fs_show, _y_x10009);
    });
  }
  else {
     
    var _x0 = x.snd;
    var x_1_10107 = _implicit_fs_snd_fs_show(_x0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10010 /* string */ ) {
        return $std_core_types._lp__plus__plus__rp_("(", $std_core_types._lp__plus__plus__rp_(x_0_10104, $std_core_types._lp__plus__plus__rp_(",", $std_core_types._lp__plus__plus__rp_(_y_x10010, ")"))));
      });
    }
    else {
      return $std_core_types._lp__plus__plus__rp_("(", $std_core_types._lp__plus__plus__rp_(x_0_10104, $std_core_types._lp__plus__plus__rp_(",", $std_core_types._lp__plus__plus__rp_(x_1_10107, ")"))));
    }
  }
}
 
 
// monadic lift
export function tuple3_fs__mlift_show_10040(_y_x10011, _y_x10012, _y_x10013) /* forall<e> (string, string, string) -> e string */  {
  return $std_core_types._lp__plus__plus__rp_("(", $std_core_types._lp__plus__plus__rp_(_y_x10011, $std_core_types._lp__plus__plus__rp_(",", $std_core_types._lp__plus__plus__rp_(_y_x10012, $std_core_types._lp__plus__plus__rp_(",", $std_core_types._lp__plus__plus__rp_(_y_x10013, ")"))))));
}
 
 
// monadic lift
export function tuple3_fs__mlift_show_10041(_y_x10011, x, _implicit_fs_thd_fs_show, _y_x10012) /* forall<a,b,c,e> (string, x : (a, b, c), ?thd/show : (c) -> e string, string) -> e string */  {
   
  var _x0 = x.thd;
  var x_0_10112 = _implicit_fs_thd_fs_show(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10013 /* string */ ) {
      return tuple3_fs__mlift_show_10040(_y_x10011, _y_x10012, _y_x10013);
    });
  }
  else {
    return tuple3_fs__mlift_show_10040(_y_x10011, _y_x10012, x_0_10112);
  }
}
 
 
// monadic lift
export function tuple3_fs__mlift_show_10042(x, _implicit_fs_snd_fs_show, _implicit_fs_thd_fs_show, _y_x10011) /* forall<a,b,c,e> (x : (a, b, c), ?snd/show : (b) -> e string, ?thd/show : (c) -> e string, string) -> e string */  {
   
  var _x0 = x.snd;
  var x_0_10114 = _implicit_fs_snd_fs_show(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10012 /* string */ ) {
      return tuple3_fs__mlift_show_10041(_y_x10011, x, _implicit_fs_thd_fs_show, _y_x10012);
    });
  }
  else {
    return tuple3_fs__mlift_show_10041(_y_x10011, x, _implicit_fs_thd_fs_show, x_0_10114);
  }
}
 
 
// Show a triple
export function tuple3_fs_show(x, _implicit_fs_fst_fs_show, _implicit_fs_snd_fs_show, _implicit_fs_thd_fs_show) /* forall<a,b,c,e> (x : (a, b, c), ?fst/show : (a) -> e string, ?snd/show : (b) -> e string, ?thd/show : (c) -> e string) -> e string */  {
   
  var _x0 = x.fst;
  var x_0_10116 = _implicit_fs_fst_fs_show(_x0);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10011 /* string */ ) {
      return tuple3_fs__mlift_show_10042(x, _implicit_fs_snd_fs_show, _implicit_fs_thd_fs_show, _y_x10011);
    });
  }
  else {
     
    var _x0 = x.snd;
    var x_1_10119 = _implicit_fs_snd_fs_show(_x0);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10012 /* string */ ) {
        return tuple3_fs__mlift_show_10041(x_0_10116, x, _implicit_fs_thd_fs_show, _y_x10012);
      });
    }
    else {
       
      var _x0 = x.thd;
      var x_2_10122 = _implicit_fs_thd_fs_show(_x0);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(_y_x10013 /* string */ ) {
          return tuple3_fs__mlift_show_10040(x_0_10116, x_1_10119, _y_x10013);
        });
      }
      else {
        return $std_core_types._lp__plus__plus__rp_("(", $std_core_types._lp__plus__plus__rp_(x_0_10116, $std_core_types._lp__plus__plus__rp_(",", $std_core_types._lp__plus__plus__rp_(x_1_10119, $std_core_types._lp__plus__plus__rp_(",", $std_core_types._lp__plus__plus__rp_(x_2_10122, ")"))))));
      }
    }
  }
}
 
 
// _deprecated_, use `tuple2/show` instead
export function show_tuple(x, showfst, showsnd) /* forall<a,b,e> (x : (a, b), showfst : (a) -> e string, showsnd : (b) -> e string) -> e string */  {
  return tuple2_fs_show(x, showfst, showsnd);
}
 
 
// Element-wise tuple equality
export function tuple2_fs__lp__eq__eq__rp_(_pat_x29__22, _pat_x29__39, _implicit_fs_fst_fs__lp__eq__eq__rp_, _implicit_fs_snd_fs__lp__eq__eq__rp_) /* forall<a,b> ((a, b), (a, b), ?fst/(==) : (a, a) -> bool, ?snd/(==) : (b, b) -> bool) -> bool */  {
  var _x0 = _implicit_fs_fst_fs__lp__eq__eq__rp_(_pat_x29__22.fst, _pat_x29__39.fst);
  if (_x0) {
    return _implicit_fs_snd_fs__lp__eq__eq__rp_(_pat_x29__22.snd, _pat_x29__39.snd);
  }
  else {
    return false;
  }
}
 
 
// Element-wise triple equality
export function tuple3_fs__lp__eq__eq__rp_(_pat_x33__22, _pat_x33__44, _implicit_fs_fst_fs__lp__eq__eq__rp_, _implicit_fs_snd_fs__lp__eq__eq__rp_, _implicit_fs_thd_fs__lp__eq__eq__rp_) /* forall<a,b,c> ((a, b, c), (a, b, c), ?fst/(==) : (a, a) -> bool, ?snd/(==) : (b, b) -> bool, ?thd/(==) : (c, c) -> bool) -> bool */  {
  var _x1 = _implicit_fs_fst_fs__lp__eq__eq__rp_(_pat_x33__22.fst, _pat_x33__44.fst);
  if (_x1) {
    var _x2 = _implicit_fs_snd_fs__lp__eq__eq__rp_(_pat_x33__22.snd, _pat_x33__44.snd);
    if (_x2) {
      return _implicit_fs_thd_fs__lp__eq__eq__rp_(_pat_x33__22.thd, _pat_x33__44.thd);
    }
    else {
      return false;
    }
  }
  else {
    return false;
  }
}
 
 
// Order on tuples
export function tuple2_fs_cmp(_pat_x38__21, _pat_x38__38, _implicit_fs_fst_fs_cmp, _implicit_fs_snd_fs_cmp) /* forall<a,b> ((a, b), (a, b), ?fst/cmp : (a, a) -> order, ?snd/cmp : (b, b) -> order) -> order */  {
  var _x3 = _implicit_fs_fst_fs_cmp(_pat_x38__21.fst, _pat_x38__38.fst);
  if (_x3 === 2) {
    return _implicit_fs_snd_fs_cmp(_pat_x38__21.snd, _pat_x38__38.snd);
  }
  else {
    return _x3;
  }
}
 
 
// Order on triples
export function tuple3_fs_cmp(_pat_x44__26, _pat_x44__48, _implicit_fs_fst_fs_cmp, _implicit_fs_snd_fs_cmp, _implicit_fs_thd_fs_cmp) /* forall<a,b,c> ((a, b, c), (a, b, c), ?fst/cmp : (a, a) -> order, ?snd/cmp : (b, b) -> order, ?thd/cmp : (c, c) -> order) -> order */  {
  var _x4 = _implicit_fs_fst_fs_cmp(_pat_x44__26.fst, _pat_x44__48.fst);
  if (_x4 === 2) {
    var _x5 = _implicit_fs_snd_fs_cmp(_pat_x44__26.snd, _pat_x44__48.snd);
    if (_x5 === 2) {
      return _implicit_fs_thd_fs_cmp(_pat_x44__26.thd, _pat_x44__48.thd);
    }
    else {
      return _x5;
    }
  }
  else {
    return _x4;
  }
}