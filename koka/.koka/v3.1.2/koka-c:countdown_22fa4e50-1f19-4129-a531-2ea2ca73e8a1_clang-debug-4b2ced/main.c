// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:state`

kk_std_core_hnd__htag kk_main__tag_state;
 
// handler for the effect `:state`

kk_box_t kk_main__handle_state(kk_main__state hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : state<e,b>, ret : (res : a) -> e b, action : () -> <state|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x128 = kk_std_core_hnd__htag_dup(kk_main__tag_state, _ctx); /*hnd/htag<main/state>*/
  return kk_std_core_hnd__hhandle(_x_x128, kk_main__state_box(hnd, _ctx), ret, action, _ctx);
}
extern kk_box_t kk_main_get_fun133(kk_function_t _fself, int32_t _b_x15, kk_std_core_hnd__ev _b_x16, kk_context_t* _ctx) {
  struct kk_main_get_fun133__t* _self = kk_function_as(struct kk_main_get_fun133__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x11 = _self->_fun_unbox_x11; /* (hnd/marker<1007,1008>, hnd/ev<1006>) -> 1007 1005 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x11, _ctx);}, {}, _ctx)
  kk_integer_t _x_x134;
  int32_t _b_x12_23 = _b_x15; /*hnd/marker<1005,1006>*/;
  kk_std_core_hnd__ev _b_x13_24 = _b_x16; /*hnd/ev<main/state>*/;
  kk_box_t _x_x135 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x11, (_fun_unbox_x11, _b_x12_23, _b_x13_24, _ctx), _ctx); /*1005*/
  _x_x134 = kk_integer_unbox(_x_x135, _ctx); /*int*/
  return kk_integer_box(_x_x134, _ctx);
}
 
// monadic lift

