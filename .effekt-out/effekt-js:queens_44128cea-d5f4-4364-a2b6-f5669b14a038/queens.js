const $effekt = {  };

class OutOfBounds_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "OutOfBounds", __data: [] };
  }
  __equals(other5448) {
    if (!other5448) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5448.__tag))) {
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
  __equals(other5449) {
    if (!other5449) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5449.__tag))) {
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
  __equals(other5450) {
    if (!other5450) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5450.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.value_0, other5450.value_0))) {
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
  __equals(other5451) {
    if (!other5451) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5451.__tag))) {
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
  __equals(other5452) {
    if (!other5452) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5452.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.head_0, other5452.head_0))) {
      return false;
    }
    if (!($effekt.equals(this.tail_0, other5452.tail_0))) {
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
  __equals(other5453) {
    if (!other5453) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5453.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.exception_0, other5453.exception_0))) {
      return false;
    }
    if (!($effekt.equals(this.msg_0, other5453.msg_0))) {
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
  __equals(other5454) {
    if (!other5454) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5454.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.a_0, other5454.a_0))) {
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

function run_0(n_0, ks_2, k_19) {
  const tmp_0 = (new Array((0)));
  function loop_0(i_0, ks_1, k_1) {
    loop_1: while (true) {
      if ((i_0 < (0))) {
        const tmp_1 = array$set(tmp_0, i_0, (true));
        /* prepare call */
        const tmp_i_0 = i_0;
        i_0 = (tmp_i_0 + (1));
        continue loop_1;
      } else {
        return () => k_1($effekt.unit, ks_1);
      }
    }
  }
  return loop_0(0, ks_2, (v_r_1, ks_3) => {
    const freeRows_0 = ks_3.arena.fresh(tmp_0);
    const tmp_2 = (new Array((0)));
    function loop_2(i_1, ks_4, k_2) {
      loop_3: while (true) {
        if ((i_1 < (0))) {
          const tmp_3 = array$set(tmp_2, i_1, (true));
          /* prepare call */
          const tmp_i_1 = i_1;
          i_1 = (tmp_i_1 + (1));
          continue loop_3;
        } else {
          return () => k_2($effekt.unit, ks_4);
        }
      }
    }
    return loop_2(0, ks_3, (v_r_2, ks_5) => {
      const freeMaxs_0 = ks_5.arena.fresh(tmp_2);
      const tmp_4 = (new Array((0)));
      function loop_4(i_2, ks_6, k_3) {
        loop_5: while (true) {
          if ((i_2 < (0))) {
            const tmp_5 = array$set(tmp_4, i_2, (true));
            /* prepare call */
            const tmp_i_2 = i_2;
            i_2 = (tmp_i_2 + (1));
            continue loop_5;
          } else {
            return () => k_3($effekt.unit, ks_6);
          }
        }
      }
      return loop_4(0, ks_5, (v_r_3, ks_7) => {
        const freeMins_0 = ks_7.arena.fresh(tmp_4);
        const tmp_6 = (new Array((0)));
        function loop_6(i_3, ks_8, k_4) {
          loop_7: while (true) {
            if ((i_3 < (0))) {
              const tmp_7 = array$set(tmp_6, i_3, (-1));
              /* prepare call */
              const tmp_i_3 = i_3;
              i_3 = (tmp_i_3 + (1));
              continue loop_7;
            } else {
              return () => k_4($effekt.unit, ks_8);
            }
          }
        }
        return loop_6(0, ks_7, (v_r_4, ks_9) => {
          const queenRows_0 = ks_9.arena.fresh(tmp_6);
          function placeQueen_0(c_0, ks_17, k_12) {
            return RESET((p_0, ks_10, k_5) => {
              function loop_8(i_4, ks_13, k_7) {
                if ((i_4 < n_0)) {
                  const x_0 = freeRows_0.value;
                  const tmp_8 = x_0[i_4];
                  let v_r_5 = undefined;
                  if (tmp_8) {
                    const x_1 = freeMaxs_0.value;
                    const tmp_9 = x_1[((c_0 + i_4))];
                    v_r_5 = tmp_9;
                  } else {
                    v_r_5 = false;
                  }
                  let v_r_6 = undefined;
                  if (v_r_5) {
                    const x_2 = freeMins_0.value;
                    const tmp_10 = x_2[((((c_0 - i_4)) + ((n_0 - (1)))))];
                    v_r_6 = tmp_10;
                  } else {
                    v_r_6 = false;
                  }
                  function k_6(_0, ks_11) {
                    return loop_8((i_4 + (1)), ks_11, k_7);
                  }
                  if (v_r_6) {
                    const x_3 = queenRows_0.value;
                    const tmp_11 = array$set(x_3, i_4, c_0);
                    const x_4 = freeRows_0.value;
                    const tmp_12 = array$set(x_4, i_4, (false));
                    const x_5 = freeMaxs_0.value;
                    const tmp_13 = array$set(x_5, ((c_0 + i_4)), (false));
                    const x_6 = freeMins_0.value;
                    const tmp_14 = array$set(x_6, ((((c_0 - i_4)) + ((n_0 - (1))))), (false));
                    let _1 = undefined;
                    if (c_0 === ((n_0 - (1)))) {
                      return SHIFT(p_0, (k_8, ks_12, k_9) =>
                        () => k_9(true, ks_12), ks_13, undefined);
                    } else {
                      _1 = $effekt.unit;
                    }
                    return placeQueen_0((c_0 + (1)), ks_13, (v_r_7, ks_14) => {
                      let _2 = undefined;
                      if (v_r_7) {
                        return SHIFT(p_0, (k_10, ks_15, k_11) =>
                          () => k_11(true, ks_15), ks_14, undefined);
                      } else {
                        _2 = $effekt.unit;
                      }
                      const x_7 = freeRows_0.value;
                      const tmp_15 = array$set(x_7, i_4, (true));
                      const x_8 = freeMaxs_0.value;
                      const tmp_16 = array$set(x_8, ((c_0 + i_4)), (true));
                      const x_9 = freeMins_0.value;
                      const tmp_17 = array$set(x_9, ((((c_0 - i_4)) + ((n_0 - (1))))), (true));
                      return () => k_6(tmp_17, ks_14);
                    });
                  } else {
                    return () => k_6($effekt.unit, ks_13);
                  }
                } else {
                  return () => k_7($effekt.unit, ks_13);
                }
              }
              return loop_8(0, ks_10, (_3, ks_16) =>
                () => k_5(false, ks_16));
            }, ks_17, k_12);
          }
          const j_0 = ks_9.arena.fresh(true);
          function loop_9(i_5, ks_20, k_14) {
            if ((i_5 < (10))) {
              const x_10 = j_0.value;
              function k_13(v_r_8, ks_18) {
                j_0.value = v_r_8;
                return loop_9((i_5 + (1)), ks_18, k_14);
              }
              if (x_10) {
                const tmp_18 = (new Array(n_0));
                function loop_10(i_6, ks_19, k_15) {
                  loop_11: while (true) {
                    if ((i_6 < n_0)) {
                      const tmp_19 = array$set(tmp_18, i_6, (true));
                      /* prepare call */
                      const tmp_i_4 = i_6;
                      i_6 = (tmp_i_4 + (1));
                      continue loop_11;
                    } else {
                      return () => k_15($effekt.unit, ks_19);
                    }
                  }
                }
                return loop_10(0, ks_20, (v_r_9, ks_21) => {
                  freeRows_0.value = tmp_18;
                  const tmp_20 = ((2) * n_0);
                  const tmp_21 = (new Array(tmp_20));
                  function loop_12(i_7, ks_22, k_16) {
                    loop_13: while (true) {
                      if ((i_7 < tmp_20)) {
                        const tmp_22 = array$set(tmp_21, i_7, (true));
                        /* prepare call */
                        const tmp_i_5 = i_7;
                        i_7 = (tmp_i_5 + (1));
                        continue loop_13;
                      } else {
                        return () => k_16($effekt.unit, ks_22);
                      }
                    }
                  }
                  return loop_12(0, ks_21, (v_r_10, ks_23) => {
                    freeMaxs_0.value = tmp_21;
                    const tmp_23 = ((2) * n_0);
                    const tmp_24 = (new Array(tmp_23));
                    function loop_14(i_8, ks_24, k_17) {
                      loop_15: while (true) {
                        if ((i_8 < tmp_23)) {
                          const tmp_25 = array$set(tmp_24, i_8, (true));
                          /* prepare call */
                          const tmp_i_6 = i_8;
                          i_8 = (tmp_i_6 + (1));
                          continue loop_15;
                        } else {
                          return () => k_17($effekt.unit, ks_24);
                        }
                      }
                    }
                    return loop_14(0, ks_23, (v_r_11, ks_25) => {
                      freeMins_0.value = tmp_24;
                      const tmp_26 = (new Array(n_0));
                      function loop_16(i_9, ks_26, k_18) {
                        loop_17: while (true) {
                          if ((i_9 < n_0)) {
                            const tmp_27 = array$set(tmp_26, i_9, (-1));
                            /* prepare call */
                            const tmp_i_7 = i_9;
                            i_9 = (tmp_i_7 + (1));
                            continue loop_17;
                          } else {
                            return () => k_18($effekt.unit, ks_26);
                          }
                        }
                      }
                      return loop_16(0, ks_25, (v_r_12, ks_27) => {
                        queenRows_0.value = tmp_26;
                        return placeQueen_0(0, ks_27, k_13);
                      });
                    });
                  });
                });
              } else {
                return () => k_13(false, ks_20);
              }
            } else {
              return () => k_14($effekt.unit, ks_20);
            }
          }
          return loop_9(1, ks_9, (_4, ks_28) => {
            const x_11 = j_0.value;
            DEALLOC(j_0);
            DEALLOC(queenRows_0);
            DEALLOC(freeMins_0);
            DEALLOC(freeMaxs_0);
            DEALLOC(freeRows_0);
            return () => k_19(x_11, ks_28);
          });
        });
      });
    });
  });
}

function main_0(ks_44, k_35) {
  return RESET((p_1, ks_29, k_20) => {
    const tmp_28 = process.argv.slice(1);
    const tmp_29 = tmp_28.length;
    function toList_worker_0(start_0, acc_0, ks_30, k_21) {
      toList_worker_1: while (true) {
        if ((start_0 < (1))) {
          return () => k_21(acc_0, ks_30);
        } else {
          const tmp_30 = tmp_28[start_0];
          /* prepare call */
          const tmp_start_0 = start_0;
          const tmp_acc_0 = acc_0;
          start_0 = (tmp_start_0 - (1));
          acc_0 = new Cons_0(tmp_30, tmp_acc_0);
          continue toList_worker_1;
        }
      }
    }
    return toList_worker_0((tmp_29 - (1)), new Nil_0(), ks_29, (v_r_13, ks_31) => {
      let v_r_14 = undefined;
      switch (v_r_13.__tag) {
        case 0:  v_r_14 = new None_0();break;
        case 1: 
          const v_y_0 = v_r_13.head_0;
          v_r_14 = new Some_0(v_y_0);
          break;
      }
      let v_r_15 = undefined;
      switch (v_r_14.__tag) {
        case 0:  v_r_15 = "";break;
        case 1:  const v_y_1 = v_r_14.value_0;v_r_15 = v_y_1;break;
      }
      function go_0(index_1, acc_1, ks_36, k_26) {
        return RESET((p_2, ks_32, k_22) => {
          const Exception_1 = {
            raise_0: (exc_0, msg_1, ks_33, k_23) =>
              SHIFT(p_2, (k_24, ks_34, k_25) =>
                () => k_25(new Error_0(exc_0, msg_1), ks_34), ks_33, undefined)
          };
          return charAt_0(v_r_15, index_1, Exception_1, ks_32, (v_r_16, ks_35) =>
            () => k_22(new Success_0(v_r_16), ks_35));
        }, ks_36, (v_r_17, ks_37) => {
          switch (v_r_17.__tag) {
            case 1: 
              const v_y_2 = v_r_17.a_0;
              if ((v_y_2 >= (48))) if ((v_y_2 <= (57))) {
                return go_0((index_1 + (1)), ((((10) * acc_1)) + (((v_y_2) - ((48))))), ks_37, k_26);
              } else {
                return SHIFT(p_1, (k_27, ks_38, k_28) =>
                  () => k_28(10, ks_38), ks_37, undefined);
              } else {
                return SHIFT(p_1, (k_29, ks_39, k_30) =>
                  () => k_30(10, ks_39), ks_37, undefined);
              }
              break;
            case 0:  return () => k_26(acc_1, ks_37);
          }
        });
      }
      const Exception_2 = {
        raise_0: (exception_1, msg_2, ks_40, k_31) =>
          SHIFT(p_1, (k_32, ks_41, k_33) => () => k_33(10, ks_41), ks_40, undefined)
      };
      return charAt_0(v_r_15, 0, Exception_2, ks_31, (v_r_18, ks_42) => {
        if (v_r_18 === (45)) {
          return go_0(1, 0, ks_42, (v_r_19, ks_43) =>
            () => k_20(((0) - v_r_19), ks_43));
        } else {
          return go_0(0, 0, ks_42, k_20);
        }
      });
    });
  }, ks_44, (n_1, ks_45) => {
    function loop_18(i_10, ks_46, k_34) {
      if ((i_10 < ((n_1 - (1))))) {
        return run_0(8, ks_46, (v_r_20, ks_47) =>
          loop_18((i_10 + (1)), ks_47, k_34));
      } else {
        return () => k_34($effekt.unit, ks_46);
      }
    }
    return loop_18(0, ks_45, (v_r_21, ks_48) =>
      run_0(8, ks_48, (r_0, ks_49) => {
        let v_r_22 = undefined;
        if (r_0) {
          v_r_22 = "True";
        } else {
          v_r_22 = "False";
        }
        const tmp_31 = $effekt.println(v_r_22);
        return () => k_35(tmp_31, ks_49);
      }));
  });
}

(typeof module != "undefined" && module !== null ? module : {}).exports = $queens = {
  main: () => RUN_TOPLEVEL(main_0)
};