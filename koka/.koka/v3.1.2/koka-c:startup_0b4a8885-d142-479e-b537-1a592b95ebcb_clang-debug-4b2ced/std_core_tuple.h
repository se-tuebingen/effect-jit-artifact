#pragma once
#ifndef kk_std_core_tuple_H
#define kk_std_core_tuple_H
// Koka generated module: std/core/tuple, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_hnd.h"

// type declarations

// value declarations
 
// Convert a unit value `()` to a string

static inline kk_string_t kk_std_core_tuple_unit_fs_show(kk_unit_t u, kk_context_t* _ctx) { /* (u : ()) -> string */ 
  kk_define_string_literal(, _s_x122, 2, "()", _ctx)
  return kk_string_dup(_s_x122, _ctx);
}
 
// monadic lift

static inline kk_std_core_types__tuple2 kk_std_core_tuple_tuple2_fs__mlift_map_10029(kk_box_t _y_x10000, kk_box_t _y_x10001, kk_context_t* _ctx) { /* forall<a,e> (a, a) -> e (a, a) */ 
  return kk_std_core_types__new_Tuple2(_y_x10000, _y_x10001, _ctx);
}

kk_std_core_types__tuple2 kk_std_core_tuple_tuple2_fs__mlift_map_10030(kk_function_t f, kk_std_core_types__tuple2 t, kk_box_t _y_x10000, kk_context_t* _ctx); /* forall<a,b,e> (f : (a) -> e b, t : (a, a), b) -> e (b, b) */ 

kk_std_core_types__tuple2 kk_std_core_tuple_tuple2_fs_map(kk_std_core_types__tuple2 t, kk_function_t f, kk_context_t* _ctx); /* forall<a,b,e> (t : (a, a), f : (a) -> e b) -> e (b, b) */ 
 
// monadic lift

static inline kk_std_core_types__tuple3 kk_std_core_tuple_tuple3_fs__mlift_map_10031(kk_box_t _y_x10002, kk_box_t _y_x10003, kk_box_t _y_x10004, kk_context_t* _ctx) { /* forall<a,e> (a, a, a) -> e (a, a, a) */ 
  return kk_std_core_types__new_Tuple3(_y_x10002, _y_x10003, _y_x10004, _ctx);
}

kk_std_core_types__tuple3 kk_std_core_tuple_tuple3_fs__mlift_map_10032(kk_box_t _y_x10002, kk_function_t f, kk_std_core_types__tuple3 t, kk_box_t _y_x10003, kk_context_t* _ctx); /* forall<a,b,e> (b, f : (a) -> e b, t : (a, a, a), b) -> e (b, b, b) */ 

kk_std_core_types__tuple3 kk_std_core_tuple_tuple3_fs__mlift_map_10033(kk_function_t f, kk_std_core_types__tuple3 t, kk_box_t _y_x10002, kk_context_t* _ctx); /* forall<a,b,e> (f : (a) -> e b, t : (a, a, a), b) -> e (b, b, b) */ 

kk_std_core_types__tuple3 kk_std_core_tuple_tuple3_fs_map(kk_std_core_types__tuple3 t, kk_function_t f, kk_context_t* _ctx); /* forall<a,b,e> (t : (a, a, a), f : (a) -> e b) -> e (b, b, b) */ 
 
// monadic lift

static inline kk_std_core_types__tuple4 kk_std_core_tuple_tuple4_fs__mlift_map_10034(kk_box_t _y_x10005, kk_box_t _y_x10006, kk_box_t _y_x10007, kk_box_t _y_x10008, kk_context_t* _ctx) { /* forall<a,e> (a, a, a, a) -> e (a, a, a, a) */ 
  return kk_std_core_types__new_Tuple4(kk_reuse_null, 0, _y_x10005, _y_x10006, _y_x10007, _y_x10008, _ctx);
}

kk_std_core_types__tuple4 kk_std_core_tuple_tuple4_fs__mlift_map_10035(kk_box_t _y_x10005, kk_box_t _y_x10006, kk_function_t f, kk_std_core_types__tuple4 t, kk_box_t _y_x10007, kk_context_t* _ctx); /* forall<a,b,e> (b, b, f : (a) -> e b, t : (a, a, a, a), b) -> e (b, b, b, b) */ 

