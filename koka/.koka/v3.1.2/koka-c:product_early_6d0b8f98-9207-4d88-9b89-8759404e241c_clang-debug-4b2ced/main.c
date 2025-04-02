// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:abort`

kk_std_core_hnd__htag kk_main__tag_abort;
 
// handler for the effect `:abort`

kk_box_t kk_main__handle_abort(kk_main__abort hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : abort<e,b>, ret : (res : a) -> e b, action : () -> <abort|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x129 = kk_std_core_hnd__htag_dup(kk_main__tag_abort, _ctx); /*hnd/htag<main/abort>*/
  return kk_std_core_hnd__hhandle(_x_x129, kk_main__abort_box(hnd, _ctx), ret, action, _ctx);
}

kk_std_core_types__list kk_main__trmc_enumerate(kk_integer_t i, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* (i : int, ctx<list<int>>) -> div list<int> */ 
  kk__tailcall: ;
  bool _match_x120 = kk_integer_lt_borrow(i,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x120) {
    kk_integer_drop(i, _ctx);
    kk_box_t _x_x133 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x133, KK_OWNED, _ctx);
  }
  {
    kk_std_core_types__list _trmc_x10021 = kk_datatype_null(); /*list<int>*/;
    kk_std_core_types__list _trmc_x10022;
    kk_box_t _x_x134;
    kk_integer_t _x_x135 = kk_integer_dup(i, _ctx); /*int*/
    _x_x134 = kk_integer_box(_x_x135, _ctx); /*1024*/
    _trmc_x10022 = kk_std_core_types__new_Cons(kk_reuse_null, 0, _x_x134, _trmc_x10021, _ctx); /*list<int>*/
    kk_field_addr_t _b_x27_32 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10022, _ctx)->tail, _ctx); /*@field-addr<list<int>>*/;
    { // tailcall
      kk_integer_t _x_x136 = kk_integer_add_small_const(i, -1, _ctx); /*int*/
      kk_std_core_types__cctx _x_x137 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10022, _ctx)),_b_x27_32,kk_context()); /*ctx<0>*/
      i = _x_x136;
      _acc = _x_x137;
      goto kk__tailcall;
    }
  }
}

kk_std_core_types__list kk_main_enumerate(kk_integer_t i_0, kk_context_t* _ctx) { /* (i : int) -> div list<int> */ 
  kk_std_core_types__cctx _x_x138 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_main__trmc_enumerate(i_0, _x_x138, _ctx);
}
 
// monadic lift

kk_integer_t kk_main__mlift_product_10032(kk_integer_t y, kk_integer_t _y_x10026, kk_context_t* _ctx) { /* (y : int, int) -> abort int */ 
  return kk_integer_mul(y,_y_x10026,kk_context());
}


// lift anonymous function
struct kk_main_product_fun144__t {
  struct kk_function_s _base;
  kk_integer_t y_0;
};
static kk_box_t kk_main_product_fun144(kk_function_t _fself, kk_box_t _b_x46, kk_context_t* _ctx);
static kk_function_t kk_main_new_product_fun144(kk_integer_t y_0, kk_context_t* _ctx) {
  struct kk_main_product_fun144__t* _self = kk_function_alloc_as(struct kk_main_product_fun144__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_product_fun144, kk_context());
  _self->y_0 = y_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_product_fun144(kk_function_t _fself, kk_box_t _b_x46, kk_context_t* _ctx) {
  struct kk_main_product_fun144__t* _self = kk_function_as(struct kk_main_product_fun144__t*, _fself, _ctx);
  kk_integer_t y_0 = _self->y_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(y_0, _ctx);}, {}, _ctx)
  kk_integer_t _y_x10026_0_48 = kk_integer_unbox(_b_x46, _ctx); /*int*/;
  kk_integer_t _x_x145 = kk_main__mlift_product_10032(y_0, _y_x10026_0_48, _ctx); /*int*/
  return kk_integer_box(_x_x145, _ctx);
}

