#pragma once
#ifndef kk_std_core_types_H
#define kk_std_core_types_H
// Koka generated module: std/core/types, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>

// type declarations

// type std/core/types/@field-addr
struct kk_std_core_types__field_addr_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__field_addr;
static inline kk_std_core_types__field_addr kk_std_core_types__field_addr_dup(kk_std_core_types__field_addr _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__field_addr_drop(kk_std_core_types__field_addr _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__field_addr_box(kk_std_core_types__field_addr _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__field_addr kk_std_core_types__field_addr_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value type std/core/types/@optional
struct kk_std_core_types__Optional {
  kk_box_t value;
};
struct kk_std_core_types__None {
  kk_box_t _unused;
};
struct kk_std_core_types__optional_s {
  kk_value_tag_t _tag;
  union {
    struct kk_std_core_types__Optional _Optional;
    struct kk_std_core_types__None _None;
    kk_box_t _fields[1];
  } _cons;
};
typedef struct kk_std_core_types__optional_s kk_std_core_types__optional;
static inline kk_std_core_types__optional kk_std_core_types__new_None(kk_context_t* _ctx) {
  kk_std_core_types__optional _con;
  _con._tag = kk_value_tag(2);
  _con._cons._fields[0] = kk_box_null();
  return _con;
}
static inline kk_std_core_types__optional kk_std_core_types__new_Optional(kk_box_t value, kk_context_t* _ctx) {
  kk_std_core_types__optional _con;
  _con._tag = kk_value_tag(1);
  _con._cons._Optional.value = value;
  return _con;
}
static inline bool kk_std_core_types__is_None(kk_std_core_types__optional x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(2)));
}
static inline bool kk_std_core_types__is_Optional(kk_std_core_types__optional x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(1)));
}
static inline kk_std_core_types__optional kk_std_core_types__optional_dup(kk_std_core_types__optional _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_Optional(_x, _ctx)) { kk_box_dup(_x._cons._Optional.value, _ctx); }
  return _x;
}
static inline void kk_std_core_types__optional_drop(kk_std_core_types__optional _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_Optional(_x, _ctx)) { kk_box_drop(_x._cons._Optional.value, _ctx); }
}
static inline kk_box_t kk_std_core_types__optional_box(kk_std_core_types__optional _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_None(_x, _ctx)) { return kk_box_Nothing(); }
    else { return kk_box_Just(kk_box_box(_x._cons._Optional.value, _ctx), _ctx); }
}
static inline kk_std_core_types__optional kk_std_core_types__optional_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  if (kk_box_is_Nothing(_x)) { return kk_std_core_types__new_None(_ctx); }
    else { return kk_std_core_types__new_Optional(kk_box_unbox(kk_unbox_Just(_x, _borrow, _ctx), _ctx), _ctx); };
}

