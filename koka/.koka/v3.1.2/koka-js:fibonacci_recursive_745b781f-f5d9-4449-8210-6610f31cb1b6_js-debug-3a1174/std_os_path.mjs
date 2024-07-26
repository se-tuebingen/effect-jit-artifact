// Koka generated module: std/os/path, koka version: 3.1.2
"use strict";
 
// imports
import * as $std_core_types from './std_core_types.mjs';
import * as $std_core_hnd from './std_core_hnd.mjs';
import * as $std_core_exn from './std_core_exn.mjs';
import * as $std_core_bool from './std_core_bool.mjs';
import * as $std_core_order from './std_core_order.mjs';
import * as $std_core_char from './std_core_char.mjs';
import * as $std_core_int from './std_core_int.mjs';
import * as $std_core_vector from './std_core_vector.mjs';
import * as $std_core_string from './std_core_string.mjs';
import * as $std_core_sslice from './std_core_sslice.mjs';
import * as $std_core_list from './std_core_list.mjs';
import * as $std_core_maybe from './std_core_maybe.mjs';
import * as $std_core_either from './std_core_either.mjs';
import * as $std_core_tuple from './std_core_tuple.mjs';
import * as $std_core_show from './std_core_show.mjs';
import * as $std_core_debug from './std_core_debug.mjs';
import * as $std_core_delayed from './std_core_delayed.mjs';
import * as $std_core_console from './std_core_console.mjs';
import * as $std_core from './std_core.mjs';
import * as $std_text_parse from './std_text_parse.mjs';
 
// externals
/*---------------------------------------------------------------------------
    Copyright 2012-2021, Microsoft Research, Daan Leijen.
 
  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/
var _get_pathsep;
var _get_dirsep;
var _get_realpath;
var _get_homedir;
var _get_tempdir;
function _get_apppath() {
  if (typeof module === "undefined" || module==null) return "";
  var m = module; 
  while(m.parent != null) { m = m.parent; }; 
  return (m.filename != null ? m.filename : "");    
};
if ($std_core.host() === "node") {
  var _fs   = await import("fs");
  var _path = await import("path");
  var _os   = await import("os");
  _get_dirsep  = function() { return _path.sep; };
  _get_pathsep = function() { return _path.delimiter; };
  _get_realpath = function(p) { return _fs.realpathSync(p); };
  _get_homedir  = function() { return _os.homedir(); }
  _get_tempdir  = function() { return _os.tmpdir(); }
}
else {
  // browser?
  _get_dirsep = function() { return "/"; };
  _get_pathsep = function() { return ":"; };
  _get_realpath = function(p) { return p; };
  _get_homedir  = function() { return "."; };
  _get_tempdir  = function() { return "."; };
}
 
// type declarations
// type path
export function Path(root, parts) /* (root : string, parts : list<string>) -> path */  {
  return { root: root, parts: parts };
}
 
// declarations
 
 
// Automatically generated. Retrieves the `root` constructor field of the `:path` type.
export function path_fs_root(path_0) /* (path : path) -> string */  {
  return path_0.root;
}
 
 
// Automatically generated. Retrieves the `parts` constructor field of the `:path` type.
export function path_fs_parts(path_0) /* (path : path) -> list<string> */  {
  return path_0.parts;
}
 
export function path_fs__copy(_this, root, parts) /* (path, root : ? string, parts : ? (list<string>)) -> path */  {
  if (root !== undefined) {
    var _x0 = root;
  }
  else {
    var _x0 = _this.root;
  }
  if (parts !== undefined) {
    var _x1 = parts;
  }
  else {
    var _x1 = _this.parts;
  }
  return Path(_x0, _x1);
}
 
export function xapp_path() /* () -> io string */  {
  return ((function() {
    try {
      return _get_apppath();
    }
    catch(_err){ return $std_core._throw_exception(_err); }
  })());
}
 
 
// Return the base name of a path (stem name + extension)\
// `"/foo/bar.txt".path.basename === "bar.txt"` \
// `"/foo".path.basename === "foo"`
export function basename(p) /* (p : path) -> string */  {
  if (p.parts !== null) {
    return p.parts.head;
  }
  else {
    var _x2 = $std_core_types.Nothing;
    return (_x2 === null) ? "" : _x2.value;
  }
}
 
 
// Remove the basename and only keep the root and directory name portion of the path.\
// `nobase("foo/bar.ext".path) == "foo")`
export function nobase(p) /* (p : path) -> path */  {
  var _x4 = undefined;
  if (_x4 !== undefined) {
    var _x3 = _x4;
  }
  else {
    var _x3 = p.root;
  }
  var _x5 = (p.parts !== null) ? p.parts.tail : $std_core_types.Nil;
  return Path(_x3, _x5);
}
 
export function split_parts(parts) /* (parts : list<string>) -> (string, list<string>) */  {
  if (parts !== null) {
    var _x6 = parts.head;
  }
  else {
    var _x7 = $std_core_types.Nothing;
    var _x6 = (_x7 === null) ? "" : _x7.value;
  }
  var _x8 = (parts !== null) ? parts.tail : $std_core_types.Nil;
  return $std_core_types.Tuple2(_x6, _x8);
}
 
