// Koka generated module: std/core/tuple, koka version: 3.1.2, platform: 64-bit
#include "std_core_tuple.h"
 
// monadic lift


// lift anonymous function
struct kk_std_core_tuple_tuple2_fs__mlift_map_10030_fun125__t {
  struct kk_function_s _base;
  kk_box_t _y_x10000;
};
static kk_box_t kk_std_core_tuple_tuple2_fs__mlift_map_10030_fun125(kk_function_t _fself, kk_box_t _b_x1, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple2_fs__new_mlift_map_10030_fun125(kk_box_t _y_x10000, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs__mlift_map_10030_fun125__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple2_fs__mlift_map_10030_fun125__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple2_fs__mlift_map_10030_fun125, kk_context());
  _self->_y_x10000 = _y_x10000;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple2_fs__mlift_map_10030_fun125(kk_function_t _fself, kk_box_t _b_x1, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs__mlift_map_10030_fun125__t* _self = kk_function_as(struct kk_std_core_tuple_tuple2_fs__mlift_map_10030_fun125__t*, _fself, _ctx);
  kk_box_t _y_x10000 = _self->_y_x10000; /* 242 */
  kk_drop_match(_self, {kk_box_dup(_y_x10000, _ctx);}, {}, _ctx)
  kk_box_t _y_x10001_3 = _b_x1; /*242*/;
  kk_std_core_types__tuple2 _x_x126 = kk_std_core_types__new_Tuple2(_y_x10000, _y_x10001_3, _ctx); /*(129, 130)*/
  return kk_std_core_types__tuple2_box(_x_x126, _ctx);
}

kk_std_core_types__tuple2 kk_std_core_tuple_tuple2_fs__mlift_map_10030(kk_function_t f, kk_std_core_types__tuple2 t, kk_box_t _y_x10000, kk_context_t* _ctx) { /* forall<a,b,e> (f : (a) -> e b, t : (a, a), b) -> e (b, b) */ 
  kk_box_t x_10043;
  kk_box_t _x_x123;
  {
    kk_box_t _x_0 = t.snd;
    kk_box_dup(_x_0, _ctx);
    kk_std_core_types__tuple2_drop(t, _ctx);
    _x_x123 = _x_0; /*241*/
  }
  x_10043 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, _x_x123, _ctx), _ctx); /*242*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10043, _ctx);
    kk_box_t _x_x124 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple2_fs__new_mlift_map_10030_fun125(_y_x10000, _ctx), _ctx); /*3728*/
    return kk_std_core_types__tuple2_unbox(_x_x124, KK_OWNED, _ctx);
  }
  {
    return kk_std_core_types__new_Tuple2(_y_x10000, x_10043, _ctx);
  }
}
 
// Map a function over a tuple of elements of the same type.


// lift anonymous function
struct kk_std_core_tuple_tuple2_fs_map_fun130__t {
  struct kk_function_s _base;
  kk_function_t f;
  kk_std_core_types__tuple2 t;
};
static kk_box_t kk_std_core_tuple_tuple2_fs_map_fun130(kk_function_t _fself, kk_box_t _b_x5, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple2_fs_new_map_fun130(kk_function_t f, kk_std_core_types__tuple2 t, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs_map_fun130__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple2_fs_map_fun130__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple2_fs_map_fun130, kk_context());
  _self->f = f;
  _self->t = t;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple2_fs_map_fun130(kk_function_t _fself, kk_box_t _b_x5, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs_map_fun130__t* _self = kk_function_as(struct kk_std_core_tuple_tuple2_fs_map_fun130__t*, _fself, _ctx);
  kk_function_t f = _self->f; /* (241) -> 243 242 */
  kk_std_core_types__tuple2 t = _self->t; /* (241, 241) */
  kk_drop_match(_self, {kk_function_dup(f, _ctx);kk_std_core_types__tuple2_dup(t, _ctx);}, {}, _ctx)
  kk_box_t _y_x10000_10 = _b_x5; /*242*/;
  kk_std_core_types__tuple2 _x_x131 = kk_std_core_tuple_tuple2_fs__mlift_map_10030(f, t, _y_x10000_10, _ctx); /*(242, 242)*/
  return kk_std_core_types__tuple2_box(_x_x131, _ctx);
}


// lift anonymous function
struct kk_std_core_tuple_tuple2_fs_map_fun134__t {
  struct kk_function_s _base;
  kk_box_t x_10047;
};
static kk_box_t kk_std_core_tuple_tuple2_fs_map_fun134(kk_function_t _fself, kk_box_t _b_x7, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple2_fs_new_map_fun134(kk_box_t x_10047, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs_map_fun134__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple2_fs_map_fun134__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple2_fs_map_fun134, kk_context());
  _self->x_10047 = x_10047;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple2_fs_map_fun134(kk_function_t _fself, kk_box_t _b_x7, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs_map_fun134__t* _self = kk_function_as(struct kk_std_core_tuple_tuple2_fs_map_fun134__t*, _fself, _ctx);
  kk_box_t x_10047 = _self->x_10047; /* 242 */
  kk_drop_match(_self, {kk_box_dup(x_10047, _ctx);}, {}, _ctx)
  kk_box_t _y_x10001_11 = _b_x7; /*242*/;
  kk_std_core_types__tuple2 _x_x135 = kk_std_core_types__new_Tuple2(x_10047, _y_x10001_11, _ctx); /*(129, 130)*/
  return kk_std_core_types__tuple2_box(_x_x135, _ctx);
}

kk_std_core_types__tuple2 kk_std_core_tuple_tuple2_fs_map(kk_std_core_types__tuple2 t, kk_function_t f, kk_context_t* _ctx) { /* forall<a,b,e> (t : (a, a), f : (a) -> e b) -> e (b, b) */ 
  kk_box_t x_10047;
  kk_function_t _x_x128 = kk_function_dup(f, _ctx); /*(241) -> 243 242*/
  kk_box_t _x_x127;
  {
    kk_box_t _x = t.fst;
    kk_box_dup(_x, _ctx);
    _x_x127 = _x; /*241*/
  }
  x_10047 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x128, (_x_x128, _x_x127, _ctx), _ctx); /*242*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10047, _ctx);
    kk_box_t _x_x129 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple2_fs_new_map_fun130(f, t, _ctx), _ctx); /*3728*/
    return kk_std_core_types__tuple2_unbox(_x_x129, KK_OWNED, _ctx);
  }
  {
    kk_box_t x_0_10050;
    kk_box_t _x_x132;
    {
      kk_box_t _x_0 = t.snd;
      kk_box_dup(_x_0, _ctx);
      kk_std_core_types__tuple2_drop(t, _ctx);
      _x_x132 = _x_0; /*241*/
    }
    x_0_10050 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, _x_x132, _ctx), _ctx); /*242*/
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_0_10050, _ctx);
      kk_box_t _x_x133 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple2_fs_new_map_fun134(x_10047, _ctx), _ctx); /*3728*/
      return kk_std_core_types__tuple2_unbox(_x_x133, KK_OWNED, _ctx);
    }
    {
      return kk_std_core_types__new_Tuple2(x_10047, x_0_10050, _ctx);
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs__mlift_map_10032_fun138__t {
  struct kk_function_s _base;
  kk_box_t _y_x10002;
  kk_box_t _y_x10003;
};
static kk_box_t kk_std_core_tuple_tuple3_fs__mlift_map_10032_fun138(kk_function_t _fself, kk_box_t _b_x13, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs__new_mlift_map_10032_fun138(kk_box_t _y_x10002, kk_box_t _y_x10003, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs__mlift_map_10032_fun138__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs__mlift_map_10032_fun138__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs__mlift_map_10032_fun138, kk_context());
  _self->_y_x10002 = _y_x10002;
  _self->_y_x10003 = _y_x10003;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs__mlift_map_10032_fun138(kk_function_t _fself, kk_box_t _b_x13, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs__mlift_map_10032_fun138__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs__mlift_map_10032_fun138__t*, _fself, _ctx);
  kk_box_t _y_x10002 = _self->_y_x10002; /* 389 */
  kk_box_t _y_x10003 = _self->_y_x10003; /* 389 */
  kk_drop_match(_self, {kk_box_dup(_y_x10002, _ctx);kk_box_dup(_y_x10003, _ctx);}, {}, _ctx)
  kk_box_t _y_x10004_15 = _b_x13; /*389*/;
  kk_std_core_types__tuple3 _x_x139 = kk_std_core_types__new_Tuple3(_y_x10002, _y_x10003, _y_x10004_15, _ctx); /*(136, 137, 138)*/
  return kk_std_core_types__tuple3_box(_x_x139, _ctx);
}

kk_std_core_types__tuple3 kk_std_core_tuple_tuple3_fs__mlift_map_10032(kk_box_t _y_x10002, kk_function_t f, kk_std_core_types__tuple3 t, kk_box_t _y_x10003, kk_context_t* _ctx) { /* forall<a,b,e> (b, f : (a) -> e b, t : (a, a, a), b) -> e (b, b, b) */ 
  kk_box_t x_10055;
  kk_box_t _x_x136;
  {
    kk_box_t _x_1 = t.thd;
    kk_box_dup(_x_1, _ctx);
    kk_std_core_types__tuple3_drop(t, _ctx);
    _x_x136 = _x_1; /*388*/
  }
  x_10055 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, _x_x136, _ctx), _ctx); /*389*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10055, _ctx);
    kk_box_t _x_x137 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs__new_mlift_map_10032_fun138(_y_x10002, _y_x10003, _ctx), _ctx); /*3728*/
    return kk_std_core_types__tuple3_unbox(_x_x137, KK_OWNED, _ctx);
  }
  {
    return kk_std_core_types__new_Tuple3(_y_x10002, _y_x10003, x_10055, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs__mlift_map_10033_fun143__t {
  struct kk_function_s _base;
  kk_box_t _y_x10002;
  kk_function_t f;
  kk_std_core_types__tuple3 t;
};
static kk_box_t kk_std_core_tuple_tuple3_fs__mlift_map_10033_fun143(kk_function_t _fself, kk_box_t _b_x17, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs__new_mlift_map_10033_fun143(kk_box_t _y_x10002, kk_function_t f, kk_std_core_types__tuple3 t, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs__mlift_map_10033_fun143__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs__mlift_map_10033_fun143__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs__mlift_map_10033_fun143, kk_context());
  _self->_y_x10002 = _y_x10002;
  _self->f = f;
  _self->t = t;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs__mlift_map_10033_fun143(kk_function_t _fself, kk_box_t _b_x17, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs__mlift_map_10033_fun143__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs__mlift_map_10033_fun143__t*, _fself, _ctx);
  kk_box_t _y_x10002 = _self->_y_x10002; /* 389 */
  kk_function_t f = _self->f; /* (388) -> 390 389 */
  kk_std_core_types__tuple3 t = _self->t; /* (388, 388, 388) */
  kk_drop_match(_self, {kk_box_dup(_y_x10002, _ctx);kk_function_dup(f, _ctx);kk_std_core_types__tuple3_dup(t, _ctx);}, {}, _ctx)
  kk_box_t _y_x10003_19 = _b_x17; /*389*/;
  kk_std_core_types__tuple3 _x_x144 = kk_std_core_tuple_tuple3_fs__mlift_map_10032(_y_x10002, f, t, _y_x10003_19, _ctx); /*(389, 389, 389)*/
  return kk_std_core_types__tuple3_box(_x_x144, _ctx);
}

kk_std_core_types__tuple3 kk_std_core_tuple_tuple3_fs__mlift_map_10033(kk_function_t f, kk_std_core_types__tuple3 t, kk_box_t _y_x10002, kk_context_t* _ctx) { /* forall<a,b,e> (f : (a) -> e b, t : (a, a, a), b) -> e (b, b, b) */ 
  kk_box_t x_10060;
  kk_function_t _x_x141 = kk_function_dup(f, _ctx); /*(388) -> 390 389*/
  kk_box_t _x_x140;
  {
    kk_box_t _x_0 = t.snd;
    kk_box_dup(_x_0, _ctx);
    _x_x140 = _x_0; /*388*/
  }
  x_10060 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x141, (_x_x141, _x_x140, _ctx), _ctx); /*389*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10060, _ctx);
    kk_box_t _x_x142 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs__new_mlift_map_10033_fun143(_y_x10002, f, t, _ctx), _ctx); /*3728*/
    return kk_std_core_types__tuple3_unbox(_x_x142, KK_OWNED, _ctx);
  }
  {
    return kk_std_core_tuple_tuple3_fs__mlift_map_10032(_y_x10002, f, t, x_10060, _ctx);
  }
}
 