// type std/core/types/@reuse
struct kk_std_core_types__reuse_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__reuse;
static inline kk_std_core_types__reuse kk_std_core_types__reuse_dup(kk_std_core_types__reuse _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__reuse_drop(kk_std_core_types__reuse _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__reuse_box(kk_std_core_types__reuse _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__reuse kk_std_core_types__reuse_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value type std/core/types/@valueop
struct kk_std_core_types__valueop_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__valueop;
static inline kk_std_core_types__valueop kk_std_core_types__new_Valueop(kk_context_t* _ctx) {
  return kk_datatype_from_tag((kk_tag_t)(1));
}
static inline bool kk_std_core_types__is_Valueop(kk_std_core_types__valueop x, kk_context_t* _ctx) {
  return (kk_datatype_has_singleton_tag(x, (kk_tag_t)(1)));
}
static inline kk_std_core_types__valueop kk_std_core_types__valueop_dup(kk_std_core_types__valueop _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__valueop_drop(kk_std_core_types__valueop _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__valueop_box(kk_std_core_types__valueop _x, kk_context_t* _ctx) {
  kk_box_t _box;
  kk_valuetype_box(kk_std_core_types__valueop, _box, _x, 0 /* scan count */, _ctx);
  return _box;
}
static inline kk_std_core_types__valueop kk_std_core_types__valueop_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/alloc
struct kk_std_core_types__alloc_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__alloc;
static inline kk_std_core_types__alloc kk_std_core_types__alloc_dup(kk_std_core_types__alloc _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__alloc_drop(kk_std_core_types__alloc _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__alloc_box(kk_std_core_types__alloc _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__alloc kk_std_core_types__alloc_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/any
struct kk_std_core_types__any_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__any;
static inline kk_std_core_types__any kk_std_core_types__any_dup(kk_std_core_types__any _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__any_drop(kk_std_core_types__any _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__any_box(kk_std_core_types__any _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__any kk_std_core_types__any_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value type std/core/types/bool
enum kk_std_core_types__bool_e {
  kk_std_core_types_False,
  kk_std_core_types_True
};
typedef uint8_t kk_std_core_types__bool;

static inline kk_std_core_types__bool kk_std_core_types__new_False(kk_context_t* _ctx) {
  return kk_std_core_types_False;
}
static inline kk_std_core_types__bool kk_std_core_types__new_True(kk_context_t* _ctx) {
  return kk_std_core_types_True;
}
static inline bool kk_std_core_types__is_False(kk_std_core_types__bool x, kk_context_t* _ctx) {
  return (x == kk_std_core_types_False);
}
static inline bool kk_std_core_types__is_True(kk_std_core_types__bool x, kk_context_t* _ctx) {
  return (x == kk_std_core_types_True);
}
static inline kk_std_core_types__bool kk_std_core_types__bool_dup(kk_std_core_types__bool _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__bool_drop(kk_std_core_types__bool _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__bool_box(kk_std_core_types__bool _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__bool kk_std_core_types__bool_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__bool)kk_enum_unbox(_x);
}

// value type std/core/types/box
struct kk_std_core_types_Box {
  kk_box_t unbox;
};
typedef struct kk_std_core_types_Box kk_std_core_types__box;
static inline kk_std_core_types__box kk_std_core_types__new_Box(kk_box_t unbox, kk_context_t* _ctx) {
  kk_std_core_types__box _con = { unbox };
  return _con;
}
static inline bool kk_std_core_types__is_Box(kk_std_core_types__box x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core_types__box kk_std_core_types__box_dup(kk_std_core_types__box _x, kk_context_t* _ctx) {
  kk_box_dup(_x.unbox, _ctx);
  return _x;
}
static inline void kk_std_core_types__box_drop(kk_std_core_types__box _x, kk_context_t* _ctx) {
  kk_box_drop(_x.unbox, _ctx);
}
static inline kk_box_t kk_std_core_types__box_box(kk_std_core_types__box _x, kk_context_t* _ctx) {
  return kk_box_box(_x.unbox, _ctx);
}
static inline kk_std_core_types__box kk_std_core_types__box_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_std_core_types__new_Box(kk_box_unbox(_x, _ctx), _ctx);
}

// value type std/core/types/cctx
struct kk_std_core_types__Cctx {
  kk_box_t res;
  kk_field_addr_t holeptr;
};
typedef struct kk_std_core_types__Cctx kk_std_core_types__cctx;
static inline kk_std_core_types__cctx kk_std_core_types__new_Cctx(kk_box_t res, kk_field_addr_t holeptr, kk_context_t* _ctx) {
  kk_std_core_types__cctx _con;
  _con.res = res;
  _con.holeptr = holeptr;
  return _con;
}
static inline bool kk_std_core_types__is_Cctx(kk_std_core_types__cctx x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core_types__cctx kk_std_core_types__cctx_dup(kk_std_core_types__cctx _x, kk_context_t* _ctx) {
  kk_box_dup(_x.res, _ctx);
  kk_skip_dup(_x.holeptr, _ctx);
  return _x;
}
static inline void kk_std_core_types__cctx_drop(kk_std_core_types__cctx _x, kk_context_t* _ctx) {
  kk_box_drop(_x.res, _ctx);
  kk_skip_drop(_x.holeptr, _ctx);
}
static inline kk_box_t kk_std_core_types__cctx_box(kk_std_core_types__cctx _x, kk_context_t* _ctx) {
  kk_box_t _box;
  kk_valuetype_box(kk_std_core_types__cctx, _box, _x, 2 /* scan count */, _ctx);
  return _box;
}
static inline kk_std_core_types__cctx kk_std_core_types__cctx_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  kk_std_core_types__cctx _unbox;
  kk_valuetype_unbox(kk_std_core_types__cctx, _unbox, _x, _borrow, _ctx);
  return _unbox;
}

// value type std/core/types/char
enum kk_std_core_types__char_e {
  kk_std_core_types_char_empty
};
typedef uint32_t kk_std_core_types__char;

static inline kk_std_core_types__char kk_std_core_types__char_dup(kk_std_core_types__char _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__char_drop(kk_std_core_types__char _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__char_box(kk_std_core_types__char _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__char kk_std_core_types__char_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__char)kk_enum_unbox(_x);
}

// type std/core/types/div
struct kk_std_core_types__div_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__div;
static inline kk_std_core_types__div kk_std_core_types__div_dup(kk_std_core_types__div _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__div_drop(kk_std_core_types__div _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__div_box(kk_std_core_types__div _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__div kk_std_core_types__div_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/ediv
struct kk_std_core_types__ediv_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__ediv;
static inline kk_std_core_types__ediv kk_std_core_types__ediv_dup(kk_std_core_types__ediv _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__ediv_drop(kk_std_core_types__ediv _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__ediv_box(kk_std_core_types__ediv _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__ediv kk_std_core_types__ediv_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/effect-extend
struct kk_std_core_types__effect_extend_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__effect_extend;
static inline kk_std_core_types__effect_extend kk_std_core_types__effect_extend_dup(kk_std_core_types__effect_extend _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__effect_extend_drop(kk_std_core_types__effect_extend _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__effect_extend_box(kk_std_core_types__effect_extend _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__effect_extend kk_std_core_types__effect_extend_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value type std/core/types/either
struct kk_std_core_types_Left {
  kk_box_t left;
};
struct kk_std_core_types_Right {
  kk_box_t right;
};
struct kk_std_core_types_either_s {
  kk_value_tag_t _tag;
  union {
    struct kk_std_core_types_Left Left;
    struct kk_std_core_types_Right Right;
  } _cons;
};
typedef struct kk_std_core_types_either_s kk_std_core_types__either;
static inline kk_std_core_types__either kk_std_core_types__new_Left(kk_box_t left, kk_context_t* _ctx) {
  kk_std_core_types__either _con;
  _con._tag = kk_value_tag(1);
  _con._cons.Left.left = left;
  return _con;
}
static inline kk_std_core_types__either kk_std_core_types__new_Right(kk_box_t right, kk_context_t* _ctx) {
  kk_std_core_types__either _con;
  _con._tag = kk_value_tag(2);
  _con._cons.Right.right = right;
  return _con;
}
static inline bool kk_std_core_types__is_Left(kk_std_core_types__either x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(1)));
}
static inline bool kk_std_core_types__is_Right(kk_std_core_types__either x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(2)));
}
static inline kk_std_core_types__either kk_std_core_types__either_dup(kk_std_core_types__either _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_Left(_x, _ctx)) { kk_box_dup(_x._cons.Left.left, _ctx); }
  else { kk_box_dup(_x._cons.Right.right, _ctx); }
  return _x;
}
static inline void kk_std_core_types__either_drop(kk_std_core_types__either _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_Left(_x, _ctx)) { kk_box_drop(_x._cons.Left.left, _ctx); }
  else { kk_box_drop(_x._cons.Right.right, _ctx); }
}
static inline kk_box_t kk_std_core_types__either_box(kk_std_core_types__either _x, kk_context_t* _ctx) {
  kk_box_t _box;
  kk_valuetype_box(kk_std_core_types__either, _box, _x, 2 /* scan count */, _ctx);
  return _box;
}
static inline kk_std_core_types__either kk_std_core_types__either_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  kk_std_core_types__either _unbox;
  kk_valuetype_unbox(kk_std_core_types__either, _unbox, _x, _borrow, _ctx);
  return _unbox;
}

// value type std/core/types/float32
enum kk_std_core_types__float32_e {
  kk_std_core_types_float32_empty
};
typedef uint32_t kk_std_core_types__float32;

static inline kk_std_core_types__float32 kk_std_core_types__float32_dup(kk_std_core_types__float32 _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__float32_drop(kk_std_core_types__float32 _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__float32_box(kk_std_core_types__float32 _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__float32 kk_std_core_types__float32_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__float32)kk_enum_unbox(_x);
}

// value type std/core/types/float64
enum kk_std_core_types__float64_e {
  kk_std_core_types_float64_empty
};
typedef uint64_t kk_std_core_types__float64;

static inline kk_std_core_types__float64 kk_std_core_types__float64_dup(kk_std_core_types__float64 _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__float64_drop(kk_std_core_types__float64 _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__float64_box(kk_std_core_types__float64 _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__float64 kk_std_core_types__float64_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__float64)kk_enum_unbox(_x);
}

// type std/core/types/global
struct kk_std_core_types__global_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__global;
static inline kk_std_core_types__global kk_std_core_types__global_dup(kk_std_core_types__global _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__global_drop(kk_std_core_types__global _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__global_box(kk_std_core_types__global _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__global kk_std_core_types__global_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/handled
struct kk_std_core_types__handled_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__handled;
static inline kk_std_core_types__handled kk_std_core_types__handled_dup(kk_std_core_types__handled _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__handled_drop(kk_std_core_types__handled _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__handled_box(kk_std_core_types__handled _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__handled kk_std_core_types__handled_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/handled1
struct kk_std_core_types__handled1_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__handled1;
static inline kk_std_core_types__handled1 kk_std_core_types__handled1_dup(kk_std_core_types__handled1 _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__handled1_drop(kk_std_core_types__handled1 _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__handled1_box(kk_std_core_types__handled1 _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__handled1 kk_std_core_types__handled1_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/hdiv
struct kk_std_core_types__hdiv_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__hdiv;
static inline kk_std_core_types__hdiv kk_std_core_types__hdiv_dup(kk_std_core_types__hdiv _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__hdiv_drop(kk_std_core_types__hdiv _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__hdiv_box(kk_std_core_types__hdiv _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__hdiv kk_std_core_types__hdiv_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/int
struct kk_std_core_types__int_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__int;
static inline kk_std_core_types__int kk_std_core_types__int_dup(kk_std_core_types__int _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__int_drop(kk_std_core_types__int _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__int_box(kk_std_core_types__int _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__int kk_std_core_types__int_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value type std/core/types/int16
enum kk_std_core_types__int16_e {
  kk_std_core_types_int16_empty
};
typedef uint16_t kk_std_core_types__int16;

static inline kk_std_core_types__int16 kk_std_core_types__int16_dup(kk_std_core_types__int16 _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__int16_drop(kk_std_core_types__int16 _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__int16_box(kk_std_core_types__int16 _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__int16 kk_std_core_types__int16_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__int16)kk_enum_unbox(_x);
}

// value type std/core/types/int32
enum kk_std_core_types__int32_e {
  kk_std_core_types_int32_empty
};
typedef uint32_t kk_std_core_types__int32;

static inline kk_std_core_types__int32 kk_std_core_types__int32_dup(kk_std_core_types__int32 _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__int32_drop(kk_std_core_types__int32 _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__int32_box(kk_std_core_types__int32 _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__int32 kk_std_core_types__int32_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__int32)kk_enum_unbox(_x);
}

// value type std/core/types/int64
enum kk_std_core_types__int64_e {
  kk_std_core_types_int64_empty
};
typedef uint64_t kk_std_core_types__int64;

static inline kk_std_core_types__int64 kk_std_core_types__int64_dup(kk_std_core_types__int64 _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__int64_drop(kk_std_core_types__int64 _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__int64_box(kk_std_core_types__int64 _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__int64 kk_std_core_types__int64_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__int64)kk_enum_unbox(_x);
}

// value type std/core/types/int8
enum kk_std_core_types__int8_e {
  kk_std_core_types_int8_empty
};
typedef uint8_t kk_std_core_types__int8;

static inline kk_std_core_types__int8 kk_std_core_types__int8_dup(kk_std_core_types__int8 _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__int8_drop(kk_std_core_types__int8 _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__int8_box(kk_std_core_types__int8 _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__int8 kk_std_core_types__int8_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__int8)kk_enum_unbox(_x);
}

// value type std/core/types/intptr_t
enum kk_std_core_types__intptr__t_e {
  kk_std_core_types_intptr__t_empty
};
typedef uint64_t kk_std_core_types__intptr__t;

static inline kk_std_core_types__intptr__t kk_std_core_types__intptr__t_dup(kk_std_core_types__intptr__t _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__intptr__t_drop(kk_std_core_types__intptr__t _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__intptr__t_box(kk_std_core_types__intptr__t _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__intptr__t kk_std_core_types__intptr__t_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__intptr__t)kk_enum_unbox(_x);
}

// type std/core/types/list
struct kk_std_core_types__list_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__list;
struct kk_std_core_types_Cons {
  struct kk_std_core_types__list_s _base;
  kk_box_t head;
  kk_std_core_types__list tail;
};
static inline kk_std_core_types__list kk_std_core_types__new_Nil(kk_context_t* _ctx) {
  return kk_datatype_from_tag((kk_tag_t)(1));
}
static inline kk_std_core_types__list kk_std_core_types__base_Cons(struct kk_std_core_types_Cons* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_std_core_types__list kk_std_core_types__new_Cons(kk_reuse_t _at, int32_t _cpath, kk_box_t head, kk_std_core_types__list tail, kk_context_t* _ctx) {
  struct kk_std_core_types_Cons* _con = kk_block_alloc_at_as(struct kk_std_core_types_Cons, _at, 2 /* scan count */, _cpath, (kk_tag_t)(2), _ctx);
  _con->head = head;
  _con->tail = tail;
  return kk_std_core_types__base_Cons(_con, _ctx);
}
static inline struct kk_std_core_types_Cons* kk_std_core_types__as_Cons(kk_std_core_types__list x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_types_Cons*, x, (kk_tag_t)(2), _ctx);
}
static inline bool kk_std_core_types__is_Nil(kk_std_core_types__list x, kk_context_t* _ctx) {
  return (kk_datatype_has_singleton_tag(x, (kk_tag_t)(1)));
}
static inline bool kk_std_core_types__is_Cons(kk_std_core_types__list x, kk_context_t* _ctx) {
  return (!kk_std_core_types__is_Nil(x, _ctx));
}
static inline kk_std_core_types__list kk_std_core_types__list_dup(kk_std_core_types__list _x, kk_context_t* _ctx) {
  return kk_datatype_dup(_x, _ctx);
}
static inline void kk_std_core_types__list_drop(kk_std_core_types__list _x, kk_context_t* _ctx) {
  kk_datatype_drop(_x, _ctx);
}
static inline kk_box_t kk_std_core_types__list_box(kk_std_core_types__list _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__list kk_std_core_types__list_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/local
struct kk_std_core_types__local_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__local;
static inline kk_std_core_types__local kk_std_core_types__local_dup(kk_std_core_types__local _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__local_drop(kk_std_core_types__local _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__local_box(kk_std_core_types__local _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__local kk_std_core_types__local_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/local-var
struct kk_std_core_types__local_var_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__local_var;
static inline kk_std_core_types__local_var kk_std_core_types__local_var_dup(kk_std_core_types__local_var _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__local_var_drop(kk_std_core_types__local_var _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__local_var_box(kk_std_core_types__local_var _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__local_var kk_std_core_types__local_var_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value type std/core/types/maybe
struct kk_std_core_types_Nothing {
  kk_box_t _unused;
};
struct kk_std_core_types_Just {
  kk_box_t value;
};
struct kk_std_core_types_maybe_s {
  kk_value_tag_t _tag;
  union {
    struct kk_std_core_types_Nothing Nothing;
    struct kk_std_core_types_Just Just;
    kk_box_t _fields[1];
  } _cons;
};
typedef struct kk_std_core_types_maybe_s kk_std_core_types__maybe;
static inline kk_std_core_types__maybe kk_std_core_types__new_Nothing(kk_context_t* _ctx) {
  kk_std_core_types__maybe _con;
  _con._tag = kk_value_tag(1);
  _con._cons._fields[0] = kk_box_null();
  return _con;
}
static inline kk_std_core_types__maybe kk_std_core_types__new_Just(kk_box_t value, kk_context_t* _ctx) {
  kk_std_core_types__maybe _con;
  _con._tag = kk_value_tag(2);
  _con._cons.Just.value = value;
  return _con;
}
static inline bool kk_std_core_types__is_Nothing(kk_std_core_types__maybe x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(1)));
}
static inline bool kk_std_core_types__is_Just(kk_std_core_types__maybe x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(2)));
}
static inline kk_std_core_types__maybe kk_std_core_types__maybe_dup(kk_std_core_types__maybe _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_Just(_x, _ctx)) { kk_box_dup(_x._cons.Just.value, _ctx); }
  return _x;
}
static inline void kk_std_core_types__maybe_drop(kk_std_core_types__maybe _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_Just(_x, _ctx)) { kk_box_drop(_x._cons.Just.value, _ctx); }
}
static inline kk_box_t kk_std_core_types__maybe_box(kk_std_core_types__maybe _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_Nothing(_x, _ctx)) { return kk_box_Nothing(); }
    else { return kk_box_Just(kk_box_box(_x._cons.Just.value, _ctx), _ctx); }
}
static inline kk_std_core_types__maybe kk_std_core_types__maybe_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  if (kk_box_is_Nothing(_x)) { return kk_std_core_types__new_Nothing(_ctx); }
    else { return kk_std_core_types__new_Just(kk_box_unbox(kk_unbox_Just(_x, _borrow, _ctx), _ctx), _ctx); };
}

// type std/core/types/ndet
struct kk_std_core_types__ndet_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__ndet;
static inline kk_std_core_types__ndet kk_std_core_types__ndet_dup(kk_std_core_types__ndet _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__ndet_drop(kk_std_core_types__ndet _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__ndet_box(kk_std_core_types__ndet _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__ndet kk_std_core_types__ndet_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/nhandled
struct kk_std_core_types__nhandled_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__nhandled;
static inline kk_std_core_types__nhandled kk_std_core_types__nhandled_dup(kk_std_core_types__nhandled _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__nhandled_drop(kk_std_core_types__nhandled _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__nhandled_box(kk_std_core_types__nhandled _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__nhandled kk_std_core_types__nhandled_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/nhandled1
struct kk_std_core_types__nhandled1_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__nhandled1;
static inline kk_std_core_types__nhandled1 kk_std_core_types__nhandled1_dup(kk_std_core_types__nhandled1 _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__nhandled1_drop(kk_std_core_types__nhandled1 _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__nhandled1_box(kk_std_core_types__nhandled1 _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__nhandled1 kk_std_core_types__nhandled1_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value type std/core/types/order
enum kk_std_core_types__order_e {
  kk_std_core_types_Lt,
  kk_std_core_types_Eq,
  kk_std_core_types_Gt
};
typedef uint8_t kk_std_core_types__order;

static inline kk_std_core_types__order kk_std_core_types__new_Lt(kk_context_t* _ctx) {
  return kk_std_core_types_Lt;
}
static inline kk_std_core_types__order kk_std_core_types__new_Eq(kk_context_t* _ctx) {
  return kk_std_core_types_Eq;
}
static inline kk_std_core_types__order kk_std_core_types__new_Gt(kk_context_t* _ctx) {
  return kk_std_core_types_Gt;
}
static inline bool kk_std_core_types__is_Lt(kk_std_core_types__order x, kk_context_t* _ctx) {
  return (x == kk_std_core_types_Lt);
}
static inline bool kk_std_core_types__is_Eq(kk_std_core_types__order x, kk_context_t* _ctx) {
  return (x == kk_std_core_types_Eq);
}
static inline bool kk_std_core_types__is_Gt(kk_std_core_types__order x, kk_context_t* _ctx) {
  return (x == kk_std_core_types_Gt);
}
static inline kk_std_core_types__order kk_std_core_types__order_dup(kk_std_core_types__order _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__order_drop(kk_std_core_types__order _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__order_box(kk_std_core_types__order _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__order kk_std_core_types__order_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__order)kk_enum_unbox(_x);
}

// value type std/core/types/order2
struct kk_std_core_types_Lt2 {
  kk_box_t lt;
  kk_box_t gt;
};
struct kk_std_core_types_Eq2 {
  kk_box_t eq;
};
struct kk_std_core_types_Gt2 {
  kk_box_t lt;
  kk_box_t gt;
};
struct kk_std_core_types_order2_s {
  kk_value_tag_t _tag;
  union {
    struct kk_std_core_types_Lt2 Lt2;
    struct kk_std_core_types_Eq2 Eq2;
    struct kk_std_core_types_Gt2 Gt2;
    kk_box_t _fields[2];
  } _cons;
};
typedef struct kk_std_core_types_order2_s kk_std_core_types__order2;
static inline kk_std_core_types__order2 kk_std_core_types__new_Eq2(kk_box_t eq, kk_context_t* _ctx) {
  kk_std_core_types__order2 _con;
  _con._tag = kk_value_tag(2);
  _con._cons.Eq2.eq = eq;
  _con._cons._fields[1] = kk_box_null();
  return _con;
}
static inline kk_std_core_types__order2 kk_std_core_types__new_Lt2(kk_box_t lt, kk_box_t gt, kk_context_t* _ctx) {
  kk_std_core_types__order2 _con;
  _con._tag = kk_value_tag(1);
  _con._cons.Lt2.lt = lt;
  _con._cons.Lt2.gt = gt;
  return _con;
}
static inline kk_std_core_types__order2 kk_std_core_types__new_Gt2(kk_box_t lt, kk_box_t gt, kk_context_t* _ctx) {
  kk_std_core_types__order2 _con;
  _con._tag = kk_value_tag(3);
  _con._cons.Gt2.lt = lt;
  _con._cons.Gt2.gt = gt;
  return _con;
}
static inline bool kk_std_core_types__is_Eq2(kk_std_core_types__order2 x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(2)));
}
static inline bool kk_std_core_types__is_Lt2(kk_std_core_types__order2 x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(1)));
}
static inline bool kk_std_core_types__is_Gt2(kk_std_core_types__order2 x, kk_context_t* _ctx) {
  return (kk_value_tag_eq(x._tag, kk_value_tag(3)));
}
static inline kk_std_core_types__order2 kk_std_core_types__order2_dup(kk_std_core_types__order2 _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_Eq2(_x, _ctx)) { kk_box_dup(_x._cons.Eq2.eq, _ctx); }
  else if (kk_std_core_types__is_Lt2(_x, _ctx)) {
    kk_box_dup(_x._cons.Lt2.lt, _ctx);
    kk_box_dup(_x._cons.Lt2.gt, _ctx);
  }
  else {
    kk_box_dup(_x._cons.Gt2.lt, _ctx);
    kk_box_dup(_x._cons.Gt2.gt, _ctx);
  }
  return _x;
}
static inline void kk_std_core_types__order2_drop(kk_std_core_types__order2 _x, kk_context_t* _ctx) {
  if (kk_std_core_types__is_Eq2(_x, _ctx)) { kk_box_drop(_x._cons.Eq2.eq, _ctx); }
  else if (kk_std_core_types__is_Lt2(_x, _ctx)) {
    kk_box_drop(_x._cons.Lt2.lt, _ctx);
    kk_box_drop(_x._cons.Lt2.gt, _ctx);
  }
  else {
    kk_box_drop(_x._cons.Gt2.lt, _ctx);
    kk_box_drop(_x._cons.Gt2.gt, _ctx);
  }
}
static inline kk_box_t kk_std_core_types__order2_box(kk_std_core_types__order2 _x, kk_context_t* _ctx) {
  kk_box_t _box;
  kk_valuetype_box(kk_std_core_types__order2, _box, _x, 3 /* scan count */, _ctx);
  return _box;
}
static inline kk_std_core_types__order2 kk_std_core_types__order2_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  kk_std_core_types__order2 _unbox;
  kk_valuetype_unbox(kk_std_core_types__order2, _unbox, _x, _borrow, _ctx);
  return _unbox;
}

// type std/core/types/read
struct kk_std_core_types__read_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__read;
static inline kk_std_core_types__read kk_std_core_types__read_dup(kk_std_core_types__read _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__read_drop(kk_std_core_types__read _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__read_box(kk_std_core_types__read _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__read kk_std_core_types__read_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/ref
struct kk_std_core_types__ref_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__ref;
static inline kk_std_core_types__ref kk_std_core_types__ref_dup(kk_std_core_types__ref _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__ref_drop(kk_std_core_types__ref _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__ref_box(kk_std_core_types__ref _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__ref kk_std_core_types__ref_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value type std/core/types/ssize_t
enum kk_std_core_types__ssize__t_e {
  kk_std_core_types_ssize__t_empty
};
typedef uint64_t kk_std_core_types__ssize__t;

static inline kk_std_core_types__ssize__t kk_std_core_types__ssize__t_dup(kk_std_core_types__ssize__t _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__ssize__t_drop(kk_std_core_types__ssize__t _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__ssize__t_box(kk_std_core_types__ssize__t _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__ssize__t kk_std_core_types__ssize__t_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__ssize__t)kk_enum_unbox(_x);
}

// type std/core/types/total
struct kk_std_core_types__total_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__total;
static inline kk_std_core_types__total kk_std_core_types__total_dup(kk_std_core_types__total _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__total_drop(kk_std_core_types__total _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__total_box(kk_std_core_types__total _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__total kk_std_core_types__total_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/write
struct kk_std_core_types__write_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__write;
static inline kk_std_core_types__write kk_std_core_types__write_dup(kk_std_core_types__write _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__write_drop(kk_std_core_types__write _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__write_box(kk_std_core_types__write _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__write kk_std_core_types__write_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/string
struct kk_std_core_types__string_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__string;
static inline kk_std_core_types__string kk_std_core_types__string_dup(kk_std_core_types__string _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__string_drop(kk_std_core_types__string _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__string_box(kk_std_core_types__string _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__string kk_std_core_types__string_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value type std/core/types/tuple2
struct kk_std_core_types_Tuple2 {
  kk_box_t fst;
  kk_box_t snd;
};
typedef struct kk_std_core_types_Tuple2 kk_std_core_types__tuple2;
static inline kk_std_core_types__tuple2 kk_std_core_types__new_Tuple2(kk_box_t fst, kk_box_t snd, kk_context_t* _ctx) {
  kk_std_core_types__tuple2 _con;
  _con.fst = fst;
  _con.snd = snd;
  return _con;
}
static inline bool kk_std_core_types__is_Tuple2(kk_std_core_types__tuple2 x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core_types__tuple2 kk_std_core_types__tuple2_dup(kk_std_core_types__tuple2 _x, kk_context_t* _ctx) {
  kk_box_dup(_x.fst, _ctx);
  kk_box_dup(_x.snd, _ctx);
  return _x;
}
static inline void kk_std_core_types__tuple2_drop(kk_std_core_types__tuple2 _x, kk_context_t* _ctx) {
  kk_box_drop(_x.fst, _ctx);
  kk_box_drop(_x.snd, _ctx);
}
static inline kk_box_t kk_std_core_types__tuple2_box(kk_std_core_types__tuple2 _x, kk_context_t* _ctx) {
  kk_box_t _box;
  kk_valuetype_box(kk_std_core_types__tuple2, _box, _x, 2 /* scan count */, _ctx);
  return _box;
}
static inline kk_std_core_types__tuple2 kk_std_core_types__tuple2_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  kk_std_core_types__tuple2 _unbox;
  kk_valuetype_unbox(kk_std_core_types__tuple2, _unbox, _x, _borrow, _ctx);
  return _unbox;
}

// value type std/core/types/tuple3
struct kk_std_core_types_Tuple3 {
  kk_box_t fst;
  kk_box_t snd;
  kk_box_t thd;
};
typedef struct kk_std_core_types_Tuple3 kk_std_core_types__tuple3;
static inline kk_std_core_types__tuple3 kk_std_core_types__new_Tuple3(kk_box_t fst, kk_box_t snd, kk_box_t thd, kk_context_t* _ctx) {
  kk_std_core_types__tuple3 _con;
  _con.fst = fst;
  _con.snd = snd;
  _con.thd = thd;
  return _con;
}
static inline bool kk_std_core_types__is_Tuple3(kk_std_core_types__tuple3 x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core_types__tuple3 kk_std_core_types__tuple3_dup(kk_std_core_types__tuple3 _x, kk_context_t* _ctx) {
  kk_box_dup(_x.fst, _ctx);
  kk_box_dup(_x.snd, _ctx);
  kk_box_dup(_x.thd, _ctx);
  return _x;
}
static inline void kk_std_core_types__tuple3_drop(kk_std_core_types__tuple3 _x, kk_context_t* _ctx) {
  kk_box_drop(_x.fst, _ctx);
  kk_box_drop(_x.snd, _ctx);
  kk_box_drop(_x.thd, _ctx);
}
static inline kk_box_t kk_std_core_types__tuple3_box(kk_std_core_types__tuple3 _x, kk_context_t* _ctx) {
  kk_box_t _box;
  kk_valuetype_box(kk_std_core_types__tuple3, _box, _x, 3 /* scan count */, _ctx);
  return _box;
}
static inline kk_std_core_types__tuple3 kk_std_core_types__tuple3_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  kk_std_core_types__tuple3 _unbox;
  kk_valuetype_unbox(kk_std_core_types__tuple3, _unbox, _x, _borrow, _ctx);
  return _unbox;
}

// type std/core/types/tuple4
struct kk_std_core_types__tuple4_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_std_core_types__tuple4;
struct kk_std_core_types_Tuple4 {
  struct kk_std_core_types__tuple4_s _base;
  kk_box_t fst;
  kk_box_t snd;
  kk_box_t thd;
  kk_box_t field4;
};
static inline kk_std_core_types__tuple4 kk_std_core_types__base_Tuple4(struct kk_std_core_types_Tuple4* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_std_core_types__tuple4 kk_std_core_types__new_Tuple4(kk_reuse_t _at, int32_t _cpath, kk_box_t fst, kk_box_t snd, kk_box_t thd, kk_box_t field4, kk_context_t* _ctx) {
  struct kk_std_core_types_Tuple4* _con = kk_block_alloc_at_as(struct kk_std_core_types_Tuple4, _at, 4 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->fst = fst;
  _con->snd = snd;
  _con->thd = thd;
  _con->field4 = field4;
  return kk_std_core_types__base_Tuple4(_con, _ctx);
}
static inline struct kk_std_core_types_Tuple4* kk_std_core_types__as_Tuple4(kk_std_core_types__tuple4 x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_types_Tuple4*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_std_core_types__is_Tuple4(kk_std_core_types__tuple4 x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core_types__tuple4 kk_std_core_types__tuple4_dup(kk_std_core_types__tuple4 _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_std_core_types__tuple4_drop(kk_std_core_types__tuple4 _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_std_core_types__tuple4_box(kk_std_core_types__tuple4 _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_std_core_types__tuple4 kk_std_core_types__tuple4_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// type std/core/types/tuple5
struct kk_std_core_types__tuple5_s {
  kk_block_t _block;
};
typedef kk_datatype_ptr_t kk_std_core_types__tuple5;
struct kk_std_core_types_Tuple5 {
  struct kk_std_core_types__tuple5_s _base;
  kk_box_t fst;
  kk_box_t snd;
  kk_box_t thd;
  kk_box_t field4;
  kk_box_t field5;
};
static inline kk_std_core_types__tuple5 kk_std_core_types__base_Tuple5(struct kk_std_core_types_Tuple5* _x, kk_context_t* _ctx) {
  return kk_datatype_from_base(&_x->_base, _ctx);
}
static inline kk_std_core_types__tuple5 kk_std_core_types__new_Tuple5(kk_reuse_t _at, int32_t _cpath, kk_box_t fst, kk_box_t snd, kk_box_t thd, kk_box_t field4, kk_box_t field5, kk_context_t* _ctx) {
  struct kk_std_core_types_Tuple5* _con = kk_block_alloc_at_as(struct kk_std_core_types_Tuple5, _at, 5 /* scan count */, _cpath, (kk_tag_t)(1), _ctx);
  _con->fst = fst;
  _con->snd = snd;
  _con->thd = thd;
  _con->field4 = field4;
  _con->field5 = field5;
  return kk_std_core_types__base_Tuple5(_con, _ctx);
}
static inline struct kk_std_core_types_Tuple5* kk_std_core_types__as_Tuple5(kk_std_core_types__tuple5 x, kk_context_t* _ctx) {
  return kk_datatype_as_assert(struct kk_std_core_types_Tuple5*, x, (kk_tag_t)(1), _ctx);
}
static inline bool kk_std_core_types__is_Tuple5(kk_std_core_types__tuple5 x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_core_types__tuple5 kk_std_core_types__tuple5_dup(kk_std_core_types__tuple5 _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_dup(_x, _ctx);
}
static inline void kk_std_core_types__tuple5_drop(kk_std_core_types__tuple5 _x, kk_context_t* _ctx) {
  kk_datatype_ptr_drop(_x, _ctx);
}
static inline kk_box_t kk_std_core_types__tuple5_box(kk_std_core_types__tuple5 _x, kk_context_t* _ctx) {
  return kk_datatype_ptr_box(_x);
}
static inline kk_std_core_types__tuple5 kk_std_core_types__tuple5_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_ptr_unbox(_x);
}

// value type std/core/types/unit
enum kk_std_core_types__unit_e {
  kk_std_core_types_Unit
};
typedef uint8_t kk_std_core_types__unit;

static inline kk_std_core_types__unit kk_std_core_types__new_Unit(kk_context_t* _ctx) {
  return kk_std_core_types_Unit;
}
static inline bool kk_std_core_types__is_Unit(kk_std_core_types__unit x, kk_context_t* _ctx) {
  return (x == kk_std_core_types_Unit);
}
static inline kk_std_core_types__unit kk_std_core_types__unit_dup(kk_std_core_types__unit _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__unit_drop(kk_std_core_types__unit _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__unit_box(kk_std_core_types__unit _x, kk_context_t* _ctx) {
  return kk_enum_box(_x);
}
static inline kk_std_core_types__unit kk_std_core_types__unit_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return (kk_std_core_types__unit)kk_enum_unbox(_x);
}

// type std/core/types/vector
struct kk_std_core_types__vector_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__vector;
static inline kk_std_core_types__vector kk_std_core_types__vector_dup(kk_std_core_types__vector _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__vector_drop(kk_std_core_types__vector _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__vector_box(kk_std_core_types__vector _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__vector kk_std_core_types__vector_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// type std/core/types/void
struct kk_std_core_types__void_s {
  kk_block_t _block;
};
typedef kk_datatype_t kk_std_core_types__void;
static inline kk_std_core_types__void kk_std_core_types__void_dup(kk_std_core_types__void _x, kk_context_t* _ctx) {
  return _x;
}
static inline void kk_std_core_types__void_drop(kk_std_core_types__void _x, kk_context_t* _ctx) {
  
}
static inline kk_box_t kk_std_core_types__void_box(kk_std_core_types__void _x, kk_context_t* _ctx) {
  return kk_datatype_box(_x);
}
static inline kk_std_core_types__void kk_std_core_types__void_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  return kk_datatype_unbox(_x);
}

// value declarations
 
// Automatically generated. Tests for the `False` constructor of the `:bool` type.

static inline bool kk_std_core_types_is_false(bool kkloc_bool, kk_context_t* _ctx) { /* (bool : bool) -> bool */ 
  if (!(kkloc_bool)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `True` constructor of the `:bool` type.

static inline bool kk_std_core_types_is_true(bool kkloc_bool, kk_context_t* _ctx) { /* (bool : bool) -> bool */ 
  if (kkloc_bool) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Retrieves the `unbox` constructor field of the `:box` type.

static inline kk_box_t kk_std_core_types_box_fs_unbox(kk_std_core_types__box box, kk_context_t* _ctx) { /* forall<a> (box : box<a>) -> a */ 
  {
    kk_box_t _x = box.unbox;
    return kk_box_dup(_x, _ctx);
  }
}

kk_std_core_types__box kk_std_core_types_box_fs__copy(kk_std_core_types__box _this, kk_std_core_types__optional unbox, kk_context_t* _ctx); /* forall<a> (box<a>, unbox : ? a) -> box<a> */ 
 
// Automatically generated. Retrieves the `res` constructor field of the `:cctx` type.

static inline kk_box_t kk_std_core_types_cctx_fs_res(kk_std_core_types__cctx cctx, kk_context_t* _ctx) { /* forall<a,b> (cctx : cctx<a,b>) -> a */ 
  {
    kk_box_t _x = cctx.res;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `holeptr` constructor field of the `:cctx` type.

static inline kk_field_addr_t kk_std_core_types_cctx_fs_holeptr(kk_std_core_types__cctx cctx, kk_context_t* _ctx) { /* forall<a,b> (cctx : cctx<a,b>) -> @field-addr<b> */ 
  {
    kk_field_addr_t _x = cctx.holeptr;
    return kk_skip_dup(_x, _ctx);
  }
}
 
// Automatically generated. Tests for the `Left` constructor of the `:either` type.

static inline bool kk_std_core_types_is_left(kk_std_core_types__either either, kk_context_t* _ctx) { /* forall<a,b> (either : either<a,b>) -> bool */ 
  if (kk_std_core_types__is_Left(either, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Right` constructor of the `:either` type.

static inline bool kk_std_core_types_is_right(kk_std_core_types__either either, kk_context_t* _ctx) { /* forall<a,b> (either : either<a,b>) -> bool */ 
  if (kk_std_core_types__is_Right(either, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Nil` constructor of the `:list` type.

static inline bool kk_std_core_types_is_nil(kk_std_core_types__list list, kk_context_t* _ctx) { /* forall<a> (list : list<a>) -> bool */ 
  if (kk_std_core_types__is_Nil(list, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Cons` constructor of the `:list` type.

static inline bool kk_std_core_types_is_cons(kk_std_core_types__list list, kk_context_t* _ctx) { /* forall<a> (list : list<a>) -> bool */ 
  if (kk_std_core_types__is_Cons(list, _ctx)) {
    struct kk_std_core_types_Cons* _con_x3 = kk_std_core_types__as_Cons(list, _ctx);
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Nothing` constructor of the `:maybe` type.

static inline bool kk_std_core_types_is_nothing(kk_std_core_types__maybe maybe, kk_context_t* _ctx) { /* forall<a> (maybe : maybe<a>) -> bool */ 
  if (kk_std_core_types__is_Nothing(maybe, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Just` constructor of the `:maybe` type.

static inline bool kk_std_core_types_is_just(kk_std_core_types__maybe maybe, kk_context_t* _ctx) { /* forall<a> (maybe : maybe<a>) -> bool */ 
  if (kk_std_core_types__is_Just(maybe, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Lt` constructor of the `:order` type.

static inline bool kk_std_core_types_is_lt(kk_std_core_types__order order, kk_context_t* _ctx) { /* (order : order) -> bool */ 
  if (kk_std_core_types__is_Lt(order, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Eq` constructor of the `:order` type.

static inline bool kk_std_core_types_is_eq(kk_std_core_types__order order, kk_context_t* _ctx) { /* (order : order) -> bool */ 
  if (kk_std_core_types__is_Eq(order, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Gt` constructor of the `:order` type.

static inline bool kk_std_core_types_is_gt(kk_std_core_types__order order, kk_context_t* _ctx) { /* (order : order) -> bool */ 
  if (kk_std_core_types__is_Gt(order, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Lt2` constructor of the `:order2` type.

static inline bool kk_std_core_types_is_lt2(kk_std_core_types__order2 order2, kk_context_t* _ctx) { /* forall<a> (order2 : order2<a>) -> bool */ 
  if (kk_std_core_types__is_Lt2(order2, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Eq2` constructor of the `:order2` type.

static inline bool kk_std_core_types_is_eq2(kk_std_core_types__order2 order2, kk_context_t* _ctx) { /* forall<a> (order2 : order2<a>) -> bool */ 
  if (kk_std_core_types__is_Eq2(order2, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Tests for the `Gt2` constructor of the `:order2` type.

static inline bool kk_std_core_types_is_gt2(kk_std_core_types__order2 order2, kk_context_t* _ctx) { /* forall<a> (order2 : order2<a>) -> bool */ 
  if (kk_std_core_types__is_Gt2(order2, _ctx)) {
    return true;
  }
  {
    return false;
  }
}
 
// Automatically generated. Retrieves the `fst` constructor field of the `:tuple2` type.

static inline kk_box_t kk_std_core_types_tuple2_fs_fst(kk_std_core_types__tuple2 tuple2, kk_context_t* _ctx) { /* forall<a,b> (tuple2 : (a, b)) -> a */ 
  {
    kk_box_t _x = tuple2.fst;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `snd` constructor field of the `:tuple2` type.

static inline kk_box_t kk_std_core_types_tuple2_fs_snd(kk_std_core_types__tuple2 tuple2, kk_context_t* _ctx) { /* forall<a,b> (tuple2 : (a, b)) -> b */ 
  {
    kk_box_t _x = tuple2.snd;
    return kk_box_dup(_x, _ctx);
  }
}

kk_std_core_types__tuple2 kk_std_core_types_tuple2_fs__copy(kk_std_core_types__tuple2 _this, kk_std_core_types__optional fst, kk_std_core_types__optional snd, kk_context_t* _ctx); /* forall<a,b> ((a, b), fst : ? a, snd : ? b) -> (a, b) */ 
 
// Automatically generated. Retrieves the `fst` constructor field of the `:tuple3` type.

static inline kk_box_t kk_std_core_types_tuple3_fs_fst(kk_std_core_types__tuple3 tuple3, kk_context_t* _ctx) { /* forall<a,b,c> (tuple3 : (a, b, c)) -> a */ 
  {
    kk_box_t _x = tuple3.fst;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `snd` constructor field of the `:tuple3` type.

static inline kk_box_t kk_std_core_types_tuple3_fs_snd(kk_std_core_types__tuple3 tuple3, kk_context_t* _ctx) { /* forall<a,b,c> (tuple3 : (a, b, c)) -> b */ 
  {
    kk_box_t _x = tuple3.snd;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `thd` constructor field of the `:tuple3` type.

static inline kk_box_t kk_std_core_types_tuple3_fs_thd(kk_std_core_types__tuple3 tuple3, kk_context_t* _ctx) { /* forall<a,b,c> (tuple3 : (a, b, c)) -> c */ 
  {
    kk_box_t _x = tuple3.thd;
    return kk_box_dup(_x, _ctx);
  }
}

kk_std_core_types__tuple3 kk_std_core_types_tuple3_fs__copy(kk_std_core_types__tuple3 _this, kk_std_core_types__optional fst, kk_std_core_types__optional snd, kk_std_core_types__optional thd, kk_context_t* _ctx); /* forall<a,b,c> ((a, b, c), fst : ? a, snd : ? b, thd : ? c) -> (a, b, c) */ 
 
// Automatically generated. Retrieves the `fst` constructor field of the `:tuple4` type.

static inline kk_box_t kk_std_core_types_tuple4_fs_fst(kk_std_core_types__tuple4 tuple4, kk_context_t* _ctx) { /* forall<a,b,c,d> (tuple4 : (a, b, c, d)) -> a */ 
  {
    struct kk_std_core_types_Tuple4* _con_x9 = kk_std_core_types__as_Tuple4(tuple4, _ctx);
    kk_box_t _x = _con_x9->fst;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `snd` constructor field of the `:tuple4` type.

static inline kk_box_t kk_std_core_types_tuple4_fs_snd(kk_std_core_types__tuple4 tuple4, kk_context_t* _ctx) { /* forall<a,b,c,d> (tuple4 : (a, b, c, d)) -> b */ 
  {
    struct kk_std_core_types_Tuple4* _con_x10 = kk_std_core_types__as_Tuple4(tuple4, _ctx);
    kk_box_t _x = _con_x10->snd;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `thd` constructor field of the `:tuple4` type.

static inline kk_box_t kk_std_core_types_tuple4_fs_thd(kk_std_core_types__tuple4 tuple4, kk_context_t* _ctx) { /* forall<a,b,c,d> (tuple4 : (a, b, c, d)) -> c */ 
  {
    struct kk_std_core_types_Tuple4* _con_x11 = kk_std_core_types__as_Tuple4(tuple4, _ctx);
    kk_box_t _x = _con_x11->thd;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `field4` constructor field of the `:tuple4` type.

static inline kk_box_t kk_std_core_types_tuple4_fs_field4(kk_std_core_types__tuple4 tuple4, kk_context_t* _ctx) { /* forall<a,b,c,d> (tuple4 : (a, b, c, d)) -> d */ 
  {
    struct kk_std_core_types_Tuple4* _con_x12 = kk_std_core_types__as_Tuple4(tuple4, _ctx);
    kk_box_t _x = _con_x12->field4;
    return kk_box_dup(_x, _ctx);
  }
}

kk_std_core_types__tuple4 kk_std_core_types_tuple4_fs__copy(kk_std_core_types__tuple4 _this, kk_std_core_types__optional fst, kk_std_core_types__optional snd, kk_std_core_types__optional thd, kk_std_core_types__optional field4, kk_context_t* _ctx); /* forall<a,b,c,d> ((a, b, c, d), fst : ? a, snd : ? b, thd : ? c, field4 : ? d) -> (a, b, c, d) */ 
 
// Automatically generated. Retrieves the `fst` constructor field of the `:tuple5` type.

static inline kk_box_t kk_std_core_types_tuple5_fs_fst(kk_std_core_types__tuple5 tuple5, kk_context_t* _ctx) { /* forall<a,b,c,d,a1> (tuple5 : (a, b, c, d, a1)) -> a */ 
  {
    struct kk_std_core_types_Tuple5* _con_x21 = kk_std_core_types__as_Tuple5(tuple5, _ctx);
    kk_box_t _x = _con_x21->fst;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `snd` constructor field of the `:tuple5` type.

static inline kk_box_t kk_std_core_types_tuple5_fs_snd(kk_std_core_types__tuple5 tuple5, kk_context_t* _ctx) { /* forall<a,b,c,d,a1> (tuple5 : (a, b, c, d, a1)) -> b */ 
  {
    struct kk_std_core_types_Tuple5* _con_x22 = kk_std_core_types__as_Tuple5(tuple5, _ctx);
    kk_box_t _x = _con_x22->snd;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `thd` constructor field of the `:tuple5` type.

static inline kk_box_t kk_std_core_types_tuple5_fs_thd(kk_std_core_types__tuple5 tuple5, kk_context_t* _ctx) { /* forall<a,b,c,d,a1> (tuple5 : (a, b, c, d, a1)) -> c */ 
  {
    struct kk_std_core_types_Tuple5* _con_x23 = kk_std_core_types__as_Tuple5(tuple5, _ctx);
    kk_box_t _x = _con_x23->thd;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `field4` constructor field of the `:tuple5` type.

static inline kk_box_t kk_std_core_types_tuple5_fs_field4(kk_std_core_types__tuple5 tuple5, kk_context_t* _ctx) { /* forall<a,b,c,d,a1> (tuple5 : (a, b, c, d, a1)) -> d */ 
  {
    struct kk_std_core_types_Tuple5* _con_x24 = kk_std_core_types__as_Tuple5(tuple5, _ctx);
    kk_box_t _x = _con_x24->field4;
    return kk_box_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `field5` constructor field of the `:tuple5` type.

static inline kk_box_t kk_std_core_types_tuple5_fs_field5(kk_std_core_types__tuple5 tuple5, kk_context_t* _ctx) { /* forall<a,b,c,d,a1> (tuple5 : (a, b, c, d, a1)) -> a1 */ 
  {
    struct kk_std_core_types_Tuple5* _con_x25 = kk_std_core_types__as_Tuple5(tuple5, _ctx);
    kk_box_t _x = _con_x25->field5;
    return kk_box_dup(_x, _ctx);
  }
}

kk_std_core_types__tuple5 kk_std_core_types_tuple5_fs__copy(kk_std_core_types__tuple5 _this, kk_std_core_types__optional fst, kk_std_core_types__optional snd, kk_std_core_types__optional thd, kk_std_core_types__optional field4, kk_std_core_types__optional field5, kk_context_t* _ctx); /* forall<a,b,c,d,a1> ((a, b, c, d, a1), fst : ? a, snd : ? b, thd : ? c, field4 : ? d, field5 : ? a1) -> (a, b, c, d, a1) */ 

static inline kk_unit_t kk_std_core_types_unit_fs__copy(kk_unit_t _this, kk_context_t* _ctx) { /* (()) -> () */ 
  kk_Unit; return kk_Unit;
}

kk_field_addr_t kk_std_core_types__field_addr_of(kk_box_t x, kk_string_t conname, kk_string_t fieldname, kk_context_t* _ctx); /* forall<a> (x : a, conname : string, fieldname : string) -> @field-addr<a> */ 

kk_ssize_t kk_std_core_types__make_ssize__t(kk_integer_t i, kk_context_t* _ctx); /* (i : int) -> ssize_t */ 

kk_reuse_t kk_std_core_types__no_reuse(kk_context_t* _ctx); /* () -> @reuse */ 

kk_box_t kk_std_core_types__open(kk_box_t x, kk_context_t* _ctx); /* forall<e,e1,a,b> (x : a) -> e1 b */ 
 
// Logical conjunction. This is compiled specially avoid evaluating the second argument if `x==False`.

static inline bool kk_std_core_types__lp__amp__amp__rp_(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> bool */ 
  if (x) {
    return y;
  }
  {
    return false;
  }
}

kk_string_t kk_std_core_types__lp__plus__plus__rp_(kk_string_t x, kk_string_t y, kk_context_t* _ctx); /* (x : string, y : string) -> string */ 
 
// The identity function returns its argument unchanged

static inline kk_box_t kk_std_core_types_id(kk_box_t x, kk_context_t* _ctx) { /* forall<a> (x : a) -> a */ 
  return x;
}

kk_box_t kk_std_core_types_keep(kk_box_t x, kk_context_t* _ctx); /* forall<a> (x : a) -> a */ 
 
// _Internal_: if local mutation is unobservable, the `:local` effect can be erased by using the `local-scope` function.
// See also: _State in Haskell, by Simon Peyton Jones and John Launchbury_.

static inline kk_box_t kk_std_core_types_local_scope(kk_function_t action, kk_context_t* _ctx) { /* forall<a,e> (action : forall<h> () -> <local<h>|e> a) -> e a */ 
  return kk_function_call(kk_box_t, (kk_function_t, kk_context_t*), action, (action, _ctx), _ctx);
}
 
// Logical negation

static inline bool kk_std_core_types_not(bool b, kk_context_t* _ctx) { /* (b : bool) -> bool */ 
  if (b) {
    return false;
  }
  {
    return true;
  }
}

kk_box_t kk_std_core_types_run(kk_function_t action, kk_context_t* _ctx); /* forall<e,a> (action : forall<h> () -> <alloc<h>,read<h>,write<h>|e> a) -> e a */ 
 
// Logical disjunction. This is compiled specially avoid evaluating the second argument if `x==True`.

static inline bool kk_std_core_types__lp__bar__bar__rp_(bool x, bool y, kk_context_t* _ctx) { /* (x : bool, y : bool) -> bool */ 
  if (x) {
    return true;
  }
  {
    return y;
  }
}
 
// Logical negation

static inline bool kk_std_core_types_bool_fs__lp__excl__rp_(bool b, kk_context_t* _ctx) { /* (b : bool) -> bool */ 
  if (b) {
    return false;
  }
  {
    return true;
  }
}

void kk_std_core_types__init(kk_context_t* _ctx);


void kk_std_core_types__done(kk_context_t* _ctx);

/*---------------------------------------------------------------------------
  Copyright 2020-2023, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/
static inline kk_field_addr_t kk_field_addr_create(void* p, kk_context_t* ctx) {
  return kk_internal_ptr_box((kk_box_t*)p, ctx);
}

static inline kk_box_t* kk_field_addr_ptr(kk_field_addr_t faddr, kk_context_t* ctx) {
  return kk_internal_ptr_unbox(faddr, ctx);
}

static inline kk_decl_const kk_field_addr_t kk_field_addr_null(void) {
  return kk_box_null();
}

static inline kk_decl_const kk_box_t kk_cctx_hole(void) {
  return kk_box_null();  // for now, this must be a value; see `kklib/src/refcount.c:kk_cctx_copy_apply`
}

static inline kk_decl_const kk_std_core_types__cctx kk_cctx_empty(kk_context_t* ctx) {
  return kk_std_core_types__new_Cctx( kk_cctx_hole(), kk_field_addr_null(), ctx);
}

static inline kk_std_core_types__cctx kk_cctx_create( kk_box_t res, kk_field_addr_t field, kk_context_t* ctx) {
  return kk_std_core_types__new_Cctx( res, field, ctx);
}

static inline kk_decl_const bool kk_cctx_is_empty( kk_std_core_types__cctx cctx ) {
  return kk_box_eq(cctx.holeptr,kk_field_addr_null()); // kk_box_is_value(cctx.res);
}

static inline kk_decl_const bool kk_cctx_is_valid( kk_std_core_types__cctx cctx ) {
  return !kk_cctx_is_empty(cctx); // kk_box_is_ptr(cctx.res);
}

// apply a context
static inline kk_box_t kk_cctx_apply( kk_std_core_types__cctx acc, kk_box_t child, kk_context_t* ctx ) {
  // note: written like this for best codegen; be careful when rewriting.
  if kk_unlikely(kk_cctx_is_empty(acc)) {
    return child;
  }
  else if kk_likely(kk_block_is_unique(kk_ptr_unbox(acc.res,ctx))) {
    *kk_field_addr_ptr(acc.holeptr,ctx) = child;   // in-place update the hole with the child
    return acc.res;
  }
  #if !defined(KK_CCTX_NO_CONTEXT_PATH)
  else {
    kk_assert_internal(!kk_block_is_unique(kk_ptr_unbox(acc.res,ctx)));
    return kk_cctx_copy_apply(acc.res,kk_field_addr_ptr(acc.holeptr,ctx),child,ctx);  // copy the context path to the hole and compose with the child
  }
  #endif
}

// apply linear, acc will be unique
// calls to kk_cctx_apply_linear are generated by the compiler during TRMC in affine contexts.
static inline kk_box_t kk_cctx_apply_linear( kk_std_core_types__cctx acc, kk_box_t child, kk_context_t* ctx ) {
  #if 1
  if kk_likely(!kk_cctx_is_empty(acc)) {
    kk_assert_internal(kk_block_is_unique(kk_ptr_unbox(acc.res,kk_get_context())));
    *kk_field_addr_ptr(acc.holeptr,ctx) = child;
    return acc.res;
  }
  else {
    return child;
  }
  #else
  // this form entices conditional moves (but seems slower in general)
  if (kk_cctx_is_valid(acc)) { *kk_field_addr_ptr(acc.holeptr,ctx) = child; }
  return (kk_cctx_is_valid(acc) ? acc.res : child);
  #endif
}


// extend a context with a guaranteed non-empty context
static inline kk_std_core_types__cctx kk_cctx_extend( kk_std_core_types__cctx acc, kk_box_t child, kk_field_addr_t field, kk_context_t* ctx  ) {
  return kk_std_core_types__new_Cctx( kk_cctx_apply(acc,child,ctx), field, ctx );
}

// extend a context with a guaranteed non-empty context, and where acc will be unique
// calls to kk_cctx_extend_linear are generated by the compiler during TRMC in affine contexts.
static inline kk_std_core_types__cctx kk_cctx_extend_linear( kk_std_core_types__cctx acc, kk_box_t child, kk_field_addr_t field, kk_context_t* ctx  ) {
  return kk_std_core_types__new_Cctx( kk_cctx_apply_linear(acc,child,ctx), field, ctx );
}

// defined as non-inline for better fast-path
kk_std_core_types__cctx kk_cctx_compose_shared( kk_std_core_types__cctx acc1, kk_std_core_types__cctx acc2, kk_context_t* ctx  );

// compose a context
static inline kk_std_core_types__cctx kk_cctx_compose( kk_std_core_types__cctx acc1, kk_std_core_types__cctx acc2, kk_context_t* ctx  ) {
  if kk_unlikely(kk_cctx_is_empty(acc2)) {
    return acc1;
  }
  else if kk_likely(kk_block_is_unique(kk_ptr_unbox(acc2.res,ctx))) {
    return kk_cctx_extend(acc1,acc2.res,acc2.holeptr,ctx);
  }
  else {
    return kk_cctx_compose_shared(acc1,acc2,ctx);
  }
}

// acc1 & acc2 will be unique
static inline kk_std_core_types__cctx kk_cctx_compose_linear( kk_std_core_types__cctx acc1, kk_std_core_types__cctx acc2, kk_context_t* ctx  ) {
  if kk_unlikely(kk_cctx_is_empty(acc2)) {
    return acc1;
  }
  kk_assert_internal(kk_block_is_unique(kk_ptr_unbox(acc2.res,ctx)));
  return kk_cctx_extend_linear(acc1,acc2.res,acc2.holeptr,ctx);
}

#endif // header
