// Koka generated module: std/text/parse, koka version: 3.1.2
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
import * as $std_core_undiv from './std_core_undiv.mjs';
 
// externals
 
// type declarations
 
 
// runtime tag for the effect `:parse`
export var _tag_parse;
var _tag_parse = "parse@parse";
// type parse
export function _Hnd_parse(_cfc, _fun_current_input, _ctl_fail, _ctl_pick, _fun_satisfy) /* forall<e,a> (int, hnd/clause0<sslice/sslice,parse,e,a>, forall<b> hnd/clause1<string,b,parse,e,a>, hnd/clause0<bool,parse,e,a>, forall<b> hnd/clause1<(sslice/sslice) -> maybe<(b, sslice/sslice)>,maybe<b>,parse,e,a>) -> parse<e,a> */  {
  return { _cfc: _cfc, _fun_current_input: _fun_current_input, _ctl_fail: _ctl_fail, _ctl_pick: _ctl_pick, _fun_satisfy: _fun_satisfy };
}
// type parse-error
export function ParseOk(result, rest) /* forall<a> (result : a, rest : sslice/sslice) -> parse-error<a> */  {
  return { _tag: 1, result: result, rest: rest };
}
export function ParseError(msg, rest) /* forall<a> (msg : string, rest : sslice/sslice) -> parse-error<a> */  {
  return { _tag: 2, msg: msg, rest: rest };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `@cfc` constructor field of the `:parse` type.
export function parse_fs__cfc(parse_0) /* forall<e,a> (parse : parse<e,a>) -> int */  {
  return parse_0._cfc;
}
 
 
// Automatically generated. Retrieves the `@fun-current-input` constructor field of the `:parse` type.
export function parse_fs__fun_current_input(parse_0) /* forall<e,a> (parse : parse<e,a>) -> hnd/clause0<sslice/sslice,parse,e,a> */  {
  return parse_0._fun_current_input;
}
 
 
// Automatically generated. Retrieves the `@ctl-fail` constructor field of the `:parse` type.
export function parse_fs__ctl_fail(parse_0) /* forall<e,a,b> (parse : parse<e,a>) -> hnd/clause1<string,b,parse,e,a> */  {
  return parse_0._ctl_fail;
}
 
 
// Automatically generated. Retrieves the `@ctl-pick` constructor field of the `:parse` type.
export function parse_fs__ctl_pick(parse_0) /* forall<e,a> (parse : parse<e,a>) -> hnd/clause0<bool,parse,e,a> */  {
  return parse_0._ctl_pick;
}
 
 
// Automatically generated. Retrieves the `@fun-satisfy` constructor field of the `:parse` type.
export function parse_fs__fun_satisfy(parse_0) /* forall<e,a,b> (parse : parse<e,a>) -> hnd/clause1<(sslice/sslice) -> maybe<(b, sslice/sslice)>,maybe<b>,parse,e,a> */  {
  return parse_0._fun_satisfy;
}
 
 
// Automatically generated. Retrieves the `rest` constructor field of the `:parse-error` type.
export function parse_error_fs_rest(_this) /* forall<a> (parse-error<a>) -> sslice/sslice */  {
  return (_this._tag === 1) ? _this.rest : _this.rest;
}
 
 
// Automatically generated. Tests for the `ParseOk` constructor of the `:parse-error` type.
export function is_parseOk(parse_error) /* forall<a> (parse-error : parse-error<a>) -> bool */  {
  return (parse_error._tag === 1);
}
 
 
// Automatically generated. Tests for the `ParseError` constructor of the `:parse-error` type.
export function is_parseError(parse_error) /* forall<a> (parse-error : parse-error<a>) -> bool */  {
  return (parse_error._tag === 2);
}
 
 
// handler for the effect `:parse`
export function _handle_parse(hnd, ret, action) /* forall<a,e,b> (hnd : parse<e,b>, ret : (res : a) -> e b, action : () -> <parse|e> a) -> e b */  {
  return $std_core_hnd._hhandle(_tag_parse, hnd, ret, action);
}
 
 
// select `current-input` operation out of effect `:parse`
export function _select_current_input(hnd) /* forall<e,a> (hnd : parse<e,a>) -> hnd/clause0<sslice/sslice,parse,e,a> */  {
  return hnd._fun_current_input;
}
 
 
// select `fail` operation out of effect `:parse`
export function _select_fail(hnd) /* forall<a,e,b> (hnd : parse<e,b>) -> hnd/clause1<string,a,parse,e,b> */  {
  return hnd._ctl_fail;
}
 
 
// select `pick` operation out of effect `:parse`
export function _select_pick(hnd) /* forall<e,a> (hnd : parse<e,a>) -> hnd/clause0<bool,parse,e,a> */  {
  return hnd._ctl_pick;
}
 
 
// select `satisfy` operation out of effect `:parse`
export function _select_satisfy(hnd) /* forall<a,e,b> (hnd : parse<e,b>) -> hnd/clause1<(sslice/sslice) -> maybe<(a, sslice/sslice)>,maybe<a>,parse,e,b> */  {
  return hnd._fun_satisfy;
}
 
export function either(perr) /* forall<a> (perr : parse-error<a>) -> either<string,a> */  {
  if (perr._tag === 1) {
    return $std_core_types.Right(perr.result);
  }
  else {
    return $std_core_types.Left(perr.msg);
  }
}
 
 
// Call the `ctl fail` operation of the effect `:parse`
export function fail(msg) /* forall<a> (msg : string) -> parse a */  {
   
  var ev_10188 = $std_core_hnd._evv_at(0);
  var _x0 = ev_10188.hnd._ctl_fail;
  return _x0(ev_10188.marker, ev_10188, msg);
}
 
 
// Call the `fun satisfy` operation of the effect `:parse`
export function satisfy(pred) /* forall<a> (pred : (sslice/sslice) -> maybe<(a, sslice/sslice)>) -> parse maybe<a> */  {
   
  var ev_10191 = $std_core_hnd._evv_at(0);
  var _x1 = ev_10191.hnd._fun_satisfy;
  return _x1(ev_10191.marker, ev_10191, pred);
}
 
 
// monadic lift
export function _mlift_satisfy_fail_10164(msg, _y_x10069) /* forall<a> (msg : string, maybe<a>) -> parse a */  {
  if (_y_x10069 === null) {
     
    var ev_10194 = $std_core_hnd._evv_at(0);
    var _x2 = ev_10194.hnd._ctl_fail;
    return _x2(ev_10194.marker, ev_10194, msg);
  }
  else {
    return _y_x10069.value;
  }
}
 
export function satisfy_fail(msg, pred) /* forall<a> (msg : string, pred : (sslice/sslice) -> maybe<(a, sslice/sslice)>) -> parse a */  {
   
  var ev_10200 = $std_core_hnd._evv_at(0);
   
  var _x3 = ev_10200.hnd._fun_satisfy;
  var x_10197 = _x3(ev_10200.marker, ev_10200, pred);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10069 /* maybe<810> */ ) {
      return _mlift_satisfy_fail_10164(msg, _y_x10069);
    });
  }
  else {
    if (x_10197 === null) {
       
      var ev_0_10203 = $std_core_hnd._evv_at(0);
      var _x3 = ev_0_10203.hnd._ctl_fail;
      return _x3(ev_0_10203.marker, ev_0_10203, msg);
    }
    else {
      return x_10197.value;
    }
  }
}
 
