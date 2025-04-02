// Koka generated module: std/core/hnd, koka version: 3.1.2, platform: 64-bit
#include "std_core_hnd.h"
/*---------------------------------------------------------------------------
  Copyright 2020-2021, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/
/*
typedef datatype_t kk_std_core_hnd__ev;
struct kk_std_core_hnd_Ev {
  kk_std_core_hnd__htag htag;
  kk_box_t hnd;
  // kk_cfc_t cfc;  // control flow context
  kk_std_core_hnd__evv hevv;
  kk_std_core_hnd__marker marker;
};
*/


// Note. We no longer support cfc for `evv_is_affine` in the C backend since we always use context paths now.
//
// typedef int32_t kk_cfc_t;

// static kk_cfc_t kk_handler_cfc_borrow( kk_box_t h, kk_context_t* ctx ) {
//   kk_box_t b = kk_block_field(kk_ptr_unbox(h,ctx),0);  // first field of the handler is the cfc
//   return kk_integer_clamp32_borrow(kk_integer_unbox(b,ctx),ctx);
// }


static kk_evv_vector_t kk_evv_vector_alloc(kk_ssize_t length, kk_context_t* ctx) {
  kk_assert_internal(length>=0);
  kk_evv_vector_t v = (kk_evv_vector_t)kk_block_alloc(kk_ssizeof(struct kk_evv_vector_s) + (length-1)*kk_ssizeof(kk_std_core_hnd__ev_t), length, KK_TAG_EVV_VECTOR, ctx);
  // v->cfc = kk_integer_from_int32(cfc,ctx);
  return v;
}

static kk_std_core_hnd__ev* kk_evv_vector_buf(kk_evv_vector_t vec, kk_ssize_t* len) {
  if (len != NULL) { *len = kk_block_scan_fsize(&vec->_block); }
  return &vec->vec[0];
}

static kk_std_core_hnd__ev* kk_evv_as_vec(kk_evv_t evv, kk_ssize_t* len, kk_std_core_hnd__ev* single, kk_context_t* ctx) {
  if (kk_evv_is_vector(evv,ctx)) {
    kk_evv_vector_t vec = kk_evv_as_vector(evv,ctx);
    *len = kk_block_scan_fsize(&vec->_block);
    return &vec->vec[0];
  }
  else {
    // single evidence
    *single = kk_evv_as_ev(evv,ctx);
    *len = 1;
    return single;
  }
}

// kk_std_core_hnd__ev kk_ev_none(kk_context_t* ctx) {
//   static kk_std_core_hnd__ev ev_none_singleton = { kk_datatype_null_init };
//   if (kk_datatype_is_null(ev_none_singleton)) {
//     ev_none_singleton = kk_std_core_hnd__new_Ev(
//       kk_reuse_null,
//       0, // cpath
//       kk_std_core_hnd__new_Htag(kk_string_empty(),ctx), // tag ""
//       0,                                                // marker 0
//       kk_box_null(),                                    // no handler
//       // -1,                                               // bot
//       kk_evv_empty(ctx),
//       ctx
//     );
//   }
//   return kk_std_core_hnd__ev_dup(ev_none_singleton,ctx);
// }


kk_ssize_t kk_evv_index( struct kk_std_core_hnd_Htag htag, kk_context_t* ctx ) {
  // todo: drop htag?
  kk_ssize_t len;
  kk_std_core_hnd__ev single;
  kk_std_core_hnd__ev* vec = kk_evv_as_vec(ctx->evv,&len,&single,ctx);
  for(kk_ssize_t i = 0; i < len; i++) {
    struct kk_std_core_hnd_Ev* ev = kk_std_core_hnd__as_Ev(vec[i],ctx);
    if (kk_string_cmp_borrow(htag.tagname,ev->htag.tagname,ctx) <= 0) return i; // break on insertion point
  }
  //string_t evvs = kk_evv_show(dup_datatype_as(kk_evv_t,ctx->evv),ctx);
  //fatal_error(EFAULT,"cannot find tag '%s' in: %s", string_cbuf_borrow(htag.htag), string_cbuf_borrow(evvs));
  //drop_string_t(evvs,ctx);
  return len;
}


// static inline kk_cfc_t kk_cfc_lub(kk_cfc_t cfc1, kk_cfc_t cfc2) {
//   if (cfc1 < 0) return cfc2;
//   else if (cfc1+cfc2 == 1) return 2;
//   else if (cfc1>cfc2) return cfc1;
//   else return cfc2;
// }

// static inline struct kk_std_core_hnd_Ev* kk_evv_as_Ev( kk_evv_t evv, kk_context_t* ctx ) {
//   return kk_std_core_hnd__as_Ev(kk_evv_as_ev(evv,ctx),ctx);
// }


// static kk_cfc_t kk_evv_cfc_of_borrow(kk_evv_t evv, kk_context_t* ctx) {
//   if (kk_evv_is_vector(evv,ctx)) {
//     kk_cfc_t cfc = -1;
//     kk_ssize_t len;
//     kk_std_core_hnd__ev single;
//     kk_std_core_hnd__ev* vec = kk_evv_as_vec(ctx->evv,&len,&single,ctx);
//     for(kk_ssize_t i = 0; i < len; i++) {
//       struct kk_std_core_hnd_Ev* ev = kk_std_core_hnd__as_Ev(vec[i],ctx);
//       cfc = kk_cfc_lub(cfc, kk_handler_cfc_borrow(ev->hnd,ctx));
//     }
//     return cfc;
//   }
//   else {
//     struct kk_std_core_hnd_Ev* ev = kk_evv_as_Ev(evv,ctx);
//     return kk_handler_cfc_borrow(ev->hnd,ctx);
//   }
// }

bool kk_evv_is_affine(kk_context_t* ctx) {
  return false;
  // return (kk_evv_cfc_of_borrow(ctx->evv,ctx) <= 2);
}


// static void kk_evv_update_cfc_borrow(kk_evv_t evv, kk_cfc_t cfc, kk_context_t* ctx) {
//   kk_assert_internal(!kk_evv_is_empty(evv,ctx)); // should never happen (as named handlers are always in some context)
//   if (kk_evv_is_vector(evv,ctx)) {
//     kk_evv_vector_t vec = kk_evv_as_vector(evv,ctx);
//     vec->cfc = kk_integer_from_int32(kk_cfc_lub(kk_integer_clamp32_borrow(vec->cfc,ctx),cfc), ctx);
//   }
//   else {
//     struct kk_std_core_hnd_Ev* ev = kk_evv_as_Ev(evv,ctx);
//     ev->cfc = kk_cfc_lub(ev->cfc,cfc);
//   }
// }

kk_evv_t kk_evv_insert(kk_evv_t evvd, kk_std_core_hnd__ev evd, kk_context_t* ctx) {
  struct kk_std_core_hnd_Ev* ev = kk_std_core_hnd__as_Ev(evd,ctx);
  // update ev with parent evidence vector (either at init, or due to non-scoped resumptions)
  kk_marker_t marker = ev->marker;
  if (marker==0) { kk_std_core_hnd__ev_drop(evd,ctx); return evvd; } // ev-none
  kk_evv_drop(ev->hevv,ctx);
  ev->hevv = kk_evv_dup(evvd,ctx); // fixme: update in-place
  if (marker<0) { // negative marker is used for named evidence; this means this evidence should not be inserted into the evidence vector
    // kk_evv_update_cfc_borrow(evvd,ev->cfc,ctx); // update cfc in-place for named evidence
    kk_std_core_hnd__ev_drop(evd,ctx);
    return evvd;
  }
  // for regular handler evidence, insert ev
  kk_ssize_t n;
  kk_std_core_hnd__ev single;
  kk_std_core_hnd__ev* const evv1 = kk_evv_as_vec(evvd, &n, &single, ctx);
  if (n == 0) {
    // use ev directly as the evidence vector
    kk_evv_drop(evvd, ctx);
    return kk_ev_as_evv(evd,ctx);
  }
  else {
    // create evidence vector
    // const kk_cfc_t cfc = kk_cfc_lub(kk_evv_cfc_of_borrow(evvd, ctx), ev->cfc);
    // ev->cfc = cfc; // update in place
    kk_evv_vector_t vec2 = kk_evv_vector_alloc(n+1, /* cfc,*/ ctx);
    kk_std_core_hnd__ev* const evv2 = kk_evv_vector_buf(vec2, NULL);
    kk_ssize_t i;
    for (i = 0; i < n; i++) {
      struct kk_std_core_hnd_Ev* ev1 = kk_std_core_hnd__as_Ev(evv1[i],ctx);
      if (kk_string_cmp_borrow(ev->htag.tagname, ev1->htag.tagname,ctx) <= 0) break;
      evv2[i] = kk_std_core_hnd__ev_dup(evv1[i],ctx);
    }
    evv2[i] = evd;
    for (; i < n; i++) {
      evv2[i+1] = kk_std_core_hnd__ev_dup(evv1[i],ctx);
    }
    kk_evv_drop(evvd, ctx);  // assigned to evidence already
    return kk_datatype_from_base(vec2,ctx);
  }
}

kk_evv_t kk_evv_delete(kk_evv_t evvd, kk_ssize_t index, bool behind, kk_context_t* ctx) {
  kk_ssize_t n;
  kk_std_core_hnd__ev single;
  const kk_std_core_hnd__ev* evv1 = kk_evv_as_vec(evvd, &n, &single, ctx);
  if (n <= 1) {
    kk_evv_drop(evvd,ctx);
    return kk_evv_empty(ctx);
  }
  if (behind) index++;
  kk_assert_internal(index < n);
  // todo: copy without dupping (and later dropping) when possible
  // const kk_cfc_t cfc1 = kk_evv_cfc_of_borrow(evvd,ctx);
  kk_evv_vector_t const vec2 = kk_evv_vector_alloc(n-1,/*cfc1,*/ ctx);
  kk_std_core_hnd__ev* const evv2 = kk_evv_vector_buf(vec2,NULL);
  kk_ssize_t i;
  for(i = 0; i < index; i++) {
    evv2[i] = kk_std_core_hnd__ev_dup(evv1[i],ctx);
  }
  for(; i < n-1; i++) {
    evv2[i] = kk_std_core_hnd__ev_dup(evv1[i+1],ctx);
  }
  struct kk_std_core_hnd_Ev* ev = kk_std_core_hnd__as_Ev(evv1[index],ctx);
  // if (ev->cfc >= cfc1) {
  //   kk_cfc_t cfc = kk_std_core_hnd__as_Ev(evv2[0],ctx)->cfc;
  //   for(i = 1; i < n-1; i++) {
  //     cfc = kk_cfc_lub(cfc,kk_std_core_hnd__as_Ev(evv2[i],ctx)->cfc);
  //   }
  //   vec2->cfc = kk_integer_from_int32(cfc,ctx);
  // }
  kk_evv_drop(evvd,ctx);
  return kk_datatype_from_base(vec2,ctx);
}

kk_evv_t kk_evv_create(kk_evv_t evv1, kk_vector_t indices, kk_context_t* ctx) {
  kk_ssize_t len;
  kk_box_t* elems = kk_vector_buf_borrow(indices,&len,ctx); // borrows
  kk_evv_vector_t evv2 = kk_evv_vector_alloc(len,/* kk_evv_cfc_of_borrow(evv1,ctx),*/ ctx);
  kk_std_core_hnd__ev* buf2 = kk_evv_vector_buf(evv2,NULL);
  kk_assert_internal(kk_evv_is_vector(evv1,ctx));
  kk_ssize_t len1;
  kk_std_core_hnd__ev single;
  kk_std_core_hnd__ev* buf1 = kk_evv_as_vec(evv1,&len1,&single,ctx);
  for(kk_ssize_t i = 0; i < len; i++) {
    kk_ssize_t idx = kk_ssize_unbox(elems[i],KK_BORROWED,ctx);
    kk_assert_internal(idx < len1);
    buf2[i] = kk_std_core_hnd__ev_dup( buf1[idx], ctx );
  }
  kk_vector_drop(indices,ctx);
  kk_evv_drop(evv1,ctx);
  return kk_datatype_from_base(evv2,ctx);
}

kk_evv_t kk_evv_swap_create( kk_vector_t indices, kk_context_t* ctx ) {
  kk_ssize_t len;
  kk_box_t* vec = kk_vector_buf_borrow(indices,&len,ctx);
  if (len==0) {
    kk_vector_drop(indices,ctx);
    return kk_evv_swap_create0(ctx);
  }
  if (len==1) {
    kk_ssize_t i = kk_ssize_unbox(vec[0],KK_BORROWED,ctx);
    kk_vector_drop(indices,ctx);
    return kk_evv_swap_create1(i,ctx);
  }
  return kk_evv_swap( kk_evv_create(kk_evv_dup(ctx->evv,ctx),indices,ctx), ctx );
}


kk_string_t kk_evv_show(kk_evv_t evv, kk_context_t* ctx) {
  return kk_string_alloc_dup_valid_utf8("(not yet implemented: kk_evv_show)",ctx);
}


/*-----------------------------------------------------------------------
  Compose continuations
-----------------------------------------------------------------------*/

struct kcompose_fun_s {
  struct kk_function_s _base;
  kk_box_t      count;
  kk_function_t conts[1];
};

// kleisli composition of continuations
static kk_box_t kcompose( kk_function_t fself, kk_box_t x, kk_context_t* ctx) {
  struct kcompose_fun_s* self = kk_function_as(struct kcompose_fun_s*,fself,ctx);
  kk_intx_t count = kk_intf_unbox(self->count);
  kk_function_t* conts = &self->conts[0];
  // call each continuation in order
  for(kk_intx_t i = 0; i < count; i++) {
    // todo: take uniqueness of fself into account to avoid dup_function
    kk_function_t f = kk_function_dup(conts[i],ctx);
    x = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, x, ctx), ctx);
    if (kk_yielding(ctx)) {
      // if yielding, `yield_next` all continuations that still need to be done
      while(++i < count) {
        // todo: if fself is unique, we could copy without dup?
        kk_yield_extend(kk_function_dup(conts[i],ctx),ctx);
      }
      kk_function_drop(fself,ctx);
      kk_box_drop(x,ctx);     // still drop even though we yield as it may release a boxed value type?
      return kk_box_any(ctx); // return yielding
    }
  }
  kk_function_drop(fself,ctx);
  return x;
}

static kk_function_t new_kcompose( kk_function_t* conts, kk_intf_t count, kk_context_t* ctx ) {
  if (count==0) return kk_function_id(ctx);
  if (count==1) return conts[0];
  struct kcompose_fun_s* f = kk_block_as(struct kcompose_fun_s*,
                               kk_block_alloc(kk_ssizeof(struct kcompose_fun_s) - kk_ssizeof(kk_function_t) + (count*kk_ssizeof(kk_function_t)),
                                 2 + count /* scan size */, KK_TAG_FUNCTION, ctx));
  f->_base.fun = kk_kkfun_ptr_box(&kcompose,ctx);
  f->count = kk_intf_box(count);
  kk_memcpy(f->conts, conts, count * kk_ssizeof(kk_function_t));
  return kk_datatype_from_base(&f->_base,ctx);
}

/*-----------------------------------------------------------------------
  Yield extension
-----------------------------------------------------------------------*/

kk_box_t kk_yield_extend( kk_function_t next, kk_context_t* ctx ) {
  kk_yield_t* yield = &ctx->yield;
  kk_assert_internal(kk_yielding(ctx));  // cannot extend if not yielding
  if (kk_unlikely(kk_yielding_final(ctx))) {
    // todo: can we optimize this so `next` is never allocated in the first place?
    kk_function_drop(next,ctx); // ignore extension if never resuming
  }
  else {
    if (kk_unlikely(yield->conts_count >= KK_YIELD_CONT_MAX)) {
      // alloc a function to compose all continuations in the array
      kk_function_t comp = new_kcompose( yield->conts, yield->conts_count, ctx );
      yield->conts[0] = comp;
      yield->conts_count = 1;
    }
    yield->conts[yield->conts_count++] = next;
  }
  return kk_box_any(ctx);
}

// cont_apply: \x -> f(cont,x)
struct cont_apply_fun_s {
  struct kk_function_s _base;
  kk_function_t f;
  kk_function_t cont;
};

static kk_box_t cont_apply( kk_function_t fself, kk_box_t x, kk_context_t* ctx ) {
  struct cont_apply_fun_s* self = kk_function_as(struct cont_apply_fun_s*, fself, ctx);
  kk_function_t f = self->f;
  kk_function_t cont = self->cont;
  kk_drop_match(self,{kk_function_dup(f,ctx);kk_function_dup(cont,ctx);},{},ctx);
  return kk_function_call( kk_box_t, (kk_function_t, kk_function_t, kk_box_t, kk_context_t* ctx), f, (f, cont, x, ctx), ctx);
}

static kk_function_t kk_new_cont_apply( kk_function_t f, kk_function_t cont, kk_context_t* ctx ) {
  struct cont_apply_fun_s* self = kk_function_alloc_as(struct cont_apply_fun_s, 3, ctx);
  self->_base.fun = kk_kkfun_ptr_box(&cont_apply,ctx);
  self->f = f;
  self->cont = cont;
  return kk_datatype_from_base(&self->_base,ctx);
}

// Unlike `yield_extend`, `yield_cont` gets access to the current continuation. This is used in `yield_prompt`.
kk_box_t kk_yield_cont( kk_function_t f, kk_context_t* ctx ) {
  kk_yield_t* yield = &ctx->yield;
  kk_assert_internal(kk_yielding(ctx)); // cannot extend if not yielding
  if (kk_unlikely(kk_yielding_final(ctx))) {
    kk_function_drop(f,ctx); // ignore extension if never resuming
  }
  else {
    kk_function_t cont = new_kcompose(yield->conts, yield->conts_count, ctx);
    yield->conts_count = 1;
    yield->conts[0] = kk_new_cont_apply(f, cont, ctx);
  }
  return kk_box_any(ctx);
}

kk_function_t kk_yield_to( kk_marker_t m, kk_function_t clause, kk_context_t* ctx ) {
  kk_yield_t* yield = &ctx->yield;
  kk_assert_internal(!kk_yielding(ctx)); // already yielding
  ctx->yielding = KK_YIELD_NORMAL;
  yield->marker = m;
  yield->clause = clause;
  yield->conts_count = 0;
  return kk_datatype_unbox(kk_box_any(ctx));
}

kk_box_t kk_yield_final( kk_marker_t m, kk_function_t clause, kk_context_t* ctx ) {
  kk_yield_to(m,clause,ctx);
  ctx->yielding = KK_YIELD_FINAL;
  return kk_box_any(ctx);
}

kk_box_t kk_fatal_resume_final(kk_context_t* ctx) {
  kk_fatal_error(EFAULT,"trying to resume a finalized resumption");
  return kk_box_any(ctx);
}

static kk_box_t _fatal_resume_final(kk_function_t self, kk_context_t* ctx) {
  kk_function_drop(self,ctx);
  return kk_fatal_resume_final(ctx);
}
static kk_function_t fun_fatal_resume_final(kk_context_t* ctx) {
  kk_define_static_function(f,_fatal_resume_final,ctx);
  return kk_function_dup(f,ctx);
}


struct kk_std_core_hnd_yld_s kk_yield_prompt( kk_marker_t m, kk_context_t* ctx ) {
  kk_yield_t* yield = &ctx->yield;
  if (ctx->yielding == KK_YIELD_NONE) {
    return kk_std_core_hnd__new_Pure(ctx);
  }
  else if (yield->marker != m) {
    return (ctx->yielding == KK_YIELD_FINAL ? kk_std_core_hnd__new_YieldingFinal(ctx) : kk_std_core_hnd__new_Yielding(ctx));
  }
  else {
    kk_function_t cont = (ctx->yielding == KK_YIELD_FINAL ? fun_fatal_resume_final(ctx) : new_kcompose(yield->conts, yield->conts_count, ctx));
    kk_function_t clause = yield->clause;
    ctx->yielding = KK_YIELD_NONE;
    #ifndef NDEBUG
    kk_memset(yield,0,kk_ssizeof(kk_yield_t));
    #endif
    return kk_std_core_hnd__new_Yield(clause, cont, ctx);
  }
}