kk_integer_t kk_main_product(kk_std_core_types__list xs, kk_context_t* _ctx) { /* (xs : list<int>) -> abort int */ 
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    return kk_integer_from_small(0);
  }
  {
    struct kk_std_core_types_Cons* _con_x139 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x36 = _con_x139->head;
    kk_std_core_types__list ys = _con_x139->tail;
    kk_integer_t y_0 = kk_integer_unbox(_box_x36, _ctx);
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_integer_dup(y_0, _ctx);
      kk_std_core_types__list_dup(ys, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    bool _match_x118 = kk_integer_eq_borrow(y_0,(kk_integer_from_small(0)),kk_context()); /*bool*/;
    if (_match_x118) {
      kk_std_core_types__list_drop(ys, _ctx);
      kk_integer_drop(y_0, _ctx);
      kk_std_core_hnd__ev ev_10037 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/abort>*/;
      kk_box_t _x_x140;
      {
        struct kk_std_core_hnd_Ev* _con_x141 = kk_std_core_hnd__as_Ev(ev_10037, _ctx);
        kk_box_t _box_x37 = _con_x141->hnd;
        int32_t m = _con_x141->marker;
        kk_main__abort h = kk_main__abort_unbox(_box_x37, KK_BORROWED, _ctx);
        kk_main__abort_dup(h, _ctx);
        {
          struct kk_main__Hnd_abort* _con_x142 = kk_main__as_Hnd_abort(h, _ctx);
          kk_integer_t _pat_0_1 = _con_x142->_cfc;
          kk_std_core_hnd__clause1 _ctl_done = _con_x142->_ctl_done;
          if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
            kk_integer_drop(_pat_0_1, _ctx);
            kk_datatype_ptr_free(h, _ctx);
          }
          else {
            kk_std_core_hnd__clause1_dup(_ctl_done, _ctx);
            kk_datatype_ptr_decref(h, _ctx);
          }
          {
            kk_function_t _fun_unbox_x41 = _ctl_done.clause;
            _x_x140 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x41, (_fun_unbox_x41, m, ev_10037, kk_integer_box(kk_integer_from_small(0), _ctx), _ctx), _ctx); /*1010*/
          }
        }
      }
      return kk_integer_unbox(_x_x140, _ctx);
    }
    {
      kk_integer_t x_0_10040 = kk_main_product(ys, _ctx); /*int*/;
      if (kk_yielding(kk_context())) {
        kk_integer_drop(x_0_10040, _ctx);
        kk_box_t _x_x143 = kk_std_core_hnd_yield_extend(kk_main_new_product_fun144(y_0, _ctx), _ctx); /*3003*/
        return kk_integer_unbox(_x_x143, _ctx);
      }
      {
        return kk_integer_mul(y_0,x_0_10040,kk_context());
      }
    }
  }
}


