// Koka generated module: std/core/list, koka version: 3.1.2, platform: 64-bit
#include "std_core_list.h"
 
// lifted local: concat, concat-pre

kk_std_core_types__list kk_std_core_list__trmc_lift_concat_4788(kk_std_core_types__list ys, kk_std_core_types__list zss, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* forall<a> (ys : list<a>, zss : list<list<a>>, ctx<list<a>>) -> list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1113 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t y = _con_x1113->head;
    kk_std_core_types__list yy = _con_x1113->tail;
    kk_reuse_t _ru_x1047 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      _ru_x1047 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(y, _ctx);
      kk_std_core_types__list_dup(yy, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_std_core_types__list _trmc_x10076 = kk_datatype_null(); /*list<614>*/;
    kk_std_core_types__list _trmc_x10077 = kk_std_core_types__new_Cons(_ru_x1047, 0, y, _trmc_x10076, _ctx); /*list<614>*/;
    kk_field_addr_t _b_x5_11 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10077, _ctx)->tail, _ctx); /*@field-addr<list<614>>*/;
    { // tailcall
      kk_std_core_types__cctx _x_x1114 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10077, _ctx)),_b_x5_11,kk_context()); /*ctx<0>*/
      ys = yy;
      _acc = _x_x1114;
      goto kk__tailcall;
    }
  }
  if (kk_std_core_types__is_Cons(zss, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1115 = kk_std_core_types__as_Cons(zss, _ctx);
    kk_box_t _box_x6 = _con_x1115->head;
    kk_std_core_types__list zzs = _con_x1115->tail;
    kk_std_core_types__list zs = kk_std_core_types__list_unbox(_box_x6, KK_BORROWED, _ctx);
    if kk_likely(kk_datatype_ptr_is_unique(zss, _ctx)) {
      kk_datatype_ptr_free(zss, _ctx);
    }
    else {
      kk_std_core_types__list_dup(zs, _ctx);
      kk_std_core_types__list_dup(zzs, _ctx);
      kk_datatype_ptr_decref(zss, _ctx);
    }
    { // tailcall
      ys = zs;
      zss = zzs;
      goto kk__tailcall;
    }
  }
  {
    kk_box_t _x_x1116 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1116, KK_OWNED, _ctx);
  }
}
 
// lifted local: concat, concat-pre

kk_std_core_types__list kk_std_core_list__lift_concat_4788(kk_std_core_types__list ys_0, kk_std_core_types__list zss_0, kk_context_t* _ctx) { /* forall<a> (ys : list<a>, zss : list<list<a>>) -> list<a> */ 
  kk_std_core_types__cctx _x_x1117 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_concat_4788(ys_0, zss_0, _x_x1117, _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_lift_flatmap_4789_10298(kk_std_core_types__cctx _acc, kk_function_t f, kk_std_core_types__list zz, kk_std_core_types__list ys_1_10002, kk_context_t* _ctx) { /* forall<a,b,e> (ctx<list<b>>, f : (a) -> e list<b>, zz : list<a>, ys@1@10002 : list<b>) -> e list<b> */ 
  return kk_std_core_list__trmc_lift_flatmap_4789(f, ys_1_10002, zz, _acc, _ctx);
}
 
// lifted local: flatmap, flatmap-pre


// lift anonymous function
struct kk_std_core_list__trmc_lift_flatmap_4789_fun1123__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_std_core_types__list zz_0;
};
static kk_box_t kk_std_core_list__trmc_lift_flatmap_4789_fun1123(kk_function_t _fself, kk_box_t _b_x24, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_lift_flatmap_4789_fun1123(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_std_core_types__list zz_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_flatmap_4789_fun1123__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_lift_flatmap_4789_fun1123__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_lift_flatmap_4789_fun1123, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->zz_0 = zz_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_lift_flatmap_4789_fun1123(kk_function_t _fself, kk_box_t _b_x24, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_flatmap_4789_fun1123__t* _self = kk_function_as(struct kk_std_core_list__trmc_lift_flatmap_4789_fun1123__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<690>> */
  kk_function_t f_0 = _self->f_0; /* (689) -> 691 list<690> */
  kk_std_core_types__list zz_0 = _self->zz_0; /* list<689> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_std_core_types__list_dup(zz_0, _ctx);}, {}, _ctx)
  kk_std_core_types__list ys_1_10002_0_36 = kk_std_core_types__list_unbox(_b_x24, KK_OWNED, _ctx); /*list<690>*/;
  kk_std_core_types__list _x_x1124 = kk_std_core_list__mlift_trmc_lift_flatmap_4789_10298(_acc_0, f_0, zz_0, ys_1_10002_0_36, _ctx); /*list<690>*/
  return kk_std_core_types__list_box(_x_x1124, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_lift_flatmap_4789(kk_function_t f_0, kk_std_core_types__list ys, kk_std_core_types__list zs, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,e> (f : (a) -> e list<b>, ys : list<b>, zs : list<a>, ctx<list<b>>) -> e list<b> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1118 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t y = _con_x1118->head;
    kk_std_core_types__list yy = _con_x1118->tail;
    kk_reuse_t _ru_x1049 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      _ru_x1049 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(y, _ctx);
      kk_std_core_types__list_dup(yy, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_std_core_types__list _trmc_x10078 = kk_datatype_null(); /*list<690>*/;
    kk_std_core_types__list _trmc_x10079 = kk_std_core_types__new_Cons(_ru_x1049, kk_field_index_of(struct kk_std_core_types_Cons, tail), y, _trmc_x10078, _ctx); /*list<690>*/;
    kk_field_addr_t _b_x22_29 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10079, _ctx)->tail, _ctx); /*@field-addr<list<690>>*/;
    { // tailcall
      kk_std_core_types__cctx _x_x1119 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10079, _ctx)),_b_x22_29,kk_context()); /*ctx<0>*/
      ys = yy;
      _acc_0 = _x_x1119;
      goto kk__tailcall;
    }
  }
  if (kk_std_core_types__is_Cons(zs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1120 = kk_std_core_types__as_Cons(zs, _ctx);
    kk_box_t z = _con_x1120->head;
    kk_std_core_types__list zz_0 = _con_x1120->tail;
    if kk_likely(kk_datatype_ptr_is_unique(zs, _ctx)) {
      kk_datatype_ptr_free(zs, _ctx);
    }
    else {
      kk_box_dup(z, _ctx);
      kk_std_core_types__list_dup(zz_0, _ctx);
      kk_datatype_ptr_decref(zs, _ctx);
    }
    kk_std_core_types__list x_10328;
    kk_function_t _x_x1121 = kk_function_dup(f_0, _ctx); /*(689) -> 691 list<690>*/
    x_10328 = kk_function_call(kk_std_core_types__list, (kk_function_t, kk_box_t, kk_context_t*), _x_x1121, (_x_x1121, z, _ctx), _ctx); /*list<690>*/
    if (kk_yielding(kk_context())) {
      kk_std_core_types__list_drop(x_10328, _ctx);
      kk_box_t _x_x1122 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_lift_flatmap_4789_fun1123(_acc_0, f_0, zz_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1122, KK_OWNED, _ctx);
    }
    { // tailcall
      ys = x_10328;
      zs = zz_0;
      goto kk__tailcall;
    }
  }
  {
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1125 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1125, KK_OWNED, _ctx);
  }
}
 
// lifted local: flatmap, flatmap-pre

kk_std_core_types__list kk_std_core_list__lift_flatmap_4789(kk_function_t f_1, kk_std_core_types__list ys_0, kk_std_core_types__list zs_0, kk_context_t* _ctx) { /* forall<a,b,e> (f : (a) -> e list<b>, ys : list<b>, zs : list<a>) -> e list<b> */ 
  kk_std_core_types__cctx _x_x1126 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_flatmap_4789(f_1, ys_0, zs_0, _x_x1126, _ctx);
}
 
// lifted local: reverse-append, reverse-acc

kk_std_core_types__list kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__list acc, kk_std_core_types__list ys, kk_context_t* _ctx) { /* forall<a> (acc : list<a>, ys : list<a>) -> list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1127 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t x = _con_x1127->head;
    kk_std_core_types__list xx = _con_x1127->tail;
    kk_reuse_t _ru_x1051 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      _ru_x1051 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    { // tailcall
      kk_std_core_types__list _x_x1128 = kk_std_core_types__new_Cons(_ru_x1051, 0, x, acc, _ctx); /*list<82>*/
      acc = _x_x1128;
      ys = xx;
      goto kk__tailcall;
    }
  }
  {
    return acc;
  }
}
 
// Return the head of list if the list is not empty.

kk_std_core_types__maybe kk_std_core_list_head(kk_std_core_types__list xs, kk_context_t* _ctx) { /* forall<a> (xs : list<a>) -> maybe<a> */ 
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1129 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1129->head;
    kk_std_core_types__list _pat_0 = _con_x1129->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_std_core_types__list_drop(_pat_0, _ctx);
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    return kk_std_core_types__new_Just(x, _ctx);
  }
  {
    return kk_std_core_types__new_Nothing(_ctx);
  }
}
 
// lifted local: intersperse, before

kk_std_core_types__list kk_std_core_list__trmc_lift_intersperse_4791(kk_box_t sep, kk_std_core_types__list ys, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* forall<a> (sep : a, ys : list<a>, ctx<list<a>>) -> list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1130 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t y = _con_x1130->head;
    kk_std_core_types__list yy = _con_x1130->tail;
    kk_reuse_t _ru_x1053 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      _ru_x1053 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(y, _ctx);
      kk_std_core_types__list_dup(yy, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_std_core_types__list _trmc_x10080;
    kk_std_core_types__list _x_x1131 = kk_datatype_null(); /*list<836>*/
    _trmc_x10080 = kk_std_core_types__new_Cons(_ru_x1053, 0, y, _x_x1131, _ctx); /*list<836>*/
    kk_field_addr_t _b_x42_47 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10080, _ctx)->tail, _ctx); /*@field-addr<list<836>>*/;
    { // tailcall
      kk_box_t _x_x1132 = kk_box_dup(sep, _ctx); /*836*/
      kk_std_core_types__cctx _x_x1133;
      kk_box_t _x_x1134;
      kk_std_core_types__list _x_x1135 = kk_std_core_types__new_Cons(kk_reuse_null, 0, sep, _trmc_x10080, _ctx); /*list<82>*/
      _x_x1134 = kk_std_core_types__list_box(_x_x1135, _ctx); /*0*/
      _x_x1133 = kk_cctx_extend_linear(_acc,_x_x1134,_b_x42_47,kk_context()); /*ctx<0>*/
      sep = _x_x1132;
      ys = yy;
      _acc = _x_x1133;
      goto kk__tailcall;
    }
  }
  {
    kk_box_drop(sep, _ctx);
    kk_box_t _x_x1136 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1136, KK_OWNED, _ctx);
  }
}
 
// lifted local: intersperse, before

kk_std_core_types__list kk_std_core_list__lift_intersperse_4791(kk_box_t sep_0, kk_std_core_types__list ys_0, kk_context_t* _ctx) { /* forall<a> (sep : a, ys : list<a>) -> list<a> */ 
  kk_std_core_types__cctx _x_x1137 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_intersperse_4791(sep_0, ys_0, _x_x1137, _ctx);
}
 
// Insert a separator `sep`  between all elements of a list `xs` .

kk_std_core_types__list kk_std_core_list_intersperse(kk_std_core_types__list xs, kk_box_t sep, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, sep : a) -> list<a> */ 
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1138 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1138->head;
    kk_std_core_types__list xx = _con_x1138->tail;
    kk_reuse_t _ru_x1054 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x1054 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_std_core_types__list _x_x1139 = kk_std_core_list__lift_intersperse_4791(sep, xx, _ctx); /*list<836>*/
    return kk_std_core_types__new_Cons(_ru_x1054, 0, x, _x_x1139, _ctx);
  }
  {
    kk_box_drop(sep, _ctx);
    return kk_std_core_types__new_Nil(_ctx);
  }
}
 
// lifted local: length, len

kk_integer_t kk_std_core_list__lift_length_4792(kk_std_core_types__list ys, kk_integer_t acc, kk_context_t* _ctx) { /* forall<a> (ys : list<a>, acc : int) -> int */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1140 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t _pat_0 = _con_x1140->head;
    kk_std_core_types__list yy = _con_x1140->tail;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      kk_box_drop(_pat_0, _ctx);
      kk_datatype_ptr_free(ys, _ctx);
    }
    else {
      kk_std_core_types__list_dup(yy, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    { // tailcall
      kk_integer_t _x_x1141 = kk_integer_add_small_const(acc, 1, _ctx); /*int*/
      ys = yy;
      acc = _x_x1141;
      goto kk__tailcall;
    }
  }
  {
    return acc;
  }
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_lift_map_indexed_4793_10299(kk_std_core_types__cctx _acc, kk_function_t f, kk_integer_t i_0_10009, kk_std_core_types__list yy, kk_box_t _trmc_x10082, kk_context_t* _ctx) { /* forall<a,b,e> (ctx<list<b>>, f : (idx : int, value : a) -> e b, i@0@10009 : int, yy : list<a>, b) -> e list<b> */ 
  kk_std_core_types__list _trmc_x10083 = kk_datatype_null(); /*list<979>*/;
  kk_std_core_types__list _trmc_x10084 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), _trmc_x10082, _trmc_x10083, _ctx); /*list<979>*/;
  kk_field_addr_t _b_x58_61 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10084, _ctx)->tail, _ctx); /*@field-addr<list<979>>*/;
  kk_std_core_types__cctx _x_x1142 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10084, _ctx)),_b_x58_61,kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_map_indexed_4793(f, yy, i_0_10009, _x_x1142, _ctx);
}
 
// lifted local: map-indexed, map-idx


// lift anonymous function
struct kk_std_core_list__trmc_lift_map_indexed_4793_fun1147__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_integer_t i_0_10009_0;
  kk_std_core_types__list yy_0;
};
static kk_box_t kk_std_core_list__trmc_lift_map_indexed_4793_fun1147(kk_function_t _fself, kk_box_t _b_x66, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_lift_map_indexed_4793_fun1147(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_integer_t i_0_10009_0, kk_std_core_types__list yy_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_map_indexed_4793_fun1147__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_lift_map_indexed_4793_fun1147__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_lift_map_indexed_4793_fun1147, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->i_0_10009_0 = i_0_10009_0;
  _self->yy_0 = yy_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_lift_map_indexed_4793_fun1147(kk_function_t _fself, kk_box_t _b_x66, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_map_indexed_4793_fun1147__t* _self = kk_function_as(struct kk_std_core_list__trmc_lift_map_indexed_4793_fun1147__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<979>> */
  kk_function_t f_0 = _self->f_0; /* (idx : int, value : 978) -> 980 979 */
  kk_integer_t i_0_10009_0 = _self->i_0_10009_0; /* int */
  kk_std_core_types__list yy_0 = _self->yy_0; /* list<978> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_integer_dup(i_0_10009_0, _ctx);kk_std_core_types__list_dup(yy_0, _ctx);}, {}, _ctx)
  kk_box_t _trmc_x10082_0_84 = _b_x66; /*979*/;
  kk_std_core_types__list _x_x1148 = kk_std_core_list__mlift_trmc_lift_map_indexed_4793_10299(_acc_0, f_0, i_0_10009_0, yy_0, _trmc_x10082_0_84, _ctx); /*list<979>*/
  return kk_std_core_types__list_box(_x_x1148, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_lift_map_indexed_4793(kk_function_t f_0, kk_std_core_types__list ys, kk_integer_t i, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,e> (f : (idx : int, value : a) -> e b, ys : list<a>, i : int, ctx<list<b>>) -> e list<b> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1143 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t y = _con_x1143->head;
    kk_std_core_types__list yy_0 = _con_x1143->tail;
    kk_reuse_t _ru_x1056 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      _ru_x1056 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(y, _ctx);
      kk_std_core_types__list_dup(yy_0, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_integer_t i_0_10009_0;
    kk_integer_t _x_x1144 = kk_integer_dup(i, _ctx); /*int*/
    i_0_10009_0 = kk_integer_add_small_const(_x_x1144, 1, _ctx); /*int*/
    kk_box_t x_10331;
    kk_function_t _x_x1145 = kk_function_dup(f_0, _ctx); /*(idx : int, value : 978) -> 980 979*/
    x_10331 = kk_function_call(kk_box_t, (kk_function_t, kk_integer_t, kk_box_t, kk_context_t*), _x_x1145, (_x_x1145, i, y, _ctx), _ctx); /*979*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1056,kk_context());
      kk_box_drop(x_10331, _ctx);
      kk_box_t _x_x1146 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_lift_map_indexed_4793_fun1147(_acc_0, f_0, i_0_10009_0, yy_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1146, KK_OWNED, _ctx);
    }
    {
      kk_std_core_types__list _trmc_x10083_0 = kk_datatype_null(); /*list<979>*/;
      kk_std_core_types__list _trmc_x10084_0 = kk_std_core_types__new_Cons(_ru_x1056, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_10331, _trmc_x10083_0, _ctx); /*list<979>*/;
      kk_field_addr_t _b_x72_78 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10084_0, _ctx)->tail, _ctx); /*@field-addr<list<979>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1149 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10084_0, _ctx)),_b_x72_78,kk_context()); /*ctx<0>*/
        ys = yy_0;
        i = i_0_10009_0;
        _acc_0 = _x_x1149;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_integer_drop(i, _ctx);
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1150 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1150, KK_OWNED, _ctx);
  }
}
 
// lifted local: map-indexed, map-idx

kk_std_core_types__list kk_std_core_list__lift_map_indexed_4793(kk_function_t f_1, kk_std_core_types__list ys_0, kk_integer_t i_0, kk_context_t* _ctx) { /* forall<a,b,e> (f : (idx : int, value : a) -> e b, ys : list<a>, i : int) -> e list<b> */ 
  kk_std_core_types__cctx _x_x1151 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_map_indexed_4793(f_1, ys_0, i_0, _x_x1151, _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_lift_map_indexed_peek_4794_10300(kk_std_core_types__cctx _acc, kk_function_t f, kk_integer_t i_0_10011, kk_std_core_types__list yy, kk_box_t _trmc_x10085, kk_context_t* _ctx) { /* forall<a,b,e> (ctx<list<b>>, f : (idx : int, value : a, rest : list<a>) -> e b, i@0@10011 : int, yy : list<a>, b) -> e list<b> */ 
  kk_std_core_types__list _trmc_x10086 = kk_datatype_null(); /*list<1041>*/;
  kk_std_core_types__list _trmc_x10087 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), _trmc_x10085, _trmc_x10086, _ctx); /*list<1041>*/;
  kk_field_addr_t _b_x90_93 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10087, _ctx)->tail, _ctx); /*@field-addr<list<1041>>*/;
  kk_std_core_types__cctx _x_x1152 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10087, _ctx)),_b_x90_93,kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_map_indexed_peek_4794(f, yy, i_0_10011, _x_x1152, _ctx);
}
 
// lifted local: map-indexed-peek, mapidx


// lift anonymous function
struct kk_std_core_list__trmc_lift_map_indexed_peek_4794_fun1158__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_integer_t i_0_10011_0;
  kk_std_core_types__list yy_0;
};
static kk_box_t kk_std_core_list__trmc_lift_map_indexed_peek_4794_fun1158(kk_function_t _fself, kk_box_t _b_x98, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_lift_map_indexed_peek_4794_fun1158(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_integer_t i_0_10011_0, kk_std_core_types__list yy_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_map_indexed_peek_4794_fun1158__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_lift_map_indexed_peek_4794_fun1158__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_lift_map_indexed_peek_4794_fun1158, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->i_0_10011_0 = i_0_10011_0;
  _self->yy_0 = yy_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_lift_map_indexed_peek_4794_fun1158(kk_function_t _fself, kk_box_t _b_x98, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_map_indexed_peek_4794_fun1158__t* _self = kk_function_as(struct kk_std_core_list__trmc_lift_map_indexed_peek_4794_fun1158__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<1041>> */
  kk_function_t f_0 = _self->f_0; /* (idx : int, value : 1040, rest : list<1040>) -> 1042 1041 */
  kk_integer_t i_0_10011_0 = _self->i_0_10011_0; /* int */
  kk_std_core_types__list yy_0 = _self->yy_0; /* list<1040> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_integer_dup(i_0_10011_0, _ctx);kk_std_core_types__list_dup(yy_0, _ctx);}, {}, _ctx)
  kk_box_t _trmc_x10085_0_116 = _b_x98; /*1041*/;
  kk_std_core_types__list _x_x1159 = kk_std_core_list__mlift_trmc_lift_map_indexed_peek_4794_10300(_acc_0, f_0, i_0_10011_0, yy_0, _trmc_x10085_0_116, _ctx); /*list<1041>*/
  return kk_std_core_types__list_box(_x_x1159, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_lift_map_indexed_peek_4794(kk_function_t f_0, kk_std_core_types__list ys, kk_integer_t i, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,e> (f : (idx : int, value : a, rest : list<a>) -> e b, ys : list<a>, i : int, ctx<list<b>>) -> e list<b> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1153 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t y = _con_x1153->head;
    kk_std_core_types__list yy_0 = _con_x1153->tail;
    kk_reuse_t _ru_x1057 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      _ru_x1057 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(y, _ctx);
      kk_std_core_types__list_dup(yy_0, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_integer_t i_0_10011_0;
    kk_integer_t _x_x1154 = kk_integer_dup(i, _ctx); /*int*/
    i_0_10011_0 = kk_integer_add_small_const(_x_x1154, 1, _ctx); /*int*/
    kk_box_t x_10334;
    kk_function_t _x_x1156 = kk_function_dup(f_0, _ctx); /*(idx : int, value : 1040, rest : list<1040>) -> 1042 1041*/
    kk_std_core_types__list _x_x1155 = kk_std_core_types__list_dup(yy_0, _ctx); /*list<1040>*/
    x_10334 = kk_function_call(kk_box_t, (kk_function_t, kk_integer_t, kk_box_t, kk_std_core_types__list, kk_context_t*), _x_x1156, (_x_x1156, i, y, _x_x1155, _ctx), _ctx); /*1041*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1057,kk_context());
      kk_box_drop(x_10334, _ctx);
      kk_box_t _x_x1157 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_lift_map_indexed_peek_4794_fun1158(_acc_0, f_0, i_0_10011_0, yy_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1157, KK_OWNED, _ctx);
    }
    {
      kk_std_core_types__list _trmc_x10086_0 = kk_datatype_null(); /*list<1041>*/;
      kk_std_core_types__list _trmc_x10087_0 = kk_std_core_types__new_Cons(_ru_x1057, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_10334, _trmc_x10086_0, _ctx); /*list<1041>*/;
      kk_field_addr_t _b_x104_110 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10087_0, _ctx)->tail, _ctx); /*@field-addr<list<1041>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1160 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10087_0, _ctx)),_b_x104_110,kk_context()); /*ctx<0>*/
        ys = yy_0;
        i = i_0_10011_0;
        _acc_0 = _x_x1160;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_integer_drop(i, _ctx);
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1161 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1161, KK_OWNED, _ctx);
  }
}
 
// lifted local: map-indexed-peek, mapidx

kk_std_core_types__list kk_std_core_list__lift_map_indexed_peek_4794(kk_function_t f_1, kk_std_core_types__list ys_0, kk_integer_t i_0, kk_context_t* _ctx) { /* forall<a,b,e> (f : (idx : int, value : a, rest : list<a>) -> e b, ys : list<a>, i : int) -> e list<b> */ 
  kk_std_core_types__cctx _x_x1162 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_map_indexed_peek_4794(f_1, ys_0, i_0, _x_x1162, _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_lift_map_peek_4795_10301(kk_std_core_types__cctx _acc, kk_function_t f, kk_std_core_types__list yy, kk_box_t _trmc_x10088, kk_context_t* _ctx) { /* forall<a,b,e> (ctx<list<b>>, f : (value : a, rest : list<a>) -> e b, yy : list<a>, b) -> e list<b> */ 
  kk_std_core_types__list _trmc_x10089 = kk_datatype_null(); /*list<1093>*/;
  kk_std_core_types__list _trmc_x10090 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), _trmc_x10088, _trmc_x10089, _ctx); /*list<1093>*/;
  kk_field_addr_t _b_x122_125 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10090, _ctx)->tail, _ctx); /*@field-addr<list<1093>>*/;
  kk_std_core_types__cctx _x_x1163 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10090, _ctx)),_b_x122_125,kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_map_peek_4795(f, yy, _x_x1163, _ctx);
}
 
// lifted local: map-peek, mappeek


// lift anonymous function
struct kk_std_core_list__trmc_lift_map_peek_4795_fun1168__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_std_core_types__list yy_0;
};
static kk_box_t kk_std_core_list__trmc_lift_map_peek_4795_fun1168(kk_function_t _fself, kk_box_t _b_x130, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_lift_map_peek_4795_fun1168(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_std_core_types__list yy_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_map_peek_4795_fun1168__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_lift_map_peek_4795_fun1168__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_lift_map_peek_4795_fun1168, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->yy_0 = yy_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_lift_map_peek_4795_fun1168(kk_function_t _fself, kk_box_t _b_x130, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_map_peek_4795_fun1168__t* _self = kk_function_as(struct kk_std_core_list__trmc_lift_map_peek_4795_fun1168__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<1093>> */
  kk_function_t f_0 = _self->f_0; /* (value : 1092, rest : list<1092>) -> 1094 1093 */
  kk_std_core_types__list yy_0 = _self->yy_0; /* list<1092> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_std_core_types__list_dup(yy_0, _ctx);}, {}, _ctx)
  kk_box_t _trmc_x10088_0_148 = _b_x130; /*1093*/;
  kk_std_core_types__list _x_x1169 = kk_std_core_list__mlift_trmc_lift_map_peek_4795_10301(_acc_0, f_0, yy_0, _trmc_x10088_0_148, _ctx); /*list<1093>*/
  return kk_std_core_types__list_box(_x_x1169, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_lift_map_peek_4795(kk_function_t f_0, kk_std_core_types__list ys, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,e> (f : (value : a, rest : list<a>) -> e b, ys : list<a>, ctx<list<b>>) -> e list<b> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1164 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t y = _con_x1164->head;
    kk_std_core_types__list yy_0 = _con_x1164->tail;
    kk_reuse_t _ru_x1058 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      _ru_x1058 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(y, _ctx);
      kk_std_core_types__list_dup(yy_0, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_box_t x_10337;
    kk_function_t _x_x1166 = kk_function_dup(f_0, _ctx); /*(value : 1092, rest : list<1092>) -> 1094 1093*/
    kk_std_core_types__list _x_x1165 = kk_std_core_types__list_dup(yy_0, _ctx); /*list<1092>*/
    x_10337 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_std_core_types__list, kk_context_t*), _x_x1166, (_x_x1166, y, _x_x1165, _ctx), _ctx); /*1093*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1058,kk_context());
      kk_box_drop(x_10337, _ctx);
      kk_box_t _x_x1167 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_lift_map_peek_4795_fun1168(_acc_0, f_0, yy_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1167, KK_OWNED, _ctx);
    }
    {
      kk_std_core_types__list _trmc_x10089_0 = kk_datatype_null(); /*list<1093>*/;
      kk_std_core_types__list _trmc_x10090_0 = kk_std_core_types__new_Cons(_ru_x1058, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_10337, _trmc_x10089_0, _ctx); /*list<1093>*/;
      kk_field_addr_t _b_x136_142 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10090_0, _ctx)->tail, _ctx); /*@field-addr<list<1093>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1170 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10090_0, _ctx)),_b_x136_142,kk_context()); /*ctx<0>*/
        ys = yy_0;
        _acc_0 = _x_x1170;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1171 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1171, KK_OWNED, _ctx);
  }
}
 