// Map a function over a triple of elements of the same type.


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs_map_fun148__t {
  struct kk_function_s _base;
  kk_function_t f;
  kk_std_core_types__tuple3 t;
};
static kk_box_t kk_std_core_tuple_tuple3_fs_map_fun148(kk_function_t _fself, kk_box_t _b_x21, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs_new_map_fun148(kk_function_t f, kk_std_core_types__tuple3 t, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_map_fun148__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs_map_fun148__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs_map_fun148, kk_context());
  _self->f = f;
  _self->t = t;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs_map_fun148(kk_function_t _fself, kk_box_t _b_x21, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_map_fun148__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs_map_fun148__t*, _fself, _ctx);
  kk_function_t f = _self->f; /* (388) -> 390 389 */
  kk_std_core_types__tuple3 t = _self->t; /* (388, 388, 388) */
  kk_drop_match(_self, {kk_function_dup(f, _ctx);kk_std_core_types__tuple3_dup(t, _ctx);}, {}, _ctx)
  kk_box_t _y_x10002_29 = _b_x21; /*389*/;
  kk_std_core_types__tuple3 _x_x149 = kk_std_core_tuple_tuple3_fs__mlift_map_10033(f, t, _y_x10002_29, _ctx); /*(389, 389, 389)*/
  return kk_std_core_types__tuple3_box(_x_x149, _ctx);
}


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs_map_fun153__t {
  struct kk_function_s _base;
  kk_function_t f;
  kk_std_core_types__tuple3 t;
  kk_box_t x_10062;
};
static kk_box_t kk_std_core_tuple_tuple3_fs_map_fun153(kk_function_t _fself, kk_box_t _b_x23, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs_new_map_fun153(kk_function_t f, kk_std_core_types__tuple3 t, kk_box_t x_10062, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_map_fun153__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs_map_fun153__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs_map_fun153, kk_context());
  _self->f = f;
  _self->t = t;
  _self->x_10062 = x_10062;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs_map_fun153(kk_function_t _fself, kk_box_t _b_x23, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_map_fun153__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs_map_fun153__t*, _fself, _ctx);
  kk_function_t f = _self->f; /* (388) -> 390 389 */
  kk_std_core_types__tuple3 t = _self->t; /* (388, 388, 388) */
  kk_box_t x_10062 = _self->x_10062; /* 389 */
  kk_drop_match(_self, {kk_function_dup(f, _ctx);kk_std_core_types__tuple3_dup(t, _ctx);kk_box_dup(x_10062, _ctx);}, {}, _ctx)
  kk_box_t _y_x10003_30 = _b_x23; /*389*/;
  kk_std_core_types__tuple3 _x_x154 = kk_std_core_tuple_tuple3_fs__mlift_map_10032(x_10062, f, t, _y_x10003_30, _ctx); /*(389, 389, 389)*/
  return kk_std_core_types__tuple3_box(_x_x154, _ctx);
}


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs_map_fun157__t {
  struct kk_function_s _base;
  kk_box_t x_0_10065;
  kk_box_t x_10062;
};
static kk_box_t kk_std_core_tuple_tuple3_fs_map_fun157(kk_function_t _fself, kk_box_t _b_x25, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs_new_map_fun157(kk_box_t x_0_10065, kk_box_t x_10062, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_map_fun157__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs_map_fun157__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs_map_fun157, kk_context());
  _self->x_0_10065 = x_0_10065;
  _self->x_10062 = x_10062;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs_map_fun157(kk_function_t _fself, kk_box_t _b_x25, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_map_fun157__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs_map_fun157__t*, _fself, _ctx);
  kk_box_t x_0_10065 = _self->x_0_10065; /* 389 */
  kk_box_t x_10062 = _self->x_10062; /* 389 */
  kk_drop_match(_self, {kk_box_dup(x_0_10065, _ctx);kk_box_dup(x_10062, _ctx);}, {}, _ctx)
  kk_box_t _y_x10004_31 = _b_x25; /*389*/;
  kk_std_core_types__tuple3 _x_x158 = kk_std_core_types__new_Tuple3(x_10062, x_0_10065, _y_x10004_31, _ctx); /*(136, 137, 138)*/
  return kk_std_core_types__tuple3_box(_x_x158, _ctx);
}

