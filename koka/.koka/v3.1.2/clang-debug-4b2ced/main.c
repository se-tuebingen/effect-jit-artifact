// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:state`

kk_std_core_hnd__htag kk_main__tag_state;
 
// handler for the effect `:state`

kk_box_t kk_main__handle_state(kk_main__state hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : state<e,b>, ret : (res : a) -> e b, action : () -> <state|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x155 = kk_std_core_hnd__htag_dup(kk_main__tag_state, _ctx); /*hnd/htag<main/state>*/
  return kk_std_core_hnd__hhandle(_x_x155, kk_main__state_box(hnd, _ctx), ret, action, _ctx);
}
 
// runtime tag for the effect `:yield`

kk_std_core_hnd__htag kk_main__tag_yield;
 
// handler for the effect `:yield`

kk_box_t kk_main__handle_yield(kk_main__yield hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : yield<e,b>, ret : (res : a) -> e b, action : () -> <yield|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x158 = kk_std_core_hnd__htag_dup(kk_main__tag_yield, _ctx); /*hnd/htag<main/yield>*/
  return kk_std_core_hnd__hhandle(_x_x158, kk_main__yield_box(hnd, _ctx), ret, action, _ctx);
}
extern kk_box_t kk_main_get_fun164(kk_function_t _fself, int32_t _b_x23, kk_std_core_hnd__ev _b_x24, kk_context_t* _ctx) {
  struct kk_main_get_fun164__t* _self = kk_function_as(struct kk_main_get_fun164__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x19 = _self->_fun_unbox_x19; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x19, _ctx);}, {}, _ctx)
  kk_integer_t _x_x165;
  int32_t _b_x20_31 = _b_x23; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x21_32 = _b_x24; /*hnd/ev<main/state>*/;
  kk_box_t _x_x166 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x19, (_fun_unbox_x19, _b_x20_31, _b_x21_32, _ctx), _ctx); /*1005*/
  _x_x165 = kk_integer_unbox(_x_x166, _ctx); /*int*/
  return kk_integer_box(_x_x165, _ctx);
}
 
// monadic lift