export function xrealpath(p) /* (p : string) -> io string */  {
  return ((function() {
    try {
      return _get_realpath(p);
    }
    catch(_err){ return $std_core._throw_exception(_err); }
  })());
}
 
 
// Return the directory part of a path (including the rootname)
// `"/foo/bar.txt".path.dirname === "/foo"` \
// `"/foo".path.dirname === "/"`
export function dirname(p) /* (p : path) -> string */  {
   
  var _x9 = (p.parts !== null) ? p.parts.tail : $std_core_types.Nil;
  var xs_10015 = $std_core_list._lift_reverse_append_4790($std_core_types.Nil, _x9);
  var _x9 = p.root;
  if (xs_10015 === null) {
    var _x10 = "";
  }
  else {
    var _x10 = $std_core_list._lift_joinsep_4797("/", xs_10015.tail, xs_10015.head);
  }
  return $std_core_types._lp__plus__plus__rp_(_x9, _x10);
}
 
 
// Return a list of all directory components (excluding the root but including the basename).\
// `"/foo/bar/test.txt".path.dirparts === ["foo","bar","test.txt"]`
export function dirparts(p) /* (p : path) -> list<string> */  {
  var _x11 = p.parts;
  return $std_core_list._lift_reverse_append_4790($std_core_types.Nil, _x11);
}
 
export function xhomedir() /* () -> io string */  {
  return ((function() {
    try {
      return _get_homedir();
    }
    catch(_err){ return $std_core._throw_exception(_err); }
  })());
}
 
 
// Remove the directory and root and only keep the base name (file name) portion of the path.\
// `nodir("foo/bar.ext".path) === "bar.ext"`
export function nodir(p) /* (p : path) -> path */  {
   
  var _x12 = p.parts;
  var parts_10024 = $std_core_list.take(_x12, 1);
  if (parts_10024 !== undefined) {
    var _x12 = parts_10024;
  }
  else {
    var _x12 = p.parts;
  }
  return Path("", _x12);
}
 
 
// Return the last directory component name (or the empty string).\
// `"c:/foo/bar/tst.txt".path.parentname === "bar"
export function parentname(p) /* (p : path) -> string */  {
  var _x13 = (p.parts !== null) ? p.parts.tail : $std_core_types.Nil;
  if (_x13 !== null) {
    return _x13.head;
  }
  else {
    var _x14 = $std_core_types.Nothing;
    return (_x14 === null) ? "" : _x14.value;
  }
}
 
 
// Return the OS specific directory separator (`"/"` or `"\\"`)
export function partsep() /* () -> ndet string */  {
  return _get_partsep();
}
 
 
// Return the OS specific path separator (`';'` or `':'`)
export function pathsep() /* () -> ndet string */  {
  return _get_pathsep();
}
 
 
// Return the root name of path.
// `"c:\\foo".path.rootname === "c:/"`\
// `"/foo".path.rootname === "/"`
export function rootname(p) /* (p : path) -> string */  {
  return p.root;
}
 
export function xtempdir() /* () -> io string */  {
  return ((function() {
    try {
      return _get_tempdir();
    }
    catch(_err){ return $std_core._throw_exception(_err); }
  })());
}
 
 
// Is a path empty?
export function is_empty(p) /* (p : path) -> bool */  {
  var _x16 = p.root;
  var _x15 = (_x16 === (""));
  if (_x15) {
    return (p.parts === null);
  }
  else {
    return false;
  }
}
 
 
// Return the first path if it is not empty, otherwise return the second one.
export function _lp__bar__bar__rp_(p1, p2) /* (p1 : path, p2 : path) -> path */  {
  var _x18 = p1.root;
  var _x17 = (_x18 === (""));
  if (_x17) {
    return (p1.parts === null) ? p2 : p1;
  }
  else {
    return p1;
  }
}
 
export function push_part(dir, dirs) /* (dir : string, dirs : list<string>) -> list<string> */  {
  if ((dir === ("."))) {
    return dirs;
  }
  else {
    if ((dir === (""))) {
      return dirs;
    }
    else {
      if ((dir === (".."))) {
        if (dirs !== null) {
          return (dirs !== null) ? dirs.tail : $std_core_types.Nil;
        }
        else {
          return $std_core_types.Cons(dir, dirs);
        }
      }
      else {
        return $std_core_types.Cons(dir, dirs);
      }
    }
  }
}
 
