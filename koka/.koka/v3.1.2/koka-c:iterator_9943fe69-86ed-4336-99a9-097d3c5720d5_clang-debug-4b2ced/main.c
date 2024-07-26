// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:emit`

kk_std_core_hnd__htag kk_main__tag_emit;
 
// handler for the effect `:emit`

kk_box_t kk_main__handle_emit(kk_main__emit hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : emit<e,b>, ret : (res : a) -> e b, action : () -> <emit|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x79 = kk_std_core_hnd__htag_dup(kk_main__tag_emit, _ctx); /*hnd/htag<main/emit>*/
  return kk_std_core_hnd__hhandle(_x_x79, kk_main__emit_box(hnd, _ctx), ret, action, _ctx);
}
 
// monadic lift

kk_unit_t kk_main__mlift_range_10019(kk_integer_t l, kk_integer_t u, kk_unit_t wild__, kk_context_t* _ctx) { /* (l : int, u : int, wild_ : ()) -> emit () */ 
  kk_integer_t _x_x84 = kk_integer_add_small_const(l, 1, _ctx); /*int*/
  kk_main_range(_x_x84, u, _ctx); return kk_Unit;
}


// lift anonymous function
struct kk_main_range_fun91__t {
  struct kk_function_s _base;
  kk_integer_t l_0;
  kk_integer_t u_0;
};
static kk_box_t kk_main_range_fun91(kk_function_t _fself, kk_box_t _b_x25, kk_context_t* _ctx);
static kk_function_t kk_main_new_range_fun91(kk_integer_t l_0, kk_integer_t u_0, kk_context_t* _ctx) {
  struct kk_main_range_fun91__t* _self = kk_function_alloc_as(struct kk_main_range_fun91__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_range_fun91, kk_context());
  _self->l_0 = l_0;
  _self->u_0 = u_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_range_fun91(kk_function_t _fself, kk_box_t _b_x25, kk_context_t* _ctx) {
  struct kk_main_range_fun91__t* _self = kk_function_as(struct kk_main_range_fun91__t*, _fself, _ctx);
  kk_integer_t l_0 = _self->l_0; /* int */
  kk_integer_t u_0 = _self->u_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(l_0, _ctx);kk_integer_dup(u_0, _ctx);}, {}, _ctx)
  kk_unit_t wild___0_27 = kk_Unit;
  kk_unit_unbox(_b_x25);
  kk_unit_t _x_x92 = kk_Unit;
  kk_main__mlift_range_10019(l_0, u_0, wild___0_27, _ctx);
  return kk_unit_box(_x_x92);
}

kk_unit_t kk_main_range(kk_integer_t l_0, kk_integer_t u_0, kk_context_t* _ctx) { /* (l : int, u : int) -> <div,emit> () */ 
  kk__tailcall: ;
  bool _match_x70 = kk_integer_gt_borrow(l_0,u_0,kk_context()); /*bool*/;
  if (_match_x70) {
    kk_integer_drop(u_0, _ctx);
    kk_integer_drop(l_0, _ctx);
    kk_Unit; return kk_Unit;
  }
  {
    kk_std_core_hnd__ev ev_10028 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/emit>*/;
    kk_unit_t x_10025 = kk_Unit;
    kk_box_t _x_x85;
    {
      struct kk_std_core_hnd_Ev* _con_x86 = kk_std_core_hnd__as_Ev(ev_10028, _ctx);
      kk_box_t _box_x16 = _con_x86->hnd;
      int32_t m = _con_x86->marker;
      kk_main__emit h = kk_main__emit_unbox(_box_x16, KK_BORROWED, _ctx);
      kk_main__emit_dup(h, _ctx);
      {
        struct kk_main__Hnd_emit* _con_x87 = kk_main__as_Hnd_emit(h, _ctx);
        kk_integer_t _pat_0_0 = _con_x87->_cfc;
        kk_std_core_hnd__clause1 _fun_emit = _con_x87->_fun_emit;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_integer_drop(_pat_0_0, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_fun_emit, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x20 = _fun_emit.clause;
          kk_box_t _x_x88;
          kk_integer_t _x_x89 = kk_integer_dup(l_0, _ctx); /*int*/
          _x_x88 = kk_integer_box(_x_x89, _ctx); /*1009*/
          _x_x85 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x20, (_fun_unbox_x20, m, ev_10028, _x_x88, _ctx), _ctx); /*1010*/
        }
      }
    }
    kk_unit_unbox(_x_x85);
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x90 = kk_std_core_hnd_yield_extend(kk_main_new_range_fun91(l_0, u_0, _ctx), _ctx); /*3003*/
      kk_unit_unbox(_x_x90); return kk_Unit;
    }
    { // tailcall
      kk_integer_t _x_x93 = kk_integer_add_small_const(l_0, 1, _ctx); /*int*/
      l_0 = _x_x93;
      goto kk__tailcall;
    }
  }
}


