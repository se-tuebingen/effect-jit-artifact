// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:operator`

kk_std_core_hnd__htag kk_main__tag_operator;
 
// handler for the effect `:operator`

kk_box_t kk_main__handle_operator(kk_main__operator hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : operator<e,b>, ret : (res : a) -> e b, action : () -> <operator|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x70 = kk_std_core_hnd__htag_dup(kk_main__tag_operator, _ctx); /*hnd/htag<main/operator>*/
  return kk_std_core_hnd__hhandle(_x_x70, kk_main__operator_box(hnd, _ctx), ret, action, _ctx);
}
 
// monadic lift

kk_integer_t kk_main__mlift_loop_10026(kk_integer_t i, kk_integer_t s, kk_unit_t wild__, kk_context_t* _ctx) { /* (i : int, s : int, wild_ : ()) -> operator int */ 
  kk_integer_t _x_x75 = kk_integer_add_small_const(i, -1, _ctx); /*int*/
  return kk_main_loop(_x_x75, s, _ctx);
}


// lift anonymous function
struct kk_main_loop_fun82__t {
  struct kk_function_s _base;
  kk_integer_t i_0;
  kk_integer_t s_0;
};
static kk_box_t kk_main_loop_fun82(kk_function_t _fself, kk_box_t _b_x25, kk_context_t* _ctx);
static kk_function_t kk_main_new_loop_fun82(kk_integer_t i_0, kk_integer_t s_0, kk_context_t* _ctx) {
  struct kk_main_loop_fun82__t* _self = kk_function_alloc_as(struct kk_main_loop_fun82__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_loop_fun82, kk_context());
  _self->i_0 = i_0;
  _self->s_0 = s_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_loop_fun82(kk_function_t _fself, kk_box_t _b_x25, kk_context_t* _ctx) {
  struct kk_main_loop_fun82__t* _self = kk_function_as(struct kk_main_loop_fun82__t*, _fself, _ctx);
  kk_integer_t i_0 = _self->i_0; /* int */
  kk_integer_t s_0 = _self->s_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(i_0, _ctx);kk_integer_dup(s_0, _ctx);}, {}, _ctx)
  kk_unit_t wild___0_27 = kk_Unit;
  kk_unit_unbox(_b_x25);
  kk_integer_t _x_x83 = kk_main__mlift_loop_10026(i_0, s_0, wild___0_27, _ctx); /*int*/
  return kk_integer_box(_x_x83, _ctx);
}

kk_integer_t kk_main_loop(kk_integer_t i_0, kk_integer_t s_0, kk_context_t* _ctx) { /* (i : int, s : int) -> <div,operator> int */ 
  kk__tailcall: ;
  bool _match_x61 = kk_integer_eq_borrow(i_0,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x61) {
    kk_integer_drop(i_0, _ctx);
    return s_0;
  }
  {
    kk_std_core_hnd__ev ev_10034 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/operator>*/;
    kk_unit_t x_10031 = kk_Unit;
    kk_box_t _x_x76;
    {
      struct kk_std_core_hnd_Ev* _con_x77 = kk_std_core_hnd__as_Ev(ev_10034, _ctx);
      kk_box_t _box_x16 = _con_x77->hnd;
      int32_t m = _con_x77->marker;
      kk_main__operator h = kk_main__operator_unbox(_box_x16, KK_BORROWED, _ctx);
      kk_main__operator_dup(h, _ctx);
      {
        struct kk_main__Hnd_operator* _con_x78 = kk_main__as_Hnd_operator(h, _ctx);
        kk_integer_t _pat_0_0 = _con_x78->_cfc;
        kk_std_core_hnd__clause1 _ctl_operator = _con_x78->_ctl_operator;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_integer_drop(_pat_0_0, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_ctl_operator, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x20 = _ctl_operator.clause;
          kk_box_t _x_x79;
          kk_integer_t _x_x80 = kk_integer_dup(i_0, _ctx); /*int*/
          _x_x79 = kk_integer_box(_x_x80, _ctx); /*1009*/
          _x_x76 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x20, (_fun_unbox_x20, m, ev_10034, _x_x79, _ctx), _ctx); /*1010*/
        }
      }
    }
    kk_unit_unbox(_x_x76);
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x81 = kk_std_core_hnd_yield_extend(kk_main_new_loop_fun82(i_0, s_0, _ctx), _ctx); /*3003*/
      return kk_integer_unbox(_x_x81, _ctx);
    }
    { // tailcall
      kk_integer_t _x_x84 = kk_integer_add_small_const(i_0, -1, _ctx); /*int*/
      i_0 = _x_x84;
      goto kk__tailcall;
    }
  }
}


