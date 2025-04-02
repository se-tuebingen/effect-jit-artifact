// Koka generated module: main, koka version: 3.1.2
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
import * as $std_os_env from './std_os_env.mjs';
 
// externals
 
// type declarations
 
// declarations
 
export function fibonacci(n) /* (n : int) -> div int */  {
  if ($std_core_types._int_eq(n,0)) {
    return 0;
  }
  else {
    if ($std_core_types._int_eq(n,1)) {
      return 1;
    }
    else {
       
      var x_10000 = fibonacci($std_core_types._int_sub(n,1));
       
      var y_10001 = fibonacci($std_core_types._int_sub(n,2));
      return $std_core_types._int_add(x_10000,y_10001);
    }
  }
}
 
export function main() /* () -> <console/console,div,ndet> () */  {
   
  var xs_10008 = $std_os_env.get_args();
   
  var _x0 = (xs_10008 !== null) ? xs_10008.head : "";
  var m_10006 = $std_core_int.parse_int(_x0);
   
  var _x1 = (m_10006 === null) ? 5 : m_10006.value;
  var r = fibonacci(_x1);
  return $std_core_console.printsln($std_core_int.show(r));
}