kk_std_core_types__tuple3 kk_std_core_tuple_tuple3_fs_map(kk_std_core_types__tuple3 t, kk_function_t f, kk_context_t* _ctx) { /* forall<a,b,e> (t : (a, a, a), f : (a) -> e b) -> e (b, b, b) */ 
  kk_box_t x_10062;
  kk_function_t _x_x146 = kk_function_dup(f, _ctx); /*(388) -> 390 389*/
  kk_box_t _x_x145;
  {
    kk_box_t _x = t.fst;
    kk_box_dup(_x, _ctx);
    _x_x145 = _x; /*388*/
  }
  x_10062 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x146, (_x_x146, _x_x145, _ctx), _ctx); /*389*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10062, _ctx);
    kk_box_t _x_x147 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs_new_map_fun148(f, t, _ctx), _ctx); /*3728*/
    return kk_std_core_types__tuple3_unbox(_x_x147, KK_OWNED, _ctx);
  }
  {
    kk_box_t x_0_10065;
    kk_function_t _x_x151 = kk_function_dup(f, _ctx); /*(388) -> 390 389*/
    kk_box_t _x_x150;
    {
      kk_box_t _x_0 = t.snd;
      kk_box_dup(_x_0, _ctx);
      _x_x150 = _x_0; /*388*/
    }
    x_0_10065 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x151, (_x_x151, _x_x150, _ctx), _ctx); /*389*/
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_0_10065, _ctx);
      kk_box_t _x_x152 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs_new_map_fun153(f, t, x_10062, _ctx), _ctx); /*3728*/
      return kk_std_core_types__tuple3_unbox(_x_x152, KK_OWNED, _ctx);
    }
    {
      kk_box_t x_1_10068;
      kk_box_t _x_x155;
      {
        kk_box_t _x_1 = t.thd;
        kk_box_dup(_x_1, _ctx);
        kk_std_core_types__tuple3_drop(t, _ctx);
        _x_x155 = _x_1; /*388*/
      }
      x_1_10068 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, _x_x155, _ctx), _ctx); /*389*/
      if (kk_yielding(kk_context())) {
        kk_box_drop(x_1_10068, _ctx);
        kk_box_t _x_x156 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs_new_map_fun157(x_0_10065, x_10062, _ctx), _ctx); /*3728*/
        return kk_std_core_types__tuple3_unbox(_x_x156, KK_OWNED, _ctx);
      }
      {
        return kk_std_core_types__new_Tuple3(x_10062, x_0_10065, x_1_10068, _ctx);
      }
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_tuple_tuple4_fs__mlift_map_10035_fun162__t {
  struct kk_function_s _base;
  kk_box_t _y_x10005;
  kk_box_t _y_x10006;
  kk_box_t _y_x10007;
};
static kk_box_t kk_std_core_tuple_tuple4_fs__mlift_map_10035_fun162(kk_function_t _fself, kk_box_t _b_x33, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple4_fs__new_mlift_map_10035_fun162(kk_box_t _y_x10005, kk_box_t _y_x10006, kk_box_t _y_x10007, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs__mlift_map_10035_fun162__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple4_fs__mlift_map_10035_fun162__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple4_fs__mlift_map_10035_fun162, kk_context());
  _self->_y_x10005 = _y_x10005;
  _self->_y_x10006 = _y_x10006;
  _self->_y_x10007 = _y_x10007;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple4_fs__mlift_map_10035_fun162(kk_function_t _fself, kk_box_t _b_x33, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs__mlift_map_10035_fun162__t* _self = kk_function_as(struct kk_std_core_tuple_tuple4_fs__mlift_map_10035_fun162__t*, _fself, _ctx);
  kk_box_t _y_x10005 = _self->_y_x10005; /* 576 */
  kk_box_t _y_x10006 = _self->_y_x10006; /* 576 */
  kk_box_t _y_x10007 = _self->_y_x10007; /* 576 */
  kk_drop_match(_self, {kk_box_dup(_y_x10005, _ctx);kk_box_dup(_y_x10006, _ctx);kk_box_dup(_y_x10007, _ctx);}, {}, _ctx)
  kk_box_t _y_x10008_35 = _b_x33; /*576*/;
  kk_std_core_types__tuple4 _x_x163 = kk_std_core_types__new_Tuple4(kk_reuse_null, 0, _y_x10005, _y_x10006, _y_x10007, _y_x10008_35, _ctx); /*(1712, 1713, 1714, 1715)*/
  return kk_std_core_types__tuple4_box(_x_x163, _ctx);
}

kk_std_core_types__tuple4 kk_std_core_tuple_tuple4_fs__mlift_map_10035(kk_box_t _y_x10005, kk_box_t _y_x10006, kk_function_t f, kk_std_core_types__tuple4 t, kk_box_t _y_x10007, kk_context_t* _ctx) { /* forall<a,b,e> (b, b, f : (a) -> e b, t : (a, a, a, a), b) -> e (b, b, b, b) */ 
  kk_box_t x_10074;
  kk_box_t _x_x159;
  {
    struct kk_std_core_types_Tuple4* _con_x160 = kk_std_core_types__as_Tuple4(t, _ctx);
    kk_box_t _pat_0_2 = _con_x160->fst;
    kk_box_t _pat_1_2 = _con_x160->snd;
    kk_box_t _pat_2_2 = _con_x160->thd;
    kk_box_t _x_2 = _con_x160->field4;
    if kk_likely(kk_datatype_ptr_is_unique(t, _ctx)) {
      kk_box_drop(_pat_2_2, _ctx);
      kk_box_drop(_pat_1_2, _ctx);
      kk_box_drop(_pat_0_2, _ctx);
      kk_datatype_ptr_free(t, _ctx);
    }
    else {
      kk_box_dup(_x_2, _ctx);
      kk_datatype_ptr_decref(t, _ctx);
    }
    _x_x159 = _x_2; /*575*/
  }
  x_10074 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, _x_x159, _ctx), _ctx); /*576*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10074, _ctx);
    kk_box_t _x_x161 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple4_fs__new_mlift_map_10035_fun162(_y_x10005, _y_x10006, _y_x10007, _ctx), _ctx); /*3728*/
    return kk_std_core_types__tuple4_unbox(_x_x161, KK_OWNED, _ctx);
  }
  {
    return kk_std_core_types__new_Tuple4(kk_reuse_null, 0, _y_x10005, _y_x10006, _y_x10007, x_10074, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_tuple_tuple4_fs__mlift_map_10036_fun168__t {
  struct kk_function_s _base;
  kk_box_t _y_x10005;
  kk_box_t _y_x10006;
  kk_function_t f;
  kk_std_core_types__tuple4 t;
};
static kk_box_t kk_std_core_tuple_tuple4_fs__mlift_map_10036_fun168(kk_function_t _fself, kk_box_t _b_x37, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple4_fs__new_mlift_map_10036_fun168(kk_box_t _y_x10005, kk_box_t _y_x10006, kk_function_t f, kk_std_core_types__tuple4 t, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs__mlift_map_10036_fun168__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple4_fs__mlift_map_10036_fun168__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple4_fs__mlift_map_10036_fun168, kk_context());
  _self->_y_x10005 = _y_x10005;
  _self->_y_x10006 = _y_x10006;
  _self->f = f;
  _self->t = t;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple4_fs__mlift_map_10036_fun168(kk_function_t _fself, kk_box_t _b_x37, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs__mlift_map_10036_fun168__t* _self = kk_function_as(struct kk_std_core_tuple_tuple4_fs__mlift_map_10036_fun168__t*, _fself, _ctx);
  kk_box_t _y_x10005 = _self->_y_x10005; /* 576 */
  kk_box_t _y_x10006 = _self->_y_x10006; /* 576 */
  kk_function_t f = _self->f; /* (575) -> 577 576 */
  kk_std_core_types__tuple4 t = _self->t; /* (575, 575, 575, 575) */
  kk_drop_match(_self, {kk_box_dup(_y_x10005, _ctx);kk_box_dup(_y_x10006, _ctx);kk_function_dup(f, _ctx);kk_std_core_types__tuple4_dup(t, _ctx);}, {}, _ctx)
  kk_box_t _y_x10007_39 = _b_x37; /*576*/;
  kk_std_core_types__tuple4 _x_x169 = kk_std_core_tuple_tuple4_fs__mlift_map_10035(_y_x10005, _y_x10006, f, t, _y_x10007_39, _ctx); /*(576, 576, 576, 576)*/
  return kk_std_core_types__tuple4_box(_x_x169, _ctx);
}

kk_std_core_types__tuple4 kk_std_core_tuple_tuple4_fs__mlift_map_10036(kk_box_t _y_x10005, kk_function_t f, kk_std_core_types__tuple4 t, kk_box_t _y_x10006, kk_context_t* _ctx) { /* forall<a,b,e> (b, f : (a) -> e b, t : (a, a, a, a), b) -> e (b, b, b, b) */ 
  kk_box_t x_10080;
  kk_function_t _x_x166 = kk_function_dup(f, _ctx); /*(575) -> 577 576*/
  kk_box_t _x_x164;
  {
    struct kk_std_core_types_Tuple4* _con_x165 = kk_std_core_types__as_Tuple4(t, _ctx);
    kk_box_t _x_1 = _con_x165->thd;
    kk_box_dup(_x_1, _ctx);
    _x_x164 = _x_1; /*575*/
  }
  x_10080 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x166, (_x_x166, _x_x164, _ctx), _ctx); /*576*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10080, _ctx);
    kk_box_t _x_x167 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple4_fs__new_mlift_map_10036_fun168(_y_x10005, _y_x10006, f, t, _ctx), _ctx); /*3728*/
    return kk_std_core_types__tuple4_unbox(_x_x167, KK_OWNED, _ctx);
  }
  {
    return kk_std_core_tuple_tuple4_fs__mlift_map_10035(_y_x10005, _y_x10006, f, t, x_10080, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_tuple_tuple4_fs__mlift_map_10037_fun174__t {
  struct kk_function_s _base;
  kk_box_t _y_x10005;
  kk_function_t f;
  kk_std_core_types__tuple4 t;
};
static kk_box_t kk_std_core_tuple_tuple4_fs__mlift_map_10037_fun174(kk_function_t _fself, kk_box_t _b_x41, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple4_fs__new_mlift_map_10037_fun174(kk_box_t _y_x10005, kk_function_t f, kk_std_core_types__tuple4 t, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs__mlift_map_10037_fun174__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple4_fs__mlift_map_10037_fun174__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple4_fs__mlift_map_10037_fun174, kk_context());
  _self->_y_x10005 = _y_x10005;
  _self->f = f;
  _self->t = t;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple4_fs__mlift_map_10037_fun174(kk_function_t _fself, kk_box_t _b_x41, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs__mlift_map_10037_fun174__t* _self = kk_function_as(struct kk_std_core_tuple_tuple4_fs__mlift_map_10037_fun174__t*, _fself, _ctx);
  kk_box_t _y_x10005 = _self->_y_x10005; /* 576 */
  kk_function_t f = _self->f; /* (575) -> 577 576 */
  kk_std_core_types__tuple4 t = _self->t; /* (575, 575, 575, 575) */
  kk_drop_match(_self, {kk_box_dup(_y_x10005, _ctx);kk_function_dup(f, _ctx);kk_std_core_types__tuple4_dup(t, _ctx);}, {}, _ctx)
  kk_box_t _y_x10006_43 = _b_x41; /*576*/;
  kk_std_core_types__tuple4 _x_x175 = kk_std_core_tuple_tuple4_fs__mlift_map_10036(_y_x10005, f, t, _y_x10006_43, _ctx); /*(576, 576, 576, 576)*/
  return kk_std_core_types__tuple4_box(_x_x175, _ctx);
}

kk_std_core_types__tuple4 kk_std_core_tuple_tuple4_fs__mlift_map_10037(kk_function_t f, kk_std_core_types__tuple4 t, kk_box_t _y_x10005, kk_context_t* _ctx) { /* forall<a,b,e> (f : (a) -> e b, t : (a, a, a, a), b) -> e (b, b, b, b) */ 
  kk_box_t x_10082;
  kk_function_t _x_x172 = kk_function_dup(f, _ctx); /*(575) -> 577 576*/
  kk_box_t _x_x170;
  {
    struct kk_std_core_types_Tuple4* _con_x171 = kk_std_core_types__as_Tuple4(t, _ctx);
    kk_box_t _x_0 = _con_x171->snd;
    kk_box_dup(_x_0, _ctx);
    _x_x170 = _x_0; /*575*/
  }
  x_10082 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x172, (_x_x172, _x_x170, _ctx), _ctx); /*576*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10082, _ctx);
    kk_box_t _x_x173 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple4_fs__new_mlift_map_10037_fun174(_y_x10005, f, t, _ctx), _ctx); /*3728*/
    return kk_std_core_types__tuple4_unbox(_x_x173, KK_OWNED, _ctx);
  }
  {
    return kk_std_core_tuple_tuple4_fs__mlift_map_10036(_y_x10005, f, t, x_10082, _ctx);
  }
}
 
// Map a function over a quadruple of elements of the same type.


// lift anonymous function
struct kk_std_core_tuple_tuple4_fs_map_fun180__t {
  struct kk_function_s _base;
  kk_function_t f;
  kk_std_core_types__tuple4 t;
};
static kk_box_t kk_std_core_tuple_tuple4_fs_map_fun180(kk_function_t _fself, kk_box_t _b_x45, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple4_fs_new_map_fun180(kk_function_t f, kk_std_core_types__tuple4 t, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs_map_fun180__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple4_fs_map_fun180__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple4_fs_map_fun180, kk_context());
  _self->f = f;
  _self->t = t;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple4_fs_map_fun180(kk_function_t _fself, kk_box_t _b_x45, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs_map_fun180__t* _self = kk_function_as(struct kk_std_core_tuple_tuple4_fs_map_fun180__t*, _fself, _ctx);
  kk_function_t f = _self->f; /* (575) -> 577 576 */
  kk_std_core_types__tuple4 t = _self->t; /* (575, 575, 575, 575) */
  kk_drop_match(_self, {kk_function_dup(f, _ctx);kk_std_core_types__tuple4_dup(t, _ctx);}, {}, _ctx)
  kk_box_t _y_x10005_56 = _b_x45; /*576*/;
  kk_std_core_types__tuple4 _x_x181 = kk_std_core_tuple_tuple4_fs__mlift_map_10037(f, t, _y_x10005_56, _ctx); /*(576, 576, 576, 576)*/
  return kk_std_core_types__tuple4_box(_x_x181, _ctx);
}


// lift anonymous function
struct kk_std_core_tuple_tuple4_fs_map_fun186__t {
  struct kk_function_s _base;
  kk_function_t f;
  kk_std_core_types__tuple4 t;
  kk_box_t x_10084;
};
static kk_box_t kk_std_core_tuple_tuple4_fs_map_fun186(kk_function_t _fself, kk_box_t _b_x47, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple4_fs_new_map_fun186(kk_function_t f, kk_std_core_types__tuple4 t, kk_box_t x_10084, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs_map_fun186__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple4_fs_map_fun186__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple4_fs_map_fun186, kk_context());
  _self->f = f;
  _self->t = t;
  _self->x_10084 = x_10084;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple4_fs_map_fun186(kk_function_t _fself, kk_box_t _b_x47, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs_map_fun186__t* _self = kk_function_as(struct kk_std_core_tuple_tuple4_fs_map_fun186__t*, _fself, _ctx);
  kk_function_t f = _self->f; /* (575) -> 577 576 */
  kk_std_core_types__tuple4 t = _self->t; /* (575, 575, 575, 575) */
  kk_box_t x_10084 = _self->x_10084; /* 576 */
  kk_drop_match(_self, {kk_function_dup(f, _ctx);kk_std_core_types__tuple4_dup(t, _ctx);kk_box_dup(x_10084, _ctx);}, {}, _ctx)
  kk_box_t _y_x10006_57 = _b_x47; /*576*/;
  kk_std_core_types__tuple4 _x_x187 = kk_std_core_tuple_tuple4_fs__mlift_map_10036(x_10084, f, t, _y_x10006_57, _ctx); /*(576, 576, 576, 576)*/
  return kk_std_core_types__tuple4_box(_x_x187, _ctx);
}


// lift anonymous function
struct kk_std_core_tuple_tuple4_fs_map_fun192__t {
  struct kk_function_s _base;
  kk_function_t f;
  kk_std_core_types__tuple4 t;
  kk_box_t x_0_10087;
  kk_box_t x_10084;
};
static kk_box_t kk_std_core_tuple_tuple4_fs_map_fun192(kk_function_t _fself, kk_box_t _b_x49, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple4_fs_new_map_fun192(kk_function_t f, kk_std_core_types__tuple4 t, kk_box_t x_0_10087, kk_box_t x_10084, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs_map_fun192__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple4_fs_map_fun192__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple4_fs_map_fun192, kk_context());
  _self->f = f;
  _self->t = t;
  _self->x_0_10087 = x_0_10087;
  _self->x_10084 = x_10084;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple4_fs_map_fun192(kk_function_t _fself, kk_box_t _b_x49, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs_map_fun192__t* _self = kk_function_as(struct kk_std_core_tuple_tuple4_fs_map_fun192__t*, _fself, _ctx);
  kk_function_t f = _self->f; /* (575) -> 577 576 */
  kk_std_core_types__tuple4 t = _self->t; /* (575, 575, 575, 575) */
  kk_box_t x_0_10087 = _self->x_0_10087; /* 576 */
  kk_box_t x_10084 = _self->x_10084; /* 576 */
  kk_drop_match(_self, {kk_function_dup(f, _ctx);kk_std_core_types__tuple4_dup(t, _ctx);kk_box_dup(x_0_10087, _ctx);kk_box_dup(x_10084, _ctx);}, {}, _ctx)
  kk_box_t _y_x10007_58 = _b_x49; /*576*/;
  kk_std_core_types__tuple4 _x_x193 = kk_std_core_tuple_tuple4_fs__mlift_map_10035(x_10084, x_0_10087, f, t, _y_x10007_58, _ctx); /*(576, 576, 576, 576)*/
  return kk_std_core_types__tuple4_box(_x_x193, _ctx);
}


// lift anonymous function
struct kk_std_core_tuple_tuple4_fs_map_fun197__t {
  struct kk_function_s _base;
  kk_box_t x_0_10087;
  kk_box_t x_10084;
  kk_box_t x_1_10090;
};
static kk_box_t kk_std_core_tuple_tuple4_fs_map_fun197(kk_function_t _fself, kk_box_t _b_x51, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple4_fs_new_map_fun197(kk_box_t x_0_10087, kk_box_t x_10084, kk_box_t x_1_10090, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs_map_fun197__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple4_fs_map_fun197__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple4_fs_map_fun197, kk_context());
  _self->x_0_10087 = x_0_10087;
  _self->x_10084 = x_10084;
  _self->x_1_10090 = x_1_10090;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple4_fs_map_fun197(kk_function_t _fself, kk_box_t _b_x51, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple4_fs_map_fun197__t* _self = kk_function_as(struct kk_std_core_tuple_tuple4_fs_map_fun197__t*, _fself, _ctx);
  kk_box_t x_0_10087 = _self->x_0_10087; /* 576 */
  kk_box_t x_10084 = _self->x_10084; /* 576 */
  kk_box_t x_1_10090 = _self->x_1_10090; /* 576 */
  kk_drop_match(_self, {kk_box_dup(x_0_10087, _ctx);kk_box_dup(x_10084, _ctx);kk_box_dup(x_1_10090, _ctx);}, {}, _ctx)
  kk_box_t _y_x10008_59 = _b_x51; /*576*/;
  kk_std_core_types__tuple4 _x_x198 = kk_std_core_types__new_Tuple4(kk_reuse_null, 0, x_10084, x_0_10087, x_1_10090, _y_x10008_59, _ctx); /*(1712, 1713, 1714, 1715)*/
  return kk_std_core_types__tuple4_box(_x_x198, _ctx);
}

kk_std_core_types__tuple4 kk_std_core_tuple_tuple4_fs_map(kk_std_core_types__tuple4 t, kk_function_t f, kk_context_t* _ctx) { /* forall<a,b,e> (t : (a, a, a, a), f : (a) -> e b) -> e (b, b, b, b) */ 
  kk_box_t x_10084;
  kk_function_t _x_x178 = kk_function_dup(f, _ctx); /*(575) -> 577 576*/
  kk_box_t _x_x176;
  {
    struct kk_std_core_types_Tuple4* _con_x177 = kk_std_core_types__as_Tuple4(t, _ctx);
    kk_box_t _x = _con_x177->fst;
    kk_box_dup(_x, _ctx);
    _x_x176 = _x; /*575*/
  }
  x_10084 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x178, (_x_x178, _x_x176, _ctx), _ctx); /*576*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(x_10084, _ctx);
    kk_box_t _x_x179 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple4_fs_new_map_fun180(f, t, _ctx), _ctx); /*3728*/
    return kk_std_core_types__tuple4_unbox(_x_x179, KK_OWNED, _ctx);
  }
  {
    kk_box_t x_0_10087;
    kk_function_t _x_x184 = kk_function_dup(f, _ctx); /*(575) -> 577 576*/
    kk_box_t _x_x182;
    {
      struct kk_std_core_types_Tuple4* _con_x183 = kk_std_core_types__as_Tuple4(t, _ctx);
      kk_box_t _x_0 = _con_x183->snd;
      kk_box_dup(_x_0, _ctx);
      _x_x182 = _x_0; /*575*/
    }
    x_0_10087 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x184, (_x_x184, _x_x182, _ctx), _ctx); /*576*/
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_0_10087, _ctx);
      kk_box_t _x_x185 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple4_fs_new_map_fun186(f, t, x_10084, _ctx), _ctx); /*3728*/
      return kk_std_core_types__tuple4_unbox(_x_x185, KK_OWNED, _ctx);
    }
    {
      kk_box_t x_1_10090;
      kk_function_t _x_x190 = kk_function_dup(f, _ctx); /*(575) -> 577 576*/
      kk_box_t _x_x188;
      {
        struct kk_std_core_types_Tuple4* _con_x189 = kk_std_core_types__as_Tuple4(t, _ctx);
        kk_box_t _x_1 = _con_x189->thd;
        kk_box_dup(_x_1, _ctx);
        _x_x188 = _x_1; /*575*/
      }
      x_1_10090 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x190, (_x_x190, _x_x188, _ctx), _ctx); /*576*/
      if (kk_yielding(kk_context())) {
        kk_box_drop(x_1_10090, _ctx);
        kk_box_t _x_x191 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple4_fs_new_map_fun192(f, t, x_0_10087, x_10084, _ctx), _ctx); /*3728*/
        return kk_std_core_types__tuple4_unbox(_x_x191, KK_OWNED, _ctx);
      }
      {
        kk_box_t x_2_10093;
        kk_box_t _x_x194;
        {
          struct kk_std_core_types_Tuple4* _con_x195 = kk_std_core_types__as_Tuple4(t, _ctx);
          kk_box_t _pat_0_2_0 = _con_x195->fst;
          kk_box_t _pat_1_2 = _con_x195->snd;
          kk_box_t _pat_2_2 = _con_x195->thd;
          kk_box_t _x_2 = _con_x195->field4;
          if kk_likely(kk_datatype_ptr_is_unique(t, _ctx)) {
            kk_box_drop(_pat_2_2, _ctx);
            kk_box_drop(_pat_1_2, _ctx);
            kk_box_drop(_pat_0_2_0, _ctx);
            kk_datatype_ptr_free(t, _ctx);
          }
          else {
            kk_box_dup(_x_2, _ctx);
            kk_datatype_ptr_decref(t, _ctx);
          }
          _x_x194 = _x_2; /*575*/
        }
        x_2_10093 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, _x_x194, _ctx), _ctx); /*576*/
        if (kk_yielding(kk_context())) {
          kk_box_drop(x_2_10093, _ctx);
          kk_box_t _x_x196 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple4_fs_new_map_fun197(x_0_10087, x_10084, x_1_10090, _ctx), _ctx); /*3728*/
          return kk_std_core_types__tuple4_unbox(_x_x196, KK_OWNED, _ctx);
        }
        {
          return kk_std_core_types__new_Tuple4(kk_reuse_null, 0, x_10084, x_0_10087, x_1_10090, x_2_10093, _ctx);
        }
      }
    }
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun209__t {
  struct kk_function_s _base;
  kk_string_t _y_x10009;
};
static kk_string_t kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun209(kk_function_t _fself, kk_string_t _y_x10010, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple2_fs__new_mlift_show_10039_fun209(kk_string_t _y_x10009, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun209__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun209__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun209, kk_context());
  _self->_y_x10009 = _y_x10009;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_string_t kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun209(kk_function_t _fself, kk_string_t _y_x10010, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun209__t* _self = kk_function_as(struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun209__t*, _fself, _ctx);
  kk_string_t _y_x10009 = _self->_y_x10009; /* string */
  kk_drop_match(_self, {kk_string_dup(_y_x10009, _ctx);}, {}, _ctx)
  kk_string_t _x_x210;
  kk_define_string_literal(, _s_x211, 1, "(", _ctx)
  _x_x210 = kk_string_dup(_s_x211, _ctx); /*string*/
  kk_string_t _x_x212;
  kk_string_t _x_x213;
  kk_string_t _x_x214;
  kk_define_string_literal(, _s_x215, 1, ",", _ctx)
  _x_x214 = kk_string_dup(_s_x215, _ctx); /*string*/
  kk_string_t _x_x216;
  kk_string_t _x_x217;
  kk_define_string_literal(, _s_x218, 1, ")", _ctx)
  _x_x217 = kk_string_dup(_s_x218, _ctx); /*string*/
  _x_x216 = kk_std_core_types__lp__plus__plus__rp_(_y_x10010, _x_x217, _ctx); /*string*/
  _x_x213 = kk_std_core_types__lp__plus__plus__rp_(_x_x214, _x_x216, _ctx); /*string*/
  _x_x212 = kk_std_core_types__lp__plus__plus__rp_(_y_x10009, _x_x213, _ctx); /*string*/
  return kk_std_core_types__lp__plus__plus__rp_(_x_x210, _x_x212, _ctx);
}


// lift anonymous function
struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun220__t {
  struct kk_function_s _base;
  kk_function_t next_10101;
};
static kk_box_t kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun220(kk_function_t _fself, kk_box_t _b_x61, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple2_fs__new_mlift_show_10039_fun220(kk_function_t next_10101, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun220__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun220__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun220, kk_context());
  _self->next_10101 = next_10101;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun220(kk_function_t _fself, kk_box_t _b_x61, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun220__t* _self = kk_function_as(struct kk_std_core_tuple_tuple2_fs__mlift_show_10039_fun220__t*, _fself, _ctx);
  kk_function_t next_10101 = _self->next_10101; /* (string) -> 748 string */
  kk_drop_match(_self, {kk_function_dup(next_10101, _ctx);}, {}, _ctx)
  kk_string_t _x_x221;
  kk_string_t _x_x222 = kk_string_unbox(_b_x61); /*string*/
  _x_x221 = kk_function_call(kk_string_t, (kk_function_t, kk_string_t, kk_context_t*), next_10101, (next_10101, _x_x222, _ctx), _ctx); /*string*/
  return kk_string_box(_x_x221);
}

kk_string_t kk_std_core_tuple_tuple2_fs__mlift_show_10039(kk_std_core_types__tuple2 x, kk_function_t _implicit_fs_snd_fs_show, kk_string_t _y_x10009, kk_context_t* _ctx) { /* forall<a,b,e> (x : (a, b), ?snd/show : (b) -> e string, string) -> e string */ 
  kk_string_t x_0_10100;
  kk_box_t _x_x208;
  {
    kk_box_t _x_0 = x.snd;
    kk_box_dup(_x_0, _ctx);
    kk_std_core_types__tuple2_drop(x, _ctx);
    _x_x208 = _x_0; /*747*/
  }
  x_0_10100 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_snd_fs_show, (_implicit_fs_snd_fs_show, _x_x208, _ctx), _ctx); /*string*/
  kk_function_t next_10101 = kk_std_core_tuple_tuple2_fs__new_mlift_show_10039_fun209(_y_x10009, _ctx); /*(string) -> 748 string*/;
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_0_10100, _ctx);
    kk_box_t _x_x219 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple2_fs__new_mlift_show_10039_fun220(next_10101, _ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x219);
  }
  {
    return kk_function_call(kk_string_t, (kk_function_t, kk_string_t, kk_context_t*), next_10101, (next_10101, x_0_10100, _ctx), _ctx);
  }
}
 
