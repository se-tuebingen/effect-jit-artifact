#pragma once
#ifndef kk_test_bench_koka_counter__main_H
#define kk_test_bench_koka_counter__main_H
// Koka generated module: test/bench/koka/counter/@main, koka version: 3.1.2, platform: 64-bit
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
#include "test_bench_koka_counter.h"

// type declarations

// value declarations

static inline kk_unit_t kk_test_bench_koka_counter__main__expr(kk_context_t* _ctx) { /* () -> <console/console,div> () */ 
  kk_test_bench_koka_counter_main(_ctx); return kk_Unit;
}

static inline kk_unit_t kk_test_bench_koka_counter__main__main(kk_context_t* _ctx) { /* () -> <st<global>,console/console,div,fsys,ndet,net,ui> () */ 
  kk_test_bench_koka_counter_main(_ctx); return kk_Unit;
}

void kk_test_bench_koka_counter__main__init(kk_context_t* _ctx);


void kk_test_bench_koka_counter__main__done(kk_context_t* _ctx);

#endif // header