// lift anonymous function
struct kk_main_run_fun99__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_run_fun99(kk_function_t _fself, int32_t _b_x39, kk_std_core_hnd__ev _b_x40, kk_box_t _b_x41, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun99(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_run_fun99__t* _self = kk_function_alloc_as(struct kk_main_run_fun99__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun99, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun99(kk_function_t _fself, int32_t _b_x39, kk_std_core_hnd__ev _b_x40, kk_box_t _b_x41, kk_context_t* _ctx) {
  struct kk_main_run_fun99__t* _self = kk_function_as(struct kk_main_run_fun99__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<391,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  int32_t ___wildcard_x691__14_63 = _b_x39; /*hnd/marker<<local<391>,div>,int>*/;
  kk_std_core_hnd__ev ___wildcard_x691__17_64 = _b_x40; /*hnd/ev<main/emit>*/;
  kk_datatype_ptr_dropn(___wildcard_x691__17_64, (KK_I32(3)), _ctx);
  kk_integer_t x_65 = kk_integer_unbox(_b_x41, _ctx); /*int*/;
  kk_integer_t x_10002;
  kk_box_t _x_x100;
  kk_ref_t _x_x101 = kk_ref_dup(loc, _ctx); /*local-var<391,int>*/
  _x_x100 = kk_ref_get(_x_x101,kk_context()); /*1000*/
  x_10002 = kk_integer_unbox(_x_x100, _ctx); /*int*/
  kk_integer_t _b_x35_37 = kk_integer_add(x_10002,x_65,kk_context()); /*int*/;
  kk_unit_t __ = kk_Unit;
  kk_unit_t _brw_x69 = kk_Unit;
  kk_ref_set_borrow(loc,(kk_integer_box(_b_x35_37, _ctx)),kk_context());
  kk_ref_drop(loc, _ctx);
  _brw_x69;
  return kk_unit_box(kk_Unit);
}


// lift anonymous function
struct kk_main_run_fun102__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun102(kk_function_t _fself, kk_box_t _b_x49, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun102(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun102, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun102(kk_function_t _fself, kk_box_t _b_x49, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _b_x49;
}


// lift anonymous function
struct kk_main_run_fun104__t {
  struct kk_function_s _base;
  kk_ref_t loc;
  kk_integer_t n;
};
static kk_box_t kk_main_run_fun104(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun104(kk_ref_t loc, kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun104__t* _self = kk_function_alloc_as(struct kk_main_run_fun104__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun104, kk_context());
  _self->loc = loc;
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_run_fun105__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_run_fun105(kk_function_t _fself, kk_box_t _b_x44, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun105(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_run_fun105__t* _self = kk_function_alloc_as(struct kk_main_run_fun105__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun105, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun105(kk_function_t _fself, kk_box_t _b_x44, kk_context_t* _ctx) {
  struct kk_main_run_fun105__t* _self = kk_function_as(struct kk_main_run_fun105__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<391,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x44, _ctx);
  return kk_ref_get(loc,kk_context());
}
static kk_box_t kk_main_run_fun104(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun104__t* _self = kk_function_as(struct kk_main_run_fun104__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<391,int> */
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_unit_t x_0_10034 = kk_Unit;
  kk_main_range(kk_integer_from_small(0), n, _ctx);
  if (kk_yielding(kk_context())) {
    return kk_std_core_hnd_yield_extend(kk_main_new_run_fun105(loc, _ctx), _ctx);
  }
  {
    return kk_ref_get(loc,kk_context());
  }
}

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<391,int>*/;
  kk_integer_t res;
  kk_box_t _x_x95;
  kk_main__emit _x_x96;
  kk_std_core_hnd__clause1 _x_x97;
  kk_function_t _x_x98;
  kk_ref_dup(loc, _ctx);
  _x_x98 = kk_main_new_run_fun99(loc, _ctx); /*(hnd/marker<1018,1019>, hnd/ev<1017>, 1015) -> 1018 1016*/
  _x_x97 = kk_std_core_hnd__new_Clause1(_x_x98, _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x96 = kk_main__new_Hnd_emit(kk_reuse_null, 0, kk_integer_from_small(1), _x_x97, _ctx); /*main/emit<6,7>*/
  kk_function_t _x_x103;
  kk_ref_dup(loc, _ctx);
  _x_x103 = kk_main_new_run_fun104(loc, n, _ctx); /*() -> <main/emit|138> 3003*/
  _x_x95 = kk_main__handle_emit(_x_x96, kk_main_new_run_fun102(_ctx), _x_x103, _ctx); /*139*/
  res = kk_integer_unbox(_x_x95, _ctx); /*int*/
  kk_box_t _x_x106 = kk_std_core_hnd_prompt_local_var(loc, kk_integer_box(res, _ctx), _ctx); /*3004*/
  return kk_integer_unbox(_x_x106, _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10006 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10004;
  kk_string_t _x_x107;
  if (kk_std_core_types__is_Cons(xs_10006, _ctx)) {
    struct kk_std_core_types_Cons* _con_x108 = kk_std_core_types__as_Cons(xs_10006, _ctx);
    kk_box_t _box_x66 = _con_x108->head;
    kk_std_core_types__list _pat_0_0 = _con_x108->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x66);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10006, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10006, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10006, _ctx);
    }
    _x_x107 = x_0; /*string*/
  }
  else {
    _x_x107 = kk_string_empty(); /*string*/
  }
  m_10004 = kk_std_core_int_parse_int(_x_x107, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_integer_t _x_x110;
  if (kk_std_core_types__is_Nothing(m_10004, _ctx)) {
    _x_x110 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x67 = m_10004._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x67, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10004, _ctx);
    _x_x110 = x; /*int*/
  }
  r = kk_main_run(_x_x110, _ctx); /*int*/
  kk_string_t _x_x111 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x111, _ctx); return kk_Unit;
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
    kk_string_t _x_x77;
    kk_define_string_literal(, _s_x78, 9, "emit@main", _ctx)
    _x_x77 = kk_string_dup(_s_x78, _ctx); /*string*/
    kk_main__tag_emit = kk_std_core_hnd__new_Htag(_x_x77, _ctx); /*hnd/htag<main/emit>*/
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