export function push_parts(parts, dirs) /* (parts : list<string>, dirs : list<string>) -> list<string> */  { tailcall: while(1)
{
  if (parts !== null) {
    {
      // tail call
      var _x19 = push_part(parts.head, dirs);
      parts = parts.tail;
      dirs = _x19;
      continue tailcall;
    }
  }
  else {
    return dirs;
  }
}}
 
 
// monadic lift
export function _mlift_proot_10188(wild___4) /* (wild_@4 : char) -> std/text/parse/parse bool */  {
  return false;
}
 
 
// monadic lift
export function _mlift_proot_10189(wild___5) /* (wild_@5 : ()) -> std/text/parse/parse bool */  {
  return true;
}
 
 
// monadic lift
export function _mlift_proot_10190(wild___0) /* (wild_@0 : char) -> std/text/parse/parse () */  {
  return $std_core_types.Unit;
}
 
 
// monadic lift
export function _mlift_proot_10191(wild__) /* (wild_ : char) -> std/text/parse/parse () */  {
   
  var x_10203 = $std_text_parse.char(0x003A);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_proot_10190);
  }
  else {
    return $std_core_types.Unit;
  }
}
 
 
// monadic lift
export function _mlift_proot_10192(_y_x10147) /* (list<char>) -> std/text/parse/parse () */  {
  return $std_core_types.Unit;
}
 
 
// monadic lift
export function _mlift_proot_10193(_y_x10145) /* (char) -> std/text/parse/parse () */  {
   
  var x_10205 = $std_text_parse.many_acc(function() {
      return $std_text_parse.none_of("/");
    }, $std_core_types.Nil);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_proot_10192);
  }
  else {
    return $std_core_types.Unit;
  }
}
 
 
// monadic lift
export function _mlift_proot_10194(wild___1) /* (wild_@1 : char) -> std/text/parse/parse () */  {
   
  var x_10207 = $std_text_parse.none_of("/");
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_proot_10193);
  }
  else {
    return _mlift_proot_10193(x_10207);
  }
}
 
 
// monadic lift
export function _mlift_proot_10195(wild___3) /* (wild_@3 : ()) -> std/text/parse/parse bool */  {
  return $std_text_parse._lp__bar__bar__rp_(function() {
       
      var x_10209 = $std_text_parse.char(0x002F);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(_mlift_proot_10188);
      }
      else {
        return false;
      }
    }, function() {
       
      var x_0_10211 = $std_text_parse.eof();
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(_mlift_proot_10189);
      }
      else {
        return true;
      }
    });
}
 
export function proot() /* () -> std/text/parse/parse bool */  {
   
  var x_10213 = $std_text_parse._lp__bar__bar__rp_(function() {
       
      var x_0_10216 = $std_text_parse.alpha();
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(_mlift_proot_10191);
      }
      else {
        return _mlift_proot_10191(x_0_10216);
      }
    }, function() {
       
      var x_1_10218 = $std_text_parse.char(0x002F);
      if ($std_core_hnd._yielding()) {
        return $std_core_hnd.yield_extend(_mlift_proot_10194);
      }
      else {
        return _mlift_proot_10194(x_1_10218);
      }
    });
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_proot_10195);
  }
  else {
    return $std_text_parse._lp__bar__bar__rp_(function() {
         
        var x_2_10220 = $std_text_parse.char(0x002F);
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(_mlift_proot_10188);
        }
        else {
          return false;
        }
      }, function() {
         
        var x_3_10222 = $std_text_parse.eof();
        if ($std_core_hnd._yielding()) {
          return $std_core_hnd.yield_extend(_mlift_proot_10189);
        }
        else {
          return true;
        }
      });
  }
}
 
 
// Convert a `:path` to a normalized `:string` path.\
// If this results in an empty string, the current directory path `"."` is returned.
// `"c:/foo/test.txt".path.string -> "c:/foo/test.txt"`\
// `"c:\\foo\\test.txt".path.string -> "c:/foo/test.txt"`\
// `"/foo//./bar/../test.txt".path.string -> "/foo/test.txt"`
export function string(p) /* (p : path) -> string */  {
   
  var _x20 = p.parts;
  var xs_10042 = $std_core_list._lift_reverse_append_4790($std_core_types.Nil, _x20);
   
  var _x21 = p.root;
  if (xs_10042 === null) {
    var _x22 = "";
  }
  else {
    var _x22 = $std_core_list._lift_joinsep_4797("/", xs_10042.tail, xs_10042.head);
  }
  var s = $std_core_types._lp__plus__plus__rp_(_x21, _x22);
  return ((s === (""))) ? "." : s;
}
 
 
// A `:path` represents a file system path.\
export function _create_Path(root, parts) /* (root : ? string, parts : ? (list<string>)) -> path */  {
  var _x20 = (root !== undefined) ? root : "";
  var _x21 = (parts !== undefined) ? parts : $std_core_types.Nil;
  return Path(_x20, _x21);
}
 