// lift anonymous function
struct kk_main_run_product_fun147__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_product_fun147(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun147(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_product_fun147, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_product_fun148__t {
  struct kk_function_s _base;
  kk_integer_t x;
};
static kk_box_t kk_main_run_product_fun148(kk_function_t _fself, kk_function_t _b_x58, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun148(kk_integer_t x, kk_context_t* _ctx) {
  struct kk_main_run_product_fun148__t* _self = kk_function_alloc_as(struct kk_main_run_product_fun148__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_product_fun148, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_product_fun149__t {
  struct kk_function_s _base;
  kk_function_t _b_x58;
};
static kk_integer_t kk_main_run_product_fun149(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x59, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun149(kk_function_t _b_x58, kk_context_t* _ctx) {
  struct kk_main_run_product_fun149__t* _self = kk_function_alloc_as(struct kk_main_run_product_fun149__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_product_fun149, kk_context());
  _self->_b_x58 = _b_x58;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_product_fun149(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x59, kk_context_t* _ctx) {
  struct kk_main_run_product_fun149__t* _self = kk_function_as(struct kk_main_run_product_fun149__t*, _fself, _ctx);
  kk_function_t _b_x58 = _self->_b_x58; /* (hnd/resume-result<3004,3006>) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x58, _ctx);}, {}, _ctx)
  kk_box_t _x_x150 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x58, (_b_x58, _b_x59, _ctx), _ctx); /*3006*/
  return kk_integer_unbox(_x_x150, _ctx);
}


// lift anonymous function
struct kk_main_run_product_fun151__t {
  struct kk_function_s _base;
};
static kk_integer_t kk_main_run_product_fun151(kk_function_t _fself, kk_integer_t r, kk_function_t resume, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun151(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_product_fun151, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_integer_t kk_main_run_product_fun151(kk_function_t _fself, kk_integer_t r, kk_function_t resume, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_drop(resume, _ctx);
  return r;
}


// lift anonymous function
struct kk_main_run_product_fun152__t {
  struct kk_function_s _base;
  kk_function_t _b_x50_75;
};
static kk_box_t kk_main_run_product_fun152(kk_function_t _fself, kk_box_t _b_x52, kk_function_t _b_x53, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun152(kk_function_t _b_x50_75, kk_context_t* _ctx) {
  struct kk_main_run_product_fun152__t* _self = kk_function_alloc_as(struct kk_main_run_product_fun152__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_product_fun152, kk_context());
  _self->_b_x50_75 = _b_x50_75;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_product_fun155__t {
  struct kk_function_s _base;
  kk_function_t _b_x53;
};
static kk_integer_t kk_main_run_product_fun155(kk_function_t _fself, kk_box_t _b_x54, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun155(kk_function_t _b_x53, kk_context_t* _ctx) {
  struct kk_main_run_product_fun155__t* _self = kk_function_alloc_as(struct kk_main_run_product_fun155__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_product_fun155, kk_context());
  _self->_b_x53 = _b_x53;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_product_fun155(kk_function_t _fself, kk_box_t _b_x54, kk_context_t* _ctx) {
  struct kk_main_run_product_fun155__t* _self = kk_function_as(struct kk_main_run_product_fun155__t*, _fself, _ctx);
  kk_function_t _b_x53 = _self->_b_x53; /* (3005) -> 3006 3007 */
  kk_drop_match(_self, {kk_function_dup(_b_x53, _ctx);}, {}, _ctx)
  kk_box_t _x_x156 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x53, (_b_x53, _b_x54, _ctx), _ctx); /*3007*/
  return kk_integer_unbox(_x_x156, _ctx);
}
static kk_box_t kk_main_run_product_fun152(kk_function_t _fself, kk_box_t _b_x52, kk_function_t _b_x53, kk_context_t* _ctx) {
  struct kk_main_run_product_fun152__t* _self = kk_function_as(struct kk_main_run_product_fun152__t*, _fself, _ctx);
  kk_function_t _b_x50_75 = _self->_b_x50_75; /* (r : int, resume : (422) -> int) -> int */
  kk_drop_match(_self, {kk_function_dup(_b_x50_75, _ctx);}, {}, _ctx)
  kk_integer_t _x_x153;
  kk_integer_t _x_x154 = kk_integer_unbox(_b_x52, _ctx); /*int*/
  _x_x153 = kk_function_call(kk_integer_t, (kk_function_t, kk_integer_t, kk_function_t, kk_context_t*), _b_x50_75, (_b_x50_75, _x_x154, kk_main_new_run_product_fun155(_b_x53, _ctx), _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x153, _ctx);
}


// lift anonymous function
struct kk_main_run_product_fun157__t {
  struct kk_function_s _base;
  kk_function_t _b_x51_76;
};
static kk_box_t kk_main_run_product_fun157(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x55, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun157(kk_function_t _b_x51_76, kk_context_t* _ctx) {
  struct kk_main_run_product_fun157__t* _self = kk_function_alloc_as(struct kk_main_run_product_fun157__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_product_fun157, kk_context());
  _self->_b_x51_76 = _b_x51_76;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_product_fun157(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x55, kk_context_t* _ctx) {
  struct kk_main_run_product_fun157__t* _self = kk_function_as(struct kk_main_run_product_fun157__t*, _fself, _ctx);
  kk_function_t _b_x51_76 = _self->_b_x51_76; /* (hnd/resume-result<422,int>) -> int */
  kk_drop_match(_self, {kk_function_dup(_b_x51_76, _ctx);}, {}, _ctx)
  kk_integer_t _x_x158 = kk_function_call(kk_integer_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x51_76, (_b_x51_76, _b_x55, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x158, _ctx);
}
static kk_box_t kk_main_run_product_fun148(kk_function_t _fself, kk_function_t _b_x58, kk_context_t* _ctx) {
  struct kk_main_run_product_fun148__t* _self = kk_function_as(struct kk_main_run_product_fun148__t*, _fself, _ctx);
  kk_integer_t x = _self->x; /* int */
  kk_drop_match(_self, {kk_integer_dup(x, _ctx);}, {}, _ctx)
  kk_function_t k_77 = kk_main_new_run_product_fun149(_b_x58, _ctx); /*(hnd/resume-result<422,int>) -> int*/;
  kk_integer_t _b_x49_74 = x; /*int*/;
  kk_function_t _b_x50_75 = kk_main_new_run_product_fun151(_ctx); /*(r : int, resume : (422) -> int) -> int*/;
  kk_function_t _b_x51_76 = k_77; /*(hnd/resume-result<422,int>) -> int*/;
  return kk_std_core_hnd_protect(kk_integer_box(_b_x49_74, _ctx), kk_main_new_run_product_fun152(_b_x50_75, _ctx), kk_main_new_run_product_fun157(_b_x51_76, _ctx), _ctx);
}
static kk_box_t kk_main_run_product_fun147(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x681__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_main_new_run_product_fun148(x, _ctx), _ctx);
}


// lift anonymous function
struct kk_main_run_product_fun161__t {
  struct kk_function_s _base;
  kk_function_t _b_x60_71;
};
static kk_box_t kk_main_run_product_fun161(kk_function_t _fself, int32_t _b_x61, kk_std_core_hnd__ev _b_x62, kk_box_t _b_x63, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun161(kk_function_t _b_x60_71, kk_context_t* _ctx) {
  struct kk_main_run_product_fun161__t* _self = kk_function_alloc_as(struct kk_main_run_product_fun161__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_product_fun161, kk_context());
  _self->_b_x60_71 = _b_x60_71;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_product_fun161(kk_function_t _fself, int32_t _b_x61, kk_std_core_hnd__ev _b_x62, kk_box_t _b_x63, kk_context_t* _ctx) {
  struct kk_main_run_product_fun161__t* _self = kk_function_as(struct kk_main_run_product_fun161__t*, _fself, _ctx);
  kk_function_t _b_x60_71 = _self->_b_x60_71; /* (m : hnd/marker<total,int>, hnd/ev<main/abort>, x : int) -> 422 */
  kk_drop_match(_self, {kk_function_dup(_b_x60_71, _ctx);}, {}, _ctx)
  kk_integer_t _x_x162 = kk_integer_unbox(_b_x63, _ctx); /*int*/
  return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_integer_t, kk_context_t*), _b_x60_71, (_b_x60_71, _b_x61, _b_x62, _x_x162, _ctx), _ctx);
}


// lift anonymous function
struct kk_main_run_product_fun163__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_product_fun163(kk_function_t _fself, kk_box_t _b_x67, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun163(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_product_fun163, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_product_fun163(kk_function_t _fself, kk_box_t _b_x67, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_78 = kk_integer_unbox(_b_x67, _ctx); /*int*/;
  return kk_integer_box(_x_78, _ctx);
}


// lift anonymous function
struct kk_main_run_product_fun164__t {
  struct kk_function_s _base;
  kk_std_core_types__list xs;
};
static kk_box_t kk_main_run_product_fun164(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_product_fun164(kk_std_core_types__list xs, kk_context_t* _ctx) {
  struct kk_main_run_product_fun164__t* _self = kk_function_alloc_as(struct kk_main_run_product_fun164__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_product_fun164, kk_context());
  _self->xs = xs;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_product_fun164(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_product_fun164__t* _self = kk_function_as(struct kk_main_run_product_fun164__t*, _fself, _ctx);
  kk_std_core_types__list xs = _self->xs; /* list<int> */
  kk_drop_match(_self, {kk_std_core_types__list_dup(xs, _ctx);}, {}, _ctx)
  kk_integer_t _x_x165 = kk_main_product(xs, _ctx); /*int*/
  return kk_integer_box(_x_x165, _ctx);
}

kk_integer_t kk_main_run_product(kk_std_core_types__list xs, kk_context_t* _ctx) { /* (xs : list<int>) -> int */ 
  kk_box_t _x_x146;
  kk_function_t _b_x60_71 = kk_main_new_run_product_fun147(_ctx); /*(m : hnd/marker<total,int>, hnd/ev<main/abort>, x : int) -> 422*/;
  kk_main__abort _x_x159;
  kk_std_core_hnd__clause1 _x_x160 = kk_std_core_hnd__new_Clause1(kk_main_new_run_product_fun161(_b_x60_71, _ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x159 = kk_main__new_Hnd_abort(kk_reuse_null, 0, kk_integer_from_small(3), _x_x160, _ctx); /*main/abort<7,8>*/
  _x_x146 = kk_main__handle_abort(_x_x159, kk_main_new_run_product_fun163(_ctx), kk_main_new_run_product_fun164(xs, _ctx), _ctx); /*171*/
  return kk_integer_unbox(_x_x146, _ctx);
}
 
// lifted local: run, loop


// lift anonymous function
struct kk_main__lift_run_586_fun169__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_586_fun169(kk_function_t _fself, int32_t _b_x91, kk_std_core_hnd__ev _b_x92, kk_box_t _b_x93, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_586_fun169(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_586_fun169, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main__lift_run_586_fun170__t {
  struct kk_function_s _base;
  kk_box_t _b_x93;
};
static kk_box_t kk_main__lift_run_586_fun170(kk_function_t _fself, kk_function_t _b_x88, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_586_fun170(kk_box_t _b_x93, kk_context_t* _ctx) {
  struct kk_main__lift_run_586_fun170__t* _self = kk_function_alloc_as(struct kk_main__lift_run_586_fun170__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__lift_run_586_fun170, kk_context());
  _self->_b_x93 = _b_x93;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main__lift_run_586_fun171__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_586_fun171(kk_function_t _fself, kk_box_t _b_x82, kk_function_t _b_x83, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_586_fun171(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_586_fun171, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__lift_run_586_fun171(kk_function_t _fself, kk_box_t _b_x82, kk_function_t _b_x83, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_drop(_b_x83, _ctx);
  return _b_x82;
}
static kk_box_t kk_main__lift_run_586_fun170(kk_function_t _fself, kk_function_t _b_x88, kk_context_t* _ctx) {
  struct kk_main__lift_run_586_fun170__t* _self = kk_function_as(struct kk_main__lift_run_586_fun170__t*, _fself, _ctx);
  kk_box_t _b_x93 = _self->_b_x93; /* 1015 */
  kk_drop_match(_self, {kk_box_dup(_b_x93, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect(_b_x93, kk_main__new_lift_run_586_fun171(_ctx), _b_x88, _ctx);
}
static kk_box_t kk_main__lift_run_586_fun169(kk_function_t _fself, int32_t _b_x91, kk_std_core_hnd__ev _b_x92, kk_box_t _b_x93, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(_b_x92, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(_b_x91, kk_main__new_lift_run_586_fun170(_b_x93, _ctx), _ctx);
}


// lift anonymous function
struct kk_main__lift_run_586_fun172__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_586_fun172(kk_function_t _fself, kk_box_t _b_x97, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_586_fun172(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_586_fun172, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__lift_run_586_fun172(kk_function_t _fself, kk_box_t _b_x97, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _b_x97;
}


// lift anonymous function
struct kk_main__lift_run_586_fun174__t {
  struct kk_function_s _base;
  kk_std_core_types__list xs;
};
static kk_box_t kk_main__lift_run_586_fun174(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_586_fun174(kk_std_core_types__list xs, kk_context_t* _ctx) {
  struct kk_main__lift_run_586_fun174__t* _self = kk_function_alloc_as(struct kk_main__lift_run_586_fun174__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__lift_run_586_fun174, kk_context());
  _self->xs = xs;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__lift_run_586_fun174(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main__lift_run_586_fun174__t* _self = kk_function_as(struct kk_main__lift_run_586_fun174__t*, _fself, _ctx);
  kk_std_core_types__list xs = _self->xs; /* list<int> */
  kk_drop_match(_self, {kk_std_core_types__list_dup(xs, _ctx);}, {}, _ctx)
  kk_integer_t _x_x175 = kk_main_product(xs, _ctx); /*int*/
  return kk_integer_box(_x_x175, _ctx);
}

kk_integer_t kk_main__lift_run_586(kk_std_core_types__list xs, kk_integer_t i, kk_integer_t a, kk_context_t* _ctx) { /* (xs : list<int>, i : int, a : int) -> div int */ 
  kk__tailcall: ;
  bool _match_x117 = kk_integer_eq_borrow(i,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x117) {
    kk_std_core_types__list_drop(xs, _ctx);
    kk_integer_drop(i, _ctx);
    return a;
  }
  {
    kk_integer_t i_0_10003 = kk_integer_add_small_const(i, -1, _ctx); /*int*/;
    kk_integer_t y_0_10008;
    kk_box_t _x_x166;
    kk_main__abort _x_x167;
    kk_std_core_hnd__clause1 _x_x168 = kk_std_core_hnd__new_Clause1(kk_main__new_lift_run_586_fun169(_ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
    _x_x167 = kk_main__new_Hnd_abort(kk_reuse_null, 0, kk_integer_from_small(3), _x_x168, _ctx); /*main/abort<7,8>*/
    kk_function_t _x_x173;
    kk_std_core_types__list_dup(xs, _ctx);
    _x_x173 = kk_main__new_lift_run_586_fun174(xs, _ctx); /*() -> <main/abort|170> 169*/
    _x_x166 = kk_main__handle_abort(_x_x167, kk_main__new_lift_run_586_fun172(_ctx), _x_x173, _ctx); /*171*/
    y_0_10008 = kk_integer_unbox(_x_x166, _ctx); /*int*/
    kk_integer_t a_0_10004 = kk_integer_add(a,y_0_10008,kk_context()); /*int*/;
    { // tailcall
      i = i_0_10003;
      a = a_0_10004;
      goto kk__tailcall;
    }
  }
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10014 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10012;
  kk_string_t _x_x176;
  if (kk_std_core_types__is_Cons(xs_10014, _ctx)) {
    struct kk_std_core_types_Cons* _con_x177 = kk_std_core_types__as_Cons(xs_10014, _ctx);
    kk_box_t _box_x115 = _con_x177->head;
    kk_std_core_types__list _pat_0_0 = _con_x177->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x115);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10014, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10014, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10014, _ctx);
    }
    _x_x176 = x_0; /*string*/
  }
  else {
    _x_x176 = kk_string_empty(); /*string*/
  }
  m_10012 = kk_std_core_int_parse_int(_x_x176, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_std_core_types__list xs_0 = kk_main_enumerate(kk_integer_from_small(1000), _ctx); /*list<int>*/;
  kk_integer_t r;
  kk_integer_t _x_x179;
  if (kk_std_core_types__is_Nothing(m_10012, _ctx)) {
    _x_x179 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x116 = m_10012._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x116, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10012, _ctx);
    _x_x179 = x; /*int*/
  }
  r = kk_main__lift_run_586(xs_0, _x_x179, kk_integer_from_small(0), _ctx); /*int*/
  kk_string_t _x_x180 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x180, _ctx); return kk_Unit;
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
    kk_string_t _x_x127;
    kk_define_string_literal(, _s_x128, 10, "abort@main", _ctx)
    _x_x127 = kk_string_dup(_s_x128, _ctx); /*string*/
    kk_main__tag_abort = kk_std_core_hnd__new_Htag(_x_x127, _ctx); /*hnd/htag<main/abort>*/
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
  kk_std_core_hnd__htag_drop(kk_main__tag_abort, _ctx);
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
