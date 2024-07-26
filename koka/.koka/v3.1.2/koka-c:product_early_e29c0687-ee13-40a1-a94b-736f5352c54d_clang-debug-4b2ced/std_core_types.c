// Koka generated module: std/core/types, koka version: 3.1.2, platform: 64-bit
#include "std_core_types.h"
/*---------------------------------------------------------------------------
  Copyright 2020-2024, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/

kk_decl_noinline kk_std_core_types__cctx kk_cctx_compose_shared( kk_std_core_types__cctx acc1, kk_std_core_types__cctx acc2, kk_context_t* ctx  ) {
  kk_assert_internal(!kk_cctx_is_empty(acc2));
  kk_assert_internal(!kk_block_is_unique(kk_ptr_unbox(acc2.res,ctx)));
  kk_box_t* holeptr = NULL;
  kk_box_t res = kk_cctx_copy(acc2.res,kk_field_addr_ptr(acc2.holeptr,ctx),&holeptr,ctx);
  return kk_cctx_extend(acc1,res,kk_field_addr_create(holeptr,ctx),ctx);
}

kk_std_core_types__box kk_std_core_types_box_fs__copy(kk_std_core_types__box _this, kk_std_core_types__optional unbox, kk_context_t* _ctx) { /* forall<a> (box<a>, unbox : ? a) -> box<a> */ 
  kk_box_t _x_x2;
  if (kk_std_core_types__is_Optional(unbox, _ctx)) {
    kk_box_t _uniq_unbox_485 = unbox._cons._Optional.value;
    kk_box_dup(_uniq_unbox_485, _ctx);
    kk_std_core_types__optional_drop(unbox, _ctx);
    kk_std_core_types__box_drop(_this, _ctx);
    _x_x2 = _uniq_unbox_485; /*497*/
  }
  else {
    kk_std_core_types__optional_drop(unbox, _ctx);
    {
      kk_box_t _x = _this.unbox;
      _x_x2 = _x; /*497*/
    }
  }
  return kk_std_core_types__new_Box(_x_x2, _ctx);
}

kk_std_core_types__tuple2 kk_std_core_types_tuple2_fs__copy(kk_std_core_types__tuple2 _this, kk_std_core_types__optional fst, kk_std_core_types__optional snd, kk_context_t* _ctx) { /* forall<a,b> ((a, b), fst : ? a, snd : ? b) -> (a, b) */ 
  kk_box_t _x_x4;
  if (kk_std_core_types__is_Optional(fst, _ctx)) {
    kk_box_t _uniq_fst_795 = fst._cons._Optional.value;
    kk_box_dup(_uniq_fst_795, _ctx);
    kk_std_core_types__optional_drop(fst, _ctx);
    _x_x4 = _uniq_fst_795; /*826*/
  }
  else {
    kk_std_core_types__optional_drop(fst, _ctx);
    {
      kk_box_t _x = _this.fst;
      kk_box_dup(_x, _ctx);
      _x_x4 = _x; /*826*/
    }
  }
  kk_box_t _x_x5;
  if (kk_std_core_types__is_Optional(snd, _ctx)) {
    kk_box_t _uniq_snd_808 = snd._cons._Optional.value;
    kk_box_dup(_uniq_snd_808, _ctx);
    kk_std_core_types__optional_drop(snd, _ctx);
    kk_std_core_types__tuple2_drop(_this, _ctx);
    _x_x5 = _uniq_snd_808; /*827*/
  }
  else {
    kk_std_core_types__optional_drop(snd, _ctx);
    {
      kk_box_t _x_0 = _this.snd;
      kk_box_dup(_x_0, _ctx);
      kk_std_core_types__tuple2_drop(_this, _ctx);
      _x_x5 = _x_0; /*827*/
    }
  }
  return kk_std_core_types__new_Tuple2(_x_x4, _x_x5, _ctx);
}

