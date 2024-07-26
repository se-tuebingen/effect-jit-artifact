// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:emit`

kk_std_core_hnd__htag kk_main__tag_emit;
 
// handler for the effect `:emit`

kk_box_t kk_main__handle_emit(kk_main__emit hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : emit<e,b>, ret : (res : a) -> e b, action : () -> <emit|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x153 = kk_std_core_hnd__htag_dup(kk_main__tag_emit, _ctx); /*hnd/htag<main/emit>*/
  return kk_std_core_hnd__hhandle(_x_x153, kk_main__emit_box(hnd, _ctx), ret, action, _ctx);
}


// lift anonymous function
struct kk_main_counting_fun161__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_counting_fun161(kk_function_t _fself, kk_box_t _b_x31, kk_context_t* _ctx);
static kk_function_t kk_main_new_counting_fun161(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_counting_fun161__t* _self = kk_function_alloc_as(struct kk_main_counting_fun161__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_counting_fun161, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_counting_fun164__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_unit_t kk_main_counting_fun164(kk_function_t _fself, kk_integer_t _y_x10020, kk_context_t* _ctx);
static kk_function_t kk_main_new_counting_fun164(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_counting_fun164__t* _self = kk_function_alloc_as(struct kk_main_counting_fun164__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_counting_fun164, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_unit_t kk_main_counting_fun164(kk_function_t _fself, kk_integer_t _y_x10020, kk_context_t* _ctx) {
  struct kk_main_counting_fun164__t* _self = kk_function_as(struct kk_main_counting_fun164__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<472,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_integer_t _b_x25_27;
  kk_integer_t _x_x165 = kk_integer_add_small_const(_y_x10020, 1, _ctx); /*int*/
  _b_x25_27 = kk_integer_mod(_x_x165,(kk_integer_from_small(1009)),kk_context()); /*int*/
  kk_unit_t _brw_x144 = kk_Unit;
  kk_ref_set_borrow(loc,(kk_integer_box(_b_x25_27, _ctx)),kk_context());
  kk_ref_drop(loc, _ctx);
  return _brw_x144;
}


// lift anonymous function
struct kk_main_counting_fun168__t {
  struct kk_function_s _base;
  kk_function_t next_10067;
};
static kk_box_t kk_main_counting_fun168(kk_function_t _fself, kk_box_t _b_x29, kk_context_t* _ctx);
static kk_function_t kk_main_new_counting_fun168(kk_function_t next_10067, kk_context_t* _ctx) {
  struct kk_main_counting_fun168__t* _self = kk_function_alloc_as(struct kk_main_counting_fun168__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_counting_fun168, kk_context());
  _self->next_10067 = next_10067;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_counting_fun168(kk_function_t _fself, kk_box_t _b_x29, kk_context_t* _ctx) {
  struct kk_main_counting_fun168__t* _self = kk_function_as(struct kk_main_counting_fun168__t*, _fself, _ctx);
  kk_function_t next_10067 = _self->next_10067; /* (int) -> <local<472>|223> () */
  kk_drop_match(_self, {kk_function_dup(next_10067, _ctx);}, {}, _ctx)
  kk_unit_t _x_x169 = kk_Unit;
  kk_integer_t _x_x170 = kk_integer_unbox(_b_x29, _ctx); /*int*/
  kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10067, (next_10067, _x_x170, _ctx), _ctx);
  return kk_unit_box(_x_x169);
}
static kk_box_t kk_main_counting_fun161(kk_function_t _fself, kk_box_t _b_x31, kk_context_t* _ctx) {
  struct kk_main_counting_fun161__t* _self = kk_function_as(struct kk_main_counting_fun161__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<472,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x31, _ctx);
  kk_integer_t x_10066;
  kk_box_t _x_x162;
  kk_ref_t _x_x163 = kk_ref_dup(loc, _ctx); /*local-var<472,int>*/
  _x_x162 = kk_ref_get(_x_x163,kk_context()); /*1000*/
  x_10066 = kk_integer_unbox(_x_x162, _ctx); /*int*/
  kk_function_t next_10067 = kk_main_new_counting_fun164(loc, _ctx); /*(int) -> <local<472>|223> ()*/;
  kk_unit_t _x_x166 = kk_Unit;
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10066, _ctx);
    kk_box_t _x_x167 = kk_std_core_hnd_yield_extend(kk_main_new_counting_fun168(next_10067, _ctx), _ctx); /*3003*/
    kk_unit_unbox(_x_x167);
  }
  else {
    kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10067, (next_10067, x_10066, _ctx), _ctx);
  }
  return kk_unit_box(_x_x166);
}


// lift anonymous function
struct kk_main_counting_fun173__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_counting_fun173(kk_function_t _fself, kk_box_t _b_x36, kk_context_t* _ctx);
static kk_function_t kk_main_new_counting_fun173(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_counting_fun173__t* _self = kk_function_alloc_as(struct kk_main_counting_fun173__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_counting_fun173, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_counting_fun173(kk_function_t _fself, kk_box_t _b_x36, kk_context_t* _ctx) {
  struct kk_main_counting_fun173__t* _self = kk_function_as(struct kk_main_counting_fun173__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<472,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x36, _ctx);
  return kk_ref_get(loc,kk_context());
}

kk_integer_t kk_main_counting(kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (action : () -> <emit|e> a) -> e int */ 
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<472,int>*/;
  kk_main__emit _b_x33_37;
  kk_std_core_hnd__clause1 _x_x159;
  kk_function_t _x_x160;
  kk_ref_dup(loc, _ctx);
  _x_x160 = kk_main_new_counting_fun161(loc, _ctx); /*(1003) -> 1000 1004*/
  _x_x159 = kk_std_core_hnd_clause_tail1(_x_x160, _ctx); /*hnd/clause1<1003,1004,1002,1000,1001>*/
  _b_x33_37 = kk_main__new_Hnd_emit(kk_reuse_null, 0, kk_integer_from_small(1), _x_x159, _ctx); /*main/emit<<local<472>|223>,int>*/
  kk_integer_t res;
  kk_box_t _x_x171;
  kk_function_t _x_x172;
  kk_ref_dup(loc, _ctx);
  _x_x172 = kk_main_new_counting_fun173(loc, _ctx); /*(142) -> 143 1000*/
  _x_x171 = kk_main__handle_emit(_b_x33_37, _x_x172, action, _ctx); /*144*/
  res = kk_integer_unbox(_x_x171, _ctx); /*int*/
  kk_box_t _x_x174 = kk_std_core_hnd_prompt_local_var(loc, kk_integer_box(res, _ctx), _ctx); /*3004*/
  return kk_integer_unbox(_x_x174, _ctx);
}
 
// monadic lift

kk_unit_t kk_main__mlift_lift_generator_1196_10057(kk_integer_t i, kk_integer_t n, kk_unit_t wild__, kk_context_t* _ctx) { /* (i : int, n : int, wild_ : ()) -> emit () */ 
  kk_integer_t i_0_10002 = kk_integer_add_small_const(i, 1, _ctx); /*int*/;
  kk_main__lift_generator_1196(n, i_0_10002, _ctx); return kk_Unit;
}
 
// lifted local: generator, go


// lift anonymous function
struct kk_main__lift_generator_1196_fun181__t {
  struct kk_function_s _base;
  kk_integer_t i_0;
  kk_integer_t n_0;
};
static kk_box_t kk_main__lift_generator_1196_fun181(kk_function_t _fself, kk_box_t _b_x58, kk_context_t* _ctx);
static kk_function_t kk_main__new_lift_generator_1196_fun181(kk_integer_t i_0, kk_integer_t n_0, kk_context_t* _ctx) {
  struct kk_main__lift_generator_1196_fun181__t* _self = kk_function_alloc_as(struct kk_main__lift_generator_1196_fun181__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__lift_generator_1196_fun181, kk_context());
  _self->i_0 = i_0;
  _self->n_0 = n_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__lift_generator_1196_fun181(kk_function_t _fself, kk_box_t _b_x58, kk_context_t* _ctx) {
  struct kk_main__lift_generator_1196_fun181__t* _self = kk_function_as(struct kk_main__lift_generator_1196_fun181__t*, _fself, _ctx);
  kk_integer_t i_0 = _self->i_0; /* int */
  kk_integer_t n_0 = _self->n_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(i_0, _ctx);kk_integer_dup(n_0, _ctx);}, {}, _ctx)
  kk_unit_t wild___0_60 = kk_Unit;
  kk_unit_unbox(_b_x58);
  kk_unit_t _x_x182 = kk_Unit;
  kk_main__mlift_lift_generator_1196_10057(i_0, n_0, wild___0_60, _ctx);
  return kk_unit_box(_x_x182);
}

kk_unit_t kk_main__lift_generator_1196(kk_integer_t n_0, kk_integer_t i_0, kk_context_t* _ctx) { /* (n : int, i : int) -> <emit,div> () */ 
  kk__tailcall: ;
  bool _match_x141 = kk_integer_gt_borrow(i_0,n_0,kk_context()); /*bool*/;
  if (_match_x141) {
    kk_integer_drop(n_0, _ctx);
    kk_integer_drop(i_0, _ctx);
    kk_Unit; return kk_Unit;
  }
  {
    kk_std_core_hnd__ev ev_10074 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/emit>*/;
    kk_unit_t x_10071 = kk_Unit;
    kk_box_t _x_x175;
    {
      struct kk_std_core_hnd_Ev* _con_x176 = kk_std_core_hnd__as_Ev(ev_10074, _ctx);
      kk_box_t _box_x49 = _con_x176->hnd;
      int32_t m = _con_x176->marker;
      kk_main__emit h = kk_main__emit_unbox(_box_x49, KK_BORROWED, _ctx);
      kk_main__emit_dup(h, _ctx);
      {
        struct kk_main__Hnd_emit* _con_x177 = kk_main__as_Hnd_emit(h, _ctx);
        kk_integer_t _pat_0_0 = _con_x177->_cfc;
        kk_std_core_hnd__clause1 _fun_emit = _con_x177->_fun_emit;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_integer_drop(_pat_0_0, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_fun_emit, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x53 = _fun_emit.clause;
          kk_box_t _x_x178;
          kk_integer_t _x_x179 = kk_integer_dup(i_0, _ctx); /*int*/
          _x_x178 = kk_integer_box(_x_x179, _ctx); /*1009*/
          _x_x175 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x53, (_fun_unbox_x53, m, ev_10074, _x_x178, _ctx), _ctx); /*1010*/
        }
      }
    }
    kk_unit_unbox(_x_x175);
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x180 = kk_std_core_hnd_yield_extend(kk_main__new_lift_generator_1196_fun181(i_0, n_0, _ctx), _ctx); /*3003*/
      kk_unit_unbox(_x_x180); return kk_Unit;
    }
    {
      kk_integer_t i_0_10002_0 = kk_integer_add_small_const(i_0, 1, _ctx); /*int*/;
      { // tailcall
        i_0 = i_0_10002_0;
        goto kk__tailcall;
      }
    }
  }
}
 
// monadic lift

kk_unit_t kk_main__mlift_sq__summing_10058(kk_integer_t i, kk_ref_t res, kk_integer_t _y_x10031, kk_context_t* _ctx) { /* forall<e,h> (i : int, res : local-var<h,int>, int) -> <local<h>|e> () */ 
  kk_integer_t y_10053;
  kk_integer_t _x_x183 = kk_integer_dup(i, _ctx); /*int*/
  y_10053 = kk_integer_mul(_x_x183,i,kk_context()); /*int*/
  kk_integer_t _b_x62_64;
  kk_integer_t _x_x184 = kk_integer_add(_y_x10031,y_10053,kk_context()); /*int*/
  _b_x62_64 = kk_integer_mod(_x_x184,(kk_integer_from_small(1009)),kk_context()); /*int*/
  kk_unit_t _brw_x140 = kk_Unit;
  kk_ref_set_borrow(res,(kk_integer_box(_b_x62_64, _ctx)),kk_context());
  kk_ref_drop(res, _ctx);
  _brw_x140; return kk_Unit;
}


// lift anonymous function
struct kk_main_sq__summing_fun187__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_sq__summing_fun187(kk_function_t _fself, kk_box_t _b_x76, kk_context_t* _ctx);
static kk_function_t kk_main_new_sq__summing_fun187(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_sq__summing_fun187__t* _self = kk_function_alloc_as(struct kk_main_sq__summing_fun187__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_sq__summing_fun187, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_sq__summing_fun190__t {
  struct kk_function_s _base;
  kk_box_t _b_x76;
  kk_ref_t loc;
};
static kk_unit_t kk_main_sq__summing_fun190(kk_function_t _fself, kk_integer_t _y_x10031, kk_context_t* _ctx);
static kk_function_t kk_main_new_sq__summing_fun190(kk_box_t _b_x76, kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_sq__summing_fun190__t* _self = kk_function_alloc_as(struct kk_main_sq__summing_fun190__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_sq__summing_fun190, kk_context());
  _self->_b_x76 = _b_x76;
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_unit_t kk_main_sq__summing_fun190(kk_function_t _fself, kk_integer_t _y_x10031, kk_context_t* _ctx) {
  struct kk_main_sq__summing_fun190__t* _self = kk_function_as(struct kk_main_sq__summing_fun190__t*, _fself, _ctx);
  kk_box_t _b_x76 = _self->_b_x76; /* 1003 */
  kk_ref_t loc = _self->loc; /* local-var<779,int> */
  kk_drop_match(_self, {kk_box_dup(_b_x76, _ctx);kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_integer_t y_10053;
  kk_integer_t _x_x191;
  kk_box_t _x_x192 = kk_box_dup(_b_x76, _ctx); /*1003*/
  _x_x191 = kk_integer_unbox(_x_x192, _ctx); /*int*/
  kk_integer_t _x_x193 = kk_integer_unbox(_b_x76, _ctx); /*int*/
  y_10053 = kk_integer_mul(_x_x191,_x_x193,kk_context()); /*int*/
  kk_integer_t _b_x70_72;
  kk_integer_t _x_x194 = kk_integer_add(_y_x10031,y_10053,kk_context()); /*int*/
  _b_x70_72 = kk_integer_mod(_x_x194,(kk_integer_from_small(1009)),kk_context()); /*int*/
  kk_unit_t _brw_x139 = kk_Unit;
  kk_ref_set_borrow(loc,(kk_integer_box(_b_x70_72, _ctx)),kk_context());
  kk_ref_drop(loc, _ctx);
  return _brw_x139;
}


// lift anonymous function
struct kk_main_sq__summing_fun197__t {
  struct kk_function_s _base;
  kk_function_t next_10080;
};
static kk_box_t kk_main_sq__summing_fun197(kk_function_t _fself, kk_box_t _b_x74, kk_context_t* _ctx);
static kk_function_t kk_main_new_sq__summing_fun197(kk_function_t next_10080, kk_context_t* _ctx) {
  struct kk_main_sq__summing_fun197__t* _self = kk_function_alloc_as(struct kk_main_sq__summing_fun197__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_sq__summing_fun197, kk_context());
  _self->next_10080 = next_10080;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_sq__summing_fun197(kk_function_t _fself, kk_box_t _b_x74, kk_context_t* _ctx) {
  struct kk_main_sq__summing_fun197__t* _self = kk_function_as(struct kk_main_sq__summing_fun197__t*, _fself, _ctx);
  kk_function_t next_10080 = _self->next_10080; /* (int) -> <local<779>|522> () */
  kk_drop_match(_self, {kk_function_dup(next_10080, _ctx);}, {}, _ctx)
  kk_unit_t _x_x198 = kk_Unit;
  kk_integer_t _x_x199 = kk_integer_unbox(_b_x74, _ctx); /*int*/
  kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10080, (next_10080, _x_x199, _ctx), _ctx);
  return kk_unit_box(_x_x198);
}
static kk_box_t kk_main_sq__summing_fun187(kk_function_t _fself, kk_box_t _b_x76, kk_context_t* _ctx) {
  struct kk_main_sq__summing_fun187__t* _self = kk_function_as(struct kk_main_sq__summing_fun187__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<779,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_integer_t x_10079;
  kk_box_t _x_x188;
  kk_ref_t _x_x189 = kk_ref_dup(loc, _ctx); /*local-var<779,int>*/
  _x_x188 = kk_ref_get(_x_x189,kk_context()); /*1000*/
  x_10079 = kk_integer_unbox(_x_x188, _ctx); /*int*/
  kk_function_t next_10080 = kk_main_new_sq__summing_fun190(_b_x76, loc, _ctx); /*(int) -> <local<779>|522> ()*/;
  kk_unit_t _x_x195 = kk_Unit;
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10079, _ctx);
    kk_box_t _x_x196 = kk_std_core_hnd_yield_extend(kk_main_new_sq__summing_fun197(next_10080, _ctx), _ctx); /*3003*/
    kk_unit_unbox(_x_x196);
  }
  else {
    kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10080, (next_10080, x_10079, _ctx), _ctx);
  }
  return kk_unit_box(_x_x195);
}


// lift anonymous function
struct kk_main_sq__summing_fun202__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_sq__summing_fun202(kk_function_t _fself, kk_box_t _b_x81, kk_context_t* _ctx);
static kk_function_t kk_main_new_sq__summing_fun202(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_sq__summing_fun202__t* _self = kk_function_alloc_as(struct kk_main_sq__summing_fun202__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_sq__summing_fun202, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_sq__summing_fun202(kk_function_t _fself, kk_box_t _b_x81, kk_context_t* _ctx) {
  struct kk_main_sq__summing_fun202__t* _self = kk_function_as(struct kk_main_sq__summing_fun202__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<779,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x81, _ctx);
  return kk_ref_get(loc,kk_context());
}

kk_integer_t kk_main_sq__summing(kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (action : () -> <emit|e> a) -> e int */ 
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<779,int>*/;
  kk_main__emit _b_x78_82;
  kk_std_core_hnd__clause1 _x_x185;
  kk_function_t _x_x186;
  kk_ref_dup(loc, _ctx);
  _x_x186 = kk_main_new_sq__summing_fun187(loc, _ctx); /*(1003) -> 1000 1004*/
  _x_x185 = kk_std_core_hnd_clause_tail1(_x_x186, _ctx); /*hnd/clause1<1003,1004,1002,1000,1001>*/
  _b_x78_82 = kk_main__new_Hnd_emit(kk_reuse_null, 0, kk_integer_from_small(1), _x_x185, _ctx); /*main/emit<<local<779>|522>,int>*/
  kk_integer_t res;
  kk_box_t _x_x200;
  kk_function_t _x_x201;
  kk_ref_dup(loc, _ctx);
  _x_x201 = kk_main_new_sq__summing_fun202(loc, _ctx); /*(142) -> 143 1000*/
  _x_x200 = kk_main__handle_emit(_b_x78_82, _x_x201, action, _ctx); /*144*/
  res = kk_integer_unbox(_x_x200, _ctx); /*int*/
  kk_box_t _x_x203 = kk_std_core_hnd_prompt_local_var(loc, kk_integer_box(res, _ctx), _ctx); /*3004*/
  return kk_integer_unbox(_x_x203, _ctx);
}


// lift anonymous function
struct kk_main_summing_fun207__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_summing_fun207(kk_function_t _fself, kk_box_t _b_x109, kk_context_t* _ctx);
static kk_function_t kk_main_new_summing_fun207(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_summing_fun207__t* _self = kk_function_alloc_as(struct kk_main_summing_fun207__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_summing_fun207, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_summing_fun210__t {
  struct kk_function_s _base;
  kk_box_t _b_x109;
  kk_ref_t loc;
};
static kk_unit_t kk_main_summing_fun210(kk_function_t _fself, kk_integer_t _y_x10038, kk_context_t* _ctx);
static kk_function_t kk_main_new_summing_fun210(kk_box_t _b_x109, kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_summing_fun210__t* _self = kk_function_alloc_as(struct kk_main_summing_fun210__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_summing_fun210, kk_context());
  _self->_b_x109 = _b_x109;
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_unit_t kk_main_summing_fun210(kk_function_t _fself, kk_integer_t _y_x10038, kk_context_t* _ctx) {
  struct kk_main_summing_fun210__t* _self = kk_function_as(struct kk_main_summing_fun210__t*, _fself, _ctx);
  kk_box_t _b_x109 = _self->_b_x109; /* 3030 */
  kk_ref_t loc = _self->loc; /* local-var<1037,int> */
  kk_drop_match(_self, {kk_box_dup(_b_x109, _ctx);kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_integer_t _b_x103_105;
  kk_integer_t _x_x211;
  kk_integer_t _x_x212 = kk_integer_unbox(_b_x109, _ctx); /*int*/
  _x_x211 = kk_integer_add(_y_x10038,_x_x212,kk_context()); /*int*/
  _b_x103_105 = kk_integer_mod(_x_x211,(kk_integer_from_small(1009)),kk_context()); /*int*/
  kk_unit_t _brw_x136 = kk_Unit;
  kk_ref_set_borrow(loc,(kk_integer_box(_b_x103_105, _ctx)),kk_context());
  kk_ref_drop(loc, _ctx);
  return _brw_x136;
}


// lift anonymous function
struct kk_main_summing_fun215__t {
  struct kk_function_s _base;
  kk_function_t next_10088;
};
static kk_box_t kk_main_summing_fun215(kk_function_t _fself, kk_box_t _b_x107, kk_context_t* _ctx);
static kk_function_t kk_main_new_summing_fun215(kk_function_t next_10088, kk_context_t* _ctx) {
  struct kk_main_summing_fun215__t* _self = kk_function_alloc_as(struct kk_main_summing_fun215__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_summing_fun215, kk_context());
  _self->next_10088 = next_10088;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_summing_fun215(kk_function_t _fself, kk_box_t _b_x107, kk_context_t* _ctx) {
  struct kk_main_summing_fun215__t* _self = kk_function_as(struct kk_main_summing_fun215__t*, _fself, _ctx);
  kk_function_t next_10088 = _self->next_10088; /* (int) -> <local<1037>|788> () */
  kk_drop_match(_self, {kk_function_dup(next_10088, _ctx);}, {}, _ctx)
  kk_unit_t _x_x216 = kk_Unit;
  kk_integer_t _x_x217 = kk_integer_unbox(_b_x107, _ctx); /*int*/
  kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10088, (next_10088, _x_x217, _ctx), _ctx);
  return kk_unit_box(_x_x216);
}
static kk_box_t kk_main_summing_fun207(kk_function_t _fself, kk_box_t _b_x109, kk_context_t* _ctx) {
  struct kk_main_summing_fun207__t* _self = kk_function_as(struct kk_main_summing_fun207__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<1037,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_integer_t x_10087;
  kk_box_t _x_x208;
  kk_ref_t _x_x209 = kk_ref_dup(loc, _ctx); /*local-var<1037,int>*/
  _x_x208 = kk_ref_get(_x_x209,kk_context()); /*3004*/
  x_10087 = kk_integer_unbox(_x_x208, _ctx); /*int*/
  kk_function_t next_10088 = kk_main_new_summing_fun210(_b_x109, loc, _ctx); /*(int) -> <local<1037>|788> ()*/;
  kk_unit_t _x_x213 = kk_Unit;
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10087, _ctx);
    kk_box_t _x_x214 = kk_std_core_hnd_yield_extend(kk_main_new_summing_fun215(next_10088, _ctx), _ctx); /*3038*/
    kk_unit_unbox(_x_x214);
  }
  else {
    kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10088, (next_10088, x_10087, _ctx), _ctx);
  }
  return kk_unit_box(_x_x213);
}


// lift anonymous function
struct kk_main_summing_fun220__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_summing_fun220(kk_function_t _fself, kk_box_t _b_x114, kk_context_t* _ctx);
static kk_function_t kk_main_new_summing_fun220(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_summing_fun220__t* _self = kk_function_alloc_as(struct kk_main_summing_fun220__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_summing_fun220, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_summing_fun220(kk_function_t _fself, kk_box_t _b_x114, kk_context_t* _ctx) {
  struct kk_main_summing_fun220__t* _self = kk_function_as(struct kk_main_summing_fun220__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<1037,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x114, _ctx);
  return kk_ref_get(loc,kk_context());
}

kk_integer_t kk_main_summing(kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (action : () -> <emit|e> a) -> e int */ 
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<1037,int>*/;
  kk_main__emit _b_x111_115;
  kk_std_core_hnd__clause1 _x_x205;
  kk_function_t _x_x206;
  kk_ref_dup(loc, _ctx);
  _x_x206 = kk_main_new_summing_fun207(loc, _ctx); /*(3030) -> 3027 3031*/
  _x_x205 = kk_std_core_hnd_clause_tail1(_x_x206, _ctx); /*hnd/clause1<3030,3031,3029,3027,3028>*/
  _b_x111_115 = kk_main__new_Hnd_emit(kk_reuse_null, 0, kk_integer_from_small(1), _x_x205, _ctx); /*main/emit<<local<1037>|788>,int>*/
  kk_integer_t res;
  kk_box_t _x_x218;
  kk_function_t _x_x219;
  kk_ref_dup(loc, _ctx);
  _x_x219 = kk_main_new_summing_fun220(loc, _ctx); /*(142) -> 143 3019*/
  _x_x218 = kk_main__handle_emit(_b_x111_115, _x_x219, action, _ctx); /*144*/
  res = kk_integer_unbox(_x_x218, _ctx); /*int*/
  kk_box_t _x_x221 = kk_std_core_hnd_prompt_local_var(loc, kk_integer_box(res, _ctx), _ctx); /*3038*/
  return kk_integer_unbox(_x_x221, _ctx);
}


// lift anonymous function
struct kk_main_run_fun223__t {
  struct kk_function_s _base;
  kk_integer_t n;
};
static kk_box_t kk_main_run_fun223(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun223(kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun223__t* _self = kk_function_alloc_as(struct kk_main_run_fun223__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun223, kk_context());
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun223(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun223__t* _self = kk_function_as(struct kk_main_run_fun223__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_unit_t _x_x224 = kk_Unit;
  kk_main__lift_generator_1196(n, kk_integer_from_small(0), _ctx);
  return kk_unit_box(_x_x224);
}


// lift anonymous function
struct kk_main_run_fun226__t {
  struct kk_function_s _base;
  kk_integer_t n;
};
static kk_box_t kk_main_run_fun226(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun226(kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun226__t* _self = kk_function_alloc_as(struct kk_main_run_fun226__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun226, kk_context());
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun226(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun226__t* _self = kk_function_as(struct kk_main_run_fun226__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_unit_t _x_x227 = kk_Unit;
  kk_main__lift_generator_1196(n, kk_integer_from_small(0), _ctx);
  return kk_unit_box(_x_x227);
}


// lift anonymous function
struct kk_main_run_fun228__t {
  struct kk_function_s _base;
  kk_integer_t n;
};
static kk_box_t kk_main_run_fun228(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun228(kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun228__t* _self = kk_function_alloc_as(struct kk_main_run_fun228__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun228, kk_context());
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun228(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun228__t* _self = kk_function_as(struct kk_main_run_fun228__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_unit_t _x_x229 = kk_Unit;
  kk_main__lift_generator_1196(n, kk_integer_from_small(0), _ctx);
  return kk_unit_box(_x_x229);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  kk_integer_t sqs;
  kk_function_t _x_x222;
  kk_integer_dup(n, _ctx);
  _x_x222 = kk_main_new_run_fun223(n, _ctx); /*() -> <main/emit|2302> 2349*/
  sqs = kk_main_sq__summing(_x_x222, _ctx); /*int*/
  kk_integer_t s;
  kk_function_t _x_x225;
  kk_integer_dup(n, _ctx);
  _x_x225 = kk_main_new_run_fun226(n, _ctx); /*() -> <main/emit|2826> 2873*/
  s = kk_main_summing(_x_x225, _ctx); /*int*/
  kk_integer_t c = kk_main_counting(kk_main_new_run_fun228(n, _ctx), _ctx); /*int*/;
  kk_integer_t x_0_10010 = kk_integer_mul(sqs,(kk_integer_from_small(1009)),kk_context()); /*int*/;
  kk_integer_t y_0_10011 = kk_integer_mul(s,(kk_integer_from_small(103)),kk_context()); /*int*/;
  kk_integer_t x_10008 = kk_integer_add(x_0_10010,y_0_10011,kk_context()); /*int*/;
  return kk_integer_add(x_10008,c,kk_context());
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10014 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10012;
  kk_string_t _x_x230;
  if (kk_std_core_types__is_Cons(xs_10014, _ctx)) {
    struct kk_std_core_types_Cons* _con_x231 = kk_std_core_types__as_Cons(xs_10014, _ctx);
    kk_box_t _box_x133 = _con_x231->head;
    kk_std_core_types__list _pat_0_0 = _con_x231->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x133);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10014, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10014, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10014, _ctx);
    }
    _x_x230 = x_0; /*string*/
  }
  else {
    _x_x230 = kk_string_empty(); /*string*/
  }
  m_10012 = kk_std_core_int_parse_int(_x_x230, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_integer_t _x_x233;
  if (kk_std_core_types__is_Nothing(m_10012, _ctx)) {
    _x_x233 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x134 = m_10012._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x134, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10012, _ctx);
    _x_x233 = x; /*int*/
  }
  r = kk_main_run(_x_x233, _ctx); /*int*/
  kk_string_t _x_x234 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x234, _ctx); return kk_Unit;
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
    kk_string_t _x_x151;
    kk_define_string_literal(, _s_x152, 9, "emit@main", _ctx)
    _x_x151 = kk_string_dup(_s_x152, _ctx); /*string*/
    kk_main__tag_emit = kk_std_core_hnd__new_Htag(_x_x151, _ctx); /*hnd/htag<main/emit>*/
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
