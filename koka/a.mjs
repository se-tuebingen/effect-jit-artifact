// Koka generated module: test/algeff/effs1/@main, koka version: 3.1.2
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
import * as $test_algeff_effs1 from './test_algeff_effs1.mjs';
 
// externals
 
// type declarations
 
// declarations
 
export function _expr() /* () -> console/console () */  {
   
  var s_10000 = $std_core_list.show($test_algeff_effs1.amb($test_algeff_effs1.xor), $std_core_bool.show);
  return $std_core_console.printsln(s_10000);
}
 
export function _main() /* () -> <st<global>,console/console,div,fsys,ndet,net,ui> () */  {
   
  var s_10000 = $std_core_list.show($test_algeff_effs1.amb($test_algeff_effs1.xor), $std_core_bool.show);
  return $std_core_console.printsln(s_10000);
}
 
// main entry:
_main($std_core.id);