kk_std_core_types__tuple3 kk_std_core_types_tuple3_fs__copy(kk_std_core_types__tuple3 _this, kk_std_core_types__optional fst, kk_std_core_types__optional snd, kk_std_core_types__optional thd, kk_context_t* _ctx) { /* forall<a,b,c> ((a, b, c), fst : ? a, snd : ? b, thd : ? c) -> (a, b, c) */ 
  kk_box_t _x_x6;
  if (kk_std_core_types__is_Optional(fst, _ctx)) {
    kk_box_t _uniq_fst_956 = fst._cons._Optional.value;
    kk_box_dup(_uniq_fst_956, _ctx);
    kk_std_core_types__optional_drop(fst, _ctx);
    _x_x6 = _uniq_fst_956; /*1019*/
  }
  else {
    kk_std_core_types__optional_drop(fst, _ctx);
    {
      kk_box_t _x = _this.fst;
      kk_box_dup(_x, _ctx);
      _x_x6 = _x; /*1019*/
    }
  }
  kk_box_t _x_x7;
  if (kk_std_core_types__is_Optional(snd, _ctx)) {
    kk_box_t _uniq_snd_979 = snd._cons._Optional.value;
    kk_box_dup(_uniq_snd_979, _ctx);
    kk_std_core_types__optional_drop(snd, _ctx);
    _x_x7 = _uniq_snd_979; /*1020*/
  }
  else {
    kk_std_core_types__optional_drop(snd, _ctx);
    {
      kk_box_t _x_0 = _this.snd;
      kk_box_dup(_x_0, _ctx);
      _x_x7 = _x_0; /*1020*/
    }
  }
  kk_box_t _x_x8;
  if (kk_std_core_types__is_Optional(thd, _ctx)) {
    kk_box_t _uniq_thd_995 = thd._cons._Optional.value;
    kk_box_dup(_uniq_thd_995, _ctx);
    kk_std_core_types__optional_drop(thd, _ctx);
    kk_std_core_types__tuple3_drop(_this, _ctx);
    _x_x8 = _uniq_thd_995; /*1021*/
  }
  else {
    kk_std_core_types__optional_drop(thd, _ctx);
    {
      kk_box_t _x_1 = _this.thd;
      kk_box_dup(_x_1, _ctx);
      kk_std_core_types__tuple3_drop(_this, _ctx);
      _x_x8 = _x_1; /*1021*/
    }
  }
  return kk_std_core_types__new_Tuple3(_x_x6, _x_x7, _x_x8, _ctx);
}

kk_std_core_types__tuple4 kk_std_core_types_tuple4_fs__copy(kk_std_core_types__tuple4 _this, kk_std_core_types__optional fst, kk_std_core_types__optional snd, kk_std_core_types__optional thd, kk_std_core_types__optional field4, kk_context_t* _ctx) { /* forall<a,b,c,d> ((a, b, c, d), fst : ? a, snd : ? b, thd : ? c, field4 : ? d) -> (a, b, c, d) */ 
  kk_box_t _x_x13;
  if (kk_std_core_types__is_Optional(fst, _ctx)) {
    kk_box_t _uniq_fst_1228 = fst._cons._Optional.value;
    kk_box_dup(_uniq_fst_1228, _ctx);
    kk_std_core_types__optional_drop(fst, _ctx);
    _x_x13 = _uniq_fst_1228; /*1339*/
  }
  else {
    kk_std_core_types__optional_drop(fst, _ctx);
    {
      struct kk_std_core_types_Tuple4* _con_x14 = kk_std_core_types__as_Tuple4(_this, _ctx);
      kk_box_t _x = _con_x14->fst;
      kk_box_dup(_x, _ctx);
      _x_x13 = _x; /*1339*/
    }
  }
  kk_box_t _x_x15;
  if (kk_std_core_types__is_Optional(snd, _ctx)) {
    kk_box_t _uniq_snd_1261 = snd._cons._Optional.value;
    kk_box_dup(_uniq_snd_1261, _ctx);
    kk_std_core_types__optional_drop(snd, _ctx);
    _x_x15 = _uniq_snd_1261; /*1340*/
  }
  else {
    kk_std_core_types__optional_drop(snd, _ctx);
    {
      struct kk_std_core_types_Tuple4* _con_x16 = kk_std_core_types__as_Tuple4(_this, _ctx);
      kk_box_t _x_0 = _con_x16->snd;
      kk_box_dup(_x_0, _ctx);
      _x_x15 = _x_0; /*1340*/
    }
  }
  kk_box_t _x_x17;
  if (kk_std_core_types__is_Optional(thd, _ctx)) {
    kk_box_t _uniq_thd_1290 = thd._cons._Optional.value;
    kk_box_dup(_uniq_thd_1290, _ctx);
    kk_std_core_types__optional_drop(thd, _ctx);
    _x_x17 = _uniq_thd_1290; /*1341*/
  }
  else {
    kk_std_core_types__optional_drop(thd, _ctx);
    {
      struct kk_std_core_types_Tuple4* _con_x18 = kk_std_core_types__as_Tuple4(_this, _ctx);
      kk_box_t _x_1 = _con_x18->thd;
      kk_box_dup(_x_1, _ctx);
      _x_x17 = _x_1; /*1341*/
    }
  }
  kk_box_t _x_x19;
  if (kk_std_core_types__is_Optional(field4, _ctx)) {
    kk_box_t _uniq_field4_1309 = field4._cons._Optional.value;
    kk_box_dup(_uniq_field4_1309, _ctx);
    kk_std_core_types__optional_drop(field4, _ctx);
    kk_datatype_ptr_dropn(_this, (KK_I32(4)), _ctx);
    _x_x19 = _uniq_field4_1309; /*1342*/
  }
  else {
    kk_std_core_types__optional_drop(field4, _ctx);
    {
      struct kk_std_core_types_Tuple4* _con_x20 = kk_std_core_types__as_Tuple4(_this, _ctx);
      kk_box_t _pat_0_3 = _con_x20->fst;
      kk_box_t _pat_1_4 = _con_x20->snd;
      kk_box_t _pat_2_3 = _con_x20->thd;
      kk_box_t _x_2 = _con_x20->field4;
      if kk_likely(kk_datatype_ptr_is_unique(_this, _ctx)) {
        kk_box_drop(_pat_2_3, _ctx);
        kk_box_drop(_pat_1_4, _ctx);
        kk_box_drop(_pat_0_3, _ctx);
        kk_datatype_ptr_free(_this, _ctx);
      }
      else {
        kk_box_dup(_x_2, _ctx);
        kk_datatype_ptr_decref(_this, _ctx);
      }
      _x_x19 = _x_2; /*1342*/
    }
  }
  return kk_std_core_types__new_Tuple4(kk_reuse_null, 0, _x_x13, _x_x15, _x_x17, _x_x19, _ctx);
}

