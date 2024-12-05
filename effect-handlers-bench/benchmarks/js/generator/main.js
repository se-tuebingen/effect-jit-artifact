class Leaf {}
class Node {
    constructor(left, value, right) {
        this.value = value;
        this.left = left;
        this.right = right;
    }
}

function make(n) {
    if (n == 0) {
        return new Leaf();
    } else {
        let sub = make(n - 1);
        return new Node(sub, n, sub);
    }
}

function* iterate(t) {
    if(t instanceof Leaf) {
        return;
    } else {
        // assert(t instanceof Node);
        yield* iterate(t.left);
        yield t.value;
        yield* iterate(t.right);
    }
}

class Empty {}
class Thunk {
    constructor(value, k) {
        this.value = value;
        this.k = k;
    }
}

function generate(f) {
    let it = f();
    function go(result) {
        if (result.done) {
            return new Empty();
        } else {
            return new Thunk(result.value, function() {
                return go(it.next());
            });
        }
    }
    return go(it.next());
}

function sum(a, g) {
    while (!(g instanceof Empty)) {
        a = g.value + a;
        g = g.k();
    }
    return a;
}

function run(n) {
    return sum(0, generate(function* (){
        yield* iterate(make(n));
    }));
}

let args;
if (typeof process !== "undefined") {
    args = process.argv.slice(2);
} else if (typeof scriptArgs !== "undefined") { 
    args = scriptArgs;
} else {
    console.error("Don't know how to get cli args");
}
const n = parseInt(args[0], 10);
if (!isNaN(n)) {
    console.log(run(n));
} else {
    console.log(run(5));
}