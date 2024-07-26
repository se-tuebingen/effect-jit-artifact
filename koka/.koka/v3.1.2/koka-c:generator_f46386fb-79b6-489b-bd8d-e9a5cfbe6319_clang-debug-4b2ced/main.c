// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:yield`

kk_std_core_hnd__htag kk_main__tag_yield;
 
// handler for the effect `:yield`

kk_box_t kk_main__handle_yield(kk_main__yield hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : yield<e,b>, ret : (res : a) -> e b, action : () -> <yield|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x132 = kk_std_core_hnd__htag_dup(kk_main__tag_yield, _ctx); /*hnd/htag<main/yield>*/
  return kk_std_core_hnd__hhandle(_x_x132, kk_main__yield_box(hnd, _ctx), ret, action, _ctx);
}


// lift anonymous function
struct kk_main_generate_fun138__t {
  struct kk_function_s _base;
};
static kk_unit_t kk_main_generate_fun138(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun138(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_generate_fun138, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_generate_fun140__t {
  struct kk_function_s _base;
  kk_integer_t x;
};
static kk_box_t kk_main_generate_fun140(kk_function_t _fself, kk_function_t _b_x25, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun140(kk_integer_t x, kk_context_t* _ctx) {
  struct kk_main_generate_fun140__t* _self = kk_function_alloc_as(struct kk_main_generate_fun140__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_generate_fun140, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_generate_fun141__t {
  struct kk_function_s _base;
  kk_function_t _b_x25;
};
static kk_main__generator kk_main_generate_fun141(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x26, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun141(kk_function_t _b_x25, kk_context_t* _ctx) {
  struct kk_main_generate_fun141__t* _self = kk_function_alloc_as(struct kk_main_generate_fun141__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_generate_fun141, kk_context());
  _self->_b_x25 = _b_x25;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_main__generator kk_main_generate_fun141(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x26, kk_context_t* _ctx) {
  struct kk_main_generate_fun141__t* _self = kk_function_as(struct kk_main_generate_fun141__t*, _fself, _ctx);
  kk_function_t _b_x25 = _self->_b_x25; /* (hnd/resume-result<3004,3006>) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x25, _ctx);}, {}, _ctx)
  kk_box_t _x_x142 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x25, (_b_x25, _b_x26, _ctx), _ctx); /*3006*/
  return kk_main__generator_unbox(_x_x142, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_main_generate_fun143__t {
  struct kk_function_s _base;
};
static kk_main__generator kk_main_generate_fun143(kk_function_t _fself, kk_integer_t x_0, kk_function_t resume, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun143(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_generate_fun143, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_generate_fun144__t {
  struct kk_function_s _base;
  kk_function_t resume;
};
static kk_main__generator kk_main_generate_fun144(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun144(kk_function_t resume, kk_context_t* _ctx) {
  struct kk_main_generate_fun144__t* _self = kk_function_alloc_as(struct kk_main_generate_fun144__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_generate_fun144, kk_context());
  _self->resume = resume;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_main__generator kk_main_generate_fun144(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_generate_fun144__t* _self = kk_function_as(struct kk_main_generate_fun144__t*, _fself, _ctx);
  kk_function_t resume = _self->resume; /* (()) -> div main/generator */
  kk_drop_match(_self, {kk_function_dup(resume, _ctx);}, {}, _ctx)
  return kk_function_call(kk_main__generator, (kk_function_t, kk_unit_t, kk_context_t*), resume, (resume, kk_Unit, _ctx), _ctx);
}
static kk_main__generator kk_main_generate_fun143(kk_function_t _fself, kk_integer_t x_0, kk_function_t resume, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_main__new_Thunk(kk_reuse_null, 0, x_0, kk_main_new_generate_fun144(resume, _ctx), _ctx);
}


// lift anonymous function
struct kk_main_generate_fun145__t {
  struct kk_function_s _base;
  kk_function_t _b_x17_42;
};
static kk_box_t kk_main_generate_fun145(kk_function_t _fself, kk_box_t _b_x19, kk_function_t _b_x20, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun145(kk_function_t _b_x17_42, kk_context_t* _ctx) {
  struct kk_main_generate_fun145__t* _self = kk_function_alloc_as(struct kk_main_generate_fun145__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_generate_fun145, kk_context());
  _self->_b_x17_42 = _b_x17_42;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_generate_fun148__t {
  struct kk_function_s _base;
  kk_function_t _b_x20;
};
static kk_main__generator kk_main_generate_fun148(kk_function_t _fself, kk_unit_t _b_x21, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun148(kk_function_t _b_x20, kk_context_t* _ctx) {
  struct kk_main_generate_fun148__t* _self = kk_function_alloc_as(struct kk_main_generate_fun148__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_generate_fun148, kk_context());
  _self->_b_x20 = _b_x20;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_main__generator kk_main_generate_fun148(kk_function_t _fself, kk_unit_t _b_x21, kk_context_t* _ctx) {
  struct kk_main_generate_fun148__t* _self = kk_function_as(struct kk_main_generate_fun148__t*, _fself, _ctx);
  kk_function_t _b_x20 = _self->_b_x20; /* (3005) -> 3006 3007 */
  kk_drop_match(_self, {kk_function_dup(_b_x20, _ctx);}, {}, _ctx)
  kk_box_t _x_x149 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x20, (_b_x20, kk_unit_box(_b_x21), _ctx), _ctx); /*3007*/
  return kk_main__generator_unbox(_x_x149, KK_OWNED, _ctx);
}
static kk_box_t kk_main_generate_fun145(kk_function_t _fself, kk_box_t _b_x19, kk_function_t _b_x20, kk_context_t* _ctx) {
  struct kk_main_generate_fun145__t* _self = kk_function_as(struct kk_main_generate_fun145__t*, _fself, _ctx);
  kk_function_t _b_x17_42 = _self->_b_x17_42; /* (x@0 : int, resume : (()) -> div main/generator) -> div main/generator */
  kk_drop_match(_self, {kk_function_dup(_b_x17_42, _ctx);}, {}, _ctx)
  kk_main__generator _x_x146;
  kk_integer_t _x_x147 = kk_integer_unbox(_b_x19, _ctx); /*int*/
  _x_x146 = kk_function_call(kk_main__generator, (kk_function_t, kk_integer_t, kk_function_t, kk_context_t*), _b_x17_42, (_b_x17_42, _x_x147, kk_main_new_generate_fun148(_b_x20, _ctx), _ctx), _ctx); /*main/generator*/
  return kk_main__generator_box(_x_x146, _ctx);
}


// lift anonymous function
struct kk_main_generate_fun150__t {
  struct kk_function_s _base;
  kk_function_t _b_x18_43;
};
static kk_box_t kk_main_generate_fun150(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x22, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun150(kk_function_t _b_x18_43, kk_context_t* _ctx) {
  struct kk_main_generate_fun150__t* _self = kk_function_alloc_as(struct kk_main_generate_fun150__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_generate_fun150, kk_context());
  _self->_b_x18_43 = _b_x18_43;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_generate_fun150(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x22, kk_context_t* _ctx) {
  struct kk_main_generate_fun150__t* _self = kk_function_as(struct kk_main_generate_fun150__t*, _fself, _ctx);
  kk_function_t _b_x18_43 = _self->_b_x18_43; /* (hnd/resume-result<(),main/generator>) -> div main/generator */
  kk_drop_match(_self, {kk_function_dup(_b_x18_43, _ctx);}, {}, _ctx)
  kk_main__generator _x_x151 = kk_function_call(kk_main__generator, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x18_43, (_b_x18_43, _b_x22, _ctx), _ctx); /*main/generator*/
  return kk_main__generator_box(_x_x151, _ctx);
}
static kk_box_t kk_main_generate_fun140(kk_function_t _fself, kk_function_t _b_x25, kk_context_t* _ctx) {
  struct kk_main_generate_fun140__t* _self = kk_function_as(struct kk_main_generate_fun140__t*, _fself, _ctx);
  kk_integer_t x = _self->x; /* int */
  kk_drop_match(_self, {kk_integer_dup(x, _ctx);}, {}, _ctx)
  kk_function_t k_44 = kk_main_new_generate_fun141(_b_x25, _ctx); /*(hnd/resume-result<(),main/generator>) -> div main/generator*/;
  kk_integer_t _b_x16_41 = x; /*int*/;
  kk_function_t _b_x17_42 = kk_main_new_generate_fun143(_ctx); /*(x@0 : int, resume : (()) -> div main/generator) -> div main/generator*/;
  kk_function_t _b_x18_43 = k_44; /*(hnd/resume-result<(),main/generator>) -> div main/generator*/;
  return kk_std_core_hnd_protect(kk_integer_box(_b_x16_41, _ctx), kk_main_new_generate_fun145(_b_x17_42, _ctx), kk_main_new_generate_fun150(_b_x18_43, _ctx), _ctx);
}
static kk_unit_t kk_main_generate_fun138(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_integer_t x, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x681__16, (KK_I32(3)), _ctx);
  kk_box_t _x_x139 = kk_std_core_hnd_yield_to(m, kk_main_new_generate_fun140(x, _ctx), _ctx); /*3004*/
  return kk_unit_unbox(_x_x139);
}


// lift anonymous function
struct kk_main_generate_fun154__t {
  struct kk_function_s _base;
  kk_function_t _b_x27_38;
};
static kk_box_t kk_main_generate_fun154(kk_function_t _fself, int32_t _b_x28, kk_std_core_hnd__ev _b_x29, kk_box_t _b_x30, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun154(kk_function_t _b_x27_38, kk_context_t* _ctx) {
  struct kk_main_generate_fun154__t* _self = kk_function_alloc_as(struct kk_main_generate_fun154__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_generate_fun154, kk_context());
  _self->_b_x27_38 = _b_x27_38;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_generate_fun154(kk_function_t _fself, int32_t _b_x28, kk_std_core_hnd__ev _b_x29, kk_box_t _b_x30, kk_context_t* _ctx) {
  struct kk_main_generate_fun154__t* _self = kk_function_as(struct kk_main_generate_fun154__t*, _fself, _ctx);
  kk_function_t _b_x27_38 = _self->_b_x27_38; /* (m : hnd/marker<div,main/generator>, hnd/ev<main/yield>, x : int) -> div () */
  kk_drop_match(_self, {kk_function_dup(_b_x27_38, _ctx);}, {}, _ctx)
  kk_unit_t _x_x155 = kk_Unit;
  kk_integer_t _x_x156 = kk_integer_unbox(_b_x30, _ctx); /*int*/
  kk_function_call(kk_unit_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_integer_t, kk_context_t*), _b_x27_38, (_b_x27_38, _b_x28, _b_x29, _x_x156, _ctx), _ctx);
  return kk_unit_box(_x_x155);
}


// lift anonymous function
struct kk_main_generate_fun157__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_generate_fun157(kk_function_t _fself, kk_box_t _b_x34, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun157(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_generate_fun157, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_generate_fun157(kk_function_t _fself, kk_box_t _b_x34, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t __w_l33_c12_45 = kk_Unit;
  kk_unit_unbox(_b_x34);
  return kk_main__generator_box(kk_main__new_Empty(_ctx), _ctx);
}


// lift anonymous function
struct kk_main_generate_fun158__t {
  struct kk_function_s _base;
  kk_function_t f;
};
static kk_box_t kk_main_generate_fun158(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_generate_fun158(kk_function_t f, kk_context_t* _ctx) {
  struct kk_main_generate_fun158__t* _self = kk_function_alloc_as(struct kk_main_generate_fun158__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_generate_fun158, kk_context());
  _self->f = f;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_generate_fun158(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_generate_fun158__t* _self = kk_function_as(struct kk_main_generate_fun158__t*, _fself, _ctx);
  kk_function_t f = _self->f; /* () -> <main/yield,div> () */
  kk_drop_match(_self, {kk_function_dup(f, _ctx);}, {}, _ctx)
  kk_unit_t _x_x159 = kk_Unit;
  kk_function_call(kk_unit_t, (kk_function_t, kk_context_t*), f, (f, _ctx), _ctx);
  return kk_unit_box(_x_x159);
}

kk_main__generator kk_main_generate(kk_function_t f, kk_context_t* _ctx) { /* (f : () -> <div,yield> ()) -> div generator */ 
  kk_box_t _x_x137;
  kk_function_t _b_x27_38 = kk_main_new_generate_fun138(_ctx); /*(m : hnd/marker<div,main/generator>, hnd/ev<main/yield>, x : int) -> div ()*/;
  kk_main__yield _x_x152;
  kk_std_core_hnd__clause1 _x_x153 = kk_std_core_hnd__new_Clause1(kk_main_new_generate_fun154(_b_x27_38, _ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x152 = kk_main__new_Hnd_yield(kk_reuse_null, 0, kk_integer_from_small(3), _x_x153, _ctx); /*main/yield<11,12>*/
  _x_x137 = kk_main__handle_yield(_x_x152, kk_main_new_generate_fun157(_ctx), kk_main_new_generate_fun158(f, _ctx), _ctx); /*188*/
  return kk_main__generator_unbox(_x_x137, KK_OWNED, _ctx);
}
 
// monadic lift

kk_unit_t kk_main__mlift_iterate_10021(kk_main__tree r, kk_unit_t wild___0, kk_context_t* _ctx) { /* (r : tree, wild_@0 : ()) -> yield () */ 
  kk_main_iterate(r, _ctx); return kk_Unit;
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_iterate_10022_fun164__t {
  struct kk_function_s _base;
  kk_main__tree r_0;
};
static kk_box_t kk_main__mlift_iterate_10022_fun164(kk_function_t _fself, kk_box_t _b_x55, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_iterate_10022_fun164(kk_main__tree r_0, kk_context_t* _ctx) {
  struct kk_main__mlift_iterate_10022_fun164__t* _self = kk_function_alloc_as(struct kk_main__mlift_iterate_10022_fun164__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_iterate_10022_fun164, kk_context());
  _self->r_0 = r_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_iterate_10022_fun164(kk_function_t _fself, kk_box_t _b_x55, kk_context_t* _ctx) {
  struct kk_main__mlift_iterate_10022_fun164__t* _self = kk_function_as(struct kk_main__mlift_iterate_10022_fun164__t*, _fself, _ctx);
  kk_main__tree r_0 = _self->r_0; /* main/tree */
  kk_drop_match(_self, {kk_main__tree_dup(r_0, _ctx);}, {}, _ctx)
  kk_unit_t wild___0_0_57 = kk_Unit;
  kk_unit_unbox(_b_x55);
  kk_unit_t _x_x165 = kk_Unit;
  kk_main__mlift_iterate_10021(r_0, wild___0_0_57, _ctx);
  return kk_unit_box(_x_x165);
}

kk_unit_t kk_main__mlift_iterate_10022(kk_main__tree r_0, kk_integer_t v, kk_unit_t wild__, kk_context_t* _ctx) { /* (r : tree, v : int, wild_ : ()) -> yield () */ 
  kk_std_core_hnd__ev ev_10030 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/yield>*/;
  kk_unit_t x_10028 = kk_Unit;
  kk_box_t _x_x160;
  {
    struct kk_std_core_hnd_Ev* _con_x161 = kk_std_core_hnd__as_Ev(ev_10030, _ctx);
    kk_box_t _box_x46 = _con_x161->hnd;
    int32_t m = _con_x161->marker;
    kk_main__yield h = kk_main__yield_unbox(_box_x46, KK_BORROWED, _ctx);
    kk_main__yield_dup(h, _ctx);
    {
      struct kk_main__Hnd_yield* _con_x162 = kk_main__as_Hnd_yield(h, _ctx);
      kk_integer_t _pat_0 = _con_x162->_cfc;
      kk_std_core_hnd__clause1 _ctl_yield = _con_x162->_ctl_yield;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_integer_drop(_pat_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_yield, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x50 = _ctl_yield.clause;
        _x_x160 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x50, (_fun_unbox_x50, m, ev_10030, kk_integer_box(v, _ctx), _ctx), _ctx); /*1010*/
      }
    }
  }
  kk_unit_unbox(_x_x160);
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x163 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_iterate_10022_fun164(r_0, _ctx), _ctx); /*3003*/
    kk_unit_unbox(_x_x163); return kk_Unit;
  }
  {
    kk_main__mlift_iterate_10021(r_0, x_10028, _ctx); return kk_Unit;
  }
}


// lift anonymous function
struct kk_main_iterate_fun168__t {
  struct kk_function_s _base;
  kk_main__tree r_1;
  kk_integer_t v_0;
};
static kk_box_t kk_main_iterate_fun168(kk_function_t _fself, kk_box_t _b_x59, kk_context_t* _ctx);
static kk_function_t kk_main_new_iterate_fun168(kk_main__tree r_1, kk_integer_t v_0, kk_context_t* _ctx) {
  struct kk_main_iterate_fun168__t* _self = kk_function_alloc_as(struct kk_main_iterate_fun168__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_iterate_fun168, kk_context());
  _self->r_1 = r_1;
  _self->v_0 = v_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_iterate_fun168(kk_function_t _fself, kk_box_t _b_x59, kk_context_t* _ctx) {
  struct kk_main_iterate_fun168__t* _self = kk_function_as(struct kk_main_iterate_fun168__t*, _fself, _ctx);
  kk_main__tree r_1 = _self->r_1; /* main/tree */
  kk_integer_t v_0 = _self->v_0; /* int */
  kk_drop_match(_self, {kk_main__tree_dup(r_1, _ctx);kk_integer_dup(v_0, _ctx);}, {}, _ctx)
  kk_unit_t wild___1_72 = kk_Unit;
  kk_unit_unbox(_b_x59);
  kk_unit_t _x_x169 = kk_Unit;
  kk_main__mlift_iterate_10022(r_1, v_0, wild___1_72, _ctx);
  return kk_unit_box(_x_x169);
}


// lift anonymous function
struct kk_main_iterate_fun174__t {
  struct kk_function_s _base;
  kk_main__tree r_1;
};
static kk_box_t kk_main_iterate_fun174(kk_function_t _fself, kk_box_t _b_x69, kk_context_t* _ctx);
static kk_function_t kk_main_new_iterate_fun174(kk_main__tree r_1, kk_context_t* _ctx) {
  struct kk_main_iterate_fun174__t* _self = kk_function_alloc_as(struct kk_main_iterate_fun174__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_iterate_fun174, kk_context());
  _self->r_1 = r_1;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_iterate_fun174(kk_function_t _fself, kk_box_t _b_x69, kk_context_t* _ctx) {
  struct kk_main_iterate_fun174__t* _self = kk_function_as(struct kk_main_iterate_fun174__t*, _fself, _ctx);
  kk_main__tree r_1 = _self->r_1; /* main/tree */
  kk_drop_match(_self, {kk_main__tree_dup(r_1, _ctx);}, {}, _ctx)
  kk_unit_t wild___0_1_73 = kk_Unit;
  kk_unit_unbox(_b_x69);
  kk_unit_t _x_x175 = kk_Unit;
  kk_main__mlift_iterate_10021(r_1, wild___0_1_73, _ctx);
  return kk_unit_box(_x_x175);
}

kk_unit_t kk_main_iterate(kk_main__tree t, kk_context_t* _ctx) { /* (t : tree) -> yield () */ 
  kk__tailcall: ;
  if (kk_main__is_Leaf(t, _ctx)) {
    kk_Unit; return kk_Unit;
  }
  {
    struct kk_main_Node* _con_x166 = kk_main__as_Node(t, _ctx);
    kk_main__tree l = _con_x166->left;
    kk_integer_t v_0 = _con_x166->value;
    kk_main__tree r_1 = _con_x166->right;
    if kk_likely(kk_datatype_ptr_is_unique(t, _ctx)) {
      kk_datatype_ptr_free(t, _ctx);
    }
    else {
      kk_main__tree_dup(l, _ctx);
      kk_main__tree_dup(r_1, _ctx);
      kk_integer_dup(v_0, _ctx);
      kk_datatype_ptr_decref(t, _ctx);
    }
    kk_unit_t x_1_10033 = kk_Unit;
    kk_main_iterate(l, _ctx);
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x167 = kk_std_core_hnd_yield_extend(kk_main_new_iterate_fun168(r_1, v_0, _ctx), _ctx); /*3003*/
      kk_unit_unbox(_x_x167); return kk_Unit;
    }
    {
      kk_std_core_hnd__ev ev_0_10039 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/yield>*/;
      kk_unit_t x_2_10036 = kk_Unit;
      kk_box_t _x_x170;
      {
        struct kk_std_core_hnd_Ev* _con_x171 = kk_std_core_hnd__as_Ev(ev_0_10039, _ctx);
        kk_box_t _box_x60 = _con_x171->hnd;
        int32_t m_0 = _con_x171->marker;
        kk_main__yield h_0 = kk_main__yield_unbox(_box_x60, KK_BORROWED, _ctx);
        kk_main__yield_dup(h_0, _ctx);
        {
          struct kk_main__Hnd_yield* _con_x172 = kk_main__as_Hnd_yield(h_0, _ctx);
          kk_integer_t _pat_0_3 = _con_x172->_cfc;
          kk_std_core_hnd__clause1 _ctl_yield_0 = _con_x172->_ctl_yield;
          if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
            kk_integer_drop(_pat_0_3, _ctx);
            kk_datatype_ptr_free(h_0, _ctx);
          }
          else {
            kk_std_core_hnd__clause1_dup(_ctl_yield_0, _ctx);
            kk_datatype_ptr_decref(h_0, _ctx);
          }
          {
            kk_function_t _fun_unbox_x64 = _ctl_yield_0.clause;
            _x_x170 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x64, (_fun_unbox_x64, m_0, ev_0_10039, kk_integer_box(v_0, _ctx), _ctx), _ctx); /*1010*/
          }
        }
      }
      kk_unit_unbox(_x_x170);
      if (kk_yielding(kk_context())) {
        kk_box_t _x_x173 = kk_std_core_hnd_yield_extend(kk_main_new_iterate_fun174(r_1, _ctx), _ctx); /*3003*/
        kk_unit_unbox(_x_x173); return kk_Unit;
      }
      { // tailcall
        t = r_1;
        goto kk__tailcall;
      }
    }
  }
}

kk_main__tree kk_main_make(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div tree */ 
  bool _match_x114 = kk_integer_eq_borrow(n,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x114) {
    kk_integer_drop(n, _ctx);
    return kk_main__new_Leaf(_ctx);
  }
  {
    kk_main__tree t;
    kk_integer_t _x_x176;
    kk_integer_t _x_x177 = kk_integer_dup(n, _ctx); /*int*/
    _x_x176 = kk_integer_add_small_const(_x_x177, -1, _ctx); /*int*/
    t = kk_main_make(_x_x176, _ctx); /*main/tree*/
    kk_main__tree _x_x178 = kk_main__tree_dup(t, _ctx); /*main/tree*/
    return kk_main__new_Node(kk_reuse_null, 0, _x_x178, n, t, _ctx);
  }
}

kk_integer_t kk_main_sum(kk_integer_t a, kk_main__generator g, kk_context_t* _ctx) { /* (a : int, g : generator) -> div int */ 
  kk__tailcall: ;
  if (kk_main__is_Empty(g, _ctx)) {
    return a;
  }
  {
    struct kk_main_Thunk* _con_x179 = kk_main__as_Thunk(g, _ctx);
    kk_integer_t v = _con_x179->value;
    kk_function_t f = _con_x179->next;
    if kk_likely(kk_datatype_ptr_is_unique(g, _ctx)) {
      kk_datatype_ptr_free(g, _ctx);
    }
    else {
      kk_function_dup(f, _ctx);
      kk_integer_dup(v, _ctx);
      kk_datatype_ptr_decref(g, _ctx);
    }
    { // tailcall
      kk_integer_t _x_x180 = kk_integer_add(v,a,kk_context()); /*int*/
      kk_main__generator _x_x181 = kk_function_call(kk_main__generator, (kk_function_t, kk_context_t*), f, (f, _ctx), _ctx); /*main/generator*/
      a = _x_x180;
      g = _x_x181;
      goto kk__tailcall;
    }
  }
}


// lift anonymous function
struct kk_main_run_fun186__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun186(kk_function_t _fself, int32_t _b_x86, kk_std_core_hnd__ev _b_x87, kk_box_t _b_x88, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun186(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun186, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun189__t {
  struct kk_function_s _base;
  kk_integer_t x_110;
};
static kk_box_t kk_main_run_fun189(kk_function_t _fself, kk_function_t _b_x83, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun189(kk_integer_t x_110, kk_context_t* _ctx) {
  struct kk_main_run_fun189__t* _self = kk_function_alloc_as(struct kk_main_run_fun189__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun189, kk_context());
  _self->x_110 = x_110;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun190__t {
  struct kk_function_s _base;
  kk_function_t _b_x83;
};
static kk_main__generator kk_main_run_fun190(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x84, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun190(kk_function_t _b_x83, kk_context_t* _ctx) {
  struct kk_main_run_fun190__t* _self = kk_function_alloc_as(struct kk_main_run_fun190__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun190, kk_context());
  _self->_b_x83 = _b_x83;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_main__generator kk_main_run_fun190(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x84, kk_context_t* _ctx) {
  struct kk_main_run_fun190__t* _self = kk_function_as(struct kk_main_run_fun190__t*, _fself, _ctx);
  kk_function_t _b_x83 = _self->_b_x83; /* (hnd/resume-result<3004,3006>) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x83, _ctx);}, {}, _ctx)
  kk_box_t _x_x191 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x83, (_b_x83, _b_x84, _ctx), _ctx); /*3006*/
  return kk_main__generator_unbox(_x_x191, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_main_run_fun192__t {
  struct kk_function_s _base;
};
static kk_main__generator kk_main_run_fun192(kk_function_t _fself, kk_integer_t x_0, kk_function_t resume, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun192(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun192, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main_run_fun193__t {
  struct kk_function_s _base;
  kk_function_t resume;
};
static kk_main__generator kk_main_run_fun193(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun193(kk_function_t resume, kk_context_t* _ctx) {
  struct kk_main_run_fun193__t* _self = kk_function_alloc_as(struct kk_main_run_fun193__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun193, kk_context());
  _self->resume = resume;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_main__generator kk_main_run_fun193(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun193__t* _self = kk_function_as(struct kk_main_run_fun193__t*, _fself, _ctx);
  kk_function_t resume = _self->resume; /* (()) -> div main/generator */
  kk_drop_match(_self, {kk_function_dup(resume, _ctx);}, {}, _ctx)
  return kk_function_call(kk_main__generator, (kk_function_t, kk_unit_t, kk_context_t*), resume, (resume, kk_Unit, _ctx), _ctx);
}
static kk_main__generator kk_main_run_fun192(kk_function_t _fself, kk_integer_t x_0, kk_function_t resume, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_main__new_Thunk(kk_reuse_null, 0, x_0, kk_main_new_run_fun193(resume, _ctx), _ctx);
}


// lift anonymous function
struct kk_main_run_fun194__t {
  struct kk_function_s _base;
  kk_function_t _b_x75_103;
};
static kk_box_t kk_main_run_fun194(kk_function_t _fself, kk_box_t _b_x77, kk_function_t _b_x78, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun194(kk_function_t _b_x75_103, kk_context_t* _ctx) {
  struct kk_main_run_fun194__t* _self = kk_function_alloc_as(struct kk_main_run_fun194__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun194, kk_context());
  _self->_b_x75_103 = _b_x75_103;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun197__t {
  struct kk_function_s _base;
  kk_function_t _b_x78;
};
static kk_main__generator kk_main_run_fun197(kk_function_t _fself, kk_unit_t _b_x79, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun197(kk_function_t _b_x78, kk_context_t* _ctx) {
  struct kk_main_run_fun197__t* _self = kk_function_alloc_as(struct kk_main_run_fun197__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun197, kk_context());
  _self->_b_x78 = _b_x78;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_main__generator kk_main_run_fun197(kk_function_t _fself, kk_unit_t _b_x79, kk_context_t* _ctx) {
  struct kk_main_run_fun197__t* _self = kk_function_as(struct kk_main_run_fun197__t*, _fself, _ctx);
  kk_function_t _b_x78 = _self->_b_x78; /* (3005) -> 3006 3007 */
  kk_drop_match(_self, {kk_function_dup(_b_x78, _ctx);}, {}, _ctx)
  kk_box_t _x_x198 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x78, (_b_x78, kk_unit_box(_b_x79), _ctx), _ctx); /*3007*/
  return kk_main__generator_unbox(_x_x198, KK_OWNED, _ctx);
}
static kk_box_t kk_main_run_fun194(kk_function_t _fself, kk_box_t _b_x77, kk_function_t _b_x78, kk_context_t* _ctx) {
  struct kk_main_run_fun194__t* _self = kk_function_as(struct kk_main_run_fun194__t*, _fself, _ctx);
  kk_function_t _b_x75_103 = _self->_b_x75_103; /* (x@0 : int, resume : (()) -> div main/generator) -> div main/generator */
  kk_drop_match(_self, {kk_function_dup(_b_x75_103, _ctx);}, {}, _ctx)
  kk_main__generator _x_x195;
  kk_integer_t _x_x196 = kk_integer_unbox(_b_x77, _ctx); /*int*/
  _x_x195 = kk_function_call(kk_main__generator, (kk_function_t, kk_integer_t, kk_function_t, kk_context_t*), _b_x75_103, (_b_x75_103, _x_x196, kk_main_new_run_fun197(_b_x78, _ctx), _ctx), _ctx); /*main/generator*/
  return kk_main__generator_box(_x_x195, _ctx);
}


// lift anonymous function
struct kk_main_run_fun199__t {
  struct kk_function_s _base;
  kk_function_t _b_x76_104;
};
static kk_box_t kk_main_run_fun199(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x80, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun199(kk_function_t _b_x76_104, kk_context_t* _ctx) {
  struct kk_main_run_fun199__t* _self = kk_function_alloc_as(struct kk_main_run_fun199__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun199, kk_context());
  _self->_b_x76_104 = _b_x76_104;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun199(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x80, kk_context_t* _ctx) {
  struct kk_main_run_fun199__t* _self = kk_function_as(struct kk_main_run_fun199__t*, _fself, _ctx);
  kk_function_t _b_x76_104 = _self->_b_x76_104; /* (hnd/resume-result<(),main/generator>) -> div main/generator */
  kk_drop_match(_self, {kk_function_dup(_b_x76_104, _ctx);}, {}, _ctx)
  kk_main__generator _x_x200 = kk_function_call(kk_main__generator, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), _b_x76_104, (_b_x76_104, _b_x80, _ctx), _ctx); /*main/generator*/
  return kk_main__generator_box(_x_x200, _ctx);
}
static kk_box_t kk_main_run_fun189(kk_function_t _fself, kk_function_t _b_x83, kk_context_t* _ctx) {
  struct kk_main_run_fun189__t* _self = kk_function_as(struct kk_main_run_fun189__t*, _fself, _ctx);
  kk_integer_t x_110 = _self->x_110; /* int */
  kk_drop_match(_self, {kk_integer_dup(x_110, _ctx);}, {}, _ctx)
  kk_function_t k_107 = kk_main_new_run_fun190(_b_x83, _ctx); /*(hnd/resume-result<(),main/generator>) -> div main/generator*/;
  kk_integer_t _b_x74_102 = x_110; /*int*/;
  kk_function_t _b_x75_103 = kk_main_new_run_fun192(_ctx); /*(x@0 : int, resume : (()) -> div main/generator) -> div main/generator*/;
  kk_function_t _b_x76_104 = k_107; /*(hnd/resume-result<(),main/generator>) -> div main/generator*/;
  return kk_std_core_hnd_protect(kk_integer_box(_b_x74_102, _ctx), kk_main_new_run_fun194(_b_x75_103, _ctx), kk_main_new_run_fun199(_b_x76_104, _ctx), _ctx);
}
static kk_box_t kk_main_run_fun186(kk_function_t _fself, int32_t _b_x86, kk_std_core_hnd__ev _b_x87, kk_box_t _b_x88, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x187 = kk_Unit;
  int32_t m_108 = _b_x86; /*hnd/marker<div,main/generator>*/;
  kk_std_core_hnd__ev ___wildcard_x681__16_109 = _b_x87; /*hnd/ev<main/yield>*/;
  kk_datatype_ptr_dropn(___wildcard_x681__16_109, (KK_I32(3)), _ctx);
  kk_integer_t x_110 = kk_integer_unbox(_b_x88, _ctx); /*int*/;
  kk_box_t _x_x188 = kk_std_core_hnd_yield_to(m_108, kk_main_new_run_fun189(x_110, _ctx), _ctx); /*3004*/
  kk_unit_unbox(_x_x188);
  return kk_unit_box(_x_x187);
}


// lift anonymous function
struct kk_main_run_fun201__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun201(kk_function_t _fself, kk_box_t _b_x95, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun201(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun201, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun201(kk_function_t _fself, kk_box_t _b_x95, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_main__generator _x_x202;
  kk_unit_t __w_l33_c12_111 = kk_Unit;
  kk_unit_unbox(_b_x95);
  _x_x202 = kk_main__new_Empty(_ctx); /*main/generator*/
  return kk_main__generator_box(_x_x202, _ctx);
}


// lift anonymous function
struct kk_main_run_fun203__t {
  struct kk_function_s _base;
  kk_integer_t n;
};
static kk_box_t kk_main_run_fun203(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun203(kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun203__t* _self = kk_function_alloc_as(struct kk_main_run_fun203__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun203, kk_context());
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun206__t {
  struct kk_function_s _base;
};
static kk_main__tree kk_main_run_fun206(kk_function_t _fself, kk_integer_t _x1_x205, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun206(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun206, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_main__tree kk_main_run_fun206(kk_function_t _fself, kk_integer_t _x1_x205, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_main_make(_x1_x205, _ctx);
}


// lift anonymous function
struct kk_main_run_fun209__t {
  struct kk_function_s _base;
  kk_function_t _b_x89_105;
};
static kk_box_t kk_main_run_fun209(kk_function_t _fself, kk_box_t _b_x91, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun209(kk_function_t _b_x89_105, kk_context_t* _ctx) {
  struct kk_main_run_fun209__t* _self = kk_function_alloc_as(struct kk_main_run_fun209__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun209, kk_context());
  _self->_b_x89_105 = _b_x89_105;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun209(kk_function_t _fself, kk_box_t _b_x91, kk_context_t* _ctx) {
  struct kk_main_run_fun209__t* _self = kk_function_as(struct kk_main_run_fun209__t*, _fself, _ctx);
  kk_function_t _b_x89_105 = _self->_b_x89_105; /* (n : int) -> div main/tree */
  kk_drop_match(_self, {kk_function_dup(_b_x89_105, _ctx);}, {}, _ctx)
  kk_main__tree _x_x210;
  kk_integer_t _x_x211 = kk_integer_unbox(_b_x91, _ctx); /*int*/
  _x_x210 = kk_function_call(kk_main__tree, (kk_function_t, kk_integer_t, kk_context_t*), _b_x89_105, (_b_x89_105, _x_x211, _ctx), _ctx); /*main/tree*/
  return kk_main__tree_box(_x_x210, _ctx);
}
static kk_box_t kk_main_run_fun203(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun203__t* _self = kk_function_as(struct kk_main_run_fun203__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_unit_t _x_x204 = kk_Unit;
  kk_function_t _b_x89_105 = kk_main_new_run_fun206(_ctx); /*(n : int) -> div main/tree*/;
  kk_integer_t _b_x90_106 = n; /*int*/;
  kk_main__tree _x_x207;
  kk_box_t _x_x208 = kk_std_core_hnd__open_none1(kk_main_new_run_fun209(_b_x89_105, _ctx), kk_integer_box(_b_x90_106, _ctx), _ctx); /*1001*/
  _x_x207 = kk_main__tree_unbox(_x_x208, KK_OWNED, _ctx); /*main/tree*/
  kk_main_iterate(_x_x207, _ctx);
  return kk_unit_box(_x_x204);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  kk_main__generator _x_x182;
  kk_box_t _x_x183;
  kk_main__yield _x_x184;
  kk_std_core_hnd__clause1 _x_x185 = kk_std_core_hnd__new_Clause1(kk_main_new_run_fun186(_ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x184 = kk_main__new_Hnd_yield(kk_reuse_null, 0, kk_integer_from_small(3), _x_x185, _ctx); /*main/yield<11,12>*/
  _x_x183 = kk_main__handle_yield(_x_x184, kk_main_new_run_fun201(_ctx), kk_main_new_run_fun203(n, _ctx), _ctx); /*188*/
  _x_x182 = kk_main__generator_unbox(_x_x183, KK_OWNED, _ctx); /*main/generator*/
  return kk_main_sum(kk_integer_from_small(0), _x_x182, _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10008 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10006;
  kk_string_t _x_x212;
  if (kk_std_core_types__is_Cons(xs_10008, _ctx)) {
    struct kk_std_core_types_Cons* _con_x213 = kk_std_core_types__as_Cons(xs_10008, _ctx);
    kk_box_t _box_x112 = _con_x213->head;
    kk_std_core_types__list _pat_0_0 = _con_x213->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x112);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10008, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10008, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10008, _ctx);
    }
    _x_x212 = x_0; /*string*/
  }
  else {
    _x_x212 = kk_string_empty(); /*string*/
  }
  m_10006 = kk_std_core_int_parse_int(_x_x212, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_integer_t _x_x215;
  if (kk_std_core_types__is_Nothing(m_10006, _ctx)) {
    _x_x215 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x113 = m_10006._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x113, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10006, _ctx);
    _x_x215 = x; /*int*/
  }
  r = kk_main_run(_x_x215, _ctx); /*int*/
  kk_string_t _x_x216 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x216, _ctx); return kk_Unit;
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
    kk_string_t _x_x130;
    kk_define_string_literal(, _s_x131, 10, "yield@main", _ctx)
    _x_x130 = kk_string_dup(_s_x131, _ctx); /*string*/
    kk_main__tag_yield = kk_std_core_hnd__new_Htag(_x_x130, _ctx); /*hnd/htag<main/yield>*/
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
