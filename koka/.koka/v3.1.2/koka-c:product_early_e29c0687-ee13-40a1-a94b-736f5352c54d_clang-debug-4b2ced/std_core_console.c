// Koka generated module: std/core/console, koka version: 3.1.2, platform: 64-bit
#include "std_core_console.h"

kk_ref_t kk_std_core_console_redirect;
 
// Print a string to the console

kk_unit_t kk_std_core_console_xprints(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> console () */ 
  kk_print(s,kk_context()); return kk_Unit;
}
 
// Print a string to the console, including a final newline character.

kk_unit_t kk_std_core_console_xprintsln(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> console () */ 
  kk_println(s,kk_context()); return kk_Unit;
}

kk_unit_t kk_std_core_console_prints(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> console () */ 
  kk_std_core_types__maybe _match_x30;
  kk_box_t _x_x31;
  kk_ref_t _x_x32 = kk_ref_dup(kk_std_core_console_redirect, _ctx); /*ref<global,maybe<(string) -> console/console ()>>*/
  _x_x31 = kk_ref_get(_x_x32,kk_context()); /*209*/
  _match_x30 = kk_std_core_types__maybe_unbox(_x_x31, KK_OWNED, _ctx); /*maybe<(string) -> console/console ()>*/
  if (kk_std_core_types__is_Nothing(_match_x30, _ctx)) {
    kk_std_core_console_xprints(s, _ctx); return kk_Unit;
  }
  {
    kk_box_t _fun_unbox_x6 = _match_x30._cons.Just.value;
    kk_box_t _x_x33;
    kk_function_t _x_x34 = kk_function_unbox(_fun_unbox_x6, _ctx); /*(7) -> console/console 8*/
    _x_x33 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x34, (_x_x34, kk_string_box(s), _ctx), _ctx); /*8*/
    kk_unit_unbox(_x_x33); return kk_Unit;
  }
}
 
// Redirect `print` and `println` calls to a specified function.


// lift anonymous function
struct kk_std_core_console_print_redirect_fun38__t {
  struct kk_function_s _base;
  kk_function_t print;
};
static kk_box_t kk_std_core_console_print_redirect_fun38(kk_function_t _fself, kk_box_t _b_x14, kk_context_t* _ctx);
static kk_function_t kk_std_core_console_new_print_redirect_fun38(kk_function_t print, kk_context_t* _ctx) {
  struct kk_std_core_console_print_redirect_fun38__t* _self = kk_function_alloc_as(struct kk_std_core_console_print_redirect_fun38__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_console_print_redirect_fun38, kk_context());
  _self->print = print;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_console_print_redirect_fun38(kk_function_t _fself, kk_box_t _b_x14, kk_context_t* _ctx) {
  struct kk_std_core_console_print_redirect_fun38__t* _self = kk_function_as(struct kk_std_core_console_print_redirect_fun38__t*, _fself, _ctx);
  kk_function_t print = _self->print; /* (msg : string) -> console/console () */
  kk_drop_match(_self, {kk_function_dup(print, _ctx);}, {}, _ctx)
  kk_unit_t _x_x39 = kk_Unit;
  kk_string_t _x_x40 = kk_string_unbox(_b_x14); /*string*/
  kk_function_call(kk_unit_t, (kk_function_t, kk_string_t, kk_context_t*), print, (print, _x_x40, _ctx), _ctx);
  return kk_unit_box(_x_x39);
}

kk_unit_t kk_std_core_console_print_redirect(kk_function_t print, kk_context_t* _ctx) { /* (print : (msg : string) -> console ()) -> <st<global>,console,ndet> () */ 
  kk_box_t _x_x36;
  kk_std_core_types__maybe _x_x37 = kk_std_core_types__new_Just(kk_function_box(kk_std_core_console_new_print_redirect_fun38(print, _ctx), _ctx), _ctx); /*maybe<91>*/
  _x_x36 = kk_std_core_types__maybe_box(_x_x37, _ctx); /*195*/
  kk_ref_set_borrow(kk_std_core_console_redirect,_x_x36,kk_context()); return kk_Unit;
}

kk_unit_t kk_std_core_console_printsln(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> console () */ 
  kk_std_core_types__maybe _match_x29;
  kk_box_t _x_x41;
  kk_ref_t _x_x42 = kk_ref_dup(kk_std_core_console_redirect, _ctx); /*ref<global,maybe<(string) -> console/console ()>>*/
  _x_x41 = kk_ref_get(_x_x42,kk_context()); /*1451*/
  _match_x29 = kk_std_core_types__maybe_unbox(_x_x41, KK_OWNED, _ctx); /*maybe<(string) -> console/console ()>*/
  if (kk_std_core_types__is_Nothing(_match_x29, _ctx)) {
    kk_std_core_console_xprintsln(s, _ctx); return kk_Unit;
  }
  {
    kk_box_t _fun_unbox_x24 = _match_x29._cons.Just.value;
    kk_string_t _b_x27;
    kk_string_t _x_x43;
    kk_define_string_literal(, _s_x44, 1, "\n", _ctx)
    _x_x43 = kk_string_dup(_s_x44, _ctx); /*string*/
    _b_x27 = kk_std_core_types__lp__plus__plus__rp_(s, _x_x43, _ctx); /*string*/
    kk_box_t _x_x45;
    kk_function_t _x_x46 = kk_function_unbox(_fun_unbox_x24, _ctx); /*(25) -> console/console 26*/
    _x_x45 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x46, (_x_x46, kk_string_box(_b_x27), _ctx), _ctx); /*26*/
    kk_unit_unbox(_x_x45); return kk_Unit;
  }
}

// initialization
void kk_std_core_console__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_unsafe__init(_ctx);
  kk_std_core_hnd__init(_ctx);
  kk_std_core_string__init(_ctx);
  kk_std_core_show__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
  {
    kk_std_core_console_redirect = kk_ref_alloc((kk_std_core_types__maybe_box(kk_std_core_types__new_Nothing(_ctx), _ctx)),kk_context()); /*ref<global,maybe<(string) -> console/console ()>>*/
  }
}

// termination
void kk_std_core_console__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_ref_drop(kk_std_core_console_redirect, _ctx);
  kk_std_core_show__done(_ctx);
  kk_std_core_string__done(_ctx);
  kk_std_core_hnd__done(_ctx);
  kk_std_core_unsafe__done(_ctx);
  kk_std_core_types__done(_ctx);
}
