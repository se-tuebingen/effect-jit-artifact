const $effekt = {  };

class OutOfBounds_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "OutOfBounds", __data: [] };
  }
  __equals(other4420) {
    if (!other4420) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4420.__tag))) {
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
  __equals(other4421) {
    if (!other4421) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4421.__tag))) {
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
  __equals(other4422) {
    if (!other4422) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4422.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.value_0, other4422.value_0))) {
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
  __equals(other4423) {
    if (!other4423) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4423.__tag))) {
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
  __equals(other4424) {
    if (!other4424) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4424.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.head_0, other4424.head_0))) {
      return false;
    }
    if (!($effekt.equals(this.tail_0, other4424.tail_0))) {
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
  __equals(other4425) {
    if (!other4425) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4425.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.exception_0, other4425.exception_0))) {
      return false;
    }
    if (!($effekt.equals(this.msg_0, other4425.msg_0))) {
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
  __equals(other4426) {
    if (!other4426) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other4426.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.a_0, other4426.a_0))) {
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

function fibonacci_0(n_0, ks_1, k_1) {
  fibonacci_1: while (true) {
    if (n_0 === (0)) {
      return () => k_1(0, ks_1);
    } else if (n_0 === (1)) {
      return () => k_1(1, ks_1);
    } else {
      /* prepare call */
      const tmp_n_0 = n_0;
      const tmp_k_0 = k_1;
      k_1 = (v_r_1, ks_2) =>
        fibonacci_0((tmp_n_0 - (2)), ks_2, (v_r_2, ks_3) =>
          () => tmp_k_0((v_r_1 + v_r_2), ks_3));
      n_0 = (tmp_n_0 - (1));
      continue fibonacci_1;
    }
  }
}

function main_0(ks_19, k_16) {
  return RESET((p_0, ks_4, k_2) => {
    const tmp_0 = process.argv.slice(1);
    const tmp_1 = tmp_0.length;
    function toList_worker_0(start_0, acc_0, ks_5, k_3) {
      toList_worker_1: while (true) {
        if ((start_0 < (1))) {
          return () => k_3(acc_0, ks_5);
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
    return toList_worker_0((tmp_1 - (1)), new Nil_0(), ks_4, (v_r_3, ks_6) => {
      let v_r_4 = undefined;
      switch (v_r_3.__tag) {
        case 0:  v_r_4 = new None_0();break;
        case 1: 
          const v_y_0 = v_r_3.head_0;
          v_r_4 = new Some_0(v_y_0);
          break;
      }
      let v_r_5 = undefined;
      switch (v_r_4.__tag) {
        case 0:  v_r_5 = "";break;
        case 1:  const v_y_1 = v_r_4.value_0;v_r_5 = v_y_1;break;
      }
      function go_0(index_1, acc_1, ks_11, k_8) {
        return RESET((p_1, ks_7, k_4) => {
          const Exception_1 = {
            raise_0: (exc_0, msg_1, ks_8, k_5) =>
              SHIFT(p_1, (k_6, ks_9, k_7) =>
                () => k_7(new Error_0(exc_0, msg_1), ks_9), ks_8, undefined)
          };
          return charAt_0(v_r_5, index_1, Exception_1, ks_7, (v_r_6, ks_10) =>
            () => k_4(new Success_0(v_r_6), ks_10));
        }, ks_11, (v_r_7, ks_12) => {
          switch (v_r_7.__tag) {
            case 1: 
              const v_y_2 = v_r_7.a_0;
              if ((v_y_2 >= (48))) if ((v_y_2 <= (57))) {
                return go_0((index_1 + (1)), ((((10) * acc_1)) + (((v_y_2) - ((48))))), ks_12, k_8);
              } else {
                return SHIFT(p_0, (k_9, ks_13, k_10) =>
                  () => k_10(5, ks_13), ks_12, undefined);
              } else {
                return SHIFT(p_0, (k_11, ks_14, k_12) =>
                  () => k_12(5, ks_14), ks_12, undefined);
              }
              break;
            case 0:  return () => k_8(acc_1, ks_12);
          }
        });
      }
      const Exception_2 = {
        raise_0: (exception_1, msg_2, ks_15, k_13) =>
          SHIFT(p_0, (k_14, ks_16, k_15) => () => k_15(5, ks_16), ks_15, undefined)
      };
      return charAt_0(v_r_5, 0, Exception_2, ks_6, (v_r_8, ks_17) => {
        if (v_r_8 === (45)) {
          return go_0(1, 0, ks_17, (v_r_9, ks_18) =>
            () => k_2(((0) - v_r_9), ks_18));
        } else {
          return go_0(0, 0, ks_17, k_2);
        }
      });
    });
  }, ks_19, (n_1, ks_20) =>
    fibonacci_0(n_1, ks_20, (r_0, ks_21) => {
      const tmp_3 = $effekt.println(('' + r_0));
      return () => k_16(tmp_3, ks_21);
    }));
}

(typeof module != "undefined" && module !== null ? module : {}).exports = $main = {
  main: () => RUN_TOPLEVEL(main_0)
};