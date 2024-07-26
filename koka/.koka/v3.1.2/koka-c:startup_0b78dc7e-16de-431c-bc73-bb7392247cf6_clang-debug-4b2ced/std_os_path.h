#pragma once
#ifndef kk_std_os_path_H
#define kk_std_os_path_H
// Koka generated module: std/os/path, koka version: 3.1.2, platform: 64-bit
#include <kklib.h>
#include "std_core_types.h"
#include "std_core_hnd.h"
#include "std_core_exn.h"
#include "std_core_bool.h"
#include "std_core_order.h"
#include "std_core_char.h"
#include "std_core_int.h"
#include "std_core_vector.h"
#include "std_core_string.h"
#include "std_core_sslice.h"
#include "std_core_list.h"
#include "std_core_maybe.h"
#include "std_core_either.h"
#include "std_core_tuple.h"
#include "std_core_show.h"
#include "std_core_debug.h"
#include "std_core_delayed.h"
#include "std_core_console.h"
#include "std_core.h"
#include "std_text_parse.h"

// type declarations

// value type std/os/path/path
struct kk_std_os_path_Path {
  kk_string_t root;
  kk_std_core_types__list parts;
};
typedef struct kk_std_os_path_Path kk_std_os_path__path;
static inline kk_std_os_path__path kk_std_os_path__new_Path(kk_string_t root, kk_std_core_types__list parts, kk_context_t* _ctx) {
  kk_std_os_path__path _con;
  _con.root = root;
  _con.parts = parts;
  return _con;
}
static inline bool kk_std_os_path__is_Path(kk_std_os_path__path x, kk_context_t* _ctx) {
  return (true);
}
static inline kk_std_os_path__path kk_std_os_path__path_dup(kk_std_os_path__path _x, kk_context_t* _ctx) {
  kk_string_dup(_x.root, _ctx);
  kk_std_core_types__list_dup(_x.parts, _ctx);
  return _x;
}
static inline void kk_std_os_path__path_drop(kk_std_os_path__path _x, kk_context_t* _ctx) {
  kk_string_drop(_x.root, _ctx);
  kk_std_core_types__list_drop(_x.parts, _ctx);
}
static inline kk_box_t kk_std_os_path__path_box(kk_std_os_path__path _x, kk_context_t* _ctx) {
  kk_box_t _box;
  kk_valuetype_box(kk_std_os_path__path, _box, _x, 2 /* scan count */, _ctx);
  return _box;
}
static inline kk_std_os_path__path kk_std_os_path__path_unbox(kk_box_t _x, kk_borrow_t _borrow, kk_context_t* _ctx) {
  kk_std_os_path__path _unbox;
  kk_valuetype_unbox(kk_std_os_path__path, _unbox, _x, _borrow, _ctx);
  return _unbox;
}

// value declarations
 
// Automatically generated. Retrieves the `root` constructor field of the `:path` type.

static inline kk_string_t kk_std_os_path_path_fs_root(kk_std_os_path__path path_0, kk_context_t* _ctx) { /* (path : path) -> string */ 
  {
    kk_string_t _x = path_0.root;
    return kk_string_dup(_x, _ctx);
  }
}
 
// Automatically generated. Retrieves the `parts` constructor field of the `:path` type.

static inline kk_std_core_types__list kk_std_os_path_path_fs_parts(kk_std_os_path__path path_0, kk_context_t* _ctx) { /* (path : path) -> list<string> */ 
  {
    kk_std_core_types__list _x = path_0.parts;
    return kk_std_core_types__list_dup(_x, _ctx);
  }
}

kk_std_os_path__path kk_std_os_path_path_fs__copy(kk_std_os_path__path _this, kk_std_core_types__optional root, kk_std_core_types__optional parts, kk_context_t* _ctx); /* (path, root : ? string, parts : ? (list<string>)) -> path */ 

kk_string_t kk_std_os_path_xapp_path(kk_context_t* _ctx); /* () -> io string */ 