export function path_parts(root, s, dirs) /* (root : string, s : string, dirs : ? (list<string>)) -> path */  {
   
  var v_10012 = ((s).split(("/")));
   
  var _x22 = (dirs !== undefined) ? dirs : $std_core_types.Nil;
  var parts = push_parts($std_core_vector.vlist(v_10012), _x22);
  return Path(root, parts);
}
 
 
// Create a normalized `:path` from a path string.
export function path(s) /* (s : string) -> path */  {
  if ((s === (""))) {
    return Path("", $std_core_types.Nil);
  }
  else {
     
    var t = (s).replace(new RegExp((("\\")).replace(/[\\\$\^*+\-{}?().]/g,'\\$&'),'g'),("/"));
    var _x22 = $std_text_parse.starts_with(t, proot);
    if (_x22 === null) {
       
      var v_10012 = ((t).split(("/")));
       
      var _x24 = undefined;
      var _x23 = (_x24 !== undefined) ? _x24 : $std_core_types.Nil;
      var parts = push_parts($std_core_vector.vlist(v_10012), _x23);
      return Path("", parts);
    }
    else {
       
      var _x23 = $std_core_sslice.Sslice(_x22.value.snd.str, 0, _x22.value.snd.start);
      var _x24 = (_x22.value.fst) ? "/" : "";
      var root_0_10105 = $std_core_types._lp__plus__plus__rp_($std_core_sslice.string(_x23), _x24);
       
      var s_1_10106 = $std_core_sslice.string(_x22.value.snd);
       
      var v_10012_0 = ((s_1_10106).split(("/")));
       
      var _x26 = undefined;
      var _x25 = (_x26 !== undefined) ? _x26 : $std_core_types.Nil;
      var parts_0 = push_parts($std_core_vector.vlist(v_10012_0), _x25);
      return Path(root_0_10105, parts_0);
    }
  }
}
 
 
// Add two paths together using left-associative operator `(/)`. \
// Keeps the root of `p1` and discards the root name of `p2`.\
// `"/a/" / "b/foo.txt"          === "/a/b/foo.txt"`\
// `"/a/foo.txt" / "/b/bar.txt"  === "/a/foo.txt/b/bar.txt"`\
// `"c:/foo" / "d:/bar"          === "c:/foo/bar"`
export function _lp__fs__rp_(p1, p2) /* (p1 : path, p2 : path) -> path */  {
   
  var _x23 = p2.parts;
  var _x24 = p1.parts;
  var parts_10056 = push_parts($std_core_list._lift_reverse_append_4790($std_core_types.Nil, _x23), _x24);
  var _x23 = p1.root;
  var _x24 = (parts_10056 !== undefined) ? parts_10056 : $std_core_types.Nil;
  return Path(_x23, _x24);
}
 
 
// monadic lift
export function _mlift_app_path_10196(_y_x10153) /* (string) -> io path */  {
  return $std_core_hnd._open_none1(path, _y_x10153);
}
 
 
// Return the path to the currently executing application.
export function app_path() /* () -> io path */  {
   
  var x_10224 = xapp_path();
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_app_path_10196);
  }
  else {
    return $std_core_hnd._open_none1(path, x_10224);
  }
}
 
 
// monadic lift
export function _mlift_appdir_10197(_y_x10154) /* (string) -> io path */  {
   
  var _x_x1_10176 = $std_core_hnd._open_none1(path, _y_x10154);
   
  var p_0 = $std_core_hnd._open_none1(function(p /* path */ ) {
      var _x26 = undefined;
      if (_x26 !== undefined) {
        var _x25 = _x26;
      }
      else {
        var _x25 = p.root;
      }
      var _x27 = (p.parts !== null) ? p.parts.tail : $std_core_types.Nil;
      return Path(_x25, _x27);
    }, _x_x1_10176);
  var _x25 = (($std_core_hnd._open_none1(function(p_1 /* path */ ) {
      if (p_1.parts !== null) {
        return p_1.parts.head;
      }
      else {
        var _x26 = $std_core_types.Nothing;
        return (_x26 === null) ? "" : _x26.value;
      }
    }, p_0)) === ("bin"));
  if (_x25) {
    return $std_core_hnd._open_none1(function(p_2 /* path */ ) {
        var _x28 = undefined;
        if (_x28 !== undefined) {
          var _x27 = _x28;
        }
        else {
          var _x27 = p_2.root;
        }
        var _x29 = (p_2.parts !== null) ? p_2.parts.tail : $std_core_types.Nil;
        return Path(_x27, _x29);
      }, p_0);
  }
  else {
    var _x30 = (($std_core_hnd._open_none1(function(p_3 /* path */ ) {
        if (p_3.parts !== null) {
          return p_3.parts.head;
        }
        else {
          var _x31 = $std_core_types.Nothing;
          return (_x31 === null) ? "" : _x31.value;
        }
      }, p_0)) === ("exe"));
    if (_x30) {
      return $std_core_hnd._open_none1(function(p_4 /* path */ ) {
          var _x33 = undefined;
          if (_x33 !== undefined) {
            var _x32 = _x33;
          }
          else {
            var _x32 = p_4.root;
          }
          var _x34 = (p_4.parts !== null) ? p_4.parts.tail : $std_core_types.Nil;
          return Path(_x32, _x34);
        }, p_0);
    }
    else {
      return p_0;
    }
  }
}
 
 
// Return the base directory that contains the currently running application.
// First tries `app-path().nobase`; if that ends in the ``bin`` or ``exe`` directory it
// returns the parent of that directory.
export function appdir() /* () -> io path */  {
   
  var x_10227 = xapp_path();
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_appdir_10197);
  }
  else {
     
    var _x_x1_10176 = $std_core_hnd._open_none1(path, x_10227);
     
    var p_0 = $std_core_hnd._open_none1(function(p /* path */ ) {
        var _x36 = undefined;
        if (_x36 !== undefined) {
          var _x35 = _x36;
        }
        else {
          var _x35 = p.root;
        }
        var _x37 = (p.parts !== null) ? p.parts.tail : $std_core_types.Nil;
        return Path(_x35, _x37);
      }, _x_x1_10176);
    var _x35 = (($std_core_hnd._open_none1(function(p_1 /* path */ ) {
        if (p_1.parts !== null) {
          return p_1.parts.head;
        }
        else {
          var _x36 = $std_core_types.Nothing;
          return (_x36 === null) ? "" : _x36.value;
        }
      }, p_0)) === ("bin"));
    if (_x35) {
      return $std_core_hnd._open_none1(function(p_2 /* path */ ) {
          var _x38 = undefined;
          if (_x38 !== undefined) {
            var _x37 = _x38;
          }
          else {
            var _x37 = p_2.root;
          }
          var _x39 = (p_2.parts !== null) ? p_2.parts.tail : $std_core_types.Nil;
          return Path(_x37, _x39);
        }, p_0);
    }
    else {
      var _x40 = (($std_core_hnd._open_none1(function(p_3 /* path */ ) {
          if (p_3.parts !== null) {
            return p_3.parts.head;
          }
          else {
            var _x41 = $std_core_types.Nothing;
            return (_x41 === null) ? "" : _x41.value;
          }
        }, p_0)) === ("exe"));
      if (_x40) {
        return $std_core_hnd._open_none1(function(p_4 /* path */ ) {
            var _x43 = undefined;
            if (_x43 !== undefined) {
              var _x42 = _x43;
            }
            else {
              var _x42 = p_4.root;
            }
            var _x44 = (p_4.parts !== null) ? p_4.parts.tail : $std_core_types.Nil;
            return Path(_x42, _x44);
          }, p_0);
      }
      else {
        return p_0;
      }
    }
  }
}
 
 
// Change the base name of a path
export function change_base(p, basename_0) /* (p : path, basename : string) -> path */  {
   
  var _x46 = undefined;
  if (_x46 !== undefined) {
    var _x45 = _x46;
  }
  else {
    var _x45 = p.root;
  }
  var _x47 = (p.parts !== null) ? p.parts.tail : $std_core_types.Nil;
  var q = Path(_x45, _x47);
   
  var v_10012 = ((basename_0).split(("/")));
   
  var _x48 = q.parts;
  var parts = push_parts($std_core_vector.vlist(v_10012), _x48);
  var _x45 = q.root;
  return Path(_x45, parts);
}
 