export function char_is(msg, pred) /* (msg : string, pred : (char) -> bool) -> parse char */  {
  return satisfy_fail(msg, function(slice /* sslice/sslice */ ) {
      var _x4 = $std_core_sslice.next(slice);
      if (_x4 !== null) {
        if (pred(_x4.value.fst)){
          return $std_core_types.Just($std_core_types.Tuple2(_x4.value.fst, _x4.value.snd));
        }
      }
      return $std_core_types.Nothing;
    });
}
 
export function alpha() /* () -> parse char */  {
  return satisfy_fail("alpha", function(slice /* sslice/sslice */ ) {
      var _x5 = $std_core_sslice.next(slice);
      if (_x5 !== null) {
        if ($std_core_char.is_alpha(_x5.value.fst)){
          return $std_core_types.Just($std_core_types.Tuple2(_x5.value.fst, _x5.value.snd));
        }
      }
      return $std_core_types.Nothing;
    });
}
 
export function alpha_num() /* () -> parse char */  {
  return satisfy_fail("alpha-num", function(slice /* sslice/sslice */ ) {
      var _x6 = $std_core_sslice.next(slice);
      if (_x6 !== null) {
        if ($std_core_char.is_alpha_num(_x6.value.fst)){
          return $std_core_types.Just($std_core_types.Tuple2(_x6.value.fst, _x6.value.snd));
        }
      }
      return $std_core_types.Nothing;
    });
}
 
export function char(c) /* (c : char) -> parse char */  {
   
  var msg_10006 = $std_core_types._lp__plus__plus__rp_("\'", $std_core_types._lp__plus__plus__rp_($std_core_show.show_char(c), "\'"));
  return satisfy_fail(msg_10006, function(slice /* sslice/sslice */ ) {
      var _x7 = $std_core_sslice.next(slice);
      if (_x7 !== null) {
        if ((c === (_x7.value.fst))){
          return $std_core_types.Just($std_core_types.Tuple2(_x7.value.fst, _x7.value.snd));
        }
      }
      return $std_core_types.Nothing;
    });
}
 
export function next_while0(slice, pred, acc) /* (slice : sslice/sslice, pred : (char) -> bool, acc : list<char>) -> (list<char>, sslice/sslice) */  { tailcall: while(1)
{
  var _x8 = $std_core_sslice.next(slice);
  if (_x8 !== null) {
    if (pred(_x8.value.fst)){
      {
        // tail call
        var _x9 = $std_core_types.Cons(_x8.value.fst, acc);
        slice = _x8.value.snd;
        acc = _x9;
        continue tailcall;
      }
    }
  }
  return $std_core_types.Tuple2($std_core_list._lift_reverse_append_4790($std_core_types.Nil, acc), slice);
}}
 