// Show a tuple


// lift anonymous function
struct kk_std_core_tuple_tuple2_fs_show_fun225__t {
  struct kk_function_s _base;
  kk_std_core_types__tuple2 x;
  kk_function_t _implicit_fs_snd_fs_show;
};
static kk_box_t kk_std_core_tuple_tuple2_fs_show_fun225(kk_function_t _fself, kk_box_t _b_x64, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple2_fs_new_show_fun225(kk_std_core_types__tuple2 x, kk_function_t _implicit_fs_snd_fs_show, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs_show_fun225__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple2_fs_show_fun225__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple2_fs_show_fun225, kk_context());
  _self->x = x;
  _self->_implicit_fs_snd_fs_show = _implicit_fs_snd_fs_show;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple2_fs_show_fun225(kk_function_t _fself, kk_box_t _b_x64, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs_show_fun225__t* _self = kk_function_as(struct kk_std_core_tuple_tuple2_fs_show_fun225__t*, _fself, _ctx);
  kk_std_core_types__tuple2 x = _self->x; /* (746, 747) */
  kk_function_t _implicit_fs_snd_fs_show = _self->_implicit_fs_snd_fs_show; /* (747) -> 748 string */
  kk_drop_match(_self, {kk_std_core_types__tuple2_dup(x, _ctx);kk_function_dup(_implicit_fs_snd_fs_show, _ctx);}, {}, _ctx)
  kk_string_t _y_x10009_69 = kk_string_unbox(_b_x64); /*string*/;
  kk_string_t _x_x226 = kk_std_core_tuple_tuple2_fs__mlift_show_10039(x, _implicit_fs_snd_fs_show, _y_x10009_69, _ctx); /*string*/
  return kk_string_box(_x_x226);
}


// lift anonymous function
struct kk_std_core_tuple_tuple2_fs_show_fun229__t {
  struct kk_function_s _base;
  kk_string_t x_0_10104;
};
static kk_box_t kk_std_core_tuple_tuple2_fs_show_fun229(kk_function_t _fself, kk_box_t _b_x66, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple2_fs_new_show_fun229(kk_string_t x_0_10104, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs_show_fun229__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple2_fs_show_fun229__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple2_fs_show_fun229, kk_context());
  _self->x_0_10104 = x_0_10104;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple2_fs_show_fun229(kk_function_t _fself, kk_box_t _b_x66, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple2_fs_show_fun229__t* _self = kk_function_as(struct kk_std_core_tuple_tuple2_fs_show_fun229__t*, _fself, _ctx);
  kk_string_t x_0_10104 = _self->x_0_10104; /* string */
  kk_drop_match(_self, {kk_string_dup(x_0_10104, _ctx);}, {}, _ctx)
  kk_string_t _y_x10010_70 = kk_string_unbox(_b_x66); /*string*/;
  kk_string_t _x_x230;
  kk_string_t _x_x231;
  kk_define_string_literal(, _s_x232, 1, "(", _ctx)
  _x_x231 = kk_string_dup(_s_x232, _ctx); /*string*/
  kk_string_t _x_x233;
  kk_string_t _x_x234;
  kk_string_t _x_x235;
  kk_define_string_literal(, _s_x236, 1, ",", _ctx)
  _x_x235 = kk_string_dup(_s_x236, _ctx); /*string*/
  kk_string_t _x_x237;
  kk_string_t _x_x238;
  kk_define_string_literal(, _s_x239, 1, ")", _ctx)
  _x_x238 = kk_string_dup(_s_x239, _ctx); /*string*/
  _x_x237 = kk_std_core_types__lp__plus__plus__rp_(_y_x10010_70, _x_x238, _ctx); /*string*/
  _x_x234 = kk_std_core_types__lp__plus__plus__rp_(_x_x235, _x_x237, _ctx); /*string*/
  _x_x233 = kk_std_core_types__lp__plus__plus__rp_(x_0_10104, _x_x234, _ctx); /*string*/
  _x_x230 = kk_std_core_types__lp__plus__plus__rp_(_x_x231, _x_x233, _ctx); /*string*/
  return kk_string_box(_x_x230);
}

kk_string_t kk_std_core_tuple_tuple2_fs_show(kk_std_core_types__tuple2 x, kk_function_t _implicit_fs_fst_fs_show, kk_function_t _implicit_fs_snd_fs_show, kk_context_t* _ctx) { /* forall<a,b,e> (x : (a, b), ?fst/show : (a) -> e string, ?snd/show : (b) -> e string) -> e string */ 
  kk_string_t x_0_10104;
  kk_box_t _x_x223;
  {
    kk_box_t _x = x.fst;
    kk_box_dup(_x, _ctx);
    _x_x223 = _x; /*746*/
  }
  x_0_10104 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_fst_fs_show, (_implicit_fs_fst_fs_show, _x_x223, _ctx), _ctx); /*string*/
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_0_10104, _ctx);
    kk_box_t _x_x224 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple2_fs_new_show_fun225(x, _implicit_fs_snd_fs_show, _ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x224);
  }
  {
    kk_string_t x_1_10107;
    kk_box_t _x_x227;
    {
      kk_box_t _x_0 = x.snd;
      kk_box_dup(_x_0, _ctx);
      kk_std_core_types__tuple2_drop(x, _ctx);
      _x_x227 = _x_0; /*747*/
    }
    x_1_10107 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_snd_fs_show, (_implicit_fs_snd_fs_show, _x_x227, _ctx), _ctx); /*string*/
    if (kk_yielding(kk_context())) {
      kk_string_drop(x_1_10107, _ctx);
      kk_box_t _x_x228 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple2_fs_new_show_fun229(x_0_10104, _ctx), _ctx); /*3728*/
      return kk_string_unbox(_x_x228);
    }
    {
      kk_string_t _x_x240;
      kk_define_string_literal(, _s_x241, 1, "(", _ctx)
      _x_x240 = kk_string_dup(_s_x241, _ctx); /*string*/
      kk_string_t _x_x242;
      kk_string_t _x_x243;
      kk_string_t _x_x244;
      kk_define_string_literal(, _s_x245, 1, ",", _ctx)
      _x_x244 = kk_string_dup(_s_x245, _ctx); /*string*/
      kk_string_t _x_x246;
      kk_string_t _x_x247;
      kk_define_string_literal(, _s_x248, 1, ")", _ctx)
      _x_x247 = kk_string_dup(_s_x248, _ctx); /*string*/
      _x_x246 = kk_std_core_types__lp__plus__plus__rp_(x_1_10107, _x_x247, _ctx); /*string*/
      _x_x243 = kk_std_core_types__lp__plus__plus__rp_(_x_x244, _x_x246, _ctx); /*string*/
      _x_x242 = kk_std_core_types__lp__plus__plus__rp_(x_0_10104, _x_x243, _ctx); /*string*/
      return kk_std_core_types__lp__plus__plus__rp_(_x_x240, _x_x242, _ctx);
    }
  }
}
 