export function split_base(basename_0) /* (basename : string) -> (string, string) */  {
  var _x46 = $std_core_sslice.find_last(basename_0, ".");
  if (_x46 !== null) {
    var _x47 = $std_core_sslice.Sslice(_x46.value.str, 0, _x46.value.start);
    return $std_core_types.Tuple2($std_core_sslice.string(_x47), $std_core_sslice.string($std_core_sslice.after(_x46.value)));
  }
  else {
    return $std_core_types.Tuple2(basename_0, "");
  }
}
 
 
// Change the extension of a path.
// Only adds a dot if the extname does not already start with a dot.
export function change_ext(p, extname_0) /* (p : path, extname : string) -> path */  {
  if (p.parts !== null) {
    var _x49 = p.parts.head;
  }
  else {
    var _x50 = $std_core_types.Nothing;
    var _x49 = (_x50 === null) ? "" : _x50.value;
  }
  var _x48 = $std_core_sslice.find_last(_x49, ".");
  if (_x48 !== null) {
     
    var _x51 = $std_core_sslice.Sslice(_x48.value.str, 0, _x48.value.start);
    var stemname_0 = $std_core_sslice.string(_x51);
     
    var _pat_1_2 = $std_core_sslice.string($std_core_sslice.after(_x48.value));
     
    var maybe_10070 = $std_core_sslice.starts_with(extname_0, ".");
     
    if (maybe_10070 !== null) {
      var newext = extname_0;
    }
    else {
      var newext = $std_core_types._lp__plus__plus__rp_(".", extname_0);
    }
     
    var s_0_10114 = $std_core_types._lp__plus__plus__rp_(stemname_0, newext);
     
    var v_10012 = ((s_0_10114).split(("/")));
     
    var _x52 = (p.parts !== null) ? p.parts.tail : $std_core_types.Nil;
    var parts = push_parts($std_core_vector.vlist(v_10012), _x52);
    var _x51 = p.root;
    return Path(_x51, parts);
  }
  else {
     
    var maybe_10070_0 = $std_core_sslice.starts_with(extname_0, ".");
     
    if (maybe_10070_0 !== null) {
      var newext_0 = extname_0;
    }
    else {
      var newext_0 = $std_core_types._lp__plus__plus__rp_(".", extname_0);
    }
     
    if (p.parts !== null) {
      var _x52 = p.parts.head;
    }
    else {
      var _x53 = $std_core_types.Nothing;
      var _x52 = (_x53 === null) ? "" : _x53.value;
    }
    var s_0_10114_0 = $std_core_types._lp__plus__plus__rp_(_x52, newext_0);
     
    var v_10012_0 = ((s_0_10114_0).split(("/")));
     
    var _x54 = (p.parts !== null) ? p.parts.tail : $std_core_types.Nil;
    var parts_0 = push_parts($std_core_vector.vlist(v_10012_0), _x54);
    var _x52 = p.root;
    return Path(_x52, parts_0);
  }
}
 
 
// Return the extension of path (without the preceding dot (`'.'`))\
// `"/foo/bar.svg.txt".path.extname === "txt"`
export function extname(p) /* (p : path) -> string */  {
   
  if (p.parts !== null) {
    var _x54 = p.parts.head;
  }
  else {
    var _x55 = $std_core_types.Nothing;
    var _x54 = (_x55 === null) ? "" : _x55.value;
  }
  var _x53 = $std_core_sslice.find_last(_x54, ".");
  if (_x53 !== null) {
    var _x56 = $std_core_sslice.Sslice(_x53.value.str, 0, _x53.value.start);
    var tuple2_10072 = $std_core_types.Tuple2($std_core_sslice.string(_x56), $std_core_sslice.string($std_core_sslice.after(_x53.value)));
  }
  else {
    if (p.parts !== null) {
      var _x57 = p.parts.head;
    }
    else {
      var _x58 = $std_core_types.Nothing;
      var _x57 = (_x58 === null) ? "" : _x58.value;
    }
    var tuple2_10072 = $std_core_types.Tuple2(_x57, "");
  }
  return tuple2_10072.snd;
}
 
 
// Change the stem name of a path
export function change_stem(p, stemname_0) /* (p : path, stemname : string) -> path */  {
   
  if (p.parts !== null) {
    var _x54 = p.parts.head;
  }
  else {
    var _x55 = $std_core_types.Nothing;
    var _x54 = (_x55 === null) ? "" : _x55.value;
  }
  var _x53 = $std_core_sslice.find_last(_x54, ".");
  if (_x53 !== null) {
    var _x56 = $std_core_sslice.Sslice(_x53.value.str, 0, _x53.value.start);
    var tuple2_10074 = $std_core_types.Tuple2($std_core_sslice.string(_x56), $std_core_sslice.string($std_core_sslice.after(_x53.value)));
  }
  else {
    if (p.parts !== null) {
      var _x57 = p.parts.head;
    }
    else {
      var _x58 = $std_core_types.Nothing;
      var _x57 = (_x58 === null) ? "" : _x58.value;
    }
    var tuple2_10074 = $std_core_types.Tuple2(_x57, "");
  }
   
  var _x61 = tuple2_10074.snd;
  var _x60 = (_x61 === (""));
  if (_x60) {
    var _x59 = "";
  }
  else {
    var _x62 = tuple2_10074.snd;
    var _x59 = $std_core_types._lp__plus__plus__rp_(".", _x62);
  }
  var basename_0_10076 = $std_core_types._lp__plus__plus__rp_(stemname_0, _x59);
   
  var _x64 = undefined;
  if (_x64 !== undefined) {
    var _x63 = _x64;
  }
  else {
    var _x63 = p.root;
  }
  var _x65 = (p.parts !== null) ? p.parts.tail : $std_core_types.Nil;
  var q = Path(_x63, _x65);
   
  var v_10012 = ((basename_0_10076).split(("/")));
   
  var _x66 = q.parts;
  var parts = push_parts($std_core_vector.vlist(v_10012), _x66);
  var _x53 = q.root;
  return Path(_x53, parts);
}
 
 
// Convenience function that adds a string path.
export function pathstring_fs__lp__fs__rp_(p1, p2) /* (p1 : path, p2 : string) -> path */  {
   
  var p2_0_10125 = path(p2);
   
  var _x54 = p2_0_10125.parts;
  var _x55 = p1.parts;
  var parts_10056 = push_parts($std_core_list._lift_reverse_append_4790($std_core_types.Nil, _x54), _x55);
  var _x54 = p1.root;
  var _x55 = (parts_10056 !== undefined) ? parts_10056 : $std_core_types.Nil;
  return Path(_x54, _x55);
}
 
 
// Convenience function that adds two strings into a path.
export function string_fs__lp__fs__rp_(p1, p2) /* (p1 : string, p2 : string) -> path */  {
   
  var p1_0_10126 = path(p1);
   
  var p2_0_10127 = path(p2);
   
  var _x56 = p2_0_10127.parts;
  var _x57 = p1_0_10126.parts;
  var parts_10056 = push_parts($std_core_list._lift_reverse_append_4790($std_core_types.Nil, _x56), _x57);
  var _x56 = p1_0_10126.root;
  var _x57 = (parts_10056 !== undefined) ? parts_10056 : $std_core_types.Nil;
  return Path(_x56, _x57);
}
 
 
// Combine multiple paths using `(/)`.
export function combine(ps) /* (ps : list<path>) -> path */  {
  if (ps === null) {
    var _x59 = undefined;
    var _x58 = (_x59 !== undefined) ? _x59 : "";
    var _x61 = undefined;
    var _x60 = (_x61 !== undefined) ? _x61 : $std_core_types.Nil;
    return Path(_x58, _x60);
  }
  else {
    return $std_core_list.foldl(ps.tail, ps.head, _lp__fs__rp_);
  }
}
 
 
// monadic lift
export function string_fs__mlift_realpath_10198(_y_x10157) /* (string) -> io path */  {
  return $std_core_hnd._open_none1(path, _y_x10157);
}
 
 
// Convert a path to the absolute path on the file system.\
// The overload on a plain string is necessary as it allows
// for unnormalized paths with `".."` parts. For example
// `"/foo/symlink/../test.txt"` may resolve to `"/bar/test.txt"` if
// ``symlink`` is a symbolic link to a sub directory of `"/bar"`.
export function string_fs_realpath(s) /* (s : string) -> io path */  {
   
  var x_10230 = xrealpath(s);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(string_fs__mlift_realpath_10198);
  }
  else {
    return $std_core_hnd._open_none1(path, x_10230);
  }
}
 
 
// monadic lift
export function _mlift_realpath_10199(_y_x10158) /* (string) -> io path */  {
  return $std_core_hnd._open_none1(path, _y_x10158);
}
 
 
// Convert a path to the absolute path on the file system.
// The path is not required to exist on disk. However, if it
// exists any permissions and symbolic links are resolved fully.\
// `".".realpath` (to get the current working directory)\
// `"/foo".realpath` (to resolve the full root, like `"c:/foo"` on windows)
export function realpath(p) /* (p : path) -> io path */  {
   
  var s_10082 = $std_core_hnd._open_none1(string, p);
   
  var x_10233 = xrealpath(s_10082);
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_realpath_10199);
  }
  else {
    return $std_core_hnd._open_none1(path, x_10233);
  }
}
 
 
// monadic lift
export function _mlift_cwd_10200(_y_x10159) /* (string) -> io path */  {
  return $std_core_hnd._open_none1(path, _y_x10159);
}
 
 
// Returns the current working directory.\
// Equal to `".".realpath`.
export function cwd() /* () -> io path */  {
   
  var x_10236 = xrealpath(".");
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_cwd_10200);
  }
  else {
    return $std_core_hnd._open_none1(path, x_10236);
  }
}
 
 
// If a path has no extension, set it to the provided one.
export function default_ext(p, newext) /* (p : path, newext : string) -> path */  {
   
  if (p.parts !== null) {
    var _x63 = p.parts.head;
  }
  else {
    var _x64 = $std_core_types.Nothing;
    var _x63 = (_x64 === null) ? "" : _x64.value;
  }
  var _x62 = $std_core_sslice.find_last(_x63, ".");
  if (_x62 !== null) {
    var _x65 = $std_core_sslice.Sslice(_x62.value.str, 0, _x62.value.start);
    var tuple2_10086 = $std_core_types.Tuple2($std_core_sslice.string(_x65), $std_core_sslice.string($std_core_sslice.after(_x62.value)));
  }
  else {
    if (p.parts !== null) {
      var _x66 = p.parts.head;
    }
    else {
      var _x67 = $std_core_types.Nothing;
      var _x66 = (_x67 === null) ? "" : _x67.value;
    }
    var tuple2_10086 = $std_core_types.Tuple2(_x66, "");
  }
  var _x63 = tuple2_10086.snd;
  var _x62 = (_x63 === (""));
  if (_x62) {
    return change_ext(p, newext);
  }
  else {
    return p;
  }
}
 
 
// monadic lift
export function _mlift_homedir_10201(_y_x10160) /* (string) -> io path */  {
  return $std_core_hnd._open_none1(path, _y_x10160);
}
 
 
// Return the home directory of the current user.
export function homedir() /* () -> io path */  {
   
  var x_10239 = xhomedir();
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_homedir_10201);
  }
  else {
    return $std_core_hnd._open_none1(path, x_10239);
  }
}
 
 
// Is a path relative?
export function is_relative(p) /* (p : path) -> bool */  {
  var _x64 = p.root;
  return (_x64 === (""));
}
 
 
// Is a path absolute?
export function is_absolute(p) /* (p : path) -> bool */  {
   
  var _x65 = p.root;
  var b_10089 = (_x65 === (""));
  return (b_10089) ? false : true;
}
 
 
// Remove the extension from a path.
export function noext(p) /* (p : path) -> path */  {
  return change_ext(p, "");
}
 
