// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:fail`

kk_std_core_hnd__htag kk_main__tag_fail;
 
// handler for the effect `:fail`

kk_box_t kk_main__handle_fail(kk_main__fail hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : fail<e,b>, ret : (res : a) -> e b, action : () -> <fail|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x252 = kk_std_core_hnd__htag_dup(kk_main__tag_fail, _ctx); /*hnd/htag<main/fail>*/
  return kk_std_core_hnd__hhandle(_x_x252, kk_main__fail_box(hnd, _ctx), ret, action, _ctx);
}
 
// runtime tag for the effect `:flip`

kk_std_core_hnd__htag kk_main__tag_flip;
 
// handler for the effect `:flip`

kk_box_t kk_main__handle_flip(kk_main__flip hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : flip<e,b>, ret : (res : a) -> e b, action : () -> <flip|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x255 = kk_std_core_hnd__htag_dup(kk_main__tag_flip, _ctx); /*hnd/htag<main/flip>*/
  return kk_std_core_hnd__hhandle(_x_x255, kk_main__flip_box(hnd, _ctx), ret, action, _ctx);
}

kk_integer_t kk_main_hash(kk_std_core_types__tuple3 _pat_x25__10, kk_context_t* _ctx) { /* ((int, int, int)) -> int */ 
  {
    kk_box_t _box_x16 = _pat_x25__10.fst;
    kk_box_t _box_x17 = _pat_x25__10.snd;
    kk_box_t _box_x18 = _pat_x25__10.thd;
    kk_integer_t a = kk_integer_unbox(_box_x16, _ctx);
    kk_integer_t b = kk_integer_unbox(_box_x17, _ctx);
    kk_integer_t c = kk_integer_unbox(_box_x18, _ctx);
    kk_integer_dup(a, _ctx);
    kk_integer_dup(b, _ctx);
    kk_integer_dup(c, _ctx);
    kk_std_core_types__tuple3_drop(_pat_x25__10, _ctx);
    kk_integer_t x_0_10002 = kk_integer_mul((kk_integer_from_small(53)),a,kk_context()); /*int*/;
    kk_integer_t y_0_10003 = kk_integer_mul((kk_integer_from_small(2809)),b,kk_context()); /*int*/;
    kk_integer_t x_10000 = kk_integer_add(x_0_10002,y_0_10003,kk_context()); /*int*/;
    kk_integer_t y_10001 = kk_integer_mul((kk_integer_from_int(148877, _ctx)),c,kk_context()); /*int*/;
    kk_integer_t _x_x258 = kk_integer_add(x_10000,y_10001,kk_context()); /*int*/
    return kk_integer_mod(_x_x258,(kk_integer_from_int(1000000007, _ctx)),kk_context());
  }
}
extern kk_box_t kk_main_flip_fun264(kk_function_t _fself, int32_t _b_x27, kk_std_core_hnd__ev _b_x28, kk_context_t* _ctx) {
  struct kk_main_flip_fun264__t* _self = kk_function_as(struct kk_main_flip_fun264__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x23 = _self->_fun_unbox_x23; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x23, _ctx);}, {}, _ctx)
  bool _x_x265;
  int32_t _b_x24_35 = _b_x27; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x25_36 = _b_x28; /*hnd/ev<main/flip>*/;
  kk_box_t _x_x266 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x23, (_fun_unbox_x23, _b_x24_35, _b_x25_36, _ctx), _ctx); /*1005*/
  _x_x265 = kk_bool_unbox(_x_x266); /*bool*/
  return kk_bool_box(_x_x265);
}
 
// monadic lift

kk_integer_t kk_main__mlift_choice_10050(kk_integer_t n, bool _y_x10023, kk_context_t* _ctx) { /* (n : int, bool) -> <flip,fail,div> int */ 
  if (_y_x10023) {
    return n;
  }
  {
    kk_integer_t _x_x268 = kk_integer_add_small_const(n, -1, _ctx); /*int*/
    return kk_main_choice(_x_x268, _ctx);
  }
}


// lift anonymous function
struct kk_main_choice_fun270__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_choice_fun270(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_choice_fun270(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_choice_fun270, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_choice_fun274__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x40;
};
static kk_box_t kk_main_choice_fun274(kk_function_t _fself, int32_t _b_x44, kk_std_core_hnd__ev _b_x45, kk_context_t* _ctx);
static kk_function_t kk_main_new_choice_fun274(kk_function_t _fun_unbox_x40, kk_context_t* _ctx) {
  struct kk_main_choice_fun274__t* _self = kk_function_alloc_as(struct kk_main_choice_fun274__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_choice_fun274, kk_context());
  _self->_fun_unbox_x40 = _fun_unbox_x40;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_choice_fun274(kk_function_t _fself, int32_t _b_x44, kk_std_core_hnd__ev _b_x45, kk_context_t* _ctx) {
  struct kk_main_choice_fun274__t* _self = kk_function_as(struct kk_main_choice_fun274__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x40 = _self->_fun_unbox_x40; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x40, _ctx);}, {}, _ctx)
  kk_integer_t _x_x275;
  int32_t _b_x41_81 = _b_x44; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x42_82 = _b_x45; /*hnd/ev<main/fail>*/;
  kk_box_t _x_x276 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x40, (_fun_unbox_x40, _b_x41_81, _b_x42_82, _ctx), _ctx); /*1005*/
  _x_x275 = kk_integer_unbox(_x_x276, _ctx); /*int*/
  return kk_integer_box(_x_x275, _ctx);
}
static kk_box_t kk_main_choice_fun270(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_10061 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/fail>*/;
  kk_integer_t _x_x271;
  {
    struct kk_std_core_hnd_Ev* _con_x272 = kk_std_core_hnd__as_Ev(ev_10061, _ctx);
    kk_box_t _box_x37 = _con_x272->hnd;
    int32_t m = _con_x272->marker;
    kk_main__fail h = kk_main__fail_unbox(_box_x37, KK_BORROWED, _ctx);
    kk_main__fail_dup(h, _ctx);
    {
      struct kk_main__Hnd_fail* _con_x273 = kk_main__as_Hnd_fail(h, _ctx);
      kk_integer_t _pat_0_1 = _con_x273->_cfc;
      kk_std_core_hnd__clause0 _ctl_fail = _con_x273->_ctl_fail;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_1, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_fail, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x40 = _ctl_fail.clause;
        kk_function_t _bv_x46 = (kk_main_new_choice_fun274(_fun_unbox_x40, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x277 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x46, (_bv_x46, m, ev_10061, _ctx), _ctx); /*3004*/
        _x_x271 = kk_integer_unbox(_x_x277, _ctx); /*int*/
      }
    }
  }
  return kk_integer_box(_x_x271, _ctx);
}


