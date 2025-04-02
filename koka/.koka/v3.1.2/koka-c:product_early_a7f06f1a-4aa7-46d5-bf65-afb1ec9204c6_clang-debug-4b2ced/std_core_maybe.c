// Koka generated module: std/core/maybe, koka version: 3.1.2, platform: 64-bit
#include "std_core_maybe.h"


// lift anonymous function
struct kk_std_core_maybe_map_fun30__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_maybe_map_fun30(kk_function_t _fself, kk_box_t _b_x1, kk_context_t* _ctx);
static kk_function_t kk_std_core_maybe_new_map_fun30(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_maybe_map_fun30, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_maybe_map_fun30(kk_function_t _fself, kk_box_t _b_x1, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_box_t _y_x10000_3 = _b_x1; /*142*/;
  kk_std_core_types__maybe _x_x31 = kk_std_core_types__new_Just(_y_x10000_3, _ctx); /*maybe<91>*/
  return kk_std_core_types__maybe_box(_x_x31, _ctx);
}

kk_std_core_types__maybe kk_std_core_maybe_map(kk_std_core_types__maybe m, kk_function_t f, kk_context_t* _ctx) { /* forall<a,b,e> (m : maybe<a>, f : (a) -> e b) -> e maybe<b> */ 
  if (kk_std_core_types__is_Nothing(m, _ctx)) {
    kk_function_drop(f, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
  {
    kk_box_t x = m._cons.Just.value;
    kk_box_t x_0_10010 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, x, _ctx), _ctx); /*142*/;
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_0_10010, _ctx);
      kk_box_t _x_x29 = kk_std_core_hnd_yield_extend(kk_std_core_maybe_new_map_fun30(_ctx), _ctx); /*3728*/
      return kk_std_core_types__maybe_unbox(_x_x29, KK_OWNED, _ctx);
    }
    {
      return kk_std_core_types__new_Just(x_0_10010, _ctx);
    }
  }
}
 
// Equality on `:maybe`

bool kk_std_core_maybe__lp__eq__eq__rp_(kk_std_core_types__maybe mb1, kk_std_core_types__maybe mb2, kk_function_t _implicit_fs__lp__eq__eq__rp_, kk_context_t* _ctx) { /* forall<a> (mb1 : maybe<a>, mb2 : maybe<a>, ?(==) : (a, a) -> bool) -> bool */ 
  if (kk_std_core_types__is_Just(mb1, _ctx)) {
    kk_box_t x = mb1._cons.Just.value;
    if (kk_std_core_types__is_Just(mb2, _ctx)) {
      kk_box_t y = mb2._cons.Just.value;
      return kk_function_call(bool, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs__lp__eq__eq__rp_, (_implicit_fs__lp__eq__eq__rp_, x, y, _ctx), _ctx);
    }
    {
      kk_function_drop(_implicit_fs__lp__eq__eq__rp_, _ctx);
      kk_box_drop(x, _ctx);
      return false;
    }
  }
  {
    kk_function_drop(_implicit_fs__lp__eq__eq__rp_, _ctx);
    if (kk_std_core_types__is_Nothing(mb2, _ctx)) {
      return true;
    }
    {
      kk_std_core_types__maybe_drop(mb2, _ctx);
      return false;
    }
  }
}
 
// Order on `:maybe` values

