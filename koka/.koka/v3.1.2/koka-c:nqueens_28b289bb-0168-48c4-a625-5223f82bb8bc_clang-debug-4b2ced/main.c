// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:search`

kk_std_core_hnd__htag kk_main__tag_search;
 
// handler for the effect `:search`

kk_box_t kk_main__handle_search(kk_main__search hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : search<e,b>, ret : (res : a) -> e b, action : () -> <search|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x243 = kk_std_core_hnd__htag_dup(kk_main__tag_search, _ctx); /*hnd/htag<main/search>*/
  return kk_std_core_hnd__hhandle(_x_x243, kk_main__search_box(hnd, _ctx), ret, action, _ctx);
}

bool kk_main_safe(kk_integer_t queen, kk_integer_t diag, kk_std_core_types__list xs, kk_context_t* _ctx) { /* (queen : int, diag : int, xs : solution) -> bool */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    kk_integer_drop(queen, _ctx);
    kk_integer_drop(diag, _ctx);
    return true;
  }
  {
    struct kk_std_core_types_Cons* _con_x252 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x17 = _con_x252->head;
    kk_std_core_types__list qs = _con_x252->tail;
    kk_integer_t q = kk_integer_unbox(_box_x17, _ctx);
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_integer_dup(q, _ctx);
      kk_std_core_types__list_dup(qs, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    bool _match_x223 = kk_integer_neq_borrow(queen,q,kk_context()); /*bool*/;
    if (_match_x223) {
      bool _match_x224;
      kk_integer_t _brw_x228;
      kk_integer_t _x_x253 = kk_integer_dup(q, _ctx); /*int*/
      kk_integer_t _x_x254 = kk_integer_dup(diag, _ctx); /*int*/
      _brw_x228 = kk_integer_add(_x_x253,_x_x254,kk_context()); /*int*/
      bool _brw_x229 = kk_integer_neq_borrow(queen,_brw_x228,kk_context()); /*bool*/;
      kk_integer_drop(_brw_x228, _ctx);
      _match_x224 = _brw_x229; /*bool*/
      if (_match_x224) {
        bool _match_x225;
        kk_integer_t _brw_x226;
        kk_integer_t _x_x255 = kk_integer_dup(diag, _ctx); /*int*/
        _brw_x226 = kk_integer_sub(q,_x_x255,kk_context()); /*int*/
        bool _brw_x227 = kk_integer_neq_borrow(queen,_brw_x226,kk_context()); /*bool*/;
        kk_integer_drop(_brw_x226, _ctx);
        _match_x225 = _brw_x227; /*bool*/
        if (_match_x225) { // tailcall
                           kk_integer_t _x_x256 = kk_integer_add_small_const(diag, 1, _ctx); /*int*/
                           diag = _x_x256;
                           xs = qs;
                           goto kk__tailcall;
        }
        {
          kk_integer_drop(queen, _ctx);
          kk_std_core_types__list_drop(qs, _ctx);
          kk_integer_drop(diag, _ctx);
          return false;
        }
      }
      {
        kk_integer_drop(queen, _ctx);
        kk_std_core_types__list_drop(qs, _ctx);
        kk_integer_drop(q, _ctx);
        kk_integer_drop(diag, _ctx);
        return false;
      }
    }
    {
      kk_integer_drop(queen, _ctx);
      kk_std_core_types__list_drop(qs, _ctx);
      kk_integer_drop(q, _ctx);
      kk_integer_drop(diag, _ctx);
      return false;
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_place_10038_fun258__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_place_10038_fun258(kk_function_t _fself, kk_box_t _b_x22, kk_box_t _b_x23, kk_box_t _b_x24, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_place_10038_fun258(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_place_10038_fun258, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_place_10038_fun258(kk_function_t _fself, kk_box_t _b_x22, kk_box_t _b_x23, kk_box_t _b_x24, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x259;
  kk_integer_t _x_x260 = kk_integer_unbox(_b_x22, _ctx); /*int*/
  kk_integer_t _x_x261 = kk_integer_unbox(_b_x23, _ctx); /*int*/
  kk_std_core_types__list _x_x262 = kk_std_core_types__list_unbox(_b_x24, KK_OWNED, _ctx); /*main/solution*/
  _x_x259 = kk_main_safe(_x_x260, _x_x261, _x_x262, _ctx); /*bool*/
  return kk_bool_box(_x_x259);
}


// lift anonymous function
struct kk_main__mlift_place_10038_fun269__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x30;
};
static kk_box_t kk_main__mlift_place_10038_fun269(kk_function_t _fself, int32_t _b_x34, kk_std_core_hnd__ev _b_x35, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_place_10038_fun269(kk_function_t _fun_unbox_x30, kk_context_t* _ctx) {
  struct kk_main__mlift_place_10038_fun269__t* _self = kk_function_alloc_as(struct kk_main__mlift_place_10038_fun269__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_place_10038_fun269, kk_context());
  _self->_fun_unbox_x30 = _fun_unbox_x30;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_place_10038_fun269(kk_function_t _fself, int32_t _b_x34, kk_std_core_hnd__ev _b_x35, kk_context_t* _ctx) {
  struct kk_main__mlift_place_10038_fun269__t* _self = kk_function_as(struct kk_main__mlift_place_10038_fun269__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x30 = _self->_fun_unbox_x30; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x30, _ctx);}, {}, _ctx)
  kk_std_core_types__list _x_x270;
  int32_t _b_x31_48 = _b_x34; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x32_49 = _b_x35; /*hnd/ev<main/search>*/;
  kk_box_t _x_x271 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x30, (_fun_unbox_x30, _b_x31_48, _b_x32_49, _ctx), _ctx); /*1005*/
  _x_x270 = kk_std_core_types__list_unbox(_x_x271, KK_OWNED, _ctx); /*main/solution*/
  return kk_std_core_types__list_box(_x_x270, _ctx);
}

kk_std_core_types__list kk_main__mlift_place_10038(kk_std_core_types__list rest, kk_integer_t next, kk_context_t* _ctx) { /* (rest : solution, next : int) -> search list<int> */ 
  bool _match_x222;
  kk_box_t _x_x257;
  kk_box_t _x_x263;
  kk_integer_t _x_x264 = kk_integer_dup(next, _ctx); /*int*/
  _x_x263 = kk_integer_box(_x_x264, _ctx); /*1000*/
  kk_box_t _x_x265;
  kk_std_core_types__list _x_x266 = kk_std_core_types__list_dup(rest, _ctx); /*main/solution*/
  _x_x265 = kk_std_core_types__list_box(_x_x266, _ctx); /*1002*/
  _x_x257 = kk_std_core_hnd__open_none3(kk_main__new_mlift_place_10038_fun258(_ctx), _x_x263, kk_integer_box(kk_integer_from_small(1), _ctx), _x_x265, _ctx); /*1003*/
  _match_x222 = kk_bool_unbox(_x_x257); /*bool*/
  if (_match_x222) {
    return kk_std_core_types__new_Cons(kk_reuse_null, 0, kk_integer_box(next, _ctx), rest, _ctx);
  }
  {
    kk_std_core_types__list_drop(rest, _ctx);
    kk_integer_drop(next, _ctx);
    kk_std_core_hnd__ev ev_10046 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/search>*/;
    {
      struct kk_std_core_hnd_Ev* _con_x267 = kk_std_core_hnd__as_Ev(ev_10046, _ctx);
      kk_box_t _box_x27 = _con_x267->hnd;
      int32_t m = _con_x267->marker;
      kk_main__search h = kk_main__search_unbox(_box_x27, KK_BORROWED, _ctx);
      kk_main__search_dup(h, _ctx);
      {
        struct kk_main__Hnd_search* _con_x268 = kk_main__as_Hnd_search(h, _ctx);
        kk_integer_t _pat_0_0 = _con_x268->_cfc;
        kk_std_core_hnd__clause0 _ctl_fail = _con_x268->_ctl_fail;
        kk_std_core_hnd__clause1 _pat_1_1 = _con_x268->_ctl_pick;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_std_core_hnd__clause1_drop(_pat_1_1, _ctx);
          kk_integer_drop(_pat_0_0, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause0_dup(_ctl_fail, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x30 = _ctl_fail.clause;
          kk_function_t _bv_x36 = (kk_main__new_mlift_place_10038_fun269(_fun_unbox_x30, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
          kk_box_t _x_x272 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x36, (_bv_x36, m, ev_10046, _ctx), _ctx); /*3004*/
          return kk_std_core_types__list_unbox(_x_x272, KK_OWNED, _ctx);
        }
      }
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_place_10039_fun277__t {
  struct kk_function_s _base;
  kk_std_core_types__list rest_0;
};
static kk_box_t kk_main__mlift_place_10039_fun277(kk_function_t _fself, kk_box_t _b_x59, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_place_10039_fun277(kk_std_core_types__list rest_0, kk_context_t* _ctx) {
  struct kk_main__mlift_place_10039_fun277__t* _self = kk_function_alloc_as(struct kk_main__mlift_place_10039_fun277__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_place_10039_fun277, kk_context());
  _self->rest_0 = rest_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_place_10039_fun277(kk_function_t _fself, kk_box_t _b_x59, kk_context_t* _ctx) {
  struct kk_main__mlift_place_10039_fun277__t* _self = kk_function_as(struct kk_main__mlift_place_10039_fun277__t*, _fself, _ctx);
  kk_std_core_types__list rest_0 = _self->rest_0; /* main/solution */
  kk_drop_match(_self, {kk_std_core_types__list_dup(rest_0, _ctx);}, {}, _ctx)
  kk_integer_t next_1_61 = kk_integer_unbox(_b_x59, _ctx); /*int*/;
  kk_std_core_types__list _x_x278 = kk_main__mlift_place_10038(rest_0, next_1_61, _ctx); /*list<int>*/
  return kk_std_core_types__list_box(_x_x278, _ctx);
}

kk_std_core_types__list kk_main__mlift_place_10039(kk_integer_t size, kk_std_core_types__list rest_0, kk_context_t* _ctx) { /* (size : int, rest : solution) -> <div,search> list<int> */ 
  kk_std_core_hnd__ev ev_0_10050 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/search>*/;
  kk_integer_t x_10048;
  kk_box_t _x_x273;
  {
    struct kk_std_core_hnd_Ev* _con_x274 = kk_std_core_hnd__as_Ev(ev_0_10050, _ctx);
    kk_box_t _box_x50 = _con_x274->hnd;
    int32_t m_0 = _con_x274->marker;
    kk_main__search h_0 = kk_main__search_unbox(_box_x50, KK_BORROWED, _ctx);
    kk_main__search_dup(h_0, _ctx);
    {
      struct kk_main__Hnd_search* _con_x275 = kk_main__as_Hnd_search(h_0, _ctx);
      kk_integer_t _pat_0_2 = _con_x275->_cfc;
      kk_std_core_hnd__clause0 _pat_1_2 = _con_x275->_ctl_fail;
      kk_std_core_hnd__clause1 _ctl_pick = _con_x275->_ctl_pick;
      if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
        kk_std_core_hnd__clause0_drop(_pat_1_2, _ctx);
        kk_integer_drop(_pat_0_2, _ctx);
        kk_datatype_ptr_free(h_0, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_pick, _ctx);
        kk_datatype_ptr_decref(h_0, _ctx);
      }
      {
        kk_function_t _fun_unbox_x54 = _ctl_pick.clause;
        _x_x273 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x54, (_fun_unbox_x54, m_0, ev_0_10050, kk_integer_box(size, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  x_10048 = kk_integer_unbox(_x_x273, _ctx); /*int*/
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10048, _ctx);
    kk_box_t _x_x276 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_place_10039_fun277(rest_0, _ctx), _ctx); /*3003*/
    return kk_std_core_types__list_unbox(_x_x276, KK_OWNED, _ctx);
  }
  {
    return kk_main__mlift_place_10038(rest_0, x_10048, _ctx);
  }
}


// lift anonymous function
struct kk_main_place_fun282__t {
  struct kk_function_s _base;
  kk_integer_t size_0;
};
static kk_box_t kk_main_place_fun282(kk_function_t _fself, kk_box_t _b_x63, kk_context_t* _ctx);
static kk_function_t kk_main_new_place_fun282(kk_integer_t size_0, kk_context_t* _ctx) {
  struct kk_main_place_fun282__t* _self = kk_function_alloc_as(struct kk_main_place_fun282__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_place_fun282, kk_context());
  _self->size_0 = size_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_place_fun282(kk_function_t _fself, kk_box_t _b_x63, kk_context_t* _ctx) {
  struct kk_main_place_fun282__t* _self = kk_function_as(struct kk_main_place_fun282__t*, _fself, _ctx);
  kk_integer_t size_0 = _self->size_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(size_0, _ctx);}, {}, _ctx)
  kk_std_core_types__list rest_1_104 = kk_std_core_types__list_unbox(_b_x63, KK_OWNED, _ctx); /*main/solution*/;
  kk_std_core_types__list _x_x283 = kk_main__mlift_place_10039(size_0, rest_1_104, _ctx); /*list<int>*/
  return kk_std_core_types__list_box(_x_x283, _ctx);
}


// lift anonymous function
struct kk_main_place_fun288__t {
  struct kk_function_s _base;
  kk_std_core_types__list x_1_10053;
};
static kk_box_t kk_main_place_fun288(kk_function_t _fself, kk_box_t _b_x73, kk_context_t* _ctx);
static kk_function_t kk_main_new_place_fun288(kk_std_core_types__list x_1_10053, kk_context_t* _ctx) {
  struct kk_main_place_fun288__t* _self = kk_function_alloc_as(struct kk_main_place_fun288__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_place_fun288, kk_context());
  _self->x_1_10053 = x_1_10053;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_place_fun288(kk_function_t _fself, kk_box_t _b_x73, kk_context_t* _ctx) {
  struct kk_main_place_fun288__t* _self = kk_function_as(struct kk_main_place_fun288__t*, _fself, _ctx);
  kk_std_core_types__list x_1_10053 = _self->x_1_10053; /* main/solution */
  kk_drop_match(_self, {kk_std_core_types__list_dup(x_1_10053, _ctx);}, {}, _ctx)
  kk_integer_t next_4_105 = kk_integer_unbox(_b_x73, _ctx); /*int*/;
  kk_std_core_types__list _x_x289 = kk_main__mlift_place_10038(x_1_10053, next_4_105, _ctx); /*list<int>*/
  return kk_std_core_types__list_box(_x_x289, _ctx);
}


// lift anonymous function
struct kk_main_place_fun291__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_place_fun291(kk_function_t _fself, kk_box_t _b_x78, kk_box_t _b_x79, kk_box_t _b_x80, kk_context_t* _ctx);
static kk_function_t kk_main_new_place_fun291(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_place_fun291, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_place_fun291(kk_function_t _fself, kk_box_t _b_x78, kk_box_t _b_x79, kk_box_t _b_x80, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x292;
  kk_integer_t _x_x293 = kk_integer_unbox(_b_x78, _ctx); /*int*/
  kk_integer_t _x_x294 = kk_integer_unbox(_b_x79, _ctx); /*int*/
  kk_std_core_types__list _x_x295 = kk_std_core_types__list_unbox(_b_x80, KK_OWNED, _ctx); /*main/solution*/
  _x_x292 = kk_main_safe(_x_x293, _x_x294, _x_x295, _ctx); /*bool*/
  return kk_bool_box(_x_x292);
}


// lift anonymous function
struct kk_main_place_fun302__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x86;
};
static kk_box_t kk_main_place_fun302(kk_function_t _fself, int32_t _b_x90, kk_std_core_hnd__ev _b_x91, kk_context_t* _ctx);
static kk_function_t kk_main_new_place_fun302(kk_function_t _fun_unbox_x86, kk_context_t* _ctx) {
  struct kk_main_place_fun302__t* _self = kk_function_alloc_as(struct kk_main_place_fun302__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_place_fun302, kk_context());
  _self->_fun_unbox_x86 = _fun_unbox_x86;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_place_fun302(kk_function_t _fself, int32_t _b_x90, kk_std_core_hnd__ev _b_x91, kk_context_t* _ctx) {
  struct kk_main_place_fun302__t* _self = kk_function_as(struct kk_main_place_fun302__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x86 = _self->_fun_unbox_x86; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x86, _ctx);}, {}, _ctx)
  kk_std_core_types__list _x_x303;
  int32_t _b_x87_108 = _b_x90; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x88_109 = _b_x91; /*hnd/ev<main/search>*/;
  kk_box_t _x_x304 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x86, (_fun_unbox_x86, _b_x87_108, _b_x88_109, _ctx), _ctx); /*1005*/
  _x_x303 = kk_std_core_types__list_unbox(_x_x304, KK_OWNED, _ctx); /*main/solution*/
  return kk_std_core_types__list_box(_x_x303, _ctx);
}

kk_std_core_types__list kk_main_place(kk_integer_t size_0, kk_integer_t column, kk_context_t* _ctx) { /* (size : int, column : int) -> <div,search> solution */ 
  bool _match_x217 = kk_integer_eq_borrow(column,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x217) {
    kk_integer_drop(size_0, _ctx);
    kk_integer_drop(column, _ctx);
    return kk_std_core_types__new_Nil(_ctx);
  }
  {
    kk_std_core_types__list x_1_10053;
    kk_integer_t _x_x279 = kk_integer_dup(size_0, _ctx); /*int*/
    kk_integer_t _x_x280 = kk_integer_add_small_const(column, -1, _ctx); /*int*/
    x_1_10053 = kk_main_place(_x_x279, _x_x280, _ctx); /*main/solution*/
    if (kk_yielding(kk_context())) {
      kk_std_core_types__list_drop(x_1_10053, _ctx);
      kk_box_t _x_x281 = kk_std_core_hnd_yield_extend(kk_main_new_place_fun282(size_0, _ctx), _ctx); /*3003*/
      return kk_std_core_types__list_unbox(_x_x281, KK_OWNED, _ctx);
    }
    {
      kk_std_core_hnd__ev ev_1_10059 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/search>*/;
      kk_integer_t x_2_10056;
      kk_box_t _x_x284;
      {
        struct kk_std_core_hnd_Ev* _con_x285 = kk_std_core_hnd__as_Ev(ev_1_10059, _ctx);
        kk_box_t _box_x64 = _con_x285->hnd;
        int32_t m_1 = _con_x285->marker;
        kk_main__search h_1 = kk_main__search_unbox(_box_x64, KK_BORROWED, _ctx);
        kk_main__search_dup(h_1, _ctx);
        {
          struct kk_main__Hnd_search* _con_x286 = kk_main__as_Hnd_search(h_1, _ctx);
          kk_integer_t _pat_0_4 = _con_x286->_cfc;
          kk_std_core_hnd__clause0 _pat_1_3 = _con_x286->_ctl_fail;
          kk_std_core_hnd__clause1 _ctl_pick_0 = _con_x286->_ctl_pick;
          if kk_likely(kk_datatype_ptr_is_unique(h_1, _ctx)) {
            kk_std_core_hnd__clause0_drop(_pat_1_3, _ctx);
            kk_integer_drop(_pat_0_4, _ctx);
            kk_datatype_ptr_free(h_1, _ctx);
          }
          else {
            kk_std_core_hnd__clause1_dup(_ctl_pick_0, _ctx);
            kk_datatype_ptr_decref(h_1, _ctx);
          }
          {
            kk_function_t _fun_unbox_x68 = _ctl_pick_0.clause;
            _x_x284 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x68, (_fun_unbox_x68, m_1, ev_1_10059, kk_integer_box(size_0, _ctx), _ctx), _ctx); /*1010*/
          }
        }
      }
      x_2_10056 = kk_integer_unbox(_x_x284, _ctx); /*int*/
      if (kk_yielding(kk_context())) {
        kk_integer_drop(x_2_10056, _ctx);
        kk_box_t _x_x287 = kk_std_core_hnd_yield_extend(kk_main_new_place_fun288(x_1_10053, _ctx), _ctx); /*3003*/
        return kk_std_core_types__list_unbox(_x_x287, KK_OWNED, _ctx);
      }
      {
        bool _match_x220;
        kk_box_t _x_x290;
        kk_box_t _x_x296;
        kk_integer_t _x_x297 = kk_integer_dup(x_2_10056, _ctx); /*int*/
        _x_x296 = kk_integer_box(_x_x297, _ctx); /*1000*/
        kk_box_t _x_x298;
        kk_std_core_types__list _x_x299 = kk_std_core_types__list_dup(x_1_10053, _ctx); /*main/solution*/
        _x_x298 = kk_std_core_types__list_box(_x_x299, _ctx); /*1002*/
        _x_x290 = kk_std_core_hnd__open_none3(kk_main_new_place_fun291(_ctx), _x_x296, kk_integer_box(kk_integer_from_small(1), _ctx), _x_x298, _ctx); /*1003*/
        _match_x220 = kk_bool_unbox(_x_x290); /*bool*/
        if (_match_x220) {
          return kk_std_core_types__new_Cons(kk_reuse_null, 0, kk_integer_box(x_2_10056, _ctx), x_1_10053, _ctx);
        }
        {
          kk_integer_drop(x_2_10056, _ctx);
          kk_std_core_types__list_drop(x_1_10053, _ctx);
          kk_std_core_hnd__ev ev_2_10062 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/search>*/;
          {
            struct kk_std_core_hnd_Ev* _con_x300 = kk_std_core_hnd__as_Ev(ev_2_10062, _ctx);
            kk_box_t _box_x83 = _con_x300->hnd;
            int32_t m_2 = _con_x300->marker;
            kk_main__search h_2 = kk_main__search_unbox(_box_x83, KK_BORROWED, _ctx);
            kk_main__search_dup(h_2, _ctx);
            {
              struct kk_main__Hnd_search* _con_x301 = kk_main__as_Hnd_search(h_2, _ctx);
              kk_integer_t _pat_0_7 = _con_x301->_cfc;
              kk_std_core_hnd__clause0 _ctl_fail_0 = _con_x301->_ctl_fail;
              kk_std_core_hnd__clause1 _pat_1_5 = _con_x301->_ctl_pick;
              if kk_likely(kk_datatype_ptr_is_unique(h_2, _ctx)) {
                kk_std_core_hnd__clause1_drop(_pat_1_5, _ctx);
                kk_integer_drop(_pat_0_7, _ctx);
                kk_datatype_ptr_free(h_2, _ctx);
              }
              else {
                kk_std_core_hnd__clause0_dup(_ctl_fail_0, _ctx);
                kk_datatype_ptr_decref(h_2, _ctx);
              }
              {
                kk_function_t _fun_unbox_x86 = _ctl_fail_0.clause;
                kk_function_t _bv_x92 = (kk_main_new_place_fun302(_fun_unbox_x86, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
                kk_box_t _x_x305 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x92, (_bv_x92, m_2, ev_2_10062, _ctx), _ctx); /*3004*/
                return kk_std_core_types__list_unbox(_x_x305, KK_OWNED, _ctx);
              }
            }
          }
        }
      }
    }
  }
}
 
// lifted local: run, loop

kk_integer_t kk_main__lift_run_828(kk_function_t resume_0, kk_integer_t size, kk_integer_t i, kk_integer_t a, kk_context_t* _ctx) { /* (resume@0 : (int) -> div int, size : int, i : int, a : int) -> div int */ 
  kk__tailcall: ;
  bool _match_x216 = kk_integer_eq_borrow(i,size,kk_context()); /*bool*/;
  if (_match_x216) {
    kk_integer_drop(size, _ctx);
    kk_integer_t y_10008 = kk_function_call(kk_integer_t, (kk_function_t, kk_integer_t, kk_context_t*), resume_0, (resume_0, i, _ctx), _ctx); /*int*/;
    return kk_integer_add(a,y_10008,kk_context());
  }
  {
    kk_integer_t i_0_10009;
    kk_integer_t _x_x306 = kk_integer_dup(i, _ctx); /*int*/
    i_0_10009 = kk_integer_add_small_const(_x_x306, 1, _ctx); /*int*/
    kk_integer_t y_1_10014;
    kk_function_t _x_x307 = kk_function_dup(resume_0, _ctx); /*(int) -> div int*/
    y_1_10014 = kk_function_call(kk_integer_t, (kk_function_t, kk_integer_t, kk_context_t*), _x_x307, (_x_x307, i, _ctx), _ctx); /*int*/
    kk_integer_t a_0_10010 = kk_integer_add(a,y_1_10014,kk_context()); /*int*/;
    { // tailcall
      i = i_0_10009;
      a = a_0_10010;
      goto kk__tailcall;
    }
  }
}


// lift anonymous function
struct kk_main_run_fun309__t {
  struct kk_function_s _base;
};
static kk_integer_t kk_main_run_fun309(kk_function_t _fself, int32_t m_0, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun309(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun309, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun311__t {
  struct kk_function_s _base;
  kk_integer_t x;
};
static kk_box_t kk_main_run_fun311(kk_function_t _fself, kk_function_t _b_x130, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun311(kk_integer_t x, kk_context_t* _ctx) {
  struct kk_main_run_fun311__t* _self = kk_function_alloc_as(struct kk_main_run_fun311__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun311, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun312__t {
  struct kk_function_s _base;
  kk_function_t _b_x130;
};
static kk_integer_t kk_main_run_fun312(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x131, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun312(kk_function_t _b_x130, kk_context_t* _ctx) {
  struct kk_main_run_fun312__t* _self = kk_function_alloc_as(struct kk_main_run_fun312__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun312, kk_context());
  _self->_b_x130 = _b_x130;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun312(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x131, kk_context_t* _ctx) {
  struct kk_main_run_fun312__t* _self = kk_function_as(struct kk_main_run_fun312__t*, _fself, _ctx);
  kk_function_t _b_x130 = _self->_b_x130; /* (hnd/resume-result<3004,3006>) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x130, _ctx);}, {}, _ctx)
  kk_box_t _x_x313 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x130, (_b_x130, _b_x131, _ctx), _ctx); /*3006*/
  return kk_integer_unbox(_x_x313, _ctx);
}


// lift anonymous function
struct kk_main_run_fun314__t {
  struct kk_function_s _base;
};
static kk_integer_t kk_main_run_fun314(kk_function_t _fself, kk_integer_t size, kk_function_t resume_0, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun314(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun314, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_integer_t kk_main_run_fun314(kk_function_t _fself, kk_integer_t size, kk_function_t resume_0, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_main__lift_run_828(resume_0, size, kk_integer_from_small(1), kk_integer_from_small(0), _ctx);
}


// lift anonymous function
struct kk_main_run_fun315__t {
  struct kk_function_s _base;
  kk_function_t _b_x122_152;
};
static kk_box_t kk_main_run_fun315(kk_function_t _fself, kk_box_t _b_x124, kk_function_t _b_x125, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun315(kk_function_t _b_x122_152, kk_context_t* _ctx) {
  struct kk_main_run_fun315__t* _self = kk_function_alloc_as(struct kk_main_run_fun315__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun315, kk_context());
  _self->_b_x122_152 = _b_x122_152;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun318__t {
  struct kk_function_s _base;
  kk_function_t _b_x125;
};
static kk_integer_t kk_main_run_fun318(kk_function_t _fself, kk_integer_t _b_x126, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun318(kk_function_t _b_x125, kk_context_t* _ctx) {
  struct kk_main_run_fun318__t* _self = kk_function_alloc_as(struct kk_main_run_fun318__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun318, kk_context());
  _self->_b_x125 = _b_x125;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun318(kk_function_t _fself, kk_integer_t _b_x126, kk_context_t* _ctx) {
  struct kk_main_run_fun318__t* _self = kk_function_as(struct kk_main_run_fun318__t*, _fself, _ctx);
  kk_function_t _b_x125 = _self->_b_x125; /* (3005) -> 3006 3007 */
  kk_drop_match(_self, {kk_function_dup(_b_x125, _ctx);}, {}, _ctx)
  kk_box_t _x_x319 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x125, (_b_x125, kk_integer_box(_b_x126, _ctx), _ctx), _ctx); /*3007*/
  return kk_integer_unbox(_x_x319, _ctx);
}
static kk_box_t kk_main_run_fun315(kk_function_t _fself, kk_box_t _b_x124, kk_function_t _b_x125, kk_context_t* _ctx) {
  struct kk_main_run_fun315__t* _self = kk_function_as(struct kk_main_run_fun315__t*, _fself, _ctx);
  kk_function_t _b_x122_152 = _self->_b_x122_152; /* (size : int, resume@0 : (int) -> div int) -> div int */
  kk_drop_match(_self, {kk_function_dup(_b_x122_152, _ctx);}, {}, _ctx)
  kk_integer_t _x_x316;
  kk_integer_t _x_x317 = kk_integer_unbox(_b_x124, _ctx); /*int*/
  _x_x316 = kk_function_call(kk_integer_t, (kk_function_t, kk_integer_t, kk_function_t, kk_context_t*), _b_x122_152, (_b_x122_152, _x_x317, kk_main_new_run_fun318(_b_x125, _ctx), _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x316, _ctx);
}


// lift anonymous function
struct kk_main_run_fun320__t {
  struct kk_function_s _base;
  kk_function_t _b_x123_153;
};
static kk_box_t kk_main_run_fun320(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x127, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun320(kk_function_t _b_x123_153, kk_context_t* _ctx) {
  struct kk_main_run_fun320__t* _self = kk_function_alloc_as(struct kk_main_run_fun320__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun320, kk_context());
  _self->_b_x123_153 = _b_x123_153;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun320(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x127, kk_context_t* _ctx) {
  struct kk_main_run_fun320__t* _self = kk_function_as(struct kk_main_run_fun320__t*, _fself, _ctx);
  kk_function_t _b_x123_153 = _self->_b_x123_153; /* (hnd/resume-result<int,int>) -> div int */
  kk_drop_match(_self, {kk_function_dup(_b_x123_153, _ctx);}, {}, _ctx)
  kk_integer_t _x_x321 = kk_function_call(kk_integer_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x123_153, (_b_x123_153, _b_x127, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x321, _ctx);
}
static kk_box_t kk_main_run_fun311(kk_function_t _fself, kk_function_t _b_x130, kk_context_t* _ctx) {
  struct kk_main_run_fun311__t* _self = kk_function_as(struct kk_main_run_fun311__t*, _fself, _ctx);
  kk_integer_t x = _self->x; /* int */
  kk_drop_match(_self, {kk_integer_dup(x, _ctx);}, {}, _ctx)
  kk_function_t k_0_154 = kk_main_new_run_fun312(_b_x130, _ctx); /*(hnd/resume-result<int,int>) -> div int*/;
  kk_integer_t _b_x121_151 = x; /*int*/;
  kk_function_t _b_x122_152 = kk_main_new_run_fun314(_ctx); /*(size : int, resume@0 : (int) -> div int) -> div int*/;
  kk_function_t _b_x123_153 = k_0_154; /*(hnd/resume-result<int,int>) -> div int*/;
  return kk_std_core_hnd_protect(kk_integer_box(_b_x121_151, _ctx), kk_main_new_run_fun315(_b_x122_152, _ctx), kk_main_new_run_fun320(_b_x123_153, _ctx), _ctx);
}
static kk_integer_t kk_main_run_fun309(kk_function_t _fself, int32_t m_0, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x681__16, (KK_I32(3)), _ctx);
  kk_box_t _x_x310 = kk_std_core_hnd_yield_to(m_0, kk_main_new_run_fun311(x, _ctx), _ctx); /*3004*/
  return kk_integer_unbox(_x_x310, _ctx);
}


// lift anonymous function
struct kk_main_run_fun324__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun324(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun324(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun324, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun325__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun325(kk_function_t _fself, kk_function_t _b_x119, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun325(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun325, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun326__t {
  struct kk_function_s _base;
  kk_function_t _b_x119;
};
static kk_integer_t kk_main_run_fun326(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x120, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun326(kk_function_t _b_x119, kk_context_t* _ctx) {
  struct kk_main_run_fun326__t* _self = kk_function_alloc_as(struct kk_main_run_fun326__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun326, kk_context());
  _self->_b_x119 = _b_x119;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun326(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x120, kk_context_t* _ctx) {
  struct kk_main_run_fun326__t* _self = kk_function_as(struct kk_main_run_fun326__t*, _fself, _ctx);
  kk_function_t _b_x119 = _self->_b_x119; /* (hnd/resume-result<3003,3005>) -> 3004 3005 */
  kk_drop_match(_self, {kk_function_dup(_b_x119, _ctx);}, {}, _ctx)
  kk_box_t _x_x327 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x119, (_b_x119, _b_x120, _ctx), _ctx); /*3005*/
  return kk_integer_unbox(_x_x327, _ctx);
}


// lift anonymous function
struct kk_main_run_fun328__t {
  struct kk_function_s _base;
};
static kk_integer_t kk_main_run_fun328(kk_function_t _fself, kk_unit_t ___wildcard_x730__55, kk_function_t r, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun328(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun328, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_integer_t kk_main_run_fun328(kk_function_t _fself, kk_unit_t ___wildcard_x730__55, kk_function_t r, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_drop(r, _ctx);
  return kk_integer_from_small(0);
}


// lift anonymous function
struct kk_main_run_fun329__t {
  struct kk_function_s _base;
  kk_function_t _b_x111_146;
};
static kk_box_t kk_main_run_fun329(kk_function_t _fself, kk_box_t _b_x113, kk_function_t _b_x114, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun329(kk_function_t _b_x111_146, kk_context_t* _ctx) {
  struct kk_main_run_fun329__t* _self = kk_function_alloc_as(struct kk_main_run_fun329__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun329, kk_context());
  _self->_b_x111_146 = _b_x111_146;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun332__t {
  struct kk_function_s _base;
  kk_function_t _b_x114;
};
static kk_integer_t kk_main_run_fun332(kk_function_t _fself, kk_box_t _b_x115, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun332(kk_function_t _b_x114, kk_context_t* _ctx) {
  struct kk_main_run_fun332__t* _self = kk_function_alloc_as(struct kk_main_run_fun332__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun332, kk_context());
  _self->_b_x114 = _b_x114;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun332(kk_function_t _fself, kk_box_t _b_x115, kk_context_t* _ctx) {
  struct kk_main_run_fun332__t* _self = kk_function_as(struct kk_main_run_fun332__t*, _fself, _ctx);
  kk_function_t _b_x114 = _self->_b_x114; /* (3004) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x114, _ctx);}, {}, _ctx)
  kk_box_t _x_x333 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x114, (_b_x114, _b_x115, _ctx), _ctx); /*3006*/
  return kk_integer_unbox(_x_x333, _ctx);
}
static kk_box_t kk_main_run_fun329(kk_function_t _fself, kk_box_t _b_x113, kk_function_t _b_x114, kk_context_t* _ctx) {
  struct kk_main_run_fun329__t* _self = kk_function_as(struct kk_main_run_fun329__t*, _fself, _ctx);
  kk_function_t _b_x111_146 = _self->_b_x111_146; /* ((), r : (648) -> div int) -> div int */
  kk_drop_match(_self, {kk_function_dup(_b_x111_146, _ctx);}, {}, _ctx)
  kk_integer_t _x_x330;
  kk_unit_t _x_x331 = kk_Unit;
  kk_unit_unbox(_b_x113);
  _x_x330 = kk_function_call(kk_integer_t, (kk_function_t, kk_unit_t, kk_function_t, kk_context_t*), _b_x111_146, (_b_x111_146, _x_x331, kk_main_new_run_fun332(_b_x114, _ctx), _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x330, _ctx);
}


// lift anonymous function
struct kk_main_run_fun334__t {
  struct kk_function_s _base;
  kk_function_t _b_x112_147;
};
static kk_box_t kk_main_run_fun334(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x116, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun334(kk_function_t _b_x112_147, kk_context_t* _ctx) {
  struct kk_main_run_fun334__t* _self = kk_function_alloc_as(struct kk_main_run_fun334__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun334, kk_context());
  _self->_b_x112_147 = _b_x112_147;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun334(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x116, kk_context_t* _ctx) {
  struct kk_main_run_fun334__t* _self = kk_function_as(struct kk_main_run_fun334__t*, _fself, _ctx);
  kk_function_t _b_x112_147 = _self->_b_x112_147; /* (hnd/resume-result<648,int>) -> div int */
  kk_drop_match(_self, {kk_function_dup(_b_x112_147, _ctx);}, {}, _ctx)
  kk_integer_t _x_x335 = kk_function_call(kk_integer_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x112_147, (_b_x112_147, _b_x116, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x335, _ctx);
}
static kk_box_t kk_main_run_fun325(kk_function_t _fself, kk_function_t _b_x119, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_t k_155 = kk_main_new_run_fun326(_b_x119, _ctx); /*(hnd/resume-result<648,int>) -> div int*/;
  kk_unit_t _b_x110_145 = kk_Unit;
  kk_function_t _b_x111_146 = kk_main_new_run_fun328(_ctx); /*((), r : (648) -> div int) -> div int*/;
  kk_function_t _b_x112_147 = k_155; /*(hnd/resume-result<648,int>) -> div int*/;
  return kk_std_core_hnd_protect(kk_unit_box(_b_x110_145), kk_main_new_run_fun329(_b_x111_146, _ctx), kk_main_new_run_fun334(_b_x112_147, _ctx), _ctx);
}
static kk_box_t kk_main_run_fun324(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x730__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_main_new_run_fun325(_ctx), _ctx);
}


// lift anonymous function
struct kk_main_run_fun337__t {
  struct kk_function_s _base;
  kk_function_t _b_x132_148;
};
static kk_box_t kk_main_run_fun337(kk_function_t _fself, int32_t _b_x133, kk_std_core_hnd__ev _b_x134, kk_box_t _b_x135, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun337(kk_function_t _b_x132_148, kk_context_t* _ctx) {
  struct kk_main_run_fun337__t* _self = kk_function_alloc_as(struct kk_main_run_fun337__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun337, kk_context());
  _self->_b_x132_148 = _b_x132_148;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun337(kk_function_t _fself, int32_t _b_x133, kk_std_core_hnd__ev _b_x134, kk_box_t _b_x135, kk_context_t* _ctx) {
  struct kk_main_run_fun337__t* _self = kk_function_as(struct kk_main_run_fun337__t*, _fself, _ctx);
  kk_function_t _b_x132_148 = _self->_b_x132_148; /* (m@0 : hnd/marker<div,int>, hnd/ev<main/search>, x : int) -> div int */
  kk_drop_match(_self, {kk_function_dup(_b_x132_148, _ctx);}, {}, _ctx)
  kk_integer_t _x_x338;
  kk_integer_t _x_x339 = kk_integer_unbox(_b_x135, _ctx); /*int*/
  _x_x338 = kk_function_call(kk_integer_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_integer_t, kk_context_t*), _b_x132_148, (_b_x132_148, _b_x133, _b_x134, _x_x339, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x338, _ctx);
}


// lift anonymous function
struct kk_main_run_fun340__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun340(kk_function_t _fself, kk_box_t _b_x139, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun340(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun340, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun340(kk_function_t _fself, kk_box_t _b_x139, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__list __w_l30_c12_156 = kk_std_core_types__list_unbox(_b_x139, KK_OWNED, _ctx); /*main/solution*/;
  kk_std_core_types__list_drop(__w_l30_c12_156, _ctx);
  return kk_integer_box(kk_integer_from_small(1), _ctx);
}


// lift anonymous function
struct kk_main_run_fun341__t {
  struct kk_function_s _base;
  kk_integer_t n;
};
static kk_box_t kk_main_run_fun341(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun341(kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun341__t* _self = kk_function_alloc_as(struct kk_main_run_fun341__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun341, kk_context());
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun341(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun341__t* _self = kk_function_as(struct kk_main_run_fun341__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_std_core_types__list _x_x342;
  kk_integer_t _x_x343 = kk_integer_dup(n, _ctx); /*int*/
  _x_x342 = kk_main_place(_x_x343, n, _ctx); /*main/solution*/
  return kk_std_core_types__list_box(_x_x342, _ctx);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  kk_box_t _x_x308;
  kk_function_t _b_x132_148 = kk_main_new_run_fun309(_ctx); /*(m@0 : hnd/marker<div,int>, hnd/ev<main/search>, x : int) -> div int*/;
  kk_main__search _x_x322;
  kk_std_core_hnd__clause0 _x_x323 = kk_std_core_hnd__new_Clause0(kk_main_new_run_fun324(_ctx), _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
  kk_std_core_hnd__clause1 _x_x336 = kk_std_core_hnd__new_Clause1(kk_main_new_run_fun337(_b_x132_148, _ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x322 = kk_main__new_Hnd_search(kk_reuse_null, 0, kk_integer_from_small(3), _x_x323, _x_x336, _ctx); /*main/search<11,12>*/
  _x_x308 = kk_main__handle_search(_x_x322, kk_main_new_run_fun340(_ctx), kk_main_new_run_fun341(n, _ctx), _ctx); /*201*/
  return kk_integer_unbox(_x_x308, _ctx);
}


// lift anonymous function
struct kk_main_main_fun350__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun350(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun350(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun350, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_main_fun351__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun351(kk_function_t _fself, kk_function_t _b_x167, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun351(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun351, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_main_fun352__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun352(kk_function_t _fself, kk_box_t _b_x161, kk_function_t _b_x162, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun352(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun352, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_main_fun352(kk_function_t _fself, kk_box_t _b_x161, kk_function_t _b_x162, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_box_drop(_b_x161, _ctx);
  kk_function_drop(_b_x162, _ctx);
  return kk_integer_box(kk_integer_from_small(0), _ctx);
}
static kk_box_t kk_main_main_fun351(kk_function_t _fself, kk_function_t _b_x167, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_hnd_protect(kk_unit_box(kk_Unit), kk_main_new_main_fun352(_ctx), _b_x167, _ctx);
}
static kk_box_t kk_main_main_fun350(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x730__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_main_new_main_fun351(_ctx), _ctx);
}


// lift anonymous function
struct kk_main_main_fun354__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun354(kk_function_t _fself, int32_t _b_x181, kk_std_core_hnd__ev _b_x182, kk_box_t _b_x183, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun354(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun354, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_main_fun355__t {
  struct kk_function_s _base;
  kk_integer_t x_215;
};
static kk_box_t kk_main_main_fun355(kk_function_t _fself, kk_function_t _b_x178, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun355(kk_integer_t x_215, kk_context_t* _ctx) {
  struct kk_main_main_fun355__t* _self = kk_function_alloc_as(struct kk_main_main_fun355__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_main_fun355, kk_context());
  _self->x_215 = x_215;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_main_fun356__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun356(kk_function_t _fself, kk_box_t _b_x172, kk_function_t _b_x173, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun356(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun356, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_main_fun358__t {
  struct kk_function_s _base;
  kk_function_t _b_x173;
};
static kk_integer_t kk_main_main_fun358(kk_function_t _fself, kk_integer_t _b_x174, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun358(kk_function_t _b_x173, kk_context_t* _ctx) {
  struct kk_main_main_fun358__t* _self = kk_function_alloc_as(struct kk_main_main_fun358__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_main_fun358, kk_context());
  _self->_b_x173 = _b_x173;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_main_fun358(kk_function_t _fself, kk_integer_t _b_x174, kk_context_t* _ctx) {
  struct kk_main_main_fun358__t* _self = kk_function_as(struct kk_main_main_fun358__t*, _fself, _ctx);
  kk_function_t _b_x173 = _self->_b_x173; /* (3005) -> 3006 3007 */
  kk_drop_match(_self, {kk_function_dup(_b_x173, _ctx);}, {}, _ctx)
  kk_box_t _x_x359 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x173, (_b_x173, kk_integer_box(_b_x174, _ctx), _ctx), _ctx); /*3007*/
  return kk_integer_unbox(_x_x359, _ctx);
}
static kk_box_t kk_main_main_fun356(kk_function_t _fself, kk_box_t _b_x172, kk_function_t _b_x173, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x357;
  kk_integer_t _x_x360 = kk_integer_unbox(_b_x172, _ctx); /*int*/
  _x_x357 = kk_main__lift_run_828(kk_main_new_main_fun358(_b_x173, _ctx), _x_x360, kk_integer_from_small(1), kk_integer_from_small(0), _ctx); /*int*/
  return kk_integer_box(_x_x357, _ctx);
}
static kk_box_t kk_main_main_fun355(kk_function_t _fself, kk_function_t _b_x178, kk_context_t* _ctx) {
  struct kk_main_main_fun355__t* _self = kk_function_as(struct kk_main_main_fun355__t*, _fself, _ctx);
  kk_integer_t x_215 = _self->x_215; /* int */
  kk_drop_match(_self, {kk_integer_dup(x_215, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect(kk_integer_box(x_215, _ctx), kk_main_new_main_fun356(_ctx), _b_x178, _ctx);
}
static kk_box_t kk_main_main_fun354(kk_function_t _fself, int32_t _b_x181, kk_std_core_hnd__ev _b_x182, kk_box_t _b_x183, kk_context_t* _ctx) {
  kk_unused(_fself);
  int32_t m_0_213 = _b_x181; /*hnd/marker<div,int>*/;
  kk_std_core_hnd__ev ___wildcard_x681__16_214 = _b_x182; /*hnd/ev<main/search>*/;
  kk_datatype_ptr_dropn(___wildcard_x681__16_214, (KK_I32(3)), _ctx);
  kk_integer_t x_215 = kk_integer_unbox(_b_x183, _ctx); /*int*/;
  return kk_std_core_hnd_yield_to(m_0_213, kk_main_new_main_fun355(x_215, _ctx), _ctx);
}


// lift anonymous function
struct kk_main_main_fun361__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun361(kk_function_t _fself, kk_box_t _b_x189, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun361(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun361, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_main_fun361(kk_function_t _fself, kk_box_t _b_x189, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_box_drop(_b_x189, _ctx);
  return kk_integer_box(kk_integer_from_small(1), _ctx);
}


// lift anonymous function
struct kk_main_main_fun362__t {
  struct kk_function_s _base;
  kk_std_core_types__maybe m_10015;
};
static kk_box_t kk_main_main_fun362(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun362(kk_std_core_types__maybe m_10015, kk_context_t* _ctx) {
  struct kk_main_main_fun362__t* _self = kk_function_alloc_as(struct kk_main_main_fun362__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_main_fun362, kk_context());
  _self->m_10015 = m_10015;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_main_fun362(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_main_fun362__t* _self = kk_function_as(struct kk_main_main_fun362__t*, _fself, _ctx);
  kk_std_core_types__maybe m_10015 = _self->m_10015; /* maybe<int> */
  kk_drop_match(_self, {kk_std_core_types__maybe_dup(m_10015, _ctx);}, {}, _ctx)
  kk_std_core_types__list _x_x363;
  kk_integer_t _x_x364;
  if (kk_std_core_types__is_Nothing(m_10015, _ctx)) {
    _x_x364 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x184 = m_10015._cons.Just.value;
    kk_integer_t x_1 = kk_integer_unbox(_box_x184, _ctx);
    kk_integer_dup(x_1, _ctx);
    _x_x364 = x_1; /*int*/
  }
  kk_integer_t _x_x365;
  if (kk_std_core_types__is_Nothing(m_10015, _ctx)) {
    _x_x365 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x185 = m_10015._cons.Just.value;
    kk_integer_t x_1_0 = kk_integer_unbox(_box_x185, _ctx);
    kk_integer_dup(x_1_0, _ctx);
    kk_std_core_types__maybe_drop(m_10015, _ctx);
    _x_x365 = x_1_0; /*int*/
  }
  _x_x363 = kk_main_place(_x_x364, _x_x365, _ctx); /*main/solution*/
  return kk_std_core_types__list_box(_x_x363, _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10017 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10015;
  kk_string_t _x_x344;
  if (kk_std_core_types__is_Cons(xs_10017, _ctx)) {
    struct kk_std_core_types_Cons* _con_x345 = kk_std_core_types__as_Cons(xs_10017, _ctx);
    kk_box_t _box_x157 = _con_x345->head;
    kk_std_core_types__list _pat_0_0 = _con_x345->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x157);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10017, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10017, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10017, _ctx);
    }
    _x_x344 = x_0; /*string*/
  }
  else {
    _x_x344 = kk_string_empty(); /*string*/
  }
  m_10015 = kk_std_core_int_parse_int(_x_x344, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r_0;
  kk_box_t _x_x347;
  kk_main__search _x_x348;
  kk_std_core_hnd__clause0 _x_x349 = kk_std_core_hnd__new_Clause0(kk_main_new_main_fun350(_ctx), _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
  kk_std_core_hnd__clause1 _x_x353 = kk_std_core_hnd__new_Clause1(kk_main_new_main_fun354(_ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x348 = kk_main__new_Hnd_search(kk_reuse_null, 0, kk_integer_from_small(3), _x_x349, _x_x353, _ctx); /*main/search<11,12>*/
  _x_x347 = kk_main__handle_search(_x_x348, kk_main_new_main_fun361(_ctx), kk_main_new_main_fun362(m_10015, _ctx), _ctx); /*201*/
  r_0 = kk_integer_unbox(_x_x347, _ctx); /*int*/
  kk_string_t _x_x366 = kk_std_core_int_show(r_0, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x366, _ctx); return kk_Unit;
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
    kk_string_t _x_x241;
    kk_define_string_literal(, _s_x242, 11, "search@main", _ctx)
    _x_x241 = kk_string_dup(_s_x242, _ctx); /*string*/
    kk_main__tag_search = kk_std_core_hnd__new_Htag(_x_x241, _ctx); /*hnd/htag<main/search>*/
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
  kk_std_core_hnd__htag_drop(kk_main__tag_search, _ctx);
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
