// Koka generated module: std/os/env, koka version: 3.1.2
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
import * as $std_os_path from './std_os_path.mjs';
 
// externals
 
// type declarations
 
// declarations
 
export function os_get_argv() /* () -> ndet vector<string> */  {
  return (typeof process !== 'undefined' ? process.argv : []);
}
 
export function os_get_env() /* () -> ndet vector<string> */  {
  return (typeof process !== 'undefined' ? (function(){ var env = []; Object.keys(process.env).forEach(function(name){ env.push(name); env.push(process.env[name]); }); return env; })() : []);
}
 
 
// The backend compiler name, like `gcc`, `clang`, `cl`, `clang-cl`, `mingw`, or `icc` (and `js` for JavaScript).
export function get_cc_name() /* () -> ndet string */  {
  return "js";
}
 
 
// The current compiler version.
export function get_compiler_version() /* () -> ndet string */  {
  return "2";
}
 
 
// Return the processor maximum address size in bits (`8*sizeof(vaddr_t)`). This is usually
// equal to the `get-cpu-pointer-bits` but may be smaller on capability architectures like ARM CHERI.
export function get_cpu_address_bits() /* () -> ndet int */  {
  return 32;
}
 
 
// Return the main processor architecture: x64, x86, arm64, arm32, riscv32, riscv64, alpha64, ppc64, etc.
export function get_cpu_arch() /* () -> ndet string */  {
  return $std_core.host();
}
 
 
// Return the size of boxed values in the heap (`8*sizeof(kk_box_t)`). This is usually
// equal to `8*sizeof(void*)` but can be less if compressed pointers are used (when
// compiled with `--target=c64c` for example).
export function get_cpu_boxed_bits() /* () -> ndet int */  {
  return 32;
}
 
 
// Return the available CPU's.
// This is the logical core count including hyper-threaded cores.
export function get_cpu_count() /* () -> ndet int */  {
  return 1;
}
 
 
// Return the processor natural integer register size in bits.
//
// Note: Usually this equals the `get-cpu-size-bits` and `get-cpu-pointer-bits` on modern cpu's
// but they can differ on segmented architectures.
// For example, on the old x86 FAR-NEAR model, the addresses are 32-bit but the integer register size is 16-bit.
// Or on the more recent-[x32 ABI](https://en.wikipedia.org/wiki/X32_ABI)
// the addresses and object sizes are 32-bits but the architecture has 64-bit integer registers.
export function get_cpu_int_bits() /* () -> ndet int */  {
  return 32;
}
 
 
// Is the byte-order little-endian?
// If not, it is big-endian; other byte orders are not supported.
export function get_cpu_is_little_endian() /* () -> ndet bool */  {
  return true;
}
 
 
// Return the processor maximum pointer size in bits (`8*sizeof(void*)`). This is usually
// equal to the `get-cpu-address-bits` but may be larger on capability architectures like ARM CHERI.
export function get_cpu_pointer_bits() /* () -> ndet int */  {
  return 32;
}
 
 
// Return the processor maximum object size in bits (`8*sizeof(size_t)`). This is usually
// equal to the `get-cpu-int-bits` but may be different on segmented architectures.
export function get_cpu_size_bits() /* () -> ndet int */  {
  return 32;
}
 
 
// Return the main OS name: windows, linux, macos, unix, posix, ios, tvos, watchos, unknown.
// Sometimes has a _dash_ subsystem, like: unix-&lt;freebsd,openbsd,dragonfly,bsd&gt;, and windows-mingw.
export function get_os_name() /* () -> ndet string */  {
  return $std_core.host();
}
 
export var argv;
var argv = $std_core_delayed.delay(function() {
   
  var v_10000 = os_get_argv();
  return $std_core_vector.vlist(v_10000);
});
 
export function _trmc_to_tuples(xs, _acc) /* (xs : list<string>, ctx<env>) -> env */  { tailcall: while(1)
{
  if (xs !== null && xs.tail !== null) {
     
    var _trmc_x10002 = undefined;
     
    var _trmc_x10003 = $std_core_types.Cons($std_core_types.Tuple2(xs.head, xs.tail.head), _trmc_x10002);
    {
      // tail call
      var _x0 = $std_core_types._cctx_extend(_acc,_trmc_x10003,({obj: _trmc_x10003, field_name: "tail"}));
      xs = xs.tail.tail;
      _acc = _x0;
      continue tailcall;
    }
  }
  else if (xs !== null && xs.tail === null) {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Cons($std_core_types.Tuple2(xs.head, ""), $std_core_types.Nil)));
  }
  else {
    return $std_core_types._cctx_apply(_acc,($std_core_types.Nil));
  }
}}
 
export function to_tuples(xs_0) /* (xs : list<string>) -> env */  {
  return _trmc_to_tuples(xs_0, $std_core_types._cctx_empty());
}
 
export var environ;
var environ = $std_core_delayed.delay(function() {
   
  var v_10001 = os_get_env();
  return to_tuples($std_core_vector.vlist(v_10001));
});
 
 
// The unprocessed command line that was used to start this program.
// On ''Node'' the first arguments will often be of the form `["node","interactive.js",...]`.
export function get_argv() /* () -> ndet list<string> */  {
  return $std_core_delayed.force(argv);
}
 
 
// Return the arguments that were passed to program itself.
// Strips off the initial program from the unprocessed command line.
// i.e. If a program started as:
// ````
// > node myprogram.js --flag bla
// ````
// The `arguments` list will be `["--flag","bla"]`
export function get_args() /* () -> ndet list<string> */  {
   
  var is_node = (($std_core.host()) === ("node"));
   
  var is_vm = (($std_core.host()) === ("vm"));
  var _x1 = $std_core_delayed.force(argv);
  if (_x1 !== null) {
    if (is_node) {
      var _x2 = (($std_os_path.stemname($std_os_path.path(_x1.head))) === ("node"));
    }
    else {
      var _x2 = false;
    }
    if (_x2){
      return $std_core_list.drop(_x1.tail, 1);
    }
  }
  if (is_vm){
    return _x1;
  }
  return $std_core_list.drop(_x1, 1);
}
 
 
// Get the environment variables for this program
export function get_env() /* () -> ndet env */  {
  return $std_core_delayed.force(environ);
}
 
 
// Returns the value of an environment variable `name` (or `Nothing` if not present)
export function get_env_value(name) /* (name : string) -> ndet maybe<string> */  {
  return $std_core_list.lookup($std_core_delayed.force(environ), function(nm /* string */ ) {
      return (nm === name);
    });
}