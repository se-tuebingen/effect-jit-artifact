// Koka generated module: main, koka version: 3.1.2, platform: 64-bit
#include "main.h"
 
// runtime tag for the effect `:prime`

kk_std_core_hnd__htag kk_main__tag_prime;
 
// handler for the effect `:prime`

kk_box_t kk_main__handle_prime(kk_main__prime hnd, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (hnd : prime<e,b>, ret : (res : a) -> e b, action : () -> <prime|e> a) -> e b */ 
  kk_std_core_hnd__htag _x_x142 = kk_std_core_hnd__htag_dup(kk_main__tag_prime, _ctx); /*hnd/htag<main/prime>*/
  return kk_std_core_hnd__hhandle(_x_x142, kk_main__prime_box(hnd, _ctx), ret, action, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_main__mlift_primes_10031_fun149__t {
  struct kk_function_s _base;
  kk_integer_t i;
};
static kk_box_t kk_main__mlift_primes_10031_fun149(kk_function_t _fself, kk_box_t _b_x25, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_primes_10031_fun149(kk_integer_t i, kk_context_t* _ctx) {
  struct kk_main__mlift_primes_10031_fun149__t* _self = kk_function_alloc_as(struct kk_main__mlift_primes_10031_fun149__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_primes_10031_fun149, kk_context());
  _self->i = i;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main__mlift_primes_10031_fun149(kk_function_t _fself, kk_box_t _b_x25, kk_context_t* _ctx) {
  struct kk_main__mlift_primes_10031_fun149__t* _self = kk_function_as(struct kk_main__mlift_primes_10031_fun149__t*, _fself, _ctx);
  kk_integer_t i = _self->i; /* int */
  kk_drop_match(_self, {kk_integer_dup(i, _ctx);}, {}, _ctx)
  bool _x_x150;
  kk_integer_t e_0_48 = kk_integer_unbox(_b_x25, _ctx); /*int*/;
  bool _match_x130;
  kk_integer_t _brw_x131;
  kk_integer_t _x_x151 = kk_integer_dup(e_0_48, _ctx); /*int*/
  _brw_x131 = kk_integer_mod(_x_x151,i,kk_context()); /*int*/
  bool _brw_x132 = kk_integer_eq_borrow(_brw_x131,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  kk_integer_drop(_brw_x131, _ctx);
  _match_x130 = _brw_x132; /*bool*/
  if (_match_x130) {
    kk_integer_drop(e_0_48, _ctx);
    _x_x150 = false; /*bool*/
  }
  else {
    kk_std_core_hnd__ev ev_10036 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/prime>*/;
    kk_box_t _x_x152;
    {
      struct kk_std_core_hnd_Ev* _con_x153 = kk_std_core_hnd__as_Ev(ev_10036, _ctx);
      kk_box_t _box_x16 = _con_x153->hnd;
      int32_t m = _con_x153->marker;
      kk_main__prime h = kk_main__prime_unbox(_box_x16, KK_BORROWED, _ctx);
      kk_main__prime_dup(h, _ctx);
      {
        struct kk_main__Hnd_prime* _con_x154 = kk_main__as_Hnd_prime(h, _ctx);
        kk_integer_t _pat_0_0 = _con_x154->_cfc;
        kk_std_core_hnd__clause1 _fun_prime = _con_x154->_fun_prime;
        if kk_likely(kk_datatype_ptr_is_unique(h, _ctx)) {
          kk_integer_drop(_pat_0_0, _ctx);
          kk_datatype_ptr_free(h, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_fun_prime, _ctx);
          kk_datatype_ptr_decref(h, _ctx);
        }
        {
          kk_function_t _fun_unbox_x20 = _fun_prime.clause;
          _x_x152 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x20, (_fun_unbox_x20, m, ev_10036, kk_integer_box(e_0_48, _ctx), _ctx), _ctx); /*1010*/
        }
      }
    }
    _x_x150 = kk_bool_unbox(_x_x152); /*bool*/
  }
  return kk_bool_box(_x_x150);
}


// lift anonymous function
struct kk_main__mlift_primes_10031_fun156__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_primes_10031_fun156(kk_function_t _fself, kk_box_t _b_x37, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_primes_10031_fun156(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_primes_10031_fun156, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_primes_10031_fun156(kk_function_t _fself, kk_box_t _b_x37, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_47 = kk_integer_unbox(_b_x37, _ctx); /*int*/;
  return kk_integer_box(_x_47, _ctx);
}


// lift anonymous function
struct kk_main__mlift_primes_10031_fun157__t {
  struct kk_function_s _base;
  kk_integer_t a;
  kk_integer_t i;
  kk_integer_t n;
};
static kk_box_t kk_main__mlift_primes_10031_fun157(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_primes_10031_fun157(kk_integer_t a, kk_integer_t i, kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main__mlift_primes_10031_fun157__t* _self = kk_function_alloc_as(struct kk_main__mlift_primes_10031_fun157__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main__mlift_primes_10031_fun157, kk_context());
  _self->a = a;
  _self->i = i;
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main__mlift_primes_10031_fun159__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main__mlift_primes_10031_fun159(kk_function_t _fself, kk_box_t _b_x31, kk_box_t _b_x32, kk_box_t _b_x33, kk_context_t* _ctx);
static kk_function_t kk_main__new_mlift_primes_10031_fun159(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main__mlift_primes_10031_fun159, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main__mlift_primes_10031_fun159(kk_function_t _fself, kk_box_t _b_x31, kk_box_t _b_x32, kk_box_t _b_x33, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x160;
  kk_integer_t _x_x161 = kk_integer_unbox(_b_x31, _ctx); /*int*/
  kk_integer_t _x_x162 = kk_integer_unbox(_b_x32, _ctx); /*int*/
  kk_integer_t _x_x163 = kk_integer_unbox(_b_x33, _ctx); /*int*/
  _x_x160 = kk_main_primes(_x_x161, _x_x162, _x_x163, _ctx); /*int*/
  return kk_integer_box(_x_x160, _ctx);
}
static kk_box_t kk_main__mlift_primes_10031_fun157(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main__mlift_primes_10031_fun157__t* _self = kk_function_as(struct kk_main__mlift_primes_10031_fun157__t*, _fself, _ctx);
  kk_integer_t a = _self->a; /* int */
  kk_integer_t i = _self->i; /* int */
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(a, _ctx);kk_integer_dup(i, _ctx);kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_integer_t _x_x1_10028;
  kk_integer_t _x_x158 = kk_integer_dup(i, _ctx); /*int*/
  _x_x1_10028 = kk_integer_add_small_const(_x_x158, 1, _ctx); /*int*/
  kk_integer_t _x_x3_10030 = kk_integer_add(a,i,kk_context()); /*int*/;
  kk_ssize_t _b_x26_42 = (KK_IZ(0)); /*hnd/ev-index*/;
  return kk_std_core_hnd__open_at3(_b_x26_42, kk_main__new_mlift_primes_10031_fun159(_ctx), kk_integer_box(_x_x1_10028, _ctx), kk_integer_box(n, _ctx), kk_integer_box(_x_x3_10030, _ctx), _ctx);
}

kk_integer_t kk_main__mlift_primes_10031(kk_integer_t a, kk_integer_t i, kk_integer_t n, bool _y_x10011, kk_context_t* _ctx) { /* (a : int, i : int, n : int, bool) -> prime int */ 
  if (_y_x10011) {
    kk_main__prime _b_x34_38;
    kk_std_core_hnd__clause1 _x_x147;
    kk_function_t _x_x148;
    kk_integer_dup(i, _ctx);
    _x_x148 = kk_main__new_mlift_primes_10031_fun149(i, _ctx); /*(1003) -> 1000 1004*/
    _x_x147 = kk_std_core_hnd_clause_tail1(_x_x148, _ctx); /*hnd/clause1<1003,1004,1002,1000,1001>*/
    _b_x34_38 = kk_main__new_Hnd_prime(kk_reuse_null, 0, kk_integer_from_small(1), _x_x147, _ctx); /*main/prime<<main/prime,div>,int>*/
    kk_box_t _x_x155 = kk_main__handle_prime(_b_x34_38, kk_main__new_mlift_primes_10031_fun156(_ctx), kk_main__new_mlift_primes_10031_fun157(a, i, n, _ctx), _ctx); /*137*/
    return kk_integer_unbox(_x_x155, _ctx);
  }
  {
    kk_integer_t _x_x164 = kk_integer_add_small_const(i, 1, _ctx); /*int*/
    return kk_main_primes(_x_x164, n, a, _ctx);
  }
}


// lift anonymous function
struct kk_main_primes_fun171__t {
  struct kk_function_s _base;
  kk_integer_t a_0;
  kk_integer_t i_0;
  kk_integer_t n_0;
};
static kk_box_t kk_main_primes_fun171(kk_function_t _fself, kk_box_t _b_x58, kk_context_t* _ctx);
static kk_function_t kk_main_new_primes_fun171(kk_integer_t a_0, kk_integer_t i_0, kk_integer_t n_0, kk_context_t* _ctx) {
  struct kk_main_primes_fun171__t* _self = kk_function_alloc_as(struct kk_main_primes_fun171__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_primes_fun171, kk_context());
  _self->a_0 = a_0;
  _self->i_0 = i_0;
  _self->n_0 = n_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_primes_fun171(kk_function_t _fself, kk_box_t _b_x58, kk_context_t* _ctx) {
  struct kk_main_primes_fun171__t* _self = kk_function_as(struct kk_main_primes_fun171__t*, _fself, _ctx);
  kk_integer_t a_0 = _self->a_0; /* int */
  kk_integer_t i_0 = _self->i_0; /* int */
  kk_integer_t n_0 = _self->n_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(a_0, _ctx);kk_integer_dup(i_0, _ctx);kk_integer_dup(n_0, _ctx);}, {}, _ctx)
  bool _y_x10011_0_91 = kk_bool_unbox(_b_x58); /*bool*/;
  kk_integer_t _x_x172 = kk_main__mlift_primes_10031(a_0, i_0, n_0, _y_x10011_0_91, _ctx); /*int*/
  return kk_integer_box(_x_x172, _ctx);
}


// lift anonymous function
struct kk_main_primes_fun175__t {
  struct kk_function_s _base;
  kk_integer_t i_0;
};
static kk_box_t kk_main_primes_fun175(kk_function_t _fself, kk_box_t _b_x68, kk_context_t* _ctx);
static kk_function_t kk_main_new_primes_fun175(kk_integer_t i_0, kk_context_t* _ctx) {
  struct kk_main_primes_fun175__t* _self = kk_function_alloc_as(struct kk_main_primes_fun175__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_primes_fun175, kk_context());
  _self->i_0 = i_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_primes_fun175(kk_function_t _fself, kk_box_t _b_x68, kk_context_t* _ctx) {
  struct kk_main_primes_fun175__t* _self = kk_function_as(struct kk_main_primes_fun175__t*, _fself, _ctx);
  kk_integer_t i_0 = _self->i_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(i_0, _ctx);}, {}, _ctx)
  bool _x_x176;
  kk_integer_t e_0_0_93 = kk_integer_unbox(_b_x68, _ctx); /*int*/;
  bool _match_x127;
  kk_integer_t _brw_x128;
  kk_integer_t _x_x177 = kk_integer_dup(e_0_0_93, _ctx); /*int*/
  _brw_x128 = kk_integer_mod(_x_x177,i_0,kk_context()); /*int*/
  bool _brw_x129 = kk_integer_eq_borrow(_brw_x128,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  kk_integer_drop(_brw_x128, _ctx);
  _match_x127 = _brw_x129; /*bool*/
  if (_match_x127) {
    kk_integer_drop(e_0_0_93, _ctx);
    _x_x176 = false; /*bool*/
  }
  else {
    kk_std_core_hnd__ev ev_1_10045 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/prime>*/;
    kk_box_t _x_x178;
    {
      struct kk_std_core_hnd_Ev* _con_x179 = kk_std_core_hnd__as_Ev(ev_1_10045, _ctx);
      kk_box_t _box_x59 = _con_x179->hnd;
      int32_t m_1 = _con_x179->marker;
      kk_main__prime h_1 = kk_main__prime_unbox(_box_x59, KK_BORROWED, _ctx);
      kk_main__prime_dup(h_1, _ctx);
      {
        struct kk_main__Hnd_prime* _con_x180 = kk_main__as_Hnd_prime(h_1, _ctx);
        kk_integer_t _pat_0_4 = _con_x180->_cfc;
        kk_std_core_hnd__clause1 _fun_prime_1 = _con_x180->_fun_prime;
        if kk_likely(kk_datatype_ptr_is_unique(h_1, _ctx)) {
          kk_integer_drop(_pat_0_4, _ctx);
          kk_datatype_ptr_free(h_1, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_fun_prime_1, _ctx);
          kk_datatype_ptr_decref(h_1, _ctx);
        }
        {
          kk_function_t _fun_unbox_x63 = _fun_prime_1.clause;
          _x_x178 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x63, (_fun_unbox_x63, m_1, ev_1_10045, kk_integer_box(e_0_0_93, _ctx), _ctx), _ctx); /*1010*/
        }
      }
    }
    _x_x176 = kk_bool_unbox(_x_x178); /*bool*/
  }
  return kk_bool_box(_x_x176);
}


// lift anonymous function
struct kk_main_primes_fun182__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_primes_fun182(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx);
static kk_function_t kk_main_new_primes_fun182(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_primes_fun182, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_primes_fun182(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_0_92 = kk_integer_unbox(_b_x80, _ctx); /*int*/;
  return kk_integer_box(_x_0_92, _ctx);
}


// lift anonymous function
struct kk_main_primes_fun183__t {
  struct kk_function_s _base;
  kk_integer_t a_0;
  kk_integer_t i_0;
  kk_integer_t n_0;
};
static kk_box_t kk_main_primes_fun183(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_primes_fun183(kk_integer_t a_0, kk_integer_t i_0, kk_integer_t n_0, kk_context_t* _ctx) {
  struct kk_main_primes_fun183__t* _self = kk_function_alloc_as(struct kk_main_primes_fun183__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_primes_fun183, kk_context());
  _self->a_0 = a_0;
  _self->i_0 = i_0;
  _self->n_0 = n_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_main_primes_fun185__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_primes_fun185(kk_function_t _fself, kk_box_t _b_x74, kk_box_t _b_x75, kk_box_t _b_x76, kk_context_t* _ctx);
static kk_function_t kk_main_new_primes_fun185(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_primes_fun185, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_primes_fun185(kk_function_t _fself, kk_box_t _b_x74, kk_box_t _b_x75, kk_box_t _b_x76, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x186;
  kk_integer_t _x_x187 = kk_integer_unbox(_b_x74, _ctx); /*int*/
  kk_integer_t _x_x188 = kk_integer_unbox(_b_x75, _ctx); /*int*/
  kk_integer_t _x_x189 = kk_integer_unbox(_b_x76, _ctx); /*int*/
  _x_x186 = kk_main_primes(_x_x187, _x_x188, _x_x189, _ctx); /*int*/
  return kk_integer_box(_x_x186, _ctx);
}
static kk_box_t kk_main_primes_fun183(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_primes_fun183__t* _self = kk_function_as(struct kk_main_primes_fun183__t*, _fself, _ctx);
  kk_integer_t a_0 = _self->a_0; /* int */
  kk_integer_t i_0 = _self->i_0; /* int */
  kk_integer_t n_0 = _self->n_0; /* int */
  kk_drop_match(_self, {kk_integer_dup(a_0, _ctx);kk_integer_dup(i_0, _ctx);kk_integer_dup(n_0, _ctx);}, {}, _ctx)
  kk_integer_t _x_x1_10028_0;
  kk_integer_t _x_x184 = kk_integer_dup(i_0, _ctx); /*int*/
  _x_x1_10028_0 = kk_integer_add_small_const(_x_x184, 1, _ctx); /*int*/
  kk_integer_t _x_x3_10030_0 = kk_integer_add(a_0,i_0,kk_context()); /*int*/;
  kk_ssize_t _b_x69_86 = (KK_IZ(0)); /*hnd/ev-index*/;
  return kk_std_core_hnd__open_at3(_b_x69_86, kk_main_new_primes_fun185(_ctx), kk_integer_box(_x_x1_10028_0, _ctx), kk_integer_box(n_0, _ctx), kk_integer_box(_x_x3_10030_0, _ctx), _ctx);
}

kk_integer_t kk_main_primes(kk_integer_t i_0, kk_integer_t n_0, kk_integer_t a_0, kk_context_t* _ctx) { /* (i : int, n : int, a : int) -> <div,prime> int */ 
  kk__tailcall: ;
  bool _match_x125 = kk_integer_gte_borrow(i_0,n_0,kk_context()); /*bool*/;
  if (_match_x125) {
    kk_integer_drop(n_0, _ctx);
    kk_integer_drop(i_0, _ctx);
    return a_0;
  }
  {
    kk_std_core_hnd__ev ev_0_10042 = kk_evv_at(((KK_IZ(0))),kk_context()); /*hnd/ev<main/prime>*/;
    bool x_0_10039;
    kk_box_t _x_x165;
    {
      struct kk_std_core_hnd_Ev* _con_x166 = kk_std_core_hnd__as_Ev(ev_0_10042, _ctx);
      kk_box_t _box_x49 = _con_x166->hnd;
      int32_t m_0 = _con_x166->marker;
      kk_main__prime h_0 = kk_main__prime_unbox(_box_x49, KK_BORROWED, _ctx);
      kk_main__prime_dup(h_0, _ctx);
      {
        struct kk_main__Hnd_prime* _con_x167 = kk_main__as_Hnd_prime(h_0, _ctx);
        kk_integer_t _pat_0_1 = _con_x167->_cfc;
        kk_std_core_hnd__clause1 _fun_prime_0 = _con_x167->_fun_prime;
        if kk_likely(kk_datatype_ptr_is_unique(h_0, _ctx)) {
          kk_integer_drop(_pat_0_1, _ctx);
          kk_datatype_ptr_free(h_0, _ctx);
        }
        else {
          kk_std_core_hnd__clause1_dup(_fun_prime_0, _ctx);
          kk_datatype_ptr_decref(h_0, _ctx);
        }
        {
          kk_function_t _fun_unbox_x53 = _fun_prime_0.clause;
          kk_box_t _x_x168;
          kk_integer_t _x_x169 = kk_integer_dup(i_0, _ctx); /*int*/
          _x_x168 = kk_integer_box(_x_x169, _ctx); /*1009*/
          _x_x165 = kk_function_call(kk_box_t, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_box_t, kk_context_t*), _fun_unbox_x53, (_fun_unbox_x53, m_0, ev_0_10042, _x_x168, _ctx), _ctx); /*1010*/
        }
      }
    }
    x_0_10039 = kk_bool_unbox(_x_x165); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x170 = kk_std_core_hnd_yield_extend(kk_main_new_primes_fun171(a_0, i_0, n_0, _ctx), _ctx); /*3003*/
      return kk_integer_unbox(_x_x170, _ctx);
    }
    if (x_0_10039) {
      kk_main__prime _b_x77_82;
      kk_std_core_hnd__clause1 _x_x173;
      kk_function_t _x_x174;
      kk_integer_dup(i_0, _ctx);
      _x_x174 = kk_main_new_primes_fun175(i_0, _ctx); /*(1003) -> 1000 1004*/
      _x_x173 = kk_std_core_hnd_clause_tail1(_x_x174, _ctx); /*hnd/clause1<1003,1004,1002,1000,1001>*/
      _b_x77_82 = kk_main__new_Hnd_prime(kk_reuse_null, 0, kk_integer_from_small(1), _x_x173, _ctx); /*main/prime<<main/prime,div>,int>*/
      kk_box_t _x_x181 = kk_main__handle_prime(_b_x77_82, kk_main_new_primes_fun182(_ctx), kk_main_new_primes_fun183(a_0, i_0, n_0, _ctx), _ctx); /*137*/
      return kk_integer_unbox(_x_x181, _ctx);
    }
    { // tailcall
      kk_integer_t _x_x190 = kk_integer_add_small_const(i_0, 1, _ctx); /*int*/
      i_0 = _x_x190;
      goto kk__tailcall;
    }
  }
}


// lift anonymous function
struct kk_main_run_fun192__t {
  struct kk_function_s _base;
};
static bool kk_main_run_fun192(kk_function_t _fself, int32_t ___wildcard_x691__14, kk_std_core_hnd__ev ___wildcard_x691__17, kk_integer_t x, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun192(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun192, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static bool kk_main_run_fun192(kk_function_t _fself, int32_t ___wildcard_x691__14, kk_std_core_hnd__ev ___wildcard_x691__17, kk_integer_t x, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_datatype_ptr_dropn(___wildcard_x691__17, (KK_I32(3)), _ctx);
  kk_integer_drop(x, _ctx);
  return true;
}


// lift anonymous function
struct kk_main_run_fun195__t {
  struct kk_function_s _base;
  kk_function_t _b_x94_105;
};
static kk_box_t kk_main_run_fun195(kk_function_t _fself, int32_t _b_x95, kk_std_core_hnd__ev _b_x96, kk_box_t _b_x97, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun195(kk_function_t _b_x94_105, kk_context_t* _ctx) {
  struct kk_main_run_fun195__t* _self = kk_function_alloc_as(struct kk_main_run_fun195__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun195, kk_context());
  _self->_b_x94_105 = _b_x94_105;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun195(kk_function_t _fself, int32_t _b_x95, kk_std_core_hnd__ev _b_x96, kk_box_t _b_x97, kk_context_t* _ctx) {
  struct kk_main_run_fun195__t* _self = kk_function_as(struct kk_main_run_fun195__t*, _fself, _ctx);
  kk_function_t _b_x94_105 = _self->_b_x94_105; /* (hnd/marker<div,int>, hnd/ev<main/prime>, x : int) -> div bool */
  kk_drop_match(_self, {kk_function_dup(_b_x94_105, _ctx);}, {}, _ctx)
  bool _x_x196;
  kk_integer_t _x_x197 = kk_integer_unbox(_b_x97, _ctx); /*int*/
  _x_x196 = kk_function_call(bool, (kk_function_t, int32_t, kk_std_core_hnd__ev, kk_integer_t, kk_context_t*), _b_x94_105, (_b_x94_105, _b_x95, _b_x96, _x_x197, _ctx), _ctx); /*bool*/
  return kk_bool_box(_x_x196);
}


// lift anonymous function
struct kk_main_run_fun198__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_run_fun198(kk_function_t _fself, kk_box_t _b_x101, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun198(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_run_fun198, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_run_fun198(kk_function_t _fself, kk_box_t _b_x101, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_106 = kk_integer_unbox(_b_x101, _ctx); /*int*/;
  return kk_integer_box(_x_106, _ctx);
}


// lift anonymous function
struct kk_main_run_fun199__t {
  struct kk_function_s _base;
  kk_integer_t n;
};
static kk_box_t kk_main_run_fun199(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_run_fun199(kk_integer_t n, kk_context_t* _ctx) {
  struct kk_main_run_fun199__t* _self = kk_function_alloc_as(struct kk_main_run_fun199__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_run_fun199, kk_context());
  _self->n = n;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_run_fun199(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_run_fun199__t* _self = kk_function_as(struct kk_main_run_fun199__t*, _fself, _ctx);
  kk_integer_t n = _self->n; /* int */
  kk_drop_match(_self, {kk_integer_dup(n, _ctx);}, {}, _ctx)
  kk_integer_t _x_x200 = kk_main_primes(kk_integer_from_small(2), n, kk_integer_from_small(0), _ctx); /*int*/
  return kk_integer_box(_x_x200, _ctx);
}

kk_integer_t kk_main_run(kk_integer_t n, kk_context_t* _ctx) { /* (n : int) -> div int */ 
  kk_box_t _x_x191;
  kk_function_t _b_x94_105 = kk_main_new_run_fun192(_ctx); /*(hnd/marker<div,int>, hnd/ev<main/prime>, x : int) -> div bool*/;
  kk_main__prime _x_x193;
  kk_std_core_hnd__clause1 _x_x194 = kk_std_core_hnd__new_Clause1(kk_main_new_run_fun195(_b_x94_105, _ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x193 = kk_main__new_Hnd_prime(kk_reuse_null, 0, kk_integer_from_small(1), _x_x194, _ctx); /*main/prime<6,7>*/
  _x_x191 = kk_main__handle_prime(_x_x193, kk_main_new_run_fun198(_ctx), kk_main_new_run_fun199(n, _ctx), _ctx); /*137*/
  return kk_integer_unbox(_x_x191, _ctx);
}


// lift anonymous function
struct kk_main_main_fun207__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun207(kk_function_t _fself, int32_t _b_x109, kk_std_core_hnd__ev _b_x110, kk_box_t _b_x111, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun207(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun207, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_main_fun207(kk_function_t _fself, int32_t _b_x109, kk_std_core_hnd__ev _b_x110, kk_box_t _b_x111, kk_context_t* _ctx) {
  kk_unused(_fself);
  int32_t ___wildcard_x691__14_122 = _b_x109; /*hnd/marker<div,int>*/;
  kk_std_core_hnd__ev ___wildcard_x691__17_123 = _b_x110; /*hnd/ev<main/prime>*/;
  kk_datatype_ptr_dropn(___wildcard_x691__17_123, (KK_I32(3)), _ctx);
  kk_integer_t x_124 = kk_integer_unbox(_b_x111, _ctx); /*int*/;
  kk_integer_drop(x_124, _ctx);
  return kk_bool_box(true);
}


// lift anonymous function
struct kk_main_main_fun208__t {
  struct kk_function_s _base;
};
static kk_box_t kk_main_main_fun208(kk_function_t _fself, kk_box_t _b_x116, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun208(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_main_main_fun208, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_main_main_fun208(kk_function_t _fself, kk_box_t _b_x116, kk_context_t* _ctx) {
  kk_unused(_fself);
  return _b_x116;
}


// lift anonymous function
struct kk_main_main_fun209__t {
  struct kk_function_s _base;
  kk_std_core_types__maybe m_10002;
};
static kk_box_t kk_main_main_fun209(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_main_new_main_fun209(kk_std_core_types__maybe m_10002, kk_context_t* _ctx) {
  struct kk_main_main_fun209__t* _self = kk_function_alloc_as(struct kk_main_main_fun209__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_main_main_fun209, kk_context());
  _self->m_10002 = m_10002;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_main_main_fun209(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_main_main_fun209__t* _self = kk_function_as(struct kk_main_main_fun209__t*, _fself, _ctx);
  kk_std_core_types__maybe m_10002 = _self->m_10002; /* maybe<int> */
  kk_drop_match(_self, {kk_std_core_types__maybe_dup(m_10002, _ctx);}, {}, _ctx)
  kk_integer_t _x_x210;
  kk_integer_t _x_x211;
  if (kk_std_core_types__is_Nothing(m_10002, _ctx)) {
    _x_x211 = kk_integer_from_small(10); /*int*/
  }
  else {
    kk_box_t _box_x112 = m_10002._cons.Just.value;
    kk_integer_t x_1 = kk_integer_unbox(_box_x112, _ctx);
    kk_integer_dup(x_1, _ctx);
    kk_std_core_types__maybe_drop(m_10002, _ctx);
    _x_x211 = x_1; /*int*/
  }
  _x_x210 = kk_main_primes(kk_integer_from_small(2), _x_x211, kk_integer_from_small(0), _ctx); /*int*/
  return kk_integer_box(_x_x210, _ctx);
}

kk_unit_t kk_main_main(kk_context_t* _ctx) { /* () -> <console/console,div,ndet> () */ 
  kk_std_core_types__list xs_10004 = kk_std_os_env_get_args(_ctx); /*list<string>*/;
  kk_std_core_types__maybe m_10002;
  kk_string_t _x_x201;
  if (kk_std_core_types__is_Cons(xs_10004, _ctx)) {
    struct kk_std_core_types_Cons* _con_x202 = kk_std_core_types__as_Cons(xs_10004, _ctx);
    kk_box_t _box_x107 = _con_x202->head;
    kk_std_core_types__list _pat_0_0 = _con_x202->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x107);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10004, _ctx)) {
      kk_std_core_types__list_drop(_pat_0_0, _ctx);
      kk_datatype_ptr_free(xs_10004, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_datatype_ptr_decref(xs_10004, _ctx);
    }
    _x_x201 = x_0; /*string*/
  }
  else {
    _x_x201 = kk_string_empty(); /*string*/
  }
  m_10002 = kk_std_core_int_parse_int(_x_x201, kk_std_core_types__new_None(_ctx), _ctx); /*maybe<int>*/
  kk_integer_t r;
  kk_box_t _x_x204;
  kk_main__prime _x_x205;
  kk_std_core_hnd__clause1 _x_x206 = kk_std_core_hnd__new_Clause1(kk_main_new_main_fun207(_ctx), _ctx); /*hnd/clause1<1015,1016,1017,1018,1019>*/
  _x_x205 = kk_main__new_Hnd_prime(kk_reuse_null, 0, kk_integer_from_small(1), _x_x206, _ctx); /*main/prime<6,7>*/
  _x_x204 = kk_main__handle_prime(_x_x205, kk_main_new_main_fun208(_ctx), kk_main_new_main_fun209(m_10002, _ctx), _ctx); /*137*/
  r = kk_integer_unbox(_x_x204, _ctx); /*int*/
  kk_string_t _x_x212 = kk_std_core_int_show(r, _ctx); /*string*/
  kk_std_core_console_printsln(_x_x212, _ctx); return kk_Unit;
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
    kk_string_t _x_x140;
    kk_define_string_literal(, _s_x141, 10, "prime@main", _ctx)
    _x_x140 = kk_string_dup(_s_x141, _ctx); /*string*/
    kk_main__tag_prime = kk_std_core_hnd__new_Htag(_x_x140, _ctx); /*hnd/htag<main/prime>*/
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
  kk_std_core_hnd__htag_drop(kk_main__tag_prime, _ctx);
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