kk_std_core_types__tuple5 kk_std_core_types_tuple5_fs__copy(kk_std_core_types__tuple5 _this, kk_std_core_types__optional fst, kk_std_core_types__optional snd, kk_std_core_types__optional thd, kk_std_core_types__optional field4, kk_std_core_types__optional field5, kk_context_t* _ctx) { /* forall<a,b,c,d,a1> ((a, b, c, d, a1), fst : ? a, snd : ? b, thd : ? c, field4 : ? d, field5 : ? a1) -> (a, b, c, d, a1) */ 
  kk_box_t _x_x26;
  if (kk_std_core_types__is_Optional(fst, _ctx)) {
    kk_box_t _uniq_fst_1645 = fst._cons._Optional.value;
    kk_box_dup(_uniq_fst_1645, _ctx);
    kk_std_core_types__optional_drop(fst, _ctx);
    _x_x26 = _uniq_fst_1645; /*1824*/
  }
  else {
    kk_std_core_types__optional_drop(fst, _ctx);
    {
      struct kk_std_core_types_Tuple5* _con_x27 = kk_std_core_types__as_Tuple5(_this, _ctx);
      kk_box_t _x = _con_x27->fst;
      kk_box_dup(_x, _ctx);
      _x_x26 = _x; /*1824*/
    }
  }
  kk_box_t _x_x28;
  if (kk_std_core_types__is_Optional(snd, _ctx)) {
    kk_box_t _uniq_snd_1690 = snd._cons._Optional.value;
    kk_box_dup(_uniq_snd_1690, _ctx);
    kk_std_core_types__optional_drop(snd, _ctx);
    _x_x28 = _uniq_snd_1690; /*1825*/
  }
  else {
    kk_std_core_types__optional_drop(snd, _ctx);
    {
      struct kk_std_core_types_Tuple5* _con_x29 = kk_std_core_types__as_Tuple5(_this, _ctx);
      kk_box_t _x_0 = _con_x29->snd;
      kk_box_dup(_x_0, _ctx);
      _x_x28 = _x_0; /*1825*/
    }
  }
  kk_box_t _x_x30;
  if (kk_std_core_types__is_Optional(thd, _ctx)) {
    kk_box_t _uniq_thd_1731 = thd._cons._Optional.value;
    kk_box_dup(_uniq_thd_1731, _ctx);
    kk_std_core_types__optional_drop(thd, _ctx);
    _x_x30 = _uniq_thd_1731; /*1826*/
  }
  else {
    kk_std_core_types__optional_drop(thd, _ctx);
    {
      struct kk_std_core_types_Tuple5* _con_x31 = kk_std_core_types__as_Tuple5(_this, _ctx);
      kk_box_t _x_1 = _con_x31->thd;
      kk_box_dup(_x_1, _ctx);
      _x_x30 = _x_1; /*1826*/
    }
  }
  kk_box_t _x_x32;
  if (kk_std_core_types__is_Optional(field4, _ctx)) {
    kk_box_t _uniq_field4_1766 = field4._cons._Optional.value;
    kk_box_dup(_uniq_field4_1766, _ctx);
    kk_std_core_types__optional_drop(field4, _ctx);
    _x_x32 = _uniq_field4_1766; /*1827*/
  }
  else {
    kk_std_core_types__optional_drop(field4, _ctx);
    {
      struct kk_std_core_types_Tuple5* _con_x33 = kk_std_core_types__as_Tuple5(_this, _ctx);
      kk_box_t _x_2 = _con_x33->field4;
      kk_box_dup(_x_2, _ctx);
      _x_x32 = _x_2; /*1827*/
    }
  }
  kk_box_t _x_x34;
  if (kk_std_core_types__is_Optional(field5, _ctx)) {
    kk_box_t _uniq_field5_1788 = field5._cons._Optional.value;
    kk_box_dup(_uniq_field5_1788, _ctx);
    kk_std_core_types__optional_drop(field5, _ctx);
    kk_datatype_ptr_dropn(_this, (KK_I32(5)), _ctx);
    _x_x34 = _uniq_field5_1788; /*1828*/
  }
  else {
    kk_std_core_types__optional_drop(field5, _ctx);
    {
      struct kk_std_core_types_Tuple5* _con_x35 = kk_std_core_types__as_Tuple5(_this, _ctx);
      kk_box_t _pat_0_4 = _con_x35->fst;
      kk_box_t _pat_1_5 = _con_x35->snd;
      kk_box_t _pat_2_4 = _con_x35->thd;
      kk_box_t _pat_3_4 = _con_x35->field4;
      kk_box_t _x_3 = _con_x35->field5;
      if kk_likely(kk_datatype_ptr_is_unique(_this, _ctx)) {
        kk_box_drop(_pat_3_4, _ctx);
        kk_box_drop(_pat_2_4, _ctx);
        kk_box_drop(_pat_1_5, _ctx);
        kk_box_drop(_pat_0_4, _ctx);
        kk_datatype_ptr_free(_this, _ctx);
      }
      else {
        kk_box_dup(_x_3, _ctx);
        kk_datatype_ptr_decref(_this, _ctx);
      }
      _x_x34 = _x_3; /*1828*/
    }
  }
  return kk_std_core_types__new_Tuple5(kk_reuse_null, 0, _x_x26, _x_x28, _x_x30, _x_x32, _x_x34, _ctx);
}
 
