// Koka generated module: std/os/env, koka version: 3.1.2, platform: 64-bit
#include "std_os_env.h"

kk_vector_t kk_std_os_env_os_get_argv(kk_context_t* _ctx) { /* () -> ndet vector<string> */ 
  return kk_os_get_argv(kk_context());
}

kk_vector_t kk_std_os_env_os_get_env(kk_context_t* _ctx) { /* () -> ndet vector<string> */ 
  return kk_os_get_env(kk_context());
}
 
// The backend compiler name, like `gcc`, `clang`, `cl`, `clang-cl`, `mingw`, or `icc` (and `js` for JavaScript).

kk_string_t kk_std_os_env_get_cc_name(kk_context_t* _ctx) { /* () -> ndet string */ 
  return kk_cc_name(kk_context());
}
 
// The current compiler version.

kk_string_t kk_std_os_env_get_compiler_version(kk_context_t* _ctx) { /* () -> ndet string */ 
  return kk_compiler_version(kk_context());
}
 
// Return the processor maximum address size in bits (`8*sizeof(vaddr_t)`). This is usually
// equal to the `get-cpu-pointer-bits` but may be smaller on capability architectures like ARM CHERI.

kk_integer_t kk_std_os_env_get_cpu_address_bits(kk_context_t* _ctx) { /* () -> ndet int */ 
  return kk_integer_from_int(kk_cpu_address_bits(kk_context()),kk_context());
}
 
// Return the main processor architecture: x64, x86, arm64, arm32, riscv32, riscv64, alpha64, ppc64, etc.

kk_string_t kk_std_os_env_get_cpu_arch(kk_context_t* _ctx) { /* () -> ndet string */ 
  return kk_cpu_arch(kk_context());
}
 
// Return the size of boxed values in the heap (`8*sizeof(kk_box_t)`). This is usually
// equal to `8*sizeof(void*)` but can be less if compressed pointers are used (when
// compiled with `--target=c64c` for example).

kk_integer_t kk_std_os_env_get_cpu_boxed_bits(kk_context_t* _ctx) { /* () -> ndet int */ 
  return kk_integer_from_size_t(CHAR_BIT*sizeof(kk_intb_t),kk_context());
}
 
// Return the available CPU's.
// This is the logical core count including hyper-threaded cores.

kk_integer_t kk_std_os_env_get_cpu_count(kk_context_t* _ctx) { /* () -> ndet int */ 
  return kk_integer_from_int(kk_cpu_count(kk_context()),kk_context());
}
 
// Return the processor natural integer register size in bits.
//
// Note: Usually this equals the `get-cpu-size-bits` and `get-cpu-pointer-bits` on modern cpu's
// but they can differ on segmented architectures.
// For example, on the old x86 FAR-NEAR model, the addresses are 32-bit but the integer register size is 16-bit.
// Or on the more recent-[x32 ABI](https://en.wikipedia.org/wiki/X32_ABI)
// the addresses and object sizes are 32-bits but the architecture has 64-bit integer registers.

kk_integer_t kk_std_os_env_get_cpu_int_bits(kk_context_t* _ctx) { /* () -> ndet int */ 
  return kk_integer_from_size_t(CHAR_BIT*sizeof(kk_intx_t),kk_context());
}
 
// Is the byte-order little-endian?
// If not, it is big-endian; other byte orders are not supported.

bool kk_std_os_env_get_cpu_is_little_endian(kk_context_t* _ctx) { /* () -> ndet bool */ 
  return kk_cpu_is_little_endian(kk_context());
}
 
// Return the processor maximum pointer size in bits (`8*sizeof(void*)`). This is usually
// equal to the `get-cpu-address-bits` but may be larger on capability architectures like ARM CHERI.

kk_integer_t kk_std_os_env_get_cpu_pointer_bits(kk_context_t* _ctx) { /* () -> ndet int */ 
  return kk_integer_from_size_t(CHAR_BIT*sizeof(void*),kk_context());
}
 
// Return the processor maximum object size in bits (`8*sizeof(size_t)`). This is usually
// equal to the `get-cpu-int-bits` but may be different on segmented architectures.

kk_integer_t kk_std_os_env_get_cpu_size_bits(kk_context_t* _ctx) { /* () -> ndet int */ 
  return kk_integer_from_size_t(CHAR_BIT*sizeof(size_t),kk_context());
}
 
// Return the main OS name: windows, linux, macos, unix, posix, ios, tvos, watchos, unknown.
// Sometimes has a _dash_ subsystem, like: unix-&lt;freebsd,openbsd,dragonfly,bsd&gt;, and windows-mingw.

kk_string_t kk_std_os_env_get_os_name(kk_context_t* _ctx) { /* () -> ndet string */ 
  return kk_os_name(kk_context());
}