kk_std_core_types__tuple4 kk_std_core_tuple_tuple4_fs__mlift_map_10036(kk_box_t _y_x10005, kk_function_t f, kk_std_core_types__tuple4 t, kk_box_t _y_x10006, kk_context_t* _ctx); /* forall<a,b,e> (b, f : (a) -> e b, t : (a, a, a, a), b) -> e (b, b, b, b) */ 

kk_std_core_types__tuple4 kk_std_core_tuple_tuple4_fs__mlift_map_10037(kk_function_t f, kk_std_core_types__tuple4 t, kk_box_t _y_x10005, kk_context_t* _ctx); /* forall<a,b,e> (f : (a) -> e b, t : (a, a, a, a), b) -> e (b, b, b, b) */ 

kk_std_core_types__tuple4 kk_std_core_tuple_tuple4_fs_map(kk_std_core_types__tuple4 t, kk_function_t f, kk_context_t* _ctx); /* forall<a,b,e> (t : (a, a, a, a), f : (a) -> e b) -> e (b, b, b, b) */ 
 
// monadic lift

static inline kk_string_t kk_std_core_tuple_tuple2_fs__mlift_show_10038(kk_string_t _y_x10009, kk_string_t _y_x10010, kk_context_t* _ctx) { /* forall<e> (string, string) -> e string */ 
  kk_string_t _x_x199;
  kk_define_string_literal(, _s_x200, 1, "(", _ctx)
  _x_x199 = kk_string_dup(_s_x200, _ctx); /*string*/
  kk_string_t _x_x201;
  kk_string_t _x_x202;
  kk_string_t _x_x203;
  kk_define_string_literal(, _s_x204, 1, ",", _ctx)
  _x_x203 = kk_string_dup(_s_x204, _ctx); /*string*/
  kk_string_t _x_x205;
  kk_string_t _x_x206;
  kk_define_string_literal(, _s_x207, 1, ")", _ctx)
  _x_x206 = kk_string_dup(_s_x207, _ctx); /*string*/
  _x_x205 = kk_std_core_types__lp__plus__plus__rp_(_y_x10010, _x_x206, _ctx); /*string*/
  _x_x202 = kk_std_core_types__lp__plus__plus__rp_(_x_x203, _x_x205, _ctx); /*string*/
  _x_x201 = kk_std_core_types__lp__plus__plus__rp_(_y_x10009, _x_x202, _ctx); /*string*/
  return kk_std_core_types__lp__plus__plus__rp_(_x_x199, _x_x201, _ctx);
}

kk_string_t kk_std_core_tuple_tuple2_fs__mlift_show_10039(kk_std_core_types__tuple2 x, kk_function_t _implicit_fs_snd_fs_show, kk_string_t _y_x10009, kk_context_t* _ctx); /* forall<a,b,e> (x : (a, b), ?snd/show : (b) -> e string, string) -> e string */ 

kk_string_t kk_std_core_tuple_tuple2_fs_show(kk_std_core_types__tuple2 x, kk_function_t _implicit_fs_fst_fs_show, kk_function_t _implicit_fs_snd_fs_show, kk_context_t* _ctx); /* forall<a,b,e> (x : (a, b), ?fst/show : (a) -> e string, ?snd/show : (b) -> e string) -> e string */ 

kk_string_t kk_std_core_tuple_tuple3_fs__mlift_show_10040(kk_string_t _y_x10011, kk_string_t _y_x10012, kk_string_t _y_x10013, kk_context_t* _ctx); /* forall<e> (string, string, string) -> e string */ 

kk_string_t kk_std_core_tuple_tuple3_fs__mlift_show_10041(kk_string_t _y_x10011, kk_std_core_types__tuple3 x, kk_function_t _implicit_fs_thd_fs_show, kk_string_t _y_x10012, kk_context_t* _ctx); /* forall<a,b,c,e> (string, x : (a, b, c), ?thd/show : (c) -> e string, string) -> e string */ 