export function chars_are(msg, pred) /* (msg : string, pred : (char) -> bool) -> parse list<char> */  {
  return satisfy_fail(msg, function(slice /* sslice/sslice */ ) {
      var _x10 = next_while0(slice, pred, $std_core_types.Nil);
      if (_x10.fst === null) {
        return $std_core_types.Nothing;
      }
      else {
        return $std_core_types.Just($std_core_types.Tuple2(_x10.fst, _x10.snd));
      }
    });
}
 
 
// Call the `ctl pick` operation of the effect `:parse`
export function pick() /* () -> parse bool */  {
   
  var ev_10206 = $std_core_hnd._evv_at(0);
  return (ev_10206.hnd._ctl_pick)(ev_10206.marker, ev_10206);
}
 
 
// monadic lift
export function _mlift_choose_10165(p_0, pp, _y_x10082) /* forall<a,e> (p@0 : parser<e,a>, pp : list<parser<e,a>>, bool) -> <parse|e> a */  {
  if (_y_x10082) {
    return p_0();
  }
  else {
    return choose(pp);
  }
}
 
export function choose(ps) /* forall<a,e> (ps : list<parser<e,a>>) -> <parse|e> a */  { tailcall: while(1)
{
  if (ps === null) {
    return $std_core_hnd._open_at1($std_core_hnd._evv_index(_tag_parse), function(msg /* string */ ) {
         
        var ev_10208 = $std_core_hnd._evv_at(0);
        var _x11 = ev_10208.hnd._ctl_fail;
        return _x11(ev_10208.marker, ev_10208, msg);
      }, "no further alternatives");
  }
  else if (ps !== null && ps.tail === null) {
    return ps.head();
  }
  else {
     
    var x_0_10211 = $std_core_hnd._open_at0($std_core_hnd._evv_index(_tag_parse), function() {
         
        var ev_0_10214 = $std_core_hnd._evv_at(0);
        return (ev_0_10214.hnd._ctl_pick)(ev_0_10214.marker, ev_0_10214);
      });
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10082_0 /* bool */ ) {
        return _mlift_choose_10165(ps.head, ps.tail, _y_x10082_0);
      });
    }
    else {
      if (x_0_10211) {
        return ps.head();
      }
      else {
        {
          // tail call
          ps = ps.tail;
          continue tailcall;
        }
      }
    }
  }
}}
 
 
// monadic lift
export function _mlift_count_acc_10166(acc, n, p, x) /* forall<a,e> (acc : list<a>, n : int, p : parser<e,a>, x : a) -> <parse|e> list<a> */  {
  return count_acc($std_core_types._int_sub(n,1), $std_core_types.Cons(x, acc), p);
}
 
export function count_acc(n_0, acc_0, p_0) /* forall<a,e> (n : int, acc : list<a>, p : parser<e,a>) -> <parse|e> list<a> */  { tailcall: while(1)
{
  if ($std_core_types._int_le(n_0,0)) {
    return $std_core_list._lift_reverse_append_4790($std_core_types.Nil, acc_0);
  }
  else {
     
    var x_0_10216 = p_0();
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(x_1 /* 1212 */ ) {
        return _mlift_count_acc_10166(acc_0, n_0, p_0, x_1);
      });
    }
    else {
      {
        // tail call
        var _x12 = $std_core_types._int_sub(n_0,1);
        var _x13 = $std_core_types.Cons(x_0_10216, acc_0);
        n_0 = _x12;
        acc_0 = _x13;
        continue tailcall;
      }
    }
  }
}}
 
export function count(n, p) /* forall<a,e> (n : int, p : parser<e,a>) -> <parse|e> list<a> */  {
  return count_acc(n, $std_core_types.Nil, p);
}
 
 
// Call the `fun current-input` operation of the effect `:parse`
export function current_input() /* () -> parse sslice/sslice */  {
   
  var ev_10219 = $std_core_hnd._evv_at(0);
  return (ev_10219.hnd._fun_current_input)(ev_10219.marker, ev_10219);
}
 
 
// monadic lift
export function _mlift_digit_10167(c_0_0) /* (c@0@0 : char) -> parse int */  {
  return ($std_core_hnd._open_none2(function(c_1 /* char */ , d /* char */ ) {
       
      var x_10002 = c_1;
       
      var y_10003 = d;
      return (($std_core_types._int_sub(x_10002,y_10003)));
    }, c_0_0, 0x0030));
}
 
