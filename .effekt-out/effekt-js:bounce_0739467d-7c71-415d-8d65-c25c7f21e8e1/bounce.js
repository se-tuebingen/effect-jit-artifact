const $effekt = {  };

class OutOfBounds_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "OutOfBounds", __data: [] };
  }
  __equals(other6015) {
    if (!other6015) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other6015.__tag))) {
      return false;
    }
    return true;
  }
}

class None_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "None", __data: [] };
  }
  __equals(other6016) {
    if (!other6016) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other6016.__tag))) {
      return false;
    }
    return true;
  }
}

class Some_0 {
  constructor(value_0) {
    this.__tag = 1;
    this.value_0 = value_0;
  }
  __reflect() {
    return { __tag: 1, __name: "Some", __data: [this.value_0] };
  }
  __equals(other6017) {
    if (!other6017) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other6017.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.value_0, other6017.value_0))) {
      return false;
    }
    return true;
  }
}

class Nil_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "Nil", __data: [] };
  }
  __equals(other6018) {
    if (!other6018) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other6018.__tag))) {
      return false;
    }
    return true;
  }
}

class Cons_0 {
  constructor(head_0, tail_0) {
    this.__tag = 1;
    this.head_0 = head_0;
    this.tail_0 = tail_0;
  }
  __reflect() {
    return { __tag: 1, __name: "Cons", __data: [this.head_0, this.tail_0] };
  }
  __equals(other6019) {
    if (!other6019) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other6019.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.head_0, other6019.head_0))) {
      return false;
    }
    if (!($effekt.equals(this.tail_0, other6019.tail_0))) {
      return false;
    }
    return true;
  }
}

class Error_0 {
  constructor(exception_0, msg_0) {
    this.__tag = 0;
    this.exception_0 = exception_0;
    this.msg_0 = msg_0;
  }
  __reflect() {
    return {
      __tag: 0,
      __name: "Error",
      __data: [this.exception_0, this.msg_0]
    };
  }
  __equals(other6020) {
    if (!other6020) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other6020.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.exception_0, other6020.exception_0))) {
      return false;
    }
    if (!($effekt.equals(this.msg_0, other6020.msg_0))) {
      return false;
    }
    return true;
  }
}

class Success_0 {
  constructor(a_0) {
    this.__tag = 1;
    this.a_0 = a_0;
  }
  __reflect() {
    return { __tag: 1, __name: "Success", __data: [this.a_0] };
  }
  __equals(other6021) {
    if (!other6021) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other6021.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.a_0, other6021.a_0))) {
      return false;
    }
    return true;
  }
}


// Common Runtime
// --------------
function Cell(init, region) {
  const cell = {
    value: init,
    backup: function() {
      const _backup = cell.value;
      // restore function (has a STRONG reference to `this`)
      return () => { cell.value = _backup; return cell }
    }
  }
  return cell;
}

const global = {
  fresh: Cell
}

function Arena(_region) {
  const region = _region;
  return {
    fresh: function(init) {
      const cell = Cell(init);
      // region keeps track what to backup, but we do not need to backup unreachable cells
      region.push(cell) // new WeakRef(cell))
      return cell;
    },
    region: _region,
    newRegion: function() {
      // a region aggregates weak references
      const nested = Arena([])
      // this doesn't work yet, since Arena.backup doesn't return a thunk
      region.push(nested) //new WeakRef(nested))
      return nested;
    },
    backup: function() {
      const _backup = []
      let nextIndex = 0;
      for (const ref of region) {
        const cell = ref //.deref()
        // only backup live cells
        if (cell) {
          _backup[nextIndex] = cell.backup()
          nextIndex++
        }
      }
      function restore() {
        const region = []
        let nextIndex = 0;
        for (const restoreCell of _backup) {
          region[nextIndex] = restoreCell() // new WeakRef(restoreCell())
          nextIndex++
        }
        return Arena(region)
      }
      return restore;
    }
  }
}


let _prompt = 1;

const TOPLEVEL_K = (x, ks) => { throw { computationIsDone: true, result: x } }
const TOPLEVEL_KS = { prompt: 0, arena: Arena([]), rest: null }

function THUNK(f) {
  f.thunk = true
  return f
}

function CAPTURE(body) {
  return (ks, k) => {
    const res = body(x => TRAMPOLINE(() => k(x, ks)))
    if (res instanceof Function) return res
    else throw { computationIsDone: true, result: $effekt.unit }
  }
}