// monadic lift

kk_string_t kk_std_core_tuple_tuple3_fs__mlift_show_10040(kk_string_t _y_x10011, kk_string_t _y_x10012, kk_string_t _y_x10013, kk_context_t* _ctx) { /* forall<e> (string, string, string) -> e string */ 
  kk_string_t _x_x249;
  kk_define_string_literal(, _s_x250, 1, "(", _ctx)
  _x_x249 = kk_string_dup(_s_x250, _ctx); /*string*/
  kk_string_t _x_x251;
  kk_string_t _x_x252;
  kk_string_t _x_x253;
  kk_define_string_literal(, _s_x254, 1, ",", _ctx)
  _x_x253 = kk_string_dup(_s_x254, _ctx); /*string*/
  kk_string_t _x_x255;
  kk_string_t _x_x256;
  kk_string_t _x_x257;
  kk_define_string_literal(, _s_x258, 1, ",", _ctx)
  _x_x257 = kk_string_dup(_s_x258, _ctx); /*string*/
  kk_string_t _x_x259;
  kk_string_t _x_x260;
  kk_define_string_literal(, _s_x261, 1, ")", _ctx)
  _x_x260 = kk_string_dup(_s_x261, _ctx); /*string*/
  _x_x259 = kk_std_core_types__lp__plus__plus__rp_(_y_x10013, _x_x260, _ctx); /*string*/
  _x_x256 = kk_std_core_types__lp__plus__plus__rp_(_x_x257, _x_x259, _ctx); /*string*/
  _x_x255 = kk_std_core_types__lp__plus__plus__rp_(_y_x10012, _x_x256, _ctx); /*string*/
  _x_x252 = kk_std_core_types__lp__plus__plus__rp_(_x_x253, _x_x255, _ctx); /*string*/
  _x_x251 = kk_std_core_types__lp__plus__plus__rp_(_y_x10011, _x_x252, _ctx); /*string*/
  return kk_std_core_types__lp__plus__plus__rp_(_x_x249, _x_x251, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs__mlift_show_10041_fun264__t {
  struct kk_function_s _base;
  kk_string_t _y_x10011;
  kk_string_t _y_x10012;
};
static kk_box_t kk_std_core_tuple_tuple3_fs__mlift_show_10041_fun264(kk_function_t _fself, kk_box_t _b_x72, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs__new_mlift_show_10041_fun264(kk_string_t _y_x10011, kk_string_t _y_x10012, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs__mlift_show_10041_fun264__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs__mlift_show_10041_fun264__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs__mlift_show_10041_fun264, kk_context());
  _self->_y_x10011 = _y_x10011;
  _self->_y_x10012 = _y_x10012;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs__mlift_show_10041_fun264(kk_function_t _fself, kk_box_t _b_x72, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs__mlift_show_10041_fun264__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs__mlift_show_10041_fun264__t*, _fself, _ctx);
  kk_string_t _y_x10011 = _self->_y_x10011; /* string */
  kk_string_t _y_x10012 = _self->_y_x10012; /* string */
  kk_drop_match(_self, {kk_string_dup(_y_x10011, _ctx);kk_string_dup(_y_x10012, _ctx);}, {}, _ctx)
  kk_string_t _y_x10013_74 = kk_string_unbox(_b_x72); /*string*/;
  kk_string_t _x_x265 = kk_std_core_tuple_tuple3_fs__mlift_show_10040(_y_x10011, _y_x10012, _y_x10013_74, _ctx); /*string*/
  return kk_string_box(_x_x265);
}

kk_string_t kk_std_core_tuple_tuple3_fs__mlift_show_10041(kk_string_t _y_x10011, kk_std_core_types__tuple3 x, kk_function_t _implicit_fs_thd_fs_show, kk_string_t _y_x10012, kk_context_t* _ctx) { /* forall<a,b,c,e> (string, x : (a, b, c), ?thd/show : (c) -> e string, string) -> e string */ 
  kk_string_t x_0_10112;
  kk_box_t _x_x262;
  {
    kk_box_t _x_1 = x.thd;
    kk_box_dup(_x_1, _ctx);
    kk_std_core_types__tuple3_drop(x, _ctx);
    _x_x262 = _x_1; /*989*/
  }
  x_0_10112 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_thd_fs_show, (_implicit_fs_thd_fs_show, _x_x262, _ctx), _ctx); /*string*/
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_0_10112, _ctx);
    kk_box_t _x_x263 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs__new_mlift_show_10041_fun264(_y_x10011, _y_x10012, _ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x263);
  }
  {
    return kk_std_core_tuple_tuple3_fs__mlift_show_10040(_y_x10011, _y_x10012, x_0_10112, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs__mlift_show_10042_fun268__t {
  struct kk_function_s _base;
  kk_string_t _y_x10011;
  kk_std_core_types__tuple3 x;
  kk_function_t _implicit_fs_thd_fs_show;
};
static kk_box_t kk_std_core_tuple_tuple3_fs__mlift_show_10042_fun268(kk_function_t _fself, kk_box_t _b_x76, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs__new_mlift_show_10042_fun268(kk_string_t _y_x10011, kk_std_core_types__tuple3 x, kk_function_t _implicit_fs_thd_fs_show, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs__mlift_show_10042_fun268__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs__mlift_show_10042_fun268__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs__mlift_show_10042_fun268, kk_context());
  _self->_y_x10011 = _y_x10011;
  _self->x = x;
  _self->_implicit_fs_thd_fs_show = _implicit_fs_thd_fs_show;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs__mlift_show_10042_fun268(kk_function_t _fself, kk_box_t _b_x76, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs__mlift_show_10042_fun268__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs__mlift_show_10042_fun268__t*, _fself, _ctx);
  kk_string_t _y_x10011 = _self->_y_x10011; /* string */
  kk_std_core_types__tuple3 x = _self->x; /* (987, 988, 989) */
  kk_function_t _implicit_fs_thd_fs_show = _self->_implicit_fs_thd_fs_show; /* (989) -> 990 string */
  kk_drop_match(_self, {kk_string_dup(_y_x10011, _ctx);kk_std_core_types__tuple3_dup(x, _ctx);kk_function_dup(_implicit_fs_thd_fs_show, _ctx);}, {}, _ctx)
  kk_string_t _y_x10012_78 = kk_string_unbox(_b_x76); /*string*/;
  kk_string_t _x_x269 = kk_std_core_tuple_tuple3_fs__mlift_show_10041(_y_x10011, x, _implicit_fs_thd_fs_show, _y_x10012_78, _ctx); /*string*/
  return kk_string_box(_x_x269);
}

kk_string_t kk_std_core_tuple_tuple3_fs__mlift_show_10042(kk_std_core_types__tuple3 x, kk_function_t _implicit_fs_snd_fs_show, kk_function_t _implicit_fs_thd_fs_show, kk_string_t _y_x10011, kk_context_t* _ctx) { /* forall<a,b,c,e> (x : (a, b, c), ?snd/show : (b) -> e string, ?thd/show : (c) -> e string, string) -> e string */ 
  kk_string_t x_0_10114;
  kk_box_t _x_x266;
  {
    kk_box_t _x_0 = x.snd;
    kk_box_dup(_x_0, _ctx);
    _x_x266 = _x_0; /*988*/
  }
  x_0_10114 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_snd_fs_show, (_implicit_fs_snd_fs_show, _x_x266, _ctx), _ctx); /*string*/
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_0_10114, _ctx);
    kk_box_t _x_x267 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs__new_mlift_show_10042_fun268(_y_x10011, x, _implicit_fs_thd_fs_show, _ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x267);
  }
  {
    return kk_std_core_tuple_tuple3_fs__mlift_show_10041(_y_x10011, x, _implicit_fs_thd_fs_show, x_0_10114, _ctx);
  }
}
 
