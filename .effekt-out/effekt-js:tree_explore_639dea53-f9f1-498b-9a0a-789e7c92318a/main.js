const $effekt = {  };

class OutOfBounds_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "OutOfBounds", __data: [] };
  }
  __equals(other5391) {
    if (!other5391) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5391.__tag))) {
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
  __equals(other5392) {
    if (!other5392) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5392.__tag))) {
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
  __equals(other5393) {
    if (!other5393) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5393.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.value_0, other5393.value_0))) {
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
  __equals(other5394) {
    if (!other5394) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5394.__tag))) {
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
  __equals(other5395) {
    if (!other5395) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5395.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.head_0, other5395.head_0))) {
      return false;
    }
    if (!($effekt.equals(this.tail_0, other5395.tail_0))) {
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
  __equals(other5396) {
    if (!other5396) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5396.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.exception_0, other5396.exception_0))) {
      return false;
    }
    if (!($effekt.equals(this.msg_0, other5396.msg_0))) {
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
  __equals(other5397) {
    if (!other5397) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5397.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.a_0, other5397.a_0))) {
      return false;
    }
    return true;
  }
}

class Leaf_0 {
  constructor() {
    this.__tag = 0;
  }
  __reflect() {
    return { __tag: 0, __name: "Leaf", __data: [] };
  }
  __equals(other5398) {
    if (!other5398) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5398.__tag))) {
      return false;
    }
    return true;
  }
}

