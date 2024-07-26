// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:emit`

kk_std_core_hnd__htag kk_main__tag_emit;
 
// handler for the effect `:emit`

kk_box_t kk_main__handle_emit(kk_main__emit hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : emit<e,b>, ret : (res : a) -> e b, action : () -> <emit|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x386 = kk_std_core_hnd__htag_dup(kk_main__tag_emit, _ctx); /*hnd/htag<main/emit>*/
  return kk_std_core_hnd__hhandle(_x_x386, kk_main__emit_box(hnd, _ctx), ret, action, _ctx);
}
 
// runtime tag for the effect `:read`

kk_std_core_hnd__htag kk_main__tag_read;
 
// handler for the effect `:read`

kk_box_t kk_main__handle_read(kk_main__read hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : read<e,b>, ret : (res : a) -> e b, action : () -> <read|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x389 = kk_std_core_hnd__htag_dup(kk_main__tag_read, _ctx); /*hnd/htag<main/read>*/
  return kk_std_core_hnd__hhandle(_x_x389, kk_main__read_box(hnd, _ctx), ret, action, _ctx);
}
 
// runtime tag for the effect `:stop`

kk_std_core_hnd__htag kk_main__tag_stop;
 
// handler for the effect `:stop`

kk_box_t kk_main__handle_stop(kk_main__stop hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : stop<e,b>, ret : (res : a) -> e b, action : () -> <stop|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x392 = kk_std_core_hnd__htag_dup(kk_main__tag_stop, _ctx); /*hnd/htag<main/stop>*/
  return kk_std_core_hnd__hhandle(_x_x392, kk_main__stop_box(hnd, _ctx), ret, action, _ctx);
}


