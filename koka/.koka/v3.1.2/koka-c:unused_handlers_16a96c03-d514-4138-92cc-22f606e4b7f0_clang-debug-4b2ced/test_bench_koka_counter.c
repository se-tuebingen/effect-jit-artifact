// Koka generated module: test/bench/koka/counter, koka version: 3.1.2, platform: 64-bit
#include "test_bench_koka_counter.h"
 
// runtime tag for the effect `:st`

kk_std_core_hnd__htag kk_test_bench_koka_counter__tag_st;
 
// handler for the effect `:st`

kk_box_t kk_test_bench_koka_counter__handle_st(kk_test_bench_koka_counter__st hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : st<e,b>, ret : (res : a) -> e b, action : () -> <st|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x103 = kk_std_core_hnd__htag_dup(kk_test_bench_koka_counter__tag_st, _ctx); /*hnd/htag<test/bench/koka/counter/st>*/
  return kk_std_core_hnd__hhandle(_x_x103, kk_test_bench_koka_counter__st_box(hnd, _ctx), ret, action, _ctx);
}
extern kk_box_t kk_test_bench_koka_counter_get_fun108(kk_function_t _fself, int32_t _b_x15, kk_std_core_hnd__ev _b_x16, kk_context_t* _ctx) {
  struct kk_test_bench_koka_counter_get_fun108__t* _self = kk_function_as(struct kk_test_bench_koka_counter_get_fun108__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x11 = _self->_fun_unbox_x11; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x11, _ctx);}, {}, _ctx)
  int32_t _x_x109;
  int32_t _b_x12_23 = _b_x15; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x13_24 = _b_x16; /*hnd/ev<test/bench/koka/counter/st>*/;
  kk_box_t _x_x110 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x11, (_fun_unbox_x11, _b_x12_23, _b_x13_24, _ctx), _ctx); /*1005*/
  _x_x109 = kk_int32_unbox(_x_x110, KK_OWNED, _ctx); /*int32*/
  return kk_int32_box(_x_x109, _ctx);
}

kk_integer_t kk_test_bench_koka_counter_counter(int32_t c, kk_context_t* _ctx) { /* (c : int32) -> <div,st> int */ 
  kk__tailcall: ;
  kk_std_core_hnd__ev ev_10020 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<test/bench/koka/counter/st>*/;
  int32_t i;
  {
    struct kk_std_core_hnd_Ev* _con_x115 = kk_std_core_hnd__as_Ev(ev_10020, _ctx);
    kk_box_t _box_x33 = _con_x115->hnd;
    int32_t m = _con_x115->marker;
    kk_test_bench_koka_counter__st h = kk_test_bench_koka_counter__st_unbox(_box_x33, KK_BORROWED, _ctx);
    kk_test_bench_koka_counter__st_dup(h, _ctx);
    {
      struct kk_test_bench_koka_counter__Hnd_st* _con_x116 = kk_test_bench_koka_counter__as_Hnd_st(h, _ctx);
      kk_integer_t _pat_0_0 = _con_x116->_cfc;
      kk_std_core_hnd__clause0 _fun_get = _con_x116->_fun_get;
      kk_std_core_hnd__clause1 _pat_1_0 = _con_x116->_fun_set;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause1_drop(_pat_1_0, _ctx);
        kk_integer_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_fun_get, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x36 = _fun_get.clause;
        kk_function_t _bv_x42 = _fun_unbox_x36; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x117 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x42, (_bv_x42, m, ev_10020, _ctx), _ctx); /*3004*/
        i = kk_int32_unbox(_x_x117, KK_OWNED, _ctx); /*int32*/
      }
    }
  }
  bool _match_x93 = (i == kk_std_num_int32_zero); /*bool*/;
  if (_match_x93) {
    return kk_integer_from_int(c,kk_context());
  }
  {
    int32_t i_0_10000 = (int32_t)((uint32_t)i - (uint32_t)((KK_I32(1)))); /*int32*/;
    kk_std_core_hnd__ev ev_0_10022 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<test/bench/koka/counter/st>*/;
    kk_unit_t __ = kk_Unit;
    kk_box_t _x_x118;
    {
      struct kk_std_core_hnd_Ev* _con_x119 = kk_std_core_hnd__as_Ev(ev_0_10022, _ctx);
      kk_box_t _box_x50 = _con_x119->hnd;
      int32_t m_0 = _con_x119->marker;
      kk_test_bench_koka_counter__st h_0 = kk_test_bench_koka_counter__st_unbox(_box_x50, KK_BORROWED, _ctx);
      kk_test_bench_koka_counter__st_dup(h_0, _ctx);
      {
        struct kk_test_bench_koka_counter__Hnd_st* _con_x120 = kk_test_bench_koka_counter__as_Hnd_st(h_0, _ctx);
        kk_integer_t _pat_0_2 = _con_x120->_cfc;
        kk_std_core_hnd__clause0 _pat_1_1 = _con_x120->_fun_get;
        kk_std_core_hnd__clause1 _fun_set = _con_x120->_fun_set;
        if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
          kk_std_core_hnd__clause0_drop(_pat_1_1, _ctx);
          kk_integer_drop(_pat_0_2, _ctx);
          kk_datatype_ptr_free(h_0, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_fun_set, _ctx);
          kk_datatype_ptr_decref(h_0, _ctx);
        }
        {
          kk_function_t _fun_unbox_x54 = _fun_set.clause;
          _x_x118 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x54, (_fun_unbox_x54, m_0, ev_0_10022, kk_int32_box(i_0_10000, _ctx), _ctx), _ctx); /*1010*/
        }
      }
    }
    kk_unit_unbox(_x_x118);
    { // tailcall
      int32_t _x_x121 = (int32_t)((uint32_t)c + (uint32_t)((KK_I32(1)))); /*int32*/
      c = _x_x121;
      goto kk__tailcall;
    }
  }
}


