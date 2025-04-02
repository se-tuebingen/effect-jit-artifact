const $effekt = {  };

class OutOfBounds_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "OutOfBounds", __data: [] };
  }
  __equals(other4791) {
    if (!other4791) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4791.__tag))) {
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
  __equals(other4792) {
    if (!other4792) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4792.__tag))) {
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
  __equals(other4793) {
    if (!other4793) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4793.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.value_0, other4793.value_0))) {
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
  __equals(other4794) {
    if (!other4794) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4794.__tag))) {
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
  __equals(other4795) {
    if (!other4795) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4795.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.head_0, other4795.head_0))) {
      return false;
    }
    if (!($effekt.equals(this.tail_0, other4795.tail_0))) {
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
  __equals(other4796) {
    if (!other4796) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4796.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.exception_0, other4796.exception_0))) {
      return false;
    }
    if (!($effekt.equals(this.msg_0, other4796.msg_0))) {
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
  __equals(other4797) {
    if (!other4797) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4797.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.a_0, other4797.a_0))) {
      return false;
    }
    return true;
  }
}

class Triple_0 {
  constructor(a_1, b_0, c_0) {
    this.__tag = 0;
    this.a_1 = a_1;
    this.b_0 = b_0;
    this.c_0 = c_0;
  }
  __reflect() {
    return {
      __tag: 0,
      __name: "Triple",
      __data: [this.a_1, this.b_0, this.c_0]
    };
  }
  __equals(other4798) {
    if (!other4798) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4798.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.a_1, other4798.a_1))) {
      return false;
    }
    if (!($effekt.equals(this.b_0, other4798.b_0))) {
      return false;
    }
    if (!($effekt.equals(this.c_0, other4798.c_0))) {
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

function main_0(ks_16, k_40) {
  return RESET((p_0, ks_1, k_1) => {
    const tmp_0 = process.argv.slice(1);
    const tmp_1 = tmp_0.length;
    function toList_worker_0(start_0, acc_0, ks_2, k_2) {
      toList_worker_1: while (true) {
        if ((start_0 < (1))) {
          return () => k_2(acc_0, ks_2);
        } else {
          const tmp_2 = tmp_0[start_0];
          /* prepare call */
          const tmp_start_0 = start_0;
          const tmp_acc_0 = acc_0;
          start_0 = (tmp_start_0 - (1));
          acc_0 = new Cons_0(tmp_2, tmp_acc_0);
          continue toList_worker_1;
        }
      }
    }
    return toList_worker_0((tmp_1 - (1)), new Nil_0(), ks_1, (v_r_1, ks_3) => {
      let v_r_2 = undefined;
      switch (v_r_1.__tag) {
        case 0:  v_r_2 = new None_0();break;
        case 1: 
          const v_y_0 = v_r_1.head_0;
          v_r_2 = new Some_0(v_y_0);
          break;
      }
      let v_r_3 = undefined;
      switch (v_r_2.__tag) {
        case 0:  v_r_3 = "";break;
        case 1:  const v_y_1 = v_r_2.value_0;v_r_3 = v_y_1;break;
      }
      function go_0(index_1, acc_1, ks_8, k_7) {
        return RESET((p_1, ks_4, k_3) => {
          const Exception_1 = {
            raise_0: (exc_0, msg_1, ks_5, k_4) =>
              SHIFT(p_1, (k_5, ks_6, k_6) =>
                () => k_6(new Error_0(exc_0, msg_1), ks_6), ks_5, undefined)
          };
          return charAt_0(v_r_3, index_1, Exception_1, ks_4, (v_r_4, ks_7) =>
            () => k_3(new Success_0(v_r_4), ks_7));
        }, ks_8, (v_r_5, ks_9) => {
          switch (v_r_5.__tag) {
            case 1: 
              const v_y_2 = v_r_5.a_0;
              if ((v_y_2 >= (48))) if ((v_y_2 <= (57))) {
                return go_0((index_1 + (1)), ((((10) * acc_1)) + (((v_y_2) - ((48))))), ks_9, k_7);
              } else {
                return SHIFT(p_0, (k_8, ks_10, k_9) => () => k_9(5, ks_10), ks_9, undefined);
              } else {
                return SHIFT(p_0, (k_10, ks_11, k_11) =>
                  () => k_11(5, ks_11), ks_9, undefined);
              }
              break;
            case 0:  return () => k_7(acc_1, ks_9);
          }
        });
      }
      const Exception_2 = {
        raise_0: (exception_1, msg_2, ks_12, k_12) =>
          SHIFT(p_0, (k_13, ks_13, k_14) => () => k_14(5, ks_13), ks_12, undefined)
      };
      return charAt_0(v_r_3, 0, Exception_2, ks_3, (v_r_6, ks_14) => {
        if (v_r_6 === (45)) {
          return go_0(1, 0, ks_14, (v_r_7, ks_15) =>
            () => k_1(((0) - v_r_7), ks_15));
        } else {
          return go_0(0, 0, ks_14, k_1);
        }
      });
    });
  }, ks_16, (n_0, ks_17) =>
    RESET((p_2, ks_18, k_15) => {
      function choice_worker_0(n_1, ks_20, k_22) {
        if ((n_1 < (1))) {
          return SHIFT(p_2, (k_16, ks_19, k_17) => () => k_17(0, ks_19), ks_20, undefined);
        } else {
          return SHIFT(p_2, (k_18, ks_21, k_19) =>
            RESUME(k_18, (ks_22, k_20) => () => k_20(true, ks_22), ks_21, (v_r_8, ks_23) =>
              RESUME(k_18, (ks_24, k_21) => () => k_21(false, ks_24), ks_23, (v_r_9, ks_25) =>
                () => k_19((((v_r_8 + v_r_9)) % (1000000007)), ks_25))), ks_20, (v_r_10, ks_26) => {
            if (v_r_10) {
              return () => k_22(n_1, ks_26);
            } else {
              return choice_worker_0((n_1 - (1)), ks_26, k_22);
            }
          });
        }
      }
      return choice_worker_0(n_0, ks_18, (i_0, ks_27) => {
        function choice_worker_1(n_2, ks_29, k_29) {
          if ((n_2 < (1))) {
            return SHIFT(p_2, (k_23, ks_28, k_24) => () => k_24(0, ks_28), ks_29, undefined);
          } else {
            return SHIFT(p_2, (k_25, ks_30, k_26) =>
              RESUME(k_25, (ks_31, k_27) => () => k_27(true, ks_31), ks_30, (v_r_11, ks_32) =>
                RESUME(k_25, (ks_33, k_28) => () => k_28(false, ks_33), ks_32, (v_r_12, ks_34) =>
                  () => k_26((((v_r_11 + v_r_12)) % (1000000007)), ks_34))), ks_29, (v_r_13, ks_35) => {
              if (v_r_13) {
                return () => k_29(n_2, ks_35);
              } else {
                return choice_worker_1((n_2 - (1)), ks_35, k_29);
              }
            });
          }
        }
        return choice_worker_1((i_0 - (1)), ks_27, (j_0, ks_36) => {
          function choice_worker_2(n_3, ks_38, k_36) {
            if ((n_3 < (1))) {
              return SHIFT(p_2, (k_30, ks_37, k_31) => () => k_31(0, ks_37), ks_38, undefined);
            } else {
              return SHIFT(p_2, (k_32, ks_39, k_33) =>
                RESUME(k_32, (ks_40, k_34) => () => k_34(true, ks_40), ks_39, (v_r_14, ks_41) =>
                  RESUME(k_32, (ks_42, k_35) => () => k_35(false, ks_42), ks_41, (v_r_15, ks_43) =>
                    () => k_33((((v_r_14 + v_r_15)) % (1000000007)), ks_43))), ks_38, (v_r_16, ks_44) => {
                if (v_r_16) {
                  return () => k_36(n_3, ks_44);
                } else {
                  return choice_worker_2((n_3 - (1)), ks_44, k_36);
                }
              });
            }
          }
          return choice_worker_2((j_0 - (1)), ks_36, (k_37, ks_45) => {
            let v_r_17 = undefined;
            if (((((i_0 + j_0)) + k_37)) === n_0) {
              v_r_17 = new Triple_0(i_0, j_0, k_37);
            } else {
              return SHIFT(p_2, (k_38, ks_46, k_39) => () => k_39(0, ks_46), ks_45, undefined);
            }
            const v_y_3 = v_r_17.a_1;
            const v_y_4 = v_r_17.b_0;
            const v_y_5 = v_r_17.c_0;
            return () =>
              k_15(((((((((53) * v_y_3)) + (((2809) * v_y_4)))) + (((148877) * v_y_5)))) % (1000000007)), ks_45);
          });
        });
      });
    }, ks_17, (r_0, ks_47) => {
      const tmp_3 = $effekt.println(('' + r_0));
      return () => k_40(tmp_3, ks_47);
    }));
}

(typeof module != "undefined" && module !== null ? module : {}).exports = $main = {
  main: () => RUN_TOPLEVEL(main_0)
};