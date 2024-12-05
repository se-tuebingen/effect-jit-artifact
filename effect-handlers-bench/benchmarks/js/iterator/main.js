function* range(l, u) {
    while (l <= u) {
        yield l;
        l = l + 1;
    }
}

function run(n) {
    let s = 0;
    for (const r of range(0, n)) {
        s = s + r;
    }
    return s;
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