export function digit() /* () -> parse int */  {
   
  var x_10221 = satisfy_fail("digit", function(slice /* sslice/sslice */ ) {
      var _x14 = $std_core_sslice.next(slice);
      if (_x14 !== null) {
        var _x15 = (((_x14.value.fst) >= 0x0030)) ? ((_x14.value.fst) <= 0x0039) : false;
        if (_x15){
          return $std_core_types.Just($std_core_types.Tuple2(_x14.value.fst, _x14.value.snd));
        }
      }
      return $std_core_types.Nothing;
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_digit_10167);
  }
  else {
    return ($std_core_hnd._open_none2(function(c_1 /* char */ , d /* char */ ) {
         
        var x_10002 = c_1;
         
        var y_10003 = d;
        return (($std_core_types._int_sub(x_10002,y_10003)));
      }, x_10221, 0x0030));
  }
}
 
export function digits() /* () -> parse string */  {
   
  var x_10224 = satisfy_fail("digit", function(slice /* sslice/sslice */ ) {
      var _x14 = next_while0(slice, $std_core_char.is_digit, $std_core_types.Nil);
      if (_x14.fst === null) {
        return $std_core_types.Nothing;
      }
      else {
        return $std_core_types.Just($std_core_types.Tuple2(_x14.fst, _x14.snd));
      }
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend($std_core_string.listchar_fs_string);
  }
  else {
    return $std_core_string.listchar_fs_string(x_10224);
  }
}
 
 
// monadic lift
export function _lp__at_mlift_x_10168_bar__bar__rp_(p1, p2, _y_x10095) /* forall<a,e> (p1 : parser<e,a>, p2 : parser<e,a>, bool) -> <parse|e> a */  {
  if (_y_x10095) {
    return p1();
  }
  else {
    return p2();
  }
}
 
export function _lp__bar__bar__rp_(p1, p2) /* forall<a,e> (p1 : parser<e,a>, p2 : parser<e,a>) -> <parse|e> a */  {
   
  var x_10226 = $std_core_hnd._open_at0($std_core_hnd._evv_index(_tag_parse), function() {
       
      var ev_10229 = $std_core_hnd._evv_at(0);
      return (ev_10229.hnd._ctl_pick)(ev_10229.marker, ev_10229);
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10095 /* bool */ ) {
      if (_y_x10095) {
        return p1();
      }
      else {
        return p2();
      }
    });
  }
  else {
    if (x_10226) {
      return p1();
    }
    else {
      return p2();
    }
  }
}
 
export function optional($default, p) /* forall<a,e> (default : a, p : parser<e,a>) -> <parse|e> a */  {
  return _lp__bar__bar__rp_(p, function() {
      return $default;
    });
}
 
export function digits0() /* () -> parse string */  {
  return _lp__bar__bar__rp_(function() {
       
      var x_10234 = satisfy_fail("digit", function(slice /* sslice/sslice */ ) {
          var _x14 = next_while0(slice, $std_core_char.is_digit, $std_core_types.Nil);
          if (_x14.fst === null) {
            return $std_core_types.Nothing;
          }
          else {
            return $std_core_types.Just($std_core_types.Tuple2(_x14.fst, _x14.snd));
          }
        });
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend($std_core_string.listchar_fs_string);
      }
      else {
        return $std_core_string.listchar_fs_string(x_10234);
      }
    }, function() {
      return "0";
    });
}
 
 
// monadic lift
export function _mlift_eof_10169(_y_x10102) /* (maybe<()>) -> parse () */  {
  if (_y_x10102 === null) {
     
    var ev_10236 = $std_core_hnd._evv_at(0);
    var _x14 = ev_10236.hnd._ctl_fail;
    return _x14(ev_10236.marker, ev_10236, "expecting end-of-input");
  }
  else {
    return $std_core_types.Unit;
  }
}
 
export function eof() /* () -> parse () */  {
   
  var ev_10242 = $std_core_hnd._evv_at(0);
   
  var _x15 = ev_10242.hnd._fun_satisfy;
  var x_10239 = _x15(ev_10242.marker, ev_10242, function(s /* sslice/sslice */ ) {
       
      var _x16 = s.len;
      var b_10013 = $std_core_types._int_gt(_x16,0);
      if (b_10013) {
        return $std_core_types.Nothing;
      }
      else {
        return $std_core_types.Just($std_core_types.Tuple2($std_core_types.Unit, s));
      }
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_eof_10169);
  }
  else {
    if (x_10239 === null) {
       
      var ev_0_10245 = $std_core_hnd._evv_at(0);
      var _x15 = ev_0_10245.hnd._ctl_fail;
      return _x15(ev_0_10245.marker, ev_0_10245, "expecting end-of-input");
    }
    else {
      return $std_core_types.Unit;
    }
  }
}
 
