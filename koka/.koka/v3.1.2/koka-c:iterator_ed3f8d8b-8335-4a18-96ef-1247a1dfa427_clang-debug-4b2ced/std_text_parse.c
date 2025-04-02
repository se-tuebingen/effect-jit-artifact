// Koka generated module: std/text/parse, koka version: 3.1.2, platform: 64-bit
#include "std_text_parse.h"
 
// runtime tag for the effect `:parse`

kk_std_core_hnd__htag kk_std_text_parse__tag_parse;
 
// handler for the effect `:parse`

kk_box_t kk_std_text_parse__handle_parse(kk_std_text_parse__parse hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : parse<e,b>, ret : (res : a) -> e b, action : () -> <parse|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x853 = kk_std_core_hnd__htag_dup(kk_std_text_parse__tag_parse, _ctx); /*hnd/htag<std/text/parse/parse>*/
  return kk_std_core_hnd__hhandle(_x_x853, kk_std_text_parse__parse_box(hnd, _ctx), ret, action, _ctx);
}

kk_std_core_types__either kk_std_text_parse_either(kk_std_text_parse__parse_error perr, kk_context_t* _ctx) { /* forall<a> (perr : parse-error<a>) -> either<string,a> */ 
  if (kk_std_text_parse__is_ParseOk(perr, _ctx)) {
    struct kk_std_text_parse_ParseOk* _con_x858 = kk_std_text_parse__as_ParseOk(perr, _ctx);
    kk_std_core_sslice__sslice _pat_0 = _con_x858->rest;
    kk_box_t x = _con_x858->result;
    if kk_likely(kk_datatype_ptr_is_unique(perr, _ctx)) {
      kk_std_core_sslice__sslice_drop(_pat_0, _ctx);
      kk_datatype_ptr_free(perr, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_datatype_ptr_decref(perr, _ctx);
    }
    return kk_std_core_types__new_Right(x, _ctx);
  }
  {
    struct kk_std_text_parse_ParseError* _con_x859 = kk_std_text_parse__as_ParseError(perr, _ctx);
    kk_std_core_sslice__sslice _pat_5 = _con_x859->rest;
    kk_string_t msg = _con_x859->msg;
    if kk_likely(kk_datatype_ptr_is_unique(perr, _ctx)) {
      kk_std_core_sslice__sslice_drop(_pat_5, _ctx);
      kk_datatype_ptr_free(perr, _ctx);
    }
    else {
      kk_string_dup(msg, _ctx);
      kk_datatype_ptr_decref(perr, _ctx);
    }
    return kk_std_core_types__new_Left(kk_string_box(msg), _ctx);
  }
}
extern kk_box_t kk_std_text_parse_satisfy_fun865(kk_function_t _fself, kk_box_t _b_x31, kk_context_t* _ctx) {
  struct kk_std_text_parse_satisfy_fun865__t* _self = kk_function_as(struct kk_std_text_parse_satisfy_fun865__t*, _fself, _ctx);
  kk_function_t pred = _self->pred; /* (sslice/sslice) -> maybe<(777, sslice/sslice)> */
  kk_drop_match(_self, {kk_function_dup(pred, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _x_x866;
  kk_std_core_sslice__sslice _x_x867 = kk_std_core_sslice__sslice_unbox(_b_x31, KK_OWNED, _ctx); /*sslice/sslice*/
  _x_x866 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, kk_std_core_sslice__sslice, kk_context_t*), pred, (pred, _x_x867, _ctx), _ctx); /*maybe<(777, sslice/sslice)>*/
  return kk_std_core_types__maybe_box(_x_x866, _ctx);
}
 
// monadic lift

kk_box_t kk_std_text_parse__mlift_satisfy_fail_10164(kk_string_t msg, kk_std_core_types__maybe _y_x10069, kk_context_t* _ctx) { /* forall<a> (msg : string, maybe<a>) -> parse a */ 
  if (kk_std_core_types__is_Nothing(_y_x10069, _ctx)) {
    kk_std_core_hnd__ev ev_10194 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<std/text/parse/parse>*/;
    {
      struct kk_std_core_hnd_Ev* _con_x868 = kk_std_core_hnd__as_Ev(ev_10194, _ctx);
      kk_box_t _box_x32 = _con_x868->hnd;
      int32_t m = _con_x868->marker;
      kk_std_text_parse__parse h = kk_std_text_parse__parse_unbox(_box_x32, KK_BORROWED, _ctx);
      kk_std_text_parse__parse_dup(h, _ctx);
      {
        struct kk_std_text_parse__Hnd_parse* _con_x869 = kk_std_text_parse__as_Hnd_parse(h, _ctx);
        kk_integer_t _pat_0_1 = _con_x869->_cfc;
        kk_std_core_hnd__clause0 _pat_1_0 = _con_x869->_fun_current_input;
        kk_std_core_hnd__clause1 _ctl_fail = _con_x869->_ctl_fail;
        kk_std_core_hnd__clause0 _pat_2_0 = _con_x869->_ctl_pick;
        kk_std_core_hnd__clause1 _pat_3 = _con_x869->_fun_satisfy;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_std_core_hnd__clause1_drop(_pat_3, _ctx);
          kk_std_core_hnd__clause0_drop(_pat_2_0, _ctx);
          kk_std_core_hnd__clause0_drop(_pat_1_0, _ctx);
          kk_integer_drop(_pat_0_1, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_ctl_fail, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x36 = _ctl_fail.clause;
          return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x36, (_fun_unbox_x36, m, ev_10194, kk_string_box(msg), _ctx), _ctx);
        }
      }
    }
  }
  {
    kk_box_t x_0 = _y_x10069._cons.Just.value;
    kk_string_drop(msg, _ctx);
    return x_0;
  }
}


// lift anonymous function
struct kk_std_text_parse_satisfy_fail_fun873__t {
  struct kk_function_s _base;
  kk_function_t pred;
};
static kk_box_t kk_std_text_parse_satisfy_fail_fun873(kk_function_t _fself, kk_box_t _b_x53, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_satisfy_fail_fun873(kk_function_t pred, kk_context_t* _ctx) {
  struct kk_std_text_parse_satisfy_fail_fun873__t* _self = kk_function_alloc_as(struct kk_std_text_parse_satisfy_fail_fun873__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_satisfy_fail_fun873, kk_context());
  _self->pred = pred;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_satisfy_fail_fun873(kk_function_t _fself, kk_box_t _b_x53, kk_context_t* _ctx) {
  struct kk_std_text_parse_satisfy_fail_fun873__t* _self = kk_function_as(struct kk_std_text_parse_satisfy_fail_fun873__t*, _fself, _ctx);
  kk_function_t pred = _self->pred; /* (sslice/sslice) -> maybe<(810, sslice/sslice)> */
  kk_drop_match(_self, {kk_function_dup(pred, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _x_x874;
  kk_std_core_sslice__sslice _x_x875 = kk_std_core_sslice__sslice_unbox(_b_x53, KK_OWNED, _ctx); /*sslice/sslice*/
  _x_x874 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, kk_std_core_sslice__sslice, kk_context_t*), pred, (pred, _x_x875, _ctx), _ctx); /*maybe<(810, sslice/sslice)>*/
  return kk_std_core_types__maybe_box(_x_x874, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_satisfy_fail_fun876__t {
  struct kk_function_s _base;
  kk_string_t msg;
};
static kk_box_t kk_std_text_parse_satisfy_fail_fun876(kk_function_t _fself, kk_box_t _b_x55, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_satisfy_fail_fun876(kk_string_t msg, kk_context_t* _ctx) {
  struct kk_std_text_parse_satisfy_fail_fun876__t* _self = kk_function_alloc_as(struct kk_std_text_parse_satisfy_fail_fun876__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_satisfy_fail_fun876, kk_context());
  _self->msg = msg;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_satisfy_fail_fun876(kk_function_t _fself, kk_box_t _b_x55, kk_context_t* _ctx) {
  struct kk_std_text_parse_satisfy_fail_fun876__t* _self = kk_function_as(struct kk_std_text_parse_satisfy_fail_fun876__t*, _fself, _ctx);
  kk_string_t msg = _self->msg; /* string */
  kk_drop_match(_self, {kk_string_dup(msg, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _x_x877 = kk_std_core_types__maybe_unbox(_b_x55, KK_OWNED, _ctx); /*maybe<810>*/
  return kk_std_text_parse__mlift_satisfy_fail_10164(msg, _x_x877, _ctx);
}

kk_box_t kk_std_text_parse_satisfy_fail(kk_string_t msg, kk_function_t pred, kk_context_t* _ctx) { /* forall<a> (msg : string, pred : (sslice/sslice) -> maybe<(a, sslice/sslice)>) -> parse a */ 
  kk_std_core_hnd__ev ev_10200 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<std/text/parse/parse>*/;
  kk_std_core_types__maybe x_10197;
  kk_box_t _x_x870;
  {
    struct kk_std_core_hnd_Ev* _con_x871 = kk_std_core_hnd__as_Ev(ev_10200, _ctx);
    kk_box_t _box_x40 = _con_x871->hnd;
    int32_t m = _con_x871->marker;
    kk_std_text_parse__parse h = kk_std_text_parse__parse_unbox(_box_x40, KK_BORROWED, _ctx);
    kk_std_text_parse__parse_dup(h, _ctx);
    {
      struct kk_std_text_parse__Hnd_parse* _con_x872 = kk_std_text_parse__as_Hnd_parse(h, _ctx);
      kk_integer_t _pat_0 = _con_x872->_cfc;
      kk_std_core_hnd__clause0 _pat_1_1 = _con_x872->_fun_current_input;
      kk_std_core_hnd__clause1 _pat_2 = _con_x872->_ctl_fail;
      kk_std_core_hnd__clause0 _pat_3 = _con_x872->_ctl_pick;
      kk_std_core_hnd__clause1 _fun_satisfy = _con_x872->_fun_satisfy;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause0_drop(_pat_3, _ctx);
        kk_std_core_hnd__clause1_drop(_pat_2, _ctx);
        kk_std_core_hnd__clause0_drop(_pat_1_1, _ctx);
        kk_integer_drop(_pat_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_fun_satisfy, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x47 = _fun_satisfy.clause;
        _x_x870 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x47, (_fun_unbox_x47, m, ev_10200, kk_function_box(kk_std_text_parse_new_satisfy_fail_fun873(pred, _ctx), _ctx), _ctx), _ctx); /*46*/
      }
    }
  }
  x_10197 = kk_std_core_types__maybe_unbox(_x_x870, KK_OWNED, _ctx); /*maybe<810>*/
  if (kk_yielding(kk_context())) {
    kk_std_core_types__maybe_drop(x_10197, _ctx);
    return kk_std_core_hnd_yield_extend(kk_std_text_parse_new_satisfy_fail_fun876(msg, _ctx), _ctx);
  }
  if (kk_std_core_types__is_Nothing(x_10197, _ctx)) {
    kk_std_core_hnd__ev ev_0_10203 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<std/text/parse/parse>*/;
    {
      struct kk_std_core_hnd_Ev* _con_x878 = kk_std_core_hnd__as_Ev(ev_0_10203, _ctx);
      kk_box_t _box_x56 = _con_x878->hnd;
      int32_t m_0 = _con_x878->marker;
      kk_std_text_parse__parse h_0 = kk_std_text_parse__parse_unbox(_box_x56, KK_BORROWED, _ctx);
      kk_std_text_parse__parse_dup(h_0, _ctx);
      {
        struct kk_std_text_parse__Hnd_parse* _con_x879 = kk_std_text_parse__as_Hnd_parse(h_0, _ctx);
        kk_integer_t _pat_0_2 = _con_x879->_cfc;
        kk_std_core_hnd__clause0 _pat_1_2 = _con_x879->_fun_current_input;
        kk_std_core_hnd__clause1 _ctl_fail = _con_x879->_ctl_fail;
        kk_std_core_hnd__clause0 _pat_2_1 = _con_x879->_ctl_pick;
        kk_std_core_hnd__clause1 _pat_3_1 = _con_x879->_fun_satisfy;
        if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
          kk_std_core_hnd__clause1_drop(_pat_3_1, _ctx);
          kk_std_core_hnd__clause0_drop(_pat_2_1, _ctx);
          kk_std_core_hnd__clause0_drop(_pat_1_2, _ctx);
          kk_integer_drop(_pat_0_2, _ctx);
          kk_datatype_ptr_free(h_0, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_ctl_fail, _ctx);
          kk_datatype_ptr_decref(h_0, _ctx);
        }
        {
          kk_function_t _fun_unbox_x60 = _ctl_fail.clause;
          return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x60, (_fun_unbox_x60, m_0, ev_0_10203, kk_string_box(msg), _ctx), _ctx);
        }
      }
    }
  }
  {
    kk_box_t x_2 = x_10197._cons.Just.value;
    kk_string_drop(msg, _ctx);
    return x_2;
  }
}


// lift anonymous function
struct kk_std_text_parse_char_is_fun881__t {
  struct kk_function_s _base;
  kk_function_t pred;
};
static kk_std_core_types__maybe kk_std_text_parse_char_is_fun881(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_char_is_fun881(kk_function_t pred, kk_context_t* _ctx) {
  struct kk_std_text_parse_char_is_fun881__t* _self = kk_function_alloc_as(struct kk_std_text_parse_char_is_fun881__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_char_is_fun881, kk_context());
  _self->pred = pred;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_char_is_fun881(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  struct kk_std_text_parse_char_is_fun881__t* _self = kk_function_as(struct kk_std_text_parse_char_is_fun881__t*, _fself, _ctx);
  kk_function_t pred = _self->pred; /* (char) -> bool */
  kk_drop_match(_self, {kk_function_dup(pred, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _match_x815 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x815, _ctx)) {
    kk_box_t _box_x66 = _match_x815._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x66, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0, _ctx)) {
      kk_box_t _box_x67 = _pat_0.fst;
      kk_box_t _box_x68 = _pat_0.snd;
      kk_char_t c = kk_char_unbox(_box_x67, KK_BORROWED, _ctx);
      kk_function_t _x_x882 = kk_function_dup(pred, _ctx); /*(char) -> bool*/
      if (kk_function_call(bool, (kk_function_t, kk_char_t, kk_context_t*), _x_x882, (_x_x882, c, _ctx), _ctx)) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x68, KK_BORROWED, _ctx);
        kk_function_drop(pred, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x815, _ctx);
        kk_box_t _x_x883;
        kk_std_core_types__tuple2 _x_x884 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x883 = kk_std_core_types__tuple2_box(_x_x884, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x883, _ctx);
      }
    }
  }
  {
    kk_function_drop(pred, _ctx);
    kk_std_core_types__maybe_drop(_match_x815, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_char_t kk_std_text_parse_char_is(kk_string_t msg, kk_function_t pred, kk_context_t* _ctx) { /* (msg : string, pred : (char) -> bool) -> parse char */ 
  kk_box_t _x_x880 = kk_std_text_parse_satisfy_fail(msg, kk_std_text_parse_new_char_is_fun881(pred, _ctx), _ctx); /*810*/
  return kk_char_unbox(_x_x880, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_alpha_fun888__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_alpha_fun888(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_alpha_fun888(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_alpha_fun888, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_alpha_fun888(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__maybe _match_x814 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x814, _ctx)) {
    kk_box_t _box_x79 = _match_x814._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x79, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0, _ctx)) {
      kk_box_t _box_x80 = _pat_0.fst;
      kk_box_t _box_x81 = _pat_0.snd;
      kk_char_t c = kk_char_unbox(_box_x80, KK_BORROWED, _ctx);
      if (kk_std_core_char_is_alpha(c, _ctx)) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x81, KK_BORROWED, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x814, _ctx);
        kk_box_t _x_x889;
        kk_std_core_types__tuple2 _x_x890 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x889 = kk_std_core_types__tuple2_box(_x_x890, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x889, _ctx);
      }
    }
  }
  {
    kk_std_core_types__maybe_drop(_match_x814, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_char_t kk_std_text_parse_alpha(kk_context_t* _ctx) { /* () -> parse char */ 
  kk_box_t _x_x885;
  kk_string_t _x_x886;
  kk_define_string_literal(, _s_x887, 5, "alpha", _ctx)
  _x_x886 = kk_string_dup(_s_x887, _ctx); /*string*/
  _x_x885 = kk_std_text_parse_satisfy_fail(_x_x886, kk_std_text_parse_new_alpha_fun888(_ctx), _ctx); /*810*/
  return kk_char_unbox(_x_x885, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_alpha_num_fun894__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_alpha_num_fun894(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_alpha_num_fun894(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_alpha_num_fun894, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_alpha_num_fun894(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__maybe _match_x813 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x813, _ctx)) {
    kk_box_t _box_x92 = _match_x813._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x92, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0, _ctx)) {
      kk_box_t _box_x93 = _pat_0.fst;
      kk_box_t _box_x94 = _pat_0.snd;
      kk_char_t c = kk_char_unbox(_box_x93, KK_BORROWED, _ctx);
      if (kk_std_core_char_is_alpha_num(c, _ctx)) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x94, KK_BORROWED, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x813, _ctx);
        kk_box_t _x_x895;
        kk_std_core_types__tuple2 _x_x896 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x895 = kk_std_core_types__tuple2_box(_x_x896, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x895, _ctx);
      }
    }
  }
  {
    kk_std_core_types__maybe_drop(_match_x813, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_char_t kk_std_text_parse_alpha_num(kk_context_t* _ctx) { /* () -> parse char */ 
  kk_box_t _x_x891;
  kk_string_t _x_x892;
  kk_define_string_literal(, _s_x893, 9, "alpha-num", _ctx)
  _x_x892 = kk_string_dup(_s_x893, _ctx); /*string*/
  _x_x891 = kk_std_text_parse_satisfy_fail(_x_x892, kk_std_text_parse_new_alpha_num_fun894(_ctx), _ctx); /*810*/
  return kk_char_unbox(_x_x891, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_char_fun904__t {
  struct kk_function_s _base;
  kk_char_t c;
};
static kk_std_core_types__maybe kk_std_text_parse_char_fun904(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_char_fun904(kk_char_t c, kk_context_t* _ctx) {
  struct kk_std_text_parse_char_fun904__t* _self = kk_function_alloc_as(struct kk_std_text_parse_char_fun904__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_char_fun904, kk_context());
  _self->c = c;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_char_fun904(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  struct kk_std_text_parse_char_fun904__t* _self = kk_function_as(struct kk_std_text_parse_char_fun904__t*, _fself, _ctx);
  kk_char_t c = _self->c; /* char */
  kk_drop_match(_self, {kk_skip_dup(c, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _match_x812 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x812, _ctx)) {
    kk_box_t _box_x105 = _match_x812._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x105, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0, _ctx)) {
      kk_box_t _box_x106 = _pat_0.fst;
      kk_box_t _box_x107 = _pat_0.snd;
      kk_char_t c_0 = kk_char_unbox(_box_x106, KK_BORROWED, _ctx);
      if (c == c_0) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x107, KK_BORROWED, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x812, _ctx);
        kk_box_t _x_x905;
        kk_std_core_types__tuple2 _x_x906 = kk_std_core_types__new_Tuple2(kk_char_box(c_0, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x905 = kk_std_core_types__tuple2_box(_x_x906, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x905, _ctx);
      }
    }
  }
  {
    kk_std_core_types__maybe_drop(_match_x812, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_char_t kk_std_text_parse_char(kk_char_t c, kk_context_t* _ctx) { /* (c : char) -> parse char */ 
  kk_string_t msg_10006;
  kk_string_t _x_x897;
  kk_define_string_literal(, _s_x898, 1, "\'", _ctx)
  _x_x897 = kk_string_dup(_s_x898, _ctx); /*string*/
  kk_string_t _x_x899;
  kk_string_t _x_x900 = kk_std_core_show_show_char(c, _ctx); /*string*/
  kk_string_t _x_x901;
  kk_define_string_literal(, _s_x902, 1, "\'", _ctx)
  _x_x901 = kk_string_dup(_s_x902, _ctx); /*string*/
  _x_x899 = kk_std_core_types__lp__plus__plus__rp_(_x_x900, _x_x901, _ctx); /*string*/
  msg_10006 = kk_std_core_types__lp__plus__plus__rp_(_x_x897, _x_x899, _ctx); /*string*/
  kk_box_t _x_x903 = kk_std_text_parse_satisfy_fail(msg_10006, kk_std_text_parse_new_char_fun904(c, _ctx), _ctx); /*810*/
  return kk_char_unbox(_x_x903, KK_OWNED, _ctx);
}

kk_std_core_types__tuple2 kk_std_text_parse_next_while0(kk_std_core_sslice__sslice slice, kk_function_t pred, kk_std_core_types__list acc, kk_context_t* _ctx) { /* (slice : sslice/sslice, pred : (char) -> bool, acc : list<char>) -> (list<char>, sslice/sslice) */ 
  kk__tailcall: ;
  kk_std_core_types__maybe _match_x811;
  kk_std_core_sslice__sslice _x_x907 = kk_std_core_sslice__sslice_dup(slice, _ctx); /*sslice/sslice*/
  _match_x811 = kk_std_core_sslice_next(_x_x907, _ctx); /*maybe<(char, sslice/sslice)>*/
  if (kk_std_core_types__is_Just(_match_x811, _ctx)) {
    kk_box_t _box_x118 = _match_x811._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x118, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0, _ctx)) {
      kk_box_t _box_x119 = _pat_0.fst;
      kk_box_t _box_x120 = _pat_0.snd;
      kk_char_t c = kk_char_unbox(_box_x119, KK_BORROWED, _ctx);
      kk_function_t _x_x908 = kk_function_dup(pred, _ctx); /*(char) -> bool*/
      if (kk_function_call(bool, (kk_function_t, kk_char_t, kk_context_t*), _x_x908, (_x_x908, c, _ctx), _ctx)) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x120, KK_BORROWED, _ctx);
        kk_std_core_sslice__sslice_drop(slice, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x811, _ctx);
        { // tailcall
          kk_std_core_types__list _x_x909 = kk_std_core_types__new_Cons(kk_reuse_null, 0, kk_char_box(c, _ctx), acc, _ctx); /*list<82>*/
          slice = rest;
          acc = _x_x909;
          goto kk__tailcall;
        }
      }
    }
  }
  {
    kk_function_drop(pred, _ctx);
    kk_std_core_types__maybe_drop(_match_x811, _ctx);
    kk_std_core_types__list _b_x123_127 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), acc, _ctx); /*list<char>*/;
    return kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(_b_x123_127, _ctx), kk_std_core_sslice__sslice_box(slice, _ctx), _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_chars_are_fun911__t {
  struct kk_function_s _base;
  kk_function_t pred;
};
static kk_std_core_types__maybe kk_std_text_parse_chars_are_fun911(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_chars_are_fun911(kk_function_t pred, kk_context_t* _ctx) {
  struct kk_std_text_parse_chars_are_fun911__t* _self = kk_function_alloc_as(struct kk_std_text_parse_chars_are_fun911__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_chars_are_fun911, kk_context());
  _self->pred = pred;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_chars_are_fun911(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  struct kk_std_text_parse_chars_are_fun911__t* _self = kk_function_as(struct kk_std_text_parse_chars_are_fun911__t*, _fself, _ctx);
  kk_function_t pred = _self->pred; /* (char) -> bool */
  kk_drop_match(_self, {kk_function_dup(pred, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple2 _match_x810 = kk_std_text_parse_next_while0(slice, pred, kk_std_core_types__new_Nil(_ctx), _ctx); /*(list<char>, sslice/sslice)*/;
  {
    kk_box_t _box_x129 = _match_x810.fst;
    kk_box_t _box_x130 = _match_x810.snd;
    kk_std_core_types__list _pat_0 = kk_std_core_types__list_unbox(_box_x129, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice _pat_1 = kk_std_core_sslice__sslice_unbox(_box_x130, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Nil(_pat_0, _ctx)) {
      kk_std_core_types__tuple2_drop(_match_x810, _ctx);
      return kk_std_core_types__new_Nothing(_ctx);
    }
  }
  {
    kk_box_t _box_x131 = _match_x810.fst;
    kk_box_t _box_x132 = _match_x810.snd;
    kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x132, KK_BORROWED, _ctx);
    kk_std_core_types__list xs = kk_std_core_types__list_unbox(_box_x131, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(rest, _ctx);
    kk_std_core_types__list_dup(xs, _ctx);
    kk_std_core_types__tuple2_drop(_match_x810, _ctx);
    kk_box_t _x_x912;
    kk_std_core_types__tuple2 _x_x913 = kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(xs, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x912 = kk_std_core_types__tuple2_box(_x_x913, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x912, _ctx);
  }
}

kk_std_core_types__list kk_std_text_parse_chars_are(kk_string_t msg, kk_function_t pred, kk_context_t* _ctx) { /* (msg : string, pred : (char) -> bool) -> parse list<char> */ 
  kk_box_t _x_x910 = kk_std_text_parse_satisfy_fail(msg, kk_std_text_parse_new_chars_are_fun911(pred, _ctx), _ctx); /*810*/
  return kk_std_core_types__list_unbox(_x_x910, KK_OWNED, _ctx);
}
extern kk_box_t kk_std_text_parse_pick_fun916(kk_function_t _fself, int32_t _b_x150, kk_std_core_hnd__ev _b_x151, kk_context_t* _ctx) {
  struct kk_std_text_parse_pick_fun916__t* _self = kk_function_as(struct kk_std_text_parse_pick_fun916__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x146 = _self->_fun_unbox_x146; /* (hnd/marker<37,38>, hnd/ev<36>) -> 37 35 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x146, _ctx);}, {}, _ctx)
  bool _x_x917;
  int32_t _b_x147_158 = _b_x150; /*hnd/marker<3233,3234>*/;
  kk_std_core_hnd__ev _b_x148_159 = _b_x151; /*hnd/ev<std/text/parse/parse>*/;
  kk_box_t _x_x918 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x146, (_fun_unbox_x146, _b_x147_158, _b_x148_159, _ctx), _ctx); /*35*/
  _x_x917 = kk_bool_unbox(_x_x918); /*bool*/
  return kk_bool_box(_x_x917);
}
 
// monadic lift

kk_box_t kk_std_text_parse__mlift_choose_10165(kk_function_t p_0, kk_std_core_types__list pp, bool _y_x10082, kk_context_t* _ctx) { /* forall<a,e> (p@0 : parser<e,a>, pp : list<parser<e,a>>, bool) -> <parse|e> a */ 
  if (_y_x10082) {
    kk_std_core_types__list_drop(pp, _ctx);
    return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), p_0, (p_0, _ctx), _ctx);
  }
  {
    kk_function_drop(p_0, _ctx);
    return kk_std_text_parse_choose(pp, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_choose_fun921__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_choose_fun921(kk_function_t _fself, kk_box_t _b_x171, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_choose_fun921(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_choose_fun921, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_choose_fun921(kk_function_t _fself, kk_box_t _b_x171, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_10208 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<std/text/parse/parse>*/;
  {
    struct kk_std_core_hnd_Ev* _con_x922 = kk_std_core_hnd__as_Ev(ev_10208, _ctx);
    kk_box_t _box_x160 = _con_x922->hnd;
    int32_t m = _con_x922->marker;
    kk_std_text_parse__parse h = kk_std_text_parse__parse_unbox(_box_x160, KK_BORROWED, _ctx);
    kk_std_text_parse__parse_dup(h, _ctx);
    {
      struct kk_std_text_parse__Hnd_parse* _con_x923 = kk_std_text_parse__as_Hnd_parse(h, _ctx);
      kk_integer_t _pat_0_1 = _con_x923->_cfc;
      kk_std_core_hnd__clause0 _pat_1_0 = _con_x923->_fun_current_input;
      kk_std_core_hnd__clause1 _ctl_fail = _con_x923->_ctl_fail;
      kk_std_core_hnd__clause0 _pat_2_0 = _con_x923->_ctl_pick;
      kk_std_core_hnd__clause1 _pat_3_0 = _con_x923->_fun_satisfy;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause1_drop(_pat_3_0, _ctx);
        kk_std_core_hnd__clause0_drop(_pat_2_0, _ctx);
        kk_std_core_hnd__clause0_drop(_pat_1_0, _ctx);
        kk_integer_drop(_pat_0_1, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_ctl_fail, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x164 = _ctl_fail.clause;
        return kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x164, (_fun_unbox_x164, m, ev_10208, _b_x171, _ctx), _ctx);
      }
    }
  }
}


// lift anonymous function
struct kk_std_text_parse_choose_fun932__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_choose_fun932(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_choose_fun932(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_choose_fun932, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_choose_fun932(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_0_10214 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<std/text/parse/parse>*/;
  bool _x_x933;
  {
    struct kk_std_core_hnd_Ev* _con_x934 = kk_std_core_hnd__as_Ev(ev_0_10214, _ctx);
    kk_box_t _box_x178 = _con_x934->hnd;
    int32_t m_0 = _con_x934->marker;
    kk_std_text_parse__parse h_0 = kk_std_text_parse__parse_unbox(_box_x178, KK_BORROWED, _ctx);
    kk_std_text_parse__parse_dup(h_0, _ctx);
    {
      struct kk_std_text_parse__Hnd_parse* _con_x935 = kk_std_text_parse__as_Hnd_parse(h_0, _ctx);
      kk_integer_t _pat_0_2 = _con_x935->_cfc;
      kk_std_core_hnd__clause0 _pat_1_2 = _con_x935->_fun_current_input;
      kk_std_core_hnd__clause1 _pat_2_2 = _con_x935->_ctl_fail;
      kk_std_core_hnd__clause0 _ctl_pick = _con_x935->_ctl_pick;
      kk_std_core_hnd__clause1 _pat_3_1 = _con_x935->_fun_satisfy;
      if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
        kk_std_core_hnd__clause1_drop(_pat_3_1, _ctx);
        kk_std_core_hnd__clause1_drop(_pat_2_2, _ctx);
        kk_std_core_hnd__clause0_drop(_pat_1_2, _ctx);
        kk_integer_drop(_pat_0_2, _ctx);
        kk_datatype_ptr_free(h_0, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_pick, _ctx);
        kk_datatype_ptr_decref(h_0, _ctx);
      }
      {
        kk_function_t _fun_unbox_x181 = _ctl_pick.clause;
        kk_function_t _bv_x187 = _fun_unbox_x181; /*(hnd/marker<426,428>, hnd/ev<427>) -> 425 424*/;
        kk_box_t _x_x936 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x187, (_bv_x187, m_0, ev_0_10214, _ctx), _ctx); /*424*/
        _x_x933 = kk_bool_unbox(_x_x936); /*bool*/
      }
    }
  }
  return kk_bool_box(_x_x933);
}


// lift anonymous function
struct kk_std_text_parse_choose_fun937__t {
  struct kk_function_s _base;
  kk_function_t p_0_0;
  kk_std_core_types__list pp_0;
};
static kk_box_t kk_std_text_parse_choose_fun937(kk_function_t _fself, kk_box_t _b_x200, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_choose_fun937(kk_function_t p_0_0, kk_std_core_types__list pp_0, kk_context_t* _ctx) {
  struct kk_std_text_parse_choose_fun937__t* _self = kk_function_alloc_as(struct kk_std_text_parse_choose_fun937__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_choose_fun937, kk_context());
  _self->p_0_0 = p_0_0;
  _self->pp_0 = pp_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_choose_fun937(kk_function_t _fself, kk_box_t _b_x200, kk_context_t* _ctx) {
  struct kk_std_text_parse_choose_fun937__t* _self = kk_function_as(struct kk_std_text_parse_choose_fun937__t*, _fself, _ctx);
  kk_function_t p_0_0 = _self->p_0_0; /* std/text/parse/parser<1145,1144> */
  kk_std_core_types__list pp_0 = _self->pp_0; /* list<std/text/parse/parser<1145,1144>> */
  kk_drop_match(_self, {kk_function_dup(p_0_0, _ctx);kk_std_core_types__list_dup(pp_0, _ctx);}, {}, _ctx)
  bool _x_x938 = kk_bool_unbox(_b_x200); /*bool*/
  return kk_std_text_parse__mlift_choose_10165(p_0_0, pp_0, _x_x938, _ctx);
}

kk_box_t kk_std_text_parse_choose(kk_std_core_types__list ps, kk_context_t* _ctx) { /* forall<a,e> (ps : list<parser<e,a>>) -> <parse|e> a */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Nil(ps, _ctx)) {
    kk_ssize_t _b_x168_201;
    kk_std_core_hnd__htag _x_x920 = kk_std_core_hnd__htag_dup(kk_std_text_parse__tag_parse, _ctx); /*hnd/htag<std/text/parse/parse>*/
    _b_x168_201 = kk_std_core_hnd__evv_index(_x_x920, _ctx); /*hnd/ev-index*/
    kk_box_t _x_x924;
    kk_string_t _x_x925;
    kk_define_string_literal(, _s_x926, 23, "no further alternatives", _ctx)
    _x_x925 = kk_string_dup(_s_x926, _ctx); /*string*/
    _x_x924 = kk_string_box(_x_x925); /*5824*/
    return kk_std_core_hnd__open_at1(_b_x168_201, kk_std_text_parse_new_choose_fun921(_ctx), _x_x924, _ctx);
  }
  {
    struct kk_std_core_types_Cons* _con_x927 = kk_std_core_types__as_Cons(ps, _ctx);
    kk_std_core_types__list _pat_1_0_0 = _con_x927->tail;
    if (kk_std_core_types__is_Nil(_pat_1_0_0, _ctx)) {
      kk_box_t _fun_unbox_x173 = _con_x927->head;
      if kk_likely(kk_datatype_ptr_is_unique(ps, _ctx)) {
        kk_datatype_ptr_free(ps, _ctx);
      }
      else {
        kk_box_dup(_fun_unbox_x173, _ctx);
        kk_datatype_ptr_decref(ps, _ctx);
      }
      kk_function_t _x_x928 = kk_function_unbox(_fun_unbox_x173, _ctx); /*() -> <std/text/parse/parse|1145> 174*/
      return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), _x_x928, (_x_x928, _ctx), _ctx);
    }
  }
  {
    struct kk_std_core_types_Cons* _con_x929 = kk_std_core_types__as_Cons(ps, _ctx);
    kk_box_t _fun_unbox_x176 = _con_x929->head;
    kk_std_core_types__list pp_0 = _con_x929->tail;
    if kk_likely(kk_datatype_ptr_is_unique(ps, _ctx)) {
      kk_datatype_ptr_free(ps, _ctx);
    }
    else {
      kk_box_dup(_fun_unbox_x176, _ctx);
      kk_std_core_types__list_dup(pp_0, _ctx);
      kk_datatype_ptr_decref(ps, _ctx);
    }
    kk_function_t p_0_0 = kk_function_unbox(_fun_unbox_x176, _ctx); /*std/text/parse/parser<1145,1144>*/;
    kk_ssize_t _b_x190_192;
    kk_std_core_hnd__htag _x_x930 = kk_std_core_hnd__htag_dup(kk_std_text_parse__tag_parse, _ctx); /*hnd/htag<std/text/parse/parse>*/
    _b_x190_192 = kk_std_core_hnd__evv_index(_x_x930, _ctx); /*hnd/ev-index*/
    bool x_0_10211;
    kk_box_t _x_x931 = kk_std_core_hnd__open_at0(_b_x190_192, kk_std_text_parse_new_choose_fun932(_ctx), _ctx); /*5726*/
    x_0_10211 = kk_bool_unbox(_x_x931); /*bool*/
    if (kk_yielding(kk_context())) {
      return kk_std_core_hnd_yield_extend(kk_std_text_parse_new_choose_fun937(p_0_0, pp_0, _ctx), _ctx);
    }
    if (x_0_10211) {
      kk_std_core_types__list_drop(pp_0, _ctx);
      return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), p_0_0, (p_0_0, _ctx), _ctx);
    }
    {
      kk_function_drop(p_0_0, _ctx);
      { // tailcall
        ps = pp_0;
        goto kk__tailcall;
      }
    }
  }
}
 
// monadic lift

kk_std_core_types__list kk_std_text_parse__mlift_count_acc_10166(kk_std_core_types__list acc, kk_integer_t n, kk_function_t p, kk_box_t x, kk_context_t* _ctx) { /* forall<a,e> (acc : list<a>, n : int, p : parser<e,a>, x : a) -> <parse|e> list<a> */ 
  kk_integer_t _x_x939 = kk_integer_add_small_const(n, -1, _ctx); /*int*/
  kk_std_core_types__list _x_x940 = kk_std_core_types__new_Cons(kk_reuse_null, 0, x, acc, _ctx); /*list<82>*/
  return kk_std_text_parse_count_acc(_x_x939, _x_x940, p, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_count_acc_fun943__t {
  struct kk_function_s _base;
  kk_std_core_types__list acc_0;
  kk_integer_t n_0;
  kk_function_t p_0;
};
static kk_box_t kk_std_text_parse_count_acc_fun943(kk_function_t _fself, kk_box_t _b_x208, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_count_acc_fun943(kk_std_core_types__list acc_0, kk_integer_t n_0, kk_function_t p_0, kk_context_t* _ctx) {
  struct kk_std_text_parse_count_acc_fun943__t* _self = kk_function_alloc_as(struct kk_std_text_parse_count_acc_fun943__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_count_acc_fun943, kk_context());
  _self->acc_0 = acc_0;
  _self->n_0 = n_0;
  _self->p_0 = p_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_count_acc_fun943(kk_function_t _fself, kk_box_t _b_x208, kk_context_t* _ctx) {
  struct kk_std_text_parse_count_acc_fun943__t* _self = kk_function_as(struct kk_std_text_parse_count_acc_fun943__t*, _fself, _ctx);
  kk_std_core_types__list acc_0 = _self->acc_0; /* list<1212> */
  kk_integer_t n_0 = _self->n_0; /* int */
  kk_function_t p_0 = _self->p_0; /* std/text/parse/parser<1213,1212> */
  kk_drop_match(_self, {kk_std_core_types__list_dup(acc_0, _ctx);kk_integer_dup(n_0, _ctx);kk_function_dup(p_0, _ctx);}, {}, _ctx)
  kk_box_t x_1_210 = _b_x208; /*1212*/;
  kk_std_core_types__list _x_x944 = kk_std_text_parse__mlift_count_acc_10166(acc_0, n_0, p_0, x_1_210, _ctx); /*list<1212>*/
  return kk_std_core_types__list_box(_x_x944, _ctx);
}

kk_std_core_types__list kk_std_text_parse_count_acc(kk_integer_t n_0, kk_std_core_types__list acc_0, kk_function_t p_0, kk_context_t* _ctx) { /* forall<a,e> (n : int, acc : list<a>, p : parser<e,a>) -> <parse|e> list<a> */ 
  kk__tailcall: ;
  bool _match_x807 = kk_integer_lte_borrow(n_0,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x807) {
    kk_function_drop(p_0, _ctx);
    kk_integer_drop(n_0, _ctx);
    return kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), acc_0, _ctx);
  }
  {
    kk_box_t x_0_10216;
    kk_function_t _x_x941 = kk_function_dup(p_0, _ctx); /*std/text/parse/parser<1213,1212>*/
    x_0_10216 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), _x_x941, (_x_x941, _ctx), _ctx); /*1212*/
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_0_10216, _ctx);
      kk_box_t _x_x942 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_count_acc_fun943(acc_0, n_0, p_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x942, KK_OWNED, _ctx);
    }
    { // tailcall
      kk_integer_t _x_x945 = kk_integer_add_small_const(n_0, -1, _ctx); /*int*/
      kk_std_core_types__list _x_x946 = kk_std_core_types__new_Cons(kk_reuse_null, 0, x_0_10216, acc_0, _ctx); /*list<82>*/
      n_0 = _x_x945;
      acc_0 = _x_x946;
      goto kk__tailcall;
    }
  }
}
extern kk_box_t kk_std_text_parse_current_input_fun949(kk_function_t _fself, int32_t _b_x218, kk_std_core_hnd__ev _b_x219, kk_context_t* _ctx) {
  struct kk_std_text_parse_current_input_fun949__t* _self = kk_function_as(struct kk_std_text_parse_current_input_fun949__t*, _fself, _ctx);
  kk_function_t _fun_unbox_x214 = _self->_fun_unbox_x214; /* (hnd/marker<37,38>, hnd/ev<36>) -> 37 35 */
  kk_drop_match(_self, {kk_function_dup(_fun_unbox_x214, _ctx);}, {}, _ctx)
  kk_std_core_sslice__sslice _x_x950;
  int32_t _b_x215_226 = _b_x218; /*hnd/marker<3233,3234>*/;
  kk_std_core_hnd__ev _b_x216_227 = _b_x219; /*hnd/ev<std/text/parse/parse>*/;
  kk_box_t _x_x951 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _fun_unbox_x214, (_fun_unbox_x214, _b_x215_226, _b_x216_227, _ctx), _ctx); /*35*/
  _x_x950 = kk_std_core_sslice__sslice_unbox(_x_x951, KK_OWNED, _ctx); /*sslice/sslice*/
  return kk_std_core_sslice__sslice_box(_x_x950, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_std_text_parse__mlift_digit_10167_fun955__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse__mlift_digit_10167_fun955(kk_function_t _fself, kk_box_t _b_x231, kk_box_t _b_x232, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_digit_10167_fun955(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse__mlift_digit_10167_fun955, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse__mlift_digit_10167_fun955(kk_function_t _fself, kk_box_t _b_x231, kk_box_t _b_x232, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_char_t _x_x956;
  kk_char_t c_1_236 = kk_char_unbox(_b_x231, KK_OWNED, _ctx); /*char*/;
  kk_char_t d_237 = kk_char_unbox(_b_x232, KK_OWNED, _ctx); /*char*/;
  kk_integer_t x_10002 = kk_integer_from_int(c_1_236,kk_context()); /*int*/;
  kk_integer_t y_10003 = kk_integer_from_int(d_237,kk_context()); /*int*/;
  kk_integer_t _x_x957 = kk_integer_sub(x_10002,y_10003,kk_context()); /*int*/
  _x_x956 = kk_integer_clamp32(_x_x957,kk_context()); /*char*/
  return kk_char_box(_x_x956, _ctx);
}

kk_integer_t kk_std_text_parse__mlift_digit_10167(kk_char_t c_0_0, kk_context_t* _ctx) { /* (c@0@0 : char) -> parse int */ 
  kk_char_t _x_x953;
  kk_box_t _x_x954 = kk_std_core_hnd__open_none2(kk_std_text_parse__new_mlift_digit_10167_fun955(_ctx), kk_char_box(c_0_0, _ctx), kk_char_box('0', _ctx), _ctx); /*3037*/
  _x_x953 = kk_char_unbox(_x_x954, KK_OWNED, _ctx); /*char*/
  return kk_integer_from_int(_x_x953,kk_context());
}


// lift anonymous function
struct kk_std_text_parse_digit_fun961__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_digit_fun961(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digit_fun961(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digit_fun961, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_digit_fun961(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__maybe _match_x805 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x805, _ctx)) {
    kk_box_t _box_x238 = _match_x805._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0_0 = kk_std_core_types__tuple2_unbox(_box_x238, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0_0, _ctx)) {
      kk_box_t _box_x239 = _pat_0_0.fst;
      kk_box_t _box_x240 = _pat_0_0.snd;
      kk_char_t c = kk_char_unbox(_box_x239, KK_BORROWED, _ctx);
      bool _match_x806 = (c >= ('0')); /*bool*/;
      bool _x_x962;
      if (_match_x806) {
        _x_x962 = (c <= ('9')); /*bool*/
      }
      else {
        _x_x962 = false; /*bool*/
      }
      if (_x_x962) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x240, KK_BORROWED, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x805, _ctx);
        kk_box_t _x_x963;
        kk_std_core_types__tuple2 _x_x964 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x963 = kk_std_core_types__tuple2_box(_x_x964, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x963, _ctx);
      }
    }
  }
  {
    kk_std_core_types__maybe_drop(_match_x805, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_digit_fun966__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_digit_fun966(kk_function_t _fself, kk_box_t _b_x252, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digit_fun966(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digit_fun966, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_digit_fun966(kk_function_t _fself, kk_box_t _b_x252, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x967;
  kk_char_t _x_x968 = kk_char_unbox(_b_x252, KK_OWNED, _ctx); /*char*/
  _x_x967 = kk_std_text_parse__mlift_digit_10167(_x_x968, _ctx); /*int*/
  return kk_integer_box(_x_x967, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_digit_fun971__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_digit_fun971(kk_function_t _fself, kk_box_t _b_x256, kk_box_t _b_x257, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digit_fun971(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digit_fun971, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_digit_fun971(kk_function_t _fself, kk_box_t _b_x256, kk_box_t _b_x257, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_char_t _x_x972;
  kk_char_t c_1_262 = kk_char_unbox(_b_x256, KK_OWNED, _ctx); /*char*/;
  kk_char_t d_263 = kk_char_unbox(_b_x257, KK_OWNED, _ctx); /*char*/;
  kk_integer_t x_10002 = kk_integer_from_int(c_1_262,kk_context()); /*int*/;
  kk_integer_t y_10003 = kk_integer_from_int(d_263,kk_context()); /*int*/;
  kk_integer_t _x_x973 = kk_integer_sub(x_10002,y_10003,kk_context()); /*int*/
  _x_x972 = kk_integer_clamp32(_x_x973,kk_context()); /*char*/
  return kk_char_box(_x_x972, _ctx);
}

kk_integer_t kk_std_text_parse_digit(kk_context_t* _ctx) { /* () -> parse int */ 
  kk_char_t x_10221;
  kk_box_t _x_x958;
  kk_string_t _x_x959;
  kk_define_string_literal(, _s_x960, 5, "digit", _ctx)
  _x_x959 = kk_string_dup(_s_x960, _ctx); /*string*/
  _x_x958 = kk_std_text_parse_satisfy_fail(_x_x959, kk_std_text_parse_new_digit_fun961(_ctx), _ctx); /*810*/
  x_10221 = kk_char_unbox(_x_x958, KK_OWNED, _ctx); /*char*/
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x965 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_digit_fun966(_ctx), _ctx); /*3728*/
    return kk_integer_unbox(_x_x965, _ctx);
  }
  {
    kk_char_t _x_x969;
    kk_box_t _x_x970 = kk_std_core_hnd__open_none2(kk_std_text_parse_new_digit_fun971(_ctx), kk_char_box(x_10221, _ctx), kk_char_box('0', _ctx), _ctx); /*3037*/
    _x_x969 = kk_char_unbox(_x_x970, KK_OWNED, _ctx); /*char*/
    return kk_integer_from_int(_x_x969,kk_context());
  }
}


// lift anonymous function
struct kk_std_text_parse_digits_fun977__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_digits_fun977(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digits_fun977(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digits_fun977, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_digits_fun979__t {
  struct kk_function_s _base;
};
static bool kk_std_text_parse_digits_fun979(kk_function_t _fself, kk_char_t _x1_x978, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digits_fun979(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digits_fun979, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static bool kk_std_text_parse_digits_fun979(kk_function_t _fself, kk_char_t _x1_x978, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_char_is_digit(_x1_x978, _ctx);
}
static kk_std_core_types__maybe kk_std_text_parse_digits_fun977(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__tuple2 _match_x803 = kk_std_text_parse_next_while0(slice, kk_std_text_parse_new_digits_fun979(_ctx), kk_std_core_types__new_Nil(_ctx), _ctx); /*(list<char>, sslice/sslice)*/;
  {
    kk_box_t _box_x264 = _match_x803.fst;
    kk_box_t _box_x265 = _match_x803.snd;
    kk_std_core_types__list _pat_0_0 = kk_std_core_types__list_unbox(_box_x264, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice _pat_1_0 = kk_std_core_sslice__sslice_unbox(_box_x265, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Nil(_pat_0_0, _ctx)) {
      kk_std_core_types__tuple2_drop(_match_x803, _ctx);
      return kk_std_core_types__new_Nothing(_ctx);
    }
  }
  {
    kk_box_t _box_x266 = _match_x803.fst;
    kk_box_t _box_x267 = _match_x803.snd;
    kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x267, KK_BORROWED, _ctx);
    kk_std_core_types__list xs = kk_std_core_types__list_unbox(_box_x266, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(rest, _ctx);
    kk_std_core_types__list_dup(xs, _ctx);
    kk_std_core_types__tuple2_drop(_match_x803, _ctx);
    kk_box_t _x_x980;
    kk_std_core_types__tuple2 _x_x981 = kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(xs, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x980 = kk_std_core_types__tuple2_box(_x_x981, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x980, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_digits_fun983__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_digits_fun983(kk_function_t _fself, kk_box_t _b_x279, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digits_fun983(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digits_fun983, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_digits_fun983(kk_function_t _fself, kk_box_t _b_x279, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x984;
  kk_std_core_types__list _x_x985 = kk_std_core_types__list_unbox(_b_x279, KK_OWNED, _ctx); /*list<char>*/
  _x_x984 = kk_std_core_string_listchar_fs_string(_x_x985, _ctx); /*string*/
  return kk_string_box(_x_x984);
}

kk_string_t kk_std_text_parse_digits(kk_context_t* _ctx) { /* () -> parse string */ 
  kk_std_core_types__list x_10224;
  kk_box_t _x_x974;
  kk_string_t _x_x975;
  kk_define_string_literal(, _s_x976, 5, "digit", _ctx)
  _x_x975 = kk_string_dup(_s_x976, _ctx); /*string*/
  _x_x974 = kk_std_text_parse_satisfy_fail(_x_x975, kk_std_text_parse_new_digits_fun977(_ctx), _ctx); /*810*/
  x_10224 = kk_std_core_types__list_unbox(_x_x974, KK_OWNED, _ctx); /*list<char>*/
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10224, _ctx);
    kk_box_t _x_x982 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_digits_fun983(_ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x982);
  }
  {
    return kk_std_core_string_listchar_fs_string(x_10224, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse__lp__at_x_fun988__t_bar__bar__rp_ {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse__lp__at_x_fun988_bar__bar__rp_(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__lp__at_new_x_fun988_bar__bar__rp_(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse__lp__at_x_fun988_bar__bar__rp_, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse__lp__at_x_fun988_bar__bar__rp_(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_hnd__ev ev_10229 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<std/text/parse/parse>*/;
  bool _x_x989;
  {
    struct kk_std_core_hnd_Ev* _con_x990 = kk_std_core_hnd__as_Ev(ev_10229, _ctx);
    kk_box_t _box_x281 = _con_x990->hnd;
    int32_t m = _con_x990->marker;
    kk_std_text_parse__parse h = kk_std_text_parse__parse_unbox(_box_x281, KK_BORROWED, _ctx);
    kk_std_text_parse__parse_dup(h, _ctx);
    {
      struct kk_std_text_parse__Hnd_parse* _con_x991 = kk_std_text_parse__as_Hnd_parse(h, _ctx);
      kk_integer_t _pat_0 = _con_x991->_cfc;
      kk_std_core_hnd__clause0 _pat_1_1 = _con_x991->_fun_current_input;
      kk_std_core_hnd__clause1 _pat_2 = _con_x991->_ctl_fail;
      kk_std_core_hnd__clause0 _ctl_pick = _con_x991->_ctl_pick;
      kk_std_core_hnd__clause1 _pat_3 = _con_x991->_fun_satisfy;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause1_drop(_pat_3, _ctx);
        kk_std_core_hnd__clause1_drop(_pat_2, _ctx);
        kk_std_core_hnd__clause0_drop(_pat_1_1, _ctx);
        kk_integer_drop(_pat_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause0_dup(_ctl_pick, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x284 = _ctl_pick.clause;
        kk_function_t _bv_x290 = _fun_unbox_x284; /*(hnd/marker<426,428>, hnd/ev<427>) -> 425 424*/;
        kk_box_t _x_x992 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_context_t*), _bv_x290, (_bv_x290, m, ev_10229, _ctx), _ctx); /*424*/
        _x_x989 = kk_bool_unbox(_x_x992); /*bool*/
      }
    }
  }
  return kk_bool_box(_x_x989);
}


// lift anonymous function
struct kk_std_text_parse__lp__at_x_fun993__t_bar__bar__rp_ {
  struct kk_function_s _base;
  kk_function_t p1;
  kk_function_t p2;
};
static kk_box_t kk_std_text_parse__lp__at_x_fun993_bar__bar__rp_(kk_function_t _fself, kk_box_t _b_x303, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__lp__at_new_x_fun993_bar__bar__rp_(kk_function_t p1, kk_function_t p2, kk_context_t* _ctx) {
  struct kk_std_text_parse__lp__at_x_fun993__t_bar__bar__rp_* _self = kk_function_alloc_as(struct kk_std_text_parse__lp__at_x_fun993__t_bar__bar__rp_, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse__lp__at_x_fun993_bar__bar__rp_, kk_context());
  _self->p1 = p1;
  _self->p2 = p2;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse__lp__at_x_fun993_bar__bar__rp_(kk_function_t _fself, kk_box_t _b_x303, kk_context_t* _ctx) {
  struct kk_std_text_parse__lp__at_x_fun993__t_bar__bar__rp_* _self = kk_function_as(struct kk_std_text_parse__lp__at_x_fun993__t_bar__bar__rp_*, _fself, _ctx);
  kk_function_t p1 = _self->p1; /* std/text/parse/parser<1337,1336> */
  kk_function_t p2 = _self->p2; /* std/text/parse/parser<1337,1336> */
  kk_drop_match(_self, {kk_function_dup(p1, _ctx);kk_function_dup(p2, _ctx);}, {}, _ctx)
  bool _match_x801 = kk_bool_unbox(_b_x303); /*bool*/;
  if (_match_x801) {
    kk_function_drop(p2, _ctx);
    return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), p1, (p1, _ctx), _ctx);
  }
  {
    kk_function_drop(p1, _ctx);
    return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), p2, (p2, _ctx), _ctx);
  }
}

kk_box_t kk_std_text_parse__lp__bar__bar__rp_(kk_function_t p1, kk_function_t p2, kk_context_t* _ctx) { /* forall<a,e> (p1 : parser<e,a>, p2 : parser<e,a>) -> <parse|e> a */ 
  kk_ssize_t _b_x293_295;
  kk_std_core_hnd__htag _x_x986 = kk_std_core_hnd__htag_dup(kk_std_text_parse__tag_parse, _ctx); /*hnd/htag<std/text/parse/parse>*/
  _b_x293_295 = kk_std_core_hnd__evv_index(_x_x986, _ctx); /*hnd/ev-index*/
  bool x_10226;
  kk_box_t _x_x987 = kk_std_core_hnd__open_at0(_b_x293_295, kk_std_text_parse__lp__at_new_x_fun988_bar__bar__rp_(_ctx), _ctx); /*5726*/
  x_10226 = kk_bool_unbox(_x_x987); /*bool*/
  if (kk_yielding(kk_context())) {
    return kk_std_core_hnd_yield_extend(kk_std_text_parse__lp__at_new_x_fun993_bar__bar__rp_(p1, p2, _ctx), _ctx);
  }
  if (x_10226) {
    kk_function_drop(p2, _ctx);
    return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), p1, (p1, _ctx), _ctx);
  }
  {
    kk_function_drop(p1, _ctx);
    return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), p2, (p2, _ctx), _ctx);
  }
}
extern kk_box_t kk_std_text_parse_optional_fun994(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_text_parse_optional_fun994__t* _self = kk_function_as(struct kk_std_text_parse_optional_fun994__t*, _fself, _ctx);
  kk_box_t kkloc_default = _self->kkloc_default; /* 1362 */
  kk_drop_match(_self, {kk_box_dup(kkloc_default, _ctx);}, {}, _ctx)
  return kkloc_default;
}


// lift anonymous function
struct kk_std_text_parse_digits0_fun996__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_digits0_fun996(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digits0_fun996(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digits0_fun996, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_digits0_fun1000__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_digits0_fun1000(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digits0_fun1000(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digits0_fun1000, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_digits0_fun1002__t {
  struct kk_function_s _base;
};
static bool kk_std_text_parse_digits0_fun1002(kk_function_t _fself, kk_char_t _x1_x1001, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digits0_fun1002(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digits0_fun1002, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static bool kk_std_text_parse_digits0_fun1002(kk_function_t _fself, kk_char_t _x1_x1001, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_char_is_digit(_x1_x1001, _ctx);
}
static kk_std_core_types__maybe kk_std_text_parse_digits0_fun1000(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__tuple2 _match_x799 = kk_std_text_parse_next_while0(slice, kk_std_text_parse_new_digits0_fun1002(_ctx), kk_std_core_types__new_Nil(_ctx), _ctx); /*(list<char>, sslice/sslice)*/;
  {
    kk_box_t _box_x306 = _match_x799.fst;
    kk_box_t _box_x307 = _match_x799.snd;
    kk_std_core_types__list _pat_0_0 = kk_std_core_types__list_unbox(_box_x306, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice _pat_1_0 = kk_std_core_sslice__sslice_unbox(_box_x307, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Nil(_pat_0_0, _ctx)) {
      kk_std_core_types__tuple2_drop(_match_x799, _ctx);
      return kk_std_core_types__new_Nothing(_ctx);
    }
  }
  {
    kk_box_t _box_x308 = _match_x799.fst;
    kk_box_t _box_x309 = _match_x799.snd;
    kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x309, KK_BORROWED, _ctx);
    kk_std_core_types__list xs = kk_std_core_types__list_unbox(_box_x308, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(rest, _ctx);
    kk_std_core_types__list_dup(xs, _ctx);
    kk_std_core_types__tuple2_drop(_match_x799, _ctx);
    kk_box_t _x_x1003;
    kk_std_core_types__tuple2 _x_x1004 = kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(xs, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x1003 = kk_std_core_types__tuple2_box(_x_x1004, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x1003, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_digits0_fun1007__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_digits0_fun1007(kk_function_t _fself, kk_box_t _b_x321, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digits0_fun1007(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digits0_fun1007, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_digits0_fun1007(kk_function_t _fself, kk_box_t _b_x321, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1008;
  kk_std_core_types__list _x_x1009 = kk_std_core_types__list_unbox(_b_x321, KK_OWNED, _ctx); /*list<char>*/
  _x_x1008 = kk_std_core_string_listchar_fs_string(_x_x1009, _ctx); /*string*/
  return kk_string_box(_x_x1008);
}
static kk_box_t kk_std_text_parse_digits0_fun996(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__list x_10234;
  kk_box_t _x_x997;
  kk_string_t _x_x998;
  kk_define_string_literal(, _s_x999, 5, "digit", _ctx)
  _x_x998 = kk_string_dup(_s_x999, _ctx); /*string*/
  _x_x997 = kk_std_text_parse_satisfy_fail(_x_x998, kk_std_text_parse_new_digits0_fun1000(_ctx), _ctx); /*810*/
  x_10234 = kk_std_core_types__list_unbox(_x_x997, KK_OWNED, _ctx); /*list<char>*/
  kk_string_t _x_x1005;
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10234, _ctx);
    kk_box_t _x_x1006 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_digits0_fun1007(_ctx), _ctx); /*3728*/
    _x_x1005 = kk_string_unbox(_x_x1006); /*string*/
  }
  else {
    _x_x1005 = kk_std_core_string_listchar_fs_string(x_10234, _ctx); /*string*/
  }
  return kk_string_box(_x_x1005);
}


// lift anonymous function
struct kk_std_text_parse_digits0_fun1010__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_digits0_fun1010(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_digits0_fun1010(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_digits0_fun1010, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_digits0_fun1010(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1011;
  kk_define_string_literal(, _s_x1012, 1, "0", _ctx)
  _x_x1011 = kk_string_dup(_s_x1012, _ctx); /*string*/
  return kk_string_box(_x_x1011);
}

kk_string_t kk_std_text_parse_digits0(kk_context_t* _ctx) { /* () -> parse string */ 
  kk_box_t _x_x995 = kk_std_text_parse__lp__bar__bar__rp_(kk_std_text_parse_new_digits0_fun996(_ctx), kk_std_text_parse_new_digits0_fun1010(_ctx), _ctx); /*1336*/
  return kk_string_unbox(_x_x995);
}
 
// monadic lift

kk_unit_t kk_std_text_parse__mlift_eof_10169(kk_std_core_types__maybe _y_x10102, kk_context_t* _ctx) { /* (maybe<()>) -> parse () */ 
  if (kk_std_core_types__is_Nothing(_y_x10102, _ctx)) {
    kk_std_core_hnd__ev ev_10236 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<std/text/parse/parse>*/;
    kk_box_t _x_x1013;
    {
      struct kk_std_core_hnd_Ev* _con_x1014 = kk_std_core_hnd__as_Ev(ev_10236, _ctx);
      kk_box_t _box_x327 = _con_x1014->hnd;
      int32_t m = _con_x1014->marker;
      kk_std_text_parse__parse h = kk_std_text_parse__parse_unbox(_box_x327, KK_BORROWED, _ctx);
      kk_std_text_parse__parse_dup(h, _ctx);
      {
        struct kk_std_text_parse__Hnd_parse* _con_x1015 = kk_std_text_parse__as_Hnd_parse(h, _ctx);
        kk_integer_t _pat_0_0 = _con_x1015->_cfc;
        kk_std_core_hnd__clause0 _pat_1_0 = _con_x1015->_fun_current_input;
        kk_std_core_hnd__clause1 _ctl_fail = _con_x1015->_ctl_fail;
        kk_std_core_hnd__clause0 _pat_2_0 = _con_x1015->_ctl_pick;
        kk_std_core_hnd__clause1 _pat_3 = _con_x1015->_fun_satisfy;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_std_core_hnd__clause1_drop(_pat_3, _ctx);
          kk_std_core_hnd__clause0_drop(_pat_2_0, _ctx);
          kk_std_core_hnd__clause0_drop(_pat_1_0, _ctx);
          kk_integer_drop(_pat_0_0, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_ctl_fail, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x331 = _ctl_fail.clause;
          kk_box_t _x_x1016;
          kk_string_t _x_x1017;
          kk_define_string_literal(, _s_x1018, 22, "expecting end-of-input", _ctx)
          _x_x1017 = kk_string_dup(_s_x1018, _ctx); /*string*/
          _x_x1016 = kk_string_box(_x_x1017); /*45*/
          _x_x1013 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x331, (_fun_unbox_x331, m, ev_10236, _x_x1016, _ctx), _ctx); /*46*/
        }
      }
    }
    kk_unit_unbox(_x_x1013); return kk_Unit;
  }
  {
    kk_box_t _box_x335 = _y_x10102._cons.Just.value;
    kk_unit_t _pat_3_0 = kk_unit_unbox(_box_x335);
    kk_std_core_types__maybe_drop(_y_x10102, _ctx);
    kk_Unit; return kk_Unit;
  }
}


// lift anonymous function
struct kk_std_text_parse_eof_fun1022__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_eof_fun1022(kk_function_t _fself, kk_box_t _b_x349, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_eof_fun1022(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_eof_fun1022, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_eof_fun1022(kk_function_t _fself, kk_box_t _b_x349, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool b_10013;
  kk_integer_t _brw_x796;
  kk_std_core_sslice__sslice _match_x795;
  kk_box_t _x_x1023 = kk_box_dup(_b_x349, _ctx); /*347*/
  _match_x795 = kk_std_core_sslice__sslice_unbox(_x_x1023, KK_OWNED, _ctx); /*sslice/sslice*/
  {
    kk_integer_t _x = _match_x795.len;
    kk_integer_dup(_x, _ctx);
    kk_std_core_sslice__sslice_drop(_match_x795, _ctx);
    _brw_x796 = _x; /*int*/
  }
  bool _brw_x797 = kk_integer_gt_borrow(_brw_x796,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  kk_integer_drop(_brw_x796, _ctx);
  b_10013 = _brw_x797; /*bool*/
  kk_std_core_types__maybe _x_x1024;
  if (b_10013) {
    kk_box_drop(_b_x349, _ctx);
    _x_x1024 = kk_std_core_types__new_Nothing(_ctx); /*forall<a> maybe<a>*/
  }
  else {
    kk_box_t _x_x1025;
    kk_std_core_types__tuple2 _x_x1026 = kk_std_core_types__new_Tuple2(kk_unit_box(kk_Unit), _b_x349, _ctx); /*(129, 130)*/
    _x_x1025 = kk_std_core_types__tuple2_box(_x_x1026, _ctx); /*91*/
    _x_x1024 = kk_std_core_types__new_Just(_x_x1025, _ctx); /*forall<a> maybe<a>*/
  }
  return kk_std_core_types__maybe_box(_x_x1024, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_eof_fun1028__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_eof_fun1028(kk_function_t _fself, kk_box_t _b_x358, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_eof_fun1028(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_eof_fun1028, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_eof_fun1028(kk_function_t _fself, kk_box_t _b_x358, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x1029 = kk_Unit;
  kk_std_core_types__maybe _x_x1030 = kk_std_core_types__maybe_unbox(_b_x358, KK_OWNED, _ctx); /*maybe<()>*/
  kk_std_text_parse__mlift_eof_10169(_x_x1030, _ctx);
  return kk_unit_box(_x_x1029);
}

kk_unit_t kk_std_text_parse_eof(kk_context_t* _ctx) { /* () -> parse () */ 
  kk_std_core_hnd__ev ev_10242 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<std/text/parse/parse>*/;
  kk_std_core_types__maybe x_10239;
  kk_box_t _x_x1019;
  {
    struct kk_std_core_hnd_Ev* _con_x1020 = kk_std_core_hnd__as_Ev(ev_10242, _ctx);
    kk_box_t _box_x336 = _con_x1020->hnd;
    int32_t m = _con_x1020->marker;
    kk_std_text_parse__parse h = kk_std_text_parse__parse_unbox(_box_x336, KK_BORROWED, _ctx);
    kk_std_text_parse__parse_dup(h, _ctx);
    {
      struct kk_std_text_parse__Hnd_parse* _con_x1021 = kk_std_text_parse__as_Hnd_parse(h, _ctx);
      kk_integer_t _pat_0 = _con_x1021->_cfc;
      kk_std_core_hnd__clause0 _pat_1_1 = _con_x1021->_fun_current_input;
      kk_std_core_hnd__clause1 _pat_2 = _con_x1021->_ctl_fail;
      kk_std_core_hnd__clause0 _pat_3 = _con_x1021->_ctl_pick;
      kk_std_core_hnd__clause1 _fun_satisfy = _con_x1021->_fun_satisfy;
      if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
        kk_std_core_hnd__clause0_drop(_pat_3, _ctx);
        kk_std_core_hnd__clause1_drop(_pat_2, _ctx);
        kk_std_core_hnd__clause0_drop(_pat_1_1, _ctx);
        kk_integer_drop(_pat_0, _ctx);
        kk_datatype_ptr_free(h, _ctx);
      }
      else {
        kk_std_core_hnd__clause1_dup(_fun_satisfy, _ctx);
        kk_datatype_ptr_decref(h, _ctx);
      }
      {
        kk_function_t _fun_unbox_x343 = _fun_satisfy.clause;
        _x_x1019 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x343, (_fun_unbox_x343, m, ev_10242, kk_function_box(kk_std_text_parse_new_eof_fun1022(_ctx), _ctx), _ctx), _ctx); /*46*/
      }
    }
  }
  x_10239 = kk_std_core_types__maybe_unbox(_x_x1019, KK_OWNED, _ctx); /*maybe<()>*/
  if (kk_yielding(kk_context())) {
    kk_std_core_types__maybe_drop(x_10239, _ctx);
    kk_box_t _x_x1027 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_eof_fun1028(_ctx), _ctx); /*3728*/
    kk_unit_unbox(_x_x1027); return kk_Unit;
  }
  if (kk_std_core_types__is_Nothing(x_10239, _ctx)) {
    kk_std_core_hnd__ev ev_0_10245 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<std/text/parse/parse>*/;
    kk_box_t _x_x1031;
    {
      struct kk_std_core_hnd_Ev* _con_x1032 = kk_std_core_hnd__as_Ev(ev_0_10245, _ctx);
      kk_box_t _box_x359 = _con_x1032->hnd;
      int32_t m_0 = _con_x1032->marker;
      kk_std_text_parse__parse h_0 = kk_std_text_parse__parse_unbox(_box_x359, KK_BORROWED, _ctx);
      kk_std_text_parse__parse_dup(h_0, _ctx);
      {
        struct kk_std_text_parse__Hnd_parse* _con_x1033 = kk_std_text_parse__as_Hnd_parse(h_0, _ctx);
        kk_integer_t _pat_0_3 = _con_x1033->_cfc;
        kk_std_core_hnd__clause0 _pat_1_3 = _con_x1033->_fun_current_input;
        kk_std_core_hnd__clause1 _ctl_fail = _con_x1033->_ctl_fail;
        kk_std_core_hnd__clause0 _pat_2_1 = _con_x1033->_ctl_pick;
        kk_std_core_hnd__clause1 _pat_3_1 = _con_x1033->_fun_satisfy;
        if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
          kk_std_core_hnd__clause1_drop(_pat_3_1, _ctx);
          kk_std_core_hnd__clause0_drop(_pat_2_1, _ctx);
          kk_std_core_hnd__clause0_drop(_pat_1_3, _ctx);
          kk_integer_drop(_pat_0_3, _ctx);
          kk_datatype_ptr_free(h_0, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_ctl_fail, _ctx);
          kk_datatype_ptr_decref(h_0, _ctx);
        }
        {
          kk_function_t _fun_unbox_x363 = _ctl_fail.clause;
          kk_box_t _x_x1034;
          kk_string_t _x_x1035;
          kk_define_string_literal(, _s_x1036, 22, "expecting end-of-input", _ctx)
          _x_x1035 = kk_string_dup(_s_x1036, _ctx); /*string*/
          _x_x1034 = kk_string_box(_x_x1035); /*45*/
          _x_x1031 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x363, (_fun_unbox_x363, m_0, ev_0_10245, _x_x1034, _ctx), _ctx); /*46*/
        }
      }
    }
    kk_unit_unbox(_x_x1031); return kk_Unit;
  }
  {
    kk_box_t _box_x367 = x_10239._cons.Just.value;
    kk_unit_t _pat_3_0_0 = kk_unit_unbox(_box_x367);
    kk_std_core_types__maybe_drop(x_10239, _ctx);
    kk_Unit; return kk_Unit;
  }
}


// lift anonymous function
struct kk_std_text_parse_hex_digits_fun1040__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_hex_digits_fun1040(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_hex_digits_fun1040(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_hex_digits_fun1040, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_hex_digits_fun1042__t {
  struct kk_function_s _base;
};
static bool kk_std_text_parse_hex_digits_fun1042(kk_function_t _fself, kk_char_t _x1_x1041, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_hex_digits_fun1042(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_hex_digits_fun1042, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static bool kk_std_text_parse_hex_digits_fun1042(kk_function_t _fself, kk_char_t _x1_x1041, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_char_is_hex_digit(_x1_x1041, _ctx);
}
static kk_std_core_types__maybe kk_std_text_parse_hex_digits_fun1040(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__tuple2 _match_x793 = kk_std_text_parse_next_while0(slice, kk_std_text_parse_new_hex_digits_fun1042(_ctx), kk_std_core_types__new_Nil(_ctx), _ctx); /*(list<char>, sslice/sslice)*/;
  {
    kk_box_t _box_x369 = _match_x793.fst;
    kk_box_t _box_x370 = _match_x793.snd;
    kk_std_core_types__list _pat_0_0 = kk_std_core_types__list_unbox(_box_x369, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice _pat_1_0 = kk_std_core_sslice__sslice_unbox(_box_x370, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Nil(_pat_0_0, _ctx)) {
      kk_std_core_types__tuple2_drop(_match_x793, _ctx);
      return kk_std_core_types__new_Nothing(_ctx);
    }
  }
  {
    kk_box_t _box_x371 = _match_x793.fst;
    kk_box_t _box_x372 = _match_x793.snd;
    kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x372, KK_BORROWED, _ctx);
    kk_std_core_types__list xs = kk_std_core_types__list_unbox(_box_x371, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(rest, _ctx);
    kk_std_core_types__list_dup(xs, _ctx);
    kk_std_core_types__tuple2_drop(_match_x793, _ctx);
    kk_box_t _x_x1043;
    kk_std_core_types__tuple2 _x_x1044 = kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(xs, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x1043 = kk_std_core_types__tuple2_box(_x_x1044, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x1043, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_hex_digits_fun1046__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_hex_digits_fun1046(kk_function_t _fself, kk_box_t _b_x384, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_hex_digits_fun1046(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_hex_digits_fun1046, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_hex_digits_fun1046(kk_function_t _fself, kk_box_t _b_x384, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1047;
  kk_std_core_types__list _x_x1048 = kk_std_core_types__list_unbox(_b_x384, KK_OWNED, _ctx); /*list<char>*/
  _x_x1047 = kk_std_core_string_listchar_fs_string(_x_x1048, _ctx); /*string*/
  return kk_string_box(_x_x1047);
}

kk_string_t kk_std_text_parse_hex_digits(kk_context_t* _ctx) { /* () -> parse string */ 
  kk_std_core_types__list x_10248;
  kk_box_t _x_x1037;
  kk_string_t _x_x1038;
  kk_define_string_literal(, _s_x1039, 5, "digit", _ctx)
  _x_x1038 = kk_string_dup(_s_x1039, _ctx); /*string*/
  _x_x1037 = kk_std_text_parse_satisfy_fail(_x_x1038, kk_std_text_parse_new_hex_digits_fun1040(_ctx), _ctx); /*810*/
  x_10248 = kk_std_core_types__list_unbox(_x_x1037, KK_OWNED, _ctx); /*list<char>*/
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10248, _ctx);
    kk_box_t _x_x1045 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_hex_digits_fun1046(_ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x1045);
  }
  {
    return kk_std_core_string_listchar_fs_string(x_10248, _ctx);
  }
}
 
// monadic lift

kk_std_core_types__list kk_std_text_parse__mlift_many_acc_10170(kk_std_core_types__list acc, kk_function_t p, kk_box_t x, kk_context_t* _ctx) { /* forall<a,e> (acc : list<a>, p : parser<e,a>, x : a) -> <parse|e> list<a> */ 
  kk_std_core_types__list _x_x1049 = kk_std_core_types__new_Cons(kk_reuse_null, 0, x, acc, _ctx); /*list<82>*/
  return kk_std_text_parse_many_acc(p, _x_x1049, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_many_acc_fun1052__t {
  struct kk_function_s _base;
  kk_std_core_types__list acc_0;
  kk_function_t p_0;
};
static kk_box_t kk_std_text_parse_many_acc_fun1052(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_many_acc_fun1052(kk_std_core_types__list acc_0, kk_function_t p_0, kk_context_t* _ctx) {
  struct kk_std_text_parse_many_acc_fun1052__t* _self = kk_function_alloc_as(struct kk_std_text_parse_many_acc_fun1052__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_many_acc_fun1052, kk_context());
  _self->acc_0 = acc_0;
  _self->p_0 = p_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_many_acc_fun1056__t {
  struct kk_function_s _base;
  kk_std_core_types__list acc_0;
  kk_function_t p_0;
};
static kk_box_t kk_std_text_parse_many_acc_fun1056(kk_function_t _fself, kk_box_t _b_x387, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_many_acc_fun1056(kk_std_core_types__list acc_0, kk_function_t p_0, kk_context_t* _ctx) {
  struct kk_std_text_parse_many_acc_fun1056__t* _self = kk_function_alloc_as(struct kk_std_text_parse_many_acc_fun1056__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_many_acc_fun1056, kk_context());
  _self->acc_0 = acc_0;
  _self->p_0 = p_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_many_acc_fun1056(kk_function_t _fself, kk_box_t _b_x387, kk_context_t* _ctx) {
  struct kk_std_text_parse_many_acc_fun1056__t* _self = kk_function_as(struct kk_std_text_parse_many_acc_fun1056__t*, _fself, _ctx);
  kk_std_core_types__list acc_0 = _self->acc_0; /* list<1498> */
  kk_function_t p_0 = _self->p_0; /* std/text/parse/parser<1499,1498> */
  kk_drop_match(_self, {kk_std_core_types__list_dup(acc_0, _ctx);kk_function_dup(p_0, _ctx);}, {}, _ctx)
  kk_box_t x_1_393 = _b_x387; /*1498*/;
  kk_std_core_types__list _x_x1057 = kk_std_text_parse__mlift_many_acc_10170(acc_0, p_0, x_1_393, _ctx); /*list<1498>*/
  return kk_std_core_types__list_box(_x_x1057, _ctx);
}
static kk_box_t kk_std_text_parse_many_acc_fun1052(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_text_parse_many_acc_fun1052__t* _self = kk_function_as(struct kk_std_text_parse_many_acc_fun1052__t*, _fself, _ctx);
  kk_std_core_types__list acc_0 = _self->acc_0; /* list<1498> */
  kk_function_t p_0 = _self->p_0; /* std/text/parse/parser<1499,1498> */
  kk_drop_match(_self, {kk_std_core_types__list_dup(acc_0, _ctx);kk_function_dup(p_0, _ctx);}, {}, _ctx)
  kk_box_t x_0_10250;
  kk_function_t _x_x1053 = kk_function_dup(p_0, _ctx); /*std/text/parse/parser<1499,1498>*/
  x_0_10250 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), _x_x1053, (_x_x1053, _ctx), _ctx); /*1498*/
  kk_std_core_types__list _x_x1054;
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_0_10250, _ctx);
    kk_box_t _x_x1055 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_many_acc_fun1056(acc_0, p_0, _ctx), _ctx); /*3728*/
    _x_x1054 = kk_std_core_types__list_unbox(_x_x1055, KK_OWNED, _ctx); /*list<1498>*/
  }
  else {
    _x_x1054 = kk_std_text_parse__mlift_many_acc_10170(acc_0, p_0, x_0_10250, _ctx); /*list<1498>*/
  }
  return kk_std_core_types__list_box(_x_x1054, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_many_acc_fun1058__t {
  struct kk_function_s _base;
  kk_std_core_types__list acc_0;
};
static kk_box_t kk_std_text_parse_many_acc_fun1058(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_many_acc_fun1058(kk_std_core_types__list acc_0, kk_context_t* _ctx) {
  struct kk_std_text_parse_many_acc_fun1058__t* _self = kk_function_alloc_as(struct kk_std_text_parse_many_acc_fun1058__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_many_acc_fun1058, kk_context());
  _self->acc_0 = acc_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_many_acc_fun1058(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_text_parse_many_acc_fun1058__t* _self = kk_function_as(struct kk_std_text_parse_many_acc_fun1058__t*, _fself, _ctx);
  kk_std_core_types__list acc_0 = _self->acc_0; /* list<1498> */
  kk_drop_match(_self, {kk_std_core_types__list_dup(acc_0, _ctx);}, {}, _ctx)
  kk_std_core_types__list _x_x1059 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), acc_0, _ctx); /*list<733>*/
  return kk_std_core_types__list_box(_x_x1059, _ctx);
}

kk_std_core_types__list kk_std_text_parse_many_acc(kk_function_t p_0, kk_std_core_types__list acc_0, kk_context_t* _ctx) { /* forall<a,e> (p : parser<e,a>, acc : list<a>) -> <parse|e> list<a> */ 
  kk_box_t _x_x1050;
  kk_function_t _x_x1051;
  kk_std_core_types__list_dup(acc_0, _ctx);
  _x_x1051 = kk_std_text_parse_new_many_acc_fun1052(acc_0, p_0, _ctx); /*() -> <std/text/parse/parse|1337> 1336*/
  _x_x1050 = kk_std_text_parse__lp__bar__bar__rp_(_x_x1051, kk_std_text_parse_new_many_acc_fun1058(acc_0, _ctx), _ctx); /*1336*/
  return kk_std_core_types__list_unbox(_x_x1050, KK_OWNED, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_std_text_parse__mlift_many1_10172_fun1061__t {
  struct kk_function_s _base;
  kk_box_t _y_x10110;
};
static kk_box_t kk_std_text_parse__mlift_many1_10172_fun1061(kk_function_t _fself, kk_box_t _b_x395, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_many1_10172_fun1061(kk_box_t _y_x10110, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_many1_10172_fun1061__t* _self = kk_function_alloc_as(struct kk_std_text_parse__mlift_many1_10172_fun1061__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse__mlift_many1_10172_fun1061, kk_context());
  _self->_y_x10110 = _y_x10110;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse__mlift_many1_10172_fun1061(kk_function_t _fself, kk_box_t _b_x395, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_many1_10172_fun1061__t* _self = kk_function_as(struct kk_std_text_parse__mlift_many1_10172_fun1061__t*, _fself, _ctx);
  kk_box_t _y_x10110 = _self->_y_x10110; /* 1554 */
  kk_drop_match(_self, {kk_box_dup(_y_x10110, _ctx);}, {}, _ctx)
  kk_std_core_types__list _y_x10111_397 = kk_std_core_types__list_unbox(_b_x395, KK_OWNED, _ctx); /*list<1554>*/;
  kk_std_core_types__list _x_x1062 = kk_std_core_types__new_Cons(kk_reuse_null, 0, _y_x10110, _y_x10111_397, _ctx); /*list<82>*/
  return kk_std_core_types__list_box(_x_x1062, _ctx);
}

kk_std_core_types__list kk_std_text_parse__mlift_many1_10172(kk_function_t p, kk_box_t _y_x10110, kk_context_t* _ctx) { /* forall<a,e> (p : parser<e,a>, a) -> <parse|e> list<a> */ 
  kk_std_core_types__list x_10252 = kk_std_text_parse_many_acc(p, kk_std_core_types__new_Nil(_ctx), _ctx); /*list<1554>*/;
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10252, _ctx);
    kk_box_t _x_x1060 = kk_std_core_hnd_yield_extend(kk_std_text_parse__new_mlift_many1_10172_fun1061(_y_x10110, _ctx), _ctx); /*3728*/
    return kk_std_core_types__list_unbox(_x_x1060, KK_OWNED, _ctx);
  }
  {
    return kk_std_core_types__new_Cons(kk_reuse_null, 0, _y_x10110, x_10252, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_many1_fun1065__t {
  struct kk_function_s _base;
  kk_function_t p;
};
static kk_box_t kk_std_text_parse_many1_fun1065(kk_function_t _fself, kk_box_t _b_x399, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_many1_fun1065(kk_function_t p, kk_context_t* _ctx) {
  struct kk_std_text_parse_many1_fun1065__t* _self = kk_function_alloc_as(struct kk_std_text_parse_many1_fun1065__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_many1_fun1065, kk_context());
  _self->p = p;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_many1_fun1065(kk_function_t _fself, kk_box_t _b_x399, kk_context_t* _ctx) {
  struct kk_std_text_parse_many1_fun1065__t* _self = kk_function_as(struct kk_std_text_parse_many1_fun1065__t*, _fself, _ctx);
  kk_function_t p = _self->p; /* std/text/parse/parser<1555,1554> */
  kk_drop_match(_self, {kk_function_dup(p, _ctx);}, {}, _ctx)
  kk_box_t _y_x10110_404 = _b_x399; /*1554*/;
  kk_std_core_types__list _x_x1066 = kk_std_text_parse__mlift_many1_10172(p, _y_x10110_404, _ctx); /*list<1554>*/
  return kk_std_core_types__list_box(_x_x1066, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_many1_fun1068__t {
  struct kk_function_s _base;
  kk_box_t x_10256;
};
static kk_box_t kk_std_text_parse_many1_fun1068(kk_function_t _fself, kk_box_t _b_x401, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_many1_fun1068(kk_box_t x_10256, kk_context_t* _ctx) {
  struct kk_std_text_parse_many1_fun1068__t* _self = kk_function_alloc_as(struct kk_std_text_parse_many1_fun1068__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_many1_fun1068, kk_context());
  _self->x_10256 = x_10256;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_many1_fun1068(kk_function_t _fself, kk_box_t _b_x401, kk_context_t* _ctx) {
  struct kk_std_text_parse_many1_fun1068__t* _self = kk_function_as(struct kk_std_text_parse_many1_fun1068__t*, _fself, _ctx);
  kk_box_t x_10256 = _self->x_10256; /* 1554 */
  kk_drop_match(_self, {kk_box_dup(x_10256, _ctx);}, {}, _ctx)
  kk_std_core_types__list _y_x10111_405 = kk_std_core_types__list_unbox(_b_x401, KK_OWNED, _ctx); /*list<1554>*/;
  kk_std_core_types__list _x_x1069 = kk_std_core_types__new_Cons(kk_reuse_null, 0, x_10256, _y_x10111_405, _ctx); /*list<82>*/
  return kk_std_core_types__list_box(_x_x1069, _ctx);
}

kk_std_core_types__list kk_std_text_parse_many1(kk_function_t p, kk_context_t* _ctx) { /* forall<a,e> (p : parser<e,a>) -> <parse|e> list<a> */ 
  kk_box_t x_10256;
  kk_function_t _x_x1063 = kk_function_dup(p, _ctx); /*std/text/parse/parser<1555,1554>*/
  x_10256 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), _x_x1063, (_x_x1063, _ctx), _ctx); /*1554*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10256, _ctx);
    kk_box_t _x_x1064 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_many1_fun1065(p, _ctx), _ctx); /*3728*/
    return kk_std_core_types__list_unbox(_x_x1064, KK_OWNED, _ctx);
  }
  {
    kk_std_core_types__list x_0_10259 = kk_std_text_parse_many_acc(p, kk_std_core_types__new_Nil(_ctx), _ctx); /*list<1554>*/;
    if (kk_yielding(kk_context())) {
      kk_std_core_types__list_drop(x_0_10259, _ctx);
      kk_box_t _x_x1067 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_many1_fun1068(x_10256, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1067, KK_OWNED, _ctx);
    }
    {
      return kk_std_core_types__new_Cons(kk_reuse_null, 0, x_10256, x_0_10259, _ctx);
    }
  }
}

kk_std_core_types__maybe kk_std_text_parse_maybe(kk_std_text_parse__parse_error perr, kk_context_t* _ctx) { /* forall<a> (perr : parse-error<a>) -> maybe<a> */ 
  if (kk_std_text_parse__is_ParseOk(perr, _ctx)) {
    struct kk_std_text_parse_ParseOk* _con_x1070 = kk_std_text_parse__as_ParseOk(perr, _ctx);
    kk_std_core_sslice__sslice _pat_0_0 = _con_x1070->rest;
    kk_box_t x_0 = _con_x1070->result;
    if kk_likely(kk_datatype_ptr_is_unique(perr, _ctx)) {
      kk_std_core_sslice__sslice_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(perr, _ctx);
    }
    else {
      kk_box_dup(x_0, _ctx);
      kk_datatype_ptr_decref(perr, _ctx);
    }
    return kk_std_core_types__new_Just(x_0, _ctx);
  }
  {
    struct kk_std_text_parse_ParseError* _con_x1071 = kk_std_text_parse__as_ParseError(perr, _ctx);
    kk_std_core_sslice__sslice _pat_5 = _con_x1071->rest;
    kk_string_t msg = _con_x1071->msg;
    if kk_likely(kk_datatype_ptr_is_unique(perr, _ctx)) {
      kk_string_drop(msg, _ctx);
      kk_std_core_sslice__sslice_drop(_pat_5, _ctx);
      kk_datatype_ptr_free(perr, _ctx);
    }
    else {
      kk_datatype_ptr_decref(perr, _ctx);
    }
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_std_core_types__maybe kk_std_text_parse_next_match(kk_std_core_sslice__sslice slice, kk_std_core_types__list cs, kk_context_t* _ctx) { /* (slice : sslice/sslice, cs : list<char>) -> maybe<sslice/sslice> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Nil(cs, _ctx)) {
    return kk_std_core_types__new_Just(kk_std_core_sslice__sslice_box(slice, _ctx), _ctx);
  }
  {
    struct kk_std_core_types_Cons* _con_x1072 = kk_std_core_types__as_Cons(cs, _ctx);
    kk_box_t _box_x407 = _con_x1072->head;
    kk_std_core_types__list cc = _con_x1072->tail;
    kk_char_t c = kk_char_unbox(_box_x407, KK_BORROWED, _ctx);
    if kk_likely(kk_datatype_ptr_is_unique(cs, _ctx)) {
      kk_datatype_ptr_free(cs, _ctx);
    }
    else {
      kk_std_core_types__list_dup(cc, _ctx);
      kk_datatype_ptr_decref(cs, _ctx);
    }
    kk_std_core_types__maybe _match_x787 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
    if (kk_std_core_types__is_Just(_match_x787, _ctx)) {
      kk_box_t _box_x408 = _match_x787._cons.Just.value;
      kk_std_core_types__tuple2 _pat_2 = kk_std_core_types__tuple2_unbox(_box_x408, KK_BORROWED, _ctx);
      if (kk_std_core_types__is_Tuple2(_pat_2, _ctx)) {
        kk_box_t _box_x409 = _pat_2.fst;
        kk_box_t _box_x410 = _pat_2.snd;
        kk_char_t d = kk_char_unbox(_box_x409, KK_BORROWED, _ctx);
        if (c == d) {
          kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x410, KK_BORROWED, _ctx);
          kk_std_core_sslice__sslice_dup(rest, _ctx);
          kk_std_core_types__maybe_drop(_match_x787, _ctx);
          { // tailcall
            slice = rest;
            cs = cc;
            goto kk__tailcall;
          }
        }
      }
    }
    {
      kk_std_core_types__list_drop(cc, _ctx);
      kk_std_core_types__maybe_drop(_match_x787, _ctx);
      return kk_std_core_types__new_Nothing(_ctx);
    }
  }
}


// lift anonymous function
struct kk_std_text_parse_no_digit_fun1076__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_no_digit_fun1076(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_no_digit_fun1076(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_no_digit_fun1076, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_no_digit_fun1076(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__maybe _match_x785 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x785, _ctx)) {
    kk_box_t _box_x412 = _match_x785._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x412, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0, _ctx)) {
      kk_box_t _box_x413 = _pat_0.fst;
      kk_box_t _box_x414 = _pat_0.snd;
      kk_char_t c = kk_char_unbox(_box_x413, KK_BORROWED, _ctx);
      bool b_10027;
      bool _match_x786 = (c >= ('0')); /*bool*/;
      if (_match_x786) {
        b_10027 = (c <= ('9')); /*bool*/
      }
      else {
        b_10027 = false; /*bool*/
      }
      bool _x_x1077;
      if (b_10027) {
        _x_x1077 = false; /*bool*/
      }
      else {
        _x_x1077 = true; /*bool*/
      }
      if (_x_x1077) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x414, KK_BORROWED, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x785, _ctx);
        kk_box_t _x_x1078;
        kk_std_core_types__tuple2 _x_x1079 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x1078 = kk_std_core_types__tuple2_box(_x_x1079, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x1078, _ctx);
      }
    }
  }
  {
    kk_std_core_types__maybe_drop(_match_x785, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_char_t kk_std_text_parse_no_digit(kk_context_t* _ctx) { /* () -> parse char */ 
  kk_box_t _x_x1073;
  kk_string_t _x_x1074;
  kk_define_string_literal(, _s_x1075, 11, "not a digit", _ctx)
  _x_x1074 = kk_string_dup(_s_x1075, _ctx); /*string*/
  _x_x1073 = kk_std_text_parse_satisfy_fail(_x_x1074, kk_std_text_parse_new_no_digit_fun1076(_ctx), _ctx); /*810*/
  return kk_char_unbox(_x_x1073, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_none_of_fun1083__t {
  struct kk_function_s _base;
  kk_string_t chars;
};
static kk_std_core_types__maybe kk_std_text_parse_none_of_fun1083(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_none_of_fun1083(kk_string_t chars, kk_context_t* _ctx) {
  struct kk_std_text_parse_none_of_fun1083__t* _self = kk_function_alloc_as(struct kk_std_text_parse_none_of_fun1083__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_none_of_fun1083, kk_context());
  _self->chars = chars;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_none_of_fun1083(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  struct kk_std_text_parse_none_of_fun1083__t* _self = kk_function_as(struct kk_std_text_parse_none_of_fun1083__t*, _fself, _ctx);
  kk_string_t chars = _self->chars; /* string */
  kk_drop_match(_self, {kk_string_dup(chars, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _match_x784 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x784, _ctx)) {
    kk_box_t _box_x425 = _match_x784._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x425, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0, _ctx)) {
      kk_box_t _box_x426 = _pat_0.fst;
      kk_box_t _box_x427 = _pat_0.snd;
      kk_char_t c = kk_char_unbox(_box_x426, KK_BORROWED, _ctx);
      bool b_10031;
      kk_string_t _x_x1084 = kk_string_dup(chars, _ctx); /*string*/
      kk_string_t _x_x1085 = kk_std_core_string_char_fs_string(c, _ctx); /*string*/
      b_10031 = kk_string_contains(_x_x1084,_x_x1085,kk_context()); /*bool*/
      bool _x_x1086;
      if (b_10031) {
        _x_x1086 = false; /*bool*/
      }
      else {
        _x_x1086 = true; /*bool*/
      }
      if (_x_x1086) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x427, KK_BORROWED, _ctx);
        kk_string_drop(chars, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x784, _ctx);
        kk_box_t _x_x1087;
        kk_std_core_types__tuple2 _x_x1088 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x1087 = kk_std_core_types__tuple2_box(_x_x1088, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x1087, _ctx);
      }
    }
  }
  {
    kk_string_drop(chars, _ctx);
    kk_std_core_types__maybe_drop(_match_x784, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_char_t kk_std_text_parse_none_of(kk_string_t chars, kk_context_t* _ctx) { /* (chars : string) -> parse char */ 
  kk_box_t _x_x1080;
  kk_string_t _x_x1081 = kk_string_empty(); /*string*/
  _x_x1080 = kk_std_text_parse_satisfy_fail(_x_x1081, kk_std_text_parse_new_none_of_fun1083(chars, _ctx), _ctx); /*810*/
  return kk_char_unbox(_x_x1080, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_none_of_many1_fun1092__t {
  struct kk_function_s _base;
  kk_string_t chars;
};
static kk_std_core_types__maybe kk_std_text_parse_none_of_many1_fun1092(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_none_of_many1_fun1092(kk_string_t chars, kk_context_t* _ctx) {
  struct kk_std_text_parse_none_of_many1_fun1092__t* _self = kk_function_alloc_as(struct kk_std_text_parse_none_of_many1_fun1092__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_none_of_many1_fun1092, kk_context());
  _self->chars = chars;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_none_of_many1_fun1093__t {
  struct kk_function_s _base;
  kk_string_t chars;
};
static bool kk_std_text_parse_none_of_many1_fun1093(kk_function_t _fself, kk_char_t c, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_none_of_many1_fun1093(kk_string_t chars, kk_context_t* _ctx) {
  struct kk_std_text_parse_none_of_many1_fun1093__t* _self = kk_function_alloc_as(struct kk_std_text_parse_none_of_many1_fun1093__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_none_of_many1_fun1093, kk_context());
  _self->chars = chars;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static bool kk_std_text_parse_none_of_many1_fun1093(kk_function_t _fself, kk_char_t c, kk_context_t* _ctx) {
  struct kk_std_text_parse_none_of_many1_fun1093__t* _self = kk_function_as(struct kk_std_text_parse_none_of_many1_fun1093__t*, _fself, _ctx);
  kk_string_t chars = _self->chars; /* string */
  kk_drop_match(_self, {kk_string_dup(chars, _ctx);}, {}, _ctx)
  bool b_10034;
  kk_string_t _x_x1094 = kk_std_core_string_char_fs_string(c, _ctx); /*string*/
  b_10034 = kk_string_contains(chars,_x_x1094,kk_context()); /*bool*/
  if (b_10034) {
    return false;
  }
  {
    return true;
  }
}
static kk_std_core_types__maybe kk_std_text_parse_none_of_many1_fun1092(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  struct kk_std_text_parse_none_of_many1_fun1092__t* _self = kk_function_as(struct kk_std_text_parse_none_of_many1_fun1092__t*, _fself, _ctx);
  kk_string_t chars = _self->chars; /* string */
  kk_drop_match(_self, {kk_string_dup(chars, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple2 _match_x783 = kk_std_text_parse_next_while0(slice, kk_std_text_parse_new_none_of_many1_fun1093(chars, _ctx), kk_std_core_types__new_Nil(_ctx), _ctx); /*(list<char>, sslice/sslice)*/;
  {
    kk_box_t _box_x438 = _match_x783.fst;
    kk_box_t _box_x439 = _match_x783.snd;
    kk_std_core_types__list _pat_0_1 = kk_std_core_types__list_unbox(_box_x438, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice _pat_1_0 = kk_std_core_sslice__sslice_unbox(_box_x439, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Nil(_pat_0_1, _ctx)) {
      kk_std_core_types__tuple2_drop(_match_x783, _ctx);
      return kk_std_core_types__new_Nothing(_ctx);
    }
  }
  {
    kk_box_t _box_x440 = _match_x783.fst;
    kk_box_t _box_x441 = _match_x783.snd;
    kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x441, KK_BORROWED, _ctx);
    kk_std_core_types__list xs = kk_std_core_types__list_unbox(_box_x440, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(rest, _ctx);
    kk_std_core_types__list_dup(xs, _ctx);
    kk_std_core_types__tuple2_drop(_match_x783, _ctx);
    kk_box_t _x_x1095;
    kk_std_core_types__tuple2 _x_x1096 = kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(xs, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x1095 = kk_std_core_types__tuple2_box(_x_x1096, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x1095, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_none_of_many1_fun1098__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_none_of_many1_fun1098(kk_function_t _fself, kk_box_t _b_x453, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_none_of_many1_fun1098(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_none_of_many1_fun1098, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_none_of_many1_fun1098(kk_function_t _fself, kk_box_t _b_x453, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1099;
  kk_std_core_types__list _x_x1100 = kk_std_core_types__list_unbox(_b_x453, KK_OWNED, _ctx); /*list<char>*/
  _x_x1099 = kk_std_core_string_listchar_fs_string(_x_x1100, _ctx); /*string*/
  return kk_string_box(_x_x1099);
}

kk_string_t kk_std_text_parse_none_of_many1(kk_string_t chars, kk_context_t* _ctx) { /* (chars : string) -> parse string */ 
  kk_std_core_types__list x_10264;
  kk_box_t _x_x1089;
  kk_string_t _x_x1090 = kk_string_empty(); /*string*/
  _x_x1089 = kk_std_text_parse_satisfy_fail(_x_x1090, kk_std_text_parse_new_none_of_many1_fun1092(chars, _ctx), _ctx); /*810*/
  x_10264 = kk_std_core_types__list_unbox(_x_x1089, KK_OWNED, _ctx); /*list<char>*/
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10264, _ctx);
    kk_box_t _x_x1097 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_none_of_many1_fun1098(_ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x1097);
  }
  {
    return kk_std_core_string_listchar_fs_string(x_10264, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_one_of_fun1103__t {
  struct kk_function_s _base;
  kk_string_t chars;
};
static kk_std_core_types__maybe kk_std_text_parse_one_of_fun1103(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_one_of_fun1103(kk_string_t chars, kk_context_t* _ctx) {
  struct kk_std_text_parse_one_of_fun1103__t* _self = kk_function_alloc_as(struct kk_std_text_parse_one_of_fun1103__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_one_of_fun1103, kk_context());
  _self->chars = chars;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_one_of_fun1103(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  struct kk_std_text_parse_one_of_fun1103__t* _self = kk_function_as(struct kk_std_text_parse_one_of_fun1103__t*, _fself, _ctx);
  kk_string_t chars = _self->chars; /* string */
  kk_drop_match(_self, {kk_string_dup(chars, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _match_x781 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x781, _ctx)) {
    kk_box_t _box_x455 = _match_x781._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x455, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0, _ctx)) {
      kk_box_t _box_x456 = _pat_0.fst;
      kk_box_t _box_x457 = _pat_0.snd;
      kk_char_t c = kk_char_unbox(_box_x456, KK_BORROWED, _ctx);
      kk_string_t _x_x1104 = kk_string_dup(chars, _ctx); /*string*/
      kk_string_t _x_x1105 = kk_std_core_string_char_fs_string(c, _ctx); /*string*/
      if (kk_string_contains(_x_x1104,_x_x1105,kk_context())) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x457, KK_BORROWED, _ctx);
        kk_string_drop(chars, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x781, _ctx);
        kk_box_t _x_x1106;
        kk_std_core_types__tuple2 _x_x1107 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x1106 = kk_std_core_types__tuple2_box(_x_x1107, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x1106, _ctx);
      }
    }
  }
  {
    kk_string_drop(chars, _ctx);
    kk_std_core_types__maybe_drop(_match_x781, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_char_t kk_std_text_parse_one_of(kk_string_t chars, kk_context_t* _ctx) { /* (chars : string) -> parse char */ 
  kk_box_t _x_x1101;
  kk_string_t _x_x1102 = kk_string_dup(chars, _ctx); /*string*/
  _x_x1101 = kk_std_text_parse_satisfy_fail(_x_x1102, kk_std_text_parse_new_one_of_fun1103(chars, _ctx), _ctx); /*810*/
  return kk_char_unbox(_x_x1101, KK_OWNED, _ctx);
}
extern kk_box_t kk_std_text_parse_one_of_or_fun1109(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_text_parse_one_of_or_fun1109__t* _self = kk_function_as(struct kk_std_text_parse_one_of_or_fun1109__t*, _fself, _ctx);
  kk_string_t chars = _self->chars; /* string */
  kk_drop_match(_self, {kk_string_dup(chars, _ctx);}, {}, _ctx)
  kk_char_t _x_x1110 = kk_std_text_parse_one_of(chars, _ctx); /*char*/
  return kk_char_box(_x_x1110, _ctx);
}
extern kk_box_t kk_std_text_parse_one_of_or_fun1111(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_text_parse_one_of_or_fun1111__t* _self = kk_function_as(struct kk_std_text_parse_one_of_or_fun1111__t*, _fself, _ctx);
  kk_char_t kkloc_default = _self->kkloc_default; /* char */
  kk_drop_match(_self, {kk_skip_dup(kkloc_default, _ctx);}, {}, _ctx)
  return kk_char_box(kkloc_default, _ctx);
}
 
// monadic lift

kk_std_text_parse__parse_error kk_std_text_parse__mlift_parse_10174(kk_std_text_parse__parse_error err1, kk_std_text_parse__parse_error _y_x10123, kk_context_t* _ctx) { /* forall<h,a,e> (err1 : parse-error<a>, parse-error<a>) -> <local<h>|e> parse-error<a> */ 
  if (kk_std_text_parse__is_ParseOk(_y_x10123, _ctx)) {
    struct kk_std_text_parse_ParseOk* _con_x1112 = kk_std_text_parse__as_ParseOk(_y_x10123, _ctx);
    kk_std_core_sslice__sslice rest2 = _con_x1112->rest;
    kk_box_t x2 = _con_x1112->result;
    kk_std_text_parse__parse_error_drop(err1, _ctx);
    kk_reuse_t _ru_x837 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(_y_x10123, _ctx)) {
      _ru_x837 = (kk_datatype_ptr_reuse(_y_x10123, _ctx));
    }
    else {
      kk_std_core_sslice__sslice_dup(rest2, _ctx);
      kk_box_dup(x2, _ctx);
      kk_datatype_ptr_decref(_y_x10123, _ctx);
    }
    return kk_std_text_parse__new_ParseOk(_ru_x837, 0, x2, rest2, _ctx);
  }
  {
    kk_std_text_parse__parse_error_drop(_y_x10123, _ctx);
    return err1;
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_text_parse__mlift_parse_10175_fun1114__t {
  struct kk_function_s _base;
  kk_std_text_parse__parse_error err1;
};
static kk_box_t kk_std_text_parse__mlift_parse_10175_fun1114(kk_function_t _fself, kk_box_t _b_x473, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_parse_10175_fun1114(kk_std_text_parse__parse_error err1, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_10175_fun1114__t* _self = kk_function_alloc_as(struct kk_std_text_parse__mlift_parse_10175_fun1114__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse__mlift_parse_10175_fun1114, kk_context());
  _self->err1 = err1;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse__mlift_parse_10175_fun1114(kk_function_t _fself, kk_box_t _b_x473, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_10175_fun1114__t* _self = kk_function_as(struct kk_std_text_parse__mlift_parse_10175_fun1114__t*, _fself, _ctx);
  kk_std_text_parse__parse_error err1 = _self->err1; /* std/text/parse/parse-error<2446> */
  kk_drop_match(_self, {kk_std_text_parse__parse_error_dup(err1, _ctx);}, {}, _ctx)
  kk_std_text_parse__parse_error _x_x1115;
  kk_std_text_parse__parse_error _y_x10123_475 = kk_std_text_parse__parse_error_unbox(_b_x473, KK_OWNED, _ctx); /*std/text/parse/parse-error<2446>*/;
  if (kk_std_text_parse__is_ParseOk(_y_x10123_475, _ctx)) {
    struct kk_std_text_parse_ParseOk* _con_x1116 = kk_std_text_parse__as_ParseOk(_y_x10123_475, _ctx);
    kk_std_core_sslice__sslice rest2 = _con_x1116->rest;
    kk_box_t x2 = _con_x1116->result;
    kk_std_text_parse__parse_error_drop(err1, _ctx);
    kk_reuse_t _ru_x838 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(_y_x10123_475, _ctx)) {
      _ru_x838 = (kk_datatype_ptr_reuse(_y_x10123_475, _ctx));
    }
    else {
      kk_std_core_sslice__sslice_dup(rest2, _ctx);
      kk_box_dup(x2, _ctx);
      kk_datatype_ptr_decref(_y_x10123_475, _ctx);
    }
    _x_x1115 = kk_std_text_parse__new_ParseOk(_ru_x838, 0, x2, rest2, _ctx); /*std/text/parse/parse-error<33>*/
  }
  else {
    kk_std_text_parse__parse_error_drop(_y_x10123_475, _ctx);
    _x_x1115 = err1; /*std/text/parse/parse-error<33>*/
  }
  return kk_std_text_parse__parse_error_box(_x_x1115, _ctx);
}

kk_std_text_parse__parse_error kk_std_text_parse__mlift_parse_10175(kk_std_text_parse__parse_error err1, kk_function_t resume, kk_unit_t wild__, kk_context_t* _ctx) { /* forall<h,a,e> (err1 : parse-error<a>, resume : (bool) -> <local<h>|e> parse-error<a>, wild_ : ()) -> <local<h>|e> parse-error<a> */ 
  kk_std_text_parse__parse_error x_10266 = kk_function_call(kk_std_text_parse__parse_error, (kk_function_t, bool, kk_context_t*), resume, (resume, false, _ctx), _ctx); /*std/text/parse/parse-error<2446>*/;
  if (kk_yielding(kk_context())) {
    kk_std_text_parse__parse_error_drop(x_10266, _ctx);
    kk_box_t _x_x1113 = kk_std_core_hnd_yield_extend(kk_std_text_parse__new_mlift_parse_10175_fun1114(err1, _ctx), _ctx); /*3728*/
    return kk_std_text_parse__parse_error_unbox(_x_x1113, KK_OWNED, _ctx);
  }
  {
    kk_std_text_parse__parse_error _y_x10123_476 = x_10266; /*std/text/parse/parse-error<2446>*/;
    if (kk_std_text_parse__is_ParseOk(_y_x10123_476, _ctx)) {
      struct kk_std_text_parse_ParseOk* _con_x1117 = kk_std_text_parse__as_ParseOk(_y_x10123_476, _ctx);
      kk_std_core_sslice__sslice rest2 = _con_x1117->rest;
      kk_box_t x2 = _con_x1117->result;
      kk_std_text_parse__parse_error_drop(err1, _ctx);
      kk_reuse_t _ru_x839 = kk_reuse_null; /*@reuse*/;
      if kk_likely(kk_datatype_ptr_is_unique(_y_x10123_476, _ctx)) {
        _ru_x839 = (kk_datatype_ptr_reuse(_y_x10123_476, _ctx));
      }
      else {
        kk_std_core_sslice__sslice_dup(rest2, _ctx);
        kk_box_dup(x2, _ctx);
        kk_datatype_ptr_decref(_y_x10123_476, _ctx);
      }
      return kk_std_text_parse__new_ParseOk(_ru_x839, 0, x2, rest2, _ctx);
    }
    {
      kk_std_text_parse__parse_error_drop(_y_x10123_476, _ctx);
      return err1;
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_text_parse__mlift_parse_10176_fun1120__t {
  struct kk_function_s _base;
  kk_std_text_parse__parse_error _y_x10121;
  kk_function_t resume;
};
static kk_box_t kk_std_text_parse__mlift_parse_10176_fun1120(kk_function_t _fself, kk_box_t _b_x482, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_parse_10176_fun1120(kk_std_text_parse__parse_error _y_x10121, kk_function_t resume, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_10176_fun1120__t* _self = kk_function_alloc_as(struct kk_std_text_parse__mlift_parse_10176_fun1120__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse__mlift_parse_10176_fun1120, kk_context());
  _self->_y_x10121 = _y_x10121;
  _self->resume = resume;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse__mlift_parse_10176_fun1120(kk_function_t _fself, kk_box_t _b_x482, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_10176_fun1120__t* _self = kk_function_as(struct kk_std_text_parse__mlift_parse_10176_fun1120__t*, _fself, _ctx);
  kk_std_text_parse__parse_error _y_x10121 = _self->_y_x10121; /* std/text/parse/parse-error<2446> */
  kk_function_t resume = _self->resume; /* (bool) -> <local<2440>|2447> std/text/parse/parse-error<2446> */
  kk_drop_match(_self, {kk_std_text_parse__parse_error_dup(_y_x10121, _ctx);kk_function_dup(resume, _ctx);}, {}, _ctx)
  kk_unit_t wild___484 = kk_Unit;
  kk_unit_unbox(_b_x482);
  kk_std_text_parse__parse_error _x_x1121 = kk_std_text_parse__mlift_parse_10175(_y_x10121, resume, wild___484, _ctx); /*std/text/parse/parse-error<2446>*/
  return kk_std_text_parse__parse_error_box(_x_x1121, _ctx);
}

kk_std_text_parse__parse_error kk_std_text_parse__mlift_parse_10176(kk_ref_t input, kk_function_t resume, kk_std_core_sslice__sslice save, kk_std_text_parse__parse_error _y_x10121, kk_context_t* _ctx) { /* forall<h,a,e> (input : local-var<h,sslice/sslice>, resume : (bool) -> <local<h>|e> parse-error<a>, save : sslice/sslice, parse-error<a>) -> <local<h>|e> parse-error<a> */ 
  if (kk_std_text_parse__is_ParseOk(_y_x10121, _ctx)) {
    struct kk_std_text_parse_ParseOk* _con_x1118 = kk_std_text_parse__as_ParseOk(_y_x10121, _ctx);
    kk_std_core_sslice__sslice rest1 = _con_x1118->rest;
    kk_box_t x1 = _con_x1118->result;
    kk_std_core_sslice__sslice_drop(save, _ctx);
    kk_function_drop(resume, _ctx);
    kk_ref_drop(input, _ctx);
    kk_reuse_t _ru_x840 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(_y_x10121, _ctx)) {
      _ru_x840 = (kk_datatype_ptr_reuse(_y_x10121, _ctx));
    }
    else {
      kk_std_core_sslice__sslice_dup(rest1, _ctx);
      kk_box_dup(x1, _ctx);
      kk_datatype_ptr_decref(_y_x10121, _ctx);
    }
    return kk_std_text_parse__new_ParseOk(_ru_x840, 0, x1, rest1, _ctx);
  }
  {
    kk_unit_t x_10270 = kk_Unit;
    kk_unit_t _brw_x779 = kk_Unit;
    kk_ref_set_borrow(input,(kk_std_core_sslice__sslice_box(save, _ctx)),kk_context());
    kk_ref_drop(input, _ctx);
    _brw_x779;
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x1119 = kk_std_core_hnd_yield_extend(kk_std_text_parse__new_mlift_parse_10176_fun1120(_y_x10121, resume, _ctx), _ctx); /*3728*/
      return kk_std_text_parse__parse_error_unbox(_x_x1119, KK_OWNED, _ctx);
    }
    {
      return kk_std_text_parse__mlift_parse_10175(_y_x10121, resume, x_10270, _ctx);
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_text_parse__mlift_parse_10177_fun1124__t {
  struct kk_function_s _base;
  kk_ref_t input;
  kk_function_t resume;
  kk_std_core_sslice__sslice save;
};
static kk_box_t kk_std_text_parse__mlift_parse_10177_fun1124(kk_function_t _fself, kk_box_t _b_x486, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_parse_10177_fun1124(kk_ref_t input, kk_function_t resume, kk_std_core_sslice__sslice save, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_10177_fun1124__t* _self = kk_function_alloc_as(struct kk_std_text_parse__mlift_parse_10177_fun1124__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse__mlift_parse_10177_fun1124, kk_context());
  _self->input = input;
  _self->resume = resume;
  _self->save = save;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse__mlift_parse_10177_fun1124(kk_function_t _fself, kk_box_t _b_x486, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_10177_fun1124__t* _self = kk_function_as(struct kk_std_text_parse__mlift_parse_10177_fun1124__t*, _fself, _ctx);
  kk_ref_t input = _self->input; /* local-var<2440,sslice/sslice> */
  kk_function_t resume = _self->resume; /* (bool) -> <local<2440>|2447> std/text/parse/parse-error<2446> */
  kk_std_core_sslice__sslice save = _self->save; /* sslice/sslice */
  kk_drop_match(_self, {kk_ref_dup(input, _ctx);kk_function_dup(resume, _ctx);kk_std_core_sslice__sslice_dup(save, _ctx);}, {}, _ctx)
  kk_std_text_parse__parse_error _y_x10121_488 = kk_std_text_parse__parse_error_unbox(_b_x486, KK_OWNED, _ctx); /*std/text/parse/parse-error<2446>*/;
  kk_std_text_parse__parse_error _x_x1125 = kk_std_text_parse__mlift_parse_10176(input, resume, save, _y_x10121_488, _ctx); /*std/text/parse/parse-error<2446>*/
  return kk_std_text_parse__parse_error_box(_x_x1125, _ctx);
}

kk_std_text_parse__parse_error kk_std_text_parse__mlift_parse_10177(kk_ref_t input, kk_function_t resume, kk_std_core_sslice__sslice save, kk_context_t* _ctx) { /* forall<h,a,e> (input : local-var<h,sslice/sslice>, resume : (bool) -> <local<h>|e> parse-error<a>, save : sslice/sslice) -> <local<h>|e> parse-error<a> */ 
  kk_std_text_parse__parse_error x_10272;
  kk_function_t _x_x1122 = kk_function_dup(resume, _ctx); /*(bool) -> <local<2440>|2447> std/text/parse/parse-error<2446>*/
  x_10272 = kk_function_call(kk_std_text_parse__parse_error, (kk_function_t, bool, kk_context_t*), _x_x1122, (_x_x1122, true, _ctx), _ctx); /*std/text/parse/parse-error<2446>*/
  if (kk_yielding(kk_context())) {
    kk_std_text_parse__parse_error_drop(x_10272, _ctx);
    kk_box_t _x_x1123 = kk_std_core_hnd_yield_extend(kk_std_text_parse__new_mlift_parse_10177_fun1124(input, resume, save, _ctx), _ctx); /*3728*/
    return kk_std_text_parse__parse_error_unbox(_x_x1123, KK_OWNED, _ctx);
  }
  {
    return kk_std_text_parse__mlift_parse_10176(input, resume, save, x_10272, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_text_parse__mlift_parse_10179_fun1127__t {
  struct kk_function_s _base;
  kk_box_t x;
};
static kk_box_t kk_std_text_parse__mlift_parse_10179_fun1127(kk_function_t _fself, kk_box_t _b_x496, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_parse_10179_fun1127(kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_10179_fun1127__t* _self = kk_function_alloc_as(struct kk_std_text_parse__mlift_parse_10179_fun1127__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse__mlift_parse_10179_fun1127, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse__mlift_parse_10179_fun1127(kk_function_t _fself, kk_box_t _b_x496, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_10179_fun1127__t* _self = kk_function_as(struct kk_std_text_parse__mlift_parse_10179_fun1127__t*, _fself, _ctx);
  kk_box_t x = _self->x; /* 2404 */
  kk_drop_match(_self, {kk_box_dup(x, _ctx);}, {}, _ctx)
  kk_unit_t wild___0_498 = kk_Unit;
  kk_unit_unbox(_b_x496);
  kk_std_core_types__maybe _x_x1128 = kk_std_core_types__new_Just(x, _ctx); /*maybe<91>*/
  return kk_std_core_types__maybe_box(_x_x1128, _ctx);
}

kk_std_core_types__maybe kk_std_text_parse__mlift_parse_10179(kk_ref_t input, kk_function_t pred, kk_std_core_sslice__sslice inp, kk_context_t* _ctx) { /* forall<a,h,e> (input : local-var<h,sslice/sslice>, pred : (sslice/sslice) -> maybe<(a, sslice/sslice)>, inp : sslice/sslice) -> <local<h>|e> maybe<a> */ 
  kk_std_core_types__maybe _match_x774 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, kk_std_core_sslice__sslice, kk_context_t*), pred, (pred, inp, _ctx), _ctx); /*maybe<(2404, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x774, _ctx)) {
    kk_box_t _box_x489 = _match_x774._cons.Just.value;
    kk_std_core_types__tuple2 _pat_9 = kk_std_core_types__tuple2_unbox(_box_x489, KK_BORROWED, _ctx);
    kk_box_t _box_x490 = _pat_9.snd;
    kk_std_core_sslice__sslice cap = kk_std_core_sslice__sslice_unbox(_box_x490, KK_BORROWED, _ctx);
    kk_box_t x = _pat_9.fst;
    kk_std_core_sslice__sslice_dup(cap, _ctx);
    kk_box_dup(x, _ctx);
    kk_std_core_types__maybe_drop(_match_x774, _ctx);
    kk_unit_t x_0_10274 = kk_Unit;
    kk_unit_t _brw_x776 = kk_Unit;
    kk_ref_set_borrow(input,(kk_std_core_sslice__sslice_box(cap, _ctx)),kk_context());
    kk_ref_drop(input, _ctx);
    _brw_x776;
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x1126 = kk_std_core_hnd_yield_extend(kk_std_text_parse__new_mlift_parse_10179_fun1127(x, _ctx), _ctx); /*3728*/
      return kk_std_core_types__maybe_unbox(_x_x1126, KK_OWNED, _ctx);
    }
    {
      return kk_std_core_types__new_Just(x, _ctx);
    }
  }
  {
    kk_ref_drop(input, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_parse_fun1131__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_std_text_parse_parse_fun1131(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1131(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1131__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1131__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1131, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_parse_fun1131(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1131__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1131__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  return kk_ref_get(loc,kk_context());
}


// lift anonymous function
struct kk_std_text_parse_parse_fun1134__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_std_text_parse_parse_fun1134(kk_function_t _fself, int32_t _b_x512, kk_std_core_hnd__ev _b_x513, kk_box_t _b_x514, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1134(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1134__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1134__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1134, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_parse_fun1135__t {
  struct kk_function_s _base;
  kk_box_t _b_x514;
  kk_ref_t loc;
};
static kk_box_t kk_std_text_parse_parse_fun1135(kk_function_t _fself, kk_function_t _b_x509, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1135(kk_box_t _b_x514, kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1135__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1135__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1135, kk_context());
  _self->_b_x514 = _b_x514;
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_parse_fun1139__t {
  struct kk_function_s _base;
  kk_box_t _b_x514;
};
static kk_box_t kk_std_text_parse_parse_fun1139(kk_function_t _fself, kk_box_t _b_x506, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1139(kk_box_t _b_x514, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1139__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1139__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1139, kk_context());
  _self->_b_x514 = _b_x514;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_parse_fun1139(kk_function_t _fself, kk_box_t _b_x506, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1139__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1139__t*, _fself, _ctx);
  kk_box_t _b_x514 = _self->_b_x514; /* 45 */
  kk_drop_match(_self, {kk_box_dup(_b_x514, _ctx);}, {}, _ctx)
  kk_std_text_parse__parse_error _x_x1140;
  kk_string_t _x_x1141 = kk_string_unbox(_b_x514); /*string*/
  kk_std_core_sslice__sslice _x_x1142 = kk_std_core_sslice__sslice_unbox(_b_x506, KK_OWNED, _ctx); /*sslice/sslice*/
  _x_x1140 = kk_std_text_parse__new_ParseError(kk_reuse_null, 0, _x_x1141, _x_x1142, _ctx); /*std/text/parse/parse-error<33>*/
  return kk_std_text_parse__parse_error_box(_x_x1140, _ctx);
}
static kk_box_t kk_std_text_parse_parse_fun1135(kk_function_t _fself, kk_function_t _b_x509, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1135__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1135__t*, _fself, _ctx);
  kk_box_t _b_x514 = _self->_b_x514; /* 45 */
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_drop_match(_self, {kk_box_dup(_b_x514, _ctx);kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_function_drop(_b_x509, _ctx);
  kk_std_core_sslice__sslice x_0_10281;
  kk_box_t _x_x1136 = kk_ref_get(loc,kk_context()); /*3540*/
  x_0_10281 = kk_std_core_sslice__sslice_unbox(_x_x1136, KK_OWNED, _ctx); /*sslice/sslice*/
  kk_std_text_parse__parse_error _x_x1137;
  if (kk_yielding(kk_context())) {
    kk_std_core_sslice__sslice_drop(x_0_10281, _ctx);
    kk_box_t _x_x1138 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_parse_fun1139(_b_x514, _ctx), _ctx); /*3728*/
    _x_x1137 = kk_std_text_parse__parse_error_unbox(_x_x1138, KK_OWNED, _ctx); /*std/text/parse/parse-error<2446>*/
  }
  else {
    kk_string_t _x_x1143 = kk_string_unbox(_b_x514); /*string*/
    _x_x1137 = kk_std_text_parse__new_ParseError(kk_reuse_null, 0, _x_x1143, x_0_10281, _ctx); /*std/text/parse/parse-error<2446>*/
  }
  return kk_std_text_parse__parse_error_box(_x_x1137, _ctx);
}
static kk_box_t kk_std_text_parse_parse_fun1134(kk_function_t _fself, int32_t _b_x512, kk_std_core_hnd__ev _b_x513, kk_box_t _b_x514, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1134__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1134__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(_b_x513, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to_final(_b_x512, kk_std_text_parse_new_parse_fun1135(_b_x514, loc, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_text_parse_parse_fun1146__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_std_text_parse_parse_fun1146(kk_function_t _fself, int32_t _b_x531, kk_std_core_hnd__ev _b_x532, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1146(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1146__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1146__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1146, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_parse_fun1147__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_std_text_parse_parse_fun1147(kk_function_t _fself, kk_function_t _b_x528, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1147(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1147__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1147__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1147, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_parse_fun1148__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_std_text_parse_parse_fun1148(kk_function_t _fself, kk_box_t _b_x522, kk_function_t _b_x523, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1148(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1148__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1148__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1148, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_parse_fun1149__t {
  struct kk_function_s _base;
  kk_function_t _b_x523;
};
static kk_std_text_parse__parse_error kk_std_text_parse_parse_fun1149(kk_function_t _fself, bool _b_x524, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1149(kk_function_t _b_x523, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1149__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1149__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1149, kk_context());
  _self->_b_x523 = _b_x523;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_text_parse__parse_error kk_std_text_parse_parse_fun1149(kk_function_t _fself, bool _b_x524, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1149__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1149__t*, _fself, _ctx);
  kk_function_t _b_x523 = _self->_b_x523; /* (7816) -> 7817 7818 */
  kk_drop_match(_self, {kk_function_dup(_b_x523, _ctx);}, {}, _ctx)
  kk_box_t _x_x1150 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _b_x523, (_b_x523, kk_bool_box(_b_x524), _ctx), _ctx); /*7818*/
  return kk_std_text_parse__parse_error_unbox(_x_x1150, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_parse_fun1155__t {
  struct kk_function_s _base;
  kk_ref_t loc;
  kk_function_t r_585;
};
static kk_box_t kk_std_text_parse_parse_fun1155(kk_function_t _fself, kk_box_t _b_x518, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1155(kk_ref_t loc, kk_function_t r_585, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1155__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1155__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1155, kk_context());
  _self->loc = loc;
  _self->r_585 = r_585;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_parse_fun1155(kk_function_t _fself, kk_box_t _b_x518, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1155__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1155__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_function_t r_585 = _self->r_585; /* (bool) -> <local<2440>|2447> std/text/parse/parse-error<2446> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);kk_function_dup(r_585, _ctx);}, {}, _ctx)
  kk_std_text_parse__parse_error _x_x1156;
  kk_std_core_sslice__sslice _x_x1157 = kk_std_core_sslice__sslice_unbox(_b_x518, KK_OWNED, _ctx); /*sslice/sslice*/
  _x_x1156 = kk_std_text_parse__mlift_parse_10177(loc, r_585, _x_x1157, _ctx); /*std/text/parse/parse-error<2446>*/
  return kk_std_text_parse__parse_error_box(_x_x1156, _ctx);
}
static kk_box_t kk_std_text_parse_parse_fun1148(kk_function_t _fself, kk_box_t _b_x522, kk_function_t _b_x523, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1148__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1148__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x522, _ctx);
  kk_function_t r_585 = kk_std_text_parse_new_parse_fun1149(_b_x523, _ctx); /*(bool) -> <local<2440>|2447> std/text/parse/parse-error<2446>*/;
  kk_std_core_sslice__sslice x_1_10286;
  kk_box_t _x_x1151;
  kk_ref_t _x_x1152 = kk_ref_dup(loc, _ctx); /*local-var<2440,sslice/sslice>*/
  _x_x1151 = kk_ref_get(_x_x1152,kk_context()); /*3618*/
  x_1_10286 = kk_std_core_sslice__sslice_unbox(_x_x1151, KK_OWNED, _ctx); /*sslice/sslice*/
  kk_std_text_parse__parse_error _x_x1153;
  if (kk_yielding(kk_context())) {
    kk_std_core_sslice__sslice_drop(x_1_10286, _ctx);
    kk_box_t _x_x1154 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_parse_fun1155(loc, r_585, _ctx), _ctx); /*3728*/
    _x_x1153 = kk_std_text_parse__parse_error_unbox(_x_x1154, KK_OWNED, _ctx); /*std/text/parse/parse-error<2446>*/
  }
  else {
    _x_x1153 = kk_std_text_parse__mlift_parse_10177(loc, r_585, x_1_10286, _ctx); /*std/text/parse/parse-error<2446>*/
  }
  return kk_std_text_parse__parse_error_box(_x_x1153, _ctx);
}
static kk_box_t kk_std_text_parse_parse_fun1147(kk_function_t _fself, kk_function_t _b_x528, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1147__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1147__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect(kk_unit_box(kk_Unit), kk_std_text_parse_new_parse_fun1148(loc, _ctx), _b_x528, _ctx);
}
static kk_box_t kk_std_text_parse_parse_fun1146(kk_function_t _fself, int32_t _b_x531, kk_std_core_hnd__ev _b_x532, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1146__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1146__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(_b_x532, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(_b_x531, kk_std_text_parse_new_parse_fun1147(loc, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_text_parse_parse_fun1160__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_std_text_parse_parse_fun1160(kk_function_t _fself, kk_box_t _b_x538, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1160(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1160__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1160__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1160, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_parse_fun1161__t {
  struct kk_function_s _base;
  kk_box_t _b_x538;
};
static kk_std_core_types__maybe kk_std_text_parse_parse_fun1161(kk_function_t _fself, kk_std_core_sslice__sslice _b_x541, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1161(kk_box_t _b_x538, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1161__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1161__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1161, kk_context());
  _self->_b_x538 = _b_x538;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_parse_fun1161(kk_function_t _fself, kk_std_core_sslice__sslice _b_x541, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1161__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1161__t*, _fself, _ctx);
  kk_box_t _b_x538 = _self->_b_x538; /* 9374 */
  kk_drop_match(_self, {kk_box_dup(_b_x538, _ctx);}, {}, _ctx)
  kk_box_t _x_x1162;
  kk_function_t _x_x1163 = kk_function_unbox(_b_x538, _ctx); /*(539) -> 540*/
  _x_x1162 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x1163, (_x_x1163, kk_std_core_sslice__sslice_box(_b_x541, _ctx), _ctx), _ctx); /*540*/
  return kk_std_core_types__maybe_unbox(_x_x1162, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_parse_fun1168__t {
  struct kk_function_s _base;
  kk_ref_t loc;
  kk_function_t pred_581;
};
static kk_box_t kk_std_text_parse_parse_fun1168(kk_function_t _fself, kk_box_t _b_x536, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1168(kk_ref_t loc, kk_function_t pred_581, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1168__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1168__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1168, kk_context());
  _self->loc = loc;
  _self->pred_581 = pred_581;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_parse_fun1168(kk_function_t _fself, kk_box_t _b_x536, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1168__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1168__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_function_t pred_581 = _self->pred_581; /* (sslice/sslice) -> maybe<(2404, sslice/sslice)> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);kk_function_dup(pred_581, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _x_x1169;
  kk_std_core_sslice__sslice _x_x1170 = kk_std_core_sslice__sslice_unbox(_b_x536, KK_OWNED, _ctx); /*sslice/sslice*/
  _x_x1169 = kk_std_text_parse__mlift_parse_10179(loc, pred_581, _x_x1170, _ctx); /*maybe<2404>*/
  return kk_std_core_types__maybe_box(_x_x1169, _ctx);
}
static kk_box_t kk_std_text_parse_parse_fun1160(kk_function_t _fself, kk_box_t _b_x538, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1160__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1160__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_function_t pred_581 = kk_std_text_parse_new_parse_fun1161(_b_x538, _ctx); /*(sslice/sslice) -> maybe<(2404, sslice/sslice)>*/;
  kk_std_core_sslice__sslice x_2_10288;
  kk_box_t _x_x1164;
  kk_ref_t _x_x1165 = kk_ref_dup(loc, _ctx); /*local-var<2440,sslice/sslice>*/
  _x_x1164 = kk_ref_get(_x_x1165,kk_context()); /*3694*/
  x_2_10288 = kk_std_core_sslice__sslice_unbox(_x_x1164, KK_OWNED, _ctx); /*sslice/sslice*/
  kk_std_core_types__maybe _x_x1166;
  if (kk_yielding(kk_context())) {
    kk_std_core_sslice__sslice_drop(x_2_10288, _ctx);
    kk_box_t _x_x1167 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_parse_fun1168(loc, pred_581, _ctx), _ctx); /*3728*/
    _x_x1166 = kk_std_core_types__maybe_unbox(_x_x1167, KK_OWNED, _ctx); /*maybe<2404>*/
  }
  else {
    _x_x1166 = kk_std_text_parse__mlift_parse_10179(loc, pred_581, x_2_10288, _ctx); /*maybe<2404>*/
  }
  return kk_std_core_types__maybe_box(_x_x1166, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_parse_fun1173__t {
  struct kk_function_s _base;
  kk_ref_t loc;
};
static kk_box_t kk_std_text_parse_parse_fun1173(kk_function_t _fself, kk_box_t _b_x549, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1173(kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1173__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1173__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1173, kk_context());
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_parse_fun1177__t {
  struct kk_function_s _base;
  kk_box_t _b_x549;
};
static kk_box_t kk_std_text_parse_parse_fun1177(kk_function_t _fself, kk_box_t _b_x545, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_fun1177(kk_box_t _b_x549, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1177__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_fun1177__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_fun1177, kk_context());
  _self->_b_x549 = _b_x549;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_parse_fun1177(kk_function_t _fself, kk_box_t _b_x545, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1177__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1177__t*, _fself, _ctx);
  kk_box_t _b_x549 = _self->_b_x549; /* 510 */
  kk_drop_match(_self, {kk_box_dup(_b_x549, _ctx);}, {}, _ctx)
  kk_std_text_parse__parse_error _x_x1178;
  kk_std_core_sslice__sslice _x_x1179 = kk_std_core_sslice__sslice_unbox(_b_x545, KK_OWNED, _ctx); /*sslice/sslice*/
  _x_x1178 = kk_std_text_parse__new_ParseOk(kk_reuse_null, 0, _b_x549, _x_x1179, _ctx); /*std/text/parse/parse-error<33>*/
  return kk_std_text_parse__parse_error_box(_x_x1178, _ctx);
}
static kk_box_t kk_std_text_parse_parse_fun1173(kk_function_t _fself, kk_box_t _b_x549, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_fun1173__t* _self = kk_function_as(struct kk_std_text_parse_parse_fun1173__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<2440,sslice/sslice> */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_std_core_sslice__sslice x_3_10290;
  kk_box_t _x_x1174 = kk_ref_get(loc,kk_context()); /*3719*/
  x_3_10290 = kk_std_core_sslice__sslice_unbox(_x_x1174, KK_OWNED, _ctx); /*sslice/sslice*/
  kk_std_text_parse__parse_error _x_x1175;
  if (kk_yielding(kk_context())) {
    kk_std_core_sslice__sslice_drop(x_3_10290, _ctx);
    kk_box_t _x_x1176 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_parse_fun1177(_b_x549, _ctx), _ctx); /*3728*/
    _x_x1175 = kk_std_text_parse__parse_error_unbox(_x_x1176, KK_OWNED, _ctx); /*std/text/parse/parse-error<2446>*/
  }
  else {
    _x_x1175 = kk_std_text_parse__new_ParseOk(kk_reuse_null, 0, _b_x549, x_3_10290, _ctx); /*std/text/parse/parse-error<2446>*/
  }
  return kk_std_text_parse__parse_error_box(_x_x1175, _ctx);
}

kk_std_text_parse__parse_error kk_std_text_parse_parse(kk_std_core_sslice__sslice input0, kk_function_t p, kk_context_t* _ctx) { /* forall<a,e> (input0 : sslice/sslice, p : () -> <parse|e> a) -> e parse-error<a> */ 
  kk_ref_t loc = kk_ref_alloc((kk_std_core_sslice__sslice_box(input0, _ctx)),kk_context()); /*local-var<2440,sslice/sslice>*/;
  kk_std_text_parse__parse _b_x546_550;
  kk_std_core_hnd__clause0 _x_x1129;
  kk_function_t _x_x1130;
  kk_ref_dup(loc, _ctx);
  _x_x1130 = kk_std_text_parse_new_parse_fun1131(loc, _ctx); /*() -> 9302 3497*/
  _x_x1129 = kk_std_core_hnd_clause_tail0(_x_x1130, _ctx); /*hnd/clause0<9305,9304,9302,9303>*/
  kk_std_core_hnd__clause1 _x_x1132;
  kk_function_t _x_x1133;
  kk_ref_dup(loc, _ctx);
  _x_x1133 = kk_std_text_parse_new_parse_fun1134(loc, _ctx); /*(hnd/marker<48,49>, hnd/ev<47>, 45) -> 48 3846*/
  _x_x1132 = kk_std_core_hnd__new_Clause1(_x_x1133, _ctx); /*hnd/clause1<45,46,47,48,49>*/
  kk_std_core_hnd__clause0 _x_x1144;
  kk_function_t _x_x1145;
  kk_ref_dup(loc, _ctx);
  _x_x1145 = kk_std_text_parse_new_parse_fun1146(loc, _ctx); /*(hnd/marker<37,38>, hnd/ev<36>) -> 37 7174*/
  _x_x1144 = kk_std_core_hnd__new_Clause0(_x_x1145, _ctx); /*hnd/clause0<35,36,37,38>*/
  kk_std_core_hnd__clause1 _x_x1158;
  kk_function_t _x_x1159;
  kk_ref_dup(loc, _ctx);
  _x_x1159 = kk_std_text_parse_new_parse_fun1160(loc, _ctx); /*(9374) -> 9371 9375*/
  _x_x1158 = kk_std_core_hnd_clause_tail1(_x_x1159, _ctx); /*hnd/clause1<9374,9375,9373,9371,9372>*/
  _b_x546_550 = kk_std_text_parse__new_Hnd_parse(kk_reuse_null, 0, kk_integer_from_small(3), _x_x1129, _x_x1132, _x_x1144, _x_x1158, _ctx); /*std/text/parse/parse<<local<2440>|2447>,std/text/parse/parse-error<2446>>*/
  kk_std_text_parse__parse_error res;
  kk_box_t _x_x1171;
  kk_function_t _x_x1172;
  kk_ref_dup(loc, _ctx);
  _x_x1172 = kk_std_text_parse_new_parse_fun1173(loc, _ctx); /*(510) -> 511 512*/
  _x_x1171 = kk_std_text_parse__handle_parse(_b_x546_550, _x_x1172, p, _ctx); /*512*/
  res = kk_std_text_parse__parse_error_unbox(_x_x1171, KK_OWNED, _ctx); /*std/text/parse/parse-error<2446>*/
  kk_box_t _x_x1180 = kk_std_core_hnd_prompt_local_var(loc, kk_std_text_parse__parse_error_box(res, _ctx), _ctx); /*21474*/
  return kk_std_text_parse__parse_error_unbox(_x_x1180, KK_OWNED, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_std_text_parse__mlift_parse_eof_10182_fun1183__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse__mlift_parse_eof_10182_fun1183(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_parse_eof_10182_fun1183(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse__mlift_parse_eof_10182_fun1183, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse__mlift_parse_eof_10182_fun1183(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x1184 = kk_Unit;
  kk_std_text_parse_eof(_ctx);
  return kk_unit_box(_x_x1184);
}


// lift anonymous function
struct kk_std_text_parse__mlift_parse_eof_10182_fun1185__t {
  struct kk_function_s _base;
  kk_box_t x;
};
static kk_box_t kk_std_text_parse__mlift_parse_eof_10182_fun1185(kk_function_t _fself, kk_box_t _b_x594, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_parse_eof_10182_fun1185(kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_eof_10182_fun1185__t* _self = kk_function_alloc_as(struct kk_std_text_parse__mlift_parse_eof_10182_fun1185__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse__mlift_parse_eof_10182_fun1185, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse__mlift_parse_eof_10182_fun1185(kk_function_t _fself, kk_box_t _b_x594, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_parse_eof_10182_fun1185__t* _self = kk_function_as(struct kk_std_text_parse__mlift_parse_eof_10182_fun1185__t*, _fself, _ctx);
  kk_box_t x = _self->x; /* 2475 */
  kk_drop_match(_self, {kk_box_dup(x, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x594, _ctx);
  return x;
}

kk_box_t kk_std_text_parse__mlift_parse_eof_10182(kk_box_t x, kk_context_t* _ctx) { /* forall<a,e> (x : a) -> <parse|e> a */ 
  kk_ssize_t _b_x589_591;
  kk_std_core_hnd__htag _x_x1181 = kk_std_core_hnd__htag_dup(kk_std_text_parse__tag_parse, _ctx); /*hnd/htag<std/text/parse/parse>*/
  _b_x589_591 = kk_std_core_hnd__evv_index(_x_x1181, _ctx); /*hnd/ev-index*/
  kk_unit_t x_0_10295 = kk_Unit;
  kk_box_t _x_x1182 = kk_std_core_hnd__open_at0(_b_x589_591, kk_std_text_parse__new_mlift_parse_eof_10182_fun1183(_ctx), _ctx); /*5726*/
  kk_unit_unbox(_x_x1182);
  if (kk_yielding(kk_context())) {
    return kk_std_core_hnd_yield_extend(kk_std_text_parse__new_mlift_parse_eof_10182_fun1185(x, _ctx), _ctx);
  }
  {
    return x;
  }
}


// lift anonymous function
struct kk_std_text_parse_parse_eof_fun1186__t {
  struct kk_function_s _base;
  kk_function_t p;
};
static kk_box_t kk_std_text_parse_parse_eof_fun1186(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_eof_fun1186(kk_function_t p, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_eof_fun1186__t* _self = kk_function_alloc_as(struct kk_std_text_parse_parse_eof_fun1186__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_parse_eof_fun1186, kk_context());
  _self->p = p;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_text_parse_parse_eof_fun1188__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_parse_eof_fun1188(kk_function_t _fself, kk_box_t _x1_x1187, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_parse_eof_fun1188(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_parse_eof_fun1188, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_parse_eof_fun1188(kk_function_t _fself, kk_box_t _x1_x1187, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_text_parse__mlift_parse_eof_10182(_x1_x1187, _ctx);
}
static kk_box_t kk_std_text_parse_parse_eof_fun1186(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_text_parse_parse_eof_fun1186__t* _self = kk_function_as(struct kk_std_text_parse_parse_eof_fun1186__t*, _fself, _ctx);
  kk_function_t p = _self->p; /* () -> <std/text/parse/parse|2476> 2475 */
  kk_drop_match(_self, {kk_function_dup(p, _ctx);}, {}, _ctx)
  kk_box_t x_10299 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), p, (p, _ctx), _ctx); /*2475*/;
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10299, _ctx);
    return kk_std_core_hnd_yield_extend(kk_std_text_parse_new_parse_eof_fun1188(_ctx), _ctx);
  }
  {
    return kk_std_text_parse__mlift_parse_eof_10182(x_10299, _ctx);
  }
}

kk_std_text_parse__parse_error kk_std_text_parse_parse_eof(kk_std_core_sslice__sslice input, kk_function_t p, kk_context_t* _ctx) { /* forall<a,e> (input : sslice/sslice, p : () -> <parse|e> a) -> e parse-error<a> */ 
  return kk_std_text_parse_parse(input, kk_std_text_parse_new_parse_eof_fun1186(p, _ctx), _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_std_text_parse__mlift_pnat_10183_fun1191__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse__mlift_pnat_10183_fun1191(kk_function_t _fself, kk_box_t _b_x601, kk_box_t _b_x602, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_pnat_10183_fun1191(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse__mlift_pnat_10183_fun1191, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse__mlift_pnat_10183_fun1191(kk_function_t _fself, kk_box_t _b_x601, kk_box_t _b_x602, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__maybe m_606 = kk_std_core_types__maybe_unbox(_b_x601, KK_OWNED, _ctx); /*maybe<int>*/;
  kk_integer_t nothing_607 = kk_integer_unbox(_b_x602, _ctx); /*int*/;
  kk_integer_t _x_x1192;
  if (kk_std_core_types__is_Nothing(m_606, _ctx)) {
    _x_x1192 = nothing_607; /*int*/
  }
  else {
    kk_box_t _box_x597 = m_606._cons.Just.value;
    kk_integer_t x = kk_integer_unbox(_box_x597, _ctx);
    kk_integer_drop(nothing_607, _ctx);
    kk_integer_dup(x, _ctx);
    kk_std_core_types__maybe_drop(m_606, _ctx);
    _x_x1192 = x; /*int*/
  }
  return kk_integer_box(_x_x1192, _ctx);
}

kk_integer_t kk_std_text_parse__mlift_pnat_10183(kk_std_core_types__list _y_x10136, kk_context_t* _ctx) { /* (list<char>) -> parse int */ 
  kk_std_core_types__maybe _x_x1_10162;
  kk_string_t _x_x1189 = kk_std_core_string_listchar_fs_string(_y_x10136, _ctx); /*string*/
  _x_x1_10162 = kk_std_core_int_parse_int(_x_x1189, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_box_t _x_x1190 = kk_std_core_hnd__open_none2(kk_std_text_parse__new_mlift_pnat_10183_fun1191(_ctx), kk_std_core_types__maybe_box(_x_x1_10162, _ctx), kk_integer_box(kk_integer_from_small(0), _ctx), _ctx); /*3037*/
  return kk_integer_unbox(_x_x1190, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_pnat_fun1196__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_pnat_fun1196(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pnat_fun1196(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_pnat_fun1196, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_pnat_fun1198__t {
  struct kk_function_s _base;
};
static bool kk_std_text_parse_pnat_fun1198(kk_function_t _fself, kk_char_t _x1_x1197, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pnat_fun1198(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_pnat_fun1198, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static bool kk_std_text_parse_pnat_fun1198(kk_function_t _fself, kk_char_t _x1_x1197, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_char_is_digit(_x1_x1197, _ctx);
}
static kk_std_core_types__maybe kk_std_text_parse_pnat_fun1196(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__tuple2 _match_x767 = kk_std_text_parse_next_while0(slice, kk_std_text_parse_new_pnat_fun1198(_ctx), kk_std_core_types__new_Nil(_ctx), _ctx); /*(list<char>, sslice/sslice)*/;
  {
    kk_box_t _box_x608 = _match_x767.fst;
    kk_box_t _box_x609 = _match_x767.snd;
    kk_std_core_types__list _pat_0_0 = kk_std_core_types__list_unbox(_box_x608, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice _pat_1_0 = kk_std_core_sslice__sslice_unbox(_box_x609, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Nil(_pat_0_0, _ctx)) {
      kk_std_core_types__tuple2_drop(_match_x767, _ctx);
      return kk_std_core_types__new_Nothing(_ctx);
    }
  }
  {
    kk_box_t _box_x610 = _match_x767.fst;
    kk_box_t _box_x611 = _match_x767.snd;
    kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x611, KK_BORROWED, _ctx);
    kk_std_core_types__list xs = kk_std_core_types__list_unbox(_box_x610, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(rest, _ctx);
    kk_std_core_types__list_dup(xs, _ctx);
    kk_std_core_types__tuple2_drop(_match_x767, _ctx);
    kk_box_t _x_x1199;
    kk_std_core_types__tuple2 _x_x1200 = kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(xs, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x1199 = kk_std_core_types__tuple2_box(_x_x1200, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x1199, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_pnat_fun1202__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_pnat_fun1202(kk_function_t _fself, kk_box_t _b_x623, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pnat_fun1202(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_pnat_fun1202, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_pnat_fun1202(kk_function_t _fself, kk_box_t _b_x623, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x1203;
  kk_std_core_types__list _x_x1204 = kk_std_core_types__list_unbox(_b_x623, KK_OWNED, _ctx); /*list<char>*/
  _x_x1203 = kk_std_text_parse__mlift_pnat_10183(_x_x1204, _ctx); /*int*/
  return kk_integer_box(_x_x1203, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_pnat_fun1207__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_pnat_fun1207(kk_function_t _fself, kk_box_t _b_x628, kk_box_t _b_x629, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pnat_fun1207(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_pnat_fun1207, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_pnat_fun1207(kk_function_t _fself, kk_box_t _b_x628, kk_box_t _b_x629, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__maybe m_634 = kk_std_core_types__maybe_unbox(_b_x628, KK_OWNED, _ctx); /*maybe<int>*/;
  kk_integer_t nothing_635 = kk_integer_unbox(_b_x629, _ctx); /*int*/;
  kk_integer_t _x_x1208;
  if (kk_std_core_types__is_Nothing(m_634, _ctx)) {
    _x_x1208 = nothing_635; /*int*/
  }
  else {
    kk_box_t _box_x624 = m_634._cons.Just.value;
    kk_integer_t x_0 = kk_integer_unbox(_box_x624, _ctx);
    kk_integer_drop(nothing_635, _ctx);
    kk_integer_dup(x_0, _ctx);
    kk_std_core_types__maybe_drop(m_634, _ctx);
    _x_x1208 = x_0; /*int*/
  }
  return kk_integer_box(_x_x1208, _ctx);
}

kk_integer_t kk_std_text_parse_pnat(kk_context_t* _ctx) { /* () -> parse int */ 
  kk_std_core_types__list x_10301;
  kk_box_t _x_x1193;
  kk_string_t _x_x1194;
  kk_define_string_literal(, _s_x1195, 5, "digit", _ctx)
  _x_x1194 = kk_string_dup(_s_x1195, _ctx); /*string*/
  _x_x1193 = kk_std_text_parse_satisfy_fail(_x_x1194, kk_std_text_parse_new_pnat_fun1196(_ctx), _ctx); /*810*/
  x_10301 = kk_std_core_types__list_unbox(_x_x1193, KK_OWNED, _ctx); /*list<char>*/
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10301, _ctx);
    kk_box_t _x_x1201 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_pnat_fun1202(_ctx), _ctx); /*3728*/
    return kk_integer_unbox(_x_x1201, _ctx);
  }
  {
    kk_std_core_types__maybe _x_x1_10162;
    kk_string_t _x_x1205 = kk_std_core_string_listchar_fs_string(x_10301, _ctx); /*string*/
    _x_x1_10162 = kk_std_core_int_parse_int(_x_x1205, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
    kk_box_t _x_x1206 = kk_std_core_hnd__open_none2(kk_std_text_parse_new_pnat_fun1207(_ctx), kk_std_core_types__maybe_box(_x_x1_10162, _ctx), kk_integer_box(kk_integer_from_small(0), _ctx), _ctx); /*3037*/
    return kk_integer_unbox(_x_x1206, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_sign_fun1210__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_sign_fun1210(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_sign_fun1210(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_sign_fun1210, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_sign_fun1213__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_sign_fun1213(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_sign_fun1213(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_sign_fun1213, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_sign_fun1213(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__maybe _match_x765 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x765, _ctx)) {
    kk_box_t _box_x636 = _match_x765._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0_0 = kk_std_core_types__tuple2_unbox(_box_x636, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0_0, _ctx)) {
      kk_box_t _box_x637 = _pat_0_0.fst;
      kk_box_t _box_x638 = _pat_0_0.snd;
      kk_char_t c = kk_char_unbox(_box_x637, KK_BORROWED, _ctx);
      kk_string_t _x_x1214;
      kk_define_string_literal(, _s_x1215, 2, "+-", _ctx)
      _x_x1214 = kk_string_dup(_s_x1215, _ctx); /*string*/
      kk_string_t _x_x1216 = kk_std_core_string_char_fs_string(c, _ctx); /*string*/
      if (kk_string_contains(_x_x1214,_x_x1216,kk_context())) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x638, KK_BORROWED, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x765, _ctx);
        kk_box_t _x_x1217;
        kk_std_core_types__tuple2 _x_x1218 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x1217 = kk_std_core_types__tuple2_box(_x_x1218, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x1217, _ctx);
      }
    }
  }
  {
    kk_std_core_types__maybe_drop(_match_x765, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}
static kk_box_t kk_std_text_parse_sign_fun1210(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1211;
  kk_define_string_literal(, _s_x1212, 2, "+-", _ctx)
  _x_x1211 = kk_string_dup(_s_x1212, _ctx); /*string*/
  return kk_std_text_parse_satisfy_fail(_x_x1211, kk_std_text_parse_new_sign_fun1213(_ctx), _ctx);
}


// lift anonymous function
struct kk_std_text_parse_sign_fun1219__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_sign_fun1219(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_sign_fun1219(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_sign_fun1219, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_sign_fun1219(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_char_box('+', _ctx);
}


// lift anonymous function
struct kk_std_text_parse_sign_fun1221__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_sign_fun1221(kk_function_t _fself, kk_box_t _b_x654, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_sign_fun1221(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_sign_fun1221, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_sign_fun1221(kk_function_t _fself, kk_box_t _b_x654, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x1222;
  kk_char_t _x_x1223 = kk_char_unbox(_b_x654, KK_OWNED, _ctx); /*char*/
  _x_x1222 = kk_std_text_parse__mlift_sign_10184(_x_x1223, _ctx); /*bool*/
  return kk_bool_box(_x_x1222);
}

bool kk_std_text_parse_sign(kk_context_t* _ctx) { /* () -> parse bool */ 
  kk_char_t x_10304;
  kk_box_t _x_x1209 = kk_std_text_parse__lp__bar__bar__rp_(kk_std_text_parse_new_sign_fun1210(_ctx), kk_std_text_parse_new_sign_fun1219(_ctx), _ctx); /*1336*/
  x_10304 = kk_char_unbox(_x_x1209, KK_OWNED, _ctx); /*char*/
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x1220 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_sign_fun1221(_ctx), _ctx); /*3728*/
    return kk_bool_unbox(_x_x1220);
  }
  {
    return (x_10304 == ('-'));
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_text_parse__mlift_pint_10186_fun1225__t {
  struct kk_function_s _base;
  bool neg;
};
static kk_box_t kk_std_text_parse__mlift_pint_10186_fun1225(kk_function_t _fself, kk_box_t _b_x657, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse__new_mlift_pint_10186_fun1225(bool neg, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_pint_10186_fun1225__t* _self = kk_function_alloc_as(struct kk_std_text_parse__mlift_pint_10186_fun1225__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse__mlift_pint_10186_fun1225, kk_context());
  _self->neg = neg;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse__mlift_pint_10186_fun1225(kk_function_t _fself, kk_box_t _b_x657, kk_context_t* _ctx) {
  struct kk_std_text_parse__mlift_pint_10186_fun1225__t* _self = kk_function_as(struct kk_std_text_parse__mlift_pint_10186_fun1225__t*, _fself, _ctx);
  bool neg = _self->neg; /* bool */
  kk_drop_match(_self, {kk_skip_dup(neg, _ctx);}, {}, _ctx)
  kk_integer_t _x_x1226;
  kk_integer_t i_659 = kk_integer_unbox(_b_x657, _ctx); /*int*/;
  if (neg) {
    _x_x1226 = kk_integer_neg(i_659,kk_context()); /*int*/
  }
  else {
    _x_x1226 = i_659; /*int*/
  }
  return kk_integer_box(_x_x1226, _ctx);
}

kk_integer_t kk_std_text_parse__mlift_pint_10186(kk_char_t c_0, kk_context_t* _ctx) { /* (c@0 : char) -> parse int */ 
  bool neg = (c_0 == ('-')); /*bool*/;
  kk_integer_t x_10307 = kk_std_text_parse_pnat(_ctx); /*int*/;
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10307, _ctx);
    kk_box_t _x_x1224 = kk_std_core_hnd_yield_extend(kk_std_text_parse__new_mlift_pint_10186_fun1225(neg, _ctx), _ctx); /*3728*/
    return kk_integer_unbox(_x_x1224, _ctx);
  }
  {
    kk_integer_t i_660 = x_10307; /*int*/;
    if (neg) {
      return kk_integer_neg(i_660,kk_context());
    }
    {
      return i_660;
    }
  }
}


// lift anonymous function
struct kk_std_text_parse_pint_fun1228__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_pint_fun1228(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pint_fun1228(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_pint_fun1228, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_pint_fun1231__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_pint_fun1231(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pint_fun1231(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_pint_fun1231, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_pint_fun1231(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__maybe _match_x762 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x762, _ctx)) {
    kk_box_t _box_x661 = _match_x762._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0_0 = kk_std_core_types__tuple2_unbox(_box_x661, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0_0, _ctx)) {
      kk_box_t _box_x662 = _pat_0_0.fst;
      kk_box_t _box_x663 = _pat_0_0.snd;
      kk_char_t c = kk_char_unbox(_box_x662, KK_BORROWED, _ctx);
      kk_string_t _x_x1232;
      kk_define_string_literal(, _s_x1233, 2, "+-", _ctx)
      _x_x1232 = kk_string_dup(_s_x1233, _ctx); /*string*/
      kk_string_t _x_x1234 = kk_std_core_string_char_fs_string(c, _ctx); /*string*/
      if (kk_string_contains(_x_x1232,_x_x1234,kk_context())) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x663, KK_BORROWED, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x762, _ctx);
        kk_box_t _x_x1235;
        kk_std_core_types__tuple2 _x_x1236 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x1235 = kk_std_core_types__tuple2_box(_x_x1236, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x1235, _ctx);
      }
    }
  }
  {
    kk_std_core_types__maybe_drop(_match_x762, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}
static kk_box_t kk_std_text_parse_pint_fun1228(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1229;
  kk_define_string_literal(, _s_x1230, 2, "+-", _ctx)
  _x_x1229 = kk_string_dup(_s_x1230, _ctx); /*string*/
  return kk_std_text_parse_satisfy_fail(_x_x1229, kk_std_text_parse_new_pint_fun1231(_ctx), _ctx);
}


// lift anonymous function
struct kk_std_text_parse_pint_fun1237__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_pint_fun1237(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pint_fun1237(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_pint_fun1237, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_pint_fun1237(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_char_box('+', _ctx);
}


// lift anonymous function
struct kk_std_text_parse_pint_fun1239__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_pint_fun1239(kk_function_t _fself, kk_box_t _b_x679, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pint_fun1239(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_pint_fun1239, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_pint_fun1239(kk_function_t _fself, kk_box_t _b_x679, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x1240;
  kk_char_t _x_x1241 = kk_char_unbox(_b_x679, KK_OWNED, _ctx); /*char*/
  _x_x1240 = kk_std_text_parse__mlift_pint_10186(_x_x1241, _ctx); /*int*/
  return kk_integer_box(_x_x1240, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_pint_fun1243__t {
  struct kk_function_s _base;
  bool neg;
};
static kk_box_t kk_std_text_parse_pint_fun1243(kk_function_t _fself, kk_box_t _b_x681, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pint_fun1243(bool neg, kk_context_t* _ctx) {
  struct kk_std_text_parse_pint_fun1243__t* _self = kk_function_alloc_as(struct kk_std_text_parse_pint_fun1243__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_pint_fun1243, kk_context());
  _self->neg = neg;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_text_parse_pint_fun1243(kk_function_t _fself, kk_box_t _b_x681, kk_context_t* _ctx) {
  struct kk_std_text_parse_pint_fun1243__t* _self = kk_function_as(struct kk_std_text_parse_pint_fun1243__t*, _fself, _ctx);
  bool neg = _self->neg; /* bool */
  kk_drop_match(_self, {kk_skip_dup(neg, _ctx);}, {}, _ctx)
  kk_integer_t i_684 = kk_integer_unbox(_b_x681, _ctx); /*int*/;
  kk_integer_t _x_x1244;
  if (neg) {
    _x_x1244 = kk_integer_neg(i_684,kk_context()); /*int*/
  }
  else {
    _x_x1244 = i_684; /*int*/
  }
  return kk_integer_box(_x_x1244, _ctx);
}

kk_integer_t kk_std_text_parse_pint(kk_context_t* _ctx) { /* () -> parse int */ 
  kk_char_t x_10311;
  kk_box_t _x_x1227 = kk_std_text_parse__lp__bar__bar__rp_(kk_std_text_parse_new_pint_fun1228(_ctx), kk_std_text_parse_new_pint_fun1237(_ctx), _ctx); /*1336*/
  x_10311 = kk_char_unbox(_x_x1227, KK_OWNED, _ctx); /*char*/
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x1238 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_pint_fun1239(_ctx), _ctx); /*3728*/
    return kk_integer_unbox(_x_x1238, _ctx);
  }
  {
    bool neg = (x_10311 == ('-')); /*bool*/;
    kk_integer_t x_0_10314 = kk_std_text_parse_pnat(_ctx); /*int*/;
    if (kk_yielding(kk_context())) {
      kk_integer_drop(x_0_10314, _ctx);
      kk_box_t _x_x1242 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_pint_fun1243(neg, _ctx), _ctx); /*3728*/
      return kk_integer_unbox(_x_x1242, _ctx);
    }
    if (neg) {
      return kk_integer_neg(x_0_10314,kk_context());
    }
    {
      return x_0_10314;
    }
  }
}


// lift anonymous function
struct kk_std_text_parse_pstring_fun1247__t {
  struct kk_function_s _base;
  kk_string_t s;
};
static kk_std_core_types__maybe kk_std_text_parse_pstring_fun1247(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_pstring_fun1247(kk_string_t s, kk_context_t* _ctx) {
  struct kk_std_text_parse_pstring_fun1247__t* _self = kk_function_alloc_as(struct kk_std_text_parse_pstring_fun1247__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_text_parse_pstring_fun1247, kk_context());
  _self->s = s;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_pstring_fun1247(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  struct kk_std_text_parse_pstring_fun1247__t* _self = kk_function_as(struct kk_std_text_parse_pstring_fun1247__t*, _fself, _ctx);
  kk_string_t s = _self->s; /* string */
  kk_drop_match(_self, {kk_string_dup(s, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _match_x759;
  kk_std_core_types__list _x_x1248;
  kk_string_t _x_x1249 = kk_string_dup(s, _ctx); /*string*/
  _x_x1248 = kk_std_core_string_list(_x_x1249, _ctx); /*list<char>*/
  _match_x759 = kk_std_text_parse_next_match(slice, _x_x1248, _ctx); /*maybe<sslice/sslice>*/
  if (kk_std_core_types__is_Just(_match_x759, _ctx)) {
    kk_box_t _box_x685 = _match_x759._cons.Just.value;
    kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x685, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(rest, _ctx);
    kk_std_core_types__maybe_drop(_match_x759, _ctx);
    kk_box_t _x_x1250;
    kk_std_core_types__tuple2 _x_x1251 = kk_std_core_types__new_Tuple2(kk_string_box(s), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x1250 = kk_std_core_types__tuple2_box(_x_x1251, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x1250, _ctx);
  }
  {
    kk_string_drop(s, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_string_t kk_std_text_parse_pstring(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> parse string */ 
  kk_box_t _x_x1245;
  kk_string_t _x_x1246 = kk_string_dup(s, _ctx); /*string*/
  _x_x1245 = kk_std_text_parse_satisfy_fail(_x_x1246, kk_std_text_parse_new_pstring_fun1247(s, _ctx), _ctx); /*810*/
  return kk_string_unbox(_x_x1245);
}

kk_std_core_types__maybe kk_std_text_parse_starts_with(kk_string_t s, kk_function_t p, kk_context_t* _ctx) { /* forall<a> (s : string, p : () -> parse a) -> maybe<(a, sslice/sslice)> */ 
  kk_std_text_parse__parse_error _match_x758;
  kk_std_core_sslice__sslice _x_x1252;
  kk_string_t _x_x1253 = kk_string_dup(s, _ctx); /*string*/
  kk_integer_t _x_x1254 = kk_string_len_int(s,kk_context()); /*int*/
  _x_x1252 = kk_std_core_sslice__new_Sslice(_x_x1253, kk_integer_from_small(0), _x_x1254, _ctx); /*sslice/sslice*/
  _match_x758 = kk_std_text_parse_parse(_x_x1252, p, _ctx); /*std/text/parse/parse-error<2446>*/
  if (kk_std_text_parse__is_ParseOk(_match_x758, _ctx)) {
    struct kk_std_text_parse_ParseOk* _con_x1255 = kk_std_text_parse__as_ParseOk(_match_x758, _ctx);
    kk_std_core_sslice__sslice rest = _con_x1255->rest;
    kk_box_t x = _con_x1255->result;
    if kk_likely(kk_datatype_ptr_is_unique(_match_x758, _ctx)) {
      kk_datatype_ptr_free(_match_x758, _ctx);
    }
    else {
      kk_std_core_sslice__sslice_dup(rest, _ctx);
      kk_box_dup(x, _ctx);
      kk_datatype_ptr_decref(_match_x758, _ctx);
    }
    kk_box_t _x_x1256;
    kk_std_core_types__tuple2 _x_x1257 = kk_std_core_types__new_Tuple2(x, kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x1256 = kk_std_core_types__tuple2_box(_x_x1257, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x1256, _ctx);
  }
  {
    kk_std_text_parse__parse_error_drop(_match_x758, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_white_fun1261__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_white_fun1261(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_white_fun1261(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_white_fun1261, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_std_core_types__maybe kk_std_text_parse_white_fun1261(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__maybe _match_x757 = kk_std_core_sslice_next(slice, _ctx); /*maybe<(char, sslice/sslice)>*/;
  if (kk_std_core_types__is_Just(_match_x757, _ctx)) {
    kk_box_t _box_x702 = _match_x757._cons.Just.value;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x702, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Tuple2(_pat_0, _ctx)) {
      kk_box_t _box_x703 = _pat_0.fst;
      kk_box_t _box_x704 = _pat_0.snd;
      kk_char_t c = kk_char_unbox(_box_x703, KK_BORROWED, _ctx);
      if (kk_std_core_char_is_white(c, _ctx)) {
        kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x704, KK_BORROWED, _ctx);
        kk_std_core_sslice__sslice_dup(rest, _ctx);
        kk_std_core_types__maybe_drop(_match_x757, _ctx);
        kk_box_t _x_x1262;
        kk_std_core_types__tuple2 _x_x1263 = kk_std_core_types__new_Tuple2(kk_char_box(c, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
        _x_x1262 = kk_std_core_types__tuple2_box(_x_x1263, _ctx); /*91*/
        return kk_std_core_types__new_Just(_x_x1262, _ctx);
      }
    }
  }
  {
    kk_std_core_types__maybe_drop(_match_x757, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_char_t kk_std_text_parse_white(kk_context_t* _ctx) { /* () -> parse char */ 
  kk_box_t _x_x1258;
  kk_string_t _x_x1259 = kk_string_empty(); /*string*/
  _x_x1258 = kk_std_text_parse_satisfy_fail(_x_x1259, kk_std_text_parse_new_white_fun1261(_ctx), _ctx); /*810*/
  return kk_char_unbox(_x_x1258, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_std_text_parse_whitespace_fun1267__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_whitespace_fun1267(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_whitespace_fun1267(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_whitespace_fun1267, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_whitespace_fun1269__t {
  struct kk_function_s _base;
};
static bool kk_std_text_parse_whitespace_fun1269(kk_function_t _fself, kk_char_t _x1_x1268, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_whitespace_fun1269(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_whitespace_fun1269, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static bool kk_std_text_parse_whitespace_fun1269(kk_function_t _fself, kk_char_t _x1_x1268, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_char_is_white(_x1_x1268, _ctx);
}
static kk_std_core_types__maybe kk_std_text_parse_whitespace_fun1267(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__tuple2 _match_x756 = kk_std_text_parse_next_while0(slice, kk_std_text_parse_new_whitespace_fun1269(_ctx), kk_std_core_types__new_Nil(_ctx), _ctx); /*(list<char>, sslice/sslice)*/;
  {
    kk_box_t _box_x715 = _match_x756.fst;
    kk_box_t _box_x716 = _match_x756.snd;
    kk_std_core_types__list _pat_0_0 = kk_std_core_types__list_unbox(_box_x715, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice _pat_1_0 = kk_std_core_sslice__sslice_unbox(_box_x716, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Nil(_pat_0_0, _ctx)) {
      kk_std_core_types__tuple2_drop(_match_x756, _ctx);
      return kk_std_core_types__new_Nothing(_ctx);
    }
  }
  {
    kk_box_t _box_x717 = _match_x756.fst;
    kk_box_t _box_x718 = _match_x756.snd;
    kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x718, KK_BORROWED, _ctx);
    kk_std_core_types__list xs = kk_std_core_types__list_unbox(_box_x717, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(rest, _ctx);
    kk_std_core_types__list_dup(xs, _ctx);
    kk_std_core_types__tuple2_drop(_match_x756, _ctx);
    kk_box_t _x_x1270;
    kk_std_core_types__tuple2 _x_x1271 = kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(xs, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x1270 = kk_std_core_types__tuple2_box(_x_x1271, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x1270, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_whitespace_fun1273__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_whitespace_fun1273(kk_function_t _fself, kk_box_t _b_x730, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_whitespace_fun1273(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_whitespace_fun1273, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_whitespace_fun1273(kk_function_t _fself, kk_box_t _b_x730, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1274;
  kk_std_core_types__list _x_x1275 = kk_std_core_types__list_unbox(_b_x730, KK_OWNED, _ctx); /*list<char>*/
  _x_x1274 = kk_std_core_string_listchar_fs_string(_x_x1275, _ctx); /*string*/
  return kk_string_box(_x_x1274);
}

kk_string_t kk_std_text_parse_whitespace(kk_context_t* _ctx) { /* () -> parse string */ 
  kk_std_core_types__list x_10319;
  kk_box_t _x_x1264;
  kk_string_t _x_x1265 = kk_string_empty(); /*string*/
  _x_x1264 = kk_std_text_parse_satisfy_fail(_x_x1265, kk_std_text_parse_new_whitespace_fun1267(_ctx), _ctx); /*810*/
  x_10319 = kk_std_core_types__list_unbox(_x_x1264, KK_OWNED, _ctx); /*list<char>*/
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10319, _ctx);
    kk_box_t _x_x1272 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_whitespace_fun1273(_ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x1272);
  }
  {
    return kk_std_core_string_listchar_fs_string(x_10319, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_whitespace0_fun1277__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_whitespace0_fun1277(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_whitespace0_fun1277(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_whitespace0_fun1277, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_whitespace0_fun1281__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_text_parse_whitespace0_fun1281(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_whitespace0_fun1281(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_whitespace0_fun1281, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_text_parse_whitespace0_fun1283__t {
  struct kk_function_s _base;
};
static bool kk_std_text_parse_whitespace0_fun1283(kk_function_t _fself, kk_char_t _x1_x1282, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_whitespace0_fun1283(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_whitespace0_fun1283, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static bool kk_std_text_parse_whitespace0_fun1283(kk_function_t _fself, kk_char_t _x1_x1282, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_char_is_white(_x1_x1282, _ctx);
}
static kk_std_core_types__maybe kk_std_text_parse_whitespace0_fun1281(kk_function_t _fself, kk_std_core_sslice__sslice slice, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__tuple2 _match_x754 = kk_std_text_parse_next_while0(slice, kk_std_text_parse_new_whitespace0_fun1283(_ctx), kk_std_core_types__new_Nil(_ctx), _ctx); /*(list<char>, sslice/sslice)*/;
  {
    kk_box_t _box_x732 = _match_x754.fst;
    kk_box_t _box_x733 = _match_x754.snd;
    kk_std_core_types__list _pat_0_0 = kk_std_core_types__list_unbox(_box_x732, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice _pat_1_0 = kk_std_core_sslice__sslice_unbox(_box_x733, KK_BORROWED, _ctx);
    if (kk_std_core_types__is_Nil(_pat_0_0, _ctx)) {
      kk_std_core_types__tuple2_drop(_match_x754, _ctx);
      return kk_std_core_types__new_Nothing(_ctx);
    }
  }
  {
    kk_box_t _box_x734 = _match_x754.fst;
    kk_box_t _box_x735 = _match_x754.snd;
    kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x735, KK_BORROWED, _ctx);
    kk_std_core_types__list xs = kk_std_core_types__list_unbox(_box_x734, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(rest, _ctx);
    kk_std_core_types__list_dup(xs, _ctx);
    kk_std_core_types__tuple2_drop(_match_x754, _ctx);
    kk_box_t _x_x1284;
    kk_std_core_types__tuple2 _x_x1285 = kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(xs, _ctx), kk_std_core_sslice__sslice_box(rest, _ctx), _ctx); /*(129, 130)*/
    _x_x1284 = kk_std_core_types__tuple2_box(_x_x1285, _ctx); /*91*/
    return kk_std_core_types__new_Just(_x_x1284, _ctx);
  }
}


// lift anonymous function
struct kk_std_text_parse_whitespace0_fun1288__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_whitespace0_fun1288(kk_function_t _fself, kk_box_t _b_x747, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_whitespace0_fun1288(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_whitespace0_fun1288, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_whitespace0_fun1288(kk_function_t _fself, kk_box_t _b_x747, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1289;
  kk_std_core_types__list _x_x1290 = kk_std_core_types__list_unbox(_b_x747, KK_OWNED, _ctx); /*list<char>*/
  _x_x1289 = kk_std_core_string_listchar_fs_string(_x_x1290, _ctx); /*string*/
  return kk_string_box(_x_x1289);
}
static kk_box_t kk_std_text_parse_whitespace0_fun1277(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__list x_10321;
  kk_box_t _x_x1278;
  kk_string_t _x_x1279 = kk_string_empty(); /*string*/
  _x_x1278 = kk_std_text_parse_satisfy_fail(_x_x1279, kk_std_text_parse_new_whitespace0_fun1281(_ctx), _ctx); /*810*/
  x_10321 = kk_std_core_types__list_unbox(_x_x1278, KK_OWNED, _ctx); /*list<char>*/
  kk_string_t _x_x1286;
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10321, _ctx);
    kk_box_t _x_x1287 = kk_std_core_hnd_yield_extend(kk_std_text_parse_new_whitespace0_fun1288(_ctx), _ctx); /*3728*/
    _x_x1286 = kk_string_unbox(_x_x1287); /*string*/
  }
  else {
    _x_x1286 = kk_std_core_string_listchar_fs_string(x_10321, _ctx); /*string*/
  }
  return kk_string_box(_x_x1286);
}


// lift anonymous function
struct kk_std_text_parse_whitespace0_fun1291__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_text_parse_whitespace0_fun1291(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_text_parse_new_whitespace0_fun1291(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_text_parse_whitespace0_fun1291, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_text_parse_whitespace0_fun1291(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1292 = kk_string_empty(); /*string*/
  return kk_string_box(_x_x1292);
}

kk_string_t kk_std_text_parse_whitespace0(kk_context_t* _ctx) { /* () -> parse string */ 
  kk_box_t _x_x1276 = kk_std_text_parse__lp__bar__bar__rp_(kk_std_text_parse_new_whitespace0_fun1277(_ctx), kk_std_text_parse_new_whitespace0_fun1291(_ctx), _ctx); /*1336*/
  return kk_string_unbox(_x_x1276);
}

// initialization
void kk_std_text_parse__init(kk_context_t* _ctx){
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
  kk_std_core_undiv__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
  {
    kk_string_t _x_x851;
    kk_define_string_literal(, _s_x852, 11, "parse@parse", _ctx)
    _x_x851 = kk_string_dup(_s_x852, _ctx); /*string*/
    kk_std_text_parse__tag_parse = kk_std_core_hnd__new_Htag(_x_x851, _ctx); /*hnd/htag<std/text/parse/parse>*/
  }
}

// termination
void kk_std_text_parse__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_hnd__htag_drop(kk_std_text_parse__tag_parse, _ctx);
  kk_std_core_undiv__done(_ctx);
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