const RETURN = (x, ks) => ks.rest.stack(x, ks.rest)

// const r = ks.arena.newRegion(); body
// const x = r.alloc(init); body

// HANDLE(ks, ks, (p, ks, k) => { STMT })
function RESET(prog, ks, k) {
  const prompt = _prompt++;
  const rest = { stack: k, prompt: ks.prompt, arena: ks.arena, rest: ks.rest }
  return prog(prompt, { prompt, arena: Arena([]), rest }, RETURN)
}

function DEALLOC(ks) {
  const arena = ks.arena
  if (!!arena) {
    arena.length = arena.length - 1
  }
}

function SHIFT(p, body, ks, k) {

  // TODO avoid constructing this object
  let meta = { stack: k, prompt: ks.prompt, arena: ks.arena, rest: ks.rest }
  let cont = null

  while (!!meta && meta.prompt !== p) {
    cont = { stack: meta.stack, prompt: meta.prompt, backup: meta.arena.backup(), rest: cont }
    meta = meta.rest
  }
  if (!meta) { throw `Prompt not found ${p}` }

  // package the prompt itself
  cont = { stack: meta.stack, prompt: meta.prompt, backup: meta.arena.backup(), rest: cont }
  meta = meta.rest

  const k1 = meta.stack
  meta.stack = null
  return body(cont, meta, k1)
}

// Rewind stack `cont` back onto `k` :: `ks` and resume with c
function RESUME(cont, c, ks, k) {
  let meta = { stack: k, prompt: ks.prompt, arena: ks.arena, rest: ks.rest }
  let toRewind = cont
  while (!!toRewind) {
    meta = { stack: toRewind.stack, prompt: toRewind.prompt, arena: toRewind.backup(), rest: meta }
    toRewind = toRewind.rest
  }

  const k1 = meta.stack // TODO instead copy meta here, like elsewhere?
  meta.stack = null
  return () => c(meta, k1)
}

function RUN_TOPLEVEL(comp) {
  try {
    let a = comp(TOPLEVEL_KS, TOPLEVEL_K)
    while (true) { a = a() }
  } catch (e) {
    if (e.computationIsDone) return e.result
    else throw e
  }
}

// trampolines the given computation (like RUN_TOPLEVEL, but doesn't provide continuations)
function TRAMPOLINE(comp) {
  let a = comp;
  try {
    while (true) {
      a = a()
    }
  } catch (e) {
    if (e.computationIsDone) return e.result
    else throw e
  }
}

// keeps the current trampoline going and dispatches the given task
function RUN(task) {
  return () => task(TOPLEVEL_KS, TOPLEVEL_K)
}

// aborts the current continuation
function ABORT(value) {
  throw { computationIsDone: true, result: value }
}


// "Public API" used in FFI
// ------------------------

/**
 * Captures the current continuation as a WHOLE and makes it available
 * as argument to the passed body. For example:
 *
 *   $effekt.capture(k => ... k(42) ...)
 *
 * The body
 *
 *   $effekt.capture(k => >>> ... <<<)
 *
 * conceptually runs on the _native_ JS call stack. You can call JS functions,
 * like `setTimeout` etc., but you are not expected or required to return an
 * Effekt value like `$effekt.unit`. If you want to run an Effekt computation
 * like in `io::spawn`, you can use `$effekt.run`.
 *
 * Advanced usage details:
 *
 * The value returned by the function passed to `capture` returns
 * - a function: the returned function will be passed to the
 *   Effekt runtime, which performs trampolining.
 *   In this case, the Effekt runtime will keep running, though the
 *   continuation has been removed.
 *
 * - another value (like `undefined`): the Effekt runtime will terminate.
 */
$effekt.capture = CAPTURE

/**
 * Used to call Effekt function arguments in the JS FFI, like in `io::spawn`.
 *
 * Requires an active Effekt runtime (trampoline).
 */
$effekt.run = RUN

/**
 * Used to call Effekt function arguments in the JS FFI, like in `network::listen`.
 *
 * This function should be used when _no_ Effekt runtime is available. For instance,
 * in callbacks passed to the NodeJS eventloop.
 *
 * If a runtime is available, use `$effekt.run`, instead.
 */
$effekt.runToplevel = RUN_TOPLEVEL