kk_string_t kk_std_os_path_basename(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> string */ 

kk_std_os_path__path kk_std_os_path_nobase(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> path */ 

kk_std_core_types__tuple2 kk_std_os_path_split_parts(kk_std_core_types__list parts, kk_context_t* _ctx); /* (parts : list<string>) -> (string, list<string>) */ 

kk_string_t kk_std_os_path_xrealpath(kk_string_t p, kk_context_t* _ctx); /* (p : string) -> io string */ 

kk_string_t kk_std_os_path_dirname(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> string */ 
 
// Return a list of all directory components (excluding the root but including the basename).
// `"/foo/bar/test.txt".path.dirparts === ["foo","bar","test.txt"]`

static inline kk_std_core_types__list kk_std_os_path_dirparts(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> list<string> */ 
  kk_std_core_types__list _x_x531;
  {
    kk_std_core_types__list _x = p.parts;
    kk_std_core_types__list_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    _x_x531 = _x; /*list<string>*/
  }
  return kk_std_core_list__lift_reverse_append_4790(kk_std_core_types__new_Nil(_ctx), _x_x531, _ctx);
}

kk_string_t kk_std_os_path_xhomedir(kk_context_t* _ctx); /* () -> io string */ 

kk_std_os_path__path kk_std_os_path_nodir(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> path */ 

kk_string_t kk_std_os_path_parentname(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> string */ 

kk_string_t kk_std_os_path_partsep(kk_context_t* _ctx); /* () -> ndet string */ 

kk_string_t kk_std_os_path_pathsep(kk_context_t* _ctx); /* () -> ndet string */ 
 
// Return the root name of path.
// `"c:\\foo".path.rootname === "c:/"`
// `"/foo".path.rootname === "/"`

static inline kk_string_t kk_std_os_path_rootname(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> string */ 
  {
    kk_string_t _x = p.root;
    kk_string_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    return _x;
  }
}

kk_string_t kk_std_os_path_xtempdir(kk_context_t* _ctx); /* () -> io string */ 

bool kk_std_os_path_is_empty(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> bool */ 

kk_std_os_path__path kk_std_os_path__lp__bar__bar__rp_(kk_std_os_path__path p1, kk_std_os_path__path p2, kk_context_t* _ctx); /* (p1 : path, p2 : path) -> path */ 

kk_std_core_types__list kk_std_os_path_push_part(kk_string_t dir, kk_std_core_types__list dirs, kk_context_t* _ctx); /* (dir : string, dirs : list<string>) -> list<string> */ 

kk_std_core_types__list kk_std_os_path_push_parts(kk_std_core_types__list parts, kk_std_core_types__list dirs, kk_context_t* _ctx); /* (parts : list<string>, dirs : list<string>) -> list<string> */ 
 
// monadic lift

static inline bool kk_std_os_path__mlift_proot_10188(kk_char_t wild___4, kk_context_t* _ctx) { /* (wild_@4 : char) -> std/text/parse/parse bool */ 
  return false;
}
 
// monadic lift

static inline bool kk_std_os_path__mlift_proot_10189(kk_unit_t wild___5, kk_context_t* _ctx) { /* (wild_@5 : ()) -> std/text/parse/parse bool */ 
  return true;
}
 
// monadic lift

static inline kk_unit_t kk_std_os_path__mlift_proot_10190(kk_char_t wild___0, kk_context_t* _ctx) { /* (wild_@0 : char) -> std/text/parse/parse () */ 
  kk_Unit; return kk_Unit;
}

kk_unit_t kk_std_os_path__mlift_proot_10191(kk_char_t wild__, kk_context_t* _ctx); /* (wild_ : char) -> std/text/parse/parse () */ 
 
// monadic lift

static inline kk_unit_t kk_std_os_path__mlift_proot_10192(kk_std_core_types__list _y_x10147, kk_context_t* _ctx) { /* (list<char>) -> std/text/parse/parse () */ 
  kk_std_core_types__list_drop(_y_x10147, _ctx);
  kk_Unit; return kk_Unit;
}

kk_unit_t kk_std_os_path__mlift_proot_10193(kk_char_t _y_x10145, kk_context_t* _ctx); /* (char) -> std/text/parse/parse () */ 

kk_unit_t kk_std_os_path__mlift_proot_10194(kk_char_t wild___1, kk_context_t* _ctx); /* (wild_@1 : char) -> std/text/parse/parse () */ 

bool kk_std_os_path__mlift_proot_10195(kk_unit_t wild___3, kk_context_t* _ctx); /* (wild_@3 : ()) -> std/text/parse/parse bool */ 

bool kk_std_os_path_proot(kk_context_t* _ctx); /* () -> std/text/parse/parse bool */ 

kk_string_t kk_std_os_path_string(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> string */ 
 
// A `:path` represents a file system path.

static inline kk_std_os_path__path kk_std_os_path__create_Path(kk_std_core_types__optional root, kk_std_core_types__optional parts, kk_context_t* _ctx) { /* (root : ? string, parts : ? (list<string>)) -> path */ 
  kk_string_t _x_x629;
  if (kk_std_core_types__is_Optional(root, _ctx)) {
    kk_box_t _box_x79 = root._cons._Optional.value;
    kk_string_t _uniq_root_801 = kk_string_unbox(_box_x79);
    kk_string_dup(_uniq_root_801, _ctx);
    kk_std_core_types__optional_drop(root, _ctx);
    _x_x629 = _uniq_root_801; /*string*/
  }
  else {
    kk_std_core_types__optional_drop(root, _ctx);
    _x_x629 = kk_string_empty(); /*string*/
  }
  kk_std_core_types__list _x_x631;
  if (kk_std_core_types__is_Optional(parts, _ctx)) {
    kk_box_t _box_x80 = parts._cons._Optional.value;
    kk_std_core_types__list _uniq_parts_807 = kk_std_core_types__list_unbox(_box_x80, KK_BORROWED, _ctx);
    kk_std_core_types__list_dup(_uniq_parts_807, _ctx);
    kk_std_core_types__optional_drop(parts, _ctx);
    _x_x631 = _uniq_parts_807; /*list<string>*/
  }
  else {
    kk_std_core_types__optional_drop(parts, _ctx);
    _x_x631 = kk_std_core_types__new_Nil(_ctx); /*list<string>*/
  }
  return kk_std_os_path__new_Path(_x_x629, _x_x631, _ctx);
}

kk_std_os_path__path kk_std_os_path_path_parts(kk_string_t root, kk_string_t s, kk_std_core_types__optional dirs, kk_context_t* _ctx); /* (root : string, s : string, dirs : ? (list<string>)) -> path */ 

kk_std_os_path__path kk_std_os_path_path(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> path */ 

kk_std_os_path__path kk_std_os_path__lp__fs__rp_(kk_std_os_path__path p1, kk_std_os_path__path p2, kk_context_t* _ctx); /* (p1 : path, p2 : path) -> path */ 

kk_std_os_path__path kk_std_os_path__mlift_app_path_10196(kk_string_t _y_x10153, kk_context_t* _ctx); /* (string) -> io path */ 

kk_std_os_path__path kk_std_os_path_app_path(kk_context_t* _ctx); /* () -> io path */ 

kk_std_os_path__path kk_std_os_path__mlift_appdir_10197(kk_string_t _y_x10154, kk_context_t* _ctx); /* (string) -> io path */ 

kk_std_os_path__path kk_std_os_path_appdir(kk_context_t* _ctx); /* () -> io path */ 

kk_std_os_path__path kk_std_os_path_change_base(kk_std_os_path__path p, kk_string_t basename_0, kk_context_t* _ctx); /* (p : path, basename : string) -> path */ 

kk_std_core_types__tuple2 kk_std_os_path_split_base(kk_string_t basename_0, kk_context_t* _ctx); /* (basename : string) -> (string, string) */ 

kk_std_os_path__path kk_std_os_path_change_ext(kk_std_os_path__path p, kk_string_t extname_0, kk_context_t* _ctx); /* (p : path, extname : string) -> path */ 

kk_string_t kk_std_os_path_extname(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> string */ 

kk_std_os_path__path kk_std_os_path_change_stem(kk_std_os_path__path p, kk_string_t stemname_0, kk_context_t* _ctx); /* (p : path, stemname : string) -> path */ 

kk_std_os_path__path kk_std_os_path_pathstring_fs__lp__fs__rp_(kk_std_os_path__path p1, kk_string_t p2, kk_context_t* _ctx); /* (p1 : path, p2 : string) -> path */ 

kk_std_os_path__path kk_std_os_path_string_fs__lp__fs__rp_(kk_string_t p1, kk_string_t p2, kk_context_t* _ctx); /* (p1 : string, p2 : string) -> path */ 

kk_std_os_path__path kk_std_os_path_combine(kk_std_core_types__list ps, kk_context_t* _ctx); /* (ps : list<path>) -> path */ 

kk_std_os_path__path kk_std_os_path_string_fs__mlift_realpath_10198(kk_string_t _y_x10157, kk_context_t* _ctx); /* (string) -> io path */ 

kk_std_os_path__path kk_std_os_path_string_fs_realpath(kk_string_t s, kk_context_t* _ctx); /* (s : string) -> io path */ 

kk_std_os_path__path kk_std_os_path__mlift_realpath_10199(kk_string_t _y_x10158, kk_context_t* _ctx); /* (string) -> io path */ 

kk_std_os_path__path kk_std_os_path_realpath(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> io path */ 

kk_std_os_path__path kk_std_os_path__mlift_cwd_10200(kk_string_t _y_x10159, kk_context_t* _ctx); /* (string) -> io path */ 

kk_std_os_path__path kk_std_os_path_cwd(kk_context_t* _ctx); /* () -> io path */ 

kk_std_os_path__path kk_std_os_path_default_ext(kk_std_os_path__path p, kk_string_t newext, kk_context_t* _ctx); /* (p : path, newext : string) -> path */ 

kk_std_os_path__path kk_std_os_path__mlift_homedir_10201(kk_string_t _y_x10160, kk_context_t* _ctx); /* (string) -> io path */ 

kk_std_os_path__path kk_std_os_path_homedir(kk_context_t* _ctx); /* () -> io path */ 
 
// Is a path relative?

static inline bool kk_std_os_path_is_relative(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> bool */ 
  kk_string_t _x_x947;
  {
    kk_string_t _x = p.root;
    kk_string_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    _x_x947 = _x; /*string*/
  }
  kk_string_t _x_x948 = kk_string_empty(); /*string*/
  return kk_string_is_eq(_x_x947,_x_x948,kk_context());
}
 
// Is a path absolute?

static inline bool kk_std_os_path_is_absolute(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> bool */ 
  bool b_10089;
  kk_string_t _x_x950;
  {
    kk_string_t _x = p.root;
    kk_string_dup(_x, _ctx);
    kk_std_os_path__path_drop(p, _ctx);
    _x_x950 = _x; /*string*/
  }
  kk_string_t _x_x951 = kk_string_empty(); /*string*/
  b_10089 = kk_string_is_eq(_x_x950,_x_x951,kk_context()); /*bool*/
  if (b_10089) {
    return false;
  }
  {
    return true;
  }
}
 
// Remove the extension from a path.

static inline kk_std_os_path__path kk_std_os_path_noext(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> path */ 
  kk_string_t _x_x953 = kk_string_empty(); /*string*/
  return kk_std_os_path_change_ext(p, _x_x953, _ctx);
}

kk_std_core_types__list kk_std_os_path__trmc_paths_collect(kk_std_core_types__list ps, kk_std_core_types__cctx _acc, kk_context_t* _ctx); /* (ps : list<string>, ctx<list<path>>) -> list<path> */ 

kk_std_core_types__list kk_std_os_path_paths_collect(kk_std_core_types__list ps_0, kk_context_t* _ctx); /* (ps : list<string>) -> list<path> */ 
 
// Parse a list of paths seperated by colon (`':'`) or semi-colon (`';'`)
//
// Colon separated paths can be ambiguous with Windows style root names (`c:\\`)
// In particular, a single letter path followed by an absolute path, e.g. ``c:/foo:/bar`` is
// parsed as ``c:/foo`` and ``/bar``.

static inline kk_std_core_types__list kk_std_os_path_paths(kk_string_t s, kk_context_t* _ctx) { /* (s : string) -> list<path> */ 
  kk_string_t s_0_10098;
  kk_string_t _x_x981;
  kk_define_string_literal(, _s_x982, 1, ";", _ctx)
  _x_x981 = kk_string_dup(_s_x982, _ctx); /*string*/
  kk_string_t _x_x983;
  kk_define_string_literal(, _s_x984, 1, ":", _ctx)
  _x_x983 = kk_string_dup(_s_x984, _ctx); /*string*/
  s_0_10098 = kk_string_replace_all(s,_x_x981,_x_x983,kk_context()); /*string*/
  kk_vector_t v_10012;
  kk_string_t _x_x985;
  kk_define_string_literal(, _s_x986, 1, ":", _ctx)
  _x_x985 = kk_string_dup(_s_x986, _ctx); /*string*/
  v_10012 = kk_string_splitv(s_0_10098,_x_x985,kk_context()); /*vector<string>*/
  kk_std_core_types__list _x_x987 = kk_std_core_vector_vlist(v_10012, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
  return kk_std_os_path_paths_collect(_x_x987, _ctx);
}
 
// Show a path as a string.

static inline kk_string_t kk_std_os_path_show(kk_std_os_path__path p, kk_context_t* _ctx) { /* (p : path) -> string */ 
  kk_string_t _x_x988 = kk_std_os_path_string(p, _ctx); /*string*/
  return kk_std_core_show_string_fs_show(_x_x988, _ctx);
}

kk_string_t kk_std_os_path_stemname(kk_std_os_path__path p, kk_context_t* _ctx); /* (p : path) -> string */ 

kk_std_os_path__path kk_std_os_path__mlift_tempdir_10202(kk_string_t _y_x10161, kk_context_t* _ctx); /* (string) -> io path */ 

kk_std_os_path__path kk_std_os_path_tempdir(kk_context_t* _ctx); /* () -> io path */ 

void kk_std_os_path__init(kk_context_t* _ctx);


void kk_std_os_path__done(kk_context_t* _ctx);

#endif // header