export function _trmc_paths_collect(ps, _acc) /* (ps : list<string>, ctx<list<path>>) -> list<path> */  { tailcall: while(1)
{
  if (ps !== null && ps.tail !== null) {
    var _x66 = $std_core_types._int_eq(($std_core_string.count(ps.head)),1);
    if (_x66) {
       
      var m_10093 = $std_core_sslice.foreach_while($std_core_sslice.Sslice(ps.head, 0, (ps.head).length), $std_core_types.Just);
      var _x68 = (m_10093 === null) ? 0x0020 : m_10093.value;
      var _x67 = $std_core_char.is_alpha(_x68);
      if (_x67) {
         
        var b_10096 = ((ps.tail.head) === (""));
        if (b_10096) {
          var _x65 = false;
        }
        else {
          var _x65 = ((("/\\")).indexOf(($std_core_sslice.head(ps.tail.head))) >= 0);
        }
      }
      else {
        var _x65 = false;
      }
    }
    else {
      var _x65 = false;
    }
    if (_x65){
       
      var _trmc_x10132 = path($std_core_types._lp__plus__plus__rp_(ps.head, $std_core_types._lp__plus__plus__rp_(":", ps.tail.head)));
       
      var _trmc_x10133 = undefined;
       
      var _trmc_x10134 = $std_core_types.Cons(_trmc_x10132, _trmc_x10133);
      {
        // tail call
        var _x69 = $std_core_types._cctx_extend(_acc,_trmc_x10134,({obj: _trmc_x10134, field_name: "tail"}));
        ps = ps.tail.tail;
        _acc = _x69;
        continue tailcall;
      }
    }
  }
  if (ps !== null) {
     
    var _trmc_x10135 = path(ps.head);
     
    var _trmc_x10136 = undefined;
     
    var _trmc_x10137 = $std_core_types.Cons(_trmc_x10135, _trmc_x10136);
    {
      // tail call
      var _x70 = $std_core_types._cctx_extend(_acc,_trmc_x10137,({obj: _trmc_x10137, field_name: "tail"}));
      ps = ps.tail;
      _acc = _x70;
      continue tailcall;
    }
  }
  return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
}}
 