export function hex_digits() /* () -> parse string */  {
   
  var x_10248 = satisfy_fail("digit", function(slice /* sslice/sslice */ ) {
      var _x16 = next_while0(slice, $std_core_char.is_hex_digit, $std_core_types.Nil);
      if (_x16.fst === null) {
        return $std_core_types.Nothing;
      }
      else {
        return $std_core_types.Just($std_core_types.Tuple2(_x16.fst, _x16.snd));
      }
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend($std_core_string.listchar_fs_string);
  }
  else {
    return $std_core_string.listchar_fs_string(x_10248);
  }
}
 
 
// monadic lift
export function _mlift_many_acc_10170(acc, p, x) /* forall<a,e> (acc : list<a>, p : parser<e,a>, x : a) -> <parse|e> list<a> */  {
  return many_acc(p, $std_core_types.Cons(x, acc));
}
 
export function many_acc(p_0, acc_0) /* forall<a,e> (p : parser<e,a>, acc : list<a>) -> <parse|e> list<a> */  {
  return _lp__bar__bar__rp_(function() {
       
      var x_0_10250 = p_0();
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(x_1 /* 1498 */ ) {
          return _mlift_many_acc_10170(acc_0, p_0, x_1);
        });
      }
      else {
        return _mlift_many_acc_10170(acc_0, p_0, x_0_10250);
      }
    }, function() {
      return $std_core_list._lift_reverse_append_4790($std_core_types.Nil, acc_0);
    });
}
 
export function many(p) /* forall<a,e> (p : parser<e,a>) -> <parse|e> list<a> */  {
  return many_acc(p, $std_core_types.Nil);
}
 
 
// monadic lift
export function _mlift_many1_10171(_y_x10110, _y_x10111) /* forall<a,e> (a, list<a>) -> <parse|e> list<a> */  {
  return $std_core_types.Cons(_y_x10110, _y_x10111);
}
 
 
// monadic lift
export function _mlift_many1_10172(p, _y_x10110) /* forall<a,e> (p : parser<e,a>, a) -> <parse|e> list<a> */  {
   
  var x_10252 = many_acc(p, $std_core_types.Nil);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10111 /* list<1554> */ ) {
      return $std_core_types.Cons(_y_x10110, _y_x10111);
    });
  }
  else {
    return $std_core_types.Cons(_y_x10110, x_10252);
  }
}
 
export function many1(p) /* forall<a,e> (p : parser<e,a>) -> <parse|e> list<a> */  {
   
  var x_10256 = p();
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10110 /* 1554 */ ) {
      return _mlift_many1_10172(p, _y_x10110);
    });
  }
  else {
     
    var x_0_10259 = many_acc(p, $std_core_types.Nil);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(_y_x10111 /* list<1554> */ ) {
        return $std_core_types.Cons(x_10256, _y_x10111);
      });
    }
    else {
      return $std_core_types.Cons(x_10256, x_0_10259);
    }
  }
}
 