kk_integer_t kk_main__mlift_countdown_10042(kk_unit_t wild__, kk_context_t* _ctx) { /* (wild_ : ()) -> state int */ 
  return kk_main_countdown(_ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_countdown_10043_fun175__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_countdown_10043_fun175(kk_function_t _fself, kk_box_t _b_x50, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_countdown_10043_fun175(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_countdown_10043_fun175, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_countdown_10043_fun175(kk_function_t _fself, kk_box_t _b_x50, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x176;
  kk_unit_t _x_x177 = kk_Unit;
  kk_unit_unbox(_b_x50);
  _x_x176 = kk_main__mlift_countdown_10042(_x_x177, _ctx); /*int*/
  return kk_integer_box(_x_x176, _ctx);
}

kk_integer_t kk_main__mlift_countdown_10043(kk_integer_t i, kk_context_t* _ctx) { /* (i : int) -> state int */ 
  bool _match_x137 = kk_integer_eq_borrow(i,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x137) {
    return i;
  }
  {
    kk_integer_t i_0_10000 = kk_integer_add_small_const(i, -1, _ctx); /*int*/;
    kk_std_core_hnd__ev ev_10054 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
    kk_unit_t x_10052 = kk_Unit;
    kk_box_t _x_x171;
    {
      struct kk_std_core_hnd_Ev* _con_x172 = kk_std_core_hnd__as_Ev(ev_10054, _ctx);
      kk_box_t _box_x41 = _con_x172->hnd;
      int32_t m = _con_x172->marker;
      kk_main__state h = kk_main__state_unbox(_box_x41, KK_BORROWED, _ctx);
      kk_main__state_dup(h, _ctx);
      {
        struct kk_main__Hnd_state* _con_x173 = kk_main__as_Hnd_state(h, _ctx);
        kk_integer_t _pat_0_0 = _con_x173->_cfc;
        kk_std_core_hnd__clause0 _pat_1_1 = _con_x173->_ctl_get;
        kk_std_core_hnd__clause1 _ctl_set = _con_x173->_ctl_set;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_std_core_hnd__clause0_drop(_pat_1_1, _ctx);
          kk_integer_drop(_pat_0_0, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_ctl_set, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x45 = _ctl_set.clause;
          _x_x171 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x45, (_fun_unbox_x45, m, ev_10054, kk_integer_box(i_0_10000, _ctx), _ctx), _ctx); /*1010*/
        }
      }
    }
    kk_unit_unbox(_x_x171);
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x174 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_countdown_10043_fun175(_ctx), _ctx); /*3003*/
      return kk_integer_unbox(_x_x174, _ctx);
    }
    {
      return kk_main__mlift_countdown_10042(x_10052, _ctx);
    }
  }
}


// lift anonymous function
struct kk_main_countdown_fun182__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_countdown_fun182(kk_function_t _fself, kk_box_t _b_x70, kk_context_t* _ctx);
static kk_function_t kk_main_new_countdown_fun182(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_countdown_fun182, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_countdown_fun182(kk_function_t _fself, kk_box_t _b_x70, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x183;
  kk_integer_t _x_x184 = kk_integer_unbox(_b_x70, _ctx); /*int*/
  _x_x183 = kk_main__mlift_countdown_10043(_x_x184, _ctx); /*int*/
  return kk_integer_box(_x_x183, _ctx);
}


// lift anonymous function
struct kk_main_countdown_fun189__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_countdown_fun189(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx);
static kk_function_t kk_main_new_countdown_fun189(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_countdown_fun189, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_countdown_fun189(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x190;
  kk_unit_t _x_x191 = kk_Unit;
  kk_unit_unbox(_b_x80);
  _x_x190 = kk_main__mlift_countdown_10042(_x_x191, _ctx); /*int*/
  return kk_integer_box(_x_x190, _ctx);
}

kk_integer_t kk_main_countdown(kk_context_t* _ctx) { /* () -> <div,state> int */ 
  kk__tailcall: ;
  kk_std_core_hnd__ev ev_0_10060 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
  kk_integer_t x_1_10057;
  {
    struct kk_std_core_hnd_Ev* _con_x178 = kk_std_core_hnd__as_Ev(ev_0_10060, _ctx);
    kk_box_t _box_x52 = _con_x178->hnd;
    int32_t m_0 = _con_x178->marker;
    kk_main__state h_0 = kk_main__state_unbox(_box_x52, KK_BORROWED, _ctx);
    kk_main__state_dup(h_0, _ctx);
    {
      struct kk_main__Hnd_state* _con_x179 = kk_main__as_Hnd_state(h_0, _ctx);
      kk_integer_t _pat_0_2 = _con_x179->_cfc;
      kk_std_core_hnd__clause0 _ctl_get = _con_x179->_ctl_get;
      kk_std_core_hnd__clause1 _pat_1_3 = _con_x179->_ctl_set;
      if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
        kk_std_core_hnd__clause1_drop(_pat_1_3, _ctx);
        kk_integer_drop(_pat_0_2, _ctx);
        kk_datatype_ptr_free(h_0, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_get, _ctx);
        kk_datatype_ptr_decref(h_0, _ctx);
      }
      {
        kk_function_t _fun_unbox_x55 = _ctl_get.clause;
        kk_function_t _bv_x61 = _fun_unbox_x55; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x180 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x61, (_bv_x61, m_0, ev_0_10060, _ctx), _ctx); /*3004*/
        x_1_10057 = kk_integer_unbox(_x_x180, _ctx); /*int*/
      }
    }
  }
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_1_10057, _ctx);
    kk_box_t _x_x181 = kk_std_core_hnd_yield_extend(kk_main_new_countdown_fun182(_ctx), _ctx); /*3003*/
    return kk_integer_unbox(_x_x181, _ctx);
  }
  {
    bool _match_x135 = kk_integer_eq_borrow(x_1_10057,(kk_integer_from_small(0)),kk_context()); /*bool*/;
    if (_match_x135) {
      return x_1_10057;
    }
    {
      kk_integer_t i_0_10000_0 = kk_integer_add_small_const(x_1_10057, -1, _ctx); /*int*/;
      kk_std_core_hnd__ev ev_1_10065 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
      kk_unit_t x_2_10062 = kk_Unit;
      kk_box_t _x_x185;
      {
        struct kk_std_core_hnd_Ev* _con_x186 = kk_std_core_hnd__as_Ev(ev_1_10065, _ctx);
        kk_box_t _box_x71 = _con_x186->hnd;
        int32_t m_1 = _con_x186->marker;
        kk_main__state h_1 = kk_main__state_unbox(_box_x71, KK_BORROWED, _ctx);
        kk_main__state_dup(h_1, _ctx);
        {
          struct kk_main__Hnd_state* _con_x187 = kk_main__as_Hnd_state(h_1, _ctx);
          kk_integer_t _pat_0_5 = _con_x187->_cfc;
          kk_std_core_hnd__clause0 _pat_1_4 = _con_x187->_ctl_get;
          kk_std_core_hnd__clause1 _ctl_set_0 = _con_x187->_ctl_set;
          if kk_likely(kk_datatype_ptr_is_unique(h_1, _ctx)) {
            kk_std_core_hnd__clause0_drop(_pat_1_4, _ctx);
            kk_integer_drop(_pat_0_5, _ctx);
            kk_datatype_ptr_free(h_1, _ctx);
          }
          else {
            kk_std_core_hnd__clause1_dup(_ctl_set_0, _ctx);
            kk_datatype_ptr_decref(h_1, _ctx);
          }
          {
            kk_function_t _fun_unbox_x75 = _ctl_set_0.clause;
            _x_x185 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x75, (_fun_unbox_x75, m_1, ev_1_10065, kk_integer_box(i_0_10000_0, _ctx), _ctx), _ctx); /*1010*/
          }
        }
      }
      kk_unit_unbox(_x_x185);
      if (kk_yielding(kk_context())) {
        kk_box_t _x_x188 = kk_std_core_hnd_yield_extend(kk_main_new_countdown_fun189(_ctx), _ctx); /*3003*/
        return kk_integer_unbox(_x_x188, _ctx);
      }
      { // tailcall
        goto kk__tailcall;
      }
    }
  }
}


