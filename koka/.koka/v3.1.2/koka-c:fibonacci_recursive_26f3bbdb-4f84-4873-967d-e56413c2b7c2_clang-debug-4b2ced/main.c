// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"

kk_integer_t kk_main_fibonacci(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  bool _match_x2 = kk_integer_eq_borrow(n,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x2) {
    kk_integer_drop(n, _ctx);
    return kk_integer_from_small(0);
  }
  {
    bool _match_x3 = kk_integer_eq_borrow(n,(kk_integer_from_small(1)),kk_context()); /*bool*/;
    if (_match_x3) {
      kk_integer_drop(n, _ctx);
      return kk_integer_from_small(1);
    }
    {
      kk_integer_t x_10000;
      kk_integer_t _x_x5;
      kk_integer_t _x_x6 = kk_integer_dup(n, _ctx); /*int*/
      _x_x5 = kk_integer_add_small_const(_x_x6, -1, _ctx); /*int*/
      x_10000 = kk_main_fibonacci(_x_x5, _ctx); /*int*/
      kk_integer_t y_10001;
      kk_integer_t _x_x7 = kk_integer_add_small_const(n, -2, _ctx); /*int*/
      y_10001 = kk_main_fibonacci(_x_x7, _ctx); /*int*/
      return kk_integer_add(x_10000,y_10001,kk_context());
    }
  }
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10008 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10006;
  kk_string_t _x_x8;
  if (kk_std_core_types__is_Cons(xs_10008, _ctx)) {
    struct kk_std_core_types_Cons* _con_x9 = kk_std_core_types__as_Cons(xs_10008, _ctx);
    kk_box_t _box_x0 = _con_x9->head;
    kk_std_core_types__list _pat_0_0 = _con_x9->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x0);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10008, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10008, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10008, _ctx);
    }
    _x_x8 = x_0; /*string*/
  }
  else {
    _x_x8 = kk_string_empty(); /*string*/
  }
  m_10006 = kk_std_core_int_parse_int(_x_x8, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_integer_t _x_x11;
  if (kk_std_core_types__is_Nothing(m_10006, _ctx)) {
    _x_x11 = kk_integer_from_small(5); /*int*/
  }
  else {
    kk_box_t _box_x1 = m_10006._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x1, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_10006, _ctx);
    _x_x11 = x; /*int*/
  }
  r = kk_main_fibonacci(_x_x11, _ctx); /*int*/
  kk_string_t _x_x12 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x12, _ctx); return kk_Unit;
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
}

// termination
void kk_main__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
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
