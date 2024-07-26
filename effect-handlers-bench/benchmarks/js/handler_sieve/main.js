
function* primes(i, n, a) {
    if (i >= n) {
        return a;
    } else if(yield i) {
        let it = primes(i + 1, n, a + i);
        let res = it.next();
        while(!res.done) {
            if (res.value % i == 0) {
                res = it.next(false);
            } else {
                res = it.next(yield (res.value));
            }
        }
        return res.value;
    } else {
        return yield* primes(i + 1, n, a);
    }
}

function run(n) {
    let it = primes(2, n, 0);
    let res = it.next();
    while(!res.done) {
        res = it.next(true);
    }
    return res.value;
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