// lift anonymous function
struct kk_std_os_env_argv_fun63__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_env_argv_fun63(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_env_new_argv_fun63(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_env_argv_fun63, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_env_argv_fun63(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_vector_t v_10000 = kk_std_os_env_os_get_argv(_ctx); /*vector<string>*/;
  kk_std_core_types__list _x_x64 = kk_std_core_vector_vlist(v_10000, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
  return kk_std_core_types__list_box(_x_x64, _ctx);
}

kk_std_core_delayed__delayed kk_std_os_env_argv;

kk_std_core_types__list kk_std_os_env__trmc_to_tuples(kk_std_core_types__list xs, kk_std_core_types__cctx _acc, kk_context_t* _ctx) { /* (xs : list<string>, ctx<env>) -> env */ 
  kk__tailcall: ;
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x65 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x2 = _con_x65->head;
    kk_std_core_types__list _pat_0 = _con_x65->tail;
    if (kk_std_core_types__is_Cons(_pat_0, _ctx)) {
      struct kk_std_core_types_Cons* _con_x66 = kk_std_core_types__as_Cons(_pat_0, _ctx);
      kk_box_t _box_x3 = _con_x66->head;
      kk_string_t name = kk_string_unbox(_box_x2);
      kk_std_core_types__list xx = _con_x66->tail;
      kk_string_t value = kk_string_unbox(_box_x3);
      kk_reuse_t _ru_x60 = kk_reuse_null; /*@reuse*/;
      if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
        if kk_likely(kk_datatype_ptr_is_unique(_pat_0, _ctx)) {
          kk_datatype_ptr_free(_pat_0, _ctx);
        }
        else {
          kk_string_dup(value, _ctx);
          kk_std_core_types__list_dup(xx, _ctx);
          kk_datatype_ptr_decref(_pat_0, _ctx);
        }
        _ru_x60 = (kk_datatype_ptr_reuse(xs, _ctx));
      }
      else {
        kk_string_dup(name, _ctx);
        kk_string_dup(value, _ctx);
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(xs, _ctx);
      }
      kk_std_core_types__list _trmc_x10002 = kk_datatype_null(); /*std/os/env/env*/;
      kk_std_core_types__list _trmc_x10003;
      kk_box_t _x_x67;
      kk_std_core_types__tuple2 _x_x68 = kk_std_core_types__new_Tuple2(kk_string_box(name), kk_string_box(value), _ctx); /*(1325, 1326)*/
      _x_x67 = kk_std_core_types__tuple2_box(_x_x68, _ctx); /*1278*/
      _trmc_x10003 = kk_std_core_types__new_Cons(_ru_x60, 0, _x_x67, _trmc_x10002, _ctx); /*list<(string, string)>*/
      kk_field_addr_t _b_x17_29 = kk_field_addr_create(&kk_std_core_types__as_Cons(_trmc_x10003, _ctx)->tail, _ctx); /*@field-addr<std/os/env/env>*/;
      { // tailcall
        kk_std_core_types__cctx _x_x69 = kk_cctx_extend_linear(_acc,(kk_std_core_types__list_box(_trmc_x10003, _ctx)),_b_x17_29,kk_context()); /*ctx<0>*/
        xs = xx;
        _acc = _x_x69;
        goto kk__tailcall;
      }
    }
  }
  if (kk_std_core_types__is_Cons(xs, _ctx)) {
    struct kk_std_core_types_Cons* _con_x70 = kk_std_core_types__as_Cons(xs, _ctx);
    kk_box_t _box_x18 = _con_x70->head;
    kk_std_core_types__list _pat_2 = _con_x70->tail;
    kk_string_t name_0 = kk_string_unbox(_box_x18);
    kk_reuse_t _ru_x61 = kk_reuse_null; /*@reuse*/;
    if kk_likely(kk_datatype_ptr_is_unique(xs, _ctx)) {
      _ru_x61 = (kk_datatype_ptr_reuse(xs, _ctx));
    }
    else {
      kk_string_dup(name_0, _ctx);
      kk_datatype_ptr_decref(xs, _ctx);
    }
    kk_box_t _x_x71;
    kk_box_t _x_x72;
    kk_std_core_types__list _x_x73;
    kk_box_t _x_x74;
    kk_std_core_types__tuple2 _x_x75;
    kk_box_t _x_x76;
    kk_string_t _x_x77 = kk_string_empty(); /*string*/
    _x_x76 = kk_string_box(_x_x77); /*1350*/
    _x_x75 = kk_std_core_types__new_Tuple2(kk_string_box(name_0), _x_x76, _ctx); /*(1349, 1350)*/
    _x_x74 = kk_std_core_types__tuple2_box(_x_x75, _ctx); /*1302*/
    _x_x73 = kk_std_core_types__new_Cons(_ru_x61, 0, _x_x74, kk_std_core_types__new_Nil(_ctx), _ctx); /*list<1302>*/
    _x_x72 = kk_std_core_types__list_box(_x_x73, _ctx); /*-1*/
    _x_x71 = kk_cctx_apply_linear(_acc,_x_x72,kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x71, KK_OWNED, _ctx);
  }
  {
    kk_box_t _x_x79 = kk_cctx_apply_linear(_acc,(kk_std_core_types__list_box(kk_std_core_types__new_Nil(_ctx), _ctx)),kk_context()); /*-1*/
    return kk_std_core_types__list_unbox(_x_x79, KK_OWNED, _ctx);
  }
}

kk_std_core_types__list kk_std_os_env_to_tuples(kk_std_core_types__list xs_0, kk_context_t* _ctx) { /* (xs : list<string>) -> env */ 
  kk_std_core_types__cctx _x_x80 = kk_cctx_empty(kk_context()); /*ctx<0>*/
  return kk_std_os_env__trmc_to_tuples(xs_0, _x_x80, _ctx);
}


// lift anonymous function
struct kk_std_os_env_environ_fun81__t {
  struct kk_function_s _base;
};
static kk_box_t kk_std_os_env_environ_fun81(kk_function_t _fself, kk_context_t* _ctx);
static kk_function_t kk_std_os_env_new_environ_fun81(kk_context_t* _ctx) {
  kk_define_static_function(_fself, kk_std_os_env_environ_fun81, _ctx)
  return kk_function_dup(_fself,kk_context());
}

static kk_box_t kk_std_os_env_environ_fun81(kk_function_t _fself, kk_context_t* _ctx) {
  kk_unused(_fself);
  kk_vector_t v_10001 = kk_std_os_env_os_get_env(_ctx); /*vector<string>*/;
  kk_std_core_types__list _x_x82;
  kk_std_core_types__list _x_x83 = kk_std_core_vector_vlist(v_10001, kk_std_core_types__new_None(_ctx), _ctx); /*list<353>*/
  _x_x82 = kk_std_os_env_to_tuples(_x_x83, _ctx); /*std/os/env/env*/
  return kk_std_core_types__list_box(_x_x82, _ctx);
}

kk_std_core_delayed__delayed kk_std_os_env_environ;
 
// Return the arguments that were passed to program itself.
// Strips off the initial program from the unprocessed command line.
// i.e. If a program started as:
// ````
// > node myprogram.js --flag bla
// ````
// The `arguments` list will be `["--flag","bla"]`

kk_std_core_types__list kk_std_os_env_get_args(kk_context_t* _ctx) { /* () -> ndet list<string> */ 
  bool is_node;
  kk_string_t _x_x86 = kk_std_core_host(_ctx); /*string*/
  kk_string_t _x_x87;
  kk_define_string_literal(, _s_x88, 4, "node", _ctx)
  _x_x87 = kk_string_dup(_s_x88, _ctx); /*string*/
  is_node = kk_string_is_eq(_x_x86,_x_x87,kk_context()); /*bool*/
  bool is_vm;
  kk_string_t _x_x89 = kk_std_core_host(_ctx); /*string*/
  kk_string_t _x_x90;
  kk_define_string_literal(, _s_x91, 2, "vm", _ctx)
  _x_x90 = kk_string_dup(_s_x91, _ctx); /*string*/
  is_vm = kk_string_is_eq(_x_x89,_x_x90,kk_context()); /*bool*/
  kk_std_core_types__list _match_x58;
  kk_box_t _x_x92;
  kk_std_core_delayed__delayed _x_x93 = kk_std_core_delayed__delayed_dup(kk_std_os_env_argv, _ctx); /*delayed/delayed<ndet,list<string>>*/
  _x_x92 = kk_std_core_delayed_force(_x_x93, _ctx); /*1541*/
  _match_x58 = kk_std_core_types__list_unbox(_x_x92, KK_OWNED, _ctx); /*list<string>*/
  if (kk_std_core_types__is_Cons(_match_x58, _ctx)) {
    struct kk_std_core_types_Cons* _con_x94 = kk_std_core_types__as_Cons(_match_x58, _ctx);
    kk_box_t _box_x46 = _con_x94->head;
    kk_string_t x = kk_string_unbox(_box_x46);
    bool _x_x95;
    if (is_node) {
      kk_string_t _x_x96;
      kk_std_os_path__path _x_x97;
      kk_string_t _x_x98 = kk_string_dup(x, _ctx); /*string*/
      _x_x97 = kk_std_os_path_path(_x_x98, _ctx); /*std/os/path/path*/
      _x_x96 = kk_std_os_path_stemname(_x_x97, _ctx); /*string*/
      kk_string_t _x_x99;
      kk_define_string_literal(, _s_x100, 4, "node", _ctx)
      _x_x99 = kk_string_dup(_s_x100, _ctx); /*string*/
      _x_x95 = kk_string_is_eq(_x_x96,_x_x99,kk_context()); /*bool*/
    }
    else {
      _x_x95 = false; /*bool*/
    }
    if (_x_x95) {
      kk_std_core_types__list xx = _con_x94->tail;
      if kk_likely(kk_datatype_ptr_is_unique(_match_x58, _ctx)) {
        kk_box_drop(_box_x46, _ctx);
        kk_datatype_ptr_free(_match_x58, _ctx);
      }
      else {
        kk_std_core_types__list_dup(xx, _ctx);
        kk_datatype_ptr_decref(_match_x58, _ctx);
      }
      return kk_std_core_list_drop(xx, kk_integer_from_small(1), _ctx);
    }
  }
  if (is_vm) {
    return _match_x58;
  }
  {
    return kk_std_core_list_drop(_match_x58, kk_integer_from_small(1), _ctx);
  }
}
 
// Returns the value of an environment variable `name` (or `Nothing` if not present)


// lift anonymous function
struct kk_std_os_env_get_env_value_fun105__t {
  struct kk_function_s _base;
  kk_string_t name;
};
static bool kk_std_os_env_get_env_value_fun105(kk_function_t _fself, kk_box_t _b_x53, kk_context_t* _ctx);
static kk_function_t kk_std_os_env_new_get_env_value_fun105(kk_string_t name, kk_context_t* _ctx) {
  struct kk_std_os_env_get_env_value_fun105__t* _self = kk_function_alloc_as(struct kk_std_os_env_get_env_value_fun105__t, 2, _ctx);
  _self->_base.fun = kk_kkfun_ptr_box(&kk_std_os_env_get_env_value_fun105, kk_context());
  _self->name = name;
  return kk_datatype_from_base(&_self->_base, kk_context());
}

static bool kk_std_os_env_get_env_value_fun105(kk_function_t _fself, kk_box_t _b_x53, kk_context_t* _ctx) {
  struct kk_std_os_env_get_env_value_fun105__t* _self = kk_function_as(struct kk_std_os_env_get_env_value_fun105__t*, _fself, _ctx);
  kk_string_t name = _self->name; /* string */
  kk_drop_match(_self, {kk_string_dup(name, _ctx);}, {}, _ctx)
  kk_string_t _x_x106 = kk_string_unbox(_b_x53); /*string*/
  return kk_string_is_eq(_x_x106,name,kk_context());
}

kk_std_core_types__maybe kk_std_os_env_get_env_value(kk_string_t name, kk_context_t* _ctx) { /* (name : string) -> ndet maybe<string> */ 
  kk_std_core_types__list _b_x51_54;
  kk_box_t _x_x103;
  kk_std_core_delayed__delayed _x_x104 = kk_std_core_delayed__delayed_dup(kk_std_os_env_environ, _ctx); /*delayed/delayed<ndet,std/os/env/env>*/
  _x_x103 = kk_std_core_delayed_force(_x_x104, _ctx); /*1687*/
  _b_x51_54 = kk_std_core_types__list_unbox(_x_x103, KK_OWNED, _ctx); /*std/os/env/env*/
  return kk_std_core_list_lookup(_b_x51_54, kk_std_os_env_new_get_env_value_fun105(name, _ctx), _ctx);
}

// initialization
void kk_std_os_env__init(kk_context_t* _ctx){
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
  kk_std_os_path__init(_ctx);
  #if defined(KK_CUSTOM_INIT)
    KK_CUSTOM_INIT (_ctx);
  #endif
  {
    kk_std_os_env_argv = kk_std_core_delayed_delay(kk_std_os_env_new_argv_fun63(_ctx), _ctx); /*delayed/delayed<ndet,list<string>>*/
  }
  {
    kk_std_os_env_environ = kk_std_core_delayed_delay(kk_std_os_env_new_environ_fun81(_ctx), _ctx); /*delayed/delayed<ndet,std/os/env/env>*/
  }
}

// termination
void kk_std_os_env__done(kk_context_t* _ctx){
  static bool _kk_done = false;
  if (_kk_done) return;
  _kk_done = true;
  #if defined(KK_CUSTOM_DONE)
    KK_CUSTOM_DONE (_ctx);
  #endif
  kk_std_core_delayed__delayed_drop(kk_std_os_env_environ, _ctx);
  kk_std_core_delayed__delayed_drop(kk_std_os_env_argv, _ctx);
  kk_std_os_path__done(_ctx);
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