// _Internal_. Internal function name for field addresses.

kk_field_addr_t kk_std_core_types__field_addr_of(kk_box_t x, kk_string_t conname, kk_string_t fieldname, kk_context_t* _ctx) { /* forall<a> (x : a, conname : string, fieldname : string) -> @field-addr<a> */ 
  return kk_field_addr_null();
}
 
// Convert an integer to an `:ssize_t`. The number is _clamped_ to the maximal or minimum `:ssize_t`
// value if it is outside the range of an `:ssize_t`.
// Needed for evidence indices in `module std/core/hnd`

kk_ssize_t kk_std_core_types__make_ssize__t(kk_integer_t i, kk_context_t* _ctx) { /* (i : int) -> ssize_t */ 
  return kk_integer_clamp_ssize_t(i,kk_context());
}

kk_reuse_t kk_std_core_types__no_reuse(kk_context_t* _ctx) { /* () -> @reuse */ 
  return NULL;
}
 
// _Internal_: generated by type inference and later refined into one of the `open` variants in `std/core/hnd`.

kk_box_t kk_std_core_types__open(kk_box_t x, kk_context_t* _ctx) { /* forall<e,e1,a,b> (x : a) -> e1 b */ 
  return x;
}
 
// Append two strings

kk_string_t kk_std_core_types__lp__plus__plus__rp_(kk_string_t x, kk_string_t y, kk_context_t* _ctx) { /* (x : string, y : string) -> string */ 
  return kk_string_cat(x,y,kk_context());
}
 
// Prevent inlining an expression by passing it to `keep` (which is a non-inlineable identity function)

kk_box_t kk_std_core_types_keep(kk_box_t x, kk_context_t* _ctx) { /* forall<a> (x : a) -> a */ 
  return x;
}
 
// If a heap effect is unobservable, the heap effect can be erased by using the `run` fun.
// See also: _State in Haskell, by Simon Peyton Jones and John Launchbury_.

kk_box_t kk_std_core_types_run(kk_function_t action, kk_context_t* _ctx) { /* forall<e,a> (action : forall<h> () -> <alloc<h>,read<h>,write<h>|e> a) -> e a */ 
  return (kk_function_call(kk_box_t,(kk_function_t,kk_context_t*),action,(action,kk_context()),kk_context()));
}

// initialization
void kk_std_core_types__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_types__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
}