// Show a triple


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs_show_fun272__t {
  struct kk_function_s _base;
  kk_std_core_types__tuple3 x;
  kk_function_t _implicit_fs_snd_fs_show;
  kk_function_t _implicit_fs_thd_fs_show;
};
static kk_box_t kk_std_core_tuple_tuple3_fs_show_fun272(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs_new_show_fun272(kk_std_core_types__tuple3 x, kk_function_t _implicit_fs_snd_fs_show, kk_function_t _implicit_fs_thd_fs_show, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_show_fun272__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs_show_fun272__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs_show_fun272, kk_context());
  _self->x = x;
  _self->_implicit_fs_snd_fs_show = _implicit_fs_snd_fs_show;
  _self->_implicit_fs_thd_fs_show = _implicit_fs_thd_fs_show;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs_show_fun272(kk_function_t _fself, kk_box_t _b_x80, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_show_fun272__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs_show_fun272__t*, _fself, _ctx);
  kk_std_core_types__tuple3 x = _self->x; /* (987, 988, 989) */
  kk_function_t _implicit_fs_snd_fs_show = _self->_implicit_fs_snd_fs_show; /* (988) -> 990 string */
  kk_function_t _implicit_fs_thd_fs_show = _self->_implicit_fs_thd_fs_show; /* (989) -> 990 string */
  kk_drop_match(_self, {kk_std_core_types__tuple3_dup(x, _ctx);kk_function_dup(_implicit_fs_snd_fs_show, _ctx);kk_function_dup(_implicit_fs_thd_fs_show, _ctx);}, {}, _ctx)
  kk_string_t _y_x10011_88 = kk_string_unbox(_b_x80); /*string*/;
  kk_string_t _x_x273 = kk_std_core_tuple_tuple3_fs__mlift_show_10042(x, _implicit_fs_snd_fs_show, _implicit_fs_thd_fs_show, _y_x10011_88, _ctx); /*string*/
  return kk_string_box(_x_x273);
}


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs_show_fun276__t {
  struct kk_function_s _base;
  kk_std_core_types__tuple3 x;
  kk_string_t x_0_10116;
  kk_function_t _implicit_fs_thd_fs_show;
};
static kk_box_t kk_std_core_tuple_tuple3_fs_show_fun276(kk_function_t _fself, kk_box_t _b_x82, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs_new_show_fun276(kk_std_core_types__tuple3 x, kk_string_t x_0_10116, kk_function_t _implicit_fs_thd_fs_show, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_show_fun276__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs_show_fun276__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs_show_fun276, kk_context());
  _self->x = x;
  _self->x_0_10116 = x_0_10116;
  _self->_implicit_fs_thd_fs_show = _implicit_fs_thd_fs_show;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs_show_fun276(kk_function_t _fself, kk_box_t _b_x82, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_show_fun276__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs_show_fun276__t*, _fself, _ctx);
  kk_std_core_types__tuple3 x = _self->x; /* (987, 988, 989) */
  kk_string_t x_0_10116 = _self->x_0_10116; /* string */
  kk_function_t _implicit_fs_thd_fs_show = _self->_implicit_fs_thd_fs_show; /* (989) -> 990 string */
  kk_drop_match(_self, {kk_std_core_types__tuple3_dup(x, _ctx);kk_string_dup(x_0_10116, _ctx);kk_function_dup(_implicit_fs_thd_fs_show, _ctx);}, {}, _ctx)
  kk_string_t _y_x10012_89 = kk_string_unbox(_b_x82); /*string*/;
  kk_string_t _x_x277 = kk_std_core_tuple_tuple3_fs__mlift_show_10041(x_0_10116, x, _implicit_fs_thd_fs_show, _y_x10012_89, _ctx); /*string*/
  return kk_string_box(_x_x277);
}


