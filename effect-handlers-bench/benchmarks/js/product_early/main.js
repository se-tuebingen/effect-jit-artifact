
class Cons {
    constructor(hd, tl) {
        this.hd = hd;
        this.tl = tl;
    }
}

function product(xs) {
    if (xs === null) {
        return 0;
    } else {
        if (xs.hd == 0) {
            throw 0;
        } else {
            return xs.hd * product(xs.tl);
        }
    }
}

function enumerate(i) {
    if (i < 0) {
        return null;
    } else {
        return new Cons(i, enumerate(i - 1));
    }
}

function run_product(xs) {
    try {
        return product(xs);
    } catch (e) {
        return e;
    }
}

function run(n) {
    let xs = enumerate(1000);
    let i = n;
    let a = 0;
    while (i != 0) {
        i = i - 1;
        a = a + run_product(xs);
    }
    return a;
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