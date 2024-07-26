// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:choose`

kk_std_core_hnd__htag kk_main__tag_choose;
 
// handler for the effect `:choose`

kk_box_t kk_main__handle_choose(kk_main__choose hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : choose<e,b>, ret : (res : a) -> e b, action : () -> <choose|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x213 = kk_std_core_hnd__htag_dup(kk_main__tag_choose, _ctx); /*hnd/htag<main/choose>*/
  return kk_std_core_hnd__hhandle(_x_x213, kk_main__choose_box(hnd, _ctx), ret, action, _ctx);
}
extern kk_box_t kk_main_choose_fun219(kk_function_t _fself, int32_t _b_x15, kk_std_core_hnd__ev _b_x16, kk_context_t* _ctx) {
  struct kk_main_choose_fun219__t* _self = kk_function_as(struct kk_main_choose_fun219__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x11 = _self->_fun_unbox_x11; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x11, _ctx);}, {}, _ctx)
  bool _x_x220;
  int32_t _b_x12_23 = _b_x15; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x13_24 = _b_x16; /*hnd/ev<main/choose>*/;
  kk_box_t _x_x221 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x11, (_fun_unbox_x11, _b_x12_23, _b_x13_24, _ctx), _ctx); /*1005*/
  _x_x220 = kk_bool_unbox(_x_x221); /*bool*/
  return kk_bool_box(_x_x220);
}

