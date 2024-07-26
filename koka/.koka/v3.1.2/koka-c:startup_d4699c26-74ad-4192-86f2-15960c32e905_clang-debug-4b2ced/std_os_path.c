// Koka generated module: std/os/path, koka version: 3.1.2, platform: 64-bit
#include "std_os_path.h"

kk_std_os_path__path kk_std_os_path_path_fs__copy(kk_std_os_path__path _this, kk_std_core_types__optional root, kk_std_core_types__optional parts, kk_context_t* _ctx) { /* (path, root : ? string, parts : ? (list<string>)) -> path */ 
  kk_string_t _x_x509;
  if (kk_std_core_types__is_Optional(root, _ctx)) {
    kk_box_t _box_x0 = root._cons._Optional.value;
    kk_string_t _uniq_root_108 = kk_string_unbox(_box_x0);
    kk_string_dup(_uniq_root_108, _ctx);
    kk_std_core_types__optional_drop(root, _ctx);
    _x_x509 = _uniq_root_108; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(root, _ctx);
    {
      kk_string_t _x = _this.root;
      kk_string_dup(_x, _ctx);
      _x_x509 = _x; /*string*/
    }
  }
  kk_std_core_types__list _x_x510;
  if (kk_std_core_types__is_Optional(parts, _ctx)) {
    kk_box_t _box_x1 = parts._cons._Optional.value;
    kk_std_core_types__list _uniq_parts_115 = kk_std_core_types__list_unbox(_box_x1, KK_BORROWED, _ctx);
    kk_std_core_types__list_dup(_uniq_parts_115, _ctx);
    kk_std_core_types__optional_drop(parts, _ctx);
    kk_std_os_path__path_drop(_this, _ctx);
    _x_x510 = _uniq_parts_115; /*list<string>*/
  }
  else {
    kk_std_core_types__optional_drop(parts, _ctx);
    {
      kk_std_core_types__list _x_0 = _this.parts;
      kk_std_core_types__list_dup(_x_0, _ctx);
      kk_std_os_path__path_drop(_this, _ctx);
      _x_x510 = _x_0; /*list<string>*/
    }
  }
  return kk_std_os_path__new_Path(_x_x509, _x_x510, _ctx);
}

kk_string_t kk_std_os_path_xapp_path(kk_context_t* _ctx) { /* () -> io string */ 
  return kk_os_app_path(kk_context());
}
 
// Return the base name of a path (stem name + extension)
// `"/foo/bar.txt".path.basename === "bar.txt"`
// `"/foo".path.basename === "foo"`

kk_string_t kk_std_os_path_basename(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> string */ 
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x511 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x2 = _con_x511->head;
      kk_std_core_types__list _pat_0_0 = _con_x511->tail;
      kk_string_t x_0 = kk_string_unbox(_box_x2);
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_string_dup(x_0, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      return x_0;
    }
    {
      return kk_string_empty();
    }
  }
}
 
// Remove the basename and only keep the root and directory name portion of the path.
// `nobase("foo/bar.ext".path) == "foo")`

kk_std_os_path__path kk_std_os_path_nobase(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> path */ 
  kk_string_t _x_x513;
  kk_std_core_types__optional _match_x470 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
  if (kk_std_core_types__is_Optional(_match_x470, _ctx)) {
    kk_box_t _box_x4 = _match_x470._cons._Optional.value;
    kk_string_t _uniq_root_108 = kk_string_unbox(_box_x4);
    kk_string_dup(_uniq_root_108, _ctx);
    kk_std_core_types__optional_drop(_match_x470, _ctx);
    _x_x513 = _uniq_root_108; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x470, _ctx);
    {
      kk_string_t _x_0 = p.root;
      kk_string_dup(_x_0, _ctx);
      _x_x513 = _x_0; /*string*/
    }
  }
  kk_std_core_types__list _x_x514;
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x515 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x5 = _con_x515->head;
      kk_std_core_types__list xx = _con_x515->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_box_drop(_box_x5, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _x_x514 = xx; /*list<string>*/
    }
    else {
      _x_x514 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  return kk_std_os_path__new_Path(_x_x513, _x_x514, _ctx);
}

kk_std_core_types__tuple2 kk_std_os_path_split_parts(kk_std_core_types__list parts, kk_context_t* _ctx) { /* (parts : list<string>) -> (string, list<string>) */ 
  kk_box_t _x_x516;
  kk_string_t _x_x517;
  if (kk_std_core_types__is_Cons(parts, _ctx)) {
    struct kk_std_core_types_Cons* _con_x518 = kk_std_core_types__as_Cons(parts, _ctx);
    kk_box_t _box_x6 = _con_x518->head;
    kk_string_t x_0 = kk_string_unbox(_box_x6);
    kk_string_dup(x_0, _ctx);
    _x_x517 = x_0; /*string*/
  }
  else {
    _x_x517 = kk_string_empty(); /*string*/
  }
  _x_x516 = kk_string_box(_x_x517); /*129*/
  kk_box_t _x_x520;
  kk_std_core_types__list _x_x521;
  if (kk_std_core_types__is_Cons(parts, _ctx)) {
    struct kk_std_core_types_Cons* _con_x522 = kk_std_core_types__as_Cons(parts, _ctx);
    kk_box_t _box_x8 = _con_x522->head;
    kk_std_core_types__list xx = _con_x522->tail;
    if kk_likely(kk_datatype_ptr_is_unique(parts, _ctx)) {
      kk_box_drop(_box_x8, _ctx);
      kk_datatype_ptr_free(parts, _ctx);
    }
    else {
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(parts, _ctx);
    }
    _x_x521 = xx; /*list<string>*/
  }
  else {
    _x_x521 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
  }
  _x_x520 = kk_std_core_types__list_box(_x_x521, _ctx); /*130*/
  return kk_std_core_types__new_Tuple2(_x_x516, _x_x520, _ctx);
}

kk_string_t kk_std_os_path_xrealpath(kk_string_t p, kk_context_t* _ctx) { /* (p : string) -> io string */ 
  return kk_os_realpath(p,kk_context());
}
 
// Return the directory part of a path (including the rootname)
// `"/foo/bar.txt".path.dirname === "/foo"`
// `"/foo".path.dirname === "/"`

kk_string_t kk_std_os_path_dirname(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> string */ 
  kk_std_core_types__list xs_10015;
  kk_std_core_types__list _x_x523;
  {
    kk_std_core_types__list _x_0 = p.parts;
    kk_std_core_types__list_dup(_x_0, _ctx);
    if (kk_std_core_types__is_Cons(_x_0, _ctx)) {
      struct kk_std_core_types_Cons* _con_x524 = kk_std_core_types__as_Cons(_x_0, _ctx);
      kk_box_t _box_x13 = _con_x524->head;
      kk_std_core_types__list xx_0 = _con_x524->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x_0, _ctx)) {
        kk_box_drop(_box_x13, _ctx);
        kk_datatype_ptr_free(_x_0, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx_0, _ctx);
        kk_datatype_ptr_decref(_x_0, _ctx);
      }
      _x_x523 = xx_0; /*list<string>*/
    }
    else {
      _x_x523 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  xs_10015 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), _x_x523, _ctx); /*list<string>*/
  kk_string_t _x_x525;
  {
    kk_string_t _x = p.root;
    kk_string_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    _x_x525 = _x; /*string*/
  }
  kk_string_t _x_x526;
  if (kk_std_core_types__is_Nil(xs_10015, _ctx)) {
    _x_x526 = kk_string_empty(); /*string*/
  }
  else {
    struct kk_std_core_types_Cons* _con_x528 = kk_std_core_types__as_Cons(xs_10015, _ctx);
    kk_box_t _box_x14 = _con_x528->head;
    kk_std_core_types__list xx = _con_x528->tail;
    kk_string_t x = kk_string_unbox(_box_x14);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10015, _ctx)) {
      kk_datatype_ptr_free(xs_10015, _ctx);
    }
    else {
      kk_string_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs_10015, _ctx);
    }
    kk_string_t _x_x529;
    kk_define_string_literal(, _s_x530, 1, "/", _ctx)
    _x_x529 = kk_string_dup(_s_x530, _ctx); /*string*/
    _x_x526 = kk_std_core_list__lift_joinsep_4797(_x_x529, xx, x, _ctx); /*string*/
  }
  return kk_std_core_types__lp__plus__plus__rp_(_x_x525, _x_x526, _ctx);
}

kk_string_t kk_std_os_path_xhomedir(kk_context_t* _ctx) { /* () -> io string */ 
  return kk_os_home_dir(kk_context());
}
 
// Remove the directory and root and only keep the base name (file name) portion of the path.
// `nodir("foo/bar.ext".path) === "bar.ext"`

kk_std_os_path__path kk_std_os_path_nodir(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> path */ 
  kk_std_core_types__list _b_x15_16;
  kk_std_core_types__list _x_x532;
  {
    kk_std_core_types__list _x_1 = p.parts;
    kk_std_core_types__list_dup(_x_1, _ctx);
    _x_x532 = _x_1; /*list<string>*/
  }
  _b_x15_16 = kk_std_core_list_take(_x_x532, kk_integer_from_small(1), _ctx); /*list<string>*/
  kk_string_t _x_x533 = kk_string_empty(); /*string*/
  kk_std_core_types__list _x_x535;
  kk_std_core_types__optional _match_x469 = kk_std_core_types__new_Optional(kk_std_core_types__list_box(_b_x15_16, _ctx), _ctx); /*? 7*/;
  if (kk_std_core_types__is_Optional(_match_x469, _ctx)) {
    kk_box_t _box_x17 = _match_x469._cons._Optional.value;
    kk_std_core_types__list _uniq_parts_115 = kk_std_core_types__list_unbox(_box_x17, KK_BORROWED, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    kk_std_core_types__list_dup(_uniq_parts_115, _ctx);
    kk_std_core_types__optional_drop(_match_x469, _ctx);
    _x_x535 = _uniq_parts_115; /*list<string>*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x469, _ctx);
    {
      kk_std_core_types__list _x_0 = p.parts;
      kk_std_core_types__list_dup(_x_0, _ctx);
      kk_std_os_path__path_drop(p, _ctx);
      _x_x535 = _x_0; /*list<string>*/
    }
  }
  return kk_std_os_path__new_Path(_x_x533, _x_x535, _ctx);
}
 
// Return the last directory component name (or the empty string).
// `"c:/foo/bar/tst.txt".path.parentname === "bar"

kk_string_t kk_std_os_path_parentname(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> string */ 
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    kk_std_core_types__list _match_x468;
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x536 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x18 = _con_x536->head;
      kk_std_core_types__list xx = _con_x536->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_box_drop(_box_x18, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _match_x468 = xx; /*list<string>*/
    }
    else {
      _match_x468 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
    if (kk_std_core_types__is_Cons(_match_x468, _ctx)) {
      struct kk_std_core_types_Cons* _con_x537 = kk_std_core_types__as_Cons(_match_x468, _ctx);
      kk_box_t _box_x19 = _con_x537->head;
      kk_std_core_types__list _pat_0_0 = _con_x537->tail;
      kk_string_t x_0 = kk_string_unbox(_box_x19);
      if kk_likely(kk_datatype_ptr_is_unique(_match_x468, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0, _ctx);
        kk_datatype_ptr_free(_match_x468, _ctx);
      }
      else {
        kk_string_dup(x_0, _ctx);
        kk_datatype_ptr_decref(_match_x468, _ctx);
      }
      return x_0;
    }
    {
      return kk_string_empty();
    }
  }
}
 
// Return the OS specific directory separator (`"/"` or `"\\"`)

kk_string_t kk_std_os_path_partsep(kk_context_t* _ctx) { /* () -> ndet string */ 
  return kk_os_dir_sep(kk_context());
}
 
// Return the OS specific path separator (`';'` or `':'`)

kk_string_t kk_std_os_path_pathsep(kk_context_t* _ctx) { /* () -> ndet string */ 
  return kk_os_path_sep(kk_context());
}

kk_string_t kk_std_os_path_xtempdir(kk_context_t* _ctx) { /* () -> io string */ 
  return kk_os_temp_dir(kk_context());
}
 
// Is a path empty?

