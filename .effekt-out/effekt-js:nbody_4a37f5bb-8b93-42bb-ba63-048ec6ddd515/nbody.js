const $effekt = {  };

class OutOfBounds_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "OutOfBounds", __data: [] };
  }
  __equals(other15906) {
    if (!other15906) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other15906.__tag))) {
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
  __equals(other15907) {
    if (!other15907) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other15907.__tag))) {
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
  __equals(other15908) {
    if (!other15908) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other15908.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.value_0, other15908.value_0))) {
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
  __equals(other15909) {
    if (!other15909) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other15909.__tag))) {
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
  __equals(other15910) {
    if (!other15910) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other15910.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.head_0, other15910.head_0))) {
      return false;
    }
    if (!($effekt.equals(this.tail_0, other15910.tail_0))) {
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
  __equals(other15911) {
    if (!other15911) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other15911.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.exception_0, other15911.exception_0))) {
      return false;
    }
    if (!($effekt.equals(this.msg_0, other15911.msg_0))) {
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
  __equals(other15912) {
    if (!other15912) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other15912.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.a_0, other15912.a_0))) {
      return false;
    }
    return true;
  }
}

class Body_0 {
  constructor(x_0, y_0, z_0, vx_0, vy_0, vz_0, mass_0) {
    this.__tag = 0;
    this.x_0 = x_0;
    this.y_0 = y_0;
    this.z_0 = z_0;
    this.vx_0 = vx_0;
    this.vy_0 = vy_0;
    this.vz_0 = vz_0;
    this.mass_0 = mass_0;
  }
  __reflect() {
    return {
      __tag: 0,
      __name: "Body",
      __data: [this.x_0, this.y_0, this.z_0, this.vx_0, this.vy_0, this.vz_0, this.mass_0]
    };
  }
  __equals(other15913) {
    if (!other15913) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other15913.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.x_0, other15913.x_0))) {
      return false;
    }
    if (!($effekt.equals(this.y_0, other15913.y_0))) {
      return false;
    }
    if (!($effekt.equals(this.z_0, other15913.z_0))) {
      return false;
    }
    if (!($effekt.equals(this.vx_0, other15913.vx_0))) {
      return false;
    }
    if (!($effekt.equals(this.vy_0, other15913.vy_0))) {
      return false;
    }
    if (!($effekt.equals(this.vz_0, other15913.vz_0))) {
      return false;
    }
    if (!($effekt.equals(this.mass_0, other15913.mass_0))) {
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

function main_0(ks_16, k_22) {
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
                return SHIFT(p_0, (k_8, ks_10, k_9) => () => k_9(10, ks_10), ks_9, undefined);
              } else {
                return SHIFT(p_0, (k_10, ks_11, k_11) =>
                  () => k_11(10, ks_11), ks_9, undefined);
              }
              break;
            case 0:  return () => k_7(acc_1, ks_9);
          }
        });
      }
      const Exception_2 = {
        raise_0: (exception_1, msg_2, ks_12, k_12) =>
          SHIFT(p_0, (k_13, ks_13, k_14) => () => k_14(10, ks_13), ks_12, undefined)
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
  }, ks_16, (n_0, ks_17) => {
    const PI_0 = 3.141592653589793;
    const tmp_3 = ((((4.0) * PI_0)) * PI_0);
    const DAYS_PER_YEAR_0 = 365.24;
    const tmp_4 = (new Array((5)));
    const tmp_5 = array$set(tmp_4, (0), (new Body_0(0.0, 0.0, 0.0, ((0.0) * DAYS_PER_YEAR_0), ((0.0) * DAYS_PER_YEAR_0), ((0.0) * DAYS_PER_YEAR_0), ((1.0) * tmp_3))));
    const tmp_6 = array$set(tmp_4, (1), (new Body_0(4.841431442464721, -1.1603200440274284, -0.10362204447112311, ((0.001660076642744037) * DAYS_PER_YEAR_0), ((0.007699011184197404) * DAYS_PER_YEAR_0), ((-6.90460016972063E-5) * DAYS_PER_YEAR_0), ((9.547919384243266E-4) * tmp_3))));
    const tmp_7 = array$set(tmp_4, (2), (new Body_0(8.34336671824458, 4.124798564124305, -0.4035234171143214, ((-0.002767425107268624) * DAYS_PER_YEAR_0), ((0.004998528012349172) * DAYS_PER_YEAR_0), ((2.304172975737639E-5) * DAYS_PER_YEAR_0), ((2.858859806661308E-4) * tmp_3))));
    const tmp_8 = array$set(tmp_4, (3), (new Body_0(12.89436956213913, -15.11115140169863, -0.22330757889265573, ((0.002964601375647616) * DAYS_PER_YEAR_0), ((0.0023784717395948095) * DAYS_PER_YEAR_0), ((-2.9658956854023756E-5) * DAYS_PER_YEAR_0), ((4.366244043351563E-5) * tmp_3))));
    const tmp_9 = array$set(tmp_4, (4), (new Body_0(15.379697114850917, -25.919314609987964, 0.17925877295037118, ((0.002680677724903893) * DAYS_PER_YEAR_0), ((0.001628241700382423) * DAYS_PER_YEAR_0), ((-9.515922545197159E-5) * DAYS_PER_YEAR_0), ((5.151389020466115E-5) * tmp_3))));
    const px_0 = ks_17.arena.fresh(0.0);
    const py_0 = ks_17.arena.fresh(0.0);
    const pz_0 = ks_17.arena.fresh(0.0);
    function loop_0(i_0, ks_18, k_15) {
      loop_1: while (true) {
        if ((i_0 < (tmp_4.length))) {
          const tmp_10 = tmp_4[i_0];
          const x_1 = px_0.value;
          const x_2 = tmp_10.vx_0;
          const x_3 = tmp_10.mass_0;
          px_0.value = (x_1 + ((x_2 * x_3)));
          const x_4 = py_0.value;
          const x_5 = tmp_10.vy_0;
          const x_6 = tmp_10.mass_0;
          py_0.value = (x_4 + ((x_5 * x_6)));
          const x_7 = pz_0.value;
          const x_8 = tmp_10.vz_0;
          const x_9 = tmp_10.mass_0;
          pz_0.value = (x_7 + ((x_8 * x_9)));
          /* prepare call */
          const tmp_i_0 = i_0;
          i_0 = (tmp_i_0 + (1));
          continue loop_1;
        } else {
          return () => k_15($effekt.unit, ks_18);
        }
      }
    }
    return loop_0(0, ks_17, (_0, ks_19) => {
      const x_10 = px_0.value;
      const x_11 = py_0.value;
      const x_12 = pz_0.value;
      const tmp_11 = array$set(tmp_4, (0), (new Body_0(0.0, 0.0, 0.0, ((0.0) - ((x_10 / tmp_3))), ((0.0) - ((x_11 / tmp_3))), ((0.0) - ((x_12 / tmp_3))), ((1.0) * tmp_3))));
      DEALLOC(pz_0);
      DEALLOC(py_0);
      DEALLOC(px_0);
      function loop_2(i_1, ks_23, k_19) {
        if ((i_1 < n_0)) {
          function loop_3(i_2, ks_21, k_17) {
            if ((i_2 < (tmp_4.length))) {
              function loop_4(i_3, ks_20, k_16) {
                loop_5: while (true) {
                  if ((i_3 < (tmp_4.length))) {
                    const tmp_12 = tmp_4[i_2];
                    const tmp_13 = tmp_4[i_3];
                    const x_13 = tmp_12.x_0;
                    const x_14 = tmp_13.x_0;
                    const tmp_14 = (x_13 - x_14);
                    const x_15 = tmp_12.y_0;
                    const x_16 = tmp_13.y_0;
                    const tmp_15 = (x_15 - x_16);
                    const x_17 = tmp_12.z_0;
                    const x_18 = tmp_13.z_0;
                    const tmp_16 = (x_17 - x_18);
                    const tmp_17 = (((((tmp_14 * tmp_14)) + ((tmp_15 * tmp_15)))) + ((tmp_16 * tmp_16)));
                    const tmp_18 = ((0.01) / ((tmp_17 * (Math.sqrt(tmp_17)))));
                    const x_19 = tmp_12.x_0;
                    const x_20 = tmp_12.y_0;
                    const x_21 = tmp_12.z_0;
                    const x_22 = tmp_12.vx_0;
                    const x_23 = tmp_13.mass_0;
                    const x_24 = tmp_12.vy_0;
                    const x_25 = tmp_13.mass_0;
                    const x_26 = tmp_12.vz_0;
                    const x_27 = tmp_13.mass_0;
                    const x_28 = tmp_12.mass_0;
                    const tmp_19 = array$set(tmp_4, i_2, (new Body_0(x_19, x_20, x_21, (x_22 - ((((tmp_14 * x_23)) * tmp_18))), (x_24 - ((((tmp_15 * x_25)) * tmp_18))), (x_26 - ((((tmp_16 * x_27)) * tmp_18))), x_28)));
                    const x_29 = tmp_13.x_0;
                    const x_30 = tmp_13.y_0;
                    const x_31 = tmp_13.z_0;
                    const x_32 = tmp_13.vx_0;
                    const x_33 = tmp_12.mass_0;
                    const x_34 = tmp_13.vy_0;
                    const x_35 = tmp_12.mass_0;
                    const x_36 = tmp_13.vz_0;
                    const x_37 = tmp_12.mass_0;
                    const x_38 = tmp_13.mass_0;
                    const tmp_20 = array$set(tmp_4, i_3, (new Body_0(x_29, x_30, x_31, (x_32 + ((((tmp_14 * x_33)) * tmp_18))), (x_34 + ((((tmp_15 * x_35)) * tmp_18))), (x_36 + ((((tmp_16 * x_37)) * tmp_18))), x_38)));
                    /* prepare call */
                    const tmp_i_1 = i_3;
                    i_3 = (tmp_i_1 + (1));
                    continue loop_5;
                  } else {
                    return () => k_16($effekt.unit, ks_20);
                  }
                }
              }
              return loop_4((i_2 + (1)), ks_21, (_1, ks_22) =>
                loop_3((i_2 + (1)), ks_22, k_17));
            } else {
              return () => k_17($effekt.unit, ks_21);
            }
          }
          return loop_3(0, ks_23, (v_r_8, ks_24) => {
            function loop_6(i_4, ks_25, k_18) {
              loop_7: while (true) {
                if ((i_4 < (tmp_4.length))) {
                  const tmp_21 = tmp_4[i_4];
                  const x_39 = tmp_21.x_0;
                  const x_40 = tmp_21.vx_0;
                  const x_41 = tmp_21.y_0;
                  const x_42 = tmp_21.vy_0;
                  const x_43 = tmp_21.z_0;
                  const x_44 = tmp_21.vz_0;
                  const x_45 = tmp_21.vx_0;
                  const x_46 = tmp_21.vy_0;
                  const x_47 = tmp_21.vz_0;
                  const x_48 = tmp_21.mass_0;
                  const tmp_22 = array$set(tmp_4, i_4, (new Body_0((x_39 + (((0.01) * x_40))), (x_41 + (((0.01) * x_42))), (x_43 + (((0.01) * x_44))), x_45, x_46, x_47, x_48)));
                  /* prepare call */
                  const tmp_i_2 = i_4;
                  i_4 = (tmp_i_2 + (1));
                  continue loop_7;
                } else {
                  return () => k_18($effekt.unit, ks_25);
                }
              }
            }
            return loop_6(0, ks_24, (_2, ks_26) =>
              loop_2((i_1 + (1)), ks_26, k_19));
          });
        } else {
          return () => k_19($effekt.unit, ks_23);
        }
      }
      return loop_2(0, ks_19, (v_r_9, ks_27) => {
        const e_0 = ks_27.arena.fresh(0.0);
        function loop_8(i_5, ks_29, k_21) {
          if ((i_5 < (tmp_4.length))) {
            const tmp_23 = tmp_4[i_5];
            const x_49 = e_0.value;
            const x_50 = tmp_23.mass_0;
            const x_51 = tmp_23.vx_0;
            const x_52 = tmp_23.vx_0;
            const x_53 = tmp_23.vy_0;
            const x_54 = tmp_23.vy_0;
            const x_55 = tmp_23.vz_0;
            const x_56 = tmp_23.vz_0;
            e_0.value = (x_49 + (((((0.5) * x_50)) * ((((((x_51 * x_52)) + ((x_53 * x_54)))) + ((x_55 * x_56)))))));
            function loop_9(i_6, ks_28, k_20) {
              loop_10: while (true) {
                if ((i_6 < (tmp_4.length))) {
                  const tmp_24 = tmp_4[i_6];
                  const x_57 = tmp_23.x_0;
                  const x_58 = tmp_24.x_0;
                  const tmp_25 = (x_57 - x_58);
                  const x_59 = tmp_23.y_0;
                  const x_60 = tmp_24.y_0;
                  const tmp_26 = (x_59 - x_60);
                  const x_61 = tmp_23.z_0;
                  const x_62 = tmp_24.z_0;
                  const tmp_27 = (x_61 - x_62);
                  const x_63 = e_0.value;
                  const x_64 = tmp_23.mass_0;
                  const x_65 = tmp_24.mass_0;
                  e_0.value = (x_63 - ((((x_64 * x_65)) / (Math.sqrt(((((((tmp_25 * tmp_25)) + ((tmp_26 * tmp_26)))) + ((tmp_27 * tmp_27)))))))));
                  /* prepare call */
                  const tmp_i_3 = i_6;
                  i_6 = (tmp_i_3 + (1));
                  continue loop_10;
                } else {
                  return () => k_20($effekt.unit, ks_28);
                }
              }
            }
            return loop_9((i_5 + (1)), ks_29, (_3, ks_30) =>
              loop_8((i_5 + (1)), ks_30, k_21));
          } else {
            return () => k_21($effekt.unit, ks_29);
          }
        }
        return loop_8(0, ks_27, (_4, ks_31) => {
          const x_66 = e_0.value;
          DEALLOC(e_0);
          const tmp_28 = $effekt.println(('' + x_66));
          return () => k_22(tmp_28, ks_31);
        });
      });
    });
  });
}

(typeof module != "undefined" && module !== null ? module : {}).exports = $nbody = {
  main: () => RUN_TOPLEVEL(main_0)
};