kk_main__tree kk_main_make(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div tree */ 
  bool _match_x201 = kk_integer_eq_borrow(n,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x201) {
    kk_integer_drop(n, _ctx);
    return kk_main__new_Leaf(_ctx);
  }
  {
    kk_main__tree t;
    kk_integer_t _x_x223;
    kk_integer_t _x_x224 = kk_integer_dup(n, _ctx); /*int*/
    _x_x223 = kk_integer_add_small_const(_x_x224, -1, _ctx); /*int*/
    t = kk_main_make(_x_x223, _ctx); /*main/tree*/
    kk_main__tree _x_x225 = kk_main__tree_dup(t, _ctx); /*main/tree*/
    return kk_main__new_Node(kk_reuse_null, 0, _x_x225, n, t, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_lift_run_707_10048_fun227__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_lift_run_707_10048_fun227(kk_function_t _fself, kk_box_t _b_x28, kk_box_t _b_x29, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_lift_run_707_10048_fun227(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_lift_run_707_10048_fun227, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_lift_run_707_10048_fun227(kk_function_t _fself, kk_box_t _b_x28, kk_box_t _b_x29, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t x_2_33 = kk_integer_unbox(_b_x28, _ctx); /*int*/;
  kk_integer_t y_2_34 = kk_integer_unbox(_b_x29, _ctx); /*int*/;
  kk_integer_t y_4_10013 = kk_integer_mul((kk_integer_from_small(503)),y_2_34,kk_context()); /*int*/;
  kk_integer_t x_3_10010 = kk_integer_sub(x_2_33,y_4_10013,kk_context()); /*int*/;
  kk_integer_t _x_x228;
  kk_integer_t _x_x229;
  kk_integer_t _x_x230 = kk_integer_add_small_const(x_3_10010, 37, _ctx); /*int*/
  _x_x229 = kk_integer_abs(_x_x230,kk_context()); /*int*/
  _x_x228 = kk_integer_mod(_x_x229,(kk_integer_from_small(1009)),kk_context()); /*int*/
  return kk_integer_box(_x_x228, _ctx);
}

kk_integer_t kk_main__mlift_lift_run_707_10048(kk_integer_t v, kk_integer_t _y_x10036, kk_context_t* _ctx) { /* forall<h> (v : int, int) -> <local<h>,choose,div> int */ 
  kk_box_t _x_x226 = kk_std_core_hnd__open_none2(kk_main__new_mlift_lift_run_707_10048_fun227(_ctx), kk_integer_box(v, _ctx), kk_integer_box(_y_x10036, _ctx), _ctx); /*1002*/
  return kk_integer_unbox(_x_x226, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_lift_run_707_10049_fun233__t {
  struct kk_function_s _base;
  kk_integer_t v_0;
};
static kk_box_t kk_main__mlift_lift_run_707_10049_fun233(kk_function_t _fself, kk_box_t _b_x36, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_lift_run_707_10049_fun233(kk_integer_t v_0, kk_context_t* _ctx) {
  struct kk_main__mlift_lift_run_707_10049_fun233__t* _self = kk_function_alloc_as(struct kk_main__mlift_lift_run_707_10049_fun233__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_lift_run_707_10049_fun233, kk_context());
  _self->v_0 = v_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_lift_run_707_10049_fun233(kk_function_t _fself, kk_box_t _b_x36, kk_context_t* _ctx) {
  struct kk_main__mlift_lift_run_707_10049_fun233__t* _self = kk_function_as(struct kk_main__mlift_lift_run_707_10049_fun233__t*, _fself, _ctx);
  kk_integer_t v_0 = _self->v_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(v_0, _ctx);}, {}, _ctx)
  kk_integer_t _y_x10036_0_38 = kk_integer_unbox(_b_x36, _ctx); /*int*/;
  kk_integer_t _x_x234 = kk_main__mlift_lift_run_707_10048(v_0, _y_x10036_0_38, _ctx); /*int*/
  return kk_integer_box(_x_x234, _ctx);
}

kk_integer_t kk_main__mlift_lift_run_707_10049(bool _y_x10033, kk_main__tree l, kk_main__tree r, kk_ref_t state, kk_integer_t v_0, kk_unit_t wild__, kk_context_t* _ctx) { /* forall<h> (bool, l : tree, r : tree, state : local-var<h,int>, v : int, wild_ : ()) -> <local<h>,choose,div> int */ 
  kk_integer_t x_10055;
  kk_main__tree _x_x231;
  if (_y_x10033) {
    kk_main__tree_drop(r, _ctx);
    _x_x231 = l; /*main/tree*/
  }
  else {
    kk_main__tree_drop(l, _ctx);
    _x_x231 = r; /*main/tree*/
  }
  x_10055 = kk_main__lift_run_707(state, _x_x231, _ctx); /*int*/
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10055, _ctx);
    kk_box_t _x_x232 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_lift_run_707_10049_fun233(v_0, _ctx), _ctx); /*3003*/
    return kk_integer_unbox(_x_x232, _ctx);
  }
  {
    return kk_main__mlift_lift_run_707_10048(v_0, x_10055, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_lift_run_707_10050_fun236__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_lift_run_707_10050_fun236(kk_function_t _fself, kk_box_t _b_x42, kk_box_t _b_x43, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_lift_run_707_10050_fun236(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_lift_run_707_10050_fun236, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_lift_run_707_10050_fun236(kk_function_t _fself, kk_box_t _b_x42, kk_box_t _b_x43, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t y_1_10009;
  kk_integer_t _x_x237 = kk_integer_unbox(_b_x43, _ctx); /*int*/
  y_1_10009 = kk_integer_mul((kk_integer_from_small(503)),_x_x237,kk_context()); /*int*/
  kk_integer_t x_0_10006;
  kk_integer_t _x_x238 = kk_integer_unbox(_b_x42, _ctx); /*int*/
  x_0_10006 = kk_integer_sub(_x_x238,y_1_10009,kk_context()); /*int*/
  kk_integer_t _x_x239;
  kk_integer_t _x_x240;
  kk_integer_t _x_x241 = kk_integer_add_small_const(x_0_10006, 37, _ctx); /*int*/
  _x_x240 = kk_integer_abs(_x_x241,kk_context()); /*int*/
  _x_x239 = kk_integer_mod(_x_x240,(kk_integer_from_small(1009)),kk_context()); /*int*/
  return kk_integer_box(_x_x239, _ctx);
}


// lift anonymous function
struct kk_main__mlift_lift_run_707_10050_fun245__t {
  struct kk_function_s _base;
  kk_main__tree l_0;
  kk_main__tree r_0;
  kk_ref_t state_0;
  kk_integer_t v_1;
  bool _y_x10033_0;
};
static kk_box_t kk_main__mlift_lift_run_707_10050_fun245(kk_function_t _fself, kk_box_t _b_x54, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_lift_run_707_10050_fun245(kk_main__tree l_0, kk_main__tree r_0, kk_ref_t state_0, kk_integer_t v_1, bool _y_x10033_0, kk_context_t* _ctx) {
  struct kk_main__mlift_lift_run_707_10050_fun245__t* _self = kk_function_alloc_as(struct kk_main__mlift_lift_run_707_10050_fun245__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_lift_run_707_10050_fun245, kk_context());
  _self->l_0 = l_0;
  _self->r_0 = r_0;
  _self->state_0 = state_0;
  _self->v_1 = v_1;
  _self->_y_x10033_0 = _y_x10033_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_lift_run_707_10050_fun245(kk_function_t _fself, kk_box_t _b_x54, kk_context_t* _ctx) {
  struct kk_main__mlift_lift_run_707_10050_fun245__t* _self = kk_function_as(struct kk_main__mlift_lift_run_707_10050_fun245__t*, _fself, _ctx);
  kk_main__tree l_0 = _self->l_0; /* main/tree */
  kk_main__tree r_0 = _self->r_0; /* main/tree */
  kk_ref_t state_0 = _self->state_0; /* local-var<616,int> */
  kk_integer_t v_1 = _self->v_1; /* int */
  bool _y_x10033_0 = _self->_y_x10033_0; /* bool */
  kk_drop_match(_self, {kk_main__tree_dup(l_0, _ctx);kk_main__tree_dup(r_0, _ctx);kk_ref_dup(state_0, _ctx);kk_integer_dup(v_1, _ctx);kk_skip_dup(_y_x10033_0, _ctx);}, {}, _ctx)
  kk_unit_t wild___0_56 = kk_Unit;
  kk_unit_unbox(_b_x54);
  kk_integer_t _x_x246 = kk_main__mlift_lift_run_707_10049(_y_x10033_0, l_0, r_0, state_0, v_1, wild___0_56, _ctx); /*int*/
  return kk_integer_box(_x_x246, _ctx);
}

kk_integer_t kk_main__mlift_lift_run_707_10050(bool _y_x10033_0, kk_main__tree l_0, kk_main__tree r_0, kk_ref_t state_0, kk_integer_t v_1, kk_integer_t _y_x10034, kk_context_t* _ctx) { /* forall<h> (bool, l : tree, r : tree, state : local-var<h,int>, v : int, int) -> <local<h>,choose,div> int */ 
  kk_integer_t _b_x45_47;
  kk_box_t _x_x235;
  kk_box_t _x_x242;
  kk_integer_t _x_x243 = kk_integer_dup(v_1, _ctx); /*int*/
  _x_x242 = kk_integer_box(_x_x243, _ctx); /*1001*/
  _x_x235 = kk_std_core_hnd__open_none2(kk_main__new_mlift_lift_run_707_10050_fun236(_ctx), kk_integer_box(_y_x10034, _ctx), _x_x242, _ctx); /*1002*/
  _b_x45_47 = kk_integer_unbox(_x_x235, _ctx); /*int*/
  kk_unit_t x_0_10057 = kk_Unit;
  kk_ref_set_borrow(state_0,(kk_integer_box(_b_x45_47, _ctx)),kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x244 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_lift_run_707_10050_fun245(l_0, r_0, state_0, v_1, _y_x10033_0, _ctx), _ctx); /*3003*/
    return kk_integer_unbox(_x_x244, _ctx);
  }
  {
    return kk_main__mlift_lift_run_707_10049(_y_x10033_0, l_0, r_0, state_0, v_1, x_0_10057, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_lift_run_707_10051_fun250__t {
  struct kk_function_s _base;
  kk_main__tree l_1;
  kk_main__tree r_1;
  kk_ref_t state_1;
  kk_integer_t v_2;
  bool _y_x10033_1;
};
static kk_box_t kk_main__mlift_lift_run_707_10051_fun250(kk_function_t _fself, kk_box_t _b_x60, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_lift_run_707_10051_fun250(kk_main__tree l_1, kk_main__tree r_1, kk_ref_t state_1, kk_integer_t v_2, bool _y_x10033_1, kk_context_t* _ctx) {
  struct kk_main__mlift_lift_run_707_10051_fun250__t* _self = kk_function_alloc_as(struct kk_main__mlift_lift_run_707_10051_fun250__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_lift_run_707_10051_fun250, kk_context());
  _self->l_1 = l_1;
  _self->r_1 = r_1;
  _self->state_1 = state_1;
  _self->v_2 = v_2;
  _self->_y_x10033_1 = _y_x10033_1;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_lift_run_707_10051_fun250(kk_function_t _fself, kk_box_t _b_x60, kk_context_t* _ctx) {
  struct kk_main__mlift_lift_run_707_10051_fun250__t* _self = kk_function_as(struct kk_main__mlift_lift_run_707_10051_fun250__t*, _fself, _ctx);
  kk_main__tree l_1 = _self->l_1; /* main/tree */
  kk_main__tree r_1 = _self->r_1; /* main/tree */
  kk_ref_t state_1 = _self->state_1; /* local-var<616,int> */
  kk_integer_t v_2 = _self->v_2; /* int */
  bool _y_x10033_1 = _self->_y_x10033_1; /* bool */
  kk_drop_match(_self, {kk_main__tree_dup(l_1, _ctx);kk_main__tree_dup(r_1, _ctx);kk_ref_dup(state_1, _ctx);kk_integer_dup(v_2, _ctx);kk_skip_dup(_y_x10033_1, _ctx);}, {}, _ctx)
  kk_integer_t _y_x10034_0_62 = kk_integer_unbox(_b_x60, _ctx); /*int*/;
  kk_integer_t _x_x251 = kk_main__mlift_lift_run_707_10050(_y_x10033_1, l_1, r_1, state_1, v_2, _y_x10034_0_62, _ctx); /*int*/
  return kk_integer_box(_x_x251, _ctx);
}

kk_integer_t kk_main__mlift_lift_run_707_10051(kk_main__tree l_1, kk_main__tree r_1, kk_ref_t state_1, kk_integer_t v_2, bool _y_x10033_1, kk_context_t* _ctx) { /* forall<h> (l : tree, r : tree, state : local-var<h,int>, v : int, bool) -> choose int */ 
  kk_integer_t x_3_10059;
  kk_box_t _x_x247;
  kk_ref_t _x_x248 = kk_ref_dup(state_1, _ctx); /*local-var<616,int>*/
  _x_x247 = kk_ref_get(_x_x248,kk_context()); /*1000*/
  x_3_10059 = kk_integer_unbox(_x_x247, _ctx); /*int*/
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_3_10059, _ctx);
    kk_box_t _x_x249 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_lift_run_707_10051_fun250(l_1, r_1, state_1, v_2, _y_x10033_1, _ctx), _ctx); /*3003*/
    return kk_integer_unbox(_x_x249, _ctx);
  }
  {
    return kk_main__mlift_lift_run_707_10050(_y_x10033_1, l_1, r_1, state_1, v_2, x_3_10059, _ctx);
  }
}
 
// lifted local: run, explore


// lift anonymous function
struct kk_main__lift_run_707_fun258__t {
  struct kk_function_s _base;
  kk_main__tree l_2;
  kk_main__tree r_2;
  kk_ref_t state_2;
  kk_integer_t v_3;
};
static kk_box_t kk_main__lift_run_707_fun258(kk_function_t _fself, kk_box_t _b_x82, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_707_fun258(kk_main__tree l_2, kk_main__tree r_2, kk_ref_t state_2, kk_integer_t v_3, kk_context_t* _ctx) {
  struct kk_main__lift_run_707_fun258__t* _self = kk_function_alloc_as(struct kk_main__lift_run_707_fun258__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__lift_run_707_fun258, kk_context());
  _self->l_2 = l_2;
  _self->r_2 = r_2;
  _self->state_2 = state_2;
  _self->v_3 = v_3;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__lift_run_707_fun258(kk_function_t _fself, kk_box_t _b_x82, kk_context_t* _ctx) {
  struct kk_main__lift_run_707_fun258__t* _self = kk_function_as(struct kk_main__lift_run_707_fun258__t*, _fself, _ctx);
  kk_main__tree l_2 = _self->l_2; /* main/tree */
  kk_main__tree r_2 = _self->r_2; /* main/tree */
  kk_ref_t state_2 = _self->state_2; /* local-var<616,int> */
  kk_integer_t v_3 = _self->v_3; /* int */
  kk_drop_match(_self, {kk_main__tree_dup(l_2, _ctx);kk_main__tree_dup(r_2, _ctx);kk_ref_dup(state_2, _ctx);kk_integer_dup(v_3, _ctx);}, {}, _ctx)
  bool _y_x10033_2_118 = kk_bool_unbox(_b_x82); /*bool*/;
  kk_integer_t _x_x259 = kk_main__mlift_lift_run_707_10051(l_2, r_2, state_2, v_3, _y_x10033_2_118, _ctx); /*int*/
  return kk_integer_box(_x_x259, _ctx);
}


// lift anonymous function
struct kk_main__lift_run_707_fun263__t {
  struct kk_function_s _base;
  kk_main__tree l_2;
  kk_main__tree r_2;
  kk_ref_t state_2;
  kk_integer_t v_3;
  bool x_4_10061;
};
static kk_box_t kk_main__lift_run_707_fun263(kk_function_t _fself, kk_box_t _b_x86, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_707_fun263(kk_main__tree l_2, kk_main__tree r_2, kk_ref_t state_2, kk_integer_t v_3, bool x_4_10061, kk_context_t* _ctx) {
  struct kk_main__lift_run_707_fun263__t* _self = kk_function_alloc_as(struct kk_main__lift_run_707_fun263__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__lift_run_707_fun263, kk_context());
  _self->l_2 = l_2;
  _self->r_2 = r_2;
  _self->state_2 = state_2;
  _self->v_3 = v_3;
  _self->x_4_10061 = x_4_10061;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__lift_run_707_fun263(kk_function_t _fself, kk_box_t _b_x86, kk_context_t* _ctx) {
  struct kk_main__lift_run_707_fun263__t* _self = kk_function_as(struct kk_main__lift_run_707_fun263__t*, _fself, _ctx);
  kk_main__tree l_2 = _self->l_2; /* main/tree */
  kk_main__tree r_2 = _self->r_2; /* main/tree */
  kk_ref_t state_2 = _self->state_2; /* local-var<616,int> */
  kk_integer_t v_3 = _self->v_3; /* int */
  bool x_4_10061 = _self->x_4_10061; /* bool */
  kk_drop_match(_self, {kk_main__tree_dup(l_2, _ctx);kk_main__tree_dup(r_2, _ctx);kk_ref_dup(state_2, _ctx);kk_integer_dup(v_3, _ctx);kk_skip_dup(x_4_10061, _ctx);}, {}, _ctx)
  kk_integer_t _y_x10034_1_119 = kk_integer_unbox(_b_x86, _ctx); /*int*/;
  kk_integer_t _x_x264 = kk_main__mlift_lift_run_707_10050(x_4_10061, l_2, r_2, state_2, v_3, _y_x10034_1_119, _ctx); /*int*/
  return kk_integer_box(_x_x264, _ctx);
}


// lift anonymous function
struct kk_main__lift_run_707_fun266__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_707_fun266(kk_function_t _fself, kk_box_t _b_x90, kk_box_t _b_x91, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_707_fun266(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_707_fun266, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__lift_run_707_fun266(kk_function_t _fself, kk_box_t _b_x90, kk_box_t _b_x91, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t y_1_10009_0;
  kk_integer_t _x_x267 = kk_integer_unbox(_b_x91, _ctx); /*int*/
  y_1_10009_0 = kk_integer_mul((kk_integer_from_small(503)),_x_x267,kk_context()); /*int*/
  kk_integer_t x_0_10006_0;
  kk_integer_t _x_x268 = kk_integer_unbox(_b_x90, _ctx); /*int*/
  x_0_10006_0 = kk_integer_sub(_x_x268,y_1_10009_0,kk_context()); /*int*/
  kk_integer_t _x_x269;
  kk_integer_t _x_x270;
  kk_integer_t _x_x271 = kk_integer_add_small_const(x_0_10006_0, 37, _ctx); /*int*/
  _x_x270 = kk_integer_abs(_x_x271,kk_context()); /*int*/
  _x_x269 = kk_integer_mod(_x_x270,(kk_integer_from_small(1009)),kk_context()); /*int*/
  return kk_integer_box(_x_x269, _ctx);
}


// lift anonymous function
struct kk_main__lift_run_707_fun275__t {
  struct kk_function_s _base;
  kk_main__tree l_2;
  kk_main__tree r_2;
  kk_ref_t state_2;
  kk_integer_t v_3;
  bool x_4_10061;
};
static kk_box_t kk_main__lift_run_707_fun275(kk_function_t _fself, kk_box_t _b_x102, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_707_fun275(kk_main__tree l_2, kk_main__tree r_2, kk_ref_t state_2, kk_integer_t v_3, bool x_4_10061, kk_context_t* _ctx) {
  struct kk_main__lift_run_707_fun275__t* _self = kk_function_alloc_as(struct kk_main__lift_run_707_fun275__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__lift_run_707_fun275, kk_context());
  _self->l_2 = l_2;
  _self->r_2 = r_2;
  _self->state_2 = state_2;
  _self->v_3 = v_3;
  _self->x_4_10061 = x_4_10061;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__lift_run_707_fun275(kk_function_t _fself, kk_box_t _b_x102, kk_context_t* _ctx) {
  struct kk_main__lift_run_707_fun275__t* _self = kk_function_as(struct kk_main__lift_run_707_fun275__t*, _fself, _ctx);
  kk_main__tree l_2 = _self->l_2; /* main/tree */
  kk_main__tree r_2 = _self->r_2; /* main/tree */
  kk_ref_t state_2 = _self->state_2; /* local-var<616,int> */
  kk_integer_t v_3 = _self->v_3; /* int */
  bool x_4_10061 = _self->x_4_10061; /* bool */
  kk_drop_match(_self, {kk_main__tree_dup(l_2, _ctx);kk_main__tree_dup(r_2, _ctx);kk_ref_dup(state_2, _ctx);kk_integer_dup(v_3, _ctx);kk_skip_dup(x_4_10061, _ctx);}, {}, _ctx)
  kk_unit_t wild___1_120 = kk_Unit;
  kk_unit_unbox(_b_x102);
  kk_integer_t _x_x276 = kk_main__mlift_lift_run_707_10049(x_4_10061, l_2, r_2, state_2, v_3, wild___1_120, _ctx); /*int*/
  return kk_integer_box(_x_x276, _ctx);
}


// lift anonymous function
struct kk_main__lift_run_707_fun279__t {
  struct kk_function_s _base;
  kk_integer_t v_3;
};
static kk_box_t kk_main__lift_run_707_fun279(kk_function_t _fself, kk_box_t _b_x104, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_707_fun279(kk_integer_t v_3, kk_context_t* _ctx) {
  struct kk_main__lift_run_707_fun279__t* _self = kk_function_alloc_as(struct kk_main__lift_run_707_fun279__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__lift_run_707_fun279, kk_context());
  _self->v_3 = v_3;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__lift_run_707_fun279(kk_function_t _fself, kk_box_t _b_x104, kk_context_t* _ctx) {
  struct kk_main__lift_run_707_fun279__t* _self = kk_function_as(struct kk_main__lift_run_707_fun279__t*, _fself, _ctx);
  kk_integer_t v_3 = _self->v_3; /* int */
  kk_drop_match(_self, {kk_integer_dup(v_3, _ctx);}, {}, _ctx)
  kk_integer_t _y_x10036_1_121 = kk_integer_unbox(_b_x104, _ctx); /*int*/;
  kk_integer_t _x_x280 = kk_main__mlift_lift_run_707_10048(v_3, _y_x10036_1_121, _ctx); /*int*/
  return kk_integer_box(_x_x280, _ctx);
}


// lift anonymous function
struct kk_main__lift_run_707_fun281__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_707_fun281(kk_function_t _fself, kk_box_t _b_x108, kk_box_t _b_x109, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_707_fun281(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_707_fun281, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__lift_run_707_fun281(kk_function_t _fself, kk_box_t _b_x108, kk_box_t _b_x109, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t x_2_0_122 = kk_integer_unbox(_b_x108, _ctx); /*int*/;
  kk_integer_t y_2_0_123 = kk_integer_unbox(_b_x109, _ctx); /*int*/;
  kk_integer_t y_4_10013_0 = kk_integer_mul((kk_integer_from_small(503)),y_2_0_123,kk_context()); /*int*/;
  kk_integer_t x_3_10010_0 = kk_integer_sub(x_2_0_122,y_4_10013_0,kk_context()); /*int*/;
  kk_integer_t _x_x282;
  kk_integer_t _x_x283;
  kk_integer_t _x_x284 = kk_integer_add_small_const(x_3_10010_0, 37, _ctx); /*int*/
  _x_x283 = kk_integer_abs(_x_x284,kk_context()); /*int*/
  _x_x282 = kk_integer_mod(_x_x283,(kk_integer_from_small(1009)),kk_context()); /*int*/
  return kk_integer_box(_x_x282, _ctx);
}

kk_integer_t kk_main__lift_run_707(kk_ref_t state_2, kk_main__tree t, kk_context_t* _ctx) { /* forall<h> (state : local-var<h,int>, t : tree) -> <local<h>,choose,div> int */ 
  if (kk_main__is_Leaf(t, _ctx)) {
    kk_box_t _x_x252 = kk_ref_get(state_2,kk_context()); /*1000*/
    return kk_integer_unbox(_x_x252, _ctx);
  }
  {
    struct kk_main_Node* _con_x253 = kk_main__as_Node(t, _ctx);
    kk_main__tree l_2 = _con_x253->left;
    kk_integer_t v_3 = _con_x253->value;
    kk_main__tree r_2 = _con_x253->right;
    if kk_likely(kk_datatype_ptr_is_unique(t, _ctx)) {
      kk_datatype_ptr_free(t, _ctx);
    }
    else {
      kk_main__tree_dup(l_2, _ctx);
      kk_main__tree_dup(r_2, _ctx);
      kk_integer_dup(v_3, _ctx);
      kk_datatype_ptr_decref(t, _ctx);
    }
    kk_std_core_hnd__ev ev_10064 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/choose>*/;
    bool x_4_10061;
    {
      struct kk_std_core_hnd_Ev* _con_x254 = kk_std_core_hnd__as_Ev(ev_10064, _ctx);
      kk_box_t _box_x64 = _con_x254->hnd;
      int32_t m = _con_x254->marker;
      kk_main__choose h = kk_main__choose_unbox(_box_x64, KK_BORROWED, _ctx);
      kk_main__choose_dup(h, _ctx);
      {
        struct kk_main__Hnd_choose* _con_x255 = kk_main__as_Hnd_choose(h, _ctx);
        kk_integer_t _pat_0_3 = _con_x255->_cfc;
        kk_std_core_hnd__clause0 _ctl_choose = _con_x255->_ctl_choose;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_integer_drop(_pat_0_3, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause0_dup(_ctl_choose, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x67 = _ctl_choose.clause;
          kk_function_t _bv_x73 = _fun_unbox_x67; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
          kk_box_t _x_x256 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x73, (_bv_x73, m, ev_10064, _ctx), _ctx); /*3004*/
          x_4_10061 = kk_bool_unbox(_x_x256); /*bool*/
        }
      }
    }
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x257 = kk_std_core_hnd_yield_extend(kk_main__new_lift_run_707_fun258(l_2, r_2, state_2, v_3, _ctx), _ctx); /*3003*/
      return kk_integer_unbox(_x_x257, _ctx);
    }
    {
      kk_integer_t x_5_10066;
      kk_box_t _x_x260;
      kk_ref_t _x_x261 = kk_ref_dup(state_2, _ctx); /*local-var<616,int>*/
      _x_x260 = kk_ref_get(_x_x261,kk_context()); /*1000*/
      x_5_10066 = kk_integer_unbox(_x_x260, _ctx); /*int*/
      if (kk_yielding(kk_context())) {
        kk_integer_drop(x_5_10066, _ctx);
        kk_box_t _x_x262 = kk_std_core_hnd_yield_extend(kk_main__new_lift_run_707_fun263(l_2, r_2, state_2, v_3, x_4_10061, _ctx), _ctx); /*3003*/
        return kk_integer_unbox(_x_x262, _ctx);
      }
      {
        kk_integer_t _b_x93_95;
        kk_box_t _x_x265;
        kk_box_t _x_x272;
        kk_integer_t _x_x273 = kk_integer_dup(v_3, _ctx); /*int*/
        _x_x272 = kk_integer_box(_x_x273, _ctx); /*1001*/
        _x_x265 = kk_std_core_hnd__open_none2(kk_main__new_lift_run_707_fun266(_ctx), kk_integer_box(x_5_10066, _ctx), _x_x272, _ctx); /*1002*/
        _b_x93_95 = kk_integer_unbox(_x_x265, _ctx); /*int*/
        kk_unit_t x_6_10069 = kk_Unit;
        kk_ref_set_borrow(state_2,(kk_integer_box(_b_x93_95, _ctx)),kk_context());
        if (kk_yielding(kk_context())) {
          kk_box_t _x_x274 = kk_std_core_hnd_yield_extend(kk_main__new_lift_run_707_fun275(l_2, r_2, state_2, v_3, x_4_10061, _ctx), _ctx); /*3003*/
          return kk_integer_unbox(_x_x274, _ctx);
        }
        {
          kk_integer_t x_8_10072;
          kk_main__tree _x_x277;
          if (x_4_10061) {
            kk_main__tree_drop(r_2, _ctx);
            _x_x277 = l_2; /*main/tree*/
          }
          else {
            kk_main__tree_drop(l_2, _ctx);
            _x_x277 = r_2; /*main/tree*/
          }
          x_8_10072 = kk_main__lift_run_707(state_2, _x_x277, _ctx); /*int*/
          kk_box_t _x_x278;
          if (kk_yielding(kk_context())) {
            kk_integer_drop(x_8_10072, _ctx);
            _x_x278 = kk_std_core_hnd_yield_extend(kk_main__new_lift_run_707_fun279(v_3, _ctx), _ctx); /*3003*/
          }
          else {
            _x_x278 = kk_std_core_hnd__open_none2(kk_main__new_lift_run_707_fun281(_ctx), kk_integer_box(v_3, _ctx), kk_integer_box(x_8_10072, _ctx), _ctx); /*3003*/
          }
          return kk_integer_unbox(_x_x278, _ctx);
        }
      }
    }
  }
}
 
// lifted local: run, loop


// lift anonymous function
struct kk_main__lift_run_708_fun289__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_708_fun289(kk_function_t _fself, int32_t _b_x137, kk_std_core_hnd__ev _b_x138, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_708_fun289(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_708_fun289, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main__lift_run_708_fun290__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_708_fun290(kk_function_t _fself, kk_function_t _b_x134, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_708_fun290(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_708_fun290, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main__lift_run_708_fun291__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_708_fun291(kk_function_t _fself, kk_box_t _b_x128, kk_function_t _b_x129, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_708_fun291(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_708_fun291, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_main__lift_run_708_fun292__t {
  struct kk_function_s _base;
  kk_function_t _b_x129;
};
static kk_std_core_types__list kk_main__lift_run_708_fun292(kk_function_t _fself, bool _b_x130, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_708_fun292(kk_function_t _b_x129, kk_context_t* _ctx) {
  struct kk_main__lift_run_708_fun292__t* _self = kk_function_alloc_as(struct kk_main__lift_run_708_fun292__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__lift_run_708_fun292, kk_context());
  _self->_b_x129 = _b_x129;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_core_types__list kk_main__lift_run_708_fun292(kk_function_t _fself, bool _b_x130, kk_context_t* _ctx) {
  struct kk_main__lift_run_708_fun292__t* _self = kk_function_as(struct kk_main__lift_run_708_fun292__t*, _fself, _ctx);
  kk_function_t _b_x129 = _self->_b_x129; /* (3004) -> 3005 3006 */
  kk_drop_match(_self, {kk_function_dup(_b_x129, _ctx);}, {}, _ctx)
  kk_box_t _x_x293 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x129, (_b_x129, kk_bool_box(_b_x130), _ctx), _ctx); /*3006*/
  return kk_std_core_types__list_unbox(_x_x293, KK_OWNED, _ctx);
}
static kk_box_t kk_main__lift_run_708_fun291(kk_function_t _fself, kk_box_t _b_x128, kk_function_t _b_x129, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_box_drop(_b_x128, _ctx);
  kk_function_t r_174 = kk_main__new_lift_run_708_fun292(_b_x129, _ctx); /*(bool) -> <div,local<616>> list<int>*/;
  kk_std_core_types__list xs_0_10017;
  kk_function_t _x_x294 = kk_function_dup(r_174, _ctx); /*(bool) -> <div,local<616>> list<int>*/
  xs_0_10017 = kk_function_call(kk_std_core_types__list, (kk_function_t, bool, kk_context_t*), _x_x294, (_x_x294, true, _ctx), _ctx); /*list<int>*/
  kk_std_core_types__list ys_10018 = kk_function_call(kk_std_core_types__list, (kk_function_t, bool, kk_context_t*), r_174, (r_174, false, _ctx), _ctx); /*list<int>*/;
  kk_std_core_types__list _x_x295 = kk_std_core_list_append(xs_0_10017, ys_10018, _ctx); /*list<3002>*/
  return kk_std_core_types__list_box(_x_x295, _ctx);
}
static kk_box_t kk_main__lift_run_708_fun290(kk_function_t _fself, kk_function_t _b_x134, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_hnd_protect(kk_unit_box(kk_Unit), kk_main__new_lift_run_708_fun291(_ctx), _b_x134, _ctx);
}
static kk_box_t kk_main__lift_run_708_fun289(kk_function_t _fself, int32_t _b_x137, kk_std_core_hnd__ev _b_x138, kk_context_t* _ctx) {
  kk_unused(_fself);
  int32_t m_176 = _b_x137; /*hnd/marker<<div,local<616>>,list<int>>*/;
  kk_std_core_hnd__ev ___wildcard_x730__16_177 = _b_x138; /*hnd/ev<main/choose>*/;
  kk_datatype_ptr_dropn(___wildcard_x730__16_177, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m_176, kk_main__new_lift_run_708_fun290(_ctx), _ctx);
}


// lift anonymous function
struct kk_main__lift_run_708_fun296__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_708_fun296(kk_function_t _fself, kk_box_t _b_x144, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_708_fun296(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_708_fun296, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__lift_run_708_fun296(kk_function_t _fself, kk_box_t _b_x144, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__list _x_x297 = kk_std_core_types__new_Cons(kk_reuse_null, 0, _b_x144, kk_std_core_types__new_Nil(_ctx), _ctx); /*list<1024>*/
  return kk_std_core_types__list_box(_x_x297, _ctx);
}


// lift anonymous function
struct kk_main__lift_run_708_fun299__t {
  struct kk_function_s _base;
  kk_function_t explore;
  kk_main__tree tree;
};
static kk_box_t kk_main__lift_run_708_fun299(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_708_fun299(kk_function_t explore, kk_main__tree tree, kk_context_t* _ctx) {
  struct kk_main__lift_run_708_fun299__t* _self = kk_function_alloc_as(struct kk_main__lift_run_708_fun299__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__lift_run_708_fun299, kk_context());
  _self->explore = explore;
  _self->tree = tree;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__lift_run_708_fun299(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main__lift_run_708_fun299__t* _self = kk_function_as(struct kk_main__lift_run_708_fun299__t*, _fself, _ctx);
  kk_function_t explore = _self->explore; /* (t : main/tree) -> <main/choose,div,local<616>> int */
  kk_main__tree tree = _self->tree; /* main/tree */
  kk_drop_match(_self, {kk_function_dup(explore, _ctx);kk_main__tree_dup(tree, _ctx);}, {}, _ctx)
  kk_integer_t _x_x300 = kk_function_call(kk_integer_t, (kk_function_t, kk_main__tree, kk_context_t*), explore, (explore, tree, _ctx), _ctx); /*int*/
  return kk_integer_box(_x_x300, _ctx);
}


// lift anonymous function
struct kk_main__lift_run_708_fun303__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__lift_run_708_fun303(kk_function_t _fself, kk_box_t _b_x163, kk_box_t _b_x164, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_run_708_fun303(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__lift_run_708_fun303, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__lift_run_708_fun303(kk_function_t _fself, kk_box_t _b_x163, kk_box_t _b_x164, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x304;
  kk_integer_t _x_x305 = kk_integer_unbox(_b_x163, _ctx); /*int*/
  kk_integer_t _x_x306 = kk_integer_unbox(_b_x164, _ctx); /*int*/
  _x_x304 = kk_std_core_int_max(_x_x305, _x_x306, _ctx); /*int*/
  return kk_integer_box(_x_x304, _ctx);
}

kk_integer_t kk_main__lift_run_708(kk_function_t explore, kk_ref_t state, kk_main__tree tree, kk_integer_t i, kk_context_t* _ctx) { /* forall<h> (explore : (t : tree) -> <choose,div,local<h>> int, state : local-var<h,int>, tree : tree, i : int) -> <div,local<h>> int */ 
  kk__tailcall: ;
  bool _match_x192 = kk_integer_eq_borrow(i,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x192) {
    kk_main__tree_drop(tree, _ctx);
    kk_integer_drop(i, _ctx);
    kk_function_drop(explore, _ctx);
    kk_box_t _x_x285 = kk_ref_get(state,kk_context()); /*1000*/
    return kk_integer_unbox(_x_x285, _ctx);
  }
  {
    kk_std_core_types__list xs_10015;
    kk_box_t _x_x286;
    kk_main__choose _x_x287;
    kk_std_core_hnd__clause0 _x_x288 = kk_std_core_hnd__new_Clause0(kk_main__new_lift_run_708_fun289(_ctx), _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
    _x_x287 = kk_main__new_Hnd_choose(kk_reuse_null, 0, kk_integer_from_small(3), _x_x288, _ctx); /*main/choose<5,6>*/
    kk_function_t _x_x298;
    kk_function_dup(explore, _ctx);
    kk_main__tree_dup(tree, _ctx);
    _x_x298 = kk_main__new_lift_run_708_fun299(explore, tree, _ctx); /*() -> <main/choose|167> 166*/
    _x_x286 = kk_main__handle_choose(_x_x287, kk_main__new_lift_run_708_fun296(_ctx), _x_x298, _ctx); /*168*/
    xs_10015 = kk_std_core_types__list_unbox(_x_x286, KK_OWNED, _ctx); /*list<int>*/
    kk_integer_t _b_x166_168;
    if (kk_std_core_types__is_Nil(xs_10015, _ctx)) {
      kk_std_core_types__optional _match_x193 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
      if (kk_std_core_types__is_Optional(_match_x193, _ctx)) {
        kk_box_t _box_x158 = _match_x193._cons._Optional.value;
        kk_integer_t _uniq_default_3236 = kk_integer_unbox(_box_x158, _ctx);
        kk_integer_dup(_uniq_default_3236, _ctx);
        kk_std_core_types__optional_drop(_match_x193, _ctx);
        _b_x166_168 = _uniq_default_3236; /*int*/
      }
      else {
        kk_std_core_types__optional_drop(_match_x193, _ctx);
        _b_x166_168 = kk_integer_from_small(0); /*int*/
      }
    }
    else {
      struct kk_std_core_types_Cons* _con_x301 = kk_std_core_types__as_Cons(xs_10015, _ctx);
      kk_box_t _box_x159 = _con_x301->head;
      kk_std_core_types__list xx = _con_x301->tail;
      kk_integer_t x = kk_integer_unbox(_box_x159, _ctx);
      if kk_likely(kk_datatype_ptr_is_unique(xs_10015, _ctx)) {
        kk_datatype_ptr_free(xs_10015, _ctx);
      }
      else {
        kk_integer_dup(x, _ctx);
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(xs_10015, _ctx);
      }
      kk_box_t _x_x302 = kk_std_core_list_foldl(xx, kk_integer_box(x, _ctx), kk_main__new_lift_run_708_fun303(_ctx), _ctx); /*1002*/
      _b_x166_168 = kk_integer_unbox(_x_x302, _ctx); /*int*/
    }
    kk_unit_t ___0 = kk_Unit;
    kk_ref_set_borrow(state,(kk_integer_box(_b_x166_168, _ctx)),kk_context());
    kk_integer_t i_0_10019 = kk_integer_add_small_const(i, -1, _ctx); /*int*/;
    { // tailcall
      i = i_0_10019;
      goto kk__tailcall;
    }
  }
}


// lift anonymous function
struct kk_main_run_fun308__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_integer_t kk_main_run_fun308(kk_function_t _fself, kk_main__tree t, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun308(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_run_fun308__t* _self = kk_function_alloc_as(struct kk_main_run_fun308__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun308, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_run_fun308(kk_function_t _fself, kk_main__tree t, kk_context_t* _ctx) {
  struct kk_main_run_fun308__t* _self = kk_function_as(struct kk_main_run_fun308__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<616,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  return kk_main__lift_run_707(loc, t, _ctx);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  kk_main__tree tree = kk_main_make(n, _ctx); /*main/tree*/;
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<616,int>*/;
  kk_integer_t res;
  kk_function_t _x_x307;
  kk_ref_dup(loc, _ctx);
  _x_x307 = kk_main_new_run_fun308(loc, _ctx); /*(t : main/tree) -> <local<616>,main/choose,div> int*/
  kk_ref_t _x_x309 = kk_ref_dup(loc, _ctx); /*local-var<616,int>*/
  res = kk_main__lift_run_708(_x_x307, _x_x309, tree, kk_integer_from_small(10), _ctx); /*int*/
  kk_box_t _x_x310 = kk_std_core_hnd_prompt_local_var(loc, kk_integer_box(res, _ctx), _ctx); /*3004*/
  return kk_integer_unbox(_x_x310, _ctx);
}


// lift anonymous function
struct kk_main_main_fun316__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_integer_t kk_main_main_fun316(kk_function_t _fself, kk_main__tree t, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun316(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_main_fun316__t* _self = kk_function_alloc_as(struct kk_main_main_fun316__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_main_fun316, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_integer_t kk_main_main_fun316(kk_function_t _fself, kk_main__tree t, kk_context_t* _ctx) {
  struct kk_main_main_fun316__t* _self = kk_function_as(struct kk_main_main_fun316__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<616,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  return kk_main__lift_run_707(loc, t, _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10025 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10023;
  kk_string_t _x_x311;
  if (kk_std_core_types__is_Cons(xs_10025, _ctx)) {
    struct kk_std_core_types_Cons* _con_x312 = kk_std_core_types__as_Cons(xs_10025, _ctx);
    kk_box_t _box_x184 = _con_x312->head;
    kk_std_core_types__list _pat_0_0 = _con_x312->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x184);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10025, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10025, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10025, _ctx);
    }
    _x_x311 = x_0; /*string*/
  }
  else {
    _x_x311 = kk_string_empty(); /*string*/
  }
  m_10023 = kk_std_core_int_parse_int(_x_x311, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_main__tree tree;
  kk_integer_t _x_x314;
  if (kk_std_core_types__is_Nothing(m_10023, _ctx)) {
    _x_x314 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x185 = m_10023._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x185, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10023, _ctx);
    _x_x314 = x; /*int*/
  }
  tree = kk_main_make(_x_x314, _ctx); /*main/tree*/
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<616,int>*/;
  kk_integer_t res;
  kk_function_t _x_x315;
  kk_ref_dup(loc, _ctx);
  _x_x315 = kk_main_new_main_fun316(loc, _ctx); /*(t : main/tree) -> <local<616>,main/choose,div> int*/
  kk_ref_t _x_x317 = kk_ref_dup(loc, _ctx); /*local-var<616,int>*/
  res = kk_main__lift_run_708(_x_x315, _x_x317, tree, kk_integer_from_small(10), _ctx); /*int*/
  kk_integer_t r;
  kk_box_t _x_x318 = kk_std_core_hnd_prompt_local_var(loc, kk_integer_box(res, _ctx), _ctx); /*3004*/
  r = kk_integer_unbox(_x_x318, _ctx); /*int*/
  kk_string_t _x_x319 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x319, _ctx); return kk_Unit;
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
  kk_std_text_parse__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
  {
    kk_string_t _x_x211;
    kk_define_string_literal(, _s_x212, 11, "choose@main", _ctx)
    _x_x211 = kk_string_dup(_s_x212, _ctx); /*string*/
    kk_main__tag_choose = kk_std_core_hnd__new_Htag(_x_x211, _ctx); /*hnd/htag<main/choose>*/
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
  kk_std_core_hnd__htag_drop(kk_main__tag_choose, _ctx);
  kk_std_text_parse__done(_ctx);
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