kk_unit_t  kk_evv_guard(kk_evv_t evv, kk_context_t* ctx) {
  bool eq = kk_datatype_eq(ctx->evv,evv);
  kk_evv_drop(evv,ctx);
  if (!eq) {
    // todo: improve error message with diagnostics
    kk_fatal_error(EFAULT,"trying to resume outside the (handler) scope of the original handler");
  }
  return kk_Unit;
}

typedef struct yield_info_s {
  struct kk_std_core_hnd__yield_info_s _base;
  kk_function_t clause;
  kk_function_t conts[KK_YIELD_CONT_MAX];
  kk_intf_t     conts_count;
  kk_marker_t   marker;
  int8_t        yielding;
}* yield_info_t;

kk_std_core_hnd__yield_info kk_yield_capture(kk_context_t* ctx) {
  kk_assert_internal(kk_yielding(ctx));
  yield_info_t yld = kk_block_alloc_as(struct yield_info_s, 1 + KK_YIELD_CONT_MAX, (kk_tag_t)1, ctx);
  yld->clause = ctx->yield.clause;
  kk_ssize_t i = 0;
  for( ; i < ctx->yield.conts_count; i++) {
    yld->conts[i] = ctx->yield.conts[i];
  }
  for( ; i < KK_YIELD_CONT_MAX; i++) {
    yld->conts[i] = kk_function_null(ctx);
  }
  yld->conts_count = ctx->yield.conts_count;
  yld->marker = ctx->yield.marker;
  yld->yielding = ctx->yielding;
  ctx->yielding = 0;
  ctx->yield.conts_count = 0;
  return kk_datatype_from_base(&yld->_base,ctx);
}

kk_box_t kk_yield_reyield( kk_std_core_hnd__yield_info yldinfo, kk_context_t* ctx) {
  kk_assert_internal(!kk_yielding(ctx));
  yield_info_t yld = kk_datatype_as_assert(yield_info_t, yldinfo, (kk_tag_t)1, ctx);
  ctx->yield.clause = kk_function_dup(yld->clause,ctx);
  ctx->yield.marker = yld->marker;
  ctx->yield.conts_count = yld->conts_count;
  ctx->yielding = yld->yielding;
  for(kk_ssize_t i = 0; i < yld->conts_count; i++) {
    ctx->yield.conts[i] = kk_function_dup(yld->conts[i],ctx);
  }
  kk_constructor_drop(yld,ctx);
  return kk_box_any(ctx);
}


kk_std_core_hnd__htag kk_std_core_hnd_htag_fs__copy(kk_std_core_hnd__htag _this, kk_std_core_types__optional tagname, kk_context_t* _ctx) { /* forall<a> (htag<a>, tagname : ? string) -> htag<a> */ 
  kk_string_t _x_x270;
  if (kk_std_core_types__is_Optional(tagname, _ctx)) {
    kk_box_t _box_x0 = tagname._cons._Optional.value;
    kk_string_t _uniq_tagname_2014 = kk_string_unbox(_box_x0);
    kk_string_dup(_uniq_tagname_2014, _ctx);
    kk_std_core_types__optional_drop(tagname, _ctx);
    kk_std_core_hnd__htag_drop(_this, _ctx);
    _x_x270 = _uniq_tagname_2014; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(tagname, _ctx);
    {
      kk_string_t _x = _this.tagname;
      _x_x270 = _x; /*string*/
    }
  }
  return kk_std_core_hnd__new_Htag(_x_x270, _ctx);
}