// lift anonymous function
struct kk_std_core_tuple_tuple3_fs_show_fun280__t {
  struct kk_function_s _base;
  kk_string_t x_0_10116;
  kk_string_t x_1_10119;
};
static kk_box_t kk_std_core_tuple_tuple3_fs_show_fun280(kk_function_t _fself, kk_box_t _b_x84, kk_context_t* _ctx);
static kk_function_t kk_std_core_tuple_tuple3_fs_new_show_fun280(kk_string_t x_0_10116, kk_string_t x_1_10119, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_show_fun280__t* _self = kk_function_alloc_as(struct kk_std_core_tuple_tuple3_fs_show_fun280__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_tuple_tuple3_fs_show_fun280, kk_context());
  _self->x_0_10116 = x_0_10116;
  _self->x_1_10119 = x_1_10119;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_tuple_tuple3_fs_show_fun280(kk_function_t _fself, kk_box_t _b_x84, kk_context_t* _ctx) {
  struct kk_std_core_tuple_tuple3_fs_show_fun280__t* _self = kk_function_as(struct kk_std_core_tuple_tuple3_fs_show_fun280__t*, _fself, _ctx);
  kk_string_t x_0_10116 = _self->x_0_10116; /* string */
  kk_string_t x_1_10119 = _self->x_1_10119; /* string */
  kk_drop_match(_self, {kk_string_dup(x_0_10116, _ctx);kk_string_dup(x_1_10119, _ctx);}, {}, _ctx)
  kk_string_t _y_x10013_90 = kk_string_unbox(_b_x84); /*string*/;
  kk_string_t _x_x281 = kk_std_core_tuple_tuple3_fs__mlift_show_10040(x_0_10116, x_1_10119, _y_x10013_90, _ctx); /*string*/
  return kk_string_box(_x_x281);
}

kk_string_t kk_std_core_tuple_tuple3_fs_show(kk_std_core_types__tuple3 x, kk_function_t _implicit_fs_fst_fs_show, kk_function_t _implicit_fs_snd_fs_show, kk_function_t _implicit_fs_thd_fs_show, kk_context_t* _ctx) { /* forall<a,b,c,e> (x : (a, b, c), ?fst/show : (a) -> e string, ?snd/show : (b) -> e string, ?thd/show : (c) -> e string) -> e string */ 
  kk_string_t x_0_10116;
  kk_box_t _x_x270;
  {
    kk_box_t _x = x.fst;
    kk_box_dup(_x, _ctx);
    _x_x270 = _x; /*987*/
  }
  x_0_10116 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_fst_fs_show, (_implicit_fs_fst_fs_show, _x_x270, _ctx), _ctx); /*string*/
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_0_10116, _ctx);
    kk_box_t _x_x271 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs_new_show_fun272(x, _implicit_fs_snd_fs_show, _implicit_fs_thd_fs_show, _ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x271);
  }
  {
    kk_string_t x_1_10119;
    kk_box_t _x_x274;
    {
      kk_box_t _x_0 = x.snd;
      kk_box_dup(_x_0, _ctx);
      _x_x274 = _x_0; /*988*/
    }
    x_1_10119 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_snd_fs_show, (_implicit_fs_snd_fs_show, _x_x274, _ctx), _ctx); /*string*/
    if (kk_yielding(kk_context())) {
      kk_string_drop(x_1_10119, _ctx);
      kk_box_t _x_x275 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs_new_show_fun276(x, x_0_10116, _implicit_fs_thd_fs_show, _ctx), _ctx); /*3728*/
      return kk_string_unbox(_x_x275);
    }
    {
      kk_string_t x_2_10122;
      kk_box_t _x_x278;
      {
        kk_box_t _x_1 = x.thd;
        kk_box_dup(_x_1, _ctx);
        kk_std_core_types__tuple3_drop(x, _ctx);
        _x_x278 = _x_1; /*989*/
      }
      x_2_10122 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_thd_fs_show, (_implicit_fs_thd_fs_show, _x_x278, _ctx), _ctx); /*string*/
      if (kk_yielding(kk_context())) {
        kk_string_drop(x_2_10122, _ctx);
        kk_box_t _x_x279 = kk_std_core_hnd_yield_extend(kk_std_core_tuple_tuple3_fs_new_show_fun280(x_0_10116, x_1_10119, _ctx), _ctx); /*3728*/
        return kk_string_unbox(_x_x279);
      }
      {
        kk_string_t _x_x282;
        kk_define_string_literal(, _s_x283, 1, "(", _ctx)
        _x_x282 = kk_string_dup(_s_x283, _ctx); /*string*/
        kk_string_t _x_x284;
        kk_string_t _x_x285;
        kk_string_t _x_x286;
        kk_define_string_literal(, _s_x287, 1, ",", _ctx)
        _x_x286 = kk_string_dup(_s_x287, _ctx); /*string*/
        kk_string_t _x_x288;
        kk_string_t _x_x289;
        kk_string_t _x_x290;
        kk_define_string_literal(, _s_x291, 1, ",", _ctx)
        _x_x290 = kk_string_dup(_s_x291, _ctx); /*string*/
        kk_string_t _x_x292;
        kk_string_t _x_x293;
        kk_define_string_literal(, _s_x294, 1, ")", _ctx)
        _x_x293 = kk_string_dup(_s_x294, _ctx); /*string*/
        _x_x292 = kk_std_core_types__lp__plus__plus__rp_(x_2_10122, _x_x293, _ctx); /*string*/
        _x_x289 = kk_std_core_types__lp__plus__plus__rp_(_x_x290, _x_x292, _ctx); /*string*/
        _x_x288 = kk_std_core_types__lp__plus__plus__rp_(x_1_10119, _x_x289, _ctx); /*string*/
        _x_x285 = kk_std_core_types__lp__plus__plus__rp_(_x_x286, _x_x288, _ctx); /*string*/
        _x_x284 = kk_std_core_types__lp__plus__plus__rp_(x_0_10116, _x_x285, _ctx); /*string*/
        return kk_std_core_types__lp__plus__plus__rp_(_x_x282, _x_x284, _ctx);
      }
    }
  }
}
 