// lifted local: map-peek, mappeek

kk_std_core_types__list kk_std_core_list__lift_map_peek_4795(kk_function_t f_1, kk_std_core_types__list ys_0, kk_context_t* _ctx) { /* forall<a,b,e> (f : (value : a, rest : list<a>) -> e b, ys : list<a>) -> e list<b> */ 
  kk_std_core_types__cctx _x_x1172 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_map_peek_4795(f_1, ys_0, _x_x1172, _ctx);
}
 
// Return the tail of list. Returns the empty list if `xs` is empty.

kk_std_core_types__list kk_std_core_list_tail(kk_std_core_types__list xs, kk_context_t* _ctx) { /* forall<a> (xs : list<a>) -> list<a> */ 
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1173 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _pat_0 = _con_x1173->head;
    kk_std_core_types__list xx = _con_x1173->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_box_drop(_pat_0, _ctx);
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    return xx;
  }
  {
    return kk_std_core_types__new_Nil(_ctx);
  }
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_lift_zipwith_indexed_4796_10302(kk_std_core_types__cctx _acc, kk_function_t f, kk_integer_t i_0_10013, kk_std_core_types__list xx, kk_std_core_types__list yy, kk_box_t _trmc_x10091, kk_context_t* _ctx) { /* forall<a,b,c,e> (ctx<list<c>>, f : (int, a, b) -> e c, i@0@10013 : int, xx : list<a>, yy : list<b>, c) -> e list<c> */ 
  kk_std_core_types__list _trmc_x10092 = kk_datatype_null(); /*list<1211>*/;
  kk_std_core_types__list _trmc_x10093 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), _trmc_x10091, _trmc_x10092, _ctx); /*list<1211>*/;
  kk_field_addr_t _b_x154_157 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10093, _ctx)->tail, _ctx); /*@field-addr<list<1211>>*/;
  kk_std_core_types__cctx _x_x1174 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10093, _ctx)),_b_x154_157,kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_zipwith_indexed_4796(f, i_0_10013, xx, yy, _x_x1174, _ctx);
}
 
// lifted local: zipwith-indexed, zipwith-iter


// lift anonymous function
struct kk_std_core_list__trmc_lift_zipwith_indexed_4796_fun1180__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_integer_t i_0_10013_0;
  kk_std_core_types__list xx_0;
  kk_std_core_types__list yy_0;
};
static kk_box_t kk_std_core_list__trmc_lift_zipwith_indexed_4796_fun1180(kk_function_t _fself, kk_box_t _b_x162, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_lift_zipwith_indexed_4796_fun1180(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_integer_t i_0_10013_0, kk_std_core_types__list xx_0, kk_std_core_types__list yy_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_zipwith_indexed_4796_fun1180__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_lift_zipwith_indexed_4796_fun1180__t, 7, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_lift_zipwith_indexed_4796_fun1180, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->i_0_10013_0 = i_0_10013_0;
  _self->xx_0 = xx_0;
  _self->yy_0 = yy_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_lift_zipwith_indexed_4796_fun1180(kk_function_t _fself, kk_box_t _b_x162, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_lift_zipwith_indexed_4796_fun1180__t* _self = kk_function_as(struct kk_std_core_list__trmc_lift_zipwith_indexed_4796_fun1180__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<1211>> */
  kk_function_t f_0 = _self->f_0; /* (int, 1209, 1210) -> 1212 1211 */
  kk_integer_t i_0_10013_0 = _self->i_0_10013_0; /* int */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<1209> */
  kk_std_core_types__list yy_0 = _self->yy_0; /* list<1210> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_integer_dup(i_0_10013_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);kk_std_core_types__list_dup(yy_0, _ctx);}, {}, _ctx)
  kk_box_t _trmc_x10091_0_184 = _b_x162; /*1211*/;
  kk_std_core_types__list _x_x1181 = kk_std_core_list__mlift_trmc_lift_zipwith_indexed_4796_10302(_acc_0, f_0, i_0_10013_0, xx_0, yy_0, _trmc_x10091_0_184, _ctx); /*list<1211>*/
  return kk_std_core_types__list_box(_x_x1181, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_lift_zipwith_indexed_4796(kk_function_t f_0, kk_integer_t i, kk_std_core_types__list xs, kk_std_core_types__list ys, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,c,e> (f : (int, a, b) -> e c, i : int, xs : list<a>, ys : list<b>, ctx<list<c>>) -> e list<c> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1175 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1175->head;
    kk_std_core_types__list xx_0 = _con_x1175->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    if (kk_std_core_types__is_Cons(ys, _ctx)) {
      struct kk_std_core_types_Cons* _con_x1176 = kk_std_core_types__as_Cons(ys, _ctx);
      kk_box_t y = _con_x1176->head;
      kk_std_core_types__list yy_0 = _con_x1176->tail;
      kk_reuse_t _ru_x1061 = kk_reuse_null; /*@reuse*/;
      if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
        _ru_x1061 = (kk_datatype_ptr_reuse(ys, _ctx));
      }
      else {
        kk_box_dup(y, _ctx);
        kk_std_core_types__list_dup(yy_0, _ctx);
        kk_datatype_ptr_decref(ys, _ctx);
      }
      kk_integer_t i_0_10013_0;
      kk_integer_t _x_x1177 = kk_integer_dup(i, _ctx); /*int*/
      i_0_10013_0 = kk_integer_add_small_const(_x_x1177, 1, _ctx); /*int*/
      kk_box_t x_0_10340;
      kk_function_t _x_x1178 = kk_function_dup(f_0, _ctx); /*(int, 1209, 1210) -> 1212 1211*/
      x_0_10340 = kk_function_call(kk_box_t, (kk_function_t, kk_integer_t, kk_box_t, kk_box_t, kk_context_t*), _x_x1178, (_x_x1178, i, x, y, _ctx), _ctx); /*1211*/
      if (kk_yielding(kk_context())) {
        kk_reuse_drop(_ru_x1061,kk_context());
        kk_box_drop(x_0_10340, _ctx);
        kk_box_t _x_x1179 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_lift_zipwith_indexed_4796_fun1180(_acc_0, f_0, i_0_10013_0, xx_0, yy_0, _ctx), _ctx); /*3728*/
        return kk_std_core_types__list_unbox(_x_x1179, KK_OWNED, _ctx);
      }
      {
        kk_std_core_types__list _trmc_x10092_0 = kk_datatype_null(); /*list<1211>*/;
        kk_std_core_types__list _trmc_x10093_0 = kk_std_core_types__new_Cons(_ru_x1061, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_0_10340, _trmc_x10092_0, _ctx); /*list<1211>*/;
        kk_field_addr_t _b_x168_176 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10093_0, _ctx)->tail, _ctx); /*@field-addr<list<1211>>*/;
        { // tailcall
          kk_std_core_types__cctx _x_x1182 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10093_0, _ctx)),_b_x168_176,kk_context()); /*ctx<0>*/
          i = i_0_10013_0;
          xs = xx_0;
          ys = yy_0;
          _acc_0 = _x_x1182;
          goto kk__tailcall;
        }
      }
    }
    {
      kk_std_core_types__list_drop(xx_0, _ctx);
      kk_box_drop(x, _ctx);
      kk_integer_drop(i, _ctx);
      kk_function_drop(f_0, _ctx);
      kk_box_t _x_x1183 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
      return kk_std_core_types__list_unbox(_x_x1183, KK_OWNED, _ctx);
    }
  }
  {
    kk_std_core_types__list_drop(ys, _ctx);
    kk_integer_drop(i, _ctx);
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1184 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1184, KK_OWNED, _ctx);
  }
}
 
// lifted local: zipwith-indexed, zipwith-iter

kk_std_core_types__list kk_std_core_list__lift_zipwith_indexed_4796(kk_function_t f_1, kk_integer_t i_0, kk_std_core_types__list xs_0, kk_std_core_types__list ys_0, kk_context_t* _ctx) { /* forall<a,b,c,e> (f : (int, a, b) -> e c, i : int, xs : list<a>, ys : list<b>) -> e list<c> */ 
  kk_std_core_types__cctx _x_x1185 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_lift_zipwith_indexed_4796(f_1, i_0, xs_0, ys_0, _x_x1185, _ctx);
}
 
// Return the head of list with a default value in case the list is empty.

kk_box_t kk_std_core_list_default_fs_head(kk_std_core_types__list xs, kk_box_t kkloc_default, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, default : a) -> a */ 
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1186 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1186->head;
    kk_std_core_types__list _pat_0 = _con_x1186->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_std_core_types__list_drop(_pat_0, _ctx);
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_box_drop(kkloc_default, _ctx);
    return x;
  }
  {
    return kkloc_default;
  }
}
 
// Append two lists.

kk_std_core_types__list kk_std_core_list__trmc_append(kk_std_core_types__list xs, kk_std_core_types__list ys, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, ys : list<a>, ctx<list<a>>) -> list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1187 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1187->head;
    kk_std_core_types__list xx = _con_x1187->tail;
    kk_reuse_t _ru_x1063 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x1063 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_std_core_types__list _trmc_x10094 = kk_datatype_null(); /*list<1271>*/;
    kk_std_core_types__list _trmc_x10095 = kk_std_core_types__new_Cons(_ru_x1063, 0, x, _trmc_x10094, _ctx); /*list<1271>*/;
    kk_field_addr_t _b_x190_195 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10095, _ctx)->tail, _ctx); /*@field-addr<list<1271>>*/;
    { // tailcall
      kk_std_core_types__cctx _x_x1188 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10095, _ctx)),_b_x190_195,kk_context()); /*ctx<0>*/
      xs = xx;
      _acc = _x_x1188;
      goto kk__tailcall;
    }
  }
  {
    kk_box_t _x_x1189 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(ys, _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1189, KK_OWNED, _ctx);
  }
}
 
// Append two lists.

kk_std_core_types__list kk_std_core_list_append(kk_std_core_types__list xs_0, kk_std_core_types__list ys_0, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, ys : list<a>) -> list<a> */ 
  kk_std_core_types__cctx _x_x1190 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_append(xs_0, ys_0, _x_x1190, _ctx);
}
 
// Element-wise list equality

bool kk_std_core_list__lp__eq__eq__rp_(kk_std_core_types__list xs, kk_std_core_types__list ys, kk_function_t _implicit_fs__lp__eq__eq__rp_, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, ys : list<a>, ?(==) : (a, a) -> bool) -> bool */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1191 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1191->head;
    kk_std_core_types__list xx = _con_x1191->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    if (kk_std_core_types__is_Nil(ys, _ctx)) {
      kk_function_drop(_implicit_fs__lp__eq__eq__rp_, _ctx);
      kk_std_core_types__list_drop(xx, _ctx);
      kk_box_drop(x, _ctx);
      return false;
    }
    {
      struct kk_std_core_types_Cons* _con_x1192 = kk_std_core_types__as_Cons(ys, _ctx);
      kk_box_t y = _con_x1192->head;
      kk_std_core_types__list yy = _con_x1192->tail;
      if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
        kk_datatype_ptr_free(ys, _ctx);
      }
      else {
        kk_box_dup(y, _ctx);
        kk_std_core_types__list_dup(yy, _ctx);
        kk_datatype_ptr_decref(ys, _ctx);
      }
      bool _match_x1041;
      kk_function_t _x_x1193 = kk_function_dup(_implicit_fs__lp__eq__eq__rp_, _ctx); /*(1353, 1353) -> bool*/
      _match_x1041 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x1193, (_x_x1193, x, y, _ctx), _ctx); /*bool*/
      if (_match_x1041) { // tailcall
                          xs = xx;
                          ys = yy;
                          goto kk__tailcall;
      }
      {
        kk_function_drop(_implicit_fs__lp__eq__eq__rp_, _ctx);
        kk_std_core_types__list_drop(yy, _ctx);
        kk_std_core_types__list_drop(xx, _ctx);
        return false;
      }
    }
  }
  {
    kk_function_drop(_implicit_fs__lp__eq__eq__rp_, _ctx);
    if (kk_std_core_types__is_Nil(ys, _ctx)) {
      return true;
    }
    {
      struct kk_std_core_types_Cons* _con_x1194 = kk_std_core_types__as_Cons(ys, _ctx);
      kk_box_t _pat_7 = _con_x1194->head;
      kk_std_core_types__list _pat_8 = _con_x1194->tail;
      if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
        kk_std_core_types__list_drop(_pat_8, _ctx);
        kk_box_drop(_pat_7, _ctx);
        kk_datatype_ptr_free(ys, _ctx);
      }
      else {
        kk_datatype_ptr_decref(ys, _ctx);
      }
      return false;
    }
  }
}
 
// Get (zero-based) element `n`  of a list. Return a `:maybe` type.

kk_std_core_types__maybe kk_std_core_list__index(kk_std_core_types__list xs, kk_integer_t n, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, n : int) -> maybe<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1195 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1195->head;
    kk_std_core_types__list xx = _con_x1195->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    bool _match_x1038 = kk_integer_gt_borrow(n,(kk_integer_from_small(0)),kk_context()); /*bool*/;
    if (_match_x1038) {
      kk_box_drop(x, _ctx);
      { // tailcall
        kk_integer_t _x_x1196 = kk_integer_add_small_const(n, -1, _ctx); /*int*/
        xs = xx;
        n = _x_x1196;
        goto kk__tailcall;
      }
    }
    {
      kk_std_core_types__list_drop(xx, _ctx);
      bool _match_x1039;
      bool _brw_x1040 = kk_integer_eq_borrow(n,(kk_integer_from_small(0)),kk_context()); /*bool*/;
      kk_integer_drop(n, _ctx);
      _match_x1039 = _brw_x1040; /*bool*/
      if (_match_x1039) {
        return kk_std_core_types__new_Just(x, _ctx);
      }
      {
        kk_box_drop(x, _ctx);
        return kk_std_core_types__new_Nothing(_ctx);
      }
    }
  }
  {
    kk_integer_drop(n, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}
 
// monadic lift

bool kk_std_core_list__mlift_all_10303(kk_function_t predicate, kk_std_core_types__list xx, bool _y_x10160, kk_context_t* _ctx) { /* forall<a,e> (predicate : (a) -> e bool, xx : list<a>, bool) -> e bool */ 
  if (_y_x10160) {
    return kk_std_core_list_all(xx, predicate, _ctx);
  }
  {
    kk_std_core_types__list_drop(xx, _ctx);
    kk_function_drop(predicate, _ctx);
    return false;
  }
}
 
// Do all elements satisfy a predicate ?


// lift anonymous function
struct kk_std_core_list_all_fun1200__t {
  struct kk_function_s _base;
  kk_function_t predicate_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list_all_fun1200(kk_function_t _fself, kk_box_t _b_x202, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_all_fun1200(kk_function_t predicate_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list_all_fun1200__t* _self = kk_function_alloc_as(struct kk_std_core_list_all_fun1200__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_all_fun1200, kk_context());
  _self->predicate_0 = predicate_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_all_fun1200(kk_function_t _fself, kk_box_t _b_x202, kk_context_t* _ctx) {
  struct kk_std_core_list_all_fun1200__t* _self = kk_function_as(struct kk_std_core_list_all_fun1200__t*, _fself, _ctx);
  kk_function_t predicate_0 = _self->predicate_0; /* (1461) -> 1462 bool */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<1461> */
  kk_drop_match(_self, {kk_function_dup(predicate_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  bool _y_x10160_0_204 = kk_bool_unbox(_b_x202); /*bool*/;
  bool _x_x1201 = kk_std_core_list__mlift_all_10303(predicate_0, xx_0, _y_x10160_0_204, _ctx); /*bool*/
  return kk_bool_box(_x_x1201);
}

bool kk_std_core_list_all(kk_std_core_types__list xs, kk_function_t predicate_0, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool) -> e bool */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1197 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1197->head;
    kk_std_core_types__list xx_0 = _con_x1197->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    bool x_0_10343;
    kk_function_t _x_x1198 = kk_function_dup(predicate_0, _ctx); /*(1461) -> 1462 bool*/
    x_0_10343 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), _x_x1198, (_x_x1198, x, _ctx), _ctx); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x1199 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_all_fun1200(predicate_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_bool_unbox(_x_x1199);
    }
    if (x_0_10343) { // tailcall
                     xs = xx_0;
                     goto kk__tailcall;
    }
    {
      kk_std_core_types__list_drop(xx_0, _ctx);
      kk_function_drop(predicate_0, _ctx);
      return false;
    }
  }
  {
    kk_function_drop(predicate_0, _ctx);
    return true;
  }
}
 
// monadic lift

bool kk_std_core_list__mlift_any_10304(kk_function_t predicate, kk_std_core_types__list xx, bool _y_x10164, kk_context_t* _ctx) { /* forall<a,e> (predicate : (a) -> e bool, xx : list<a>, bool) -> e bool */ 
  if (_y_x10164) {
    kk_std_core_types__list_drop(xx, _ctx);
    kk_function_drop(predicate, _ctx);
    return true;
  }
  {
    return kk_std_core_list_any(xx, predicate, _ctx);
  }
}
 
// Are there any elements in a list that satisfy a predicate ?


// lift anonymous function
struct kk_std_core_list_any_fun1205__t {
  struct kk_function_s _base;
  kk_function_t predicate_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list_any_fun1205(kk_function_t _fself, kk_box_t _b_x206, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_any_fun1205(kk_function_t predicate_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list_any_fun1205__t* _self = kk_function_alloc_as(struct kk_std_core_list_any_fun1205__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_any_fun1205, kk_context());
  _self->predicate_0 = predicate_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_any_fun1205(kk_function_t _fself, kk_box_t _b_x206, kk_context_t* _ctx) {
  struct kk_std_core_list_any_fun1205__t* _self = kk_function_as(struct kk_std_core_list_any_fun1205__t*, _fself, _ctx);
  kk_function_t predicate_0 = _self->predicate_0; /* (1499) -> 1500 bool */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<1499> */
  kk_drop_match(_self, {kk_function_dup(predicate_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  bool _y_x10164_0_208 = kk_bool_unbox(_b_x206); /*bool*/;
  bool _x_x1206 = kk_std_core_list__mlift_any_10304(predicate_0, xx_0, _y_x10164_0_208, _ctx); /*bool*/
  return kk_bool_box(_x_x1206);
}

bool kk_std_core_list_any(kk_std_core_types__list xs, kk_function_t predicate_0, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool) -> e bool */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1202 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1202->head;
    kk_std_core_types__list xx_0 = _con_x1202->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    bool x_0_10346;
    kk_function_t _x_x1203 = kk_function_dup(predicate_0, _ctx); /*(1499) -> 1500 bool*/
    x_0_10346 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), _x_x1203, (_x_x1203, x, _ctx), _ctx); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x1204 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_any_fun1205(predicate_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_bool_unbox(_x_x1204);
    }
    if (x_0_10346) {
      kk_std_core_types__list_drop(xx_0, _ctx);
      kk_function_drop(predicate_0, _ctx);
      return true;
    }
    { // tailcall
      xs = xx_0;
      goto kk__tailcall;
    }
  }
  {
    kk_function_drop(predicate_0, _ctx);
    return false;
  }
}
 
// Order on lists

kk_std_core_types__order kk_std_core_list_cmp(kk_std_core_types__list xs, kk_std_core_types__list ys, kk_function_t _implicit_fs_cmp, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, ys : list<a>, ?cmp : (a, a) -> order) -> order */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1207 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1207->head;
    kk_std_core_types__list xx = _con_x1207->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    if (kk_std_core_types__is_Nil(ys, _ctx)) {
      kk_function_drop(_implicit_fs_cmp, _ctx);
      kk_std_core_types__list_drop(xx, _ctx);
      kk_box_drop(x, _ctx);
      return kk_std_core_types__new_Gt(_ctx);
    }
    {
      struct kk_std_core_types_Cons* _con_x1208 = kk_std_core_types__as_Cons(ys, _ctx);
      kk_box_t y = _con_x1208->head;
      kk_std_core_types__list yy = _con_x1208->tail;
      if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
        kk_datatype_ptr_free(ys, _ctx);
      }
      else {
        kk_box_dup(y, _ctx);
        kk_std_core_types__list_dup(yy, _ctx);
        kk_datatype_ptr_decref(ys, _ctx);
      }
      kk_std_core_types__order _match_x1035;
      kk_function_t _x_x1209 = kk_function_dup(_implicit_fs_cmp, _ctx); /*(1562, 1562) -> order*/
      _match_x1035 = kk_function_call(kk_std_core_types__order, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x1209, (_x_x1209, x, y, _ctx), _ctx); /*order*/
      if (kk_std_core_types__is_Eq(_match_x1035, _ctx)) { // tailcall
                                                          xs = xx;
                                                          ys = yy;
                                                          goto kk__tailcall;
      }
      {
        kk_function_drop(_implicit_fs_cmp, _ctx);
        kk_std_core_types__list_drop(yy, _ctx);
        kk_std_core_types__list_drop(xx, _ctx);
        return _match_x1035;
      }
    }
  }
  {
    kk_function_drop(_implicit_fs_cmp, _ctx);
    if (kk_std_core_types__is_Nil(ys, _ctx)) {
      return kk_std_core_types__new_Eq(_ctx);
    }
    {
      struct kk_std_core_types_Cons* _con_x1210 = kk_std_core_types__as_Cons(ys, _ctx);
      kk_box_t _pat_6 = _con_x1210->head;
      kk_std_core_types__list _pat_7 = _con_x1210->tail;
      if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
        kk_std_core_types__list_drop(_pat_7, _ctx);
        kk_box_drop(_pat_6, _ctx);
        kk_datatype_ptr_free(ys, _ctx);
      }
      else {
        kk_datatype_ptr_decref(ys, _ctx);
      }
      return kk_std_core_types__new_Lt(_ctx);
    }
  }
}
 
// Concatenate a list of `:maybe` values

kk_std_core_types__list kk_std_core_list__trmc_concat_maybe(kk_std_core_types__list xs, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* forall<a> (xs : list<maybe<a>>, ctx<list<a>>) -> list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1211 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x209 = _con_x1211->head;
    kk_std_core_types__list xx = _con_x1211->tail;
    kk_std_core_types__maybe x = kk_std_core_types__maybe_unbox(_box_x209, KK_BORROWED, _ctx);
    kk_reuse_t _ru_x1073 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_std_core_types__maybe_dup(x, _ctx);
      kk_box_drop(_box_x209, _ctx);
      _ru_x1073 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_std_core_types__maybe_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    if (kk_std_core_types__is_Just(x, _ctx)) {
      kk_box_t y = x._cons.Just.value;
      kk_std_core_types__list _trmc_x10096 = kk_datatype_null(); /*list<1616>*/;
      kk_std_core_types__list _trmc_x10097 = kk_std_core_types__new_Cons(_ru_x1073, 0, y, _trmc_x10096, _ctx); /*list<1616>*/;
      kk_field_addr_t _b_x215_220 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10097, _ctx)->tail, _ctx); /*@field-addr<list<1616>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1212 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10097, _ctx)),_b_x215_220,kk_context()); /*ctx<0>*/
        xs = xx;
        _acc = _x_x1212;
        goto kk__tailcall;
      }
    }
    {
      kk_reuse_drop(_ru_x1073,kk_context());
      { // tailcall
        xs = xx;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_box_t _x_x1213 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1213, KK_OWNED, _ctx);
  }
}
 
// Concatenate a list of `:maybe` values

kk_std_core_types__list kk_std_core_list_concat_maybe(kk_std_core_types__list xs_0, kk_context_t* _ctx) { /* forall<a> (xs : list<maybe<a>>) -> list<a> */ 
  kk_std_core_types__cctx _x_x1214 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_concat_maybe(xs_0, _x_x1214, _ctx);
}
 
// Drop the first `n` elements of a list (or fewer if the list is shorter than `n`)