$effekt.show = function(obj) {
  if (!!obj && !!obj.__reflect) {
    const meta = obj.__reflect()
    return meta.__name + "(" + meta.__data.map($effekt.show).join(", ") + ")"
  }
  else if (!!obj && obj.__unit) {
    return "()";
  } else {
    return "" + obj;
  }
}

$effekt.equals = function(obj1, obj2) {
  if (!!obj1.__equals) {
    return obj1.__equals(obj2)
  } else {
    return (obj1.__unit && obj2.__unit) || (obj1 === obj2);
  }
}

function compare$prim(n1, n2) {
  if (n1 == n2) { return 0; }
  else if (n1 > n2) { return 1; }
  else { return -1; }
}

$effekt.compare = function(obj1, obj2) {
  if ($effekt.equals(obj1, obj2)) { return 0; }

  if (!!obj1 && !!obj2) {
    if (!!obj1.__reflect && !!obj2.__reflect) {
      const tagOrdering = compare$prim(obj1.__tag, obj2.__tag)
      if (tagOrdering != 0) { return tagOrdering; }

      const meta1 = obj1.__reflect().__data
      const meta2 = obj2.__reflect().__data

      const lengthOrdering = compare$prim(meta1.length, meta2.length)
      if (lengthOrdering != 0) { return lengthOrdering; }

      for (let i = 0; i < meta1.length; i++) {
        const contentOrdering = $effekt.compare(meta1[i], meta2[i])
        if (contentOrdering != 0) { return contentOrdering; }
      }

      return 0;
    }
  }

  return compare$prim(obj1, obj2);
}

$effekt.println = function println$impl(str) {
  console.log(str); return $effekt.unit;
}

$effekt.unit = { __unit: true }

$effekt.emptyMatch = function() { throw "empty match" }

$effekt.hole = function() { throw "not implemented, yet" }


  function array$set(arr, index, value) {
    arr[index] = value;
    return $effekt.unit
  }



  function set$impl(ref, value) {
    ref.value = value;
    return $effekt.unit;
  }



  const { performance } = require('node:perf_hooks');


const global_0 = global;

function charAt_0(str_0, index_0, Exception_0, ks_0, k_0) {
  let v_r_0 = undefined;
  if ((index_0 < (0))) {
    v_r_0 = true;
  } else {
    v_r_0 = (index_0 >= (str_0.length));
  }
  if (v_r_0) {
    return Exception_0.raise_0(new OutOfBounds_0(), ((((((((((("Index out of bounds: ") + (('' + index_0))))) + (" in string: '")))) + (str_0)))) + ("'")), ks_0, undefined);
  } else {
    return () => k_0(str_0.codePointAt(index_0), ks_0);
  }
}