// Element-wise tuple equality

bool kk_std_core_tuple_tuple2_fs__lp__eq__eq__rp_(kk_std_core_types__tuple2 _pat_x29__22, kk_std_core_types__tuple2 _pat_x29__39, kk_function_t _implicit_fs_fst_fs__lp__eq__eq__rp_, kk_function_t _implicit_fs_snd_fs__lp__eq__eq__rp_, kk_context_t* _ctx) { /* forall<a,b> ((a, b), (a, b), ?fst/(==) : (a, a) -> bool, ?snd/(==) : (b, b) -> bool) -> bool */ 
  {
    kk_box_t x1 = _pat_x29__22.fst;
    kk_box_t y1 = _pat_x29__22.snd;
    {
      kk_box_t x2 = _pat_x29__39.fst;
      kk_box_t y2 = _pat_x29__39.snd;
      bool _match_x96 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_fst_fs__lp__eq__eq__rp_, (_implicit_fs_fst_fs__lp__eq__eq__rp_, x1, x2, _ctx), _ctx); /*bool*/;
      if (_match_x96) {
        return kk_function_call(bool, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_snd_fs__lp__eq__eq__rp_, (_implicit_fs_snd_fs__lp__eq__eq__rp_, y1, y2, _ctx), _ctx);
      }
      {
        kk_function_drop(_implicit_fs_snd_fs__lp__eq__eq__rp_, _ctx);
        kk_box_drop(y2, _ctx);
        kk_box_drop(y1, _ctx);
        return false;
      }
    }
  }
}
 
// Element-wise triple equality

bool kk_std_core_tuple_tuple3_fs__lp__eq__eq__rp_(kk_std_core_types__tuple3 _pat_x33__22, kk_std_core_types__tuple3 _pat_x33__44, kk_function_t _implicit_fs_fst_fs__lp__eq__eq__rp_, kk_function_t _implicit_fs_snd_fs__lp__eq__eq__rp_, kk_function_t _implicit_fs_thd_fs__lp__eq__eq__rp_, kk_context_t* _ctx) { /* forall<a,b,c> ((a, b, c), (a, b, c), ?fst/(==) : (a, a) -> bool, ?snd/(==) : (b, b) -> bool, ?thd/(==) : (c, c) -> bool) -> bool */ 
  {
    kk_box_t x1 = _pat_x33__22.fst;
    kk_box_t y1 = _pat_x33__22.snd;
    kk_box_t z1 = _pat_x33__22.thd;
    {
      kk_box_t x2 = _pat_x33__44.fst;
      kk_box_t y2 = _pat_x33__44.snd;
      kk_box_t z2 = _pat_x33__44.thd;
      bool _match_x94 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_fst_fs__lp__eq__eq__rp_, (_implicit_fs_fst_fs__lp__eq__eq__rp_, x1, x2, _ctx), _ctx); /*bool*/;
      if (_match_x94) {
        bool _match_x95 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_snd_fs__lp__eq__eq__rp_, (_implicit_fs_snd_fs__lp__eq__eq__rp_, y1, y2, _ctx), _ctx); /*bool*/;
        if (_match_x95) {
          return kk_function_call(bool, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_thd_fs__lp__eq__eq__rp_, (_implicit_fs_thd_fs__lp__eq__eq__rp_, z1, z2, _ctx), _ctx);
        }
        {
          kk_function_drop(_implicit_fs_thd_fs__lp__eq__eq__rp_, _ctx);
          kk_box_drop(z2, _ctx);
          kk_box_drop(z1, _ctx);
          return false;
        }
      }
      {
        kk_function_drop(_implicit_fs_thd_fs__lp__eq__eq__rp_, _ctx);
        kk_function_drop(_implicit_fs_snd_fs__lp__eq__eq__rp_, _ctx);
        kk_box_drop(z2, _ctx);
        kk_box_drop(z1, _ctx);
        kk_box_drop(y2, _ctx);
        kk_box_drop(y1, _ctx);
        return false;
      }
    }
  }
}
 
// Order on tuples

kk_std_core_types__order kk_std_core_tuple_tuple2_fs_cmp(kk_std_core_types__tuple2 _pat_x38__21, kk_std_core_types__tuple2 _pat_x38__38, kk_function_t _implicit_fs_fst_fs_cmp, kk_function_t _implicit_fs_snd_fs_cmp, kk_context_t* _ctx) { /* forall<a,b> ((a, b), (a, b), ?fst/cmp : (a, a) -> order, ?snd/cmp : (b, b) -> order) -> order */ 
  {
    kk_box_t x1 = _pat_x38__21.fst;
    kk_box_t y1 = _pat_x38__21.snd;
    {
      kk_box_t x2 = _pat_x38__38.fst;
      kk_box_t y2 = _pat_x38__38.snd;
      kk_std_core_types__order _match_x93 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_fst_fs_cmp, (_implicit_fs_fst_fs_cmp, x1, x2, _ctx), _ctx); /*order*/;
      if (kk_std_core_types__is_Eq(_match_x93, _ctx)) {
        return kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _implicit_fs_snd_fs_cmp, (_implicit_fs_snd_fs_cmp, y1, y2, _ctx), _ctx);
      }
      {
        kk_function_drop(_implicit_fs_snd_fs_cmp, _ctx);
        kk_box_drop(y2, _ctx);
        kk_box_drop(y1, _ctx);
        return _match_x93;
      }
    }
  }
}
 
// Order on triples

kk_std_core_types__order kk_std_core_tuple_tuple3_fs_cmp(kk_std_core_types__tuple3 _pat_x44__26, kk_std_core_types__tuple3 _pat_x44__48, kk_function_t _implicit_fs_fst_fs_cmp, kk_function_t _implicit_fs_snd_fs_cmp, kk_function_t _implicit_fs_thd_fs_cmp, kk_context_t* _ctx) { /* forall<a,b,c> ((a, b, c), (a, b, c), ?fst/cmp : (a, a) -> order, ?snd/cmp : (b, b) -> order, ?thd/cmp : (c, c) -> order) -> order */ 
  {
    kk_box_t x1 = _pat_x44__26.fst;
    kk_box_t y1 = _pat_x44__26.snd;
    kk_box_t z1 = _pat_x44__26.thd;
    {
      kk_box_t x2 = _pat_x44__48.fst;
      kk_box_t y2 = _pat_x44__48.snd;
      kk_box_t z2 = _pat_x44__48.thd;
      kk_std_core_types__order _match_x91;
      kk_function_t _x_x295 = kk_function_dup(_implicit_fs_fst_fs_cmp, _ctx); /*(1320, 1320) -> order*/
      _match_x91 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x295, (_x_x295, x1, x2, _ctx), _ctx); /*order*/
      if (kk_std_core_types__is_Eq(_match_x91, _ctx)) {
        kk_std_core_types__order _match_x92;
        kk_function_t _x_x296 = kk_function_dup(_implicit_fs_snd_fs_cmp, _ctx); /*(1321, 1321) -> order*/
        _match_x92 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x296, (_x_x296, y1, y2, _ctx), _ctx); /*order*/
        if (kk_std_core_types__is_Eq(_match_x92, _ctx)) {
          kk_function_t _x_x297 = kk_function_dup(_implicit_fs_thd_fs_cmp, _ctx); /*(1322, 1322) -> order*/
          return kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x297, (_x_x297, z1, z2, _ctx), _ctx);
        }
        {
          kk_box_drop(z2, _ctx);
          kk_box_drop(z1, _ctx);
          return _match_x92;
        }
      }
      {
        kk_box_drop(z2, _ctx);
        kk_box_drop(z1, _ctx);
        kk_box_drop(y2, _ctx);
        kk_box_drop(y1, _ctx);
        return _match_x91;
      }
    }
  }
}

// initialization
void kk_std_core_tuple__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_hnd__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_tuple__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_hnd__done(_ctx);
  kk_std_core_types__done(_ctx);
}