class Node_0 {
  constructor(left_0, value_1, right_0) {
    this.__tag = 1;
    this.left_0 = left_0;
    this.value_1 = value_1;
    this.right_0 = right_0;
  }
  __reflect() {
    return {
      __tag: 1,
      __name: "Node",
      __data: [this.left_0, this.value_1, this.right_0]
    };
  }
  __equals(other5399) {
    if (!other5399) {
      return false;
    }
    if (!($effekt.equals(this.__tag, other5399.__tag))) {
      return false;
    }
    if (!($effekt.equals(this.left_0, other5399.left_0))) {
      return false;
    }
    if (!($effekt.equals(this.value_1, other5399.value_1))) {
      return false;
    }
    if (!($effekt.equals(this.right_0, other5399.right_0))) {
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

function reverseOnto_0(l_0, other_0, ks_0, k_0) {
  reverseOnto_1: while (true) {
    switch (l_0.__tag) {
      case 0:  return () => k_0(other_0, ks_0);
      case 1: 
        const v_y_0 = l_0.head_0;
        const v_y_1 = l_0.tail_0;
        /* prepare call */
        const tmp_other_0 = other_0;
        l_0 = v_y_1;
        other_0 = new Cons_0(v_y_0, tmp_other_0);
        continue reverseOnto_1;
    }
  }
}

function charAt_0(str_0, index_0, Exception_0, ks_1, k_1) {
  let v_r_0 = undefined;
  if ((index_0 < (0))) {
    v_r_0 = true;
  } else {
    v_r_0 = (index_0 >= (str_0.length));
  }
  if (v_r_0) {
    return Exception_0.raise_0(new OutOfBounds_0(), ((((((((((("Index out of bounds: ") + (('' + index_0))))) + (" in string: '")))) + (str_0)))) + ("'")), ks_1, undefined);
  } else {
    return () => k_1(str_0.codePointAt(index_0), ks_1);
  }
}

function maximum_0(l_1, ks_2, k_2) {
  maximum_1: while (true) {
    switch (l_1.__tag) {
      case 0:  return () => k_2(-1, ks_2);
      case 1: 
        const v_y_2 = l_1.head_0;
        const v_y_3 = l_1.tail_0;
        switch (v_y_3.__tag) {
          case 0:  return () => k_2(v_y_2, ks_2);
          default: 
            /* prepare call */
            const tmp_k_0 = k_2;
            k_2 = (v_r_1, ks_3) => {
              if ((v_y_2 > v_r_1)) {
                return () => tmp_k_0(v_y_2, ks_3);
              } else {
                return () => tmp_k_0(v_r_1, ks_3);
              }
            };
            l_1 = v_y_3;
            continue maximum_1;
        }
        break;
    }
  }
}

function make_0(n_0, ks_4, k_3) {
  make_1: while (true) {
    if (n_0 === (0)) {
      return () => k_3(new Leaf_0(), ks_4);
    } else {
      /* prepare call */
      const tmp_n_0 = n_0;
      const tmp_k_1 = k_3;
      k_3 = (t_0, ks_5) =>
        () => tmp_k_1(new Node_0(t_0, tmp_n_0, t_0), ks_5);
      n_0 = (tmp_n_0 - (1));
      continue make_1;
    }
  }
}

function main_0(ks_21, k_26) {
  return RESET((p_0, ks_6, k_4) => {
    const tmp_0 = process.argv.slice(1);
    const tmp_1 = tmp_0.length;
    function toList_worker_0(start_0, acc_0, ks_7, k_5) {
      toList_worker_1: while (true) {
        if ((start_0 < (1))) {
          return () => k_5(acc_0, ks_7);
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
    return toList_worker_0((tmp_1 - (1)), new Nil_0(), ks_6, (v_r_2, ks_8) => {
      let v_r_3 = undefined;
      switch (v_r_2.__tag) {
        case 0:  v_r_3 = new None_0();break;
        case 1: 
          const v_y_4 = v_r_2.head_0;
          v_r_3 = new Some_0(v_y_4);
          break;
      }
      let v_r_4 = undefined;
      switch (v_r_3.__tag) {
        case 0:  v_r_4 = "";break;
        case 1:  const v_y_5 = v_r_3.value_0;v_r_4 = v_y_5;break;
      }
      function go_0(index_1, acc_1, ks_13, k_10) {
        return RESET((p_1, ks_9, k_6) => {
          const Exception_1 = {
            raise_0: (exc_0, msg_1, ks_10, k_7) =>
              SHIFT(p_1, (k_8, ks_11, k_9) =>
                () => k_9(new Error_0(exc_0, msg_1), ks_11), ks_10, undefined)
          };
          return charAt_0(v_r_4, index_1, Exception_1, ks_9, (v_r_5, ks_12) =>
            () => k_6(new Success_0(v_r_5), ks_12));
        }, ks_13, (v_r_6, ks_14) => {
          switch (v_r_6.__tag) {
            case 1: 
              const v_y_6 = v_r_6.a_0;
              if ((v_y_6 >= (48))) if ((v_y_6 <= (57))) {
                return go_0((index_1 + (1)), ((((10) * acc_1)) + (((v_y_6) - ((48))))), ks_14, k_10);
              } else {
                return SHIFT(p_0, (k_11, ks_15, k_12) =>
                  () => k_12(5, ks_15), ks_14, undefined);
              } else {
                return SHIFT(p_0, (k_13, ks_16, k_14) =>
                  () => k_14(5, ks_16), ks_14, undefined);
              }
              break;
            case 0:  return () => k_10(acc_1, ks_14);
          }
        });
      }
      const Exception_2 = {
        raise_0: (exception_1, msg_2, ks_17, k_15) =>
          SHIFT(p_0, (k_16, ks_18, k_17) => () => k_17(5, ks_18), ks_17, undefined)
      };
      return charAt_0(v_r_4, 0, Exception_2, ks_8, (v_r_7, ks_19) => {
        if (v_r_7 === (45)) {
          return go_0(1, 0, ks_19, (v_r_8, ks_20) =>
            () => k_4(((0) - v_r_8), ks_20));
        } else {
          return go_0(0, 0, ks_19, k_4);
        }
      });
    });
  }, ks_21, (n_1, ks_22) =>
    make_0(n_1, ks_22, (tree_0, ks_23) => {
      const state_0 = ks_23.arena.fresh(0);
      function loop_0(i_0, ks_24, k_18) {
        if (i_0 === (0)) {
          const x_0 = state_0.value;
          return () => k_18(x_0, ks_24);
        } else {
          return RESET((p_2, ks_25, k_19) => {
            function explore_worker_0(t_1, ks_26, k_20) {
              switch (t_1.__tag) {
                case 0: 
                  const x_1 = state_0.value;
                  return () => k_20(x_1, ks_26);
                case 1: 
                  const v_y_7 = t_1.left_0;
                  const v_y_8 = t_1.value_1;
                  const v_y_9 = t_1.right_0;
                  return SHIFT(p_2, (k_21, ks_27, k_22) =>
                    RESUME(k_21, (ks_28, k_23) => () => k_23(true, ks_28), ks_27, (v_r_9, ks_29) =>
                      RESUME(k_21, (ks_30, k_24) =>
                        () => k_24(false, ks_30), ks_29, (v_r_10, ks_31) => {
                        const res_0 = ks_31.arena.fresh(new Nil_0());
                        function foreach_worker_0(l_2, ks_32, k_25) {
                          foreach_worker_1: while (true) {
                            switch (l_2.__tag) {
                              case 0: 
                                return () => k_25($effekt.unit, ks_32);
                              case 1: 
                                const v_y_10 = l_2.head_0;
                                const v_y_11 = l_2.tail_0;
                                const x_2 = res_0.value;
                                res_0.value = new Cons_0(v_y_10, x_2);
                                /* prepare call */
                                l_2 = v_y_11;
                                continue foreach_worker_1;
                            }
                          }
                        }
                        return foreach_worker_0(v_r_9, ks_31, (_0, ks_33) => {
                          const x_3 = res_0.value;
                          DEALLOC(res_0);
                          return reverseOnto_0(x_3, v_r_10, ks_33, k_22);
                        });
                      })), ks_26, (v_r_11, ks_34) => {
                    let next_0 = undefined;
                    if (v_r_11) {
                      next_0 = v_y_7;
                    } else {
                      next_0 = v_y_9;
                    }
                    const x_4 = state_0.value;
                    const tmp_3 = (((x_4 - (((503) * v_y_8)))) + (37));
                    let v_r_12 = undefined;
                    if ((tmp_3 < (0))) {
                      v_r_12 = ((0) - tmp_3);
                    } else {
                      v_r_12 = tmp_3;
                    }
                    state_0.value = (v_r_12 % (1009));
                    return explore_worker_0(next_0, ks_34, (v_r_13, ks_35) => {
                      const tmp_4 = (((v_y_8 - (((503) * v_r_13)))) + (37));
                      if ((tmp_4 < (0))) {
                        return () =>
                          k_20(((((0) - tmp_4)) % (1009)), ks_35);
                      } else {
                        return () => k_20((tmp_4 % (1009)), ks_35);
                      }
                    });
                  });
              }
            }
            return explore_worker_0(tree_0, ks_25, (v_r_14, ks_36) =>
              () => k_19(new Cons_0(v_r_14, new Nil_0()), ks_36));
          }, ks_24, (v_r_15, ks_37) =>
            maximum_0(v_r_15, ks_37, (v_r_16, ks_38) => {
              state_0.value = v_r_16;
              return loop_0((i_0 - (1)), ks_38, k_18);
            }));
        }
      }
      return loop_0(10, ks_23, (tmp_5, ks_39) => {
        DEALLOC(state_0);
        const tmp_6 = $effekt.println(('' + tmp_5));
        return () => k_26(tmp_6, ks_39);
      });
    }));
}

(typeof module != "undefined" && module !== null ? module : {}).exports = $main = {
  main: () => RUN_TOPLEVEL(main_0)
};