function run_0(n_0, ks_1, k_5) {
  const seed_0 = ks_1.arena.fresh(74755);
  const ballCount_0 = 100;
  const bounces_0 = ks_1.arena.fresh(0);
  const tmp_0 = (new Array(ballCount_0));
  function loop_0(i_0, ks_3, k_2) {
    loop_1: while (true) {
      if ((i_0 < ballCount_0)) {
        const x_0 = seed_0.value;
        seed_0.value = (((((x_0 * (1309))) + (13849))) & (65535));
        const x_1 = seed_0.value;
        const tmp_1 = { value: (((x_1 % (500)))) };
        const x_2 = seed_0.value;
        seed_0.value = (((((x_2 * (1309))) + (13849))) & (65535));
        const x_3 = seed_0.value;
        const tmp_2 = { value: (((x_3 % (500)))) };
        const x_4 = seed_0.value;
        seed_0.value = (((((x_4 * (1309))) + (13849))) & (65535));
        const x_5 = seed_0.value;
        const tmp_3 = { value: (((((x_5 % (300))) - (150)))) };
        const x_6 = seed_0.value;
        seed_0.value = (((((x_6 * (1309))) + (13849))) & (65535));
        const x_7 = seed_0.value;
        const tmp_4 = { value: (((((x_7 % (300))) - (150)))) };
        const tmp_5 = array$set(tmp_0, i_0, {
          bounce_0: (ks_2, k_1) => {
            const xLimit_0 = 500.0;
            const yLimit_0 = 500.0;
            const bounced_0 = ks_2.arena.fresh(false);
            const tmp_6 = tmp_1.value;
            const tmp_7 = tmp_3.value;
            const tmp_8 = set$impl(tmp_1, ((tmp_6 + tmp_7)));
            const tmp_9 = tmp_2.value;
            const tmp_10 = tmp_4.value;
            const tmp_11 = set$impl(tmp_2, ((tmp_9 + tmp_10)));
            const tmp_12 = tmp_1.value;
            let _0 = undefined;
            if ((tmp_12 > xLimit_0)) {
              const tmp_13 = set$impl(tmp_1, xLimit_0);
              const tmp_14 = tmp_3.value;
              const tmp_15 = ((0.0) - tmp_14);
              let v_r_1 = undefined;
              if ((tmp_14 > tmp_15)) {
                v_r_1 = tmp_14;
              } else {
                v_r_1 = tmp_15;
              }
              const tmp_16 = set$impl(tmp_3, (((0.0) - v_r_1)));
              bounced_0.value = true;
              _0 = $effekt.unit;
            } else {
              _0 = $effekt.unit;
            }
            const tmp_17 = tmp_1.value;
            let _1 = undefined;
            if ((tmp_17 < (0.0))) {
              const tmp_18 = set$impl(tmp_1, (0.0));
              const tmp_19 = tmp_3.value;
              const tmp_20 = ((0.0) - tmp_19);
              let v_r_2 = undefined;
              if ((tmp_19 > tmp_20)) {
                v_r_2 = tmp_19;
              } else {
                v_r_2 = tmp_20;
              }
              const tmp_21 = set$impl(tmp_3, v_r_2);
              bounced_0.value = true;
              _1 = $effekt.unit;
            } else {
              _1 = $effekt.unit;
            }
            const tmp_22 = tmp_2.value;
            let _2 = undefined;
            if ((tmp_22 > yLimit_0)) {
              const tmp_23 = set$impl(tmp_2, yLimit_0);
              const tmp_24 = tmp_4.value;
              const tmp_25 = ((0.0) - tmp_24);
              let v_r_3 = undefined;
              if ((tmp_24 > tmp_25)) {
                v_r_3 = tmp_24;
              } else {
                v_r_3 = tmp_25;
              }
              const tmp_26 = set$impl(tmp_4, (((0.0) - v_r_3)));
              bounced_0.value = true;
              _2 = $effekt.unit;
            } else {
              _2 = $effekt.unit;
            }
            const tmp_27 = tmp_2.value;
            if ((tmp_27 < (0.0))) {
              const tmp_28 = set$impl(tmp_2, (0.0));
              const tmp_29 = tmp_4.value;
              const tmp_30 = ((0.0) - tmp_29);
              let v_r_4 = undefined;
              if ((tmp_29 > tmp_30)) {
                v_r_4 = tmp_29;
              } else {
                v_r_4 = tmp_30;
              }
              const tmp_31 = set$impl(tmp_4, v_r_4);
              bounced_0.value = true;
              const x_8 = bounced_0.value;
              DEALLOC(bounced_0);
              return () => k_1(x_8, ks_2);
            } else {
              const x_9 = bounced_0.value;
              DEALLOC(bounced_0);
              return () => k_1(x_9, ks_2);
            }
          }
        });
        /* prepare call */
        const tmp_i_0 = i_0;
        i_0 = (tmp_i_0 + (1));
        continue loop_1;
      } else {
        return () => k_2($effekt.unit, ks_3);
      }
    }
  }
  return loop_0(0, ks_1, (_3, ks_4) => {
    function loop_2(i_1, ks_7, k_4) {
      if ((i_1 < n_0)) {
        function loop_3(i_2, ks_5, k_3) {
          if ((i_2 < ballCount_0)) {
            const tmp_32 = tmp_0[i_2];
            const tmp_33 = tmp_32;
            return tmp_33.bounce_0(ks_5, (didBounce_0, ks_6) => {
              let _4 = undefined;
              if (didBounce_0) {
                const x_10 = bounces_0.value;
                bounces_0.value = (x_10 + (1));
                _4 = $effekt.unit;
              } else {
                _4 = $effekt.unit;
              }
              return loop_3((i_2 + (1)), ks_6, k_3);
            });
          } else {
            return () => k_3($effekt.unit, ks_5);
          }
        }
        return loop_3(0, ks_7, (_5, ks_8) => loop_2((i_1 + (1)), ks_8, k_4));
      } else {
        return () => k_4($effekt.unit, ks_7);
      }
    }
    return loop_2(0, ks_4, (_6, ks_9) => {
      const x_11 = bounces_0.value;
      DEALLOC(bounces_0);
      DEALLOC(seed_0);
      return () => k_5(x_11, ks_9);
    });
  });
}

