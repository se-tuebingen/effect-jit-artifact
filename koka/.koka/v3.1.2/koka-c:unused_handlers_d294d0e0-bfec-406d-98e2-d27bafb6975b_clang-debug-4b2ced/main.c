// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:state`

kk_std_core_hnd__htag kk_main__tag_state;
 
// handler for the effect `:state`

kk_box_t kk_main__handle_state(kk_main__state hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : state<e,b>, ret : (res : a) -> e b, action : () -> <state|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x214 = kk_std_core_hnd__htag_dup(kk_main__tag_state, _ctx); /*hnd/htag<main/state>*/
  return kk_std_core_hnd__hhandle(_x_x214, kk_main__state_box(hnd, _ctx), ret, action, _ctx);
}
 
// runtime tag for the effect `:yield`

kk_std_core_hnd__htag kk_main__tag_yield;
 
// handler for the effect `:yield`

kk_box_t kk_main__handle_yield(kk_main__yield hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : yield<e,b>, ret : (res : a) -> e b, action : () -> <yield|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x217 = kk_std_core_hnd__htag_dup(kk_main__tag_yield, _ctx); /*hnd/htag<main/yield>*/
  return kk_std_core_hnd__hhandle(_x_x217, kk_main__yield_box(hnd, _ctx), ret, action, _ctx);
}
extern kk_box_t kk_main_get_fun223(kk_function_t _fself, int32_t _b_x23, kk_std_core_hnd__ev _b_x24, kk_context_t* _ctx) {
  struct kk_main_get_fun223__t* _self = kk_function_as(struct kk_main_get_fun223__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x19 = _self->_fun_unbox_x19; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x19, _ctx);}, {}, _ctx)
  kk_integer_t _x_x224;
  int32_t _b_x20_31 = _b_x23; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x21_32 = _b_x24; /*hnd/ev<main/state>*/;
  kk_box_t _x_x225 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x19, (_fun_unbox_x19, _b_x20_31, _b_x21_32, _ctx), _ctx); /*1005*/
  _x_x224 = kk_integer_unbox(_x_x225, _ctx); /*int*/
  return kk_integer_box(_x_x224, _ctx);
}
 
// monadic lift

