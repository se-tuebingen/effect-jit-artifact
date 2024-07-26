// Koka generated module: std/core/delayed, koka version: 3.1.2, platform: 64-bit
#include "std_core_delayed.h"

kk_std_core_delayed__delayed kk_std_core_delayed_delayed_fs__copy(kk_std_core_delayed__delayed _this, kk_std_core_types__optional dref, kk_context_t* _ctx) { /* forall<e,a> (delayed<e,a>, dref : ? (ref<global,either<() -> e a,a>>)) -> delayed<e,a> */ 
  kk_ref_t _x_x34;
  if (kk_std_core_types__is_Optional(dref, _ctx)) {
    kk_box_t _box_x0 = dref._cons._Optional.value;
    kk_ref_t _uniq_dref_88 = kk_ref_unbox(_box_x0, _ctx);
    kk_ref_dup(_uniq_dref_88, _ctx);
    kk_std_core_types__optional_drop(dref, _ctx);
    kk_std_core_delayed__delayed_drop(_this, _ctx);
    _x_x34 = _uniq_dref_88; /*ref<global,either<() -> 105 106,106>>*/
  }
  else {
    kk_std_core_types__optional_drop(dref, _ctx);
    {
      kk_ref_t _x = _this.dref;
      _x_x34 = _x; /*ref<global,either<() -> 105 106,106>>*/
    }
  }
  return kk_std_core_delayed__new_XDelay(_x_x34, _ctx);
}
 
// Force a delayed value; the value is computed only on the first
// call to `force` and cached afterwards.


// lift anonymous function
struct kk_std_core_delayed_force_fun43__t {
  struct kk_function_s _base;
  kk_std_core_delayed__delayed delayed;
};
static kk_box_t kk_std_core_delayed_force_fun43(kk_function_t _fself, kk_box_t x_0_0, kk_context_t* _ctx);
static kk_function_t kk_std_core_delayed_new_force_fun43(kk_std_core_delayed__delayed delayed, kk_context_t* _ctx) {
  struct kk_std_core_delayed_force_fun43__t* _self = kk_function_alloc_as(struct kk_std_core_delayed_force_fun43__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_delayed_force_fun43, kk_context());
  _self->delayed = delayed;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_delayed_force_fun43(kk_function_t _fself, kk_box_t x_0_0, kk_context_t* _ctx) {
  struct kk_std_core_delayed_force_fun43__t* _self = kk_function_as(struct kk_std_core_delayed_force_fun43__t*, _fself, _ctx);
  kk_std_core_delayed__delayed delayed = _self->delayed; /* delayed/delayed<271,270> */
  kk_drop_match(_self, {kk_std_core_delayed__delayed_dup(delayed, _ctx);}, {}, _ctx)
  kk_unit_t __ = kk_Unit;
  kk_ref_t _brw_x31;
  {
    kk_ref_t _x_0 = delayed.dref;
    _brw_x31 = _x_0; /*ref<global,either<() -> 271 270,270>>*/
  }
  kk_unit_t _brw_x32 = kk_Unit;
  kk_box_t _x_x44;
  kk_std_core_types__either _x_x45;
  kk_box_t _x_x46 = kk_box_dup(x_0_0, _ctx); /*270*/
  _x_x45 = kk_std_core_types__new_Right(_x_x46, _ctx); /*either<1312,1313>*/
  _x_x44 = kk_std_core_types__either_box(_x_x45, _ctx); /*1456*/
  kk_ref_set_borrow(_brw_x31,_x_x44,kk_context());
  kk_ref_drop(_brw_x31, _ctx);
  _brw_x32;
  return x_0_0;
}

kk_box_t kk_std_core_delayed_force(kk_std_core_delayed__delayed delayed, kk_context_t* _ctx) { /* forall<a,e> (delayed : delayed<e,a>) -> e a */ 
  kk_std_core_types__either _match_x29;
  kk_box_t _x_x40;
  kk_ref_t _x_x41;
  {
    kk_ref_t _x = delayed.dref;
    kk_ref_dup(_x, _ctx);
    _x_x41 = _x; /*ref<global,either<() -> 271 270,270>>*/
  }
  _x_x40 = kk_ref_get(_x_x41,kk_context()); /*1472*/
  _match_x29 = kk_std_core_types__either_unbox(_x_x40, KK_OWNED, _ctx); /*either<() -> 271 270,270>*/
  if (kk_std_core_types__is_Right(_match_x29, _ctx)) {
    kk_box_t x = _match_x29._cons.Right.right;
    kk_std_core_delayed__delayed_drop(delayed, _ctx);
    return x;
  }
  {
    kk_box_t _fun_unbox_x12 = _match_x29._cons.Left.left;
    kk_box_t x_0_10011;
    kk_function_t _x_x42 = kk_function_unbox(_fun_unbox_x12, _ctx); /*() -> 271 13*/
    x_0_10011 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), _x_x42, (_x_x42, _ctx), _ctx); /*270*/
    kk_function_t next_10012 = kk_std_core_delayed_new_force_fun43(delayed, _ctx); /*(270) -> <st<global>,div|271> 270*/;
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_0_10011, _ctx);
      return kk_std_core_hnd_yield_extend(next_10012, _ctx);
    }
    {
      return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), next_10012, (next_10012, x_0_10011, _ctx), _ctx);
    }
  }
}
 