// lift anonymous function
struct kk_main_choice_fun279__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_choice_fun279(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_choice_fun279(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_choice_fun279, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_choice_fun279(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_0_10066 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/flip>*/;
  bool _x_x280;
  {
    struct kk_std_core_hnd_Ev* _con_x281 = kk_std_core_hnd__as_Ev(ev_0_10066, _ctx);
    kk_box_t _box_x51 = _con_x281->hnd;
    int32_t m_0 = _con_x281->marker;
    kk_main__flip h_0 = kk_main__flip_unbox(_box_x51, KK_BORROWED, _ctx);
    kk_main__flip_dup(h_0, _ctx);
    {
      struct kk_main__Hnd_flip* _con_x282 = kk_main__as_Hnd_flip(h_0, _ctx);
      kk_integer_t _pat_0_2 = _con_x282->_cfc;
      kk_std_core_hnd__clause0 _ctl_flip = _con_x282->_ctl_flip;
      if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
        kk_integer_drop(_pat_0_2, _ctx);
        kk_datatype_ptr_free(h_0, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_flip, _ctx);
        kk_datatype_ptr_decref(h_0, _ctx);
      }
      {
        kk_function_t _fun_unbox_x54 = _ctl_flip.clause;
        kk_function_t _bv_x60 = _fun_unbox_x54; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x283 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x60, (_bv_x60, m_0, ev_0_10066, _ctx), _ctx); /*3004*/
        _x_x280 = kk_bool_unbox(_x_x283); /*bool*/
      }
    }
  }
  return kk_bool_box(_x_x280);
}


// lift anonymous function
struct kk_main_choice_fun285__t {
  struct kk_function_s _base;
  kk_integer_t n_0;
};
static kk_box_t kk_main_choice_fun285(kk_function_t _fself, kk_box_t _b_x73, kk_context_t* _ctx);
static kk_function_t kk_main_new_choice_fun285(kk_integer_t n_0, kk_context_t* _ctx) {
  struct kk_main_choice_fun285__t* _self = kk_function_alloc_as(struct kk_main_choice_fun285__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_choice_fun285, kk_context());
  _self->n_0 = n_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_choice_fun285(kk_function_t _fself, kk_box_t _b_x73, kk_context_t* _ctx) {
  struct kk_main_choice_fun285__t* _self = kk_function_as(struct kk_main_choice_fun285__t*, _fself, _ctx);
  kk_integer_t n_0 = _self->n_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(n_0, _ctx);}, {}, _ctx)
  bool _y_x10023_0_80 = kk_bool_unbox(_b_x73); /*bool*/;
  kk_integer_t _x_x286 = kk_main__mlift_choice_10050(n_0, _y_x10023_0_80, _ctx); /*int*/
  return kk_integer_box(_x_x286, _ctx);
}