function main_0(ks_25, k_21) {
  return RESET((p_0, ks_10, k_6) => {
    const tmp_34 = process.argv.slice(1);
    const tmp_35 = tmp_34.length;
    function toList_worker_0(start_0, acc_0, ks_11, k_7) {
      toList_worker_1: while (true) {
        if ((start_0 < (1))) {
          return () => k_7(acc_0, ks_11);
        } else {
          const tmp_36 = tmp_34[start_0];
          /* prepare call */
          const tmp_start_0 = start_0;
          const tmp_acc_0 = acc_0;
          start_0 = (tmp_start_0 - (1));
          acc_0 = new Cons_0(tmp_36, tmp_acc_0);
          continue toList_worker_1;
        }
      }
    }
    return toList_worker_0((tmp_35 - (1)), new Nil_0(), ks_10, (v_r_5, ks_12) => {
      let v_r_6 = undefined;
      switch (v_r_5.__tag) {
        case 0:  v_r_6 = new None_0();break;
        case 1: 
          const v_y_0 = v_r_5.head_0;
          v_r_6 = new Some_0(v_y_0);
          break;
      }
      let v_r_7 = undefined;
      switch (v_r_6.__tag) {
        case 0:  v_r_7 = "";break;
        case 1:  const v_y_1 = v_r_6.value_0;v_r_7 = v_y_1;break;
      }
      function go_0(index_1, acc_1, ks_17, k_12) {
        return RESET((p_1, ks_13, k_8) => {
          const Exception_1 = {
            raise_0: (exc_0, msg_1, ks_14, k_9) =>
              SHIFT(p_1, (k_10, ks_15, k_11) =>
                () => k_11(new Error_0(exc_0, msg_1), ks_15), ks_14, undefined)
          };
          return charAt_0(v_r_7, index_1, Exception_1, ks_13, (v_r_8, ks_16) =>
            () => k_8(new Success_0(v_r_8), ks_16));
        }, ks_17, (v_r_9, ks_18) => {
          switch (v_r_9.__tag) {
            case 1: 
              const v_y_2 = v_r_9.a_0;
              if ((v_y_2 >= (48))) if ((v_y_2 <= (57))) {
                return go_0((index_1 + (1)), ((((10) * acc_1)) + (((v_y_2) - ((48))))), ks_18, k_12);
              } else {
                return SHIFT(p_0, (k_13, ks_19, k_14) =>
                  () => k_14(5, ks_19), ks_18, undefined);
              } else {
                return SHIFT(p_0, (k_15, ks_20, k_16) =>
                  () => k_16(5, ks_20), ks_18, undefined);
              }
              break;
            case 0:  return () => k_12(acc_1, ks_18);
          }
        });
      }
      const Exception_2 = {
        raise_0: (exception_1, msg_2, ks_21, k_17) =>
          SHIFT(p_0, (k_18, ks_22, k_19) => () => k_19(5, ks_22), ks_21, undefined)
      };
      return charAt_0(v_r_7, 0, Exception_2, ks_12, (v_r_10, ks_23) => {
        if (v_r_10 === (45)) {
          return go_0(1, 0, ks_23, (v_r_11, ks_24) =>
            () => k_6(((0) - v_r_11), ks_24));
        } else {
          return go_0(0, 0, ks_23, k_6);
        }
      });
    });
  }, ks_25, (n_1, ks_26) => {
    function loop_4(i_3, ks_27, k_20) {
      if ((i_3 < ((n_1 - (1))))) {
        return run_0(50, ks_27, (v_r_12, ks_28) =>
          loop_4((i_3 + (1)), ks_28, k_20));
      } else {
        return () => k_20($effekt.unit, ks_27);
      }
    }
    return loop_4(0, ks_26, (v_r_13, ks_29) =>
      run_0(50, ks_29, (r_0, ks_30) => {
        const tmp_37 = $effekt.println(('' + r_0));
        return () => k_21(tmp_37, ks_30);
      }));
  });
}

(typeof module != "undefined" && module !== null ? module : {}).exports = $bounce = {
  main: () => RUN_TOPLEVEL(main_0)
};