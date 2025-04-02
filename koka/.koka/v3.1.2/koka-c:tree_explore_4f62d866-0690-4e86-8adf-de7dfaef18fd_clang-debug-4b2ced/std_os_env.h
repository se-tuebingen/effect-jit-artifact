#pragma once
#ifndef kk_std_os_env_H
#define kk_std_os_env_H
// Koka generated module: std/os/env, koka version: 3.1.2, platform: 64-bit
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
#include "std_os_path.h"

// type declarations

// value declarations

kk_vector_t kk_std_os_env_os_get_argv(kk_context_t* _ctx); /* () -> ndet vector<string> */ 

kk_vector_t kk_std_os_env_os_get_env(kk_context_t* _ctx); /* () -> ndet vector<string> */ 

kk_string_t kk_std_os_env_get_cc_name(kk_context_t* _ctx); /* () -> ndet string */ 

kk_string_t kk_std_os_env_get_compiler_version(kk_context_t* _ctx); /* () -> ndet string */ 

kk_integer_t kk_std_os_env_get_cpu_address_bits(kk_context_t* _ctx); /* () -> ndet int */ 

kk_string_t kk_std_os_env_get_cpu_arch(kk_context_t* _ctx); /* () -> ndet string */ 

kk_integer_t kk_std_os_env_get_cpu_boxed_bits(kk_context_t* _ctx); /* () -> ndet int */ 

kk_integer_t kk_std_os_env_get_cpu_count(kk_context_t* _ctx); /* () -> ndet int */ 

kk_integer_t kk_std_os_env_get_cpu_int_bits(kk_context_t* _ctx); /* () -> ndet int */ 

bool kk_std_os_env_get_cpu_is_little_endian(kk_context_t* _ctx); /* () -> ndet bool */ 

kk_integer_t kk_std_os_env_get_cpu_pointer_bits(kk_context_t* _ctx); /* () -> ndet int */ 

kk_integer_t kk_std_os_env_get_cpu_size_bits(kk_context_t* _ctx); /* () -> ndet int */ 

kk_string_t kk_std_os_env_get_os_name(kk_context_t* _ctx); /* () -> ndet string */ 

extern kk_std_core_delayed__delayed kk_std_os_env_argv;

kk_std_core_types__list kk_std_os_env__trmc_to_tuples(kk_std_core_types__list xs, kk_std_core_types__cctx _acc, kk_context_t* _ctx); /* (xs : list<string>, ctx<env>) -> env */ 

kk_std_core_types__list kk_std_os_env_to_tuples(kk_std_core_types__list xs_0, kk_context_t* _ctx); /* (xs : list<string>) -> env */ 

extern kk_std_core_delayed__delayed kk_std_os_env_environ;
 
// The unprocessed command line that was used to start this program.
// On ''Node'' the first arguments will often be of the form `["node","interactive.js",...]`.

static inline kk_std_core_types__list kk_std_os_env_get_argv(kk_context_t* _ctx) { /* () -> ndet list<string> */ 
  kk_box_t _x_x84;
  kk_std_core_delayed__delayed _x_x85 = kk_std_core_delayed__delayed_dup(kk_std_os_env_argv, _ctx); /*delayed/delayed<ndet,list<string>>*/
  _x_x84 = kk_std_core_delayed_force(_x_x85, _ctx); /*1541*/
  return kk_std_core_types__list_unbox(_x_x84, KK_OWNED, _ctx);
}

kk_std_core_types__list kk_std_os_env_get_args(kk_context_t* _ctx); /* () -> ndet list<string> */ 
 
// Get the environment variables for this program

static inline kk_std_core_types__list kk_std_os_env_get_env(kk_context_t* _ctx) { /* () -> ndet env */ 
  kk_box_t _x_x101;
  kk_std_core_delayed__delayed _x_x102 = kk_std_core_delayed__delayed_dup(kk_std_os_env_environ, _ctx); /*delayed/delayed<ndet,std/os/env/env>*/
  _x_x101 = kk_std_core_delayed_force(_x_x102, _ctx); /*1687*/
  return kk_std_core_types__list_unbox(_x_x101, KK_OWNED, _ctx);
}

kk_std_core_types__maybe kk_std_os_env_get_env_value(kk_string_t name, kk_context_t* _ctx); /* (name : string) -> ndet maybe<string> */ 

void kk_std_os_env__init(kk_context_t* _ctx);


void kk_std_os_env__done(kk_context_t* _ctx);

#endif // header