kk_integer_t kk_main_choice(kk_integer_t n_0, kk_context_t* _ctx) { /* (n : int) -> <div,fail,flip> int */ 
  kk__tailcall: ;
  bool _match_x237 = kk_integer_lt_borrow(n_0,(kk_integer_from_small(1)),kk_context()); /*bool*/;
  if (_match_x237) {
    kk_integer_drop(n_0, _ctx);
    kk_ssize_t _b_x49_74 = (KK_IZ(0)); /*hnd/ev-index*/;
    kk_box_t _x_x269 = kk_std_core_hnd__open_at0(_b_x49_74, kk_main_new_choice_fun270(_ctx), _ctx); /*1000*/
    return kk_integer_unbox(_x_x269, _ctx);
  }
  {
    kk_ssize_t _b_x63_65 = (KK_IZ(1)); /*hnd/ev-index*/;
    bool x_10063;
    kk_box_t _x_x278 = kk_std_core_hnd__open_at0(_b_x63_65, kk_main_new_choice_fun279(_ctx), _ctx); /*1000*/
    x_10063 = kk_bool_unbox(_x_x278); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x284 = kk_std_core_hnd_yield_extend(kk_main_new_choice_fun285(n_0, _ctx), _ctx); /*3003*/
      return kk_integer_unbox(_x_x284, _ctx);
    }
    if (x_10063) {
      return n_0;
    }
    { // tailcall
      kk_integer_t _x_x287 = kk_integer_add_small_const(n_0, -1, _ctx); /*int*/
      n_0 = _x_x287;
      goto kk__tailcall;
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_triple_10051_fun292__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_triple_10051_fun292(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_triple_10051_fun292(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_triple_10051_fun292, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main__mlift_triple_10051_fun296__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x89;
};
static kk_box_t kk_main__mlift_triple_10051_fun296(kk_function_t _fself, int32_t _b_x93, kk_std_core_hnd__ev _b_x94, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_triple_10051_fun296(kk_function_t _fun_unbox_x89, kk_context_t* _ctx) {
  struct kk_main__mlift_triple_10051_fun296__t* _self = kk_function_alloc_as(struct kk_main__mlift_triple_10051_fun296__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_triple_10051_fun296, kk_context());
  _self->_fun_unbox_x89 = _fun_unbox_x89;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_triple_10051_fun296(kk_function_t _fself, int32_t _b_x93, kk_std_core_hnd__ev _b_x94, kk_context_t* _ctx) {
  struct kk_main__mlift_triple_10051_fun296__t* _self = kk_function_as(struct kk_main__mlift_triple_10051_fun296__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x89 = _self->_fun_unbox_x89; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x89, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple3 _x_x297;
  int32_t _b_x90_108 = _b_x93; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x91_109 = _b_x94; /*hnd/ev<main/fail>*/;
  kk_box_t _x_x298 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x89, (_fun_unbox_x89, _b_x90_108, _b_x91_109, _ctx), _ctx); /*1005*/
  _x_x297 = kk_std_core_types__tuple3_unbox(_x_x298, KK_OWNED, _ctx); /*(int, int, int)*/
  return kk_std_core_types__tuple3_box(_x_x297, _ctx);
}
static kk_box_t kk_main__mlift_triple_10051_fun292(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_10068 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/fail>*/;
  kk_std_core_types__tuple3 _x_x293;
  {
    struct kk_std_core_hnd_Ev* _con_x294 = kk_std_core_hnd__as_Ev(ev_10068, _ctx);
    kk_box_t _box_x86 = _con_x294->hnd;
    int32_t m = _con_x294->marker;
    kk_main__fail h = kk_main__fail_unbox(_box_x86, KK_BORROWED, _ctx);
    kk_main__fail_dup(h, _ctx);
    {
      struct kk_main__Hnd_fail* _con_x295 = kk_main__as_Hnd_fail(h, _ctx);
      kk_integer_t _pat_0_1 = _con_x295->_cfc;
      kk_std_core_hnd__clause0 _ctl_fail = _con_x295->_ctl_fail;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_1, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_fail, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x89 = _ctl_fail.clause;
        kk_function_t _bv_x95 = (kk_main__new_mlift_triple_10051_fun296(_fun_unbox_x89, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x299 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x95, (_bv_x95, m, ev_10068, _ctx), _ctx); /*3004*/
        _x_x293 = kk_std_core_types__tuple3_unbox(_x_x299, KK_OWNED, _ctx); /*(int, int, int)*/
      }
    }
  }
  return kk_std_core_types__tuple3_box(_x_x293, _ctx);
}

kk_std_core_types__tuple3 kk_main__mlift_triple_10051(kk_integer_t i, kk_integer_t j, kk_integer_t s, kk_integer_t k, kk_context_t* _ctx) { /* (i : int, j : int, s : int, k : int) -> <div,fail,flip> (int, int, int) */ 
  kk_integer_t x_1_10043;
  kk_integer_t _x_x288 = kk_integer_dup(i, _ctx); /*int*/
  kk_integer_t _x_x289 = kk_integer_dup(j, _ctx); /*int*/
  x_1_10043 = kk_integer_add(_x_x288,_x_x289,kk_context()); /*int*/
  bool _match_x234;
  kk_integer_t _brw_x235;
  kk_integer_t _x_x290 = kk_integer_dup(k, _ctx); /*int*/
  _brw_x235 = kk_integer_add(x_1_10043,_x_x290,kk_context()); /*int*/
  bool _brw_x236 = kk_integer_eq_borrow(_brw_x235,s,kk_context()); /*bool*/;
  kk_integer_drop(_brw_x235, _ctx);
  kk_integer_drop(s, _ctx);
  _match_x234 = _brw_x236; /*bool*/
  if (_match_x234) {
    return kk_std_core_types__new_Tuple3(kk_integer_box(i, _ctx), kk_integer_box(j, _ctx), kk_integer_box(k, _ctx), _ctx);
  }
  {
    kk_integer_drop(k, _ctx);
    kk_integer_drop(j, _ctx);
    kk_integer_drop(i, _ctx);
    kk_ssize_t _b_x98_103 = (KK_IZ(0)); /*hnd/ev-index*/;
    kk_box_t _x_x291 = kk_std_core_hnd__open_at0(_b_x98_103, kk_main__new_mlift_triple_10051_fun292(_ctx), _ctx); /*1000*/
    return kk_std_core_types__tuple3_unbox(_x_x291, KK_OWNED, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_triple_10052_fun303__t {
  struct kk_function_s _base;
  kk_integer_t i;
  kk_integer_t j;
  kk_integer_t s;
};
static kk_box_t kk_main__mlift_triple_10052_fun303(kk_function_t _fself, kk_box_t _b_x111, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_triple_10052_fun303(kk_integer_t i, kk_integer_t j, kk_integer_t s, kk_context_t* _ctx) {
  struct kk_main__mlift_triple_10052_fun303__t* _self = kk_function_alloc_as(struct kk_main__mlift_triple_10052_fun303__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_triple_10052_fun303, kk_context());
  _self->i = i;
  _self->j = j;
  _self->s = s;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_triple_10052_fun303(kk_function_t _fself, kk_box_t _b_x111, kk_context_t* _ctx) {
  struct kk_main__mlift_triple_10052_fun303__t* _self = kk_function_as(struct kk_main__mlift_triple_10052_fun303__t*, _fself, _ctx);
  kk_integer_t i = _self->i; /* int */
  kk_integer_t j = _self->j; /* int */
  kk_integer_t s = _self->s; /* int */
  kk_drop_match(_self, {kk_integer_dup(i, _ctx);kk_integer_dup(j, _ctx);kk_integer_dup(s, _ctx);}, {}, _ctx)
  kk_integer_t k_113 = kk_integer_unbox(_b_x111, _ctx); /*int*/;
  kk_std_core_types__tuple3 _x_x304 = kk_main__mlift_triple_10051(i, j, s, k_113, _ctx); /*(int, int, int)*/
  return kk_std_core_types__tuple3_box(_x_x304, _ctx);
}

kk_std_core_types__tuple3 kk_main__mlift_triple_10052(kk_integer_t i, kk_integer_t s, kk_integer_t j, kk_context_t* _ctx) { /* (i : int, s : int, j : int) -> <div,fail,flip> (int, int, int) */ 
  kk_integer_t x_10070;
  kk_integer_t _x_x300;
  kk_integer_t _x_x301 = kk_integer_dup(j, _ctx); /*int*/
  _x_x300 = kk_integer_add_small_const(_x_x301, -1, _ctx); /*int*/
  x_10070 = kk_main_choice(_x_x300, _ctx); /*int*/
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10070, _ctx);
    kk_box_t _x_x302 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_triple_10052_fun303(i, j, s, _ctx), _ctx); /*3003*/
    return kk_std_core_types__tuple3_unbox(_x_x302, KK_OWNED, _ctx);
  }
  {
    return kk_main__mlift_triple_10051(i, j, s, x_10070, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_triple_10053_fun308__t {
  struct kk_function_s _base;
  kk_integer_t i;
  kk_integer_t s;
};
static kk_box_t kk_main__mlift_triple_10053_fun308(kk_function_t _fself, kk_box_t _b_x115, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_triple_10053_fun308(kk_integer_t i, kk_integer_t s, kk_context_t* _ctx) {
  struct kk_main__mlift_triple_10053_fun308__t* _self = kk_function_alloc_as(struct kk_main__mlift_triple_10053_fun308__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_triple_10053_fun308, kk_context());
  _self->i = i;
  _self->s = s;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_triple_10053_fun308(kk_function_t _fself, kk_box_t _b_x115, kk_context_t* _ctx) {
  struct kk_main__mlift_triple_10053_fun308__t* _self = kk_function_as(struct kk_main__mlift_triple_10053_fun308__t*, _fself, _ctx);
  kk_integer_t i = _self->i; /* int */
  kk_integer_t s = _self->s; /* int */
  kk_drop_match(_self, {kk_integer_dup(i, _ctx);kk_integer_dup(s, _ctx);}, {}, _ctx)
  kk_integer_t j_117 = kk_integer_unbox(_b_x115, _ctx); /*int*/;
  kk_std_core_types__tuple3 _x_x309 = kk_main__mlift_triple_10052(i, s, j_117, _ctx); /*(int, int, int)*/
  return kk_std_core_types__tuple3_box(_x_x309, _ctx);
}

kk_std_core_types__tuple3 kk_main__mlift_triple_10053(kk_integer_t s, kk_integer_t i, kk_context_t* _ctx) { /* (s : int, i : int) -> <div,fail,flip> (int, int, int) */ 
  kk_integer_t x_10072;
  kk_integer_t _x_x305;
  kk_integer_t _x_x306 = kk_integer_dup(i, _ctx); /*int*/
  _x_x305 = kk_integer_add_small_const(_x_x306, -1, _ctx); /*int*/
  x_10072 = kk_main_choice(_x_x305, _ctx); /*int*/
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10072, _ctx);
    kk_box_t _x_x307 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_triple_10053_fun308(i, s, _ctx), _ctx); /*3003*/
    return kk_std_core_types__tuple3_unbox(_x_x307, KK_OWNED, _ctx);
  }
  {
    return kk_main__mlift_triple_10052(i, s, x_10072, _ctx);
  }
}


// lift anonymous function
struct kk_main_triple_fun311__t {
  struct kk_function_s _base;
  kk_integer_t s;
};
static kk_box_t kk_main_triple_fun311(kk_function_t _fself, kk_box_t _b_x119, kk_context_t* _ctx);
static kk_function_t kk_main_new_triple_fun311(kk_integer_t s, kk_context_t* _ctx) {
  struct kk_main_triple_fun311__t* _self = kk_function_alloc_as(struct kk_main_triple_fun311__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_triple_fun311, kk_context());
  _self->s = s;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_triple_fun311(kk_function_t _fself, kk_box_t _b_x119, kk_context_t* _ctx) {
  struct kk_main_triple_fun311__t* _self = kk_function_as(struct kk_main_triple_fun311__t*, _fself, _ctx);
  kk_integer_t s = _self->s; /* int */
  kk_drop_match(_self, {kk_integer_dup(s, _ctx);}, {}, _ctx)
  kk_integer_t i_150 = kk_integer_unbox(_b_x119, _ctx); /*int*/;
  kk_std_core_types__tuple3 _x_x312 = kk_main__mlift_triple_10053(s, i_150, _ctx); /*(int, int, int)*/
  return kk_std_core_types__tuple3_box(_x_x312, _ctx);
}


// lift anonymous function
struct kk_main_triple_fun316__t {
  struct kk_function_s _base;
  kk_integer_t s;
  kk_integer_t x_10074;
};
static kk_box_t kk_main_triple_fun316(kk_function_t _fself, kk_box_t _b_x121, kk_context_t* _ctx);
static kk_function_t kk_main_new_triple_fun316(kk_integer_t s, kk_integer_t x_10074, kk_context_t* _ctx) {
  struct kk_main_triple_fun316__t* _self = kk_function_alloc_as(struct kk_main_triple_fun316__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_triple_fun316, kk_context());
  _self->s = s;
  _self->x_10074 = x_10074;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_triple_fun316(kk_function_t _fself, kk_box_t _b_x121, kk_context_t* _ctx) {
  struct kk_main_triple_fun316__t* _self = kk_function_as(struct kk_main_triple_fun316__t*, _fself, _ctx);
  kk_integer_t s = _self->s; /* int */
  kk_integer_t x_10074 = _self->x_10074; /* int */
  kk_drop_match(_self, {kk_integer_dup(s, _ctx);kk_integer_dup(x_10074, _ctx);}, {}, _ctx)
  kk_integer_t j_151 = kk_integer_unbox(_b_x121, _ctx); /*int*/;
  kk_std_core_types__tuple3 _x_x317 = kk_main__mlift_triple_10052(x_10074, s, j_151, _ctx); /*(int, int, int)*/
  return kk_std_core_types__tuple3_box(_x_x317, _ctx);
}


// lift anonymous function
struct kk_main_triple_fun321__t {
  struct kk_function_s _base;
  kk_integer_t s;
  kk_integer_t x_0_10077;
  kk_integer_t x_10074;
};
static kk_box_t kk_main_triple_fun321(kk_function_t _fself, kk_box_t _b_x123, kk_context_t* _ctx);
static kk_function_t kk_main_new_triple_fun321(kk_integer_t s, kk_integer_t x_0_10077, kk_integer_t x_10074, kk_context_t* _ctx) {
  struct kk_main_triple_fun321__t* _self = kk_function_alloc_as(struct kk_main_triple_fun321__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_triple_fun321, kk_context());
  _self->s = s;
  _self->x_0_10077 = x_0_10077;
  _self->x_10074 = x_10074;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_triple_fun321(kk_function_t _fself, kk_box_t _b_x123, kk_context_t* _ctx) {
  struct kk_main_triple_fun321__t* _self = kk_function_as(struct kk_main_triple_fun321__t*, _fself, _ctx);
  kk_integer_t s = _self->s; /* int */
  kk_integer_t x_0_10077 = _self->x_0_10077; /* int */
  kk_integer_t x_10074 = _self->x_10074; /* int */
  kk_drop_match(_self, {kk_integer_dup(s, _ctx);kk_integer_dup(x_0_10077, _ctx);kk_integer_dup(x_10074, _ctx);}, {}, _ctx)
  kk_integer_t k_152 = kk_integer_unbox(_b_x123, _ctx); /*int*/;
  kk_std_core_types__tuple3 _x_x322 = kk_main__mlift_triple_10051(x_10074, x_0_10077, s, k_152, _ctx); /*(int, int, int)*/
  return kk_std_core_types__tuple3_box(_x_x322, _ctx);
}


// lift anonymous function
struct kk_main_triple_fun327__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_triple_fun327(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_triple_fun327(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_triple_fun327, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_triple_fun331__t {
  struct kk_function_s _base;
  kk_function_t _fun_unbox_x130;
};
static kk_box_t kk_main_triple_fun331(kk_function_t _fself, int32_t _b_x134, kk_std_core_hnd__ev _b_x135, kk_context_t* _ctx);
static kk_function_t kk_main_new_triple_fun331(kk_function_t _fun_unbox_x130, kk_context_t* _ctx) {
  struct kk_main_triple_fun331__t* _self = kk_function_alloc_as(struct kk_main_triple_fun331__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_triple_fun331, kk_context());
  _self->_fun_unbox_x130 = _fun_unbox_x130;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_triple_fun331(kk_function_t _fself, int32_t _b_x134, kk_std_core_hnd__ev _b_x135, kk_context_t* _ctx) {
  struct kk_main_triple_fun331__t* _self = kk_function_as(struct kk_main_triple_fun331__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x130 = _self->_fun_unbox_x130; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x130, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple3 _x_x332;
  int32_t _b_x131_155 = _b_x134; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x132_156 = _b_x135; /*hnd/ev<main/fail>*/;
  kk_box_t _x_x333 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x130, (_fun_unbox_x130, _b_x131_155, _b_x132_156, _ctx), _ctx); /*1005*/
  _x_x332 = kk_std_core_types__tuple3_unbox(_x_x333, KK_OWNED, _ctx); /*(int, int, int)*/
  return kk_std_core_types__tuple3_box(_x_x332, _ctx);
}
static kk_box_t kk_main_triple_fun327(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_10083 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/fail>*/;
  kk_std_core_types__tuple3 _x_x328;
  {
    struct kk_std_core_hnd_Ev* _con_x329 = kk_std_core_hnd__as_Ev(ev_10083, _ctx);
    kk_box_t _box_x127 = _con_x329->hnd;
    int32_t m = _con_x329->marker;
    kk_main__fail h = kk_main__fail_unbox(_box_x127, KK_BORROWED, _ctx);
    kk_main__fail_dup(h, _ctx);
    {
      struct kk_main__Hnd_fail* _con_x330 = kk_main__as_Hnd_fail(h, _ctx);
      kk_integer_t _pat_0_4 = _con_x330->_cfc;
      kk_std_core_hnd__clause0 _ctl_fail = _con_x330->_ctl_fail;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0_4, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_fail, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x130 = _ctl_fail.clause;
        kk_function_t _bv_x136 = (kk_main_new_triple_fun331(_fun_unbox_x130, _ctx)); /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x334 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x136, (_bv_x136, m, ev_10083, _ctx), _ctx); /*3004*/
        _x_x328 = kk_std_core_types__tuple3_unbox(_x_x334, KK_OWNED, _ctx); /*(int, int, int)*/
      }
    }
  }
  return kk_std_core_types__tuple3_box(_x_x328, _ctx);
}

kk_std_core_types__tuple3 kk_main_triple(kk_integer_t n, kk_integer_t s, kk_context_t* _ctx) { /* (n : int, s : int) -> <div,fail,flip> (int, int, int) */ 
  kk_integer_t x_10074 = kk_main_choice(n, _ctx); /*int*/;
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10074, _ctx);
    kk_box_t _x_x310 = kk_std_core_hnd_yield_extend(kk_main_new_triple_fun311(s, _ctx), _ctx); /*3003*/
    return kk_std_core_types__tuple3_unbox(_x_x310, KK_OWNED, _ctx);
  }
  {
    kk_integer_t x_0_10077;
    kk_integer_t _x_x313;
    kk_integer_t _x_x314 = kk_integer_dup(x_10074, _ctx); /*int*/
    _x_x313 = kk_integer_add_small_const(_x_x314, -1, _ctx); /*int*/
    x_0_10077 = kk_main_choice(_x_x313, _ctx); /*int*/
    if (kk_yielding(kk_context())) {
      kk_integer_drop(x_0_10077, _ctx);
      kk_box_t _x_x315 = kk_std_core_hnd_yield_extend(kk_main_new_triple_fun316(s, x_10074, _ctx), _ctx); /*3003*/
      return kk_std_core_types__tuple3_unbox(_x_x315, KK_OWNED, _ctx);
    }
    {
      kk_integer_t x_1_10080;
      kk_integer_t _x_x318;
      kk_integer_t _x_x319 = kk_integer_dup(x_0_10077, _ctx); /*int*/
      _x_x318 = kk_integer_add_small_const(_x_x319, -1, _ctx); /*int*/
      x_1_10080 = kk_main_choice(_x_x318, _ctx); /*int*/
      if (kk_yielding(kk_context())) {
        kk_integer_drop(x_1_10080, _ctx);
        kk_box_t _x_x320 = kk_std_core_hnd_yield_extend(kk_main_new_triple_fun321(s, x_0_10077, x_10074, _ctx), _ctx); /*3003*/
        return kk_std_core_types__tuple3_unbox(_x_x320, KK_OWNED, _ctx);
      }
      {
        kk_integer_t x_1_10043;
        kk_integer_t _x_x323 = kk_integer_dup(x_10074, _ctx); /*int*/
        kk_integer_t _x_x324 = kk_integer_dup(x_0_10077, _ctx); /*int*/
        x_1_10043 = kk_integer_add(_x_x323,_x_x324,kk_context()); /*int*/
        bool _match_x229;
        kk_integer_t _brw_x230;
        kk_integer_t _x_x325 = kk_integer_dup(x_1_10080, _ctx); /*int*/
        _brw_x230 = kk_integer_add(x_1_10043,_x_x325,kk_context()); /*int*/
        bool _brw_x231 = kk_integer_eq_borrow(_brw_x230,s,kk_context()); /*bool*/;
        kk_integer_drop(_brw_x230, _ctx);
        kk_integer_drop(s, _ctx);
        _match_x229 = _brw_x231; /*bool*/
        if (_match_x229) {
          return kk_std_core_types__new_Tuple3(kk_integer_box(x_10074, _ctx), kk_integer_box(x_0_10077, _ctx), kk_integer_box(x_1_10080, _ctx), _ctx);
        }
        {
          kk_integer_drop(x_1_10080, _ctx);
          kk_integer_drop(x_10074, _ctx);
          kk_integer_drop(x_0_10077, _ctx);
          kk_ssize_t _b_x139_147 = (KK_IZ(0)); /*hnd/ev-index*/;
          kk_box_t _x_x326 = kk_std_core_hnd__open_at0(_b_x139_147, kk_main_new_triple_fun327(_ctx), _ctx); /*1000*/
          return kk_std_core_types__tuple3_unbox(_x_x326, KK_OWNED, _ctx);
        }
      }
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_run_10054_fun336__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_run_10054_fun336(kk_function_t _fself, kk_box_t _b_x162, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_run_10054_fun336(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_run_10054_fun336, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_run_10054_fun336(kk_function_t _fself, kk_box_t _b_x162, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__tuple3 _pat_x25__10_165 = kk_std_core_types__tuple3_unbox(_b_x162, KK_OWNED, _ctx); /*(int, int, int)*/;
  kk_integer_t _x_x337;
  {
    kk_box_t _box_x157 = _pat_x25__10_165.fst;
    kk_box_t _box_x158 = _pat_x25__10_165.snd;
    kk_box_t _box_x159 = _pat_x25__10_165.thd;
    kk_integer_t a = kk_integer_unbox(_box_x157, _ctx);
    kk_integer_t b = kk_integer_unbox(_box_x158, _ctx);
    kk_integer_t c = kk_integer_unbox(_box_x159, _ctx);
    kk_integer_dup(a, _ctx);
    kk_integer_dup(b, _ctx);
    kk_integer_dup(c, _ctx);
    kk_std_core_types__tuple3_drop(_pat_x25__10_165, _ctx);
    kk_integer_t x_1_10008 = kk_integer_mul((kk_integer_from_small(53)),a,kk_context()); /*int*/;
    kk_integer_t y_1_10009 = kk_integer_mul((kk_integer_from_small(2809)),b,kk_context()); /*int*/;
    kk_integer_t x_0_10006 = kk_integer_add(x_1_10008,y_1_10009,kk_context()); /*int*/;
    kk_integer_t y_0_10007 = kk_integer_mul((kk_integer_from_int(148877, _ctx)),c,kk_context()); /*int*/;
    kk_integer_t _x_x338 = kk_integer_add(x_0_10006,y_0_10007,kk_context()); /*int*/
    _x_x337 = kk_integer_mod(_x_x338,(kk_integer_from_int(1000000007, _ctx)),kk_context()); /*int*/
  }
  return kk_integer_box(_x_x337, _ctx);
}

kk_integer_t kk_main__mlift_run_10054(kk_std_core_types__tuple3 _y_x10033, kk_context_t* _ctx) { /* ((int, int, int)) -> <div,fail,flip> int */ 
  kk_box_t _x_x335 = kk_std_core_hnd__open_none1(kk_main__new_mlift_run_10054_fun336(_ctx), kk_std_core_types__tuple3_box(_y_x10033, _ctx), _ctx); /*1001*/
  return kk_integer_unbox(_x_x335, _ctx);
}


// lift anonymous function
struct kk_main_run_fun340__t {
  struct kk_function_s _base;
};
static bool kk_main_run_fun340(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun340(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun340, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun342__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun342(kk_function_t _fself, kk_function_t _b_x175, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun342(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun342, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun343__t {
  struct kk_function_s _base;
  kk_function_t _b_x175;
};
static kk_integer_t kk_main_run_fun343(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x176, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun343(kk_function_t _b_x175, kk_context_t* _ctx) {
  struct kk_main_run_fun343__t* _self = kk_function_alloc_as(struct kk_main_run_fun343__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun343, kk_context());
  _self->_b_x175 = _b_x175;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun343(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x176, kk_context_t* _ctx) {
  struct kk_main_run_fun343__t* _self = kk_function_as(struct kk_main_run_fun343__t*, _fself, _ctx);
  kk_function_t _b_x175 = _self->_b_x175; /* (hnd/resume-result<3003,3005>) -> 3004 3005 */
  kk_drop_match(_self, {kk_function_dup(_b_x175, _ctx);}, {}, _ctx)
  kk_box_t _x_x344 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x175, (_b_x175, _b_x176, _ctx), _ctx); /*3005*/
  return kk_integer_unbox(_x_x344, _ctx);
}


// lift anonymous function
struct kk_main_run_fun345__t {
  struct kk_function_s _base;
};
static kk_integer_t kk_main_run_fun345(kk_function_t _fself, kk_unit_t ___wildcard_x730__55, kk_function_t r, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun345(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun345, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_integer_t kk_main_run_fun345(kk_function_t _fself, kk_unit_t ___wildcard_x730__55, kk_function_t r, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t x_10004;
  kk_function_t _x_x346 = kk_function_dup(r, _ctx); /*(bool) -> div int*/
  x_10004 = kk_function_call(kk_integer_t, (kk_function_t, bool, kk_context_t*), _x_x346, (_x_x346, true, _ctx), _ctx); /*int*/
  kk_integer_t y_10005 = kk_function_call(kk_integer_t, (kk_function_t, bool, kk_context_t*), r, (r, false, _ctx), _ctx); /*int*/;
  kk_integer_t _x_x347 = kk_integer_add(x_10004,y_10005,kk_context()); /*int*/
  return kk_integer_mod(_x_x347,(kk_integer_from_int(1000000007, _ctx)),kk_context());
}


// lift anonymous function
struct kk_main_run_fun348__t {
  struct kk_function_s _base;
  kk_function_t _b_x167_208;
};
static kk_box_t kk_main_run_fun348(kk_function_t _fself, kk_box_t _b_x169, kk_function_t _b_x170, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun348(kk_function_t _b_x167_208, kk_context_t* _ctx) {
  struct kk_main_run_fun348__t* _self = kk_function_alloc_as(struct kk_main_run_fun348__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun348, kk_context());
  _self->_b_x167_208 = _b_x167_208;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun351__t {
  struct kk_function_s _base;
  kk_function_t _b_x170;
};
static kk_integer_t kk_main_run_fun351(kk_function_t _fself, bool _b_x171, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun351(kk_function_t _b_x170, kk_context_t* _ctx) {
  struct kk_main_run_fun351__t* _self = kk_function_alloc_as(struct kk_main_run_fun351__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun351, kk_context());
  _self->_b_x170 = _b_x170;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun351(kk_function_t _fself, bool _b_x171, kk_context_t* _ctx) {
  struct kk_main_run_fun351__t* _self = kk_function_as(struct kk_main_run_fun351__t*, _fself, _ctx);
  kk_function_t _b_x170 = _self->_b_x170; /* (3004) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x170, _ctx);}, {}, _ctx)
  kk_box_t _x_x352 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x170, (_b_x170, kk_bool_box(_b_x171), _ctx), _ctx); /*3006*/
  return kk_integer_unbox(_x_x352, _ctx);
}
static kk_box_t kk_main_run_fun348(kk_function_t _fself, kk_box_t _b_x169, kk_function_t _b_x170, kk_context_t* _ctx) {
  struct kk_main_run_fun348__t* _self = kk_function_as(struct kk_main_run_fun348__t*, _fself, _ctx);
  kk_function_t _b_x167_208 = _self->_b_x167_208; /* ((), r : (bool) -> div int) -> div int */
  kk_drop_match(_self, {kk_function_dup(_b_x167_208, _ctx);}, {}, _ctx)
  kk_integer_t _x_x349;
  kk_unit_t _x_x350 = kk_Unit;
  kk_unit_unbox(_b_x169);
  _x_x349 = kk_function_call(kk_integer_t, (kk_function_t, kk_unit_t, kk_function_t, kk_context_t*), _b_x167_208, (_b_x167_208, _x_x350, kk_main_new_run_fun351(_b_x170, _ctx), _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x349, _ctx);
}


// lift anonymous function
struct kk_main_run_fun353__t {
  struct kk_function_s _base;
  kk_function_t _b_x168_209;
};
static kk_box_t kk_main_run_fun353(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x172, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun353(kk_function_t _b_x168_209, kk_context_t* _ctx) {
  struct kk_main_run_fun353__t* _self = kk_function_alloc_as(struct kk_main_run_fun353__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun353, kk_context());
  _self->_b_x168_209 = _b_x168_209;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun353(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x172, kk_context_t* _ctx) {
  struct kk_main_run_fun353__t* _self = kk_function_as(struct kk_main_run_fun353__t*, _fself, _ctx);
  kk_function_t _b_x168_209 = _self->_b_x168_209; /* (hnd/resume-result<bool,int>) -> div int */
  kk_drop_match(_self, {kk_function_dup(_b_x168_209, _ctx);}, {}, _ctx)
  kk_integer_t _x_x354 = kk_function_call(kk_integer_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x168_209, (_b_x168_209, _b_x172, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x354, _ctx);
}
static kk_box_t kk_main_run_fun342(kk_function_t _fself, kk_function_t _b_x175, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_t k_219 = kk_main_new_run_fun343(_b_x175, _ctx); /*(hnd/resume-result<bool,int>) -> div int*/;
  kk_unit_t _b_x166_207 = kk_Unit;
  kk_function_t _b_x167_208 = kk_main_new_run_fun345(_ctx); /*((), r : (bool) -> div int) -> div int*/;
  kk_function_t _b_x168_209 = k_219; /*(hnd/resume-result<bool,int>) -> div int*/;
  return kk_std_core_hnd_protect(kk_unit_box(_b_x166_207), kk_main_new_run_fun348(_b_x167_208, _ctx), kk_main_new_run_fun353(_b_x168_209, _ctx), _ctx);
}
static bool kk_main_run_fun340(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x730__16, (KK_I32(3)), _ctx);
  kk_box_t _x_x341 = kk_std_core_hnd_yield_to(m, kk_main_new_run_fun342(_ctx), _ctx); /*3003*/
  return kk_bool_unbox(_x_x341);
}


// lift anonymous function
struct kk_main_run_fun357__t {
  struct kk_function_s _base;
  kk_function_t _b_x177_204;
};
static kk_box_t kk_main_run_fun357(kk_function_t _fself, int32_t _b_x178, kk_std_core_hnd__ev _b_x179, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun357(kk_function_t _b_x177_204, kk_context_t* _ctx) {
  struct kk_main_run_fun357__t* _self = kk_function_alloc_as(struct kk_main_run_fun357__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun357, kk_context());
  _self->_b_x177_204 = _b_x177_204;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun357(kk_function_t _fself, int32_t _b_x178, kk_std_core_hnd__ev _b_x179, kk_context_t* _ctx) {
  struct kk_main_run_fun357__t* _self = kk_function_as(struct kk_main_run_fun357__t*, _fself, _ctx);
  kk_function_t _b_x177_204 = _self->_b_x177_204; /* (m : hnd/marker<div,int>, hnd/ev<main/flip>) -> div bool */
  kk_drop_match(_self, {kk_function_dup(_b_x177_204, _ctx);}, {}, _ctx)
  bool _x_x358 = kk_function_call(bool, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _b_x177_204, (_b_x177_204, _b_x178, _b_x179, _ctx), _ctx); /*bool*/
  return kk_bool_box(_x_x358);
}


// lift anonymous function
struct kk_main_run_fun359__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun359(kk_function_t _fself, kk_box_t _b_x200, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun359(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun359, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun359(kk_function_t _fself, kk_box_t _b_x200, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_220 = kk_integer_unbox(_b_x200, _ctx); /*int*/;
  return kk_integer_box(_x_220, _ctx);
}


// lift anonymous function
struct kk_main_run_fun360__t {
  struct kk_function_s _base;
  kk_integer_t n;
  kk_integer_t s;
};
static kk_box_t kk_main_run_fun360(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun360(kk_integer_t n, kk_integer_t s, kk_context_t* _ctx) {
  struct kk_main_run_fun360__t* _self = kk_function_alloc_as(struct kk_main_run_fun360__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun360, kk_context());
  _self->n = n;
  _self->s = s;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun362__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun362(kk_function_t _fself, int32_t m_0, kk_std_core_hnd__ev ___wildcard_x730__16_0, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun362(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun362, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun363__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun363(kk_function_t _fself, kk_function_t _b_x189, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun363(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun363, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun364__t {
  struct kk_function_s _base;
  kk_function_t _b_x189;
};
static kk_integer_t kk_main_run_fun364(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x190, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun364(kk_function_t _b_x189, kk_context_t* _ctx) {
  struct kk_main_run_fun364__t* _self = kk_function_alloc_as(struct kk_main_run_fun364__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun364, kk_context());
  _self->_b_x189 = _b_x189;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun364(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x190, kk_context_t* _ctx) {
  struct kk_main_run_fun364__t* _self = kk_function_as(struct kk_main_run_fun364__t*, _fself, _ctx);
  kk_function_t _b_x189 = _self->_b_x189; /* (hnd/resume-result<3003,3005>) -> 3004 3005 */
  kk_drop_match(_self, {kk_function_dup(_b_x189, _ctx);}, {}, _ctx)
  kk_box_t _x_x365 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x189, (_b_x189, _b_x190, _ctx), _ctx); /*3005*/
  return kk_integer_unbox(_x_x365, _ctx);
}


// lift anonymous function
struct kk_main_run_fun366__t {
  struct kk_function_s _base;
};
static kk_integer_t kk_main_run_fun366(kk_function_t _fself, kk_unit_t ___wildcard_x730__55_0, kk_function_t r_0, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun366(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun366, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_integer_t kk_main_run_fun366(kk_function_t _fself, kk_unit_t ___wildcard_x730__55_0, kk_function_t r_0, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_drop(r_0, _ctx);
  return kk_integer_from_small(0);
}


// lift anonymous function
struct kk_main_run_fun367__t {
  struct kk_function_s _base;
  kk_function_t _b_x181_216;
};
static kk_box_t kk_main_run_fun367(kk_function_t _fself, kk_box_t _b_x183, kk_function_t _b_x184, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun367(kk_function_t _b_x181_216, kk_context_t* _ctx) {
  struct kk_main_run_fun367__t* _self = kk_function_alloc_as(struct kk_main_run_fun367__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun367, kk_context());
  _self->_b_x181_216 = _b_x181_216;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun370__t {
  struct kk_function_s _base;
  kk_function_t _b_x184;
};
static kk_integer_t kk_main_run_fun370(kk_function_t _fself, kk_box_t _b_x185, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun370(kk_function_t _b_x184, kk_context_t* _ctx) {
  struct kk_main_run_fun370__t* _self = kk_function_alloc_as(struct kk_main_run_fun370__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun370, kk_context());
  _self->_b_x184 = _b_x184;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun370(kk_function_t _fself, kk_box_t _b_x185, kk_context_t* _ctx) {
  struct kk_main_run_fun370__t* _self = kk_function_as(struct kk_main_run_fun370__t*, _fself, _ctx);
  kk_function_t _b_x184 = _self->_b_x184; /* (3004) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x184, _ctx);}, {}, _ctx)
  kk_box_t _x_x371 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x184, (_b_x184, _b_x185, _ctx), _ctx); /*3006*/
  return kk_integer_unbox(_x_x371, _ctx);
}
static kk_box_t kk_main_run_fun367(kk_function_t _fself, kk_box_t _b_x183, kk_function_t _b_x184, kk_context_t* _ctx) {
  struct kk_main_run_fun367__t* _self = kk_function_as(struct kk_main_run_fun367__t*, _fself, _ctx);
  kk_function_t _b_x181_216 = _self->_b_x181_216; /* ((), r@0 : (726) -> <div,main/flip> int) -> <div,main/flip> int */
  kk_drop_match(_self, {kk_function_dup(_b_x181_216, _ctx);}, {}, _ctx)
  kk_integer_t _x_x368;
  kk_unit_t _x_x369 = kk_Unit;
  kk_unit_unbox(_b_x183);
  _x_x368 = kk_function_call(kk_integer_t, (kk_function_t, kk_unit_t, kk_function_t, kk_context_t*), _b_x181_216, (_b_x181_216, _x_x369, kk_main_new_run_fun370(_b_x184, _ctx), _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x368, _ctx);
}


// lift anonymous function
struct kk_main_run_fun372__t {
  struct kk_function_s _base;
  kk_function_t _b_x182_217;
};
static kk_box_t kk_main_run_fun372(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x186, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun372(kk_function_t _b_x182_217, kk_context_t* _ctx) {
  struct kk_main_run_fun372__t* _self = kk_function_alloc_as(struct kk_main_run_fun372__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun372, kk_context());
  _self->_b_x182_217 = _b_x182_217;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun372(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x186, kk_context_t* _ctx) {
  struct kk_main_run_fun372__t* _self = kk_function_as(struct kk_main_run_fun372__t*, _fself, _ctx);
  kk_function_t _b_x182_217 = _self->_b_x182_217; /* (hnd/resume-result<726,int>) -> <div,main/flip> int */
  kk_drop_match(_self, {kk_function_dup(_b_x182_217, _ctx);}, {}, _ctx)
  kk_integer_t _x_x373 = kk_function_call(kk_integer_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x182_217, (_b_x182_217, _b_x186, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x373, _ctx);
}
static kk_box_t kk_main_run_fun363(kk_function_t _fself, kk_function_t _b_x189, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_t k_0_221 = kk_main_new_run_fun364(_b_x189, _ctx); /*(hnd/resume-result<726,int>) -> <div,main/flip> int*/;
  kk_unit_t _b_x180_215 = kk_Unit;
  kk_function_t _b_x181_216 = kk_main_new_run_fun366(_ctx); /*((), r@0 : (726) -> <div,main/flip> int) -> <div,main/flip> int*/;
  kk_function_t _b_x182_217 = k_0_221; /*(hnd/resume-result<726,int>) -> <div,main/flip> int*/;
  return kk_std_core_hnd_protect(kk_unit_box(_b_x180_215), kk_main_new_run_fun367(_b_x181_216, _ctx), kk_main_new_run_fun372(_b_x182_217, _ctx), _ctx);
}
static kk_box_t kk_main_run_fun362(kk_function_t _fself, int32_t m_0, kk_std_core_hnd__ev ___wildcard_x730__16_0, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x730__16_0, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m_0, kk_main_new_run_fun363(_ctx), _ctx);
}


// lift anonymous function
struct kk_main_run_fun374__t {
  struct kk_function_s _base;
};
static kk_integer_t kk_main_run_fun374(kk_function_t _fself, kk_integer_t _x_0, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun374(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun374, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_integer_t kk_main_run_fun374(kk_function_t _fself, kk_integer_t _x_0, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _x_0;
}


// lift anonymous function
struct kk_main_run_fun375__t {
  struct kk_function_s _base;
  kk_integer_t n;
  kk_integer_t s;
};
static kk_integer_t kk_main_run_fun375(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun375(kk_integer_t n, kk_integer_t s, kk_context_t* _ctx) {
  struct kk_main_run_fun375__t* _self = kk_function_alloc_as(struct kk_main_run_fun375__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun375, kk_context());
  _self->n = n;
  _self->s = s;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun377__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun377(kk_function_t _fself, kk_box_t _b_x192, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun377(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun377, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun377(kk_function_t _fself, kk_box_t _b_x192, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x378;
  kk_std_core_types__tuple3 _x_x379 = kk_std_core_types__tuple3_unbox(_b_x192, KK_OWNED, _ctx); /*(int, int, int)*/
  _x_x378 = kk_main__mlift_run_10054(_x_x379, _ctx); /*int*/
  return kk_integer_box(_x_x378, _ctx);
}
static kk_integer_t kk_main_run_fun375(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun375__t* _self = kk_function_as(struct kk_main_run_fun375__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_integer_t s = _self->s; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);kk_integer_dup(s, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple3 x_10087 = kk_main_triple(n, s, _ctx); /*(int, int, int)*/;
  if (kk_yielding(kk_context())) {
    kk_std_core_types__tuple3_drop(x_10087, _ctx);
    kk_box_t _x_x376 = kk_std_core_hnd_yield_extend(kk_main_new_run_fun377(_ctx), _ctx); /*3003*/
    return kk_integer_unbox(_x_x376, _ctx);
  }
  {
    return kk_main__mlift_run_10054(x_10087, _ctx);
  }
}


// lift anonymous function
struct kk_main_run_fun380__t {
  struct kk_function_s _base;
  kk_function_t _b_x194_211;
};
static kk_box_t kk_main_run_fun380(kk_function_t _fself, kk_box_t _b_x196, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun380(kk_function_t _b_x194_211, kk_context_t* _ctx) {
  struct kk_main_run_fun380__t* _self = kk_function_alloc_as(struct kk_main_run_fun380__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun380, kk_context());
  _self->_b_x194_211 = _b_x194_211;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun380(kk_function_t _fself, kk_box_t _b_x196, kk_context_t* _ctx) {
  struct kk_main_run_fun380__t* _self = kk_function_as(struct kk_main_run_fun380__t*, _fself, _ctx);
  kk_function_t _b_x194_211 = _self->_b_x194_211; /* (int) -> <div,main/flip> int */
  kk_drop_match(_self, {kk_function_dup(_b_x194_211, _ctx);}, {}, _ctx)
  kk_integer_t _x_x381;
  kk_integer_t _x_x382 = kk_integer_unbox(_b_x196, _ctx); /*int*/
  _x_x381 = kk_function_call(kk_integer_t, (kk_function_t, kk_integer_t, kk_context_t*), _b_x194_211, (_b_x194_211, _x_x382, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x381, _ctx);
}


// lift anonymous function
struct kk_main_run_fun383__t {
  struct kk_function_s _base;
  kk_function_t _b_x195_212;
};
static kk_box_t kk_main_run_fun383(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun383(kk_function_t _b_x195_212, kk_context_t* _ctx) {
  struct kk_main_run_fun383__t* _self = kk_function_alloc_as(struct kk_main_run_fun383__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun383, kk_context());
  _self->_b_x195_212 = _b_x195_212;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun383(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun383__t* _self = kk_function_as(struct kk_main_run_fun383__t*, _fself, _ctx);
  kk_function_t _b_x195_212 = _self->_b_x195_212; /* () -> <main/fail,div,main/flip> int */
  kk_drop_match(_self, {kk_function_dup(_b_x195_212, _ctx);}, {}, _ctx)
  kk_integer_t _x_x384 = kk_function_call(kk_integer_t, (kk_function_t, kk_context_t*), _b_x195_212, (_b_x195_212, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x384, _ctx);
}
static kk_box_t kk_main_run_fun360(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun360__t* _self = kk_function_as(struct kk_main_run_fun360__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_integer_t s = _self->s; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);kk_integer_dup(s, _ctx);}, {}, _ctx)
  kk_main__fail _b_x193_210;
  kk_std_core_hnd__clause0 _x_x361 = kk_std_core_hnd__new_Clause0(kk_main_new_run_fun362(_ctx), _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
  _b_x193_210 = kk_main__new_Hnd_fail(kk_reuse_null, 0, kk_integer_from_small(3), _x_x361, _ctx); /*main/fail<<div,main/flip>,int>*/
  kk_function_t _b_x194_211 = kk_main_new_run_fun374(_ctx); /*(int) -> <div,main/flip> int*/;
  kk_function_t _b_x195_212 = kk_main_new_run_fun375(n, s, _ctx); /*() -> <main/fail,div,main/flip> int*/;
  return kk_main__handle_fail(_b_x193_210, kk_main_new_run_fun380(_b_x194_211, _ctx), kk_main_new_run_fun383(_b_x195_212, _ctx), _ctx);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_integer_t s, kk_context_t* _ctx) { /* (n : int, s : int) -> div int */ 
  kk_box_t _x_x339;
  kk_function_t _b_x177_204 = kk_main_new_run_fun340(_ctx); /*(m : hnd/marker<div,int>, hnd/ev<main/flip>) -> div bool*/;
  kk_main__flip _x_x355;
  kk_std_core_hnd__clause0 _x_x356 = kk_std_core_hnd__new_Clause0(kk_main_new_run_fun357(_b_x177_204, _ctx), _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
  _x_x355 = kk_main__new_Hnd_flip(kk_reuse_null, 0, kk_integer_from_small(3), _x_x356, _ctx); /*main/flip<14,15>*/
  _x_x339 = kk_main__handle_flip(_x_x355, kk_main_new_run_fun359(_ctx), kk_main_new_run_fun360(n, s, _ctx), _ctx); /*283*/
  return kk_integer_unbox(_x_x339, _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10012 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10010;
  kk_string_t _x_x385;
  if (kk_std_core_types__is_Cons(xs_10012, _ctx)) {
    struct kk_std_core_types_Cons* _con_x386 = kk_std_core_types__as_Cons(xs_10012, _ctx);
    kk_box_t _box_x222 = _con_x386->head;
    kk_std_core_types__list _pat_0_0 = _con_x386->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x222);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10012, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10012, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10012, _ctx);
    }
    _x_x385 = x_0; /*string*/
  }
  else {
    _x_x385 = kk_string_empty(); /*string*/
  }
  m_10010 = kk_std_core_int_parse_int(_x_x385, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_integer_t _x_x388;
  if (kk_std_core_types__is_Nothing(m_10010, _ctx)) {
    _x_x388 = kk_integer_from_small(10); /*int*/
  }
  else {
    kk_box_t _box_x223 = m_10010._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x223, _ctx);
    kk_integer_dup(x, _ctx);
    _x_x388 = x; /*int*/
  }
  kk_integer_t _x_x389;
  if (kk_std_core_types__is_Nothing(m_10010, _ctx)) {
    _x_x389 = kk_integer_from_small(10); /*int*/
  }
  else {
    kk_box_t _box_x224 = m_10010._cons.Just.value;
    kk_integer_t x_1 = kk_integer_unbox(_box_x224, _ctx);
    kk_integer_dup(x_1, _ctx);
    kk_std_core_types__maybe_drop(m_10010, _ctx);
    _x_x389 = x_1; /*int*/
  }
  r = kk_main_run(_x_x388, _x_x389, _ctx); /*int*/
  kk_string_t _x_x390 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x390, _ctx); return kk_Unit;
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
    kk_string_t _x_x250;
    kk_define_string_literal(, _s_x251, 9, "fail@main", _ctx)
    _x_x250 = kk_string_dup(_s_x251, _ctx); /*string*/
    kk_main__tag_fail = kk_std_core_hnd__new_Htag(_x_x250, _ctx); /*hnd/htag<main/fail>*/
  }
  {
    kk_string_t _x_x253;
    kk_define_string_literal(, _s_x254, 9, "flip@main", _ctx)
    _x_x253 = kk_string_dup(_s_x254, _ctx); /*string*/
    kk_main__tag_flip = kk_std_core_hnd__new_Htag(_x_x253, _ctx); /*hnd/htag<main/flip>*/
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
  kk_std_core_hnd__htag_drop(kk_main__tag_flip, _ctx);
  kk_std_core_hnd__htag_drop(kk_main__tag_fail, _ctx);
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
