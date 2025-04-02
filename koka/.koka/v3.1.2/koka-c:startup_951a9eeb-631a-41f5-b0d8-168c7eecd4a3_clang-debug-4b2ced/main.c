// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,ndet> () */ 
  kk_std_core_types__list xs_10002 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10000;
  kk_string_t _x_x2;
  if (kk_std_core_types__is_Cons(xs_10002, _ctx)) {
    struct kk_std_core_types_Cons* _con_x3 = kk_std_core_types__as_Cons(xs_10002, _ctx);
    kk_box_t _box_x0 = _con_x3->head;
    kk_std_core_types__list _pat_0_0 = _con_x3->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x0);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10002, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10002, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10002, _ctx);
    }
    _x_x2 = x_0; /*string*/
  }
  else {
    _x_x2 = kk_string_empty(); /*string*/
  }
  m_10000 = kk_std_core_int_parse_int(_x_x2, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_std_core_types__maybe_drop(m_10000, _ctx);
  kk_string_t _x_x5 = kk_std_core_int_show(kk_integer_from_small(0), _ctx); /*string*/
  kk_std_core_console_printsln(_x_x5, _ctx); return kk_Unit;
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