kk_std_core_types__order kk_std_core_maybe_cmp(kk_std_core_types__maybe mb1, kk_std_core_types__maybe mb2, kk_function_t _implicit_fs_cmp, kk_context_t* _ctx) { /* forall<a> (mb1 : maybe<a>, mb2 : maybe<a>, ?cmp : (a, a) -> order) -> order */ 
  if (kk_std_core_types__is_Just(mb1, _ctx)) {
    kk_box_t x = mb1._cons.Just.value;
    if (kk_std_core_types__is_Just(mb2, _ctx)) {
      kk_box_t y = mb2._cons.Just.value;
      return kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_cmp, (_implicit_fs_cmp, x, y, _ctx), _ctx);
    }
    {
      kk_function_drop(_implicit_fs_cmp, _ctx);
      kk_box_drop(x, _ctx);
      return kk_std_core_types__new_Gt(_ctx);
    }
  }
  {
    kk_function_drop(_implicit_fs_cmp, _ctx);
    if (kk_std_core_types__is_Nothing(mb2, _ctx)) {
      return kk_std_core_types__new_Eq(_ctx);
    }
    {
      kk_std_core_types__maybe_drop(mb2, _ctx);
      return kk_std_core_types__new_Lt(_ctx);
    }
  }
}
 
// Order two `:maybe` values in ascending order

kk_std_core_types__order2 kk_std_core_maybe_order2(kk_std_core_types__maybe mb1, kk_std_core_types__maybe mb2, kk_function_t _implicit_fs_order2, kk_context_t* _ctx) { /* forall<a> (mb1 : maybe<a>, mb2 : maybe<a>, ?order2 : (a, a) -> order2<a>) -> order2<maybe<a>> */ 
  if (kk_std_core_types__is_Just(mb1, _ctx)) {
    kk_box_t x = mb1._cons.Just.value;
    if (kk_std_core_types__is_Just(mb2, _ctx)) {
      kk_box_t y = mb2._cons.Just.value;
      kk_std_core_types__order2 _match_x27;
      kk_function_t _x_x34 = kk_function_dup(_implicit_fs_order2, _ctx); /*(433, 433) -> order2<433>*/
      _match_x27 = kk_function_call(kk_std_core_types__order2, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x34, (_x_x34, x, y, _ctx), _ctx); /*order2<433>*/
      if (kk_std_core_types__is_Eq2(_match_x27, _ctx)) {
        kk_box_t z = _match_x27._cons.Eq2.eq;
        kk_box_t _x_x35;
        kk_std_core_types__maybe _x_x36 = kk_std_core_types__new_Just(z, _ctx); /*maybe<91>*/
        _x_x35 = kk_std_core_types__maybe_box(_x_x36, _ctx); /*1451*/
        return kk_std_core_types__new_Eq2(_x_x35, _ctx);
      }
      if (kk_std_core_types__is_Lt2(_match_x27, _ctx)) {
        kk_box_t l = _match_x27._cons.Lt2.lt;
        kk_box_t g = _match_x27._cons.Lt2.gt;
        kk_box_t _x_x37;
        kk_std_core_types__maybe _x_x38 = kk_std_core_types__new_Just(l, _ctx); /*maybe<91>*/
        _x_x37 = kk_std_core_types__maybe_box(_x_x38, _ctx); /*1474*/
        kk_box_t _x_x39;
        kk_std_core_types__maybe _x_x40 = kk_std_core_types__new_Just(g, _ctx); /*maybe<91>*/
        _x_x39 = kk_std_core_types__maybe_box(_x_x40, _ctx); /*1474*/
        return kk_std_core_types__new_Lt2(_x_x37, _x_x39, _ctx);
      }
      {
        kk_box_t l_0 = _match_x27._cons.Gt2.lt;
        kk_box_t g_0 = _match_x27._cons.Gt2.gt;
        kk_box_t _x_x41;
        kk_std_core_types__maybe _x_x42 = kk_std_core_types__new_Just(l_0, _ctx); /*maybe<91>*/
        _x_x41 = kk_std_core_types__maybe_box(_x_x42, _ctx); /*1497*/
        kk_box_t _x_x43;
        kk_std_core_types__maybe _x_x44 = kk_std_core_types__new_Just(g_0, _ctx); /*maybe<91>*/
        _x_x43 = kk_std_core_types__maybe_box(_x_x44, _ctx); /*1497*/
        return kk_std_core_types__new_Gt2(_x_x41, _x_x43, _ctx);
      }
    }
    {
      kk_box_t _x_x45;
      kk_std_core_types__maybe _x_x46 = kk_std_core_types__new_Just(x, _ctx); /*maybe<91>*/
      _x_x45 = kk_std_core_types__maybe_box(_x_x46, _ctx); /*1516*/
      return kk_std_core_types__new_Gt2(kk_std_core_types__maybe_box(kk_std_core_types__new_Nothing(_ctx), _ctx), _x_x45, _ctx);
    }
  }
  {
    return kk_std_core_types__new_Lt2(kk_std_core_types__maybe_box(kk_std_core_types__new_Nothing(_ctx), _ctx), kk_std_core_types__maybe_box(mb2, _ctx), _ctx);
  }
}
 