kk_string_t kk_std_core_tuple_tuple3_fs__mlift_show_10042(kk_std_core_types__tuple3 x, kk_function_t _implicit_fs_snd_fs_show, kk_function_t _implicit_fs_thd_fs_show, kk_string_t _y_x10011, kk_context_t* _ctx); /* forall<a,b,c,e> (x : (a, b, c), ?snd/show : (b) -> e string, ?thd/show : (c) -> e string, string) -> e string */ 

kk_string_t kk_std_core_tuple_tuple3_fs_show(kk_std_core_types__tuple3 x, kk_function_t _implicit_fs_fst_fs_show, kk_function_t _implicit_fs_snd_fs_show, kk_function_t _implicit_fs_thd_fs_show, kk_context_t* _ctx); /* forall<a,b,c,e> (x : (a, b, c), ?fst/show : (a) -> e string, ?snd/show : (b) -> e string, ?thd/show : (c) -> e string) -> e string */ 
 
// _deprecated_, use `tuple2/show` instead

static inline kk_string_t kk_std_core_tuple_show_tuple(kk_std_core_types__tuple2 x, kk_function_t showfst, kk_function_t showsnd, kk_context_t* _ctx) { /* forall<a,b,e> (x : (a, b), showfst : (a) -> e string, showsnd : (b) -> e string) -> e string */ 
  return kk_std_core_tuple_tuple2_fs_show(x, showfst, showsnd, _ctx);
}

bool kk_std_core_tuple_tuple2_fs__lp__eq__eq__rp_(kk_std_core_types__tuple2 _pat_x29__22, kk_std_core_types__tuple2 _pat_x29__39, kk_function_t _implicit_fs_fst_fs__lp__eq__eq__rp_, kk_function_t _implicit_fs_snd_fs__lp__eq__eq__rp_, kk_context_t* _ctx); /* forall<a,b> ((a, b), (a, b), ?fst/(==) : (a, a) -> bool, ?snd/(==) : (b, b) -> bool) -> bool */ 

bool kk_std_core_tuple_tuple3_fs__lp__eq__eq__rp_(kk_std_core_types__tuple3 _pat_x33__22, kk_std_core_types__tuple3 _pat_x33__44, kk_function_t _implicit_fs_fst_fs__lp__eq__eq__rp_, kk_function_t _implicit_fs_snd_fs__lp__eq__eq__rp_, kk_function_t _implicit_fs_thd_fs__lp__eq__eq__rp_, kk_context_t* _ctx); /* forall<a,b,c> ((a, b, c), (a, b, c), ?fst/(==) : (a, a) -> bool, ?snd/(==) : (b, b) -> bool, ?thd/(==) : (c, c) -> bool) -> bool */ 

kk_std_core_types__order kk_std_core_tuple_tuple2_fs_cmp(kk_std_core_types__tuple2 _pat_x38__21, kk_std_core_types__tuple2 _pat_x38__38, kk_function_t _implicit_fs_fst_fs_cmp, kk_function_t _implicit_fs_snd_fs_cmp, kk_context_t* _ctx); /* forall<a,b> ((a, b), (a, b), ?fst/cmp : (a, a) -> order, ?snd/cmp : (b, b) -> order) -> order */ 

kk_std_core_types__order kk_std_core_tuple_tuple3_fs_cmp(kk_std_core_types__tuple3 _pat_x44__26, kk_std_core_types__tuple3 _pat_x44__48, kk_function_t _implicit_fs_fst_fs_cmp, kk_function_t _implicit_fs_snd_fs_cmp, kk_function_t _implicit_fs_thd_fs_cmp, kk_context_t* _ctx); /* forall<a,b,c> ((a, b, c), (a, b, c), ?fst/cmp : (a, a) -> order, ?snd/cmp : (b, b) -> order, ?thd/cmp : (c, c) -> order) -> order */ 

void kk_std_core_tuple__init(kk_context_t* _ctx);


void kk_std_core_tuple__done(kk_context_t* _ctx);

#endif // header