// lift anonymous function
struct kk_main_shandler_fun195__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_shandler_fun195(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_shandler_fun195(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_shandler_fun195__t* _self = kk_function_alloc_as(struct kk_main_shandler_fun195__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_shandler_fun195, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_shandler_fun195(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_shandler_fun195__t* _self = kk_function_as(struct kk_main_shandler_fun195__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<768,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  return kk_ref_get(loc,kk_context());
}


// lift anonymous function
struct kk_main_shandler_fun198__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_shandler_fun198(kk_function_t _fself, kk_box_t _b_x90, kk_context_t* _ctx);
static kk_function_t kk_main_new_shandler_fun198(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_shandler_fun198__t* _self = kk_function_alloc_as(struct kk_main_shandler_fun198__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_shandler_fun198, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_shandler_fun198(kk_function_t _fself, kk_box_t _b_x90, kk_context_t* _ctx) {
  struct kk_main_shandler_fun198__t* _self = kk_function_as(struct kk_main_shandler_fun198__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<768,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_unit_t _x_x199 = kk_Unit;
  kk_unit_t _brw_x133 = kk_Unit;
  kk_ref_set_borrow(loc,_b_x90,kk_context());
  kk_ref_drop(loc, _ctx);
  _brw_x133;
  return kk_unit_box(_x_x199);
}


// lift anonymous function
struct kk_main_shandler_fun200__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_shandler_fun200(kk_function_t _fself, kk_box_t _x, kk_context_t* _ctx);
static kk_function_t kk_main_new_shandler_fun200(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_shandler_fun200, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_shandler_fun200(kk_function_t _fself, kk_box_t _x, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _x;
}

kk_box_t kk_main_shandler(kk_integer_t n, kk_function_t body, kk_context_t* _ctx) { /* forall<a,e> (n : int, body : () -> <state|e> a) -> e a */ 
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(n, _ctx)),kk_context()); /*local-var<768,int>*/;
  kk_box_t res;
  kk_main__state _x_x192;
  kk_std_core_hnd__clause0 _x_x193;
  kk_function_t _x_x194;
  kk_ref_dup(loc, _ctx);
  _x_x194 = kk_main_new_shandler_fun195(loc, _ctx); /*() -> 1000 1000*/
  _x_x193 = kk_std_core_hnd_clause_tail0(_x_x194, _ctx); /*hnd/clause0<1003,1002,1000,1001>*/
  kk_std_core_hnd__clause1 _x_x196;
  kk_function_t _x_x197;
  kk_ref_dup(loc, _ctx);
  _x_x197 = kk_main_new_shandler_fun198(loc, _ctx); /*(1003) -> 1000 1004*/
  _x_x196 = kk_std_core_hnd_clause_tail1(_x_x197, _ctx); /*hnd/clause1<1003,1004,1002,1000,1001>*/
  _x_x192 = kk_main__new_Hnd_state(kk_reuse_null, 0, kk_integer_from_small(1), _x_x193, _x_x196, _ctx); /*main/state<10,11>*/
  res = kk_main__handle_state(_x_x192, kk_main_new_shandler_fun200(_ctx), body, _ctx); /*774*/
  return kk_std_core_hnd_prompt_local_var(loc, res, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_pad_10044_fun201__t {
  struct kk_function_s _base;
  kk_function_t body;
  kk_integer_t d;
};
static kk_box_t kk_main__mlift_pad_10044_fun201(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_pad_10044_fun201(kk_function_t body, kk_integer_t d, kk_context_t* _ctx) {
  struct kk_main__mlift_pad_10044_fun201__t* _self = kk_function_alloc_as(struct kk_main__mlift_pad_10044_fun201__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_pad_10044_fun201, kk_context());
  _self->body = body;
  _self->d = d;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_pad_10044_fun201(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main__mlift_pad_10044_fun201__t* _self = kk_function_as(struct kk_main__mlift_pad_10044_fun201__t*, _fself, _ctx);
  kk_function_t body = _self->body; /* () -> <div|864> 863 */
  kk_integer_t d = _self->d; /* int */
  kk_drop_match(_self, {kk_function_dup(body, _ctx);kk_integer_dup(d, _ctx);}, {}, _ctx)
  kk_integer_t _x_x202 = kk_integer_add_small_const(d, -1, _ctx); /*int*/
  return kk_main_pad(_x_x202, body, _ctx);
}

kk_box_t kk_main__mlift_pad_10044(kk_function_t body, kk_integer_t d, kk_ssize_t _y_x10030, kk_context_t* _ctx) { /* forall<a,e> (body : () -> <div|e> a, d : int, hnd/ev-index) -> <state,div|e> a */ 
  return kk_std_core_hnd__mask_at(_y_x10030, false, kk_main__new_mlift_pad_10044_fun201(body, d, _ctx), _ctx);
}


// lift anonymous function
struct kk_main_pad_fun203__t {
  struct kk_function_s _base;
  kk_function_t body_0;
  kk_integer_t d_0;
};
static kk_box_t kk_main_pad_fun203(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_pad_fun203(kk_function_t body_0, kk_integer_t d_0, kk_context_t* _ctx) {
  struct kk_main_pad_fun203__t* _self = kk_function_alloc_as(struct kk_main_pad_fun203__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_pad_fun203, kk_context());
  _self->body_0 = body_0;
  _self->d_0 = d_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_pad_fun205__t {
  struct kk_function_s _base;
  kk_function_t body_0;
  kk_integer_t d_0;
};
static kk_box_t kk_main_pad_fun205(kk_function_t _fself, kk_box_t _b_x98, kk_context_t* _ctx);
static kk_function_t kk_main_new_pad_fun205(kk_function_t body_0, kk_integer_t d_0, kk_context_t* _ctx) {
  struct kk_main_pad_fun205__t* _self = kk_function_alloc_as(struct kk_main_pad_fun205__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_pad_fun205, kk_context());
  _self->body_0 = body_0;
  _self->d_0 = d_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_pad_fun205(kk_function_t _fself, kk_box_t _b_x98, kk_context_t* _ctx) {
  struct kk_main_pad_fun205__t* _self = kk_function_as(struct kk_main_pad_fun205__t*, _fself, _ctx);
  kk_function_t body_0 = _self->body_0; /* () -> <div|864> 863 */
  kk_integer_t d_0 = _self->d_0; /* int */
  kk_drop_match(_self, {kk_function_dup(body_0, _ctx);kk_integer_dup(d_0, _ctx);}, {}, _ctx)
  kk_ssize_t _x_x206 = kk_ssize_unbox(_b_x98, KK_OWNED, _ctx); /*hnd/ev-index*/
  return kk_main__mlift_pad_10044(body_0, d_0, _x_x206, _ctx);
}
static kk_box_t kk_main_pad_fun203(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_pad_fun203__t* _self = kk_function_as(struct kk_main_pad_fun203__t*, _fself, _ctx);
  kk_function_t body_0 = _self->body_0; /* () -> <div|864> 863 */
  kk_integer_t d_0 = _self->d_0; /* int */
  kk_drop_match(_self, {kk_function_dup(body_0, _ctx);kk_integer_dup(d_0, _ctx);}, {}, _ctx)
  kk_ssize_t x_10071;
  kk_std_core_hnd__htag _x_x204 = kk_std_core_hnd__htag_dup(kk_main__tag_state, _ctx); /*hnd/htag<main/state>*/
  x_10071 = kk_std_core_hnd__evv_index(_x_x204, _ctx); /*hnd/ev-index*/
  if (kk_yielding(kk_context())) {
    return kk_std_core_hnd_yield_extend(kk_main_new_pad_fun205(body_0, d_0, _ctx), _ctx);
  }
  {
    return kk_main__mlift_pad_10044(body_0, d_0, x_10071, _ctx);
  }
}

kk_box_t kk_main_pad(kk_integer_t d_0, kk_function_t body_0, kk_context_t* _ctx) { /* forall<a,e> (d : int, body : () -> <div|e> a) -> <div|e> a */ 
  bool _match_x131 = kk_integer_eq_borrow(d_0,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x131) {
    kk_integer_drop(d_0, _ctx);
    return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), body_0, (body_0, _ctx), _ctx);
  }
  {
    return kk_main_shandler(kk_integer_from_small(-377), kk_main_new_pad_fun203(body_0, d_0, _ctx), _ctx);
  }
}
extern kk_integer_t kk_main_run_fun209(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_main_countdown(_ctx);
}
extern kk_box_t kk_main_run_fun210(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun210__t* _self = kk_function_as(struct kk_main_run_fun210__t*, _fself, _ctx);
  kk_function_t _b_x102_108 = _self->_b_x102_108; /* () -> <div,main/state> int */
  kk_drop_match(_self, {kk_function_dup(_b_x102_108, _ctx);}, {}, _ctx)
  kk_integer_t _x_x211 = kk_function_call(kk_integer_t, (kk_function_t, kk_context_t*), _b_x102_108, (_b_x102_108, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x211, _ctx);
}
extern kk_box_t kk_main_run_fun208(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun208__t* _self = kk_function_as(struct kk_main_run_fun208__t*, _fself, _ctx);
  kk_integer_t d = _self->d; /* int */
  kk_drop_match(_self, {kk_integer_dup(d, _ctx);}, {}, _ctx)
  kk_integer_t _b_x101_107 = d; /*int*/;
  kk_function_t _b_x102_108 = kk_main_new_run_fun209(_ctx); /*() -> <div,main/state> int*/;
  return kk_main_pad(_b_x101_107, kk_main_new_run_fun210(_b_x102_108, _ctx), _ctx);
}


// lift anonymous function
struct kk_main_main_fun221__t {
  struct kk_function_s _base;
  kk_std_core_types__maybe m_0_10006;
};
static kk_box_t kk_main_main_fun221(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun221(kk_std_core_types__maybe m_0_10006, kk_context_t* _ctx) {
  struct kk_main_main_fun221__t* _self = kk_function_alloc_as(struct kk_main_main_fun221__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_main_fun221, kk_context());
  _self->m_0_10006 = m_0_10006;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_main_fun223__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun223(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun223(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun223, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_main_fun223(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x224 = kk_main_countdown(_ctx); /*int*/
  return kk_integer_box(_x_x224, _ctx);
}
static kk_box_t kk_main_main_fun221(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_main_fun221__t* _self = kk_function_as(struct kk_main_main_fun221__t*, _fself, _ctx);
  kk_std_core_types__maybe m_0_10006 = _self->m_0_10006; /* maybe<int> */
  kk_drop_match(_self, {kk_std_core_types__maybe_dup(m_0_10006, _ctx);}, {}, _ctx)
  kk_integer_t _x_x222;
  if (kk_std_core_types__is_Nothing(m_0_10006, _ctx)) {
    _x_x222 = kk_integer_from_small(10); /*int*/
  }
  else {
    kk_box_t _box_x113 = m_0_10006._cons.Just.value;
    kk_integer_t x_1 = kk_integer_unbox(_box_x113, _ctx);
    kk_integer_dup(x_1, _ctx);
    kk_std_core_types__maybe_drop(m_0_10006, _ctx);
    _x_x222 = x_1; /*int*/
  }
  return kk_main_pad(_x_x222, kk_main_new_main_fun223(_ctx), _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10004 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10002;
  kk_string_t _x_x212;
  if (kk_std_core_types__is_Cons(xs_10004, _ctx)) {
    struct kk_std_core_types_Cons* _con_x213 = kk_std_core_types__as_Cons(xs_10004, _ctx);
    kk_box_t _box_x109 = _con_x213->head;
    kk_std_core_types__list _pat_0_0 = _con_x213->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x109);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10004, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10004, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10004, _ctx);
    }
    _x_x212 = x_0; /*string*/
  }
  else {
    _x_x212 = kk_string_empty(); /*string*/
  }
  m_10002 = kk_std_core_int_parse_int(_x_x212, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_std_core_types__list xs_1_10010 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_0_10006;
  kk_string_t _x_x215;
  kk_std_core_types__list _match_x130;
  if (kk_std_core_types__is_Cons(xs_1_10010, _ctx)) {
    struct kk_std_core_types_Cons* _con_x216 = kk_std_core_types__as_Cons(xs_1_10010, _ctx);
    kk_box_t _box_x110 = _con_x216->head;
    kk_std_core_types__list xx = _con_x216->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs_1_10010, _ctx)) {
      kk_box_drop(_box_x110, _ctx);
      kk_datatype_ptr_free(xs_1_10010, _ctx);
    }
    else {
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs_1_10010, _ctx);
    }
    _match_x130 = xx; /*list<string>*/
  }
  else {
    _match_x130 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
  }
  if (kk_std_core_types__is_Cons(_match_x130, _ctx)) {
    struct kk_std_core_types_Cons* _con_x217 = kk_std_core_types__as_Cons(_match_x130, _ctx);
    kk_box_t _box_x111 = _con_x217->head;
    kk_std_core_types__list _pat_0_2 = _con_x217->tail;
    kk_string_t x_2 = kk_string_unbox(_box_x111);
    if kk_likely(kk_datatype_ptr_is_unique(_match_x130, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_2, _ctx);
      kk_datatype_ptr_free(_match_x130, _ctx);
    }
    else {
      kk_string_dup(x_2, _ctx);
      kk_datatype_ptr_decref(_match_x130, _ctx);
    }
    _x_x215 = x_2; /*string*/
  }
  else {
    _x_x215 = kk_string_empty(); /*string*/
  }
  m_0_10006 = kk_std_core_int_parse_int(_x_x215, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_box_t _x_x219;
  kk_integer_t _x_x220;
  if (kk_std_core_types__is_Nothing(m_10002, _ctx)) {
    _x_x220 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x112 = m_10002._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x112, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10002, _ctx);
    _x_x220 = x; /*int*/
  }
  _x_x219 = kk_main_shandler(_x_x220, kk_main_new_main_fun221(m_0_10006, _ctx), _ctx); /*774*/
  r = kk_integer_unbox(_x_x219, _ctx); /*int*/
  kk_string_t _x_x225 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x225, _ctx); return kk_Unit;
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
    kk_string_t _x_x153;
    kk_define_string_literal(, _s_x154, 10, "state@main", _ctx)
    _x_x153 = kk_string_dup(_s_x154, _ctx); /*string*/
    kk_main__tag_state = kk_std_core_hnd__new_Htag(_x_x153, _ctx); /*hnd/htag<main/state>*/
  }
  {
    kk_string_t _x_x156;
    kk_define_string_literal(, _s_x157, 10, "yield@main", _ctx)
    _x_x156 = kk_string_dup(_s_x157, _ctx); /*string*/
    kk_main__tag_yield = kk_std_core_hnd__new_Htag(_x_x156, _ctx); /*hnd/htag<main/yield>*/
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
