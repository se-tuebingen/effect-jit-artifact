// Koka generated module: std/core/order, koka version: 3.1.2, platform: 64-bit
#include "std_core_order.h"
 
// Given a comparison function, we can order 2 elements.

kk_std_core_types__order2 kk_std_core_order_order2(kk_box_t x, kk_box_t y, kk_function_t cmp, kk_context_t* _ctx) { /* forall<a> (x : a, y : a, cmp : (a, a) -> order) -> order2<a> */ 
  kk_std_core_types__order _match_x18;
  kk_function_t _x_x21 = kk_function_dup(cmp, _ctx); /*(98, 98) -> order*/
  kk_box_t _x_x19 = kk_box_dup(x, _ctx); /*98*/
  kk_box_t _x_x20 = kk_box_dup(y, _ctx); /*98*/
  _match_x18 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x21, (_x_x21, _x_x19, _x_x20, _ctx), _ctx); /*order*/
  if (kk_std_core_types__is_Eq(_match_x18, _ctx)) {
    kk_box_drop(y, _ctx);
    return kk_std_core_types__new_Eq2(x, _ctx);
  }
  if (kk_std_core_types__is_Lt(_match_x18, _ctx)) {
    return kk_std_core_types__new_Lt2(x, y, _ctx);
  }
  {
    return kk_std_core_types__new_Gt2(y, x, _ctx);
  }
}

bool kk_std_core_order__lp__excl__eq__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx) { /* (x : order, y : order) -> bool */ 
  kk_integer_t _brw_x16;
  if (kk_std_core_types__is_Lt(x, _ctx)) {
    _brw_x16 = kk_integer_from_small(-1); /*int*/
    goto _match_x22;
  }
  if (kk_std_core_types__is_Eq(x, _ctx)) {
    _brw_x16 = kk_integer_from_small(0); /*int*/
    goto _match_x22;
  }
  {
    _brw_x16 = kk_integer_from_small(1); /*int*/
  }
  _match_x22: ;
  kk_integer_t _brw_x15;
  if (kk_std_core_types__is_Lt(y, _ctx)) {
    _brw_x15 = kk_integer_from_small(-1); /*int*/
    goto _match_x23;
  }
  if (kk_std_core_types__is_Eq(y, _ctx)) {
    _brw_x15 = kk_integer_from_small(0); /*int*/
    goto _match_x23;
  }
  {
    _brw_x15 = kk_integer_from_small(1); /*int*/
  }
  _match_x23: ;
  bool _brw_x17 = kk_integer_neq_borrow(_brw_x16,_brw_x15,kk_context()); /*bool*/;
  kk_integer_drop(_brw_x16, _ctx);
  kk_integer_drop(_brw_x15, _ctx);
  return _brw_x17;
}

bool kk_std_core_order__lp__lt__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx) { /* (x : order, y : order) -> bool */ 
  kk_integer_t _brw_x13;
  if (kk_std_core_types__is_Lt(x, _ctx)) {
    _brw_x13 = kk_integer_from_small(-1); /*int*/
    goto _match_x24;
  }
  if (kk_std_core_types__is_Eq(x, _ctx)) {
    _brw_x13 = kk_integer_from_small(0); /*int*/
    goto _match_x24;
  }
  {
    _brw_x13 = kk_integer_from_small(1); /*int*/
  }
  _match_x24: ;
  kk_integer_t _brw_x12;
  if (kk_std_core_types__is_Lt(y, _ctx)) {
    _brw_x12 = kk_integer_from_small(-1); /*int*/
    goto _match_x25;
  }
  if (kk_std_core_types__is_Eq(y, _ctx)) {
    _brw_x12 = kk_integer_from_small(0); /*int*/
    goto _match_x25;
  }
  {
    _brw_x12 = kk_integer_from_small(1); /*int*/
  }
  _match_x25: ;
  bool _brw_x14 = kk_integer_lt_borrow(_brw_x13,_brw_x12,kk_context()); /*bool*/;
  kk_integer_drop(_brw_x13, _ctx);
  kk_integer_drop(_brw_x12, _ctx);
  return _brw_x14;
}

bool kk_std_core_order__lp__lt__eq__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx) { /* (x : order, y : order) -> bool */ 
  kk_integer_t _brw_x10;
  if (kk_std_core_types__is_Lt(x, _ctx)) {
    _brw_x10 = kk_integer_from_small(-1); /*int*/
    goto _match_x26;
  }
  if (kk_std_core_types__is_Eq(x, _ctx)) {
    _brw_x10 = kk_integer_from_small(0); /*int*/
    goto _match_x26;
  }
  {
    _brw_x10 = kk_integer_from_small(1); /*int*/
  }
  _match_x26: ;
  kk_integer_t _brw_x9;
  if (kk_std_core_types__is_Lt(y, _ctx)) {
    _brw_x9 = kk_integer_from_small(-1); /*int*/
    goto _match_x27;
  }
  if (kk_std_core_types__is_Eq(y, _ctx)) {
    _brw_x9 = kk_integer_from_small(0); /*int*/
    goto _match_x27;
  }
  {
    _brw_x9 = kk_integer_from_small(1); /*int*/
  }
  _match_x27: ;
  bool _brw_x11 = kk_integer_lte_borrow(_brw_x10,_brw_x9,kk_context()); /*bool*/;
  kk_integer_drop(_brw_x10, _ctx);
  kk_integer_drop(_brw_x9, _ctx);
  return _brw_x11;
}

