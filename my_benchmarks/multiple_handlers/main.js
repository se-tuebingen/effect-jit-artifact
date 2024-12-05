function* generator(n) {
    let i = 0;
    while (i <= n) {
        yield i;
        i = i + 1;
    }
}

function summing(body) {
    let res = 0;
    for(const x of body()) {
        res = (res + x) % 1009;
    }
    return res;
}

function counting(body) {
    let res = 0;
    for(const x of body()) {
        res = (res + 1) % 1009;
    }
    return res;
}

function sq_summing(body) {
    let res = 0;
    for(const x of body()) {
        res = (res + x * x) % 1009;
    }
    return res;
}

function run(n) {
    let sqs = sq_summing(function*() { yield* generator(n) });
    let s = summing(function*() { yield* generator(n) });
    let c = counting(function*() { yield* generator(n) });
    return sqs * 1009 + s * 103 + c;
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