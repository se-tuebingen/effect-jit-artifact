const $effekt = {  };

class OutOfBounds_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "OutOfBounds", __data: [] };
  }
  __equals(other4663) {
    if (!other4663) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4663.__tag))) {
      return false;
    }
    return true;
  }
}

class WrongFormat_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "WrongFormat", __data: [] };
  }
  __equals(other4664) {
    if (!other4664) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4664.__tag))) {
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
  __equals(other4665) {
    if (!other4665) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4665.__tag))) {
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
  __equals(other4666) {
    if (!other4666) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4666.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.value_0, other4666.value_0))) {
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
  __equals(other4667) {
    if (!other4667) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4667.__tag))) {
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
  __equals(other4668) {
    if (!other4668) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4668.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.head_0, other4668.head_0))) {
      return false;
    }
    if (!($effekt.equals(this.tail_0, other4668.tail_0))) {
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
  __equals(other4669) {
    if (!other4669) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4669.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.exception_0, other4669.exception_0))) {
      return false;
    }
    if (!($effekt.equals(this.msg_0, other4669.msg_0))) {
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
  __equals(other4670) {
    if (!other4670) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4670.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.a_0, other4670.a_0))) {
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

function toInt_0(str_0, Exception_1, ks_11, k_9) {
  function go_0(index_0, acc_0, ks_4, k_4) {
    return RESET((p_0, ks_0, k_0) => {
      const Exception_0 = {
        raise_0: (exc_0, msg_1, ks_1, k_1) =>
          SHIFT(p_0, (k_2, ks_2, k_3) =>
            () => k_3(new Error_0(exc_0, msg_1), ks_2), ks_1, undefined)
      };
      return charAt_0(str_0, index_0, Exception_0, ks_0, (v_r_0, ks_3) =>
        () => k_0(new Success_0(v_r_0), ks_3));
    }, ks_4, (v_r_1, ks_5) => {
      switch (v_r_1.__tag) {
        case 1: 
          const v_y_0 = v_r_1.a_0;
          if ((v_y_0 >= (48))) if ((v_y_0 <= (57))) {
            return go_0((index_0 + (1)), ((((10) * acc_0)) + (((v_y_0) - ((48))))), ks_5, k_4);
          } else {
            return Exception_1.raise_0(new WrongFormat_0(), ((((("Not a valid number: '") + (str_0)))) + ("'")), ks_5, undefined);
          } else {
            return Exception_1.raise_0(new WrongFormat_0(), ((((("Not a valid number: '") + (str_0)))) + ("'")), ks_5, undefined);
          }
          break;
        case 0:  return () => k_4(acc_0, ks_5);
      }
    });
  }
  return RESET((p_1, ks_6, k_5) => {
    const Exception_2 = {
      raise_0: (exception_1, msg_2, ks_7, k_6) =>
        SHIFT(p_1, (k_7, ks_8, k_8) =>
          Exception_1.raise_0(new WrongFormat_0(), "Empty string is not a valid number", ks_8, undefined), ks_7, undefined)
    };
    return charAt_0(str_0, 0, Exception_2, ks_6, (v_r_2, ks_9) => {
      if (v_r_2 === (45)) {
        return go_0(1, 0, ks_9, (v_r_3, ks_10) =>
          () => k_5(((0) - v_r_3), ks_10));
      } else {
        return go_0(0, 0, ks_9, k_5);
      }
    });
  }, ks_11, k_9);
}

function charAt_0(str_1, index_1, Exception_3, ks_12, k_10) {
  let v_r_4 = undefined;
  if ((index_1 < (0))) {
    v_r_4 = true;
  } else {
    v_r_4 = (index_1 >= (str_1.length));
  }
  if (v_r_4) {
    return Exception_3.raise_0(new OutOfBounds_0(), ((((((((((("Index out of bounds: ") + (('' + index_1))))) + (" in string: '")))) + (str_1)))) + ("'")), ks_12, undefined);
  } else {
    return () => k_10(str_1.codePointAt(index_1), ks_12);
  }
}

function main_0(ks_18, k_27) {
  return RESET((p_2, ks_13, k_11) => {
    const Exception_4 = {
      raise_0: (exception_2, msg_3, ks_14, k_12) =>
        SHIFT(p_2, (k_13, ks_15, k_14) => () => k_14(5, ks_15), ks_14, undefined)
    };
    const tmp_0 = process.argv.slice(1);
    const tmp_1 = tmp_0.length;
    function toList_worker_0(start_0, acc_1, ks_16, k_15) {
      toList_worker_1: while (true) {
        if ((start_0 < (1))) {
          return () => k_15(acc_1, ks_16);
        } else {
          const tmp_2 = tmp_0[start_0];
          /* prepare call */
          const tmp_start_0 = start_0;
          const tmp_acc_0 = acc_1;
          start_0 = (tmp_start_0 - (1));
          acc_1 = new Cons_0(tmp_2, tmp_acc_0);
          continue toList_worker_1;
        }
      }
    }
    return toList_worker_0((tmp_1 - (1)), new Nil_0(), ks_13, (v_r_5, ks_17) => {
      let v_r_6 = undefined;
      switch (v_r_5.__tag) {
        case 0:  v_r_6 = new None_0();break;
        case 1: 
          const v_y_1 = v_r_5.head_0;
          v_r_6 = new Some_0(v_y_1);
          break;
      }
      let v_r_7 = undefined;
      switch (v_r_6.__tag) {
        case 0:  v_r_7 = "";break;
        case 1:  const v_y_2 = v_r_6.value_0;v_r_7 = v_y_2;break;
      }
      return toInt_0(v_r_7, Exception_4, ks_17, k_11);
    });
  }, ks_18, (n_0, ks_19) =>
    RESET((p_3, ks_20, k_16) => {
      const Exception_5 = {
        raise_0: (exception_3, msg_4, ks_21, k_17) =>
          SHIFT(p_3, (k_18, ks_22, k_19) => () => k_19(10, ks_22), ks_21, undefined)
      };
      return RESET((p_4, ks_23, k_20) => {
        const tmp_3 = process.argv.slice(1);
        const tmp_4 = tmp_3.length;
        function toList_worker_2(start_1, acc_2, ks_24, k_21) {
          toList_worker_3: while (true) {
            if ((start_1 < (1))) {
              return () => k_21(acc_2, ks_24);
            } else {
              const tmp_5 = tmp_3[start_1];
              /* prepare call */
              const tmp_start_1 = start_1;
              const tmp_acc_1 = acc_2;
              start_1 = (tmp_start_1 - (1));
              acc_2 = new Cons_0(tmp_5, tmp_acc_1);
              continue toList_worker_3;
            }
          }
        }
        return toList_worker_2((tmp_4 - (1)), new Nil_0(), ks_23, (v_r_8, ks_25) => {
          function go_1(list_0, i_0, ks_27, k_24) {
            go_2: while (true) {
              switch (list_0.__tag) {
                case 0: 
                  return SHIFT(p_4, (k_22, ks_26, k_23) =>
                    () => k_23(10, ks_26), ks_27, undefined);
                case 1: 
                  const v_y_3 = list_0.head_0;
                  const v_y_4 = list_0.tail_0;
                  if (i_0 === (0)) {
                    return () => k_24(v_y_3, ks_27);
                  } else {
                    /* prepare call */
                    const tmp_i_0 = i_0;
                    list_0 = v_y_4;
                    i_0 = (tmp_i_0 - (1));
                    continue go_2;
                  }
                  break;
              }
            }
          }
          return go_1(v_r_8, 1, ks_25, (v_r_9, ks_28) =>
            toInt_0(v_r_9, Exception_5, ks_28, k_20));
        });
      }, ks_20, k_16);
    }, ks_19, (d_0, ks_29) => {
      const s_0 = ks_29.arena.fresh(n_0);
      function handled_worker_0(d_1, ks_31, k_26) {
        handled_worker_1: while (true) {
          if (d_1 === (0)) {
            function countdown_worker_0(ks_30, k_25) {
              countdown_worker_1: while (true) {
                const x_0 = s_0.value;
                if (x_0 === (0)) {
                  return () => k_25(x_0, ks_30);
                } else {
                  s_0.value = (x_0 - (1));
                  /* prepare call */
                  continue countdown_worker_1;
                }
              }
            }
            return countdown_worker_0(ks_31, k_26);
          } else {
            /* prepare call */
            const tmp_d_0 = d_1;
            d_1 = (tmp_d_0 - (1));
            continue handled_worker_1;
          }
        }
      }
      return handled_worker_0(d_0, ks_29, (tmp_6, ks_32) => {
        DEALLOC(s_0);
        const tmp_7 = $effekt.println(('' + tmp_6));
        return () => k_27(tmp_7, ks_32);
      });
    }));
}

(typeof module != "undefined" && module !== null ? module : {}).exports = $main = {
  main: () => RUN_TOPLEVEL(main_0)
};