bool kk_std_core_order__lp__eq__eq__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx) { /* (x : order, y : order) -> bool */ 
  kk_integer_t _brw_x7;
  if (kk_std_core_types__is_Lt(x, _ctx)) {
    _brw_x7 = kk_integer_from_small(-1); /*int*/
    goto _match_x28;
  }
  if (kk_std_core_types__is_Eq(x, _ctx)) {
    _brw_x7 = kk_integer_from_small(0); /*int*/
    goto _match_x28;
  }
  {
    _brw_x7 = kk_integer_from_small(1); /*int*/
  }
  _match_x28: ;
  kk_integer_t _brw_x6;
  if (kk_std_core_types__is_Lt(y, _ctx)) {
    _brw_x6 = kk_integer_from_small(-1); /*int*/
    goto _match_x29;
  }
  if (kk_std_core_types__is_Eq(y, _ctx)) {
    _brw_x6 = kk_integer_from_small(0); /*int*/
    goto _match_x29;
  }
  {
    _brw_x6 = kk_integer_from_small(1); /*int*/
  }
  _match_x29: ;
  bool _brw_x8 = kk_integer_eq_borrow(_brw_x7,_brw_x6,kk_context()); /*bool*/;
  kk_integer_drop(_brw_x7, _ctx);
  kk_integer_drop(_brw_x6, _ctx);
  return _brw_x8;
}

bool kk_std_core_order__lp__gt__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx) { /* (x : order, y : order) -> bool */ 
  kk_integer_t _brw_x4;
  if (kk_std_core_types__is_Lt(x, _ctx)) {
    _brw_x4 = kk_integer_from_small(-1); /*int*/
    goto _match_x30;
  }
  if (kk_std_core_types__is_Eq(x, _ctx)) {
    _brw_x4 = kk_integer_from_small(0); /*int*/
    goto _match_x30;
  }
  {
    _brw_x4 = kk_integer_from_small(1); /*int*/
  }
  _match_x30: ;
  kk_integer_t _brw_x3;
  if (kk_std_core_types__is_Lt(y, _ctx)) {
    _brw_x3 = kk_integer_from_small(-1); /*int*/
    goto _match_x31;
  }
  if (kk_std_core_types__is_Eq(y, _ctx)) {
    _brw_x3 = kk_integer_from_small(0); /*int*/
    goto _match_x31;
  }
  {
    _brw_x3 = kk_integer_from_small(1); /*int*/
  }
  _match_x31: ;
  bool _brw_x5 = kk_integer_gt_borrow(_brw_x4,_brw_x3,kk_context()); /*bool*/;
  kk_integer_drop(_brw_x4, _ctx);
  kk_integer_drop(_brw_x3, _ctx);
  return _brw_x5;
}

bool kk_std_core_order__lp__gt__eq__rp_(kk_std_core_types__order x, kk_std_core_types__order y, kk_context_t* _ctx) { /* (x : order, y : order) -> bool */ 
  kk_integer_t _brw_x1;
  if (kk_std_core_types__is_Lt(x, _ctx)) {
    _brw_x1 = kk_integer_from_small(-1); /*int*/
    goto _match_x32;
  }
  if (kk_std_core_types__is_Eq(x, _ctx)) {
    _brw_x1 = kk_integer_from_small(0); /*int*/
    goto _match_x32;
  }
  {
    _brw_x1 = kk_integer_from_small(1); /*int*/
  }
  _match_x32: ;
  kk_integer_t _brw_x0;
  if (kk_std_core_types__is_Lt(y, _ctx)) {
    _brw_x0 = kk_integer_from_small(-1); /*int*/
    goto _match_x33;
  }
  if (kk_std_core_types__is_Eq(y, _ctx)) {
    _brw_x0 = kk_integer_from_small(0); /*int*/
    goto _match_x33;
  }
  {
    _brw_x0 = kk_integer_from_small(1); /*int*/
  }
  _match_x33: ;
  bool _brw_x2 = kk_integer_gte_borrow(_brw_x1,_brw_x0,kk_context()); /*bool*/;
  kk_integer_drop(_brw_x1, _ctx);
  kk_integer_drop(_brw_x0, _ctx);
  return _brw_x2;
}

// initialization
void kk_std_core_order__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_int__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_order__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_int__done(_ctx);
  kk_std_core_types__done(_ctx);
}