kk_integer_t kk_main__mlift_countdown_10039(kk_unit_t wild__, kk_context_t* _ctx) { /* (wild_ : ()) -> state int */ 
  return kk_main_countdown(_ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_countdown_10040_fun234__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_countdown_10040_fun234(kk_function_t _fself, kk_box_t _b_x50, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_countdown_10040_fun234(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_countdown_10040_fun234, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_countdown_10040_fun234(kk_function_t _fself, kk_box_t _b_x50, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x235;
  kk_unit_t _x_x236 = kk_Unit;
  kk_unit_unbox(_b_x50);
  _x_x235 = kk_main__mlift_countdown_10039(_x_x236, _ctx); /*int*/
  return kk_integer_box(_x_x235, _ctx);
}

kk_integer_t kk_main__mlift_countdown_10040(kk_integer_t i, kk_context_t* _ctx) { /* (i : int) -> state int */ 
  bool _match_x196 = kk_integer_eq_borrow(i,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x196) {
    return i;
  }
  {
    kk_integer_t i_0_10000 = kk_integer_add_small_const(i, -1, _ctx); /*int*/;
    kk_std_core_hnd__ev ev_10050 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
    kk_unit_t x_10048 = kk_Unit;
    kk_box_t _x_x230;
    {
      struct kk_std_core_hnd_Ev* _con_x231 = kk_std_core_hnd__as_Ev(ev_10050, _ctx);
      kk_box_t _box_x41 = _con_x231->hnd;
      int32_t m = _con_x231->marker;
      kk_main__state h = kk_main__state_unbox(_box_x41, KK_BORROWED, _ctx);
      kk_main__state_dup(h, _ctx);
      {
        struct kk_main__Hnd_state* _con_x232 = kk_main__as_Hnd_state(h, _ctx);
        kk_integer_t _pat_0_0 = _con_x232->_cfc;
        kk_std_core_hnd__clause0 _pat_1_1 = _con_x232->_fun_get;
        kk_std_core_hnd__clause1 _fun_set = _con_x232->_fun_set;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_std_core_hnd__clause0_drop(_pat_1_1, _ctx);
          kk_integer_drop(_pat_0_0, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_fun_set, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x45 = _fun_set.clause;
          _x_x230 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x45, (_fun_unbox_x45, m, ev_10050, kk_integer_box(i_0_10000, _ctx), _ctx), _ctx); /*1010*/
        }
      }
    }
    kk_unit_unbox(_x_x230);
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x233 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_countdown_10040_fun234(_ctx), _ctx); /*3003*/
      return kk_integer_unbox(_x_x233, _ctx);
    }
    {
      return kk_main__mlift_countdown_10039(x_10048, _ctx);
    }
  }
}


// lift anonymous function
struct kk_main_countdown_fun241__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_countdown_fun241(kk_function_t _fself, kk_box_t _b_x70, kk_context_t* _ctx);
static kk_function_t kk_main_new_countdown_fun241(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_countdown_fun241, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_countdown_fun241(kk_function_t _fself, kk_box_t _b_x70, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x242;
  kk_integer_t _x_x243 = kk_integer_unbox(_b_x70, _ctx); /*int*/
  _x_x242 = kk_main__mlift_countdown_10040(_x_x243, _ctx); /*int*/
  return kk_integer_box(_x_x242, _ctx);
}


// lift anonymous function
struct kk_main_countdown_fun248__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_countdown_fun248(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx);
static kk_function_t kk_main_new_countdown_fun248(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_countdown_fun248, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_countdown_fun248(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x249;
  kk_unit_t _x_x250 = kk_Unit;
  kk_unit_unbox(_b_x80);
  _x_x249 = kk_main__mlift_countdown_10039(_x_x250, _ctx); /*int*/
  return kk_integer_box(_x_x249, _ctx);
}

kk_integer_t kk_main_countdown(kk_context_t* _ctx) { /* () -> <div,state> int */ 
  kk__tailcall: ;
  kk_std_core_hnd__ev ev_0_10056 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
  kk_integer_t x_1_10053;
  {
    struct kk_std_core_hnd_Ev* _con_x237 = kk_std_core_hnd__as_Ev(ev_0_10056, _ctx);
    kk_box_t _box_x52 = _con_x237->hnd;
    int32_t m_0 = _con_x237->marker;
    kk_main__state h_0 = kk_main__state_unbox(_box_x52, KK_BORROWED, _ctx);
    kk_main__state_dup(h_0, _ctx);
    {
      struct kk_main__Hnd_state* _con_x238 = kk_main__as_Hnd_state(h_0, _ctx);
      kk_integer_t _pat_0_2 = _con_x238->_cfc;
      kk_std_core_hnd__clause0 _fun_get = _con_x238->_fun_get;
      kk_std_core_hnd__clause1 _pat_1_3 = _con_x238->_fun_set;
      if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
        kk_std_core_hnd__clause1_drop(_pat_1_3, _ctx);
        kk_integer_drop(_pat_0_2, _ctx);
        kk_datatype_ptr_free(h_0, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_fun_get, _ctx);
        kk_datatype_ptr_decref(h_0, _ctx);
      }
      {
        kk_function_t _fun_unbox_x55 = _fun_get.clause;
        kk_function_t _bv_x61 = _fun_unbox_x55; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x239 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x61, (_bv_x61, m_0, ev_0_10056, _ctx), _ctx); /*3004*/
        x_1_10053 = kk_integer_unbox(_x_x239, _ctx); /*int*/
      }
    }
  }
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_1_10053, _ctx);
    kk_box_t _x_x240 = kk_std_core_hnd_yield_extend(kk_main_new_countdown_fun241(_ctx), _ctx); /*3003*/
    return kk_integer_unbox(_x_x240, _ctx);
  }
  {
    bool _match_x194 = kk_integer_eq_borrow(x_1_10053,(kk_integer_from_small(0)),kk_context()); /*bool*/;
    if (_match_x194) {
      return x_1_10053;
    }
    {
      kk_integer_t i_0_10000_0 = kk_integer_add_small_const(x_1_10053, -1, _ctx); /*int*/;
      kk_std_core_hnd__ev ev_1_10061 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
      kk_unit_t x_2_10058 = kk_Unit;
      kk_box_t _x_x244;
      {
        struct kk_std_core_hnd_Ev* _con_x245 = kk_std_core_hnd__as_Ev(ev_1_10061, _ctx);
        kk_box_t _box_x71 = _con_x245->hnd;
        int32_t m_1 = _con_x245->marker;
        kk_main__state h_1 = kk_main__state_unbox(_box_x71, KK_BORROWED, _ctx);
        kk_main__state_dup(h_1, _ctx);
        {
          struct kk_main__Hnd_state* _con_x246 = kk_main__as_Hnd_state(h_1, _ctx);
          kk_integer_t _pat_0_5 = _con_x246->_cfc;
          kk_std_core_hnd__clause0 _pat_1_4 = _con_x246->_fun_get;
          kk_std_core_hnd__clause1 _fun_set_0 = _con_x246->_fun_set;
          if kk_likely(kk_datatype_ptr_is_unique(h_1, _ctx)) {
            kk_std_core_hnd__clause0_drop(_pat_1_4, _ctx);
            kk_integer_drop(_pat_0_5, _ctx);
            kk_datatype_ptr_free(h_1, _ctx);
          }
          else {
            kk_std_core_hnd__clause1_dup(_fun_set_0, _ctx);
            kk_datatype_ptr_decref(h_1, _ctx);
          }
          {
            kk_function_t _fun_unbox_x75 = _fun_set_0.clause;
            _x_x244 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x75, (_fun_unbox_x75, m_1, ev_1_10061, kk_integer_box(i_0_10000_0, _ctx), _ctx), _ctx); /*1010*/
          }
        }
      }
      kk_unit_unbox(_x_x244);
      if (kk_yielding(kk_context())) {
        kk_box_t _x_x247 = kk_std_core_hnd_yield_extend(kk_main_new_countdown_fun248(_ctx), _ctx); /*3003*/
        return kk_integer_unbox(_x_x247, _ctx);
      }
      { // tailcall
        goto kk__tailcall;
      }
    }
  }
}