export function paths_collect(ps_0) /* (ps : list<string>) -> list<path> */  {
  return _trmc_paths_collect(ps_0, $std_core_types._cctx_empty());
}
 
 
// Parse a list of paths seperated by colon (`':'`) or semi-colon (`';'`)
//
// Colon separated paths can be ambiguous with Windows style root names (`c:\\`)
// In particular, a single letter path followed by an absolute path, e.g. ``c:/foo:/bar`` is
// parsed as ``c:/foo`` and ``/bar``.
export function paths(s) /* (s : string) -> list<path> */  {
   
  var s_0_10098 = (s).replace(new RegExp(((";")).replace(/[\\\$\^*+\-{}?().]/g,'\\$&'),'g'),(":"));
   
  var v_10012 = ((s_0_10098).split((":")));
  return paths_collect($std_core_vector.vlist(v_10012));
}
 
 
// Show a path as a string.
export function show(p) /* (p : path) -> string */  {
  return $std_core_show.string_fs_show(string(p));
}
 
 
// Return the stem name of path.\
// `"/foo/bar.svg.txt".path.extname === "foo.svg"`
export function stemname(p) /* (p : path) -> string */  {
   
  if (p.parts !== null) {
    var _x72 = p.parts.head;
  }
  else {
    var _x73 = $std_core_types.Nothing;
    var _x72 = (_x73 === null) ? "" : _x73.value;
  }
  var _x71 = $std_core_sslice.find_last(_x72, ".");
  if (_x71 !== null) {
    var _x74 = $std_core_sslice.Sslice(_x71.value.str, 0, _x71.value.start);
    var tuple2_10100 = $std_core_types.Tuple2($std_core_sslice.string(_x74), $std_core_sslice.string($std_core_sslice.after(_x71.value)));
  }
  else {
    if (p.parts !== null) {
      var _x75 = p.parts.head;
    }
    else {
      var _x76 = $std_core_types.Nothing;
      var _x75 = (_x76 === null) ? "" : _x76.value;
    }
    var tuple2_10100 = $std_core_types.Tuple2(_x75, "");
  }
  return tuple2_10100.fst;
}
 
 
// monadic lift
export function _mlift_tempdir_10202(_y_x10161) /* (string) -> io path */  {
  return $std_core_hnd._open_none1(path, _y_x10161);
}
 
 
// Return the temporary directory for the current user.
export function tempdir() /* () -> io path */  {
   
  var x_10242 = xtempdir();
  if ($std_core_hnd._yielding()) {
    return $std_core_hnd.yield_extend(_mlift_tempdir_10202);
  }
  else {
    return $std_core_hnd._open_none1(path, x_10242);
  }
}