kk_std_core_types__list kk_std_core_list_drop(kk_std_core_types__list xs, kk_integer_t n, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, n : int) -> list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1215 = kk_std_core_types__as_Cons(xs, _ctx);
    if (kk_integer_gt_borrow(n,(kk_integer_from_small(0)),kk_context())) {
      kk_box_t _pat_0 = _con_x1215->head;
      kk_std_core_types__list xx = _con_x1215->tail;
      if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
        kk_box_drop(_pat_0, _ctx);
        kk_datatype_ptr_free(xs, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(xs, _ctx);
      }
      { // tailcall
        kk_integer_t _x_x1216 = kk_integer_add_small_const(n, -1, _ctx); /*int*/
        xs = xx;
        n = _x_x1216;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_integer_drop(n, _ctx);
    return xs;
  }
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_drop_while_10305(kk_function_t predicate, kk_std_core_types__list xs, kk_std_core_types__list xx, bool _y_x10168, kk_context_t* _ctx) { /* forall<a,e> (predicate : (a) -> e bool, xs : list<a>, xx : list<a>, bool) -> e list<a> */ 
  if (_y_x10168) {
    kk_std_core_types__list_drop(xs, _ctx);
    return kk_std_core_list_drop_while(xx, predicate, _ctx);
  }
  {
    kk_std_core_types__list_drop(xx, _ctx);
    kk_function_drop(predicate, _ctx);
    return xs;
  }
}
 
// Drop all initial elements that satisfy `predicate`


// lift anonymous function
struct kk_std_core_list_drop_while_fun1220__t {
  struct kk_function_s _base;
  kk_function_t predicate_0;
  kk_std_core_types__list xs_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list_drop_while_fun1220(kk_function_t _fself, kk_box_t _b_x227, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_drop_while_fun1220(kk_function_t predicate_0, kk_std_core_types__list xs_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list_drop_while_fun1220__t* _self = kk_function_alloc_as(struct kk_std_core_list_drop_while_fun1220__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_drop_while_fun1220, kk_context());
  _self->predicate_0 = predicate_0;
  _self->xs_0 = xs_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_drop_while_fun1220(kk_function_t _fself, kk_box_t _b_x227, kk_context_t* _ctx) {
  struct kk_std_core_list_drop_while_fun1220__t* _self = kk_function_as(struct kk_std_core_list_drop_while_fun1220__t*, _fself, _ctx);
  kk_function_t predicate_0 = _self->predicate_0; /* (1687) -> 1688 bool */
  kk_std_core_types__list xs_0 = _self->xs_0; /* list<1687> */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<1687> */
  kk_drop_match(_self, {kk_function_dup(predicate_0, _ctx);kk_std_core_types__list_dup(xs_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  bool _y_x10168_0_229 = kk_bool_unbox(_b_x227); /*bool*/;
  kk_std_core_types__list _x_x1221 = kk_std_core_list__mlift_drop_while_10305(predicate_0, xs_0, xx_0, _y_x10168_0_229, _ctx); /*list<1687>*/
  return kk_std_core_types__list_box(_x_x1221, _ctx);
}

kk_std_core_types__list kk_std_core_list_drop_while(kk_std_core_types__list xs_0, kk_function_t predicate_0, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool) -> e list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs_0, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1217 = kk_std_core_types__as_Cons(xs_0, _ctx);
    kk_box_t x = _con_x1217->head;
    kk_std_core_types__list xx_0 = _con_x1217->tail;
    kk_box_dup(x, _ctx);
    kk_std_core_types__list_dup(xx_0, _ctx);
    bool x_0_10349;
    kk_function_t _x_x1218 = kk_function_dup(predicate_0, _ctx); /*(1687) -> 1688 bool*/
    x_0_10349 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), _x_x1218, (_x_x1218, x, _ctx), _ctx); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x1219 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_drop_while_fun1220(predicate_0, xs_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1219, KK_OWNED, _ctx);
    }
    if (x_0_10349) {
      if kk_likely(kk_datatype_ptr_is_unique(xs_0, _ctx)) {
        kk_std_core_types__list_drop(xx_0, _ctx);
        kk_box_drop(x, _ctx);
        kk_datatype_ptr_free(xs_0, _ctx);
      }
      else {
        kk_datatype_ptr_decref(xs_0, _ctx);
      }
      { // tailcall
        xs_0 = xx_0;
        goto kk__tailcall;
      }
    }
    {
      kk_std_core_types__list_drop(xx_0, _ctx);
      kk_function_drop(predicate_0, _ctx);
      return xs_0;
    }
  }
  {
    kk_function_drop(predicate_0, _ctx);
    return kk_std_core_types__new_Nil(_ctx);
  }
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_filter_10306(kk_std_core_types__cctx _acc, kk_function_t pred, kk_box_t x, kk_std_core_types__list xx, bool _y_x10172, kk_context_t* _ctx) { /* forall<a,e> (ctx<list<a>>, pred : (a) -> e bool, x : a, xx : list<a>, bool) -> e list<a> */ 
  if (_y_x10172) {
    kk_std_core_types__list _trmc_x10098 = kk_datatype_null(); /*list<1742>*/;
    kk_std_core_types__list _trmc_x10099 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), x, _trmc_x10098, _ctx); /*list<1742>*/;
    kk_field_addr_t _b_x235_238 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10099, _ctx)->tail, _ctx); /*@field-addr<list<1742>>*/;
    kk_std_core_types__cctx _x_x1222 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10099, _ctx)),_b_x235_238,kk_context()); /*ctx<0>*/
    return kk_std_core_list__trmc_filter(xx, pred, _x_x1222, _ctx);
  }
  {
    kk_box_drop(x, _ctx);
    return kk_std_core_list__trmc_filter(xx, pred, _acc, _ctx);
  }
}
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filter([1,2,3],odd?) == [1,3]`


// lift anonymous function
struct kk_std_core_list__trmc_filter_fun1227__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t pred_0;
  kk_box_t x_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list__trmc_filter_fun1227(kk_function_t _fself, kk_box_t _b_x243, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_filter_fun1227(kk_std_core_types__cctx _acc_0, kk_function_t pred_0, kk_box_t x_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_filter_fun1227__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_filter_fun1227__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_filter_fun1227, kk_context());
  _self->_acc_0 = _acc_0;
  _self->pred_0 = pred_0;
  _self->x_0 = x_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_filter_fun1227(kk_function_t _fself, kk_box_t _b_x243, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_filter_fun1227__t* _self = kk_function_as(struct kk_std_core_list__trmc_filter_fun1227__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<1742>> */
  kk_function_t pred_0 = _self->pred_0; /* (1742) -> 1743 bool */
  kk_box_t x_0 = _self->x_0; /* 1742 */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<1742> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(pred_0, _ctx);kk_box_dup(x_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  bool _y_x10172_0_261 = kk_bool_unbox(_b_x243); /*bool*/;
  kk_std_core_types__list _x_x1228 = kk_std_core_list__mlift_trmc_filter_10306(_acc_0, pred_0, x_0, xx_0, _y_x10172_0_261, _ctx); /*list<1742>*/
  return kk_std_core_types__list_box(_x_x1228, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_filter(kk_std_core_types__list xs, kk_function_t pred_0, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, pred : (a) -> e bool, ctx<list<a>>) -> e list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1223 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x_0 = _con_x1223->head;
    kk_std_core_types__list xx_0 = _con_x1223->tail;
    kk_reuse_t _ru_x1076 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x1076 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_box_dup(x_0, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    bool x_1_10352;
    kk_function_t _x_x1225 = kk_function_dup(pred_0, _ctx); /*(1742) -> 1743 bool*/
    kk_box_t _x_x1224 = kk_box_dup(x_0, _ctx); /*1742*/
    x_1_10352 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), _x_x1225, (_x_x1225, _x_x1224, _ctx), _ctx); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1076,kk_context());
      kk_box_t _x_x1226 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_filter_fun1227(_acc_0, pred_0, x_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1226, KK_OWNED, _ctx);
    }
    if (x_1_10352) {
      kk_std_core_types__list _trmc_x10098_0 = kk_datatype_null(); /*list<1742>*/;
      kk_std_core_types__list _trmc_x10099_0 = kk_std_core_types__new_Cons(_ru_x1076, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_0, _trmc_x10098_0, _ctx); /*list<1742>*/;
      kk_field_addr_t _b_x249_255 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10099_0, _ctx)->tail, _ctx); /*@field-addr<list<1742>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1229 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10099_0, _ctx)),_b_x249_255,kk_context()); /*ctx<0>*/
        xs = xx_0;
        _acc_0 = _x_x1229;
        goto kk__tailcall;
      }
    }
    {
      kk_reuse_drop(_ru_x1076,kk_context());
      kk_box_drop(x_0, _ctx);
      { // tailcall
        xs = xx_0;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_function_drop(pred_0, _ctx);
    kk_box_t _x_x1230 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1230, KK_OWNED, _ctx);
  }
}
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filter([1,2,3],odd?) == [1,3]`