export function maybe(perr) /* forall<a> (perr : parse-error<a>) -> maybe<a> */  {
  if (perr._tag === 1) {
    return $std_core_types.Just(perr.result);
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
export function next_match(slice, cs) /* (slice : sslice/sslice, cs : list<char>) -> maybe<sslice/sslice> */  { tailcall: while(1)
{
  if (cs === null) {
    return $std_core_types.Just(slice);
  }
  else {
    var _x16 = $std_core_sslice.next(slice);
    if (_x16 !== null) {
      if (((cs.head) === (_x16.value.fst))){
        {
          // tail call
          slice = _x16.value.snd;
          cs = cs.tail;
          continue tailcall;
        }
      }
    }
    return $std_core_types.Nothing;
  }
}}
 
export function no_digit() /* () -> parse char */  {
  return satisfy_fail("not a digit", function(slice /* sslice/sslice */ ) {
      var _x17 = $std_core_sslice.next(slice);
      if (_x17 !== null) {
         
        var b_10027 = (((_x17.value.fst) >= 0x0030)) ? ((_x17.value.fst) <= 0x0039) : false;
        var _x18 = (b_10027) ? false : true;
        if (_x18){
          return $std_core_types.Just($std_core_types.Tuple2(_x17.value.fst, _x17.value.snd));
        }
      }
      return $std_core_types.Nothing;
    });
}
 
export function none_of(chars) /* (chars : string) -> parse char */  {
  return satisfy_fail("", function(slice /* sslice/sslice */ ) {
      var _x19 = $std_core_sslice.next(slice);
      if (_x19 !== null) {
         
        var b_10031 = ((chars).indexOf(($std_core_string.char_fs_string(_x19.value.fst))) >= 0);
        var _x20 = (b_10031) ? false : true;
        if (_x20){
          return $std_core_types.Just($std_core_types.Tuple2(_x19.value.fst, _x19.value.snd));
        }
      }
      return $std_core_types.Nothing;
    });
}
 
export function none_of_many1(chars) /* (chars : string) -> parse string */  {
   
  var x_10264 = satisfy_fail("", function(slice /* sslice/sslice */ ) {
      var _x21 = next_while0(slice, function(c /* char */ ) {
           
          var b_10034 = ((chars).indexOf(($std_core_string.char_fs_string(c))) >= 0);
          return (b_10034) ? false : true;
        }, $std_core_types.Nil);
      if (_x21.fst === null) {
        return $std_core_types.Nothing;
      }
      else {
        return $std_core_types.Just($std_core_types.Tuple2(_x21.fst, _x21.snd));
      }
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend($std_core_string.listchar_fs_string);
  }
  else {
    return $std_core_string.listchar_fs_string(x_10264);
  }
}
 
export function one_of(chars) /* (chars : string) -> parse char */  {
  return satisfy_fail(chars, function(slice /* sslice/sslice */ ) {
      var _x21 = $std_core_sslice.next(slice);
      if (_x21 !== null) {
        if (((chars).indexOf(($std_core_string.char_fs_string(_x21.value.fst))) >= 0)){
          return $std_core_types.Just($std_core_types.Tuple2(_x21.value.fst, _x21.value.snd));
        }
      }
      return $std_core_types.Nothing;
    });
}
 
export function one_of_or(chars, $default) /* (chars : string, default : char) -> parse char */  {
  return _lp__bar__bar__rp_(function() {
      return one_of(chars);
    }, function() {
      return $default;
    });
}
 
 
// monadic lift
export function _mlift_parse_10173(msg, _y_x10119) /* forall<h,a,e> (msg : string, sslice/sslice) -> <local<h>|e> parse-error<a> */  {
  return ParseError(msg, _y_x10119);
}
 
 
// monadic lift
export function _mlift_parse_10174(err1, _y_x10123) /* forall<h,a,e> (err1 : parse-error<a>, parse-error<a>) -> <local<h>|e> parse-error<a> */  {
  if (_y_x10123._tag === 1) {
    return ParseOk(_y_x10123.result, _y_x10123.rest);
  }
  else {
    return err1;
  }
}
 
 
// monadic lift
export function _mlift_parse_10175(err1, resume, wild__) /* forall<h,a,e> (err1 : parse-error<a>, resume : (bool) -> <local<h>|e> parse-error<a>, wild_ : ()) -> <local<h>|e> parse-error<a> */  {
   
  var x_10266 = resume(false);
   
  function next_10267(_y_x10123) /* (parse-error<2446>) -> <local<2440>|2447> parse-error<2446> */  {
    if (_y_x10123._tag === 1) {
      return ParseOk(_y_x10123.result, _y_x10123.rest);
    }
    else {
      return err1;
    }
  }
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(next_10267);
  }
  else {
    return next_10267(x_10266);
  }
}
 
 
// monadic lift
export function _mlift_parse_10176(input, resume, save, _y_x10121) /* forall<h,a,e> (input : local-var<h,sslice/sslice>, resume : (bool) -> <local<h>|e> parse-error<a>, save : sslice/sslice, parse-error<a>) -> <local<h>|e> parse-error<a> */  {
  if (_y_x10121._tag === 1) {
    return ParseOk(_y_x10121.result, _y_x10121.rest);
  }
  else {
     
    var x_10270 = ((input).value = save);
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild__ /* () */ ) {
        return _mlift_parse_10175(_y_x10121, resume, wild__);
      });
    }
    else {
      return _mlift_parse_10175(_y_x10121, resume, x_10270);
    }
  }
}
 
 
// monadic lift
export function _mlift_parse_10177(input, resume, save) /* forall<h,a,e> (input : local-var<h,sslice/sslice>, resume : (bool) -> <local<h>|e> parse-error<a>, save : sslice/sslice) -> <local<h>|e> parse-error<a> */  {
   
  var x_10272 = resume(true);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(_y_x10121 /* parse-error<2446> */ ) {
      return _mlift_parse_10176(input, resume, save, _y_x10121);
    });
  }
  else {
    return _mlift_parse_10176(input, resume, save, x_10272);
  }
}
 
 
// monadic lift
export function _mlift_parse_10178(x, wild___0) /* forall<a,h,e> (x : a, wild_@0 : ()) -> <local<h>|e> maybe<a> */  {
  return $std_core_types.Just(x);
}
 
 
// monadic lift
export function _mlift_parse_10179(input, pred, inp) /* forall<a,h,e> (input : local-var<h,sslice/sslice>, pred : (sslice/sslice) -> maybe<(a, sslice/sslice)>, inp : sslice/sslice) -> <local<h>|e> maybe<a> */  {
  var _x22 = pred(inp);
  if (_x22 !== null) {
     
    var x_0_10274 = ((input).value = (_x22.value.snd));
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(wild___0 /* () */ ) {
        return $std_core_types.Just(_x22.value.fst);
      });
    }
    else {
      return $std_core_types.Just(_x22.value.fst);
    }
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
 
// monadic lift
export function _mlift_parse_10180(x_0, _y_x10128) /* forall<h,a,e> (x@0 : a, sslice/sslice) -> <local<h>|e> parse-error<a> */  {
  return ParseOk(x_0, _y_x10128);
}
 