kk_std_core_hnd__ev kk_std_core_hnd_ev_fs__copy(kk_std_core_hnd__ev _this, kk_std_core_types__optional htag, int32_t marker, kk_box_t hnd, kk_evv_t hevv, kk_context_t* _ctx) { /* forall<a,e,b> (ev<a>, htag : ? (htag<a>), marker : marker<e,b>, hnd : a<e,b>, hevv : evv<e>) -> ev<a> */ 
  kk_std_core_hnd__htag _x_x272;
  if (kk_std_core_types__is_Optional(htag, _ctx)) {
    kk_box_t _box_x1 = htag._cons._Optional.value;
    kk_std_core_hnd__htag _uniq_htag_2065 = kk_std_core_hnd__htag_unbox(_box_x1, KK_BORROWED, _ctx);
    kk_std_core_hnd__htag_dup(_uniq_htag_2065, _ctx);
    kk_std_core_types__optional_drop(htag, _ctx);
    kk_datatype_ptr_dropn(_this, (KK_I32(3)), _ctx);
    _x_x272 = _uniq_htag_2065; /*hnd/htag<2090>*/
  }
  else {
    kk_std_core_types__optional_drop(htag, _ctx);
    {
      struct kk_std_core_hnd_Ev* _con_x273 = kk_std_core_hnd__as_Ev(_this, _ctx);
      kk_std_core_hnd__htag _x = _con_x273->htag;
      kk_box_t _pat_1_0 = _con_x273->hnd;
      kk_evv_t _pat_2 = _con_x273->hevv;
      if kk_likely(kk_datatype_ptr_is_unique(_this, _ctx)) {
        kk_evv_drop(_pat_2, _ctx);
        kk_box_drop(_pat_1_0, _ctx);
        kk_datatype_ptr_free(_this, _ctx);
      }
      else {
        kk_std_core_hnd__htag_dup(_x, _ctx);
        kk_datatype_ptr_decref(_this, _ctx);
      }
      _x_x272 = _x; /*hnd/htag<2090>*/
    }
  }
  return kk_std_core_hnd__new_Ev(kk_reuse_null, 0, _x_x272, marker, hnd, hevv, _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause0_fs__copy_fun275__t {
  struct kk_function_s _base;
  kk_box_t _fun_unbox_x7;
};
static kk_box_t kk_std_core_hnd_clause0_fs__copy_fun275(kk_function_t _fself, int32_t _b_x11, kk_std_core_hnd__ev _b_x12, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_clause0_fs__new_copy_fun275(kk_box_t _fun_unbox_x7, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause0_fs__copy_fun275__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause0_fs__copy_fun275__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause0_fs__copy_fun275, kk_context());
  _self->_fun_unbox_x7 = _fun_unbox_x7;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause0_fs__copy_fun275(kk_function_t _fself, int32_t _b_x11, kk_std_core_hnd__ev _b_x12, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause0_fs__copy_fun275__t* _self = kk_function_as(struct kk_std_core_hnd_clause0_fs__copy_fun275__t*, _fself, _ctx);
  kk_box_t _fun_unbox_x7 = _self->_fun_unbox_x7; /* 7 */
  kk_drop_match(_self, {kk_box_dup(_fun_unbox_x7, _ctx);}, {}, _ctx)
  kk_function_t _x_x276 = kk_function_unbox(_fun_unbox_x7, _ctx); /*(8, 9) -> 2194 10*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), _x_x276, (_x_x276, kk_int32_box(_b_x11, _ctx), kk_std_core_hnd__ev_box(_b_x12, _ctx), _ctx), _ctx);
}

kk_std_core_hnd__clause0 kk_std_core_hnd_clause0_fs__copy(kk_std_core_hnd__clause0 _this, kk_std_core_types__optional clause, kk_context_t* _ctx) { /* forall<a,b,e,c> (clause0<a,b,e,c>, clause : ? ((marker<e,c>, ev<b>) -> e a)) -> clause0<a,b,e,c> */ 
  kk_function_t _x_x274;
  if (kk_std_core_types__is_Optional(clause, _ctx)) {
    kk_box_t _fun_unbox_x7 = clause._cons._Optional.value;
    kk_box_dup(_fun_unbox_x7, _ctx);
    kk_std_core_types__optional_drop(clause, _ctx);
    kk_std_core_hnd__clause0_drop(_this, _ctx);
    _x_x274 = kk_std_core_hnd_clause0_fs__new_copy_fun275(_fun_unbox_x7, _ctx); /*(hnd/marker<2194,2195>, hnd/ev<2193>) -> 2194 10*/
  }
  else {
    kk_std_core_types__optional_drop(clause, _ctx);
    {
      kk_function_t _x = _this.clause;
      _x_x274 = _x; /*(hnd/marker<2194,2195>, hnd/ev<2193>) -> 2194 10*/
    }
  }
  return kk_std_core_hnd__new_Clause0(_x_x274, _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause1_fs__copy_fun278__t {
  struct kk_function_s _base;
  kk_box_t _fun_unbox_x20;
};
static kk_box_t kk_std_core_hnd_clause1_fs__copy_fun278(kk_function_t _fself, int32_t _b_x25, kk_std_core_hnd__ev _b_x26, kk_box_t _b_x27, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_clause1_fs__new_copy_fun278(kk_box_t _fun_unbox_x20, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause1_fs__copy_fun278__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause1_fs__copy_fun278__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause1_fs__copy_fun278, kk_context());
  _self->_fun_unbox_x20 = _fun_unbox_x20;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause1_fs__copy_fun278(kk_function_t _fself, int32_t _b_x25, kk_std_core_hnd__ev _b_x26, kk_box_t _b_x27, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause1_fs__copy_fun278__t* _self = kk_function_as(struct kk_std_core_hnd_clause1_fs__copy_fun278__t*, _fself, _ctx);
  kk_box_t _fun_unbox_x20 = _self->_fun_unbox_x20; /* 7 */
  kk_drop_match(_self, {kk_box_dup(_fun_unbox_x20, _ctx);}, {}, _ctx)
  kk_function_t _x_x279 = kk_function_unbox(_fun_unbox_x20, _ctx); /*(21, 22, 23) -> 2322 24*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), _x_x279, (_x_x279, kk_int32_box(_b_x25, _ctx), kk_std_core_hnd__ev_box(_b_x26, _ctx), _b_x27, _ctx), _ctx);
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause1_fs__copy(kk_std_core_hnd__clause1 _this, kk_std_core_types__optional clause, kk_context_t* _ctx) { /* forall<a,b,c,e,d> (clause1<a,b,c,e,d>, clause : ? ((marker<e,d>, ev<c>, a) -> e b)) -> clause1<a,b,c,e,d> */ 
  kk_function_t _x_x277;
  if (kk_std_core_types__is_Optional(clause, _ctx)) {
    kk_box_t _fun_unbox_x20 = clause._cons._Optional.value;
    kk_box_dup(_fun_unbox_x20, _ctx);
    kk_std_core_types__optional_drop(clause, _ctx);
    kk_std_core_hnd__clause1_drop(_this, _ctx);
    _x_x277 = kk_std_core_hnd_clause1_fs__new_copy_fun278(_fun_unbox_x20, _ctx); /*(hnd/marker<2322,2323>, hnd/ev<2321>, 2319) -> 2322 24*/
  }
  else {
    kk_std_core_types__optional_drop(clause, _ctx);
    {
      kk_function_t _x = _this.clause;
      _x_x277 = _x; /*(hnd/marker<2322,2323>, hnd/ev<2321>, 2319) -> 2322 24*/
    }
  }
  return kk_std_core_hnd__new_Clause1(_x_x277, _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause2_fs__copy_fun281__t {
  struct kk_function_s _base;
  kk_box_t _fun_unbox_x37;
};
static kk_box_t kk_std_core_hnd_clause2_fs__copy_fun281(kk_function_t _fself, int32_t _b_x43, kk_std_core_hnd__ev _b_x44, kk_box_t _b_x45, kk_box_t _b_x46, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_clause2_fs__new_copy_fun281(kk_box_t _fun_unbox_x37, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause2_fs__copy_fun281__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause2_fs__copy_fun281__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause2_fs__copy_fun281, kk_context());
  _self->_fun_unbox_x37 = _fun_unbox_x37;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause2_fs__copy_fun281(kk_function_t _fself, int32_t _b_x43, kk_std_core_hnd__ev _b_x44, kk_box_t _b_x45, kk_box_t _b_x46, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause2_fs__copy_fun281__t* _self = kk_function_as(struct kk_std_core_hnd_clause2_fs__copy_fun281__t*, _fself, _ctx);
  kk_box_t _fun_unbox_x37 = _self->_fun_unbox_x37; /* 7 */
  kk_drop_match(_self, {kk_box_dup(_fun_unbox_x37, _ctx);}, {}, _ctx)
  kk_function_t _x_x282 = kk_function_unbox(_fun_unbox_x37, _ctx); /*(38, 39, 40, 41) -> 2476 42*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), _x_x282, (_x_x282, kk_int32_box(_b_x43, _ctx), kk_std_core_hnd__ev_box(_b_x44, _ctx), _b_x45, _b_x46, _ctx), _ctx);
}

kk_std_core_hnd__clause2 kk_std_core_hnd_clause2_fs__copy(kk_std_core_hnd__clause2 _this, kk_std_core_types__optional clause, kk_context_t* _ctx) { /* forall<a,b,c,d,e,a1> (clause2<a,b,c,d,e,a1>, clause : ? ((marker<e,a1>, ev<d>, a, b) -> e c)) -> clause2<a,b,c,d,e,a1> */ 
  kk_function_t _x_x280;
  if (kk_std_core_types__is_Optional(clause, _ctx)) {
    kk_box_t _fun_unbox_x37 = clause._cons._Optional.value;
    kk_box_dup(_fun_unbox_x37, _ctx);
    kk_std_core_types__optional_drop(clause, _ctx);
    kk_std_core_hnd__clause2_drop(_this, _ctx);
    _x_x280 = kk_std_core_hnd_clause2_fs__new_copy_fun281(_fun_unbox_x37, _ctx); /*(hnd/marker<2476,2477>, hnd/ev<2475>, 2472, 2473) -> 2476 42*/
  }
  else {
    kk_std_core_types__optional_drop(clause, _ctx);
    {
      kk_function_t _x = _this.clause;
      _x_x280 = _x; /*(hnd/marker<2476,2477>, hnd/ev<2475>, 2472, 2473) -> 2476 42*/
    }
  }
  return kk_std_core_hnd__new_Clause2(_x_x280, _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_resume_context_fs__copy_fun284__t {
  struct kk_function_s _base;
  kk_box_t _fun_unbox_x50;
};
static kk_box_t kk_std_core_hnd_resume_context_fs__copy_fun284(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x53, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_resume_context_fs__new_copy_fun284(kk_box_t _fun_unbox_x50, kk_context_t* _ctx) {
  struct kk_std_core_hnd_resume_context_fs__copy_fun284__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_resume_context_fs__copy_fun284__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_resume_context_fs__copy_fun284, kk_context());
  _self->_fun_unbox_x50 = _fun_unbox_x50;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_resume_context_fs__copy_fun284(kk_function_t _fself, kk_std_core_hnd__resume_result _b_x53, kk_context_t* _ctx) {
  struct kk_std_core_hnd_resume_context_fs__copy_fun284__t* _self = kk_function_as(struct kk_std_core_hnd_resume_context_fs__copy_fun284__t*, _fself, _ctx);
  kk_box_t _fun_unbox_x50 = _self->_fun_unbox_x50; /* 7 */
  kk_drop_match(_self, {kk_box_dup(_fun_unbox_x50, _ctx);}, {}, _ctx)
  kk_function_t _x_x285 = kk_function_unbox(_fun_unbox_x50, _ctx); /*(51) -> 2647 52*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), _x_x285, (_x_x285, kk_std_core_hnd__resume_result_box(_b_x53, _ctx), _ctx), _ctx);
}

kk_std_core_hnd__resume_context kk_std_core_hnd_resume_context_fs__copy(kk_std_core_hnd__resume_context _this, kk_std_core_types__optional k, kk_context_t* _ctx) { /* forall<a,e,e1,b> (resume-context<a,e,e1,b>, k : ? ((resume-result<a,b>) -> e b)) -> resume-context<a,e,e1,b> */ 
  kk_function_t _x_x283;
  if (kk_std_core_types__is_Optional(k, _ctx)) {
    kk_box_t _fun_unbox_x50 = k._cons._Optional.value;
    kk_box_dup(_fun_unbox_x50, _ctx);
    kk_std_core_types__optional_drop(k, _ctx);
    kk_std_core_hnd__resume_context_drop(_this, _ctx);
    _x_x283 = kk_std_core_hnd_resume_context_fs__new_copy_fun284(_fun_unbox_x50, _ctx); /*(hnd/resume-result<2646,2649>) -> 2647 52*/
  }
  else {
    kk_std_core_types__optional_drop(k, _ctx);
    {
      kk_function_t _x = _this.k;
      _x_x283 = _x; /*(hnd/resume-result<2646,2649>) -> 2647 52*/
    }
  }
  return kk_std_core_hnd__new_Resume_context(_x_x283, _ctx);
}
 
// (dynamically) find evidence insertion/deletion index in the evidence vector
// The compiler optimizes `@evv-index` to a static index when apparent from the effect type.

kk_ssize_t kk_std_core_hnd__evv_index(kk_std_core_hnd__htag htag, kk_context_t* _ctx) { /* forall<e,a> (htag : htag<a>) -> e ev-index */ 
  return kk_evv_index(htag,kk_context());
}
 
// Does the current evidence vector consist solely of affine handlers?
// This is called in backends that do not have context paths (like javascript)
// to optimize TRMC (where we can use faster update-in-place TRMC if we know the
// operations are all affine). As such, it is always safe to return `false`.
//
// control flow context:
//                 -1: none: bottom
//                   /
// 0: except: never resumes   1: linear: resumes exactly once
//                   \          /
//           2: affine: resumes never or once
//                        |
//     3: multi: resumes never, once, or multiple times
//

bool kk_std_core_hnd__evv_is_affine(kk_context_t* _ctx) { /* () -> bool */ 
  return kk_evv_is_affine(kk_context());
}

kk_box_t kk_std_core_hnd__reset_vm(int32_t m, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,b> (m : marker<e,b>, ret : (a) -> e b, action : () -> e a) -> e b */ 
  return kk_box_null();
}

kk_box_t kk_std_core_hnd__prompt_local_var_prim_vm(kk_box_t init, kk_function_t action, kk_context_t* _ctx) { /* forall<a,b,e,h> (init : a, action : (l : local-var<h,a>) -> <local<h>|e> b) -> <local<h>|e> b */ 
  return kk_box_null();
}

kk_box_t kk_std_core_hnd__protect_vm(kk_box_t x, kk_function_t clause, kk_function_t k, kk_context_t* _ctx) { /* forall<a,b,e,c> (x : a, clause : (x : a, k : (b) -> e c) -> e c, k : (b) -> e c) -> e c */ 
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_function_t, kk_context_t*), clause, (clause, x, k, _ctx), _ctx);
}

kk_box_t kk_std_core_hnd__yield_to_prim_vm(int32_t m, kk_function_t clause, kk_context_t* _ctx) { /* forall<a,e,e1,b> (m : marker<e1,b>, clause : ((a) -> e1 b) -> e1 b) -> e a */ 
  return kk_box_null();
}
 
// Get the current evidence vector.

kk_evv_t kk_std_core_hnd_evv_get(kk_context_t* _ctx) { /* forall<e> () -> e evv<e> */ 
  return kk_evv_get(kk_context());
}
 
// Insert new evidence into the given evidence vector.

kk_evv_t kk_std_core_hnd_evv_insert(kk_evv_t evv, kk_std_core_hnd__ev ev, kk_context_t* _ctx) { /* forall<e,e1,a> (evv : evv<e>, ev : ev<a>) -> e evv<e1> */ 
  return kk_evv_insert(evv,ev,kk_context());
}

int32_t kk_std_core_hnd_fresh_marker(kk_context_t* _ctx) { /* forall<a,e> () -> marker<e,a> */ 
  return kk_marker_unique(kk_context());
}
 
// Is an evidence vector unchanged? (i.e. as pointer equality).
// This is used to avoid copying in common cases.

bool kk_std_core_hnd_evv_eq(kk_evv_t evv0, kk_evv_t evv1, kk_context_t* _ctx) { /* forall<e> (evv0 : evv<e>, evv1 : evv<e>) -> bool */ 
  return kk_evv_eq(evv0,evv1,kk_context());
}

kk_unit_t kk_std_core_hnd_guard(kk_evv_t w, kk_context_t* _ctx) { /* forall<e> (w : evv<e>) -> e () */ 
  kk_evv_guard(w,kk_context()); return kk_Unit;
}

kk_box_t kk_std_core_hnd_yield_extend(kk_function_t next, kk_context_t* _ctx) { /* forall<a,b,e> (next : (a) -> e b) -> e b */ 
  return kk_yield_extend(next,kk_context());
}

kk_box_t kk_std_core_hnd_yield_cont(kk_function_t f, kk_context_t* _ctx) { /* forall<a,e,b> (f : forall<c> ((c) -> e a, c) -> e b) -> e b */ 
  return kk_yield_cont(f,kk_context());
}

kk_std_core_hnd__yld kk_std_core_hnd_yield_prompt(int32_t m, kk_context_t* _ctx) { /* forall<a,e,b> (m : marker<e,b>) -> yld<e,a,b> */ 
  return kk_yield_prompt(m,kk_context());
}

kk_box_t kk_std_core_hnd_yield_to_final(int32_t m, kk_function_t clause, kk_context_t* _ctx) { /* forall<a,e,e1,b> (m : marker<e1,b>, clause : ((resume-result<a,b>) -> e1 b) -> e1 b) -> e a */ 
  return kk_yield_final(m,clause,kk_context());
}
 
// Remove evidence at index `i` of the current evidence vector, and return the old one.
// (used by `mask`)

kk_evv_t kk_std_core_hnd_evv_swap_delete(kk_ssize_t i, bool behind, kk_context_t* _ctx) { /* forall<e,e1> (i : ev-index, behind : bool) -> e1 evv<e> */ 
  return kk_evv_swap_delete(i,behind,kk_context());
}

int32_t kk_std_core_hnd_fresh_marker_named(kk_context_t* _ctx) { /* forall<a,e> () -> marker<e,a> */ 
  return -kk_marker_unique(kk_context());
}
 
// Swap the current evidence vector with a new vector consisting of evidence
// at indices `indices` in the current vector.

kk_evv_t kk_std_core_hnd_evv_swap_create(kk_vector_t indices, kk_context_t* _ctx) { /* forall<e> (indices : vector<ev-index>) -> e evv<e> */ 
  return kk_evv_swap_create(indices,kk_context());
}

kk_function_t kk_std_core_hnd_yield_to_prim(int32_t m, kk_function_t clause, kk_context_t* _ctx) { /* forall<a,e,e1,b> (m : marker<e1,b>, clause : ((resume-result<a,b>) -> e1 b) -> e1 b) -> e (() -> a) */ 
  return kk_yield_to(m,clause,kk_context());
}
extern kk_box_t kk_std_core_hnd_clause_tail_noop0_fun291(kk_function_t _fself, int32_t ___wildcard_x737__14, kk_std_core_hnd__ev ___wildcard_x737__17, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail_noop0_fun291__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail_noop0_fun291__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* () -> 4088 4091 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x737__17, (KK_I32(3)), _ctx);
  return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), op, (op, _ctx), _ctx);
}
extern kk_box_t kk_std_core_hnd_clause_tail_noop1_fun292(kk_function_t _fself, int32_t ___wildcard_x691__14, kk_std_core_hnd__ev ___wildcard_x691__17, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail_noop1_fun292__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail_noop1_fun292__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (4146) -> 4143 4147 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x691__17, (KK_I32(3)), _ctx);
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), op, (op, x, _ctx), _ctx);
}
extern kk_box_t kk_std_core_hnd_clause_tail_noop2_fun293(kk_function_t _fself, int32_t ___wildcard_x779__14, kk_std_core_hnd__ev ___wildcard_x779__17, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail_noop2_fun293__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail_noop2_fun293__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (4212, 4213) -> 4209 4214 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x779__17, (KK_I32(3)), _ctx);
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, _ctx), _ctx);
}

kk_evv_t kk_std_core_hnd_evv_swap_with(kk_std_core_hnd__ev ev, kk_context_t* _ctx) { /* forall<a,e> (ev : ev<a>) -> evv<e> */ 
  kk_evv_t _x_x294;
  {
    struct kk_std_core_hnd_Ev* _con_x295 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_std_core_hnd__htag _pat_0 = _con_x295->htag;
    kk_box_t _pat_2 = _con_x295->hnd;
    kk_evv_t w = _con_x295->hevv;
    if kk_likely(kk_datatype_ptr_is_unique(ev, _ctx)) {
      kk_box_drop(_pat_2, _ctx);
      kk_std_core_hnd__htag_drop(_pat_0, _ctx);
      kk_datatype_ptr_free(ev, _ctx);
    }
    else {
      kk_evv_dup(w, _ctx);
      kk_datatype_ptr_decref(ev, _ctx);
    }
    _x_x294 = w; /*hnd/evv<4237>*/
  }
  return kk_evv_swap(_x_x294,kk_context());
}
extern kk_box_t kk_std_core_hnd_clause_value_fun296(kk_function_t _fself, int32_t ___wildcard_x740__14, kk_std_core_hnd__ev ___wildcard_x740__17, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_value_fun296__t* _self = kk_function_as(struct kk_std_core_hnd_clause_value_fun296__t*, _fself, _ctx);
  kk_box_t v = _self->v; /* 4302 */
  kk_drop_match(_self, {kk_box_dup(v, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x740__17, (KK_I32(3)), _ctx);
  return v;
}
 
// Are two markers equal?

bool kk_std_core_hnd_eq_marker(int32_t x, int32_t y, kk_context_t* _ctx) { /* forall<a,b,e,e1> (x : marker<e,a>, y : marker<e1,b>) -> bool */ 
  return x==y;
}
 
// show evidence for debug purposes

kk_string_t kk_std_core_hnd_evv_show(kk_evv_t evv, kk_context_t* _ctx) { /* forall<e> (evv : evv<e>) -> string */ 
  return kk_evv_show(evv,kk_context());
}

kk_box_t kk_std_core_hnd_unsafe_reyield(kk_std_core_hnd__yield_info yld, kk_context_t* _ctx) { /* forall<a,e> (yld : yield-info) -> e a */ 
  return kk_yield_reyield(yld,kk_context());
}

kk_std_core_hnd__yield_info kk_std_core_hnd_yield_capture(kk_context_t* _ctx) { /* forall<e> () -> e yield-info */ 
  return kk_yield_capture(kk_context());
}

kk_box_t kk_std_core_hnd_resume_final(kk_context_t* _ctx) { /* forall<a> () -> a */ 
  return kk_fatal_resume_final(kk_context());
}


// lift anonymous function
struct kk_std_core_hnd_prompt_fun301__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
  kk_function_t ret;
  kk_evv_t w0;
  kk_evv_t w1;
  int32_t m;
};
static kk_box_t kk_std_core_hnd_prompt_fun301(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_prompt_fun301(kk_std_core_hnd__ev ev, kk_function_t ret, kk_evv_t w0, kk_evv_t w1, int32_t m, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun301__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_prompt_fun301__t, 5, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_prompt_fun301, kk_context());
  _self->ev = ev;
  _self->ret = ret;
  _self->w0 = w0;
  _self->w1 = w1;
  _self->m = m;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_prompt_fun301(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun301__t* _self = kk_function_as(struct kk_std_core_hnd_prompt_fun301__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<4981> */
  kk_function_t ret = _self->ret; /* (4979) -> 4980 4982 */
  kk_evv_t w0 = _self->w0; /* hnd/evv<4980> */
  kk_evv_t w1 = _self->w1; /* hnd/evv<4980> */
  int32_t m = _self->m; /* hnd/marker<4980,4982> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);kk_function_dup(ret, _ctx);kk_evv_dup(w0, _ctx);kk_evv_dup(w1, _ctx);kk_skip_dup(m, _ctx);}, {}, _ctx)
  kk_evv_t w0_sq_ = kk_std_core_hnd_evv_get(_ctx); /*hnd/evv<4980>*/;
  kk_evv_t w1_sq_;
  bool _match_x256;
  kk_evv_t _x_x302 = kk_evv_dup(w0_sq_, _ctx); /*hnd/evv<4980>*/
  _match_x256 = kk_std_core_hnd_evv_eq(w0, _x_x302, _ctx); /*bool*/
  if (_match_x256) {
    w1_sq_ = w1; /*hnd/evv<4980>*/
  }
  else {
    kk_evv_drop(w1, _ctx);
    kk_evv_t _x_x303 = kk_evv_dup(w0_sq_, _ctx); /*hnd/evv<4980>*/
    kk_std_core_hnd__ev _x_x304 = kk_std_core_hnd__ev_dup(ev, _ctx); /*hnd/ev<4981>*/
    w1_sq_ = kk_std_core_hnd_evv_insert(_x_x303, _x_x304, _ctx); /*hnd/evv<4980>*/
  }
  kk_unit_t ___1 = kk_Unit;
  kk_evv_t _x_x305 = kk_evv_dup(w1_sq_, _ctx); /*hnd/evv<4980>*/
  kk_evv_set(_x_x305,kk_context());
  kk_box_t _x_x306 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, res, _ctx), _ctx); /*4979*/
  return kk_std_core_hnd_prompt(w0_sq_, w1_sq_, ev, m, ret, _x_x306, _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_prompt_fun307__t {
  struct kk_function_s _base;
  kk_function_t cont_0;
  kk_std_core_hnd__ev ev;
  kk_function_t ret;
  kk_evv_t w0;
  kk_evv_t w1;
  int32_t m;
};
static kk_box_t kk_std_core_hnd_prompt_fun307(kk_function_t _fself, kk_std_core_hnd__resume_result r, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_prompt_fun307(kk_function_t cont_0, kk_std_core_hnd__ev ev, kk_function_t ret, kk_evv_t w0, kk_evv_t w1, int32_t m, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun307__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_prompt_fun307__t, 6, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_prompt_fun307, kk_context());
  _self->cont_0 = cont_0;
  _self->ev = ev;
  _self->ret = ret;
  _self->w0 = w0;
  _self->w1 = w1;
  _self->m = m;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_prompt_fun313__t {
  struct kk_function_s _base;
  kk_box_t x;
};
static kk_box_t kk_std_core_hnd_prompt_fun313(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_prompt_fun313(kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun313__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_prompt_fun313__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_prompt_fun313, kk_context());
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_prompt_fun313(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun313__t* _self = kk_function_as(struct kk_std_core_hnd_prompt_fun313__t*, _fself, _ctx);
  kk_box_t x = _self->x; /* 4779 */
  kk_drop_match(_self, {kk_box_dup(x, _ctx);}, {}, _ctx)
  return x;
}


// lift anonymous function
struct kk_std_core_hnd_prompt_fun314__t {
  struct kk_function_s _base;
  kk_box_t x_0;
};
static kk_box_t kk_std_core_hnd_prompt_fun314(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_prompt_fun314(kk_box_t x_0, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun314__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_prompt_fun314__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_prompt_fun314, kk_context());
  _self->x_0 = x_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_prompt_fun314(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun314__t* _self = kk_function_as(struct kk_std_core_hnd_prompt_fun314__t*, _fself, _ctx);
  kk_box_t x_0 = _self->x_0; /* 4779 */
  kk_drop_match(_self, {kk_box_dup(x_0, _ctx);}, {}, _ctx)
  return x_0;
}


// lift anonymous function
struct kk_std_core_hnd_prompt_fun320__t {
  struct kk_function_s _base;
  kk_box_t x_1_0;
  int32_t m;
};
static kk_box_t kk_std_core_hnd_prompt_fun320(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_prompt_fun320(kk_box_t x_1_0, int32_t m, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun320__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_prompt_fun320__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_prompt_fun320, kk_context());
  _self->x_1_0 = x_1_0;
  _self->m = m;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_prompt_fun321__t {
  struct kk_function_s _base;
  kk_box_t x_1_0;
};
static kk_box_t kk_std_core_hnd_prompt_fun321(kk_function_t _fself, kk_function_t ___wildcard_x432__85, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_prompt_fun321(kk_box_t x_1_0, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun321__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_prompt_fun321__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_prompt_fun321, kk_context());
  _self->x_1_0 = x_1_0;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_prompt_fun321(kk_function_t _fself, kk_function_t ___wildcard_x432__85, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun321__t* _self = kk_function_as(struct kk_std_core_hnd_prompt_fun321__t*, _fself, _ctx);
  kk_box_t x_1_0 = _self->x_1_0; /* 4982 */
  kk_drop_match(_self, {kk_box_dup(x_1_0, _ctx);}, {}, _ctx)
  kk_function_drop(___wildcard_x432__85, _ctx);
  return x_1_0;
}
static kk_box_t kk_std_core_hnd_prompt_fun320(kk_function_t _fself, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun320__t* _self = kk_function_as(struct kk_std_core_hnd_prompt_fun320__t*, _fself, _ctx);
  kk_box_t x_1_0 = _self->x_1_0; /* 4982 */
  int32_t m = _self->m; /* hnd/marker<4980,4982> */
  kk_drop_match(_self, {kk_box_dup(x_1_0, _ctx);kk_skip_dup(m, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_yield_to_final(m, kk_std_core_hnd_new_prompt_fun321(x_1_0, _ctx), _ctx);
}
static kk_box_t kk_std_core_hnd_prompt_fun307(kk_function_t _fself, kk_std_core_hnd__resume_result r, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_fun307__t* _self = kk_function_as(struct kk_std_core_hnd_prompt_fun307__t*, _fself, _ctx);
  kk_function_t cont_0 = _self->cont_0; /* (() -> 4779) -> 4980 4979 */
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<4981> */
  kk_function_t ret = _self->ret; /* (4979) -> 4980 4982 */
  kk_evv_t w0 = _self->w0; /* hnd/evv<4980> */
  kk_evv_t w1 = _self->w1; /* hnd/evv<4980> */
  int32_t m = _self->m; /* hnd/marker<4980,4982> */
  kk_drop_match(_self, {kk_function_dup(cont_0, _ctx);kk_std_core_hnd__ev_dup(ev, _ctx);kk_function_dup(ret, _ctx);kk_evv_dup(w0, _ctx);kk_evv_dup(w1, _ctx);kk_skip_dup(m, _ctx);}, {}, _ctx)
  if (kk_std_core_hnd__is_Deep(r, _ctx)) {
    kk_box_t x = r._cons.Deep.result;
    kk_evv_t w0_0_sq_ = kk_std_core_hnd_evv_get(_ctx); /*hnd/evv<4980>*/;
    kk_evv_t w1_0_sq_;
    bool _match_x255;
    kk_evv_t _x_x308 = kk_evv_dup(w0_0_sq_, _ctx); /*hnd/evv<4980>*/
    _match_x255 = kk_std_core_hnd_evv_eq(w0, _x_x308, _ctx); /*bool*/
    if (_match_x255) {
      w1_0_sq_ = w1; /*hnd/evv<4980>*/
    }
    else {
      kk_evv_drop(w1, _ctx);
      kk_evv_t _x_x309 = kk_evv_dup(w0_0_sq_, _ctx); /*hnd/evv<4980>*/
      kk_std_core_hnd__ev _x_x310 = kk_std_core_hnd__ev_dup(ev, _ctx); /*hnd/ev<4981>*/
      w1_0_sq_ = kk_std_core_hnd_evv_insert(_x_x309, _x_x310, _ctx); /*hnd/evv<4980>*/
    }
    kk_unit_t ___2 = kk_Unit;
    kk_evv_t _x_x311 = kk_evv_dup(w1_0_sq_, _ctx); /*hnd/evv<4980>*/
    kk_evv_set(_x_x311,kk_context());
    kk_box_t _x_x312 = kk_function_call(kk_box_t, (kk_function_t, kk_function_t, kk_context_t*), cont_0, (cont_0, kk_std_core_hnd_new_prompt_fun313(x, _ctx), _ctx), _ctx); /*4979*/
    return kk_std_core_hnd_prompt(w0_0_sq_, w1_0_sq_, ev, m, ret, _x_x312, _ctx);
  }
  if (kk_std_core_hnd__is_Shallow(r, _ctx)) {
    kk_box_t x_0 = r._cons.Shallow.result;
    kk_evv_drop(w1, _ctx);
    kk_evv_drop(w0, _ctx);
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    kk_box_t x_1_10006 = kk_function_call(kk_box_t, (kk_function_t, kk_function_t, kk_context_t*), cont_0, (cont_0, kk_std_core_hnd_new_prompt_fun314(x_0, _ctx), _ctx), _ctx); /*4979*/;
    if (kk_yielding(kk_context())) {
      kk_box_drop(x_1_10006, _ctx);
      return kk_std_core_hnd_yield_extend(ret, _ctx);
    }
    {
      return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), ret, (ret, x_1_10006, _ctx), _ctx);
    }
  }
  {
    kk_box_t x_1_0 = r._cons.Finalize.result;
    kk_evv_t w0_1_sq_ = kk_std_core_hnd_evv_get(_ctx); /*hnd/evv<4980>*/;
    kk_evv_t w1_1_sq_;
    bool _match_x253;
    kk_evv_t _x_x315 = kk_evv_dup(w0_1_sq_, _ctx); /*hnd/evv<4980>*/
    _match_x253 = kk_std_core_hnd_evv_eq(w0, _x_x315, _ctx); /*bool*/
    if (_match_x253) {
      w1_1_sq_ = w1; /*hnd/evv<4980>*/
    }
    else {
      kk_evv_drop(w1, _ctx);
      kk_evv_t _x_x316 = kk_evv_dup(w0_1_sq_, _ctx); /*hnd/evv<4980>*/
      kk_std_core_hnd__ev _x_x317 = kk_std_core_hnd__ev_dup(ev, _ctx); /*hnd/ev<4981>*/
      w1_1_sq_ = kk_std_core_hnd_evv_insert(_x_x316, _x_x317, _ctx); /*hnd/evv<4980>*/
    }
    kk_unit_t ___3 = kk_Unit;
    kk_evv_t _x_x318 = kk_evv_dup(w1_1_sq_, _ctx); /*hnd/evv<4980>*/
    kk_evv_set(_x_x318,kk_context());
    kk_box_t _x_x319 = kk_function_call(kk_box_t, (kk_function_t, kk_function_t, kk_context_t*), cont_0, (cont_0, kk_std_core_hnd_new_prompt_fun320(x_1_0, m, _ctx), _ctx), _ctx); /*4979*/
    return kk_std_core_hnd_prompt(w0_1_sq_, w1_1_sq_, ev, m, ret, _x_x319, _ctx);
  }
}

kk_box_t kk_std_core_hnd_prompt(kk_evv_t w0, kk_evv_t w1, kk_std_core_hnd__ev ev, int32_t m, kk_function_t ret, kk_box_t result, kk_context_t* _ctx) { /* forall<a,e,b,c> (w0 : evv<e>, w1 : evv<e>, ev : ev<b>, m : marker<e,c>, ret : (a) -> e c, result : a) -> e c */ 
  kk_unit_t __ = kk_Unit;
  kk_evv_t _x_x299 = kk_evv_dup(w1, _ctx); /*hnd/evv<4980>*/
  kk_std_core_hnd_guard(_x_x299, _ctx);
  kk_unit_t ___0 = kk_Unit;
  kk_evv_t _x_x300 = kk_evv_dup(w0, _ctx); /*hnd/evv<4980>*/
  kk_evv_set(_x_x300,kk_context());
  kk_std_core_hnd__yld _match_x252 = kk_std_core_hnd_yield_prompt(m, _ctx); /*hnd/yld<3806,3805,3807>*/;
  if (kk_std_core_hnd__is_Pure(_match_x252, _ctx)) {
    kk_evv_drop(w1, _ctx);
    kk_evv_drop(w0, _ctx);
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), ret, (ret, result, _ctx), _ctx);
  }
  if (kk_std_core_hnd__is_YieldingFinal(_match_x252, _ctx)) {
    kk_evv_drop(w1, _ctx);
    kk_evv_drop(w0, _ctx);
    kk_function_drop(ret, _ctx);
    kk_box_drop(result, _ctx);
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    return kk_box_any(kk_context());
  }
  if (kk_std_core_hnd__is_Yielding(_match_x252, _ctx)) {
    kk_box_drop(result, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_prompt_fun301(ev, ret, w0, w1, m, _ctx), _ctx);
  }
  {
    kk_function_t clause = _match_x252._cons.Yield.clause;
    kk_function_t cont_0 = _match_x252._cons.Yield.cont;
    kk_box_drop(result, _ctx);
    return kk_function_call(kk_box_t, (kk_function_t, kk_function_t, kk_context_t*), clause, (clause, kk_std_core_hnd_new_prompt_fun307(cont_0, ev, ret, w0, w1, m, _ctx), _ctx), _ctx);
  }
}

kk_box_t kk_std_core_hnd__hhandle(kk_std_core_hnd__htag tag, kk_box_t h, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,e1,b,c> (tag : htag<b>, h : b<e,c>, ret : (a) -> e c, action : () -> e1 a) -> e c */ 
  kk_evv_t w0 = kk_std_core_hnd_evv_get(_ctx); /*hnd/evv<5092>*/;
  int32_t m = kk_std_core_hnd_fresh_marker(_ctx); /*hnd/marker<5092,5095>*/;
  kk_std_core_hnd__ev ev;
  kk_evv_t _x_x322 = kk_evv_dup(w0, _ctx); /*hnd/evv<5092>*/
  ev = kk_std_core_hnd__new_Ev(kk_reuse_null, 0, tag, m, h, _x_x322, _ctx); /*hnd/ev<5094>*/
  kk_evv_t w1;
  kk_evv_t _x_x323 = kk_evv_dup(w0, _ctx); /*hnd/evv<5092>*/
  kk_std_core_hnd__ev _x_x324 = kk_std_core_hnd__ev_dup(ev, _ctx); /*hnd/ev<5094>*/
  w1 = kk_std_core_hnd_evv_insert(_x_x323, _x_x324, _ctx); /*hnd/evv<5092>*/
  kk_unit_t __ = kk_Unit;
  kk_evv_t _x_x325 = kk_evv_dup(w1, _ctx); /*hnd/evv<5092>*/
  kk_evv_set(_x_x325,kk_context());
  kk_box_t _x_x326 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx); /*5091*/
  return kk_std_core_hnd_prompt(w0, w1, ev, m, ret, _x_x326, _ctx);
}

kk_box_t kk_std_core_hnd__hhandle_vm(kk_std_core_hnd__htag tag, kk_box_t h, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,e1,b,c> (tag : htag<b>, h : b<e,c>, ret : (a) -> e c, action : () -> e1 a) -> e c */ 
  kk_evv_t w0 = kk_std_core_hnd_evv_get(_ctx); /*hnd/evv<5211>*/;
  int32_t m = kk_std_core_hnd_fresh_marker(_ctx); /*hnd/marker<5211,5214>*/;
  kk_evv_t w1;
  kk_evv_t _x_x327 = kk_evv_dup(w0, _ctx); /*hnd/evv<5211>*/
  kk_std_core_hnd__ev _x_x328;
  kk_evv_t _x_x329 = kk_evv_dup(w0, _ctx); /*hnd/evv<5211>*/
  _x_x328 = kk_std_core_hnd__new_Ev(kk_reuse_null, 0, tag, m, h, _x_x329, _ctx); /*hnd/ev<22>*/
  w1 = kk_std_core_hnd_evv_insert(_x_x327, _x_x328, _ctx); /*hnd/evv<_5153>*/
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w1,kk_context());
  kk_box_t res = kk_std_core_hnd__reset_vm(m, ret, action, _ctx); /*5214*/;
  kk_unit_t ___0 = kk_Unit;
  kk_evv_set(w0,kk_context());
  return res;
}


// lift anonymous function
struct kk_std_core_hnd_mask_at1_fun330__t {
  struct kk_function_s _base;
  kk_ssize_t i;
  bool behind;
};
static kk_box_t kk_std_core_hnd_mask_at1_fun330(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_mask_at1_fun330(kk_ssize_t i, bool behind, kk_context_t* _ctx) {
  struct kk_std_core_hnd_mask_at1_fun330__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_mask_at1_fun330__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_mask_at1_fun330, kk_context());
  _self->i = i;
  _self->behind = behind;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_mask_at1_fun330(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_mask_at1_fun330__t* _self = kk_function_as(struct kk_std_core_hnd_mask_at1_fun330__t*, _fself, _ctx);
  kk_ssize_t i = _self->i; /* hnd/ev-index */
  bool behind = _self->behind; /* bool */
  kk_drop_match(_self, {kk_skip_dup(i, _ctx);kk_skip_dup(behind, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_mask_at1(i, behind, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd_mask_at1(kk_ssize_t i, bool behind, kk_function_t action, kk_box_t x, kk_context_t* _ctx) { /* forall<a,b,e,e1> (i : ev-index, behind : bool, action : (a) -> e b, x : a) -> e1 b */ 
  kk_evv_t w0 = kk_std_core_hnd_evv_swap_delete(i, behind, _ctx); /*hnd/evv<_5239>*/;
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), action, (action, x, _ctx), _ctx); /*5328*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w0,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_mask_at1_fun330(i, behind, _ctx), _ctx);
  }
  {
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__mask_at_fun331__t {
  struct kk_function_s _base;
  kk_ssize_t i;
  bool behind;
};
static kk_box_t kk_std_core_hnd__mask_at_fun331(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_mask_at_fun331(kk_ssize_t i, bool behind, kk_context_t* _ctx) {
  struct kk_std_core_hnd__mask_at_fun331__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__mask_at_fun331__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__mask_at_fun331, kk_context());
  _self->i = i;
  _self->behind = behind;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__mask_at_fun331(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__mask_at_fun331__t* _self = kk_function_as(struct kk_std_core_hnd__mask_at_fun331__t*, _fself, _ctx);
  kk_ssize_t i = _self->i; /* hnd/ev-index */
  bool behind = _self->behind; /* bool */
  kk_drop_match(_self, {kk_skip_dup(i, _ctx);kk_skip_dup(behind, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_mask_at1(i, behind, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__mask_at(kk_ssize_t i, bool behind, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,e1> (i : ev-index, behind : bool, action : () -> e a) -> e1 a */ 
  kk_evv_t w0 = kk_std_core_hnd_evv_swap_delete(i, behind, _ctx); /*hnd/evv<_5351>*/;
  kk_box_t x = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx); /*5427*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w0,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(x, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_mask_at_fun331(i, behind, _ctx), _ctx);
  }
  {
    return x;
  }
}

kk_box_t kk_std_core_hnd__named_handle(kk_std_core_hnd__htag tag, kk_box_t h, kk_function_t ret, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e,e1,b,c> (tag : htag<b>, h : b<e,c>, ret : (a) -> e c, action : (ev<b>) -> e1 a) -> e c */ 
  int32_t m = kk_std_core_hnd_fresh_marker_named(_ctx); /*hnd/marker<5520,5523>*/;
  kk_evv_t w0 = kk_std_core_hnd_evv_get(_ctx); /*hnd/evv<5520>*/;
  kk_std_core_hnd__ev ev;
  kk_evv_t _x_x332 = kk_evv_dup(w0, _ctx); /*hnd/evv<5520>*/
  ev = kk_std_core_hnd__new_Ev(kk_reuse_null, 0, tag, m, h, _x_x332, _ctx); /*hnd/ev<5522>*/
  kk_evv_t _x_x333 = kk_evv_dup(w0, _ctx); /*hnd/evv<5520>*/
  kk_std_core_hnd__ev _x_x334 = kk_std_core_hnd__ev_dup(ev, _ctx); /*hnd/ev<5522>*/
  kk_box_t _x_x335 = kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__ev, kk_context_t*), action, (action, ev, _ctx), _ctx); /*5519*/
  return kk_std_core_hnd_prompt(_x_x333, w0, _x_x334, m, ret, _x_x335, _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_open_at1_fun336__t {
  struct kk_function_s _base;
  kk_ssize_t i;
};
static kk_box_t kk_std_core_hnd_open_at1_fun336(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_open_at1_fun336(kk_ssize_t i, kk_context_t* _ctx) {
  struct kk_std_core_hnd_open_at1_fun336__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_open_at1_fun336__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_open_at1_fun336, kk_context());
  _self->i = i;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_open_at1_fun336(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_open_at1_fun336__t* _self = kk_function_as(struct kk_std_core_hnd_open_at1_fun336__t*, _fself, _ctx);
  kk_ssize_t i = _self->i; /* hnd/ev-index */
  kk_drop_match(_self, {kk_skip_dup(i, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open_at1(i, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd_open_at1(kk_ssize_t i, kk_function_t f, kk_box_t x, kk_context_t* _ctx) { /* forall<a,b,e,e1> (i : ev-index, f : (a) -> e b, x : a) -> e1 b */ 
  kk_evv_t w = kk_evv_swap_create1(i,kk_context()); /*hnd/evv<5634>*/;
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, x, _ctx), _ctx); /*5632*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_open_at1_fun336(i, _ctx), _ctx);
  }
  {
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open_at0_fun337__t {
  struct kk_function_s _base;
  kk_ssize_t i;
};
static kk_box_t kk_std_core_hnd__open_at0_fun337(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open_at0_fun337(kk_ssize_t i, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at0_fun337__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open_at0_fun337__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open_at0_fun337, kk_context());
  _self->i = i;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open_at0_fun337(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at0_fun337__t* _self = kk_function_as(struct kk_std_core_hnd__open_at0_fun337__t*, _fself, _ctx);
  kk_ssize_t i = _self->i; /* hnd/ev-index */
  kk_drop_match(_self, {kk_skip_dup(i, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open_at1(i, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open_at0(kk_ssize_t i, kk_function_t f, kk_context_t* _ctx) { /* forall<a,e,e1> (i : ev-index, f : () -> e a) -> e1 a */ 
  kk_evv_t w = kk_evv_swap_create1(i,kk_context()); /*hnd/evv<5728>*/;
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), f, (f, _ctx), _ctx); /*5726*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open_at0_fun337(i, _ctx), _ctx);
  }
  {
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open_at1_fun338__t {
  struct kk_function_s _base;
  kk_ssize_t i;
};
static kk_box_t kk_std_core_hnd__open_at1_fun338(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open_at1_fun338(kk_ssize_t i, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at1_fun338__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open_at1_fun338__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open_at1_fun338, kk_context());
  _self->i = i;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open_at1_fun338(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at1_fun338__t* _self = kk_function_as(struct kk_std_core_hnd__open_at1_fun338__t*, _fself, _ctx);
  kk_ssize_t i = _self->i; /* hnd/ev-index */
  kk_drop_match(_self, {kk_skip_dup(i, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open_at1(i, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open_at1(kk_ssize_t i, kk_function_t f, kk_box_t x, kk_context_t* _ctx) { /* forall<a,b,e,e1> (i : ev-index, f : (a) -> e b, x : a) -> e1 b */ 
  kk_evv_t w = kk_evv_swap_create1(i,kk_context()); /*hnd/evv<5827>*/;
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, x, _ctx), _ctx); /*5825*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open_at1_fun338(i, _ctx), _ctx);
  }
  {
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open_at2_fun339__t {
  struct kk_function_s _base;
  kk_ssize_t i;
};
static kk_box_t kk_std_core_hnd__open_at2_fun339(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open_at2_fun339(kk_ssize_t i, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at2_fun339__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open_at2_fun339__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open_at2_fun339, kk_context());
  _self->i = i;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open_at2_fun339(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at2_fun339__t* _self = kk_function_as(struct kk_std_core_hnd__open_at2_fun339__t*, _fself, _ctx);
  kk_ssize_t i = _self->i; /* hnd/ev-index */
  kk_drop_match(_self, {kk_skip_dup(i, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open_at1(i, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open_at2(kk_ssize_t i, kk_function_t f, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) { /* forall<a,b,c,e,e1> (i : ev-index, f : (a, b) -> e c, x1 : a, x2 : b) -> e1 c */ 
  kk_evv_t w = kk_evv_swap_create1(i,kk_context()); /*hnd/evv<5937>*/;
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), f, (f, x1, x2, _ctx), _ctx); /*5935*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open_at2_fun339(i, _ctx), _ctx);
  }
  {
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open_at3_fun340__t {
  struct kk_function_s _base;
  kk_ssize_t i;
};
static kk_box_t kk_std_core_hnd__open_at3_fun340(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open_at3_fun340(kk_ssize_t i, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at3_fun340__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open_at3_fun340__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open_at3_fun340, kk_context());
  _self->i = i;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open_at3_fun340(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at3_fun340__t* _self = kk_function_as(struct kk_std_core_hnd__open_at3_fun340__t*, _fself, _ctx);
  kk_ssize_t i = _self->i; /* hnd/ev-index */
  kk_drop_match(_self, {kk_skip_dup(i, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open_at1(i, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open_at3(kk_ssize_t i, kk_function_t f, kk_box_t x1, kk_box_t x2, kk_box_t x3, kk_context_t* _ctx) { /* forall<a,b,c,d,e,e1> (i : ev-index, f : (a, b, c) -> e d, x1 : a, x2 : b, x3 : c) -> e1 d */ 
  kk_evv_t w = kk_evv_swap_create1(i,kk_context()); /*hnd/evv<6058>*/;
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), f, (f, x1, x2, x3, _ctx), _ctx); /*6056*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open_at3_fun340(i, _ctx), _ctx);
  }
  {
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open_at4_fun341__t {
  struct kk_function_s _base;
  kk_ssize_t i;
};
static kk_box_t kk_std_core_hnd__open_at4_fun341(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open_at4_fun341(kk_ssize_t i, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at4_fun341__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open_at4_fun341__t, 1, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open_at4_fun341, kk_context());
  _self->i = i;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open_at4_fun341(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open_at4_fun341__t* _self = kk_function_as(struct kk_std_core_hnd__open_at4_fun341__t*, _fself, _ctx);
  kk_ssize_t i = _self->i; /* hnd/ev-index */
  kk_drop_match(_self, {kk_skip_dup(i, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open_at1(i, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open_at4(kk_ssize_t i, kk_function_t f, kk_box_t x1, kk_box_t x2, kk_box_t x3, kk_box_t x4, kk_context_t* _ctx) { /* forall<a,b,c,d,a1,e,e1> (i : ev-index, f : (a, b, c, d) -> e a1, x1 : a, x2 : b, x3 : c, x4 : d) -> e1 a1 */ 
  kk_evv_t w = kk_evv_swap_create1(i,kk_context()); /*hnd/evv<6190>*/;
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), f, (f, x1, x2, x3, x4, _ctx), _ctx); /*6188*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open_at4_fun341(i, _ctx), _ctx);
  }
  {
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd_open1_fun343__t {
  struct kk_function_s _base;
  kk_vector_t indices;
};
static kk_box_t kk_std_core_hnd_open1_fun343(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_open1_fun343(kk_vector_t indices, kk_context_t* _ctx) {
  struct kk_std_core_hnd_open1_fun343__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_open1_fun343__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_open1_fun343, kk_context());
  _self->indices = indices;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_open1_fun343(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_open1_fun343__t* _self = kk_function_as(struct kk_std_core_hnd_open1_fun343__t*, _fself, _ctx);
  kk_vector_t indices = _self->indices; /* vector<hnd/ev-index> */
  kk_drop_match(_self, {kk_vector_dup(indices, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open1(indices, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd_open1(kk_vector_t indices, kk_function_t f, kk_box_t x, kk_context_t* _ctx) { /* forall<a,b,e,e1> (indices : vector<ev-index>, f : (a) -> e b, x : a) -> e1 b */ 
  kk_evv_t w;
  kk_vector_t _x_x342 = kk_vector_dup(indices, _ctx); /*vector<hnd/ev-index>*/
  w = kk_std_core_hnd_evv_swap_create(_x_x342, _ctx); /*hnd/evv<6307>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, x, _ctx), _ctx); /*6305*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_open1_fun343(indices, _ctx), _ctx);
  }
  {
    kk_vector_drop(indices, _ctx);
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open0_fun345__t {
  struct kk_function_s _base;
  kk_vector_t indices;
};
static kk_box_t kk_std_core_hnd__open0_fun345(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open0_fun345(kk_vector_t indices, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open0_fun345__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open0_fun345__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open0_fun345, kk_context());
  _self->indices = indices;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open0_fun345(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open0_fun345__t* _self = kk_function_as(struct kk_std_core_hnd__open0_fun345__t*, _fself, _ctx);
  kk_vector_t indices = _self->indices; /* vector<hnd/ev-index> */
  kk_drop_match(_self, {kk_vector_dup(indices, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open1(indices, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open0(kk_vector_t indices, kk_function_t f, kk_context_t* _ctx) { /* forall<a,e,e1> (indices : vector<ev-index>, f : () -> e a) -> e1 a */ 
  kk_evv_t w;
  kk_vector_t _x_x344 = kk_vector_dup(indices, _ctx); /*vector<hnd/ev-index>*/
  w = kk_std_core_hnd_evv_swap_create(_x_x344, _ctx); /*hnd/evv<6401>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), f, (f, _ctx), _ctx); /*6399*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open0_fun345(indices, _ctx), _ctx);
  }
  {
    kk_vector_drop(indices, _ctx);
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open1_fun347__t {
  struct kk_function_s _base;
  kk_vector_t indices;
};
static kk_box_t kk_std_core_hnd__open1_fun347(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open1_fun347(kk_vector_t indices, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open1_fun347__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open1_fun347__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open1_fun347, kk_context());
  _self->indices = indices;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open1_fun347(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open1_fun347__t* _self = kk_function_as(struct kk_std_core_hnd__open1_fun347__t*, _fself, _ctx);
  kk_vector_t indices = _self->indices; /* vector<hnd/ev-index> */
  kk_drop_match(_self, {kk_vector_dup(indices, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open1(indices, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open1(kk_vector_t indices, kk_function_t f, kk_box_t x, kk_context_t* _ctx) { /* forall<a,b,e,e1> (indices : vector<ev-index>, f : (a) -> e b, x : a) -> e1 b */ 
  kk_evv_t w;
  kk_vector_t _x_x346 = kk_vector_dup(indices, _ctx); /*vector<hnd/ev-index>*/
  w = kk_std_core_hnd_evv_swap_create(_x_x346, _ctx); /*hnd/evv<6500>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), f, (f, x, _ctx), _ctx); /*6498*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open1_fun347(indices, _ctx), _ctx);
  }
  {
    kk_vector_drop(indices, _ctx);
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open2_fun349__t {
  struct kk_function_s _base;
  kk_vector_t indices;
};
static kk_box_t kk_std_core_hnd__open2_fun349(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open2_fun349(kk_vector_t indices, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open2_fun349__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open2_fun349__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open2_fun349, kk_context());
  _self->indices = indices;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open2_fun349(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open2_fun349__t* _self = kk_function_as(struct kk_std_core_hnd__open2_fun349__t*, _fself, _ctx);
  kk_vector_t indices = _self->indices; /* vector<hnd/ev-index> */
  kk_drop_match(_self, {kk_vector_dup(indices, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open1(indices, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open2(kk_vector_t indices, kk_function_t f, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) { /* forall<a,b,c,e,e1> (indices : vector<ev-index>, f : (a, b) -> e c, x1 : a, x2 : b) -> e1 c */ 
  kk_evv_t w;
  kk_vector_t _x_x348 = kk_vector_dup(indices, _ctx); /*vector<hnd/ev-index>*/
  w = kk_std_core_hnd_evv_swap_create(_x_x348, _ctx); /*hnd/evv<6610>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), f, (f, x1, x2, _ctx), _ctx); /*6608*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open2_fun349(indices, _ctx), _ctx);
  }
  {
    kk_vector_drop(indices, _ctx);
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open3_fun351__t {
  struct kk_function_s _base;
  kk_vector_t indices;
};
static kk_box_t kk_std_core_hnd__open3_fun351(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open3_fun351(kk_vector_t indices, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open3_fun351__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open3_fun351__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open3_fun351, kk_context());
  _self->indices = indices;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open3_fun351(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open3_fun351__t* _self = kk_function_as(struct kk_std_core_hnd__open3_fun351__t*, _fself, _ctx);
  kk_vector_t indices = _self->indices; /* vector<hnd/ev-index> */
  kk_drop_match(_self, {kk_vector_dup(indices, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open1(indices, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open3(kk_vector_t indices, kk_function_t f, kk_box_t x1, kk_box_t x2, kk_box_t x3, kk_context_t* _ctx) { /* forall<a,b,c,d,e,e1> (indices : vector<ev-index>, f : (a, b, c) -> e d, x1 : a, x2 : b, x3 : c) -> e1 d */ 
  kk_evv_t w;
  kk_vector_t _x_x350 = kk_vector_dup(indices, _ctx); /*vector<hnd/ev-index>*/
  w = kk_std_core_hnd_evv_swap_create(_x_x350, _ctx); /*hnd/evv<6731>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), f, (f, x1, x2, x3, _ctx), _ctx); /*6729*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open3_fun351(indices, _ctx), _ctx);
  }
  {
    kk_vector_drop(indices, _ctx);
    return y;
  }
}


// lift anonymous function
struct kk_std_core_hnd__open4_fun353__t {
  struct kk_function_s _base;
  kk_vector_t indices;
};
static kk_box_t kk_std_core_hnd__open4_fun353(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd__new_open4_fun353(kk_vector_t indices, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open4_fun353__t* _self = kk_function_alloc_as(struct kk_std_core_hnd__open4_fun353__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd__open4_fun353, kk_context());
  _self->indices = indices;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd__open4_fun353(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd__open4_fun353__t* _self = kk_function_as(struct kk_std_core_hnd__open4_fun353__t*, _fself, _ctx);
  kk_vector_t indices = _self->indices; /* vector<hnd/ev-index> */
  kk_drop_match(_self, {kk_vector_dup(indices, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_open1(indices, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd__open4(kk_vector_t indices, kk_function_t f, kk_box_t x1, kk_box_t x2, kk_box_t x3, kk_box_t x4, kk_context_t* _ctx) { /* forall<a,b,c,d,a1,e,e1> (indices : vector<ev-index>, f : (a, b, c, d) -> e a1, x1 : a, x2 : b, x3 : c, x4 : d) -> e1 a1 */ 
  kk_evv_t w;
  kk_vector_t _x_x352 = kk_vector_dup(indices, _ctx); /*vector<hnd/ev-index>*/
  w = kk_std_core_hnd_evv_swap_create(_x_x352, _ctx); /*hnd/evv<6863>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), f, (f, x1, x2, x3, x4, _ctx), _ctx); /*6861*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd__new_open4_fun353(indices, _ctx), _ctx);
  }
  {
    kk_vector_drop(indices, _ctx);
    return y;
  }
}

kk_box_t kk_std_core_hnd__yield_to_vm(int32_t m, kk_function_t clause, kk_context_t* _ctx) { /* forall<a,e,b> (m : marker<e,b>, clause : ((a) -> e b) -> e b) -> e a */ 
  kk_evv_t w0 = kk_std_core_hnd_evv_get(_ctx); /*hnd/evv<7121>*/;
  kk_box_t r = kk_std_core_hnd__yield_to_prim_vm(m, clause, _ctx); /*7120*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w0,kk_context());
  return r;
}


// lift anonymous function
struct kk_std_core_hnd_yield_to_fun360__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_hnd_yield_to_fun360(kk_function_t _fself, kk_box_t _b_x69, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_yield_to_fun360(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_hnd_yield_to_fun360, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_hnd_yield_to_fun360(kk_function_t _fself, kk_box_t _b_x69, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_t _x_x361 = kk_function_unbox(_b_x69, _ctx); /*() -> 7175 70*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), _x_x361, (_x_x361, _ctx), _ctx);
}

kk_box_t kk_std_core_hnd_yield_to(int32_t m, kk_function_t clause, kk_context_t* _ctx) { /* forall<a,e,b> (m : marker<e,b>, clause : ((resume-result<a,b>) -> e b) -> e b) -> e a */ 
  kk_function_t g = kk_std_core_hnd_yield_to_prim(m, clause, _ctx); /*() -> 7174*/;
  kk_function_drop(g, _ctx);
  return kk_std_core_hnd_yield_extend(kk_std_core_hnd_new_yield_to_fun360(_ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_control_raw0_fun362__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control_raw0_fun362(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x722__16, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control_raw0_fun362(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw0_fun362__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control_raw0_fun362__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control_raw0_fun362, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control_raw0_fun363__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control_raw0_fun363(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control_raw0_fun363(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw0_fun363__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control_raw0_fun363__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control_raw0_fun363, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_control_raw0_fun363(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw0_fun363__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control_raw0_fun363__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (hnd/resume-context<7248,7249,7250,7252>) -> 7249 7252 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_std_core_hnd__resume_context _x_x364 = kk_std_core_hnd__new_Resume_context(k, _ctx); /*hnd/resume-context<83,84,85,86>*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_context, kk_context_t*), op, (op, _x_x364, _ctx), _ctx);
}
static kk_box_t kk_std_core_hnd_clause_control_raw0_fun362(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x722__16, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw0_fun362__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control_raw0_fun362__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (hnd/resume-context<7248,7249,7250,7252>) -> 7249 7252 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x722__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_std_core_hnd_new_clause_control_raw0_fun363(op, _ctx), _ctx);
}

kk_std_core_hnd__clause0 kk_std_core_hnd_clause_control_raw0(kk_function_t op, kk_context_t* _ctx) { /* forall<a,e,e1,b,c> (op : (resume-context<a,e,e1,c>) -> e c) -> clause0<a,b,e,c> */ 
  return kk_std_core_hnd__new_Clause0(kk_std_core_hnd_new_clause_control_raw0_fun362(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_control_raw1_fun365__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control_raw1_fun365(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x648__16, kk_box_t x, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control_raw1_fun365(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw1_fun365__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control_raw1_fun365__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control_raw1_fun365, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control_raw1_fun366__t {
  struct kk_function_s _base;
  kk_function_t op;
  kk_box_t x;
};
static kk_box_t kk_std_core_hnd_clause_control_raw1_fun366(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control_raw1_fun366(kk_function_t op, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw1_fun366__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control_raw1_fun366__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control_raw1_fun366, kk_context());
  _self->op = op;
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_control_raw1_fun366(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw1_fun366__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control_raw1_fun366__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (x : 7338, r : hnd/resume-context<7339,7340,7341,7343>) -> 7340 7343 */
  kk_box_t x = _self->x; /* 7338 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);kk_box_dup(x, _ctx);}, {}, _ctx)
  kk_std_core_hnd__resume_context _x_x367 = kk_std_core_hnd__new_Resume_context(k, _ctx); /*hnd/resume-context<83,84,85,86>*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_std_core_hnd__resume_context, kk_context_t*), op, (op, x, _x_x367, _ctx), _ctx);
}
static kk_box_t kk_std_core_hnd_clause_control_raw1_fun365(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x648__16, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw1_fun365__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control_raw1_fun365__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (x : 7338, r : hnd/resume-context<7339,7340,7341,7343>) -> 7340 7343 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x648__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_std_core_hnd_new_clause_control_raw1_fun366(op, x, _ctx), _ctx);
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_control_raw1(kk_function_t op, kk_context_t* _ctx) { /* forall<a,b,e,e1,c,d> (op : (x : a, r : resume-context<b,e,e1,d>) -> e d) -> clause1<a,b,c,e,d> */ 
  return kk_std_core_hnd__new_Clause1(kk_std_core_hnd_new_clause_control_raw1_fun365(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_control_raw2_fun368__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control_raw2_fun368(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x773__16, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control_raw2_fun368(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw2_fun368__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control_raw2_fun368__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control_raw2_fun368, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control_raw2_fun369__t {
  struct kk_function_s _base;
  kk_function_t op;
  kk_box_t x1;
  kk_box_t x2;
};
static kk_box_t kk_std_core_hnd_clause_control_raw2_fun369(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control_raw2_fun369(kk_function_t op, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw2_fun369__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control_raw2_fun369__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control_raw2_fun369, kk_context());
  _self->op = op;
  _self->x1 = x1;
  _self->x2 = x2;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_control_raw2_fun369(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw2_fun369__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control_raw2_fun369__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (x1 : 7439, x2 : 7440, r : hnd/resume-context<7441,7442,7443,7445>) -> 7442 7445 */
  kk_box_t x1 = _self->x1; /* 7439 */
  kk_box_t x2 = _self->x2; /* 7440 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);kk_box_dup(x1, _ctx);kk_box_dup(x2, _ctx);}, {}, _ctx)
  kk_std_core_hnd__resume_context _x_x370 = kk_std_core_hnd__new_Resume_context(k, _ctx); /*hnd/resume-context<83,84,85,86>*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_std_core_hnd__resume_context, kk_context_t*), op, (op, x1, x2, _x_x370, _ctx), _ctx);
}
static kk_box_t kk_std_core_hnd_clause_control_raw2_fun368(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x773__16, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw2_fun368__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control_raw2_fun368__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (x1 : 7439, x2 : 7440, r : hnd/resume-context<7441,7442,7443,7445>) -> 7442 7445 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x773__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_std_core_hnd_new_clause_control_raw2_fun369(op, x1, x2, _ctx), _ctx);
}

kk_std_core_hnd__clause2 kk_std_core_hnd_clause_control_raw2(kk_function_t op, kk_context_t* _ctx) { /* forall<a,b,c,e,e1,d,a1> (op : (x1 : a, x2 : b, r : resume-context<c,e,e1,a1>) -> e a1) -> clause2<a,b,c,d,e,a1> */ 
  return kk_std_core_hnd__new_Clause2(kk_std_core_hnd_new_clause_control_raw2_fun368(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_control_raw3_fun371__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control_raw3_fun371(kk_function_t _fself, int32_t _b_x74, kk_std_core_hnd__ev _b_x75, kk_box_t _b_x76, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control_raw3_fun371(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw3_fun371__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control_raw3_fun371__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control_raw3_fun371, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control_raw3_fun372__t {
  struct kk_function_s _base;
  kk_box_t _b_x76;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control_raw3_fun372(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control_raw3_fun372(kk_box_t _b_x76, kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw3_fun372__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control_raw3_fun372__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control_raw3_fun372, kk_context());
  _self->_b_x76 = _b_x76;
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_control_raw3_fun372(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw3_fun372__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control_raw3_fun372__t*, _fself, _ctx);
  kk_box_t _b_x76 = _self->_b_x76; /* 45 */
  kk_function_t op = _self->op; /* (x1 : 7528, x2 : 7529, x3 : 7530, r : hnd/resume-context<7531,7532,7533,7535>) -> 7532 7535 */
  kk_drop_match(_self, {kk_box_dup(_b_x76, _ctx);kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple3 _match_x235 = kk_std_core_types__tuple3_unbox(_b_x76, KK_OWNED, _ctx); /*(7528, 7529, 7530)*/;
  {
    kk_box_t x1 = _match_x235.fst;
    kk_box_t x2 = _match_x235.snd;
    kk_box_t x3 = _match_x235.thd;
    kk_std_core_hnd__resume_context _x_x373 = kk_std_core_hnd__new_Resume_context(k, _ctx); /*hnd/resume-context<83,84,85,86>*/
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_std_core_hnd__resume_context, kk_context_t*), op, (op, x1, x2, x3, _x_x373, _ctx), _ctx);
  }
}
static kk_box_t kk_std_core_hnd_clause_control_raw3_fun371(kk_function_t _fself, int32_t _b_x74, kk_std_core_hnd__ev _b_x75, kk_box_t _b_x76, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control_raw3_fun371__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control_raw3_fun371__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (x1 : 7528, x2 : 7529, x3 : 7530, r : hnd/resume-context<7531,7532,7533,7535>) -> 7532 7535 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(_b_x75, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(_b_x74, kk_std_core_hnd_new_clause_control_raw3_fun372(_b_x76, op, _ctx), _ctx);
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_control_raw3(kk_function_t op, kk_context_t* _ctx) { /* forall<a,b,c,d,e,e1,a1,b1> (op : (x1 : a, x2 : b, x3 : c, r : resume-context<d,e,e1,b1>) -> e b1) -> clause1<(a, b, c),d,a1,e,b1> */ 
  return kk_std_core_hnd__new_Clause1(kk_std_core_hnd_new_clause_control_raw3_fun371(op, _ctx), _ctx);
}

kk_box_t kk_std_core_hnd_protect_check(kk_ref_t resumed, kk_function_t k, kk_box_t res, kk_context_t* _ctx) { /* forall<a,e,b> (resumed : ref<global,bool>, k : (resume-result<a,b>) -> e b, res : b) -> e b */ 
  bool did_resume;
  kk_box_t _x_x375 = kk_ref_get(resumed,kk_context()); /*209*/
  did_resume = kk_bool_unbox(_x_x375); /*bool*/
  if (did_resume) {
    kk_function_drop(k, _ctx);
    return res;
  }
  {
    kk_std_core_hnd__resume_result _x_x376 = kk_std_core_hnd__new_Finalize(res, _ctx); /*hnd/resume-result<74,75>*/
    return kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), k, (k, _x_x376, _ctx), _ctx);
  }
}


// lift anonymous function
struct kk_std_core_hnd_protect_fun378__t {
  struct kk_function_s _base;
  kk_function_t k;
  kk_ref_t resumed;
};
static kk_box_t kk_std_core_hnd_protect_fun378(kk_function_t _fself, kk_box_t ret, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_protect_fun378(kk_function_t k, kk_ref_t resumed, kk_context_t* _ctx) {
  struct kk_std_core_hnd_protect_fun378__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_protect_fun378__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_protect_fun378, kk_context());
  _self->k = k;
  _self->resumed = resumed;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_protect_fun378(kk_function_t _fself, kk_box_t ret, kk_context_t* _ctx) {
  struct kk_std_core_hnd_protect_fun378__t* _self = kk_function_as(struct kk_std_core_hnd_protect_fun378__t*, _fself, _ctx);
  kk_function_t k = _self->k; /* (hnd/resume-result<7816,7818>) -> 7817 7818 */
  kk_ref_t resumed = _self->resumed; /* ref<global,bool> */
  kk_drop_match(_self, {kk_function_dup(k, _ctx);kk_ref_dup(resumed, _ctx);}, {}, _ctx)
  kk_unit_t __ = kk_Unit;
  kk_unit_t _brw_x234 = kk_Unit;
  kk_ref_set_borrow(resumed,(kk_bool_box(true)),kk_context());
  kk_ref_drop(resumed, _ctx);
  _brw_x234;
  kk_std_core_hnd__resume_result _x_x379 = kk_std_core_hnd__new_Deep(ret, _ctx); /*hnd/resume-result<74,75>*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), k, (k, _x_x379, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_protect_fun380__t {
  struct kk_function_s _base;
  kk_function_t k;
  kk_ref_t resumed;
};
static kk_box_t kk_std_core_hnd_protect_fun380(kk_function_t _fself, kk_box_t xres, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_protect_fun380(kk_function_t k, kk_ref_t resumed, kk_context_t* _ctx) {
  struct kk_std_core_hnd_protect_fun380__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_protect_fun380__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_protect_fun380, kk_context());
  _self->k = k;
  _self->resumed = resumed;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_protect_fun380(kk_function_t _fself, kk_box_t xres, kk_context_t* _ctx) {
  struct kk_std_core_hnd_protect_fun380__t* _self = kk_function_as(struct kk_std_core_hnd_protect_fun380__t*, _fself, _ctx);
  kk_function_t k = _self->k; /* (hnd/resume-result<7816,7818>) -> 7817 7818 */
  kk_ref_t resumed = _self->resumed; /* ref<global,bool> */
  kk_drop_match(_self, {kk_function_dup(k, _ctx);kk_ref_dup(resumed, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect_check(resumed, k, xres, _ctx);
}

kk_box_t kk_std_core_hnd_protect(kk_box_t x, kk_function_t clause, kk_function_t k, kk_context_t* _ctx) { /* forall<a,b,e,c> (x : a, clause : (x : a, k : (b) -> e c) -> e c, k : (resume-result<b,c>) -> e c) -> e c */ 
  kk_ref_t resumed = kk_ref_alloc((kk_bool_box(false)),kk_context()); /*ref<global,bool>*/;
  kk_box_t res;
  kk_function_t _x_x377;
  kk_function_dup(k, _ctx);
  kk_ref_dup(resumed, _ctx);
  _x_x377 = kk_std_core_hnd_new_protect_fun378(k, resumed, _ctx); /*(ret : 7816) -> 7817 7818*/
  res = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_function_t, kk_context_t*), clause, (clause, x, _x_x377, _ctx), _ctx); /*7818*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(res, _ctx);
    return kk_std_core_hnd_yield_extend(kk_std_core_hnd_new_protect_fun380(k, resumed, _ctx), _ctx);
  }
  {
    return kk_std_core_hnd_protect_check(resumed, k, res, _ctx);
  }
}


// lift anonymous function
struct kk_std_core_hnd_clause_control0_fun381__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control0_fun381(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control0_fun381(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control0_fun381__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control0_fun381__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control0_fun381, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control0_fun382__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control0_fun382(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control0_fun382(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control0_fun382__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control0_fun382__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control0_fun382, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control0_fun383__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control0_fun383(kk_function_t _fself, kk_box_t _b_x92, kk_function_t _b_x93, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control0_fun383(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control0_fun383__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control0_fun383__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control0_fun383, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_control0_fun383(kk_function_t _fself, kk_box_t _b_x92, kk_function_t _b_x93, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control0_fun383__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control0_fun383__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* ((7891) -> 7892 7894) -> 7892 7894 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x92, _ctx);
  return kk_function_call(kk_box_t, (kk_function_t, kk_function_t, kk_context_t*), op, (op, _b_x93, _ctx), _ctx);
}
static kk_box_t kk_std_core_hnd_clause_control0_fun382(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control0_fun382__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control0_fun382__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* ((7891) -> 7892 7894) -> 7892 7894 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect(kk_unit_box(kk_Unit), kk_std_core_hnd_new_clause_control0_fun383(op, _ctx), k, _ctx);
}
static kk_box_t kk_std_core_hnd_clause_control0_fun381(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x730__16, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control0_fun381__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control0_fun381__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* ((7891) -> 7892 7894) -> 7892 7894 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x730__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_std_core_hnd_new_clause_control0_fun382(op, _ctx), _ctx);
}

kk_std_core_hnd__clause0 kk_std_core_hnd_clause_control0(kk_function_t op, kk_context_t* _ctx) { /* forall<a,e,b,c> (op : ((a) -> e c) -> e c) -> clause0<a,b,e,c> */ 
  return kk_std_core_hnd__new_Clause0(kk_std_core_hnd_new_clause_control0_fun381(op, _ctx), _ctx);
}
extern kk_box_t kk_std_core_hnd_clause_control1_fun385(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control1_fun385__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control1_fun385__t*, _fself, _ctx);
  kk_function_t clause = _self->clause; /* (x : 7972, k : (7973) -> 7974 7976) -> 7974 7976 */
  kk_box_t x = _self->x; /* 7972 */
  kk_drop_match(_self, {kk_function_dup(clause, _ctx);kk_box_dup(x, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect(x, clause, k, _ctx);
}
extern kk_box_t kk_std_core_hnd_clause_control1_fun384(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x681__16, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control1_fun384__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control1_fun384__t*, _fself, _ctx);
  kk_function_t clause = _self->clause; /* (x : 7972, k : (7973) -> 7974 7976) -> 7974 7976 */
  kk_drop_match(_self, {kk_function_dup(clause, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x681__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_std_core_hnd_new_clause_control1_fun385(clause, x, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_protect2_fun387__t {
  struct kk_function_s _base;
  kk_function_t k;
  kk_ref_t resumed;
};
static kk_box_t kk_std_core_hnd_protect2_fun387(kk_function_t _fself, kk_box_t ret, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_protect2_fun387(kk_function_t k, kk_ref_t resumed, kk_context_t* _ctx) {
  struct kk_std_core_hnd_protect2_fun387__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_protect2_fun387__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_protect2_fun387, kk_context());
  _self->k = k;
  _self->resumed = resumed;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_protect2_fun387(kk_function_t _fself, kk_box_t ret, kk_context_t* _ctx) {
  struct kk_std_core_hnd_protect2_fun387__t* _self = kk_function_as(struct kk_std_core_hnd_protect2_fun387__t*, _fself, _ctx);
  kk_function_t k = _self->k; /* (hnd/resume-result<8120,8122>) -> 8121 8122 */
  kk_ref_t resumed = _self->resumed; /* ref<global,bool> */
  kk_drop_match(_self, {kk_function_dup(k, _ctx);kk_ref_dup(resumed, _ctx);}, {}, _ctx)
  kk_unit_t __ = kk_Unit;
  kk_unit_t _brw_x232 = kk_Unit;
  kk_ref_set_borrow(resumed,(kk_bool_box(true)),kk_context());
  kk_ref_drop(resumed, _ctx);
  _brw_x232;
  kk_std_core_hnd__resume_result _x_x388 = kk_std_core_hnd__new_Deep(ret, _ctx); /*hnd/resume-result<74,75>*/
  return kk_function_call(kk_box_t, (kk_function_t, kk_std_core_hnd__resume_result, kk_context_t*), k, (k, _x_x388, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_protect2_fun389__t {
  struct kk_function_s _base;
  kk_function_t k;
  kk_ref_t resumed;
};
static kk_box_t kk_std_core_hnd_protect2_fun389(kk_function_t _fself, kk_box_t xres, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_protect2_fun389(kk_function_t k, kk_ref_t resumed, kk_context_t* _ctx) {
  struct kk_std_core_hnd_protect2_fun389__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_protect2_fun389__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_protect2_fun389, kk_context());
  _self->k = k;
  _self->resumed = resumed;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_protect2_fun389(kk_function_t _fself, kk_box_t xres, kk_context_t* _ctx) {
  struct kk_std_core_hnd_protect2_fun389__t* _self = kk_function_as(struct kk_std_core_hnd_protect2_fun389__t*, _fself, _ctx);
  kk_function_t k = _self->k; /* (hnd/resume-result<8120,8122>) -> 8121 8122 */
  kk_ref_t resumed = _self->resumed; /* ref<global,bool> */
  kk_drop_match(_self, {kk_function_dup(k, _ctx);kk_ref_dup(resumed, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect_check(resumed, k, xres, _ctx);
}

kk_box_t kk_std_core_hnd_protect2(kk_box_t x1, kk_box_t x2, kk_function_t clause, kk_function_t k, kk_context_t* _ctx) { /* forall<a,b,c,e,d> (x1 : a, x2 : b, clause : (x : a, x : b, k : (c) -> e d) -> e d, k : (resume-result<c,d>) -> e d) -> e d */ 
  kk_ref_t resumed = kk_ref_alloc((kk_bool_box(false)),kk_context()); /*ref<global,bool>*/;
  kk_box_t res;
  kk_function_t _x_x386;
  kk_function_dup(k, _ctx);
  kk_ref_dup(resumed, _ctx);
  _x_x386 = kk_std_core_hnd_new_protect2_fun387(k, resumed, _ctx); /*(ret : 8120) -> 8121 8122*/
  res = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_function_t, kk_context_t*), clause, (clause, x1, x2, _x_x386, _ctx), _ctx); /*8122*/
  if (kk_yielding(kk_context())) {
    kk_box_drop(res, _ctx);
    return kk_std_core_hnd_yield_extend(kk_std_core_hnd_new_protect2_fun389(k, resumed, _ctx), _ctx);
  }
  {
    return kk_std_core_hnd_protect_check(resumed, k, res, _ctx);
  }
}
extern kk_box_t kk_std_core_hnd_clause_control2_fun391(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control2_fun391__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control2_fun391__t*, _fself, _ctx);
  kk_function_t clause = _self->clause; /* (x1 : 8212, x2 : 8213, k : (8214) -> 8215 8217) -> 8215 8217 */
  kk_box_t x1 = _self->x1; /* 8212 */
  kk_box_t x2 = _self->x2; /* 8213 */
  kk_drop_match(_self, {kk_function_dup(clause, _ctx);kk_box_dup(x1, _ctx);kk_box_dup(x2, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect2(x1, x2, clause, k, _ctx);
}
extern kk_box_t kk_std_core_hnd_clause_control2_fun390(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x769__16, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control2_fun390__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control2_fun390__t*, _fself, _ctx);
  kk_function_t clause = _self->clause; /* (x1 : 8212, x2 : 8213, k : (8214) -> 8215 8217) -> 8215 8217 */
  kk_drop_match(_self, {kk_function_dup(clause, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x769__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(m, kk_std_core_hnd_new_clause_control2_fun391(clause, x1, x2, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_control3_fun392__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control3_fun392(kk_function_t _fself, int32_t _b_x111, kk_std_core_hnd__ev _b_x112, kk_box_t _b_x113, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control3_fun392(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control3_fun392__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control3_fun392__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control3_fun392, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control3_fun393__t {
  struct kk_function_s _base;
  kk_box_t _b_x113;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control3_fun393(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control3_fun393(kk_box_t _b_x113, kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control3_fun393__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control3_fun393__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control3_fun393, kk_context());
  _self->_b_x113 = _b_x113;
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control3_fun394__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control3_fun394(kk_function_t _fself, kk_box_t _b_x108, kk_function_t _b_x109, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control3_fun394(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control3_fun394__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control3_fun394__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control3_fun394, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_control3_fun394(kk_function_t _fself, kk_box_t _b_x108, kk_function_t _b_x109, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control3_fun394__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control3_fun394__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (x1 : 8291, x2 : 8292, x3 : 8293, k : (8294) -> 8295 8297) -> 8295 8297 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple3 _match_x230 = kk_std_core_types__tuple3_unbox(_b_x108, KK_OWNED, _ctx); /*(8291, 8292, 8293)*/;
  {
    kk_box_t x1 = _match_x230.fst;
    kk_box_t x2 = _match_x230.snd;
    kk_box_t x3 = _match_x230.thd;
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_function_t, kk_context_t*), op, (op, x1, x2, x3, _b_x109, _ctx), _ctx);
  }
}
static kk_box_t kk_std_core_hnd_clause_control3_fun393(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control3_fun393__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control3_fun393__t*, _fself, _ctx);
  kk_box_t _b_x113 = _self->_b_x113; /* 45 */
  kk_function_t op = _self->op; /* (x1 : 8291, x2 : 8292, x3 : 8293, k : (8294) -> 8295 8297) -> 8295 8297 */
  kk_drop_match(_self, {kk_box_dup(_b_x113, _ctx);kk_function_dup(op, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect(_b_x113, kk_std_core_hnd_new_clause_control3_fun394(op, _ctx), k, _ctx);
}
static kk_box_t kk_std_core_hnd_clause_control3_fun392(kk_function_t _fself, int32_t _b_x111, kk_std_core_hnd__ev _b_x112, kk_box_t _b_x113, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control3_fun392__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control3_fun392__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (x1 : 8291, x2 : 8292, x3 : 8293, k : (8294) -> 8295 8297) -> 8295 8297 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(_b_x112, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(_b_x111, kk_std_core_hnd_new_clause_control3_fun393(_b_x113, op, _ctx), _ctx);
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_control3(kk_function_t op, kk_context_t* _ctx) { /* forall<a,b,c,d,e,a1,b1> (op : (x1 : a, x2 : b, x3 : c, k : (d) -> e b1) -> e b1) -> clause1<(a, b, c),d,a1,e,b1> */ 
  return kk_std_core_hnd__new_Clause1(kk_std_core_hnd_new_clause_control3_fun392(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_control4_fun395__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control4_fun395(kk_function_t _fself, int32_t _b_x129, kk_std_core_hnd__ev _b_x130, kk_box_t _b_x131, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control4_fun395(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control4_fun395__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control4_fun395__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control4_fun395, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control4_fun396__t {
  struct kk_function_s _base;
  kk_box_t _b_x131;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control4_fun396(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control4_fun396(kk_box_t _b_x131, kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control4_fun396__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control4_fun396__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control4_fun396, kk_context());
  _self->_b_x131 = _b_x131;
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_control4_fun397__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_control4_fun397(kk_function_t _fself, kk_box_t _b_x126, kk_function_t _b_x127, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_control4_fun397(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control4_fun397__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_control4_fun397__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_control4_fun397, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_control4_fun397(kk_function_t _fself, kk_box_t _b_x126, kk_function_t _b_x127, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control4_fun397__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control4_fun397__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (x1 : 8379, x2 : 8380, x3 : 8381, x4 : 8382, k : (8383) -> 8384 8386) -> 8384 8386 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple4 _match_x229 = kk_std_core_types__tuple4_unbox(_b_x126, KK_OWNED, _ctx); /*(8379, 8380, 8381, 8382)*/;
  {
    struct kk_std_core_types_Tuple4* _con_x398 = kk_std_core_types__as_Tuple4(_match_x229, _ctx);
    kk_box_t x1 = _con_x398->fst;
    kk_box_t x2 = _con_x398->snd;
    kk_box_t x3 = _con_x398->thd;
    kk_box_t x4 = _con_x398->field4;
    if kk_likely(kk_datatype_ptr_is_unique(_match_x229, _ctx)) {
      kk_datatype_ptr_free(_match_x229, _ctx);
    }
    else {
      kk_box_dup(x1, _ctx);
      kk_box_dup(x2, _ctx);
      kk_box_dup(x3, _ctx);
      kk_box_dup(x4, _ctx);
      kk_datatype_ptr_decref(_match_x229, _ctx);
    }
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_box_t, kk_function_t, kk_context_t*), op, (op, x1, x2, x3, x4, _b_x127, _ctx), _ctx);
  }
}
static kk_box_t kk_std_core_hnd_clause_control4_fun396(kk_function_t _fself, kk_function_t k, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control4_fun396__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control4_fun396__t*, _fself, _ctx);
  kk_box_t _b_x131 = _self->_b_x131; /* 45 */
  kk_function_t op = _self->op; /* (x1 : 8379, x2 : 8380, x3 : 8381, x4 : 8382, k : (8383) -> 8384 8386) -> 8384 8386 */
  kk_drop_match(_self, {kk_box_dup(_b_x131, _ctx);kk_function_dup(op, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_protect(_b_x131, kk_std_core_hnd_new_clause_control4_fun397(op, _ctx), k, _ctx);
}
static kk_box_t kk_std_core_hnd_clause_control4_fun395(kk_function_t _fself, int32_t _b_x129, kk_std_core_hnd__ev _b_x130, kk_box_t _b_x131, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_control4_fun395__t* _self = kk_function_as(struct kk_std_core_hnd_clause_control4_fun395__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (x1 : 8379, x2 : 8380, x3 : 8381, x4 : 8382, k : (8383) -> 8384 8386) -> 8384 8386 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(_b_x130, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to(_b_x129, kk_std_core_hnd_new_clause_control4_fun396(_b_x131, op, _ctx), _ctx);
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_control4(kk_function_t op, kk_context_t* _ctx) { /* forall<a,b,c,d,a1,e,b1,c1> (op : (x1 : a, x2 : b, x3 : c, x4 : d, k : (a1) -> e c1) -> e c1) -> clause1<(a, b, c, d),a1,b1,e,c1> */ 
  return kk_std_core_hnd__new_Clause1(kk_std_core_hnd_new_clause_control4_fun395(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_never0_fun399__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_never0_fun399(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x743__16, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never0_fun399(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never0_fun399__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never0_fun399__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never0_fun399, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_never0_fun400__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_never0_fun400(kk_function_t _fself, kk_function_t ___wildcard_x743__43, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never0_fun400(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never0_fun400__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never0_fun400__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never0_fun400, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_never0_fun400(kk_function_t _fself, kk_function_t ___wildcard_x743__43, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never0_fun400__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never0_fun400__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* () -> 8459 8461 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_function_drop(___wildcard_x743__43, _ctx);
  return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), op, (op, _ctx), _ctx);
}
static kk_box_t kk_std_core_hnd_clause_never0_fun399(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x743__16, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never0_fun399__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never0_fun399__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* () -> 8459 8461 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x743__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to_final(m, kk_std_core_hnd_new_clause_never0_fun400(op, _ctx), _ctx);
}

kk_std_core_hnd__clause0 kk_std_core_hnd_clause_never0(kk_function_t op, kk_context_t* _ctx) { /* forall<a,e,b,c> (op : () -> e c) -> clause0<a,b,e,c> */ 
  return kk_std_core_hnd__new_Clause0(kk_std_core_hnd_new_clause_never0_fun399(op, _ctx), _ctx);
}
 
// clause that never resumes (e.g. an exception handler)
// (these do not need to capture a resumption and execute finally clauses upfront)


// lift anonymous function
struct kk_std_core_hnd_clause_never1_fun401__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_never1_fun401(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x696__16, kk_box_t x, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never1_fun401(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never1_fun401__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never1_fun401__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never1_fun401, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_never1_fun402__t {
  struct kk_function_s _base;
  kk_function_t op;
  kk_box_t x;
};
static kk_box_t kk_std_core_hnd_clause_never1_fun402(kk_function_t _fself, kk_function_t ___wildcard_x696__45, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never1_fun402(kk_function_t op, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never1_fun402__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never1_fun402__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never1_fun402, kk_context());
  _self->op = op;
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_never1_fun402(kk_function_t _fself, kk_function_t ___wildcard_x696__45, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never1_fun402__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never1_fun402__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (8528) -> 8530 8532 */
  kk_box_t x = _self->x; /* 8528 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);kk_box_dup(x, _ctx);}, {}, _ctx)
  kk_function_drop(___wildcard_x696__45, _ctx);
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), op, (op, x, _ctx), _ctx);
}
static kk_box_t kk_std_core_hnd_clause_never1_fun401(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x696__16, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never1_fun401__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never1_fun401__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (8528) -> 8530 8532 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x696__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to_final(m, kk_std_core_hnd_new_clause_never1_fun402(op, x, _ctx), _ctx);
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_never1(kk_function_t op, kk_context_t* _ctx) { /* forall<a,b,e,c,d> (op : (a) -> e d) -> clause1<a,b,c,e,d> */ 
  return kk_std_core_hnd__new_Clause1(kk_std_core_hnd_new_clause_never1_fun401(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_never2_fun403__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_never2_fun403(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x787__16, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never2_fun403(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never2_fun403__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never2_fun403__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never2_fun403, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_never2_fun404__t {
  struct kk_function_s _base;
  kk_function_t op;
  kk_box_t x1;
  kk_box_t x2;
};
static kk_box_t kk_std_core_hnd_clause_never2_fun404(kk_function_t _fself, kk_function_t ___wildcard_x787__49, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never2_fun404(kk_function_t op, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never2_fun404__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never2_fun404__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never2_fun404, kk_context());
  _self->op = op;
  _self->x1 = x1;
  _self->x2 = x2;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_never2_fun404(kk_function_t _fself, kk_function_t ___wildcard_x787__49, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never2_fun404__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never2_fun404__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (8609, 8610) -> 8612 8614 */
  kk_box_t x1 = _self->x1; /* 8609 */
  kk_box_t x2 = _self->x2; /* 8610 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);kk_box_dup(x1, _ctx);kk_box_dup(x2, _ctx);}, {}, _ctx)
  kk_function_drop(___wildcard_x787__49, _ctx);
  return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, _ctx), _ctx);
}
static kk_box_t kk_std_core_hnd_clause_never2_fun403(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ___wildcard_x787__16, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never2_fun403__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never2_fun403__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (8609, 8610) -> 8612 8614 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(___wildcard_x787__16, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to_final(m, kk_std_core_hnd_new_clause_never2_fun404(op, x1, x2, _ctx), _ctx);
}

kk_std_core_hnd__clause2 kk_std_core_hnd_clause_never2(kk_function_t op, kk_context_t* _ctx) { /* forall<a,b,c,e,d,a1> (op : (a, b) -> e a1) -> clause2<a,b,c,d,e,a1> */ 
  return kk_std_core_hnd__new_Clause2(kk_std_core_hnd_new_clause_never2_fun403(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_never3_fun405__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_never3_fun405(kk_function_t _fself, int32_t _b_x142, kk_std_core_hnd__ev _b_x143, kk_box_t _b_x144, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never3_fun405(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never3_fun405__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never3_fun405__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never3_fun405, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_never3_fun406__t {
  struct kk_function_s _base;
  kk_box_t _b_x144;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_never3_fun406(kk_function_t _fself, kk_function_t ___wildcard_x696__45, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never3_fun406(kk_box_t _b_x144, kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never3_fun406__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never3_fun406__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never3_fun406, kk_context());
  _self->_b_x144 = _b_x144;
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_never3_fun406(kk_function_t _fself, kk_function_t ___wildcard_x696__45, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never3_fun406__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never3_fun406__t*, _fself, _ctx);
  kk_box_t _b_x144 = _self->_b_x144; /* 45 */
  kk_function_t op = _self->op; /* (8687, 8688, 8689) -> 8691 8693 */
  kk_drop_match(_self, {kk_box_dup(_b_x144, _ctx);kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_function_drop(___wildcard_x696__45, _ctx);
  kk_std_core_types__tuple3 _match_x228 = kk_std_core_types__tuple3_unbox(_b_x144, KK_OWNED, _ctx); /*(8687, 8688, 8689)*/;
  {
    kk_box_t x1 = _match_x228.fst;
    kk_box_t x2 = _match_x228.snd;
    kk_box_t x3 = _match_x228.thd;
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, x3, _ctx), _ctx);
  }
}
static kk_box_t kk_std_core_hnd_clause_never3_fun405(kk_function_t _fself, int32_t _b_x142, kk_std_core_hnd__ev _b_x143, kk_box_t _b_x144, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never3_fun405__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never3_fun405__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (8687, 8688, 8689) -> 8691 8693 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(_b_x143, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to_final(_b_x142, kk_std_core_hnd_new_clause_never3_fun406(_b_x144, op, _ctx), _ctx);
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_never3(kk_function_t op, kk_context_t* _ctx) { /* forall<a,b,c,d,e,a1,b1> (op : (a, b, c) -> e b1) -> clause1<(a, b, c),d,a1,e,b1> */ 
  return kk_std_core_hnd__new_Clause1(kk_std_core_hnd_new_clause_never3_fun405(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_clause_never4_fun407__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_never4_fun407(kk_function_t _fself, int32_t _b_x150, kk_std_core_hnd__ev _b_x151, kk_box_t _b_x152, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never4_fun407(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never4_fun407__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never4_fun407__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never4_fun407, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_never4_fun408__t {
  struct kk_function_s _base;
  kk_box_t _b_x152;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_never4_fun408(kk_function_t _fself, kk_function_t ___wildcard_x696__45, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_never4_fun408(kk_box_t _b_x152, kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never4_fun408__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_never4_fun408__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_never4_fun408, kk_context());
  _self->_b_x152 = _b_x152;
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_never4_fun408(kk_function_t _fself, kk_function_t ___wildcard_x696__45, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never4_fun408__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never4_fun408__t*, _fself, _ctx);
  kk_box_t _b_x152 = _self->_b_x152; /* 45 */
  kk_function_t op = _self->op; /* (8774, 8775, 8776, 8777) -> 8779 8781 */
  kk_drop_match(_self, {kk_box_dup(_b_x152, _ctx);kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_function_drop(___wildcard_x696__45, _ctx);
  kk_std_core_types__tuple4 _match_x227 = kk_std_core_types__tuple4_unbox(_b_x152, KK_OWNED, _ctx); /*(8774, 8775, 8776, 8777)*/;
  {
    struct kk_std_core_types_Tuple4* _con_x409 = kk_std_core_types__as_Tuple4(_match_x227, _ctx);
    kk_box_t x1 = _con_x409->fst;
    kk_box_t x2 = _con_x409->snd;
    kk_box_t x3 = _con_x409->thd;
    kk_box_t x4 = _con_x409->field4;
    if kk_likely(kk_datatype_ptr_is_unique(_match_x227, _ctx)) {
      kk_datatype_ptr_free(_match_x227, _ctx);
    }
    else {
      kk_box_dup(x1, _ctx);
      kk_box_dup(x2, _ctx);
      kk_box_dup(x3, _ctx);
      kk_box_dup(x4, _ctx);
      kk_datatype_ptr_decref(_match_x227, _ctx);
    }
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, x3, x4, _ctx), _ctx);
  }
}
static kk_box_t kk_std_core_hnd_clause_never4_fun407(kk_function_t _fself, int32_t _b_x150, kk_std_core_hnd__ev _b_x151, kk_box_t _b_x152, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_never4_fun407__t* _self = kk_function_as(struct kk_std_core_hnd_clause_never4_fun407__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (8774, 8775, 8776, 8777) -> 8779 8781 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(_b_x151, (KK_I32(3)), _ctx);
  return kk_std_core_hnd_yield_to_final(_b_x150, kk_std_core_hnd_new_clause_never4_fun408(_b_x152, op, _ctx), _ctx);
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_never4(kk_function_t op, kk_context_t* _ctx) { /* forall<a,b,c,d,a1,e,b1,c1> (op : (a, b, c, d) -> e c1) -> clause1<(a, b, c, d),a1,b1,e,c1> */ 
  return kk_std_core_hnd__new_Clause1(kk_std_core_hnd_new_clause_never4_fun407(op, _ctx), _ctx);
}
extern kk_box_t kk_std_core_hnd_clause_tail_noop3_fun410(kk_function_t _fself, int32_t _b_x158, kk_std_core_hnd__ev _b_x159, kk_box_t _b_x160, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail_noop3_fun410__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail_noop3_fun410__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (8863, 8864, 8865) -> 8860 8866 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(_b_x159, (KK_I32(3)), _ctx);
  kk_std_core_types__tuple3 _match_x226 = kk_std_core_types__tuple3_unbox(_b_x160, KK_OWNED, _ctx); /*(8863, 8864, 8865)*/;
  {
    kk_box_t x1 = _match_x226.fst;
    kk_box_t x2 = _match_x226.snd;
    kk_box_t x3 = _match_x226.thd;
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, x3, _ctx), _ctx);
  }
}


// lift anonymous function
struct kk_std_core_hnd_clause_tail_noop4_fun411__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_tail_noop4_fun411(kk_function_t _fself, int32_t _b_x166, kk_std_core_hnd__ev _b_x167, kk_box_t _b_x168, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_tail_noop4_fun411(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail_noop4_fun411__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_tail_noop4_fun411__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_tail_noop4_fun411, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_tail_noop4_fun411(kk_function_t _fself, int32_t _b_x166, kk_std_core_hnd__ev _b_x167, kk_box_t _b_x168, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail_noop4_fun411__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail_noop4_fun411__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (8950, 8951, 8952, 8953) -> 8947 8954 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_datatype_ptr_dropn(_b_x167, (KK_I32(3)), _ctx);
  kk_std_core_types__tuple4 _match_x225 = kk_std_core_types__tuple4_unbox(_b_x168, KK_OWNED, _ctx); /*(8950, 8951, 8952, 8953)*/;
  {
    struct kk_std_core_types_Tuple4* _con_x412 = kk_std_core_types__as_Tuple4(_match_x225, _ctx);
    kk_box_t x1 = _con_x412->fst;
    kk_box_t x2 = _con_x412->snd;
    kk_box_t x3 = _con_x412->thd;
    kk_box_t x4 = _con_x412->field4;
    if kk_likely(kk_datatype_ptr_is_unique(_match_x225, _ctx)) {
      kk_datatype_ptr_free(_match_x225, _ctx);
    }
    else {
      kk_box_dup(x1, _ctx);
      kk_box_dup(x2, _ctx);
      kk_box_dup(x3, _ctx);
      kk_box_dup(x4, _ctx);
      kk_datatype_ptr_decref(_match_x225, _ctx);
    }
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, x3, x4, _ctx), _ctx);
  }
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_tail_noop4(kk_function_t op, kk_context_t* _ctx) { /* forall<e,a,b,c,d,a1,b1,c1> (op : (c, d, a1, b1) -> e c1) -> clause1<(c, d, a1, b1),c1,b,e,a> */ 
  return kk_std_core_hnd__new_Clause1(kk_std_core_hnd_new_clause_tail_noop4_fun411(op, _ctx), _ctx);
}
 
// extra under1x to make under1 inlineable


// lift anonymous function
struct kk_std_core_hnd_under1x_fun415__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_under1x_fun415(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_under1x_fun415(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under1x_fun415__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_under1x_fun415__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_under1x_fun415, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_under1x_fun415(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under1x_fun415__t* _self = kk_function_as(struct kk_std_core_hnd_under1x_fun415__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<9065> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_under1x(ev, cont, res, _ctx);
}

kk_box_t kk_std_core_hnd_under1x(kk_std_core_hnd__ev ev, kk_function_t op, kk_box_t x, kk_context_t* _ctx) { /* forall<a,b,e,c> (ev : ev<c>, op : (a) -> e b, x : a) -> e b */ 
  kk_evv_t w0;
  kk_evv_t _x_x413;
  {
    struct kk_std_core_hnd_Ev* _con_x414 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w = _con_x414->hevv;
    kk_evv_dup(w, _ctx);
    _x_x413 = w; /*hnd/evv<4237>*/
  }
  w0 = kk_evv_swap(_x_x413,kk_context()); /*hnd/evv<_8991>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), op, (op, x, _ctx), _ctx); /*9063*/;
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    kk_evv_drop(w0, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_under1x_fun415(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    kk_unit_t ___0 = kk_Unit;
    kk_evv_set(w0,kk_context());
    return y;
  }
}
extern kk_box_t kk_std_core_hnd_under1_fun418(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under1_fun418__t* _self = kk_function_as(struct kk_std_core_hnd_under1_fun418__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<9163> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_under1x(ev, cont, res, _ctx);
}
extern kk_box_t kk_std_core_hnd_under0_fun424(kk_function_t _fself, kk_function_t cont_0, kk_box_t res_0, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under0_fun424__t* _self = kk_function_as(struct kk_std_core_hnd_under0_fun424__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<9250> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_under1x(ev, cont_0, res_0, _ctx);
}
extern kk_box_t kk_std_core_hnd_under0_fun421(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under0_fun421__t* _self = kk_function_as(struct kk_std_core_hnd_under0_fun421__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<9250> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  kk_evv_t w0_0;
  kk_evv_t _x_x422;
  {
    struct kk_std_core_hnd_Ev* _con_x423 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w_0 = _con_x423->hevv;
    kk_evv_dup(w_0, _ctx);
    _x_x422 = w_0; /*hnd/evv<4237>*/
  }
  w0_0 = kk_evv_swap(_x_x422,kk_context()); /*hnd/evv<_9089>*/
  kk_box_t y_0 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, res, _ctx), _ctx); /*9248*/;
  if (kk_yielding(kk_context())) {
    kk_box_drop(y_0, _ctx);
    kk_evv_drop(w0_0, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_under0_fun424(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    kk_unit_t ___0 = kk_Unit;
    kk_evv_set(w0_0,kk_context());
    return y_0;
  }
}


// lift anonymous function
struct kk_std_core_hnd_clause_tail0_fun425__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_tail0_fun425(kk_function_t _fself, int32_t ___wildcard_x734__14, kk_std_core_hnd__ev ev, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_tail0_fun425(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail0_fun425__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_tail0_fun425__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_tail0_fun425, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_tail0_fun428__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_clause_tail0_fun428(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_tail0_fun428(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail0_fun428__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_tail0_fun428__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_tail0_fun428, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_tail0_fun431__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_clause_tail0_fun431(kk_function_t _fself, kk_function_t cont_0, kk_box_t res_0, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_tail0_fun431(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail0_fun431__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_tail0_fun431__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_tail0_fun431, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_tail0_fun431(kk_function_t _fself, kk_function_t cont_0, kk_box_t res_0, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail0_fun431__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail0_fun431__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<9304> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_under1x(ev, cont_0, res_0, _ctx);
}
static kk_box_t kk_std_core_hnd_clause_tail0_fun428(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail0_fun428__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail0_fun428__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<9304> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  kk_evv_t w0_0;
  kk_evv_t _x_x429;
  {
    struct kk_std_core_hnd_Ev* _con_x430 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w_0 = _con_x430->hevv;
    kk_evv_dup(w_0, _ctx);
    _x_x429 = w_0; /*hnd/evv<4237>*/
  }
  w0_0 = kk_evv_swap(_x_x429,kk_context()); /*hnd/evv<_9089>*/
  kk_box_t y_0 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, res, _ctx), _ctx); /*9305*/;
  if (kk_yielding(kk_context())) {
    kk_box_drop(y_0, _ctx);
    kk_evv_drop(w0_0, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_clause_tail0_fun431(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    kk_unit_t ___0 = kk_Unit;
    kk_evv_set(w0_0,kk_context());
    return y_0;
  }
}
static kk_box_t kk_std_core_hnd_clause_tail0_fun425(kk_function_t _fself, int32_t ___wildcard_x734__14, kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail0_fun425__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail0_fun425__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* () -> 9302 9305 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_evv_t w0;
  kk_evv_t _x_x426;
  {
    struct kk_std_core_hnd_Ev* _con_x427 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w = _con_x427->hevv;
    kk_evv_dup(w, _ctx);
    _x_x426 = w; /*hnd/evv<4237>*/
  }
  w0 = kk_evv_swap(_x_x426,kk_context()); /*hnd/evv<_9186>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), op, (op, _ctx), _ctx); /*9305*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w0,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_clause_tail0_fun428(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    return y;
  }
}

kk_std_core_hnd__clause0 kk_std_core_hnd_clause_tail0(kk_function_t op, kk_context_t* _ctx) { /* forall<e,a,b,c> (op : () -> e c) -> clause0<c,b,e,a> */ 
  return kk_std_core_hnd__new_Clause0(kk_std_core_hnd_new_clause_tail0_fun425(op, _ctx), _ctx);
}
 
// tail-resumptive clause: resumes exactly once at the end
// (these can be executed 'in-place' without capturing a resumption)


// lift anonymous function
struct kk_std_core_hnd_clause_tail1_fun432__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_tail1_fun432(kk_function_t _fself, int32_t ___wildcard_x686__14, kk_std_core_hnd__ev ev, kk_box_t x, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_tail1_fun432(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail1_fun432__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_tail1_fun432__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_tail1_fun432, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_clause_tail1_fun435__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_clause_tail1_fun435(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_tail1_fun435(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail1_fun435__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_tail1_fun435__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_tail1_fun435, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_tail1_fun435(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail1_fun435__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail1_fun435__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<9373> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_under1x(ev, cont, res, _ctx);
}
static kk_box_t kk_std_core_hnd_clause_tail1_fun432(kk_function_t _fself, int32_t ___wildcard_x686__14, kk_std_core_hnd__ev ev, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail1_fun432__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail1_fun432__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (9374) -> 9371 9375 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_evv_t w0;
  kk_evv_t _x_x433;
  {
    struct kk_std_core_hnd_Ev* _con_x434 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w = _con_x434->hevv;
    kk_evv_dup(w, _ctx);
    _x_x433 = w; /*hnd/evv<4237>*/
  }
  w0 = kk_evv_swap(_x_x433,kk_context()); /*hnd/evv<_9089>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), op, (op, x, _ctx), _ctx); /*9375*/;
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    kk_evv_drop(w0, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_clause_tail1_fun435(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    kk_unit_t ___0 = kk_Unit;
    kk_evv_set(w0,kk_context());
    return y;
  }
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_tail1(kk_function_t op, kk_context_t* _ctx) { /* forall<e,a,b,c,d> (op : (c) -> e d) -> clause1<c,d,b,e,a> */ 
  return kk_std_core_hnd__new_Clause1(kk_std_core_hnd_new_clause_tail1_fun432(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_under2_fun438__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_under2_fun438(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_under2_fun438(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under2_fun438__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_under2_fun438__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_under2_fun438, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_under2_fun441__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_under2_fun441(kk_function_t _fself, kk_function_t cont_0, kk_box_t res_0, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_under2_fun441(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under2_fun441__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_under2_fun441__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_under2_fun441, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_under2_fun441(kk_function_t _fself, kk_function_t cont_0, kk_box_t res_0, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under2_fun441__t* _self = kk_function_as(struct kk_std_core_hnd_under2_fun441__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<9476> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_under1x(ev, cont_0, res_0, _ctx);
}
static kk_box_t kk_std_core_hnd_under2_fun438(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under2_fun438__t* _self = kk_function_as(struct kk_std_core_hnd_under2_fun438__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<9476> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  kk_evv_t w0_0;
  kk_evv_t _x_x439;
  {
    struct kk_std_core_hnd_Ev* _con_x440 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w_0 = _con_x440->hevv;
    kk_evv_dup(w_0, _ctx);
    _x_x439 = w_0; /*hnd/evv<4237>*/
  }
  w0_0 = kk_evv_swap(_x_x439,kk_context()); /*hnd/evv<_9089>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, res, _ctx), _ctx); /*9474*/;
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    kk_evv_drop(w0_0, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_under2_fun441(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    kk_unit_t ___0 = kk_Unit;
    kk_evv_set(w0_0,kk_context());
    return y;
  }
}

kk_box_t kk_std_core_hnd_under2(kk_std_core_hnd__ev ev, kk_function_t op, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) { /* forall<a,b,c,e,d> (ev : ev<d>, op : (a, b) -> e c, x1 : a, x2 : b) -> e c */ 
  kk_evv_t w0;
  kk_evv_t _x_x436;
  {
    struct kk_std_core_hnd_Ev* _con_x437 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w = _con_x437->hevv;
    kk_evv_dup(w, _ctx);
    _x_x436 = w; /*hnd/evv<4237>*/
  }
  w0 = kk_evv_swap(_x_x436,kk_context()); /*hnd/evv<_9404>*/
  kk_box_t z = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, _ctx), _ctx); /*9474*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w0,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(z, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_under2_fun438(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    return z;
  }
}
extern kk_box_t kk_std_core_hnd_clause_tail2_fun442(kk_function_t _fself, int32_t m, kk_std_core_hnd__ev ev, kk_box_t x1, kk_box_t x2, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail2_fun442__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail2_fun442__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (9557, 9558) -> 9554 9559 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_under2(ev, op, x1, x2, _ctx);
}
extern kk_box_t kk_std_core_hnd_clause_tail3_fun443(kk_function_t _fself, kk_box_t _b_x174, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail3_fun443__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail3_fun443__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (9635, 9636, 9637) -> 9632 9638 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple3 _match_x215 = kk_std_core_types__tuple3_unbox(_b_x174, KK_OWNED, _ctx); /*(9635, 9636, 9637)*/;
  {
    kk_box_t x1 = _match_x215.fst;
    kk_box_t x2 = _match_x215.snd;
    kk_box_t x3 = _match_x215.thd;
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, x3, _ctx), _ctx);
  }
}


// lift anonymous function
struct kk_std_core_hnd_clause_tail4_fun444__t {
  struct kk_function_s _base;
  kk_function_t op;
};
static kk_box_t kk_std_core_hnd_clause_tail4_fun444(kk_function_t _fself, kk_box_t _b_x178, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_clause_tail4_fun444(kk_function_t op, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail4_fun444__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_clause_tail4_fun444__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_clause_tail4_fun444, kk_context());
  _self->op = op;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_clause_tail4_fun444(kk_function_t _fself, kk_box_t _b_x178, kk_context_t* _ctx) {
  struct kk_std_core_hnd_clause_tail4_fun444__t* _self = kk_function_as(struct kk_std_core_hnd_clause_tail4_fun444__t*, _fself, _ctx);
  kk_function_t op = _self->op; /* (9722, 9723, 9724, 9725) -> 9719 9726 */
  kk_drop_match(_self, {kk_function_dup(op, _ctx);}, {}, _ctx)
  kk_std_core_types__tuple4 _match_x214 = kk_std_core_types__tuple4_unbox(_b_x178, KK_OWNED, _ctx); /*(9722, 9723, 9724, 9725)*/;
  {
    struct kk_std_core_types_Tuple4* _con_x445 = kk_std_core_types__as_Tuple4(_match_x214, _ctx);
    kk_box_t x1 = _con_x445->fst;
    kk_box_t x2 = _con_x445->snd;
    kk_box_t x3 = _con_x445->thd;
    kk_box_t x4 = _con_x445->field4;
    if kk_likely(kk_datatype_ptr_is_unique(_match_x214, _ctx)) {
      kk_datatype_ptr_free(_match_x214, _ctx);
    }
    else {
      kk_box_dup(x1, _ctx);
      kk_box_dup(x2, _ctx);
      kk_box_dup(x3, _ctx);
      kk_box_dup(x4, _ctx);
      kk_datatype_ptr_decref(_match_x214, _ctx);
    }
    return kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, x3, x4, _ctx), _ctx);
  }
}

kk_std_core_hnd__clause1 kk_std_core_hnd_clause_tail4(kk_function_t op, kk_context_t* _ctx) { /* forall<e,a,b,c,d,a1,b1,c1> (op : (c, d, a1, b1) -> e c1) -> clause1<(c, d, a1, b1),c1,b,e,a> */ 
  return kk_std_core_hnd_clause_tail1(kk_std_core_hnd_new_clause_tail4_fun444(op, _ctx), _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_finally_prompt_fun446__t {
  struct kk_function_s _base;
  kk_function_t fin;
};
static kk_box_t kk_std_core_hnd_finally_prompt_fun446(kk_function_t _fself, kk_function_t cont, kk_box_t x, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_finally_prompt_fun446(kk_function_t fin, kk_context_t* _ctx) {
  struct kk_std_core_hnd_finally_prompt_fun446__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_finally_prompt_fun446__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_finally_prompt_fun446, kk_context());
  _self->fin = fin;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_finally_prompt_fun446(kk_function_t _fself, kk_function_t cont, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_finally_prompt_fun446__t* _self = kk_function_as(struct kk_std_core_hnd_finally_prompt_fun446__t*, _fself, _ctx);
  kk_function_t fin = _self->fin; /* () -> 9857 () */
  kk_drop_match(_self, {kk_function_dup(fin, _ctx);}, {}, _ctx)
  kk_box_t _x_x447 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, x, _ctx), _ctx); /*9856*/
  return kk_std_core_hnd_finally_prompt(fin, _x_x447, _ctx);
}


// lift anonymous function
struct kk_std_core_hnd_finally_prompt_fun448__t {
  struct kk_function_s _base;
  kk_std_core_hnd__yield_info yld;
};
static kk_box_t kk_std_core_hnd_finally_prompt_fun448(kk_function_t _fself, kk_box_t ___wildcard_x537__43, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_finally_prompt_fun448(kk_std_core_hnd__yield_info yld, kk_context_t* _ctx) {
  struct kk_std_core_hnd_finally_prompt_fun448__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_finally_prompt_fun448__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_finally_prompt_fun448, kk_context());
  _self->yld = yld;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_finally_prompt_fun448(kk_function_t _fself, kk_box_t ___wildcard_x537__43, kk_context_t* _ctx) {
  struct kk_std_core_hnd_finally_prompt_fun448__t* _self = kk_function_as(struct kk_std_core_hnd_finally_prompt_fun448__t*, _fself, _ctx);
  kk_std_core_hnd__yield_info yld = _self->yld; /* hnd/yield-info */
  kk_drop_match(_self, {kk_std_core_hnd__yield_info_dup(yld, _ctx);}, {}, _ctx)
  kk_box_drop(___wildcard_x537__43, _ctx);
  return kk_std_core_hnd_unsafe_reyield(yld, _ctx);
}

kk_box_t kk_std_core_hnd_finally_prompt(kk_function_t fin, kk_box_t res, kk_context_t* _ctx) { /* forall<a,e> (fin : () -> e (), res : a) -> e a */ 
  if (kk_yielding(kk_context())) {
    kk_box_drop(res, _ctx);
    bool _match_x212 = kk_yielding_non_final(kk_context()); /*bool*/;
    if (_match_x212) {
      return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_finally_prompt_fun446(fin, _ctx), _ctx);
    }
    {
      kk_std_core_hnd__yield_info yld = kk_std_core_hnd_yield_capture(_ctx); /*hnd/yield-info*/;
      kk_unit_t ___0 = kk_Unit;
      kk_function_call(kk_unit_t, (kk_function_t, kk_context_t*), fin, (fin, _ctx), _ctx);
      if (kk_yielding(kk_context())) {
        return kk_std_core_hnd_yield_extend(kk_std_core_hnd_new_finally_prompt_fun448(yld, _ctx), _ctx);
      }
      {
        return kk_std_core_hnd_unsafe_reyield(yld, _ctx);
      }
    }
  }
  {
    kk_unit_t __ = kk_Unit;
    kk_function_call(kk_unit_t, (kk_function_t, kk_context_t*), fin, (fin, _ctx), _ctx);
    return res;
  }
}


// lift anonymous function
struct kk_std_core_hnd_initially_prompt_fun450__t {
  struct kk_function_s _base;
  kk_ref_t count;
  kk_function_t init;
};
static kk_box_t kk_std_core_hnd_initially_prompt_fun450(kk_function_t _fself, kk_function_t cont, kk_box_t x, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_initially_prompt_fun450(kk_ref_t count, kk_function_t init, kk_context_t* _ctx) {
  struct kk_std_core_hnd_initially_prompt_fun450__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_initially_prompt_fun450__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_initially_prompt_fun450, kk_context());
  _self->count = count;
  _self->init = init;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_initially_prompt_fun456__t {
  struct kk_function_s _base;
  kk_function_t cont;
  kk_function_t init;
  kk_box_t x;
};
static kk_box_t kk_std_core_hnd_initially_prompt_fun456(kk_function_t _fself, kk_box_t ___wildcard_x580__35, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_initially_prompt_fun456(kk_function_t cont, kk_function_t init, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_initially_prompt_fun456__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_initially_prompt_fun456__t, 4, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_initially_prompt_fun456, kk_context());
  _self->cont = cont;
  _self->init = init;
  _self->x = x;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_initially_prompt_fun456(kk_function_t _fself, kk_box_t ___wildcard_x580__35, kk_context_t* _ctx) {
  struct kk_std_core_hnd_initially_prompt_fun456__t* _self = kk_function_as(struct kk_std_core_hnd_initially_prompt_fun456__t*, _fself, _ctx);
  kk_function_t cont = _self->cont; /* (10049) -> 10059 10058 */
  kk_function_t init = _self->init; /* (int) -> 10059 () */
  kk_box_t x = _self->x; /* 10049 */
  kk_drop_match(_self, {kk_function_dup(cont, _ctx);kk_function_dup(init, _ctx);kk_box_dup(x, _ctx);}, {}, _ctx)
  kk_box_drop(___wildcard_x580__35, _ctx);
  kk_box_t _x_x457 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, x, _ctx), _ctx); /*10058*/
  return kk_std_core_hnd_initially_prompt(init, _x_x457, _ctx);
}
static kk_box_t kk_std_core_hnd_initially_prompt_fun450(kk_function_t _fself, kk_function_t cont, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_initially_prompt_fun450__t* _self = kk_function_as(struct kk_std_core_hnd_initially_prompt_fun450__t*, _fself, _ctx);
  kk_ref_t count = _self->count; /* ref<global,int> */
  kk_function_t init = _self->init; /* (int) -> 10059 () */
  kk_drop_match(_self, {kk_ref_dup(count, _ctx);kk_function_dup(init, _ctx);}, {}, _ctx)
  kk_integer_t cnt;
  kk_box_t _x_x451;
  kk_ref_t _x_x452 = kk_ref_dup(count, _ctx); /*ref<global,int>*/
  _x_x451 = kk_ref_get(_x_x452,kk_context()); /*209*/
  cnt = kk_integer_unbox(_x_x451, _ctx); /*int*/
  kk_integer_t _b_x186_188;
  kk_integer_t _x_x453 = kk_integer_dup(cnt, _ctx); /*int*/
  _b_x186_188 = kk_integer_add(_x_x453,(kk_integer_from_small(1)),kk_context()); /*int*/
  kk_unit_t __ = kk_Unit;
  kk_unit_t _brw_x211 = kk_Unit;
  kk_ref_set_borrow(count,(kk_integer_box(_b_x186_188, _ctx)),kk_context());
  kk_ref_drop(count, _ctx);
  _brw_x211;
  kk_unit_t ___1 = kk_Unit;
  bool _match_x209 = kk_integer_eq_borrow(cnt,(kk_integer_from_small(0)),kk_context()); /*bool*/;
  if (_match_x209) {
    kk_integer_drop(cnt, _ctx);
  }
  else {
    kk_unit_t r = kk_Unit;
    kk_function_t _x_x454 = kk_function_dup(init, _ctx); /*(int) -> 10059 ()*/
    kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), _x_x454, (_x_x454, cnt, _ctx), _ctx);
    if (kk_yielding(kk_context())) {
      kk_box_t ___0;
      kk_function_t _x_x455;
      kk_function_dup(cont, _ctx);
      kk_function_dup(init, _ctx);
      kk_box_dup(x, _ctx);
      _x_x455 = kk_std_core_hnd_new_initially_prompt_fun456(cont, init, x, _ctx); /*(_10005) -> 10059 1851*/
      ___0 = kk_std_core_hnd_yield_extend(_x_x455, _ctx); /*10058*/
      kk_box_drop(___0, _ctx);
    }
    else {
      
    }
  }
  kk_box_t _x_x458 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, x, _ctx), _ctx); /*10058*/
  return kk_std_core_hnd_initially_prompt(init, _x_x458, _ctx);
}

kk_box_t kk_std_core_hnd_initially_prompt(kk_function_t init, kk_box_t res, kk_context_t* _ctx) { /* forall<a,e> (init : (int) -> e (), res : a) -> e a */ 
  bool _match_x208 = kk_yielding_non_final(kk_context()); /*bool*/;
  if (_match_x208) {
    kk_box_drop(res, _ctx);
    kk_ref_t count = kk_ref_alloc((kk_integer_box(kk_integer_from_small(0), _ctx)),kk_context()); /*ref<global,int>*/;
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_initially_prompt_fun450(count, init, _ctx), _ctx);
  }
  {
    kk_function_drop(init, _ctx);
    return res;
  }
}


// lift anonymous function
struct kk_std_core_hnd_initially_fun460__t {
  struct kk_function_s _base;
  kk_function_t action;
  kk_function_t init;
};
static kk_box_t kk_std_core_hnd_initially_fun460(kk_function_t _fself, kk_box_t _b_x190, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_initially_fun460(kk_function_t action, kk_function_t init, kk_context_t* _ctx) {
  struct kk_std_core_hnd_initially_fun460__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_initially_fun460__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_initially_fun460, kk_context());
  _self->action = action;
  _self->init = init;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_initially_fun460(kk_function_t _fself, kk_box_t _b_x190, kk_context_t* _ctx) {
  struct kk_std_core_hnd_initially_fun460__t* _self = kk_function_as(struct kk_std_core_hnd_initially_fun460__t*, _fself, _ctx);
  kk_function_t action = _self->action; /* () -> 10113 10112 */
  kk_function_t init = _self->init; /* (int) -> 10113 () */
  kk_drop_match(_self, {kk_function_dup(action, _ctx);kk_function_dup(init, _ctx);}, {}, _ctx)
  kk_box_drop(_b_x190, _ctx);
  kk_box_t _x_x461 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx); /*10112*/
  return kk_std_core_hnd_initially_prompt(init, _x_x461, _ctx);
}

kk_box_t kk_std_core_hnd_initially(kk_function_t init, kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (init : (int) -> e (), action : () -> e a) -> e a */ 
  kk_unit_t __ = kk_Unit;
  kk_function_t _x_x459 = kk_function_dup(init, _ctx); /*(int) -> 10113 ()*/
  kk_function_call(kk_unit_t, (kk_function_t, kk_integer_t, kk_context_t*), _x_x459, (_x_x459, kk_integer_from_small(0), _ctx), _ctx);
  if (kk_yielding(kk_context())) {
    return kk_std_core_hnd_yield_extend(kk_std_core_hnd_new_initially_fun460(action, init, _ctx), _ctx);
  }
  {
    kk_box_t _x_x462 = kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx); /*10112*/
    return kk_std_core_hnd_initially_prompt(init, _x_x462, _ctx);
  }
}


// lift anonymous function
struct kk_std_core_hnd_prompt_local_var_fun464__t {
  struct kk_function_s _base;
  kk_ref_t loc;
  kk_box_t v;
};
static kk_box_t kk_std_core_hnd_prompt_local_var_fun464(kk_function_t _fself, kk_function_t cont, kk_box_t x, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_prompt_local_var_fun464(kk_ref_t loc, kk_box_t v, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_local_var_fun464__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_prompt_local_var_fun464__t, 3, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_prompt_local_var_fun464, kk_context());
  _self->loc = loc;
  _self->v = v;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_prompt_local_var_fun464(kk_function_t _fself, kk_function_t cont, kk_box_t x, kk_context_t* _ctx) {
  struct kk_std_core_hnd_prompt_local_var_fun464__t* _self = kk_function_as(struct kk_std_core_hnd_prompt_local_var_fun464__t*, _fself, _ctx);
  kk_ref_t loc = _self->loc; /* local-var<10233,10230> */
  kk_box_t v = _self->v; /* 10230 */
  kk_drop_match(_self, {kk_ref_dup(loc, _ctx);kk_box_dup(v, _ctx);}, {}, _ctx)
  kk_unit_t ___0 = kk_Unit;
  kk_ref_set_borrow(loc,v,kk_context());
  kk_box_t _x_x465 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, x, _ctx), _ctx); /*10231*/
  return kk_std_core_hnd_prompt_local_var(loc, _x_x465, _ctx);
}

kk_box_t kk_std_core_hnd_prompt_local_var(kk_ref_t loc, kk_box_t res, kk_context_t* _ctx) { /* forall<a,b,h> (loc : local-var<h,a>, res : b) -> <div,local<h>> b */ 
  if (kk_yielding(kk_context())) {
    kk_box_drop(res, _ctx);
    kk_box_t v;
    kk_ref_t _x_x463 = kk_ref_dup(loc, _ctx); /*local-var<10233,10230>*/
    v = kk_ref_get(_x_x463,kk_context()); /*10230*/
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_prompt_local_var_fun464(loc, v, _ctx), _ctx);
  }
  {
    kk_ref_drop(loc, _ctx);
    return res;
  }
}


// lift anonymous function
struct kk_std_core_hnd_try_finalize_prompt_fun468__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_core_hnd_try_finalize_prompt_fun468(kk_function_t _fself, kk_function_t _b_x194, kk_box_t _b_x195, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_try_finalize_prompt_fun468(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_core_hnd_try_finalize_prompt_fun468, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_core_hnd_try_finalize_prompt_fun468(kk_function_t _fself, kk_function_t _b_x194, kk_box_t _b_x195, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_function_t cont_199 = _b_x194; /*(10411) -> 10462 10461*/;
  kk_box_t x_200 = _b_x195; /*10411*/;
  kk_std_core_types__either _x_x469;
  kk_box_t _x_x470 = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont_199, (cont_199, x_200, _ctx), _ctx); /*10461*/
  _x_x469 = kk_std_core_hnd_try_finalize_prompt(_x_x470, _ctx); /*either<hnd/yield-info,1922>*/
  return kk_std_core_types__either_box(_x_x469, _ctx);
}

kk_std_core_types__either kk_std_core_hnd_try_finalize_prompt(kk_box_t res, kk_context_t* _ctx) { /* forall<a,e> (res : a) -> e either<yield-info,a> */ 
  bool _match_x206 = kk_yielding_non_final(kk_context()); /*bool*/;
  if (_match_x206) {
    kk_box_drop(res, _ctx);
    kk_box_t _x_x467 = kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_try_finalize_prompt_fun468(_ctx), _ctx); /*3770*/
    return kk_std_core_types__either_unbox(_x_x467, KK_OWNED, _ctx);
  }
  if (kk_yielding(kk_context())) {
    kk_box_drop(res, _ctx);
    kk_std_core_hnd__yield_info _b_x196_198 = kk_std_core_hnd_yield_capture(_ctx); /*hnd/yield-info*/;
    return kk_std_core_types__new_Left(kk_std_core_hnd__yield_info_box(_b_x196_198, _ctx), _ctx);
  }
  {
    return kk_std_core_types__new_Right(res, _ctx);
  }
}


// lift anonymous function
struct kk_std_core_hnd_under3_fun473__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_under3_fun473(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_under3_fun473(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under3_fun473__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_under3_fun473__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_under3_fun473, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_under3_fun476__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_under3_fun476(kk_function_t _fself, kk_function_t cont_0, kk_box_t res_0, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_under3_fun476(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under3_fun476__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_under3_fun476__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_under3_fun476, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_under3_fun476(kk_function_t _fself, kk_function_t cont_0, kk_box_t res_0, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under3_fun476__t* _self = kk_function_as(struct kk_std_core_hnd_under3_fun476__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<10558> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_under1x(ev, cont_0, res_0, _ctx);
}
static kk_box_t kk_std_core_hnd_under3_fun473(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under3_fun473__t* _self = kk_function_as(struct kk_std_core_hnd_under3_fun473__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<10558> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  kk_evv_t w0_0;
  kk_evv_t _x_x474;
  {
    struct kk_std_core_hnd_Ev* _con_x475 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w_0 = _con_x475->hevv;
    kk_evv_dup(w_0, _ctx);
    _x_x474 = w_0; /*hnd/evv<4237>*/
  }
  w0_0 = kk_evv_swap(_x_x474,kk_context()); /*hnd/evv<_9089>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, res, _ctx), _ctx); /*10556*/;
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    kk_evv_drop(w0_0, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_under3_fun476(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    kk_unit_t ___0 = kk_Unit;
    kk_evv_set(w0_0,kk_context());
    return y;
  }
}

kk_box_t kk_std_core_hnd_under3(kk_std_core_hnd__ev ev, kk_function_t op, kk_box_t x1, kk_box_t x2, kk_box_t x3, kk_context_t* _ctx) { /* forall<a,b,c,d,e,a1> (ev : ev<a1>, op : (a, b, c) -> e d, x1 : a, x2 : b, x3 : c) -> e d */ 
  kk_evv_t w0;
  kk_evv_t _x_x471;
  {
    struct kk_std_core_hnd_Ev* _con_x472 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w = _con_x472->hevv;
    kk_evv_dup(w, _ctx);
    _x_x471 = w; /*hnd/evv<4237>*/
  }
  w0 = kk_evv_swap(_x_x471,kk_context()); /*hnd/evv<_10482>*/
  kk_box_t z = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, x3, _ctx), _ctx); /*10556*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w0,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(z, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_under3_fun473(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    return z;
  }
}


// lift anonymous function
struct kk_std_core_hnd_under4_fun479__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_under4_fun479(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_under4_fun479(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under4_fun479__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_under4_fun479__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_under4_fun479, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}



// lift anonymous function
struct kk_std_core_hnd_under4_fun482__t {
  struct kk_function_s _base;
  kk_std_core_hnd__ev ev;
};
static kk_box_t kk_std_core_hnd_under4_fun482(kk_function_t _fself, kk_function_t cont_0, kk_box_t res_0, kk_context_t* _ctx);
static kk_function_t kk_std_core_hnd_new_under4_fun482(kk_std_core_hnd__ev ev, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under4_fun482__t* _self = kk_function_alloc_as(struct kk_std_core_hnd_under4_fun482__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_core_hnd_under4_fun482, kk_context());
  _self->ev = ev;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_core_hnd_under4_fun482(kk_function_t _fself, kk_function_t cont_0, kk_box_t res_0, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under4_fun482__t* _self = kk_function_as(struct kk_std_core_hnd_under4_fun482__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<10671> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  return kk_std_core_hnd_under1x(ev, cont_0, res_0, _ctx);
}
static kk_box_t kk_std_core_hnd_under4_fun479(kk_function_t _fself, kk_function_t cont, kk_box_t res, kk_context_t* _ctx) {
  struct kk_std_core_hnd_under4_fun479__t* _self = kk_function_as(struct kk_std_core_hnd_under4_fun479__t*, _fself, _ctx);
  kk_std_core_hnd__ev ev = _self->ev; /* hnd/ev<10671> */
  kk_drop_match(_self, {kk_std_core_hnd__ev_dup(ev, _ctx);}, {}, _ctx)
  kk_evv_t w0_0;
  kk_evv_t _x_x480;
  {
    struct kk_std_core_hnd_Ev* _con_x481 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w_0 = _con_x481->hevv;
    kk_evv_dup(w_0, _ctx);
    _x_x480 = w_0; /*hnd/evv<4237>*/
  }
  w0_0 = kk_evv_swap(_x_x480,kk_context()); /*hnd/evv<_9089>*/
  kk_box_t y = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_context_t*), cont, (cont, res, _ctx), _ctx); /*10669*/;
  if (kk_yielding(kk_context())) {
    kk_box_drop(y, _ctx);
    kk_evv_drop(w0_0, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_under4_fun482(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    kk_unit_t ___0 = kk_Unit;
    kk_evv_set(w0_0,kk_context());
    return y;
  }
}

kk_box_t kk_std_core_hnd_under4(kk_std_core_hnd__ev ev, kk_function_t op, kk_box_t x1, kk_box_t x2, kk_box_t x3, kk_box_t x4, kk_context_t* _ctx) { /* forall<a,b,c,d,a1,e,b1> (ev : ev<b1>, op : (a, b, c, d) -> e a1, x1 : a, x2 : b, x3 : c, x4 : d) -> e a1 */ 
  kk_evv_t w0;
  kk_evv_t _x_x477;
  {
    struct kk_std_core_hnd_Ev* _con_x478 = kk_std_core_hnd__as_Ev(ev, _ctx);
    kk_evv_t w = _con_x478->hevv;
    kk_evv_dup(w, _ctx);
    _x_x477 = w; /*hnd/evv<4237>*/
  }
  w0 = kk_evv_swap(_x_x477,kk_context()); /*hnd/evv<_10591>*/
  kk_box_t z = kk_function_call(kk_box_t, (kk_function_t, kk_box_t, kk_box_t, kk_box_t, kk_box_t, kk_context_t*), op, (op, x1, x2, x3, x4, _ctx), _ctx); /*10669*/;
  kk_unit_t __ = kk_Unit;
  kk_evv_set(w0,kk_context());
  if (kk_yielding(kk_context())) {
    kk_box_drop(z, _ctx);
    return kk_std_core_hnd_yield_cont(kk_std_core_hnd_new_under4_fun479(ev, _ctx), _ctx);
  }
  {
    kk_datatype_ptr_dropn(ev, (KK_I32(3)), _ctx);
    return z;
  }
}
 
// Evidence equality compares the markers.

bool kk_std_core_hnd_ev_fs__lp__eq__eq__rp_(kk_std_core_hnd__ev _pat_x142__18, kk_std_core_hnd__ev _pat_x142__37, kk_context_t* _ctx) { /* forall<a> (ev<a>, ev<a>) -> bool */ 
  {
    struct kk_std_core_hnd_Ev* _con_x484 = kk_std_core_hnd__as_Ev(_pat_x142__18, _ctx);
    kk_std_core_hnd__htag _pat_0 = _con_x484->htag;
    int32_t m1 = _con_x484->marker;
    kk_box_t _pat_1 = _con_x484->hnd;
    kk_evv_t _pat_2 = _con_x484->hevv;
    if kk_likely(kk_datatype_ptr_is_unique(_pat_x142__18, _ctx)) {
      kk_evv_drop(_pat_2, _ctx);
      kk_box_drop(_pat_1, _ctx);
      kk_std_core_hnd__htag_drop(_pat_0, _ctx);
      kk_datatype_ptr_free(_pat_x142__18, _ctx);
    }
    else {
      kk_datatype_ptr_decref(_pat_x142__18, _ctx);
    }
    {
      struct kk_std_core_hnd_Ev* _con_x485 = kk_std_core_hnd__as_Ev(_pat_x142__37, _ctx);
      kk_std_core_hnd__htag _pat_4 = _con_x485->htag;
      int32_t m2 = _con_x485->marker;
      kk_box_t _pat_5 = _con_x485->hnd;
      kk_evv_t _pat_6 = _con_x485->hevv;
      if kk_likely(kk_datatype_ptr_is_unique(_pat_x142__37, _ctx)) {
        kk_evv_drop(_pat_6, _ctx);
        kk_box_drop(_pat_5, _ctx);
        kk_std_core_hnd__htag_drop(_pat_4, _ctx);
        kk_datatype_ptr_free(_pat_x142__37, _ctx);
      }
      else {
        kk_datatype_ptr_decref(_pat_x142__37, _ctx);
      }
      return kk_std_core_hnd_eq_marker(m1, m2, _ctx);
    }
  }
}

// initialization
void kk_std_core_hnd__init(kk_context_t* _ctx){
  static bool _kk_initialized = false;
  if (_kk_initialized) return;
  _kk_initialized = true;
  kk_std_core_types__init(_ctx);
  kk_std_core_undiv__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_core_hnd__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_undiv__done(_ctx);
  kk_std_core_types__done(_ctx);
}