kk_std_core_types__list kk_std_core_list_filter(kk_std_core_types__list xs_0, kk_function_t pred_1, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, pred : (a) -> e bool) -> e list<a> */ 
  kk_std_core_types__cctx _x_x1231 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_filter(xs_0, pred_1, _x_x1231, _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_filter_map_10307(kk_std_core_types__cctx _acc, kk_function_t pred, kk_std_core_types__list xx, kk_std_core_types__maybe _y_x10178, kk_context_t* _ctx) { /* forall<a,b,e> (ctx<list<b>>, pred : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e list<b> */ 
  if (kk_std_core_types__is_Nothing(_y_x10178, _ctx)) {
    return kk_std_core_list__trmc_filter_map(xx, pred, _acc, _ctx);
  }
  {
    kk_box_t y = _y_x10178._cons.Just.value;
    kk_std_core_types__list _trmc_x10100 = kk_datatype_null(); /*list<1810>*/;
    kk_std_core_types__list _trmc_x10101 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), y, _trmc_x10100, _ctx); /*list<1810>*/;
    kk_field_addr_t _b_x267_270 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10101, _ctx)->tail, _ctx); /*@field-addr<list<1810>>*/;
    kk_std_core_types__cctx _x_x1232 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10101, _ctx)),_b_x267_270,kk_context()); /*ctx<0>*/
    return kk_std_core_list__trmc_filter_map(xx, pred, _x_x1232, _ctx);
  }
}
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filterMap([1,2,3],fn(i) { if i.odd? then Nothing else Just(i*i) }) == [4]`


// lift anonymous function
struct kk_std_core_list__trmc_filter_map_fun1237__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t pred_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list__trmc_filter_map_fun1237(kk_function_t _fself, kk_box_t _b_x277, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_filter_map_fun1237(kk_std_core_types__cctx _acc_0, kk_function_t pred_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_filter_map_fun1237__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_filter_map_fun1237__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_filter_map_fun1237, kk_context());
  _self->_acc_0 = _acc_0;
  _self->pred_0 = pred_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_filter_map_fun1237(kk_function_t _fself, kk_box_t _b_x277, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_filter_map_fun1237__t* _self = kk_function_as(struct kk_std_core_list__trmc_filter_map_fun1237__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<1810>> */
  kk_function_t pred_0 = _self->pred_0; /* (1809) -> 1811 maybe<1810> */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<1809> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(pred_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _y_x10178_0_293 = kk_std_core_types__maybe_unbox(_b_x277, KK_OWNED, _ctx); /*maybe<1810>*/;
  kk_std_core_types__list _x_x1238 = kk_std_core_list__mlift_trmc_filter_map_10307(_acc_0, pred_0, xx_0, _y_x10178_0_293, _ctx); /*list<1810>*/
  return kk_std_core_types__list_box(_x_x1238, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_filter_map(kk_std_core_types__list xs, kk_function_t pred_0, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, pred : (a) -> e maybe<b>, ctx<list<b>>) -> e list<b> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    kk_function_drop(pred_0, _ctx);
    kk_box_t _x_x1233 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1233, KK_OWNED, _ctx);
  }
  {
    struct kk_std_core_types_Cons* _con_x1234 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1234->head;
    kk_std_core_types__list xx_0 = _con_x1234->tail;
    kk_reuse_t _ru_x1077 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x1077 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_std_core_types__maybe x_0_10355;
    kk_function_t _x_x1235 = kk_function_dup(pred_0, _ctx); /*(1809) -> 1811 maybe<1810>*/
    x_0_10355 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, kk_box_t, kk_context_t*), _x_x1235, (_x_x1235, x, _ctx), _ctx); /*maybe<1810>*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1077,kk_context());
      kk_std_core_types__maybe_drop(x_0_10355, _ctx);
      kk_box_t _x_x1236 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_filter_map_fun1237(_acc_0, pred_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1236, KK_OWNED, _ctx);
    }
    if (kk_std_core_types__is_Nothing(x_0_10355, _ctx)) {
      kk_reuse_drop(_ru_x1077,kk_context());
      { // tailcall
        xs = xx_0;
        goto kk__tailcall;
      }
    }
    {
      kk_box_t y_0 = x_0_10355._cons.Just.value;
      kk_std_core_types__list _trmc_x10100_0 = kk_datatype_null(); /*list<1810>*/;
      kk_std_core_types__list _trmc_x10101_0 = kk_std_core_types__new_Cons(_ru_x1077, kk_field_index_of(struct kk_std_core_types_Cons, tail), y_0, _trmc_x10100_0, _ctx); /*list<1810>*/;
      kk_field_addr_t _b_x283_289 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10101_0, _ctx)->tail, _ctx); /*@field-addr<list<1810>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1239 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10101_0, _ctx)),_b_x283_289,kk_context()); /*ctx<0>*/
        xs = xx_0;
        _acc_0 = _x_x1239;
        goto kk__tailcall;
      }
    }
  }
}
 
// Retain only those elements of a list that satisfy the given predicate `pred`.
// For example: `filterMap([1,2,3],fn(i) { if i.odd? then Nothing else Just(i*i) }) == [4]`

kk_std_core_types__list kk_std_core_list_filter_map(kk_std_core_types__list xs_0, kk_function_t pred_1, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, pred : (a) -> e maybe<b>) -> e list<b> */ 
  kk_std_core_types__cctx _x_x1240 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_filter_map(xs_0, pred_1, _x_x1240, _ctx);
}
 
// monadic lift

kk_std_core_types__maybe kk_std_core_list__mlift_foreach_while_10308(kk_function_t action, kk_std_core_types__list xx, kk_std_core_types__maybe _y_x10184, kk_context_t* _ctx) { /* forall<a,b,e> (action : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e maybe<b> */ 
  if (kk_std_core_types__is_Nothing(_y_x10184, _ctx)) {
    return kk_std_core_list_foreach_while(xx, action, _ctx);
  }
  {
    kk_std_core_types__list_drop(xx, _ctx);
    kk_function_drop(action, _ctx);
    return _y_x10184;
  }
}
 
// Invoke `action` for each element of a list while `action` return `Nothing`


// lift anonymous function
struct kk_std_core_list_foreach_while_fun1244__t {
  struct kk_function_s _base;
  kk_function_t action_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list_foreach_while_fun1244(kk_function_t _fself, kk_box_t _b_x295, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_foreach_while_fun1244(kk_function_t action_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list_foreach_while_fun1244__t* _self = kk_function_alloc_as(struct kk_std_core_list_foreach_while_fun1244__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_foreach_while_fun1244, kk_context());
  _self->action_0 = action_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_foreach_while_fun1244(kk_function_t _fself, kk_box_t _b_x295, kk_context_t* _ctx) {
  struct kk_std_core_list_foreach_while_fun1244__t* _self = kk_function_as(struct kk_std_core_list_foreach_while_fun1244__t*, _fself, _ctx);
  kk_function_t action_0 = _self->action_0; /* (1860) -> 1862 maybe<1861> */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<1860> */
  kk_drop_match(_self, {kk_function_dup(action_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _y_x10184_0_297 = kk_std_core_types__maybe_unbox(_b_x295, KK_OWNED, _ctx); /*maybe<1861>*/;
  kk_std_core_types__maybe _x_x1245 = kk_std_core_list__mlift_foreach_while_10308(action_0, xx_0, _y_x10184_0_297, _ctx); /*maybe<1861>*/
  return kk_std_core_types__maybe_box(_x_x1245, _ctx);
}

kk_std_core_types__maybe kk_std_core_list_foreach_while(kk_std_core_types__list xs, kk_function_t action_0, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, action : (a) -> e maybe<b>) -> e maybe<b> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    kk_function_drop(action_0, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
  {
    struct kk_std_core_types_Cons* _con_x1241 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1241->head;
    kk_std_core_types__list xx_0 = _con_x1241->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_std_core_types__maybe x_0_10358;
    kk_function_t _x_x1242 = kk_function_dup(action_0, _ctx); /*(1860) -> 1862 maybe<1861>*/
    x_0_10358 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, kk_box_t, kk_context_t*), _x_x1242, (_x_x1242, x, _ctx), _ctx); /*maybe<1861>*/
    if (kk_yielding(kk_context())) {
      kk_std_core_types__maybe_drop(x_0_10358, _ctx);
      kk_box_t _x_x1243 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_foreach_while_fun1244(action_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__maybe_unbox(_x_x1243, KK_OWNED, _ctx);
    }
    if (kk_std_core_types__is_Nothing(x_0_10358, _ctx)) { // tailcall
                                                          xs = xx_0;
                                                          goto kk__tailcall;
    }
    {
      kk_std_core_types__list_drop(xx_0, _ctx);
      kk_function_drop(action_0, _ctx);
      return x_0_10358;
    }
  }
}
 
// Find the first element satisfying some predicate


// lift anonymous function
struct kk_std_core_list_find_fun1246__t {
  struct kk_function_s _base;
  kk_function_t pred;
};
static kk_std_core_types__maybe kk_std_core_list_find_fun1246(kk_function_t _fself, kk_box_t x, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_find_fun1246(kk_function_t pred, kk_context_t* _ctx) {
  struct kk_std_core_list_find_fun1246__t* _self = kk_function_alloc_as(struct kk_std_core_list_find_fun1246__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_find_fun1246, kk_context());
  _self->pred = pred;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_list_find_fun1249__t {
  struct kk_function_s _base;
  kk_box_t x;
};
static kk_box_t kk_std_core_list_find_fun1249(kk_function_t _fself, kk_box_t _b_x299, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_find_fun1249(kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_list_find_fun1249__t* _self = kk_function_alloc_as(struct kk_std_core_list_find_fun1249__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_find_fun1249, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_find_fun1249(kk_function_t _fself, kk_box_t _b_x299, kk_context_t* _ctx) {
  struct kk_std_core_list_find_fun1249__t* _self = kk_function_as(struct kk_std_core_list_find_fun1249__t*, _fself, _ctx);
  kk_box_t x = _self->x; /* 1906 */
  kk_drop_match(_self, {kk_box_dup(x, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _x_x1250;
  bool _y_x10188_301 = kk_bool_unbox(_b_x299); /*bool*/;
  if (_y_x10188_301) {
    _x_x1250 = kk_std_core_types__new_Just(x, _ctx); /*maybe<91>*/
  }
  else {
    kk_box_drop(x, _ctx);
    _x_x1250 = kk_std_core_types__new_Nothing(_ctx); /*maybe<91>*/
  }
  return kk_std_core_types__maybe_box(_x_x1250, _ctx);
}
static kk_std_core_types__maybe kk_std_core_list_find_fun1246(kk_function_t _fself, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_list_find_fun1246__t* _self = kk_function_as(struct kk_std_core_list_find_fun1246__t*, _fself, _ctx);
  kk_function_t pred = _self->pred; /* (1906) -> 1907 bool */
  kk_drop_match(_self, {kk_function_dup(pred, _ctx);}, {}, _ctx)
  bool x_0_10361;
  kk_box_t _x_x1247 = kk_box_dup(x, _ctx); /*1906*/
  x_0_10361 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), pred, (pred, _x_x1247, _ctx), _ctx); /*bool*/
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x1248 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_find_fun1249(x, _ctx), _ctx); /*3728*/
    return kk_std_core_types__maybe_unbox(_x_x1248, KK_OWNED, _ctx);
  }
  if (x_0_10361) {
    return kk_std_core_types__new_Just(x, _ctx);
  }
  {
    kk_box_drop(x, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}

kk_std_core_types__maybe kk_std_core_list_find(kk_std_core_types__list xs, kk_function_t pred, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, pred : (a) -> e bool) -> e maybe<a> */ 
  return kk_std_core_list_foreach_while(xs, kk_std_core_list_new_find_fun1246(pred, _ctx), _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_flatmap_maybe_10310(kk_std_core_types__cctx _acc, kk_function_t f, kk_std_core_types__list xx, kk_std_core_types__maybe _y_x10191, kk_context_t* _ctx) { /* forall<a,b,e> (ctx<list<b>>, f : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e list<b> */ 
  if (kk_std_core_types__is_Just(_y_x10191, _ctx)) {
    kk_box_t y = _y_x10191._cons.Just.value;
    kk_std_core_types__list _trmc_x10102 = kk_datatype_null(); /*list<2008>*/;
    kk_std_core_types__list _trmc_x10103 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), y, _trmc_x10102, _ctx); /*list<2008>*/;
    kk_field_addr_t _b_x308_311 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10103, _ctx)->tail, _ctx); /*@field-addr<list<2008>>*/;
    kk_std_core_types__cctx _x_x1251 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10103, _ctx)),_b_x308_311,kk_context()); /*ctx<0>*/
    return kk_std_core_list__trmc_flatmap_maybe(xx, f, _x_x1251, _ctx);
  }
  {
    return kk_std_core_list__trmc_flatmap_maybe(xx, f, _acc, _ctx);
  }
}
 
// Concatenate the `Just` result elements from applying a function to all elements.


// lift anonymous function
struct kk_std_core_list__trmc_flatmap_maybe_fun1255__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list__trmc_flatmap_maybe_fun1255(kk_function_t _fself, kk_box_t _b_x316, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_flatmap_maybe_fun1255(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_flatmap_maybe_fun1255__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_flatmap_maybe_fun1255__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_flatmap_maybe_fun1255, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_flatmap_maybe_fun1255(kk_function_t _fself, kk_box_t _b_x316, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_flatmap_maybe_fun1255__t* _self = kk_function_as(struct kk_std_core_list__trmc_flatmap_maybe_fun1255__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<2008>> */
  kk_function_t f_0 = _self->f_0; /* (2007) -> 2009 maybe<2008> */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<2007> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _y_x10191_0_334 = kk_std_core_types__maybe_unbox(_b_x316, KK_OWNED, _ctx); /*maybe<2008>*/;
  kk_std_core_types__list _x_x1256 = kk_std_core_list__mlift_trmc_flatmap_maybe_10310(_acc_0, f_0, xx_0, _y_x10191_0_334, _ctx); /*list<2008>*/
  return kk_std_core_types__list_box(_x_x1256, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_flatmap_maybe(kk_std_core_types__list xs, kk_function_t f_0, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, f : (a) -> e maybe<b>, ctx<list<b>>) -> e list<b> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1252 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1252->head;
    kk_std_core_types__list xx_0 = _con_x1252->tail;
    kk_reuse_t _ru_x1079 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x1079 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_std_core_types__maybe x_0_10365;
    kk_function_t _x_x1253 = kk_function_dup(f_0, _ctx); /*(2007) -> 2009 maybe<2008>*/
    x_0_10365 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, kk_box_t, kk_context_t*), _x_x1253, (_x_x1253, x, _ctx), _ctx); /*maybe<2008>*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1079,kk_context());
      kk_std_core_types__maybe_drop(x_0_10365, _ctx);
      kk_box_t _x_x1254 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_flatmap_maybe_fun1255(_acc_0, f_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1254, KK_OWNED, _ctx);
    }
    if (kk_std_core_types__is_Just(x_0_10365, _ctx)) {
      kk_box_t y_0 = x_0_10365._cons.Just.value;
      kk_std_core_types__list _trmc_x10102_0 = kk_datatype_null(); /*list<2008>*/;
      kk_std_core_types__list _trmc_x10103_0 = kk_std_core_types__new_Cons(_ru_x1079, kk_field_index_of(struct kk_std_core_types_Cons, tail), y_0, _trmc_x10102_0, _ctx); /*list<2008>*/;
      kk_field_addr_t _b_x322_328 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10103_0, _ctx)->tail, _ctx); /*@field-addr<list<2008>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1257 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10103_0, _ctx)),_b_x322_328,kk_context()); /*ctx<0>*/
        xs = xx_0;
        _acc_0 = _x_x1257;
        goto kk__tailcall;
      }
    }
    {
      kk_reuse_drop(_ru_x1079,kk_context());
      { // tailcall
        xs = xx_0;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1258 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1258, KK_OWNED, _ctx);
  }
}
 
// Concatenate the `Just` result elements from applying a function to all elements.

kk_std_core_types__list kk_std_core_list_flatmap_maybe(kk_std_core_types__list xs_0, kk_function_t f_1, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, f : (a) -> e maybe<b>) -> e list<b> */ 
  kk_std_core_types__cctx _x_x1259 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_flatmap_maybe(xs_0, f_1, _x_x1259, _ctx);
}
 
// monadic lift

kk_box_t kk_std_core_list__mlift_foldl_10311(kk_function_t f, kk_std_core_types__list xx, kk_box_t _y_x10197, kk_context_t* _ctx) { /* forall<a,b,e> (f : (b, a) -> e b, xx : list<a>, b) -> e b */ 
  return kk_std_core_list_foldl(xx, _y_x10197, f, _ctx);
}
 
// Fold a list from the left, i.e. `foldl([1,2],0,(+)) == (0+1)+2`
// Since `foldl` is tail recursive, it is preferred over `foldr` when using an associative function `f`


// lift anonymous function
struct kk_std_core_list_foldl_fun1262__t {
  struct kk_function_s _base;
  kk_function_t f_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list_foldl_fun1262(kk_function_t _fself, kk_box_t _y_x10197_0, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_foldl_fun1262(kk_function_t f_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list_foldl_fun1262__t* _self = kk_function_alloc_as(struct kk_std_core_list_foldl_fun1262__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_foldl_fun1262, kk_context());
  _self->f_0 = f_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_foldl_fun1262(kk_function_t _fself, kk_box_t _y_x10197_0, kk_context_t* _ctx) {
  struct kk_std_core_list_foldl_fun1262__t* _self = kk_function_as(struct kk_std_core_list_foldl_fun1262__t*, _fself, _ctx);
  kk_function_t f_0 = _self->f_0; /* (2053, 2052) -> 2054 2053 */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<2052> */
  kk_drop_match(_self, {kk_function_dup(f_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  return kk_std_core_list__mlift_foldl_10311(f_0, xx_0, _y_x10197_0, _ctx);
}

kk_box_t kk_std_core_list_foldl(kk_std_core_types__list xs, kk_box_t z, kk_function_t f_0, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, z : b, f : (b, a) -> e b) -> e b */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1260 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1260->head;
    kk_std_core_types__list xx_0 = _con_x1260->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_box_t x_0_10368;
    kk_function_t _x_x1261 = kk_function_dup(f_0, _ctx); /*(2053, 2052) -> 2054 2053*/
    x_0_10368 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x1261, (_x_x1261, z, x, _ctx), _ctx); /*2053*/
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_0_10368, _ctx);
      return kk_std_core_hnd_yield_extend(kk_std_core_list_new_foldl_fun1262(f_0, xx_0, _ctx), _ctx);
    }
    { // tailcall
      xs = xx_0;
      z = x_0_10368;
      goto kk__tailcall;
    }
  }
  {
    kk_function_drop(f_0, _ctx);
    return z;
  }
}


// lift anonymous function
struct kk_std_core_list_foldl1_fun1265__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_list_foldl1_fun1265(kk_function_t _fself, kk_box_t _b_x339, kk_box_t _b_x340, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_foldl1_fun1265(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_list_foldl1_fun1265, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_list_foldl1_fun1265(kk_function_t _fself, kk_box_t _b_x339, kk_box_t _b_x340, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1266 = kk_string_unbox(_b_x339); /*string*/
  kk_std_core_types__optional _x_x1267 = kk_std_core_types__optional_unbox(_b_x340, KK_OWNED, _ctx); /*? exception-info*/
  return kk_std_core_exn_throw(_x_x1266, _x_x1267, _ctx);
}

kk_box_t kk_std_core_list_foldl1(kk_std_core_types__list xs, kk_function_t f, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, f : (a, a) -> <exn|e> a) -> <exn|e> a */ 
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1263 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1263->head;
    kk_std_core_types__list xx = _con_x1263->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    return kk_std_core_list_foldl(xx, x, f, _ctx);
  }
  {
    kk_function_drop(f, _ctx);
    kk_ssize_t _b_x335_341;
    kk_std_core_hnd__htag _x_x1264 = kk_std_core_hnd__htag_dup(kk_std_core_exn__tag_exn, _ctx); /*hnd/htag<exn>*/
    _b_x335_341 = kk_std_core_hnd__evv_index(_x_x1264, _ctx); /*hnd/ev-index*/
    kk_box_t _x_x1268;
    kk_string_t _x_x1269;
    kk_define_string_literal(, _s_x1270, 33, "unexpected Nil in std/core/foldl1", _ctx)
    _x_x1269 = kk_string_dup(_s_x1270, _ctx); /*string*/
    _x_x1268 = kk_string_box(_x_x1269); /*5933*/
    return kk_std_core_hnd__open_at2(_b_x335_341, kk_std_core_list_new_foldl1_fun1265(_ctx), _x_x1268, kk_std_core_types__optional_box(kk_std_core_types__new_None(_ctx), _ctx), _ctx);
  }
}
extern kk_box_t kk_std_core_list_foldr_fun1272(kk_function_t _fself, kk_box_t x, kk_box_t y, kk_context_t* _ctx) {
  struct kk_std_core_list_foldr_fun1272__t* _self = kk_function_as(struct kk_std_core_list_foldr_fun1272__t*, _fself, _ctx);
  kk_function_t f = _self->f; /* (2161, 2162) -> 2163 2162 */
  kk_drop_match(_self, {kk_function_dup(f, _ctx);}, {}, _ctx)
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), f, (f, y, x, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_list_foldr1_fun1275__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_list_foldr1_fun1275(kk_function_t _fself, kk_box_t _b_x349, kk_box_t _b_x350, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_foldr1_fun1275(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_list_foldr1_fun1275, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_list_foldr1_fun1275(kk_function_t _fself, kk_box_t _b_x349, kk_box_t _b_x350, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1276 = kk_string_unbox(_b_x349); /*string*/
  kk_std_core_types__optional _x_x1277 = kk_std_core_types__optional_unbox(_b_x350, KK_OWNED, _ctx); /*? exception-info*/
  return kk_std_core_exn_throw(_x_x1276, _x_x1277, _ctx);
}

kk_box_t kk_std_core_list_foldr1(kk_std_core_types__list xs, kk_function_t f, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, f : (a, a) -> <exn|e> a) -> <exn|e> a */ 
  kk_std_core_types__list xs_0_10024 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), xs, _ctx); /*list<2195>*/;
  if (kk_std_core_types__is_Cons(xs_0_10024, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1273 = kk_std_core_types__as_Cons(xs_0_10024, _ctx);
    kk_box_t x = _con_x1273->head;
    kk_std_core_types__list xx = _con_x1273->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs_0_10024, _ctx)) {
      kk_datatype_ptr_free(xs_0_10024, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs_0_10024, _ctx);
    }
    return kk_std_core_list_foldl(xx, x, f, _ctx);
  }
  {
    kk_function_drop(f, _ctx);
    kk_ssize_t _b_x345_351;
    kk_std_core_hnd__htag _x_x1274 = kk_std_core_hnd__htag_dup(kk_std_core_exn__tag_exn, _ctx); /*hnd/htag<exn>*/
    _b_x345_351 = kk_std_core_hnd__evv_index(_x_x1274, _ctx); /*hnd/ev-index*/
    kk_box_t _x_x1278;
    kk_string_t _x_x1279;
    kk_define_string_literal(, _s_x1280, 33, "unexpected Nil in std/core/foldl1", _ctx)
    _x_x1279 = kk_string_dup(_s_x1280, _ctx); /*string*/
    _x_x1278 = kk_string_box(_x_x1279); /*5933*/
    return kk_std_core_hnd__open_at2(_b_x345_351, kk_std_core_list_new_foldr1_fun1275(_ctx), _x_x1278, kk_std_core_types__optional_box(kk_std_core_types__new_None(_ctx), _ctx), _ctx);
  }
}
 
// monadic lift

kk_unit_t kk_std_core_list__mlift_foreach_10312(kk_function_t action, kk_std_core_types__list xx, kk_unit_t wild__, kk_context_t* _ctx) { /* forall<a,e> (action : (a) -> e (), xx : list<a>, wild_ : ()) -> e () */ 
  kk_std_core_list_foreach(xx, action, _ctx); return kk_Unit;
}
 
// Invoke `action` for each element of a list


// lift anonymous function
struct kk_std_core_list_foreach_fun1284__t {
  struct kk_function_s _base;
  kk_function_t action_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list_foreach_fun1284(kk_function_t _fself, kk_box_t _b_x356, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_foreach_fun1284(kk_function_t action_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list_foreach_fun1284__t* _self = kk_function_alloc_as(struct kk_std_core_list_foreach_fun1284__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_foreach_fun1284, kk_context());
  _self->action_0 = action_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_foreach_fun1284(kk_function_t _fself, kk_box_t _b_x356, kk_context_t* _ctx) {
  struct kk_std_core_list_foreach_fun1284__t* _self = kk_function_as(struct kk_std_core_list_foreach_fun1284__t*, _fself, _ctx);
  kk_function_t action_0 = _self->action_0; /* (2229) -> 2230 () */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<2229> */
  kk_drop_match(_self, {kk_function_dup(action_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  kk_unit_t wild___0_358 = kk_Unit;
  kk_unit_unbox(_b_x356);
  kk_unit_t _x_x1285 = kk_Unit;
  kk_std_core_list__mlift_foreach_10312(action_0, xx_0, wild___0_358, _ctx);
  return kk_unit_box(_x_x1285);
}

kk_unit_t kk_std_core_list_foreach(kk_std_core_types__list xs, kk_function_t action_0, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, action : (a) -> e ()) -> e () */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1281 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1281->head;
    kk_std_core_types__list xx_0 = _con_x1281->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_unit_t x_0_10371 = kk_Unit;
    kk_function_t _x_x1282 = kk_function_dup(action_0, _ctx); /*(2229) -> 2230 ()*/
    kk_function_call(kk_unit_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x1282, (_x_x1282, x, _ctx), _ctx);
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x1283 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_foreach_fun1284(action_0, xx_0, _ctx), _ctx); /*3728*/
      kk_unit_unbox(_x_x1283); return kk_Unit;
    }
    { // tailcall
      xs = xx_0;
      goto kk__tailcall;
    }
  }
  {
    kk_function_drop(action_0, _ctx);
    kk_Unit; return kk_Unit;
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_list__mlift_foreach_indexed_10314_fun1288__t {
  struct kk_function_s _base;
  kk_ref_t i;
};
static kk_unit_t kk_std_core_list__mlift_foreach_indexed_10314_fun1288(kk_function_t _fself, kk_integer_t _y_x10214, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_mlift_foreach_indexed_10314_fun1288(kk_ref_t i, kk_context_t* _ctx) {
  struct kk_std_core_list__mlift_foreach_indexed_10314_fun1288__t* _self = kk_function_alloc_as(struct kk_std_core_list__mlift_foreach_indexed_10314_fun1288__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__mlift_foreach_indexed_10314_fun1288, kk_context());
  _self->i = i;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_unit_t kk_std_core_list__mlift_foreach_indexed_10314_fun1288(kk_function_t _fself, kk_integer_t _y_x10214, kk_context_t* _ctx) {
  struct kk_std_core_list__mlift_foreach_indexed_10314_fun1288__t* _self = kk_function_as(struct kk_std_core_list__mlift_foreach_indexed_10314_fun1288__t*, _fself, _ctx);
  kk_ref_t i = _self->i; /* local-var<2329,int> */
  kk_drop_match(_self, {kk_ref_dup(i, _ctx);}, {}, _ctx)
  kk_integer_t _b_x366_368 = kk_integer_add_small_const(_y_x10214, 1, _ctx); /*int*/;
  kk_unit_t _brw_x1025 = kk_Unit;
  kk_ref_set_borrow(i,(kk_integer_box(_b_x366_368, _ctx)),kk_context());
  kk_ref_drop(i, _ctx);
  return _brw_x1025;
}


// lift anonymous function
struct kk_std_core_list__mlift_foreach_indexed_10314_fun1290__t {
  struct kk_function_s _base;
  kk_function_t next_10375;
};
static kk_box_t kk_std_core_list__mlift_foreach_indexed_10314_fun1290(kk_function_t _fself, kk_box_t _b_x370, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_mlift_foreach_indexed_10314_fun1290(kk_function_t next_10375, kk_context_t* _ctx) {
  struct kk_std_core_list__mlift_foreach_indexed_10314_fun1290__t* _self = kk_function_alloc_as(struct kk_std_core_list__mlift_foreach_indexed_10314_fun1290__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__mlift_foreach_indexed_10314_fun1290, kk_context());
  _self->next_10375 = next_10375;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__mlift_foreach_indexed_10314_fun1290(kk_function_t _fself, kk_box_t _b_x370, kk_context_t* _ctx) {
  struct kk_std_core_list__mlift_foreach_indexed_10314_fun1290__t* _self = kk_function_as(struct kk_std_core_list__mlift_foreach_indexed_10314_fun1290__t*, _fself, _ctx);
  kk_function_t next_10375 = _self->next_10375; /* (int) -> <local<2329>|2336> () */
  kk_drop_match(_self, {kk_function_dup(next_10375, _ctx);}, {}, _ctx)
  kk_unit_t _x_x1291 = kk_Unit;
  kk_integer_t _x_x1292 = kk_integer_unbox(_b_x370, _ctx); /*int*/
  kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10375, (next_10375, _x_x1292, _ctx), _ctx);
  return kk_unit_box(_x_x1291);
}

kk_unit_t kk_std_core_list__mlift_foreach_indexed_10314(kk_ref_t i, kk_unit_t wild__, kk_context_t* _ctx) { /* forall<h,e> (i : local-var<h,int>, wild_ : ()) -> <local<h>|e> () */ 
  kk_integer_t x_10374;
  kk_box_t _x_x1286;
  kk_ref_t _x_x1287 = kk_ref_dup(i, _ctx); /*local-var<2329,int>*/
  _x_x1286 = kk_ref_get(_x_x1287,kk_context()); /*294*/
  x_10374 = kk_integer_unbox(_x_x1286, _ctx); /*int*/
  kk_function_t next_10375 = kk_std_core_list__new_mlift_foreach_indexed_10314_fun1288(i, _ctx); /*(int) -> <local<2329>|2336> ()*/;
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_10374, _ctx);
    kk_box_t _x_x1289 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_mlift_foreach_indexed_10314_fun1290(next_10375, _ctx), _ctx); /*3728*/
    kk_unit_unbox(_x_x1289); return kk_Unit;
  }
  {
    kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), next_10375, (next_10375, x_10374, _ctx), _ctx); return kk_Unit;
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_core_list__mlift_foreach_indexed_10315_fun1294__t {
  struct kk_function_s _base;
  kk_ref_t i;
};
static kk_box_t kk_std_core_list__mlift_foreach_indexed_10315_fun1294(kk_function_t _fself, kk_box_t _b_x373, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_mlift_foreach_indexed_10315_fun1294(kk_ref_t i, kk_context_t* _ctx) {
  struct kk_std_core_list__mlift_foreach_indexed_10315_fun1294__t* _self = kk_function_alloc_as(struct kk_std_core_list__mlift_foreach_indexed_10315_fun1294__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__mlift_foreach_indexed_10315_fun1294, kk_context());
  _self->i = i;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__mlift_foreach_indexed_10315_fun1294(kk_function_t _fself, kk_box_t _b_x373, kk_context_t* _ctx) {
  struct kk_std_core_list__mlift_foreach_indexed_10315_fun1294__t* _self = kk_function_as(struct kk_std_core_list__mlift_foreach_indexed_10315_fun1294__t*, _fself, _ctx);
  kk_ref_t i = _self->i; /* local-var<2329,int> */
  kk_drop_match(_self, {kk_ref_dup(i, _ctx);}, {}, _ctx)
  kk_unit_t wild___375 = kk_Unit;
  kk_unit_unbox(_b_x373);
  kk_unit_t _x_x1295 = kk_Unit;
  kk_std_core_list__mlift_foreach_indexed_10314(i, wild___375, _ctx);
  return kk_unit_box(_x_x1295);
}

kk_unit_t kk_std_core_list__mlift_foreach_indexed_10315(kk_function_t action, kk_ref_t i, kk_box_t x, kk_integer_t j, kk_context_t* _ctx) { /* forall<h,a,e> (action : (int, a) -> e (), i : local-var<h,int>, x : a, j : int) -> <local<h>|e> () */ 
  kk_unit_t x_0_10378 = kk_Unit;
  kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_box_t, kk_context_t*), action, (action, j, x, _ctx), _ctx);
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x1293 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_mlift_foreach_indexed_10315_fun1294(i, _ctx), _ctx); /*3728*/
    kk_unit_unbox(_x_x1293); return kk_Unit;
  }
  {
    kk_std_core_list__mlift_foreach_indexed_10314(i, x_0_10378, _ctx); return kk_Unit;
  }
}
 
// Invoke `action` for each element of a list, passing also the position of the element.


// lift anonymous function
struct kk_std_core_list_foreach_indexed_fun1297__t {
  struct kk_function_s _base;
  kk_function_t action;
  kk_ref_t loc;
};
static kk_unit_t kk_std_core_list_foreach_indexed_fun1297(kk_function_t _fself, kk_box_t x, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_foreach_indexed_fun1297(kk_function_t action, kk_ref_t loc, kk_context_t* _ctx) {
  struct kk_std_core_list_foreach_indexed_fun1297__t* _self = kk_function_alloc_as(struct kk_std_core_list_foreach_indexed_fun1297__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_foreach_indexed_fun1297, kk_context());
  _self->action = action;
  _self->loc = loc;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_list_foreach_indexed_fun1301__t {
  struct kk_function_s _base;
  kk_function_t action;
  kk_ref_t loc;
  kk_box_t x;
};
static kk_box_t kk_std_core_list_foreach_indexed_fun1301(kk_function_t _fself, kk_box_t _b_x381, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_foreach_indexed_fun1301(kk_function_t action, kk_ref_t loc, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_list_foreach_indexed_fun1301__t* _self = kk_function_alloc_as(struct kk_std_core_list_foreach_indexed_fun1301__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_foreach_indexed_fun1301, kk_context());
  _self->action = action;
  _self->loc = loc;
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_foreach_indexed_fun1301(kk_function_t _fself, kk_box_t _b_x381, kk_context_t* _ctx) {
  struct kk_std_core_list_foreach_indexed_fun1301__t* _self = kk_function_as(struct kk_std_core_list_foreach_indexed_fun1301__t*, _fself, _ctx);
  kk_function_t action = _self->action; /* (int, 2335) -> 2336 () */
  kk_ref_t loc = _self->loc; /* local-var<2329,int> */
  kk_box_t x = _self->x; /* 2335 */
  kk_drop_match(_self, {kk_function_dup(action, _ctx);kk_ref_dup(loc, _ctx);kk_box_dup(x, _ctx);}, {}, _ctx)
  kk_unit_t _x_x1302 = kk_Unit;
  kk_integer_t _x_x1303 = kk_integer_unbox(_b_x381, _ctx); /*int*/
  kk_std_core_list__mlift_foreach_indexed_10315(action, loc, x, _x_x1303, _ctx);
  return kk_unit_box(_x_x1302);
}
static kk_unit_t kk_std_core_list_foreach_indexed_fun1297(kk_function_t _fself, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_list_foreach_indexed_fun1297__t* _self = kk_function_as(struct kk_std_core_list_foreach_indexed_fun1297__t*, _fself, _ctx);
  kk_function_t action = _self->action; /* (int, 2335) -> 2336 () */
  kk_ref_t loc = _self->loc; /* local-var<2329,int> */
  kk_drop_match(_self, {kk_function_dup(action, _ctx);kk_ref_dup(loc, _ctx);}, {}, _ctx)
  kk_integer_t x_0_10383;
  kk_box_t _x_x1298;
  kk_ref_t _x_x1299 = kk_ref_dup(loc, _ctx); /*local-var<2329,int>*/
  _x_x1298 = kk_ref_get(_x_x1299,kk_context()); /*294*/
  x_0_10383 = kk_integer_unbox(_x_x1298, _ctx); /*int*/
  if (kk_yielding(kk_context())) {
    kk_integer_drop(x_0_10383, _ctx);
    kk_box_t _x_x1300 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_foreach_indexed_fun1301(action, loc, x, _ctx), _ctx); /*3728*/
    return kk_unit_unbox(_x_x1300);
  }
  {
    return kk_std_core_list__mlift_foreach_indexed_10315(action, loc, x, x_0_10383, _ctx);
  }
}

kk_unit_t kk_std_core_list_foreach_indexed(kk_std_core_types__list xs, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, action : (int, a) -> e ()) -> e () */ 
  kk_ref_t loc = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*local-var<2329,int>*/;
  kk_unit_t res = kk_Unit;
  kk_function_t _x_x1296;
  kk_ref_dup(loc, _ctx);
  _x_x1296 = kk_std_core_list_new_foreach_indexed_fun1297(action, loc, _ctx); /*(x : 2335) -> <local<2329>|2336> ()*/
  kk_std_core_list_foreach(xs, _x_x1296, _ctx);
  kk_box_t _x_x1304 = kk_std_core_hnd_prompt_local_var(loc, kk_unit_box(res), _ctx); /*21474*/
  kk_unit_unbox(_x_x1304); return kk_Unit;
}
 
// monadic lift

kk_integer_t kk_std_core_list__mlift_index_of_acc_10316(kk_integer_t idx, kk_function_t pred, kk_std_core_types__list xx, bool _y_x10219, kk_context_t* _ctx) { /* forall<a,e> (idx : int, pred : (a) -> e bool, xx : list<a>, bool) -> e int */ 
  if (_y_x10219) {
    kk_std_core_types__list_drop(xx, _ctx);
    kk_function_drop(pred, _ctx);
    return idx;
  }
  {
    kk_integer_t _x_x1305 = kk_integer_add_small_const(idx, 1, _ctx); /*int*/
    return kk_std_core_list_index_of_acc(xx, pred, _x_x1305, _ctx);
  }
}


// lift anonymous function
struct kk_std_core_list_index_of_acc_fun1309__t {
  struct kk_function_s _base;
  kk_integer_t idx_0;
  kk_function_t pred_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list_index_of_acc_fun1309(kk_function_t _fself, kk_box_t _b_x389, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_index_of_acc_fun1309(kk_integer_t idx_0, kk_function_t pred_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list_index_of_acc_fun1309__t* _self = kk_function_alloc_as(struct kk_std_core_list_index_of_acc_fun1309__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_index_of_acc_fun1309, kk_context());
  _self->idx_0 = idx_0;
  _self->pred_0 = pred_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_index_of_acc_fun1309(kk_function_t _fself, kk_box_t _b_x389, kk_context_t* _ctx) {
  struct kk_std_core_list_index_of_acc_fun1309__t* _self = kk_function_as(struct kk_std_core_list_index_of_acc_fun1309__t*, _fself, _ctx);
  kk_integer_t idx_0 = _self->idx_0; /* int */
  kk_function_t pred_0 = _self->pred_0; /* (2378) -> 2379 bool */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<2378> */
  kk_drop_match(_self, {kk_integer_dup(idx_0, _ctx);kk_function_dup(pred_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  bool _y_x10219_0_391 = kk_bool_unbox(_b_x389); /*bool*/;
  kk_integer_t _x_x1310 = kk_std_core_list__mlift_index_of_acc_10316(idx_0, pred_0, xx_0, _y_x10219_0_391, _ctx); /*int*/
  return kk_integer_box(_x_x1310, _ctx);
}

kk_integer_t kk_std_core_list_index_of_acc(kk_std_core_types__list xs, kk_function_t pred_0, kk_integer_t idx_0, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, pred : (a) -> e bool, idx : int) -> e int */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1306 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1306->head;
    kk_std_core_types__list xx_0 = _con_x1306->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    bool x_0_10385;
    kk_function_t _x_x1307 = kk_function_dup(pred_0, _ctx); /*(2378) -> 2379 bool*/
    x_0_10385 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), _x_x1307, (_x_x1307, x, _ctx), _ctx); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x1308 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_index_of_acc_fun1309(idx_0, pred_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_integer_unbox(_x_x1308, _ctx);
    }
    if (x_0_10385) {
      kk_std_core_types__list_drop(xx_0, _ctx);
      kk_function_drop(pred_0, _ctx);
      return idx_0;
    }
    { // tailcall
      kk_integer_t _x_x1311 = kk_integer_add_small_const(idx_0, 1, _ctx); /*int*/
      xs = xx_0;
      idx_0 = _x_x1311;
      goto kk__tailcall;
    }
  }
  {
    kk_function_drop(pred_0, _ctx);
    kk_integer_drop(idx_0, _ctx);
    return kk_integer_from_small(-1);
  }
}
 
// Return the list without its last element.
// Return an empty list for an empty list.

kk_std_core_types__list kk_std_core_list__trmc_init(kk_std_core_types__list xs, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, ctx<list<a>>) -> list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1312 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_std_core_types__list xx = _con_x1312->tail;
    if (kk_std_core_types__is_Cons(xx, _ctx)) {
      struct kk_std_core_types_Cons* _con_x1313 = kk_std_core_types__as_Cons(xx, _ctx);
      kk_box_t x = _con_x1312->head;
      kk_reuse_t _ru_x1085 = kk_reuse_null; /*@reuse*/;
      if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
        _ru_x1085 = (kk_datatype_ptr_reuse(xs, _ctx));
      }
      else {
        kk_box_dup(x, _ctx);
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(xs, _ctx);
      }
      kk_std_core_types__list _trmc_x10104 = kk_datatype_null(); /*list<2441>*/;
      kk_std_core_types__list _trmc_x10105 = kk_std_core_types__new_Cons(_ru_x1085, 0, x, _trmc_x10104, _ctx); /*list<2441>*/;
      kk_field_addr_t _b_x397_402 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10105, _ctx)->tail, _ctx); /*@field-addr<list<2441>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1314 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10105, _ctx)),_b_x397_402,kk_context()); /*ctx<0>*/
        xs = xx;
        _acc = _x_x1314;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_std_core_types__list_drop(xs, _ctx);
    kk_box_t _x_x1315 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1315, KK_OWNED, _ctx);
  }
}
 
// Return the list without its last element.
// Return an empty list for an empty list.

kk_std_core_types__list kk_std_core_list_init(kk_std_core_types__list xs_0, kk_context_t* _ctx) { /* forall<a> (xs : list<a>) -> list<a> */ 
  kk_std_core_types__cctx _x_x1316 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_init(xs_0, _x_x1316, _ctx);
}
 
// lifted local: joinsep, join-acc

kk_string_t kk_std_core_list__lift_joinsep_4797(kk_string_t sep, kk_std_core_types__list ys, kk_string_t acc, kk_context_t* _ctx) { /* (sep : string, ys : list<string>, acc : string) -> string */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1317 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t _box_x408 = _con_x1317->head;
    kk_std_core_types__list yy = _con_x1317->tail;
    kk_string_t y = kk_string_unbox(_box_x408);
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      kk_datatype_ptr_free(ys, _ctx);
    }
    else {
      kk_string_dup(y, _ctx);
      kk_std_core_types__list_dup(yy, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_string_t acc_0_10030;
    kk_string_t _x_x1318;
    kk_string_t _x_x1319 = kk_string_dup(sep, _ctx); /*string*/
    _x_x1318 = kk_std_core_types__lp__plus__plus__rp_(_x_x1319, y, _ctx); /*string*/
    acc_0_10030 = kk_std_core_types__lp__plus__plus__rp_(acc, _x_x1318, _ctx); /*string*/
    { // tailcall
      ys = yy;
      acc = acc_0_10030;
      goto kk__tailcall;
    }
  }
  {
    kk_string_drop(sep, _ctx);
    return acc;
  }
}
 
// Concatenate all strings in a list

kk_string_t kk_std_core_list_joinsep(kk_std_core_types__list xs, kk_string_t sep, kk_context_t* _ctx) { /* (xs : list<string>, sep : string) -> string */ 
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    kk_string_drop(sep, _ctx);
    return kk_string_empty();
  }
  {
    struct kk_std_core_types_Cons* _con_x1321 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x409 = _con_x1321->head;
    kk_std_core_types__list xx = _con_x1321->tail;
    kk_string_t x = kk_string_unbox(_box_x409);
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_string_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    return kk_std_core_list__lift_joinsep_4797(sep, xx, x, _ctx);
  }
}
 
// Concatenate all strings in a list

kk_string_t kk_std_core_list_join(kk_std_core_types__list xs, kk_context_t* _ctx) { /* (xs : list<string>) -> string */ 
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    return kk_string_empty();
  }
  {
    struct kk_std_core_types_Cons* _con_x1323 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x410 = _con_x1323->head;
    kk_std_core_types__list xx = _con_x1323->tail;
    kk_string_t x = kk_string_unbox(_box_x410);
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_string_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_string_t _x_x1324 = kk_string_empty(); /*string*/
    return kk_std_core_list__lift_joinsep_4797(_x_x1324, xx, x, _ctx);
  }
}
 
// Append `end` to each string in the list `xs` and join them all together.
// `join-end([],end) === ""`
// `join-end(["a","b"],"/") === "a/b/"`

kk_string_t kk_std_core_list_join_end(kk_std_core_types__list xs, kk_string_t end, kk_context_t* _ctx) { /* (xs : list<string>, end : string) -> string */ 
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    kk_string_drop(end, _ctx);
    return kk_string_empty();
  }
  {
    kk_string_t _x_x1327;
    if (kk_std_core_types__is_Nil(xs, _ctx)) {
      _x_x1327 = kk_string_empty(); /*string*/
    }
    else {
      struct kk_std_core_types_Cons* _con_x1329 = kk_std_core_types__as_Cons(xs, _ctx);
      kk_box_t _box_x411 = _con_x1329->head;
      kk_std_core_types__list xx = _con_x1329->tail;
      kk_string_t x = kk_string_unbox(_box_x411);
      if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
        kk_datatype_ptr_free(xs, _ctx);
      }
      else {
        kk_string_dup(x, _ctx);
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(xs, _ctx);
      }
      kk_string_t _x_x1330 = kk_string_dup(end, _ctx); /*string*/
      _x_x1327 = kk_std_core_list__lift_joinsep_4797(_x_x1330, xx, x, _ctx); /*string*/
    }
    return kk_std_core_types__lp__plus__plus__rp_(_x_x1327, end, _ctx);
  }
}
 
// Return the last element of a list (or `Nothing` for the empty list)

kk_std_core_types__maybe kk_std_core_list_last(kk_std_core_types__list xs, kk_context_t* _ctx) { /* forall<a> (xs : list<a>) -> maybe<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1331 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_std_core_types__list _pat_0 = _con_x1331->tail;
    if (kk_std_core_types__is_Nil(_pat_0, _ctx)) {
      kk_box_t x = _con_x1331->head;
      if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
        kk_datatype_ptr_free(xs, _ctx);
      }
      else {
        kk_box_dup(x, _ctx);
        kk_datatype_ptr_decref(xs, _ctx);
      }
      return kk_std_core_types__new_Just(x, _ctx);
    }
  }
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1332 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _pat_2 = _con_x1332->head;
    kk_std_core_types__list xx = _con_x1332->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_box_drop(_pat_2, _ctx);
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    { // tailcall
      xs = xx;
      goto kk__tailcall;
    }
  }
  {
    return kk_std_core_types__new_Nothing(_ctx);
  }
}
 
// Take the first `n` elements of a list (or fewer if the list is shorter than `n`)

kk_std_core_types__list kk_std_core_list__trmc_take(kk_std_core_types__list xs, kk_integer_t n, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, n : int, ctx<list<a>>) -> list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1333 = kk_std_core_types__as_Cons(xs, _ctx);
    if (kk_integer_gt_borrow(n,(kk_integer_from_small(0)),kk_context())) {
      kk_box_t x = _con_x1333->head;
      kk_std_core_types__list xx = _con_x1333->tail;
      kk_reuse_t _ru_x1092 = kk_reuse_null; /*@reuse*/;
      if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
        _ru_x1092 = (kk_datatype_ptr_reuse(xs, _ctx));
      }
      else {
        kk_box_dup(x, _ctx);
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(xs, _ctx);
      }
      kk_std_core_types__list _trmc_x10106 = kk_datatype_null(); /*list<2612>*/;
      kk_std_core_types__list _trmc_x10107 = kk_std_core_types__new_Cons(_ru_x1092, 0, x, _trmc_x10106, _ctx); /*list<2612>*/;
      kk_field_addr_t _b_x417_422 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10107, _ctx)->tail, _ctx); /*@field-addr<list<2612>>*/;
      { // tailcall
        kk_integer_t _x_x1334 = kk_integer_add_small_const(n, -1, _ctx); /*int*/
        kk_std_core_types__cctx _x_x1335 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10107, _ctx)),_b_x417_422,kk_context()); /*ctx<0>*/
        xs = xx;
        n = _x_x1334;
        _acc = _x_x1335;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_std_core_types__list_drop(xs, _ctx);
    kk_integer_drop(n, _ctx);
    kk_box_t _x_x1336 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1336, KK_OWNED, _ctx);
  }
}
 
// Take the first `n` elements of a list (or fewer if the list is shorter than `n`)

kk_std_core_types__list kk_std_core_list_take(kk_std_core_types__list xs_0, kk_integer_t n_0, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, n : int) -> list<a> */ 
  kk_std_core_types__cctx _x_x1337 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_take(xs_0, n_0, _x_x1337, _ctx);
}
 
// split a list at position `n`

kk_std_core_types__tuple2 kk_std_core_list_split(kk_std_core_types__list xs, kk_integer_t n, kk_context_t* _ctx) { /* forall<a> (xs : list<a>, n : int) -> (list<a>, list<a>) */ 
  kk_std_core_types__list _b_x428_430;
  kk_std_core_types__list _x_x1338 = kk_std_core_types__list_dup(xs, _ctx); /*list<2647>*/
  kk_integer_t _x_x1339 = kk_integer_dup(n, _ctx); /*int*/
  _b_x428_430 = kk_std_core_list_take(_x_x1338, _x_x1339, _ctx); /*list<2647>*/
  kk_std_core_types__list _b_x429_431 = kk_std_core_list_drop(xs, n, _ctx); /*list<2647>*/;
  return kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(_b_x428_430, _ctx), kk_std_core_types__list_box(_b_x429_431, _ctx), _ctx);
}
 
// Returns an integer list of increasing elements from `lo`  to `hi`
// (including both `lo`  and `hi` ).
// If `lo > hi`  the function returns the empty list.

kk_std_core_types__list kk_std_core_list__trmc_list(kk_integer_t lo, kk_integer_t hi, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* (lo : int, hi : int, ctx<list<int>>) -> list<int> */ 
  kk__tailcall: ;
  bool _match_x1020 = kk_integer_lte_borrow(lo,hi,kk_context()); /*bool*/;
  if (_match_x1020) {
    kk_std_core_types__list _trmc_x10108 = kk_datatype_null(); /*list<int>*/;
    kk_std_core_types__list _trmc_x10109;
    kk_box_t _x_x1342;
    kk_integer_t _x_x1343 = kk_integer_dup(lo, _ctx); /*int*/
    _x_x1342 = kk_integer_box(_x_x1343, _ctx); /*82*/
    _trmc_x10109 = kk_std_core_types__new_Cons(kk_reuse_null, 0, _x_x1342, _trmc_x10108, _ctx); /*list<int>*/
    kk_field_addr_t _b_x441_446 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10109, _ctx)->tail, _ctx); /*@field-addr<list<int>>*/;
    { // tailcall
      kk_integer_t _x_x1344 = kk_integer_add_small_const(lo, 1, _ctx); /*int*/
      kk_std_core_types__cctx _x_x1345 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10109, _ctx)),_b_x441_446,kk_context()); /*ctx<0>*/
      lo = _x_x1344;
      _acc = _x_x1345;
      goto kk__tailcall;
    }
  }
  {
    kk_integer_drop(lo, _ctx);
    kk_integer_drop(hi, _ctx);
    kk_box_t _x_x1346 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1346, KK_OWNED, _ctx);
  }
}
 
// Returns an integer list of increasing elements from `lo`  to `hi`
// (including both `lo`  and `hi` ).
// If `lo > hi`  the function returns the empty list.

kk_std_core_types__list kk_std_core_list_list(kk_integer_t lo_0, kk_integer_t hi_0, kk_context_t* _ctx) { /* (lo : int, hi : int) -> list<int> */ 
  kk_std_core_types__cctx _x_x1347 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_list(lo_0, hi_0, _x_x1347, _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_map_10317(kk_std_core_types__cctx _acc, kk_function_t f, kk_std_core_types__list xx, kk_box_t _trmc_x10110, kk_context_t* _ctx) { /* forall<a,b,e> (ctx<list<b>>, f : (a) -> e b, xx : list<a>, b) -> e list<b> */ 
  kk_std_core_types__list _trmc_x10111 = kk_datatype_null(); /*list<3010>*/;
  kk_std_core_types__list _trmc_x10112 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), _trmc_x10110, _trmc_x10111, _ctx); /*list<3010>*/;
  kk_field_addr_t _b_x457_460 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10112, _ctx)->tail, _ctx); /*@field-addr<list<3010>>*/;
  kk_std_core_types__cctx _x_x1348 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10112, _ctx)),_b_x457_460,kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_map(xx, f, _x_x1348, _ctx);
}
 
// Apply a function `f`  to each element of the input list in sequence.


// lift anonymous function
struct kk_std_core_list__trmc_map_fun1352__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list__trmc_map_fun1352(kk_function_t _fself, kk_box_t _b_x465, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_map_fun1352(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_map_fun1352__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_map_fun1352__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_map_fun1352, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_map_fun1352(kk_function_t _fself, kk_box_t _b_x465, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_map_fun1352__t* _self = kk_function_as(struct kk_std_core_list__trmc_map_fun1352__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<3010>> */
  kk_function_t f_0 = _self->f_0; /* (3009) -> 3011 3010 */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<3009> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  kk_box_t _trmc_x10110_0_483 = _b_x465; /*3010*/;
  kk_std_core_types__list _x_x1353 = kk_std_core_list__mlift_trmc_map_10317(_acc_0, f_0, xx_0, _trmc_x10110_0_483, _ctx); /*list<3010>*/
  return kk_std_core_types__list_box(_x_x1353, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_map(kk_std_core_types__list xs, kk_function_t f_0, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, f : (a) -> e b, ctx<list<b>>) -> e list<b> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1349 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1349->head;
    kk_std_core_types__list xx_0 = _con_x1349->tail;
    kk_reuse_t _ru_x1093 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x1093 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_box_t x_0_10388;
    kk_function_t _x_x1350 = kk_function_dup(f_0, _ctx); /*(3009) -> 3011 3010*/
    x_0_10388 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x1350, (_x_x1350, x, _ctx), _ctx); /*3010*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1093,kk_context());
      kk_box_drop(x_0_10388, _ctx);
      kk_box_t _x_x1351 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_map_fun1352(_acc_0, f_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1351, KK_OWNED, _ctx);
    }
    {
      kk_std_core_types__list _trmc_x10111_0 = kk_datatype_null(); /*list<3010>*/;
      kk_std_core_types__list _trmc_x10112_0 = kk_std_core_types__new_Cons(_ru_x1093, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_0_10388, _trmc_x10111_0, _ctx); /*list<3010>*/;
      kk_field_addr_t _b_x471_477 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10112_0, _ctx)->tail, _ctx); /*@field-addr<list<3010>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1354 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10112_0, _ctx)),_b_x471_477,kk_context()); /*ctx<0>*/
        xs = xx_0;
        _acc_0 = _x_x1354;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1355 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1355, KK_OWNED, _ctx);
  }
}
 
// Apply a function `f`  to each element of the input list in sequence.

kk_std_core_types__list kk_std_core_list_map(kk_std_core_types__list xs_0, kk_function_t f_1, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, f : (a) -> e b) -> e list<b> */ 
  kk_std_core_types__cctx _x_x1356 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_map(xs_0, f_1, _x_x1356, _ctx);
}
 
// Create a list of characters from `lo`  to `hi`  (including `hi`).


// lift anonymous function
struct kk_std_core_list_char_fs_list_fun1359__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_list_char_fs_list_fun1359(kk_function_t _fself, kk_box_t _b_x486, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_char_fs_new_list_fun1359(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_list_char_fs_list_fun1359, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_list_char_fs_list_fun1359(kk_function_t _fself, kk_box_t _b_x486, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_char_t _x_x1360;
  kk_integer_t _x_x1361 = kk_integer_unbox(_b_x486, _ctx); /*int*/
  _x_x1360 = kk_integer_clamp32(_x_x1361,kk_context()); /*char*/
  return kk_char_box(_x_x1360, _ctx);
}

kk_std_core_types__list kk_std_core_list_char_fs_list(kk_char_t lo, kk_char_t hi, kk_context_t* _ctx) { /* (lo : char, hi : char) -> list<char> */ 
  kk_std_core_types__list _b_x484_487;
  kk_integer_t _x_x1357 = kk_integer_from_int(lo,kk_context()); /*int*/
  kk_integer_t _x_x1358 = kk_integer_from_int(hi,kk_context()); /*int*/
  _b_x484_487 = kk_std_core_list_list(_x_x1357, _x_x1358, _ctx); /*list<int>*/
  return kk_std_core_list_map(_b_x484_487, kk_std_core_list_char_fs_new_list_fun1359(_ctx), _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list_function_fs__mlift_trmc_list_10318(kk_std_core_types__cctx _acc, kk_function_t f, kk_integer_t hi, kk_integer_t lo, kk_box_t _trmc_x10113, kk_context_t* _ctx) { /* forall<a,e> (ctx<list<a>>, f : (int) -> e a, hi : int, lo : int, a) -> e list<a> */ 
  kk_std_core_types__list _trmc_x10114 = kk_datatype_null(); /*list<2811>*/;
  kk_std_core_types__list _trmc_x10115 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), _trmc_x10113, _trmc_x10114, _ctx); /*list<2811>*/;
  kk_field_addr_t _b_x494_497 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10115, _ctx)->tail, _ctx); /*@field-addr<list<2811>>*/;
  kk_integer_t _x_x1362 = kk_integer_add_small_const(lo, 1, _ctx); /*int*/
  kk_std_core_types__cctx _x_x1363 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10115, _ctx)),_b_x494_497,kk_context()); /*ctx<0>*/
  return kk_std_core_list_function_fs__trmc_list(_x_x1362, hi, f, _x_x1363, _ctx);
}
 
// Applies a function `f` to list of increasing elements from `lo`  to `hi`
// (including both `lo`  and `hi` ).
// If `lo > hi`  the function returns the empty list.


// lift anonymous function
struct kk_std_core_list_function_fs__trmc_list_fun1367__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_integer_t hi_0;
  kk_integer_t lo_0;
};
static kk_box_t kk_std_core_list_function_fs__trmc_list_fun1367(kk_function_t _fself, kk_box_t _b_x502, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_function_fs__new_trmc_list_fun1367(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_integer_t hi_0, kk_integer_t lo_0, kk_context_t* _ctx) {
  struct kk_std_core_list_function_fs__trmc_list_fun1367__t* _self = kk_function_alloc_as(struct kk_std_core_list_function_fs__trmc_list_fun1367__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_function_fs__trmc_list_fun1367, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->hi_0 = hi_0;
  _self->lo_0 = lo_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_function_fs__trmc_list_fun1367(kk_function_t _fself, kk_box_t _b_x502, kk_context_t* _ctx) {
  struct kk_std_core_list_function_fs__trmc_list_fun1367__t* _self = kk_function_as(struct kk_std_core_list_function_fs__trmc_list_fun1367__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<2811>> */
  kk_function_t f_0 = _self->f_0; /* (int) -> 2812 2811 */
  kk_integer_t hi_0 = _self->hi_0; /* int */
  kk_integer_t lo_0 = _self->lo_0; /* int */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_integer_dup(hi_0, _ctx);kk_integer_dup(lo_0, _ctx);}, {}, _ctx)
  kk_box_t _trmc_x10113_0_520 = _b_x502; /*2811*/;
  kk_std_core_types__list _x_x1368 = kk_std_core_list_function_fs__mlift_trmc_list_10318(_acc_0, f_0, hi_0, lo_0, _trmc_x10113_0_520, _ctx); /*list<2811>*/
  return kk_std_core_types__list_box(_x_x1368, _ctx);
}

kk_std_core_types__list kk_std_core_list_function_fs__trmc_list(kk_integer_t lo_0, kk_integer_t hi_0, kk_function_t f_0, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,e> (lo : int, hi : int, f : (int) -> e a, ctx<list<a>>) -> e list<a> */ 
  kk__tailcall: ;
  bool _match_x1017 = kk_integer_lte_borrow(lo_0,hi_0,kk_context()); /*bool*/;
  if (_match_x1017) {
    kk_box_t x_10391;
    kk_function_t _x_x1365 = kk_function_dup(f_0, _ctx); /*(int) -> 2812 2811*/
    kk_integer_t _x_x1364 = kk_integer_dup(lo_0, _ctx); /*int*/
    x_10391 = kk_function_call(kk_box_t, (kk_function_t, kk_integer_t, kk_context_t*), _x_x1365, (_x_x1365, _x_x1364, _ctx), _ctx); /*2811*/
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_10391, _ctx);
      kk_box_t _x_x1366 = kk_std_core_hnd_yield_extend(kk_std_core_list_function_fs__new_trmc_list_fun1367(_acc_0, f_0, hi_0, lo_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1366, KK_OWNED, _ctx);
    }
    {
      kk_std_core_types__list _trmc_x10114_0 = kk_datatype_null(); /*list<2811>*/;
      kk_std_core_types__list _trmc_x10115_0 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_10391, _trmc_x10114_0, _ctx); /*list<2811>*/;
      kk_field_addr_t _b_x508_514 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10115_0, _ctx)->tail, _ctx); /*@field-addr<list<2811>>*/;
      { // tailcall
        kk_integer_t _x_x1369 = kk_integer_add_small_const(lo_0, 1, _ctx); /*int*/
        kk_std_core_types__cctx _x_x1370 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10115_0, _ctx)),_b_x508_514,kk_context()); /*ctx<0>*/
        lo_0 = _x_x1369;
        _acc_0 = _x_x1370;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_integer_drop(lo_0, _ctx);
    kk_integer_drop(hi_0, _ctx);
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1371 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1371, KK_OWNED, _ctx);
  }
}
 
// Applies a function `f` to list of increasing elements from `lo`  to `hi`
// (including both `lo`  and `hi` ).
// If `lo > hi`  the function returns the empty list.

kk_std_core_types__list kk_std_core_list_function_fs_list(kk_integer_t lo_1, kk_integer_t hi_1, kk_function_t f_1, kk_context_t* _ctx) { /* forall<a,e> (lo : int, hi : int, f : (int) -> e a) -> e list<a> */ 
  kk_std_core_types__cctx _x_x1372 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list_function_fs__trmc_list(lo_1, hi_1, f_1, _x_x1372, _ctx);
}
 
// Returns an integer list of increasing elements from `lo`  to `hi` with stride `stride`.
// If `lo > hi`  the function returns the empty list.

kk_std_core_types__list kk_std_core_list_stride_fs__trmc_list(kk_integer_t lo, kk_integer_t hi, kk_integer_t stride, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* (lo : int, hi : int, stride : int, ctx<list<int>>) -> list<int> */ 
  kk__tailcall: ;
  bool _match_x1016 = kk_integer_lte_borrow(lo,hi,kk_context()); /*bool*/;
  if (_match_x1016) {
    kk_std_core_types__list _trmc_x10116 = kk_datatype_null(); /*list<int>*/;
    kk_std_core_types__list _trmc_x10117;
    kk_box_t _x_x1373;
    kk_integer_t _x_x1374 = kk_integer_dup(lo, _ctx); /*int*/
    _x_x1373 = kk_integer_box(_x_x1374, _ctx); /*82*/
    _trmc_x10117 = kk_std_core_types__new_Cons(kk_reuse_null, 0, _x_x1373, _trmc_x10116, _ctx); /*list<int>*/
    kk_field_addr_t _b_x530_535 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10117, _ctx)->tail, _ctx); /*@field-addr<list<int>>*/;
    { // tailcall
      kk_integer_t _x_x1375;
      kk_integer_t _x_x1376 = kk_integer_dup(stride, _ctx); /*int*/
      _x_x1375 = kk_integer_add(lo,_x_x1376,kk_context()); /*int*/
      kk_std_core_types__cctx _x_x1377 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10117, _ctx)),_b_x530_535,kk_context()); /*ctx<0>*/
      lo = _x_x1375;
      _acc = _x_x1377;
      goto kk__tailcall;
    }
  }
  {
    kk_integer_drop(stride, _ctx);
    kk_integer_drop(lo, _ctx);
    kk_integer_drop(hi, _ctx);
    kk_box_t _x_x1378 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1378, KK_OWNED, _ctx);
  }
}
 
// Returns an integer list of increasing elements from `lo`  to `hi` with stride `stride`.
// If `lo > hi`  the function returns the empty list.

kk_std_core_types__list kk_std_core_list_stride_fs_list(kk_integer_t lo_0, kk_integer_t hi_0, kk_integer_t stride_0, kk_context_t* _ctx) { /* (lo : int, hi : int, stride : int) -> list<int> */ 
  kk_std_core_types__cctx _x_x1379 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list_stride_fs__trmc_list(lo_0, hi_0, stride_0, _x_x1379, _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list_stridefunction_fs__mlift_trmc_list_10319(kk_std_core_types__cctx _acc, kk_function_t f, kk_integer_t hi, kk_integer_t lo, kk_integer_t stride, kk_box_t _trmc_x10118, kk_context_t* _ctx) { /* forall<a,e> (ctx<list<a>>, f : (int) -> e a, hi : int, lo : int, stride : int, a) -> e list<a> */ 
  kk_std_core_types__list _trmc_x10119 = kk_datatype_null(); /*list<2925>*/;
  kk_std_core_types__list _trmc_x10120 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), _trmc_x10118, _trmc_x10119, _ctx); /*list<2925>*/;
  kk_field_addr_t _b_x546_549 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10120, _ctx)->tail, _ctx); /*@field-addr<list<2925>>*/;
  kk_integer_t _x_x1380;
  kk_integer_t _x_x1381 = kk_integer_dup(stride, _ctx); /*int*/
  _x_x1380 = kk_integer_add(lo,_x_x1381,kk_context()); /*int*/
  kk_std_core_types__cctx _x_x1382 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10120, _ctx)),_b_x546_549,kk_context()); /*ctx<0>*/
  return kk_std_core_list_stridefunction_fs__trmc_list(_x_x1380, hi, stride, f, _x_x1382, _ctx);
}
 
// Returns an integer list of increasing elements from `lo`  to `hi` with stride `stride`.
// If `lo > hi`  the function returns the empty list.


// lift anonymous function
struct kk_std_core_list_stridefunction_fs__trmc_list_fun1386__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_integer_t hi_0;
  kk_integer_t lo_0;
  kk_integer_t stride_0;
};
static kk_box_t kk_std_core_list_stridefunction_fs__trmc_list_fun1386(kk_function_t _fself, kk_box_t _b_x554, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_stridefunction_fs__new_trmc_list_fun1386(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_integer_t hi_0, kk_integer_t lo_0, kk_integer_t stride_0, kk_context_t* _ctx) {
  struct kk_std_core_list_stridefunction_fs__trmc_list_fun1386__t* _self = kk_function_alloc_as(struct kk_std_core_list_stridefunction_fs__trmc_list_fun1386__t, 7, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_stridefunction_fs__trmc_list_fun1386, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->hi_0 = hi_0;
  _self->lo_0 = lo_0;
  _self->stride_0 = stride_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_stridefunction_fs__trmc_list_fun1386(kk_function_t _fself, kk_box_t _b_x554, kk_context_t* _ctx) {
  struct kk_std_core_list_stridefunction_fs__trmc_list_fun1386__t* _self = kk_function_as(struct kk_std_core_list_stridefunction_fs__trmc_list_fun1386__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<2925>> */
  kk_function_t f_0 = _self->f_0; /* (int) -> 2926 2925 */
  kk_integer_t hi_0 = _self->hi_0; /* int */
  kk_integer_t lo_0 = _self->lo_0; /* int */
  kk_integer_t stride_0 = _self->stride_0; /* int */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_integer_dup(hi_0, _ctx);kk_integer_dup(lo_0, _ctx);kk_integer_dup(stride_0, _ctx);}, {}, _ctx)
  kk_box_t _trmc_x10118_0_572 = _b_x554; /*2925*/;
  kk_std_core_types__list _x_x1387 = kk_std_core_list_stridefunction_fs__mlift_trmc_list_10319(_acc_0, f_0, hi_0, lo_0, stride_0, _trmc_x10118_0_572, _ctx); /*list<2925>*/
  return kk_std_core_types__list_box(_x_x1387, _ctx);
}

kk_std_core_types__list kk_std_core_list_stridefunction_fs__trmc_list(kk_integer_t lo_0, kk_integer_t hi_0, kk_integer_t stride_0, kk_function_t f_0, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,e> (lo : int, hi : int, stride : int, f : (int) -> e a, ctx<list<a>>) -> e list<a> */ 
  kk__tailcall: ;
  bool _match_x1014 = kk_integer_lte_borrow(lo_0,hi_0,kk_context()); /*bool*/;
  if (_match_x1014) {
    kk_box_t x_10394;
    kk_function_t _x_x1384 = kk_function_dup(f_0, _ctx); /*(int) -> 2926 2925*/
    kk_integer_t _x_x1383 = kk_integer_dup(lo_0, _ctx); /*int*/
    x_10394 = kk_function_call(kk_box_t, (kk_function_t, kk_integer_t, kk_context_t*), _x_x1384, (_x_x1384, _x_x1383, _ctx), _ctx); /*2925*/
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_10394, _ctx);
      kk_box_t _x_x1385 = kk_std_core_hnd_yield_extend(kk_std_core_list_stridefunction_fs__new_trmc_list_fun1386(_acc_0, f_0, hi_0, lo_0, stride_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1385, KK_OWNED, _ctx);
    }
    {
      kk_std_core_types__list _trmc_x10119_0 = kk_datatype_null(); /*list<2925>*/;
      kk_std_core_types__list _trmc_x10120_0 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_10394, _trmc_x10119_0, _ctx); /*list<2925>*/;
      kk_field_addr_t _b_x560_566 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10120_0, _ctx)->tail, _ctx); /*@field-addr<list<2925>>*/;
      { // tailcall
        kk_integer_t _x_x1388;
        kk_integer_t _x_x1389 = kk_integer_dup(stride_0, _ctx); /*int*/
        _x_x1388 = kk_integer_add(lo_0,_x_x1389,kk_context()); /*int*/
        kk_std_core_types__cctx _x_x1390 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10120_0, _ctx)),_b_x560_566,kk_context()); /*ctx<0>*/
        lo_0 = _x_x1388;
        _acc_0 = _x_x1390;
        goto kk__tailcall;
      }
    }
  }
  {
    kk_integer_drop(stride_0, _ctx);
    kk_integer_drop(lo_0, _ctx);
    kk_integer_drop(hi_0, _ctx);
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1391 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1391, KK_OWNED, _ctx);
  }
}
 
// Returns an integer list of increasing elements from `lo`  to `hi` with stride `stride`.
// If `lo > hi`  the function returns the empty list.

kk_std_core_types__list kk_std_core_list_stridefunction_fs_list(kk_integer_t lo_1, kk_integer_t hi_1, kk_integer_t stride_1, kk_function_t f_1, kk_context_t* _ctx) { /* forall<a,e> (lo : int, hi : int, stride : int, f : (int) -> e a) -> e list<a> */ 
  kk_std_core_types__cctx _x_x1392 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list_stridefunction_fs__trmc_list(lo_1, hi_1, stride_1, f_1, _x_x1392, _ctx);
}
 
// Apply a function `f` to each character in a string


// lift anonymous function
struct kk_std_core_list_string_fs_map_fun1393__t {
  struct kk_function_s _base;
  kk_function_t f;
};
static kk_box_t kk_std_core_list_string_fs_map_fun1393(kk_function_t _fself, kk_box_t _b_x575, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_string_fs_new_map_fun1393(kk_function_t f, kk_context_t* _ctx) {
  struct kk_std_core_list_string_fs_map_fun1393__t* _self = kk_function_alloc_as(struct kk_std_core_list_string_fs_map_fun1393__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_string_fs_map_fun1393, kk_context());
  _self->f = f;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_string_fs_map_fun1393(kk_function_t _fself, kk_box_t _b_x575, kk_context_t* _ctx) {
  struct kk_std_core_list_string_fs_map_fun1393__t* _self = kk_function_as(struct kk_std_core_list_string_fs_map_fun1393__t*, _fself, _ctx);
  kk_function_t f = _self->f; /* (char) -> 2966 char */
  kk_drop_match(_self, {kk_function_dup(f, _ctx);}, {}, _ctx)
  kk_char_t _x_x1394;
  kk_char_t _x_x1395 = kk_char_unbox(_b_x575, KK_OWNED, _ctx); /*char*/
  _x_x1394 = kk_function_call(kk_char_t, (kk_function_t, kk_char_t, kk_context_t*), f, (f, _x_x1395, _ctx), _ctx); /*char*/
  return kk_char_box(_x_x1394, _ctx);
}


// lift anonymous function
struct kk_std_core_list_string_fs_map_fun1397__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_list_string_fs_map_fun1397(kk_function_t _fself, kk_box_t _b_x579, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_string_fs_new_map_fun1397(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_list_string_fs_map_fun1397, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_list_string_fs_map_fun1397(kk_function_t _fself, kk_box_t _b_x579, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x1398;
  kk_std_core_types__list _x_x1399 = kk_std_core_types__list_unbox(_b_x579, KK_OWNED, _ctx); /*list<char>*/
  _x_x1398 = kk_std_core_string_listchar_fs_string(_x_x1399, _ctx); /*string*/
  return kk_string_box(_x_x1398);
}

kk_string_t kk_std_core_list_string_fs_map(kk_string_t s, kk_function_t f, kk_context_t* _ctx) { /* forall<e> (s : string, f : (char) -> e char) -> e string */ 
  kk_std_core_types__list _b_x573_576 = kk_std_core_string_list(s, _ctx); /*list<char>*/;
  kk_std_core_types__list x_10397 = kk_std_core_list_map(_b_x573_576, kk_std_core_list_string_fs_new_map_fun1393(f, _ctx), _ctx); /*list<char>*/;
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10397, _ctx);
    kk_box_t _x_x1396 = kk_std_core_hnd_yield_extend(kk_std_core_list_string_fs_new_map_fun1397(_ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x1396);
  }
  {
    return kk_std_core_string_listchar_fs_string(x_10397, _ctx);
  }
}
 
// Lookup the first element satisfying some predicate


// lift anonymous function
struct kk_std_core_list_lookup_fun1401__t {
  struct kk_function_s _base;
  kk_function_t pred;
};
static kk_std_core_types__maybe kk_std_core_list_lookup_fun1401(kk_function_t _fself, kk_box_t _b_x585, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_lookup_fun1401(kk_function_t pred, kk_context_t* _ctx) {
  struct kk_std_core_list_lookup_fun1401__t* _self = kk_function_alloc_as(struct kk_std_core_list_lookup_fun1401__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_lookup_fun1401, kk_context());
  _self->pred = pred;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_list_lookup_fun1404__t {
  struct kk_function_s _base;
  kk_box_t _b_x585;
};
static kk_std_core_types__maybe kk_std_core_list_lookup_fun1404(kk_function_t _fself, bool _y_x10237, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_lookup_fun1404(kk_box_t _b_x585, kk_context_t* _ctx) {
  struct kk_std_core_list_lookup_fun1404__t* _self = kk_function_alloc_as(struct kk_std_core_list_lookup_fun1404__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_lookup_fun1404, kk_context());
  _self->_b_x585 = _b_x585;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_std_core_types__maybe kk_std_core_list_lookup_fun1404(kk_function_t _fself, bool _y_x10237, kk_context_t* _ctx) {
  struct kk_std_core_list_lookup_fun1404__t* _self = kk_function_as(struct kk_std_core_list_lookup_fun1404__t*, _fself, _ctx);
  kk_box_t _b_x585 = _self->_b_x585; /* 1860 */
  kk_drop_match(_self, {kk_box_dup(_b_x585, _ctx);}, {}, _ctx)
  if (_y_x10237) {
    kk_box_t _x_x1405;
    kk_std_core_types__tuple2 _match_x1011 = kk_std_core_types__tuple2_unbox(_b_x585, KK_OWNED, _ctx); /*(3159, 3160)*/;
    {
      kk_box_t _x_0 = _match_x1011.snd;
      kk_box_dup(_x_0, _ctx);
      kk_std_core_types__tuple2_drop(_match_x1011, _ctx);
      _x_x1405 = _x_0; /*3160*/
    }
    return kk_std_core_types__new_Just(_x_x1405, _ctx);
  }
  {
    kk_box_drop(_b_x585, _ctx);
    return kk_std_core_types__new_Nothing(_ctx);
  }
}


// lift anonymous function
struct kk_std_core_list_lookup_fun1407__t {
  struct kk_function_s _base;
  kk_function_t next_10400;
};
static kk_box_t kk_std_core_list_lookup_fun1407(kk_function_t _fself, kk_box_t _b_x582, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_lookup_fun1407(kk_function_t next_10400, kk_context_t* _ctx) {
  struct kk_std_core_list_lookup_fun1407__t* _self = kk_function_alloc_as(struct kk_std_core_list_lookup_fun1407__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_lookup_fun1407, kk_context());
  _self->next_10400 = next_10400;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_lookup_fun1407(kk_function_t _fself, kk_box_t _b_x582, kk_context_t* _ctx) {
  struct kk_std_core_list_lookup_fun1407__t* _self = kk_function_as(struct kk_std_core_list_lookup_fun1407__t*, _fself, _ctx);
  kk_function_t next_10400 = _self->next_10400; /* (bool) -> 3161 maybe<3160> */
  kk_drop_match(_self, {kk_function_dup(next_10400, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _x_x1408;
  bool _x_x1409 = kk_bool_unbox(_b_x582); /*bool*/
  _x_x1408 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, bool, kk_context_t*), next_10400, (next_10400, _x_x1409, _ctx), _ctx); /*maybe<3160>*/
  return kk_std_core_types__maybe_box(_x_x1408, _ctx);
}
static kk_std_core_types__maybe kk_std_core_list_lookup_fun1401(kk_function_t _fself, kk_box_t _b_x585, kk_context_t* _ctx) {
  struct kk_std_core_list_lookup_fun1401__t* _self = kk_function_as(struct kk_std_core_list_lookup_fun1401__t*, _fself, _ctx);
  kk_function_t pred = _self->pred; /* (3159) -> 3161 bool */
  kk_drop_match(_self, {kk_function_dup(pred, _ctx);}, {}, _ctx)
  bool x_10399;
  kk_box_t _x_x1402;
  kk_std_core_types__tuple2 _match_x1012;
  kk_box_t _x_x1403 = kk_box_dup(_b_x585, _ctx); /*1860*/
  _match_x1012 = kk_std_core_types__tuple2_unbox(_x_x1403, KK_OWNED, _ctx); /*(3159, 3160)*/
  {
    kk_box_t _x = _match_x1012.fst;
    kk_box_dup(_x, _ctx);
    kk_std_core_types__tuple2_drop(_match_x1012, _ctx);
    _x_x1402 = _x; /*3159*/
  }
  x_10399 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), pred, (pred, _x_x1402, _ctx), _ctx); /*bool*/
  kk_function_t next_10400 = kk_std_core_list_new_lookup_fun1404(_b_x585, _ctx); /*(bool) -> 3161 maybe<3160>*/;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x1406 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_lookup_fun1407(next_10400, _ctx), _ctx); /*3728*/
    return kk_std_core_types__maybe_unbox(_x_x1406, KK_OWNED, _ctx);
  }
  {
    return kk_function_call(kk_std_core_types__maybe, (kk_function_t, bool, kk_context_t*), next_10400, (next_10400, x_10399, _ctx), _ctx);
  }
}

kk_std_core_types__maybe kk_std_core_list_lookup(kk_std_core_types__list xs, kk_function_t pred, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<(a, b)>, pred : (a) -> e bool) -> e maybe<b> */ 
  return kk_std_core_list_foreach_while(xs, kk_std_core_list_new_lookup_fun1401(pred, _ctx), _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_map_while_10321(kk_std_core_types__cctx _acc, kk_function_t action, kk_std_core_types__list xx, kk_std_core_types__maybe _y_x10240, kk_context_t* _ctx) { /* forall<a,b,e> (ctx<list<b>>, action : (a) -> e maybe<b>, xx : list<a>, maybe<b>) -> e list<b> */ 
  if (kk_std_core_types__is_Just(_y_x10240, _ctx)) {
    kk_box_t y = _y_x10240._cons.Just.value;
    kk_std_core_types__list _trmc_x10121 = kk_datatype_null(); /*list<3222>*/;
    kk_std_core_types__list _trmc_x10122 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), y, _trmc_x10121, _ctx); /*list<3222>*/;
    kk_field_addr_t _b_x595_600 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10122, _ctx)->tail, _ctx); /*@field-addr<list<3222>>*/;
    kk_std_core_types__cctx _x_x1410 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10122, _ctx)),_b_x595_600,kk_context()); /*ctx<0>*/
    return kk_std_core_list__trmc_map_while(xx, action, _x_x1410, _ctx);
  }
  {
    kk_std_core_types__list_drop(xx, _ctx);
    kk_function_drop(action, _ctx);
    kk_box_t _x_x1411 = kk_cctx_apply(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1411, KK_OWNED, _ctx);
  }
}
 
// Invoke `action` on each element of a list while `action` returns `Just`


// lift anonymous function
struct kk_std_core_list__trmc_map_while_fun1416__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t action_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list__trmc_map_while_fun1416(kk_function_t _fself, kk_box_t _b_x609, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_map_while_fun1416(kk_std_core_types__cctx _acc_0, kk_function_t action_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_map_while_fun1416__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_map_while_fun1416__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_map_while_fun1416, kk_context());
  _self->_acc_0 = _acc_0;
  _self->action_0 = action_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_map_while_fun1416(kk_function_t _fself, kk_box_t _b_x609, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_map_while_fun1416__t* _self = kk_function_as(struct kk_std_core_list__trmc_map_while_fun1416__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<3222>> */
  kk_function_t action_0 = _self->action_0; /* (3221) -> 3223 maybe<3222> */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<3221> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(action_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  kk_std_core_types__maybe _y_x10240_0_629 = kk_std_core_types__maybe_unbox(_b_x609, KK_OWNED, _ctx); /*maybe<3222>*/;
  kk_std_core_types__list _x_x1417 = kk_std_core_list__mlift_trmc_map_while_10321(_acc_0, action_0, xx_0, _y_x10240_0_629, _ctx); /*list<3222>*/
  return kk_std_core_types__list_box(_x_x1417, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_map_while(kk_std_core_types__list xs, kk_function_t action_0, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, action : (a) -> e maybe<b>, ctx<list<b>>) -> e list<b> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    kk_function_drop(action_0, _ctx);
    kk_box_t _x_x1412 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1412, KK_OWNED, _ctx);
  }
  {
    struct kk_std_core_types_Cons* _con_x1413 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1413->head;
    kk_std_core_types__list xx_0 = _con_x1413->tail;
    kk_reuse_t _ru_x1094 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x1094 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_std_core_types__maybe x_0_10403;
    kk_function_t _x_x1414 = kk_function_dup(action_0, _ctx); /*(3221) -> 3223 maybe<3222>*/
    x_0_10403 = kk_function_call(kk_std_core_types__maybe, (kk_function_t, kk_box_t, kk_context_t*), _x_x1414, (_x_x1414, x, _ctx), _ctx); /*maybe<3222>*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1094,kk_context());
      kk_std_core_types__maybe_drop(x_0_10403, _ctx);
      kk_box_t _x_x1415 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_map_while_fun1416(_acc_0, action_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1415, KK_OWNED, _ctx);
    }
    if (kk_std_core_types__is_Just(x_0_10403, _ctx)) {
      kk_box_t y_0 = x_0_10403._cons.Just.value;
      kk_std_core_types__list _trmc_x10121_0 = kk_datatype_null(); /*list<3222>*/;
      kk_std_core_types__list _trmc_x10122_0 = kk_std_core_types__new_Cons(_ru_x1094, kk_field_index_of(struct kk_std_core_types_Cons, tail), y_0, _trmc_x10121_0, _ctx); /*list<3222>*/;
      kk_field_addr_t _b_x615_623 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10122_0, _ctx)->tail, _ctx); /*@field-addr<list<3222>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1418 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10122_0, _ctx)),_b_x615_623,kk_context()); /*ctx<0>*/
        xs = xx_0;
        _acc_0 = _x_x1418;
        goto kk__tailcall;
      }
    }
    {
      kk_reuse_drop(_ru_x1094,kk_context());
      kk_std_core_types__list_drop(xx_0, _ctx);
      kk_function_drop(action_0, _ctx);
      kk_box_t _x_x1419 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
      return kk_std_core_types__list_unbox(_x_x1419, KK_OWNED, _ctx);
    }
  }
}
 
// Invoke `action` on each element of a list while `action` returns `Just`

kk_std_core_types__list kk_std_core_list_map_while(kk_std_core_types__list xs_0, kk_function_t action_1, kk_context_t* _ctx) { /* forall<a,b,e> (xs : list<a>, action : (a) -> e maybe<b>) -> e list<b> */ 
  kk_std_core_types__cctx _x_x1420 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_map_while(xs_0, action_1, _x_x1420, _ctx);
}
 
// Returns the largest element of a list of integers (or `default` (=`0`) for the empty list)


// lift anonymous function
struct kk_std_core_list_maximum_fun1423__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_list_maximum_fun1423(kk_function_t _fself, kk_box_t _b_x635, kk_box_t _b_x636, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_maximum_fun1423(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_list_maximum_fun1423, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_list_maximum_fun1423(kk_function_t _fself, kk_box_t _b_x635, kk_box_t _b_x636, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x1424;
  kk_integer_t _x_x1425 = kk_integer_unbox(_b_x635, _ctx); /*int*/
  kk_integer_t _x_x1426 = kk_integer_unbox(_b_x636, _ctx); /*int*/
  _x_x1424 = kk_std_core_int_max(_x_x1425, _x_x1426, _ctx); /*int*/
  return kk_integer_box(_x_x1424, _ctx);
}

kk_integer_t kk_std_core_list_maximum(kk_std_core_types__list xs, kk_std_core_types__optional kkloc_default, kk_context_t* _ctx) { /* (xs : list<int>, default : ? int) -> int */ 
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    if (kk_std_core_types__is_Optional(kkloc_default, _ctx)) {
      kk_box_t _box_x630 = kkloc_default._cons._Optional.value;
      kk_integer_t _uniq_default_3236 = kk_integer_unbox(_box_x630, _ctx);
      kk_integer_dup(_uniq_default_3236, _ctx);
      kk_std_core_types__optional_drop(kkloc_default, _ctx);
      return _uniq_default_3236;
    }
    {
      kk_std_core_types__optional_drop(kkloc_default, _ctx);
      return kk_integer_from_small(0);
    }
  }
  {
    struct kk_std_core_types_Cons* _con_x1421 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x631 = _con_x1421->head;
    kk_std_core_types__list xx = _con_x1421->tail;
    kk_integer_t x = kk_integer_unbox(_box_x631, _ctx);
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_integer_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_std_core_types__optional_drop(kkloc_default, _ctx);
    kk_box_t _x_x1422 = kk_std_core_list_foldl(xx, kk_integer_box(x, _ctx), kk_std_core_list_new_maximum_fun1423(_ctx), _ctx); /*2053*/
    return kk_integer_unbox(_x_x1422, _ctx);
  }
}
 
// Returns the smallest element of a list of integers (or `default` (=`0`) for the empty list)


// lift anonymous function
struct kk_std_core_list_minimum_fun1429__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_list_minimum_fun1429(kk_function_t _fself, kk_box_t _b_x645, kk_box_t _b_x646, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_minimum_fun1429(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_list_minimum_fun1429, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_list_minimum_fun1429(kk_function_t _fself, kk_box_t _b_x645, kk_box_t _b_x646, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x1430;
  kk_integer_t _x_x1431 = kk_integer_unbox(_b_x645, _ctx); /*int*/
  kk_integer_t _x_x1432 = kk_integer_unbox(_b_x646, _ctx); /*int*/
  _x_x1430 = kk_std_core_int_min(_x_x1431, _x_x1432, _ctx); /*int*/
  return kk_integer_box(_x_x1430, _ctx);
}

kk_integer_t kk_std_core_list_minimum(kk_std_core_types__list xs, kk_std_core_types__optional kkloc_default, kk_context_t* _ctx) { /* (xs : list<int>, default : ? int) -> int */ 
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    if (kk_std_core_types__is_Optional(kkloc_default, _ctx)) {
      kk_box_t _box_x640 = kkloc_default._cons._Optional.value;
      kk_integer_t _uniq_default_3266 = kk_integer_unbox(_box_x640, _ctx);
      kk_integer_dup(_uniq_default_3266, _ctx);
      kk_std_core_types__optional_drop(kkloc_default, _ctx);
      return _uniq_default_3266;
    }
    {
      kk_std_core_types__optional_drop(kkloc_default, _ctx);
      return kk_integer_from_small(0);
    }
  }
  {
    struct kk_std_core_types_Cons* _con_x1427 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x641 = _con_x1427->head;
    kk_std_core_types__list xx = _con_x1427->tail;
    kk_integer_t x = kk_integer_unbox(_box_x641, _ctx);
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_integer_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_std_core_types__optional_drop(kkloc_default, _ctx);
    kk_box_t _x_x1428 = kk_std_core_list_foldl(xx, kk_integer_box(x, _ctx), kk_std_core_list_new_minimum_fun1429(_ctx), _ctx); /*2053*/
    return kk_integer_unbox(_x_x1428, _ctx);
  }
}
 
// monadic lift

kk_std_core_types__tuple2 kk_std_core_list__mlift_partition_acc_10322(kk_std_core_types__cctx acc1, kk_std_core_types__cctx acc2, kk_function_t pred, kk_box_t x, kk_std_core_types__list xx, bool _y_x10245, kk_context_t* _ctx) { /* forall<a,e> (acc1 : ctx<list<a>>, acc2 : ctx<list<a>>, pred : (a) -> e bool, x : a, xx : list<a>, bool) -> e (list<a>, list<a>) */ 
  if (_y_x10245) {
    kk_std_core_types__list _cctx_x3377;
    kk_std_core_types__list _x_x1433 = kk_datatype_null(); /*list<3429>*/
    _cctx_x3377 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), x, _x_x1433, _ctx); /*list<3429>*/
    kk_field_addr_t _cctx_x3378 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x3377, _ctx)->tail, _ctx); /*@field-addr<list<3429>>*/;
    kk_std_core_types__list _b_x656_666 = _cctx_x3377; /*list<3429>*/;
    kk_field_addr_t _b_x657_667 = _cctx_x3378; /*@field-addr<list<3429>>*/;
    kk_std_core_types__cctx _own_x1007;
    kk_std_core_types__cctx _x_x1434 = kk_cctx_create((kk_std_core_types__list_box(_b_x656_666, _ctx)),_b_x657_667,kk_context()); /*cctx<0,1>*/
    _own_x1007 = kk_cctx_compose(acc1,_x_x1434,kk_context()); /*cctx<371,373>*/
    kk_std_core_types__tuple2 _brw_x1008 = kk_std_core_list_partition_acc(xx, pred, _own_x1007, acc2, _ctx); /*(list<414>, list<414>)*/;
    kk_function_drop(pred, _ctx);
    return _brw_x1008;
  }
  {
    kk_std_core_types__list _cctx_x3420;
    kk_std_core_types__list _x_x1435 = kk_datatype_null(); /*list<3429>*/
    _cctx_x3420 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), x, _x_x1435, _ctx); /*list<3429>*/
    kk_field_addr_t _cctx_x3421 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x3420, _ctx)->tail, _ctx); /*@field-addr<list<3429>>*/;
    kk_std_core_types__list _b_x664_668 = _cctx_x3420; /*list<3429>*/;
    kk_field_addr_t _b_x665_669 = _cctx_x3421; /*@field-addr<list<3429>>*/;
    kk_std_core_types__cctx _own_x1005;
    kk_std_core_types__cctx _x_x1436 = kk_cctx_create((kk_std_core_types__list_box(_b_x664_668, _ctx)),_b_x665_669,kk_context()); /*cctx<0,1>*/
    _own_x1005 = kk_cctx_compose(acc2,_x_x1436,kk_context()); /*cctx<371,373>*/
    kk_std_core_types__tuple2 _brw_x1006 = kk_std_core_list_partition_acc(xx, pred, acc1, _own_x1005, _ctx); /*(list<414>, list<414>)*/;
    kk_function_drop(pred, _ctx);
    return _brw_x1006;
  }
}


// lift anonymous function
struct kk_std_core_list_partition_acc_fun1444__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx acc1_0;
  kk_std_core_types__cctx acc2_0;
  kk_function_t pred_0;
  kk_box_t x_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list_partition_acc_fun1444(kk_function_t _fself, kk_box_t _b_x677, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_partition_acc_fun1444(kk_std_core_types__cctx acc1_0, kk_std_core_types__cctx acc2_0, kk_function_t pred_0, kk_box_t x_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list_partition_acc_fun1444__t* _self = kk_function_alloc_as(struct kk_std_core_list_partition_acc_fun1444__t, 8, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_partition_acc_fun1444, kk_context());
  _self->acc1_0 = acc1_0;
  _self->acc2_0 = acc2_0;
  _self->pred_0 = pred_0;
  _self->x_0 = x_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_partition_acc_fun1444(kk_function_t _fself, kk_box_t _b_x677, kk_context_t* _ctx) {
  struct kk_std_core_list_partition_acc_fun1444__t* _self = kk_function_as(struct kk_std_core_list_partition_acc_fun1444__t*, _fself, _ctx);
  kk_std_core_types__cctx acc1_0 = _self->acc1_0; /* ctx<list<3429>> */
  kk_std_core_types__cctx acc2_0 = _self->acc2_0; /* ctx<list<3429>> */
  kk_function_t pred_0 = _self->pred_0; /* (3429) -> 3430 bool */
  kk_box_t x_0 = _self->x_0; /* 3429 */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<3429> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(acc1_0, _ctx);kk_std_core_types__cctx_dup(acc2_0, _ctx);kk_function_dup(pred_0, _ctx);kk_box_dup(x_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  bool _y_x10245_0_705 = kk_bool_unbox(_b_x677); /*bool*/;
  kk_std_core_types__tuple2 _x_x1445 = kk_std_core_list__mlift_partition_acc_10322(acc1_0, acc2_0, pred_0, x_0, xx_0, _y_x10245_0_705, _ctx); /*(list<3429>, list<3429>)*/
  return kk_std_core_types__tuple2_box(_x_x1445, _ctx);
}

kk_std_core_types__tuple2 kk_std_core_list_partition_acc(kk_std_core_types__list xs, kk_function_t pred_0, kk_std_core_types__cctx acc1_0, kk_std_core_types__cctx acc2_0, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, pred : (a) -> e bool, acc1 : ctx<list<a>>, acc2 : ctx<list<a>>) -> e (list<a>, list<a>) */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    kk_std_core_types__list _b_x674_694;
    kk_box_t _x_x1437 = kk_cctx_apply(acc1_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    _b_x674_694 = kk_std_core_types__list_unbox(_x_x1437, KK_OWNED, _ctx); /*list<3429>*/
    kk_std_core_types__list _b_x675_695;
    kk_box_t _x_x1438 = kk_cctx_apply(acc2_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    _b_x675_695 = kk_std_core_types__list_unbox(_x_x1438, KK_OWNED, _ctx); /*list<3429>*/
    return kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(_b_x674_694, _ctx), kk_std_core_types__list_box(_b_x675_695, _ctx), _ctx);
  }
  {
    struct kk_std_core_types_Cons* _con_x1439 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x_0 = _con_x1439->head;
    kk_std_core_types__list xx_0 = _con_x1439->tail;
    kk_reuse_t _ru_x1097 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x1097 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_box_dup(x_0, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    bool x_1_10406;
    kk_function_t _x_x1441 = kk_function_dup(pred_0, _ctx); /*(3429) -> 3430 bool*/
    kk_box_t _x_x1440 = kk_box_dup(x_0, _ctx); /*3429*/
    x_1_10406 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), _x_x1441, (_x_x1441, _x_x1440, _ctx), _ctx); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1097,kk_context());
      kk_box_t _x_x1442;
      kk_function_t _x_x1443;
      kk_function_dup(pred_0, _ctx);
      _x_x1443 = kk_std_core_list_new_partition_acc_fun1444(acc1_0, acc2_0, pred_0, x_0, xx_0, _ctx); /*(3727) -> 3729 3728*/
      _x_x1442 = kk_std_core_hnd_yield_extend(_x_x1443, _ctx); /*3728*/
      return kk_std_core_types__tuple2_unbox(_x_x1442, KK_OWNED, _ctx);
    }
    if (x_1_10406) {
      kk_std_core_types__list _cctx_x3377_0;
      kk_std_core_types__list _x_x1446 = kk_datatype_null(); /*list<3429>*/
      _cctx_x3377_0 = kk_std_core_types__new_Cons(_ru_x1097, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_0, _x_x1446, _ctx); /*list<3429>*/
      kk_field_addr_t _cctx_x3378_0 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x3377_0, _ctx)->tail, _ctx); /*@field-addr<list<3429>>*/;
      kk_std_core_types__list _b_x684_701 = _cctx_x3377_0; /*list<3429>*/;
      kk_field_addr_t _b_x685_702 = _cctx_x3378_0; /*@field-addr<list<3429>>*/;
      kk_std_core_types__cctx _own_x1004;
      kk_std_core_types__cctx _x_x1447 = kk_cctx_create((kk_std_core_types__list_box(_b_x684_701, _ctx)),_b_x685_702,kk_context()); /*cctx<0,1>*/
      _own_x1004 = kk_cctx_compose(acc1_0,_x_x1447,kk_context()); /*cctx<371,373>*/
      { // tailcall
        xs = xx_0;
        acc1_0 = _own_x1004;
        goto kk__tailcall;
      }
    }
    {
      kk_std_core_types__list _cctx_x3420_0;
      kk_std_core_types__list _x_x1448 = kk_datatype_null(); /*list<3429>*/
      _cctx_x3420_0 = kk_std_core_types__new_Cons(_ru_x1097, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_0, _x_x1448, _ctx); /*list<3429>*/
      kk_field_addr_t _cctx_x3421_0 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x3420_0, _ctx)->tail, _ctx); /*@field-addr<list<3429>>*/;
      kk_std_core_types__list _b_x692_703 = _cctx_x3420_0; /*list<3429>*/;
      kk_field_addr_t _b_x693_704 = _cctx_x3421_0; /*@field-addr<list<3429>>*/;
      kk_std_core_types__cctx _own_x1003;
      kk_std_core_types__cctx _x_x1449 = kk_cctx_create((kk_std_core_types__list_box(_b_x692_703, _ctx)),_b_x693_704,kk_context()); /*cctx<0,1>*/
      _own_x1003 = kk_cctx_compose(acc2_0,_x_x1449,kk_context()); /*cctx<371,373>*/
      { // tailcall
        xs = xx_0;
        acc2_0 = _own_x1003;
        goto kk__tailcall;
      }
    }
  }
}
 
// Remove those elements of a list that satisfy the given predicate `pred`.
// For example: `remove([1,2,3],odd?) == [2]`


// lift anonymous function
struct kk_std_core_list_remove_fun1450__t {
  struct kk_function_s _base;
  kk_function_t pred;
};
static bool kk_std_core_list_remove_fun1450(kk_function_t _fself, kk_box_t x, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_remove_fun1450(kk_function_t pred, kk_context_t* _ctx) {
  struct kk_std_core_list_remove_fun1450__t* _self = kk_function_alloc_as(struct kk_std_core_list_remove_fun1450__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_remove_fun1450, kk_context());
  _self->pred = pred;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_list_remove_fun1452__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_list_remove_fun1452(kk_function_t _fself, kk_box_t _b_x707, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_remove_fun1452(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_list_remove_fun1452, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_list_remove_fun1452(kk_function_t _fself, kk_box_t _b_x707, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _y_x10251_709 = kk_bool_unbox(_b_x707); /*bool*/;
  bool _x_x1453;
  if (_y_x10251_709) {
    _x_x1453 = false; /*bool*/
  }
  else {
    _x_x1453 = true; /*bool*/
  }
  return kk_bool_box(_x_x1453);
}
static bool kk_std_core_list_remove_fun1450(kk_function_t _fself, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_list_remove_fun1450__t* _self = kk_function_as(struct kk_std_core_list_remove_fun1450__t*, _fself, _ctx);
  kk_function_t pred = _self->pred; /* (3506) -> 3507 bool */
  kk_drop_match(_self, {kk_function_dup(pred, _ctx);}, {}, _ctx)
  bool x_0_10409 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), pred, (pred, x, _ctx), _ctx); /*bool*/;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x1451 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_remove_fun1452(_ctx), _ctx); /*3728*/
    return kk_bool_unbox(_x_x1451);
  }
  if (x_0_10409) {
    return false;
  }
  {
    return true;
  }
}

kk_std_core_types__list kk_std_core_list_remove(kk_std_core_types__list xs, kk_function_t pred, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, pred : (a) -> e bool) -> e list<a> */ 
  return kk_std_core_list_filter(xs, kk_std_core_list_new_remove_fun1450(pred, _ctx), _ctx);
}
 
// Create a list of `n` repeated elements `x`

kk_std_core_types__list kk_std_core_list__trmc_replicate(kk_box_t x, kk_integer_t n, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* forall<a> (x : a, n : int, ctx<list<a>>) -> list<a> */ 
  kk__tailcall: ;
  bool _match_x998 = kk_integer_gt_borrow(n,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x998) {
    kk_std_core_types__list _trmc_x10123 = kk_datatype_null(); /*list<3555>*/;
    kk_std_core_types__list _trmc_x10124;
    kk_box_t _x_x1454 = kk_box_dup(x, _ctx); /*3555*/
    _trmc_x10124 = kk_std_core_types__new_Cons(kk_reuse_null, 0, _x_x1454, _trmc_x10123, _ctx); /*list<3555>*/
    kk_field_addr_t _b_x715_720 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10124, _ctx)->tail, _ctx); /*@field-addr<list<3555>>*/;
    { // tailcall
      kk_integer_t _x_x1455 = kk_integer_add_small_const(n, -1, _ctx); /*int*/
      kk_std_core_types__cctx _x_x1456 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10124, _ctx)),_b_x715_720,kk_context()); /*ctx<0>*/
      n = _x_x1455;
      _acc = _x_x1456;
      goto kk__tailcall;
    }
  }
  {
    kk_box_drop(x, _ctx);
    kk_integer_drop(n, _ctx);
    kk_box_t _x_x1457 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1457, KK_OWNED, _ctx);
  }
}
 
// Create a list of `n` repeated elements `x`

kk_std_core_types__list kk_std_core_list_replicate(kk_box_t x_0, kk_integer_t n_0, kk_context_t* _ctx) { /* forall<a> (x : a, n : int) -> list<a> */ 
  kk_std_core_types__cctx _x_x1458 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_replicate(x_0, n_0, _x_x1458, _ctx);
}
 
// Concatenate all strings in a list in reverse order

kk_string_t kk_std_core_list_reverse_join(kk_std_core_types__list xs, kk_context_t* _ctx) { /* (xs : list<string>) -> string */ 
  kk_std_core_types__list xs_0_10045 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), xs, _ctx); /*list<string>*/;
  if (kk_std_core_types__is_Nil(xs_0_10045, _ctx)) {
    return kk_string_empty();
  }
  {
    struct kk_std_core_types_Cons* _con_x1460 = kk_std_core_types__as_Cons(xs_0_10045, _ctx);
    kk_box_t _box_x726 = _con_x1460->head;
    kk_std_core_types__list xx = _con_x1460->tail;
    kk_string_t x = kk_string_unbox(_box_x726);
    if kk_likely(kk_datatype_ptr_is_unique(xs_0_10045, _ctx)) {
      kk_datatype_ptr_free(xs_0_10045, _ctx);
    }
    else {
      kk_string_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs_0_10045, _ctx);
    }
    kk_string_t _x_x1461 = kk_string_empty(); /*string*/
    return kk_std_core_list__lift_joinsep_4797(_x_x1461, xx, x, _ctx);
  }
}
 
// Concatenate all strings in a list using a specific separator

kk_string_t kk_std_core_list_joinsep_fs_join(kk_std_core_types__list xs, kk_string_t sep, kk_context_t* _ctx) { /* (xs : list<string>, sep : string) -> string */ 
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    kk_string_drop(sep, _ctx);
    return kk_string_empty();
  }
  {
    struct kk_std_core_types_Cons* _con_x1464 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x727 = _con_x1464->head;
    kk_std_core_types__list xx = _con_x1464->tail;
    kk_string_t x = kk_string_unbox(_box_x727);
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_string_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    return kk_std_core_list__lift_joinsep_4797(sep, xx, x, _ctx);
  }
}
 
// monadic lift

kk_string_t kk_std_core_list__mlift_show_10324(kk_std_core_types__list _y_x10253, kk_context_t* _ctx) { /* forall<e> (list<string>) -> e string */ 
  kk_string_t _x_x1465;
  kk_define_string_literal(, _s_x1466, 1, "[", _ctx)
  _x_x1465 = kk_string_dup(_s_x1466, _ctx); /*string*/
  kk_string_t _x_x1467;
  kk_string_t _x_x1468;
  if (kk_std_core_types__is_Nil(_y_x10253, _ctx)) {
    _x_x1468 = kk_string_empty(); /*string*/
  }
  else {
    struct kk_std_core_types_Cons* _con_x1470 = kk_std_core_types__as_Cons(_y_x10253, _ctx);
    kk_box_t _box_x728 = _con_x1470->head;
    kk_std_core_types__list xx = _con_x1470->tail;
    kk_string_t x = kk_string_unbox(_box_x728);
    if kk_likely(kk_datatype_ptr_is_unique(_y_x10253, _ctx)) {
      kk_datatype_ptr_free(_y_x10253, _ctx);
    }
    else {
      kk_string_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(_y_x10253, _ctx);
    }
    kk_string_t _x_x1471;
    kk_define_string_literal(, _s_x1472, 1, ",", _ctx)
    _x_x1471 = kk_string_dup(_s_x1472, _ctx); /*string*/
    _x_x1468 = kk_std_core_list__lift_joinsep_4797(_x_x1471, xx, x, _ctx); /*string*/
  }
  kk_string_t _x_x1473;
  kk_define_string_literal(, _s_x1474, 1, "]", _ctx)
  _x_x1473 = kk_string_dup(_s_x1474, _ctx); /*string*/
  _x_x1467 = kk_std_core_types__lp__plus__plus__rp_(_x_x1468, _x_x1473, _ctx); /*string*/
  return kk_std_core_types__lp__plus__plus__rp_(_x_x1465, _x_x1467, _ctx);
}
 
// Show a list


// lift anonymous function
struct kk_std_core_list_show_fun1475__t {
  struct kk_function_s _base;
  kk_function_t _implicit_fs_show;
};
static kk_box_t kk_std_core_list_show_fun1475(kk_function_t _fself, kk_box_t _b_x731, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_show_fun1475(kk_function_t _implicit_fs_show, kk_context_t* _ctx) {
  struct kk_std_core_list_show_fun1475__t* _self = kk_function_alloc_as(struct kk_std_core_list_show_fun1475__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list_show_fun1475, kk_context());
  _self->_implicit_fs_show = _implicit_fs_show;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list_show_fun1475(kk_function_t _fself, kk_box_t _b_x731, kk_context_t* _ctx) {
  struct kk_std_core_list_show_fun1475__t* _self = kk_function_as(struct kk_std_core_list_show_fun1475__t*, _fself, _ctx);
  kk_function_t _implicit_fs_show = _self->_implicit_fs_show; /* (3643) -> 3644 string */
  kk_drop_match(_self, {kk_function_dup(_implicit_fs_show, _ctx);}, {}, _ctx)
  kk_string_t _x_x1476 = kk_function_call(kk_string_t, (kk_function_t, kk_box_t, kk_context_t*), _implicit_fs_show, (_implicit_fs_show, _b_x731, _ctx), _ctx); /*string*/
  return kk_string_box(_x_x1476);
}


// lift anonymous function
struct kk_std_core_list_show_fun1478__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_list_show_fun1478(kk_function_t _fself, kk_box_t _b_x736, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_show_fun1478(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_list_show_fun1478, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_list_show_fun1478(kk_function_t _fself, kk_box_t _b_x736, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_core_types__list _y_x10253_739 = kk_std_core_types__list_unbox(_b_x736, KK_OWNED, _ctx); /*list<string>*/;
  kk_string_t _x_x1479;
  kk_string_t _x_x1480;
  kk_define_string_literal(, _s_x1481, 1, "[", _ctx)
  _x_x1480 = kk_string_dup(_s_x1481, _ctx); /*string*/
  kk_string_t _x_x1482;
  kk_string_t _x_x1483;
  if (kk_std_core_types__is_Nil(_y_x10253_739, _ctx)) {
    _x_x1483 = kk_string_empty(); /*string*/
  }
  else {
    struct kk_std_core_types_Cons* _con_x1485 = kk_std_core_types__as_Cons(_y_x10253_739, _ctx);
    kk_box_t _box_x734 = _con_x1485->head;
    kk_std_core_types__list xx = _con_x1485->tail;
    kk_string_t x_0 = kk_string_unbox(_box_x734);
    if kk_likely(kk_datatype_ptr_is_unique(_y_x10253_739, _ctx)) {
      kk_datatype_ptr_free(_y_x10253_739, _ctx);
    }
    else {
      kk_string_dup(x_0, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(_y_x10253_739, _ctx);
    }
    kk_string_t _x_x1486;
    kk_define_string_literal(, _s_x1487, 1, ",", _ctx)
    _x_x1486 = kk_string_dup(_s_x1487, _ctx); /*string*/
    _x_x1483 = kk_std_core_list__lift_joinsep_4797(_x_x1486, xx, x_0, _ctx); /*string*/
  }
  kk_string_t _x_x1488;
  kk_define_string_literal(, _s_x1489, 1, "]", _ctx)
  _x_x1488 = kk_string_dup(_s_x1489, _ctx); /*string*/
  _x_x1482 = kk_std_core_types__lp__plus__plus__rp_(_x_x1483, _x_x1488, _ctx); /*string*/
  _x_x1479 = kk_std_core_types__lp__plus__plus__rp_(_x_x1480, _x_x1482, _ctx); /*string*/
  return kk_string_box(_x_x1479);
}

kk_string_t kk_std_core_list_show(kk_std_core_types__list xs, kk_function_t _implicit_fs_show, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, ?show : (a) -> e string) -> e string */ 
  kk_std_core_types__list x_10412 = kk_std_core_list_map(xs, kk_std_core_list_new_show_fun1475(_implicit_fs_show, _ctx), _ctx); /*list<string>*/;
  if (kk_yielding(kk_context())) {
    kk_std_core_types__list_drop(x_10412, _ctx);
    kk_box_t _x_x1477 = kk_std_core_hnd_yield_extend(kk_std_core_list_new_show_fun1478(_ctx), _ctx); /*3728*/
    return kk_string_unbox(_x_x1477);
  }
  {
    kk_string_t _x_x1490;
    kk_define_string_literal(, _s_x1491, 1, "[", _ctx)
    _x_x1490 = kk_string_dup(_s_x1491, _ctx); /*string*/
    kk_string_t _x_x1492;
    kk_string_t _x_x1493;
    if (kk_std_core_types__is_Nil(x_10412, _ctx)) {
      _x_x1493 = kk_string_empty(); /*string*/
    }
    else {
      struct kk_std_core_types_Cons* _con_x1495 = kk_std_core_types__as_Cons(x_10412, _ctx);
      kk_box_t _box_x737 = _con_x1495->head;
      kk_std_core_types__list xx_0 = _con_x1495->tail;
      kk_string_t x_1 = kk_string_unbox(_box_x737);
      if kk_likely(kk_datatype_ptr_is_unique(x_10412, _ctx)) {
        kk_datatype_ptr_free(x_10412, _ctx);
      }
      else {
        kk_string_dup(x_1, _ctx);
        kk_std_core_types__list_dup(xx_0, _ctx);
        kk_datatype_ptr_decref(x_10412, _ctx);
      }
      kk_string_t _x_x1496;
      kk_define_string_literal(, _s_x1497, 1, ",", _ctx)
      _x_x1496 = kk_string_dup(_s_x1497, _ctx); /*string*/
      _x_x1493 = kk_std_core_list__lift_joinsep_4797(_x_x1496, xx_0, x_1, _ctx); /*string*/
    }
    kk_string_t _x_x1498;
    kk_define_string_literal(, _s_x1499, 1, "]", _ctx)
    _x_x1498 = kk_string_dup(_s_x1499, _ctx); /*string*/
    _x_x1492 = kk_std_core_types__lp__plus__plus__rp_(_x_x1493, _x_x1498, _ctx); /*string*/
    return kk_std_core_types__lp__plus__plus__rp_(_x_x1490, _x_x1492, _ctx);
  }
}
 
// monadic lift

kk_std_core_types__tuple2 kk_std_core_list__mlift_lift_span_4798_10325(kk_std_core_types__list acc, kk_function_t predicate, kk_box_t y, kk_std_core_types__list ys, kk_std_core_types__list yy, bool _y_x10255, kk_context_t* _ctx) { /* forall<a,e> (acc : list<a>, predicate : (a) -> e bool, y : a, ys : list<a>, yy : list<a>, bool) -> e (list<a>, list<a>) */ 
  if (_y_x10255) {
    kk_std_core_types__list_drop(ys, _ctx);
    kk_std_core_types__list _x_x1500 = kk_std_core_types__new_Cons(kk_reuse_null, 0, y, acc, _ctx); /*list<82>*/
    return kk_std_core_list__lift_span_4798(predicate, yy, _x_x1500, _ctx);
  }
  {
    kk_std_core_types__list_drop(yy, _ctx);
    kk_box_drop(y, _ctx);
    kk_function_drop(predicate, _ctx);
    kk_std_core_types__list _b_x740_742 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), acc, _ctx); /*list<3762>*/;
    return kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(_b_x740_742, _ctx), kk_std_core_types__list_box(ys, _ctx), _ctx);
  }
}
 
// lifted local: span, span-acc
// todo: implement TRMC with multiple results to avoid the reverse


// lift anonymous function
struct kk_std_core_list__lift_span_4798_fun1505__t {
  struct kk_function_s _base;
  kk_std_core_types__list acc_0;
  kk_function_t predicate_0;
  kk_box_t y_0;
  kk_std_core_types__list ys_0;
  kk_std_core_types__list yy_0;
};
static kk_box_t kk_std_core_list__lift_span_4798_fun1505(kk_function_t _fself, kk_box_t _b_x745, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_lift_span_4798_fun1505(kk_std_core_types__list acc_0, kk_function_t predicate_0, kk_box_t y_0, kk_std_core_types__list ys_0, kk_std_core_types__list yy_0, kk_context_t* _ctx) {
  struct kk_std_core_list__lift_span_4798_fun1505__t* _self = kk_function_alloc_as(struct kk_std_core_list__lift_span_4798_fun1505__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__lift_span_4798_fun1505, kk_context());
  _self->acc_0 = acc_0;
  _self->predicate_0 = predicate_0;
  _self->y_0 = y_0;
  _self->ys_0 = ys_0;
  _self->yy_0 = yy_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__lift_span_4798_fun1505(kk_function_t _fself, kk_box_t _b_x745, kk_context_t* _ctx) {
  struct kk_std_core_list__lift_span_4798_fun1505__t* _self = kk_function_as(struct kk_std_core_list__lift_span_4798_fun1505__t*, _fself, _ctx);
  kk_std_core_types__list acc_0 = _self->acc_0; /* list<3762> */
  kk_function_t predicate_0 = _self->predicate_0; /* (3762) -> 3763 bool */
  kk_box_t y_0 = _self->y_0; /* 3762 */
  kk_std_core_types__list ys_0 = _self->ys_0; /* list<3762> */
  kk_std_core_types__list yy_0 = _self->yy_0; /* list<3762> */
  kk_drop_match(_self, {kk_std_core_types__list_dup(acc_0, _ctx);kk_function_dup(predicate_0, _ctx);kk_box_dup(y_0, _ctx);kk_std_core_types__list_dup(ys_0, _ctx);kk_std_core_types__list_dup(yy_0, _ctx);}, {}, _ctx)
  bool _y_x10255_0_755 = kk_bool_unbox(_b_x745); /*bool*/;
  kk_std_core_types__tuple2 _x_x1506 = kk_std_core_list__mlift_lift_span_4798_10325(acc_0, predicate_0, y_0, ys_0, yy_0, _y_x10255_0_755, _ctx); /*(list<3762>, list<3762>)*/
  return kk_std_core_types__tuple2_box(_x_x1506, _ctx);
}

kk_std_core_types__tuple2 kk_std_core_list__lift_span_4798(kk_function_t predicate_0, kk_std_core_types__list ys_0, kk_std_core_types__list acc_0, kk_context_t* _ctx) { /* forall<a,e> (predicate : (a) -> e bool, ys : list<a>, acc : list<a>) -> e (list<a>, list<a>) */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys_0, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1501 = kk_std_core_types__as_Cons(ys_0, _ctx);
    kk_box_t y_0 = _con_x1501->head;
    kk_std_core_types__list yy_0 = _con_x1501->tail;
    kk_box_dup(y_0, _ctx);
    kk_std_core_types__list_dup(yy_0, _ctx);
    bool x_10416;
    kk_function_t _x_x1503 = kk_function_dup(predicate_0, _ctx); /*(3762) -> 3763 bool*/
    kk_box_t _x_x1502 = kk_box_dup(y_0, _ctx); /*3762*/
    x_10416 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), _x_x1503, (_x_x1503, _x_x1502, _ctx), _ctx); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_box_t _x_x1504 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_lift_span_4798_fun1505(acc_0, predicate_0, y_0, ys_0, yy_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__tuple2_unbox(_x_x1504, KK_OWNED, _ctx);
    }
    if (x_10416) {
      kk_reuse_t _ru_x1103 = kk_reuse_null; /*@reuse*/;
      if kk_likely(kk_datatype_ptr_is_unique(ys_0, _ctx)) {
        kk_std_core_types__list_drop(yy_0, _ctx);
        kk_box_drop(y_0, _ctx);
        _ru_x1103 = (kk_datatype_ptr_reuse(ys_0, _ctx));
      }
      else {
        kk_datatype_ptr_decref(ys_0, _ctx);
      }
      { // tailcall
        kk_std_core_types__list _x_x1507 = kk_std_core_types__new_Cons(_ru_x1103, 0, y_0, acc_0, _ctx); /*list<82>*/
        ys_0 = yy_0;
        acc_0 = _x_x1507;
        goto kk__tailcall;
      }
    }
    {
      kk_std_core_types__list_drop(yy_0, _ctx);
      kk_box_drop(y_0, _ctx);
      kk_function_drop(predicate_0, _ctx);
      kk_std_core_types__list _b_x746_751 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), acc_0, _ctx); /*list<3762>*/;
      return kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(_b_x746_751, _ctx), kk_std_core_types__list_box(ys_0, _ctx), _ctx);
    }
  }
  {
    kk_function_drop(predicate_0, _ctx);
    kk_std_core_types__list _b_x748_753 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), acc_0, _ctx); /*list<3762>*/;
    return kk_std_core_types__new_Tuple2(kk_std_core_types__list_box(_b_x748_753, _ctx), kk_std_core_types__list_box(ys_0, _ctx), _ctx);
  }
}
 
// Return the sum of a list of integers


// lift anonymous function
struct kk_std_core_list_sum_fun1509__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_list_sum_fun1509(kk_function_t _fself, kk_box_t _b_x759, kk_box_t _b_x760, kk_context_t* _ctx);
static kk_function_t kk_std_core_list_new_sum_fun1509(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_list_sum_fun1509, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_list_sum_fun1509(kk_function_t _fself, kk_box_t _b_x759, kk_box_t _b_x760, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_integer_t _x_x1510;
  kk_integer_t _x_x1511 = kk_integer_unbox(_b_x759, _ctx); /*int*/
  kk_integer_t _x_x1512 = kk_integer_unbox(_b_x760, _ctx); /*int*/
  _x_x1510 = kk_std_core_int__lp__plus__rp_(_x_x1511, _x_x1512, _ctx); /*int*/
  return kk_integer_box(_x_x1510, _ctx);
}

kk_integer_t kk_std_core_list_sum(kk_std_core_types__list xs, kk_context_t* _ctx) { /* (xs : list<int>) -> int */ 
  kk_box_t _x_x1508 = kk_std_core_list_foldl(xs, kk_integer_box(kk_integer_from_small(0), _ctx), kk_std_core_list_new_sum_fun1509(_ctx), _ctx); /*2053*/
  return kk_integer_unbox(_x_x1508, _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_take_while_10326(kk_std_core_types__cctx _acc, kk_function_t predicate, kk_box_t x, kk_std_core_types__list xx, bool _y_x10260, kk_context_t* _ctx) { /* forall<a,e> (ctx<list<a>>, predicate : (a) -> e bool, x : a, xx : list<a>, bool) -> e list<a> */ 
  if (_y_x10260) {
    kk_std_core_types__list _trmc_x10125 = kk_datatype_null(); /*list<3832>*/;
    kk_std_core_types__list _trmc_x10126 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), x, _trmc_x10125, _ctx); /*list<3832>*/;
    kk_field_addr_t _b_x769_774 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10126, _ctx)->tail, _ctx); /*@field-addr<list<3832>>*/;
    kk_std_core_types__cctx _x_x1513 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10126, _ctx)),_b_x769_774,kk_context()); /*ctx<0>*/
    return kk_std_core_list__trmc_take_while(xx, predicate, _x_x1513, _ctx);
  }
  {
    kk_std_core_types__list_drop(xx, _ctx);
    kk_box_drop(x, _ctx);
    kk_function_drop(predicate, _ctx);
    kk_box_t _x_x1514 = kk_cctx_apply(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1514, KK_OWNED, _ctx);
  }
}
 
// Keep only those initial elements that satisfy `predicate`


// lift anonymous function
struct kk_std_core_list__trmc_take_while_fun1519__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t predicate_0;
  kk_box_t x_0;
  kk_std_core_types__list xx_0;
};
static kk_box_t kk_std_core_list__trmc_take_while_fun1519(kk_function_t _fself, kk_box_t _b_x781, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_take_while_fun1519(kk_std_core_types__cctx _acc_0, kk_function_t predicate_0, kk_box_t x_0, kk_std_core_types__list xx_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_take_while_fun1519__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_take_while_fun1519__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_take_while_fun1519, kk_context());
  _self->_acc_0 = _acc_0;
  _self->predicate_0 = predicate_0;
  _self->x_0 = x_0;
  _self->xx_0 = xx_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_take_while_fun1519(kk_function_t _fself, kk_box_t _b_x781, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_take_while_fun1519__t* _self = kk_function_as(struct kk_std_core_list__trmc_take_while_fun1519__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<3832>> */
  kk_function_t predicate_0 = _self->predicate_0; /* (3832) -> 3833 bool */
  kk_box_t x_0 = _self->x_0; /* 3832 */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<3832> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(predicate_0, _ctx);kk_box_dup(x_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);}, {}, _ctx)
  bool _y_x10260_0_803 = kk_bool_unbox(_b_x781); /*bool*/;
  kk_std_core_types__list _x_x1520 = kk_std_core_list__mlift_trmc_take_while_10326(_acc_0, predicate_0, x_0, xx_0, _y_x10260_0_803, _ctx); /*list<3832>*/
  return kk_std_core_types__list_box(_x_x1520, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_take_while(kk_std_core_types__list xs, kk_function_t predicate_0, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool, ctx<list<a>>) -> e list<a> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1515 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x_0 = _con_x1515->head;
    kk_std_core_types__list xx_0 = _con_x1515->tail;
    kk_reuse_t _ru_x1104 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x1104 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_box_dup(x_0, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    bool x_1_10419;
    kk_function_t _x_x1517 = kk_function_dup(predicate_0, _ctx); /*(3832) -> 3833 bool*/
    kk_box_t _x_x1516 = kk_box_dup(x_0, _ctx); /*3832*/
    x_1_10419 = kk_function_call(bool, (kk_function_t, kk_box_t, kk_context_t*), _x_x1517, (_x_x1517, _x_x1516, _ctx), _ctx); /*bool*/
    if (kk_yielding(kk_context())) {
      kk_reuse_drop(_ru_x1104,kk_context());
      kk_box_t _x_x1518 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_take_while_fun1519(_acc_0, predicate_0, x_0, xx_0, _ctx), _ctx); /*3728*/
      return kk_std_core_types__list_unbox(_x_x1518, KK_OWNED, _ctx);
    }
    if (x_1_10419) {
      kk_std_core_types__list _trmc_x10125_0 = kk_datatype_null(); /*list<3832>*/;
      kk_std_core_types__list _trmc_x10126_0 = kk_std_core_types__new_Cons(_ru_x1104, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_0, _trmc_x10125_0, _ctx); /*list<3832>*/;
      kk_field_addr_t _b_x787_795 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10126_0, _ctx)->tail, _ctx); /*@field-addr<list<3832>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1521 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10126_0, _ctx)),_b_x787_795,kk_context()); /*ctx<0>*/
        xs = xx_0;
        _acc_0 = _x_x1521;
        goto kk__tailcall;
      }
    }
    {
      kk_reuse_drop(_ru_x1104,kk_context());
      kk_std_core_types__list_drop(xx_0, _ctx);
      kk_box_drop(x_0, _ctx);
      kk_function_drop(predicate_0, _ctx);
      kk_box_t _x_x1522 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
      return kk_std_core_types__list_unbox(_x_x1522, KK_OWNED, _ctx);
    }
  }
  {
    kk_function_drop(predicate_0, _ctx);
    kk_box_t _x_x1523 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1523, KK_OWNED, _ctx);
  }
}
 
// Keep only those initial elements that satisfy `predicate`

kk_std_core_types__list kk_std_core_list_take_while(kk_std_core_types__list xs_0, kk_function_t predicate_1, kk_context_t* _ctx) { /* forall<a,e> (xs : list<a>, predicate : (a) -> e bool) -> e list<a> */ 
  kk_std_core_types__cctx _x_x1524 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_take_while(xs_0, predicate_1, _x_x1524, _ctx);
}
 
// Join a list of strings with newlines

kk_string_t kk_std_core_list_unlines(kk_std_core_types__list xs, kk_context_t* _ctx) { /* (xs : list<string>) -> string */ 
  if (kk_std_core_types__is_Nil(xs, _ctx)) {
    return kk_string_empty();
  }
  {
    struct kk_std_core_types_Cons* _con_x1526 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x804 = _con_x1526->head;
    kk_std_core_types__list xx = _con_x1526->tail;
    kk_string_t x = kk_string_unbox(_box_x804);
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_string_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_string_t _x_x1527;
    kk_define_string_literal(, _s_x1528, 1, "\n", _ctx)
    _x_x1527 = kk_string_dup(_s_x1528, _ctx); /*string*/
    return kk_std_core_list__lift_joinsep_4797(_x_x1527, xx, x, _ctx);
  }
}
 
// lifted local: unzip, iter
// todo: implement TRMC for multiple results

kk_std_core_types__tuple2 kk_std_core_list__lift_unzip_4799(kk_std_core_types__list ys, kk_std_core_types__cctx acc1, kk_std_core_types__cctx acc2, kk_context_t* _ctx) { /* forall<a,b,c,d> (ys : list<(a, b)>, acc1 : cctx<c,list<a>>, acc2 : cctx<d,list<b>>) -> (c, d) */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1529 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t _box_x805 = _con_x1529->head;
    kk_std_core_types__tuple2 _pat_0 = kk_std_core_types__tuple2_unbox(_box_x805, KK_BORROWED, _ctx);
    kk_std_core_types__list xx = _con_x1529->tail;
    kk_box_t x = _pat_0.fst;
    kk_box_t y = _pat_0.snd;
    kk_reuse_t _ru_x1106 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      kk_box_dup(x, _ctx);
      kk_box_dup(y, _ctx);
      kk_box_drop(_box_x805, _ctx);
      _ru_x1106 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_box_dup(y, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_std_core_types__list _cctx_x3895;
    kk_std_core_types__list _x_x1530 = kk_datatype_null(); /*list<3864>*/
    _cctx_x3895 = kk_std_core_types__new_Cons(_ru_x1106, kk_field_index_of(struct kk_std_core_types_Cons, tail), x, _x_x1530, _ctx); /*list<3864>*/
    kk_field_addr_t _cctx_x3896 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x3895, _ctx)->tail, _ctx); /*@field-addr<list<3864>>*/;
    kk_std_core_types__list _cctx_x3935;
    kk_std_core_types__list _x_x1531 = kk_datatype_null(); /*list<3865>*/
    _cctx_x3935 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), y, _x_x1531, _ctx); /*list<3865>*/
    kk_field_addr_t _cctx_x3936 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x3935, _ctx)->tail, _ctx); /*@field-addr<list<3865>>*/;
    kk_std_core_types__list _b_x818_826 = _cctx_x3895; /*list<3864>*/;
    kk_field_addr_t _b_x819_827 = _cctx_x3896; /*@field-addr<list<3864>>*/;
    kk_std_core_types__list _b_x820_828 = _cctx_x3935; /*list<3865>*/;
    kk_field_addr_t _b_x821_829 = _cctx_x3936; /*@field-addr<list<3865>>*/;
    { // tailcall
      kk_std_core_types__cctx _x_x1532;
      kk_std_core_types__cctx _x_x1533 = kk_cctx_create((kk_std_core_types__list_box(_b_x818_826, _ctx)),_b_x819_827,kk_context()); /*cctx<0,1>*/
      _x_x1532 = kk_cctx_compose(acc1,_x_x1533,kk_context()); /*cctx<371,373>*/
      kk_std_core_types__cctx _x_x1534;
      kk_std_core_types__cctx _x_x1535 = kk_cctx_create((kk_std_core_types__list_box(_b_x820_828, _ctx)),_b_x821_829,kk_context()); /*cctx<0,1>*/
      _x_x1534 = kk_cctx_compose(acc2,_x_x1535,kk_context()); /*cctx<371,373>*/
      ys = xx;
      acc1 = _x_x1532;
      acc2 = _x_x1534;
      goto kk__tailcall;
    }
  }
  {
    kk_box_t _x_x1536 = kk_cctx_apply(acc1,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    kk_box_t _x_x1537 = kk_cctx_apply(acc2,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    return kk_std_core_types__new_Tuple2(_x_x1536, _x_x1537, _ctx);
  }
}
 
// lifted local: unzip3, iter
// todo: implement TRMC for multiple results

kk_std_core_types__tuple3 kk_std_core_list__lift_unzip3_4800(kk_std_core_types__list ys, kk_std_core_types__cctx acc1, kk_std_core_types__cctx acc2, kk_std_core_types__cctx acc3, kk_context_t* _ctx) { /* forall<a,b,c,d,a1,b1> (ys : list<(a, b, c)>, acc1 : cctx<d,list<a>>, acc2 : cctx<a1,list<b>>, acc3 : cctx<b1,list<c>>) -> (d, a1, b1) */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1540 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t _box_x834 = _con_x1540->head;
    kk_std_core_types__tuple3 _pat_0 = kk_std_core_types__tuple3_unbox(_box_x834, KK_BORROWED, _ctx);
    kk_std_core_types__list xx = _con_x1540->tail;
    kk_box_t x = _pat_0.fst;
    kk_box_t y = _pat_0.snd;
    kk_box_t z = _pat_0.thd;
    kk_reuse_t _ru_x1107 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      kk_box_dup(x, _ctx);
      kk_box_dup(y, _ctx);
      kk_box_dup(z, _ctx);
      kk_box_drop(_box_x834, _ctx);
      _ru_x1107 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_box_dup(y, _ctx);
      kk_box_dup(z, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_std_core_types__list _cctx_x4086;
    kk_std_core_types__list _x_x1541 = kk_datatype_null(); /*list<4054>*/
    _cctx_x4086 = kk_std_core_types__new_Cons(_ru_x1107, kk_field_index_of(struct kk_std_core_types_Cons, tail), x, _x_x1541, _ctx); /*list<4054>*/
    kk_field_addr_t _cctx_x4087 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x4086, _ctx)->tail, _ctx); /*@field-addr<list<4054>>*/;
    kk_std_core_types__list _cctx_x4126;
    kk_std_core_types__list _x_x1542 = kk_datatype_null(); /*list<4055>*/
    _cctx_x4126 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), y, _x_x1542, _ctx); /*list<4055>*/
    kk_field_addr_t _cctx_x4127 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x4126, _ctx)->tail, _ctx); /*@field-addr<list<4055>>*/;
    kk_std_core_types__list _cctx_x4166;
    kk_std_core_types__list _x_x1543 = kk_datatype_null(); /*list<4056>*/
    _cctx_x4166 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), z, _x_x1543, _ctx); /*list<4056>*/
    kk_field_addr_t _cctx_x4167 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x4166, _ctx)->tail, _ctx); /*@field-addr<list<4056>>*/;
    kk_std_core_types__list _b_x853_865 = _cctx_x4086; /*list<4054>*/;
    kk_field_addr_t _b_x854_866 = _cctx_x4087; /*@field-addr<list<4054>>*/;
    kk_std_core_types__list _b_x855_867 = _cctx_x4126; /*list<4055>*/;
    kk_field_addr_t _b_x856_868 = _cctx_x4127; /*@field-addr<list<4055>>*/;
    kk_std_core_types__list _b_x857_869 = _cctx_x4166; /*list<4056>*/;
    kk_field_addr_t _b_x858_870 = _cctx_x4167; /*@field-addr<list<4056>>*/;
    { // tailcall
      kk_std_core_types__cctx _x_x1544;
      kk_std_core_types__cctx _x_x1545 = kk_cctx_create((kk_std_core_types__list_box(_b_x853_865, _ctx)),_b_x854_866,kk_context()); /*cctx<0,1>*/
      _x_x1544 = kk_cctx_compose(acc1,_x_x1545,kk_context()); /*cctx<371,373>*/
      kk_std_core_types__cctx _x_x1546;
      kk_std_core_types__cctx _x_x1547 = kk_cctx_create((kk_std_core_types__list_box(_b_x855_867, _ctx)),_b_x856_868,kk_context()); /*cctx<0,1>*/
      _x_x1546 = kk_cctx_compose(acc2,_x_x1547,kk_context()); /*cctx<371,373>*/
      kk_std_core_types__cctx _x_x1548;
      kk_std_core_types__cctx _x_x1549 = kk_cctx_create((kk_std_core_types__list_box(_b_x857_869, _ctx)),_b_x858_870,kk_context()); /*cctx<0,1>*/
      _x_x1548 = kk_cctx_compose(acc3,_x_x1549,kk_context()); /*cctx<371,373>*/
      ys = xx;
      acc1 = _x_x1544;
      acc2 = _x_x1546;
      acc3 = _x_x1548;
      goto kk__tailcall;
    }
  }
  {
    kk_box_t _x_x1550 = kk_cctx_apply(acc1,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    kk_box_t _x_x1551 = kk_cctx_apply(acc2,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    kk_box_t _x_x1552 = kk_cctx_apply(acc3,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    return kk_std_core_types__new_Tuple3(_x_x1550, _x_x1551, _x_x1552, _ctx);
  }
}
 
// lifted local: unzip4, iter
// todo: implement TRMC for multiple results

kk_std_core_types__tuple4 kk_std_core_list__lift_unzip4_4801(kk_std_core_types__list ys, kk_std_core_types__cctx acc1, kk_std_core_types__cctx acc2, kk_std_core_types__cctx acc3, kk_std_core_types__cctx acc4, kk_context_t* _ctx) { /* forall<a,b,c,d,a1,b1,c1,d1> (ys : list<(a, b, c, d)>, acc1 : cctx<a1,list<a>>, acc2 : cctx<b1,list<b>>, acc3 : cctx<c1,list<c>>, acc4 : cctx<d1,list<d>>) -> (a1, b1, c1, d1) */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ys, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1556 = kk_std_core_types__as_Cons(ys, _ctx);
    kk_box_t _box_x877 = _con_x1556->head;
    kk_std_core_types__tuple4 _pat_0 = kk_std_core_types__tuple4_unbox(_box_x877, KK_BORROWED, _ctx);
    struct kk_std_core_types_Tuple4* _con_x1557 = kk_std_core_types__as_Tuple4(_pat_0, _ctx);
    kk_std_core_types__list xx = _con_x1556->tail;
    kk_box_t x = _con_x1557->fst;
    kk_box_t y = _con_x1557->snd;
    kk_box_t z = _con_x1557->thd;
    kk_box_t w = _con_x1557->field4;
    kk_reuse_t _ru_x1108 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
      kk_box_dup(w, _ctx);
      kk_box_dup(x, _ctx);
      kk_box_dup(y, _ctx);
      kk_box_dup(z, _ctx);
      kk_box_drop(_box_x877, _ctx);
      _ru_x1108 = (kk_datatype_ptr_reuse(ys, _ctx));
    }
    else {
      kk_box_dup(w, _ctx);
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_box_dup(y, _ctx);
      kk_box_dup(z, _ctx);
      kk_datatype_ptr_decref(ys, _ctx);
    }
    kk_std_core_types__list _cctx_x4357;
    kk_std_core_types__list _x_x1558 = kk_datatype_null(); /*list<4324>*/
    _cctx_x4357 = kk_std_core_types__new_Cons(_ru_x1108, kk_field_index_of(struct kk_std_core_types_Cons, tail), x, _x_x1558, _ctx); /*list<4324>*/
    kk_field_addr_t _cctx_x4358 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x4357, _ctx)->tail, _ctx); /*@field-addr<list<4324>>*/;
    kk_std_core_types__list _cctx_x4397;
    kk_std_core_types__list _x_x1559 = kk_datatype_null(); /*list<4325>*/
    _cctx_x4397 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), y, _x_x1559, _ctx); /*list<4325>*/
    kk_field_addr_t _cctx_x4398 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x4397, _ctx)->tail, _ctx); /*@field-addr<list<4325>>*/;
    kk_std_core_types__list _cctx_x4437;
    kk_std_core_types__list _x_x1560 = kk_datatype_null(); /*list<4326>*/
    _cctx_x4437 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), z, _x_x1560, _ctx); /*list<4326>*/
    kk_field_addr_t _cctx_x4438 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x4437, _ctx)->tail, _ctx); /*@field-addr<list<4326>>*/;
    kk_std_core_types__list _cctx_x4477;
    kk_std_core_types__list _x_x1561 = kk_datatype_null(); /*list<4327>*/
    _cctx_x4477 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), w, _x_x1561, _ctx); /*list<4327>*/
    kk_field_addr_t _cctx_x4478 = kk_field_addr_create(&kk_std_core_types__as_Cons(_cctx_x4477, _ctx)->tail, _ctx); /*@field-addr<list<4327>>*/;
    kk_std_core_types__list _b_x902_918 = _cctx_x4357; /*list<4324>*/;
    kk_field_addr_t _b_x903_919 = _cctx_x4358; /*@field-addr<list<4324>>*/;
    kk_std_core_types__list _b_x904_920 = _cctx_x4397; /*list<4325>*/;
    kk_field_addr_t _b_x905_921 = _cctx_x4398; /*@field-addr<list<4325>>*/;
    kk_std_core_types__list _b_x906_922 = _cctx_x4437; /*list<4326>*/;
    kk_field_addr_t _b_x907_923 = _cctx_x4438; /*@field-addr<list<4326>>*/;
    kk_std_core_types__list _b_x908_924 = _cctx_x4477; /*list<4327>*/;
    kk_field_addr_t _b_x909_925 = _cctx_x4478; /*@field-addr<list<4327>>*/;
    { // tailcall
      kk_std_core_types__cctx _x_x1562;
      kk_std_core_types__cctx _x_x1563 = kk_cctx_create((kk_std_core_types__list_box(_b_x902_918, _ctx)),_b_x903_919,kk_context()); /*cctx<0,1>*/
      _x_x1562 = kk_cctx_compose(acc1,_x_x1563,kk_context()); /*cctx<371,373>*/
      kk_std_core_types__cctx _x_x1564;
      kk_std_core_types__cctx _x_x1565 = kk_cctx_create((kk_std_core_types__list_box(_b_x904_920, _ctx)),_b_x905_921,kk_context()); /*cctx<0,1>*/
      _x_x1564 = kk_cctx_compose(acc2,_x_x1565,kk_context()); /*cctx<371,373>*/
      kk_std_core_types__cctx _x_x1566;
      kk_std_core_types__cctx _x_x1567 = kk_cctx_create((kk_std_core_types__list_box(_b_x906_922, _ctx)),_b_x907_923,kk_context()); /*cctx<0,1>*/
      _x_x1566 = kk_cctx_compose(acc3,_x_x1567,kk_context()); /*cctx<371,373>*/
      kk_std_core_types__cctx _x_x1568;
      kk_std_core_types__cctx _x_x1569 = kk_cctx_create((kk_std_core_types__list_box(_b_x908_924, _ctx)),_b_x909_925,kk_context()); /*cctx<0,1>*/
      _x_x1568 = kk_cctx_compose(acc4,_x_x1569,kk_context()); /*cctx<371,373>*/
      ys = xx;
      acc1 = _x_x1562;
      acc2 = _x_x1564;
      acc3 = _x_x1566;
      acc4 = _x_x1568;
      goto kk__tailcall;
    }
  }
  {
    kk_box_t _x_x1570 = kk_cctx_apply(acc1,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    kk_box_t _x_x1571 = kk_cctx_apply(acc2,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    kk_box_t _x_x1572 = kk_cctx_apply(acc3,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    kk_box_t _x_x1573 = kk_cctx_apply(acc4,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*359*/
    return kk_std_core_types__new_Tuple4(kk_reuse_null, 0, _x_x1570, _x_x1571, _x_x1572, _x_x1573, _ctx);
  }
}
 
// Zip two lists together by pairing the corresponding elements.
// The returned list is only as long as the smallest input list.

kk_std_core_types__list kk_std_core_list__trmc_zip(kk_std_core_types__list xs, kk_std_core_types__list ys, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* forall<a,b> (xs : list<a>, ys : list<b>, ctx<list<(a, b)>>) -> list<(a, b)> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1578 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1578->head;
    kk_std_core_types__list xx = _con_x1578->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    if (kk_std_core_types__is_Cons(ys, _ctx)) {
      struct kk_std_core_types_Cons* _con_x1579 = kk_std_core_types__as_Cons(ys, _ctx);
      kk_box_t y = _con_x1579->head;
      kk_std_core_types__list yy = _con_x1579->tail;
      kk_reuse_t _ru_x1110 = kk_reuse_null; /*@reuse*/;
      if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
        _ru_x1110 = (kk_datatype_ptr_reuse(ys, _ctx));
      }
      else {
        kk_box_dup(y, _ctx);
        kk_std_core_types__list_dup(yy, _ctx);
        kk_datatype_ptr_decref(ys, _ctx);
      }
      kk_std_core_types__list _trmc_x10127 = kk_datatype_null(); /*list<(4706, 4707)>*/;
      kk_std_core_types__list _trmc_x10128;
      kk_box_t _x_x1580;
      kk_std_core_types__tuple2 _x_x1581 = kk_std_core_types__new_Tuple2(x, y, _ctx); /*(129, 130)*/
      _x_x1580 = kk_std_core_types__tuple2_box(_x_x1581, _ctx); /*82*/
      _trmc_x10128 = kk_std_core_types__new_Cons(_ru_x1110, 0, _x_x1580, _trmc_x10127, _ctx); /*list<(4706, 4707)>*/
      kk_field_addr_t _b_x943_950 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10128, _ctx)->tail, _ctx); /*@field-addr<list<(4706, 4707)>>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x1582 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10128, _ctx)),_b_x943_950,kk_context()); /*ctx<0>*/
        xs = xx;
        ys = yy;
        _acc = _x_x1582;
        goto kk__tailcall;
      }
    }
    {
      kk_std_core_types__list_drop(xx, _ctx);
      kk_box_drop(x, _ctx);
      kk_box_t _x_x1583 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
      return kk_std_core_types__list_unbox(_x_x1583, KK_OWNED, _ctx);
    }
  }
  {
    kk_std_core_types__list_drop(ys, _ctx);
    kk_box_t _x_x1584 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1584, KK_OWNED, _ctx);
  }
}
 
// Zip two lists together by pairing the corresponding elements.
// The returned list is only as long as the smallest input list.

kk_std_core_types__list kk_std_core_list_zip(kk_std_core_types__list xs_0, kk_std_core_types__list ys_0, kk_context_t* _ctx) { /* forall<a,b> (xs : list<a>, ys : list<b>) -> list<(a, b)> */ 
  kk_std_core_types__cctx _x_x1585 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_zip(xs_0, ys_0, _x_x1585, _ctx);
}
 
// monadic lift

kk_std_core_types__list kk_std_core_list__mlift_trmc_zipwith_10327(kk_std_core_types__cctx _acc, kk_function_t f, kk_std_core_types__list xx, kk_std_core_types__list yy, kk_box_t _trmc_x10129, kk_context_t* _ctx) { /* forall<a,b,c,e> (ctx<list<c>>, f : (a, b) -> e c, xx : list<a>, yy : list<b>, c) -> e list<c> */ 
  kk_std_core_types__list _trmc_x10130 = kk_datatype_null(); /*list<4774>*/;
  kk_std_core_types__list _trmc_x10131 = kk_std_core_types__new_Cons(kk_reuse_null, kk_field_index_of(struct kk_std_core_types_Cons, tail), _trmc_x10129, _trmc_x10130, _ctx); /*list<4774>*/;
  kk_field_addr_t _b_x963_966 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10131, _ctx)->tail, _ctx); /*@field-addr<list<4774>>*/;
  kk_std_core_types__cctx _x_x1586 = kk_cctx_extend(_acc,(kk_std_core_types__list_box(_trmc_x10131, _ctx)),_b_x963_966,kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_zipwith(xx, yy, f, _x_x1586, _ctx);
}
 
// Zip two lists together by apply a function `f` to all corresponding elements.
// The returned list is only as long as the smallest input list.


// lift anonymous function
struct kk_std_core_list__trmc_zipwith_fun1591__t {
  struct kk_function_s _base;
  kk_std_core_types__cctx _acc_0;
  kk_function_t f_0;
  kk_std_core_types__list xx_0;
  kk_std_core_types__list yy_0;
};
static kk_box_t kk_std_core_list__trmc_zipwith_fun1591(kk_function_t _fself, kk_box_t _b_x971, kk_context_t* _ctx);
static kk_function_t kk_std_core_list__new_trmc_zipwith_fun1591(kk_std_core_types__cctx _acc_0, kk_function_t f_0, kk_std_core_types__list xx_0, kk_std_core_types__list yy_0, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_zipwith_fun1591__t* _self = kk_function_alloc_as(struct kk_std_core_list__trmc_zipwith_fun1591__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_list__trmc_zipwith_fun1591, kk_context());
  _self->_acc_0 = _acc_0;
  _self->f_0 = f_0;
  _self->xx_0 = xx_0;
  _self->yy_0 = yy_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_list__trmc_zipwith_fun1591(kk_function_t _fself, kk_box_t _b_x971, kk_context_t* _ctx) {
  struct kk_std_core_list__trmc_zipwith_fun1591__t* _self = kk_function_as(struct kk_std_core_list__trmc_zipwith_fun1591__t*, _fself, _ctx);
  kk_std_core_types__cctx _acc_0 = _self->_acc_0; /* ctx<list<4774>> */
  kk_function_t f_0 = _self->f_0; /* (4772, 4773) -> 4775 4774 */
  kk_std_core_types__list xx_0 = _self->xx_0; /* list<4772> */
  kk_std_core_types__list yy_0 = _self->yy_0; /* list<4773> */
  kk_drop_match(_self, {kk_std_core_types__cctx_dup(_acc_0, _ctx);kk_function_dup(f_0, _ctx);kk_std_core_types__list_dup(xx_0, _ctx);kk_std_core_types__list_dup(yy_0, _ctx);}, {}, _ctx)
  kk_box_t _trmc_x10129_0_993 = _b_x971; /*4774*/;
  kk_std_core_types__list _x_x1592 = kk_std_core_list__mlift_trmc_zipwith_10327(_acc_0, f_0, xx_0, yy_0, _trmc_x10129_0_993, _ctx); /*list<4774>*/
  return kk_std_core_types__list_box(_x_x1592, _ctx);
}

kk_std_core_types__list kk_std_core_list__trmc_zipwith(kk_std_core_types__list xs, kk_std_core_types__list ys, kk_function_t f_0, kk_std_core_types__cctx _acc_0, kk_context_t* _ctx) { /* forall<a,b,c,e> (xs : list<a>, ys : list<b>, f : (a, b) -> e c, ctx<list<c>>) -> e list<c> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x1587 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t x = _con_x1587->head;
    kk_std_core_types__list xx_0 = _con_x1587->tail;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      kk_datatype_ptr_free(xs, _ctx);
    }
    else {
      kk_box_dup(x, _ctx);
      kk_std_core_types__list_dup(xx_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    if (kk_std_core_types__is_Cons(ys, _ctx)) {
      struct kk_std_core_types_Cons* _con_x1588 = kk_std_core_types__as_Cons(ys, _ctx);
      kk_box_t y = _con_x1588->head;
      kk_std_core_types__list yy_0 = _con_x1588->tail;
      kk_reuse_t _ru_x1112 = kk_reuse_null; /*@reuse*/;
      if kk_likely(kk_datatype_ptr_is_unique(ys, _ctx)) {
        _ru_x1112 = (kk_datatype_ptr_reuse(ys, _ctx));
      }
      else {
        kk_box_dup(y, _ctx);
        kk_std_core_types__list_dup(yy_0, _ctx);
        kk_datatype_ptr_decref(ys, _ctx);
      }
      kk_box_t x_0_10422;
      kk_function_t _x_x1589 = kk_function_dup(f_0, _ctx); /*(4772, 4773) -> 4775 4774*/
      x_0_10422 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x1589, (_x_x1589, x, y, _ctx), _ctx); /*4774*/
      if (kk_yielding(kk_context())) {
        kk_reuse_drop(_ru_x1112,kk_context());
        kk_box_drop(x_0_10422, _ctx);
        kk_box_t _x_x1590 = kk_std_core_hnd_yield_extend(kk_std_core_list__new_trmc_zipwith_fun1591(_acc_0, f_0, xx_0, yy_0, _ctx), _ctx); /*3728*/
        return kk_std_core_types__list_unbox(_x_x1590, KK_OWNED, _ctx);
      }
      {
        kk_std_core_types__list _trmc_x10130_0 = kk_datatype_null(); /*list<4774>*/;
        kk_std_core_types__list _trmc_x10131_0 = kk_std_core_types__new_Cons(_ru_x1112, kk_field_index_of(struct kk_std_core_types_Cons, tail), x_0_10422, _trmc_x10130_0, _ctx); /*list<4774>*/;
        kk_field_addr_t _b_x977_985 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10131_0, _ctx)->tail, _ctx); /*@field-addr<list<4774>>*/;
        { // tailcall
          kk_std_core_types__cctx _x_x1593 = kk_cctx_extend(_acc_0,(kk_std_core_types__list_box(_trmc_x10131_0, _ctx)),_b_x977_985,kk_context()); /*ctx<0>*/
          xs = xx_0;
          ys = yy_0;
          _acc_0 = _x_x1593;
          goto kk__tailcall;
        }
      }
    }
    {
      kk_std_core_types__list_drop(xx_0, _ctx);
      kk_box_drop(x, _ctx);
      kk_function_drop(f_0, _ctx);
      kk_box_t _x_x1594 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
      return kk_std_core_types__list_unbox(_x_x1594, KK_OWNED, _ctx);
    }
  }
  {
    kk_std_core_types__list_drop(ys, _ctx);
    kk_function_drop(f_0, _ctx);
    kk_box_t _x_x1595 = kk_cctx_apply(_acc_0,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x1595, KK_OWNED, _ctx);
  }
}
 
// Zip two lists together by apply a function `f` to all corresponding elements.
// The returned list is only as long as the smallest input list.

kk_std_core_types__list kk_std_core_list_zipwith(kk_std_core_types__list xs_0, kk_std_core_types__list ys_0, kk_function_t f_1, kk_context_t* _ctx) { /* forall<a,b,c,e> (xs : list<a>, ys : list<b>, f : (a, b) -> e c) -> e list<c> */ 
  kk_std_core_types__cctx _x_x1596 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_core_list__trmc_zipwith(xs_0, ys_0, f_1, _x_x1596, _ctx);
}

// initialization
void kk_std_core_list__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_undiv__init(_ctx);
  kk_std_core_hnd__init(_ctx);
  kk_std_core_exn__init(_ctx);
  kk_std_core_char__init(_ctx);
  kk_std_core_string__init(_ctx);
  kk_std_core_int__init(_ctx);
  kk_std_core_vector__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_list__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_vector__done(_ctx);
  kk_std_core_int__done(_ctx);
  kk_std_core_string__done(_ctx);
  kk_std_core_char__done(_ctx);
  kk_std_core_exn__done(_ctx);
  kk_std_core_hnd__done(_ctx);
  kk_std_core_undiv__done(_ctx);
  kk_std_core_types__done(_ctx);
}