kk_integer_t kk_main__mlift_countdown_10018(kk_unit_t wild__, kk_context_t* _ctx) { /* (wild_ : ()) -> state int */ 
  return kk_main_countdown(_ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_countdown_10019_fun144__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_countdown_10019_fun144(kk_function_t _fself, kk_box_t _b_x42, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_countdown_10019_fun144(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_countdown_10019_fun144, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_countdown_10019_fun144(kk_function_t _fself, kk_box_t _b_x42, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x145;
  kk_unit_t _x_x146 = kk_Unit;
  kk_unit_unbox(_b_x42);
  _x_x145 = kk_main__mlift_countdown_10018(_x_x146, _ctx); /*int*/
  return kk_integer_box(_x_x145, _ctx);
}

kk_integer_t kk_main__mlift_countdown_10019(kk_integer_t i, kk_context_t* _ctx) { /* (i : int) -> state int */ 
  bool _match_x115 = kk_integer_eq_borrow(i,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x115) {
    return i;
  }
  {
    kk_integer_t i_0_10000 = kk_integer_add_small_const(i, -1, _ctx); /*int*/;
    kk_std_core_hnd__ev ev_10028 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
    kk_unit_t x_10026 = kk_Unit;
    kk_box_t _x_x140;
    {
      struct kk_std_core_hnd_Ev* _con_x141 = kk_std_core_hnd__as_Ev(ev_10028, _ctx);
      kk_box_t _box_x33 = _con_x141->hnd;
      int32_t m = _con_x141->marker;
      kk_main__state h = kk_main__state_unbox(_box_x33, KK_BORROWED, _ctx);
      kk_main__state_dup(h, _ctx);
      {
        struct kk_main__Hnd_state* _con_x142 = kk_main__as_Hnd_state(h, _ctx);
        kk_integer_t _pat_0_0 = _con_x142->_cfc;
        kk_std_core_hnd__clause0 _pat_1_1 = _con_x142->_fun_get;
        kk_std_core_hnd__clause1 _fun_set = _con_x142->_fun_set;
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
          kk_function_t _fun_unbox_x37 = _fun_set.clause;
          _x_x140 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x37, (_fun_unbox_x37, m, ev_10028, kk_integer_box(i_0_10000, _ctx), _ctx), _ctx); /*1010*/
        }
      }
    }
    kk_unit_unbox(_x_x140);
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x143 = kk_std_core_hnd_yield_extend(kk_main__new_mlift_countdown_10019_fun144(_ctx), _ctx); /*3003*/
      return kk_integer_unbox(_x_x143, _ctx);
    }
    {
      return kk_main__mlift_countdown_10018(x_10026, _ctx);
    }
  }
}


// lift anonymous function
struct kk_main_countdown_fun151__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_countdown_fun151(kk_function_t _fself, kk_box_t _b_x62, kk_context_t* _ctx);
static kk_function_t kk_main_new_countdown_fun151(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_countdown_fun151, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_countdown_fun151(kk_function_t _fself, kk_box_t _b_x62, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x152;
  kk_integer_t _x_x153 = kk_integer_unbox(_b_x62, _ctx); /*int*/
  _x_x152 = kk_main__mlift_countdown_10019(_x_x153, _ctx); /*int*/
  return kk_integer_box(_x_x152, _ctx);
}


// lift anonymous function
struct kk_main_countdown_fun158__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_countdown_fun158(kk_function_t _fself, kk_box_t _b_x72, kk_context_t* _ctx);
static kk_function_t kk_main_new_countdown_fun158(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_countdown_fun158, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_countdown_fun158(kk_function_t _fself, kk_box_t _b_x72, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x159;
  kk_unit_t _x_x160 = kk_Unit;
  kk_unit_unbox(_b_x72);
  _x_x159 = kk_main__mlift_countdown_10018(_x_x160, _ctx); /*int*/
  return kk_integer_box(_x_x159, _ctx);
}

kk_integer_t kk_main_countdown(kk_context_t* _ctx) { /* () -> <div,state> int */ 
  kk__tailcall: ;
  kk_std_core_hnd__ev ev_0_10034 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
  kk_integer_t x_1_10031;
  {
    struct kk_std_core_hnd_Ev* _con_x147 = kk_std_core_hnd__as_Ev(ev_0_10034, _ctx);
    kk_box_t _box_x44 = _con_x147->hnd;
    int32_t m_0 = _con_x147->marker;
    kk_main__state h_0 = kk_main__state_unbox(_box_x44, KK_BORROWED, _ctx);
    kk_main__state_dup(h_0, _ctx);
    {
      struct kk_main__Hnd_state* _con_x148 = kk_main__as_Hnd_state(h_0, _ctx);
      kk_integer_t _pat_0_2 = _con_x148->_cfc;
      kk_std_core_hnd__clause0 _fun_get = _con_x148->_fun_get;
      kk_std_core_hnd__clause1 _pat_1_3 = _con_x148->_fun_set;
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
        kk_function_t _fun_unbox_x47 = _fun_get.clause;
        kk_function_t _bv_x53 = _fun_unbox_x47; /*(hnd/marker<3006,3008>, hnd/ev<3007>) -> 3005 3004*/;
        kk_box_t _x_x149 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x53, (_bv_x53, m_0, ev_0_10034, _ctx), _ctx); /*3004*/
        x_1_10031 = kk_integer_unbox(_x_x149, _ctx); /*int*/
      }
    }
  }
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_1_10031, _ctx);
    kk_box_t _x_x150 = kk_std_core_hnd_yield_extend(kk_main_new_countdown_fun151(_ctx), _ctx); /*3003*/
    return kk_integer_unbox(_x_x150, _ctx);
  }
  {
    bool _match_x113 = kk_integer_eq_borrow(x_1_10031,(kk_integer_from_small(0)),kk_context()); /*bool*/;
    if (_match_x113) {
      return x_1_10031;
    }
    {
      kk_integer_t i_0_10000_0 = kk_integer_add_small_const(x_1_10031, -1, _ctx); /*int*/;
      kk_std_core_hnd__ev ev_1_10039 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/state>*/;
      kk_unit_t x_2_10036 = kk_Unit;
      kk_box_t _x_x154;
      {
        struct kk_std_core_hnd_Ev* _con_x155 = kk_std_core_hnd__as_Ev(ev_1_10039, _ctx);
        kk_box_t _box_x63 = _con_x155->hnd;
        int32_t m_1 = _con_x155->marker;
        kk_main__state h_1 = kk_main__state_unbox(_box_x63, KK_BORROWED, _ctx);
        kk_main__state_dup(h_1, _ctx);
        {
          struct kk_main__Hnd_state* _con_x156 = kk_main__as_Hnd_state(h_1, _ctx);
          kk_integer_t _pat_0_5 = _con_x156->_cfc;
          kk_std_core_hnd__clause0 _pat_1_4 = _con_x156->_fun_get;
          kk_std_core_hnd__clause1 _fun_set_0 = _con_x156->_fun_set;
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
            kk_function_t _fun_unbox_x67 = _fun_set_0.clause;
            _x_x154 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x67, (_fun_unbox_x67, m_1, ev_1_10039, kk_integer_box(i_0_10000_0, _ctx), _ctx), _ctx); /*1010*/
          }
        }
      }
      kk_unit_unbox(_x_x154);
      if (kk_yielding(kk_context())) {
        kk_box_t _x_x157 = kk_std_core_hnd_yield_extend(kk_main_new_countdown_fun158(_ctx), _ctx); /*3003*/
        return kk_integer_unbox(_x_x157, _ctx);
      }
      { // tailcall
        goto kk__tailcall;
      }
    }
  }
}