// Given a total function to calculate a value `:a`, return
// a total function that only calculates the value once and then
// returns the cached result.


// lift anonymous function
struct kk_std_core_delayed_once_fun47__t {
  struct kk_function_s _base;
  kk_function_t calc;
  kk_ref_t r;
};
static kk_box_t kk_std_core_delayed_once_fun47(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_core_delayed_new_once_fun47(kk_function_t calc, kk_ref_t r, kk_context_t* _ctx) {
  struct kk_std_core_delayed_once_fun47__t* _self = kk_function_alloc_as(struct kk_std_core_delayed_once_fun47__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_delayed_once_fun47, kk_context());
  _self->calc = calc;
  _self->r = r;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_delayed_once_fun47(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_core_delayed_once_fun47__t* _self = kk_function_as(struct kk_std_core_delayed_once_fun47__t*, _fself, _ctx);
  kk_function_t calc = _self->calc; /* () -> 371 */
  kk_ref_t r = _self->r; /* ref<_296,maybe<371>> */
  kk_drop_match(_self, {kk_function_dup(calc, _ctx);kk_ref_dup(r, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _match_x27;
  kk_box_t _x_x48;
  kk_ref_t _x_x49 = kk_ref_dup(r, _ctx); /*ref<_296,maybe<371>>*/
  _x_x48 = kk_ref_get(_x_x49,kk_context()); /*1568*/
  _match_x27 = kk_std_core_types__maybe_unbox(_x_x48, KK_OWNED, _ctx); /*maybe<371>*/
  if (kk_std_core_types__is_Just(_match_x27, _ctx)) {
    kk_box_t x = _match_x27._cons.Just.value;
    kk_ref_drop(r, _ctx);
    kk_function_drop(calc, _ctx);
    return x;
  }
  {
    kk_box_t x_0 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), calc, (calc, _ctx), _ctx); /*371*/;
    kk_unit_t __ = kk_Unit;
    kk_unit_t _brw_x28 = kk_Unit;
    kk_box_t _x_x50;
    kk_std_core_types__maybe _x_x51;
    kk_box_t _x_x52 = kk_box_dup(x_0, _ctx); /*371*/
    _x_x51 = kk_std_core_types__new_Just(_x_x52, _ctx); /*maybe<91>*/
    _x_x50 = kk_std_core_types__maybe_box(_x_x51, _ctx); /*1551*/
    kk_ref_set_borrow(r,_x_x50,kk_context());
    kk_ref_drop(r, _ctx);
    _brw_x28;
    return x_0;
  }
}

kk_function_t kk_std_core_delayed_once(kk_function_t calc, kk_context_t* _ctx) { /* forall<a> (calc : () -> a) -> (() -> a) */ 
  kk_ref_t r = kk_ref_alloc((kk_std_core_types__maybe_box(kk_std_core_types__new_Nothing(_ctx), _ctx)),kk_context()); /*ref<_296,maybe<371>>*/;
  return kk_std_core_delayed_new_once_fun47(calc, r, _ctx);
}

// initialization
void kk_std_core_delayed__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_hnd__init(_ctx);
  kk_std_core_unsafe__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_delayed__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_unsafe__done(_ctx);
  kk_std_core_hnd__done(_ctx);
  kk_std_core_types__done(_ctx);
}
