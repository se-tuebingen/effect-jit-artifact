// Koka generated module: std/core/char, koka version: 3.1.2, platform: 64-bit
#include "std_core_char.h"
 
// Tests if a character is an element of `" \t\n\r"`

bool kk_std_core_char_is_white(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> bool */ 
  bool _match_x28 = (c == (' ')); /*bool*/;
  if (_match_x28) {
    return true;
  }
  {
    bool _match_x29 = (c == 0x0009); /*bool*/;
    if (_match_x29) {
      return true;
    }
    {
      bool _match_x30 = (c == 0x000A); /*bool*/;
      if (_match_x30) {
        return true;
      }
      {
        return (c == 0x000D);
      }
    }
  }
}
 
// Order two characters in ascending order.

kk_std_core_types__order2 kk_std_core_char_order2(kk_char_t x, kk_char_t y, kk_context_t* _ctx) { /* (x : char, y : char) -> order2<char> */ 
  bool _match_x26 = (x == y); /*bool*/;
  if (_match_x26) {
    return kk_std_core_types__new_Eq2(kk_char_box(x, _ctx), _ctx);
  }
  {
    bool _match_x27 = (x < y); /*bool*/;
    if (_match_x27) {
      return kk_std_core_types__new_Lt2(kk_char_box(x, _ctx), kk_char_box(y, _ctx), _ctx);
    }
    {
      return kk_std_core_types__new_Gt2(kk_char_box(y, _ctx), kk_char_box(x, _ctx), _ctx);
    }
  }
}
 
// Is the character an ASCII letter?

bool kk_std_core_char_is_alpha(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> bool */ 
  bool _match_x22 = (c >= ('a')); /*bool*/;
  if (_match_x22) {
    bool _match_x24 = (c <= ('z')); /*bool*/;
    if (_match_x24) {
      return true;
    }
    {
      bool _match_x25 = (c >= ('A')); /*bool*/;
      if (_match_x25) {
        return (c <= ('Z'));
      }
      {
        return false;
      }
    }
  }
  {
    bool _match_x23 = (c >= ('A')); /*bool*/;
    if (_match_x23) {
      return (c <= ('Z'));
    }
    {
      return false;
    }
  }
}
 
// Is the character an ASCII hexa-decimal digit?

bool kk_std_core_char_is_hex_digit(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> bool */ 
  bool _match_x10 = (c >= ('0')); /*bool*/;
  if (_match_x10) {
    bool _match_x15 = (c <= ('9')); /*bool*/;
    if (_match_x15) {
      return true;
    }
    {
      bool _match_x16 = (c >= ('a')); /*bool*/;
      if (_match_x16) {
        bool _match_x18 = (c <= ('f')); /*bool*/;
        if (_match_x18) {
          return true;
        }
        {
          bool _match_x19 = (c >= ('A')); /*bool*/;
          if (_match_x19) {
            return (c <= ('F'));
          }
          {
            return false;
          }
        }
      }
      {
        bool _match_x17 = (c >= ('A')); /*bool*/;
        if (_match_x17) {
          return (c <= ('F'));
        }
        {
          return false;
        }
      }
    }
  }
  {
    bool _match_x11 = (c >= ('a')); /*bool*/;
    if (_match_x11) {
      bool _match_x13 = (c <= ('f')); /*bool*/;
      if (_match_x13) {
        return true;
      }
      {
        bool _match_x14 = (c >= ('A')); /*bool*/;
        if (_match_x14) {
          return (c <= ('F'));
        }
        {
          return false;
        }
      }
    }
    {
      bool _match_x12 = (c >= ('A')); /*bool*/;
      if (_match_x12) {
        return (c <= ('F'));
      }
      {
        return false;
      }
    }
  }
}

// initialization
void kk_std_core_char__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_int__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_char__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_int__done(_ctx);
  kk_std_core_types__done(_ctx);
}