// lift anonymous function
struct kk_main_run_fun165__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_run_fun165(kk_function_t _fself, int32_t _b_x79, kk_std_core_hnd__ev _b_x80, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun165(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_run_fun165__t* _self = kk_function_alloc_as(struct kk_main_run_fun165__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun165, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun165(kk_function_t _fself, int32_t _b_x79, kk_std_core_hnd__ev _b_x80, kk_context_t* _ctx) {
  struct kk_main_run_fun165__t* _self = kk_function_as(struct kk_main_run_fun165__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<603,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  int32_t ___wildcard_x737__14_104 = _b_x79; /*hnd/marker<<local<603>,div>,int>*/;
  kk_std_core_hnd__ev ___wildcard_x737__17_105 = _b_x80; /*hnd/ev<main/state>*/;
  kk_datatype_ptr_dropn(___wildcard_x737__17_105, (KK_I32(3)), _ctx);
  return kk_ref_get(loc,kk_context());
}


// lift anonymous function
struct kk_main_run_fun168__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_main_run_fun168(kk_function_t _fself, int32_t _b_x84, kk_std_core_hnd__ev _b_x85, kk_box_t _b_x86, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun168(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_main_run_fun168__t* _self = kk_function_alloc_as(struct kk_main_run_fun168__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun168, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun168(kk_function_t _fself, int32_t _b_x84, kk_std_core_hnd__ev _b_x85, kk_box_t _b_x86, kk_context_t* _ctx) {
  struct kk_main_run_fun168__t* _self = kk_function_as(struct kk_main_run_fun168__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<603,int> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  int32_t ___wildcard_x691__14_106 = _b_x84; /*hnd/marker<<local<603>,div>,int>*/;
  kk_std_core_hnd__ev ___wildcard_x691__17_107 = _b_x85; /*hnd/ev<main/state>*/;
  kk_datatype_ptr_dropn(___wildcard_x691__17_107, (KK_I32(3)), _ctx);
  kk_integer_t x_108 = kk_integer_unbox(_b_x86, _ctx); /*int*/;
  kk_unit_t _x_x169 = kk_Unit;
  kk_unit_t _brw_x111 = kk_Unit;
  kk_ref_set_borrow(loc,(kk_integer_box(x_108, _ctx)),kk_context());
  kk_ref_drop(loc, _ctx);
  _brw_x111;
  return kk_unit_box(_x_x169);
}


// lift anonymous function
struct kk_main_run_fun170__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun170(kk_function_t _fself, kk_box_t _b_x90, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun170(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun170, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun170(kk_function_t _fself, kk_box_t _b_x90, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _b_x90;
}


// lift anonymous function
struct kk_main_run_fun171__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun171(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun171(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun171, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun171(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x172 = kk_main_countdown(_ctx); /*int*/
  return kk_integer_box(_x_x172, _ctx);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(n, _ctx)),kk_context()); /*local-var<603,int>*/;
  kk_integer_t res;
  kk_box_t _x_x161;
  kk_main__state _x_x162;
  kk_std_core_hnd__clause0 _x_x163;
  kk_function_t _x_x164;
  kk_ref_dup(loc, _ctx);
  _x_x164 = kk_main_new_run_fun165(loc, _ctx); /*(hnd/marker<1012,1013>, hnd/ev<1011>) -> 1012 1000*/
  _x_x163 = kk_std_core_hnd__new_Clause0(_x_x164, _ctx); /*hnd/clause0<1010,1011,1012,1013>*/
  kk_std_core_hnd__clause1 _x_x166;
  kk_function_t _x_x167;
  kk_ref_dup(loc, _ctx);
  _x_x167 = kk_main_new_run_fun168(loc, _ctx); /*(hnd/marker<1018,1019>, hnd/ev<1017>, 1015) -> 1018 1016*/
  _x_x166 = kk_std_core_hnd__new_Clause1(_x_x167, _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x162 = kk_main__new_Hnd_state(kk_reuse_null, 0, kk_integer_from_small(1), _x_x163, _x_x166, _ctx); /*main/state<10,11>*/
  _x_x161 = kk_main__handle_state(_x_x162, kk_main_new_run_fun170(_ctx), kk_main_new_run_fun171(_ctx), _ctx); /*174*/
  res = kk_integer_unbox(_x_x161, _ctx); /*int*/
  kk_box_t _x_x173 = kk_std_core_hnd_prompt_local_var(loc, kk_integer_box(res, _ctx), _ctx); /*3004*/
  return kk_integer_unbox(_x_x173, _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10004 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10002;
  kk_string_t _x_x174;
  if (kk_std_core_types__is_Cons(xs_10004, _ctx)) {
    struct kk_std_core_types_Cons* _con_x175 = kk_std_core_types__as_Cons(xs_10004, _ctx);
    kk_box_t _box_x109 = _con_x175->head;
    kk_std_core_types__list _pat_0_0 = _con_x175->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x109);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10004, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10004, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10004, _ctx);
    }
    _x_x174 = x_0; /*string*/
  }
  else {
    _x_x174 = kk_string_empty(); /*string*/
  }
  m_10002 = kk_std_core_int_parse_int(_x_x174, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_integer_t _x_x177;
  if (kk_std_core_types__is_Nothing(m_10002, _ctx)) {
    _x_x177 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x110 = m_10002._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x110, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10002, _ctx);
    _x_x177 = x; /*int*/
  }
  r = kk_main_run(_x_x177, _ctx); /*int*/
  kk_string_t _x_x178 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x178, _ctx); return kk_Unit;
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
    kk_string_t _x_x126;
    kk_define_string_literal(, _s_x127, 10, "state@main", _ctx)
    _x_x126 = kk_string_dup(_s_x127, _ctx); /*string*/
    kk_main__tag_state = kk_std_core_hnd__new_Htag(_x_x126, _ctx); /*hnd/htag<main/state>*/
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