// lift anonymous function
struct kk_main_run_fun86__t {
  struct kk_function_s _base;
};
static kk_unit_t kk_main_run_fun86(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun86(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun86, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun88__t {
  struct kk_function_s _base;
  kk_integer_t x;
};
static kk_box_t kk_main_run_fun88(kk_function_t _fself, kk_function_t _b_x37, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun88(kk_integer_t x, kk_context_t* _ctx) {
  struct kk_main_run_fun88__t* _self = kk_function_alloc_as(struct kk_main_run_fun88__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun88, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun89__t {
  struct kk_function_s _base;
  kk_function_t _b_x37;
};
static kk_integer_t kk_main_run_fun89(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x38, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun89(kk_function_t _b_x37, kk_context_t* _ctx) {
  struct kk_main_run_fun89__t* _self = kk_function_alloc_as(struct kk_main_run_fun89__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun89, kk_context());
  _self->_b_x37 = _b_x37;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun89(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x38, kk_context_t* _ctx) {
  struct kk_main_run_fun89__t* _self = kk_function_as(struct kk_main_run_fun89__t*, _fself, _ctx);
  kk_function_t _b_x37 = _self->_b_x37; /* (hnd/resume-result<3004,3006>) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x37, _ctx);}, {}, _ctx)
  kk_box_t _x_x90 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x37, (_b_x37, _b_x38, _ctx), _ctx); /*3006*/
  return kk_integer_unbox(_x_x90, _ctx);
}


// lift anonymous function
struct kk_main_run_fun91__t {
  struct kk_function_s _base;
};
static kk_integer_t kk_main_run_fun91(kk_function_t _fself, kk_integer_t x_0, kk_function_t resume, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun91(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun91, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_integer_t kk_main_run_fun91(kk_function_t _fself, kk_integer_t x_0, kk_function_t resume, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t y = kk_function_call(kk_integer_t, (kk_function_t, kk_unit_t, kk_context_t*), resume, (resume, kk_Unit, _ctx), _ctx); /*int*/;
  kk_integer_t y_1_10004 = kk_integer_mul((kk_integer_from_small(503)),y,kk_context()); /*int*/;
  kk_integer_t x_0_10001 = kk_integer_sub(x_0,y_1_10004,kk_context()); /*int*/;
  kk_integer_t _x_x92;
  kk_integer_t _x_x93 = kk_integer_add_small_const(x_0_10001, 37, _ctx); /*int*/
  _x_x92 = kk_integer_abs(_x_x93,kk_context()); /*int*/
  return kk_integer_mod(_x_x92,(kk_integer_from_small(1009)),kk_context());
}


// lift anonymous function
struct kk_main_run_fun94__t {
  struct kk_function_s _base;
  kk_function_t _b_x29_54;
};
static kk_box_t kk_main_run_fun94(kk_function_t _fself, kk_box_t _b_x31, kk_function_t _b_x32, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun94(kk_function_t _b_x29_54, kk_context_t* _ctx) {
  struct kk_main_run_fun94__t* _self = kk_function_alloc_as(struct kk_main_run_fun94__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun94, kk_context());
  _self->_b_x29_54 = _b_x29_54;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun97__t {
  struct kk_function_s _base;
  kk_function_t _b_x32;
};
static kk_integer_t kk_main_run_fun97(kk_function_t _fself, kk_unit_t _b_x33, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun97(kk_function_t _b_x32, kk_context_t* _ctx) {
  struct kk_main_run_fun97__t* _self = kk_function_alloc_as(struct kk_main_run_fun97__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun97, kk_context());
  _self->_b_x32 = _b_x32;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun97(kk_function_t _fself, kk_unit_t _b_x33, kk_context_t* _ctx) {
  struct kk_main_run_fun97__t* _self = kk_function_as(struct kk_main_run_fun97__t*, _fself, _ctx);
  kk_function_t _b_x32 = _self->_b_x32; /* (3005) -> 3006 3007 */
  kk_drop_match(_self, {kk_function_dup(_b_x32, _ctx);}, {}, _ctx)
  kk_box_t _x_x98 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x32, (_b_x32, kk_unit_box(_b_x33), _ctx), _ctx); /*3007*/
  return kk_integer_unbox(_x_x98, _ctx);
}
static kk_box_t kk_main_run_fun94(kk_function_t _fself, kk_box_t _b_x31, kk_function_t _b_x32, kk_context_t* _ctx) {
  struct kk_main_run_fun94__t* _self = kk_function_as(struct kk_main_run_fun94__t*, _fself, _ctx);
  kk_function_t _b_x29_54 = _self->_b_x29_54; /* (x@0 : int, resume : (()) -> div int) -> div int */
  kk_drop_match(_self, {kk_function_dup(_b_x29_54, _ctx);}, {}, _ctx)
  kk_integer_t _x_x95;
  kk_integer_t _x_x96 = kk_integer_unbox(_b_x31, _ctx); /*int*/
  _x_x95 = kk_function_call(kk_integer_t, (kk_function_t, kk_integer_t, kk_function_t, kk_context_t*), _b_x29_54, (_b_x29_54, _x_x96, kk_main_new_run_fun97(_b_x32, _ctx), _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x95, _ctx);
}


// lift anonymous function
struct kk_main_run_fun99__t {
  struct kk_function_s _base;
  kk_function_t _b_x30_55;
};
static kk_box_t kk_main_run_fun99(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x34, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun99(kk_function_t _b_x30_55, kk_context_t* _ctx) {
  struct kk_main_run_fun99__t* _self = kk_function_alloc_as(struct kk_main_run_fun99__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun99, kk_context());
  _self->_b_x30_55 = _b_x30_55;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun99(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x34, kk_context_t* _ctx) {
  struct kk_main_run_fun99__t* _self = kk_function_as(struct kk_main_run_fun99__t*, _fself, _ctx);
  kk_function_t _b_x30_55 = _self->_b_x30_55; /* (hnd/resume-result<(),int>) -> div int */
  kk_drop_match(_self, {kk_function_dup(_b_x30_55, _ctx);}, {}, _ctx)
  kk_integer_t _x_x100 = kk_function_call(kk_integer_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x30_55, (_b_x30_55, _b_x34, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x100, _ctx);
}
static kk_box_t kk_main_run_fun88(kk_function_t _fself, kk_function_t _b_x37, kk_context_t* _ctx) {
  struct kk_main_run_fun88__t* _self = kk_function_as(struct kk_main_run_fun88__t*, _fself, _ctx);
  kk_integer_t x = _self->x; /* int */
  kk_drop_match(_self, {kk_integer_dup(x, _ctx);}, {}, _ctx)
  kk_function_t k_56 = kk_main_new_run_fun89(_b_x37, _ctx); /*(hnd/resume-result<(),int>) -> div int*/;
  kk_integer_t _b_x28_53 = x; /*int*/;
  kk_function_t _b_x29_54 = kk_main_new_run_fun91(_ctx); /*(x@0 : int, resume : (()) -> div int) -> div int*/;
  kk_function_t _b_x30_55 = k_56; /*(hnd/resume-result<(),int>) -> div int*/;
  return kk_std_core_hnd_protect(kk_integer_box(_b_x28_53, _ctx), kk_main_new_run_fun94(_b_x29_54, _ctx), kk_main_new_run_fun99(_b_x30_55, _ctx), _ctx);
}
static kk_unit_t kk_main_run_fun86(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x681__16, (KK_I32(3)), _ctx);
  kk_box_t _x_x87 = kk_std_core_hnd_yield_to(m, kk_main_new_run_fun88(x, _ctx), _ctx); /*3004*/
  return kk_unit_unbox(_x_x87);
}


// lift anonymous function
struct kk_main_run_fun103__t {
  struct kk_function_s _base;
  kk_function_t _b_x39_50;
};
static kk_box_t kk_main_run_fun103(kk_function_t _fself, int32_t _b_x40, kk_std_core_hnd__ev _b_x41, kk_box_t _b_x42, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun103(kk_function_t _b_x39_50, kk_context_t* _ctx) {
  struct kk_main_run_fun103__t* _self = kk_function_alloc_as(struct kk_main_run_fun103__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun103, kk_context());
  _self->_b_x39_50 = _b_x39_50;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun103(kk_function_t _fself, int32_t _b_x40, kk_std_core_hnd__ev _b_x41, kk_box_t _b_x42, kk_context_t* _ctx) {
  struct kk_main_run_fun103__t* _self = kk_function_as(struct kk_main_run_fun103__t*, _fself, _ctx);
  kk_function_t _b_x39_50 = _self->_b_x39_50; /* (m : hnd/marker<div,int>, hnd/ev<main/operator>, x : int) -> div () */
  kk_drop_match(_self, {kk_function_dup(_b_x39_50, _ctx);}, {}, _ctx)
  kk_unit_t _x_x104 = kk_Unit;
  kk_integer_t _x_x105 = kk_integer_unbox(_b_x42, _ctx); /*int*/
  kk_function_call(kk_unit_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_integer_t, kk_context_t*), _b_x39_50, (_b_x39_50, _b_x40, _b_x41, _x_x105, _ctx), _ctx);
  return kk_unit_box(_x_x104);
}


// lift anonymous function
struct kk_main_run_fun106__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun106(kk_function_t _fself, kk_box_t _b_x46, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun106(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun106, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun106(kk_function_t _fself, kk_box_t _b_x46, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_57 = kk_integer_unbox(_b_x46, _ctx); /*int*/;
  return kk_integer_box(_x_57, _ctx);
}


// lift anonymous function
struct kk_main_run_fun107__t {
  struct kk_function_s _base;
  kk_integer_t n;
  kk_integer_t s;
};
static kk_box_t kk_main_run_fun107(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun107(kk_integer_t n, kk_integer_t s, kk_context_t* _ctx) {
  struct kk_main_run_fun107__t* _self = kk_function_alloc_as(struct kk_main_run_fun107__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun107, kk_context());
  _self->n = n;
  _self->s = s;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun107(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun107__t* _self = kk_function_as(struct kk_main_run_fun107__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_integer_t s = _self->s; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);kk_integer_dup(s, _ctx);}, {}, _ctx)
  kk_integer_t _x_x108 = kk_main_loop(n, s, _ctx); /*int*/
  return kk_integer_box(_x_x108, _ctx);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_integer_t s, kk_context_t* _ctx) { /* (n : int, s : int) -> div int */ 
  kk_box_t _x_x85;
  kk_function_t _b_x39_50 = kk_main_new_run_fun86(_ctx); /*(m : hnd/marker<div,int>, hnd/ev<main/operator>, x : int) -> div ()*/;
  kk_main__operator _x_x101;
  kk_std_core_hnd__clause1 _x_x102 = kk_std_core_hnd__new_Clause1(kk_main_new_run_fun103(_b_x39_50, _ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x101 = kk_main__new_Hnd_operator(kk_reuse_null, 0, kk_integer_from_small(3), _x_x102, _ctx); /*main/operator<6,7>*/
  _x_x85 = kk_main__handle_operator(_x_x101, kk_main_new_run_fun106(_ctx), kk_main_new_run_fun107(n, s, _ctx), _ctx); /*134*/
  return kk_integer_unbox(_x_x85, _ctx);
}
 
// lifted local: repeat, step

kk_integer_t kk_main__lift_repeat_514(kk_integer_t n, kk_integer_t l, kk_integer_t s, kk_context_t* _ctx) { /* (n : int, l : int, s : int) -> div int */ 
  kk__tailcall: ;
  bool _match_x60 = kk_integer_eq_borrow(l,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x60) {
    kk_integer_drop(n, _ctx);
    kk_integer_drop(l, _ctx);
    return s;
  }
  {
    kk_integer_t l_0_10005 = kk_integer_add_small_const(l, -1, _ctx); /*int*/;
    kk_integer_t s_0_10006;
    kk_integer_t _x_x109 = kk_integer_dup(n, _ctx); /*int*/
    s_0_10006 = kk_main_run(_x_x109, s, _ctx); /*int*/
    { // tailcall
      l = l_0_10005;
      s = s_0_10006;
      goto kk__tailcall;
    }
  }
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10011 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10009;
  kk_string_t _x_x110;
  if (kk_std_core_types__is_Cons(xs_10011, _ctx)) {
    struct kk_std_core_types_Cons* _con_x111 = kk_std_core_types__as_Cons(xs_10011, _ctx);
    kk_box_t _box_x58 = _con_x111->head;
    kk_std_core_types__list _pat_0_0 = _con_x111->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x58);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10011, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10011, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10011, _ctx);
    }
    _x_x110 = x_0; /*string*/
  }
  else {
    _x_x110 = kk_string_empty(); /*string*/
  }
  m_10009 = kk_std_core_int_parse_int(_x_x110, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_integer_t _x_x113;
  if (kk_std_core_types__is_Nothing(m_10009, _ctx)) {
    _x_x113 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x59 = m_10009._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x59, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10009, _ctx);
    _x_x113 = x; /*int*/
  }
  r = kk_main__lift_repeat_514(_x_x113, kk_integer_from_small(1000), kk_integer_from_small(0), _ctx); /*int*/
  kk_string_t _x_x114 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x114, _ctx); return kk_Unit;
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
    kk_string_t _x_x68;
    kk_define_string_literal(, _s_x69, 13, "operator@main", _ctx)
    _x_x68 = kk_string_dup(_s_x69, _ctx); /*string*/
    kk_main__tag_operator = kk_std_core_hnd__new_Htag(_x_x68, _ctx); /*hnd/htag<main/operator>*/
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
  kk_std_core_hnd__htag_drop(kk_main__tag_operator, _ctx);
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