// lift anonymous function
struct kk_main_catch_fun402__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_catch_fun402(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx);
static kk_function_t kk_main_new_catch_fun402(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_catch_fun402, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_catch_fun403__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_catch_fun403(kk_function_t _fself, kk_function_t _b_x34, kk_context_t* _ctx);
static kk_function_t kk_main_new_catch_fun403(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_catch_fun403, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_catch_fun404__t {
  struct kk_function_s _base;
  kk_function_t _b_x34;
};
static kk_unit_t kk_main_catch_fun404(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x35, kk_context_t* _ctx);
static kk_function_t kk_main_new_catch_fun404(kk_function_t _b_x34, kk_context_t* _ctx) {
  struct kk_main_catch_fun404__t* _self = kk_function_alloc_as(struct kk_main_catch_fun404__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_catch_fun404, kk_context());
  _self->_b_x34 = _b_x34;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_unit_t kk_main_catch_fun404(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x35, kk_context_t* _ctx) {
  struct kk_main_catch_fun404__t* _self = kk_function_as(struct kk_main_catch_fun404__t*, _fself, _ctx);
  kk_function_t _b_x34 = _self->_b_x34; /* (hnd/resume-result<3003,3005>) -> 3004 3005 */
  kk_drop_match(_self, {kk_function_dup(_b_x34, _ctx);}, {}, _ctx)
  kk_box_t _x_x405 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x34, (_b_x34, _b_x35, _ctx), _ctx); /*3005*/
  return kk_unit_unbox(_x_x405);
}


// lift anonymous function
struct kk_main_catch_fun406__t {
  struct kk_function_s _base;
};
static kk_unit_t kk_main_catch_fun406(kk_function_t _fself, kk_unit_t ___wildcard_x730__55, kk_function_t r, kk_context_t* _ctx);
static kk_function_t kk_main_new_catch_fun406(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_catch_fun406, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_unit_t kk_main_catch_fun406(kk_function_t _fself, kk_unit_t ___wildcard_x730__55, kk_function_t r, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_drop(r, _ctx);
  return kk_Unit;
}


// lift anonymous function
struct kk_main_catch_fun407__t {
  struct kk_function_s _base;
  kk_function_t _b_x26_46;
};
static kk_box_t kk_main_catch_fun407(kk_function_t _fself, kk_box_t _b_x28, kk_function_t _b_x29, kk_context_t* _ctx);
static kk_function_t kk_main_new_catch_fun407(kk_function_t _b_x26_46, kk_context_t* _ctx) {
  struct kk_main_catch_fun407__t* _self = kk_function_alloc_as(struct kk_main_catch_fun407__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_catch_fun407, kk_context());
  _self->_b_x26_46 = _b_x26_46;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_catch_fun410__t {
  struct kk_function_s _base;
  kk_function_t _b_x29;
};
static kk_unit_t kk_main_catch_fun410(kk_function_t _fself, kk_box_t _b_x30, kk_context_t* _ctx);
static kk_function_t kk_main_new_catch_fun410(kk_function_t _b_x29, kk_context_t* _ctx) {
  struct kk_main_catch_fun410__t* _self = kk_function_alloc_as(struct kk_main_catch_fun410__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_catch_fun410, kk_context());
  _self->_b_x29 = _b_x29;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_unit_t kk_main_catch_fun410(kk_function_t _fself, kk_box_t _b_x30, kk_context_t* _ctx) {
  struct kk_main_catch_fun410__t* _self = kk_function_as(struct kk_main_catch_fun410__t*, _fself, _ctx);
  kk_function_t _b_x29 = _self->_b_x29; /* (3004) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x29, _ctx);}, {}, _ctx)
  kk_box_t _x_x411 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x29, (_b_x29, _b_x30, _ctx), _ctx); /*3006*/
  return kk_unit_unbox(_x_x411);
}
static kk_box_t kk_main_catch_fun407(kk_function_t _fself, kk_box_t _b_x28, kk_function_t _b_x29, kk_context_t* _ctx) {
  struct kk_main_catch_fun407__t* _self = kk_function_as(struct kk_main_catch_fun407__t*, _fself, _ctx);
  kk_function_t _b_x26_46 = _self->_b_x26_46; /* ((), r : (717) -> 727 ()) -> 727 () */
  kk_drop_match(_self, {kk_function_dup(_b_x26_46, _ctx);}, {}, _ctx)
  kk_unit_t _x_x408 = kk_Unit;
  kk_unit_t _x_x409 = kk_Unit;
  kk_unit_unbox(_b_x28);
  kk_function_call(kk_unit_t, (kk_function_t, kk_unit_t, kk_function_t, kk_context_t*), _b_x26_46, (_b_x26_46, _x_x409, kk_main_new_catch_fun410(_b_x29, _ctx), _ctx), _ctx);
  return kk_unit_box(_x_x408);
}


// lift anonymous function
struct kk_main_catch_fun412__t {
  struct kk_function_s _base;
  kk_function_t _b_x27_47;
};
static kk_box_t kk_main_catch_fun412(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x31, kk_context_t* _ctx);
static kk_function_t kk_main_new_catch_fun412(kk_function_t _b_x27_47, kk_context_t* _ctx) {
  struct kk_main_catch_fun412__t* _self = kk_function_alloc_as(struct kk_main_catch_fun412__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_catch_fun412, kk_context());
  _self->_b_x27_47 = _b_x27_47;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_catch_fun412(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x31, kk_context_t* _ctx) {
  struct kk_main_catch_fun412__t* _self = kk_function_as(struct kk_main_catch_fun412__t*, _fself, _ctx);
  kk_function_t _b_x27_47 = _self->_b_x27_47; /* (hnd/resume-result<717,()>) -> 727 () */
  kk_drop_match(_self, {kk_function_dup(_b_x27_47, _ctx);}, {}, _ctx)
  kk_unit_t _x_x413 = kk_Unit;
  kk_function_call(kk_unit_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x27_47, (_b_x27_47, _b_x31, _ctx), _ctx);
  return kk_unit_box(_x_x413);
}
static kk_box_t kk_main_catch_fun403(kk_function_t _fself, kk_function_t _b_x34, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_t k_48 = kk_main_new_catch_fun404(_b_x34, _ctx); /*(hnd/resume-result<717,()>) -> 727 ()*/;
  kk_unit_t _b_x25_45 = kk_Unit;
  kk_function_t _b_x26_46 = kk_main_new_catch_fun406(_ctx); /*((), r : (717) -> 727 ()) -> 727 ()*/;
  kk_function_t _b_x27_47 = k_48; /*(hnd/resume-result<717,()>) -> 727 ()*/;
  return kk_std_core_hnd_protect(kk_unit_box(_b_x25_45), kk_main_new_catch_fun407(_b_x26_46, _ctx), kk_main_new_catch_fun412(_b_x27_47, _ctx), _ctx);
}
static kk_box_t kk_main_catch_fun402(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x730__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_main_new_catch_fun403(_ctx), _ctx);
}


// lift anonymous function
struct kk_main_catch_fun414__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_catch_fun414(kk_function_t _fself, kk_box_t _b_x39, kk_context_t* _ctx);
static kk_function_t kk_main_new_catch_fun414(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_catch_fun414, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_catch_fun414(kk_function_t _fself, kk_box_t _b_x39, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_49 = kk_Unit;
  kk_unit_unbox(_b_x39);
  return kk_unit_box(_x_49);
}


// lift anonymous function
struct kk_main_catch_fun415__t {
  struct kk_function_s _base;
  kk_function_t action;
};
static kk_box_t kk_main_catch_fun415(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_catch_fun415(kk_function_t action, kk_context_t* _ctx) {
  struct kk_main_catch_fun415__t* _self = kk_function_alloc_as(struct kk_main_catch_fun415__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_catch_fun415, kk_context());
  _self->action = action;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_catch_fun415(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_catch_fun415__t* _self = kk_function_as(struct kk_main_catch_fun415__t*, _fself, _ctx);
  kk_function_t action = _self->action; /* () -> <main/stop|727> () */
  kk_drop_match(_self, {kk_function_dup(action, _ctx);}, {}, _ctx)
  kk_unit_t _x_x416 = kk_Unit;
  kk_function_call(kk_unit_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx);
  return kk_unit_box(_x_x416);
}

kk_unit_t kk_main_catch(kk_function_t action, kk_context_t* _ctx) { /* forall<e> (action : () -> <stop|e> ()) -> e () */ 
  kk_box_t _x_x399;
  kk_main__stop _x_x400;
  kk_std_core_hnd__clause0 _x_x401 = kk_std_core_hnd__new_Clause0(kk_main_new_catch_fun402(_ctx), _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
  _x_x400 = kk_main__new_Hnd_stop(kk_reuse_null, 0, kk_integer_from_small(3), _x_x401, _ctx); /*main/stop<23,24>*/
  _x_x399 = kk_main__handle_stop(_x_x400, kk_main_new_catch_fun414(_ctx), kk_main_new_catch_fun415(action, _ctx), _ctx); /*444*/
  kk_unit_unbox(_x_x399); return kk_Unit;
}
extern kk_box_t kk_main_read_fun422(kk_function_t _fself, int32_t _b_x65, kk_std_core_hnd__ev _b_x66, kk_context_t* _ctx) {
  struct kk_main_read_fun422__t* _self = kk_function_as(struct kk_main_read_fun422__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x61 = _self->_fun_unbox_x61; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x61, _ctx);}, {}, _ctx)
  kk_integer_t _x_x423;
  int32_t _b_x62_73 = _b_x65; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x63_74 = _b_x66; /*hnd/ev<main/read>*/;
  kk_box_t _x_x424 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x61, (_fun_unbox_x61, _b_x62_73, _b_x63_74, _ctx), _ctx); /*1005*/
  _x_x423 = kk_integer_unbox(_x_x424, _ctx); /*main/chr*/
  return kk_integer_box(_x_x423, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_feed_10073_fun427__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_feed_10073_fun427(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_feed_10073_fun427(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_feed_10073_fun427, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_feed_10073_fun427(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t wild___0_82 = kk_Unit;
  kk_unit_unbox(_b_x80);
  return kk_integer_box(kk_integer_from_small(10), _ctx);
}

kk_integer_t kk_main__mlift_feed_10073(kk_ref_t j, kk_integer_t _y_x10023, kk_context_t* _ctx) { /* forall<h,e> (j : local-var<h,int>, int) -> <local<h>,stop|e> chr */ 
  kk_unit_t x_10095 = kk_Unit;
  kk_unit_t _brw_x365 = kk_Unit;
  kk_ref_set_borrow(j,(kk_integer_box(_y_x10023, _ctx)),kk_context());
  kk_ref_drop(j, _ctx);
  _brw_x365;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x426 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_feed_10073_fun427(_ctx), _ctx); /*3321*/
    return kk_integer_unbox(_x_x426, _ctx);
  }
  {
    return kk_integer_from_small(10);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_feed_10074_fun430__t {
  struct kk_function_s _base;
  kk_ref_t j;
};
static kk_box_t kk_main__mlift_feed_10074_fun430(kk_function_t _fself, kk_box_t _b_x86, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_feed_10074_fun430(kk_ref_t j, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10074_fun430__t* _self = kk_function_alloc_as(struct kk_main__mlift_feed_10074_fun430__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_feed_10074_fun430, kk_context());
  _self->j = j;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_feed_10074_fun430(kk_function_t _fself, kk_box_t _b_x86, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10074_fun430__t* _self = kk_function_as(struct kk_main__mlift_feed_10074_fun430__t*, _fself, _ctx);
  kk_ref_t j = _self->j; /* local-var<1316,int> */
  kk_drop_match(_self, {kk_ref_dup(j, _ctx);}, {}, _ctx)
  kk_integer_t _y_x10023_88 = kk_integer_unbox(_b_x86, _ctx); /*int*/;
  kk_integer_t _x_x431 = kk_main__mlift_feed_10073(j, _y_x10023_88, _ctx); /*main/chr*/
  return kk_integer_box(_x_x431, _ctx);
}

kk_integer_t kk_main__mlift_feed_10074(kk_ref_t i, kk_ref_t j, kk_unit_t wild__, kk_context_t* _ctx) { /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, wild_ : ()) -> <local<h>,stop|e> chr */ 
  kk_integer_t x_10098;
  kk_box_t _x_x428 = kk_ref_get(i,kk_context()); /*3256*/
  x_10098 = kk_integer_unbox(_x_x428, _ctx); /*int*/
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10098, _ctx);
    kk_box_t _x_x429 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_feed_10074_fun430(j, _ctx), _ctx); /*3321*/
    return kk_integer_unbox(_x_x429, _ctx);
  }
  {
    return kk_main__mlift_feed_10073(j, x_10098, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_feed_10075_fun433__t {
  struct kk_function_s _base;
  kk_ref_t i;
  kk_ref_t j;
};
static kk_box_t kk_main__mlift_feed_10075_fun433(kk_function_t _fself, kk_box_t _b_x94, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_feed_10075_fun433(kk_ref_t i, kk_ref_t j, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10075_fun433__t* _self = kk_function_alloc_as(struct kk_main__mlift_feed_10075_fun433__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_feed_10075_fun433, kk_context());
  _self->i = i;
  _self->j = j;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_feed_10075_fun433(kk_function_t _fself, kk_box_t _b_x94, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10075_fun433__t* _self = kk_function_as(struct kk_main__mlift_feed_10075_fun433__t*, _fself, _ctx);
  kk_ref_t i = _self->i; /* local-var<1316,int> */
  kk_ref_t j = _self->j; /* local-var<1316,int> */
  kk_drop_match(_self, {kk_ref_dup(i, _ctx);kk_ref_dup(j, _ctx);}, {}, _ctx)
  kk_unit_t wild___96 = kk_Unit;
  kk_unit_unbox(_b_x94);
  kk_integer_t _x_x434 = kk_main__mlift_feed_10074(i, j, wild___96, _ctx); /*main/chr*/
  return kk_integer_box(_x_x434, _ctx);
}

kk_integer_t kk_main__mlift_feed_10075(kk_ref_t i, kk_ref_t j, kk_integer_t _y_x10021, kk_context_t* _ctx) { /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, int) -> <local<h>,stop|e> chr */ 
  kk_integer_t _b_x90_92 = kk_integer_add_small_const(_y_x10021, 1, _ctx); /*int*/;
  kk_unit_t x_10100 = kk_Unit;
  kk_ref_set_borrow(i,(kk_integer_box(_b_x90_92, _ctx)),kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x432 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_feed_10075_fun433(i, j, _ctx), _ctx); /*3321*/
    return kk_integer_unbox(_x_x432, _ctx);
  }
  {
    return kk_main__mlift_feed_10074(i, j, x_10100, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_feed_10077_fun436__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_feed_10077_fun436(kk_function_t _fself, kk_box_t _b_x102, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_feed_10077_fun436(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_feed_10077_fun436, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_feed_10077_fun436(kk_function_t _fself, kk_box_t _b_x102, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t wild___1_104 = kk_Unit;
  kk_unit_unbox(_b_x102);
  return kk_integer_box(kk_integer_from_small(36), _ctx);
}

kk_integer_t kk_main__mlift_feed_10077(kk_ref_t j, kk_integer_t _y_x10025, kk_context_t* _ctx) { /* forall<h,e> (j : local-var<h,int>, int) -> <local<h>,stop|e> chr */ 
  kk_integer_t _b_x98_100 = kk_integer_add_small_const(_y_x10025, -1, _ctx); /*int*/;
  kk_unit_t x_10102 = kk_Unit;
  kk_unit_t _brw_x361 = kk_Unit;
  kk_ref_set_borrow(j,(kk_integer_box(_b_x98_100, _ctx)),kk_context());
  kk_ref_drop(j, _ctx);
  _brw_x361;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x435 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_feed_10077_fun436(_ctx), _ctx); /*3321*/
    return kk_integer_unbox(_x_x435, _ctx);
  }
  {
    return kk_integer_from_small(36);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_feed_10078_fun440__t {
  struct kk_function_s _base;
  kk_ref_t i;
  kk_ref_t j;
};
static kk_box_t kk_main__mlift_feed_10078_fun440(kk_function_t _fself, kk_box_t _b_x108, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_feed_10078_fun440(kk_ref_t i, kk_ref_t j, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10078_fun440__t* _self = kk_function_alloc_as(struct kk_main__mlift_feed_10078_fun440__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_feed_10078_fun440, kk_context());
  _self->i = i;
  _self->j = j;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_feed_10078_fun440(kk_function_t _fself, kk_box_t _b_x108, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10078_fun440__t* _self = kk_function_as(struct kk_main__mlift_feed_10078_fun440__t*, _fself, _ctx);
  kk_ref_t i = _self->i; /* local-var<1316,int> */
  kk_ref_t j = _self->j; /* local-var<1316,int> */
  kk_drop_match(_self, {kk_ref_dup(i, _ctx);kk_ref_dup(j, _ctx);}, {}, _ctx)
  kk_integer_t _y_x10021_115 = kk_integer_unbox(_b_x108, _ctx); /*int*/;
  kk_integer_t _x_x441 = kk_main__mlift_feed_10075(i, j, _y_x10021_115, _ctx); /*main/chr*/
  return kk_integer_box(_x_x441, _ctx);
}


// lift anonymous function
struct kk_main__mlift_feed_10078_fun445__t {
  struct kk_function_s _base;
  kk_ref_t j;
};
static kk_box_t kk_main__mlift_feed_10078_fun445(kk_function_t _fself, kk_box_t _b_x112, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_feed_10078_fun445(kk_ref_t j, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10078_fun445__t* _self = kk_function_alloc_as(struct kk_main__mlift_feed_10078_fun445__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_feed_10078_fun445, kk_context());
  _self->j = j;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_feed_10078_fun445(kk_function_t _fself, kk_box_t _b_x112, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10078_fun445__t* _self = kk_function_as(struct kk_main__mlift_feed_10078_fun445__t*, _fself, _ctx);
  kk_ref_t j = _self->j; /* local-var<1316,int> */
  kk_drop_match(_self, {kk_ref_dup(j, _ctx);}, {}, _ctx)
  kk_integer_t _y_x10025_116 = kk_integer_unbox(_b_x112, _ctx); /*int*/;
  kk_integer_t _x_x446 = kk_main__mlift_feed_10077(j, _y_x10025_116, _ctx); /*main/chr*/
  return kk_integer_box(_x_x446, _ctx);
}

kk_integer_t kk_main__mlift_feed_10078(kk_ref_t i, kk_ref_t j, kk_integer_t _y_x10020, kk_context_t* _ctx) { /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, int) -> <local<h>,stop|e> chr */ 
  bool _match_x356;
  bool _brw_x359 = kk_integer_eq_borrow(_y_x10020,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  kk_integer_drop(_y_x10020, _ctx);
  _match_x356 = _brw_x359; /*bool*/
  if (_match_x356) {
    kk_integer_t x_10105;
    kk_box_t _x_x437;
    kk_ref_t _x_x438 = kk_ref_dup(i, _ctx); /*local-var<1316,int>*/
    _x_x437 = kk_ref_get(_x_x438,kk_context()); /*3256*/
    x_10105 = kk_integer_unbox(_x_x437, _ctx); /*int*/
    if (kk_yielding(kk_context())) {
      kk_integer_drop(x_10105, _ctx);
      kk_box_t _x_x439 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_feed_10078_fun440(i, j, _ctx), _ctx); /*3321*/
      return kk_integer_unbox(_x_x439, _ctx);
    }
    {
      return kk_main__mlift_feed_10075(i, j, x_10105, _ctx);
    }
  }
  {
    kk_ref_drop(i, _ctx);
    kk_integer_t x_0_10107;
    kk_box_t _x_x442;
    kk_ref_t _x_x443 = kk_ref_dup(j, _ctx); /*local-var<1316,int>*/
    _x_x442 = kk_ref_get(_x_x443,kk_context()); /*3289*/
    x_0_10107 = kk_integer_unbox(_x_x442, _ctx); /*int*/
    if (kk_yielding(kk_context())) {
      kk_integer_drop(x_0_10107, _ctx);
      kk_box_t _x_x444 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_feed_10078_fun445(j, _ctx), _ctx); /*3321*/
      return kk_integer_unbox(_x_x444, _ctx);
    }
    {
      return kk_main__mlift_feed_10077(j, x_0_10107, _ctx);
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_feed_10079_fun449__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_feed_10079_fun449(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_feed_10079_fun449(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_feed_10079_fun449, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main__mlift_feed_10079_fun453__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x120;
};
static kk_box_t kk_main__mlift_feed_10079_fun453(kk_function_t _fself, int32_t _b_x124, kk_std_core_hnd__ev _b_x125, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_feed_10079_fun453(kk_function_t _fun_unbox_x120, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10079_fun453__t* _self = kk_function_alloc_as(struct kk_main__mlift_feed_10079_fun453__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_feed_10079_fun453, kk_context());
  _self->_fun_unbox_x120 = _fun_unbox_x120;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_feed_10079_fun453(kk_function_t _fself, int32_t _b_x124, kk_std_core_hnd__ev _b_x125, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10079_fun453__t* _self = kk_function_as(struct kk_main__mlift_feed_10079_fun453__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x120 = _self->_fun_unbox_x120; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x120, _ctx);}, {}, _ctx)
  kk_integer_t _x_x454;
  int32_t _b_x121_142 = _b_x124; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x122_143 = _b_x125; /*hnd/ev<main/stop>*/;
  kk_box_t _x_x455 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x120, (_fun_unbox_x120, _b_x121_142, _b_x122_143, _ctx), _ctx); /*1005*/
  _x_x454 = kk_integer_unbox(_x_x455, _ctx); /*main/chr*/
  return kk_integer_box(_x_x454, _ctx);
}
static kk_box_t kk_main__mlift_feed_10079_fun449(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_10109 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/stop>*/;
  kk_integer_t _x_x450;
  {
    struct kk_std_core_hnd_Ev* _con_x451 = kk_std_core_hnd__as_Ev(ev_10109, _ctx);
    kk_box_t _box_x117 = _con_x451->hnd;
    int32_t m = _con_x451->marker;
    kk_main__stop h = kk_main__stop_unbox(_box_x117, KK_BORROWED, _ctx);
    kk_main__stop_dup(h, _ctx);
    {
      struct kk_main__Hnd_stop* _con_x452 = kk_main__as_Hnd_stop(h, _ctx);
      kk_integer_t _pat_0_1 = _con_x452->_cfc;
      kk_std_core_hnd__clause0 _ctl_stop = _con_x452->_ctl_stop;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_1, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_stop, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x120 = _ctl_stop.clause;
        kk_function_t _bv_x126 = (kk_main__new_mlift_feed_10079_fun453(_fun_unbox_x120, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x456 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x126, (_bv_x126, m, ev_10109, _ctx), _ctx); /*3004*/
        _x_x450 = kk_integer_unbox(_x_x456, _ctx); /*main/chr*/
      }
    }
  }
  return kk_integer_box(_x_x450, _ctx);
}


// lift anonymous function
struct kk_main__mlift_feed_10079_fun460__t {
  struct kk_function_s _base;
  kk_ref_t i;
  kk_ref_t j;
};
static kk_box_t kk_main__mlift_feed_10079_fun460(kk_function_t _fself, kk_box_t _b_x134, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_feed_10079_fun460(kk_ref_t i, kk_ref_t j, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10079_fun460__t* _self = kk_function_alloc_as(struct kk_main__mlift_feed_10079_fun460__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_feed_10079_fun460, kk_context());
  _self->i = i;
  _self->j = j;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_feed_10079_fun460(kk_function_t _fself, kk_box_t _b_x134, kk_context_t* _ctx) {
  struct kk_main__mlift_feed_10079_fun460__t* _self = kk_function_as(struct kk_main__mlift_feed_10079_fun460__t*, _fself, _ctx);
  kk_ref_t i = _self->i; /* local-var<1316,int> */
  kk_ref_t j = _self->j; /* local-var<1316,int> */
  kk_drop_match(_self, {kk_ref_dup(i, _ctx);kk_ref_dup(j, _ctx);}, {}, _ctx)
  kk_integer_t _y_x10020_141 = kk_integer_unbox(_b_x134, _ctx); /*int*/;
  kk_integer_t _x_x461 = kk_main__mlift_feed_10078(i, j, _y_x10020_141, _ctx); /*main/chr*/
  return kk_integer_box(_x_x461, _ctx);
}

kk_integer_t kk_main__mlift_feed_10079(kk_ref_t i, kk_ref_t j, kk_integer_t n, kk_integer_t _y_x10017, kk_context_t* _ctx) { /* forall<h,e> (i : local-var<h,int>, j : local-var<h,int>, n : int, int) -> <local<h>,stop|e> chr */ 
  bool _match_x353;
  bool _brw_x355 = kk_integer_gt_borrow(_y_x10017,n,kk_context()); /*bool*/;
  kk_integer_drop(_y_x10017, _ctx);
  kk_integer_drop(n, _ctx);
  _match_x353 = _brw_x355; /*bool*/
  if (_match_x353) {
    kk_ref_drop(j, _ctx);
    kk_ref_drop(i, _ctx);
    kk_ssize_t _b_x129_135;
    kk_std_core_hnd__htag _x_x447 = kk_std_core_hnd__htag_dup(kk_main__tag_stop, _ctx); /*hnd/htag<main/stop>*/
    _b_x129_135 = kk_std_core_hnd__evv_index(_x_x447, _ctx); /*hnd/ev-index*/
    kk_box_t _x_x448 = kk_std_core_hnd__open_at0(_b_x129_135, kk_main__new_mlift_feed_10079_fun449(_ctx), _ctx); /*1000*/
    return kk_integer_unbox(_x_x448, _ctx);
  }
  {
    kk_integer_t x_10111;
    kk_box_t _x_x457;
    kk_ref_t _x_x458 = kk_ref_dup(j, _ctx); /*local-var<1316,int>*/
    _x_x457 = kk_ref_get(_x_x458,kk_context()); /*3290*/
    x_10111 = kk_integer_unbox(_x_x457, _ctx); /*int*/
    if (kk_yielding(kk_context())) {
      kk_integer_drop(x_10111, _ctx);
      kk_box_t _x_x459 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_feed_10079_fun460(i, j, _ctx), _ctx); /*3321*/
      return kk_integer_unbox(_x_x459, _ctx);
    }
    {
      return kk_main__mlift_feed_10078(i, j, x_10111, _ctx);
    }
  }
}


// lift anonymous function
struct kk_main_feed_fun464__t {
  struct kk_function_s _base;
  kk_ref_t loc;
  kk_ref_t loc_0;
  kk_integer_t n;
};
static kk_box_t kk_main_feed_fun464(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_feed_fun464(kk_ref_t loc, kk_ref_t loc_0, kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_feed_fun464__t* _self = kk_function_alloc_as(struct kk_main_feed_fun464__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_feed_fun464, kk_context());
  _self->loc = loc;
  _self->loc_0 = loc_0;
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_feed_fun469__t {
  struct kk_function_s _base;
  kk_ref_t loc;
  kk_ref_t loc_0;
  kk_integer_t n;
};
static kk_box_t kk_main_feed_fun469(kk_function_t _fself, kk_box_t _b_x151, kk_context_t* _ctx);
static kk_function_t kk_main_new_feed_fun469(kk_ref_t loc, kk_ref_t loc_0, kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_feed_fun469__t* _self = kk_function_alloc_as(struct kk_main_feed_fun469__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_feed_fun469, kk_context());
  _self->loc = loc;
  _self->loc_0 = loc_0;
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_feed_fun469(kk_function_t _fself, kk_box_t _b_x151, kk_context_t* _ctx) {
  struct kk_main_feed_fun469__t* _self = kk_function_as(struct kk_main_feed_fun469__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<1316,int> */
  kk_ref_t loc_0 = _self->loc_0; /* local-var<1316,int> */
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);kk_ref_dup(loc_0, _ctx);kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_integer_t _x_x470;
  kk_integer_t _x_x471 = kk_integer_unbox(_b_x151, _ctx); /*int*/
  _x_x470 = kk_main__mlift_feed_10079(loc, loc_0, n, _x_x471, _ctx); /*main/chr*/
  return kk_integer_box(_x_x470, _ctx);
}
static kk_box_t kk_main_feed_fun464(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_feed_fun464__t* _self = kk_function_as(struct kk_main_feed_fun464__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<1316,int> */
  kk_ref_t loc_0 = _self->loc_0; /* local-var<1316,int> */
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);kk_ref_dup(loc_0, _ctx);kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_integer_t x_10117;
  kk_box_t _x_x465;
  kk_ref_t _x_x466 = kk_ref_dup(loc, _ctx); /*local-var<1316,int>*/
  _x_x465 = kk_ref_get(_x_x466,kk_context()); /*3294*/
  x_10117 = kk_integer_unbox(_x_x465, _ctx); /*int*/
  kk_integer_t _x_x467;
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10117, _ctx);
    kk_box_t _x_x468 = kk_std_core_hnd_yield_extend(kk_main_new_feed_fun469(loc, loc_0, n, _ctx), _ctx); /*3321*/
    _x_x467 = kk_integer_unbox(_x_x468, _ctx); /*main/chr*/
  }
  else {
    _x_x467 = kk_main__mlift_feed_10079(loc, loc_0, n, x_10117, _ctx); /*main/chr*/
  }
  return kk_integer_box(_x_x467, _ctx);
}


// lift anonymous function
struct kk_main_feed_fun473__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_feed_fun473(kk_function_t _fself, kk_box_t _b_x156, kk_context_t* _ctx);
static kk_function_t kk_main_new_feed_fun473(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_feed_fun473, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_feed_fun473(kk_function_t _fself, kk_box_t _b_x156, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _b_x156;
}


// lift anonymous function
struct kk_main_feed_fun474__t {
  struct kk_function_s _base;
  kk_function_t action;
};
static kk_box_t kk_main_feed_fun474(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_feed_fun474(kk_function_t action, kk_context_t* _ctx) {
  struct kk_main_feed_fun474__t* _self = kk_function_alloc_as(struct kk_main_feed_fun474__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_feed_fun474, kk_context());
  _self->action = action;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_feed_fun474(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_feed_fun474__t* _self = kk_function_as(struct kk_main_feed_fun474__t*, _fself, _ctx);
  kk_function_t action = _self->action; /* () -> <main/read,main/stop|1320> () */
  kk_drop_match(_self, {kk_function_dup(action, _ctx);}, {}, _ctx)
  kk_unit_t _x_x475 = kk_Unit;
  kk_function_call(kk_unit_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx);
  return kk_unit_box(_x_x475);
}

kk_unit_t kk_main_feed(kk_integer_t n, kk_function_t action, kk_context_t* _ctx) { /* forall<e> (n : int, action : () -> <read,stop|e> ()) -> <stop|e> () */ 
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<1316,int>*/;
  kk_ref_t loc_0 = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<1316,int>*/;
  kk_main__read _b_x153_157;
  kk_std_core_hnd__clause0 _x_x462;
  kk_function_t _x_x463;
  kk_ref_dup(loc, _ctx);
  kk_ref_dup(loc_0, _ctx);
  _x_x463 = kk_main_new_feed_fun464(loc, loc_0, n, _ctx); /*() -> 3304 3307*/
  _x_x462 = kk_std_core_hnd_clause_tail0(_x_x463, _ctx); /*hnd/clause0<3307,3306,3304,3305>*/
  _b_x153_157 = kk_main__new_Hnd_read(kk_reuse_null, 0, kk_integer_from_small(1), _x_x462, _ctx); /*main/read<<local<1316>,main/stop|1320>,()>*/
  kk_unit_t res_0 = kk_Unit;
  kk_box_t _x_x472 = kk_main__handle_read(_b_x153_157, kk_main_new_feed_fun473(_ctx), kk_main_new_feed_fun474(action, _ctx), _ctx); /*395*/
  kk_unit_unbox(_x_x472);
  kk_unit_t res = kk_Unit;
  kk_box_t _x_x476 = kk_std_core_hnd_prompt_local_var(loc_0, kk_unit_box(res_0), _ctx); /*3321*/
  kk_unit_unbox(_x_x476);
  kk_box_t _x_x477 = kk_std_core_hnd_prompt_local_var(loc, kk_unit_box(res), _ctx); /*3321*/
  kk_unit_unbox(_x_x477); return kk_Unit;
}
 
// monadic lift

kk_box_t kk_main__mlift_parse_10080(kk_unit_t wild__, kk_context_t* _ctx) { /* forall<a> (wild_ : ()) -> <emit,stop,read,div> a */ 
  return kk_main_parse(kk_integer_from_small(0), _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_parse_10081_fun480__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_parse_10081_fun480(kk_function_t _fself, kk_box_t _b_x183, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_parse_10081_fun480(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_parse_10081_fun480, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_parse_10081_fun480(kk_function_t _fself, kk_box_t _b_x183, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_10122 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/emit>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x481 = kk_std_core_hnd__as_Ev(ev_10122, _ctx);
    kk_box_t _box_x172 = _con_x481->hnd;
    int32_t m = _con_x481->marker;
    kk_main__emit h = kk_main__emit_unbox(_box_x172, KK_BORROWED, _ctx);
    kk_main__emit_dup(h, _ctx);
    {
      struct kk_main__Hnd_emit* _con_x482 = kk_main__as_Hnd_emit(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x482->_cfc;
      kk_std_core_hnd__clause1 _fun_emit = _con_x482->_fun_emit;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_fun_emit, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x176 = _fun_emit.clause;
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x176, (_fun_unbox_x176, m, ev_10122, _b_x183, _ctx), _ctx);
      }
    }
  }
}


// lift anonymous function
struct kk_main__mlift_parse_10081_fun483__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_parse_10081_fun483(kk_function_t _fself, kk_box_t _b_x189, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_parse_10081_fun483(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_parse_10081_fun483, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_parse_10081_fun483(kk_function_t _fself, kk_box_t _b_x189, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x484 = kk_Unit;
  kk_unit_unbox(_b_x189);
  return kk_main__mlift_parse_10080(_x_x484, _ctx);
}


// lift anonymous function
struct kk_main__mlift_parse_10081_fun485__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_parse_10081_fun485(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_parse_10081_fun485(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_parse_10081_fun485, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_parse_10081_fun485(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_0_10125 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/stop>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x486 = kk_std_core_hnd__as_Ev(ev_0_10125, _ctx);
    kk_box_t _box_x190 = _con_x486->hnd;
    int32_t m_0 = _con_x486->marker;
    kk_main__stop h_0 = kk_main__stop_unbox(_box_x190, KK_BORROWED, _ctx);
    kk_main__stop_dup(h_0, _ctx);
    {
      struct kk_main__Hnd_stop* _con_x487 = kk_main__as_Hnd_stop(h_0, _ctx);
      kk_integer_t _pat_0_3 = _con_x487->_cfc;
      kk_std_core_hnd__clause0 _ctl_stop = _con_x487->_ctl_stop;
      if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
        kk_integer_drop(_pat_0_3, _ctx);
        kk_datatype_ptr_free(h_0, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_stop, _ctx);
        kk_datatype_ptr_decref(h_0, _ctx);
      }
      {
        kk_function_t f_0 = _ctl_stop.clause;
        kk_function_t _x_x488 = f_0; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _x_x488, (_x_x488, m_0, ev_0_10125, _ctx), _ctx);
      }
    }
  }
}

kk_box_t kk_main__mlift_parse_10081(kk_integer_t a, kk_integer_t c, kk_context_t* _ctx) { /* forall<a> (a : int, c : chr) -> <read,emit,stop,div> a */ 
  bool _match_x348 = kk_integer_eq_borrow(c,(kk_integer_from_small(36)),kk_context()); /*bool*/;
  if (_match_x348) {
    kk_integer_drop(c, _ctx);
    kk_integer_t _x_x478 = kk_integer_add_small_const(a, 1, _ctx); /*int*/
    return kk_main_parse(_x_x478, _ctx);
  }
  {
    bool _match_x349;
    bool _brw_x351 = kk_integer_eq_borrow(c,(kk_integer_from_small(10)),kk_context()); /*bool*/;
    kk_integer_drop(c, _ctx);
    _match_x349 = _brw_x351; /*bool*/
    if (_match_x349) {
      kk_ssize_t _b_x180_184 = (KK_IZ(0)); /*hnd/ev-index*/;
      kk_unit_t x_10120 = kk_Unit;
      kk_box_t _x_x479 = kk_std_core_hnd__open_at1(_b_x180_184, kk_main__new_mlift_parse_10081_fun480(_ctx), kk_integer_box(a, _ctx), _ctx); /*1001*/
      kk_unit_unbox(_x_x479);
      if (kk_yielding(kk_context())) {
        return kk_std_core_hnd_yield_extend(kk_main__new_mlift_parse_10081_fun483(_ctx), _ctx);
      }
      {
        return kk_main__mlift_parse_10080(x_10120, _ctx);
      }
    }
    {
      kk_integer_drop(a, _ctx);
      return kk_std_core_hnd__open_at0((KK_IZ(2)), kk_main__new_mlift_parse_10081_fun485(_ctx), _ctx);
    }
  }
}


// lift anonymous function
struct kk_main_parse_fun490__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_parse_fun490(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_parse_fun490(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_parse_fun490, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_parse_fun490(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_1_10130 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/read>*/;
  kk_integer_t _x_x491;
  {
    struct kk_std_core_hnd_Ev* _con_x492 = kk_std_core_hnd__as_Ev(ev_1_10130, _ctx);
    kk_box_t _box_x193 = _con_x492->hnd;
    int32_t m_1 = _con_x492->marker;
    kk_main__read h_1 = kk_main__read_unbox(_box_x193, KK_BORROWED, _ctx);
    kk_main__read_dup(h_1, _ctx);
    {
      struct kk_main__Hnd_read* _con_x493 = kk_main__as_Hnd_read(h_1, _ctx);
      kk_integer_t _pat_0_5 = _con_x493->_cfc;
      kk_std_core_hnd__clause0 _fun_read = _con_x493->_fun_read;
      if kk_likely(kk_datatype_ptr_is_unique(h_1, _ctx)) {
        kk_integer_drop(_pat_0_5, _ctx);
        kk_datatype_ptr_free(h_1, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_fun_read, _ctx);
        kk_datatype_ptr_decref(h_1, _ctx);
      }
      {
        kk_function_t _fun_unbox_x196 = _fun_read.clause;
        kk_function_t _bv_x202 = _fun_unbox_x196; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x494 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x202, (_bv_x202, m_1, ev_1_10130, _ctx), _ctx); /*3004*/
        _x_x491 = kk_integer_unbox(_x_x494, _ctx); /*main/chr*/
      }
    }
  }
  return kk_integer_box(_x_x491, _ctx);
}


// lift anonymous function
struct kk_main_parse_fun495__t {
  struct kk_function_s _base;
  kk_integer_t a_0;
};
static kk_box_t kk_main_parse_fun495(kk_function_t _fself, kk_box_t _b_x215, kk_context_t* _ctx);
static kk_function_t kk_main_new_parse_fun495(kk_integer_t a_0, kk_context_t* _ctx) {
  struct kk_main_parse_fun495__t* _self = kk_function_alloc_as(struct kk_main_parse_fun495__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_parse_fun495, kk_context());
  _self->a_0 = a_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_parse_fun495(kk_function_t _fself, kk_box_t _b_x215, kk_context_t* _ctx) {
  struct kk_main_parse_fun495__t* _self = kk_function_as(struct kk_main_parse_fun495__t*, _fself, _ctx);
  kk_integer_t a_0 = _self->a_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(a_0, _ctx);}, {}, _ctx)
  kk_integer_t _x_x496 = kk_integer_unbox(_b_x215, _ctx); /*main/chr*/
  return kk_main__mlift_parse_10081(a_0, _x_x496, _ctx);
}


// lift anonymous function
struct kk_main_parse_fun499__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_parse_fun499(kk_function_t _fself, kk_box_t _b_x227, kk_context_t* _ctx);
static kk_function_t kk_main_new_parse_fun499(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_parse_fun499, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_parse_fun499(kk_function_t _fself, kk_box_t _b_x227, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_2_10135 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/emit>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x500 = kk_std_core_hnd__as_Ev(ev_2_10135, _ctx);
    kk_box_t _box_x216 = _con_x500->hnd;
    int32_t m_2 = _con_x500->marker;
    kk_main__emit h_2 = kk_main__emit_unbox(_box_x216, KK_BORROWED, _ctx);
    kk_main__emit_dup(h_2, _ctx);
    {
      struct kk_main__Hnd_emit* _con_x501 = kk_main__as_Hnd_emit(h_2, _ctx);
      kk_integer_t _pat_0_6 = _con_x501->_cfc;
      kk_std_core_hnd__clause1 _fun_emit_0 = _con_x501->_fun_emit;
      if kk_likely(kk_datatype_ptr_is_unique(h_2, _ctx)) {
        kk_integer_drop(_pat_0_6, _ctx);
        kk_datatype_ptr_free(h_2, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_fun_emit_0, _ctx);
        kk_datatype_ptr_decref(h_2, _ctx);
      }
      {
        kk_function_t _fun_unbox_x220 = _fun_emit_0.clause;
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x220, (_fun_unbox_x220, m_2, ev_2_10135, _b_x227, _ctx), _ctx);
      }
    }
  }
}


// lift anonymous function
struct kk_main_parse_fun502__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_parse_fun502(kk_function_t _fself, kk_box_t _b_x233, kk_context_t* _ctx);
static kk_function_t kk_main_new_parse_fun502(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_parse_fun502, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_parse_fun502(kk_function_t _fself, kk_box_t _b_x233, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x503 = kk_Unit;
  kk_unit_unbox(_b_x233);
  return kk_main__mlift_parse_10080(_x_x503, _ctx);
}


// lift anonymous function
struct kk_main_parse_fun505__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_parse_fun505(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_parse_fun505(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_parse_fun505, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_parse_fun505(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_3_10138 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/stop>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x506 = kk_std_core_hnd__as_Ev(ev_3_10138, _ctx);
    kk_box_t _box_x234 = _con_x506->hnd;
    int32_t m_3 = _con_x506->marker;
    kk_main__stop h_3 = kk_main__stop_unbox(_box_x234, KK_BORROWED, _ctx);
    kk_main__stop_dup(h_3, _ctx);
    {
      struct kk_main__Hnd_stop* _con_x507 = kk_main__as_Hnd_stop(h_3, _ctx);
      kk_integer_t _pat_0_9 = _con_x507->_cfc;
      kk_std_core_hnd__clause0 _ctl_stop_0 = _con_x507->_ctl_stop;
      if kk_likely(kk_datatype_ptr_is_unique(h_3, _ctx)) {
        kk_integer_drop(_pat_0_9, _ctx);
        kk_datatype_ptr_free(h_3, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_stop_0, _ctx);
        kk_datatype_ptr_decref(h_3, _ctx);
      }
      {
        kk_function_t f_3 = _ctl_stop_0.clause;
        kk_function_t _x_x508 = f_3; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _x_x508, (_x_x508, m_3, ev_3_10138, _ctx), _ctx);
      }
    }
  }
}

kk_box_t kk_main_parse(kk_integer_t a_0, kk_context_t* _ctx) { /* forall<a> (a : int) -> <div,emit,read,stop> a */ 
  kk__tailcall: ;
  kk_ssize_t _b_x205_207 = (KK_IZ(1)); /*hnd/ev-index*/;
  kk_integer_t x_1_10127;
  kk_box_t _x_x489 = kk_std_core_hnd__open_at0(_b_x205_207, kk_main_new_parse_fun490(_ctx), _ctx); /*1000*/
  x_1_10127 = kk_integer_unbox(_x_x489, _ctx); /*main/chr*/
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_1_10127, _ctx);
    return kk_std_core_hnd_yield_extend(kk_main_new_parse_fun495(a_0, _ctx), _ctx);
  }
  {
    bool _match_x344 = kk_integer_eq_borrow(x_1_10127,(kk_integer_from_small(36)),kk_context()); /*bool*/;
    if (_match_x344) {
      kk_integer_drop(x_1_10127, _ctx);
      { // tailcall
        kk_integer_t _x_x497 = kk_integer_add_small_const(a_0, 1, _ctx); /*int*/
        a_0 = _x_x497;
        goto kk__tailcall;
      }
    }
    {
      bool _match_x345;
      bool _brw_x347 = kk_integer_eq_borrow(x_1_10127,(kk_integer_from_small(10)),kk_context()); /*bool*/;
      kk_integer_drop(x_1_10127, _ctx);
      _match_x345 = _brw_x347; /*bool*/
      if (_match_x345) {
        kk_ssize_t _b_x224_228 = (KK_IZ(0)); /*hnd/ev-index*/;
        kk_unit_t x_2_10132 = kk_Unit;
        kk_box_t _x_x498 = kk_std_core_hnd__open_at1(_b_x224_228, kk_main_new_parse_fun499(_ctx), kk_integer_box(a_0, _ctx), _ctx); /*1001*/
        kk_unit_unbox(_x_x498);
        if (kk_yielding(kk_context())) {
          return kk_std_core_hnd_yield_extend(kk_main_new_parse_fun502(_ctx), _ctx);
        }
        { // tailcall
          kk_integer_t _x_x504 = kk_integer_from_small(0); /*int*/
          a_0 = _x_x504;
          goto kk__tailcall;
        }
      }
      {
        kk_integer_drop(a_0, _ctx);
        return kk_std_core_hnd__open_at0((KK_IZ(2)), kk_main_new_parse_fun505(_ctx), _ctx);
      }
    }
  }
}


// lift anonymous function
struct kk_main_sum_fun512__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_sum_fun512(kk_function_t _fself, kk_box_t _b_x256, kk_context_t* _ctx);
static kk_function_t kk_main_new_sum_fun512(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_sum_fun512__t* _self = kk_function_alloc_as(struct kk_main_sum_fun512__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_sum_fun512, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_sum_fun515__t {
  struct kk_function_s _base;
  kk_box_t _b_x256;
  kk_ref_t loc;
};
static kk_unit_t kk_main_sum_fun515(kk_function_t _fself, kk_integer_t _y_x10044, kk_context_t* _ctx);
static kk_function_t kk_main_new_sum_fun515(kk_box_t _b_x256, kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_sum_fun515__t* _self = kk_function_alloc_as(struct kk_main_sum_fun515__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_sum_fun515, kk_context());
  _self->_b_x256 = _b_x256;
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_unit_t kk_main_sum_fun515(kk_function_t _fself, kk_integer_t _y_x10044, kk_context_t* _ctx) {
  struct kk_main_sum_fun515__t* _self = kk_function_as(struct kk_main_sum_fun515__t*, _fself, _ctx);
  kk_box_t _b_x256 = _self->_b_x256; /* 3480 */
  kk_ref_t loc = _self->loc; /* local-var<1508,int> */
  kk_drop_match(_self, {kk_box_dup(_b_x256, _ctx);kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_integer_t _b_x250_252;
  kk_integer_t _x_x516 = kk_integer_unbox(_b_x256, _ctx); /*int*/
  _b_x250_252 = kk_integer_add(_y_x10044,_x_x516,kk_context()); /*int*/
  kk_unit_t _brw_x341 = kk_Unit;
  kk_ref_set_borrow(loc,(kk_integer_box(_b_x250_252, _ctx)),kk_context());
  kk_ref_drop(loc, _ctx);
  return _brw_x341;
}


// lift anonymous function
struct kk_main_sum_fun519__t {
  struct kk_function_s _base;
  kk_function_t next_10143;
};
static kk_box_t kk_main_sum_fun519(kk_function_t _fself, kk_box_t _b_x254, kk_context_t* _ctx);
static kk_function_t kk_main_new_sum_fun519(kk_function_t next_10143, kk_context_t* _ctx) {
  struct kk_main_sum_fun519__t* _self = kk_function_alloc_as(struct kk_main_sum_fun519__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_sum_fun519, kk_context());
  _self->next_10143 = next_10143;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_sum_fun519(kk_function_t _fself, kk_box_t _b_x254, kk_context_t* _ctx) {
  struct kk_main_sum_fun519__t* _self = kk_function_as(struct kk_main_sum_fun519__t*, _fself, _ctx);
  kk_function_t next_10143 = _self->next_10143; /* (int) -> <local<1508>|1512> () */
  kk_drop_match(_self, {kk_function_dup(next_10143, _ctx);}, {}, _ctx)
  kk_unit_t _x_x520 = kk_Unit;
  kk_integer_t _x_x521 = kk_integer_unbox(_b_x254, _ctx); /*int*/
  kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10143, (next_10143, _x_x521, _ctx), _ctx);
  return kk_unit_box(_x_x520);
}
static kk_box_t kk_main_sum_fun512(kk_function_t _fself, kk_box_t _b_x256, kk_context_t* _ctx) {
  struct kk_main_sum_fun512__t* _self = kk_function_as(struct kk_main_sum_fun512__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<1508,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_integer_t x_10142;
  kk_box_t _x_x513;
  kk_ref_t _x_x514 = kk_ref_dup(loc, _ctx); /*local-var<1508,int>*/
  _x_x513 = kk_ref_get(_x_x514,kk_context()); /*3471*/
  x_10142 = kk_integer_unbox(_x_x513, _ctx); /*int*/
  kk_function_t next_10143 = kk_main_new_sum_fun515(_b_x256, loc, _ctx); /*(int) -> <local<1508>|1512> ()*/;
  kk_unit_t _x_x517 = kk_Unit;
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10142, _ctx);
    kk_box_t _x_x518 = kk_std_core_hnd_yield_extend(kk_main_new_sum_fun519(next_10143, _ctx), _ctx); /*3513*/
    kk_unit_unbox(_x_x518);
  }
  else {
    kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10143, (next_10143, x_10142, _ctx), _ctx);
  }
  return kk_unit_box(_x_x517);
}


// lift anonymous function
struct kk_main_sum_fun523__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_sum_fun523(kk_function_t _fself, kk_box_t _b_x264, kk_context_t* _ctx);
static kk_function_t kk_main_new_sum_fun523(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_sum_fun523, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_sum_fun523(kk_function_t _fself, kk_box_t _b_x264, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _b_x264;
}


// lift anonymous function
struct kk_main_sum_fun525__t {
  struct kk_function_s _base;
  kk_function_t action;
  kk_ref_t loc;
};
static kk_box_t kk_main_sum_fun525(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_sum_fun525(kk_function_t action, kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_sum_fun525__t* _self = kk_function_alloc_as(struct kk_main_sum_fun525__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_sum_fun525, kk_context());
  _self->action = action;
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_sum_fun526__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_sum_fun526(kk_function_t _fself, kk_box_t _b_x259, kk_context_t* _ctx);
static kk_function_t kk_main_new_sum_fun526(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_sum_fun526__t* _self = kk_function_alloc_as(struct kk_main_sum_fun526__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_sum_fun526, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_sum_fun526(kk_function_t _fself, kk_box_t _b_x259, kk_context_t* _ctx) {
  struct kk_main_sum_fun526__t* _self = kk_function_as(struct kk_main_sum_fun526__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<1508,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x259, _ctx);
  return kk_ref_get(loc,kk_context());
}
static kk_box_t kk_main_sum_fun525(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_sum_fun525__t* _self = kk_function_as(struct kk_main_sum_fun525__t*, _fself, _ctx);
  kk_function_t action = _self->action; /* () -> <main/emit|1512> () */
  kk_ref_t loc = _self->loc; /* local-var<1508,int> */
  kk_drop_match(_self, {kk_function_dup(action, _ctx);kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_unit_t x_0_10147 = kk_Unit;
  kk_function_call(kk_unit_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx);
  if (kk_yielding(kk_context())) {
    return kk_std_core_hnd_yield_extend(kk_main_new_sum_fun526(loc, _ctx), _ctx);
  }
  {
    return kk_ref_get(loc,kk_context());
  }
}

kk_integer_t kk_main_sum(kk_function_t action, kk_context_t* _ctx) { /* forall<e> (action : () -> <emit|e> ()) -> e int */ 
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<1508,int>*/;
  kk_main__emit _b_x261_265;
  kk_std_core_hnd__clause1 _x_x510;
  kk_function_t _x_x511;
  kk_ref_dup(loc, _ctx);
  _x_x511 = kk_main_new_sum_fun512(loc, _ctx); /*(3480) -> 3477 3481*/
  _x_x510 = kk_std_core_hnd_clause_tail1(_x_x511, _ctx); /*hnd/clause1<3480,3481,3479,3477,3478>*/
  _b_x261_265 = kk_main__new_Hnd_emit(kk_reuse_null, 0, kk_integer_from_small(1), _x_x510, _ctx); /*main/emit<<local<1508>|1512>,int>*/
  kk_integer_t res;
  kk_box_t _x_x522;
  kk_function_t _x_x524;
  kk_ref_dup(loc, _ctx);
  _x_x524 = kk_main_new_sum_fun525(action, loc, _ctx); /*() -> <main/emit|345> 3513*/
  _x_x522 = kk_main__handle_emit(_b_x261_265, kk_main_new_sum_fun523(_ctx), _x_x524, _ctx); /*346*/
  res = kk_integer_unbox(_x_x522, _ctx); /*int*/
  kk_box_t _x_x527 = kk_std_core_hnd_prompt_local_var(loc, kk_integer_box(res, _ctx), _ctx); /*3513*/
  return kk_integer_unbox(_x_x527, _ctx);
}


// lift anonymous function
struct kk_main_run_fun528__t {
  struct kk_function_s _base;
  kk_integer_t n;
};
static kk_unit_t kk_main_run_fun528(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun528(kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun528__t* _self = kk_function_alloc_as(struct kk_main_run_fun528__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun528, kk_context());
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun532__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun532(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun532(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun532, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun533__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun533(kk_function_t _fself, kk_function_t _b_x289, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun533(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun533, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun534__t {
  struct kk_function_s _base;
  kk_function_t _b_x289;
};
static kk_unit_t kk_main_run_fun534(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x290, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun534(kk_function_t _b_x289, kk_context_t* _ctx) {
  struct kk_main_run_fun534__t* _self = kk_function_alloc_as(struct kk_main_run_fun534__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun534, kk_context());
  _self->_b_x289 = _b_x289;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_unit_t kk_main_run_fun534(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x290, kk_context_t* _ctx) {
  struct kk_main_run_fun534__t* _self = kk_function_as(struct kk_main_run_fun534__t*, _fself, _ctx);
  kk_function_t _b_x289 = _self->_b_x289; /* (hnd/resume-result<3003,3005>) -> 3004 3005 */
  kk_drop_match(_self, {kk_function_dup(_b_x289, _ctx);}, {}, _ctx)
  kk_box_t _x_x535 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x289, (_b_x289, _b_x290, _ctx), _ctx); /*3005*/
  return kk_unit_unbox(_x_x535);
}


// lift anonymous function
struct kk_main_run_fun536__t {
  struct kk_function_s _base;
};
static kk_unit_t kk_main_run_fun536(kk_function_t _fself, kk_unit_t ___wildcard_x730__55, kk_function_t r, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun536(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun536, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_unit_t kk_main_run_fun536(kk_function_t _fself, kk_unit_t ___wildcard_x730__55, kk_function_t r, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_drop(r, _ctx);
  return kk_Unit;
}


// lift anonymous function
struct kk_main_run_fun537__t {
  struct kk_function_s _base;
  kk_function_t _b_x281_302;
};
static kk_box_t kk_main_run_fun537(kk_function_t _fself, kk_box_t _b_x283, kk_function_t _b_x284, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun537(kk_function_t _b_x281_302, kk_context_t* _ctx) {
  struct kk_main_run_fun537__t* _self = kk_function_alloc_as(struct kk_main_run_fun537__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun537, kk_context());
  _self->_b_x281_302 = _b_x281_302;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun540__t {
  struct kk_function_s _base;
  kk_function_t _b_x284;
};
static kk_unit_t kk_main_run_fun540(kk_function_t _fself, kk_box_t _b_x285, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun540(kk_function_t _b_x284, kk_context_t* _ctx) {
  struct kk_main_run_fun540__t* _self = kk_function_alloc_as(struct kk_main_run_fun540__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun540, kk_context());
  _self->_b_x284 = _b_x284;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_unit_t kk_main_run_fun540(kk_function_t _fself, kk_box_t _b_x285, kk_context_t* _ctx) {
  struct kk_main_run_fun540__t* _self = kk_function_as(struct kk_main_run_fun540__t*, _fself, _ctx);
  kk_function_t _b_x284 = _self->_b_x284; /* (3004) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x284, _ctx);}, {}, _ctx)
  kk_box_t _x_x541 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x284, (_b_x284, _b_x285, _ctx), _ctx); /*3006*/
  return kk_unit_unbox(_x_x541);
}
static kk_box_t kk_main_run_fun537(kk_function_t _fself, kk_box_t _b_x283, kk_function_t _b_x284, kk_context_t* _ctx) {
  struct kk_main_run_fun537__t* _self = kk_function_as(struct kk_main_run_fun537__t*, _fself, _ctx);
  kk_function_t _b_x281_302 = _self->_b_x281_302; /* ((), r : (717) -> <div,main/emit> ()) -> <div,main/emit> () */
  kk_drop_match(_self, {kk_function_dup(_b_x281_302, _ctx);}, {}, _ctx)
  kk_unit_t _x_x538 = kk_Unit;
  kk_unit_t _x_x539 = kk_Unit;
  kk_unit_unbox(_b_x283);
  kk_function_call(kk_unit_t, (kk_function_t, kk_unit_t, kk_function_t, kk_context_t*), _b_x281_302, (_b_x281_302, _x_x539, kk_main_new_run_fun540(_b_x284, _ctx), _ctx), _ctx);
  return kk_unit_box(_x_x538);
}


// lift anonymous function
struct kk_main_run_fun542__t {
  struct kk_function_s _base;
  kk_function_t _b_x282_303;
};
static kk_box_t kk_main_run_fun542(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x286, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun542(kk_function_t _b_x282_303, kk_context_t* _ctx) {
  struct kk_main_run_fun542__t* _self = kk_function_alloc_as(struct kk_main_run_fun542__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun542, kk_context());
  _self->_b_x282_303 = _b_x282_303;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun542(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x286, kk_context_t* _ctx) {
  struct kk_main_run_fun542__t* _self = kk_function_as(struct kk_main_run_fun542__t*, _fself, _ctx);
  kk_function_t _b_x282_303 = _self->_b_x282_303; /* (hnd/resume-result<717,()>) -> <div,main/emit> () */
  kk_drop_match(_self, {kk_function_dup(_b_x282_303, _ctx);}, {}, _ctx)
  kk_unit_t _x_x543 = kk_Unit;
  kk_function_call(kk_unit_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x282_303, (_b_x282_303, _b_x286, _ctx), _ctx);
  return kk_unit_box(_x_x543);
}
static kk_box_t kk_main_run_fun533(kk_function_t _fself, kk_function_t _b_x289, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_t k_305 = kk_main_new_run_fun534(_b_x289, _ctx); /*(hnd/resume-result<717,()>) -> <div,main/emit> ()*/;
  kk_unit_t _b_x280_301 = kk_Unit;
  kk_function_t _b_x281_302 = kk_main_new_run_fun536(_ctx); /*((), r : (717) -> <div,main/emit> ()) -> <div,main/emit> ()*/;
  kk_function_t _b_x282_303 = k_305; /*(hnd/resume-result<717,()>) -> <div,main/emit> ()*/;
  return kk_std_core_hnd_protect(kk_unit_box(_b_x280_301), kk_main_new_run_fun537(_b_x281_302, _ctx), kk_main_new_run_fun542(_b_x282_303, _ctx), _ctx);
}
static kk_box_t kk_main_run_fun532(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x730__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_main_new_run_fun533(_ctx), _ctx);
}


// lift anonymous function
struct kk_main_run_fun544__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun544(kk_function_t _fself, kk_box_t _b_x295, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun544(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun544, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun544(kk_function_t _fself, kk_box_t _b_x295, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_306 = kk_Unit;
  kk_unit_unbox(_b_x295);
  return kk_unit_box(_x_306);
}


// lift anonymous function
struct kk_main_run_fun545__t {
  struct kk_function_s _base;
  kk_integer_t n;
};
static kk_box_t kk_main_run_fun545(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun545(kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun545__t* _self = kk_function_alloc_as(struct kk_main_run_fun545__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun545, kk_context());
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun547__t {
  struct kk_function_s _base;
};
static kk_unit_t kk_main_run_fun547(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun547(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun547, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_unit_t kk_main_run_fun547(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_box_t _x_x548 = kk_main_parse(kk_integer_from_small(0), _ctx); /*2498*/
  return kk_unit_unbox(_x_x548);
}
static kk_box_t kk_main_run_fun545(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun545__t* _self = kk_function_as(struct kk_main_run_fun545__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_unit_t _x_x546 = kk_Unit;
  kk_main_feed(n, kk_main_new_run_fun547(_ctx), _ctx);
  return kk_unit_box(_x_x546);
}
static kk_unit_t kk_main_run_fun528(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun528__t* _self = kk_function_as(struct kk_main_run_fun528__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_box_t _x_x529;
  kk_main__stop _x_x530;
  kk_std_core_hnd__clause0 _x_x531 = kk_std_core_hnd__new_Clause0(kk_main_new_run_fun532(_ctx), _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
  _x_x530 = kk_main__new_Hnd_stop(kk_reuse_null, 0, kk_integer_from_small(3), _x_x531, _ctx); /*main/stop<23,24>*/
  _x_x529 = kk_main__handle_stop(_x_x530, kk_main_new_run_fun544(_ctx), kk_main_new_run_fun545(n, _ctx), _ctx); /*444*/
  return kk_unit_unbox(_x_x529);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  return kk_main_sum(kk_main_new_run_fun528(n, _ctx), _ctx);
}


// lift anonymous function
struct kk_main_main_fun552__t {
  struct kk_function_s _base;
  kk_std_core_types__maybe m_10003;
};
static kk_unit_t kk_main_main_fun552(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun552(kk_std_core_types__maybe m_10003, kk_context_t* _ctx) {
  struct kk_main_main_fun552__t* _self = kk_function_alloc_as(struct kk_main_main_fun552__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_main_fun552, kk_context());
  _self->m_10003 = m_10003;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_main_fun556__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun556(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun556(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun556, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_main_fun557__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun557(kk_function_t _fself, kk_function_t _b_x317, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun557(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun557, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_main_fun558__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun558(kk_function_t _fself, kk_box_t _b_x311, kk_function_t _b_x312, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun558(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun558, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_main_fun558(kk_function_t _fself, kk_box_t _b_x311, kk_function_t _b_x312, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_box_drop(_b_x311, _ctx);
  kk_function_drop(_b_x312, _ctx);
  return kk_unit_box(kk_Unit);
}
static kk_box_t kk_main_main_fun557(kk_function_t _fself, kk_function_t _b_x317, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_hnd_protect(kk_unit_box(kk_Unit), kk_main_new_main_fun558(_ctx), _b_x317, _ctx);
}
static kk_box_t kk_main_main_fun556(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x730__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_main_new_main_fun557(_ctx), _ctx);
}


// lift anonymous function
struct kk_main_main_fun559__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun559(kk_function_t _fself, kk_box_t _b_x324, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun559(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun559, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_main_fun559(kk_function_t _fself, kk_box_t _b_x324, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _b_x324;
}


// lift anonymous function
struct kk_main_main_fun560__t {
  struct kk_function_s _base;
  kk_std_core_types__maybe m_10003;
};
static kk_box_t kk_main_main_fun560(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun560(kk_std_core_types__maybe m_10003, kk_context_t* _ctx) {
  struct kk_main_main_fun560__t* _self = kk_function_alloc_as(struct kk_main_main_fun560__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_main_fun560, kk_context());
  _self->m_10003 = m_10003;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_main_fun563__t {
  struct kk_function_s _base;
};
static kk_unit_t kk_main_main_fun563(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun563(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun563, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_unit_t kk_main_main_fun563(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_box_t _x_x564 = kk_main_parse(kk_integer_from_small(0), _ctx); /*2498*/
  return kk_unit_unbox(_x_x564);
}
static kk_box_t kk_main_main_fun560(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_main_fun560__t* _self = kk_function_as(struct kk_main_main_fun560__t*, _fself, _ctx);
  kk_std_core_types__maybe m_10003 = _self->m_10003; /* maybe<int> */
  kk_drop_match(_self, {kk_std_core_types__maybe_dup(m_10003, _ctx);}, {}, _ctx)
  kk_unit_t _x_x561 = kk_Unit;
  kk_integer_t _x_x562;
  if (kk_std_core_types__is_Nothing(m_10003, _ctx)) {
    _x_x562 = kk_integer_from_small(10); /*int*/
  }
  else {
    kk_box_t _box_x319 = m_10003._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x319, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10003, _ctx);
    _x_x562 = x; /*int*/
  }
  kk_main_feed(_x_x562, kk_main_new_main_fun563(_ctx), _ctx);
  return kk_unit_box(_x_x561);
}
static kk_unit_t kk_main_main_fun552(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_main_fun552__t* _self = kk_function_as(struct kk_main_main_fun552__t*, _fself, _ctx);
  kk_std_core_types__maybe m_10003 = _self->m_10003; /* maybe<int> */
  kk_drop_match(_self, {kk_std_core_types__maybe_dup(m_10003, _ctx);}, {}, _ctx)
  kk_box_t _x_x553;
  kk_main__stop _x_x554;
  kk_std_core_hnd__clause0 _x_x555 = kk_std_core_hnd__new_Clause0(kk_main_new_main_fun556(_ctx), _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
  _x_x554 = kk_main__new_Hnd_stop(kk_reuse_null, 0, kk_integer_from_small(3), _x_x555, _ctx); /*main/stop<23,24>*/
  _x_x553 = kk_main__handle_stop(_x_x554, kk_main_new_main_fun559(_ctx), kk_main_new_main_fun560(m_10003, _ctx), _ctx); /*444*/
  return kk_unit_unbox(_x_x553);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10005 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10003;
  kk_string_t _x_x549;
  if (kk_std_core_types__is_Cons(xs_10005, _ctx)) {
    struct kk_std_core_types_Cons* _con_x550 = kk_std_core_types__as_Cons(xs_10005, _ctx);
    kk_box_t _box_x307 = _con_x550->head;
    kk_std_core_types__list _pat_0_0 = _con_x550->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x307);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10005, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10005, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10005, _ctx);
    }
    _x_x549 = x_0; /*string*/
  }
  else {
    _x_x549 = kk_string_empty(); /*string*/
  }
  m_10003 = kk_std_core_int_parse_int(_x_x549, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r_0 = kk_main_sum(kk_main_new_main_fun552(m_10003, _ctx), _ctx); /*int*/;
  kk_string_t _x_x565 = kk_std_core_int_show(r_0, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x565, _ctx); return kk_Unit;
}

// initialization
void kk_main__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_hnd__init(_ctx);
  kk_std_core_exn__init(_ctx);
  kk_std_core_bool__init(_ctx);
  kk_std_core_order__init(_ctx);
  kk_std_core_char__init(_ctx);
  kk_std_core_int__init(_ctx);
  kk_std_core_vector__init(_ctx);
  kk_std_core_string__init(_ctx);
  kk_std_core_sslice__init(_ctx);
  kk_std_core_list__init(_ctx);
  kk_std_core_maybe__init(_ctx);
  kk_std_core_either__init(_ctx);
  kk_std_core_tuple__init(_ctx);
  kk_std_core_show__init(_ctx);
  kk_std_core_debug__init(_ctx);
  kk_std_core_delayed__init(_ctx);
  kk_std_core_console__init(_ctx);
  kk_std_core__init(_ctx);
  kk_std_os_env__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
  {
    kk_string_t _x_x384;
    kk_define_string_literal(, _s_x385, 9, "emit@main", _ctx)
    _x_x384 = kk_string_dup(_s_x385, _ctx); /*string*/
    kk_main__tag_emit = kk_std_core_hnd__new_Htag(_x_x384, _ctx); /*hnd/htag<main/emit>*/
  }
  {
    kk_string_t _x_x387;
    kk_define_string_literal(, _s_x388, 9, "read@main", _ctx)
    _x_x387 = kk_string_dup(_s_x388, _ctx); /*string*/
    kk_main__tag_read = kk_std_core_hnd__new_Htag(_x_x387, _ctx); /*hnd/htag<main/read>*/
  }
  {
    kk_string_t _x_x390;
    kk_define_string_literal(, _s_x391, 9, "stop@main", _ctx)
    _x_x390 = kk_string_dup(_s_x391, _ctx); /*string*/
    kk_main__tag_stop = kk_std_core_hnd__new_Htag(_x_x390, _ctx); /*hnd/htag<main/stop>*/
  }
}

// termination
void kk_main__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_hnd__htag_drop(kk_main__tag_stop, _ctx);
  kk_std_core_hnd__htag_drop(kk_main__tag_read, _ctx);
  kk_std_core_hnd__htag_drop(kk_main__tag_emit, _ctx);
  kk_std_os_env__done(_ctx);
  kk_std_core__done(_ctx);
  kk_std_core_console__done(_ctx);
  kk_std_core_delayed__done(_ctx);
  kk_std_core_debug__done(_ctx);
  kk_std_core_show__done(_ctx);
  kk_std_core_tuple__done(_ctx);
  kk_std_core_either__done(_ctx);
  kk_std_core_maybe__done(_ctx);
  kk_std_core_list__done(_ctx);
  kk_std_core_sslice__done(_ctx);
  kk_std_core_string__done(_ctx);
  kk_std_core_vector__done(_ctx);
  kk_std_core_int__done(_ctx);
  kk_std_core_char__done(_ctx);
  kk_std_core_order__done(_ctx);
  kk_std_core_bool__done(_ctx);
  kk_std_core_exn__done(_ctx);
  kk_std_core_hnd__done(_ctx);
  kk_std_core_types__done(_ctx);
}