// Show a `:maybe` type


// lift anonymous function
struct kk_std_core_maybe_show_fun53__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_maybe_show_fun53(kk_function_t _fself, kk_box_t _b_x23, kk_context_t* _ctx);
static kk_function_t kk_std_core_maybe_new_show_fun53(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_maybe_show_fun53, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_maybe_show_fun53(kk_function_t _fself, kk_box_t _b_x23, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _y_x10006_25 = kk_string_unbox(_b_x23); /*string*/;
  kk_string_t _x_x54;
  kk_string_t _x_x55;
  kk_define_string_literal(, _s_x56, 5, "Just(", _ctx)
  _x_x55 = kk_string_dup(_s_x56, _ctx); /*string*/
  kk_string_t _x_x57;
  kk_string_t _x_x58;
  kk_define_string_literal(, _s_x59, 1, ")", _ctx)
  _x_x58 = kk_string_dup(_s_x59, _ctx); /*string*/
  _x_x57 = kk_std_core_types__lp__plus__plus__rp_(_y_x10006_25, _x_x58, _ctx); /*string*/
  _x_x54 = kk_std_core_types__lp__plus__plus__rp_(_x_x55, _x_x57, _ctx); /*string*/
  return kk_string_box(_x_x54);
}

kk_string_t kk_std_core_maybe_show(kk_std_core_types__maybe mb, kk_function_t _implicit_fs_show, kk_context_t* _ctx) { /* forall<a,e> (mb : maybe<a>, ?show : (a) -> e string) -> e string */ 
  if (kk_std_core_types__is_Just(mb, _ctx)) {
    kk_box_t x = mb._cons.Just.value;
    kk_string_t x_0_10014 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_show, (_implicit_fs_show, x, _ctx), _ctx); /*string*/;
    if (kk_yielding(kk_context())) {
      kk_string_drop(x_0_10014, _ctx);
      kk_box_t _x_x52 = kk_std_core_hnd_yield_extend(kk_std_core_maybe_new_show_fun53(_ctx), _ctx); /*3728*/
      return kk_string_unbox(_x_x52);
    }
    {
      kk_string_t _x_x60;
      kk_define_string_literal(, _s_x61, 5, "Just(", _ctx)
      _x_x60 = kk_string_dup(_s_x61, _ctx); /*string*/
      kk_string_t _x_x62;
      kk_string_t _x_x63;
      kk_define_string_literal(, _s_x64, 1, ")", _ctx)
      _x_x63 = kk_string_dup(_s_x64, _ctx); /*string*/
      _x_x62 = kk_std_core_types__lp__plus__plus__rp_(x_0_10014, _x_x63, _ctx); /*string*/
      return kk_std_core_types__lp__plus__plus__rp_(_x_x60, _x_x62, _ctx);
    }
  }
  {
    kk_function_drop(_implicit_fs_show, _ctx);
    kk_define_string_literal(, _s_x65, 7, "Nothing", _ctx)
    return kk_string_dup(_s_x65, _ctx);
  }
}

// initialization
void kk_std_core_maybe__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_hnd__init(_ctx);
  kk_std_core_exn__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_maybe__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_exn__done(_ctx);
  kk_std_core_hnd__done(_ctx);
  kk_std_core_types__done(_ctx);
}