// lift anonymous function
struct kk_main_ignoreyield_fun254__t {
  struct kk_function_s _base;
};
static kk_unit_t kk_main_ignoreyield_fun254(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx);
static kk_function_t kk_main_new_ignoreyield_fun254(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_ignoreyield_fun254, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_ignoreyield_fun256__t {
  struct kk_function_s _base;
  kk_integer_t x;
};
static kk_box_t kk_main_ignoreyield_fun256(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx);
static kk_function_t kk_main_new_ignoreyield_fun256(kk_integer_t x, kk_context_t* _ctx) {
  struct kk_main_ignoreyield_fun256__t* _self = kk_function_alloc_as(struct kk_main_ignoreyield_fun256__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_ignoreyield_fun256, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_ignoreyield_fun257__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_ignoreyield_fun257(kk_function_t _fself, kk_box_t _b_x94, kk_function_t _b_x95, kk_context_t* _ctx);
static kk_function_t kk_main_new_ignoreyield_fun257(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_ignoreyield_fun257, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_ignoreyield_fun257(kk_function_t _fself, kk_box_t _b_x94, kk_function_t _b_x95, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_box_drop(_b_x94, _ctx);
  kk_unit_t _b_x96 = kk_Unit;
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x95, (_b_x95, kk_unit_box(_b_x96), _ctx), _ctx);
}
static kk_box_t kk_main_ignoreyield_fun256(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_main_ignoreyield_fun256__t* _self = kk_function_as(struct kk_main_ignoreyield_fun256__t*, _fself, _ctx);
  kk_integer_t x = _self->x; /* int */
  kk_drop_match(_self, {kk_integer_dup(x, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect(kk_integer_box(x, _ctx), kk_main_new_ignoreyield_fun257(_ctx), k, _ctx);
}
static kk_unit_t kk_main_ignoreyield_fun254(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x681__16, (KK_I32(3)), _ctx);
  kk_box_t _x_x255 = kk_std_core_hnd_yield_to(m, kk_main_new_ignoreyield_fun256(x, _ctx), _ctx); /*3004*/
  return kk_unit_unbox(_x_x255);
}


// lift anonymous function
struct kk_main_ignoreyield_fun260__t {
  struct kk_function_s _base;
  kk_function_t _b_x99_103;
};
static kk_box_t kk_main_ignoreyield_fun260(kk_function_t _fself, int32_t _b_x100, kk_std_core_hnd__ev _b_x101, kk_box_t _b_x102, kk_context_t* _ctx);
static kk_function_t kk_main_new_ignoreyield_fun260(kk_function_t _b_x99_103, kk_context_t* _ctx) {
  struct kk_main_ignoreyield_fun260__t* _self = kk_function_alloc_as(struct kk_main_ignoreyield_fun260__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_ignoreyield_fun260, kk_context());
  _self->_b_x99_103 = _b_x99_103;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_ignoreyield_fun260(kk_function_t _fself, int32_t _b_x100, kk_std_core_hnd__ev _b_x101, kk_box_t _b_x102, kk_context_t* _ctx) {
  struct kk_main_ignoreyield_fun260__t* _self = kk_function_as(struct kk_main_ignoreyield_fun260__t*, _fself, _ctx);
  kk_function_t _b_x99_103 = _self->_b_x99_103; /* (m : hnd/marker<651,650>, hnd/ev<main/yield>, x : int) -> 651 () */
  kk_drop_match(_self, {kk_function_dup(_b_x99_103, _ctx);}, {}, _ctx)
  kk_unit_t _x_x261 = kk_Unit;
  kk_integer_t _x_x262 = kk_integer_unbox(_b_x102, _ctx); /*int*/
  kk_function_call(kk_unit_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_integer_t, kk_context_t*), _b_x99_103, (_b_x99_103, _b_x100, _b_x101, _x_x262, _ctx), _ctx);
  return kk_unit_box(_x_x261);
}


// lift anonymous function
struct kk_main_ignoreyield_fun263__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_ignoreyield_fun263(kk_function_t _fself, kk_box_t _x, kk_context_t* _ctx);
static kk_function_t kk_main_new_ignoreyield_fun263(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_ignoreyield_fun263, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_ignoreyield_fun263(kk_function_t _fself, kk_box_t _x, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _x;
}

kk_box_t kk_main_ignoreyield(kk_function_t body, kk_context_t* _ctx) { /* forall<a,e> (body : () -> <yield|e> a) -> e a */ 
  kk_function_t _b_x99_103 = kk_main_new_ignoreyield_fun254(_ctx); /*(m : hnd/marker<651,650>, hnd/ev<main/yield>, x : int) -> 651 ()*/;
  kk_main__yield _x_x258;
  kk_std_core_hnd__clause1 _x_x259 = kk_std_core_hnd__new_Clause1(kk_main_new_ignoreyield_fun260(_b_x99_103, _ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x258 = kk_main__new_Hnd_yield(kk_reuse_null, 0, kk_integer_from_small(3), _x_x259, _ctx); /*main/yield<18,19>*/
  return kk_main__handle_yield(_x_x258, kk_main_new_ignoreyield_fun263(_ctx), body, _ctx);
}


// lift anonymous function
struct kk_main_handled_fun265__t {
  struct kk_function_s _base;
};
static kk_unit_t kk_main_handled_fun265(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun265(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_handled_fun265, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_handled_fun267__t {
  struct kk_function_s _base;
  kk_integer_t x;
};
static kk_box_t kk_main_handled_fun267(kk_function_t _fself, kk_function_t _b_x120, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun267(kk_integer_t x, kk_context_t* _ctx) {
  struct kk_main_handled_fun267__t* _self = kk_function_alloc_as(struct kk_main_handled_fun267__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_handled_fun267, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_handled_fun268__t {
  struct kk_function_s _base;
  kk_function_t _b_x120;
};
static kk_integer_t kk_main_handled_fun268(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x121, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun268(kk_function_t _b_x120, kk_context_t* _ctx) {
  struct kk_main_handled_fun268__t* _self = kk_function_alloc_as(struct kk_main_handled_fun268__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_handled_fun268, kk_context());
  _self->_b_x120 = _b_x120;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_handled_fun268(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x121, kk_context_t* _ctx) {
  struct kk_main_handled_fun268__t* _self = kk_function_as(struct kk_main_handled_fun268__t*, _fself, _ctx);
  kk_function_t _b_x120 = _self->_b_x120; /* (hnd/resume-result<3004,3006>) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x120, _ctx);}, {}, _ctx)
  kk_box_t _x_x269 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x120, (_b_x120, _b_x121, _ctx), _ctx); /*3006*/
  return kk_integer_unbox(_x_x269, _ctx);
}


// lift anonymous function
struct kk_main_handled_fun270__t {
  struct kk_function_s _base;
};
static kk_integer_t kk_main_handled_fun270(kk_function_t _fself, kk_integer_t i, kk_function_t resume, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun270(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_handled_fun270, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_integer_t kk_main_handled_fun270(kk_function_t _fself, kk_integer_t i, kk_function_t resume, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_drop(i, _ctx);
  return kk_function_call(kk_integer_t, (kk_function_t, kk_unit_t, kk_context_t*), resume, (resume, kk_Unit, _ctx), _ctx);
}


// lift anonymous function
struct kk_main_handled_fun271__t {
  struct kk_function_s _base;
  kk_function_t _b_x112_143;
};
static kk_box_t kk_main_handled_fun271(kk_function_t _fself, kk_box_t _b_x114, kk_function_t _b_x115, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun271(kk_function_t _b_x112_143, kk_context_t* _ctx) {
  struct kk_main_handled_fun271__t* _self = kk_function_alloc_as(struct kk_main_handled_fun271__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_handled_fun271, kk_context());
  _self->_b_x112_143 = _b_x112_143;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_handled_fun274__t {
  struct kk_function_s _base;
  kk_function_t _b_x115;
};
static kk_integer_t kk_main_handled_fun274(kk_function_t _fself, kk_unit_t _b_x116, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun274(kk_function_t _b_x115, kk_context_t* _ctx) {
  struct kk_main_handled_fun274__t* _self = kk_function_alloc_as(struct kk_main_handled_fun274__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_handled_fun274, kk_context());
  _self->_b_x115 = _b_x115;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_handled_fun274(kk_function_t _fself, kk_unit_t _b_x116, kk_context_t* _ctx) {
  struct kk_main_handled_fun274__t* _self = kk_function_as(struct kk_main_handled_fun274__t*, _fself, _ctx);
  kk_function_t _b_x115 = _self->_b_x115; /* (3005) -> 3006 3007 */
  kk_drop_match(_self, {kk_function_dup(_b_x115, _ctx);}, {}, _ctx)
  kk_box_t _x_x275 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x115, (_b_x115, kk_unit_box(_b_x116), _ctx), _ctx); /*3007*/
  return kk_integer_unbox(_x_x275, _ctx);
}
static kk_box_t kk_main_handled_fun271(kk_function_t _fself, kk_box_t _b_x114, kk_function_t _b_x115, kk_context_t* _ctx) {
  struct kk_main_handled_fun271__t* _self = kk_function_as(struct kk_main_handled_fun271__t*, _fself, _ctx);
  kk_function_t _b_x112_143 = _self->_b_x112_143; /* (i : int, resume : (()) -> <div,main/state> int) -> <div,main/state> int */
  kk_drop_match(_self, {kk_function_dup(_b_x112_143, _ctx);}, {}, _ctx)
  kk_integer_t _x_x272;
  kk_integer_t _x_x273 = kk_integer_unbox(_b_x114, _ctx); /*int*/
  _x_x272 = kk_function_call(kk_integer_t, (kk_function_t, kk_integer_t, kk_function_t, kk_context_t*), _b_x112_143, (_b_x112_143, _x_x273, kk_main_new_handled_fun274(_b_x115, _ctx), _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x272, _ctx);
}


// lift anonymous function
struct kk_main_handled_fun276__t {
  struct kk_function_s _base;
  kk_function_t _b_x113_144;
};
static kk_box_t kk_main_handled_fun276(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x117, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun276(kk_function_t _b_x113_144, kk_context_t* _ctx) {
  struct kk_main_handled_fun276__t* _self = kk_function_alloc_as(struct kk_main_handled_fun276__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_handled_fun276, kk_context());
  _self->_b_x113_144 = _b_x113_144;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_handled_fun276(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x117, kk_context_t* _ctx) {
  struct kk_main_handled_fun276__t* _self = kk_function_as(struct kk_main_handled_fun276__t*, _fself, _ctx);
  kk_function_t _b_x113_144 = _self->_b_x113_144; /* (hnd/resume-result<(),int>) -> <div,main/state> int */
  kk_drop_match(_self, {kk_function_dup(_b_x113_144, _ctx);}, {}, _ctx)
  kk_integer_t _x_x277 = kk_function_call(kk_integer_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x113_144, (_b_x113_144, _b_x117, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x277, _ctx);
}
static kk_box_t kk_main_handled_fun267(kk_function_t _fself, kk_function_t _b_x120, kk_context_t* _ctx) {
  struct kk_main_handled_fun267__t* _self = kk_function_as(struct kk_main_handled_fun267__t*, _fself, _ctx);
  kk_integer_t x = _self->x; /* int */
  kk_drop_match(_self, {kk_integer_dup(x, _ctx);}, {}, _ctx)
  kk_function_t k_149 = kk_main_new_handled_fun268(_b_x120, _ctx); /*(hnd/resume-result<(),int>) -> <div,main/state> int*/;
  kk_integer_t _b_x111_142 = x; /*int*/;
  kk_function_t _b_x112_143 = kk_main_new_handled_fun270(_ctx); /*(i : int, resume : (()) -> <div,main/state> int) -> <div,main/state> int*/;
  kk_function_t _b_x113_144 = k_149; /*(hnd/resume-result<(),int>) -> <div,main/state> int*/;
  return kk_std_core_hnd_protect(kk_integer_box(_b_x111_142, _ctx), kk_main_new_handled_fun271(_b_x112_143, _ctx), kk_main_new_handled_fun276(_b_x113_144, _ctx), _ctx);
}
static kk_unit_t kk_main_handled_fun265(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x681__16, (KK_I32(3)), _ctx);
  kk_box_t _x_x266 = kk_std_core_hnd_yield_to(m, kk_main_new_handled_fun267(x, _ctx), _ctx); /*3004*/
  return kk_unit_unbox(_x_x266);
}


// lift anonymous function
struct kk_main_handled_fun280__t {
  struct kk_function_s _base;
  kk_function_t _b_x122_139;
};
static kk_box_t kk_main_handled_fun280(kk_function_t _fself, int32_t _b_x123, kk_std_core_hnd__ev _b_x124, kk_box_t _b_x125, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun280(kk_function_t _b_x122_139, kk_context_t* _ctx) {
  struct kk_main_handled_fun280__t* _self = kk_function_alloc_as(struct kk_main_handled_fun280__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_handled_fun280, kk_context());
  _self->_b_x122_139 = _b_x122_139;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_handled_fun280(kk_function_t _fself, int32_t _b_x123, kk_std_core_hnd__ev _b_x124, kk_box_t _b_x125, kk_context_t* _ctx) {
  struct kk_main_handled_fun280__t* _self = kk_function_as(struct kk_main_handled_fun280__t*, _fself, _ctx);
  kk_function_t _b_x122_139 = _self->_b_x122_139; /* (m : hnd/marker<<div,main/state>,int>, hnd/ev<main/yield>, x : int) -> <div,main/state> () */
  kk_drop_match(_self, {kk_function_dup(_b_x122_139, _ctx);}, {}, _ctx)
  kk_unit_t _x_x281 = kk_Unit;
  kk_integer_t _x_x282 = kk_integer_unbox(_b_x125, _ctx); /*int*/
  kk_function_call(kk_unit_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_integer_t, kk_context_t*), _b_x122_139, (_b_x122_139, _b_x123, _b_x124, _x_x282, _ctx), _ctx);
  return kk_unit_box(_x_x281);
}


// lift anonymous function
struct kk_main_handled_fun283__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_handled_fun283(kk_function_t _fself, kk_box_t _b_x135, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun283(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_handled_fun283, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_handled_fun283(kk_function_t _fself, kk_box_t _b_x135, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_150 = kk_integer_unbox(_b_x135, _ctx); /*int*/;
  return kk_integer_box(_x_150, _ctx);
}


// lift anonymous function
struct kk_main_handled_fun284__t {
  struct kk_function_s _base;
  kk_integer_t d;
  kk_integer_t n;
};
static kk_box_t kk_main_handled_fun284(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun284(kk_integer_t d, kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_handled_fun284__t* _self = kk_function_alloc_as(struct kk_main_handled_fun284__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_handled_fun284, kk_context());
  _self->d = d;
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_handled_fun285__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_handled_fun285(kk_function_t _fself, kk_box_t _b_x130, kk_box_t _b_x131, kk_context_t* _ctx);
static kk_function_t kk_main_new_handled_fun285(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_handled_fun285, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_handled_fun285(kk_function_t _fself, kk_box_t _b_x130, kk_box_t _b_x131, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x286;
  kk_integer_t _x_x287 = kk_integer_unbox(_b_x130, _ctx); /*int*/
  kk_integer_t _x_x288 = kk_integer_unbox(_b_x131, _ctx); /*int*/
  _x_x286 = kk_main_handled(_x_x287, _x_x288, _ctx); /*int*/
  return kk_integer_box(_x_x286, _ctx);
}
static kk_box_t kk_main_handled_fun284(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_handled_fun284__t* _self = kk_function_as(struct kk_main_handled_fun284__t*, _fself, _ctx);
  kk_integer_t d = _self->d; /* int */
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(d, _ctx);kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_integer_t _x_x2_10038 = kk_integer_add_small_const(d, -1, _ctx); /*int*/;
  kk_ssize_t _b_x126_145 = (KK_IZ(0)); /*hnd/ev-index*/;
  return kk_std_core_hnd__open_at2(_b_x126_145, kk_main_new_handled_fun285(_ctx), kk_integer_box(n, _ctx), kk_integer_box(_x_x2_10038, _ctx), _ctx);
}

kk_integer_t kk_main_handled(kk_integer_t n, kk_integer_t d, kk_context_t* _ctx) { /* (n : int, d : int) -> <div,state> int */ 
  bool _match_x192 = kk_integer_eq_borrow(d,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x192) {
    kk_integer_drop(n, _ctx);
    kk_integer_drop(d, _ctx);
    return kk_main_countdown(_ctx);
  }
  {
    kk_box_t _x_x264;
    kk_function_t _b_x122_139 = kk_main_new_handled_fun265(_ctx); /*(m : hnd/marker<<div,main/state>,int>, hnd/ev<main/yield>, x : int) -> <div,main/state> ()*/;
    kk_main__yield _x_x278;
    kk_std_core_hnd__clause1 _x_x279 = kk_std_core_hnd__new_Clause1(kk_main_new_handled_fun280(_b_x122_139, _ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
    _x_x278 = kk_main__new_Hnd_yield(kk_reuse_null, 0, kk_integer_from_small(3), _x_x279, _ctx); /*main/yield<18,19>*/
    _x_x264 = kk_main__handle_yield(_x_x278, kk_main_new_handled_fun283(_ctx), kk_main_new_handled_fun284(d, n, _ctx), _ctx); /*317*/
    return kk_integer_unbox(_x_x264, _ctx);
  }
}


// lift anonymous function
struct kk_main_run_fun295__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_run_fun295(kk_function_t _fself, int32_t _b_x155, kk_std_core_hnd__ev _b_x156, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun295(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_run_fun295__t* _self = kk_function_alloc_as(struct kk_main_run_fun295__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun295, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun295(kk_function_t _fself, int32_t _b_x155, kk_std_core_hnd__ev _b_x156, kk_context_t* _ctx) {
  struct kk_main_run_fun295__t* _self = kk_function_as(struct kk_main_run_fun295__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<955,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  int32_t ___wildcard_x737__14_180 = _b_x155; /*hnd/marker<<local<955>,div>,int>*/;
  kk_std_core_hnd__ev ___wildcard_x737__17_181 = _b_x156; /*hnd/ev<main/state>*/;
  kk_datatype_ptr_dropn(___wildcard_x737__17_181, (KK_I32(3)), _ctx);
  return kk_ref_get(loc,kk_context());
}


// lift anonymous function
struct kk_main_run_fun298__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_run_fun298(kk_function_t _fself, int32_t _b_x160, kk_std_core_hnd__ev _b_x161, kk_box_t _b_x162, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun298(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_run_fun298__t* _self = kk_function_alloc_as(struct kk_main_run_fun298__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun298, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun298(kk_function_t _fself, int32_t _b_x160, kk_std_core_hnd__ev _b_x161, kk_box_t _b_x162, kk_context_t* _ctx) {
  struct kk_main_run_fun298__t* _self = kk_function_as(struct kk_main_run_fun298__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<955,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  int32_t ___wildcard_x691__14_182 = _b_x160; /*hnd/marker<<local<955>,div>,int>*/;
  kk_std_core_hnd__ev ___wildcard_x691__17_183 = _b_x161; /*hnd/ev<main/state>*/;
  kk_datatype_ptr_dropn(___wildcard_x691__17_183, (KK_I32(3)), _ctx);
  kk_integer_t x_184 = kk_integer_unbox(_b_x162, _ctx); /*int*/;
  kk_unit_t _x_x299 = kk_Unit;
  kk_unit_t _brw_x191 = kk_Unit;
  kk_ref_set_borrow(loc,(kk_integer_box(x_184, _ctx)),kk_context());
  kk_ref_drop(loc, _ctx);
  _brw_x191;
  return kk_unit_box(_x_x299);
}


// lift anonymous function
struct kk_main_run_fun300__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun300(kk_function_t _fself, kk_box_t _b_x166, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun300(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun300, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun300(kk_function_t _fself, kk_box_t _b_x166, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _b_x166;
}


// lift anonymous function
struct kk_main_run_fun301__t {
  struct kk_function_s _base;
  kk_integer_t d;
  kk_integer_t n;
};
static kk_box_t kk_main_run_fun301(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun301(kk_integer_t d, kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun301__t* _self = kk_function_alloc_as(struct kk_main_run_fun301__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun301, kk_context());
  _self->d = d;
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun301(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun301__t* _self = kk_function_as(struct kk_main_run_fun301__t*, _fself, _ctx);
  kk_integer_t d = _self->d; /* int */
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(d, _ctx);kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_integer_t _x_x302 = kk_main_handled(n, d, _ctx); /*int*/
  return kk_integer_box(_x_x302, _ctx);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_integer_t d, kk_context_t* _ctx) { /* (n : int, d : int) -> div int */ 
  kk_ref_t loc;
  kk_box_t _x_x289;
  kk_integer_t _x_x290 = kk_integer_dup(n, _ctx); /*int*/
  _x_x289 = kk_integer_box(_x_x290, _ctx); /*3003*/
  loc = kk_ref_alloc(_x_x289,kk_context()); /*local-var<955,int>*/
  kk_integer_t res;
  kk_box_t _x_x291;
  kk_main__state _x_x292;
  kk_std_core_hnd__clause0 _x_x293;
  kk_function_t _x_x294;
  kk_ref_dup(loc, _ctx);
  _x_x294 = kk_main_new_run_fun295(loc, _ctx); /*(hnd/marker<1012,1013>, hnd/ev<1011>) -> 1012 1000*/
  _x_x293 = kk_std_core_hnd__new_Clause0(_x_x294, _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
  kk_std_core_hnd__clause1 _x_x296;
  kk_function_t _x_x297;
  kk_ref_dup(loc, _ctx);
  _x_x297 = kk_main_new_run_fun298(loc, _ctx); /*(hnd/marker<1018,1019>, hnd/ev<1017>, 1015) -> 1018 1016*/
  _x_x296 = kk_std_core_hnd__new_Clause1(_x_x297, _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x292 = kk_main__new_Hnd_state(kk_reuse_null, 0, kk_integer_from_small(1), _x_x293, _x_x296, _ctx); /*main/state<10,11>*/
  _x_x291 = kk_main__handle_state(_x_x292, kk_main_new_run_fun300(_ctx), kk_main_new_run_fun301(d, n, _ctx), _ctx); /*268*/
  res = kk_integer_unbox(_x_x291, _ctx); /*int*/
  kk_box_t _x_x303 = kk_std_core_hnd_prompt_local_var(loc, kk_integer_box(res, _ctx), _ctx); /*3004*/
  return kk_integer_unbox(_x_x303, _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10005 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10003;
  kk_string_t _x_x304;
  if (kk_std_core_types__is_Cons(xs_10005, _ctx)) {
    struct kk_std_core_types_Cons* _con_x305 = kk_std_core_types__as_Cons(xs_10005, _ctx);
    kk_box_t _box_x185 = _con_x305->head;
    kk_std_core_types__list _pat_0_0 = _con_x305->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x185);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10005, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10005, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10005, _ctx);
    }
    _x_x304 = x_0; /*string*/
  }
  else {
    _x_x304 = kk_string_empty(); /*string*/
  }
  m_10003 = kk_std_core_int_parse_int(_x_x304, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_std_core_types__list xs_1_10011 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_0_10007;
  kk_string_t _x_x307;
  kk_std_core_types__list _match_x190;
  if (kk_std_core_types__is_Cons(xs_1_10011, _ctx)) {
    struct kk_std_core_types_Cons* _con_x308 = kk_std_core_types__as_Cons(xs_1_10011, _ctx);
    kk_box_t _box_x186 = _con_x308->head;
    kk_std_core_types__list xx = _con_x308->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs_1_10011, _ctx)) {
      kk_box_drop(_box_x186, _ctx);
      kk_datatype_ptr_free(xs_1_10011, _ctx);
    }
    else {
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs_1_10011, _ctx);
    }
    _match_x190 = xx; /*list<string>*/
  }
  else {
    _match_x190 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
  }
  if (kk_std_core_types__is_Cons(_match_x190, _ctx)) {
    struct kk_std_core_types_Cons* _con_x309 = kk_std_core_types__as_Cons(_match_x190, _ctx);
    kk_box_t _box_x187 = _con_x309->head;
    kk_std_core_types__list _pat_0_2 = _con_x309->tail;
    kk_string_t x_2 = kk_string_unbox(_box_x187);
    if kk_likely(kk_datatype_ptr_is_unique(_match_x190, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_2, _ctx);
      kk_datatype_ptr_free(_match_x190, _ctx);
    }
    else {
      kk_string_dup(x_2, _ctx);
      kk_datatype_ptr_decref(_match_x190, _ctx);
    }
    _x_x307 = x_2; /*string*/
  }
  else {
    _x_x307 = kk_string_empty(); /*string*/
  }
  m_0_10007 = kk_std_core_int_parse_int(_x_x307, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_integer_t _x_x311;
  if (kk_std_core_types__is_Nothing(m_10003, _ctx)) {
    _x_x311 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x188 = m_10003._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x188, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10003, _ctx);
    _x_x311 = x; /*int*/
  }
  kk_integer_t _x_x312;
  if (kk_std_core_types__is_Nothing(m_0_10007, _ctx)) {
    _x_x312 = kk_integer_from_small(10); /*int*/
  }
  else {
    kk_box_t _box_x189 = m_0_10007._cons.Just.value;
    kk_integer_t x_1 = kk_integer_unbox(_box_x189, _ctx);
    kk_integer_dup(x_1, _ctx);
    kk_std_core_types__maybe_drop(m_0_10007, _ctx);
    _x_x312 = x_1; /*int*/
  }
  r = kk_main_run(_x_x311, _x_x312, _ctx); /*int*/
  kk_string_t _x_x313 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x313, _ctx); return kk_Unit;
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
    kk_string_t _x_x212;
    kk_define_string_literal(, _s_x213, 10, "state@main", _ctx)
    _x_x212 = kk_string_dup(_s_x213, _ctx); /*string*/
    kk_main__tag_state = kk_std_core_hnd__new_Htag(_x_x212, _ctx); /*hnd/htag<main/state>*/
  }
  {
    kk_string_t _x_x215;
    kk_define_string_literal(, _s_x216, 10, "yield@main", _ctx)
    _x_x215 = kk_string_dup(_s_x216, _ctx); /*string*/
    kk_main__tag_yield = kk_std_core_hnd__new_Htag(_x_x215, _ctx); /*hnd/htag<main/yield>*/
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
  kk_std_core_hnd__htag_drop(kk_main__tag_yield, _ctx);
  kk_std_core_hnd__htag_drop(kk_main__tag_state, _ctx);
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