export function parse(input0, p) /* forall<a,e> (input0 : sslice/sslice, p : () -> <parse|e> a) -> e parse-error<a> */  {
  return function() {
     
    var loc = { value: input0 };
     
    var res = _handle_parse(_Hnd_parse(3, $std_core_hnd.clause_tail0(function() {
          return ((loc).value);
        }), function(m /* hnd/marker<<local<2440>|2447>,parse-error<2446>> */ , ___wildcard_x696__16 /* hnd/ev<parse> */ , x /* string */ ) {
          return $std_core_hnd.yield_to_final(m, function(___wildcard_x696__45 /* (hnd/resume-result<2252,parse-error<2446>>) -> <local<2440>|2447> parse-error<2446> */ ) {
               
              var x_0_10281 = ((loc).value);
              if ($std_core_hnd._yielding()) {
                return $std_core_hnd.yield_extend(function(_y_x10119 /* sslice/sslice */ ) {
                  return ParseError(x, _y_x10119);
                });
              }
              else {
                return ParseError(x, x_0_10281);
              }
            });
        }, function(m_0 /* hnd/marker<<local<2440>|2447>,parse-error<2446>> */ , ___wildcard_x730__16 /* hnd/ev<parse> */ ) {
          return $std_core_hnd.yield_to(m_0, function(k /* (hnd/resume-result<bool,parse-error<2446>>) -> <local<2440>|2447> parse-error<2446> */ ) {
              return $std_core_hnd.protect($std_core_types.Unit, function(___wildcard_x730__55 /* () */ , r /* (bool) -> <local<2440>|2447> parse-error<2446> */ ) {
                   
                  var x_1_10286 = ((loc).value);
                  if ($std_core_hnd._yielding()) {
                    return $std_core_hnd.yield_extend(function(save /* sslice/sslice */ ) {
                      return _mlift_parse_10177(loc, r, save);
                    });
                  }
                  else {
                    return _mlift_parse_10177(loc, r, x_1_10286);
                  }
                }, k);
            });
        }, $std_core_hnd.clause_tail1(function(pred /* (sslice/sslice) -> maybe<(2404, sslice/sslice)> */ ) {
           
          var x_2_10288 = ((loc).value);
          if ($std_core_hnd._yielding()) {
            return $std_core_hnd.yield_extend(function(inp /* sslice/sslice */ ) {
              return _mlift_parse_10179(loc, pred, inp);
            });
          }
          else {
            return _mlift_parse_10179(loc, pred, x_2_10288);
          }
        })), function(x_0_0 /* 2446 */ ) {
         
        var x_3_10290 = ((loc).value);
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(function(_y_x10128 /* sslice/sslice */ ) {
            return ParseOk(x_0_0, _y_x10128);
          });
        }
        else {
          return ParseOk(x_0_0, x_3_10290);
        }
      }, p);
    return $std_core_hnd.prompt_local_var(loc, res);
  }();
}
 
 
// monadic lift
export function _mlift_parse_eof_10181(x, wild__) /* forall<a,e> (x : a, wild_ : ()) -> <parse|e> a */  {
  return x;
}
 
 
// monadic lift
export function _mlift_parse_eof_10182(x) /* forall<a,e> (x : a) -> <parse|e> a */  {
   
  var x_0_10295 = $std_core_hnd._open_at0($std_core_hnd._evv_index(_tag_parse), eof);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(function(wild__ /* () */ ) {
      return x;
    });
  }
  else {
    return x;
  }
}
 
export function parse_eof(input, p) /* forall<a,e> (input : sslice/sslice, p : () -> <parse|e> a) -> e parse-error<a> */  {
  return parse(input, function() {
       
      var x_10299 = p();
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(function(x_0 /* 2475 */ ) {
          return _mlift_parse_eof_10182(x_0);
        });
      }
      else {
        return _mlift_parse_eof_10182(x_10299);
      }
    });
}
 
 
// monadic lift
export function _mlift_pnat_10183(_y_x10136) /* (list<char>) -> parse int */  {
   
  var _x_x1_10162 = $std_core_int.parse_int($std_core_string.listchar_fs_string(_y_x10136));
  return $std_core_hnd._open_none2(function(m /* maybe<int> */ , nothing /* int */ ) {
      return (m === null) ? nothing : m.value;
    }, _x_x1_10162, 0);
}
 
export function pnat() /* () -> parse int */  {
   
  var x_10301 = satisfy_fail("digit", function(slice /* sslice/sslice */ ) {
      var _x23 = next_while0(slice, $std_core_char.is_digit, $std_core_types.Nil);
      if (_x23.fst === null) {
        return $std_core_types.Nothing;
      }
      else {
        return $std_core_types.Just($std_core_types.Tuple2(_x23.fst, _x23.snd));
      }
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_pnat_10183);
  }
  else {
     
    var _x_x1_10162 = $std_core_int.parse_int($std_core_string.listchar_fs_string(x_10301));
    return $std_core_hnd._open_none2(function(m /* maybe<int> */ , nothing /* int */ ) {
        return (m === null) ? nothing : m.value;
      }, _x_x1_10162, 0);
  }
}
 
 
// monadic lift
export function _mlift_sign_10184(c_0) /* (c@0 : char) -> parse bool */  {
  return (c_0 === 0x002D);
}
 