bool kk_std_os_path_is_empty(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> bool */ 
  bool _match_x467;
  kk_string_t _x_x539;
  {
    kk_string_t _x = p.root;
    kk_string_dup(_x, _ctx);
    _x_x539 = _x; /*string*/
  }
  kk_string_t _x_x540 = kk_string_empty(); /*string*/
  _match_x467 = kk_string_is_eq(_x_x539,_x_x540,kk_context()); /*bool*/
  if (_match_x467) {
    kk_std_core_types__list _x_0 = p.parts;
    kk_std_core_types__list_dup(_x_0, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    if (kk_std_core_types__is_Nil(_x_0, _ctx)) {
      return true;
    }
    {
      kk_std_core_types__list_drop(_x_0, _ctx);
      return false;
    }
  }
  {
    kk_std_os_path__path_drop(p, _ctx);
    return false;
  }
}
 
// Return the first path if it is not empty, otherwise return the second one.

kk_std_os_path__path kk_std_os_path__lp__bar__bar__rp_(kk_std_os_path__path p1, kk_std_os_path__path p2, kk_context_t* _ctx) { /* (p1 : path, p2 : path) -> path */ 
  bool _match_x466;
  kk_string_t _x_x542;
  {
    kk_string_t _x = p1.root;
    kk_string_dup(_x, _ctx);
    _x_x542 = _x; /*string*/
  }
  kk_string_t _x_x543 = kk_string_empty(); /*string*/
  _match_x466 = kk_string_is_eq(_x_x542,_x_x543,kk_context()); /*bool*/
  if (_match_x466) {
    kk_std_core_types__list _x_0 = p1.parts;
    kk_std_core_types__list_dup(_x_0, _ctx);
    if (kk_std_core_types__is_Nil(_x_0, _ctx)) {
      kk_std_os_path__path_drop(p1, _ctx);
      return p2;
    }
    {
      kk_std_os_path__path_drop(p2, _ctx);
      kk_std_core_types__list_drop(_x_0, _ctx);
      return p1;
    }
  }
  {
    kk_std_os_path__path_drop(p2, _ctx);
    return p1;
  }
}

kk_std_core_types__list kk_std_os_path_push_part(kk_string_t dir, kk_std_core_types__list dirs, kk_context_t* _ctx) { /* (dir : string, dirs : list<string>) -> list<string> */ 
  bool _match_x463;
  kk_string_t _x_x545 = kk_string_dup(dir, _ctx); /*string*/
  kk_string_t _x_x546;
  kk_define_string_literal(, _s_x547, 1, ".", _ctx)
  _x_x546 = kk_string_dup(_s_x547, _ctx); /*string*/
  _match_x463 = kk_string_is_eq(_x_x545,_x_x546,kk_context()); /*bool*/
  if (_match_x463) {
    kk_string_drop(dir, _ctx);
    return dirs;
  }
  {
    bool _match_x464;
    kk_string_t _x_x548 = kk_string_dup(dir, _ctx); /*string*/
    kk_string_t _x_x549 = kk_string_empty(); /*string*/
    _match_x464 = kk_string_is_eq(_x_x548,_x_x549,kk_context()); /*bool*/
    if (_match_x464) {
      kk_string_drop(dir, _ctx);
      return dirs;
    }
    {
      bool _match_x465;
      kk_string_t _x_x551 = kk_string_dup(dir, _ctx); /*string*/
      kk_string_t _x_x552;
      kk_define_string_literal(, _s_x553, 2, "..", _ctx)
      _x_x552 = kk_string_dup(_s_x553, _ctx); /*string*/
      _match_x465 = kk_string_is_eq(_x_x551,_x_x552,kk_context()); /*bool*/
      if (_match_x465) {
        if (kk_std_core_types__is_Cons(dirs, _ctx)) {
          struct kk_std_core_types_Cons* _con_x554 = kk_std_core_types__as_Cons(dirs, _ctx);
          kk_box_t _box_x21 = _con_x554->head;
          kk_string_drop(dir, _ctx);
          if (kk_std_core_types__is_Cons(dirs, _ctx)) {
            struct kk_std_core_types_Cons* _con_x555 = kk_std_core_types__as_Cons(dirs, _ctx);
            kk_box_t _box_x22 = _con_x555->head;
            kk_std_core_types__list xx = _con_x555->tail;
            if kk_likely(kk_datatype_ptr_is_unique(dirs, _ctx)) {
              kk_box_drop(_box_x22, _ctx);
              kk_datatype_ptr_free(dirs, _ctx);
            }
            else {
              kk_std_core_types__list_dup(xx, _ctx);
              kk_datatype_ptr_decref(dirs, _ctx);
            }
            return xx;
          }
          {
            return kk_std_core_types__new_Nil(_ctx);
          }
        }
        {
          return kk_std_core_types__new_Cons(kk_reuse_null, 0, kk_string_box(dir), dirs, _ctx);
        }
      }
      {
        return kk_std_core_types__new_Cons(kk_reuse_null, 0, kk_string_box(dir), dirs, _ctx);
      }
    }
  }
}

kk_std_core_types__list kk_std_os_path_push_parts(kk_std_core_types__list parts, kk_std_core_types__list dirs, kk_context_t* _ctx) { /* (parts : list<string>, dirs : list<string>) -> list<string> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(parts, _ctx)) {
    struct kk_std_core_types_Cons* _con_x556 = kk_std_core_types__as_Cons(parts, _ctx);
    kk_box_t _box_x31 = _con_x556->head;
    kk_std_core_types__list rest = _con_x556->tail;
    kk_string_t part = kk_string_unbox(_box_x31);
    if kk_likely(kk_datatype_ptr_is_unique(parts, _ctx)) {
      kk_datatype_ptr_free(parts, _ctx);
    }
    else {
      kk_string_dup(part, _ctx);
      kk_std_core_types__list_dup(rest, _ctx);
      kk_datatype_ptr_decref(parts, _ctx);
    }
    { // tailcall
      kk_std_core_types__list _x_x557 = kk_std_os_path_push_part(part, dirs, _ctx); /*list<string>*/
      parts = rest;
      dirs = _x_x557;
      goto kk__tailcall;
    }
  }
  {
    return dirs;
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_proot_10191_fun559__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_proot_10191_fun559(kk_function_t _fself, kk_box_t _b_x33, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_proot_10191_fun559(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_proot_10191_fun559, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_proot_10191_fun559(kk_function_t _fself, kk_box_t _b_x33, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x560 = kk_Unit;
  kk_char_t _x_x561 = kk_char_unbox(_b_x33, KK_OWNED, _ctx); /*char*/
  kk_std_os_path__mlift_proot_10190(_x_x561, _ctx);
  return kk_unit_box(_x_x560);
}

kk_unit_t kk_std_os_path__mlift_proot_10191(kk_char_t wild__, kk_context_t* _ctx) { /* (wild_ : char) -> std/text/parse/parse () */ 
  kk_char_t x_10203 = kk_std_text_parse_char(':', _ctx); /*char*/;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x558 = kk_std_core_hnd_yield_extend(kk_std_os_path__new_mlift_proot_10191_fun559(_ctx), _ctx); /*3728*/
    kk_unit_unbox(_x_x558); return kk_Unit;
  }
  {
    kk_Unit; return kk_Unit;
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_proot_10193_fun562__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_proot_10193_fun562(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_proot_10193_fun562(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_proot_10193_fun562, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_proot_10193_fun562(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_char_t _x_x563;
  kk_string_t _x_x564;
  kk_define_string_literal(, _s_x565, 1, "/", _ctx)
  _x_x564 = kk_string_dup(_s_x565, _ctx); /*string*/
  _x_x563 = kk_std_text_parse_none_of(_x_x564, _ctx); /*char*/
  return kk_char_box(_x_x563, _ctx);
}


// lift anonymous function
struct kk_std_os_path__mlift_proot_10193_fun567__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_proot_10193_fun567(kk_function_t _fself, kk_box_t _b_x40, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_proot_10193_fun567(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_proot_10193_fun567, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_proot_10193_fun567(kk_function_t _fself, kk_box_t _b_x40, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x568 = kk_Unit;
  kk_std_core_types__list _x_x569 = kk_std_core_types__list_unbox(_b_x40, KK_OWNED, _ctx); /*list<char>*/
  kk_std_os_path__mlift_proot_10192(_x_x569, _ctx);
  return kk_unit_box(_x_x568);
}

kk_unit_t kk_std_os_path__mlift_proot_10193(kk_char_t _y_x10145, kk_context_t* _ctx) { /* (char) -> std/text/parse/parse () */ 
  kk_std_core_types__list x_10205 = kk_std_text_parse_many_acc(kk_std_os_path__new_mlift_proot_10193_fun562(_ctx), kk_std_core_types__new_Nil(_ctx), _ctx); /*list<char>*/;
  kk_std_core_types__list_drop(x_10205, _ctx);
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x566 = kk_std_core_hnd_yield_extend(kk_std_os_path__new_mlift_proot_10193_fun567(_ctx), _ctx); /*3728*/
    kk_unit_unbox(_x_x566); return kk_Unit;
  }
  {
    kk_Unit; return kk_Unit;
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_proot_10194_fun573__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_proot_10194_fun573(kk_function_t _fself, kk_box_t _b_x43, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_proot_10194_fun573(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_proot_10194_fun573, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_proot_10194_fun573(kk_function_t _fself, kk_box_t _b_x43, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x574 = kk_Unit;
  kk_char_t _x_x575 = kk_char_unbox(_b_x43, KK_OWNED, _ctx); /*char*/
  kk_std_os_path__mlift_proot_10193(_x_x575, _ctx);
  return kk_unit_box(_x_x574);
}

kk_unit_t kk_std_os_path__mlift_proot_10194(kk_char_t wild___1, kk_context_t* _ctx) { /* (wild_@1 : char) -> std/text/parse/parse () */ 
  kk_char_t x_10207;
  kk_string_t _x_x570;
  kk_define_string_literal(, _s_x571, 1, "/", _ctx)
  _x_x570 = kk_string_dup(_s_x571, _ctx); /*string*/
  x_10207 = kk_std_text_parse_none_of(_x_x570, _ctx); /*char*/
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x572 = kk_std_core_hnd_yield_extend(kk_std_os_path__new_mlift_proot_10194_fun573(_ctx), _ctx); /*3728*/
    kk_unit_unbox(_x_x572); return kk_Unit;
  }
  {
    kk_std_os_path__mlift_proot_10193(x_10207, _ctx); return kk_Unit;
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_proot_10195_fun577__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_proot_10195_fun577(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_proot_10195_fun577(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_proot_10195_fun577, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_os_path__mlift_proot_10195_fun580__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_proot_10195_fun580(kk_function_t _fself, kk_box_t _b_x46, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_proot_10195_fun580(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_proot_10195_fun580, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_proot_10195_fun580(kk_function_t _fself, kk_box_t _b_x46, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x581;
  kk_char_t _x_x582 = kk_char_unbox(_b_x46, KK_OWNED, _ctx); /*char*/
  _x_x581 = kk_std_os_path__mlift_proot_10188(_x_x582, _ctx); /*bool*/
  return kk_bool_box(_x_x581);
}
static kk_box_t kk_std_os_path__mlift_proot_10195_fun577(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_char_t x_10209 = kk_std_text_parse_char('/', _ctx); /*char*/;
  bool _x_x578;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x579 = kk_std_core_hnd_yield_extend(kk_std_os_path__new_mlift_proot_10195_fun580(_ctx), _ctx); /*3728*/
    _x_x578 = kk_bool_unbox(_x_x579); /*bool*/
  }
  else {
    _x_x578 = false; /*bool*/
  }
  return kk_bool_box(_x_x578);
}


// lift anonymous function
struct kk_std_os_path__mlift_proot_10195_fun583__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_proot_10195_fun583(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_proot_10195_fun583(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_proot_10195_fun583, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_os_path__mlift_proot_10195_fun586__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_proot_10195_fun586(kk_function_t _fself, kk_box_t _b_x48, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_proot_10195_fun586(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_proot_10195_fun586, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_proot_10195_fun586(kk_function_t _fself, kk_box_t _b_x48, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x587;
  kk_unit_t _x_x588 = kk_Unit;
  kk_unit_unbox(_b_x48);
  _x_x587 = kk_std_os_path__mlift_proot_10189(_x_x588, _ctx); /*bool*/
  return kk_bool_box(_x_x587);
}
static kk_box_t kk_std_os_path__mlift_proot_10195_fun583(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t x_0_10211 = kk_Unit;
  kk_std_text_parse_eof(_ctx);
  bool _x_x584;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x585 = kk_std_core_hnd_yield_extend(kk_std_os_path__new_mlift_proot_10195_fun586(_ctx), _ctx); /*3728*/
    _x_x584 = kk_bool_unbox(_x_x585); /*bool*/
  }
  else {
    _x_x584 = true; /*bool*/
  }
  return kk_bool_box(_x_x584);
}

bool kk_std_os_path__mlift_proot_10195(kk_unit_t wild___3, kk_context_t* _ctx) { /* (wild_@3 : ()) -> std/text/parse/parse bool */ 
  kk_box_t _x_x576 = kk_std_text_parse__lp__bar__bar__rp_(kk_std_os_path__new_mlift_proot_10195_fun577(_ctx), kk_std_os_path__new_mlift_proot_10195_fun583(_ctx), _ctx); /*1336*/
  return kk_bool_unbox(_x_x576);
}


// lift anonymous function
struct kk_std_os_path_proot_fun590__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_proot_fun590(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_proot_fun590(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_proot_fun590, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_os_path_proot_fun593__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_proot_fun593(kk_function_t _fself, kk_box_t _b_x56, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_proot_fun593(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_proot_fun593, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_proot_fun593(kk_function_t _fself, kk_box_t _b_x56, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x594 = kk_Unit;
  kk_char_t _x_x595 = kk_char_unbox(_b_x56, KK_OWNED, _ctx); /*char*/
  kk_std_os_path__mlift_proot_10191(_x_x595, _ctx);
  return kk_unit_box(_x_x594);
}
static kk_box_t kk_std_os_path_proot_fun590(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_char_t x_0_10216 = kk_std_text_parse_alpha(_ctx); /*char*/;
  kk_unit_t _x_x591 = kk_Unit;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x592 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_proot_fun593(_ctx), _ctx); /*3728*/
    kk_unit_unbox(_x_x592);
  }
  else {
    kk_std_os_path__mlift_proot_10191(x_0_10216, _ctx);
  }
  return kk_unit_box(_x_x591);
}


// lift anonymous function
struct kk_std_os_path_proot_fun596__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_proot_fun596(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_proot_fun596(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_proot_fun596, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_os_path_proot_fun599__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_proot_fun599(kk_function_t _fself, kk_box_t _b_x58, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_proot_fun599(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_proot_fun599, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_proot_fun599(kk_function_t _fself, kk_box_t _b_x58, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t _x_x600 = kk_Unit;
  kk_char_t _x_x601 = kk_char_unbox(_b_x58, KK_OWNED, _ctx); /*char*/
  kk_std_os_path__mlift_proot_10194(_x_x601, _ctx);
  return kk_unit_box(_x_x600);
}
static kk_box_t kk_std_os_path_proot_fun596(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_char_t x_1_10218 = kk_std_text_parse_char('/', _ctx); /*char*/;
  kk_unit_t _x_x597 = kk_Unit;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x598 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_proot_fun599(_ctx), _ctx); /*3728*/
    kk_unit_unbox(_x_x598);
  }
  else {
    kk_std_os_path__mlift_proot_10194(x_1_10218, _ctx);
  }
  return kk_unit_box(_x_x597);
}


// lift anonymous function
struct kk_std_os_path_proot_fun603__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_proot_fun603(kk_function_t _fself, kk_box_t _b_x66, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_proot_fun603(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_proot_fun603, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_proot_fun603(kk_function_t _fself, kk_box_t _b_x66, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x604;
  kk_unit_t _x_x605 = kk_Unit;
  kk_unit_unbox(_b_x66);
  _x_x604 = kk_std_os_path__mlift_proot_10195(_x_x605, _ctx); /*bool*/
  return kk_bool_box(_x_x604);
}


// lift anonymous function
struct kk_std_os_path_proot_fun606__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_proot_fun606(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_proot_fun606(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_proot_fun606, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_os_path_proot_fun609__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_proot_fun609(kk_function_t _fself, kk_box_t _b_x68, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_proot_fun609(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_proot_fun609, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_proot_fun609(kk_function_t _fself, kk_box_t _b_x68, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x610;
  kk_char_t _x_x611 = kk_char_unbox(_b_x68, KK_OWNED, _ctx); /*char*/
  _x_x610 = kk_std_os_path__mlift_proot_10188(_x_x611, _ctx); /*bool*/
  return kk_bool_box(_x_x610);
}
static kk_box_t kk_std_os_path_proot_fun606(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_char_t x_2_10220 = kk_std_text_parse_char('/', _ctx); /*char*/;
  bool _x_x607;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x608 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_proot_fun609(_ctx), _ctx); /*3728*/
    _x_x607 = kk_bool_unbox(_x_x608); /*bool*/
  }
  else {
    _x_x607 = false; /*bool*/
  }
  return kk_bool_box(_x_x607);
}


// lift anonymous function
struct kk_std_os_path_proot_fun612__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_proot_fun612(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_proot_fun612(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_proot_fun612, _ctx)
  return kk_function_dup(_fself,kk_context());
}



// lift anonymous function
struct kk_std_os_path_proot_fun615__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_proot_fun615(kk_function_t _fself, kk_box_t _b_x70, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_proot_fun615(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_proot_fun615, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_proot_fun615(kk_function_t _fself, kk_box_t _b_x70, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x616;
  kk_unit_t _x_x617 = kk_Unit;
  kk_unit_unbox(_b_x70);
  _x_x616 = kk_std_os_path__mlift_proot_10189(_x_x617, _ctx); /*bool*/
  return kk_bool_box(_x_x616);
}
static kk_box_t kk_std_os_path_proot_fun612(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_unit_t x_3_10222 = kk_Unit;
  kk_std_text_parse_eof(_ctx);
  bool _x_x613;
  if (kk_yielding(kk_context())) {
    kk_box_t _x_x614 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_proot_fun615(_ctx), _ctx); /*3728*/
    _x_x613 = kk_bool_unbox(_x_x614); /*bool*/
  }
  else {
    _x_x613 = true; /*bool*/
  }
  return kk_bool_box(_x_x613);
}

bool kk_std_os_path_proot(kk_context_t* _ctx) { /* () -> std/text/parse/parse bool */ 
  kk_unit_t x_10213 = kk_Unit;
  kk_box_t _x_x589 = kk_std_text_parse__lp__bar__bar__rp_(kk_std_os_path_new_proot_fun590(_ctx), kk_std_os_path_new_proot_fun596(_ctx), _ctx); /*1336*/
  kk_unit_unbox(_x_x589);
  kk_box_t _x_x602;
  if (kk_yielding(kk_context())) {
    _x_x602 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_proot_fun603(_ctx), _ctx); /*3728*/
  }
  else {
    _x_x602 = kk_std_text_parse__lp__bar__bar__rp_(kk_std_os_path_new_proot_fun606(_ctx), kk_std_os_path_new_proot_fun612(_ctx), _ctx); /*3728*/
  }
  return kk_bool_unbox(_x_x602);
}
 
// Convert a `:path` to a normalized `:string` path.
// If this results in an empty string, the current directory path `"."` is returned.
// `"c:/foo/test.txt".path.string -> "c:/foo/test.txt"`
// `"c:\\foo\\test.txt".path.string -> "c:/foo/test.txt"`
// `"/foo//./bar/../test.txt".path.string -> "/foo/test.txt"`

kk_string_t kk_std_os_path_string(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> string */ 
  kk_std_core_types__list xs_10042;
  kk_std_core_types__list _x_x618;
  {
    kk_std_core_types__list _x_0 = p.parts;
    kk_std_core_types__list_dup(_x_0, _ctx);
    _x_x618 = _x_0; /*list<string>*/
  }
  xs_10042 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), _x_x618, _ctx); /*list<string>*/
  kk_string_t s;
  kk_string_t _x_x619;
  {
    kk_string_t _x = p.root;
    kk_string_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    _x_x619 = _x; /*string*/
  }
  kk_string_t _x_x620;
  if (kk_std_core_types__is_Nil(xs_10042, _ctx)) {
    _x_x620 = kk_string_empty(); /*string*/
  }
  else {
    struct kk_std_core_types_Cons* _con_x622 = kk_std_core_types__as_Cons(xs_10042, _ctx);
    kk_box_t _box_x78 = _con_x622->head;
    kk_std_core_types__list xx = _con_x622->tail;
    kk_string_t x = kk_string_unbox(_box_x78);
    if kk_likely(kk_datatype_ptr_is_unique(xs_10042, _ctx)) {
      kk_datatype_ptr_free(xs_10042, _ctx);
    }
    else {
      kk_string_dup(x, _ctx);
      kk_std_core_types__list_dup(xx, _ctx);
      kk_datatype_ptr_decref(xs_10042, _ctx);
    }
    kk_string_t _x_x623;
    kk_define_string_literal(, _s_x624, 1, "/", _ctx)
    _x_x623 = kk_string_dup(_s_x624, _ctx); /*string*/
    _x_x620 = kk_std_core_list__lift_joinsep_4797(_x_x623, xx, x, _ctx); /*string*/
  }
  s = kk_std_core_types__lp__plus__plus__rp_(_x_x619, _x_x620, _ctx); /*string*/
  bool _match_x452;
  kk_string_t _x_x625 = kk_string_dup(s, _ctx); /*string*/
  kk_string_t _x_x626 = kk_string_empty(); /*string*/
  _match_x452 = kk_string_is_eq(_x_x625,_x_x626,kk_context()); /*bool*/
  if (_match_x452) {
    kk_string_drop(s, _ctx);
    kk_define_string_literal(, _s_x628, 1, ".", _ctx)
    return kk_string_dup(_s_x628, _ctx);
  }
  {
    return s;
  }
}

kk_std_os_path__path kk_std_os_path_path_parts(kk_string_t root, kk_string_t s, kk_std_core_types__optional dirs, kk_context_t* _ctx) { /* (root : string, s : string, dirs : ? (list<string>)) -> path */ 
  kk_vector_t v_10012;
  kk_string_t _x_x632;
  kk_define_string_literal(, _s_x633, 1, "/", _ctx)
  _x_x632 = kk_string_dup(_s_x633, _ctx); /*string*/
  v_10012 = kk_string_splitv(s,_x_x632,kk_context()); /*vector<string>*/
  kk_std_core_types__list parts;
  kk_std_core_types__list _x_x634 = kk_std_core_vector_vlist(v_10012, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
  kk_std_core_types__list _x_x635;
  if (kk_std_core_types__is_Optional(dirs, _ctx)) {
    kk_box_t _box_x81 = dirs._cons._Optional.value;
    kk_std_core_types__list _uniq_dirs_921 = kk_std_core_types__list_unbox(_box_x81, KK_BORROWED, _ctx);
    kk_std_core_types__list_dup(_uniq_dirs_921, _ctx);
    kk_std_core_types__optional_drop(dirs, _ctx);
    _x_x635 = _uniq_dirs_921; /*list<string>*/
  }
  else {
    kk_std_core_types__optional_drop(dirs, _ctx);
    _x_x635 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
  }
  parts = kk_std_os_path_push_parts(_x_x634, _x_x635, _ctx); /*list<string>*/
  return kk_std_os_path__new_Path(root, parts, _ctx);
}
 
// Create a normalized `:path` from a path string.


// lift anonymous function
struct kk_std_os_path_path_fun646__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_path_fun646(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_path_fun646(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_path_fun646, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_path_fun646(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  bool _x_x647 = kk_std_os_path_proot(_ctx); /*bool*/
  return kk_bool_box(_x_x647);
}

kk_std_os_path__path kk_std_os_path_path(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> path */ 
  bool _match_x448;
  kk_string_t _x_x636 = kk_string_dup(s, _ctx); /*string*/
  kk_string_t _x_x637 = kk_string_empty(); /*string*/
  _match_x448 = kk_string_is_eq(_x_x636,_x_x637,kk_context()); /*bool*/
  if (_match_x448) {
    kk_string_drop(s, _ctx);
    kk_string_t _x_x639 = kk_string_empty(); /*string*/
    return kk_std_os_path__new_Path(_x_x639, kk_std_core_types__new_Nil(_ctx), _ctx);
  }
  {
    kk_string_t t;
    kk_string_t _x_x641;
    kk_define_string_literal(, _s_x642, 1, "\\", _ctx)
    _x_x641 = kk_string_dup(_s_x642, _ctx); /*string*/
    kk_string_t _x_x643;
    kk_define_string_literal(, _s_x644, 1, "/", _ctx)
    _x_x643 = kk_string_dup(_s_x644, _ctx); /*string*/
    t = kk_string_replace_all(s,_x_x641,_x_x643,kk_context()); /*string*/
    kk_std_core_types__maybe _match_x449;
    kk_string_t _x_x645 = kk_string_dup(t, _ctx); /*string*/
    _match_x449 = kk_std_text_parse_starts_with(_x_x645, kk_std_os_path_new_path_fun646(_ctx), _ctx); /*maybe<(2665, sslice/sslice)>*/
    if (kk_std_core_types__is_Nothing(_match_x449, _ctx)) {
      kk_vector_t v_10012;
      kk_string_t _x_x648;
      kk_define_string_literal(, _s_x649, 1, "/", _ctx)
      _x_x648 = kk_string_dup(_s_x649, _ctx); /*string*/
      v_10012 = kk_string_splitv(t,_x_x648,kk_context()); /*vector<string>*/
      kk_std_core_types__list parts;
      kk_std_core_types__list _x_x650 = kk_std_core_vector_vlist(v_10012, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
      kk_std_core_types__list _x_x651;
      kk_std_core_types__optional _match_x451 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
      if (kk_std_core_types__is_Optional(_match_x451, _ctx)) {
        kk_box_t _box_x84 = _match_x451._cons._Optional.value;
        kk_std_core_types__list _uniq_dirs_921 = kk_std_core_types__list_unbox(_box_x84, KK_BORROWED, _ctx);
        kk_std_core_types__list_dup(_uniq_dirs_921, _ctx);
        kk_std_core_types__optional_drop(_match_x451, _ctx);
        _x_x651 = _uniq_dirs_921; /*list<string>*/
      }
      else {
        kk_std_core_types__optional_drop(_match_x451, _ctx);
        _x_x651 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
      }
      parts = kk_std_os_path_push_parts(_x_x650, _x_x651, _ctx); /*list<string>*/
      kk_string_t _x_x652 = kk_string_empty(); /*string*/
      return kk_std_os_path__new_Path(_x_x652, parts, _ctx);
    }
    {
      kk_box_t _box_x85 = _match_x449._cons.Just.value;
      kk_std_core_types__tuple2 _pat_3 = kk_std_core_types__tuple2_unbox(_box_x85, KK_BORROWED, _ctx);
      kk_box_t _box_x86 = _pat_3.fst;
      kk_box_t _box_x87 = _pat_3.snd;
      kk_std_core_sslice__sslice rest = kk_std_core_sslice__sslice_unbox(_box_x87, KK_BORROWED, _ctx);
      bool eof = kk_bool_unbox(_box_x86);
      kk_string_drop(t, _ctx);
      kk_std_core_sslice__sslice_dup(rest, _ctx);
      kk_std_core_types__maybe_drop(_match_x449, _ctx);
      kk_string_t root_0_10105;
      kk_string_t _x_x654;
      kk_std_core_sslice__sslice _x_x655;
      {
        kk_string_t s_1_0 = rest.str;
        kk_integer_t start = rest.start;
        kk_string_dup(s_1_0, _ctx);
        kk_integer_dup(start, _ctx);
        _x_x655 = kk_std_core_sslice__new_Sslice(s_1_0, kk_integer_from_small(0), start, _ctx); /*sslice/sslice*/
      }
      _x_x654 = kk_std_core_sslice_string(_x_x655, _ctx); /*string*/
      kk_string_t _x_x656;
      if (eof) {
        kk_define_string_literal(, _s_x657, 1, "/", _ctx)
        _x_x656 = kk_string_dup(_s_x657, _ctx); /*string*/
      }
      else {
        _x_x656 = kk_string_empty(); /*string*/
      }
      root_0_10105 = kk_std_core_types__lp__plus__plus__rp_(_x_x654, _x_x656, _ctx); /*string*/
      kk_string_t s_1_10106 = kk_std_core_sslice_string(rest, _ctx); /*string*/;
      kk_vector_t v_10012_0;
      kk_string_t _x_x659;
      kk_define_string_literal(, _s_x660, 1, "/", _ctx)
      _x_x659 = kk_string_dup(_s_x660, _ctx); /*string*/
      v_10012_0 = kk_string_splitv(s_1_10106,_x_x659,kk_context()); /*vector<string>*/
      kk_std_core_types__list parts_0;
      kk_std_core_types__list _x_x661 = kk_std_core_vector_vlist(v_10012_0, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
      kk_std_core_types__list _x_x662;
      kk_std_core_types__optional _match_x450 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
      if (kk_std_core_types__is_Optional(_match_x450, _ctx)) {
        kk_box_t _box_x88 = _match_x450._cons._Optional.value;
        kk_std_core_types__list _uniq_dirs_921_0 = kk_std_core_types__list_unbox(_box_x88, KK_BORROWED, _ctx);
        kk_std_core_types__list_dup(_uniq_dirs_921_0, _ctx);
        kk_std_core_types__optional_drop(_match_x450, _ctx);
        _x_x662 = _uniq_dirs_921_0; /*list<string>*/
      }
      else {
        kk_std_core_types__optional_drop(_match_x450, _ctx);
        _x_x662 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
      }
      parts_0 = kk_std_os_path_push_parts(_x_x661, _x_x662, _ctx); /*list<string>*/
      return kk_std_os_path__new_Path(root_0_10105, parts_0, _ctx);
    }
  }
}
 
// Add two paths together using left-associative operator `(/)`.
// Keeps the root of `p1` and discards the root name of `p2`.
// `"/a/" / "b/foo.txt"          === "/a/b/foo.txt"`
// `"/a/foo.txt" / "/b/bar.txt"  === "/a/foo.txt/b/bar.txt"`
// `"c:/foo" / "d:/bar"          === "c:/foo/bar"`

kk_std_os_path__path kk_std_os_path__lp__fs__rp_(kk_std_os_path__path p1, kk_std_os_path__path p2, kk_context_t* _ctx) { /* (p1 : path, p2 : path) -> path */ 
  kk_std_core_types__list _b_x91_92;
  kk_std_core_types__list _x_x663;
  kk_std_core_types__list _x_x664;
  {
    kk_std_core_types__list _x_0 = p2.parts;
    kk_std_core_types__list_dup(_x_0, _ctx);
    kk_std_os_path__path_drop(p2, _ctx);
    _x_x664 = _x_0; /*list<string>*/
  }
  _x_x663 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), _x_x664, _ctx); /*list<733>*/
  kk_std_core_types__list _x_x665;
  {
    kk_std_core_types__list _x_1 = p1.parts;
    kk_std_core_types__list_dup(_x_1, _ctx);
    _x_x665 = _x_1; /*list<string>*/
  }
  _b_x91_92 = kk_std_os_path_push_parts(_x_x663, _x_x665, _ctx); /*list<string>*/
  kk_string_t _x_x666;
  {
    kk_string_t _x = p1.root;
    kk_string_dup(_x, _ctx);
    kk_std_os_path__path_drop(p1, _ctx);
    _x_x666 = _x; /*string*/
  }
  kk_std_core_types__list _x_x667;
  kk_std_core_types__optional _match_x447 = kk_std_core_types__new_Optional(kk_std_core_types__list_box(_b_x91_92, _ctx), _ctx); /*? 7*/;
  if (kk_std_core_types__is_Optional(_match_x447, _ctx)) {
    kk_box_t _box_x93 = _match_x447._cons._Optional.value;
    kk_std_core_types__list _uniq_parts_807 = kk_std_core_types__list_unbox(_box_x93, KK_BORROWED, _ctx);
    kk_std_core_types__list_dup(_uniq_parts_807, _ctx);
    kk_std_core_types__optional_drop(_match_x447, _ctx);
    _x_x667 = _uniq_parts_807; /*list<string>*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x447, _ctx);
    _x_x667 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
  }
  return kk_std_os_path__new_Path(_x_x666, _x_x667, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_app_path_10196_fun669__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_app_path_10196_fun669(kk_function_t _fself, kk_box_t _b_x96, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_app_path_10196_fun669(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_app_path_10196_fun669, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_app_path_10196_fun669(kk_function_t _fself, kk_box_t _b_x96, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x670;
  kk_string_t _x_x671 = kk_string_unbox(_b_x96); /*string*/
  _x_x670 = kk_std_os_path_path(_x_x671, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x670, _ctx);
}

kk_std_os_path__path kk_std_os_path__mlift_app_path_10196(kk_string_t _y_x10153, kk_context_t* _ctx) { /* (string) -> io path */ 
  kk_box_t _x_x668 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_app_path_10196_fun669(_ctx), kk_string_box(_y_x10153), _ctx); /*2970*/
  return kk_std_os_path__path_unbox(_x_x668, KK_OWNED, _ctx);
}
 
// Return the path to the currently executing application.


// lift anonymous function
struct kk_std_os_path_app_path_fun673__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_app_path_fun673(kk_function_t _fself, kk_box_t _b_x100, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_app_path_fun673(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_app_path_fun673, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_app_path_fun673(kk_function_t _fself, kk_box_t _b_x100, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x674;
  kk_string_t _x_x675 = kk_string_unbox(_b_x100); /*string*/
  _x_x674 = kk_std_os_path__mlift_app_path_10196(_x_x675, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x674, _ctx);
}


// lift anonymous function
struct kk_std_os_path_app_path_fun676__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_app_path_fun676(kk_function_t _fself, kk_box_t _b_x103, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_app_path_fun676(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_app_path_fun676, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_app_path_fun676(kk_function_t _fself, kk_box_t _b_x103, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x677;
  kk_string_t _x_x678 = kk_string_unbox(_b_x103); /*string*/
  _x_x677 = kk_std_os_path_path(_x_x678, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x677, _ctx);
}

kk_std_os_path__path kk_std_os_path_app_path(kk_context_t* _ctx) { /* () -> io path */ 
  kk_string_t x_10224 = kk_std_os_path_xapp_path(_ctx); /*string*/;
  kk_box_t _x_x672;
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_10224, _ctx);
    _x_x672 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_app_path_fun673(_ctx), _ctx); /*3728*/
  }
  else {
    _x_x672 = kk_std_core_hnd__open_none1(kk_std_os_path_new_app_path_fun676(_ctx), kk_string_box(x_10224), _ctx); /*3728*/
  }
  return kk_std_os_path__path_unbox(_x_x672, KK_OWNED, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_appdir_10197_fun680__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_appdir_10197_fun680(kk_function_t _fself, kk_box_t _b_x109, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_appdir_10197_fun680(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_appdir_10197_fun680, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_appdir_10197_fun680(kk_function_t _fself, kk_box_t _b_x109, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x681;
  kk_string_t _x_x682 = kk_string_unbox(_b_x109); /*string*/
  _x_x681 = kk_std_os_path_path(_x_x682, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x681, _ctx);
}


// lift anonymous function
struct kk_std_os_path__mlift_appdir_10197_fun684__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_appdir_10197_fun684(kk_function_t _fself, kk_box_t _b_x116, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_appdir_10197_fun684(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_appdir_10197_fun684, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_appdir_10197_fun684(kk_function_t _fself, kk_box_t _b_x116, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x685;
  kk_string_t _x_x686;
  kk_std_core_types__optional _match_x444 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
  if (kk_std_core_types__is_Optional(_match_x444, _ctx)) {
    kk_box_t _box_x112 = _match_x444._cons._Optional.value;
    kk_string_t _uniq_root_108 = kk_string_unbox(_box_x112);
    kk_string_dup(_uniq_root_108, _ctx);
    kk_std_core_types__optional_drop(_match_x444, _ctx);
    _x_x686 = _uniq_root_108; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x444, _ctx);
    kk_std_os_path__path _match_x445;
    kk_box_t _x_x687 = kk_box_dup(_b_x116, _ctx); /*2969*/
    _match_x445 = kk_std_os_path__path_unbox(_x_x687, KK_OWNED, _ctx); /*std/os/path/path*/
    {
      kk_string_t _x_0 = _match_x445.root;
      kk_string_dup(_x_0, _ctx);
      kk_std_os_path__path_drop(_match_x445, _ctx);
      _x_x686 = _x_0; /*string*/
    }
  }
  kk_std_core_types__list _x_x688;
  kk_std_os_path__path _match_x443 = kk_std_os_path__path_unbox(_b_x116, KK_OWNED, _ctx); /*std/os/path/path*/;
  {
    kk_std_core_types__list _x = _match_x443.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    kk_std_os_path__path_drop(_match_x443, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x689 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x113 = _con_x689->head;
      kk_std_core_types__list xx = _con_x689->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_box_drop(_box_x113, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _x_x688 = xx; /*list<string>*/
    }
    else {
      _x_x688 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  _x_x685 = kk_std_os_path__new_Path(_x_x686, _x_x688, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x685, _ctx);
}


// lift anonymous function
struct kk_std_os_path__mlift_appdir_10197_fun690__t {
  struct kk_function_s _base;
};
static kk_string_t kk_std_os_path__mlift_appdir_10197_fun690(kk_function_t _fself, kk_std_os_path__path p_1, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_appdir_10197_fun690(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_appdir_10197_fun690, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_string_t kk_std_os_path__mlift_appdir_10197_fun690(kk_function_t _fself, kk_std_os_path__path p_1, kk_context_t* _ctx) {
  kk_unused(_fself);
  {
    kk_std_core_types__list _x_1 = p_1.parts;
    kk_std_core_types__list_dup(_x_1, _ctx);
    kk_std_os_path__path_drop(p_1, _ctx);
    if (kk_std_core_types__is_Cons(_x_1, _ctx)) {
      struct kk_std_core_types_Cons* _con_x691 = kk_std_core_types__as_Cons(_x_1, _ctx);
      kk_box_t _box_x120 = _con_x691->head;
      kk_std_core_types__list _pat_0_0_0 = _con_x691->tail;
      kk_string_t x_0 = kk_string_unbox(_box_x120);
      if kk_likely(kk_datatype_ptr_is_unique(_x_1, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0_0, _ctx);
        kk_datatype_ptr_free(_x_1, _ctx);
      }
      else {
        kk_string_dup(x_0, _ctx);
        kk_datatype_ptr_decref(_x_1, _ctx);
      }
      return x_0;
    }
    {
      return kk_string_empty();
    }
  }
}


// lift anonymous function
struct kk_std_os_path__mlift_appdir_10197_fun695__t {
  struct kk_function_s _base;
  kk_function_t _b_x122_140;
};
static kk_box_t kk_std_os_path__mlift_appdir_10197_fun695(kk_function_t _fself, kk_box_t _b_x124, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_appdir_10197_fun695(kk_function_t _b_x122_140, kk_context_t* _ctx) {
  struct kk_std_os_path__mlift_appdir_10197_fun695__t* _self = kk_function_alloc_as(struct kk_std_os_path__mlift_appdir_10197_fun695__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_os_path__mlift_appdir_10197_fun695, kk_context());
  _self->_b_x122_140 = _b_x122_140;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_os_path__mlift_appdir_10197_fun695(kk_function_t _fself, kk_box_t _b_x124, kk_context_t* _ctx) {
  struct kk_std_os_path__mlift_appdir_10197_fun695__t* _self = kk_function_as(struct kk_std_os_path__mlift_appdir_10197_fun695__t*, _fself, _ctx);
  kk_function_t _b_x122_140 = _self->_b_x122_140; /* (p@1 : std/os/path/path) -> string */
  kk_drop_match(_self, {kk_function_dup(_b_x122_140, _ctx);}, {}, _ctx)
  kk_string_t _x_x696;
  kk_std_os_path__path _x_x697 = kk_std_os_path__path_unbox(_b_x124, KK_OWNED, _ctx); /*std/os/path/path*/
  _x_x696 = kk_function_call(kk_string_t, (kk_function_t, kk_std_os_path__path, kk_context_t*), _b_x122_140, (_b_x122_140, _x_x697, _ctx), _ctx); /*string*/
  return kk_string_box(_x_x696);
}


// lift anonymous function
struct kk_std_os_path__mlift_appdir_10197_fun701__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_appdir_10197_fun701(kk_function_t _fself, kk_box_t _b_x129, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_appdir_10197_fun701(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_appdir_10197_fun701, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_appdir_10197_fun701(kk_function_t _fself, kk_box_t _b_x129, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path p_2_148 = kk_std_os_path__path_unbox(_b_x129, KK_OWNED, _ctx); /*std/os/path/path*/;
  kk_std_os_path__path _x_x702;
  kk_string_t _x_x703;
  kk_std_core_types__optional _match_x442 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
  if (kk_std_core_types__is_Optional(_match_x442, _ctx)) {
    kk_box_t _box_x125 = _match_x442._cons._Optional.value;
    kk_string_t _uniq_root_108_0 = kk_string_unbox(_box_x125);
    kk_string_dup(_uniq_root_108_0, _ctx);
    kk_std_core_types__optional_drop(_match_x442, _ctx);
    _x_x703 = _uniq_root_108_0; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x442, _ctx);
    {
      kk_string_t _x_0_0 = p_2_148.root;
      kk_string_dup(_x_0_0, _ctx);
      _x_x703 = _x_0_0; /*string*/
    }
  }
  kk_std_core_types__list _x_x704;
  {
    kk_std_core_types__list _x_2 = p_2_148.parts;
    kk_std_core_types__list_dup(_x_2, _ctx);
    kk_std_os_path__path_drop(p_2_148, _ctx);
    if (kk_std_core_types__is_Cons(_x_2, _ctx)) {
      struct kk_std_core_types_Cons* _con_x705 = kk_std_core_types__as_Cons(_x_2, _ctx);
      kk_box_t _box_x126 = _con_x705->head;
      kk_std_core_types__list xx_0 = _con_x705->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x_2, _ctx)) {
        kk_box_drop(_box_x126, _ctx);
        kk_datatype_ptr_free(_x_2, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx_0, _ctx);
        kk_datatype_ptr_decref(_x_2, _ctx);
      }
      _x_x704 = xx_0; /*list<string>*/
    }
    else {
      _x_x704 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  _x_x702 = kk_std_os_path__new_Path(_x_x703, _x_x704, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x702, _ctx);
}


// lift anonymous function
struct kk_std_os_path__mlift_appdir_10197_fun706__t {
  struct kk_function_s _base;
};
static kk_string_t kk_std_os_path__mlift_appdir_10197_fun706(kk_function_t _fself, kk_std_os_path__path p_3, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_appdir_10197_fun706(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_appdir_10197_fun706, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_string_t kk_std_os_path__mlift_appdir_10197_fun706(kk_function_t _fself, kk_std_os_path__path p_3, kk_context_t* _ctx) {
  kk_unused(_fself);
  {
    kk_std_core_types__list _x_3 = p_3.parts;
    kk_std_core_types__list_dup(_x_3, _ctx);
    kk_std_os_path__path_drop(p_3, _ctx);
    if (kk_std_core_types__is_Cons(_x_3, _ctx)) {
      struct kk_std_core_types_Cons* _con_x707 = kk_std_core_types__as_Cons(_x_3, _ctx);
      kk_box_t _box_x130 = _con_x707->head;
      kk_std_core_types__list _pat_0_0_2 = _con_x707->tail;
      kk_string_t x_0_0 = kk_string_unbox(_box_x130);
      if kk_likely(kk_datatype_ptr_is_unique(_x_3, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0_2, _ctx);
        kk_datatype_ptr_free(_x_3, _ctx);
      }
      else {
        kk_string_dup(x_0_0, _ctx);
        kk_datatype_ptr_decref(_x_3, _ctx);
      }
      return x_0_0;
    }
    {
      return kk_string_empty();
    }
  }
}


// lift anonymous function
struct kk_std_os_path__mlift_appdir_10197_fun711__t {
  struct kk_function_s _base;
  kk_function_t _b_x132_144;
};
static kk_box_t kk_std_os_path__mlift_appdir_10197_fun711(kk_function_t _fself, kk_box_t _b_x134, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_appdir_10197_fun711(kk_function_t _b_x132_144, kk_context_t* _ctx) {
  struct kk_std_os_path__mlift_appdir_10197_fun711__t* _self = kk_function_alloc_as(struct kk_std_os_path__mlift_appdir_10197_fun711__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_os_path__mlift_appdir_10197_fun711, kk_context());
  _self->_b_x132_144 = _b_x132_144;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_os_path__mlift_appdir_10197_fun711(kk_function_t _fself, kk_box_t _b_x134, kk_context_t* _ctx) {
  struct kk_std_os_path__mlift_appdir_10197_fun711__t* _self = kk_function_as(struct kk_std_os_path__mlift_appdir_10197_fun711__t*, _fself, _ctx);
  kk_function_t _b_x132_144 = _self->_b_x132_144; /* (p@3 : std/os/path/path) -> string */
  kk_drop_match(_self, {kk_function_dup(_b_x132_144, _ctx);}, {}, _ctx)
  kk_string_t _x_x712;
  kk_std_os_path__path _x_x713 = kk_std_os_path__path_unbox(_b_x134, KK_OWNED, _ctx); /*std/os/path/path*/
  _x_x712 = kk_function_call(kk_string_t, (kk_function_t, kk_std_os_path__path, kk_context_t*), _b_x132_144, (_b_x132_144, _x_x713, _ctx), _ctx); /*string*/
  return kk_string_box(_x_x712);
}


// lift anonymous function
struct kk_std_os_path__mlift_appdir_10197_fun717__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_appdir_10197_fun717(kk_function_t _fself, kk_box_t _b_x139, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_appdir_10197_fun717(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_appdir_10197_fun717, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_appdir_10197_fun717(kk_function_t _fself, kk_box_t _b_x139, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path p_4_149 = kk_std_os_path__path_unbox(_b_x139, KK_OWNED, _ctx); /*std/os/path/path*/;
  kk_std_os_path__path _x_x718;
  kk_string_t _x_x719;
  kk_std_core_types__optional _match_x441 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
  if (kk_std_core_types__is_Optional(_match_x441, _ctx)) {
    kk_box_t _box_x135 = _match_x441._cons._Optional.value;
    kk_string_t _uniq_root_108_1 = kk_string_unbox(_box_x135);
    kk_string_dup(_uniq_root_108_1, _ctx);
    kk_std_core_types__optional_drop(_match_x441, _ctx);
    _x_x719 = _uniq_root_108_1; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x441, _ctx);
    {
      kk_string_t _x_0_1 = p_4_149.root;
      kk_string_dup(_x_0_1, _ctx);
      _x_x719 = _x_0_1; /*string*/
    }
  }
  kk_std_core_types__list _x_x720;
  {
    kk_std_core_types__list _x_4 = p_4_149.parts;
    kk_std_core_types__list_dup(_x_4, _ctx);
    kk_std_os_path__path_drop(p_4_149, _ctx);
    if (kk_std_core_types__is_Cons(_x_4, _ctx)) {
      struct kk_std_core_types_Cons* _con_x721 = kk_std_core_types__as_Cons(_x_4, _ctx);
      kk_box_t _box_x136 = _con_x721->head;
      kk_std_core_types__list xx_1 = _con_x721->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x_4, _ctx)) {
        kk_box_drop(_box_x136, _ctx);
        kk_datatype_ptr_free(_x_4, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx_1, _ctx);
        kk_datatype_ptr_decref(_x_4, _ctx);
      }
      _x_x720 = xx_1; /*list<string>*/
    }
    else {
      _x_x720 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  _x_x718 = kk_std_os_path__new_Path(_x_x719, _x_x720, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x718, _ctx);
}

kk_std_os_path__path kk_std_os_path__mlift_appdir_10197(kk_string_t _y_x10154, kk_context_t* _ctx) { /* (string) -> io path */ 
  kk_std_os_path__path _x_x1_10176;
  kk_box_t _x_x679 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_appdir_10197_fun680(_ctx), kk_string_box(_y_x10154), _ctx); /*2970*/
  _x_x1_10176 = kk_std_os_path__path_unbox(_x_x679, KK_OWNED, _ctx); /*std/os/path/path*/
  kk_std_os_path__path p_0;
  kk_box_t _x_x683 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_appdir_10197_fun684(_ctx), kk_std_os_path__path_box(_x_x1_10176, _ctx), _ctx); /*2970*/
  p_0 = kk_std_os_path__path_unbox(_x_x683, KK_OWNED, _ctx); /*std/os/path/path*/
  kk_function_t _b_x122_140 = kk_std_os_path__new_mlift_appdir_10197_fun690(_ctx); /*(p@1 : std/os/path/path) -> string*/;
  kk_std_os_path__path _b_x123_141 = kk_std_os_path__path_dup(p_0, _ctx); /*std/os/path/path*/;
  bool _match_x439;
  kk_string_t _x_x693;
  kk_box_t _x_x694 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_appdir_10197_fun695(_b_x122_140, _ctx), kk_std_os_path__path_box(_b_x123_141, _ctx), _ctx); /*2970*/
  _x_x693 = kk_string_unbox(_x_x694); /*string*/
  kk_string_t _x_x698;
  kk_define_string_literal(, _s_x699, 3, "bin", _ctx)
  _x_x698 = kk_string_dup(_s_x699, _ctx); /*string*/
  _match_x439 = kk_string_is_eq(_x_x693,_x_x698,kk_context()); /*bool*/
  if (_match_x439) {
    kk_box_t _x_x700 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_appdir_10197_fun701(_ctx), kk_std_os_path__path_box(p_0, _ctx), _ctx); /*2970*/
    return kk_std_os_path__path_unbox(_x_x700, KK_OWNED, _ctx);
  }
  {
    kk_function_t _b_x132_144 = kk_std_os_path__new_mlift_appdir_10197_fun706(_ctx); /*(p@3 : std/os/path/path) -> string*/;
    kk_std_os_path__path _b_x133_145 = kk_std_os_path__path_dup(p_0, _ctx); /*std/os/path/path*/;
    bool _match_x440;
    kk_string_t _x_x709;
    kk_box_t _x_x710 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_appdir_10197_fun711(_b_x132_144, _ctx), kk_std_os_path__path_box(_b_x133_145, _ctx), _ctx); /*2970*/
    _x_x709 = kk_string_unbox(_x_x710); /*string*/
    kk_string_t _x_x714;
    kk_define_string_literal(, _s_x715, 3, "exe", _ctx)
    _x_x714 = kk_string_dup(_s_x715, _ctx); /*string*/
    _match_x440 = kk_string_is_eq(_x_x709,_x_x714,kk_context()); /*bool*/
    if (_match_x440) {
      kk_box_t _x_x716 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_appdir_10197_fun717(_ctx), kk_std_os_path__path_box(p_0, _ctx), _ctx); /*2970*/
      return kk_std_os_path__path_unbox(_x_x716, KK_OWNED, _ctx);
    }
    {
      return p_0;
    }
  }
}
 
// Return the base directory that contains the currently running application.
// First tries `app-path().nobase`; if that ends in the ``bin`` or ``exe`` directory it
// returns the parent of that directory.


// lift anonymous function
struct kk_std_os_path_appdir_fun723__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_appdir_fun723(kk_function_t _fself, kk_box_t _b_x151, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_appdir_fun723(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_appdir_fun723, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_appdir_fun723(kk_function_t _fself, kk_box_t _b_x151, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x724;
  kk_string_t _x_x725 = kk_string_unbox(_b_x151); /*string*/
  _x_x724 = kk_std_os_path__mlift_appdir_10197(_x_x725, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x724, _ctx);
}


// lift anonymous function
struct kk_std_os_path_appdir_fun727__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_appdir_fun727(kk_function_t _fself, kk_box_t _b_x154, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_appdir_fun727(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_appdir_fun727, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_appdir_fun727(kk_function_t _fself, kk_box_t _b_x154, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x728;
  kk_string_t _x_x729 = kk_string_unbox(_b_x154); /*string*/
  _x_x728 = kk_std_os_path_path(_x_x729, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x728, _ctx);
}


// lift anonymous function
struct kk_std_os_path_appdir_fun731__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_appdir_fun731(kk_function_t _fself, kk_box_t _b_x161, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_appdir_fun731(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_appdir_fun731, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_appdir_fun731(kk_function_t _fself, kk_box_t _b_x161, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x732;
  kk_string_t _x_x733;
  kk_std_core_types__optional _match_x437 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
  if (kk_std_core_types__is_Optional(_match_x437, _ctx)) {
    kk_box_t _box_x157 = _match_x437._cons._Optional.value;
    kk_string_t _uniq_root_108 = kk_string_unbox(_box_x157);
    kk_string_dup(_uniq_root_108, _ctx);
    kk_std_core_types__optional_drop(_match_x437, _ctx);
    _x_x733 = _uniq_root_108; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x437, _ctx);
    kk_std_os_path__path _match_x438;
    kk_box_t _x_x734 = kk_box_dup(_b_x161, _ctx); /*2969*/
    _match_x438 = kk_std_os_path__path_unbox(_x_x734, KK_OWNED, _ctx); /*std/os/path/path*/
    {
      kk_string_t _x_0 = _match_x438.root;
      kk_string_dup(_x_0, _ctx);
      kk_std_os_path__path_drop(_match_x438, _ctx);
      _x_x733 = _x_0; /*string*/
    }
  }
  kk_std_core_types__list _x_x735;
  kk_std_os_path__path _match_x436 = kk_std_os_path__path_unbox(_b_x161, KK_OWNED, _ctx); /*std/os/path/path*/;
  {
    kk_std_core_types__list _x = _match_x436.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    kk_std_os_path__path_drop(_match_x436, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x736 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x158 = _con_x736->head;
      kk_std_core_types__list xx = _con_x736->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_box_drop(_box_x158, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _x_x735 = xx; /*list<string>*/
    }
    else {
      _x_x735 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  _x_x732 = kk_std_os_path__new_Path(_x_x733, _x_x735, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x732, _ctx);
}


// lift anonymous function
struct kk_std_os_path_appdir_fun737__t {
  struct kk_function_s _base;
};
static kk_string_t kk_std_os_path_appdir_fun737(kk_function_t _fself, kk_std_os_path__path p_1, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_appdir_fun737(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_appdir_fun737, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_string_t kk_std_os_path_appdir_fun737(kk_function_t _fself, kk_std_os_path__path p_1, kk_context_t* _ctx) {
  kk_unused(_fself);
  {
    kk_std_core_types__list _x_1 = p_1.parts;
    kk_std_core_types__list_dup(_x_1, _ctx);
    kk_std_os_path__path_drop(p_1, _ctx);
    if (kk_std_core_types__is_Cons(_x_1, _ctx)) {
      struct kk_std_core_types_Cons* _con_x738 = kk_std_core_types__as_Cons(_x_1, _ctx);
      kk_box_t _box_x165 = _con_x738->head;
      kk_std_core_types__list _pat_0_0_0 = _con_x738->tail;
      kk_string_t x_0 = kk_string_unbox(_box_x165);
      if kk_likely(kk_datatype_ptr_is_unique(_x_1, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0_0, _ctx);
        kk_datatype_ptr_free(_x_1, _ctx);
      }
      else {
        kk_string_dup(x_0, _ctx);
        kk_datatype_ptr_decref(_x_1, _ctx);
      }
      return x_0;
    }
    {
      return kk_string_empty();
    }
  }
}


// lift anonymous function
struct kk_std_os_path_appdir_fun742__t {
  struct kk_function_s _base;
  kk_function_t _b_x167_186;
};
static kk_box_t kk_std_os_path_appdir_fun742(kk_function_t _fself, kk_box_t _b_x169, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_appdir_fun742(kk_function_t _b_x167_186, kk_context_t* _ctx) {
  struct kk_std_os_path_appdir_fun742__t* _self = kk_function_alloc_as(struct kk_std_os_path_appdir_fun742__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_os_path_appdir_fun742, kk_context());
  _self->_b_x167_186 = _b_x167_186;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_os_path_appdir_fun742(kk_function_t _fself, kk_box_t _b_x169, kk_context_t* _ctx) {
  struct kk_std_os_path_appdir_fun742__t* _self = kk_function_as(struct kk_std_os_path_appdir_fun742__t*, _fself, _ctx);
  kk_function_t _b_x167_186 = _self->_b_x167_186; /* (p@1 : std/os/path/path) -> string */
  kk_drop_match(_self, {kk_function_dup(_b_x167_186, _ctx);}, {}, _ctx)
  kk_string_t _x_x743;
  kk_std_os_path__path _x_x744 = kk_std_os_path__path_unbox(_b_x169, KK_OWNED, _ctx); /*std/os/path/path*/
  _x_x743 = kk_function_call(kk_string_t, (kk_function_t, kk_std_os_path__path, kk_context_t*), _b_x167_186, (_b_x167_186, _x_x744, _ctx), _ctx); /*string*/
  return kk_string_box(_x_x743);
}


// lift anonymous function
struct kk_std_os_path_appdir_fun748__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_appdir_fun748(kk_function_t _fself, kk_box_t _b_x174, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_appdir_fun748(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_appdir_fun748, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_appdir_fun748(kk_function_t _fself, kk_box_t _b_x174, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path p_2_194 = kk_std_os_path__path_unbox(_b_x174, KK_OWNED, _ctx); /*std/os/path/path*/;
  kk_std_os_path__path _x_x749;
  kk_string_t _x_x750;
  kk_std_core_types__optional _match_x435 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
  if (kk_std_core_types__is_Optional(_match_x435, _ctx)) {
    kk_box_t _box_x170 = _match_x435._cons._Optional.value;
    kk_string_t _uniq_root_108_0 = kk_string_unbox(_box_x170);
    kk_string_dup(_uniq_root_108_0, _ctx);
    kk_std_core_types__optional_drop(_match_x435, _ctx);
    _x_x750 = _uniq_root_108_0; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x435, _ctx);
    {
      kk_string_t _x_0_0 = p_2_194.root;
      kk_string_dup(_x_0_0, _ctx);
      _x_x750 = _x_0_0; /*string*/
    }
  }
  kk_std_core_types__list _x_x751;
  {
    kk_std_core_types__list _x_2 = p_2_194.parts;
    kk_std_core_types__list_dup(_x_2, _ctx);
    kk_std_os_path__path_drop(p_2_194, _ctx);
    if (kk_std_core_types__is_Cons(_x_2, _ctx)) {
      struct kk_std_core_types_Cons* _con_x752 = kk_std_core_types__as_Cons(_x_2, _ctx);
      kk_box_t _box_x171 = _con_x752->head;
      kk_std_core_types__list xx_0 = _con_x752->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x_2, _ctx)) {
        kk_box_drop(_box_x171, _ctx);
        kk_datatype_ptr_free(_x_2, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx_0, _ctx);
        kk_datatype_ptr_decref(_x_2, _ctx);
      }
      _x_x751 = xx_0; /*list<string>*/
    }
    else {
      _x_x751 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  _x_x749 = kk_std_os_path__new_Path(_x_x750, _x_x751, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x749, _ctx);
}


// lift anonymous function
struct kk_std_os_path_appdir_fun753__t {
  struct kk_function_s _base;
};
static kk_string_t kk_std_os_path_appdir_fun753(kk_function_t _fself, kk_std_os_path__path p_3, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_appdir_fun753(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_appdir_fun753, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_string_t kk_std_os_path_appdir_fun753(kk_function_t _fself, kk_std_os_path__path p_3, kk_context_t* _ctx) {
  kk_unused(_fself);
  {
    kk_std_core_types__list _x_3 = p_3.parts;
    kk_std_core_types__list_dup(_x_3, _ctx);
    kk_std_os_path__path_drop(p_3, _ctx);
    if (kk_std_core_types__is_Cons(_x_3, _ctx)) {
      struct kk_std_core_types_Cons* _con_x754 = kk_std_core_types__as_Cons(_x_3, _ctx);
      kk_box_t _box_x175 = _con_x754->head;
      kk_std_core_types__list _pat_0_0_2 = _con_x754->tail;
      kk_string_t x_0_0 = kk_string_unbox(_box_x175);
      if kk_likely(kk_datatype_ptr_is_unique(_x_3, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0_2, _ctx);
        kk_datatype_ptr_free(_x_3, _ctx);
      }
      else {
        kk_string_dup(x_0_0, _ctx);
        kk_datatype_ptr_decref(_x_3, _ctx);
      }
      return x_0_0;
    }
    {
      return kk_string_empty();
    }
  }
}


// lift anonymous function
struct kk_std_os_path_appdir_fun758__t {
  struct kk_function_s _base;
  kk_function_t _b_x177_190;
};
static kk_box_t kk_std_os_path_appdir_fun758(kk_function_t _fself, kk_box_t _b_x179, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_appdir_fun758(kk_function_t _b_x177_190, kk_context_t* _ctx) {
  struct kk_std_os_path_appdir_fun758__t* _self = kk_function_alloc_as(struct kk_std_os_path_appdir_fun758__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_os_path_appdir_fun758, kk_context());
  _self->_b_x177_190 = _b_x177_190;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static kk_box_t kk_std_os_path_appdir_fun758(kk_function_t _fself, kk_box_t _b_x179, kk_context_t* _ctx) {
  struct kk_std_os_path_appdir_fun758__t* _self = kk_function_as(struct kk_std_os_path_appdir_fun758__t*, _fself, _ctx);
  kk_function_t _b_x177_190 = _self->_b_x177_190; /* (p@3 : std/os/path/path) -> string */
  kk_drop_match(_self, {kk_function_dup(_b_x177_190, _ctx);}, {}, _ctx)
  kk_string_t _x_x759;
  kk_std_os_path__path _x_x760 = kk_std_os_path__path_unbox(_b_x179, KK_OWNED, _ctx); /*std/os/path/path*/
  _x_x759 = kk_function_call(kk_string_t, (kk_function_t, kk_std_os_path__path, kk_context_t*), _b_x177_190, (_b_x177_190, _x_x760, _ctx), _ctx); /*string*/
  return kk_string_box(_x_x759);
}


// lift anonymous function
struct kk_std_os_path_appdir_fun764__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_appdir_fun764(kk_function_t _fself, kk_box_t _b_x184, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_appdir_fun764(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_appdir_fun764, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_appdir_fun764(kk_function_t _fself, kk_box_t _b_x184, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path p_4_195 = kk_std_os_path__path_unbox(_b_x184, KK_OWNED, _ctx); /*std/os/path/path*/;
  kk_std_os_path__path _x_x765;
  kk_string_t _x_x766;
  kk_std_core_types__optional _match_x434 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
  if (kk_std_core_types__is_Optional(_match_x434, _ctx)) {
    kk_box_t _box_x180 = _match_x434._cons._Optional.value;
    kk_string_t _uniq_root_108_1 = kk_string_unbox(_box_x180);
    kk_string_dup(_uniq_root_108_1, _ctx);
    kk_std_core_types__optional_drop(_match_x434, _ctx);
    _x_x766 = _uniq_root_108_1; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x434, _ctx);
    {
      kk_string_t _x_0_1 = p_4_195.root;
      kk_string_dup(_x_0_1, _ctx);
      _x_x766 = _x_0_1; /*string*/
    }
  }
  kk_std_core_types__list _x_x767;
  {
    kk_std_core_types__list _x_4 = p_4_195.parts;
    kk_std_core_types__list_dup(_x_4, _ctx);
    kk_std_os_path__path_drop(p_4_195, _ctx);
    if (kk_std_core_types__is_Cons(_x_4, _ctx)) {
      struct kk_std_core_types_Cons* _con_x768 = kk_std_core_types__as_Cons(_x_4, _ctx);
      kk_box_t _box_x181 = _con_x768->head;
      kk_std_core_types__list xx_1 = _con_x768->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x_4, _ctx)) {
        kk_box_drop(_box_x181, _ctx);
        kk_datatype_ptr_free(_x_4, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx_1, _ctx);
        kk_datatype_ptr_decref(_x_4, _ctx);
      }
      _x_x767 = xx_1; /*list<string>*/
    }
    else {
      _x_x767 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  _x_x765 = kk_std_os_path__new_Path(_x_x766, _x_x767, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x765, _ctx);
}

kk_std_os_path__path kk_std_os_path_appdir(kk_context_t* _ctx) { /* () -> io path */ 
  kk_string_t x_10227 = kk_std_os_path_xapp_path(_ctx); /*string*/;
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_10227, _ctx);
    kk_box_t _x_x722 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_appdir_fun723(_ctx), _ctx); /*3728*/
    return kk_std_os_path__path_unbox(_x_x722, KK_OWNED, _ctx);
  }
  {
    kk_std_os_path__path _x_x1_10176;
    kk_box_t _x_x726 = kk_std_core_hnd__open_none1(kk_std_os_path_new_appdir_fun727(_ctx), kk_string_box(x_10227), _ctx); /*2970*/
    _x_x1_10176 = kk_std_os_path__path_unbox(_x_x726, KK_OWNED, _ctx); /*std/os/path/path*/
    kk_std_os_path__path p_0;
    kk_box_t _x_x730 = kk_std_core_hnd__open_none1(kk_std_os_path_new_appdir_fun731(_ctx), kk_std_os_path__path_box(_x_x1_10176, _ctx), _ctx); /*2970*/
    p_0 = kk_std_os_path__path_unbox(_x_x730, KK_OWNED, _ctx); /*std/os/path/path*/
    kk_function_t _b_x167_186 = kk_std_os_path_new_appdir_fun737(_ctx); /*(p@1 : std/os/path/path) -> string*/;
    kk_std_os_path__path _b_x168_187 = kk_std_os_path__path_dup(p_0, _ctx); /*std/os/path/path*/;
    bool _match_x432;
    kk_string_t _x_x740;
    kk_box_t _x_x741 = kk_std_core_hnd__open_none1(kk_std_os_path_new_appdir_fun742(_b_x167_186, _ctx), kk_std_os_path__path_box(_b_x168_187, _ctx), _ctx); /*2970*/
    _x_x740 = kk_string_unbox(_x_x741); /*string*/
    kk_string_t _x_x745;
    kk_define_string_literal(, _s_x746, 3, "bin", _ctx)
    _x_x745 = kk_string_dup(_s_x746, _ctx); /*string*/
    _match_x432 = kk_string_is_eq(_x_x740,_x_x745,kk_context()); /*bool*/
    if (_match_x432) {
      kk_box_t _x_x747 = kk_std_core_hnd__open_none1(kk_std_os_path_new_appdir_fun748(_ctx), kk_std_os_path__path_box(p_0, _ctx), _ctx); /*2970*/
      return kk_std_os_path__path_unbox(_x_x747, KK_OWNED, _ctx);
    }
    {
      kk_function_t _b_x177_190 = kk_std_os_path_new_appdir_fun753(_ctx); /*(p@3 : std/os/path/path) -> string*/;
      kk_std_os_path__path _b_x178_191 = kk_std_os_path__path_dup(p_0, _ctx); /*std/os/path/path*/;
      bool _match_x433;
      kk_string_t _x_x756;
      kk_box_t _x_x757 = kk_std_core_hnd__open_none1(kk_std_os_path_new_appdir_fun758(_b_x177_190, _ctx), kk_std_os_path__path_box(_b_x178_191, _ctx), _ctx); /*2970*/
      _x_x756 = kk_string_unbox(_x_x757); /*string*/
      kk_string_t _x_x761;
      kk_define_string_literal(, _s_x762, 3, "exe", _ctx)
      _x_x761 = kk_string_dup(_s_x762, _ctx); /*string*/
      _match_x433 = kk_string_is_eq(_x_x756,_x_x761,kk_context()); /*bool*/
      if (_match_x433) {
        kk_box_t _x_x763 = kk_std_core_hnd__open_none1(kk_std_os_path_new_appdir_fun764(_ctx), kk_std_os_path__path_box(p_0, _ctx), _ctx); /*2970*/
        return kk_std_os_path__path_unbox(_x_x763, KK_OWNED, _ctx);
      }
      {
        return p_0;
      }
    }
  }
}
 
// Change the base name of a path

kk_std_os_path__path kk_std_os_path_change_base(kk_std_os_path__path p, kk_string_t basename_0, kk_context_t* _ctx) { /* (p : path, basename : string) -> path */ 
  kk_std_os_path__path q;
  kk_string_t _x_x769;
  kk_std_core_types__optional _match_x430 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
  if (kk_std_core_types__is_Optional(_match_x430, _ctx)) {
    kk_box_t _box_x196 = _match_x430._cons._Optional.value;
    kk_string_t _uniq_root_108 = kk_string_unbox(_box_x196);
    kk_string_dup(_uniq_root_108, _ctx);
    kk_std_core_types__optional_drop(_match_x430, _ctx);
    _x_x769 = _uniq_root_108; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x430, _ctx);
    {
      kk_string_t _x_0 = p.root;
      kk_string_dup(_x_0, _ctx);
      _x_x769 = _x_0; /*string*/
    }
  }
  kk_std_core_types__list _x_x770;
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x771 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x197 = _con_x771->head;
      kk_std_core_types__list xx = _con_x771->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_box_drop(_box_x197, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _x_x770 = xx; /*list<string>*/
    }
    else {
      _x_x770 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  q = kk_std_os_path__new_Path(_x_x769, _x_x770, _ctx); /*std/os/path/path*/
  kk_vector_t v_10012;
  kk_string_t _x_x772;
  kk_define_string_literal(, _s_x773, 1, "/", _ctx)
  _x_x772 = kk_string_dup(_s_x773, _ctx); /*string*/
  v_10012 = kk_string_splitv(basename_0,_x_x772,kk_context()); /*vector<string>*/
  kk_std_core_types__list parts;
  kk_std_core_types__list _x_x774 = kk_std_core_vector_vlist(v_10012, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
  kk_std_core_types__list _x_x775;
  {
    kk_std_core_types__list _x_0_0 = q.parts;
    kk_std_core_types__list_dup(_x_0_0, _ctx);
    _x_x775 = _x_0_0; /*list<string>*/
  }
  parts = kk_std_os_path_push_parts(_x_x774, _x_x775, _ctx); /*list<string>*/
  kk_string_t _x_x776;
  {
    kk_string_t _x_1 = q.root;
    kk_string_dup(_x_1, _ctx);
    kk_std_os_path__path_drop(q, _ctx);
    _x_x776 = _x_1; /*string*/
  }
  return kk_std_os_path__new_Path(_x_x776, parts, _ctx);
}

kk_std_core_types__tuple2 kk_std_os_path_split_base(kk_string_t basename_0, kk_context_t* _ctx) { /* (basename : string) -> (string, string) */ 
  kk_std_core_types__maybe _match_x429;
  kk_string_t _x_x777 = kk_string_dup(basename_0, _ctx); /*string*/
  kk_string_t _x_x778;
  kk_define_string_literal(, _s_x779, 1, ".", _ctx)
  _x_x778 = kk_string_dup(_s_x779, _ctx); /*string*/
  _match_x429 = kk_std_core_sslice_find_last(_x_x777, _x_x778, _ctx); /*maybe<sslice/sslice>*/
  if (kk_std_core_types__is_Just(_match_x429, _ctx)) {
    kk_box_t _box_x198 = _match_x429._cons.Just.value;
    kk_std_core_sslice__sslice slice = kk_std_core_sslice__sslice_unbox(_box_x198, KK_BORROWED, _ctx);
    kk_string_drop(basename_0, _ctx);
    kk_std_core_sslice__sslice_dup(slice, _ctx);
    kk_std_core_types__maybe_drop(_match_x429, _ctx);
    kk_string_t _b_x199_203;
    kk_std_core_sslice__sslice _x_x780;
    {
      kk_string_t s = slice.str;
      kk_integer_t start = slice.start;
      kk_string_dup(s, _ctx);
      kk_integer_dup(start, _ctx);
      _x_x780 = kk_std_core_sslice__new_Sslice(s, kk_integer_from_small(0), start, _ctx); /*sslice/sslice*/
    }
    _b_x199_203 = kk_std_core_sslice_string(_x_x780, _ctx); /*string*/
    kk_string_t _b_x200_204;
    kk_std_core_sslice__sslice _x_x781 = kk_std_core_sslice_after(slice, _ctx); /*sslice/sslice*/
    _b_x200_204 = kk_std_core_sslice_string(_x_x781, _ctx); /*string*/
    return kk_std_core_types__new_Tuple2(kk_string_box(_b_x199_203), kk_string_box(_b_x200_204), _ctx);
  }
  {
    kk_box_t _x_x782;
    kk_string_t _x_x783 = kk_string_empty(); /*string*/
    _x_x782 = kk_string_box(_x_x783); /*130*/
    return kk_std_core_types__new_Tuple2(kk_string_box(basename_0), _x_x782, _ctx);
  }
}
 
// Change the extension of a path.
// Only adds a dot if the extname does not already start with a dot.

kk_std_os_path__path kk_std_os_path_change_ext(kk_std_os_path__path p, kk_string_t extname_0, kk_context_t* _ctx) { /* (p : path, extname : string) -> path */ 
  kk_std_core_types__maybe _match_x428;
  kk_string_t _x_x785;
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x786 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x207 = _con_x786->head;
      kk_std_core_types__list _pat_0_0_0 = _con_x786->tail;
      kk_string_t x_0 = kk_string_unbox(_box_x207);
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0_0, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_string_dup(x_0, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _x_x785 = x_0; /*string*/
    }
    else {
      _x_x785 = kk_string_empty(); /*string*/
    }
  }
  kk_string_t _x_x788;
  kk_define_string_literal(, _s_x789, 1, ".", _ctx)
  _x_x788 = kk_string_dup(_s_x789, _ctx); /*string*/
  _match_x428 = kk_std_core_sslice_find_last(_x_x785, _x_x788, _ctx); /*maybe<sslice/sslice>*/
  if (kk_std_core_types__is_Just(_match_x428, _ctx)) {
    kk_box_t _box_x209 = _match_x428._cons.Just.value;
    kk_std_core_sslice__sslice slice = kk_std_core_sslice__sslice_unbox(_box_x209, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(slice, _ctx);
    kk_std_core_types__maybe_drop(_match_x428, _ctx);
    kk_string_t stemname_0;
    kk_std_core_sslice__sslice _x_x790;
    {
      kk_string_t s = slice.str;
      kk_integer_t start = slice.start;
      kk_string_dup(s, _ctx);
      kk_integer_dup(start, _ctx);
      _x_x790 = kk_std_core_sslice__new_Sslice(s, kk_integer_from_small(0), start, _ctx); /*sslice/sslice*/
    }
    stemname_0 = kk_std_core_sslice_string(_x_x790, _ctx); /*string*/
    kk_string_t _pat_1_2;
    kk_std_core_sslice__sslice _x_x791 = kk_std_core_sslice_after(slice, _ctx); /*sslice/sslice*/
    _pat_1_2 = kk_std_core_sslice_string(_x_x791, _ctx); /*string*/
    kk_string_drop(_pat_1_2, _ctx);
    kk_std_core_types__maybe maybe_10070;
    kk_string_t _x_x792 = kk_string_dup(extname_0, _ctx); /*string*/
    kk_string_t _x_x793;
    kk_define_string_literal(, _s_x794, 1, ".", _ctx)
    _x_x793 = kk_string_dup(_s_x794, _ctx); /*string*/
    maybe_10070 = kk_std_core_sslice_starts_with(_x_x792, _x_x793, _ctx); /*maybe<sslice/sslice>*/
    kk_string_t newext;
    if (kk_std_core_types__is_Just(maybe_10070, _ctx)) {
      kk_box_t _box_x210 = maybe_10070._cons.Just.value;
      kk_std_core_types__maybe_drop(maybe_10070, _ctx);
      newext = extname_0; /*string*/
    }
    else {
      kk_string_t _x_x795;
      kk_define_string_literal(, _s_x796, 1, ".", _ctx)
      _x_x795 = kk_string_dup(_s_x796, _ctx); /*string*/
      newext = kk_std_core_types__lp__plus__plus__rp_(_x_x795, extname_0, _ctx); /*string*/
    }
    kk_string_t s_0_10114 = kk_std_core_types__lp__plus__plus__rp_(stemname_0, newext, _ctx); /*string*/;
    kk_vector_t v_10012;
    kk_string_t _x_x797;
    kk_define_string_literal(, _s_x798, 1, "/", _ctx)
    _x_x797 = kk_string_dup(_s_x798, _ctx); /*string*/
    v_10012 = kk_string_splitv(s_0_10114,_x_x797,kk_context()); /*vector<string>*/
    kk_std_core_types__list parts;
    kk_std_core_types__list _x_x799 = kk_std_core_vector_vlist(v_10012, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
    kk_std_core_types__list _x_x800;
    {
      kk_std_core_types__list _x_0 = p.parts;
      kk_std_core_types__list_dup(_x_0, _ctx);
      if (kk_std_core_types__is_Cons(_x_0, _ctx)) {
        struct kk_std_core_types_Cons* _con_x801 = kk_std_core_types__as_Cons(_x_0, _ctx);
        kk_box_t _box_x211 = _con_x801->head;
        kk_std_core_types__list xx = _con_x801->tail;
        if kk_likely(kk_datatype_ptr_is_unique(_x_0, _ctx)) {
          kk_box_drop(_box_x211, _ctx);
          kk_datatype_ptr_free(_x_0, _ctx);
        }
        else {
          kk_std_core_types__list_dup(xx, _ctx);
          kk_datatype_ptr_decref(_x_0, _ctx);
        }
        _x_x800 = xx; /*list<string>*/
      }
      else {
        _x_x800 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
      }
    }
    parts = kk_std_os_path_push_parts(_x_x799, _x_x800, _ctx); /*list<string>*/
    kk_string_t _x_x802;
    {
      kk_string_t _x_0_0 = p.root;
      kk_string_dup(_x_0_0, _ctx);
      kk_std_os_path__path_drop(p, _ctx);
      _x_x802 = _x_0_0; /*string*/
    }
    return kk_std_os_path__new_Path(_x_x802, parts, _ctx);
  }
  {
    kk_std_core_types__maybe maybe_10070_0;
    kk_string_t _x_x803 = kk_string_dup(extname_0, _ctx); /*string*/
    kk_string_t _x_x804;
    kk_define_string_literal(, _s_x805, 1, ".", _ctx)
    _x_x804 = kk_string_dup(_s_x805, _ctx); /*string*/
    maybe_10070_0 = kk_std_core_sslice_starts_with(_x_x803, _x_x804, _ctx); /*maybe<sslice/sslice>*/
    kk_string_t newext_0;
    if (kk_std_core_types__is_Just(maybe_10070_0, _ctx)) {
      kk_box_t _box_x212 = maybe_10070_0._cons.Just.value;
      kk_std_core_types__maybe_drop(maybe_10070_0, _ctx);
      newext_0 = extname_0; /*string*/
    }
    else {
      kk_string_t _x_x806;
      kk_define_string_literal(, _s_x807, 1, ".", _ctx)
      _x_x806 = kk_string_dup(_s_x807, _ctx); /*string*/
      newext_0 = kk_std_core_types__lp__plus__plus__rp_(_x_x806, extname_0, _ctx); /*string*/
    }
    kk_string_t s_0_10114_0;
    kk_string_t _x_x808;
    {
      kk_std_core_types__list _x_1 = p.parts;
      kk_std_core_types__list_dup(_x_1, _ctx);
      if (kk_std_core_types__is_Cons(_x_1, _ctx)) {
        struct kk_std_core_types_Cons* _con_x809 = kk_std_core_types__as_Cons(_x_1, _ctx);
        kk_box_t _box_x213 = _con_x809->head;
        kk_std_core_types__list _pat_0_0_0_0 = _con_x809->tail;
        kk_string_t x_0_0 = kk_string_unbox(_box_x213);
        if kk_likely(kk_datatype_ptr_is_unique(_x_1, _ctx)) {
          kk_std_core_types__list_drop(_pat_0_0_0_0, _ctx);
          kk_datatype_ptr_free(_x_1, _ctx);
        }
        else {
          kk_string_dup(x_0_0, _ctx);
          kk_datatype_ptr_decref(_x_1, _ctx);
        }
        _x_x808 = x_0_0; /*string*/
      }
      else {
        _x_x808 = kk_string_empty(); /*string*/
      }
    }
    s_0_10114_0 = kk_std_core_types__lp__plus__plus__rp_(_x_x808, newext_0, _ctx); /*string*/
    kk_vector_t v_10012_0;
    kk_string_t _x_x811;
    kk_define_string_literal(, _s_x812, 1, "/", _ctx)
    _x_x811 = kk_string_dup(_s_x812, _ctx); /*string*/
    v_10012_0 = kk_string_splitv(s_0_10114_0,_x_x811,kk_context()); /*vector<string>*/
    kk_std_core_types__list parts_0;
    kk_std_core_types__list _x_x813 = kk_std_core_vector_vlist(v_10012_0, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
    kk_std_core_types__list _x_x814;
    {
      kk_std_core_types__list _x_0_1 = p.parts;
      kk_std_core_types__list_dup(_x_0_1, _ctx);
      if (kk_std_core_types__is_Cons(_x_0_1, _ctx)) {
        struct kk_std_core_types_Cons* _con_x815 = kk_std_core_types__as_Cons(_x_0_1, _ctx);
        kk_box_t _box_x215 = _con_x815->head;
        kk_std_core_types__list xx_0 = _con_x815->tail;
        if kk_likely(kk_datatype_ptr_is_unique(_x_0_1, _ctx)) {
          kk_box_drop(_box_x215, _ctx);
          kk_datatype_ptr_free(_x_0_1, _ctx);
        }
        else {
          kk_std_core_types__list_dup(xx_0, _ctx);
          kk_datatype_ptr_decref(_x_0_1, _ctx);
        }
        _x_x814 = xx_0; /*list<string>*/
      }
      else {
        _x_x814 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
      }
    }
    parts_0 = kk_std_os_path_push_parts(_x_x813, _x_x814, _ctx); /*list<string>*/
    kk_string_t _x_x816;
    {
      kk_string_t _x_0_0_0 = p.root;
      kk_string_dup(_x_0_0_0, _ctx);
      kk_std_os_path__path_drop(p, _ctx);
      _x_x816 = _x_0_0_0; /*string*/
    }
    return kk_std_os_path__new_Path(_x_x816, parts_0, _ctx);
  }
}
 
// Return the extension of path (without the preceding dot (`'.'`))
// `"/foo/bar.svg.txt".path.extname === "txt"`

kk_string_t kk_std_os_path_extname(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> string */ 
  kk_std_core_types__tuple2 tuple2_10072;
  kk_std_core_types__maybe _match_x427;
  kk_string_t _x_x817;
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x818 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x216 = _con_x818->head;
      kk_std_core_types__list _pat_0_0_0 = _con_x818->tail;
      kk_string_t x_0 = kk_string_unbox(_box_x216);
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0_0, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_string_dup(x_0, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _x_x817 = x_0; /*string*/
    }
    else {
      _x_x817 = kk_string_empty(); /*string*/
    }
  }
  kk_string_t _x_x820;
  kk_define_string_literal(, _s_x821, 1, ".", _ctx)
  _x_x820 = kk_string_dup(_s_x821, _ctx); /*string*/
  _match_x427 = kk_std_core_sslice_find_last(_x_x817, _x_x820, _ctx); /*maybe<sslice/sslice>*/
  if (kk_std_core_types__is_Just(_match_x427, _ctx)) {
    kk_box_t _box_x218 = _match_x427._cons.Just.value;
    kk_std_core_sslice__sslice slice = kk_std_core_sslice__sslice_unbox(_box_x218, KK_BORROWED, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    kk_std_core_sslice__sslice_dup(slice, _ctx);
    kk_std_core_types__maybe_drop(_match_x427, _ctx);
    kk_string_t _b_x219_225;
    kk_std_core_sslice__sslice _x_x822;
    {
      kk_string_t s = slice.str;
      kk_integer_t start = slice.start;
      kk_string_dup(s, _ctx);
      kk_integer_dup(start, _ctx);
      _x_x822 = kk_std_core_sslice__new_Sslice(s, kk_integer_from_small(0), start, _ctx); /*sslice/sslice*/
    }
    _b_x219_225 = kk_std_core_sslice_string(_x_x822, _ctx); /*string*/
    kk_string_t _b_x220_226;
    kk_std_core_sslice__sslice _x_x823 = kk_std_core_sslice_after(slice, _ctx); /*sslice/sslice*/
    _b_x220_226 = kk_std_core_sslice_string(_x_x823, _ctx); /*string*/
    tuple2_10072 = kk_std_core_types__new_Tuple2(kk_string_box(_b_x219_225), kk_string_box(_b_x220_226), _ctx); /*(string, string)*/
  }
  else {
    kk_box_t _x_x824;
    kk_string_t _x_x825;
    {
      kk_std_core_types__list _x_0 = p.parts;
      kk_std_core_types__list_dup(_x_0, _ctx);
      kk_std_os_path__path_drop(p, _ctx);
      if (kk_std_core_types__is_Cons(_x_0, _ctx)) {
        struct kk_std_core_types_Cons* _con_x826 = kk_std_core_types__as_Cons(_x_0, _ctx);
        kk_box_t _box_x221 = _con_x826->head;
        kk_std_core_types__list _pat_0_0_0_0 = _con_x826->tail;
        kk_string_t x_0_0 = kk_string_unbox(_box_x221);
        if kk_likely(kk_datatype_ptr_is_unique(_x_0, _ctx)) {
          kk_std_core_types__list_drop(_pat_0_0_0_0, _ctx);
          kk_datatype_ptr_free(_x_0, _ctx);
        }
        else {
          kk_string_dup(x_0_0, _ctx);
          kk_datatype_ptr_decref(_x_0, _ctx);
        }
        _x_x825 = x_0_0; /*string*/
      }
      else {
        _x_x825 = kk_string_empty(); /*string*/
      }
    }
    _x_x824 = kk_string_box(_x_x825); /*129*/
    kk_box_t _x_x828;
    kk_string_t _x_x829 = kk_string_empty(); /*string*/
    _x_x828 = kk_string_box(_x_x829); /*130*/
    tuple2_10072 = kk_std_core_types__new_Tuple2(_x_x824, _x_x828, _ctx); /*(string, string)*/
  }
  {
    kk_box_t _box_x229 = tuple2_10072.fst;
    kk_box_t _box_x230 = tuple2_10072.snd;
    kk_string_t _x_0_0 = kk_string_unbox(_box_x230);
    kk_string_dup(_x_0_0, _ctx);
    kk_std_core_types__tuple2_drop(tuple2_10072, _ctx);
    return _x_0_0;
  }
}
 
// Change the stem name of a path

kk_std_os_path__path kk_std_os_path_change_stem(kk_std_os_path__path p, kk_string_t stemname_0, kk_context_t* _ctx) { /* (p : path, stemname : string) -> path */ 
  kk_std_core_types__tuple2 tuple2_10074;
  kk_std_core_types__maybe _match_x426;
  kk_string_t _x_x831;
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x832 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x231 = _con_x832->head;
      kk_std_core_types__list _pat_0_0_0 = _con_x832->tail;
      kk_string_t x_0 = kk_string_unbox(_box_x231);
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0_0, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_string_dup(x_0, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _x_x831 = x_0; /*string*/
    }
    else {
      _x_x831 = kk_string_empty(); /*string*/
    }
  }
  kk_string_t _x_x834;
  kk_define_string_literal(, _s_x835, 1, ".", _ctx)
  _x_x834 = kk_string_dup(_s_x835, _ctx); /*string*/
  _match_x426 = kk_std_core_sslice_find_last(_x_x831, _x_x834, _ctx); /*maybe<sslice/sslice>*/
  if (kk_std_core_types__is_Just(_match_x426, _ctx)) {
    kk_box_t _box_x233 = _match_x426._cons.Just.value;
    kk_std_core_sslice__sslice slice = kk_std_core_sslice__sslice_unbox(_box_x233, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(slice, _ctx);
    kk_std_core_types__maybe_drop(_match_x426, _ctx);
    kk_string_t _b_x234_240;
    kk_std_core_sslice__sslice _x_x836;
    {
      kk_string_t s = slice.str;
      kk_integer_t start = slice.start;
      kk_string_dup(s, _ctx);
      kk_integer_dup(start, _ctx);
      _x_x836 = kk_std_core_sslice__new_Sslice(s, kk_integer_from_small(0), start, _ctx); /*sslice/sslice*/
    }
    _b_x234_240 = kk_std_core_sslice_string(_x_x836, _ctx); /*string*/
    kk_string_t _b_x235_241;
    kk_std_core_sslice__sslice _x_x837 = kk_std_core_sslice_after(slice, _ctx); /*sslice/sslice*/
    _b_x235_241 = kk_std_core_sslice_string(_x_x837, _ctx); /*string*/
    tuple2_10074 = kk_std_core_types__new_Tuple2(kk_string_box(_b_x234_240), kk_string_box(_b_x235_241), _ctx); /*(string, string)*/
  }
  else {
    kk_box_t _x_x838;
    kk_string_t _x_x839;
    {
      kk_std_core_types__list _x_0 = p.parts;
      kk_std_core_types__list_dup(_x_0, _ctx);
      if (kk_std_core_types__is_Cons(_x_0, _ctx)) {
        struct kk_std_core_types_Cons* _con_x840 = kk_std_core_types__as_Cons(_x_0, _ctx);
        kk_box_t _box_x236 = _con_x840->head;
        kk_std_core_types__list _pat_0_0_0_0 = _con_x840->tail;
        kk_string_t x_0_0 = kk_string_unbox(_box_x236);
        if kk_likely(kk_datatype_ptr_is_unique(_x_0, _ctx)) {
          kk_std_core_types__list_drop(_pat_0_0_0_0, _ctx);
          kk_datatype_ptr_free(_x_0, _ctx);
        }
        else {
          kk_string_dup(x_0_0, _ctx);
          kk_datatype_ptr_decref(_x_0, _ctx);
        }
        _x_x839 = x_0_0; /*string*/
      }
      else {
        _x_x839 = kk_string_empty(); /*string*/
      }
    }
    _x_x838 = kk_string_box(_x_x839); /*129*/
    kk_box_t _x_x842;
    kk_string_t _x_x843 = kk_string_empty(); /*string*/
    _x_x842 = kk_string_box(_x_x843); /*130*/
    tuple2_10074 = kk_std_core_types__new_Tuple2(_x_x838, _x_x842, _ctx); /*(string, string)*/
  }
  kk_string_t basename_0_10076;
  kk_string_t _x_x845;
  bool _match_x425;
  kk_string_t _x_x846;
  {
    kk_box_t _box_x244 = tuple2_10074.fst;
    kk_box_t _box_x245 = tuple2_10074.snd;
    kk_string_t _x_0_0 = kk_string_unbox(_box_x245);
    kk_string_dup(_x_0_0, _ctx);
    _x_x846 = _x_0_0; /*string*/
  }
  kk_string_t _x_x847 = kk_string_empty(); /*string*/
  _match_x425 = kk_string_is_eq(_x_x846,_x_x847,kk_context()); /*bool*/
  if (_match_x425) {
    kk_std_core_types__tuple2_drop(tuple2_10074, _ctx);
    _x_x845 = kk_string_empty(); /*string*/
  }
  else {
    kk_string_t _x_x850;
    kk_define_string_literal(, _s_x851, 1, ".", _ctx)
    _x_x850 = kk_string_dup(_s_x851, _ctx); /*string*/
    kk_string_t _x_x852;
    {
      kk_box_t _box_x246 = tuple2_10074.fst;
      kk_box_t _box_x247 = tuple2_10074.snd;
      kk_string_t _x_0_1 = kk_string_unbox(_box_x247);
      kk_string_dup(_x_0_1, _ctx);
      kk_std_core_types__tuple2_drop(tuple2_10074, _ctx);
      _x_x852 = _x_0_1; /*string*/
    }
    _x_x845 = kk_std_core_types__lp__plus__plus__rp_(_x_x850, _x_x852, _ctx); /*string*/
  }
  basename_0_10076 = kk_std_core_types__lp__plus__plus__rp_(stemname_0, _x_x845, _ctx); /*string*/
  kk_std_os_path__path q;
  kk_string_t _x_x853;
  kk_std_core_types__optional _match_x424 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
  if (kk_std_core_types__is_Optional(_match_x424, _ctx)) {
    kk_box_t _box_x248 = _match_x424._cons._Optional.value;
    kk_string_t _uniq_root_108 = kk_string_unbox(_box_x248);
    kk_string_dup(_uniq_root_108, _ctx);
    kk_std_core_types__optional_drop(_match_x424, _ctx);
    _x_x853 = _uniq_root_108; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x424, _ctx);
    {
      kk_string_t _x_0_0_0 = p.root;
      kk_string_dup(_x_0_0_0, _ctx);
      _x_x853 = _x_0_0_0; /*string*/
    }
  }
  kk_std_core_types__list _x_x854;
  {
    kk_std_core_types__list _x_1 = p.parts;
    kk_std_core_types__list_dup(_x_1, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    if (kk_std_core_types__is_Cons(_x_1, _ctx)) {
      struct kk_std_core_types_Cons* _con_x855 = kk_std_core_types__as_Cons(_x_1, _ctx);
      kk_box_t _box_x249 = _con_x855->head;
      kk_std_core_types__list xx = _con_x855->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_x_1, _ctx)) {
        kk_box_drop(_box_x249, _ctx);
        kk_datatype_ptr_free(_x_1, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(_x_1, _ctx);
      }
      _x_x854 = xx; /*list<string>*/
    }
    else {
      _x_x854 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
  }
  q = kk_std_os_path__new_Path(_x_x853, _x_x854, _ctx); /*std/os/path/path*/
  kk_vector_t v_10012;
  kk_string_t _x_x856;
  kk_define_string_literal(, _s_x857, 1, "/", _ctx)
  _x_x856 = kk_string_dup(_s_x857, _ctx); /*string*/
  v_10012 = kk_string_splitv(basename_0_10076,_x_x856,kk_context()); /*vector<string>*/
  kk_std_core_types__list parts;
  kk_std_core_types__list _x_x858 = kk_std_core_vector_vlist(v_10012, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
  kk_std_core_types__list _x_x859;
  {
    kk_std_core_types__list _x_1_0 = q.parts;
    kk_std_core_types__list_dup(_x_1_0, _ctx);
    _x_x859 = _x_1_0; /*list<string>*/
  }
  parts = kk_std_os_path_push_parts(_x_x858, _x_x859, _ctx); /*list<string>*/
  kk_string_t _x_x860;
  {
    kk_string_t _x_0_1_0 = q.root;
    kk_string_dup(_x_0_1_0, _ctx);
    kk_std_os_path__path_drop(q, _ctx);
    _x_x860 = _x_0_1_0; /*string*/
  }
  return kk_std_os_path__new_Path(_x_x860, parts, _ctx);
}
 
// Convenience function that adds a string path.

kk_std_os_path__path kk_std_os_path_pathstring_fs__lp__fs__rp_(kk_std_os_path__path p1, kk_string_t p2, kk_context_t* _ctx) { /* (p1 : path, p2 : string) -> path */ 
  kk_std_os_path__path p2_0_10125 = kk_std_os_path_path(p2, _ctx); /*std/os/path/path*/;
  kk_std_core_types__list _b_x250_251;
  kk_std_core_types__list _x_x861;
  kk_std_core_types__list _x_x862;
  {
    kk_std_core_types__list _x_0 = p2_0_10125.parts;
    kk_std_core_types__list_dup(_x_0, _ctx);
    kk_std_os_path__path_drop(p2_0_10125, _ctx);
    _x_x862 = _x_0; /*list<string>*/
  }
  _x_x861 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), _x_x862, _ctx); /*list<733>*/
  kk_std_core_types__list _x_x863;
  {
    kk_std_core_types__list _x_1 = p1.parts;
    kk_std_core_types__list_dup(_x_1, _ctx);
    _x_x863 = _x_1; /*list<string>*/
  }
  _b_x250_251 = kk_std_os_path_push_parts(_x_x861, _x_x863, _ctx); /*list<string>*/
  kk_string_t _x_x864;
  {
    kk_string_t _x = p1.root;
    kk_string_dup(_x, _ctx);
    kk_std_os_path__path_drop(p1, _ctx);
    _x_x864 = _x; /*string*/
  }
  kk_std_core_types__list _x_x865;
  kk_std_core_types__optional _match_x423 = kk_std_core_types__new_Optional(kk_std_core_types__list_box(_b_x250_251, _ctx), _ctx); /*? 7*/;
  if (kk_std_core_types__is_Optional(_match_x423, _ctx)) {
    kk_box_t _box_x252 = _match_x423._cons._Optional.value;
    kk_std_core_types__list _uniq_parts_807 = kk_std_core_types__list_unbox(_box_x252, KK_BORROWED, _ctx);
    kk_std_core_types__list_dup(_uniq_parts_807, _ctx);
    kk_std_core_types__optional_drop(_match_x423, _ctx);
    _x_x865 = _uniq_parts_807; /*list<string>*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x423, _ctx);
    _x_x865 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
  }
  return kk_std_os_path__new_Path(_x_x864, _x_x865, _ctx);
}
 
// Convenience function that adds two strings into a path.

kk_std_os_path__path kk_std_os_path_string_fs__lp__fs__rp_(kk_string_t p1, kk_string_t p2, kk_context_t* _ctx) { /* (p1 : string, p2 : string) -> path */ 
  kk_std_os_path__path p1_0_10126 = kk_std_os_path_path(p1, _ctx); /*std/os/path/path*/;
  kk_std_os_path__path p2_0_10127 = kk_std_os_path_path(p2, _ctx); /*std/os/path/path*/;
  kk_std_core_types__list _b_x253_254;
  kk_std_core_types__list _x_x866;
  kk_std_core_types__list _x_x867;
  {
    kk_std_core_types__list _x_0 = p2_0_10127.parts;
    kk_std_core_types__list_dup(_x_0, _ctx);
    kk_std_os_path__path_drop(p2_0_10127, _ctx);
    _x_x867 = _x_0; /*list<string>*/
  }
  _x_x866 = kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), _x_x867, _ctx); /*list<733>*/
  kk_std_core_types__list _x_x868;
  {
    kk_std_core_types__list _x_1 = p1_0_10126.parts;
    kk_std_core_types__list_dup(_x_1, _ctx);
    _x_x868 = _x_1; /*list<string>*/
  }
  _b_x253_254 = kk_std_os_path_push_parts(_x_x866, _x_x868, _ctx); /*list<string>*/
  kk_string_t _x_x869;
  {
    kk_string_t _x = p1_0_10126.root;
    kk_string_dup(_x, _ctx);
    kk_std_os_path__path_drop(p1_0_10126, _ctx);
    _x_x869 = _x; /*string*/
  }
  kk_std_core_types__list _x_x870;
  kk_std_core_types__optional _match_x422 = kk_std_core_types__new_Optional(kk_std_core_types__list_box(_b_x253_254, _ctx), _ctx); /*? 7*/;
  if (kk_std_core_types__is_Optional(_match_x422, _ctx)) {
    kk_box_t _box_x255 = _match_x422._cons._Optional.value;
    kk_std_core_types__list _uniq_parts_807 = kk_std_core_types__list_unbox(_box_x255, KK_BORROWED, _ctx);
    kk_std_core_types__list_dup(_uniq_parts_807, _ctx);
    kk_std_core_types__optional_drop(_match_x422, _ctx);
    _x_x870 = _uniq_parts_807; /*list<string>*/
  }
  else {
    kk_std_core_types__optional_drop(_match_x422, _ctx);
    _x_x870 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
  }
  return kk_std_os_path__new_Path(_x_x869, _x_x870, _ctx);
}
 
// Combine multiple paths using `(/)`.


// lift anonymous function
struct kk_std_os_path_combine_fun876__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_combine_fun876(kk_function_t _fself, kk_box_t _b_x262, kk_box_t _b_x263, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_combine_fun876(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_combine_fun876, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_combine_fun876(kk_function_t _fself, kk_box_t _b_x262, kk_box_t _b_x263, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x877;
  kk_std_os_path__path _x_x878 = kk_std_os_path__path_unbox(_b_x262, KK_OWNED, _ctx); /*std/os/path/path*/
  kk_std_os_path__path _x_x879 = kk_std_os_path__path_unbox(_b_x263, KK_OWNED, _ctx); /*std/os/path/path*/
  _x_x877 = kk_std_os_path__lp__fs__rp_(_x_x878, _x_x879, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x877, _ctx);
}

kk_std_os_path__path kk_std_os_path_combine(kk_std_core_types__list ps, kk_context_t* _ctx) { /* (ps : list<path>) -> path */ 
  if (kk_std_core_types__is_Nil(ps, _ctx)) {
    kk_string_t _x_x871;
    kk_std_core_types__optional _match_x421 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
    if (kk_std_core_types__is_Optional(_match_x421, _ctx)) {
      kk_box_t _box_x256 = _match_x421._cons._Optional.value;
      kk_string_t _uniq_root_801 = kk_string_unbox(_box_x256);
      kk_string_dup(_uniq_root_801, _ctx);
      kk_std_core_types__optional_drop(_match_x421, _ctx);
      _x_x871 = _uniq_root_801; /*string*/
    }
    else {
      kk_std_core_types__optional_drop(_match_x421, _ctx);
      _x_x871 = kk_string_empty(); /*string*/
    }
    kk_std_core_types__list _x_x873;
    kk_std_core_types__optional _match_x420 = kk_std_core_types__new_None(_ctx); /*forall<a> ? a*/;
    if (kk_std_core_types__is_Optional(_match_x420, _ctx)) {
      kk_box_t _box_x257 = _match_x420._cons._Optional.value;
      kk_std_core_types__list _uniq_parts_807 = kk_std_core_types__list_unbox(_box_x257, KK_BORROWED, _ctx);
      kk_std_core_types__list_dup(_uniq_parts_807, _ctx);
      kk_std_core_types__optional_drop(_match_x420, _ctx);
      _x_x873 = _uniq_parts_807; /*list<string>*/
    }
    else {
      kk_std_core_types__optional_drop(_match_x420, _ctx);
      _x_x873 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
    }
    return kk_std_os_path__new_Path(_x_x871, _x_x873, _ctx);
  }
  {
    struct kk_std_core_types_Cons* _con_x874 = kk_std_core_types__as_Cons(ps, _ctx);
    kk_box_t _box_x258 = _con_x874->head;
    kk_std_os_path__path p = kk_std_os_path__path_unbox(_box_x258, KK_BORROWED, _ctx);
    kk_std_core_types__list pp = _con_x874->tail;
    if kk_likely(kk_datatype_ptr_is_unique(ps, _ctx)) {
      kk_std_os_path__path_dup(p, _ctx);
      kk_box_drop(_box_x258, _ctx);
      kk_datatype_ptr_free(ps, _ctx);
    }
    else {
      kk_std_os_path__path_dup(p, _ctx);
      kk_std_core_types__list_dup(pp, _ctx);
      kk_datatype_ptr_decref(ps, _ctx);
    }
    kk_box_t _x_x875 = kk_std_core_list_foldl(pp, kk_std_os_path__path_box(p, _ctx), kk_std_os_path_new_combine_fun876(_ctx), _ctx); /*2053*/
    return kk_std_os_path__path_unbox(_x_x875, KK_OWNED, _ctx);
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path_string_fs__mlift_realpath_10198_fun881__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_string_fs__mlift_realpath_10198_fun881(kk_function_t _fself, kk_box_t _b_x269, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_string_fs__new_mlift_realpath_10198_fun881(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_string_fs__mlift_realpath_10198_fun881, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_string_fs__mlift_realpath_10198_fun881(kk_function_t _fself, kk_box_t _b_x269, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x882;
  kk_string_t _x_x883 = kk_string_unbox(_b_x269); /*string*/
  _x_x882 = kk_std_os_path_path(_x_x883, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x882, _ctx);
}

kk_std_os_path__path kk_std_os_path_string_fs__mlift_realpath_10198(kk_string_t _y_x10157, kk_context_t* _ctx) { /* (string) -> io path */ 
  kk_box_t _x_x880 = kk_std_core_hnd__open_none1(kk_std_os_path_string_fs__new_mlift_realpath_10198_fun881(_ctx), kk_string_box(_y_x10157), _ctx); /*2970*/
  return kk_std_os_path__path_unbox(_x_x880, KK_OWNED, _ctx);
}
 
// Convert a path to the absolute path on the file system.
// The overload on a plain string is necessary as it allows
// for unnormalized paths with `".."` parts. For example
// `"/foo/symlink/../test.txt"` may resolve to `"/bar/test.txt"` if
// ``symlink`` is a symbolic link to a sub directory of `"/bar"`.


// lift anonymous function
struct kk_std_os_path_string_fs_realpath_fun885__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_string_fs_realpath_fun885(kk_function_t _fself, kk_box_t _b_x273, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_string_fs_new_realpath_fun885(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_string_fs_realpath_fun885, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_string_fs_realpath_fun885(kk_function_t _fself, kk_box_t _b_x273, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x886;
  kk_string_t _x_x887 = kk_string_unbox(_b_x273); /*string*/
  _x_x886 = kk_std_os_path_string_fs__mlift_realpath_10198(_x_x887, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x886, _ctx);
}


// lift anonymous function
struct kk_std_os_path_string_fs_realpath_fun888__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_string_fs_realpath_fun888(kk_function_t _fself, kk_box_t _b_x276, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_string_fs_new_realpath_fun888(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_string_fs_realpath_fun888, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_string_fs_realpath_fun888(kk_function_t _fself, kk_box_t _b_x276, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x889;
  kk_string_t _x_x890 = kk_string_unbox(_b_x276); /*string*/
  _x_x889 = kk_std_os_path_path(_x_x890, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x889, _ctx);
}

kk_std_os_path__path kk_std_os_path_string_fs_realpath(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> io path */ 
  kk_string_t x_10230 = kk_std_os_path_xrealpath(s, _ctx); /*string*/;
  kk_box_t _x_x884;
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_10230, _ctx);
    _x_x884 = kk_std_core_hnd_yield_extend(kk_std_os_path_string_fs_new_realpath_fun885(_ctx), _ctx); /*3728*/
  }
  else {
    _x_x884 = kk_std_core_hnd__open_none1(kk_std_os_path_string_fs_new_realpath_fun888(_ctx), kk_string_box(x_10230), _ctx); /*3728*/
  }
  return kk_std_os_path__path_unbox(_x_x884, KK_OWNED, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_realpath_10199_fun892__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_realpath_10199_fun892(kk_function_t _fself, kk_box_t _b_x282, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_realpath_10199_fun892(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_realpath_10199_fun892, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_realpath_10199_fun892(kk_function_t _fself, kk_box_t _b_x282, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x893;
  kk_string_t _x_x894 = kk_string_unbox(_b_x282); /*string*/
  _x_x893 = kk_std_os_path_path(_x_x894, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x893, _ctx);
}

kk_std_os_path__path kk_std_os_path__mlift_realpath_10199(kk_string_t _y_x10158, kk_context_t* _ctx) { /* (string) -> io path */ 
  kk_box_t _x_x891 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_realpath_10199_fun892(_ctx), kk_string_box(_y_x10158), _ctx); /*2970*/
  return kk_std_os_path__path_unbox(_x_x891, KK_OWNED, _ctx);
}
 
// Convert a path to the absolute path on the file system.
// The path is not required to exist on disk. However, if it
// exists any permissions and symbolic links are resolved fully.
// `".".realpath` (to get the current working directory)
// `"/foo".realpath` (to resolve the full root, like `"c:/foo"` on windows)


// lift anonymous function
struct kk_std_os_path_realpath_fun896__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_realpath_fun896(kk_function_t _fself, kk_box_t _b_x287, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_realpath_fun896(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_realpath_fun896, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_realpath_fun896(kk_function_t _fself, kk_box_t _b_x287, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_string_t _x_x897;
  kk_std_os_path__path _x_x898 = kk_std_os_path__path_unbox(_b_x287, KK_OWNED, _ctx); /*std/os/path/path*/
  _x_x897 = kk_std_os_path_string(_x_x898, _ctx); /*string*/
  return kk_string_box(_x_x897);
}


// lift anonymous function
struct kk_std_os_path_realpath_fun900__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_realpath_fun900(kk_function_t _fself, kk_box_t _b_x291, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_realpath_fun900(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_realpath_fun900, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_realpath_fun900(kk_function_t _fself, kk_box_t _b_x291, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x901;
  kk_string_t _x_x902 = kk_string_unbox(_b_x291); /*string*/
  _x_x901 = kk_std_os_path__mlift_realpath_10199(_x_x902, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x901, _ctx);
}


// lift anonymous function
struct kk_std_os_path_realpath_fun903__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_realpath_fun903(kk_function_t _fself, kk_box_t _b_x294, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_realpath_fun903(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_realpath_fun903, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_realpath_fun903(kk_function_t _fself, kk_box_t _b_x294, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x904;
  kk_string_t _x_x905 = kk_string_unbox(_b_x294); /*string*/
  _x_x904 = kk_std_os_path_path(_x_x905, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x904, _ctx);
}

kk_std_os_path__path kk_std_os_path_realpath(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> io path */ 
  kk_string_t s_10082;
  kk_box_t _x_x895 = kk_std_core_hnd__open_none1(kk_std_os_path_new_realpath_fun896(_ctx), kk_std_os_path__path_box(p, _ctx), _ctx); /*2970*/
  s_10082 = kk_string_unbox(_x_x895); /*string*/
  kk_string_t x_10233 = kk_std_os_path_xrealpath(s_10082, _ctx); /*string*/;
  kk_box_t _x_x899;
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_10233, _ctx);
    _x_x899 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_realpath_fun900(_ctx), _ctx); /*3728*/
  }
  else {
    _x_x899 = kk_std_core_hnd__open_none1(kk_std_os_path_new_realpath_fun903(_ctx), kk_string_box(x_10233), _ctx); /*3728*/
  }
  return kk_std_os_path__path_unbox(_x_x899, KK_OWNED, _ctx);
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_cwd_10200_fun907__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_cwd_10200_fun907(kk_function_t _fself, kk_box_t _b_x300, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_cwd_10200_fun907(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_cwd_10200_fun907, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_cwd_10200_fun907(kk_function_t _fself, kk_box_t _b_x300, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x908;
  kk_string_t _x_x909 = kk_string_unbox(_b_x300); /*string*/
  _x_x908 = kk_std_os_path_path(_x_x909, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x908, _ctx);
}

kk_std_os_path__path kk_std_os_path__mlift_cwd_10200(kk_string_t _y_x10159, kk_context_t* _ctx) { /* (string) -> io path */ 
  kk_box_t _x_x906 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_cwd_10200_fun907(_ctx), kk_string_box(_y_x10159), _ctx); /*2970*/
  return kk_std_os_path__path_unbox(_x_x906, KK_OWNED, _ctx);
}
 
// Returns the current working directory.
// Equal to `".".realpath`.


// lift anonymous function
struct kk_std_os_path_cwd_fun913__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_cwd_fun913(kk_function_t _fself, kk_box_t _b_x304, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_cwd_fun913(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_cwd_fun913, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_cwd_fun913(kk_function_t _fself, kk_box_t _b_x304, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x914;
  kk_string_t _x_x915 = kk_string_unbox(_b_x304); /*string*/
  _x_x914 = kk_std_os_path__mlift_cwd_10200(_x_x915, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x914, _ctx);
}


// lift anonymous function
struct kk_std_os_path_cwd_fun916__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_cwd_fun916(kk_function_t _fself, kk_box_t _b_x307, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_cwd_fun916(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_cwd_fun916, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_cwd_fun916(kk_function_t _fself, kk_box_t _b_x307, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x917;
  kk_string_t _x_x918 = kk_string_unbox(_b_x307); /*string*/
  _x_x917 = kk_std_os_path_path(_x_x918, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x917, _ctx);
}

kk_std_os_path__path kk_std_os_path_cwd(kk_context_t* _ctx) { /* () -> io path */ 
  kk_string_t x_10236;
  kk_string_t _x_x910;
  kk_define_string_literal(, _s_x911, 1, ".", _ctx)
  _x_x910 = kk_string_dup(_s_x911, _ctx); /*string*/
  x_10236 = kk_std_os_path_xrealpath(_x_x910, _ctx); /*string*/
  kk_box_t _x_x912;
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_10236, _ctx);
    _x_x912 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_cwd_fun913(_ctx), _ctx); /*3728*/
  }
  else {
    _x_x912 = kk_std_core_hnd__open_none1(kk_std_os_path_new_cwd_fun916(_ctx), kk_string_box(x_10236), _ctx); /*3728*/
  }
  return kk_std_os_path__path_unbox(_x_x912, KK_OWNED, _ctx);
}
 
// If a path has no extension, set it to the provided one.

kk_std_os_path__path kk_std_os_path_default_ext(kk_std_os_path__path p, kk_string_t newext, kk_context_t* _ctx) { /* (p : path, newext : string) -> path */ 
  kk_std_core_types__tuple2 tuple2_10086;
  kk_std_core_types__maybe _match_x416;
  kk_string_t _x_x919;
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x920 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x311 = _con_x920->head;
      kk_std_core_types__list _pat_0_0_0 = _con_x920->tail;
      kk_string_t x_0 = kk_string_unbox(_box_x311);
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0_0, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_string_dup(x_0, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _x_x919 = x_0; /*string*/
    }
    else {
      _x_x919 = kk_string_empty(); /*string*/
    }
  }
  kk_string_t _x_x922;
  kk_define_string_literal(, _s_x923, 1, ".", _ctx)
  _x_x922 = kk_string_dup(_s_x923, _ctx); /*string*/
  _match_x416 = kk_std_core_sslice_find_last(_x_x919, _x_x922, _ctx); /*maybe<sslice/sslice>*/
  if (kk_std_core_types__is_Just(_match_x416, _ctx)) {
    kk_box_t _box_x313 = _match_x416._cons.Just.value;
    kk_std_core_sslice__sslice slice = kk_std_core_sslice__sslice_unbox(_box_x313, KK_BORROWED, _ctx);
    kk_std_core_sslice__sslice_dup(slice, _ctx);
    kk_std_core_types__maybe_drop(_match_x416, _ctx);
    kk_string_t _b_x314_320;
    kk_std_core_sslice__sslice _x_x924;
    {
      kk_string_t s = slice.str;
      kk_integer_t start = slice.start;
      kk_string_dup(s, _ctx);
      kk_integer_dup(start, _ctx);
      _x_x924 = kk_std_core_sslice__new_Sslice(s, kk_integer_from_small(0), start, _ctx); /*sslice/sslice*/
    }
    _b_x314_320 = kk_std_core_sslice_string(_x_x924, _ctx); /*string*/
    kk_string_t _b_x315_321;
    kk_std_core_sslice__sslice _x_x925 = kk_std_core_sslice_after(slice, _ctx); /*sslice/sslice*/
    _b_x315_321 = kk_std_core_sslice_string(_x_x925, _ctx); /*string*/
    tuple2_10086 = kk_std_core_types__new_Tuple2(kk_string_box(_b_x314_320), kk_string_box(_b_x315_321), _ctx); /*(string, string)*/
  }
  else {
    kk_box_t _x_x926;
    kk_string_t _x_x927;
    {
      kk_std_core_types__list _x_0 = p.parts;
      kk_std_core_types__list_dup(_x_0, _ctx);
      if (kk_std_core_types__is_Cons(_x_0, _ctx)) {
        struct kk_std_core_types_Cons* _con_x928 = kk_std_core_types__as_Cons(_x_0, _ctx);
        kk_box_t _box_x316 = _con_x928->head;
        kk_std_core_types__list _pat_0_0_0_0 = _con_x928->tail;
        kk_string_t x_0_0 = kk_string_unbox(_box_x316);
        if kk_likely(kk_datatype_ptr_is_unique(_x_0, _ctx)) {
          kk_std_core_types__list_drop(_pat_0_0_0_0, _ctx);
          kk_datatype_ptr_free(_x_0, _ctx);
        }
        else {
          kk_string_dup(x_0_0, _ctx);
          kk_datatype_ptr_decref(_x_0, _ctx);
        }
        _x_x927 = x_0_0; /*string*/
      }
      else {
        _x_x927 = kk_string_empty(); /*string*/
      }
    }
    _x_x926 = kk_string_box(_x_x927); /*129*/
    kk_box_t _x_x930;
    kk_string_t _x_x931 = kk_string_empty(); /*string*/
    _x_x930 = kk_string_box(_x_x931); /*130*/
    tuple2_10086 = kk_std_core_types__new_Tuple2(_x_x926, _x_x930, _ctx); /*(string, string)*/
  }
  bool _match_x415;
  kk_string_t _x_x933;
  {
    kk_box_t _box_x324 = tuple2_10086.fst;
    kk_box_t _box_x325 = tuple2_10086.snd;
    kk_string_t _x_0_0 = kk_string_unbox(_box_x325);
    kk_string_dup(_x_0_0, _ctx);
    kk_std_core_types__tuple2_drop(tuple2_10086, _ctx);
    _x_x933 = _x_0_0; /*string*/
  }
  kk_string_t _x_x934 = kk_string_empty(); /*string*/
  _match_x415 = kk_string_is_eq(_x_x933,_x_x934,kk_context()); /*bool*/
  if (_match_x415) {
    return kk_std_os_path_change_ext(p, newext, _ctx);
  }
  {
    kk_string_drop(newext, _ctx);
    return p;
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_homedir_10201_fun937__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_homedir_10201_fun937(kk_function_t _fself, kk_box_t _b_x328, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_homedir_10201_fun937(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_homedir_10201_fun937, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_homedir_10201_fun937(kk_function_t _fself, kk_box_t _b_x328, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x938;
  kk_string_t _x_x939 = kk_string_unbox(_b_x328); /*string*/
  _x_x938 = kk_std_os_path_path(_x_x939, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x938, _ctx);
}

kk_std_os_path__path kk_std_os_path__mlift_homedir_10201(kk_string_t _y_x10160, kk_context_t* _ctx) { /* (string) -> io path */ 
  kk_box_t _x_x936 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_homedir_10201_fun937(_ctx), kk_string_box(_y_x10160), _ctx); /*2970*/
  return kk_std_os_path__path_unbox(_x_x936, KK_OWNED, _ctx);
}
 
// Return the home directory of the current user.


// lift anonymous function
struct kk_std_os_path_homedir_fun941__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_homedir_fun941(kk_function_t _fself, kk_box_t _b_x332, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_homedir_fun941(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_homedir_fun941, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_homedir_fun941(kk_function_t _fself, kk_box_t _b_x332, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x942;
  kk_string_t _x_x943 = kk_string_unbox(_b_x332); /*string*/
  _x_x942 = kk_std_os_path__mlift_homedir_10201(_x_x943, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x942, _ctx);
}


// lift anonymous function
struct kk_std_os_path_homedir_fun944__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_homedir_fun944(kk_function_t _fself, kk_box_t _b_x335, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_homedir_fun944(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_homedir_fun944, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_homedir_fun944(kk_function_t _fself, kk_box_t _b_x335, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x945;
  kk_string_t _x_x946 = kk_string_unbox(_b_x335); /*string*/
  _x_x945 = kk_std_os_path_path(_x_x946, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x945, _ctx);
}

kk_std_os_path__path kk_std_os_path_homedir(kk_context_t* _ctx) { /* () -> io path */ 
  kk_string_t x_10239 = kk_std_os_path_xhomedir(_ctx); /*string*/;
  kk_box_t _x_x940;
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_10239, _ctx);
    _x_x940 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_homedir_fun941(_ctx), _ctx); /*3728*/
  }
  else {
    _x_x940 = kk_std_core_hnd__open_none1(kk_std_os_path_new_homedir_fun944(_ctx), kk_string_box(x_10239), _ctx); /*3728*/
  }
  return kk_std_os_path__path_unbox(_x_x940, KK_OWNED, _ctx);
}


// lift anonymous function
struct kk_std_os_path__trmc_paths_collect_fun963__t {
  struct kk_function_s _base;
};
static kk_std_core_types__maybe kk_std_os_path__trmc_paths_collect_fun963(kk_function_t _fself, kk_char_t _b_x341, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_trmc_paths_collect_fun963(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__trmc_paths_collect_fun963, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_std_core_types__maybe kk_std_os_path__trmc_paths_collect_fun963(kk_function_t _fself, kk_char_t _b_x341, kk_context_t* _ctx) {
  kk_unused(_fself);
  return kk_std_core_types__new_Just(kk_char_box(_b_x341, _ctx), _ctx);
}

kk_std_core_types__list kk_std_os_path__trmc_paths_collect(kk_std_core_types__list ps, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* (ps : list<string>, ctx<list<path>>) -> list<path> */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(ps, _ctx)) {
    struct kk_std_core_types_Cons* _con_x955 = kk_std_core_types__as_Cons(ps, _ctx);
    kk_box_t _box_x339 = _con_x955->head;
    kk_std_core_types__list _pat_0 = _con_x955->tail;
    if (kk_std_core_types__is_Cons(_pat_0, _ctx)) {
      struct kk_std_core_types_Cons* _con_x956 = kk_std_core_types__as_Cons(_pat_0, _ctx);
      kk_box_t _box_x340 = _con_x956->head;
      kk_string_t root = kk_string_unbox(_box_x339);
      kk_string_t part = kk_string_unbox(_box_x340);
      bool _match_x410;
      kk_integer_t _brw_x412;
      kk_string_t _x_x957 = kk_string_dup(root, _ctx); /*string*/
      _brw_x412 = kk_std_core_string_count(_x_x957, _ctx); /*int*/
      bool _brw_x413 = kk_integer_eq_borrow(_brw_x412,(kk_integer_from_small(1)),kk_context()); /*bool*/;
      kk_integer_drop(_brw_x412, _ctx);
      _match_x410 = _brw_x413; /*bool*/
      bool _x_x958;
      if (_match_x410) {
        kk_std_core_types__maybe m_10093;
        kk_std_core_sslice__sslice _x_x959;
        kk_string_t _x_x960 = kk_string_dup(root, _ctx); /*string*/
        kk_integer_t _x_x961;
        kk_string_t _x_x962 = kk_string_dup(root, _ctx); /*string*/
        _x_x961 = kk_string_len_int(_x_x962,kk_context()); /*int*/
        _x_x959 = kk_std_core_sslice__new_Sslice(_x_x960, kk_integer_from_small(0), _x_x961, _ctx); /*sslice/sslice*/
        m_10093 = kk_std_core_sslice_foreach_while(_x_x959, kk_std_os_path__new_trmc_paths_collect_fun963(_ctx), _ctx); /*maybe<char>*/
        bool _match_x411;
        kk_char_t _x_x964;
        if (kk_std_core_types__is_Nothing(m_10093, _ctx)) {
          _x_x964 = ' '; /*char*/
        }
        else {
          kk_box_t _box_x342 = m_10093._cons.Just.value;
          kk_char_t x = kk_char_unbox(_box_x342, KK_BORROWED, _ctx);
          kk_std_core_types__maybe_drop(m_10093, _ctx);
          _x_x964 = x; /*char*/
        }
        _match_x411 = kk_std_core_char_is_alpha(_x_x964, _ctx); /*bool*/
        if (_match_x411) {
          bool b_10096;
          kk_string_t _x_x965 = kk_string_dup(part, _ctx); /*string*/
          kk_string_t _x_x966 = kk_string_empty(); /*string*/
          b_10096 = kk_string_is_eq(_x_x965,_x_x966,kk_context()); /*bool*/
          if (b_10096) {
            _x_x958 = false; /*bool*/
          }
          else {
            kk_string_t _x_x968;
            kk_define_string_literal(, _s_x969, 2, "/\\", _ctx)
            _x_x968 = kk_string_dup(_s_x969, _ctx); /*string*/
            kk_string_t _x_x970;
            kk_string_t _x_x971 = kk_string_dup(part, _ctx); /*string*/
            _x_x970 = kk_std_core_sslice_head(_x_x971, _ctx); /*string*/
            _x_x958 = kk_string_contains(_x_x968,_x_x970,kk_context()); /*bool*/
          }
        }
        else {
          _x_x958 = false; /*bool*/
        }
      }
      else {
        _x_x958 = false; /*bool*/
      }
      if (_x_x958) {
        kk_std_core_types__list rest = _con_x956->tail;
        kk_reuse_t _ru_x505 = kk_reuse_null; /*@reuse*/;
        if kk_likely(kk_datatype_ptr_is_unique(ps, _ctx)) {
          if kk_likely(kk_datatype_ptr_is_unique(_pat_0, _ctx)) {
            kk_datatype_ptr_free(_pat_0, _ctx);
          }
          else {
            kk_string_dup(part, _ctx);
            kk_std_core_types__list_dup(rest, _ctx);
            kk_datatype_ptr_decref(_pat_0, _ctx);
          }
          _ru_x505 = (kk_datatype_ptr_reuse(ps, _ctx));
        }
        else {
          kk_string_dup(part, _ctx);
          kk_std_core_types__list_dup(rest, _ctx);
          kk_string_dup(root, _ctx);
          kk_datatype_ptr_decref(ps, _ctx);
        }
        kk_std_os_path__path _trmc_x10132;
        kk_string_t _x_x972;
        kk_string_t _x_x973;
        kk_string_t _x_x974;
        kk_define_string_literal(, _s_x975, 1, ":", _ctx)
        _x_x974 = kk_string_dup(_s_x975, _ctx); /*string*/
        _x_x973 = kk_std_core_types__lp__plus__plus__rp_(_x_x974, part, _ctx); /*string*/
        _x_x972 = kk_std_core_types__lp__plus__plus__rp_(root, _x_x973, _ctx); /*string*/
        _trmc_x10132 = kk_std_os_path_path(_x_x972, _ctx); /*std/os/path/path*/
        kk_std_core_types__list _trmc_x10133 = kk_datatype_null(); /*list<std/os/path/path>*/;
        kk_std_core_types__list _trmc_x10134 = kk_std_core_types__new_Cons(_ru_x505, 0, kk_std_os_path__path_box(_trmc_x10132, _ctx), _trmc_x10133, _ctx); /*list<std/os/path/path>*/;
        kk_field_addr_t _b_x352_368 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10134, _ctx)->tail, _ctx); /*@field-addr<list<std/os/path/path>>*/;
        { // tailcall
          kk_std_core_types__cctx _x_x976 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10134, _ctx)),_b_x352_368,kk_context()); /*ctx<0>*/
          ps = rest;
          _acc = _x_x976;
          goto kk__tailcall;
        }
      }
    }
  }
  if (kk_std_core_types__is_Cons(ps, _ctx)) {
    struct kk_std_core_types_Cons* _con_x977 = kk_std_core_types__as_Cons(ps, _ctx);
    kk_box_t _box_x353 = _con_x977->head;
    kk_std_core_types__list rest_0 = _con_x977->tail;
    kk_string_t part_0 = kk_string_unbox(_box_x353);
    kk_reuse_t _ru_x506 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(ps, _ctx)) {
      _ru_x506 = (kk_datatype_ptr_reuse(ps, _ctx));
    }
    else {
      kk_string_dup(part_0, _ctx);
      kk_std_core_types__list_dup(rest_0, _ctx);
      kk_datatype_ptr_decref(ps, _ctx);
    }
    kk_std_os_path__path _trmc_x10135 = kk_std_os_path_path(part_0, _ctx); /*std/os/path/path*/;
    kk_std_core_types__list _trmc_x10136 = kk_datatype_null(); /*list<std/os/path/path>*/;
    kk_std_core_types__list _trmc_x10137 = kk_std_core_types__new_Cons(_ru_x506, 0, kk_std_os_path__path_box(_trmc_x10135, _ctx), _trmc_x10136, _ctx); /*list<std/os/path/path>*/;
    kk_field_addr_t _b_x363_374 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10137, _ctx)->tail, _ctx); /*@field-addr<list<std/os/path/path>>*/;
    { // tailcall
      kk_std_core_types__cctx _x_x978 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10137, _ctx)),_b_x363_374,kk_context()); /*ctx<0>*/
      ps = rest_0;
      _acc = _x_x978;
      goto kk__tailcall;
    }
  }
  {
    kk_box_t _x_x979 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x979, KK_OWNED, _ctx);
  }
}

kk_std_core_types__list kk_std_os_path_paths_collect(kk_std_core_types__list ps_0, kk_context_t* _ctx) { /* (ps : list<string>) -> list<path> */ 
  kk_std_core_types__cctx _x_x980 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_os_path__trmc_paths_collect(ps_0, _x_x980, _ctx);
}
 
// Return the stem name of path.
// `"/foo/bar.svg.txt".path.extname === "foo.svg"`

kk_string_t kk_std_os_path_stemname(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> string */ 
  kk_std_core_types__tuple2 tuple2_10100;
  kk_std_core_types__maybe _match_x409;
  kk_string_t _x_x989;
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    if (kk_std_core_types__is_Cons(_x, _ctx)) {
      struct kk_std_core_types_Cons* _con_x990 = kk_std_core_types__as_Cons(_x, _ctx);
      kk_box_t _box_x380 = _con_x990->head;
      kk_std_core_types__list _pat_0_0_0 = _con_x990->tail;
      kk_string_t x_0 = kk_string_unbox(_box_x380);
      if kk_likely(kk_datatype_ptr_is_unique(_x, _ctx)) {
        kk_std_core_types__list_drop(_pat_0_0_0, _ctx);
        kk_datatype_ptr_free(_x, _ctx);
      }
      else {
        kk_string_dup(x_0, _ctx);
        kk_datatype_ptr_decref(_x, _ctx);
      }
      _x_x989 = x_0; /*string*/
    }
    else {
      _x_x989 = kk_string_empty(); /*string*/
    }
  }
  kk_string_t _x_x992;
  kk_define_string_literal(, _s_x993, 1, ".", _ctx)
  _x_x992 = kk_string_dup(_s_x993, _ctx); /*string*/
  _match_x409 = kk_std_core_sslice_find_last(_x_x989, _x_x992, _ctx); /*maybe<sslice/sslice>*/
  if (kk_std_core_types__is_Just(_match_x409, _ctx)) {
    kk_box_t _box_x382 = _match_x409._cons.Just.value;
    kk_std_core_sslice__sslice slice = kk_std_core_sslice__sslice_unbox(_box_x382, KK_BORROWED, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    kk_std_core_sslice__sslice_dup(slice, _ctx);
    kk_std_core_types__maybe_drop(_match_x409, _ctx);
    kk_string_t _b_x383_389;
    kk_std_core_sslice__sslice _x_x994;
    {
      kk_string_t s = slice.str;
      kk_integer_t start = slice.start;
      kk_string_dup(s, _ctx);
      kk_integer_dup(start, _ctx);
      _x_x994 = kk_std_core_sslice__new_Sslice(s, kk_integer_from_small(0), start, _ctx); /*sslice/sslice*/
    }
    _b_x383_389 = kk_std_core_sslice_string(_x_x994, _ctx); /*string*/
    kk_string_t _b_x384_390;
    kk_std_core_sslice__sslice _x_x995 = kk_std_core_sslice_after(slice, _ctx); /*sslice/sslice*/
    _b_x384_390 = kk_std_core_sslice_string(_x_x995, _ctx); /*string*/
    tuple2_10100 = kk_std_core_types__new_Tuple2(kk_string_box(_b_x383_389), kk_string_box(_b_x384_390), _ctx); /*(string, string)*/
  }
  else {
    kk_box_t _x_x996;
    kk_string_t _x_x997;
    {
      kk_std_core_types__list _x_0 = p.parts;
      kk_std_core_types__list_dup(_x_0, _ctx);
      kk_std_os_path__path_drop(p, _ctx);
      if (kk_std_core_types__is_Cons(_x_0, _ctx)) {
        struct kk_std_core_types_Cons* _con_x998 = kk_std_core_types__as_Cons(_x_0, _ctx);
        kk_box_t _box_x385 = _con_x998->head;
        kk_std_core_types__list _pat_0_0_0_0 = _con_x998->tail;
        kk_string_t x_0_0 = kk_string_unbox(_box_x385);
        if kk_likely(kk_datatype_ptr_is_unique(_x_0, _ctx)) {
          kk_std_core_types__list_drop(_pat_0_0_0_0, _ctx);
          kk_datatype_ptr_free(_x_0, _ctx);
        }
        else {
          kk_string_dup(x_0_0, _ctx);
          kk_datatype_ptr_decref(_x_0, _ctx);
        }
        _x_x997 = x_0_0; /*string*/
      }
      else {
        _x_x997 = kk_string_empty(); /*string*/
      }
    }
    _x_x996 = kk_string_box(_x_x997); /*129*/
    kk_box_t _x_x1000;
    kk_string_t _x_x1001 = kk_string_empty(); /*string*/
    _x_x1000 = kk_string_box(_x_x1001); /*130*/
    tuple2_10100 = kk_std_core_types__new_Tuple2(_x_x996, _x_x1000, _ctx); /*(string, string)*/
  }
  {
    kk_box_t _box_x393 = tuple2_10100.fst;
    kk_box_t _box_x394 = tuple2_10100.snd;
    kk_string_t _x_0_0 = kk_string_unbox(_box_x393);
    kk_string_dup(_x_0_0, _ctx);
    kk_std_core_types__tuple2_drop(tuple2_10100, _ctx);
    return _x_0_0;
  }
}
 
// monadic lift


// lift anonymous function
struct kk_std_os_path__mlift_tempdir_10202_fun1004__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path__mlift_tempdir_10202_fun1004(kk_function_t _fself, kk_box_t _b_x397, kk_context_t* _ctx);
static kk_function_t kk_std_os_path__new_mlift_tempdir_10202_fun1004(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path__mlift_tempdir_10202_fun1004, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path__mlift_tempdir_10202_fun1004(kk_function_t _fself, kk_box_t _b_x397, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x1005;
  kk_string_t _x_x1006 = kk_string_unbox(_b_x397); /*string*/
  _x_x1005 = kk_std_os_path_path(_x_x1006, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x1005, _ctx);
}

kk_std_os_path__path kk_std_os_path__mlift_tempdir_10202(kk_string_t _y_x10161, kk_context_t* _ctx) { /* (string) -> io path */ 
  kk_box_t _x_x1003 = kk_std_core_hnd__open_none1(kk_std_os_path__new_mlift_tempdir_10202_fun1004(_ctx), kk_string_box(_y_x10161), _ctx); /*2970*/
  return kk_std_os_path__path_unbox(_x_x1003, KK_OWNED, _ctx);
}
 
// Return the temporary directory for the current user.


// lift anonymous function
struct kk_std_os_path_tempdir_fun1008__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_tempdir_fun1008(kk_function_t _fself, kk_box_t _b_x401, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_tempdir_fun1008(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_tempdir_fun1008, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_tempdir_fun1008(kk_function_t _fself, kk_box_t _b_x401, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x1009;
  kk_string_t _x_x1010 = kk_string_unbox(_b_x401); /*string*/
  _x_x1009 = kk_std_os_path__mlift_tempdir_10202(_x_x1010, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x1009, _ctx);
}


// lift anonymous function
struct kk_std_os_path_tempdir_fun1011__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_path_tempdir_fun1011(kk_function_t _fself, kk_box_t _b_x404, kk_context_t* _ctx);
static kk_function_t kk_std_os_path_new_tempdir_fun1011(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_path_tempdir_fun1011, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_path_tempdir_fun1011(kk_function_t _fself, kk_box_t _b_x404, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_std_os_path__path _x_x1012;
  kk_string_t _x_x1013 = kk_string_unbox(_b_x404); /*string*/
  _x_x1012 = kk_std_os_path_path(_x_x1013, _ctx); /*std/os/path/path*/
  return kk_std_os_path__path_box(_x_x1012, _ctx);
}

kk_std_os_path__path kk_std_os_path_tempdir(kk_context_t* _ctx) { /* () -> io path */ 
  kk_string_t x_10242 = kk_std_os_path_xtempdir(_ctx); /*string*/;
  kk_box_t _x_x1007;
  if (kk_yielding(kk_context())) {
    kk_string_drop(x_10242, _ctx);
    _x_x1007 = kk_std_core_hnd_yield_extend(kk_std_os_path_new_tempdir_fun1008(_ctx), _ctx); /*3728*/
  }
  else {
    _x_x1007 = kk_std_core_hnd__open_none1(kk_std_os_path_new_tempdir_fun1011(_ctx), kk_string_box(x_10242), _ctx); /*3728*/
  }
  return kk_std_os_path__path_unbox(_x_x1007, KK_OWNED, _ctx);
}

// initialization
void kk_std_os_path__init(kk_context_t* _ctx){
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
  kk_std_text_parse__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
}

// termination
void kk_std_os_path__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_text_parse__done(_ctx);
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
