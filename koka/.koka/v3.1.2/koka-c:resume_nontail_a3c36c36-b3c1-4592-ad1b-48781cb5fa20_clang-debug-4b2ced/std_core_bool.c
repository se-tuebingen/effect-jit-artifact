// Koka generated module: std/core/bool, koka version: 3.1.2, platform: 64-bit
#include "std_core_bool.h"
 
// Compare two booleans with `False < True`.

kk_std_core_types__order kk_std_core_bool_cmp(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> order */ 
  if (x) {
    if (x) {
      if (y) {
        return kk_std_core_types__new_Eq(_ctx);
      }
      {
        return kk_std_core_types__new_Gt(_ctx);
      }
    }
    {
      return kk_std_core_types__new_Eq(_ctx);
    }
  }
  if (y) {
    return kk_std_core_types__new_Lt(_ctx);
  }
  if (x) {
    if (y) {
      return kk_std_core_types__new_Eq(_ctx);
    }
    {
      return kk_std_core_types__new_Gt(_ctx);
    }
  }
  {
    return kk_std_core_types__new_Eq(_ctx);
  }
}
 
// Order two booleans in ascending order.

kk_std_core_types__order2 kk_std_core_bool_order2(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> order2<bool> */ 
  bool _match_x14;
  if (x) {
    _match_x14 = y; /*bool*/
  }
  else {
    if (y) {
      _match_x14 = false; /*bool*/
    }
    else {
      _match_x14 = true; /*bool*/
    }
  }
  if (_match_x14) {
    return kk_std_core_types__new_Eq2(kk_bool_box(x), _ctx);
  }
  if (x) {
    return kk_std_core_types__new_Gt2(kk_bool_box(y), kk_bool_box(x), _ctx);
  }
  if (y) {
    return kk_std_core_types__new_Lt2(kk_bool_box(x), kk_bool_box(y), _ctx);
  }
  {
    return kk_std_core_types__new_Gt2(kk_bool_box(y), kk_bool_box(x), _ctx);
  }
}

// initialization
void kk_std_core_bool__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_bool__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_types__done(_ctx);
}