// lift anonymous function
struct kk_test_bench_koka_counter_state_fun125__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_test_bench_koka_counter_state_fun125(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_test_bench_koka_counter_new_state_fun125(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_test_bench_koka_counter_state_fun125__t* _self = kk_function_alloc_as(struct kk_test_bench_koka_counter_state_fun125__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_test_bench_koka_counter_state_fun125, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_test_bench_koka_counter_state_fun125(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_test_bench_koka_counter_state_fun125__t* _self = kk_function_as(struct kk_test_bench_koka_counter_state_fun125__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<612,int32> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  return kk_ref_get(loc,kk_context());
}


// lift anonymous function
struct kk_test_bench_koka_counter_state_fun128__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_test_bench_koka_counter_state_fun128(kk_function_t _fself, kk_box_t _b_x65, kk_context_t* _ctx);
static kk_function_t kk_test_bench_koka_counter_new_state_fun128(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_test_bench_koka_counter_state_fun128__t* _self = kk_function_alloc_as(struct kk_test_bench_koka_counter_state_fun128__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_test_bench_koka_counter_state_fun128, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_test_bench_koka_counter_state_fun128(kk_function_t _fself, kk_box_t _b_x65, kk_context_t* _ctx) {
  struct kk_test_bench_koka_counter_state_fun128__t* _self = kk_function_as(struct kk_test_bench_koka_counter_state_fun128__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<612,int32> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_unit_t _x_x129 = kk_Unit;
  kk_unit_t _brw_x92 = kk_Unit;
  kk_ref_set_borrow(loc,_b_x65,kk_context());
  kk_ref_drop(loc, _ctx);
  _brw_x92;
  return kk_unit_box(_x_x129);
}


// lift anonymous function
struct kk_test_bench_koka_counter_state_fun130__t {
  struct kk_function_s _base;
};
static kk_box_t kk_test_bench_koka_counter_state_fun130(kk_function_t _fself, kk_box_t _x, kk_context_t* _ctx);
static kk_function_t kk_test_bench_koka_counter_new_state_fun130(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_test_bench_koka_counter_state_fun130, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_test_bench_koka_counter_state_fun130(kk_function_t _fself, kk_box_t _x, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _x;
}

kk_box_t kk_test_bench_koka_counter_state(int32_t i, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (i : int32, action : () -> <st|e> a) -> e a */ 
  kk_ref_t loc = kk_ref_alloc((kk_int32_box(i, _ctx)),kk_context()); /*local-var<612,int32>*/;
  kk_box_t res;
  kk_test_bench_koka_counter__st _x_x122;
  kk_std_core_hnd__clause0 _x_x123;
  kk_function_t _x_x124;
  kk_ref_dup(loc, _ctx);
  _x_x124 = kk_test_bench_koka_counter_new_state_fun125(loc, _ctx); /*() -> 1000 1000*/
  _x_x123 = kk_std_core_hnd_clause_tail0(_x_x124, _ctx); /*hnd/clause0<1003,1002,1000,1001>*/
  kk_std_core_hnd__clause1 _x_x126;
  kk_function_t _x_x127;
  kk_ref_dup(loc, _ctx);
  _x_x127 = kk_test_bench_koka_counter_new_state_fun128(loc, _ctx); /*(1003) -> 1000 1004*/
  _x_x126 = kk_std_core_hnd_clause_tail1(_x_x127, _ctx); /*hnd/clause1<1003,1004,1002,1000,1001>*/
  _x_x122 = kk_test_bench_koka_counter__new_Hnd_st(kk_reuse_null, 0, kk_integer_from_small(1), _x_x123, _x_x126, _ctx); /*test/bench/koka/counter/st<10,11>*/
  res = kk_test_bench_koka_counter__handle_st(_x_x122, kk_test_bench_koka_counter_new_state_fun130(_ctx), action, _ctx); /*618*/
  return kk_std_core_hnd_prompt_local_var(loc, res, _ctx);
}


// lift anonymous function
struct kk_test_bench_koka_counter_main_fun132__t {
  struct kk_function_s _base;
};
static kk_box_t kk_test_bench_koka_counter_main_fun132(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_test_bench_koka_counter_new_main_fun132(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_test_bench_koka_counter_main_fun132, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_test_bench_koka_counter_main_fun133__t {
  struct kk_function_s _base;
};
static kk_box_t kk_test_bench_koka_counter_main_fun133(kk_function_t _fself, kk_box_t _b_x75, kk_box_t _b_x76, kk_context_t* _ctx);
static kk_function_t kk_test_bench_koka_counter_new_main_fun133(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_test_bench_koka_counter_main_fun133, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_test_bench_koka_counter_main_fun134__t {
  struct kk_function_s _base;
  kk_box_t _b_x76;
};
static kk_string_t kk_test_bench_koka_counter_main_fun134(kk_function_t _fself, kk_integer_t _b_x79, kk_context_t* _ctx);
static kk_function_t kk_test_bench_koka_counter_new_main_fun134(kk_box_t _b_x76, kk_context_t* _ctx) {
  struct kk_test_bench_koka_counter_main_fun134__t* _self = kk_function_alloc_as(struct kk_test_bench_koka_counter_main_fun134__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_test_bench_koka_counter_main_fun134, kk_context());
  _self->_b_x76 = _b_x76;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_string_t kk_test_bench_koka_counter_main_fun134(kk_function_t _fself, kk_integer_t _b_x79, kk_context_t* _ctx) {
  struct kk_test_bench_koka_counter_main_fun134__t* _self = kk_function_as(struct kk_test_bench_koka_counter_main_fun134__t*, _fself, _ctx);
  kk_box_t _b_x76 = _self->_b_x76; /* 1001 */
  kk_drop_match(_self, {kk_box_dup(_b_x76, _ctx);}, {}, _ctx)
  kk_box_t _x_x135;
  kk_function_t _x_x136 = kk_function_unbox(_b_x76, _ctx); /*(77) -> 78*/
  _x_x135 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x136, (_x_x136, kk_integer_box(_b_x79, _ctx), _ctx), _ctx); /*78*/
  return kk_string_unbox(_x_x135);
}
static kk_box_t kk_test_bench_koka_counter_main_fun133(kk_function_t _fself, kk_box_t _b_x75, kk_box_t _b_x76, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t x_90 = kk_integer_unbox(_b_x75, _ctx); /*int*/;
  kk_function_t _implicit_fs_show_91 = kk_test_bench_koka_counter_new_main_fun134(_b_x76, _ctx); /*(int) -> string*/;
  kk_unit_t _x_x137 = kk_Unit;
  kk_string_t _x_x138 = kk_function_call(kk_string_t, (kk_function_t, kk_integer_t, kk_context_t*), _implicit_fs_show_91, (_implicit_fs_show_91, x_90, _ctx), _ctx); /*string*/
  kk_std_core_console_printsln(_x_x138, _ctx);
  return kk_unit_box(_x_x137);
}


// lift anonymous function
struct kk_test_bench_koka_counter_main_fun139__t {
  struct kk_function_s _base;
};
static kk_box_t kk_test_bench_koka_counter_main_fun139(kk_function_t _fself, kk_box_t _b_x82, kk_context_t* _ctx);
static kk_function_t kk_test_bench_koka_counter_new_main_fun139(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_test_bench_koka_counter_main_fun139, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_test_bench_koka_counter_main_fun139(kk_function_t _fself, kk_box_t _b_x82, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x140;
  kk_integer_t _x_x141 = kk_integer_unbox(_b_x82, _ctx); /*int*/
  _x_x140 = kk_std_core_int_show(_x_x141, _ctx); /*string*/
  return kk_string_box(_x_x140);
}
static kk_box_t kk_test_bench_koka_counter_main_fun132(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x1_10012 = kk_test_bench_koka_counter_counter(kk_std_num_int32_zero, _ctx); /*int*/;
  return kk_std_core_hnd__open_none2(kk_test_bench_koka_counter_new_main_fun133(_ctx), kk_integer_box(_x_x1_10012, _ctx), kk_function_box(kk_test_bench_koka_counter_new_main_fun139(_ctx), _ctx), _ctx);
}

kk_unit_t kk_test_bench_koka_counter_main(kk_context_t* _ctx) { /* () -> <console/console,div> () */ 
  int32_t _b_x83_85 = (KK_I32(100100100)); /*int32*/;
  kk_box_t _x_x131 = kk_test_bench_koka_counter_state(_b_x83_85, kk_test_bench_koka_counter_new_main_fun132(_ctx), _ctx); /*618*/
  kk_unit_unbox(_x_x131); return kk_Unit;
}

// initialization
void kk_test_bench_koka_counter__init(kk_context_t* _ctx){
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
  kk_std_num_int32__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
  {
    kk_string_t _x_x101;
    kk_define_string_literal(, _s_x102, 10, "st@counter", _ctx)
    _x_x101 = kk_string_dup(_s_x102, _ctx); /*string*/
    kk_test_bench_koka_counter__tag_st = kk_std_core_hnd__new_Htag(_x_x101, _ctx); /*hnd/htag<test/bench/koka/counter/st>*/
  }
}

// termination
void kk_test_bench_koka_counter__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_hnd__htag_drop(kk_test_bench_koka_counter__tag_st, _ctx);
  kk_std_num_int32__done(_ctx);
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