export function sign() /* () -> parse bool */  {
   
  var x_10304 = _lp__bar__bar__rp_(function() {
      return satisfy_fail("+-", function(slice /* sslice/sslice */ ) {
          var _x23 = $std_core_sslice.next(slice);
          if (_x23 !== null) {
            if (((("+-")).indexOf(($std_core_string.char_fs_string(_x23.value.fst))) >= 0)){
              return $std_core_types.Just($std_core_types.Tuple2(_x23.value.fst, _x23.value.snd));
            }
          }
          return $std_core_types.Nothing;
        });
    }, function() {
      return 0x002B;
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_sign_10184);
  }
  else {
    return (x_10304 === 0x002D);
  }
}
 
 
// monadic lift
export function _mlift_pint_10185(neg, i) /* (neg : bool, i : int) -> parse int */  {
  return (neg) ? $std_core_types._int_negate(i) : i;
}
 
 
// monadic lift
export function _mlift_pint_10186(c_0) /* (c@0 : char) -> parse int */  {
   
  var neg = (c_0 === 0x002D);
   
  var x_10307 = pnat();
   
  function next_10308(i) /* (int) -> parse int */  {
    return (neg) ? $std_core_types._int_negate(i) : i;
  }
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(next_10308);
  }
  else {
    return next_10308(x_10307);
  }
}
 
export function pint() /* () -> parse int */  {
   
  var x_10311 = _lp__bar__bar__rp_(function() {
      return satisfy_fail("+-", function(slice /* sslice/sslice */ ) {
          var _x23 = $std_core_sslice.next(slice);
          if (_x23 !== null) {
            if (((("+-")).indexOf(($std_core_string.char_fs_string(_x23.value.fst))) >= 0)){
              return $std_core_types.Just($std_core_types.Tuple2(_x23.value.fst, _x23.value.snd));
            }
          }
          return $std_core_types.Nothing;
        });
    }, function() {
      return 0x002B;
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_pint_10186);
  }
  else {
     
    var neg = (x_10311 === 0x002D);
     
    var x_0_10314 = pnat();
    if ($std_core_hnd._yielding()) {
      return $std_core_hnd.yield_extend(function(i /* int */ ) {
        return (neg) ? $std_core_types._int_negate(i) : i;
      });
    }
    else {
      return (neg) ? $std_core_types._int_negate(x_0_10314) : x_0_10314;
    }
  }
}
 
export function pstring(s) /* (s : string) -> parse string */  {
  return satisfy_fail(s, function(slice /* sslice/sslice */ ) {
      var _x23 = next_match(slice, $std_core_string.list(s));
      if (_x23 !== null) {
        return $std_core_types.Just($std_core_types.Tuple2(s, _x23.value));
      }
      else {
        return $std_core_types.Nothing;
      }
    });
}
 
export function starts_with(s, p) /* forall<a> (s : string, p : () -> parse a) -> maybe<(a, sslice/sslice)> */  {
  var _x24 = parse($std_core_sslice.Sslice(s, 0, s.length), p);
  if (_x24._tag === 1) {
    return $std_core_types.Just($std_core_types.Tuple2(_x24.result, _x24.rest));
  }
  else {
    return $std_core_types.Nothing;
  }
}
 
export function white() /* () -> parse char */  {
  return satisfy_fail("", function(slice /* sslice/sslice */ ) {
      var _x25 = $std_core_sslice.next(slice);
      if (_x25 !== null) {
        if ($std_core_char.is_white(_x25.value.fst)){
          return $std_core_types.Just($std_core_types.Tuple2(_x25.value.fst, _x25.value.snd));
        }
      }
      return $std_core_types.Nothing;
    });
}
 
export function whitespace() /* () -> parse string */  {
   
  var x_10319 = satisfy_fail("", function(slice /* sslice/sslice */ ) {
      var _x26 = next_while0(slice, $std_core_char.is_white, $std_core_types.Nil);
      if (_x26.fst === null) {
        return $std_core_types.Nothing;
      }
      else {
        return $std_core_types.Just($std_core_types.Tuple2(_x26.fst, _x26.snd));
      }
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend($std_core_string.listchar_fs_string);
  }
  else {
    return $std_core_string.listchar_fs_string(x_10319);
  }
}
 
export function whitespace0() /* () -> parse string */  {
  return _lp__bar__bar__rp_(function() {
       
      var x_10321 = satisfy_fail("", function(slice /* sslice/sslice */ ) {
          var _x26 = next_while0(slice, $std_core_char.is_white, $std_core_types.Nil);
          if (_x26.fst === null) {
            return $std_core_types.Nothing;
          }
          else {
            return $std_core_types.Just($std_core_types.Tuple2(_x26.fst, _x26.snd));
          }
        });
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend($std_core_string.listchar_fs_string);
      }
      else {
        return $std_core_string.listchar_fs_string(x_10321);
      }
    }, function() {
      return "";
    });
}